// Module setting
module	mux4to1( out,
		 in0,
		 in1,
		 in2,
		 in3,
		 sel);

output	    out		;
input	    in0		;
input	    in1		;
input	    in2		;
input	    in3		;
input [1:0] sel		;

wire  [1:0] o_mux	;

mux2to1_assign	mux_u0(	.out( 	o_mux[0] ),
			.in0( 	in0	 ),
			.in1( 	in1	 ),
			.sel( 	sel[0]   ));

mux2to1_assign	mux_u1(	.out( 	o_mux[1] ),
			.in0( 	in2	 ),
			.in1( 	in3	 ),
			.sel( 	sel[0]   ));

mux2to1_assign	mux_u2(	.out( 	out	 ),
			.in0( 	o_mux[0] ),
			.in1( 	o_mux[1] ),
			.sel( 	sel[1]   ));

endmodule


// Conditional Expression : if
module	mux4to1_if( out,
		    in0,
		    in1,
		    in2,
		    in3,
		    sel);

output	    out		;
input	    in0		;
input	    in1		;
input	    in2		;
input	    in3		;
input [1:0] sel		;

reg 	    out		;

always @(*) begin
	if(sel == 2'b00) begin
		out = in0	;
	end else if(sel == 2'b01) begin
		out = in1	;
	end else if(sel == 2'b10) begin
		out = in2	;
	end else begin
		out = in3	;
	end

end

endmodule


// Conditional Expression : case
module	mux4to1_case( out,
		      in0,
		      in1,
		      in2,
		      in3,
	   	      sel);

output	    out		;
input	    in0		;
input	    in1		;
input	    in2		;
input	    in3		;
input [1:0] sel		;

reg 	    out		;

always @(*) begin
	case( {sel} )
		2'b00 : {out} = in0;
		2'b01 : {out} = in1;
		2'b10 : {out} = in2;
		2'b11 : {out} = in3;
	endcase

end

endmodule
