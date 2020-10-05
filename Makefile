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
CAT          = cat
RM           = rm

TMP          = /tmp/
NIL          = /dev/null
HERE         = ./

ifeq ($(VERBOSE),)
INFO         = echo
HIDDEN       = @
else
INFO         = @true
HIDDEN       =
endif
NOLINE       = -n


ifeq ($(OS),)
# vbcc/sasc/etc :)
OS           = AmigaOS
MKDIR        = c:makedir
TOUCH        = :ade/bin/touch  # FIXME
NOLINE       = noline
CAT          = c:type
RM           = c:delete
TMP          = t:
NIL          = nil:
HERE         =
endif

ifeq ($(OS), AmigaOS)
OS           = aos
CPU          = 60330
DEFINES      = -DAMIGA
endif

EXT         ?= $(CC)-$(shell $(CC) -dumpversion)
OBJDIR      ?= objs-$(EXT)

EXE          = $(PROG)-$(OS)-$(CPU)-$(EXT)
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

###############################################################################
# top-level targets
###############################################################################

all: compile

tst: compile do_tst_fill do_tst_-h do_tst_all_-v5

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
	$(HIDDEN)$(INFO) $(NOLINE) Linking to $@...
	$(HIDDEN)$(CC) $(LDFLAGS) $^ $(LINK_TO) $@ $(LIBS) 
	$(HIDDEN)$(INFO) done
	
$(OBJS): $(MAKEFILE_LIST)

$(OBJDIR)/%.o: src/Inform6/%.c
	$(HIDDEN)$(INFO) $(NOLINE) Compiling $<...
	$(HIDDEN)$(CC) $(OFLAGS) $(CFLAGS) $(WFLAGS) $(DEFINES:-D%=$(DFLAG)%) \
		$(COMPILE_TO) "$@" "$<" 
	$(HIDDEN)$(INFO) done

$(OBJDIR)/%.o: src/Amiga/%.c
	$(HIDDEN)$(INFO) $(NOLINE) Compiling $<...
	$(HIDDEN)$(CC) $(OFLAGS) $(CFLAGS) $(WFLAGS) $(DEFINES:-D%=$(DFLAG)%) \
		$(COMPILE_TO) "$@" "$<" 
	$(HIDDEN)$(INFO) done

DATE         = date
INC_REVISION = 	read n < $@; n=`expr $$n + 1`; \
              	echo > $@ $$n; \
              	echo >> $@ ";"; \
              	echo >>$@ "\#define REVISION $$n"

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
	$(TOUCH) $(OBJDIR)/*.o 
	$(TOUCH) $(MAKEFILE_LIST)

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
		http://inform-fiction.org/examples/index.html
	
do_tst_all_%: 
	$(eval INF = $(wildcard test/*.inf))
	@$(MAKE) -s $(subst /,-slash-, $(addprefix do_tst_$*_, $(INF)))
	
do_tst_%:
	$(HIDDEN)$(INFO) $(NOLINE) Testing $(subst _, , $(subst -slash-,/,$*))...
	$(HIDDEN)$(HERE)$(EXE) >$(TMP)_$* +test/Library $(TST_$*) \
		$(subst _, , $(subst -slash-,/,$*)) || ($(CAT) $(TMP)_$* && fail)
	$(HIDDEN)$(RM) $(TMP)_$*
	$(HIDDEN)$(INFO) "ok"
