`include "uvm_macros.svh"
import uvm_pkg::*;

module tb;
  initial begin
    $display("Default Verbosity level : %0d", uvm_top.get_report_verbosity_level);
    #10;
    `uvm_info("TB_TOP", "String low", UVM_LOW);
    `uvm_info("TB_TOP", "String medium", UVM_MEDIUM);
    `uvm_info("TB_TOP", "String high", UVM_HIGH);
    `uvm_info("TB_TOP", "String debug", UVM_DEBUG);
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: Default Verbosity level : 200
// # KERNEL: UVM_INFO /home/runner/testbench.sv(9) @ 10: reporter [TB_TOP] String low
// # KERNEL: UVM_INFO /home/runner/testbench.sv(10) @ 10: reporter [TB_TOP] String medium
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done