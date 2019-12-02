//	==================================================
//	Copyright (c) 2019 Sookmyung Women's University.
//	--------------------------------------------------
//	FILE 			: dut.v
//	DEPARTMENT		: EE
//	AUTHOR			: WOONG CHOI
//	EMAIL			: woongchoi@sookmyung.ac.kr
//	--------------------------------------------------
//	RELEASE HISTORY
//	--------------------------------------------------
//	VERSION			DATE
//	0.0			2019-11-18
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
 		4'd0:	o_seg = 7'b111_1110; 
 		4'd1:	o_seg = 7'b011_0000; 
 		4'd2:	o_seg = 7'b110_1101; 
 		4'd3:	o_seg = 7'b111_1001; 
 		4'd4:	o_seg = 7'b011_0011; 
 		4'd5:	o_seg = 7'b101_1011; 
 		4'd6:	o_seg = 7'b101_1111; 
 		4'd7:	o_seg = 7'b111_0000; 
 		4'd8:	o_seg = 7'b111_1111; 
 		4'd9:	o_seg = 7'b111_0011; 
		default:o_seg = 7'b000_0000; 
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
//	LED Display
//	--------------------------------------------------
module	led_disp(
		o_seg,
		o_seg_dp,
		o_seg_enb,
		i_six_digit_seg,
		i_six_dp,
		i_mode,
		i_position,
		clk,
		rst_n);

output	[5:0]	o_seg_enb		;
output		o_seg_dp		;
output	[6:0]	o_seg			;

input	[41:0]	i_six_digit_seg		;
input	[5:0]	i_six_dp		;
input	[2:0]	i_mode			;
input	[1:0]	i_position		;
input		clk			;
input		rst_n			;

wire		gen_clk			;
wire		blink_clk		;
		

