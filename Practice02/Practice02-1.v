// Description : Hierarchical Design
module fa4_inst(	s,
			co,
			a,
			b,
			ci	);

output	[3:0]	s	;	// sum
output		co	;	// carry out

input	[3:0]	a	;	// input a
input	[3:0]	b	;	// input b
input		ci	;	// carry in

wire	[2:0]	carry	;	// ripple carry

fa	    fa_u0( .s	( s[0]		),
		   .co	( carry[0]	),
		   .a	( a[0]		),
		   .b	( b[0]		),
		   .ci	( ci		));

fa	    fa_u1( .s	( s[1]		),
		   .co	( carry[1]	),
		   .a	( a[1]		),
		   .b	( b[1]		),
		   .ci	( carry[0]		));

fa	    fa_u2( .s	( s[2]		),
		   .co	( carry[2]	),
		   .a	( a[2]		),
		   .b	( b[2]		),
		   .ci	( carry[1]	));

fa	    fa_u3( .s	( s[3]		),
		   .co	( co		),
		   .a	( a[3]		),
		   .b	( b[3]		),
		   .ci	( carry[2]	));

endmodule


//Description : Multi-bit Expression
module fa4_mbit(	s,
			co,
			a,
			b,
			ci	);

output	[3:0]	s	;	// sum
output		co	;	// carry out

input	[3:0]	a	;	// input a
input	[3:0]	b	;	// input b
input		ci	;	// carry in

assign		{co, s} = a + b + ci;

endmodule
