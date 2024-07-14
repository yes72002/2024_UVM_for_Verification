// how we use config_db in a real verificaiton environment

// design.sv
module adder (
  input [3:0] a, b,
  output [4:0] y
);

  assign y = a + b;

endmodule

interface adder_if;
  logic [3:0] a;
  logic [3:0] b;
  logic [4:0] y;
endinterface //adder_if
