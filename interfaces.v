// big endian
module flash_interface32bit(
	input  wire clk,
	input  wire rst_n,
	
	output reg  [21:0] interface_addr,
	input  wire [7:0]  interface_data,
	
	input  wire byte_mode,

	input  wire read_request,
	input  wire [21:0] addr,
	
	output reg [31:0] data,
	output reg finished,
	
	output reg busy
);
	// states
	localparam IDLE  = 3'd0;
	
	localparam READ_BYTE = 3'd1;
	
	// four 8-bit accseses for 32 bits
	localparam READ1 = 3'd2;
	localparam READ2 = 3'd3;	
	localparam READ3 = 3'd4;
	localparam READ4 = 3'd5;
	

	reg [2:0] state = IDLE;
	reg [2:0] next_state = IDLE;
	
	// each 8-bit access takes <=90ns, at 50MHz this needs 5 cycles
	reg [3:0] delay_counter;
		
	// FSM
	always @(*) begin
		next_state = state;
		if (state == IDLE) begin
			if (read_request)
				next_state = READ1;
			else if (read_request & byte_mode)
				next_state = READ_BYTE;
		end
		
		if (delay_counter == 4)begin
			case (state)
				READ1:
					next_state = READ2;
				READ2:
					next_state = READ3;
				READ3:
					next_state = READ4;
				READ4:
					next_state = IDLE;

				READ_BYTE:
					next_state = IDLE;
			endcase
		end
		
	end
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			state <= IDLE;
			finished <= 0;
			data <= 0;
			busy <= 0;
			interface_addr <= 0;
		end else begin
			// FSM transitions
			if (next_state != state) begin
				delay_counter <= 0;
			
				case (state)
					IDLE: begin
						delay_counter <= 0;
						interface_addr <= addr;
						busy <= 1;
						finished <= 0;
						data <= 0;
					end

					READ1: begin 
						data[31:24] <= interface_data;
						interface_addr <= addr + 1;
					end
					READ2: begin
						data[23:16] <= interface_data;
						interface_addr <= addr + 2;
					end
					READ3: begin
						data[15:8]  <= interface_data;
						interface_addr <= addr + 3;
					end
					READ4: begin
						data[7:0] <= interface_data;
						finished <= 1;
						busy <= 0;
					end

					READ_BYTE: begin
						data[7:0] <= interface_data;
						finished <= 1;
						busy <= 0;
					end

				endcase
			end else
				delay_counter <= delay_counter + 1;
			
			state <= next_state;
		end
	end
endmodule

