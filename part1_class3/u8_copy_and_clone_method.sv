`include "uvm_macros.svh"
import uvm_pkg::*;

// for copy method
class first extends uvm_object;
  rand bit [3:0] data;

  function new(string path="first");
    super.new(path);
  endfunction

  `uvm_object_utils_begin(first);
    `uvm_field_int(data, UVM_DEFAULT);
  `uvm_object_utils_end
endclass

module tb;
  first f;
  first s;

  // copy f to s
  initial begin
    // add a constructor
    f = new("first");
    s = new("second");
    f.randomize();
    s.copy(f); // copy f to s
    f.print();
    s.print();
  end
endmodule

// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: -----------------------------
// # KERNEL: Name    Type      Size  Value
// # KERNEL: -----------------------------
// # KERNEL: first   first     -     @335
// # KERNEL:   data  integral  4     'h6
// # KERNEL: -----------------------------
// # KERNEL: -----------------------------
// # KERNEL: Name    Type      Size  Value
// # KERNEL: -----------------------------
// # KERNEL: second  first     -     @336
// # KERNEL:   data  integral  4     'h6
// # KERNEL: -----------------------------
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done