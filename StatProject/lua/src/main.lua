dofile("../lib/luvit-loader.lua");

local http			= require("http");
local https			= require("https");
local utils			= require("utils");
local table			= require("table");
local pathJoin		= require("luvi").path.join
local fs			= require("fs");

local params = {};
if (args[2] and args[2] == "-colorize=off") then
	 params["colorize"] = false;
end

-- Takes in an optional table of pairs, returns the global environment
-- The first pair value is the name of the variable, the second pair value is the value
GetEnvironment = function(...)
	local env = _G;
	env.require = require;
	env.LuaServer = LuaServer;
	env.utils = utils;
	env.fs = fs;
	env.Hooks = Hooks;
	env.LoadScript = LoadScript;
	env.Include = Include;
	env.GetEnvironment = GetEnvironment;
	env.params = params;

	for _,v in pairs({...}) do
		env[v[1]] = v[2];
	end

	return env;
end

-- Load the includes
LoadScript = function(filename)
	local f, ferr = loadfile(filename);
	if (f) then
		setfenv(f, GetEnvironment());

		local ok, res = xpcall(f, debug.traceback);
		
		if (ok) then
			return res;
		else
			utils.print(utils.colorize("err", res));
		end
	else
		utils.print(utils.colorize("err", ferr));
	end
end

Include = function(filename)
	return LoadScript("../include/" .. filename);
end

Include("Utils.lua");
Include("StatProject.lua");


StatProject.OpenCLTest();

-- Actually create the server!
--http.createServer(
local function onRequest(req, res)
	-- Redirect the URL to the html folder
	local filepath = "../../www" .. req.url;

	-- Append 'index.html' to the end of a url
	if utils.string.ends(filepath, '/') then
		filepath = filepath .. "index.html";
	end

	local Path, Options = StatProject.GetPathAndOptionsFromURL(filepath);
	filepath = Path;

	utils.print(filepath);

	-- Check if the file exists before we load it
	local ok, err = fs.existsSync(filepath);
	if (ok) then
		-- Load the file and send it
		if (utils.string.ends(filepath, ".lua")) then
				local f, ferr = loadfile(filepath);

				if (f) then
					-- If we have successfully loaded the file and compiled it, then set the environment and pcall the file
					setfenv(f, GetEnvironment({"req", req}, {"res", res}, {"options", Options}));

					local ok, err = xpcall(f, debug.traceback);

					if (ok) then
						return;
					else
						-- Print the stack traceback if we have an error in the page
						utils.log(utils.colorize("err", err));
					end
				-- If we have a compile/loading error
				elseif (ferr) then
					utils.log(utils.colorize("err", ferr));
				end
		elseif (utils.string.ends(filepath, ".html")) then
			local body = fs.readFileSync(filepath);
			res:setHeader("Content-Type", "text/html");
			res:setHeader("Content-Length", #body);
			res:write(body);
			res:finish();
			return;
		elseif(utils.string.ends(filepath, ".css")) then
			local body = fs.readFileSync(filepath);
			res:setHeader("Content-Type", "text/css");
			res:setHeader("Content-Length", #body);
			res:write(body);
			res:finish();
			return;
		end
	end

	if (err) then
		utils.log(utils.colorize("err", err));
	end

	local body = "404 error";
	res:writeHead(404, {["Content-Type"] = "text/plain"});
	res:setHeader("Content-Length", #body);
	res:write(body);
	res:finish();

end

http.createServer(onRequest):listen(52)

--[[
https.createServer({
  key = fs.readFileSync(pathJoin(module.dir, "key.pem")),
  cert = fs.readFileSync(pathJoin(module.dir, "cert.pem")),
}, onRequest):listen(48)
]]

if (params["colorize"] ~= false) then
	utils.log("Server running at " .. utils.colorize("quotes", "http://" .. '127.0.0.1' .. ":" .. '52' .. "/"));
else
	utils.log("Server running at http://" .. '127.0.0.1' .. ":" .. '52' .. "/");
end
