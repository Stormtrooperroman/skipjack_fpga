TOPLEVEL_LANG = verilog

all: f_box round skipjack_iterative

f_box:
	$(MAKE) run TEST_NAME=f_box VERILOG_SOURCES=$(PWD)/../rtl/f_box.sv

round:
	$(MAKE) run TEST_NAME=round VERILOG_SOURCES+=$(PWD)/../rtl/round.sv VERILOG_SOURCES+=$(PWD)/../rtl/f_box.sv

skipjack_iterative:
	$(MAKE) run TEST_NAME=skipjack_iterative VERILOG_SOURCES+=$(PWD)/../rtl/skipjack_iterative.sv VERILOG_SOURCES+=$(PWD)/../rtl/round.sv VERILOG_SOURCES+=$(PWD)/../rtl/f_box.sv

run:
	@rm -rf $(PWD)/sim_build
	@echo "VERILOG_SOURCES=$(VERILOG_SOURCES)"
	$(MAKE) -f $(shell cocotb-config --makefiles)/Makefile.sim \
		TOPLEVEL=$(TEST_NAME) MODULE=test_$(TEST_NAME) \
		VERILOG_SOURCES="$(VERILOG_SOURCES)" \
		TOPLEVEL_LANG=$(TOPLEVEL_LANG)

	
