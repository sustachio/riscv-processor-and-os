library verilog;
use verilog.vl_types.all;
entity processor_state_manager is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        mem_finished    : in     vl_logic;
        decoder_op      : in     vl_logic_vector(5 downto 0);
        processor_state : out    vl_logic_vector(2 downto 0);
        TEST_ALLOW_WB_COMPLETE: in     vl_logic
    );
end processor_state_manager;
