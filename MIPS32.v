//MIPS32 Basic Implmentation 
//Engineer : Sat Patel 

module MIPS32 ( clk1, clk2 ) ; 

//Using two phase clock, for avoiding clashes and clock skews 
input clk1, clk2 ; 
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
		
reg [2:0] ID_EX_type, EX_MEM_type, MEM_WB_type ; 
		
reg HALTED ; 
//Set after HLT instruction is completed - in WB stage 

reg TAKEN_BRANCH ; 
//Required to disable instructions after branch 


//Defining intermediate latches between Instruction Fetch stage 
//and Instruction Decode stage 

reg [31:0] PC, IF_ID_IR, IF_ID_NPC ; 
//PC- Program Counter 
//IR - Instruction Register 
//NPC - Next Program Counter 

//Defining intermediate latches between Instruction Decode stage and 
//Execute stage 
reg [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm ; 

//Defining intermediate latches between Execute Stage and Memory Stage 
reg [31:0] EX_MEM_IR, EX_MEM_ALUOut, EX_MEM_B ; 
reg EX_MEM_cond ; 

//Defining intermediate latches between Memory Stage and Write back stage 
reg [31:0] MEM_WB_IR, MEM_WB_ALUOut, MEM_WB_LMD ; 

//Instruction Fetch Stage 

always @ ( posedge clk1 ) 

	if ( HALTED == 0 ) 
		begin 
			if(((EX_MEM_IR[31:26] == BEQZ) && (EX_MEM_cond == 1)) || ((EX_MEM_IR[31:26] == BNEQZ) && (EX_MEM_cond == 0))) 
				begin 
					IF_ID_IR <= Mem[EX_MEM_ALUOut] ; 
					TAKEN_BRANCH <= 1'b1 ; 
					IF_ID_NPC <= EX_MEM_ALUOut + 1 ; 
					PC <= EX_MEM_ALUOut + 1 ; 
				end 
		else 
			begin 
				IF_ID_IR <= Mem[PC] ; 
				IF_ID_NPC <= PC + 1 ; 
				PC <= PC + 1 ; 
			end 
		end 

//Instruction Decode Stage or Register Fetch stage

always @ ( posedge clk2 ) 

	if(HALTED == 0 ) 
		begin 
			if(IF_ID_IR[25:21] == 5'b00000) 
				ID_EX_A <= 0 ; 
			else 
				ID_EX_A <= RegBank[IF_ID_IR[25:21]] ; //"rs" 
			
			if(IF_ID_IR[20:16] == 5'b00000) 
				ID_EX_B <= 0 ; 
			else 
				ID_EX_B <= RegBank[IF_ID_IR[20:16]] ; //"rt" 
			
			ID_EX_NPC <= IF_ID_NPC ; 
			ID_EX_IR <= IF_ID_IR ; 
			ID_EX_Imm <= { {16{IF_ID_IR[15]} } , {IF_ID_IR[15:0] }} ; 
			
		case (IF_ID_IR[31:26]) 
			ADD, SUB, AND, OR, SLT, MUL:  ID_EX_type <= RR_ALU ; 
			ADDI, SUBI, SLTI: 			  ID_EX_type <= RM_ALU ; 
			LW: 						  ID_EX_type <= LOAD   ;
			SW: 						  ID_EX_type <= STORE  ;	 
			BNEQZ, BEQZ: 				  ID_EX_type <= BRANCH ;
			HLT: 						  ID_EX_type <= HALT   ;
			default: 					  ID_EX_type <= HALT   ;	//In case of invalid opcode 
		endcase 
	end 

//Execution Stage or Effective Address Calculation

always @ (posedge clk1) 
	
	if(HALTED == 0) 
	begin 
		EX_MEM_type <= ID_EX_type ; 
		EX_MEM_IR <= ID_EX_IR ; 
		TAKEN_BRANCH <= 0 ; 
		
		case ( ID_EX_type) //Decoding the type of instruction format 
		
		RR_ALU: begin 	//Register to Register type instructions 
					case(ID_EX_IR[31:26]) // opcode for Register to Register ALU instructions 
						ADD: EX_MEM_ALUOut <= ID_EX_A + ID_EX_B ; 
						SUB: EX_MEM_ALUOut <= ID_EX_A - ID_EX_B ; 
						AND: EX_MEM_ALUOut <= ID_EX_A & ID_EX_B ; 
						OR : EX_MEM_ALUOut <= ID_EX_A | ID_EX_B ; 
						SLT: EX_MEM_ALUOut <= ID_EX_A < ID_EX_B ; 
						MUL: EX_MEM_ALUOut <= ID_EX_A * ID_EX_B ; 
						default: EX_MEM_ALUOut <= 32'hxxxxxxxx ; 
					endcase 
				end 
		RM_ALU: begin //Register to memory type instructions 
					case( ID_EX_IR[31:26]) // opcode for Register to Memory ALU isntructions 
						ADDI: EX_MEM_ALUOut <= ID_EX_A + ID_EX_Imm ; 
						SUBI: EX_MEM_ALUOut <= ID_EX_A - ID_EX_Imm ; 
						SLTI: EX_MEM_ALUOut <= ID_EX_A < ID_EX_Imm ; 
						default: EX_MEM_ALUOut <= 32'hxxxxxxxx ; 
					endcase 
				end 
		LOAD, STORE: begin //Load and store instructions 
						EX_MEM_ALUOut <= ID_EX_A + ID_EX_Imm ; 
						EX_MEM_B <= ID_EX_B ; 
					end 
		BRANCH: begin 
					EX_MEM_ALUOut <= ID_EX_NPC + ID_EX_Imm ; 
					EX_MEM_cond <= (ID_EX_A == 0 ) ; 
				end 
		endcase 
	end 
	

//Memory access stage or Branch Completion  

always @ (posedge clk2) 
	if(HALTED == 0 ) 
	begin 
		MEM_WB_type <= EX_MEM_type ; 
		MEM_WB_IR <= EX_MEM_IR ; 
		
		case (EX_MEM_type) 
			RR_ALU, RM_ALU: MEM_WB_ALUOut <= EX_MEM_ALUOut ; 
			
			LOAD		  : MEM_WB_LMD <= Mem[EX_MEM_ALUOut] ; 
			
			STORE         : if(TAKEN_BRANCH == 0 ) //Disabling Writing Function  
								Mem[EX_MEM_ALUOut] <= EX_MEM_B ; 
			default		  : MEM_WB_ALUOut <= 32'hxxxxxxxx ; 
		endcase 
	end 
	
//Write back Stage 

					
always @ (posedge clk1) 
	
	begin 
		if(TAKEN_BRANCH == 0) // Disable writing if branch is taken 
		case(MEM_WB_type)
		RR_ALU: RegBank[MEM_WB_IR[15:11]] <= MEM_WB_ALUOut ; // 'rd' 
		
		RM_ALU: RegBank[MEM_WB_IR[20:16]] <= MEM_WB_ALUOut ; // 'rt' 
		
		LOAD  : RegBank[MEM_WB_IR[20:16]] <= MEM_WB_LMD    ; // 'rt' in Load Instructions 
		
		HALT  : HALTED <= 1'b1 ; 
		endcase 
	end 


endmodule 

