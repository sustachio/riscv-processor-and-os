library verilog;
use verilog.vl_types.all;
entity reg_writeback is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        processor_state : in     vl_logic_vector(2 downto 0);
        rd_in           : in     vl_logic_vector(4 downto 0);
        op              : in     vl_logic_vector(5 downto 0);
        execute_result  : in     vl_logic_vector(31 downto 0);
        mem_out         : in     vl_logic_vector(31 downto 0);
        reg_bank_rd     : out    vl_logic_vector(4 downto 0);
        reg_bank_val    : out    vl_logic_vector(31 downto 0)
    );
end reg_writeback;
