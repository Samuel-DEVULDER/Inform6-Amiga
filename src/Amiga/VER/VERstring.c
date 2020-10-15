#ifdef __SASC
#include "//Inform6/header.h"
#else
#include "../../Inform6/header.h"
#endif

#define STR2(x) #x
#define STR(x) STR2(x)

static int dummy=
#include "VERstring.h"

#if (RELEASE_NUMBER/100)%10==0
#define R0 "0"
#endif
#if (RELEASE_NUMBER/100)%10==1
#define R0 "1"
#endif
#if (RELEASE_NUMBER/100)%10==2
#define R0 "2"
#endif
#if (RELEASE_NUMBER/100)%10==3
#define R0 "3"
#endif
#if (RELEASE_NUMBER/100)%10==4
#define R0 "4"
#endif
#if (RELEASE_NUMBER/100)%10==5
#define R0 "5"
#endif
#if (RELEASE_NUMBER/100)%10==6
#define R0 "6"
#endif
#if (RELEASE_NUMBER/100)%10==7
#define R0 "7"
#endif
#if (RELEASE_NUMBER/100)%10==8
#define R0 "8"
#endif
#if (RELEASE_NUMBER/100)%10==9
#define R0 "9"
#endif

#if (RELEASE_NUMBER/10)%10==0
#define R1 "0"
#endif
#if (RELEASE_NUMBER/10)%10==1
#define R1 "1"       
#endif               
#if (RELEASE_NUMBER/10)%10==2
#define R1 "2"       
#endif               
#if (RELEASE_NUMBER/10)%10==3
#define R1 "3"       
#endif               
#if (RELEASE_NUMBER/10)%10==4
#define R1 "4"       
#endif               
#if (RELEASE_NUMBER/10)%10==5
#define R1 "5"       
#endif               
#if (RELEASE_NUMBER/10)%10==6
#define R1 "6"       
#endif               
#if (RELEASE_NUMBER/10)%10==7
#define R1 "7"       
#endif               
#if (RELEASE_NUMBER/10)%10==8
#define R1 "8"       
#endif               
#if (RELEASE_NUMBER/10)%10==9
#define R1 "9"
#endif

#if RELEASE_NUMBER%10==0
#define R2 "0"
#endif
#if RELEASE_NUMBER%10==1
#define R2 "1"
#endif
#if RELEASE_NUMBER%10==2
#define R2 "2"
#endif
#if RELEASE_NUMBER%10==3
#define R2 "3"
#endif
#if RELEASE_NUMBER%10==4
#define R2 "4"
#endif
#if RELEASE_NUMBER%10==5
#define R2 "5"
#endif
#if RELEASE_NUMBER%10==6
#define R2 "6"
#endif
#if RELEASE_NUMBER%10==7
#define R2 "7"
#endif
#if RELEASE_NUMBER%10==8
#define R2 "8"
#endif
#if RELEASE_NUMBER%10==9
#define R2 "9"
#endif

char *VERstring = "\0$VER: Inform " R0 "." R1 R2 " of " RELEASE_DATE " (" DATESTR ") " \
"Build #" STR(REVISION) " (" __DATE__ ") for " STR(CPU) " by Samuel DEVULDER with " STR(COMPILER) "\0";
