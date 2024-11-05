// Defines all possible values for report severity.
// UVM_INFO    - Informative message.
// UVM_WARNING - Indicates a potential problem.
// UVM_ERROR   - Indicates a real problem. Simulation continues subject
//               to the configured message aciton.
// UVM_FATAL   - Indicated a problem from which simulation cannot
//               recover. Simulation exits via $finish after a #0 delay.

typedef enum bit [1:0]
{
  UVM_INFO,
  UVM_WARNING,
  UVM_ERROR,
  UVM_FATAL,
} uvm_severity


`include "uvm_macros.svh"
import uvm_pkg::*;

module tb;

  initial begin
    #50;
    `uvm_info("TB_TOP", "Hello World", UVM_LOW);
    $display("Hello World with display");
  end

endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO /home/runner/testbench.sv(10) @ 50: reporter [TB_TOP] Hello World
// # KERNEL: Hello World with display
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.