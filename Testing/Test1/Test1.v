//Adding three numbers 10, 20 and 30 stored in processor registers 

//Steps: 
//1. Initilize register R1 with 10
//2. Initilize register R2 with 20
//3. Initilize register R3 with 30 
//4. Add the three numbers and store the sum in R4 and R5


module Test1 ; 

reg clk1, clk2 ; 

integer k ; 

MIPS32 mips_testing1 ( clk1, clk2 ) ; 

//Generating 2 phase clocks 
initial 
	begin 
		clk1 = 0 ; 
		clk2 = 0 ; 
		
		repeat(80) //The program would be over by this
			begin 
				#5 clk1 = 1 ; 
				#5 clk1 = 0 ; 
				#5 clk2 = 1 ; 
				#5 clk2 = 0 ; 
			end 
	end 
	


//Programming the instructions inside the memory 
initial 

	begin 
		for(k=0; k<31; k++) 
			mips_testing1.RegBank[k] = k ; 
		
		//ADDI R1, R0, 10	
		mips_testing1.Mem[0] = 32'h2801000a ; 
		
		//ADDI R2 R0, 20 
		mips_testing1.Mem[1] = 32'h28020014 ; 
		
		//ADDI R3, R0, 25 
		mips_testing1.Mem[2] = 32'h28030019 ; 
		
		//Now we have to add 2 dummy instructions 
		//to wait for R2 to be updated too.
		
		//Dummy instruction -- OR R7, R7, R7 
		mips_testing1.Mem[3] = 32'h0ce77800 ; 
		
		//Dummy instruction -- OR R7, R7, R7 
		mips_testing1.Mem[4] = 32'h0ce77800 ; 
		
		//ADD R4, R1, R2
		mips_testing1.Mem[5] = 32'h00222000 ; 
		
		
		//This dummy instruction is for waiting
		//for correct data in R3
		//Dummy instruction -- OR R7, R7, R7 
		mips_testing1.Mem[6] = 32'h0ce77800 ; 
		
		//ADD R5, R4, R3 
		mips_testing1.Mem[7] = 32'h00832800 ;
		
		//HLT 
		mips_testing1.Mem[8] = 32'hfc000000 ; 
	
		//Initializing the working variables
		mips_testing1.HALTED = 0 ; 
		mips_testing1.PC = 0 ; 
		mips_testing1.TAKEN_BRANCH = 0 ; 
		
	end 
	
	initial 
		begin 
		
			$dumpfile ("mipstesting1.vcd") ; 
			$dumpvars (0, mips_testing1) ; 
				
				#400 $finish ; 
		end 
		
	initial 
		begin 
		
		#280 
		for( k = 0 ; k < 6 ; k++ ) 
			$display ("R%1d -- %2d", k, mips_testing1.RegBank[k]) ; 
		
		end
		
endmodule 


		
	
	
	
