CC=g++
CFLAGS=-std=c++14 
INCUDES=-I./include -I/usr/include/libxml2 -I/usr/include/jsoncpp
SRC=./src/StatProject.cpp ./src/Connection.cpp ./src/HTMLParser.cpp ./src/JSONParser.cpp ./src/Database.cpp ./src/Config.cpp ./src/IO.cpp ./src/TSVParser.cpp
LUASRC=./src/StatProjectLua.cpp ./src/Test.cpp
LIBS= -lcurl -lxml2 -ljsoncpp -x86_64-linux-gnu/libOpenCL.so.1 -lodbc -pthread

StatProjectExecutable: $(SRC) $(INCLUDES)
	$(CC) $(CFLAGS) -DSTATPROJECT_EXECUTABLE $(INCUDES) -o./bin/debug/statproject $(SRC) ./src/main.cpp $(LIBS)

StatProjectModule: $(SRC) $(INCLUDES)
	$(CC) $(CFLAGS) -fPIC -c -DSTATPROJECT_MODULE $(INCUDES) -I/usr/include/lua5.3 $(SRC) $(LUASRC) ./src/modulemain.cpp $(LIBS)
	$(CC) -O -shared -fPIC -o./bin/debug/statproject.so *.o $(LIBS)
	mv *.o obj