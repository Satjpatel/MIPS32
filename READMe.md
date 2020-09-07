# MIPS32 Implementation

### Basic implementation of MIPS32 (word addressable), taking a subset of the larger instruction set (though having the functionality to extend). 
This implementation has 32 registers, each of 32 bits (R0 being directly connected to ground) 

It also has a special purpose 32 bit register-> Program Counter (PC). It points to the next instruction in memory to be fetched and executed. 


## Instructions being considered: 

#### 1. Load and Store Instructions 



	LW Rd, #offset(Rs)  // Rd = mem[#offset+Rs] 
	Sw Rd, -#offset(Rs) // mem[Rs-#offset] = Rd 
	
 

#### 2. Arithmetic and Logic Instructions 

##### 		2.1 Only register instructions


		ADD R1, R2, R3 // R1 = R2 + R3 
		SUB R1, R2, R3 //R1 = R2 - R3 
		AND R20, R1, R5 //R20 = R1 & R5 
		OR R11, R3, R2 //R11 = R2 | R3 
		MUL R1, R2, R3 //R1 = R2*R3 
		SLT R1, R2, R3 //Set if less than -> if(R2<R3) -> R1 = 1 , else R1 = 0 



##### 		2.2 Immediate instructions 
	

		ADDI R1, R2, #offset // R1 = R2 + #offset 
		SUBI R1, R2, #offset // R1 = R2 - #offset 
		SLTI R1, R2, #offset // if(R2 < #offset) -> R1 = 1 , else R1 = 0 
	


#### 3. Branch Instructions 


	BEQZ R1, Label //Branch to Label if R1 = 0 
	BNEQZ R1, Label //Branch to Label if R1 = 1 
	


#### 4. Miscellaneous Instruction 


	HLT 
	


#### 5. Jump Instruction (Present in MIPS 32, not implemented here) 


	J Label (Unconditional jump to label) 
	


## Addressing Modes: 
(Memory is word (32 bits) addressable
### 1. Register addressing 
	ADD R1, R2, R3  //R1 = R2 + R3
### 2. Immediate addressing 
	ADDI R1, R2, 200 //R1 = R2 + 200
### 3. Base addressing 
	LW R5, #offset(R1) // R5 = Mem[R1+#offset] 
### 4. PC Relative addressing 
	BEQZ R3, Label (16 bit offset is added to PC to get the target address) 
### 5. Pseudo-direct addressing 
	J Label (16 bit offset is added to PC to get the target address) 

## MIPS32 Instruction Cycle 
We divide the instruction execution cycle into five steps: 

### 1. IF -> Instruction Fetch 

Here the instruction pointed to by the PC is fetched from memory, and also the next value of PC is computed. 
For a branch instruction, new value of the PC may be the target address.So PC is not updated in this stage; new value is stored in a register NPC. 

Gist:   IR <- Mem[PC]  (IR - Instruction Register)
	NPC <- PC + 1 

### 2. ID -> Instruction Decode/ Register Fetch 

The instruction already fetched in IR is decoded. 
- 'opcode' is 6 bits ( 31:26) 
- 'rs' (first source register - 25:21) and         'rt' (second source register - 20:16) 
- 16 bit immediate data (15:0) 
- 26 bit immedaite data (25:0) 

Decoding is done in parallel with reading the register operands 'rs' and 'rt'. This is possible because these fields are in a fixed location in the instruction format. In a similar way, the immediate data are sign-extended. 

	Gist:  A <- Reg[rs] 
   	 	 B <- Reg[rt] 
    	 	 Imm <- { 16{IR[15]}, IR[15:0] } 
	
A, B, Imm are temporary registers 



### 3. EX -> Execution/ Effective Address Calculation 

Here, the ALU is used to perform some calculation. The operation to be operated is already been decoded, and the ALU operates on the operands previously made ready ( A, B and Imm). 

	Gist:   ALUOut <- A func B      // for register-register ALU operations

		  ALUOut <- A func Imm    //for register-immediate type ALU operations 

	          ALUOut <- A + Imm       // for load type LW R3, 100(R8) 

	          ALUOut <- NPC + Imm     // for branching instruction. We add the offset regardless the result 
	          cond <- (A==0)       //If this is satisfied, then it the PC would shift to the branched location

 
### 4. MEM-> Memory Access/ Branch Completion 

This step is used by load, store and branch instructions. 
The load and store instructions access the memory. 
The branch instruction updates PC depending upon the outcome of the branch condition. 
	
	Gist:  PC <- NPC                //Load instruction 
      		 LMD <- Mem[ALUOut]       //LMD - Load Memory Data (temporary register) 
	
       		PC <- NPC 			
    	        Mem[ALUOut] <- B 	//B, which is the target, is a temporary register which contains data to be stored
 
    		   if(cond) 		//Branch condition  
			PC <- ALUOut 
		  else
			PC <- NPC 

		PC <- NPC  //for all other instructions 

### 5. WE -> Register Write-back 

In this step, the result is written back into the register file. 
--Result may come from ALU. 
--Result may come from the memory system (via a LOAD instruction) 
The position of the destination register in the instruction word depends on the instruction type (although it is already known after decoding)  
R -type -> 'rd' [15:11] 
I -type -> 'rt' [20:16] 

	Gist:   Reg[rd] <- ALUOut      //Register-Register ALU instruction 
	
		   Reg[rt] <- ALUOut      //Register-Immediate ALU instruction 
	
		   Reg[rt] <- LMD 	       //Load instruction 




Some instructions require two register operands 'rs' and 'rt' as input, 
while some require only 'rs'. This is only known after the instruction is decoded. 
While decoding is going on, we can prefetch the registers in parallel (May or may not be required later). 
In short, assume by default that the instruction is "R-type" 
