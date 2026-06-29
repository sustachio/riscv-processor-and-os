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
			if (read_request & byte_mode)
        next_state = READ_BYTE;
      else if (read_request)
				next_state = READ1;
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
					
				default: begin end // already assigned above
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
						interface_addr <= addr[21:0] + 22'd1;
					end
					READ2: begin
						data[23:16] <= interface_data;
						interface_addr <= addr[21:0] + 22'd2;
					end
					READ3: begin
						data[15:8]  <= interface_data;
						interface_addr <= addr[21:0] + 22'd3;
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
				delay_counter <= delay_counter + 4'd1;
			
			state <= next_state;
		end
	end
endmodule
