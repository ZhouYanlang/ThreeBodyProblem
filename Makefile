CC = g++
CFLAGS = -std=c++11 -Ofast -Wno-unused-result -Wno-deprecated
FRAMEWORKS = -framework OpenGL -framework GLUT -framework Foundation

default:
	$(CC) TBP.cpp $(CFLAGS) $(FRAMEWORKS) -o TBP

GL:
	$(CC) GL.cpp $(CFLAGS) $(FRAMEWORKS) -o GL

clean:
	-rm TBP
	-rm *~ \#*\#