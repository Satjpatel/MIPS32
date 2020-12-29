module Test2 ;  

reg clk1 ; 
reg clk2 ; 
integer k ; 

MIPS32 mips_testing2 ( clk1, clk2 ) ; 

initial 
	begin 
	clk1 = 0 ; 
	clk2 = 0 ; 
	
		repeat(30) 
			begin 
				#5 clk1 = 1 ; 
				#5 clk1 = 0 ; 
				#5 clk2 = 1 ; 
				#5 clk2 = 0 ; 
			end 
	end 
	

initial 
	begin 
		for(k = 0 ; k < 31 ; k=k+1 ) 
			mips_testing2.RegBank[k] = k ; 
		
		//ADDI R1, R0, 120  
		mips_testing2.Mem[0] = 32'h28010078 ; 
		
		//Flow dependency - We are tackling this on the software level.   
		//(Detech and eliminate the dependency on the software level) -- No requirement of doing anything on the hardware level 
		
		
		
		//Dummy Instruction 
		//OR R3, R3, R3 
		mips_testing2.Mem[1] = 32'h0c631800 ; 
		
		//LW R2, 0(R1) 
		mips_testing2.Mem[2] = 32'h20220000 ; 
		
		//Dummy Instruction
		//OR R3, R3, R3 
		mips_testing2.Mem[3] = 32'h0c631800 ; 
		
		//ADDI R2, R2, 45 
		mips_testing2.Mem[4] = 32'h2842002d ; 
		
		//OR R3, R3, R3 
		mips_testing2.Mem[5] = 32'h0c631800 ; 
		
		//SW R2, 1(R1) 
		mips_testing2.Mem[6] = 32'h24220001 ; 
		
		//HLT 
		mips_testing2.Mem[7] = 32'hfc000000 ; 
		
		mips_testing2.Mem[120] = 85 ; 
		
		//Initializing 
		mips_testing2.PC = 0 ; 
		mips_testing2.HALTED = 0 ; 
		mips_testing2.TAKEN_BRANCH = 0 ; 
		
		#500 
		$display("Mem[120]: %4d \nMem[121]: %4d", mips_testing2.Mem[120], mips_testing2.Mem[121] ) ; 
	end 
	
initial 
	begin 
		$dumpfile ("mipstesting2.vcd") ; 
		$dumpvars (0, Test2 ) ; 
		#600 
		$finish ; 
	end 
	
endmodule 
	
	
		
		
		
