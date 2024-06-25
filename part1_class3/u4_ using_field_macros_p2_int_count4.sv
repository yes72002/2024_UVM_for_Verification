`include "uvm_macros.svh"
import uvm_pkg::*;

// UVM_NOPRINT
class obj extends uvm_object;
  // `uvm_object_utils(obj)

  function new(string path="obj");
    super.new(path);
  endfunction //new()

  rand bit [3:0] a;
  rand bit [7:0] b;

  `uvm_object_utils_begin(obj);
    `uvm_field_int(a, UVM_NOPRINT | UVM_BIN);
    `uvm_field_int(b, UVM_DEFAULT | UVM_DEC);
  `uvm_object_utils_end

endclass //obj extends uvm_object

module tb;
  obj o;

  initial begin
    o = new("obj");
    o.randomize();
    // `uvm_info("TB_TOP", $sformatf("Value of a: %0d", o.a), UVM_NONE);
    o.print(uvm_default_table_printer);
  end
endmodule

// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: ---------------------------
// # KERNEL: Name  Type      Size  Value
// # KERNEL: ---------------------------
// # KERNEL: obj   obj       -     @335
// # KERNEL:   b   integral  8     165
// # KERNEL: ---------------------------
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done