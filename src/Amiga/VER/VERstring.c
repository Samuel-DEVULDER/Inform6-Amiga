#ifdef __SASC
#include "../Inform6/header.h"
#else
#include "../../Inform6/header.h"
#endif

#define STR2(x) #x
#define STR(x) STR2(x)

static int dummy=
#include "VERstring.h"

char *VERstring = "\0$VER: " STR(PROGNAME) " " STR(RELEASE_NUMBER) "." STR(REVISION) " (" DATESTR ") Build #" STR(REVISION) " Compiled by Samuel DEVULDER\0";
