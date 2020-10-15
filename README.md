# Inform6

This is a port for [Inform6.34](https://github.com/DavidKinder/Inform6/releases/tag/v6.34) & [upward](https://github.com/DavidKinder/Inform6/) to AmigaOS & friends made by [Samuel Devulder](https://github.com/Samuel-DEVULDER). 

# Binaries

Binaries for various compilers, processor, and OSes are available [here](https://github.com/Samuel-DEVULDER/Inform6/releases/tag/v6.34).

The executable(s) contains version string indicating compilation date as well as Inform6 version. This way you know exactly which version you are using:
```
Applications:Inform6> version Inform6-vbcc-ppc.mos  full
Inform 6.34 of 21st May 2020 (15/10/20)
Build #685 (Oct 15 2020) for mos/ppc by Samuel DEVULDER with vbcc
```
__Notice__: *ks13 = AmigaOS 1.3, aos = AmigaOS 2+, mos = MorphOS*

# Build

Makefile auto-adapts itself to the compiling environment. 

Just get a gnu-c compatible make (the one of 1995-12-16 from [Aaron Digulla on Aminet](http://aminet.net/package/dev/c/make-3.75-bin) seem to work ok) and type `make` in a Shell and let the executable being compiled.

Example:
```
Boot:> cd Applications:Inform6/

Applications:Inform6> make -v
GNU Make version 3.74, by Richard Stallman and Roland McGrath.
Copyright (C) 1988, 89, 90, 91, 92, 93, 94, 95 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.
There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

Applications:Inform6> make
Compiling src/Inform6/arrays.c with vbccm68k...done (8 sec)
Compiling src/Inform6/asm.c with vbccm68k...done (18 sec)
Compiling src/Inform6/bpatch.c with vbccm68k...done (4 sec)
Compiling src/Inform6/chars.c with vbccm68k...done (12 sec)
Compiling src/Inform6/directs.c with vbccm68k...done (24 sec)
Compiling src/Inform6/errors.c with vbccm68k...done (2 sec)
Compiling src/Inform6/expressc.c with vbccm68k...done (27 sec)
Compiling src/Inform6/expressp.c with vbccm68k...done (24 sec)
Compiling src/Inform6/files.c with vbccm68k...done (3 sec)
Compiling src/Inform6/inform.c with vbccm68k...done (8 sec)
Compiling src/Inform6/lexer.c with vbccm68k...done (12 sec)
Compiling src/Inform6/linker.c with vbccm68k...done (39 sec)
Compiling src/Inform6/memory.c with vbccm68k...done (4 sec)
Compiling src/Inform6/objects.c with vbccm68k...done (12 sec)
Compiling src/Inform6/states.c with vbccm68k...done (65 sec)
Compiling src/Inform6/symbols.c with vbccm68k...done (9 sec)
Compiling src/Inform6/syntax.c with vbccm68k...done (4 sec)
Compiling src/Inform6/tables.c with vbccm68k...done (83 sec)
Compiling src/Inform6/text.c with vbccm68k...done (109 sec)
Compiling src/Inform6/veneer.c with vbccm68k...done (4 sec)
Compiling src/Inform6/verbs.c with vbccm68k...done (8 sec)
Compiling src/Amiga/extra.c with vbccm68k...done (1 sec)
Updating version string...done
Linking to Inform6-aos-68030-vbccm68k...done (593720 bytes)

Applications:Inform6>  
```

As you can se from the example above, the makefile doesn't display the real executed command to keep output simple, but if you wan't to have a plain full Make output, add `VERBOSE=1` on the command line.

You can type `make tst`to download test-cases (recent [wget with ssl](http://m68k.aminet.net/package/dev/gg/wget-1.11.4-bin) required) and test the resulting executable. 
```
Applications:Inform6> wget --version
GNU Wget AmigaOS 1.11.4

Copyright (C) 2008 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later
<http://www.gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Originally written by Hrvoje Niksic <hniksic@xemacs.org>.
Currently maintained by Micah Cowan <micah@cowan.name>.
Applications:Inform6> TY; without even the implied warranty of

Applications:Inform6> make tst
Testing Inform6-aos-68030-vbccm68k -h...done (0 sec)
Testing Inform6-aos-68030-vbccm68k -v5 test/advent.inf...done (1 sec)
Testing Inform6-aos-68030-vbccm68k -v5 test/adventureland.inf...done (1 sec)
Testing Inform6-aos-68030-vbccm68k -v5 test/balances.inf...done (2 sec)
Testing Inform6-aos-68030-vbccm68k -v5 test/museum.inf...done (1 sec)
Testing Inform6-aos-68030-vbccm68k -v5 test/ruins.inf...done (1 sec)
Testing Inform6-aos-68030-vbccm68k -v5 test/toyshop.inf...done (1 sec)

Applications:Inform6> 
```

On Amiga-68k the default target CPU is 68030, but you can change this by providing a suitable "CPU=680x0" argument on the command line. 
```
Applications:Inform6> make CPU=68000 tst
Compiling src/Inform6/arrays.c with vbccm68k...done (4 sec)
Compiling src/Inform6/asm.c with vbccm68k...done (17 sec)
Compiling src/Inform6/bpatch.c with vbccm68k...done (3 sec)
Compiling src/Inform6/chars.c with vbccm68k...done (12 sec)
Compiling src/Inform6/directs.c with vbccm68k...done (24 sec)
Compiling src/Inform6/errors.c with vbccm68k...done (2 sec)
Compiling src/Inform6/expressc.c with vbccm68k...
warning 2047 in line 5654 of "T:t_12_0.asm": branch out of range changed to jmp
>       beq     l675

warning 2047 in line 5675 of "T:t_12_0.asm": branch out of range changed to jmp
>       beq     l675

warning 2047 in line 5708 of "T:t_12_0.asm": branch out of range changed to jmp
>       bra     l675

warning 2047 in line 5795 of "T:t_12_0.asm": branch out of range changed to jmp
>       bra     l683

warning 2047 in line 5829 of "T:t_12_0.asm": branch out of range changed to jmp
>       bra     l683

warning 2047 in line 5854 of "T:t_12_0.asm": branch out of range changed to jmp
>       bra     l675

warning 2047 in line 5969 of "T:t_12_0.asm": branch out of range changed to jmp
>       bra     l675
done (42 sec)
Compiling src/Inform6/expressp.c with vbccm68k...done (24 sec)
Compiling src/Inform6/files.c with vbccm68k...done (3 sec)
Compiling src/Inform6/inform.c with vbccm68k...done (9 sec)
Compiling src/Inform6/lexer.c with vbccm68k...done (12 sec)
Compiling src/Inform6/linker.c with vbccm68k...done (37 sec)
Compiling src/Inform6/memory.c with vbccm68k...done (4 sec)
Compiling src/Inform6/objects.c with vbccm68k...done (13 sec)
Compiling src/Inform6/states.c with vbccm68k...done (66 sec)
Compiling src/Inform6/symbols.c with vbccm68k...done (9 sec)
Compiling src/Inform6/syntax.c with vbccm68k...done (4 sec)
Compiling src/Inform6/tables.c with vbccm68k...done (81 sec)
Compiling src/Inform6/text.c with vbccm68k...done (107 sec)
Compiling src/Inform6/veneer.c with vbccm68k...done (4 sec)
Compiling src/Inform6/verbs.c with vbccm68k...done (7 sec)
Compiling src/Amiga/extra.c with vbccm68k...done (1 sec)
Updating version string...done
Linking to Inform6-aos-68000-vbccm68k...done (643144 bytes)
Testing Inform6-aos-68000-vbccm68k -h...done (0 sec)
Testing Inform6-aos-68000-vbccm68k -v5 test/advent.inf...done (1 sec)
Testing Inform6-aos-68000-vbccm68k -v5 test/adventureland.inf...done (1 sec)
Testing Inform6-aos-68000-vbccm68k -v5 test/balances.inf...done (1 sec)
Testing Inform6-aos-68000-vbccm68k -v5 test/museum.inf...done (1 sec)
Testing Inform6-aos-68000-vbccm68k -v5 test/ruins.inf...done (0 sec)
Testing Inform6-aos-68000-vbccm68k -v5 test/toyshop.inf...done (1 sec)
Applications:Inform6> 
```

Stack auto-extension is enabled when possible since unix-like programs usually require a larger stack size than Amiga usually provides.

**Notice related to compiling with VBCC**: 
* the PIPE: device must be mounted in order to ignore _warning 120_ which can not be filtered out otherwise.
* as you can see from the example above, VBCC notifies of an issue with short-branches on 68000. I dont't know if this will cause harm. Better stick to 68020+ class CPU with this compiler.

# Supported compiling environments

Many compilers are supported:
* [VBCC 0.9g](http://sun.hasenbraten.de/vbcc/) for AmigaOS/m68k
* [VBCC 0.9g](http://sun.hasenbraten.de/vbcc/) for MorphOS/ppc
* [GCC 2.95.3](http://aminet.net/package/dev/gcc/ADE-repack) from Amiga's [ADE](https://aminet.net/package/dev/gcc/ADE)
* GCC 3.2.2 probably from Amiga's GeekGadgets volume 2 (not sure where my version comes from)
* [GCC 6.5.0b](https://github.com/bebbo/amiga-gcc/releases) by [Bebbo](https://github.com/bebbo) (specify `STACKEXTEND= OFLAGS=-Ofast OS=AmigaOS` on command-line, or simply use `make -f Makefile.650`)
* Probably all gcc-flavours on unix-like systems (e.g. cygwin)
* [SAS/C](http://www.pjhutchison.org/tutorial/sas_c.html) 6.58

# Source

Source is available on: https://github.com/Samuel-DEVULDER/Inform6-Amiga

# License

The license of the original Inform6 version applies to this port (see [License.txt](License.txt))