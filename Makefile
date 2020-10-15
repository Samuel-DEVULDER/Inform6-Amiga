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

# some version of make does not maintain the list of makefile. 
ifneq ($(lastword $(MAKEFILE_LIST)), Makefile)
MAKEFILE_LIST += Makefile
endif

# override CC default for gcc (or else -dumpversion will fail)
ifeq ($(origin CC), default)
CC           = gcc
endif
ifeq ($(origin OS), undefined)
OS          := $(shell uname)
endif

TMP          = /tmp/
NIL          = /dev/null

ECHO         = echo
NOLINE       = -n
MKDIR        = mkdir
TOUCH        = touch
TRUE         = true
DATE         = /bin/date
CAT          = cat
RM           = rm >$(NIL) 2>&1
EXPR         = expr
EXPR_TAIL    = || true # because expr returns error codes
SECONDS      = echo $(NOLINE) `$(DATE) +%s`

# sets NATIVE to 1 when running out of unix context 
ifeq ($(OS),)
NATIVE       = 1
OS          := AmigaOS
endif

# replace unix commands by amiga (native) ones 
ifeq ($(NATIVE),1)
TMP          = t:
NIL          = nil:
CAT          = c:type
RM           = c:delete quiet >NIL:
MKDIR        = c:makedir
TOUCH        = :ade/bin/touch  # FIXME
DATE         = :ade/bin/date   # FIXME
TRUE         = :ade/bin/true   # FIXME
NOLINE       = noline
EXPR         = c:eval
EXPR_TAIL    =
SECONDS      = sys:rexxc/rx "say time(s)"
endif

# EXT defines the compiler-suffix
ifeq ($(origin EXT), undefined) # for some reason ?= doesn't work here
EXT         := $(notdir $(CC))-$(shell $(CC) -dumpversion)
endif

