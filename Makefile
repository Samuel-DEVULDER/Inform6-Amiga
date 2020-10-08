##############################################################################
#
# Generic Makefile for:
#
#    =====================
PROG = Inform6
#    =====================
#
# Made by Samuel Devulder on 05th Oct 2020
#
##############################################################################

ifneq ($(lastword $(MAKEFILE_LIST)), Makefile)
MAKEFILE_LIST += Makefile
endif

ifeq ($(origin CC), default)
CC           = gcc
endif
OS          ?= $(shell uname)
CPU         ?= $(shell uname -m)

MKDIR        = mkdir
TOUCH        = touch
TRUE         = true
DATE         = date
CAT          = cat
RM           = rm

TMP          = /tmp/
NIL          = /dev/null
HERE         = ./

ifeq ($(VERBOSE),)
INFO         = echo
HIDDEN       = @
else
INFO         = @$(TRUE)
HIDDEN       =
endif
NOLINE       = -n

ifeq ($(OS),)
# vbcc/sasc/etc :)
NATIVE       = 1
endif

ifeq ($(NATIVE),1)
OS           = AmigaOS
CAT          = c:type
RM           = c:delete quiet
MKDIR        = c:makedir
TOUCH        = :ade/bin/touch  # FIXME
DATE         = :ade/bin/date   # FIXME
TRUE         = :ade/bin/true   # FIXME
NOLINE       = noline
TMP          = t:
NIL          = nil:
HERE         =
endif

EXT         ?= $(notdir $(CC))-$(shell $(CC) -dumpversion)
ifeq ($(origin OBJDIR), undefined) # for some reason ?= doesn't work here
OBJDIR      := objs-$(EXT)
endif

