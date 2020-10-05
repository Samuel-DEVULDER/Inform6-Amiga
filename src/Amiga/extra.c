#include <stdio.h>

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

unsigned long __stack = 128*1024; /* 128kb stack should be enough */

unsigned long __stk_minframe = 256*1024;
unsigned long __stk_safezone = 128*1024;

#undef putchar
int putchar(int c) {
	return putc(c, stdout);
}

#endif /* __SASC */

