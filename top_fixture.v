`include "top.v"

module stimulus;

reg clk;
reg reset;
reg start;

wire [31:0]a;
wire [31:0]b;
wire done;
wire [31:0]c;

wire overflow;

reg overflowflag;

reg [31:0] a1,b1;
reg [31:0] c1,c2;
reg [47:0] temp_C1;
reg [47:0] temp_C2;
reg [24:0] temp_C3;
reg [24:0] temp_C4;

reg sign;

reg [8:0] temp_norm;
reg [8:0] temp_expo;
reg [8:0] temp_expo2;
reg [7:0] temp_expo3;


reg [31:0] mem [0:95];
reg [31:0] mem2 [0:31];
reg [31:0] mem3 [0:31];
reg [31:0] mem4 [0:31];
reg mem5 [0:31];
reg mem6 [0:31];
reg mem7 [0:31];

reg [6:0] read_add;
reg [6:0] over_add;
reg [7:0] write_add;

reg [6*5:0]r;
reg count;
integer i,file;


initial
	$vcdpluson;

top x1(clk,reset,start,a,b,c,overflow,done);


initial
begin
	$readmemh("memory.txt",mem);
	//$readmemh("memory2.txt",mem);		// Inputs covering corner cases
	

	$monitor("%t: reset =%b a=%h b=%h c = %h overflow = %b done = %b", $time,reset,a,b, c, overflow, done);

end


always@(posedge clk or negedge reset)

	if(!reset)
	begin
		c1<=0;
		c2<=0;

	overflowflag <=1'b0;

		a1 <= 32'b0;
		b1 <= 32'b0;
	   temp_C1 <= 48'b0;
	   temp_C2 <= 48'b0;
	   temp_C3 <= 25'b0;
	   temp_C4 <= 25'b0;

	  sign <= 1'b0;

	 temp_expo <= 9'b0;
	 temp_norm <= 9'b0;
	temp_expo2 <= 9'b0;
	temp_expo3 <= 9'b0;

	 read_add <= 6'd0; 
	   over_add <= 6'd0;
	write_add <= 7'd64;
	count<=0;
	
	end
	
	else
	begin
		a1 <= mem [read_add];
		b1 <= mem [read_add+6'd32];

		read_add <= read_add+1'b1;

		
	end

always @(a1 or b1)

begin		
	//------------------------------multiplying the fraction---------------------------
	
	temp_C1 = {1'b1,a1 [22:0]}*{1'b1,b1 [22:0]}; 
	
	sign=a1[31]^b1[31];

	if(a1[30:23]==8'b00000000 || b1[30:23] == 8'b00000000)
		begin
		
			temp_expo = 9'b0;
			
		end

	else if (a1[30:23] == 8'b1111_1111 || b1[30:23] == 8'b1111_1111)
		begin
			
			temp_expo = 9'b011111111;			
			
		end
	
	else
		begin
			
			
			temp_expo= {1'b0,a1 [30:23]} + {1'b0,b1 [30:23]} - 9'b001111111;
		end
	
	
	//----------------------------normalisation-----------------------------------
		
		if(temp_C1[47]==1)
			begin
	
				temp_C2= temp_C1>>1;

				if (temp_expo == 9'b000000000)
				 temp_norm = 9'b000000000;

				else if(temp_expo == 9'b011111111)
				 temp_norm = 9'b011111111;

				else
				 temp_norm = temp_expo + 1'b1; 

			
			end
	
		else
			begin
				temp_C2=temp_C1;

				if (temp_expo == 9'b000000000)
				 temp_norm = 9'b000000000;

				else if(temp_expo == 9'b011111111)
				 temp_norm = 9'b011111111;

				else
				  temp_norm = temp_expo;

			end

	//----------------------------------rounding--------------------------------
		
	
		if(temp_C2[22] == 1'b1)
			temp_C3[24:0] = temp_C2[47:23]+1'b1;

		else
			temp_C3[24:0] = temp_C2[47:23];
	


	// ---------------------------------Renormalization-----------------------------

		if(temp_C3[24]==1)
			begin
				temp_C4 = temp_C3>>1;

				if (temp_norm == 9'b000000000)
				 temp_expo2 = 9'b000000000;

				else if(temp_norm == 9'b011111111)
				 temp_expo2 = 9'b011111111;

				else
				temp_expo2 = temp_norm + 1'b1;

			end

		else
			begin
				temp_C4 = temp_C3;

				if (temp_norm == 9'b000000000)
				 temp_expo2 = 9'b000000000;

				else if(temp_norm == 9'b011111111)
				 temp_expo2 = 9'b011111111;

				else
				  temp_expo2 = temp_norm;

			end


	//--------------------------------------Final-----------------------------------------

		if((temp_expo2[7:0]==8'b11111111)||(temp_expo2[7:0]==8'b00000000)||(temp_expo2[8]==1'b1))
		begin
			overflowflag = 1'b1 ; 
			c1 = 32'hffffffff;
		end
		else 
		begin
			overflowflag = 1'b0;
			c1 = {sign,temp_expo2[7:0],temp_C4 [22:0]};		
		end

		
		if(count==0)
		count = count +1;
		else
		begin
		mem [write_add] = c1;
		write_add = write_add + 1;

		mem5 [over_add] = overflowflag;
		over_add = over_add + 1;
		end


	file=$fopen("c_expected.txt");

	for(i=0;i<32;i=i+1)
	begin
	$fdisplay(file,"%h",mem[i+64]);
	end
	$fclose(file);

	file=$fopen("o_expected.txt");

	for(i=0;i<32;i=i+1)
	begin
	$fdisplay(file,"%b",mem5[i]);
	end
	$fclose(file);
end


	
initial

begin
	   reset = 1'b0;start = 1'b1;
	#5 reset = 1'b1;
	
	#393
 	 $readmemh("c_expected.txt", mem3);
	 $readmemh("c.txt", mem4);
	$readmemb("o_actual.txt", mem6);
	$readmemb("o_expected.txt", mem7);
	
	$display("\n\n\t\t-------------------------------- COMPARE RESULTS------------------------------------\n");
	for(i=0;i<32;i=i+1)
	begin
	
		if(mem3[i] == mem4[i] && mem6[i] == mem7[i]) 		
						
			r = "PASS";
		else
			r = "FAIL";

	$display("\t\ta=%h * b=%h ||  c = %h  c_expected = %h || o = %b o_expected = %b || r =%s", mem[i],mem[i+32], mem4[i], mem3[i], mem6[i], mem7[i], r);
	
	end
	


end
	
initial
begin
		   clk = 1'b0;		//initialize the clk at time 0
	forever #5 clk = ~clk;		//toggle the clk every 10  times units
end

initial
	#400 $finish;

endmodule


