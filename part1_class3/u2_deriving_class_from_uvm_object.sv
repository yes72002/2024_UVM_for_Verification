`include "uvm_macros.svh"
import uvm_pkg::*;

class obj extends uvm_object;
  `uvm_object_utils(obj)

  function new(string path="obj");
    super.new(path);
  endfunction //new()

  rand bit [3:0] a;
endclass //obj extends uvm_object

module tb;
  obj o;

  initial begin
    o = new("obj");
    o.randomize();
    `uvm_info("TB_TOP", $sformatf("Value of a: %0d", o.a), UVM_NONE);
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO /home/runner/testbench.sv(22) @ 0: reporter [TB_TOP] Value of a: 6
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done