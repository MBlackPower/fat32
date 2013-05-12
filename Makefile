#
# Created by makemake (Darwin Dec  1 2012) on Sun May 12 13:09:54 2013
#

#
# Definitions
#

.SUFFIXES:
.SUFFIXES:	.a .o .c .C .cpp .s
.c.o:
		$(COMPILE.c) $<
.C.o:
		$(COMPILE.cc) $<
.cpp.o:
		$(COMPILE.cc) $<
.s.o:
		$(COMPILE.cc) $<
.c.a:
		$(COMPILE.c) -o $% $<
		$(AR) $(ARFLAGS) $@ $%
		$(RM) $%
.C.a:
		$(COMPILE.cc) -o $% $<
		$(AR) $(ARFLAGS) $@ $%
		$(RM) $%
.cpp.a:
		$(COMPILE.cc) -o $% $<
		$(AR) $(ARFLAGS) $@ $%
		$(RM) $%

CC =		gcc
CXX =		g++

RM = rm -f
AR = ar
LINK.c = $(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS)
LINK.cc = $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(LDFLAGS)
COMPILE.c = $(CC) $(CFLAGS) $(CPPFLAGS) -c
COMPILE.cc = $(CXX) $(CXXFLAGS) $(CPPFLAGS) -c

########## Default flags (redefine these with a header.mak file if desired)
CXXFLAGS =	-ggdb -Wall -ansi -pedantic --std=c99
CFLAGS =	-ggdb -Wall -ansi -pedantic --std=c99
BINDIR =.
CLIBFLAGS =	-lm
CCLIBFLAGS =	
########## End of default flags


CPP_FILES =	
C_FILES =	fat32.c fat_common.c mkfs.c shell.c skinny28.c vfs.c
S_FILES =	
H_FILES =	fat32.h fat_common.h fs_types.h skinny28.h vfs.h
SOURCEFILES =	$(H_FILES) $(CPP_FILES) $(C_FILES) $(S_FILES)
.PRECIOUS:	$(SOURCEFILES)
OBJFILES =	fat32.o fat_common.o skinny28.o vfs.o 

#
# Main targets
#

all:	${BINDIR}/mkfs ${BINDIR}/shell 

${BINDIR}/mkfs:	mkfs.o $(OBJFILES)
	@mkdir -p ${BINDIR}/
	$(CC) $(CFLAGS) -o ${BINDIR}/mkfs mkfs.o $(OBJFILES) $(CLIBFLAGS)

${BINDIR}/shell:	shell.o $(OBJFILES)
	@mkdir -p ${BINDIR}/
	$(CC) $(CFLAGS) -o ${BINDIR}/shell shell.o $(OBJFILES) $(CLIBFLAGS)

#
# Dependencies
#

fat32.o:	fat32.h fat_common.h fs_types.h
fat_common.o:	fat_common.h
mkfs.o:	fat_common.h fs_types.h skinny28.h
shell.o:	fat32.h fat_common.h fs_types.h skinny28.h vfs.h
skinny28.o:	fat_common.h fs_types.h skinny28.h
vfs.o:	fat32.h fat_common.h fs_types.h skinny28.h vfs.h

#
# Housekeeping
#

Archive:	archive.tgz

archive.tgz:	$(SOURCEFILES) Makefile
	tar cf - $(SOURCEFILES) Makefile | gzip > archive.tgz

clean:
	-/bin/rm $(OBJFILES) mkfs.o shell.o core 2> /dev/null

realclean:        clean
	-/bin/rm -rf ${BINDIR}/mkfs ${BINDIR}/shell 
