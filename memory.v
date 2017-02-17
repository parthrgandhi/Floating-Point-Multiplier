module memory_stack (   input clk,		// System - clock
						  
			input reset, 		// System - reset

			input start, 		// signal to begin multiplication (read enable)
						
			input we, 		// signal to write back complied/final data			
						
			input we_ov, 		// signal to write back overflow into stack		

			input [31:0] c, 	// complied/final data

			input overflow, 	// final overflow
						
			output reg [31:0] a,	// multiplier
						
			output reg [31:0] b, 	// multiplicand

			output reg done 	// done signal
		   );


	reg [4:0] address1;
	reg [6:0] address2;
	reg [31:0] mem [95:0];

	reg [5:0] address3;
	reg  mem2 [31:0];


	integer i,file;
	
	always @ (posedge clk or negedge reset)
	
	begin
	
		if (!reset)
			begin
			  
				 a <= 32'b0;
				 b <= 32'b0;
			      done <= 1'b0;	



				 address1 <= 6'b0; 		// Read Address 0 - 63 for A & B
				 address2 <= 7'b0111111;	// Write Address 64 - 95 for C


				//synopsys translate_off
			
				 $readmemh("memory.txt", mem);			 

				 //$readmemh("memory2.txt", mem);	// Inputs covering corner cases			 
						 
				//synopsys translate_on

				/*synopsys translate_off*/
	 
				 for ( i=64;i<96;i=i+1)
				  begin
					mem [i] <=32'b0;
				  end

				/*synopsys translate_on*/

			end

		else if ((start ==1) &&(we==0))
			begin

				 a <= mem [ address1];
				 b <= mem [address1+6'd32];
				 address1 <= address1 + 1;				  
				  
			end
		
		else if ((start ==0) &&(we==1))
			begin
				 mem [ address2] <= c;
				 address2 <= address2 + 1;				  

				 if(address2 == 7'd95)
				   done <= 1'b1;
				 else
		                   done <= 1'b0;

			end	
			
		else if ((start ==1) &&(we==1))
			begin

				 a <= mem [ address1];
				 b <= mem [address1+6'b100000];
				 address1 <= address1 + 1;	

				 mem [ address2] <= c;
				 address2 <= address2 + 1;

				 if(address2 == 7'd95)
				   done <= 1'b1;
				 else
		                   done <= 1'b0;
			  
			end

		else 
			begin

				 a <=32'b0;
				 b <= 32'b0;
				 address1 <= address1;	

				 address2 <= address2;				 
				  
			end



	end


	always @ (posedge clk or negedge reset)
	
	begin
	
		if (!reset)
			begin

				 address3 <= 5'b0; 		// Read Address 0 - 31 for Overflow storage


				/*synopsys translate_off*/
	 
				 for ( i=0;i<32;i=i+1)
				  begin
					mem2 [i] <=32'b0;
				  end

				/*synopsys translate_on*/


			end

		else if (we_ov)

			begin
			  
			 mem2 [address3] <= overflow;
			 address3 <= address3 + 1;				  
			
			  
			end

		else
			begin
			  
			 address3 <= address3;				  
				  
			end


	end

/*	synopsys translate_off	*/
	always@(*)
	begin
		file = $fopen("final.txt");
			$fdisplay(file, "A \t * \t B  = \t C \tOverflow\n");

		for (i = 0; i<32; i= i+1)
		begin
			$fdisplay(file, "%h * %h = %h\t%b",mem[i], mem[i+32], mem[i+64] , mem2[i]);
		end

		$fclose (file);

		file = $fopen("c.txt");
	
		for (i = 0; i<32; i= i+1)
		begin
			$fdisplay(file, "%h", mem[i+64]);
		end

		$fclose (file);
		
		file = $fopen("o_actual.txt");
	
		for (i = 0; i<32; i= i+1)
		begin
			$fdisplay(file, "%b", mem2[i]);
		end

		$fclose (file);
		
	end
	/*synopsys translate_on*/

endmodule






