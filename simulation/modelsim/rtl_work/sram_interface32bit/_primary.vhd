library verilog;
use verilog.vl_types.all;
entity sram_interface32bit is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        interface_addr  : out    vl_logic_vector(17 downto 0);
        interface_data  : inout  vl_logic_vector(15 downto 0);
        interface_upper_byte_mask_n: out    vl_logic;
        interface_lower_byte_mask_n: out    vl_logic;
        interface_output_enable_n: out    vl_logic;
        interface_write_enable_n: out    vl_logic;
        byte_mode       : in     vl_logic;
        read_request    : in     vl_logic;
        addr            : in     vl_logic_vector(18 downto 0);
        write_request   : in     vl_logic;
        write_data      : in     vl_logic_vector(31 downto 0);
        data_out        : out    vl_logic_vector(31 downto 0);
        finished        : out    vl_logic;
        busy            : out    vl_logic;
        TEST_EXPOSE_STATE: out    vl_logic_vector(3 downto 0)
    );
end sram_interface32bit;
