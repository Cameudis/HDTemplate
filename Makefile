TOPNAME = top
HDL ?= chisel
# HDL ?= verilog

BUILD_DIR = ./build
OBJ_DIR = ./build/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)
CHISEL_OUT = $(BUILD_DIR)/gen_vsrc

all: $(BIN)

$(shell mkdir -p $(BUILD_DIR) $(CHISEL_OUT))

# NVBoard
NXDC_FILES = constr/top.nxdc
SRC_AUTO_BIND = $(abspath $(BUILD_DIR)/auto_bind.cpp)
$(SRC_AUTO_BIND): $(NXDC_FILES)
	@echo "Generating auto bind file..."
	@python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@

# Chisel
CHISEL_SRCS = $(shell find $(abspath ./vsrc/) -name "*.scala")

# source files
CHISEL_VSRCS = $(sort $(shell find $(CHISEL_OUT) -name "*.sv") $(CHISEL_OUT)/top.sv)
VERILOG_SRCS = $(shell find $(abspath ./vsrc) -name "*.v")
ifeq ($(HDL), chisel)
	VSRCS = $(CHISEL_VSRCS)
else
	VSRCS = $(VERILOG_SRCS)
endif
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")
CSRCS += $(SRC_AUTO_BIND)

test:
	@sbt "runMain TestMain"

$(CHISEL_VSRCS) &: $(CHISEL_SRCS)
	@echo "Running Chisel to generate Verilog..."
	@sbt "runMain VerilogMain --target-dir $(CHISEL_OUT)"

include $(NVBOARD_HOME)/scripts/nvboard.mk

# rules for verilator
INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""

$(BIN): $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE)
	@rm -rf $(OBJ_DIR)
	bear -- verilator --cc --build -j 0 --trace-fst \
		--top-module $(TOPNAME) $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE) \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))

sim: $(BIN)
	@$^ +trace

clean:
	@rm -rf $(BUILD_DIR) logs

.PHONY: clean all sim chisel_target

