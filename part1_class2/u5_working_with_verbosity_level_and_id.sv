`include "uvm_macros.svh"
import uvm_pkg::*;

class driver extends uvm_driver; // inherit from uvm_driver
  `uvm_component_utils(driver) // register our class to a factory

  // create an UVM tree
  function new(string path, uvm_component parent);
    super.new(path, parent);
  endfunction

  task run();
    `uvm_info("DRV1", "Executed Driver1 code", UVM_HIGH);
    `uvm_info("DRV2", "Executed Driver2 code", UVM_HIGH);
  endtask
endclass //driver extends uvm_driver

module tb;
  driver drv;
  initial begin
    drv = new("DRV", null);
    drv.set_report_id_verbosity("DRV1", UVM_HIGH);
    drv.run();
    // 分開ID來set verbosity level
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO /home/runner/testbench.sv(14) @ 0: DRV [DRV1] Executed Driver1 code
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done