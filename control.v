module controlunit ( input [31:0]a,
		     input [31:0]b,
		     input [31:0]c,
		     input overflow,
		     input clk,
		     input reset,
		     input start,
		     output reg [31:0]a_out,
		     output reg [31:0]b_out,
		     output [31:0]c_out,
		     output overflow_out,
		     output we,
		     output we_ov
		    );

wire [31:0] a1,b1;

reg [2:0] count1,count2,count3;
reg [3:0] count4;
reg [31:0] ctemp;
reg wetemp,wetemp2,otemp;


assign a1 = a;
assign b1 = b;

always @ (posedge clk, negedge reset)
begin 

	if (!reset)
	    begin
		a_out <= 32'b0;
		b_out <= 32'b0;
	    end

	else
	    begin
		a_out <= a1;
		b_out <= b1;
	    end

end

always @ (posedge clk, negedge reset)
begin 

	if (!reset)
	    begin
		 ctemp <= 32'b0;
		wetemp <= 1'b0;

		count1 <= 3'b0;
		count2 <= 3'd7;
	    end

	else
	    begin
		if (start)			 // Start = 1 - Transfer Multiplied value
		    begin
			count2 <= 3'd7;
			if (count1<6)
			    begin
				count1 <= count1+1;
				

				 ctemp <= 32'b0;
			
				wetemp <= 1'b0;

			    end
			else
			    begin
				 ctemp <= c;
				
				wetemp <= 1'b1;

			    end

		    end

		else 				// Start  = 0 - Do not transfer Multiplied value after 5th clock cycle
		    begin
			count1 <= 3'b0;
			if (count2>0)
			    begin
				count2 <= count2-1;
			
				 ctemp <= c;
			
				wetemp <= 1'b1;

			    end
			else
			    begin
				 ctemp <= 32'b0;
				wetemp <= 1'b0;
				
			    end
		    end	
	    end

end


always @ (posedge clk, negedge reset)
begin 

	if (!reset)
	    begin
		wetemp2 <= 1'b0;
		 otemp <= 1'b0;

		count3 <= 3'b0;
		count4 <= 4'd8;
	    end

	else
	    begin
		if (start) 			// Start = 1 - Transfer Multiplied value
		    begin
			count4 <= 4'd8;
			if (count3<7)
			    begin
				count3 <= count3+1;

				 otemp <= 1'b0;
			       wetemp2 <= 1'b0;

			    end
			else
			    begin
				 otemp <= overflow;
			       wetemp2 <= 1'b1;

			    end

		    end

		else 				// Start  = 0 - Do not transfer Multiplied value after 5th clock cycle
		    begin
			count3 <= 3'b0;
			if (count4>0)
			    begin
				count4 <= count4-1;

				 otemp <= overflow;
			       wetemp2 <= 1'b1;

			    end
			else
			    begin
				 otemp <= 1'b0;
			       wetemp2 <= 1'b0;
			    end

		    end
			
	    end
end





assign c_out = ctemp;
assign overflow_out = otemp;
assign we = wetemp;
assign we_ov = wetemp2;




endmodule


