`include "ALU.v"
`include "ALUControl.v"
`include "ControlUnit.v"
`include "SignExtension.v"
`include "ForwardingUnit.v"
`include "HazardDetectionUnit.v"

module CPU ();
   // Instruction opcodes
	parameter 	LDUR = 	11'b11111000010, 						    // Load
				STUR = 	11'b11111000000, 						    // Save
				ADD = 	11'b10001011000,							// Add
				ADDI = 	11'b1001000100,                             // Add immediate
				SUB = 	11'b11001011000,                            // Subtract
				AND = 	11'b10001010000,                            // Bit-wise And
				ORR = 	11'b10101010000,                            // Bit-wise Or
				CBZ = 	8'b10110100,        	                    // Compare and branch on zero
				CBNZ = 	8'b10110101,    	                        // Compare branch not-on-zero
				B = 	6'b000101,		                            // Unconditional Branch
				HALT = 	11'b11111111111,                            // End program 
				noop = 32'b00000_100000;
				
	reg clock;
	reg [7:0] 	IMemory[0:4095];									// 4096 bytes (1024 words)
	reg [7:0] 	DMemory[0:8191];									// 8192 bytes (1024 double words)
	reg	[63:0]	XRegs[0:31], BranchDest, SignExtReg, PC, IFIDPC, IDEXPC, RegData1, RegData2, WriteData, EXMEMresult, MEMWBresult, ReadData;
	reg [31:0]	IFIDIR;												
	reg [10:0]	ALUinstruction;
	reg [4:0]	IDEXRd, EXMEMRd, MEMWBRd, IDEXRm, IDEXRn;
	reg [2:0] 	haltCounter;
	reg [1:0]	IDEXALUop;
	reg IDEXALUsrc, IDEXBranchZ, IDEXBranchNZ, IDEXMemRead, IDEXMemWrite, IDEXRegWrite,IDEXMem2Reg, IDEXUncondBranch;
	reg EXMEMBranchZ, EXMEMBranchNZ, EXMEMMemRead, EXMEMMemWrite, EXMEMRegWrite, EXMEMMem2Reg, EXMEMUncondBranch, EXMEMZero;
	reg MEMWBRegWrite, MEMWBMem2Reg;
	reg [5:0] i;                                  // used to initialize registers
	
	wire[63:0]	Ain, Bin, ALUresult, SignExtOut, ALUResultWire;
	wire[10:0] 	OPCode;
	wire[4:0]	Rm, Rn, Rd, Rt;
	wire[3:0]	ALUconbits;
	wire[1:0]	ALUop, ForwardA, ForwardB;
 
	
   assign PCsrc = EXMEMUncondBranch || (EXMEMBranchZ && EXMEMZero) || (EXMEMBranchNZ && !EXMEMZero);
   assign OPCode = IFIDIR[31:21];
   assign Rm = IFIDIR[20:16];				// rm field
   assign Rn = IFIDIR[9:5];					// rn field
   assign Rd = IFIDIR[4:0];					// rd field
   assign Rt = IFIDIR[4:0];					// rt field
   assign Ain = ForwardA == 2'b10 ? EXMEMresult : ForwardA == 2'b01 ? MEMWBresult : RegData1;
   assign Bin = ForwardB == 2'b10 ? EXMEMresult : ForwardB == 2'b01 ? MEMWBresult : IDEXALUsrc ? SignExtReg : RegData2;
   
   
   ControlUnit MainControl (OPCode, Reg2Loc, BranchZ, BranchNZ, MemRead, Mem2Reg, ALUop, MemWrite, ALUsrc, RegWrite, UncondBranch, stopFetch);
   ALUcontrol ALUcon (ALUinstruction, IDEXALUop, ALUconbits);
   ALU MainALU (Ain, Bin, ALUconbits, ALUresult, Zero);
   SignExtension SignExt(IFIDIR, SignExtOut);
   ForwardingUnit FUnit(EXMEMRegWrite, MEMWBRegWrite, IDEXRn, IDEXRm, EXMEMRd, MEMWBRd, ForwardA, ForwardB);
   HazardDetectionUnit HDUnit(IDEXMemRead, IDEXRd, Rn, Rm, Stall);
   
   //always @ (ALUresult) begin
   //$monitor("%64b, %5d, %5d, %5d", IFIDIR, Rn, SignExtReg, SignExtOut);
   //end

   initial begin
		PC = 0;
		IFIDIR  = noop;		                        // put no-ops in ALL pipeline registers
		BranchDest = 0;
		SignExtReg = 0;
		IFIDPC = 0;
		IDEXPC = 0;
		RegData1 = 0;
		RegData2 = 0;
		WriteData = 0;
		EXMEMresult = 0;
		MEMWBresult = 0;
		ReadData = 0;
		haltCounter = 0;
		ALUinstruction = 0;
		IDEXRd = 0;
		EXMEMRd = 0;
		MEMWBRd = 0;
		EXMEMUncondBranch = 0;
		EXMEMBranchZ = 0;
		EXMEMZero = 0;
		EXMEMBranchNZ = 0; 
		EXMEMMemRead = 0;
		EXMEMMemWrite = 0;
		EXMEMRegWrite = 0;
		EXMEMMem2Reg = 0;
		IDEXALUop = 0;
		IDEXALUsrc = 0;
		IDEXBranchZ = 0;
		IDEXBranchNZ = 0;
		IDEXMemRead = 0;
		IDEXMemWrite = 0;
		IDEXRegWrite = 0;
		IDEXMem2Reg = 0;
		IDEXUncondBranch = 0;
		MEMWBRegWrite = 0;
		MEMWBMem2Reg = 0;
		IDEXRn = 0;
		IDEXRm = 0;
		$readmemh("IM_Standard_Bytes.txt", IMemory);
		$readmemh("DM_Bytes.txt", DMemory);
 
      //initialize registers--just so they aren't cares
      for (i = 0; i <= 30; i = i + 1)
         XRegs[i] = 0;
   end
   
   
   	// Clock
	always
	begin
		#10 clock = 0;
		#10 clock = 1;
	end
	
	always @ (posedge clock) begin
	// Set XZR to 0
	XRegs[31] <= 0;
	
	// Fetch Instruction if there is no stall
	if (!Stall) begin
	IFIDIR [7:0] <= IMemory[PC];
	IFIDIR [15:8] <= IMemory[PC + 1];
	IFIDIR [23:16] <= IMemory[PC + 2];
	IFIDIR [31:24] <= IMemory[PC + 3];
	
	// Advance PC if there is no stall
	PC <= PCsrc ? BranchDest : PC + 4;
	end
	
	// Determine PC
	PC <= PCsrc ? BranchDest : PC + 4;
	
	// ALU Control Signals
	ALUinstruction <= OPCode; // FIXME: Reg needed
	IDEXALUop <= Stall ? 0 : ALUop;
	IDEXALUsrc <= Stall ? 0 : ALUsrc;
	
	// BranchZ Signal
	IDEXBranchZ <= Stall? 0 : BranchZ;
	EXMEMBranchZ <= IDEXBranchZ;
	
	// BranchNZ Signal
	IDEXBranchNZ <= Stall ? 0 : BranchNZ;
	EXMEMBranchNZ <= IDEXBranchNZ;
	
	// MemRead Signal
	IDEXMemRead <= Stall ? 0 : MemRead;
	EXMEMMemRead <= IDEXMemRead;
	
	// MemWrite Signal
	IDEXMemWrite <= Stall ? 0 : MemWrite;
	EXMEMMemWrite <= IDEXMemWrite;
	
	// RegWrite Signal
	IDEXRegWrite <= Stall ? 0 : RegWrite;
	EXMEMRegWrite <= IDEXRegWrite;
	MEMWBRegWrite <= EXMEMRegWrite;
	
	// MemToReg Signal
	IDEXMem2Reg <= Stall ? 0 : Mem2Reg;
	EXMEMMem2Reg <= IDEXMem2Reg;
	MEMWBMem2Reg <= EXMEMMem2Reg;
	
	// UncondBranch Signal
	IDEXUncondBranch <= Stall ? 0 : UncondBranch;
	EXMEMUncondBranch <= IDEXUncondBranch;
	
	// Zero Signal
	EXMEMZero <= Zero;
	
	// Branch destinations
	if (!Stall) IFIDPC <= PC;
	IDEXPC <= Stall ? 0 : IFIDPC;
	SignExtReg <= SignExtOut;
	BranchDest <= IDEXPC + (SignExtReg << 2); 
	
	// Register Data // FIXME Add Regs
	RegData1 <= XRegs[Rn];
	RegData2 <= Reg2Loc ? XRegs[Rt] : XRegs[Rm];
	WriteData <= RegData2;
	
	// Destination Register
	IDEXRd <= Stall ? 0 : Rd;
	EXMEMRd <= IDEXRd;
	MEMWBRd <= EXMEMRd;
	
	// EXMEMresult
	EXMEMresult <= ALUresult;
	MEMWBresult <= EXMEMresult;
	
	// Data Forwarding
	IDEXRn <= Stall ? 0 : Rn;
	IDEXRm <= Stall ? 0 : Rm;

	
	// Data Memory Access
	if (EXMEMMemRead) begin
		ReadData[7:0] <= DMemory[EXMEMresult];
		ReadData[15:8] <= DMemory[EXMEMresult+1];
		ReadData[23:16] <= DMemory[EXMEMresult+2];
		ReadData[31:24] <= DMemory[EXMEMresult+3];
		ReadData[39:32] <= DMemory[EXMEMresult+4];
		ReadData[47:40] <= DMemory[EXMEMresult+5];
		ReadData[55:48] <= DMemory[EXMEMresult+6];
		ReadData[63:56] <= DMemory[EXMEMresult+7];
		// $monitor("Read Data: %10h", ReadData);
		end
						
	if (EXMEMMemWrite) begin
		// $display("Memory Address: %10h Write Data: %10h", EXMEMresult, WriteData);
		DMemory[EXMEMresult] <= WriteData[7:0];
		DMemory[EXMEMresult+1] <= WriteData[15:8];
		DMemory[EXMEMresult+2] <= WriteData[23:16];
		DMemory[EXMEMresult+3] <= WriteData[31:24];
		DMemory[EXMEMresult+4] <= WriteData[39:32];
		DMemory[EXMEMresult+5] <= WriteData[47:40];
		DMemory[EXMEMresult+6] <= WriteData[55:48];
		DMemory[EXMEMresult+7] <= WriteData[63:56];
		end
		
	// Write Backs
	if (MEMWBRegWrite)
		$monitor(MEMWBMem2Reg, MEMWBRd);
		XRegs[MEMWBRd] <= MEMWBMem2Reg ? ReadData : MEMWBresult;
		
		
	// Halt
	if (stopFetch) begin
		$monitor("final opcode is detected \n");
		$writememh("DM_Final_Bytes.txt", DMemory);
		$finish;
		end
	end
	
endmodule