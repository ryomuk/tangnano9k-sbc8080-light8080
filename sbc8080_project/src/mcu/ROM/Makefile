BINFILE=27128@DIP28.BIN
#BINFILE=MSBAS80.BIN
OBJFILE=obj_code_pkg.vhdl

CONVERTER=./bin2vhdl.exe
SRC_CONVERTER=bin2vhdl.c

$(OBJFILE): $(BINFILE) $(CONVERTER)
	$(CONVERTER) $(BINFILE) > $(OBJFILE)

$(CONVERTER): $(SRC_CONVERTER)
	gcc -o $(CONVERTER) $(SRC_CONVERTER)
