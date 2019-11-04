// D Latch
module	d_latch(  q,
		  d,
   		  clk,
		  rst_n);

output		q	;

input		d	;
input		clk	;
input		rst_n	;

reg		q	;

always @(d or clk or rst_n) begin
       if (rst_n == 1'b0) begin
		q <= 1'b0	;

       end else begin
	     if (clk == 1'b1) begin
		    q <= d		;
	     end
       end
end

endmodule

	