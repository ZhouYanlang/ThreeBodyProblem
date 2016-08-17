#include <cstdio>

#define G 1.0

#define MASS_SUN 1.98855e30

typedef double db;
typedef long double ldb;

struct vec3
{
    ldb x, y, z;
    vec3() {}
    vec3(const ldb &x_, const ldb &y_, const ldb &z_): 
	x(x_), y(y_), z(z_) {}

    inline vec3 operator +(const vec3 &V) const
    {
	vec3 res;
	res.x = x + V.x, res.y = y + V.y, res.z = z + V.z;
	return res;
    }

    inline void operator +=(const vec3 &V)
    {
	x += V.x, y += V.y, z += V.z;
    }

    inline void operator /=(const ldb &q)
    {
	x /= q, y /= q, z /= q;
    }

};

inline ldb dis(const vec3 &A, const vec3 &B)
{
    
}

inline ldb sqr_dis(const vec3 &A, const vec3 &B)
{
    
} //the square of distance between A and B

struct particle
{
    particle() {}
    particle(const ldb mass_, const vec3 velocity_, const vec3 position_):
	mass(mass_), velocity(velocity_), position(position_) {}
    
    inline ldb Mass()
    {
	return mass;
    }

    inline vec3 Position()
    {
	return position;
    }
    
    inline void move(const vec3 &F)
    {
	velocity += a;
	position += velocity;
    }
    
private:
    ldb mass;
    vec3 position, velocity;
};

struct universe
{
    universe() {}
    universe(const particle *P_, const int &pnum_):
	P(P_), pnum(pnum_) 
    {
	F = new vec3[pnum];
    }

    ~universe()
    {
	delete []F;
    }
    
    inline void update()
    {
	for (int i = 0; i < pnum; i++)
	    for (int j = i + 1; j < pnum; j++)
	    {
		vec3 F;
	    }
    }

    inline void draw()
    {
	
    }

private:
    int pnum; //particle number
    particle *P; //array of particles
    vec3 *F; //temp array for storing forces acting on particles
    
    inline ldb gravity(const particle &A, const particle &B)
    {
	return G * (A.Mass() * B.Mass()) / sqr_dis(A.Position(), B.Position);
    }
    
};
