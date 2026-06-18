// instruction types
`define OP_LUI 0
`define OP_AUIPC 1
`define OP_ADDI 2
`define OP_SLTI 3
`define OP_SLTIU 4
`define OP_XORI 5
`define OP_ORI 6
`define OP_ANDI 7
`define OP_SLLI 8
`define OP_SRLI 9
`define OP_SRAI 10
`define OP_ADD 11
`define OP_SUB 12
`define OP_SLL 13
`define OP_SLT 14
`define OP_SLTU 15
`define OP_XOR 16
`define OP_SRL 17
`define OP_SRA 18
`define OP_OR 19
`define OP_AND 20
`define OP_FENCE 21
`define OP_ECALL 22
`define OP_EBREAK 23
`define OP_LB 24
`define OP_LH 25
`define OP_LW 26
`define OP_LBU 27
`define OP_LHU 28
`define OP_SB 29
`define OP_SH 30
`define OP_SW 31
`define OP_JAL 32
`define OP_JALR 33
`define OP_BEQ 34
`define OP_BNE 35
`define OP_BLT 36
`define OP_BGE 37
`define OP_BLTU 38
`define OP_BGEU 39
`define OP_ILLEGAL 40

// processor_state
`define START_FETCH 0
`define FETCH 1
`define START_MEM 2
`define MEM_ACCESS 3
`define WRITEBACK 4

////////// KEYS //////////
// compiled from http://www.technoblogy.com/show?4QEL, thank you internet site! :3
// row 0
`define KEY_CODE_ESC 8'h76 // (F0 76)
`define KEY_ESC 0
`define KEY_CODE_F1 8'h05 // (F0 05)
`define KEY_F1 1
`define KEY_CODE_F2 8'h06 // (F0 06)
`define KEY_F2 2
`define KEY_CODE_F3 8'h04 // (F0 04)
`define KEY_F3 3
`define KEY_CODE_F4 8'h0C // (F0 0C)
`define KEY_F4 4
`define KEY_CODE_F5 8'h03 // (F0 03)
`define KEY_F5 5
`define KEY_CODE_F6 8'h0B // (F0 0B)
`define KEY_F6 6
`define KEY_CODE_F7 8'h83 // (F0 83)
`define KEY_F7 7
`define KEY_CODE_F8 8'h0A // (F0 0A)
`define KEY_F8 8
`define KEY_CODE_F9 8'h01 // (F0 01)
`define KEY_F9 9
`define KEY_CODE_F10 8'h09 // (F0 09)
`define KEY_F10 10
`define KEY_CODE_F11 8'h78 // (F0 78)
`define KEY_F11 11
`define KEY_CODE_F12 8'h07 // (F0 07)
`define KEY_F12 12