nco		u_nco0(
		.o_gen_clk	( gen_clk	),
		.i_nco_num	( 32'd5000	),	//10000Hz
		.clk		( clk		),
		.rst_n		( rst_n		));

nco		u_nco1(
		.o_gen_clk	( blink_clk	),
		.i_nco_num	( 32'd25000000	),	//25Hz
		.clk		( clk		),
		.rst_n		( rst_n		));


reg	[3:0]	cnt_common_node	;

always @(posedge gen_clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		cnt_common_node <= 4'd0;
	end else begin
		if(cnt_common_node >= 4'd5) begin
			cnt_common_node <= 4'd0;
		end else begin
			cnt_common_node <= cnt_common_node + 1'b1;
		end
	end
end

reg	  	blink		;
always @(posedge blink_clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
 		blink <= 1'd0	;
 	end else begin
  		blink <= ~blink	;
	end
end

reg 	[5:0] 	o_seg_enb  	;
always @(i_mode, i_position, blink, o_seg_enb, cnt_common_node) begin

	if (i_mode == 3'b001) begin
 		if ( (blink == 1'b0) && (i_position == 2'b00) ) begin 
 			case (cnt_common_node)
  				4'd0: o_seg_enb = 6'b111110;
  				4'd1: o_seg_enb = 6'b111101;
  				4'd2: o_seg_enb = 6'b111011;
  				4'd3: o_seg_enb = 6'b110111;
  				4'd4: o_seg_enb = 6'b101111;
  				4'd5: o_seg_enb = 6'b011111;
  				default:o_seg_enb = 6'b111111;
 			endcase
		end else if( ( blink == 1'b1) && (i_position == 2'b00) ) begin
			case (cnt_common_node)
  				4'd0: o_seg_enb = 6'b111111;
  				4'd1: o_seg_enb = 6'b111111;
  				4'd2: o_seg_enb = 6'b111011;
  				4'd3: o_seg_enb = 6'b110111;
  				4'd4: o_seg_enb = 6'b101111;
  				4'd5: o_seg_enb = 6'b011111;
 				default:o_seg_enb = 6'b111111;
 			endcase
		end else if( ( blink == 1'b0) && (i_position == 2'b01) ) begin
			case (cnt_common_node)
  				4'd0: o_seg_enb = 6'b111110;
  				4'd1: o_seg_enb = 6'b111101;
  				4'd2: o_seg_enb = 6'b111011;
  				4'd3: o_seg_enb = 6'b110111;
  				4'd4: o_seg_enb = 6'b101111;
  				4'd5: o_seg_enb = 6'b011111;
  				default:o_seg_enb = 6'b111111;
 			endcase
		end else if( ( blink == 1'b1) && (i_position == 2'b01) ) begin
			case (cnt_common_node)
  				4'd0: o_seg_enb = 6'b111110;
  				4'd1: o_seg_enb = 6'b111101;
  				4'd2: o_seg_enb = 6'b111111;
  				4'd3: o_seg_enb = 6'b111111;
  				4'd4: o_seg_enb = 6'b101111;
  				4'd5: o_seg_enb = 6'b011111;
  				default:o_seg_enb = 6'b111111;
 			endcase
		end else if( ( blink == 1'b0) && (i_position == 2'b10) ) begin
			case (cnt_common_node)
  				4'd0: o_seg_enb = 6'b111110;
  				4'd1: o_seg_enb = 6'b111101;
 				4'd2: o_seg_enb = 6'b111011;
  				4'd3: o_seg_enb = 6'b110111;
  				4'd4: o_seg_enb = 6'b101111;
  				4'd5: o_seg_enb = 6'b011111;
  				default:o_seg_enb = 6'b111111;
 			endcase
		end else if( ( blink == 1'b1) && (i_position == 2'b10) ) begin
			case (cnt_common_node)
  				4'd0: o_seg_enb = 6'b111110;
  				4'd1: o_seg_enb = 6'b111101;
  				4'd2: o_seg_enb = 6'b111011;
  				4'd3: o_seg_enb = 6'b110111;
  				4'd4: o_seg_enb = 6'b111111;
  				4'd5: o_seg_enb = 6'b111111;
  				default:o_seg_enb = 6'b111111;
 			endcase
		end
	end else begin
		case (cnt_common_node)
  			4'd0: o_seg_enb = 6'b111110;
  			4'd1: o_seg_enb = 6'b111101;
  			4'd2: o_seg_enb = 6'b111011;
  			4'd3: o_seg_enb = 6'b110111;
  			4'd4: o_seg_enb = 6'b101111;
  			4'd5: o_seg_enb = 6'b011111;
  			default:o_seg_enb = 6'b111111;
 		endcase
	end
end

reg		o_seg_dp		;

always @(cnt_common_node) begin
	case (cnt_common_node)
		4'd0:	o_seg_dp = i_six_dp[0];
		4'd1:	o_seg_dp = i_six_dp[1];
		4'd2:	o_seg_dp = i_six_dp[2];
		4'd3:	o_seg_dp = i_six_dp[3];
		4'd4:	o_seg_dp = i_six_dp[4];
		4'd5:	o_seg_dp = i_six_dp[5];
	endcase
end

reg	[6:0]	o_seg			;

always @(cnt_common_node) begin
	case (cnt_common_node)
		4'd0:	o_seg = i_six_digit_seg[6:0];
		4'd1:	o_seg = i_six_digit_seg[13:7];
		4'd2:	o_seg = i_six_digit_seg[20:14];
		4'd3:	o_seg = i_six_digit_seg[27:21];
		4'd4:	o_seg = i_six_digit_seg[34:28];
		4'd5:	o_seg = i_six_digit_seg[41:35];
	endcase
end

endmodule

/*//	--------------------------------------------------
//	LED Display
//	--------------------------------------------------
module	led_disp(
		o_seg,
		o_seg_dp,
		o_seg_enb,
		i_six_digit_seg,
		i_six_dp,
		i_mode,
		i_position,
		clk,
		rst_n);

output	[5:0]	o_seg_enb		;
output		o_seg_dp		;
output	[6:0]	o_seg			;

input	[41:0]	i_six_digit_seg		;
input	[5:0]	i_six_dp		;
input	[1:0]	i_mode			;
input	[1:0]	i_position		;
input		clk			;
input		rst_n			;

wire		gen_clk			;
wire		blink_clk		;
		

nco		u_nco0(
		.o_gen_clk	( gen_clk	),
		.i_nco_num	( 32'd5000	),	//10000Hz
		.clk		( clk		),
		.rst_n		( rst_n		));

nco		u_nco1(
		.o_gen_clk	( blink_clk	),
		.i_nco_num	( 32'd25000000	),	//25Hz
		.clk		( clk		),
		.rst_n		( rst_n		));


reg	[3:0]	cnt_common_node	;

always @(posedge gen_clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		cnt_common_node <= 4'd0;
	end else begin
		if(cnt_common_node >= 4'd5) begin
			cnt_common_node <= 4'd0;
		end else begin
			cnt_common_node <= cnt_common_node + 1'b1;
		end
	end
end

if (i_mode == 2'b01) begin

	reg	  	blink		;
	always @(posedge blink_clk or negedge rst_n) begin
		if (rst_n == 1'b0) begin
 			blink <= 1'd0	;
 		end else begin
  			blink <= ~blink	;
		end
	end

	reg 	[5:0] 	o_seg_enb  	;
	always @(cnt_common_node) begin
 		if ( (blink == 2'b0) && (i_position == 2'b00) ) begin 
 			case (cnt_common_node)
  				4'd0: o_seg_enb = 6'b111110;
  				4'd1: o_seg_enb = 6'b111101;
  				4'd2: o_seg_enb = 6'b111011;
  				4'd3: o_seg_enb = 6'b110111;
  				4'd4: o_seg_enb = 6'b101111;
  				4'd5: o_seg_enb = 6'b011111;
  				default:o_seg_enb = 6'b111111;
 			endcase
		end else begin
 			if( ( blink == 2'b1) && (i_position == 2'b00) ) begin
				case (cnt_common_node)
  					4'd0: o_seg_enb = 6'b111111;
  					4'd1: o_seg_enb = 6'b111111;
  					4'd2: o_seg_enb = 6'b111011;
  					4'd3: o_seg_enb = 6'b110111;
  					4'd4: o_seg_enb = 6'b101111;
  					4'd5: o_seg_enb = 6'b011111;
 				 	default:o_seg_enb = 6'b111111;
 				endcase
			end else begin
		 		if( ( blink == 2'b0) && (i_position == 2'b01) ) begin
					case (cnt_common_node)
  						4'd0: o_seg_enb = 6'b111110;
  						4'd1: o_seg_enb = 6'b111101;
  						4'd2: o_seg_enb = 6'b111011;
  						4'd3: o_seg_enb = 6'b110111;
  						4'd4: o_seg_enb = 6'b101111;
  						4'd5: o_seg_enb = 6'b011111;
  						default:o_seg_enb = 6'b111111;
 					endcase
				end else begin
					if( ( blink == 2'b1) && (i_position == 2'b01) ) begin
						case (cnt_common_node)
  							4'd0: o_seg_enb = 6'b111110;
  							4'd1: o_seg_enb = 6'b111101;
  							4'd2: o_seg_enb = 6'b111111;
  							4'd3: o_seg_enb = 6'b111111;
  							4'd4: o_seg_enb = 6'b101111;
  							4'd5: o_seg_enb = 6'b011111;
  							default:o_seg_enb = 6'b111111;
 						endcase
					end else begin
						if( ( blink == 2'b0) && (i_position == 2'b10) ) begin
							case (cnt_common_node)
  								4'd0: o_seg_enb = 6'b111110;
  								4'd1: o_seg_enb = 6'b111101;
 							 	4'd2: o_seg_enb = 6'b111011;
  								4'd3: o_seg_enb = 6'b110111;
  								4'd4: o_seg_enb = 6'b101111;
  								4'd5: o_seg_enb = 6'b011111;
  								default:o_seg_enb = 6'b111111;
 							endcase
						end else begin
							if( ( blink == 2'b1) && (i_position == 2'b10) ) begin
								case (cnt_common_node)
  									4'd0: o_seg_enb = 6'b111110;
  									4'd1: o_seg_enb = 6'b111101;
  									4'd2: o_seg_enb = 6'b111011;
  									4'd3: o_seg_enb = 6'b110111;
  									4'd4: o_seg_enb = 6'b111111;
  									4'd5: o_seg_enb = 6'b111111;
  									default:o_seg_enb = 6'b111111;
 								endcase
							end
						end
					end
				end
			end
		end
	end	
end else begin
		case (cnt_common_node)
  			4'd0: o_seg_enb = 6'b111110;
  			4'd1: o_seg_enb = 6'b111101;
  			4'd2: o_seg_enb = 6'b111011;
  			4'd3: o_seg_enb = 6'b110111;
  			4'd4: o_seg_enb = 6'b101111;
  			4'd5: o_seg_enb = 6'b011111;
  			default:o_seg_enb = 6'b111111;
 		endcase
end




reg		o_seg_dp		;

always @(cnt_common_node) begin
	case (cnt_common_node)
		4'd0:	o_seg_dp = i_six_dp[0];
		4'd1:	o_seg_dp = i_six_dp[1];
		4'd2:	o_seg_dp = i_six_dp[2];
		4'd3:	o_seg_dp = i_six_dp[3];
		4'd4:	o_seg_dp = i_six_dp[4];
		4'd5:	o_seg_dp = i_six_dp[5];
	endcase
end

reg	[6:0]	o_seg			;

always @(cnt_common_node) begin
	case (cnt_common_node)
		4'd0:	o_seg = i_six_digit_seg[6:0];
		4'd1:	o_seg = i_six_digit_seg[13:7];
		4'd2:	o_seg = i_six_digit_seg[20:14];
		4'd3:	o_seg = i_six_digit_seg[27:21];
		4'd4:	o_seg = i_six_digit_seg[34:28];
		4'd5:	o_seg = i_six_digit_seg[41:35];
	endcase
end

endmodule
*/
//	--------------------------------------------------
//	HMS(Hour:Min:Sec) UP Counter
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

//	--------------------------------------------------
//	HMS(Hour:Min:Sec) DOWN Counter					
//	--------------------------------------------------
module	hms_dcnt(
		o_hms_dcnt,
		o_min_hit,
		i_max_cnt,
		i_min_cnt,
		clk,
		rst_n);

output	[5:0]	o_hms_dcnt		;
output		o_min_hit		;

input	[5:0]	i_max_cnt		;
input	[5:0]	i_min_cnt		;
input		clk			;
input		rst_n			;

reg	[5:0]	o_hms_dcnt		;
reg		o_min_hit		;
always @(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_hms_dcnt <= 6'd0;
		o_min_hit <= 1'b0;
	end else begin
		if(o_hms_dcnt <= i_min_cnt) begin
			o_hms_dcnt <= 6'd59;
			o_min_hit <= -1'b1;
		end else begin
			o_hms_dcnt <= o_hms_dcnt - 1'b1;
			o_min_hit <= 1'b0;
		end
	end
end

endmodule

//	--------------------------------------------------
//	Debounce
//	--------------------------------------------------
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
		o_alarm_en,
		o_timer_r,
		o_timer_ss,
		o_ymd,
		o_sec_clk,
		o_min_clk,
		o_hour_clk,
		o_alarm_sec_clk,
		o_alarm_min_clk,
		o_alarm_hour_clk,
		o_timer_up_sec_clk,
		o_timer_up_min_clk,
		o_timer_up_hour_clk,
		o_timer_down_sec_clk,				
		o_timer_down_min_clk,
		o_timer_down_hour_clk,
		o_date_clk,
		o_month_clk,
		o_year_clk,
		i_max_hit_sec,
		i_max_hit_min,
		i_max_hit_hour,
		i_max_hit_date,
		i_max_hit_month,
		i_max_hit_year,
		i_max_hit_sec_timer,
		i_max_hit_min_timer,
		i_max_hit_hour_timer,
		i_min_hit_sec_timer,
		i_min_hit_min_timer,
		i_min_hit_hour_timer,
		i_sw0,
		i_sw1,
		i_sw2,
		i_sw3,
		i_sw4,
		i_sw5,
		i_sw6,
		clk,
		rst_n);

output	[2:0]	o_mode			;
output	[2:0]	o_position		;

output		o_alarm_en		;

output		o_timer_r		;
output		o_timer_ss		;

output		o_ymd			;

output		o_sec_clk		;
output		o_min_clk		;
output		o_hour_clk		;

output		o_alarm_sec_clk		;
output		o_alarm_min_clk		;
output		o_alarm_hour_clk	;

output		o_timer_up_sec_clk	;	
output		o_timer_up_min_clk	;
output		o_timer_up_hour_clk	;

output		o_timer_down_sec_clk	;		
output		o_timer_down_min_clk	;
output		o_timer_down_hour_clk	;

output		o_date_clk		;
output		o_month_clk		;
output		o_year_clk		;

input		i_max_hit_sec		;
input		i_max_hit_min		;
input		i_max_hit_hour		;

input		i_max_hit_date		;
input		i_max_hit_month		;
input		i_max_hit_year		;

input		i_max_hit_sec_timer	;
input		i_max_hit_min_timer	;
input		i_max_hit_hour_timer	;

input		i_min_hit_sec_timer	;
input		i_min_hit_min_timer	;
input		i_min_hit_hour_timer	;

input		i_sw0			;
input		i_sw1			;
input		i_sw2			;
input		i_sw3			;
input		i_sw4			;
input		i_sw5			;
input		i_sw6			;

input		clk			;
input		rst_n			;

parameter	MODE_CLOCK	= 3'b000;
parameter	MODE_SETUP	= 3'b001;
parameter	MODE_ALARM	= 3'b010;
parameter	MODE_TIMER_UP	= 3'b011;
parameter	MODE_TIMER_DOWN	= 3'b100;	

parameter	MODE_YMD	= 1'b0	;		//
parameter	MODE_SETUP_YMD	= 1'b1	;

parameter	POS_SEC		= 2'b00	;
parameter	POS_MIN		= 2'b01	;
parameter	POS_HOUR	= 2'b10	;

parameter	TIMER_RESET	= 1'b1	;

parameter	TIMER_STOP	= 1'b0	;
parameter	TIMER_START	= 1'b1	;

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

wire		sw3			;
debounce	u3_debounce(
		.o_sw		( sw3		),
		.i_sw		( i_sw3		),
		.clk		( clk_100hz	));

wire		sw4			;
debounce	u4_debounce(
		.o_sw		( sw4		),
		.i_sw		( i_sw4		),
		.clk		( clk_100hz	));

wire		sw5			;
debounce	u5_debounce(
		.o_sw		( sw5		),
		.i_sw		( i_sw5		),
		.clk		( clk_100hz	));

wire		sw6			;
debounce	u6_debounce(
		.o_sw		( sw5		),
		.i_sw		( i_sw5		),
		.clk		( clk_100hz	));

reg	[2:0]	o_mode			;
always @(posedge sw0 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_mode <= MODE_CLOCK;
	end else begin
		if(o_mode >= MODE_TIMER_DOWN) begin
			o_mode <= MODE_CLOCK;
		end else begin
			o_mode <= o_mode + 1'b1;
		end
	end
end

reg	[1:0]	o_position		;
always @(posedge sw1 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_position <= POS_SEC;
	end else begin
		if(o_position >= POS_HOUR) begin
			o_position <= POS_SEC;
		end else begin
			o_position <= o_position + 1'b1;
		end
	end
end

reg		o_alarm_en		;
always @(posedge sw3 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_alarm_en <= 1'b0;
	end else begin
		o_alarm_en <= o_alarm_en + 1'b1;
	end
end

reg		o_timer_r		;		
always @(posedge sw4 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_timer_r <= TIMER_RESET;
	end else begin
		o_timer_r <= TIMER_RESET;
	end
end

reg		o_timer_ss		;		
always @(posedge sw5 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_timer_ss <= TIMER_STOP;
	end else begin
		o_timer_ss <= o_timer_ss + 1'b1;
	end
end

reg		o_ymd			;
always @(posedge sw6 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_ymd <= MODE_YMD;
	end else begin
		o_ymd <= o_ymd + 1'b1;
	end
end

wire		clk_1hz			;
nco		u1_nco(
		.o_gen_clk	( clk_1hz	),
		.i_nco_num	( 32'd50000000	),
		.clk		( clk		),
		.rst_n		( rst_n		));

wire		clk_1hz_timer		;
nco		u2_nco(
		.o_gen_clk	( clk_1hz_timer	),
		.i_nco_num	( 32'd50000000	),
		.clk		( clk		),
		.rst_n		( rst_n		));

reg		o_sec_clk		;
reg		o_min_clk		;
reg		o_hour_clk		;

reg		o_alarm_sec_clk		;
reg		o_alarm_min_clk		;
reg		o_alarm_hour_clk	;

reg		o_timer_up_sec_clk	;		
reg		o_timer_up_min_clk	;
reg		o_timer_up_hour_clk	;

reg		o_timer_down_sec_clk	;		
reg		o_timer_down_min_clk	;
reg		o_timer_down_hour_clk	;

reg		o_date_clk		;
reg		o_month_clk		;
reg		o_year_clk		;

always @(*) begin
	case(o_mode)
		MODE_CLOCK : begin
			o_sec_clk = clk_1hz;
			o_min_clk = i_max_hit_sec;
			o_hour_clk = i_max_hit_min;
			o_alarm_sec_clk = 1'b0;
			o_alarm_min_clk = 1'b0;
			o_alarm_hour_clk = 1'b0;
			o_timer_up_sec_clk = 1'b0;		
			o_timer_up_min_clk = 1'b0;
			o_timer_up_hour_clk = 1'b0;
			o_timer_down_sec_clk = 1'b0;		
			o_timer_down_min_clk = 1'b0;
			o_timer_down_hour_clk = 1'b0;
			o_date_clk = i_max_hit_hour;
			o_month_clk = i_max_hit_date;
			o_year_clk = i_max_hit_month;
		end
		MODE_SETUP : begin
			case(o_position)
				POS_SEC : begin
					o_sec_clk = ~sw2;
					o_min_clk = 1'b0;
					o_hour_clk = 1'b0;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = 1'b0;	
					o_timer_down_min_clk = 1'b0;
					o_timer_down_hour_clk = 1'b0;
					o_date_clk = i_max_hit_hour;
					o_month_clk = i_max_hit_date;
					o_year_clk = i_max_hit_month;
				end
				POS_MIN : begin
					o_sec_clk = 1'b0;
					o_min_clk = ~sw2;
					o_hour_clk = 1'b0;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = 1'b0;		
					o_timer_down_min_clk = 1'b0;
					o_timer_down_hour_clk = 1'b0;
					o_date_clk = i_max_hit_hour;
					o_month_clk = i_max_hit_date;
					o_year_clk = i_max_hit_month;
				end
				POS_HOUR : begin
					o_sec_clk = 1'b0;
					o_min_clk = 1'b0;
					o_hour_clk = ~sw2;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = 1'b0;		
					o_timer_down_min_clk = 1'b0;
					o_timer_down_hour_clk = 1'b0;
					o_date_clk = i_max_hit_hour;
					o_month_clk = i_max_hit_date;
					o_year_clk = i_max_hit_month;
				end
			endcase
		end
		MODE_ALARM : begin
			case(o_position)
				POS_SEC : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = ~sw2;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = 1'b0;		
					o_timer_down_min_clk = 1'b0;
					o_timer_down_hour_clk = 1'b0;
					o_date_clk = i_max_hit_hour;
					o_month_clk = i_max_hit_date;
					o_year_clk = i_max_hit_month;
				end
				POS_MIN : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = ~sw2;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = 1'b0;		
					o_timer_down_min_clk = 1'b0;
					o_timer_down_hour_clk = 1'b0;
					o_date_clk = i_max_hit_hour;
					o_month_clk = i_max_hit_date;
					o_year_clk = i_max_hit_month;

				end
				POS_HOUR : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = ~sw2;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = 1'b0;		
					o_timer_down_min_clk = 1'b0;
					o_timer_down_hour_clk = 1'b0;
					o_date_clk = i_max_hit_hour;
					o_month_clk = i_max_hit_date;
					o_year_clk = i_max_hit_month;
				end
			endcase
		end
		MODE_TIMER_UP : begin					
			case(o_timer_r)
				TIMER_RESET : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = clk_1hz_timer;		
					o_timer_up_min_clk = i_max_hit_sec_timer;
					o_timer_up_hour_clk = i_max_hit_min_timer;
					o_timer_down_sec_clk = clk_1hz_timer;		
					o_timer_down_min_clk = i_min_hit_sec_timer;
					o_timer_down_hour_clk = i_min_hit_min_timer;
					o_date_clk = i_max_hit_hour;
					o_month_clk = i_max_hit_date;
					o_year_clk = i_max_hit_month;
				end
			endcase
			case(o_timer_ss)
				TIMER_STOP : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = 1'b0;		
					o_timer_down_min_clk = 1'b0;
					o_timer_down_hour_clk = 1'b0;
					o_date_clk = i_max_hit_hour;
					o_month_clk = i_max_hit_date;
					o_year_clk = i_max_hit_month;
				end
				TIMER_START : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = clk_1hz_timer;		
					o_timer_up_min_clk = i_max_hit_sec_timer;
					o_timer_up_hour_clk = i_max_hit_min_timer;
					o_timer_down_sec_clk = clk_1hz_timer;		
					o_timer_down_min_clk = i_min_hit_sec_timer;
					o_timer_down_hour_clk = i_min_hit_min_timer;
					o_date_clk = i_max_hit_hour;
					o_month_clk = i_max_hit_date;
					o_year_clk = i_max_hit_month;
				end
			endcase
		end
		MODE_TIMER_DOWN : begin					
			case(o_position)
				POS_SEC : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = ~sw2;		
					o_timer_down_min_clk = 1'b0;
					o_timer_down_hour_clk = 1'b0;
					o_date_clk = i_max_hit_hour;
					o_month_clk = i_max_hit_date;
					o_year_clk = i_max_hit_month;
				end
				POS_MIN : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = 1'b0;		
					o_timer_down_min_clk = ~sw2;
					o_timer_down_hour_clk = 1'b0;
					o_date_clk = i_max_hit_hour;
					o_month_clk = i_max_hit_date;
					o_year_clk = i_max_hit_month;

				end
				POS_HOUR : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = 1'b0;		
					o_timer_down_min_clk = 1'b0;
					o_timer_down_hour_clk = ~sw2;
					o_date_clk = i_max_hit_hour;
					o_month_clk = i_max_hit_date;
					o_year_clk = i_max_hit_month;
				end
			endcase
			case(o_timer_r)
				TIMER_RESET : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = clk_1hz_timer;		
					o_timer_up_min_clk = i_max_hit_sec_timer;
					o_timer_up_hour_clk = i_max_hit_min_timer;
					o_timer_down_sec_clk = clk_1hz_timer;		
					o_timer_down_min_clk = i_min_hit_sec_timer;
					o_timer_down_hour_clk = i_min_hit_min_timer;
					o_date_clk = i_max_hit_hour;
					o_month_clk = i_max_hit_date;
					o_year_clk = i_max_hit_month;
				end
			endcase
			case(o_timer_ss)
				TIMER_STOP : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = 1'b0;		
					o_timer_down_min_clk = 1'b0;
					o_timer_down_hour_clk = 1'b0;					o_date_clk = i_max_hit_hour;
					o_month_clk = i_max_hit_date;
					o_year_clk = i_max_hit_month;
				end
				TIMER_START : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = clk_1hz_timer;		
					o_timer_up_min_clk = i_max_hit_sec_timer;
					o_timer_up_hour_clk = i_max_hit_min_timer;
					o_timer_down_sec_clk = clk_1hz_timer;	
					o_timer_down_min_clk = i_min_hit_sec_timer;
					o_timer_down_hour_clk = i_min_hit_min_timer;
					o_date_clk = i_max_hit_hour;
					o_month_clk = i_max_hit_date;
					o_year_clk = i_max_hit_month;
				end
			endcase
		end
	endcase
	case(o_ymd)
			MODE_YMD : begin
				o_sec_clk = clk_1hz;
				o_min_clk = i_max_hit_sec;
				o_hour_clk = i_max_hit_min;
				o_alarm_sec_clk = 1'b0;
				o_alarm_min_clk = 1'b0;
				o_alarm_hour_clk = 1'b0;
				o_timer_up_sec_clk = 1'b0;		
				o_timer_up_min_clk = 1'b0;
				o_timer_up_hour_clk = 1'b0;
				o_timer_down_sec_clk = 1'b0;	
				o_timer_down_min_clk = 1'b0;
				o_timer_down_hour_clk = 1'b0;	
				o_date_clk = i_max_hit_hour;
				o_month_clk = i_max_hit_date;
				o_year_clk = i_max_hit_year;
			end
			MODE_SETUP_YMD : begin
				case(o_position)
					POS_SEC : begin
						o_sec_clk = clk_1hz;
						o_min_clk = i_max_hit_sec;
						o_hour_clk = i_max_hit_min;
						o_alarm_sec_clk = 1'b0;
						o_alarm_min_clk = 1'b0;
						o_alarm_hour_clk = 1'b0;
						o_timer_up_sec_clk = 1'b0;		
						o_timer_up_min_clk = 1'b0;
						o_timer_up_hour_clk = 1'b0;
						o_timer_down_sec_clk = 1'b0;	
						o_timer_down_min_clk = 1'b0;
						o_timer_down_hour_clk = 1'b0;	
						o_date_clk = ~sw2;
						o_month_clk = 1'b0;
						o_year_clk = 1'b0;
					end
					POS_MIN : begin
						o_sec_clk = clk_1hz;
						o_min_clk = i_max_hit_sec;
						o_hour_clk = i_max_hit_min;
						o_alarm_sec_clk = 1'b0;
						o_alarm_min_clk = 1'b0;
						o_alarm_hour_clk = 1'b0;
						o_timer_up_sec_clk = 1'b0;		
						o_timer_up_min_clk = 1'b0;
						o_timer_up_hour_clk = 1'b0;
						o_timer_down_sec_clk = 1'b0;	
						o_timer_down_min_clk = 1'b0;
						o_timer_down_hour_clk = 1'b0;	
						o_date_clk = 1'b0;
						o_month_clk = ~sw2;
						o_year_clk = 1'b0;
					end
					POS_HOUR : begin
						o_sec_clk = clk_1hz;
						o_min_clk = i_max_hit_sec;
						o_hour_clk = i_max_hit_min;
						o_alarm_sec_clk = 1'b0;
						o_alarm_min_clk = 1'b0;
						o_alarm_hour_clk = 1'b0;
						o_timer_up_sec_clk = 1'b0;		
						o_timer_up_min_clk = 1'b0;
						o_timer_up_hour_clk = 1'b0;
						o_timer_down_sec_clk = 1'b0;	
						o_timer_down_min_clk = 1'b0;
						o_timer_down_hour_clk = 1'b0;	
						o_date_clk = 1'b0;
						o_month_clk = 1'b0;
						o_year_clk = ~sw2;
					end
				endcase
			end
	endcase
/*	default: begin
	o_sec_clk = 1'b0;
	o_min_clk = 1'b0;
	o_hour_clk = 1'b0;
	o_alarm_sec_clk = 1'b0;
	o_alarm_min_clk = 1'b0;
	o_alarm_hour_clk = 1'b0;
	o_timer_up_sec_clk = 1'b0;		
	o_timer_up_min_clk = 1'b0;
	o_timer_up_hour_clk = 1'b0;
	o_timer_down_sec_clk = 1'b0;		
	o_timer_down_min_clk = 1'b0;
	o_timer_down_hour_clk = 1'b0;
	o_date_clk = 1'b0;
	o_month_clk = 1'b0;
	o_year_clk = 1'b0;
		end
	endcase*/
end

endmodule

//	--------------------------------------------------
//	HMS(Hour:Min:Sec) Counter
//	--------------------------------------------------
module	hourminsec(	
		o_sec,
		o_min,
		o_hour,
		o_max_hit_sec,
		o_max_hit_min,
		o_max_hit_hour,
		o_max_hit_date,
		o_max_hit_month,
		o_max_hit_year,
		o_max_hit_sec_timer,
		o_max_hit_min_timer,
		o_max_hit_hour_timer,
		o_min_hit_sec_timer,
		o_min_hit_min_timer,
		o_min_hit_hour_timer,
		o_alarm,
		o_timer_down,
		i_mode,
		i_position,
		i_ymd,
		i_sec_clk,
		i_min_clk,
		i_hour_clk,
		i_date_clk,
		i_month_clk,
		i_year_clk,
		i_alarm_sec_clk,
		i_alarm_min_clk,
		i_alarm_hour_clk,
		i_alarm_en,
		i_timer_up_sec_clk,			
		i_timer_up_min_clk,
		i_timer_up_hour_clk,
		i_timer_down_sec_clk,			
		i_timer_down_min_clk,
		i_timer_down_hour_clk,
		i_timer_r,
		i_timer_ss,
		clk,
		rst_n);

output	[5:0]	o_sec			;
output	[5:0]	o_min			;
output	[5:0]	o_hour			;
output		o_max_hit_sec		;
output		o_max_hit_min		;
output		o_max_hit_hour		;
output		o_max_hit_date		;
output		o_max_hit_month		;
output		o_max_hit_year		;
output		o_max_hit_sec_timer	;
output		o_max_hit_min_timer	;
output		o_max_hit_hour_timer	;
output		o_min_hit_sec_timer	;			
output		o_min_hit_min_timer	;
output		o_min_hit_hour_timer	;
output		o_alarm			;
output		o_timer_down		;

input	[2:0]	i_mode			;
input	[1:0]	i_position		;
input		i_ymd			;
input		i_sec_clk		;
input		i_min_clk		;
input		i_hour_clk		;
input		i_date_clk		;
input		i_month_clk		;
input		i_year_clk		;
input		i_alarm_sec_clk		;
input		i_alarm_min_clk		;
input		i_alarm_hour_clk	;
input		i_timer_up_sec_clk	;		
input		i_timer_up_min_clk	;
input		i_timer_up_hour_clk	;
input		i_timer_down_sec_clk	;			
input		i_timer_down_min_clk	;
input		i_timer_down_hour_clk	;
input		i_alarm_en		;
input		i_timer_r		;	
input		i_timer_ss		;	

input		clk			;
input		rst_n			;

parameter	MODE_CLOCK	= 3'b000;
parameter	MODE_SETUP	= 3'b001;
parameter	MODE_ALARM	= 3'b010;
parameter	MODE_TIMER_UP	= 3'b011;		
parameter	MODE_TIMER_DOWN	= 3'b100;	

parameter	MODE_YMD	= 1'b0	;		//
parameter	MODE_SETUP_YMD	= 1'b1	;

parameter	POS_SEC		= 2'b00	;
parameter	POS_MIN		= 2'b01	;
parameter	POS_HOUR	= 2'b10	;

parameter	TIMER_RESET	= 1'b1	;

parameter	TIMER_STOP	= 1'b0	;
parameter	TIMER_START	= 1'b1	;

//	MODE_CLOCK
wire	[5:0]	sec		;
wire		max_hit_sec	;
hms_cnt		u_hms_cnt_sec(
		.o_hms_cnt	( sec			),
		.o_max_hit	( o_max_hit_sec		),
		.i_max_cnt	( 6'd59			),
		.clk		( i_sec_clk		),
		.rst_n		( rst_n			));

wire	[5:0]	min		;
wire		max_hit_min	;
hms_cnt		u_hms_cnt_min(
		.o_hms_cnt	( min			),
		.o_max_hit	( o_max_hit_min		),
		.i_max_cnt	( 6'd59			),
		.clk		( i_min_clk		),
		.rst_n		( rst_n			));

wire	[5:0]	hour		;
wire		max_hit_hour	;
hms_cnt		u_hms_cnt_hour(
		.o_hms_cnt	( hour			),
		.o_max_hit	( o_max_hit_hour	),
		.i_max_cnt	( 6'd23			),
		.clk		( i_hour_clk		),
		.rst_n		( rst_n			));

//	MODE_ALARM
wire	[5:0]	alarm_sec	;
hms_cnt		u_hms_cnt_alarm_sec(
		.o_hms_cnt	( alarm_sec		),
		.o_max_hit	( 			),
		.i_max_cnt	( 6'd59			),
		.clk		( i_alarm_sec_clk	),
		.rst_n		( rst_n			));

wire	[5:0]	alarm_min	;
hms_cnt		u_hms_cnt_alarm_min(
		.o_hms_cnt	( alarm_min		),
		.o_max_hit	( 			),
		.i_max_cnt	( 6'd59			),
		.clk		( i_alarm_min_clk	),
		.rst_n		( rst_n			));

wire	[5:0]	alarm_hour	;
hms_cnt		u_hms_cnt_alarm_hour(
		.o_hms_cnt	( alarm_hour		),
		.o_max_hit	( 			),
		.i_max_cnt	( 6'd23			),
		.clk		( i_alarm_hour_clk	),
		.rst_n		( rst_n			));

//	MODE_TIMER_UP					//
wire	[5:0]	timer_up_sec	 ;
wire		max_hit_sec_timer;
hms_cnt		u_hms_cnt_timer_up_sec(
		.o_hms_cnt	( timer_up_sec		),
		.o_max_hit	( o_max_hit_sec_timer	),
		.i_max_cnt	( 6'd59			),
		.clk		( i_timer_up_sec_clk	),
		.rst_n		( rst_n			));

wire	[5:0]	timer_up_min	 ;
wire		max_hit_min_timer;
hms_cnt		u_hms_cnt_timer_up_min(
		.o_hms_cnt	( timer_up_min		),
		.o_max_hit	( o_max_hit_min_timer	),
		.i_max_cnt	( 6'd59			),
		.clk		( i_timer_up_min_clk	),
		.rst_n		( rst_n			));

wire	[5:0]	timer_up_hour	  ;
wire		max_hit_hour_timer;
hms_cnt		u_hms_cnt_timer_up_hour(
		.o_hms_cnt	( timer_up_hour		),
		.o_max_hit	( o_max_hit_hour_timer  ),
		.i_max_cnt	( 6'd23			),
		.clk		( i_timer_up_hour_clk	),
		.rst_n		( rst_n			));

//	MODE_TIMER_DOWN					//
wire	[5:0]	timer_down_sec	;
wire		min_hit_sec_timer	;
hms_dcnt	u_hms_cnt_timer_down_sec(
		.o_hms_dcnt	( timer_down_sec	),
		.o_min_hit	( o_min_hit_sec_timer	),
		.i_max_cnt	( 6'd59			),
		.i_min_cnt	( 6'd0			),
		.clk		( i_timer_down_sec_clk	),
		.rst_n		( rst_n			));

wire	[5:0]	timer_down_min	;
wire		min_hit_min_timer	;
hms_dcnt	u_hms_cnt_timer_down_min(
		.o_hms_dcnt	( timer_down_min	),
		.o_min_hit	( o_min_hit_min_timer	),
		.i_max_cnt	( 6'd59			),
		.i_min_cnt	( 6'd0			),
		.clk		( i_timer_down_min_clk	),
		.rst_n		( rst_n			));

wire	[5:0]	timer_down_hour	;
wire		min_hit_hour_timer	;
hms_dcnt	u_hms_cnt_timer_down_hour(
		.o_hms_dcnt	( timer_down_hour	),
		.o_min_hit	( o_min_hit_hour_timer	),
		.i_max_cnt	( 6'd23			),
		.i_min_cnt	( 6'd0			),
		.clk		( i_timer_down_hour_clk	),
		.rst_n		( rst_n			));

//	MODE_YMD
wire	[5:0]	DATE		;
wire		max_hit_date	;
hms_cnt		u_hms_cnt_date(
		.o_hms_cnt	( date			),
		.o_max_hit	( o_max_hit_date	),
		.i_max_cnt	( 6'd31			),
		.clk		( i_date_clk		),
		.rst_n		( rst_n			));

wire	[5:0]	MONTH		;
wire		max_hit_month	;
hms_cnt		u_hms_cnt_month(
		.o_hms_cnt	( month			),
		.o_max_hit	( o_max_hit_month	),
		.i_max_cnt	( 6'd12			),
		.clk		( i_month_clk		),
		.rst_n		( rst_n			));

wire	[6:0]	YEAR		;
wire		max_hit_year	;
hms_cnt		u_hms_cnt_year(
		.o_hms_cnt	( year			),
		.o_max_hit	( o_max_hit_year	),
		.i_max_cnt	( 6'd99			),
		.clk		( i_year_clk		),
		.rst_n		( rst_n			));

reg	[5:0]	o_sec		;
reg	[5:0]	o_min		;
reg	[5:0]	o_hour		;
always @ (*) begin
	case(i_mode)
		MODE_CLOCK: 	begin
			o_sec	= sec ;
			o_min	= min ;
			o_hour	= hour;
		end
		MODE_SETUP:	begin
			o_sec	= sec ;
			o_min	= min ;
			o_hour	= hour;
		end
		MODE_ALARM:	begin
			o_sec	= alarm_sec ;
			o_min	= alarm_min ;
			o_hour	= alarm_hour;
		end
		MODE_TIMER_UP:	  begin				//
			o_sec	= timer_up_sec ;
			o_min	= timer_up_min ;
			o_hour	= timer_up_hour;
		end
		MODE_TIMER_DOWN:  begin				//
			o_sec	= timer_down_sec ;
			o_min	= timer_down_min ;
			o_hour	= timer_down_hour;
		end
	endcase
	case(i_ymd)
		MODE_YMD: 	begin
			o_sec	= date ;
			o_min	= month;
			o_hour	= year ;
		end
		MODE_SETUP_YMD:	begin
			o_sec	= date ;
			o_min	= month;
			o_hour	= year ;
		end
	endcase
	/*case(i_timer_s)
		TIMER_START: 	begin
			o_sec	= timer_up_sec ;
			o_min	= timer_up_min ;
			o_hour	= timer_up_hour;
		end
	endcase*/
	/*case(i_timer_r)
		TIMER_RESET: 	begin
			o_sec	= 6'd0 ;
			o_min	= 6'd0 ;
			o_hour	= 6'd0 ;
		end*/
	/*	TIMER_STOP:	begin
			o_sec	= timer_up_sec ;
			o_min	= timer_up_min ;
			o_hour	= timer_up_hour;
		end
	endcase*/
end

reg		o_alarm		;				//
reg		o_timer_down	;	
always @ (posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		o_alarm <= 1'b0;
		o_timer_down <= 1'b0;
	end else begin
		if( (sec == alarm_sec) && (min == alarm_min) && (hour == alarm_hour) ) begin
			o_alarm <= 1'b1 & i_alarm_en;
		end else begin
			o_alarm <= o_alarm & i_alarm_en;
		end
		if( (timer_down_sec == 6'd0) && (timer_down_min == 6'd0) && (timer_down_hour == 6'd0) ) begin
			o_alarm <= 1'b1 & i_timer_ss;
		end else begin
			o_alarm <= o_alarm & i_timer_ss;
		end
	end
end


endmodule

//	--------------------------------------------------
//	Buzz
//	--------------------------------------------------
module	buzz(
		o_buzz,
		i_buzz_en,
		clk,
		rst_n);

output		o_buzz		;

input		i_buzz_en	;
input		clk		;
input		rst_n		;

parameter	C = 23889 ;
parameter	D = 21283 ;
parameter	E = 18961 ;
parameter	F = 17897 ;
parameter	G = 15944 ;
parameter	A = 14205 ;
parameter	B = 12655 ;
parameter	HC = 11944;
parameter	HD = 10641;
parameter	HE = 9480 ;
parameter	HF = 8948 ;
parameter	HG = 7972 ;
parameter	HA = 7102 ;
parameter	HB = 6327 ;
parameter	O = 1000  ;
/*parameter	C = 47778 ;
parameter	D = 42566 ;
parameter	E = 37922 ;
parameter	F = 35793 ;
parameter	G = 31888 ;
parameter	A = 28409 ;
parameter	B = 25310 ;
parameter	HC = 23889 ;
parameter	HD = 21283 ;
parameter	HE = 18961 ;
parameter	HF = 17897 ;
parameter	HG = 15944 ;
parameter	HA = 14205 ;
parameter	HB = 12655 ;
parameter	O = 1000  ;*/
/*parameter	C = 11944;
parameter	D = 10641;
parameter	E = 9480 ;
parameter	F = 8948 ;
parameter	G = 7972 ;
parameter	A = 7102 ;
parameter	B = 6327 ;
parameter	HC = 5975;
parameter	HD = 5325;
parameter	HE = 4746 ;
parameter	HF = 4482 ;
parameter	HG = 3994 ;
parameter	HA = 3560 ;
parameter	HB = 3173 ;
parameter	O = 1500   ;*/

wire		clk_bit		;
nco	u_nco_bit(	
		.o_gen_clk	( clk_bit	),
		.i_nco_num	( 25000000	),
		.clk		( clk		),
		.rst_n		( rst_n		));

reg	[6:0]	cnt		;
always @ (posedge clk_bit or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		cnt <= 7'd0;
	end else begin
		if (cnt >= 7'd96) begin
			cnt <= 7'd0;
		end else begin
			if (i_buzz_en == 1'b1) begin
				cnt <= cnt + 1'b1;
			end
		end
	end
end

reg	[31:0]	nco_num		;
always @ (*) begin
	case(cnt)
		7'd00: nco_num = O	;
		7'd01: nco_num = E	;
		7'd02: nco_num = O	;
		7'd03: nco_num = G	;
		7'd04: nco_num = HD	;
		7'd05: nco_num = O	;
		7'd06: nco_num = O	;
		7'd07: nco_num = HC	;
		7'd08: nco_num = O	;
		7'd09: nco_num = G	;
		7'd10: nco_num = F	;
		7'd11: nco_num = O	;
		7'd12: nco_num = O	;
		7'd13: nco_num = E	;
		7'd14: nco_num = O	;
		7'd15: nco_num = E	;
		7'd16: nco_num = E	;
		7'd17: nco_num = F	;
		7'd18: nco_num = G	;
		7'd19: nco_num = A	;
		7'd20: nco_num = O	;
		7'd21: nco_num = O	;
		7'd22: nco_num = G	;
		7'd23: nco_num = O	;
		7'd24: nco_num = O	;
		7'd25: nco_num = E	;
		7'd26: nco_num = O	;
		7'd27: nco_num = G	;
		7'd28: nco_num = HD	;
		7'd29: nco_num = O	;
		7'd30: nco_num = O	;
		7'd31: nco_num = HC	;
		7'd32: nco_num = O	;
		7'd33: nco_num = G	;
		7'd34: nco_num = F	;
		7'd35: nco_num = O	;
		7'd36: nco_num = O	;
		7'd37: nco_num = E	;
		7'd38: nco_num = O	;
		7'd39: nco_num = G	;
		7'd40: nco_num = G	;
		7'd41: nco_num = A	;
		7'd42: nco_num = B	;
		7'd43: nco_num = HC	;
		7'd44: nco_num = O	;
		7'd45: nco_num = O	;
		7'd46: nco_num = HC	;
		7'd47: nco_num = O	;
		7'd48: nco_num = O	;
		7'd49: nco_num = HD	;
		7'd50: nco_num = O	;
		7'd51: nco_num = G	;
		7'd52: nco_num = B	;
		7'd53: nco_num = A	;
		7'd54: nco_num = G	;
		7'd55: nco_num = E	;
		7'd56: nco_num = O	;
		7'd57: nco_num = G	;
		7'd58: nco_num = HC	;
		7'd59: nco_num = O	;
		7'd60: nco_num = O	;
		7'd61: nco_num = A	;
		7'd62: nco_num = O	;
		7'd63: nco_num = HC	;
		7'd64: nco_num = HD	;
		7'd65: nco_num = O	;
		7'd66: nco_num = HC	;
		7'd67: nco_num = B	;
		7'd68: nco_num = O	;
		7'd69: nco_num = O	;
		7'd70: nco_num = G	;
		7'd71: nco_num = O	;
		7'd72: nco_num = O	;
		7'd73: nco_num = E	;
		7'd74: nco_num = O	;
		7'd75: nco_num = G	;
		7'd76: nco_num = HD	;
		7'd77: nco_num = O	;
		7'd78: nco_num = O	;
		7'd79: nco_num = HC	;
		7'd80: nco_num = O	;
		7'd81: nco_num = G	;
		7'd82: nco_num = F	;
		7'd83: nco_num = O	;
		7'd84: nco_num = O	;
		7'd85: nco_num = E	;
		7'd86: nco_num = O	;
		7'd87: nco_num = G	;
		7'd88: nco_num = G	;
		7'd89: nco_num = A	;
		7'd90: nco_num = B	;
		7'd91: nco_num = HC	;
		7'd92: nco_num = O	;
		7'd93: nco_num = O	;
		7'd94: nco_num = HC	;
		7'd95: nco_num = O	;
		7'd96: nco_num = O	;
	endcase
end

wire		buzz		;
nco	u_nco_buzz(	
		.o_gen_clk	( buzz		),
		.i_nco_num	( nco_num	),
		.clk		( clk		),
		.rst_n		( rst_n		));

assign		o_buzz = buzz & i_buzz_en & clk_bit;
//assign		o_buzz = buzz & i_buzz_en;

endmodule

//	--------------------------------------------------
//	Top Module
//	--------------------------------------------------
module	top_DigitalClock(
			o_seg_enb,
			o_seg_dp,
			o_seg,
			o_alarm,
			i_sw0,
			i_sw1,
			i_sw2,
			i_sw3,
			i_sw4,
			i_sw5,
			i_sw6,
			clk,
			rst_n);

output	[5:0]	o_seg_enb		;
output		o_seg_dp		;
output	[6:0]	o_seg			;
output		o_alarm			;

input		i_sw0			;
input		i_sw1			;
input		i_sw2			;
input		i_sw3			;
input		i_sw4			;
input		i_sw5			;
input		i_sw6			;
input		clk			;
input		rst_n			;

wire	[2:0]	o_mode_w	    	;
wire	[1:0]	o_position_w	    	;
wire		o_ymd_w		    ;

wire		o_alarm_w	    	;
wire		o_alarm_en_w	    	;

wire		o_timer_s_w	    	;
wire		o_timer_rs_w	    	;
wire		o_timer_down_w	    	;

wire		o_alarm_sec_clk_w   	;
wire		o_alarm_min_clk_w   	;
wire		o_alarm_hour_clk_w  	;

wire		o_timer_sec_clk_w  	;		
wire		o_timer_min_clk_w   	;
wire		o_timer_hour_clk_w  	;

wire		o_sec_clk_w	    	;
wire		o_min_clk_w	    	;
wire		o_hour_clk_w	    	;

wire		o_max_hit_sec_w	    	;
wire		o_max_hit_min_w	    	;
wire		o_max_hit_hour_w    	;

wire		o_max_hit_sec_timer_w	;
wire		o_max_hit_min_timer_w	;
wire		o_max_hit_hour_timer_w  ;

wire		o_min_hit_sec_timer_w	;
wire		o_min_hit_min_timer_w	;
wire		o_min_hit_hour_timer_w  ;

wire	[5:0]   i_double_fig_sec_w  	;
wire	[5:0]   i_double_fig_min_w  	;
wire	[5:0]   i_double_fig_hour_w 	;

wire	[3:0]   i_num_sec_1_w	    	;
wire	[3:0]   i_num_sec_2_w	    	;	

wire	[3:0]   i_num_min_1_w	    	;
wire	[3:0]   i_num_min_2_w	    	;

wire	[3:0]   i_num_hour_1_w	    	;
wire	[3:0]   i_num_hour_2_w	    	;

wire	[6:0]	o_seg_sec_1_w	    	;
wire	[6:0]	o_seg_sec_2_w	    	;
		
wire	[6:0]	o_seg_min_1_w	    	;
wire	[6:0]	o_seg_min_2_w	    	;

wire	[6:0]	o_seg_hour_1_w	    	;
wire	[6:0]	o_seg_hour_2_w	    	;

wire	[41:0]	i_six_digit_seg_w   	;
assign          i_six_digit_seg_w = { o_seg_hour_1_w, o_seg_hour_2_w, o_seg_min_1_w, o_seg_min_2_w, o_seg_sec_1_w, o_seg_sec_2_w };

controller	u_controller( .o_mode		     ( o_mode_w	      		),
			      .o_position	     ( o_position_w	        ),
			      .o_alarm_en	     ( o_alarm_en_w             ),
			      .o_timer_r	     ( o_timer_r_w              ),
			      .o_timer_ss	     ( o_timer_ss_w             ),
			      .o_ymd		     ( o_ymd_w	                ),
			      .o_sec_clk	     ( o_sec_clk_w	        ),
			      .o_min_clk	     ( o_min_clk_w        	),
			      .o_hour_clk	     ( o_hour_clk_w        	),
			      .o_date_clk	     ( o_date_clk_w		),
			      .o_month_clk	     ( o_month_clk_w		),
			      .o_year_clk	     ( o_year_clk_w		),
			      .o_alarm_sec_clk       ( o_alarm_sec_clk_w   	),
			      .o_alarm_min_clk       ( o_alarm_min_clk_w   	),
			      .o_alarm_hour_clk      ( o_alarm_hour_clk_w  	),
			      .o_timer_up_sec_clk    ( o_timer_up_sec_clk_w     ),			//
			      .o_timer_up_min_clk    ( o_timer_up_min_clk_w     ),
			      .o_timer_up_hour_clk   ( o_timer_up_hour_clk_w    ),
			      .o_timer_down_sec_clk  ( o_timer_down_sec_clk_w   ),			//
			      .o_timer_down_min_clk  ( o_timer_down_min_clk_w   ),	
			      .o_timer_down_hour_clk ( o_timer_down_hour_clk_w  ),	
			      .i_max_hit_sec	     ( o_max_hit_sec_w    	),
			      .i_max_hit_min	     ( o_max_hit_min_w     	),
			      .i_max_hit_hour	     ( o_max_hit_hour_w    	),
			      .i_max_hit_date	     ( o_max_hit_date_w		),
			      .i_max_hit_month       ( o_max_hit_month_w	),
			      .i_max_hit_year	     ( o_max_hit_year_w		),
			      .i_max_hit_sec_timer   ( o_max_hit_sec_timer_w    ),
			      .i_max_hit_min_timer   ( o_max_hit_min_timer_w    ),
			      .i_max_hit_hour_timer  ( o_max_hit_hour_timer_w   ),
			      .i_min_hit_sec_timer   ( o_min_hit_sec_timer_w    ),
			      .i_min_hit_min_timer   ( o_min_hit_min_timer_w    ),
			      .i_min_hit_hour_timer  ( o_min_hit_hour_timer_w   ),
			      .i_sw0		     ( i_sw0 	     	 	),
			      .i_sw1		     ( i_sw1 	      		),
			      .i_sw2		     ( i_sw2 	      		),
			      .i_sw3		     ( i_sw3 	                ),
			      .i_sw4		     ( i_sw4 	                ),
			      .i_sw5		     ( i_sw5 	                ),
			      .i_sw6		     ( i_sw6 	                ),
			      .clk		     ( clk		        ),
			      .rst_n		     ( rst_n		        ));

hourminsec	u_hourminsec( .o_sec		     ( i_double_fig_sec_w       ),
			      .o_min		     ( i_double_fig_min_w       ),
			      .o_hour		     ( i_double_fig_hour_w      ),
			      .o_max_hit_sec	     ( o_max_hit_sec_w          ),
			      .o_max_hit_min	     ( o_max_hit_min_w          ),
			      .o_max_hit_hour	     ( o_max_hit_hour_w    	),
			      .o_max_hit_date	     ( o_max_hit_date_w         ),
			      .o_max_hit_month	     ( o_max_hit_month_w        ),
			      .o_max_hit_year	     ( o_max_hit_year_w         ),
			      .o_max_hit_sec_timer   ( o_max_hit_sec_timer_w    ),
			      .o_max_hit_min_timer   ( o_max_hit_min_timer_w    ),
			      .o_max_hit_hour_timer  ( o_max_hit_hour_timer_w   ),
			      .o_min_hit_sec_timer   ( o_min_hit_sec_timer_w    ),
			      .o_min_hit_min_timer   ( o_min_hit_min_timer_w    ),
			      .o_min_hit_hour_timer  ( o_min_hit_hour_timer_w   ),
			      .o_alarm		     ( o_alarm_w	        ),
			      .o_timer_down	     ( o_timer_down_w	        ),
			      .i_mode		     ( o_mode_w	      		),
			      .i_position	     ( o_position_w	        ),
			      .i_ymd		     ( o_ymd_w		        ),
			      .i_sec_clk	     ( o_sec_clk_w	        ),
			      .i_min_clk	     ( o_min_clk_w         	),
			      .i_hour_clk	     ( o_hour_clk_w        	),
			      .i_date_clk	     ( o_date_clk_w		),
			      .i_month_clk	     ( o_month_clk_w		),
			      .i_year_clk	     ( o_year_clk_w		),
			      .i_alarm_sec_clk       ( o_alarm_sec_clk_w   	),
			      .i_alarm_min_clk       ( o_alarm_min_clk_w   	),
			      .i_alarm_hour_clk      ( o_alarm_hour_clk_w  	),
			      .i_alarm_en	     ( o_alarm_en_w        	),
			      .i_timer_up_sec_clk    ( o_timer_up_sec_clk_w   	),
			      .i_timer_up_min_clk    ( o_timer_up_min_clk_w   	),
			      .i_timer_up_hour_clk   ( o_timer_up_hour_clk_w  	),
			      .i_timer_down_sec_clk  ( o_timer_down_sec_clk_w   ),
			      .i_timer_down_min_clk  ( o_timer_down_min_clk_w   ),
			      .i_timer_down_hour_clk ( o_timer_down_hour_clk_w  ),
			      .i_timer_r	     ( o_timer_r_w        	),
			      .i_timer_ss	     ( o_timer_ss_w        	),
			      .clk		     ( clk		        ),
		 	      .rst_n		     ( rst_n		        ));

double_fig_sep	      u0_dfs( .o_left		     ( i_num_sec_1_w	        ),
			      .o_right		     ( i_num_sec_2_w	        ),
			      .i_double_fig	     ( i_double_fig_sec_w       ));

double_fig_sep	      u1_dfs( .o_left		     ( i_num_min_1_w	        ),
			      .o_right		     ( i_num_min_2_w	        ),
			      .i_double_fig	     ( i_double_fig_min_w  	));

double_fig_sep	      u2_dfs( .o_left	     	     ( i_num_hour_1_w       	),
			      .o_right	  	     ( i_num_hour_2_w           ),
			      .i_double_fig          ( i_double_fig_hour_w      ));

fnd_dec		  u0_fnd_dec( .o_seg	     	     ( o_seg_sec_1_w            ),
		              .i_num	     	     ( i_num_sec_1_w            ));

fnd_dec		  u1_fnd_dec( .o_seg	     	     ( o_seg_sec_2_w            ),
		              .i_num	     	     ( i_num_sec_2_w            ));

fnd_dec		  u2_fnd_dec( .o_seg	     	     ( o_seg_min_1_w            ),
		              .i_num	     	     ( i_num_min_1_w            ));

fnd_dec		  u3_fnd_dec( .o_seg	     	     ( o_seg_min_2_w            ),
		              .i_num	     	     ( i_num_min_2_w            ));

fnd_dec		  u4_fnd_dec( .o_seg	     	     ( o_seg_hour_1_w           ),
			      .i_num	    	     ( i_num_hour_1_w           ));

fnd_dec		  u5_fnd_dec( .o_seg	     	     ( o_seg_hour_2_w           ),
			      .i_num	    	     ( i_num_hour_2_w           ));

led_disp	  u_led_disp( .o_seg		     ( o_seg	       		),
			      .o_seg_dp	             ( o_seg_dp	       		),
			      .o_seg_enb	     ( o_seg_enb 	        ),
			      .i_six_digit_seg       ( i_six_digit_seg_w        ),
			      .i_six_dp		     ( o_mode_w	       		),
			      .clk		     ( clk		        ),
			      .rst_n		     ( rst_n		        ));


buzz		      u_buzz( .o_buzz		     ( o_alarm	       		),
			      .i_buzz_en	     ( o_alarm_w	        ),
			      .clk		     ( clk		        ),
		  	      .rst_n		     ( rst_n		        ));


endmodule

