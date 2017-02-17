module randomnumb();

integer i;
reg [31:0] mem [63:0];
integer file1;
reg a[0:31];

initial
begin				
		file1 = $fopen("input1.out");

		for (i = 0; i<64; i= i+1)
			begin
			mem [i] = $random;
			$fdisplay(file1, "%h", mem[i]);
			end

		$fclose (file1);
		
		
	
	end


endmodule

