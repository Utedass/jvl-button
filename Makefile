# This makefile is not made by a pro, you might need to fix it.

# One thing to note is that elaboration is not necessary when using
# ghdl compiled with mcode, thus it has no dependencies in this file.
# If ghdl instead was compiled with GCC/LLVM then there will be an
# output file that should be involved in this file.
# See the documentation https://ghdl.github.io/ghdl/using/InvokingGHDL.html
# under elaboration and "With regard to the artifacts"

##### All variables you need to edit are moved here:

# Main design entity
PRIMARY_DESIGN = top

# Add design files to this row (not test benches), expected to reside in hdl_design/ subfolder
DESIGN_FILES = $(PRIMARY_DESIGN).vhd jvl-generic-clk-en-divider/hdl_design/generic_clk_en_divider.vhd jvl-generic-counter/hdl_design/generic_counter.vhd

# Add all testbench-related file names on this row, expected to reside in testbench/ subfolder
TEST_BENCHES = $(PRIMARY_DESIGN)_tb.vhd

# Name of the testbench entity to simulate (the entity name, not the filename)
TOP_TESTBENCH = $(PRIMARY_DESIGN)_tb

##### NO TOUCHIES FURTHER DOWN IN THE FILE


# Commands for GHDL and gtkwave, doesn't necessarily need to be variables but you know..
GHDL = ghdl
VIEWER = gtkwave
WAVEFILE = simulation/waves.vcd
VIEWERTCL = simulation/gtkwave.tcl

# Create a string of ghdl options
WORK_DIR = simulation
WORK_LIBRARY = work
GHDL_OPTIONS = --work=$(WORK_LIBRARY) --workdir=$(WORK_DIR) --std=93c

# Create a complete string of all design files prepended with the directory path
DESIGN_FILES_DIR = hdl_design
DESIGN_FILES_FULL_PATH = $(addprefix $(DESIGN_FILES_DIR)/,$(DESIGN_FILES))

# Create a complete string of all testbench files prepended with the directory path
TEST_BENCHES_DIR = testbench
TEST_BENCHES_FULL_PATH = $(addprefix $(TEST_BENCHES_DIR)/,$(TEST_BENCHES))


# Ensure none of these targets are treated as if they build a file, they will be used as aliases
.PHONY: all clean analyze elaborate run view debug

# Make it easier to write the aliases
ANALYZE_ARTIFACT = $(WORK_DIR)/$(WORK_LIBRARY)-obj93.cf
# This line might need update if using GHDL compiled with GCC/LLVM
ELABORATE_ARTIFACT = $(ANALYZE_ARTIFACT)
RUN_ARTIFACT = $(WAVEFILE)

all: analyze elaborate run view

$(ANALYZE_ARTIFACT): $(DESIGN_FILES_FULL_PATH) $(TEST_BENCHES_FULL_PATH)
	$(GHDL) -a $(GHDL_OPTIONS) $(DESIGN_FILES_FULL_PATH) $(TEST_BENCHES_FULL_PATH)

analyze: $(ANALYZE_ARTIFACT)

#$(ELABORATE_ARTIFACT): $(DESIGN_FILES_FULL_PATH) $(TEST_BENCHES_FULL_PATH)

#elaborate: $(ELABORATE_ARTIFACT)
#	$(GHDL) -e $(GHDL_OPTIONS) $(TOP_TESTBENCH)

$(RUN_ARTIFACT): $(ELABORATE_ARTIFACT)
	$(GHDL) -r $(GHDL_OPTIONS) $(TOP_TESTBENCH) --vcd=$(WAVEFILE)

run: $(RUN_ARTIFACT)

view: $(RUN_ARTIFACT)
	$(VIEWER) $(WAVEFILE) -S $(VIEWERTCL)

clean:
	$(GHDL) --remove $(GHDL_OPTIONS)
	$(RM) $(WAVEFILE)

debug:
	echo $(DESIGN_FILES_FULL_PATH)
