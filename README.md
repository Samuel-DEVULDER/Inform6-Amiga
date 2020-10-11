# Inform6

This is a port for Inform6.34 & upward to AmigaOS & friends made by Samuel Devulder. 

The executable(s) contains version string indicating compilation date.

# Build

Makefile auto-adapts itself to the compiling environment. 

Just get a gnu-c compatible make and type `make` in a Shell and let the executable being compiled.

On Amiga-68k the target CPU is 68030. Stack auto-extension is enabled when possible.

# Supported compiling environments

Many compilers are supported:
* gcc2.9.5 from Amiga's ADE
* gcc 3.2.2 from Amiga's GG
* SAS/C 6.58
* VBCC 0.907 for AmigaOS/m68k
* VBCC 0.907 for MorphOS/ppc
* probably all gcc on unix-like systems (works under cygwin)

# Source

Source is available on: https://github.com/Samuel-DEVULDER/Inform6-Amiga

# License

The license of the original Inform6 version applies to this port (see [License.txt](License.txt))