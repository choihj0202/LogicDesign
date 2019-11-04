`timescale 1ns/1ns

module tb_cnt		;

parameter tCK = 1000/50 ; // 50MHz Clock

reg        clk 		; 
reg        rst_n 	; 

wire [5:0] out 		;

initial clk = 1'b0	; 

always #(tCK/2) clk = ~clk	 ;

cnt6 dut(    .out    ( out ), 
	     .clk    ( clk ), 
             .rst_n  ( rst_n ))  ;

initial begin 
#(0*tCK)	rst_n = 1'b0	 ; 
#(1*tCK) 	rst_n = 1'b1	 ; 
#(100*tCK) 	$finish		 ; 
end

endmodule
