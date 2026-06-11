library verilog;
use verilog.vl_types.all;
entity instruction_fetch_and_pc is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        processor_state : in     vl_logic_vector(2 downto 0);
        next_pc         : in     vl_logic_vector(31 downto 0);
        pc              : out    vl_logic_vector(31 downto 0);
        instruction32   : out    vl_logic_vector(31 downto 0);
        mem_read_request: out    vl_logic;
        mem_addr        : out    vl_logic_vector(31 downto 0);
        mem_read_result : in     vl_logic_vector(31 downto 0);
        mem_finished    : in     vl_logic
    );
end instruction_fetch_and_pc;
