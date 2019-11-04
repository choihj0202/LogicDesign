module	tb_sequential;

reg	d		;
reg	clk		;
reg	rst_n		;

wire	q_latch		;
wire	q_dff_asyn	;
wire	q_dff_syn	;

initial	  	clk = 1'b0	;
always	#(100)  clk = ~clk	;

// instances
d_latch	 dut_0(	.q	( q_latch	),
		.d	( d		),
		.clk	( clk		),
		.rst_n	( rst_n		));

dff_asyn dut_1(	.q	( q_dff_asyn	),
		.d	( d		),
		.clk	( clk		),
		.rst_n	( rst_n		));

dff_syn	 dut_2(	.q	( q_dff_syn	),
		.d	( d		),
		.clk	( clk		),
		.rst_n	( rst_n		));

// stimulus
initial begin
	$display("=========================================================");
	$display("	rst_n	d	q_latch	q_dff_asyn	q_dff_syn");
	$display("=========================================================");
	#(0)	{rst_n, d} = 2'b_00;	#(50)	$display("	%b\t%b\t%b\t%b\t%b", rst_n, d, q_latch, q_dff_asyn, q_dff_syn);
	#(50)	{rst_n, d} = 2'b_00;	#(50)	$display("	%b\t%b\t%b\t%b\t%b", rst_n, d, q_latch, q_dff_asyn, q_dff_syn);
	#(50)	{rst_n, d} = 2'b_10;	#(50)	$display("	%b\t%b\t%b\t%b\t%b", rst_n, d, q_latch, q_dff_asyn, q_dff_syn);
	#(50)	{rst_n, d} = 2'b_10;	#(50)	$display("	%b\t%b\t%b\t%b\t%b", rst_n, d, q_latch, q_dff_asyn, q_dff_syn);
	#(50)	{rst_n, d} = 2'b_11;	#(50)	$display("	%b\t%b\t%b\t%b\t%b", rst_n, d, q_latch, q_dff_asyn, q_dff_syn);
	#(50)	{rst_n, d} = 2'b_11;	#(50)	$display("	%b\t%b\t%b\t%b\t%b", rst_n, d, q_latch, q_dff_asyn, q_dff_syn);
	#(50)	{rst_n, d} = 2'b_10;	#(50)	$display("	%b\t%b\t%b\t%b\t%b", rst_n, d, q_latch, q_dff_asyn, q_dff_syn);
	#(50)	{rst_n, d} = 2'b_11;	#(50)	$display("	%b\t%b\t%b\t%b\t%b", rst_n, d, q_latch, q_dff_asyn, q_dff_syn);

end

endmodule
