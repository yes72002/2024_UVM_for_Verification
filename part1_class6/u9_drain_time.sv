`include "uvm_macros.svh"
import uvm_pkg::*;
// Default Timeout = 9200sec

class comp extends uvm_component;
  `uvm_component_utils(comp)

  function new(string path = "comp", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("comp","Reset Started", UVM_NONE);
    #10;
    `uvm_info("comp","Reset Completed", UVM_NONE);
    phase.drop_objection(this);
  endtask

  task main_phase(uvm_phase phase);
    // after main completed, and wait 200ns to into next phase
    // phase_done: wait phase to complete
    // set_drain_time("the phase you want to add a drain time", drain_time)
    phase.phase_done.set_drain_time(this, 200);
    phase.raise_objection(this);
    `uvm_info("mon", " Main Phase Started", UVM_NONE);
    #100;
    `uvm_info("mon", " Main Phase Ended", UVM_NONE);
    phase.drop_objection(this);
  endtask

  task post_main_phase(uvm_phase phase);
    `uvm_info("mon", " Post-Main Phase Started", UVM_NONE);
  endtask

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
endclass


module tb;
  initial begin
   // uvm_top.set_timeout(100ns, 0);
    run_test("comp");
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test comp...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(14) @ 0: uvm_test_top [comp] Reset Started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(16) @ 10: uvm_test_top [comp] Reset Completed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(23) @ 10: uvm_test_top [mon]  Main Phase Started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(25) @ 110: uvm_test_top [mon]  Main Phase Ended
// # KERNEL: UVM_INFO /home/runner/testbench.sv(30) @ 310: uvm_test_top [mon]  Post-Main Phase Started
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 310: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :    7
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [RNTST]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL: [comp]     2
// # KERNEL: [mon]     3
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 310 ns,  Iteration: 89,  Instance: /tb,  Process: @INITIAL#40_0@.
// # KERNEL: stopped at time: 310 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done