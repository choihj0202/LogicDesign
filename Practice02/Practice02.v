// Description : Dataflow Style
module fa_dataflow(	s,
			co,
			a,
			b,
			ci	);

output		s	;	// sum
output		co	;	// carry out

input		a	;	// input a
input		b	;	// input b
input		ci	;	// carry in

assign		s	= ( ~a & ~b & ci) | ( ~a & b & ~ci) | ( a & b & ci) | ( a & ~b & ~ci);
assign		co	= ( a & b ) | ( b & ci ) | ( a & ci );


endmodule


// Description : Behavioral Style
module fa_behavior(	s,
			co,
			a,
			b,
			ci	);

output		s	;	// sum
output		co	;	// carry out

input		a	;	// input a
input		b	;	// input b
input		ci	;	// carry in

reg		s	;
reg		co	;

always @( a or b or ci ) begin
	s	= ( ~a & ~b & ci) | ( ~a & b & ~ci) | ( a & b & ci) | ( a & ~b & ~ci);
	co	= ( a & b ) | ( b & ci ) | ( a & ci );
end

endmodule


// Description : Case & concatenation
module fa_case(		s,
			co,
			a,
			b,
			ci	);

output		s	;	// sum
output		co	;	// carry out

input		a	;	// input a
input		b	;	// input b
input		ci	;	// carry in

reg		s	;
reg		co	;

always @( a or b or ci ) begin
	case( {ci, a, b} )
		3'b000 : {co, s} = 2'b00	;
		3'b001 : {co, s} = 2'b01	;
		3'b010 : {co, s} = 2'b10	;
		3'b011 : {co, s} = 2'b11	;
		3'b100 : {co, s} = 2'b00	;
		3'b101 : {co, s} = 2'b01	;
		3'b110 : {co, s} = 2'b10	;
		3'b111 : {co, s} = 2'b11	;
	endcase
	
end

endmodule 