// row 1
`define KEY_CODE_BACKTICK 8'h0E // (F0 0E) (this is `)
`define KEY_BACKTICK 13
`define KEY_CODE_1 8'h16 // (F0 16)
`define KEY_1 14
`define KEY_CODE_2 8'h1E // (F0 1E)
`define KEY_2 15
`define KEY_CODE_3 8'h26 // (F0 26)
`define KEY_3 16
`define KEY_CODE_4 8'h25 // (F0 25)
`define KEY_4 17
`define KEY_CODE_5 8'h2E // (F0 2E)
`define KEY_5 18
`define KEY_CODE_6 8'h36 // (F0 36)
`define KEY_6 19
`define KEY_CODE_7 8'h3D // (F0 3D)
`define KEY_7 20
`define KEY_CODE_8 8'h3E // (F0 3E)
`define KEY_8 21
`define KEY_CODE_9 8'h46 // (F0 46)
`define KEY_9 22
`define KEY_CODE_0 8'h45 // (F0 45)
`define KEY_0 23
`define KEY_CODE_MINUS 8'h4E // (F0 4E)
`define KEY_MINUS	24
`define KEY_CODE_EQUALS 8'h55 // (F0 55)
`define KEY_EQUALS 25
`define KEY_CODE_BACKSPACE 8'h66 // (F0 66)
`define KEY_BACKSPACE 26

// row 2
`define KEY_CODE_TAB 8'h0D // (F0 0D)
`define KEY_TAB 27
`define KEY_CODE_Q 8'h15 // (F0 15)
`define KEY_Q 28
`define KEY_CODE_W 8'h1D // (F0 1D)
`define KEY_W 29
`define KEY_CODE_E 8'h24 // (F0 24)
`define KEY_E 30
`define KEY_CODE_R 8'h2D // (F0 2D)
`define KEY_R 31
`define KEY_CODE_T 8'h2C // (F0 2C)
`define KEY_T 32
`define KEY_CODE_Y 8'h35 // (F0 35)
`define KEY_Y 33
`define KEY_CODE_U 8'h3C // (F0 3C)
`define KEY_U 34
`define KEY_CODE_I 8'h43 // (F0 43)
`define KEY_I 35
`define KEY_CODE_O 8'h44 // (F0 44)
`define KEY_O 36
`define KEY_CODE_P 8'h4D // (F0 4D)
`define KEY_P 37
`define KEY_CODE_OPEN_BRACKET 8'h54 // (F0 54) (this is [)
`define KEY_OPEN_BRACKET 38
`define KEY_CODE_CLOSED_BRACKET 8'h5B // (F0 5B) ( this is ])
`define KEY_CLOSED_BRACKET 39
`define KEY_CODE_BACKSLASH 8'h5D // (F0 5D) (this is \)
`define KEY_BACKSLASH 40

// row 3
`define KEY_CODE_CAPS_LOCK 8'h58 // (F0 58)
`define KEY_CAPS_LOCK 41
`define KEY_CODE_A 8'h1C // (F0 1C)
`define KEY_A 42
`define KEY_CODE_S 8'h1B // (F0 1B)
`define KEY_S 43
`define KEY_CODE_D 8'h23 // (F0 23)
`define KEY_D 44
`define KEY_CODE_F 8'h2B // (F0 2B)
`define KEY_F 45
`define KEY_CODE_G 8'h34 // (F0 34)
`define KEY_G 46
`define KEY_CODE_H 8'h33 // (F0 33)
`define KEY_H 47
`define KEY_CODE_J 8'h3B // (F0 3B)
`define KEY_J 48
`define KEY_CODE_K 8'h42 // (F0 42)
`define KEY_K 49
`define KEY_CODE_L 8'h4B // (F0 4B)
`define KEY_L 50
`define KEY_CODE_SEMICOLON 8'h4C // (F0 4C)
`define KEY_SEMICOLON 51
`define KEY_CODE_SINGLE_QUOTE 8'h52 // (F0 52)
`define KEY_SINGLE_QUOTE 52
`define KEY_CODE_ENTER 8'h5A // (F0 5A)
`define KEY_ENTER 53

// row 4
`define KEY_CODE_LEFT_SHIFT 8'h12 // (F0 12)
`define KEY_LEFT_SHIFT 54
`define KEY_CODE_Z 8'h1A // (F0 1A)
`define KEY_Z 55
`define KEY_CODE_X 8'h22 // (F0 22)
`define KEY_X 56
`define KEY_CODE_C 8'h21 // (F0 21)
`define KEY_C 57
`define KEY_CODE_V 8'h2A // (F0 2A)
`define KEY_V 58
`define KEY_CODE_B 8'h32 // (F0 32)
`define KEY_B 59
`define KEY_CODE_N 8'h31 // (F0 31)
`define KEY_N 60
`define KEY_CODE_M 8'h3A // (F0 3A)
`define KEY_M 61
`define KEY_CODE_COMMA 8'h41 // (F0 41)
`define KEY_COMMA 62
`define KEY_CODE_PERIOD 8'h49 // (F0 49)
`define KEY_PERIOD 63
`define KEY_CODE_SLASH 8'h4A // (F0 4A) (this is /)
`define KEY_SLASH 64
`define KEY_CODE_RIGHT_SHIFT 8'h59 // (F0 59)
`define KEY_RIGHT_SHIFT 65

// row 5
`define KEY_CODE_LEFT_CONTROL 8'h14 // (F0 14)
`define KEY_LEFT_CONTROL 66
`define KEY_CODE_LEFT_WINDOWS_EXTENDED 8'h1F // E0 1F (E0 F0 1F)
`define KEY_LEFT_WINDOWS 67
`define KEY_CODE_LEFT_ALT 8'h11 // (F0 11)
`define KEY_LEFT_ALT 68
`define KEY_CODE_SPACE 8'h29 // (F0 29)
`define KEY_SPACE 69
`define KEY_CODE_RIGHT_ALT_EXTENDED 8'h11 // E0 11 (E0 F0 11)
`define KEY_RIGHT_ALT 70
`define KEY_CODE_RIGHT_WINDOWS_EXTENDED 8'h27 // E0 27 (E0 F0 27)
`define KEY_RIGHT_WINDOWS 71
`define KEY_CODE_MENUS_EXTENDED 8'h2F // E0 2F (E0 F0 2F)
`define KEY_MENUS 72
`define KEY_CODE_RIGHT_CONTROL_EXTENDED 8'h14 // E0 14 (E0 F0 14)
`define KEY_RIGHT_CONTROL 73
`define KEY_CODE_INSERT_EXTENDED 8'h70 // E0 70 (E0 F0 70)
`define KEY_INSERT 74
`define KEY_CODE_HOME_EXTENDED 8'h6C // E0 6C (E0 F0 6C)
`define KEY_HOME 75
`define KEY_CODE_PAGE_UP_EXTENDED 8'h7D // E0 7D (E0 F0 7D)
`define KEY_PAGE_UP 76
`define KEY_CODE_DELETE_EXTENDED 8'h71 // E0 71 (E0 F0 71)
`define KEY_DELETE 77
`define KEY_CODE_END_EXTENDED 8'h69 // E0 69 (E0 F0 69)
`define KEY_END 78
`define KEY_CODE_PAGE_DOWN_EXTENDED 8'h7A // E0 7A (E0 F0 7A)
`define KEY_PAGE_DOWN 79
`define KEY_CODE_UP_ARROW_EXTENDED 8'h75 // E0 75 (E0 F0 75)
`define KEY_UP_ARROW 80
`define KEY_CODE_LEFT_ARROW_EXTENDED 8'h6B // E0 6B (E0 F0 6B)
`define KEY_LEFT_ARROW 81
`define KEY_CODE_DOWN_ARROW_EXTENDED 8'h72 // E0 72 (E0 F0 72)
`define KEY_DOWN_ARROW 82
`define KEY_CODE_RIGHT_ARROW_EXTENDED 8'h74 // E0 74 (E0 F0 74)
`define KEY_RIGHT_ARROW 83
`define KEY_CODE_NUM_LOCK 8'h77 // (F0 77)
`define KEY_NUM_LOCK 84

// keypad
`define KEY_CODE_KEY_PAD_SLASH_EXTENDED 8'h4A // E0 4A (E0 F0 4A)
`define KEY_KEY_PAD_SLASH 85
`define KEY_CODE_KEY_PAD_STAR 8'h7C // (F0 7C)
`define KEY_KEY_PAD_STAR 86
`define KEY_CODE_KEY_PAD_MINUS 8'h7B // (F0 7B)
`define KEY_KEY_PAD_MINUS 87
`define KEY_CODE_KEY_PAD_7 8'h6C // (F0 6C)
`define KEY_KEY_PAD_7 88
`define KEY_CODE_KEY_PAD_8 8'h75 // (F0 75)
`define KEY_KEY_PAD_8 89
`define KEY_CODE_KEY_PAD_9 8'h7D // (F0 7D)
`define KEY_KEY_PAD_9 90
`define KEY_CODE_KEY_PAD_PLUS 8'h79 // (F0 79)
`define KEY_KEY_PAD_PLUS 91
`define KEY_CODE_KEY_PAD_4 8'h6B // (F0 6B)
`define KEY_KEY_PAD_4 92
`define KEY_CODE_KEY_PAD_5 8'h73 // (F0 73)
`define KEY_KEY_PAD_5 93
`define KEY_CODE_KEY_PAD_6 8'h74 // (F0 74)
`define KEY_KEY_PAD_6 94
`define KEY_CODE_KEY_PAD_1 8'h69 // (F0 69)
`define KEY_KEY_PAD_1 95
`define KEY_CODE_KEY_PAD_2 8'h72 // (F0 72)
`define KEY_KEY_PAD_2 96
`define KEY_CODE_KEY_PAD_3 8'h7A // (F0 7A)
`define KEY_KEY_PAD_3 97
`define KEY_CODE_KEY_PAD_0 8'h70 // (F0 70)
`define KEY_KEY_PAD_0 98
`define KEY_CODE_KEY_PAD_PERIOD 8'h71 // (F0 71)
`define KEY_KEY_PAD_PERIOD 99
`define KEY_CODE_KEY_PAD_ENTER_EXTENDED 8'h5A // E0 5A (E0 F0 5A)
`define KEY_KEY_PAD_ENTER 100

// also row 0
//`define KEY_Prt Scr	// E0 12 E0 7C (E0 F0 7C E0 F0 12)
`define KEY_CODE_PRINT_SCREEN_EXTENDED 8'h12	// really E0 12 E0 7C (E0 F0 7C E0 F0 12)
`define KEY_PRINT_SCREEN 101
`define KEY_CODE_SCROLL_LOCK 8'h7E // (F0 7E)
`define KEY_SCROLL_LOCK 102
// Pause/Break im not doing this one E1 14 77 E1 F0 14 E0 77 (None)
