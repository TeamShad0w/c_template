#~constants
#! THESE CONSTANTS MUST BE FILLED IN FOR THE MAKEFILE TO WORK PROPERLY
SRC_DIR=the source directory (e.g. ./src)
BIN_DIR=the directory containing the binaries (e.g. ./bin)
BUILD_DIR=the directory in wich the distribuable executable(s) will be placed (e.g. ./build)
EXEC=the executable (e.g. app.exe)
TEST_EXEC=the test code compiled into an executable (e.g. test.exe)
TEST_SUBEXT=the subextension for test files (e.g. .test) (Test file example : main.test.c)
C=the compiler you want to use (e.g. gcc)
SRCEXTENSION=the extension for the source files (e.g. .c)
OBJEXTENSION=the extension to use for the object files (e.g. .c.o)
INCLUDEDIR=the path to the directory containing all header files (e.g ./include)
HEADEREXTENSION=the extension to use for the header files (e.g .h)
CFLAGS=the flag(s) to use for the compiler (will be put just after the compiler call)
C2OFLAGS=the flag(s) to use for the compilation from code to object files (will be put at the end of the command line) (e.g. -W)
O2EXEFLAGS=the flag(s) to use for the linking of the different object files into an executable (will be put at the end of the command line)


#~processed var
RAW_SRC_FILES_PATH=$(wildcard $(SRC_DIR)/*$(SRCEXTENSION))
SOURCE_FILES=$(foreach file, $(RAW_SRC_FILES_PATH:$(SRC_DIR)/%=%), $(if $(findstring $(TEST_SUBEXT),$(file)),,$(file)))
SRC=$(foreach file, $(SOURCE_FILES), $(SRC_DIR)/$(file))
OBJ=$(foreach file, $(SOURCE_FILES), $(BIN_DIR)/$(file:$(SRCEXTENSION)=$(OBJEXTENSION)))
TEST_FILES=$(foreach file, $(RAW_SRC_FILES_PATH:$(SRC_DIR)/%=%), $(if $(findstring $(TEST_SUBEXT),$(file)),$(file)))
TEST_SRC=$(foreach file, $(TEST_FILES), $(SRC_DIR)/$(file))
TEST_OBJ=$(foreach file, $(TEST_FILES), $(BIN_DIR)/$(file:$(SRCEXTENSION)=$(OBJEXTENSION)))

#~run command arguments parsing into RUN_ARGS
ifneq (,$(filter $(firstword $(MAKECMDGOALS)), run fullauto))
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(RUN_ARGS):;@:)
endif

#~MAKEFILE

all: $(BIN_DIR)_dir $(BIN_DIR)/$(EXEC) $(BIN_DIR)/$(TEST_EXEC)

$(BIN_DIR)/$(EXEC): $(OBJ)
	$(C) $(CFLAGS) -o $@ $^ $(O2EXEFLAGS)

$(BIN_DIR)/%$(OBJEXTENSION): $(SRC_DIR)/%$(SRCEXTENSION) $(SRC_DIR)/%.h
	$(C) $(CFLAGS) -c -o $@ $< $($@) $(C2OFLAGS)

$(BIN_DIR)/%$(OBJEXTENSION): $(SRC_DIR)/%$(SRCEXTENSION)
	$(C) $(CFLAGS) -c -o $@ $< $(C2OFLAGS)

$(BIN_DIR)/$(TEST_EXEC): $(TEST_OBJ)
	$(C) $(CFLAGS) -o $@ $^ $(O2EXEFLAGS)

$(BIN_DIR)/%$(TEST_SUBEXT)$(OBJEXTENSION) : $(SRC_DIR)/%$(TEST_SUBEXT)$(SRCEXTENSION) $(INCLUDE)/%($HEADEREXTENSION)
	$(C) $(CFLAGS) -c -o $@ $< $($@) $(C2OFLAGS)

$(BIN_DIR)/%$(TEST_SUBEXT)$(OBJEXTENSION): $(SRC_DIR)/%$(TEST_SUBEXT)$(SRCEXTENSION)
	$(C) $(CFLAGS) -c -o $@ $< $(C2OFLAGS)

#~UTILS

.PHONY: clean reset build fullauto rbin rbuild run

clean:
	rm -rf $(BIN_DIR)/*$(OBJEXTENSION)

reset:
	rm -rf $(BIN_DIR)
	rm -rf $(BUILD_DIR)

build: $(BIN_DIR)_dir $(BUILD_DIR)_dir $(BIN_DIR)/$(EXEC)
	cp $(BIN_DIR)/*.exe $(BUILD_DIR)
	set -- *.dll \
    ; if [ -e "$$1" ]; then \
        cp $(BIN_DIR)/*.dll $(BUILD_DIR); \
    fi
#^remove created files if wanted clean
ifeq (clean,$(firstword $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))))
	rbin
endif

fullauto: build
	$(BUILD_DIR)/$(EXEC) $(RUN_ARGS)

rbin:
	rm -rf $(BIN_DIR)

rbuild:
	rm -rf $(BUILD_DIR)

run: $(BUILD_DIR)/$(EXEC) | build
	$(BUILD_DIR)/$(EXEC) $(RUN_ARGS)

test: $(BIN_DIR)_dir $(BIN_DIR)/$(TEST_EXEC)
	$(BIN_DIR)/$(TEST_EXEC) $(RUN_ARGS)

#~DIRECTORIES

$(BUILD_DIR)_dir:
	mkdir $(BUILD_DIR) -p

$(BIN_DIR)_dir :
	mkdir $(BIN_DIR) -p

#~DEBUG
debug:
	@echo There is no debug script written in $(CURDIR)/makefile :: debug
