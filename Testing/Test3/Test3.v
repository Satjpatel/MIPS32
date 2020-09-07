module Test3 ; 

reg clk1, clk2 ; 
integer k ; 

mips_testing3 MIPS32 (clk1, clk2 ) ; 

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
			mips_testing3.Regbank[k] = k ; 

	//ADDI R10, R0, 200 
	mips_testing3.Mem[0] = 32
