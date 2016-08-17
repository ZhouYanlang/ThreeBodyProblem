CC = g++
CFLAGS = -std=c++11 -Ofast -Wno-unused-result
FRAMEWORKS = -framework OpenGL -framework GLUT -framework Foundation

default:
	$(CC) TBP.cpp $(CFLAGS) $(FRAMEWORKS) -o TBP

clean:
	-rm TBP
	-rm *~ \#*\#