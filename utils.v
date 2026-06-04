// 83ms debounce given 50MHz clock
module button_debounce #(
    parameter SINGLE_CYCLE_TRIGGER = 0
) (
	input  wire clk,
	input  wire button,
	output reg  debounced
);
	// double flop to avoid metastability
	reg sync1, sync2;
	
	// to allow for the single cylce trigger parameter
	// when off, is equal to exposed output
	reg internal_debounce;
	
	reg [24:0] counter;
	
	initial begin
		internal_debounce = 0;
		debounced = 0;
	end
	
	always @(posedge clk) begin
		sync1 <= button;
		sync2 <= sync1;
		
		if (sync2 != internal_debounce) begin
			counter <= counter + 1;
			if (counter[24] == 1) begin
				internal_debounce <= sync2;
				debounced <= sync2;
			end
		end
		else begin
			counter <= 0;
			
			if (SINGLE_CYCLE_TRIGGER)
				debounced <= 0;
		end
	end
endmodule

module hex_to_7seg (
    input  wire [3:0] num,
    output reg  [6:0] seg
);
    always @(*) begin
        case (num)
            4'h0: seg = 7'b100_0000; // 0
            4'h1: seg = 7'b111_1001; // 1
            4'h2: seg = 7'b010_0100; // 2
            4'h3: seg = 7'b011_0000; // 3
            4'h4: seg = 7'b001_1001; // 4
            4'h5: seg = 7'b001_0010; // 5
            4'h6: seg = 7'b000_0010; // 6
            4'h7: seg = 7'b111_1000; // 7
            4'h8: seg = 7'b000_0000; // 8
            4'h9: seg = 7'b001_0000; // 9
            4'hA: seg = 7'b000_1000; // A
            4'hb: seg = 7'b000_0011; // b
            4'hC: seg = 7'b100_0110; // C
            4'hd: seg = 7'b010_0001; // d
            4'hE: seg = 7'b000_0110; // E
            4'hF: seg = 7'b000_1110; // F
				default: seg = 7'b000_0000;
        endcase
    end
endmodule

module display_32bit_7seg (
	input [31:0] num,
	output wire [6:0] hex0,
	output wire [6:0] hex1,
	output wire [6:0] hex2,
	output wire [6:0] hex3,
	input upper_sel // 1 for most significant 16
);
	// 0 on right
	reg [3:0] digit0, digit1, digit2, digit3;

	hex_to_7seg hex0conv(digit0, hex0);
	hex_to_7seg hex1conv(digit1, hex1);
	hex_to_7seg hex2conv(digit2, hex2);
	hex_to_7seg hex3conv(digit3, hex3);
	

	always @(*) begin
		if (!upper_sel) begin
			digit0 = num[3:0];
			digit1 = num[7:4];
			digit2 = num[11:8];
			digit3 = num[15:12];
		end else begin
			digit0 = num[19:16];
			digit1 = num[23:20];
			digit2 = num[27:24];
			digit3 = num[31:28];
		end
	end
endmodule

