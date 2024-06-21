`include "uvm_macros.svh"
import uvm_pkg::*;

class obj extends uvm_object;
  // The firsting that you need to kwown is when you are specifying an implementation
  // of a core method. You don't need to register your data member with the field macro.
  `uvm_object_utils(obj)

  function new(string path="OBJ");
    super.new(path);
  endfunction

  bit [3:0] a = 4;
  string b = "UVM";
  real c = 12.34;

  // refer to uvm_object.svh
  virtual function void do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_field_int("a", a, $bits(a), UVM_HEX);
    printer.print_string("b", b);
    printer.print_real("c", c);
  endfunction
endclass

module tb;
  obj o;

  initial begin
    o = obj::type_id::create("o");
    // call do_print的寫法跟core method一樣
    o.print();
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: -------------------------------
// # KERNEL: Name  Type      Size  Value
// # KERNEL: -------------------------------
// # KERNEL: o     obj       -     @335
// # KERNEL:   a   integral  4     'h4
// # KERNEL:   b   string    3     UVM
// # KERNEL:   c   real      64    12.340000
// # KERNEL: -------------------------------
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done