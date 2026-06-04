library verilog;
use verilog.vl_types.all;
entity display_32bit_7seg is
    port(
        num             : in     vl_logic_vector(31 downto 0);
        hex0            : out    vl_logic_vector(6 downto 0);
        hex1            : out    vl_logic_vector(6 downto 0);
        hex2            : out    vl_logic_vector(6 downto 0);
        hex3            : out    vl_logic_vector(6 downto 0);
        upper_sel       : in     vl_logic
    );
end display_32bit_7seg;
