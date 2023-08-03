#
# Set ASMTOHEX.
#
CC=g++ # Can be overrided => make CC=icc

CFLAGS+=-MD -MP # Autogenerate dependencies.
CFLAGS+=-O0 -std=c++17 -Wall -g

#
# Directories.
#
BINDIR=bin
OBJDIR=obj
SRCDIR=src

#
# Adds .o as suffix and $OBJDIR as prefix to every string stored in $1.
# E.g. one two -> $(OBJDIR)/one.o $(OBJDIR)/two.o
#
define name_to_object
	$(addsuffix .o,$(addprefix $(OBJDIR)/,$(1)))
endef

#
# Files.
#
SRCS:=$(wildcard $(SRCDIR)/*.cpp)
OBJS:=$(subst $(SRCDIR),$(OBJDIR),$(SRCS:%.cpp=%.o))
DEPS:=$(subst $(SRCDIR),$(OBJDIR),$(SRCS:%.cpp=%.d))

#
# Executables.
#
ASMTOHEX=$(BINDIR)/asmtohex
_ASMTOHEX_OBJS=asmtohex
ASMTOHEX_OBJS=$(call name_to_object,$(_ASMTOHEX_OBJS))

#
# Generate executables
#
$(ASMTOHEX): $(ASMTOHEX_OBJS) | $(BINDIR)
	$(CC) $(CFLAGS) $^ -o $@

#
# Generate objects.
#

$(OBJS): $(OBJDIR)/%.o: $(SRCDIR)/%.cpp | $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@

#
# Dependencies to force the creation of $(BINDIR) and $(OBJDIR) directories.
#
$(BINDIR):
	@mkdir -p $@
$(OBJDIR):
	@mkdir -p $@

#
# Include dependencies.
#
-include $(DEPS)

#
# Rules
#
.DEFAULT_GOAL:=all
.PHONY: all
all: $(ASMTOHEX)

ASMTOHEX: $(ASMTOHEX)

.PHONY: clean
clean:
	rm -rf $(BINDIR)/*
	rm -rf $(OBJDIR)/*

.PHONY: clean_obj
clean_obj:
	rm -rf $(OBJDIR)/*