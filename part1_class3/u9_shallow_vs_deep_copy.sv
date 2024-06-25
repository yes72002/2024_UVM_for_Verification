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

class second extends uvm_object;
  first f;

  function new(string path="second");
    super.new(path);
    f = new("parent"); // 未來會學build_phase and create method to add a constructor
  endfunction

  `uvm_object_utils_begin(second);
    `uvm_field_object(f, UVM_DEFAULT);
  `uvm_object_utils_end
endclass

module tb;
  second s1, s2;

  initial begin
    s1 = new("s1");
    s2 = new("s2");
    s1.f.randomize();
    s1.print();
    s2 = s1;
    s2.print();

    s2.f.data = 12;
    s1.print();
    s2.print();
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: -------------------------------
// # KERNEL: Name      Type      Size  Value
// # KERNEL: -------------------------------
// # KERNEL: s1        second    -     @335
// # KERNEL:   f       first     -     @336
// # KERNEL:     data  integral  4     'h2
// # KERNEL: -------------------------------
// # KERNEL: -------------------------------
// # KERNEL: Name      Type      Size  Value
// # KERNEL: -------------------------------
// # KERNEL: s1        second    -     @335
// # KERNEL:   f       first     -     @336
// # KERNEL:     data  integral  4     'h2
// # KERNEL: -------------------------------
// # KERNEL: -------------------------------
// # KERNEL: Name      Type      Size  Value
// # KERNEL: -------------------------------
// # KERNEL: s1        second    -     @335
// # KERNEL:   f       first     -     @336
// # KERNEL:     data  integral  4     'hc
// # KERNEL: -------------------------------
// # KERNEL: -------------------------------
// # KERNEL: Name      Type      Size  Value
// # KERNEL: -------------------------------
// # KERNEL: s1        second    -     @335
// # KERNEL:   f       first     -     @336
// # KERNEL:     data  integral  4     'hc
// # KERNEL: -------------------------------
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done