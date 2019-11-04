module tb_bnb	;

// instances
reg	d	;
reg	clk	;

wire	q1	;
wire	q2	;

block     dut_0(q1, d, clk)	   ;

nonblock  dut_1(q2, d, clk)	   ;


// simulation
always	 #(100)  clk = ~clk	   ;

initial begin
	  clk = 1'b0	  	   ;
	  d = 1'b0   	 	   ;		
#(100)    d = 1'b1     	           ;
#(900)    $finish       	   ;

end

endmodule
