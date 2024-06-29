`include "uvm_macros.svh"
import uvm_pkg::*;

// 上一堂教consume time的phase(reset_phase)，這堂教多個component
// Show how multiple component where we have a multiple phase which could consuime time.
class comp extends uvm_component;
  `uvm_component_utils(comp)

  function new(string path = "comp", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  // multiple phases could raise an objection.
  // raise objection in both reset_phase and main_phase
  task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("comp","Reset Started", UVM_NONE);
    #10;
    `uvm_info("comp","Reset Completed", UVM_NONE);
    phase.drop_objection(this);
  endtask

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("mon", " Main Phase Started", UVM_NONE);
    #100;
    `uvm_info("mon", " Main Phase Ended", UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

module tb;
  initial begin
    run_test("comp");
  end
endmodule


// 可以看到Stop time是110ns
// You could clearly see that reset_phase, main_phase, configure_phase, and shutdown_phase also works sequentially.
// reset_phasee, main_phase, configure_phase, and shutdown_phase是按照順序執行
// 要等到上一個phase執行完成，才會執行下一個phase
// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test comp...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(15) @ 0: uvm_test_top [comp] Reset Started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(17) @ 10: uvm_test_top [comp] Reset Completed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(23) @ 10: uvm_test_top [mon]  Main Phase Started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(25) @ 110: uvm_test_top [mon]  Main Phase Ended
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 110: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :    6
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [RNTST]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL: [comp]     2
// # KERNEL: [mon]     2
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 110 ns,  Iteration: 89,  Instance: /tb,  Process: @INITIAL#31_0@.
// # KERNEL: stopped at time: 110 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done