INF          = $(wildcard test/*.inf)
SRC          = $(wildcard src/Inform6/*.c src/amiga/*.c)
OBJS         = $(addprefix $(OBJDIR)/,$(notdir $(SRC:%.c=%.o)))

WFLAGS       =
OFLAGS       = -O3 -fomit-frame-pointer
CFLAGS       = 
DFLAG        = -D

LDFLAGS      = 
LIBS         = -lm
COMPILE_TO   = -c -o
LINK_TO      = -o

ifeq ($(OS), AmigaOS)
OS           = aos
CPU          = 68030
DEFINES      = -DAMIGA
OFLAGS      += -m$(CPU) -msoft-float
LIBS        += -lstack -noixemul
endif

EXE          = $(PROG)-$(OS)-$(CPU)-$(EXT)

###############################################################################
# top-level targets
###############################################################################

ifeq ($(NATIVE)$(firstword $(MAKEFILE_LIST)),1Makefile)
unknown: all
	
%:
	$(HIDDEN)echo >$(TMP)_  ""
	$(HIDDEN)echo >>$(TMP)_  "FailAt 21"
	$(HIDDEN)echo >>$(TMP)_ "echo >T:t.c f() {}"
	$(HIDDEN)echo >>$(TMP)_ "sc NOVER >NIL: T:t.c OBJNAME T:t.o"
	$(HIDDEN)echo >>$(TMP)_ "IF *$$RC eq 10"
	$(HIDDEN)echo >>$(TMP)_ "  vbccm68k >NIL:"
	$(HIDDEN)echo >>$(TMP)_ "  IF *$$RC eq 10"
	$(HIDDEN)echo >>$(TMP)_ "    vbccppc >NIL:"
	$(HIDDEN)echo >>$(TMP)_ "    IF *$$RC eq 10"
	$(HIDDEN)echo >>$(TMP)_ "      echo Can't determine compiler"
	$(HIDDEN)echo >>$(TMP)_ "      quit 20"
	$(HIDDEN)echo >>$(TMP)_ "    ELSE"
	$(HIDDEN)echo >>$(TMP)_ "      set MAKEFIlE=Makefile.vbcc-mos"
	$(HIDDEN)echo >>$(TMP)_ "    ENDIF"
	$(HIDDEN)echo >>$(TMP)_ "  ELSE"
	$(HIDDEN)echo >>$(TMP)_ "    set MAKEFIlE=Makefile.vbcc-aos"
	$(HIDDEN)echo >>$(TMP)_ "  ENDIF"
	$(HIDDEN)echo >>$(TMP)_ "ELSE"
	$(HIDDEN)echo >>$(TMP)_ "  set MAKEFIlE=Makefile.sasc"
	$(HIDDEN)echo >>$(TMP)_ "ENDIF"
	$(HIDDEN)echo >>$(TMP)_ "DELETE QUIET T:t.o T:t.c"
	$(HIDDEN)echo >>$(TMP)_ "$(MAKE) -f *$$MAKEFILE VERBOSE=$(VERBOSE) $@"
	$(HIDDEN)echo >>$(TMP)_ "quit $$RC"
	$(HIDDEN)c:execute $(TMP)_
	$(HIDDEN)$(RM) $(TMP)_
else
all: compile

tst: compile do_tst_fill do_tst_-h do_tst_all_-v5

endif


###############################################################################
# git-suff
###############################################################################

git-pull: git-subtree
	git pull
	git subtree pull --prefix test/Library https://gitlab.com/DavidGriffith/inform6lib.git master --squash
	git subtree pull --prefix src/Inform6 https://github.com/DavidKinder/Inform6.git master --squash

git-subtree: /bin/git-subtree

/bin/git-subtree:
	wget rawgit.com/git/git/master/contrib/subtree/git-subtree.sh
	install git-subtree.sh /bin/git-subtree
	rm git-subtree.sh
	
###############################################################################
# compilation
###############################################################################

compile: $(OBJDIR) $(EXE) 

$(OBJDIR):
	-$(MKDIR) $(OBJDIR)

$(EXE): $(OBJS) $(OBJDIR)/VERstring.o
	$(HIDDEN)$(INFO) $(NOLINE) "Linking to $@..."
	$(HIDDEN)$(CC) $(LDFLAGS) $^ $(LINK_TO) $@ $(LIBS) 
	$(HIDDEN)$(POST_BUILD)
	$(HIDDEN)$(INFO) done
	
$(OBJS): $(MAKEFILE_LIST)

COMPILE_OPTS = $(OFLAGS) $(CFLAGS) $(WFLAGS) $(DEFINES:-D%=$(DFLAG)%)

$(OBJDIR)/%.o: src/Inform6/%.c
	$(HIDDEN)$(INFO) $(NOLINE) "Compiling $< with $(CC)..."
	$(HIDDEN)$(CC) $(COMPILE_OPTS) $(COMPILE_TO) "$@" "$<" $(COMPILE_EXTRA)
	$(HIDDEN)$(INFO) done

$(OBJDIR)/%.o: src/Amiga/%.c
	$(HIDDEN)$(INFO) $(NOLINE) Compiling $<...
	$(HIDDEN)$(CC) $(COMPILE_OPTS) $(COMPILE_TO) "$@" "$<" 
	$(HIDDEN)$(INFO) done

ifeq ($(NATIVE),1)
INC_REVISION = c:eval LFORMAT="%n*n;*n\#define REVISION %n*n" TO $@ \
               1 + `type $@` 
else
INC_REVISION = 	read n < $@; n=`expr $$n + 1`; \
              	echo > $@ $$n; \
              	echo >> $@ ";"; \
              	echo >>$@ "\#define REVISION $$n"
endif

src/Amiga/VER/VERstring.h: $(OBJS)
	$(HIDDEN)$(INFO) $(NOLINE) "Updating version string..."
	-$(HIDDEN)$(INC_REVISION)
	$(HIDDEN)$(INFO) done

$(OBJDIR)/VERstring.o: src/Amiga/VER/VERstring.c src/Amiga/VER/VERstring.h
	$(HIDDEN)$(CC) $(CFLAGS) $(COMPILE_TO) $@ $< \
		$(DFLAG)DATESTR=`$(DATE) +\"%-d.%-m.%y\"` $(DFLAG)PROGNAME=$(EXE)
	
###############################################################################
# helpers
###############################################################################

relink: touch compile

touch:
	$(TOUCH) $(MAKEFILE_LIST)
	$(TOUCH) $(OBJDIR)/*.o 

###############################################################################
# cleaning
###############################################################################

clean:
	-$(RM) $(OBJDIR)/*.o

fullclean: clean
	-$(RM) $(PROG).* $(OBJDIR)

###############################################################################
# perform tests
###############################################################################

do_tst_fill:
	-$(HIDDEN)wget -q -P test -nd -r -l 1 -A inf \
		--restrict-file-names=lowercase \
		http://inform-fiction.org/examples/index.html

do_tst_all_%:
	@$(MAKE) -s EXE=$(EXE) HIDDEN=$(HIDDEN) TMP=$(TMP) \
		$(subst /,-slash-,$(addprefix do_tst_$*_,$(wildcard test/*.inf)))
	
do_tst_%:
	$(HIDDEN)$(INFO) $(NOLINE) Testing $(subst _, , $(subst -slash-,/,$*))...
ifeq ($(NATIVE),1)
	$(HIDDEN)echo  >$(TMP)_$*_ "$(EXE) >$(TMP)_$* +test/Library $(TST_$*) $(subst _, , $(subst -slash-,/,$*))"
	$(HIDDEN)echo >>$(TMP)_$*_ "SET X $$RC"
	$(HIDDEN)echo >>$(TMP)_$*_ "IF NOT $$X EQ 0"
	$(HIDDEN)echo >>$(TMP)_$*_ "  $(CAT) $(TMP)_$*"
	$(HIDDEN)echo >>$(TMP)_$*_ "  QUIT $$X"
	$(HIDDEN)echo >>$(TMP)_$*_ "ENDIF"
	$(HIDDEN)execute $(TMP)_$*_
	$(HIDDEN)$(RM)   $(TMP)_$*_ $(TMP)_$*
else
	$(HIDDEN)$(HERE)$(EXE) >$(TMP)_$* +test/Library $(TST_$*) \
		$(subst _, , $(subst -slash-,/,$*)) || (echo && $(CAT) $(TMP)_$* && fail)
	$(HIDDEN)$(RM) $(TMP)_$*
endif
	$(HIDDEN)$(INFO) "ok"
