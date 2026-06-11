library verilog;
use verilog.vl_types.all;
entity memory_multiplexer is
    port(
        rst_n           : in     vl_logic;
        processor_state : in     vl_logic_vector(2 downto 0);
        fetch_read_request: in     vl_logic;
        fetch_addr      : in     vl_logic_vector(31 downto 0);
        fetch_result    : out    vl_logic_vector(31 downto 0);
        mem_access_read_request: in     vl_logic;
        mem_access_write_request: in     vl_logic;
        mem_access_addr : in     vl_logic_vector(31 downto 0);
        mem_access_data_in: in     vl_logic_vector(31 downto 0);
        mem_access_byte_mode: in     vl_logic;
        mem_access_data_out: out    vl_logic_vector(31 downto 0);
        finished        : out    vl_logic;
        memory_read_request: out    vl_logic;
        memory_write_request: out    vl_logic;
        memory_byte_mode: out    vl_logic;
        memory_addr     : out    vl_logic_vector(31 downto 0);
        memory_data_in  : out    vl_logic_vector(31 downto 0);
        memory_data_out : in     vl_logic_vector(31 downto 0);
        memory_finished : in     vl_logic
    );
end memory_multiplexer;
