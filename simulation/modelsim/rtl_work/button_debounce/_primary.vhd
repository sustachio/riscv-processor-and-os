library verilog;
use verilog.vl_types.all;
entity button_debounce is
    generic(
        PRECISE_CYCLE_TRIGGER: integer := 0
    );
    port(
        clk             : in     vl_logic;
        button          : in     vl_logic;
        debounced       : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of PRECISE_CYCLE_TRIGGER : constant is 1;
end button_debounce;
