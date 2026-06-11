library verilog;
use verilog.vl_types.all;
entity reg_bank is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        processor_state : in     vl_logic_vector(2 downto 0);
        rs1_bank_interface_in: in     vl_logic_vector(4 downto 0);
        rs2_bank_interface_in: in     vl_logic_vector(4 downto 0);
        rs1_bank_interface_out: out    vl_logic_vector(31 downto 0);
        rs2_bank_interface_out: out    vl_logic_vector(31 downto 0);
        rd_writeback_reg: in     vl_logic_vector(4 downto 0);
        rd_writeback_val: in     vl_logic_vector(31 downto 0)
    );
end reg_bank;
