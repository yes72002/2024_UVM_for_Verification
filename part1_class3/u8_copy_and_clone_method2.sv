`include "uvm_macros.svh"
import uvm_pkg::*;

// for clone method
`include "uvm_macros.svh"
import uvm_pkg::*;

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

  initial begin
    // clone do not need a constructor
    f = new("first");
    f.randomize();
    $cast(s, f.clone()); // return a current type
    // s = f.clone(); // 直接跑會得到Incompatible types
    // 因為f的parent class是uvm_object，
    // s的parent class是first

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
// # KERNEL: first   first     -     @336
// # KERNEL:   data  integral  4     'h6
// # KERNEL: -----------------------------
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done