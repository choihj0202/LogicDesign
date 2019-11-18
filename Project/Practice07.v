//	==================================================
//	Copyright (c) 2019 Sookmyung Women's University.
//	--------------------------------------------------
//	FILE 			: practice07.v
//	DEPARTMENT		: EE
//	AUTHOR			: WOONG CHOI
//	EMAIL			: woongchoi@sookmyung.ac.kr
//	--------------------------------------------------
//	RELEASE HISTORY
//	--------------------------------------------------
//	VERSION			DATE
//	0.0			2019-11-09
//	--------------------------------------------------
//	PURPOSE			: Digital Clock
//	==================================================

//	--------------------------------------------------
//	Numerical Controlled Oscillator
//	Hz of o_gen_clk = Clock Hz / num
//	--------------------------------------------------
module	nco(	
		o_gen_clk,
		i_nco_num,
		clk,
		rst_n);

output		o_gen_clk	;	// 1Hz CLK

input	[31:0]	i_nco_num	;
input		clk		;	// 50Mhz CLK
input		rst_n		;

reg	[31:0]	cnt		;
reg		o_gen_clk	;

always @(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		cnt		<= 32'd0;
		o_gen_clk	<= 1'd0	;
	end else begin
		if(cnt >= i_nco_num/2-1) begin
			cnt 	<= 32'd0;
			o_gen_clk	<= ~o_gen_clk;
		end else begin
			cnt <= cnt + 1'b1;
		end
	end
end

endmodule

//	--------------------------------------------------
//	Flexible Numerical Display Decoder
//	--------------------------------------------------
module	fnd_dec(
		o_seg,
		i_num);

output	[6:0]	o_seg		;	// {o_seg_a, o_seg_b, ... , o_seg_g}

input	[3:0]	i_num		;
reg	[6:0]	o_seg		;
//making
always @(i_num) begin 
 	case(i_num) 
 		4'd0 : o_seg = 7'b111_1110	; 
 		4'd1 : o_seg = 7'b011_0000	; 
 		4'd2 : o_seg = 7'b110_1101	; 
 		4'd3 : o_seg = 7'b111_1001	; 
 		4'd4 : o_seg = 7'b011_0011	; 
 		4'd5 : o_seg = 7'b101_1011	; 
 		4'd6 : o_seg = 7'b101_1111	; 
 		4'd7 : o_seg = 7'b111_0000	; 
 		4'd8 : o_seg = 7'b111_1111	; 
 		4'd9 : o_seg = 7'b111_0011	; 
		default : o_seg = 7'b000_0000	; 
	endcase 
end


endmodule

//	--------------------------------------------------
//	0~59 --> 2 Separated Segments
//	--------------------------------------------------
module	double_fig_sep(
		o_left,
		o_right,
		i_double_fig);

output	[3:0]	o_left		;
output	[3:0]	o_right		;

input	[5:0]	i_double_fig	;

assign		o_left	= i_double_fig / 10	;
assign		o_right	= i_double_fig % 10	;

endmodule

//	--------------------------------------------------
//	0~59 --> 2 Separated Segments
//	--------------------------------------------------
module	led_disp(
		o_seg,
		o_seg_dp,
		o_seg_enb,
		i_six_digit_seg,
		i_six_dp,
		clk,
		rst_n);

output	[5:0]	o_seg_enb		;
output		o_seg_dp		;
output	[6:0]	o_seg			;

input	[41:0]	i_six_digit_seg		;
input	[5:0]	i_six_dp		;
input		clk			;
input		rst_n			;

wire		gen_clk			;

nco		u_nco(
		.o_gen_clk	( gen_clk	),
		.i_nco_num	( 32'd5000	),
		.clk		( clk		),
		.rst_n		( rst_n		));


reg	[3:0]	cnt_common_node	;

always @(posedge gen_clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		cnt_common_node <= 4'd0;
	end else begin
		if(cnt_common_node >= 4'd5) begin
			cnt_common_node <= 4'd0;
		end else begin
			cnt_common_node <= cnt_common_node + 1'b1;
		end
	end
end

reg	[5:0]	o_seg_enb		;

always @(cnt_common_node) begin
	case (cnt_common_node)
		4'd0 : o_seg_enb = 6'b111110;
		4'd1 : o_seg_enb = 6'b111101;
		4'd2 : o_seg_enb = 6'b111011;
		4'd3 : o_seg_enb = 6'b110111;
		4'd4 : o_seg_enb = 6'b101111;
		4'd5 : o_seg_enb = 6'b011111;
	endcase
end

reg		o_seg_dp		;

always @(cnt_common_node) begin
	case (cnt_common_node)
		4'd0 : o_seg_dp = i_six_dp[0];
		4'd1 : o_seg_dp = i_six_dp[1];
		4'd2 : o_seg_dp = i_six_dp[2];
		4'd3 : o_seg_dp = i_six_dp[3];
		4'd4 : o_seg_dp = i_six_dp[4];
		4'd5 : o_seg_dp = i_six_dp[5];
	endcase
end

reg	[6:0]	o_seg			;

always @(cnt_common_node) begin
	case (cnt_common_node)
		4'd0 : o_seg = i_six_digit_seg[6:0];
		4'd1 : o_seg = i_six_digit_seg[13:7];
		4'd2 : o_seg = i_six_digit_seg[20:14];
		4'd3 : o_seg = i_six_digit_seg[27:21];
		4'd4 : o_seg = i_six_digit_seg[34:28];
		4'd5 : o_seg = i_six_digit_seg[41:35];
	endcase
end

endmodule

//	--------------------------------------------------
//	HMS(Hour:Min:Sec) Counter
//	--------------------------------------------------
module	hms_cnt(
		o_hms_cnt,
		o_max_hit,
		i_max_cnt,
		clk,
		rst_n);

output	[5:0]	o_hms_cnt		;
output		o_max_hit		;

input	[5:0]	i_max_cnt		;
input		clk			;
input		rst_n			;

reg	[5:0]	o_hms_cnt		;
reg		o_max_hit		;
always @(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_hms_cnt <= 6'd0;
		o_max_hit <= 1'b0;
	end else begin
		if(o_hms_cnt >= i_max_cnt) begin
			o_hms_cnt <= 6'd0;
			o_max_hit <= 1'b1;
		end else begin
			o_hms_cnt <= o_hms_cnt + 1'b1;
			o_max_hit <= 1'b0;
		end
	end
end

endmodule

module  debounce(
		o_sw,
		i_sw,
		clk);
output		o_sw			;

input		i_sw			;
input		clk			;

reg		dly1_sw			;
always @(posedge clk) begin
	dly1_sw <= i_sw;
end

reg		dly2_sw			;
always @(posedge clk) begin
	dly2_sw <= dly1_sw;
end

assign		o_sw = dly1_sw | ~dly2_sw;

endmodule

//	--------------------------------------------------
//	Clock Controller
//	--------------------------------------------------
module	controller(
		o_mode,
		o_position,
		o_sec_clk,
		o_min_clk,
		o_hour_clk,
		i_max_hit_sec,
		i_max_hit_min,
		i_max_hit_hour,
		i_sw0,
		i_sw1,
		i_sw2,
		clk,
		rst_n);

output		o_mode			;
output  [1:0]	o_position		;
output		o_sec_clk		;
output		o_min_clk		;
output		o_hour_clk		;

input		i_max_hit_sec		;
input		i_max_hit_min		;
input		i_max_hit_hour  	;

input		i_sw0			;
input		i_sw1			;
input		i_sw2			;

input		clk			;
input		rst_n			;

parameter	MODE_CLOCK = 1'b0	;
parameter	MODE_SETUP = 1'b1	;

parameter	POS_SEC	= 2'b00		;
parameter	POS_MIN	= 2'b01		;
parameter	POS_HOUR = 2'b10	;

wire		clk_100hz		;
nco		u0_nco(
		.o_gen_clk	( clk_100hz	),
		.i_nco_num	( 32'd500000	),
		.clk		( clk		),
		.rst_n		( rst_n		));

wire		sw0			;
debounce	u0_debounce(
		.o_sw		( sw0		),
		.i_sw		( i_sw0		),
		.clk		( clk_100hz	));

wire		sw1			;
debounce	u1_debounce(
		.o_sw		( sw1		),
		.i_sw		( i_sw1		),
		.clk		( clk_100hz	));

wire		sw2			;
debounce	u2_debounce(
		.o_sw		( sw2		),
		.i_sw		( i_sw2		),
		.clk		( clk_100hz	));

reg		o_mode			;
always @(posedge sw0 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_mode <= MODE_CLOCK;
	end else begin
		o_mode <= o_mode + 1'b1;
	end
end

reg	[1:0]	o_position		;
always @(posedge sw1 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_position <= POS_SEC;
	end else begin
		o_position <= o_position + 2'b01;
	end
end

wire		clk_1hz			;
nco		u1_nco(
		.o_gen_clk	( clk_1hz	),
		.i_nco_num	( 32'd50000000	),
		.clk		( clk		),
		.rst_n		( rst_n		));

reg		o_sec_clk		;
reg		o_min_clk		;
reg		o_hour_clk		;
always @(*) begin
	case(o_mode)
		MODE_CLOCK : begin
			o_sec_clk = clk_1hz;
			o_min_clk = i_max_hit_sec;
			o_hour_clk = i_max_hit_min;
		end
		MODE_SETUP : begin
			case(o_position)
				POS_SEC : begin
					o_sec_clk = ~sw2 ;
					o_min_clk = 1'b0 ;
					o_hour_clk = 1'b0;

				end
				POS_MIN : begin
					o_sec_clk = 1'b0 ;
					o_min_clk = ~sw2 ;
					o_hour_clk = 1'b0;
				end
				POS_HOUR : begin
					o_sec_clk = 1'b0 ;
					o_min_clk = 1'b0 ;
					o_hour_clk = ~sw2;
				end
			endcase
		end
	endcase
end

endmodule

//	--------------------------------------------------
//	HMS(Hour:Min:Sec) Counter
//	--------------------------------------------------
module	hourminsec(	o_sec,
			o_min,
			o_hour,
			o_max_hit_sec,
			o_max_hit_min,
			o_max_hit_hour,
			i_sec_clk,
			i_min_clk,
			i_hour_clk,
			clk,
			rst_n);

output	[5:0]	o_sec		;
output	[5:0]	o_min		;
output	[5:0]	o_hour		;
output		o_max_hit_sec	;
output		o_max_hit_min	;
output		o_max_hit_hour	;

input		i_sec_clk	;
input		i_min_clk	;
input		i_hour_clk	;

input		clk		;
input		rst_n		;

hms_cnt		u0_hms_cnt(
		.o_hms_cnt	( o_sec		 ),
		.o_max_hit	( o_max_hit_sec	 ),
		.i_max_cnt	( 6'd59		 ),
		.clk		( i_sec_clk	 ),
		.rst_n		( rst_n		 ));

hms_cnt		u1_hms_cnt(
		.o_hms_cnt	( o_min		 ),
		.o_max_hit	( o_max_hit_min	 ),
		.i_max_cnt	( 6'd59		 ),
		.clk		( i_min_clk	 ),
		.rst_n		( rst_n		 ));

hms_cnt		u2_hms_cnt(
		.o_hms_cnt	( o_hour	 ),
		.o_max_hit	( o_max_hit_hour ),
		.i_max_cnt	( 6'd23		 ),
		.clk		( i_hour_clk	 ),
		.rst_n		( rst_n		 ));

endmodule

module	top_hms_clock(
		o_seg_enb,
		o_seg_dp,
		o_seg,
		i_sw0,
		i_sw1,
		i_sw2,
		clk,
		rst_n);

output	[5:0]	o_seg_enb	    ;
output		o_seg_dp	    ;
output	[6:0]	o_seg		    ;

input		i_sw0		    ;
input		i_sw1		    ;
input		i_sw2		    ;
input		clk		    ;
input		rst_n		    ;

wire		o_sec_clk_w	    ;
wire		o_min_clk_w	    ;
wire		o_hour_clk_w	    ;
wire		o_max_hit_sec_w	    ;
wire		o_max_hit_min_w	    ;
wire		o_max_hit_hour_w    ;
wire	[5:0]   i_double_fig_sec_w  ;
wire	[5:0]   i_double_fig_min_w  ;
wire	[5:0]   i_double_fig_hour_w ;
wire	[3:0]   i_num_sec_1_w	    ;
wire	[3:0]   i_num_sec_2_w	    ;
wire	[3:0]   i_num_min_1_w	    ;
wire	[3:0]   i_num_min_2_w	    ;
wire	[3:0]   i_num_hour_1_w	    ;
wire	[3:0]   i_num_hour_2_w	    ;
wire	[6:0]	o_seg_sec_1_w	    ;
wire	[6:0]	o_seg_sec_2_w	    ;
wire	[6:0]	o_seg_min_1_w	    ;
wire	[6:0]	o_seg_min_2_w	    ;
wire	[6:0]	o_seg_hour_1_w	    ;
wire	[6:0]	o_seg_hour_2_w	    ;
wire	[41:0]	i_six_digit_seg_w   ;
assign          i_six_digit_seg_w = { {2{7'b0000000}}, o_seg_hour_1_w, o_seg_hour_2_w, o_seg_min_1_w, o_seg_min_2_w, o_seg_sec_1_w, o_seg_sec_2_w } ;


controller		u_ctrl( .o_mode	          (			   ),
				.o_position 	  (			   ),
				.o_sec_clk   	  ( o_sec_clk_w 	   ),
				.o_min_clk	  ( o_min_clk_w 	   ),
				.o_hour_clk	  ( o_hour_clk_w 	   ),
				.i_max_hit_sec    ( o_max_hit_sec_w	   ),
				.i_max_hit_min    ( o_max_hit_min_w	   ),
				.i_max_hit_hour   ( o_max_hit_hour_w	   ),
				.i_sw0	     	  ( i_sw0		   ),
				.i_sw1	     	  ( i_sw1		   ),
				.i_sw2	     	  ( i_sw2		   ),
				.clk	          ( clk	 		   ),
				.rst_n	     	  ( rst_n		   ));    	   

hourminsec	  u_hourminsec( .o_sec	     	  ( i_double_fig_sec_w	   ),
				.o_min	          ( i_double_fig_min_w	   ),
				.o_hour	          ( i_double_fig_hour_w	   ),
				.o_max_hit_sec    ( o_max_hit_sec_w	   ),
				.o_max_hit_min    ( o_max_hit_min_w	   ),
				.o_max_hit_hour   ( o_max_hit_hour_w	   ),
				.i_sec_clk	  ( o_sec_clk_w	  	   ),
				.i_min_clk	  ( o_min_clk_w	  	   ),
				.i_hour_clk	  ( o_hour_clk_w	   ),
				.clk	     	  ( clk			   ),
				.rst_n	     	  ( rst_n		   ));

double_fig_sep	    	u0_dfs( .o_left	     	  ( i_num_sec_1_w  	   ),
				.o_right	  ( i_num_sec_2_w	   ),
				.i_double_fig     ( i_double_fig_sec_w	   ));

double_fig_sep	        u1_dfs( .o_left	     	  ( i_num_min_1_w 	   ),
				.o_right	  ( i_num_min_2_w	   ),
				.i_double_fig     ( i_double_fig_min_w	   ));

double_fig_sep	        u2_dfs( .o_left	     	  ( i_num_hour_1_w 	   ),
				.o_right	  ( i_num_hour_2_w	   ),
				.i_double_fig     ( i_double_fig_hour_w	   ));

fnd_dec		    u0_fnd_dec( .o_seg	     	  ( o_seg_sec_1_w      	   ),
				.i_num	    	  ( i_num_sec_1_w 	   ));

fnd_dec		    u1_fnd_dec( .o_seg	     	  ( o_seg_sec_2_w      	   ),
				.i_num	    	  ( i_num_sec_2_w 	   ));

fnd_dec		    u2_fnd_dec( .o_seg	     	  ( o_seg_min_1_w      	   ),
				.i_num	    	  ( i_num_min_1_w 	   ));

fnd_dec		    u3_fnd_dec( .o_seg	     	  ( o_seg_min_2_w      	   ),
				.i_num	    	  ( i_num_min_2_w 	   ));

fnd_dec		    u4_fnd_dec( .o_seg	     	  ( o_seg_hour_1_w         ),
				.i_num	    	  ( i_num_hour_1_w 	   ));

fnd_dec		    u5_fnd_dec( .o_seg	     	  ( o_seg_hour_2_w         ),
				.i_num	    	  ( i_num_hour_2_w 	   ));

led_disp	    u_led_disp( .o_seg		  ( o_seg		   ),
				.o_seg_dp	  ( o_seg_dp		   ),
				.o_seg_enb	  ( o_seg_enb		   ),
				.i_six_digit_seg  ( i_six_digit_seg_w	   ),
				.i_six_dp	  ( 6'h0		   ),
				.clk		  ( clk			   ),
				.rst_n		  ( rst_n		   ));


endmodule




