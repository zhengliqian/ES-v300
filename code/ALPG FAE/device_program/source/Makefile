#
#   Defines
#
VERSION = 0.0.1
PROG    = SampleDevPro.ELF


ifeq ($(LOCAL), 1)
INCLUDE = -I../system_inc/ -I../include/
else
INCLUDE = -I/home/test/Innotech/SonicY/System/inc -I../include/
endif

CHARSET = -finput-charset=cp932 -fexec-charset=cp932
CFLAGS  = $(INCLUDE) -O2 -Wall -D LOGFILE -D LOGPRINT -D USE_NEW_MATCH -Wno-write-strings -MD -g3 -O0

ifeq ($(LOCAL), 1)
ifeq ($(LINK_CHK), 1)
LDFLAGS = -lrt -L../../ -lsml -lbuscon
else
LDFLAGS = -lrt
endif
else
LDFLAGS = -lrt -L/home/test/Innotech/SonicY/System/lib -lsml -lbuscon
endif


# flow select
CFLAGS  += -D_FLOW_DEMO


# backtrace select
ifeq ($(USE_BT), 1)
CFLAGS  += -D USE_BACKTRACE -rdynamic -g3
endif


CC      = g++

SRCDIR  = ./
SRCEXT  = cc
SRC     = $(shell ls $(SRCDIR)*.$(SRCEXT))

OUTDIR  = ../TEST
OBJDIR  = $(OUTDIR)/objs
OBJ     = $(SRC:$(SRCDIR)%.$(SRCEXT)=$(OBJDIR)/%.o)
#DEPFILE = $(OBJDIR)/Makefile.dep
DEPFILE = $(OBJ:%.o=%.d)


TOOLSDIR = ../tools/
FLOW2PRO = $(TOOLSDIR)/flow2pro.py
# flow file select
FLOWFILE = $(SRCDIR)/flow_demo.txt

PROFILE  = $(PROG:%.ELF=%.PRO)

SML_VER_SH = /home/test/Innotech/SonicY/sml_version.sh
ifeq ($(LOCAL), 1)
SML_VER = 1.1
else
SML_VER = $(shell $(SML_VER_SH) | cut -b -3)
endif


#
#   Recipes
#
all: 
	@echo "Compile Options: $(CFLAGS) $(CHARSET)\n"
	make $(OUTDIR)/$(PROG) 
	make $(OUTDIR)/$(PROFILE)

$(OUTDIR)/$(PROFILE): $(FLOWFILE)
	@mkdir -p -m 755 $(OUTDIR)
	@chmod 755 $(FLOW2PRO)
	$(FLOW2PRO) $(OUTDIR)/$(PROG) $(FLOWFILE) Ver$(SML_VER)
	@mv ${PROFILE} $(OUTDIR)

clean:
	rm -f $(OBJ)
	rm -f $(OUTDIR)/$(PROG)
	rm -f $(OUTDIR)/$(PROFILE)
	rm -f $(DEPFILE)

#dep: $(DEPFILE)

#$(DEPFILE):
#	$(CC) -MM $(CFLAGS) $(SRC) > $(DEPFILE)


.SUFFIXES: .$(SRCEXT) .o

$(OBJDIR)/%.o: %.$(SRCEXT)
	@mkdir -p -m 755 $(OBJDIR)
	@echo "Compile o: $<"
	@$(CC) $< $(CFLAGS) $(CHARSET) -c -o $@
 
$(OUTDIR)/$(PROG): $(OBJ)
	@mkdir -p -m 755 $(OUTDIR)
	@echo "\nCompile C: $(OBJ)\n"
	@$(CC) $(OBJ) $(CFLAGS) $(LDFLAGS) -o $@

#
#   Include dependency-files
#
ifneq ($(DEPFILE),)
-include $(DEPFILE)
endif
