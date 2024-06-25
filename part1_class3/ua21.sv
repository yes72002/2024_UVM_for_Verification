`include "uvm_macros.svh"
import uvm_pkg::*;

class my_object extends uvm_object;
  // `uvm_object_utils(my_object)

  function new(string path="my_object");
    super.new(path);
  endfunction

  rand logic [1:0] a = 4;
  rand logic [3:0] b = 4;
  rand logic [7:0] c = 4;

  `uvm_object_utils_begin(my_object);
    `uvm_field_int(a, UVM_DEFAULT);
    `uvm_field_int(b, UVM_DEFAULT);
    `uvm_field_int(c, UVM_DEFAULT);
  `uvm_object_utils_end
endclass

module tb;
  my_object my;

  initial begin
    my = my_object::type_id::create("my");
    my.randomize();
    my.print();
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: -----------------------------------
// # KERNEL: Name         Type       Size  Value
// # KERNEL: -----------------------------------
// # KERNEL: my_myobject  my_object  -     @335
// # KERNEL:   a          integral   2     'h2
// # KERNEL:   b          integral   4     'h5
// # KERNEL:   c          integral   8     'h23
// # KERNEL: -----------------------------------
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done