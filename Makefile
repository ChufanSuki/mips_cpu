TESTBENCH = sim/testbench
SRCS			= rtl/adder.sv rtl/alu_decoder.sv rtl/alu.sv rtl/controller.sv rtl/datapath.sv rtl/flopenr.sv rtl/floprc.sv rtl/flopr.sv rtl/hazard.sv rtl/flopenrc.sv rtl/main_decoder.sv rtl/mips.sv rtl/mux2.sv rtl/mux3.sv rtl/regfile.sv rtl/sign_extend.sv rtl/sl2.sv rtl/top.sv rtl/imem.sv rtl/dmem.sv
RESULT    = result
V_FLAG    = -g2012 

#------------------------------------------------------------------------------
# You should't be changing what is below
#------------------------------------------------------------------------------
all: simulate

lint:
	verilator --top-module top --lint-only $(SRCS)

simulate:
	iverilog -o $(TESTBENCH).vvp $(SRCS) $(TESTBENCH).sv
	vvp $(TESTBENCH).vvp > $(TESTBENCH)_log.txt

gtkwave:
	gtkwave $(RESULT).vcd

scansion: simulate
	open /Applications/Scansion.app $(RESULT).vcd

clean:
	rm -rf $(TESTBENCH).vvp $(RESULT).vcd $(TESTBENCH)_log.txt $(TESTBENCH)/*_log.txt  $(TESTBENCH)/*.vvp