// big endian
// upper lower upper lower
// 8bits_8bits 8bits_8bits
module sram_interface32bit(
	input  wire clk,
	input  wire rst_n,
	
	output reg  [17:0] interface_addr,
	inout  wire [15:0] interface_data,
  output reg interface_upper_byte_mask_n,
  output reg interface_lower_byte_mask_n,
	
	output reg interface_output_enable_n,
	output reg interface_write_enable_n,
	
	input  wire byte_mode,
	
	input  wire read_request,
	input  wire [18:0] addr, // one bigger as these are 8 bit wide adresses while hardware is 16 bit
	
	input  wire write_request,
	input  wire [31:0] write_data,
	
	output reg [31:0] data_out,
	output reg finished,
	
	output reg busy,
	
	output wire [3:0] TEST_EXPOSE_STATE
);
	reg writing = 0;
	reg [15:0] write_halfword = 0;
	assign interface_data = writing ? write_halfword : 16'bz;

	// two 16-bit accseses for 32 bits
	// three if odd number memory access (unaligned)
	// states
	localparam IDLE   = 4'd0;
	
	// read
	localparam READ1  = 4'd1;
	localparam READ2  = 4'd2;
	
	localparam UNALIGNED_READ1 = 4'd3;
	localparam UNALIGNED_READ2 = 4'd4;
	localparam UNALIGNED_READ3 = 4'd5;
	
	localparam READ_BYTE_LOWER = 4'd6;
	localparam READ_BYTE_UPPER = 4'd7;
	
	// writes
	localparam WRITE1 = 4'd8;
	localparam WRITE2 = 4'd9;
	
	localparam UNALIGNED_WRITE1 = 4'd10;
	localparam UNALIGNED_WRITE2 = 4'd11;
	localparam UNALIGNED_WRITE3 = 4'd12;
	
	localparam WRITE_BYTE_LOWER = 4'd13;
	localparam WRITE_BYTE_UPPER = 4'd14;
	
	// FSM
	reg [3:0] state = IDLE;
	reg [3:0] next_state = IDLE;
	assign TEST_EXPOSE_STATE = state;
	
	always @(*) begin
		next_state = state;
		
		case (state)
			IDLE: begin
				// reads
				if (read_request) begin
					if (addr[0] == 0 && byte_mode)
						next_state = READ_BYTE_UPPER;
					else if (addr[0] == 0)
						next_state = READ1;
					// unaligned
					else if (byte_mode)
						next_state = READ_BYTE_LOWER;
					else
						next_state = UNALIGNED_READ1;
        end
						
				else if (write_request) begin
					if (addr[0] == 0 && byte_mode)
						next_state = WRITE_BYTE_UPPER;
					else if (addr[0] == 0)
						next_state = WRITE1;
					// unaligned
					else if (byte_mode)
						next_state = WRITE_BYTE_LOWER;
					else
						next_state = UNALIGNED_WRITE1;
        end
			end
			
			// reads
			READ1: 
				next_state = READ2;
			READ2:
				next_state = IDLE;
				
			UNALIGNED_READ1:
				next_state = UNALIGNED_READ2;
			UNALIGNED_READ2:
				next_state = UNALIGNED_READ3;
			UNALIGNED_READ3:
				next_state = IDLE;
				
			READ_BYTE_LOWER, READ_BYTE_UPPER:
				next_state = IDLE;
			
			// writes
			WRITE1:
				next_state = WRITE2;
			WRITE2:
				next_state = IDLE;
				
			UNALIGNED_WRITE1:
				next_state = UNALIGNED_WRITE2;
			UNALIGNED_WRITE2:
				next_state = UNALIGNED_WRITE3;
			UNALIGNED_WRITE3:
				next_state = IDLE;
				
			WRITE_BYTE_LOWER, WRITE_BYTE_UPPER:
				next_state = IDLE;
		endcase
	end
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			state <= IDLE;
			finished <= 0;
			data_out <= 0;
			busy <= 0;
			interface_addr <= 0;
			
			interface_output_enable_n <= 1;
			interface_write_enable_n  <= 1;

			interface_lower_byte_mask_n <= 1;
			interface_upper_byte_mask_n <= 1;
		end else begin
			// FSM transitions
			if (next_state != state) begin			
        // finish read/write
        if (next_state == IDLE) begin 
          busy <= 0;
          finished <= 1;
          writing <= 0;

          interface_output_enable_n <= 0;
          interface_write_enable_n  <= 1;

          interface_lower_byte_mask_n <= 0;
          interface_upper_byte_mask_n <= 0;
        end

				case (state)
					IDLE: begin
						// prep read/write
						interface_addr <= addr[18:1];
						busy <= 1;
						finished <= 0;
						
            // reads
            if (next_state == READ1 ||
                next_state == UNALIGNED_READ1 ||
                next_state == READ_BYTE_LOWER ||
                next_state == READ_BYTE_UPPER) begin

							writing <= 0;
							interface_output_enable_n <= 0;
							interface_write_enable_n  <= 1;

              if (next_state == READ1) begin
                interface_lower_byte_mask_n <= 0;
                interface_upper_byte_mask_n <= 0;
              end

              else if (next_state == UNALIGNED_READ1 ||
                      next_state == READ_BYTE_LOWER) begin
                interface_lower_byte_mask_n <= 0;
                interface_upper_byte_mask_n <= 1;
              end

              else if (next_state == READ_BYTE_UPPER) begin
                interface_lower_byte_mask_n <= 1;
                interface_upper_byte_mask_n <= 0;
              end
            end

            // writes
            else if (next_state == WRITE1 ||
                     next_state == UNALIGNED_WRITE1 ||
                     next_state == WRITE_BYTE_LOWER ||
                     next_state == WRITE_BYTE_UPPER) begin
							interface_addr <= addr[18:1];		 
								
              writing <= 1;

              interface_output_enable_n <= 1;
              interface_write_enable_n  <= 0;

              if (next_state == WRITE1) begin
                interface_lower_byte_mask_n <= 0;
                interface_upper_byte_mask_n <= 0;

                write_halfword <= write_data[31:16];
              end

              else if (next_state == UNALIGNED_WRITE1) begin
                interface_lower_byte_mask_n <= 0;
                interface_upper_byte_mask_n <= 1;

                write_halfword[15:8] <= 8'bz;
                write_halfword[7:0]  <= write_data[31:24];
              end

              else if (next_state == WRITE_BYTE_LOWER) begin
                interface_lower_byte_mask_n <= 0;
                interface_upper_byte_mask_n <= 1;

                write_halfword[15:8] <= 8'bZ;
                write_halfword[7:0]  <= write_data[7:0];
              end

              else if (next_state == WRITE_BYTE_UPPER) begin
                interface_lower_byte_mask_n <= 1;
                interface_upper_byte_mask_n <= 0;

                write_halfword[15:8] <= write_data[7:0];
                write_halfword[7:0]  <= 8'bZ;
              end
            end
					end

          // reads	
          READ1: begin 
            data_out[31:16] <= interface_data;
            interface_addr <= addr[18:1] + 1;
          end
          READ2: begin
            data_out[15:0] <= interface_data;
          end

          UNALIGNED_READ1: begin
						data_out[31:24] <= interface_data[7:0];
						interface_addr <= addr[18:1] + 1;

            interface_lower_byte_mask_n <= 0;
            interface_upper_byte_mask_n <= 0;
					end
          UNALIGNED_READ2: begin
						data_out[23:8] <= interface_data;
						interface_addr <= addr[18:1] + 2;

            interface_lower_byte_mask_n <= 1;
            interface_upper_byte_mask_n <= 0;
          end
          UNALIGNED_READ3: begin
						data_out[7:0] <= interface_data[15:8];
          end

          READ_BYTE_UPPER:
						data_out[7:0] <= interface_data[15:8];
          READ_BYTE_LOWER:
            data_out[7:0] <= interface_data[7:0];

          // writes
					WRITE1: begin
						write_halfword <= write_data[15:0];
						interface_addr <= addr[18:1] + 1;
					end
					WRITE2: begin end

          UNALIGNED_WRITE1: begin
            write_halfword <= write_data[23:8];
						interface_addr <= addr[18:1] + 1;

            interface_lower_byte_mask_n <= 0;
            interface_upper_byte_mask_n <= 0;
					end
          UNALIGNED_WRITE2: begin
						interface_addr <= addr[18:1] + 2;
            write_halfword[15:8] <= write_data[7:0];

            interface_lower_byte_mask_n <= 1;
            interface_upper_byte_mask_n <= 0;
          end
          UNALIGNED_WRITE3: begin end

          WRITE_BYTE_UPPER: begin end

          WRITE_BYTE_LOWER: begin end
				endcase
			end
			
			state <= next_state;
		end
	end
endmodule


/*
	// four 8-bit accseses for 32 bits
	reg [1:0] current_byte;
	assign interface_addr = addr + current_byte;
	
	// each 8-bit access takes <=90ns, at 50MHz this needs 5 cycles
	reg [3:0] delay_counter;
	
	initial begin
		current_byte  = 0;
		delay_counter = 0;
	end

	always @(posedge clk) begin
		if (read_request & !busy) begin
			delay_counter <= 0;
			finished <= 0;
			current_byte <= 0;
		end
		// continue loading data
		else if (busy) begin
			// finish loading byte
			if (delay_counter == 5) begin
				case (current_byte)
					2'b00: data[31:24] <= interface_data;
					2'b01: data[23:16] <= interface_data;
					2'b10: data[15:8]  <= interface_data;
					2'b11: data[7:0]   <= interface_data;
				endcase
				
				delay_counter = 0;
				current_byte = current_byte + 1;
			end
			// wait for data to be ready
			else
				delay_counter = delay_counter + 1;
		end
	end
*/