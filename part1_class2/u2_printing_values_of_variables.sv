`include "uvm_macros.svh"
import uvm_pkg::*;

module tb;

  int data = 56;

  initial begin
    // `uvm_info(id, msg, verbosity level)
    `uvm_info("TB_TOP", $sformatf("value of variable: %0d", data), UVM_LOW);
    // This is how you call a system function as format f to send the value
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO /home/runner/testbench.sv(10) @ 0: reporter [TB_TOP] value of variable: 56
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.