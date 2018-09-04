# VerilogCPU
ARMv8 Processor written in Verilog

* Doubleword registers
* Supports data forwarding
* Detects data hazards and stalls

Opcodes Supported:
ADD
ADDI
SUB
SUB
AND
ORR
CBZ
CBNZ
B
LDUR
STUR

Primary Files Included:
* CPU.v -- Main data pipeline
* ControlUnit.v -- Interprets opcode control signals
* ALUcontrol.v -- Produces control signals for main ALU
* ALU.v -- Executes arithmetic and logical operations for R, I, and D-type instructions
* HazardDetectionUnit.v -- Detects data hazards and outputs stall signal if necessary
* SignExtensionUnit.v -- Performs sign extension for B, CB, I, and D-type instructions

Test Benches:
* CPU_tb.v
* ALUControl_tb.v
* SignExtension_tb.v
