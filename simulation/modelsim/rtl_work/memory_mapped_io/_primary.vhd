library verilog;
use verilog.vl_types.all;
entity memory_mapped_io is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        read_request    : in     vl_logic;
        write_request   : in     vl_logic;
        addr            : in     vl_logic_vector(31 downto 0);
        data_in         : in     vl_logic_vector(31 downto 0);
        data_out        : out    vl_logic_vector(31 downto 0);
        finished        : out    vl_logic;
        busy            : out    vl_logic;
        LEDR            : out    vl_logic_vector(9 downto 0);
        vga_pen_x       : out    vl_logic_vector(7 downto 0);
        vga_pen_y       : out    vl_logic_vector(7 downto 0);
        vga_pen_color   : out    vl_logic_vector(7 downto 0);
        vga_pen_draw    : out    vl_logic
    );
end memory_mapped_io;
