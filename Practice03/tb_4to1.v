module	tb_mux4to1	;

// instances
reg	    in0		;
reg	    in1		;
reg	    in2		;
reg	    in3		;
reg  [1:0]  sel		;

wire	  out1		;

wire	  out2		;

wire	  out3		;

mux4to1	       dut_1(	.out	( out1	),
			.in0	( in0	),
			.in1	( in1	),
			.in2	( in2	),
			.in3	( in3	),
			.sel	( sel	));

mux4to1_if     dut_2(	.out	( out2	),
			.in0	( in0	),
			.in1	( in1	),
			.in2	( in2	),
			.in3	( in3	),
			.sel	( sel	));

mux4to1_case   dut_3(	.out	( out3	),
			.in0	( in0	),
			.in1	( in1	),
			.in2	( in2	),
			.in3	( in3	),
			.sel	( sel	));

// stimulus
initial begin
	$display("Using 'mux4to1' : out1");
	$display("Using 'if' : out2");
	$display("Using 'case' : out3");
	$display("================================================================================");
	$display("	sel1	sel0	in3	in2	in1	in0	out1	out2	out3");
	$display("================================================================================");
	#(50)	{sel[1], sel[0], in3, in2, in1, in0} = 6'b_000110;	#(50)	$display("	%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", sel[1], sel[0], in3, in2, in1, in0, out1, out2, out3);
	#(50)	{sel[1], sel[0], in3, in2, in1, in0} = 6'b_001100;	#(50)	$display("	%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", sel[1], sel[0], in3, in2, in1, in0, out1, out2, out3);
	#(50)	{sel[1], sel[0], in3, in2, in1, in0} = 6'b_010111;	#(50)	$display("	%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", sel[1], sel[0], in3, in2, in1, in0, out1, out2, out3);
	#(50)	{sel[1], sel[0], in3, in2, in1, in0} = 6'b_010010;	#(50)	$display("	%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", sel[1], sel[0], in3, in2, in1, in0, out1, out2, out3);
	#(50)	{sel[1], sel[0], in3, in2, in1, in0} = 6'b_100100;	#(50)	$display("	%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", sel[1], sel[0], in3, in2, in1, in0, out1, out2, out3);
	#(50)	{sel[1], sel[0], in3, in2, in1, in0} = 6'b_101000;	#(50)	$display("	%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", sel[1], sel[0], in3, in2, in1, in0, out1, out2, out3);
	#(50)	{sel[1], sel[0], in3, in2, in1, in0} = 6'b_110011;	#(50)	$display("	%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", sel[1], sel[0], in3, in2, in1, in0, out1, out2, out3);
	#(50)	{sel[1], sel[0], in3, in2, in1, in0} = 6'b_111111;	#(50)	$display("	%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", sel[1], sel[0], in3, in2, in1, in0, out1, out2, out3);
	#(50)	$finish				     ;
end

endmodule
