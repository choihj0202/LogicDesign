// blocking
module block(  q, 
	       d, 
	       clk);

output 	    q 	   ; 

input	    d      ; 
input	    clk    ;

reg	    q	   ;
reg	    n1	   ;

always @(posedge clk) begin
	n1 = d;
	q = n1;
end

endmodule

// nonblocking
module nonblock(  q, 
	          d, 
	          clk);

output 	    q 	      ; 

input	    d         ; 
input	    clk       ;

reg	    q	      ;
reg	    n1	      ;

always @(posedge clk) begin
	n1 <= d;
	q  <= n1;
end

endmodule
