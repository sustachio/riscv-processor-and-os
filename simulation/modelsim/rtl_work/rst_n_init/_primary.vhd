library verilog;
use verilog.vl_types.all;
entity rst_n_init is
    port(
        clk             : in     vl_logic;
        rst_n           : out    vl_logic
    );
end rst_n_init;
