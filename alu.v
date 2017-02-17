module alu ( input [31:0]a,
		input [31:0]b,
		input clk,
		input reset,
		output reg[31:0]c,
		output reg overflow
		);

wire [8:0] a1,b1;
wire a_sign,b_sign;
reg [8:0] a2,b2;
reg a2_sign,a3_sign,b2_sign,b3_sign,a4_sign,a5_sign,b4_sign,b5_sign;
reg [8:0]c_expo10,c_expo11,c_expo20;

wire[22:0]atemp;
wire[22:0]btemp;
wire[23:0]atemp1;
wire[23:0]btemp1;

assign atemp = a[22:0];
assign btemp = b[22:0];

assign btemp1={1'b1,btemp};

assign atemp1={1'b1,atemp};

assign a1 = {1'b0,a[30:23]};
assign b1 = {1'b0,b[30:23]};			//original exponent
assign a_sign = a[31];				//sign bit
assign b_sign = b[31]; 

reg[47:0] ctemp24,ctemp25;

reg [24:0]ctemp27,ctemp29;

always@(posedge clk,negedge reset)
begin
	if (!reset)
	begin
			 
 		   c <= 32'b0;

	    overflow <= 1'b0;
		
	     ctemp24 <= 48'b0;
	     ctemp25 <= 48'b0;    
	     ctemp27 <= 25'b0;
	     ctemp29 <= 25'b0;

	    c_expo11 <= 9'b0; 
	    c_expo10 <= 9'b0; 
	    c_expo20 <= 9'b0; 

	    	  a2 <= 9'b0; 		
	    	  b2 <= 9'b0;

	     a2_sign <= 1'b0;
	     a3_sign <= 1'b0;
	     a4_sign <= 1'b0;
	     a5_sign <= 1'b0;

	     b2_sign <= 1'b0;
	     b3_sign <= 1'b0;
	     b4_sign <= 1'b0;
	     b5_sign <= 1'b0;
			
	end
	
	else
	begin
		if(atemp1==24'h800000 || btemp1==24'h80000)
			ctemp24 <= 48'h400000000000;
		else		
			ctemp24 <= atemp1* btemp1;

		/*------------------ Normalization ------------------------------------------*/

		if(ctemp24[47]==0)

			begin
  				ctemp25<=ctemp24;

				if (a2==9'b000000000  || b2 ==9'b000000000)
				 c_expo10 <= 9'b000000000;

				else if(a2== 9'b011111111 || b2== 9'b011111111)
				 c_expo10 <= 9'b011111111;

				else
				 c_expo10 <= (a2+b2)-9'b001111111; 

			end
		else 

		   begin
			        ctemp25<={1'b0,ctemp24[47:1]};

				if (a2 == 9'b000000000 || b2 == 9'b000000000)
				 c_expo10 <= 9'b000000000;

				else if (a2 == 9'b011111111 || b2== 9'b011111111)
				 c_expo10 <= 9'b011111111;

				else		   
				 c_expo10 <= ((a2+b2)-9'b001111111) +1;    

		   end
		/*--------------End Of Normalization--------------------------------------*/   

		c_expo11 <= c_expo10; 


		/*------------- Rounding ------------------------------------------------*/	

		if(ctemp25[22]==1)

			ctemp27 <= ctemp25[47:23] + 1'b1;		
		else
			ctemp27 <= ctemp25[47:23];

 
		/*------------End Of Rounding -------------------------------------------*/   
		 

		/*------------Re - Normalization ----------------------------------------*/
		
		if(ctemp27[24]==0)

			begin
				 ctemp29 <= ctemp27;

				if (c_expo11 == 9'b011111111)
				 c_expo20 <= 9'b011111111;

				else if (c_expo11 == 9'b000000000)
				 c_expo20 <= 9'b000000000;

				else
				 c_expo20 <= c_expo11;

			end
		else
		  
			 begin
			    ctemp29 <= {1'b0,ctemp27[24:1]};

			    if (c_expo11 == 9'b011111111)
				c_expo20 <= 9'b011111111;

			    else if (c_expo11 == 9'b000000000)
				 c_expo20 <= 9'b000000000;
			    else				
			   	c_expo20 <= c_expo11 + 1;
    
			   end
		/*----------------End Of Re - Normalization-------------------------------*/   
		
			
		/*--------------End Of Overflow Condition --------------------------------*/

		a2 <= a1;
	

		b2 <= b1;
	

		a2_sign <= a_sign;
		a3_sign <= a2_sign;
		a4_sign <= a3_sign;
		a5_sign <= a4_sign;

		b2_sign <= b_sign;
		b3_sign <= b2_sign;
		b4_sign <= b3_sign;
		b5_sign <= b4_sign;

		/*------------ final output ------------------------------------------------*/
		
		if((c_expo20[7:0]==8'b11111111)||(c_expo20[8]==1'b1)||(c_expo20[7:0]==8'b00000000))
		begin
			overflow<=1; 
			c <= 32'hFFFFFFFF;
		end
		else 
		begin
		 overflow<=0;
		   c[31] <= a5_sign^b5_sign;
		c[30:23] <= c_expo20[7:0];
		 c[22:0] <= ctemp29[22:0];
		end



	end	

end

endmodule
