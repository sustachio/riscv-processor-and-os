library verilog;
use verilog.vl_types.all;
entity flash_interface32bit is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        interface_addr  : out    vl_logic_vector(21 downto 0);
        interface_data  : in     vl_logic_vector(7 downto 0);
        byte_mode       : in     vl_logic;
        read_request    : in     vl_logic;
        addr            : in     vl_logic_vector(21 downto 0);
        data            : out    vl_logic_vector(31 downto 0);
        finished        : out    vl_logic;
        busy            : out    vl_logic
    );
end flash_interface32bit;