# test-cases files
INF          = $(wildcard test/*.inf)

# source files
SRC          = $(wildcard src/Inform6/*.c src/amiga/*.c)

# various GCC flags
WFLAGS       =
OFLAGS       = -O3 -fomit-frame-pointer
CFLAGS       = 
DFLAG        = -D

LDFLAGS      = -s
LIBS         = -lm

# these ones are set so that we can compile with SC 
COMPILE_TO   = -c -o
LINK_TO      = -o

# Default AMIGA-GCC options
ifeq ($(OS),AmigaOS)
OS          := aos
ifeq ($(CPU),)
CPU         := 68030
endif
STACKEXTEND  = -mstackextend
DEFINES      = -DAMIGA
OFLAGS      += -m$(CPU) -msoft-float
LIBS        += -lstack -noixemul
CFLAGS      += $(STACKEXTEND)
endif

# default cpu target
ifeq ($(CPU),)
CPU         ?= $(shell uname -m)
endif

# compiler-dependant object directory
ifeq ($(origin OBJDIR), undefined) # for some reason ?= doesn't work here
OBJDIR      := objs-$(EXT)-$(CPU:68%=%)
endif

# object files
OBJS         = $(addprefix $(OBJDIR)/,$(notdir $(SRC:%.c=%.o)))

# makes compilation less verbose by default
ifeq ($(VERBOSE),)
HIDDEN       = @
INFO         = $(ECHO)
TMAKE		 = $(HIDDEN)$(MAKE) -s
else
HIDDEN       =
INFO         = @$(TRUE)
TMAKE		 = $(INFO)
endif

# final exe name
EXE          = $(PROG)-$(EXT:m68k-amigaos-%=%)-$(CPU).$(OS)

ifeq ($(OS:Windows%=Win)$(EXE:%.exe=%),Win$(EXE))
EXE         := $(EXE).exe
endif

# files to archive
DISTRIB      = $(PROG)-* README.* License.*
ARCHIVE      = $(DISTRIB) Makefile* src Test 

###############################################################################
# top-level targets
###############################################################################

ifeq ($(NATIVE)$(firstword $(MAKEFILE_LIST)),1Makefile)
unknown: all
	
%:
	$(HIDDEN)$(ECHO) >$(TMP)_  ""
	$(HIDDEN)$(ECHO) >>$(TMP)_ "WHICH >NIL: sc"
	$(HIDDEN)$(ECHO) >>$(TMP)_ "IF WARN"
	$(HIDDEN)$(ECHO) >>$(TMP)_ "  WHICH >NIL: vbccm68k"
	$(HIDDEN)$(ECHO) >>$(TMP)_ "  IF WARN"
	$(HIDDEN)$(ECHO) >>$(TMP)_ "    WHICH >NIL:vbccppc"
	$(HIDDEN)$(ECHO) >>$(TMP)_ "    IF WARN"
	$(HIDDEN)$(ECHO) >>$(TMP)_ "      Echo Can't determine compiler"
	$(HIDDEN)$(ECHO) >>$(TMP)_ "      quit 20"
	$(HIDDEN)$(ECHO) >>$(TMP)_ "    ELSE"
	$(HIDDEN)$(ECHO) >>$(TMP)_ "      set MAKEFIlE=Makefile.vbcc-mos"
	$(HIDDEN)$(ECHO) >>$(TMP)_ "    ENDIF"
	$(HIDDEN)$(ECHO) >>$(TMP)_ "  ELSE"
	$(HIDDEN)$(ECHO) >>$(TMP)_ "    set MAKEFIlE=Makefile.vbcc-aos"
	$(HIDDEN)$(ECHO) >>$(TMP)_ "  ENDIF"
	$(HIDDEN)$(ECHO) >>$(TMP)_ "ELSE"
	$(HIDDEN)$(ECHO) >>$(TMP)_ "  set MAKEFIlE=Makefile.sasc"
	$(HIDDEN)$(ECHO) >>$(TMP)_ "ENDIF"
	$(HIDDEN)$(ECHO) >>$(TMP)_ "$(MAKE) -f *$$MAKEFILE VERBOSE=$(VERBOSE) CPU=$(CPU) $@"
	$(HIDDEN)$(ECHO) >>$(TMP)_ "quit $$RC"
	$(HIDDEN)c:execute $(TMP)_
	$(HIDDEN)$(RM) $(TMP)_
else
all: compile

tst: compile do_tst_fill do_tst_version do_tst_-h do_tst_all_-v5

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

git-tag-%:
	git commit
	git tag "$*" HEAD
	git push origin --tags
	
git-untag-%:
	git tag --delete "$*"
	git push origin --delete "$*"
	
	
###############################################################################
# compilation
###############################################################################

compile: $(OBJDIR) $(EXE) 

$(OBJDIR):
	-$(MKDIR) $(OBJDIR)
	
$(EXE): $(OBJS) $(OBJDIR)/VERstring.o
	$(HIDDEN)$(INFO) $(NOLINE) "Linking to $@..."
ifneq ($(LDOBJS),)
	$(HIDDEN)$(CC) $(LDFLAGS) $(LDOBJS) $(LINK_TO) $@ $(LIBS) 
else
	$(HIDDEN)$(CC) $(LDFLAGS) $^ $(LINK_TO) $@ $(LIBS) 
endif
	$(HIDDEN)$(INFO) $(NOLINE) "done ("
	$(HIDDEN)$(INFO) $(SIZE) "bytes)"
	$(HIDDEN)$(POST_BUILD)
	
$(OBJS): $(MAKEFILE_LIST)

COMPILE_OPTS = $(OFLAGS) $(CFLAGS) $(WFLAGS) $(DEFINES:-D%=$(DFLAG)%)

$(OBJDIR)/%.o: src/Inform6/%.c
	$(TMAKE) tstart
	$(HIDDEN)$(INFO) $(NOLINE) "Compiling $< with $(EXT)..."
	$(HIDDEN)$(CC) $(COMPILE_OPTS) $(COMPILE_TO) "$@" "$<" $(COMPILE_EXTRA)
	$(TMAKE) tstop_done
	
$(OBJDIR)/%.o: src/Amiga/%.c
	$(TMAKE) tstart
	$(HIDDEN)$(INFO) $(NOLINE) "Compiling $< with $(EXT)..."
	$(HIDDEN)$(CC) $(COMPILE_OPTS) $(COMPILE_TO) "$@" "$<" 
	$(TMAKE) tstop_done

ifeq ($(NATIVE),1)
INC_REVISION = c:eval LFORMAT="%n*n;*n\#define REVISION %n*n" TO $@ \
               1 + `type $@` 
SIZE         = `c:list LFORMAT=%L $@`
else
INC_REVISION = 	read n < $@; n=`expr $$n + 1`; \
              	echo > $@ $$n; \
              	echo >> $@ ";"; \
              	echo >>$@ "\#define REVISION $$n"
SIZE         = `cat "$@" | wc -c`
endif

src/Amiga/VER/VERstring.h: $(OBJS)
	$(HIDDEN)$(INFO) $(NOLINE) "Updating version string..."
	-$(HIDDEN)$(INC_REVISION)
	$(HIDDEN)$(INFO) done

$(OBJDIR)/VERstring.o: src/Amiga/VER/VERstring.c src/Amiga/VER/VERstring.h
	$(HIDDEN)$(CC) $(CFLAGS) $(COMPILE_TO) $@ $< \
		$(DFLAG)DATESTR=`$(DATE) +\"%-d.%-m.1%y\"` \
		$(DFLAG)CPU=$(OS)/$(CPU) \
		"$(DFLAG)COMPILER=$(EXT:m68k-amigaos-%=%)"
	
###############################################################################
# helpers
###############################################################################

echo_%:
	@echo $*=$($*)

relink: touch compile

touch:
	$(TOUCH) $(MAKEFILE_LIST)
	-@sleep 1
	-@c:wait 1
	$(TOUCH) $(OBJDIR)/*.o 
	-@sleep 1
	-@c:wait 1

.PHONY: tstart
TMP_TIME1 = $(TMP).time1-$(EXT)
TMP_TIME2 = $(TMP).time2-$(EXT)
tstart:
	$(HIDDEN)$(SECONDS) >$(TMP_TIME1)

tstop_%:
	$(HIDDEN)$(SECONDS) >$(TMP_TIME2)
	$(HIDDEN)echo $(NOLINE) >>$(TMP_TIME2) " - " 
	$(HIDDEN)$(CAT) >>$(TMP_TIME2) $(TMP_TIME1)
	$(HIDDEN)$(EXPR) >$(TMP_TIME1) `$(CAT) $(TMP_TIME2)` $(EXPR_TAIL)
	$(HIDDEN)$(INFO) "$* (`$(CAT) $(TMP_TIME1)` sec)"
	$(HIDDEN)$(RM) $(TMP_TIME1) $(TMP_TIME2)

###############################################################################
# cleaning
###############################################################################

clean:
	-$(RM) $(EXE) $(OBJDIR)/*.o

fullclean: clean
	-$(RM) -r $(OBJDIR)

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
	$(TMAKE) tstart
	$(HIDDEN)$(INFO) $(NOLINE) Testing $(EXE) $(subst _, , $(subst -slash-,/,$*))...
ifeq ($(NATIVE),1)
	$(HIDDEN)echo  >$(TMP)_$*_ "$(EXE) >$(TMP)_$* +test/Library $(TST_$*) $(subst _, , $(subst -slash-,/,$*))"
	$(HIDDEN)echo >>$(TMP)_$*_ "SET X $$RC"
	$(HIDDEN)echo >>$(TMP)_$*_ "IF NOT $$X EQ 0"
	$(HIDDEN)echo >>$(TMP)_$*_ "  $(CAT) $(TMP)_$*"
	$(HIDDEN)echo >>$(TMP)_$*_ "  QUIT $$X"
	$(HIDDEN)echo >>$(TMP)_$*_ "ENDIF"
	$(HIDDEN)execute $(TMP)_$*_
else
	$(HIDDEN)./$(EXE) >$(TMP)_$* +test/Library $(TST_$*) \
		$(subst _, , $(subst -slash-,/,$*)) || (echo && $(CAT) $(TMP)_$* && fail)
endif
	$(TMAKE) tstop_ok
	-$(HIDDEN)$(POST_TEST)
	$(HIDDEN)$(RM) $(TMP)_* $(subst -h,,$(*:-v5_test-slash-%.inf=%.z5))

do_tst_version: compile
	$(HIDDEN)$(INFO) $(NOLINE) Testing version...
ifeq ($(NATIVE),1)
	$(HIDDEN)c:version $(EXE) full
else 
# emulate
	$(HIDDEN)strings "$(EXE)" | grep '$VER: ' | sed -e 's%[)] %)\n%'
endif
	
###############################################################################
# multi-compiler support
###############################################################################

%_all all_%: sc_% vbcc_% ade_% gg_%
	@rm t:_ >NIL:
	@$(INFO) done "$*" with all compilers...
	
all_cpus_%: 
	$(MAKE) all_$* CPU=68000 VERBOSE=$(VERBOSE)
	$(MAKE) all_$* CPU=68020 VERBOSE=$(VERBOSE)
	$(MAKE) all_$* CPU=68030 VERBOSE=$(VERBOSE)
	$(MAKE) all_$* CPU=68040 VERBOSE=$(VERBOSE)
	$(MAKE) all_$* CPU=68060 VERBOSE=$(VERBOSE)

vbcc_%:
	-@Mount PIPE:
	@echo >  t:_ "FailAt 20"
	@echo >> t:_ "assign c: vbcc:bin add"
	@echo >> t:_ "$(MAKE) -f Makefile.vbcc-aos $* VERBOSE=$(VERBOSE) CPU=$(CPU)"
	@echo >> t:_ "$(MAKE) -f Makefile.vbcc-mos $* VERBOSE=$(VERBOSE)"
	@echo >> t:_ "assign c: vbcc:bin remove"
	@c:execute t:_
	@c:delete quiet t:_ >NIL:

ade_%:
	@echo >  t:_ "FailAt 20"
	@echo >> t:_ "assign IXPIPE: dismount >NIL: "
	@echo >> t:_ "assign PIPE:   dismount >NIL: "
	@echo >> t:_ "execute s:_ade >NIL: "
	@echo >> t:_ "$(MAKE) -f Makefile.295 $* VERBOSE=$(VERBOSE) CPU=$(CPU)"
	@echo >> t:_ "assign c:    ade:bin remove"
	@echo >> t:_ "assign c:    ade:sys/c remove"
	@echo >> t:_ "assign l:    ade:sys/l remove"
	@echo >> t:_ "assign s:    ade:sys/s remove"
	@echo >> t:_ "assign devs: ade:sys/devs remove"
	@echo >> t:_ "assign libs: ade:sys/libs remove"
	@echo >> t:_ "assign lib:  ade:lib remove"
	@echo >> t:_ "assign lib:  ade:local/lib remove"
	@echo >> t:_ "assign bin:  ade:bin remove"
	@echo >> t:_ "assign bin:  Applications:gg/bin remove"
	@c:execute t:_
	@c:delete quiet t:_ >NIL:

gg_%:	
	@echo >  t:_ "FailAt 20"
	@echo >> t:_ "delete RAM:GG-datestamp >NIL: "
	@echo >> t:_ "assign IXPIPE: dismount >NIL: "
	@echo >> t:_ "assign PIPE:   dismount >NIL: "
	@echo >> t:_ "execute s:_gg >NIL: "
	@echo >> t:_ "$(MAKE) -f Makefile.322 $* VERBOSE=$(VERBOSE) CPU=$(CPU)"
	@echo >> t:_ "assign c:    gg:bin remove"
	@echo >> t:_ "assign l:    gg:sys/l remove"
	@echo >> t:_ "assign devs: gg:sys/devs remove"
	@echo >> t:_ "assign libs: gg:sys/libs remove"	
	@c:execute t:_
	@c:delete quiet t:_ >NIL:

sc_%:
	@echo >  t:_ "FailAt 20"
	@echo >> t:_ "execute s:_sc >NIL: "
	@echo >> t:_ "$(MAKE) -f Makefile.sasc $* VERBOSE=$(VERBOSE) CPU=$(CPU)"
	@c:execute t:_
	@c:delete quiet t:_ >NIL:

###############################################################################
# archiving
###############################################################################

zip: 
	rm "$(PROG).zip"
	zip -ru "$(PROG).zip" $(DISTRIB) -x $(wildcard *sasc*)

lha: 
	lha -r u "$(PROG).lha" $(ARCHIVE)
	
# end-of-file
