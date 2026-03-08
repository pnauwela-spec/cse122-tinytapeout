`default_nettype none `timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb_ds0 ();

  // Dump the signals to a FST file. You can view it with gtkwave or surfer.
  	initial begin
    	$dumpfile("tb.fst");
    	$dumpvars(0, tb_ds0);
    	#1;
  	end

  // Wire up the inputs and outputs:
  	reg clk;
  	reg rst_n;
	reg ena;
  	reg [7:0] ui_in;
  	wire [7:0] uo_out;
	wire [7:0] uio_oe;
	wire [7:0] uio;
`ifdef GL_TEST
  	wire VPWR = 1'b1;
  	wire VGND = 1'b0;
`endif

	integer i;
	integer error_count = 0;
	reg [7:0] expected;

	initial begin 
		clk = 0;
    	forever #20 clk = ~clk;   // 25 MHz clock
	end

  // Replace tt_um_example with your module name:
  	`ifdef GL_TEST
    	tt_um_pnauwela_ds0 dut (
        	.ui_in(ui_in),
        	.uo_out(uo_out),
			.uio(uio),
			.uio(uio_oe),
        	.clk(clk),
        	.rst_n(rst_n),
			.ena(ena),
        	.VPWR(VPWR),
        	.VGND(VGND)
    );
	`else
    	tt_um_pnauwela_ds0 dut (
        	.ui_in(ui_in),
        	.uo_out(uo_out),
			.uio(uio),
			.uio_oe(uio_oe),
        	.clk(clk),
        	.rst_n(rst_n)
    	);
	`endif

	initial begin
		$display("Starting DS0 Test");

		rst_n = 0;
		ui_in = 8'hA5;
		ena = 1;

		repeat (5) @(posedge clk);
		rst_n = 1;
		
		expected = 8'b10100101;
		
		wait (uo_out[1] == 1);
		wait (uo_out[1] == 0);
		@(posedge clk);
		for (i = 7; i >= 0; i = i - 1) begin 
			if (uo_out[0] !== expected[i]) begin 
				$display("Error: Bit %0d mismatch. Expected %b. Got %b",
						 i, expected[i], uo_out[0]);
				error_count = error_count + 1;
			end else begin
				$display("Bit %0d correct: %b", i, uo_out[0]);
			end

			wait(uo_out[1] == 1);
			wait(uo_out[1] == 0);
			@(posedge clk);
		end
		
		if (error_count == 0) begin 
			$display("Tests Passed");
		end else begin 
			$display("Tests failed with %0d errors", error_count);
		end

		$finish;
	end
      	

endmodule
