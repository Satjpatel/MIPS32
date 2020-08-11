//MIPS32 Basic Implmentation 
//Engineer : Sat Patel 

module MIPS32 ( clk1, clk2 ) ; 

//Using two phase clock, for avoiding clashes and clock skews 

//Register Bank 
reg [31:0] RegBank [31:0] ; //Register bank ( 32 X 32 ) 

//Memory - 1024 x 32 
reg [31:0] Mem [1023:0] ; 

//Declaring the opcodes for the various instructions 
parameter ADD = 6'b000000 , SUB = 6'b000001, AND = 6'b000010, 
	OR = 6'b000011, SLT = 6'b000100, MUL = 6'b000101, HLT = 6'b111111, 
	LW = 6'b001000, SW = 6'b001001, ADDI = 6'b001010, SUBI = 6'b001011, 
	SLTI = 6'b001100, BNEQZ = 6'b001101, BEQZ = 6'b001110 ; 
	

//Types of instructions 
parameter RR_ALU = 3'b000, RM_ALU = 3'b001, LOAD = 3'b010, 
		STORE = 3'b011, BRANCH = 3'b100, HALT = 3'b101 ; 
		
reg HALTED ; 
//Set after HLT instruction is completed - in WB stage 

reg TAKEN_BRANCH ; 
//Required to disable instructions after branch 


//Defining intermediate latches between Instruction Fetch stage 
//and Instruction Decode 

reg [31:0] PC, IF_ID_IR, IF_ID_NPC ; 
//PC- Program Counter 
//IR - Instruction Register 
//NPC - Next Program Counter 

//Instruction Fetch Stage 

endmodule 

