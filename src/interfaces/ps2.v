`include "global_constants.vh"

`define KEY_CODE_RELEASE 8'hF0
`define KEY_CODE_EXTENDED 8'hE0

module ps2_interface(
	input clk,
	input rst_n,

  input [6:0] get_key,
  output reg key_pressed,
	
  // pins
  input PS2_CLK,
  input PS2_DAT
);
  reg keys [0:103]; // 1 if pressed

  // states
  localparam WAIT_READ_BYTE1 = 0;
  localparam READ_BYTE1 = 1; // E0 | F0 | __

  localparam WAIT_READ_STOP_BYTE2 = 2; // F0 __
  localparam READ_STOP_BYTE2 = 3; // F0 __

  localparam WRITEKEY = 4;

  /*
  localparam WAIT_READ_EXTENDED_BYTE2 = 4;
  localparam READ_EXTENDED_BYTE2 = 5; // E0 __ | E0 F0

  localparam WAIT_READ_EXTENDED_STOP_BYTE3 = 6; // E0 F0 __
  localparam READ_EXTENDED_STOP_BYTE3 = 7; // E0 F0 __
  */

  // updated on posedge PS2_CLK
  reg [2:0] state = 0;
  reg [2:0] next_state = 0;
  reg extended = 0;
  reg next_extended = 0;
  reg releasing = 0;
  reg next_releasing = 0;

  // force state change to WAIT_READ_BYTE1 after 83 ms of inactivity to avoid getting stuck in other states
  reg [22:0] reset_counter = 0;

                                    // 0 1 2 3 4 5 6 7 8      9
  reg [3:0] current_read_bit_i = 0; // 0 1 2 3 4 5 6 7 pairty stop
  reg [7:0] last_byte = 0;
  reg [6:0] current_key;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      reset_counter <= 0;
    else if (state == WAIT_READ_BYTE1)
      reset_counter <= 0;
    else if (reset_counter[22] != 1'b1)
      reset_counter <= reset_counter + 1;
  end

  always @(*) begin
    if (!rst_n)
      next_state = WAIT_READ_BYTE1;
    else begin
      key_pressed = keys[get_key];

      next_state = state;
      next_extended = extended;
      next_releasing = releasing;

      case (state)
        WAIT_READ_BYTE1: begin
          if (!PS2_DAT)
            next_state = READ_BYTE1;
        end

        WAIT_READ_STOP_BYTE2: begin
          if (!PS2_DAT)
            next_state = READ_STOP_BYTE2;
        end

        READ_BYTE1: begin
          if (current_read_bit_i == 8) begin
            if (extended) case (last_byte)
              `KEY_CODE_PRINT_SCREEN_EXTENDED, `KEY_CODE_KEY_PAD_ENTER_EXTENDED, `KEY_CODE_KEY_PAD_SLASH_EXTENDED, `KEY_CODE_RIGHT_ALT_EXTENDED, `KEY_CODE_RIGHT_WINDOWS_EXTENDED, `KEY_CODE_MENUS_EXTENDED, `KEY_CODE_RIGHT_CONTROL_EXTENDED, `KEY_CODE_INSERT_EXTENDED, `KEY_CODE_HOME_EXTENDED, `KEY_CODE_PAGE_UP_EXTENDED, `KEY_CODE_DELETE_EXTENDED, `KEY_CODE_END_EXTENDED, `KEY_CODE_PAGE_DOWN_EXTENDED, `KEY_CODE_UP_ARROW_EXTENDED, `KEY_CODE_LEFT_ARROW_EXTENDED, `KEY_CODE_DOWN_ARROW_EXTENDED, `KEY_CODE_RIGHT_ARROW_EXTENDED, `KEY_CODE_LEFT_WINDOWS_EXTENDED: begin
                next_state = WRITEKEY;
              end

              `KEY_CODE_RELEASE: begin
                next_state = WAIT_READ_STOP_BYTE2;
                next_releasing = 1;
              end

              default: begin
                next_state = WAIT_READ_BYTE1;
                next_extended = 0;
                next_releasing = 0;
              end
            endcase
            else case (last_byte)
              `KEY_CODE_ESC, `KEY_CODE_F1, `KEY_CODE_F2, `KEY_CODE_F3, `KEY_CODE_F4, `KEY_CODE_F5, `KEY_CODE_F6, `KEY_CODE_F7, `KEY_CODE_F8, `KEY_CODE_F9, `KEY_CODE_F10, `KEY_CODE_F11, `KEY_CODE_F12, `KEY_CODE_SCROLL_LOCK, `KEY_CODE_BACKTICK, `KEY_CODE_1, `KEY_CODE_2, `KEY_CODE_3, `KEY_CODE_4, `KEY_CODE_5, `KEY_CODE_6, `KEY_CODE_7, `KEY_CODE_8, `KEY_CODE_9, `KEY_CODE_0, `KEY_CODE_MINUS, `KEY_CODE_EQUALS, `KEY_CODE_BACKSPACE, `KEY_CODE_TAB, `KEY_CODE_Q, `KEY_CODE_W, `KEY_CODE_E, `KEY_CODE_R, `KEY_CODE_T, `KEY_CODE_Y, `KEY_CODE_U, `KEY_CODE_I, `KEY_CODE_O, `KEY_CODE_P, `KEY_CODE_OPEN_BRACKET, `KEY_CODE_CLOSED_BRACKET, `KEY_CODE_BACKSLASH, `KEY_CODE_CAPS_LOCK, `KEY_CODE_A, `KEY_CODE_S, `KEY_CODE_D, `KEY_CODE_F, `KEY_CODE_G, `KEY_CODE_H, `KEY_CODE_J, `KEY_CODE_K, `KEY_CODE_L, `KEY_CODE_SEMICOLON, `KEY_CODE_SINGLE_QUOTE, `KEY_CODE_ENTER, `KEY_CODE_LEFT_SHIFT, `KEY_CODE_Z, `KEY_CODE_X, `KEY_CODE_C, `KEY_CODE_V, `KEY_CODE_B, `KEY_CODE_N, `KEY_CODE_M, `KEY_CODE_COMMA, `KEY_CODE_PERIOD, `KEY_CODE_SLASH, `KEY_CODE_RIGHT_SHIFT, `KEY_CODE_LEFT_CONTROL, `KEY_CODE_LEFT_ALT, `KEY_CODE_SPACE, `KEY_CODE_NUM_LOCK, `KEY_CODE_KEY_PAD_STAR, `KEY_CODE_KEY_PAD_MINUS, `KEY_CODE_KEY_PAD_7, `KEY_CODE_KEY_PAD_8, `KEY_CODE_KEY_PAD_9, `KEY_CODE_KEY_PAD_PLUS, `KEY_CODE_KEY_PAD_4, `KEY_CODE_KEY_PAD_5, `KEY_CODE_KEY_PAD_6, `KEY_CODE_KEY_PAD_1, `KEY_CODE_KEY_PAD_2, `KEY_CODE_KEY_PAD_3, `KEY_CODE_KEY_PAD_0, `KEY_CODE_KEY_PAD_PERIOD: begin
                next_state = WRITEKEY;
                next_extended = 0;
                next_releasing = 0;
              end

              `KEY_CODE_RELEASE: begin
                next_state = WAIT_READ_STOP_BYTE2;
                next_releasing = 1;
              end

              `KEY_CODE_EXTENDED: begin
                next_state = WAIT_READ_BYTE1;
                next_extended = 1;
              end

              default: begin
                next_state = WAIT_READ_BYTE1;
                next_extended = 0;
                next_releasing = 0;
              end
           endcase // last_byte
          end // current_byte == 9
        end // READ_BYTE_1

        READ_STOP_BYTE2: begin
          if (current_read_bit_i == 8) begin // 8 bc it needs that last cycle on 9 to exit write key
            next_state = WRITEKEY;
          end
        end

        WRITEKEY: begin
          next_state = WAIT_READ_BYTE1;
          next_extended = 0;
          next_releasing = 0;
        end
      endcase // state

      if (reset_counter[22] == 1'b1) begin
        next_state = WAIT_READ_BYTE1;
        next_extended = 0;
        next_releasing = 0;
      end
    end
  end

  always @(posedge PS2_CLK) begin
    if (!rst_n) begin
      state <= 0;
			releasing <= 0;
			extended <= 0;
    end else begin
			releasing <= next_releasing;
			extended <= next_extended;

      case (state)
        WAIT_READ_BYTE1, WAIT_READ_STOP_BYTE2: begin
          current_read_bit_i <= 0;
        end

        READ_BYTE1: begin
          if (current_read_bit_i < 8)
            last_byte[current_read_bit_i] <= PS2_DAT;

          current_read_bit_i <= current_read_bit_i + 4'd1;
        end

        READ_STOP_BYTE2: begin
          if (current_read_bit_i < 8)
            last_byte[current_read_bit_i] <= PS2_DAT;

          current_read_bit_i <= current_read_bit_i + 4'd1;
        end
 
        WRITEKEY: begin
          current_key = 7'd127; // corresponds to no key

          // thank you vim macros :rose:
          case (last_byte)
            `KEY_CODE_ESC: current_key = `KEY_ESC;
            `KEY_CODE_F1: current_key = `KEY_F1;
            `KEY_CODE_F2: current_key = `KEY_F2;
            `KEY_CODE_F3: current_key = `KEY_F3;
            `KEY_CODE_F4: current_key = `KEY_F4;
            `KEY_CODE_F5: current_key = `KEY_F5;
            `KEY_CODE_F6: current_key = `KEY_F6;
            `KEY_CODE_F7: current_key = `KEY_F7;
            `KEY_CODE_F8: current_key = `KEY_F8;
            `KEY_CODE_F9: current_key = `KEY_F9;
            `KEY_CODE_F10: current_key = `KEY_F10;
            `KEY_CODE_F11: current_key = `KEY_F11;
            `KEY_CODE_F12: current_key = `KEY_F12;
            `KEY_CODE_SCROLL_LOCK: current_key = `KEY_SCROLL_LOCK;
            `KEY_CODE_BACKTICK: current_key = `KEY_BACKTICK;
            `KEY_CODE_1: current_key = `KEY_1;
            `KEY_CODE_2: current_key = `KEY_2;
            `KEY_CODE_3: current_key = `KEY_3;
            `KEY_CODE_4: current_key = `KEY_4;
            `KEY_CODE_5: current_key = `KEY_5;
            `KEY_CODE_6: current_key = `KEY_6;
            `KEY_CODE_7: current_key = `KEY_7;
            `KEY_CODE_8: current_key = `KEY_8;
            `KEY_CODE_9: current_key = `KEY_9;
            `KEY_CODE_0: current_key = `KEY_0;
            `KEY_CODE_MINUS: current_key = `KEY_MINUS;
            `KEY_CODE_EQUALS: current_key = `KEY_EQUALS;
            `KEY_CODE_BACKSPACE: current_key = `KEY_BACKSPACE;
            `KEY_CODE_TAB: current_key = `KEY_TAB;
            `KEY_CODE_Q: current_key = `KEY_Q;
            `KEY_CODE_W: current_key = `KEY_W;
            `KEY_CODE_E: current_key = `KEY_E;
            `KEY_CODE_R: current_key = `KEY_R;
            `KEY_CODE_T: current_key = `KEY_T;
            `KEY_CODE_Y: current_key = `KEY_Y;
            `KEY_CODE_U: current_key = `KEY_U;
            `KEY_CODE_I: current_key = `KEY_I;
            `KEY_CODE_O: current_key = `KEY_O;
            `KEY_CODE_P: current_key = `KEY_P;
            `KEY_CODE_OPEN_BRACKET: current_key = `KEY_OPEN_BRACKET;
            `KEY_CODE_CLOSED_BRACKET: current_key = `KEY_CLOSED_BRACKET;
            `KEY_CODE_BACKSLASH: current_key = `KEY_BACKSLASH;
            `KEY_CODE_CAPS_LOCK: current_key = `KEY_CAPS_LOCK;
            `KEY_CODE_A: current_key = `KEY_A;
            `KEY_CODE_S: current_key = `KEY_S;
            `KEY_CODE_D: current_key = `KEY_D;
            `KEY_CODE_F: current_key = `KEY_F;
            `KEY_CODE_G: current_key = `KEY_G;
            `KEY_CODE_H: current_key = `KEY_H;
            `KEY_CODE_J: current_key = `KEY_J;
            `KEY_CODE_K: current_key = `KEY_K;
            `KEY_CODE_L: current_key = `KEY_L;
            `KEY_CODE_SEMICOLON: current_key = `KEY_SEMICOLON;
            `KEY_CODE_SINGLE_QUOTE: current_key = `KEY_SINGLE_QUOTE;
            `KEY_CODE_ENTER: current_key = `KEY_ENTER;
            `KEY_CODE_LEFT_SHIFT: current_key = `KEY_LEFT_SHIFT;
            `KEY_CODE_Z: current_key = `KEY_Z;
            `KEY_CODE_X: current_key = `KEY_X;
            `KEY_CODE_C: current_key = `KEY_C;
            `KEY_CODE_V: current_key = `KEY_V;
            `KEY_CODE_B: current_key = `KEY_B;
            `KEY_CODE_N: current_key = `KEY_N;
            `KEY_CODE_M: current_key = `KEY_M;
            `KEY_CODE_COMMA: current_key = `KEY_COMMA;
            `KEY_CODE_PERIOD: current_key = `KEY_PERIOD;
            `KEY_CODE_SLASH: current_key = `KEY_SLASH;
            `KEY_CODE_RIGHT_SHIFT: current_key = `KEY_RIGHT_SHIFT;
            `KEY_CODE_LEFT_CONTROL: current_key = `KEY_LEFT_CONTROL;
            `KEY_CODE_LEFT_ALT: current_key = `KEY_LEFT_ALT;
            `KEY_CODE_SPACE: current_key = `KEY_SPACE;
            `KEY_CODE_NUM_LOCK: current_key = `KEY_NUM_LOCK;
            `KEY_CODE_KEY_PAD_STAR: current_key = `KEY_KEY_PAD_STAR;
            `KEY_CODE_KEY_PAD_MINUS: current_key = `KEY_KEY_PAD_MINUS;
            `KEY_CODE_KEY_PAD_7: current_key = `KEY_KEY_PAD_7;
            `KEY_CODE_KEY_PAD_8: current_key = `KEY_KEY_PAD_8;
            `KEY_CODE_KEY_PAD_9: current_key = `KEY_KEY_PAD_9;
            `KEY_CODE_KEY_PAD_PLUS: current_key = `KEY_KEY_PAD_PLUS;
            `KEY_CODE_KEY_PAD_4: current_key = `KEY_KEY_PAD_4;
            `KEY_CODE_KEY_PAD_5: current_key = `KEY_KEY_PAD_5;
            `KEY_CODE_KEY_PAD_6: current_key = `KEY_KEY_PAD_6;
            `KEY_CODE_KEY_PAD_1: current_key = `KEY_KEY_PAD_1;
            `KEY_CODE_KEY_PAD_2: current_key = `KEY_KEY_PAD_2;
            `KEY_CODE_KEY_PAD_3: current_key = `KEY_KEY_PAD_3;
            `KEY_CODE_KEY_PAD_0: current_key = `KEY_KEY_PAD_0;
            `KEY_CODE_KEY_PAD_PERIOD: current_key = `KEY_KEY_PAD_PERIOD;
          endcase

          if (extended) case (last_byte)
            `KEY_CODE_PRINT_SCREEN_EXTENDED: current_key = `KEY_PRINT_SCREEN;
            `KEY_CODE_LEFT_WINDOWS_EXTENDED: current_key = `KEY_LEFT_WINDOWS;
            `KEY_CODE_RIGHT_ALT_EXTENDED: current_key = `KEY_RIGHT_ALT;
            `KEY_CODE_RIGHT_WINDOWS_EXTENDED: current_key = `KEY_RIGHT_WINDOWS;
            `KEY_CODE_MENUS_EXTENDED: current_key = `KEY_MENUS;
            `KEY_CODE_RIGHT_CONTROL_EXTENDED: current_key = `KEY_RIGHT_CONTROL;
            `KEY_CODE_INSERT_EXTENDED: current_key = `KEY_INSERT;
            `KEY_CODE_HOME_EXTENDED: current_key = `KEY_HOME;
            `KEY_CODE_PAGE_UP_EXTENDED: current_key = `KEY_PAGE_UP;
            `KEY_CODE_DELETE_EXTENDED: current_key = `KEY_DELETE;
            `KEY_CODE_END_EXTENDED: current_key = `KEY_END;
            `KEY_CODE_PAGE_DOWN_EXTENDED: current_key = `KEY_PAGE_DOWN;
            `KEY_CODE_UP_ARROW_EXTENDED: current_key = `KEY_UP_ARROW;
            `KEY_CODE_LEFT_ARROW_EXTENDED: current_key = `KEY_LEFT_ARROW;
            `KEY_CODE_DOWN_ARROW_EXTENDED: current_key = `KEY_DOWN_ARROW;
            `KEY_CODE_RIGHT_ARROW_EXTENDED: current_key = `KEY_RIGHT_ARROW;
            `KEY_CODE_KEY_PAD_ENTER_EXTENDED: current_key = `KEY_KEY_PAD_ENTER;
            `KEY_CODE_KEY_PAD_SLASH_EXTENDED: current_key = `KEY_KEY_PAD_SLASH;
          endcase

          if (current_key != 7'd127) begin
            keys[current_key] <= ~releasing;
          end
        end
      endcase

      state <= next_state;
    end
  end
endmodule