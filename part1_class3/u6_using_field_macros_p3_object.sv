`include "uvm_macros.svh"
import uvm_pkg::*;

class parent extends uvm_object;
  // `uvm_object_utils(parent)

  function new(string path="parent");
    super.new(path);
  endfunction

  rand bit [3:0] data;

  `uvm_object_utils_begin(parent);
    `uvm_field_int(data, UVM_DEFAULT);
  `uvm_object_utils_end
endclass

class child extends uvm_object;
  // `uvm_object_utils(child)
  parent p;

  function new(string path="child");
    super.new(path);
    p = new("parent"); // 未來會學build_phase adn create method to add a constructor
  endfunction

  `uvm_object_utils_begin(child);
    `uvm_field_object(p, UVM_DEFAULT);
  `uvm_object_utils_end
endclass

module tb;
  child c;

  initial begin
    c = new("child");
    c.p.randomize();
    // c.randomize();
    // c.print(uvm_default_table_printer);
    c.print();
  end
endmodule

// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: -------------------------------
// # KERNEL: Name      Type      Size  Value
// # KERNEL: -------------------------------
// # KERNEL: child     child     -     @335
// # KERNEL:   p       parent    -     @336
// # KERNEL:     data  integral  4     'h2
// # KERNEL: -------------------------------
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done


module tb;
  child c;

  initial begin
    c = new("child");
    c.randomize();
    // c.print(uvm_default_table_printer);
    c.print();
  end
endmodule

// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: -------------------------------
// # KERNEL: Name      Type      Size  Value
// # KERNEL: -------------------------------
// # KERNEL: child     child     -     @335
// # KERNEL:   p       parent    -     @336
// # KERNEL:     data  integral  4     'h0
// # KERNEL: -------------------------------
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done