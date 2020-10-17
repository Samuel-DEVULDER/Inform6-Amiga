#include <stdio.h>

#ifdef __SASC
__near 
#endif
unsigned long __stack = 128*1024; /* 128kb stack should be enough */

#ifdef __SASC
int isnan(double d) {
	return d!=d;
}

int isinf(double d) {
	return d*2==d;
}

#include <stdarg.h>
int snprintf (char *str, size_t n, const char *format, ...) {
	char *tmp = tmpnam(NULL);
	va_list ap;
	FILE *f;
	int r;

	if(tmp==NULL) return -1;
	f = fopen(tmp,"w");
	if(f==NULL) return -1;
	
	va_start(ap, format);
	r = vfprintf(f, format, ap);
	va_end(ap);
	
	fclose(f);

	f = fopen(tmp,"r");
	if(f==NULL) return -1;
	if(fgets(str, n , f)==NULL) r=-1;
	fclose(f);

	return r;
}

#else

unsigned long __stk_minframe = 256*1024;
unsigned long __stk_safezone = 128*1024;

#undef putchar
int putchar(int c) {
	return putc(c, stdout);
}

#if defined(__GNUC__) && defined(mc68000) && !defined(mc68020)  && !defined(mc68030)  && !defined(mc68040)  && !defined(mc68060) 
#include <math.h>
double frexp(double x,int * nptr)
{
        int e = 0;
        int s = 1;

        if(x < 0) x = -x, s = -s;

		while(x >= 1) {++e; x /= 2;}
        while (0 < x && x < 0.5) {--e; x *= 2;}
        
		*nptr = e;
		return x * s;

}
static double pow2(int exp) 
{
	double x = 1, y=2;
	if(exp<0) return 1/pow2(-exp);
	for(; exp>0; exp>>=1, y*=y) if(exp & 1) x *= y;
	return x;
}
double ldexp(double x, int exp)
{
		
        return pow2(exp)*x;
}
#endif

#endif /* __SASC */

