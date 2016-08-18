#include <cstdio>
#include <cmath>

#define G 1.0

#define MASS_SUN 1.98855e30

typedef double db;
typedef long double ldb;

struct vec3
{
    ldb x, y, z;
    vec3(): x(0), y(0), z(0) {}
    vec3(const ldb &x_, const ldb &y_, const ldb &z_): 
	x(x_), y(y_), z(z_) {}

    inline void print()
    {
	printf("%.8lf %.8lf %.8lf", x, y, z);
    }

    inline vec3 operator +(const vec3 &V) const
    {
	return vec3(x + V.x, y + V.y, z + V.z);
    }

    inline vec3 operator -(const vec3 &V) const
    {
	return vec3(x - V.x, y - V.y, z - V.z);
    }

    inline vec3 operator *(const ldb &q) const
    {
	return vec3(q * x, q * y, q * z);
    }

    inline void operator +=(const vec3 &V)
    {
	x += V.x, y += V.y, z += V.z;
    }

    inline void operator -=(const vec3 &V)
    {
	x -= V.x, y -= V.y, z -= V.z;
    }

    inline void operator *=(const ldb &q)
    {
	x *= q, y *= q, z *= q;
    }

    inline ldb norm() const
    {
	return sqrt(sq_norm());
    }

    inline ldb sq_norm() const
    {
	return x * x + y * y + z * z;
    } //the square of the norm of this vector

    inline void normalize()
    {
	(*this) *= 1.0 / norm();
    }
};

inline ldb dis(const vec3 &A, const vec3 &B)
{
    return sqrt(sq_dis(A, B));
}

inline ldb sq_dis(const vec3 &A, const vec3 &B)
{
    return (A - B).sq_norm();
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
    
    inline void move(const vec3 &acceleration)
    {
	acceleration *= 0.5;
	velocity += acceleration;
	position += velocity;
	velocity += acceleration;
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
		vec3 f = gravity(P[i], P[j]);
		F[i] -= f, F[j] += f;
	    }

	for (int i = 0; i < pnum; i++)
	    F[i] *= 1.0 / P[i].Mass();
	for (int i = 0; i < pnum; i++)
	    P[i].move(F[i]);
    }

    inline void draw()
    {
	
    }

private:
    int pnum; //particle number
    particle *P; //array of particles
    vec3 *F; //temp array for storing forces acting on particles
    
    inline vec3 gravity(const particle &A, const particle &B)
    {
	vec3 res = A - B; res.normalize();
	res *= G * (A.Mass() * B.Mass()) / sq_dis(A.Position(), B.Position);
	return res;
    } //the gravity force exerted by A on B
    
};
