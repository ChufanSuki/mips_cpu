TESTBENCH = sim/testbench
SRCS			= rtl/adder.v rtl/alu_decoder.v rtl/alu.v rtl/controller.v rtl/datapath.v rtl/flopenr.v rtl/floprc.v rtl/flopr.v rtl/hazard.v rtl/flopenrc.sv rtl/main_decoder.v rtl/mips.v rtl/mux2.v rtl/mux3.v rtl/regfile.v rtl/sign_extend.v rtl/sl2.v rtl/top.v rtl/imem.sv rtl/dmem.sv
RESULT    = result
V_FLAG    = -g2012 

#------------------------------------------------------------------------------
# You should't be changing what is below
#------------------------------------------------------------------------------
all: simulate

lint:
	verilator --top-module top --lint-only $(SRCS)

simulate:
	iverilog -o $(TESTBENCH).vvp $(SRCS) $(TESTBENCH).v
	vvp $(TESTBENCH).vvp > $(TESTBENCH)_log.txt

gtkwave:
	gtkwave $(RESULT).vcd

scansion: simulate
	open /Applications/Scansion.app $(RESULT).vcd

clean:
	rm -rf $(TESTBENCH).vvp $(RESULT).vcd $(TESTBENCH)_log.txt $(TESTBENCH)/*_log.txt  $(TESTBENCH)/*.vvp
