library verilog;
use verilog.vl_types.all;
entity execute is
    port(
        rst_n           : in     vl_logic;
        op              : in     vl_logic_vector(5 downto 0);
        rd              : in     vl_logic_vector(4 downto 0);
        rs1             : in     vl_logic_vector(31 downto 0);
        rs2             : in     vl_logic_vector(31 downto 0);
        imm             : in     vl_logic_vector(31 downto 0);
        pc              : in     vl_logic_vector(31 downto 0);
        res             : out    vl_logic_vector(31 downto 0);
        next_pc         : out    vl_logic_vector(31 downto 0)
    );
end execute;
