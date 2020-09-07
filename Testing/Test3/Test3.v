module Test3 ; 

reg clk1, clk2 ; 
integer k ; 

MIPS32 mips_testing3 (clk1, clk2 ) ; 

initial 
	begin 
		clk1 = 0 ; 
		clk2 = 0 ; 
		
		repeat(50) 
			begin 
				#5 clk1 = 1 ; 
				#5 clk1 = 0 ; 
				#5 clk2 = 1 ; 
				#5 clk2 = 0 ; 
			end 
	end 
	
initial 
	begin 
		for(k=0 ; k <31 ; k = k + 1 ) 
			mips_testing3.RegBank[k] = k ; 

	//ADDI R10, R0, 200 
	mips_testing3.Mem[0] = 32'h280a00c8 ; 
	
	//ADDI R2, R0,1 
	mips_testing3.Mem[1] = 32'h28020001 ; 
	
	//Dummy Instruction 
	//OR R20, R20, R20 
	mips_testing3.Mem[2] = 32'h0e94a000 ; 
	
	//LW R3, 0(R10) 
	mips_testing3.Mem[3] = 32'h21430000 ; 
	
	//Dummy Instruction 
	//OR R20, R20, R20 
	mips_testing3.Mem[4] = 32'h0e94a000 ; 
	
	//Loop: MUL R2, R2, R3 
	mips_testing3.Mem[5] = 32'h14431000 ; 
	
	//SUBI R3, R3, 1 
	mips_testing3.Mem[6] = 32'h2c630001 ; 
	
	//Dummy Instruction 
	//OR R20, R20, R20 
	mips_testing3.Mem[7] = 32'h0e94a000 ; 
	
	//BNEQZ R3, loop ( -4 offset) 
	mips_testing3.Mem[8] = 32'h3460fffc ; 
	
	//SW R2, -2(R10) 
	mips_testing3.Mem[9] = 32'h2542fffe ; 
	
	//HLT
	mips_testing3.Mem[10] = 32'hfc000000 ; 
	
	//Find factorial of 7 
	mips_testing3.Mem[200] = 32'h00000007 ; 
	
	//Initializing the parameters 
	mips_testing3.PC = 0 ; 
	mips_testing3.HALTED = 0 ; 
	mips_testing3.TAKEN_BRANCH = 0 ; 
	
	#2000 $display ("Mem[200] = %2d, Mem[198] = %6d", mips_testing3.Mem[200] , mips_testing3.Mem[198] ) ; 
	
	end 

initial 
	begin 
		$dumpfile ("mipstesting3.vcd") ; 
		$dumpvars (0, Test3) ; 
		$monitor ("R2: %4d", mips_testing3.RegBank[2] ) ; 
		#3000 $finish ; 
	end 
	
endmodule 


	
