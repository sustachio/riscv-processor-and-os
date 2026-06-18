library verilog;
use verilog.vl_types.all;
entity memory_controller is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        write_request   : in     vl_logic;
        read_request    : in     vl_logic;
        byte_mode       : in     vl_logic;
        addr_in         : in     vl_logic_vector(31 downto 0);
        data_in         : in     vl_logic_vector(31 downto 0);
        data_out        : out    vl_logic_vector(31 downto 0);
        busy            : out    vl_logic;
        finished        : out    vl_logic;
        FL_ADDR         : out    vl_logic_vector(21 downto 0);
        FL_DQ           : in     vl_logic_vector(7 downto 0);
        FL_OE_N         : out    vl_logic;
        FL_RST_N        : out    vl_logic;
        FL_WE_N         : out    vl_logic;
        SRAM_ADDR       : out    vl_logic_vector(17 downto 0);
        SRAM_DQ         : inout  vl_logic_vector(15 downto 0);
        SRAM_WE_N       : out    vl_logic;
        SRAM_OE_N       : out    vl_logic;
        SRAM_UB_N       : out    vl_logic;
        SRAM_LB_N       : out    vl_logic;
        SRAM_CE_N       : out    vl_logic;
        LEDR            : out    vl_logic_vector(9 downto 0);
        vga_pen_x       : out    vl_logic_vector(7 downto 0);
        vga_pen_y       : out    vl_logic_vector(7 downto 0);
        vga_pen_color   : out    vl_logic_vector(7 downto 0);
        vga_pen_draw    : out    vl_logic;
        ps2_get_key     : out    vl_logic_vector(6 downto 0);
        ps2_key_pressed : in     vl_logic
    );
end memory_controller;
