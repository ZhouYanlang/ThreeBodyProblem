#include <cstdio>
#include <string>
#include <cmath>

#define G 6.674e-11

#define MASS_SUN 1.98855e30

typedef double db;
typedef long double ldb;
typedef unsigned long long ull;

char format_string[100];

struct vec3
{
    ldb x, y, z;
    vec3(): x(0), y(0), z(0) {}
    vec3(const ldb &x_, const ldb &y_, const ldb &z_):
    x(x_), y(y_), z(z_) {}
    
    inline void print() const
    {
        printf("%.2Lf %.2Lf %.2Lf", x, y, z);
    }
    
    /*
     inline void print(int k) //arg: number of decimal places
     {
     snprintf(format_string, 100, "%%.%dLf, %%.%dLf, %%.%dLf", k, k, k);
     printf(format_string, x, y, z);
     }
     */
    
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

inline ldb sq_dis(const vec3 &A, const vec3 &B)
{
    return (A - B).sq_norm();
} //the square of distance between A and B

inline ldb dis(const vec3 &A, const vec3 &B)
{
    return (A - B).norm();
}

struct particle
{
    particle() {}
    particle(const char *name_, const ldb &mass_,
             const vec3 &position_, const vec3 &velocity_)
        :mass(mass_), position(position_), velocity(velocity_)
    {
        memset(name, 0, sizeof(name));
        memcpy(name, name_, strlen(name_));
    }
    
    inline ldb m() const
    {
        return mass;
    }
    
    inline vec3 r() const
    {
        return position;
    }
    
    inline void update(vec3 &a)
    {
        a *= 0.5 / mass; //0.5 * a = 0.5 * F / m
        velocity += a;
        position += velocity;
        velocity += a;
    }
    
    inline void print() const
    {
        printf("%s: ", name);
        position.print();
        printf("\n");
    }
    
private:
    char name[16];
    ldb mass;
    vec3 position, velocity;
};

struct universe
{
    universe() {}
    universe(const particle *P_, const int &num_)
        :num(num_)
    {
        for (int i = 0; i < num_; i++)
            P[i] = P_[i];
    }
    
    ~universe()
    {
    }
    
    inline void update()
    {
        for (int i = 0; i < num; i++)
            for (int j = i + 1; j < num; j++)
            {
                vec3 f = gravity(P[i], P[j]);
                F[i] -= f, F[j] += f;
            }
        
        for (int i = 0; i < num; i++)
            P[i].update(F[i]);
    }
    
    inline void getPositions(vec3* Pos)
    {
        for (int i = 0; i < num; i++)
            Pos[i] = P[i].r();
    }
    
    inline void draw()
    {
        for (int i = 0; i < num; i++)
            P[i].print();
        printf("distance: %.2Lf\n", dis(P[0].r(), P[1].r()));
        printf("\n");
    }
    
private:
    int num; //number of particles
    particle P[10]; //array of particles
    vec3 F[10]; //temp array for storing forces acting on particles
    
    inline vec3 gravity(const particle &A, const particle &B)
    {
        vec3 res = A.r() - B.r(); res.normalize();
        res *= G * (A.m() * B.m()) / sq_dis(A.r(), B.r());
        return res;
    } //the gravity force exerted by A on B
    
};
