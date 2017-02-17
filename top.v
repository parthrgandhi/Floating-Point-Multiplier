`include "alu.v"
`include "memory.v"
`include "control.v"

module top( 	input clk,
		input reset,
		input start,

		output [31:0]a,		
		output [31:0]b,		
		output [31:0]c,
		output overflow,
		output done
		 );

wire [31:0]a1,a2,a3,a4,a5;
wire [31:0]b1,b2,b3,b4,b5;
wire [31:0]c1,c2,c3,c4;
wire o1,o2,o3,o4,o5;
wire d1,d2;
wire w1,w2,w3,w4;


memory_stack m1 (.clk (clk), .reset(reset), .start(start), .we(w2), .we_ov(w4), .c(c4), .overflow(o4), .a(a1), .b(b1), .done(d1));

controlunit x1 ( .a(a2),.b(b2),.c(c2),.overflow(o2),.clk(clk),.reset(reset),.start(start),.a_out(a3),.b_out(b3),.c_out(c3),.overflow_out (o3),.we(w1),.we_ov(w3));

alu  y1 (.a(a4), .b(b4), .clk (clk), .reset(reset), .c(c1), .overflow(o1));


assign a5 = a4;
assign b5 = b4;

assign a2 = a1;
assign b2 = b1;

assign a4 = a3;
assign b4 = b3;

assign c2 = c1;
assign c4 = c3;

assign o2 = o1;
assign o4 = o3;
assign o5 = o4;


assign w2 = w1;
assign w4 = w3;

assign d2 = d1;


assign a = a5;
assign b = b5;

assign c = c4;
assign overflow = o5;
assign done = d2;


endmodule


