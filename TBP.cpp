#include "globals.h"

particle P[10];

int main()
{
    particle star("star", 100000000.0, vec3(0, 0, 0), vec3(0, 0, 0));
    particle planet("planet", 1.0, vec3(100000000.0, 0, 0), vec3(0, 1, 0));
    P[0] = star, P[1] = planet;
    
    universe U(P, 2);

    clock_t s = 0;
    while (1)
    {
	U.update();
	if ((clock() - s) / (double)CLOCKS_PER_SEC < 1.0)
	    continue;
	U.draw();
	s = clock();
    }

    return 0;
}
