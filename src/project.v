/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_pnauwela_ds0 (
    input  wire [7:0] ui_in,   // Dedicated inputs
    output wire [7:0] uo_out,  // Dedicated outputs
	input  wire [7:0] uio,
	output wire [7:0] uio_oe,
    input  wire       clk,     // clock
    input  wire       rst_n,    // reset_n - low to reset
	input  wire       ena
);

	//clk divider - 64kHz required

	reg [8:0] clk_div;
	reg 	  bit_tick;

	assign uio = 8'b0;
	assign uio_oe = 8'b0;

	always @(posedge clk or negedge rst_n) begin 
		if (!rst_n) begin
			clk_div <= 9'd0;
			bit_tick <= 1'b0;
		end else if (ena) begin 
			//rough estimate, can't get exactly 64kHz from 25MHz
			if (clk_div == 9'd389) begin
				clk_div <= 9'd0;
				bit_tick <= 1'b1;
			end else begin 
				clk_div <= clk_div + 1;
				bit_tick <= 1'b0;
			end
		end
	end

	//DS0 shift register
	reg [7:0] shift_reg;
	reg [2:0] bit_cnt;
	reg		  serial_out;

	assign uo_out[0] = serial_out;
	assign uo_out[1] = bit_tick;
	assign uo_out[7:2] = 6'b0;

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin 
			shift_reg <= 8'd0;
			bit_cnt  <= 3'b0;
			serial_out <= 1'b0;
		end else if (bit_tick) begin
			if(bit_cnt == 3'd0) begin 
				shift_reg <= ui_in;
				serial_out <= ui_in[7];
			end else begin
				shift_reg <= {shift_reg[6:0], 1'b0};
				serial_out <= shift_reg[6];
			end
			bit_cnt <= bit_cnt + 1;

		end
	end

endmodule
