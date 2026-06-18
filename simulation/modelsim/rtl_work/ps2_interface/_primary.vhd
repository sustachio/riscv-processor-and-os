library verilog;
use verilog.vl_types.all;
entity ps2_interface is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        get_key         : in     vl_logic_vector(6 downto 0);
        key_pressed     : out    vl_logic;
        PS2_CLK         : in     vl_logic;
        PS2_DAT         : in     vl_logic
    );
end ps2_interface;
