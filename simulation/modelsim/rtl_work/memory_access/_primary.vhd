library verilog;
use verilog.vl_types.all;
entity memory_access is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        processor_state : in     vl_logic_vector(2 downto 0);
        op              : in     vl_logic_vector(5 downto 0);
        write_data      : in     vl_logic_vector(31 downto 0);
        execute_result  : in     vl_logic_vector(31 downto 0);
        read_res        : out    vl_logic_vector(31 downto 0);
        mem_access_read_request: out    vl_logic;
        mem_access_write_request: out    vl_logic;
        mem_access_addr : out    vl_logic_vector(31 downto 0);
        mem_access_data : out    vl_logic_vector(31 downto 0);
        mem_access_byte_mode: out    vl_logic;
        mem_access_result: in     vl_logic_vector(31 downto 0);
        mem_access_finished: in     vl_logic;
        mem_access_busy : in     vl_logic
    );
end memory_access;
