`include "uvm_macros.svh"
import uvm_pkg::*;

class obj extends uvm_object;
  // `uvm_object_utils(obj)

  // 定義變數格式，是一個2bit的變數
  typedef enum bit [1:0] {s0, s1, s2, s3 } state_type;
  // 直接用剛定義好的變數格式來宣告一個變數
  rand state_type state;

  real temp = 12.34;
  string str = "UVM";

  function new(string path="obj");
    super.new(path);
  endfunction

  // register the variable to a factory
  `uvm_object_utils_begin(obj);
    `uvm_field_enum(state_type, state, UVM_DEFAULT);
    `uvm_field_string(str, UVM_DEFAULT);
    `uvm_field_real(temp, UVM_DEFAULT);
  `uvm_object_utils_end
endclass //obj extends uvm_object

module tb;
  obj o;

  initial begin
    o = new("obj");
    o.randomize();
    o.print(uvm_default_table_printer);
  end
endmodule

// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: ------------------------------------
// # KERNEL: Name     Type        Size  Value
// # KERNEL: ------------------------------------
// # KERNEL: obj      obj         -     @335
// # KERNEL:   state  state_type  2     s2
// # KERNEL:   str    string      3     UVM
// # KERNEL:   temp   real        64    12.340000
// # KERNEL: ------------------------------------
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done