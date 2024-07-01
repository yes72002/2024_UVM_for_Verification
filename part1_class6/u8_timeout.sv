`include "uvm_macros.svh"
import uvm_pkg::*;
// default : 9200sec

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
    phase.raise_objection(this);
    `uvm_info("mon", " Main Phase Started", UVM_NONE);
    #100;
    `uvm_info("mon", " Main Phase Ended", UVM_NONE);
    phase.drop_objection(this);
  endtask

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
endclass

module tb;
  initial begin
    // uvm_top.set_timeout(time timeout, bit overridable);
    uvm_top.set_timeout(200ns, 0);
    // uvm_top.set_timeout(100ns, 0);
    run_test("comp");
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test comp...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(14) @ 0: uvm_test_top [comp] Reset Started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(16) @ 10: uvm_test_top [comp] Reset Completed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(22) @ 10: uvm_test_top [mon]  Main Phase Started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(24) @ 110: uvm_test_top [mon]  Main Phase Ended
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
// # KERNEL: Time: 110 ns,  Iteration: 89,  Instance: /tb,  Process: @INITIAL#34_0@.
// # KERNEL: stopped at time: 110 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done


// uvm_top.set_timeout(100ns, 0);
// uvm call the fatal at time 100ns
// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test comp...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(14) @ 0: uvm_test_top [comp] Reset Started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(16) @ 10: uvm_test_top [comp] Reset Completed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(22) @ 10: uvm_test_top [mon]  Main Phase Started
// # KERNEL: UVM_FATAL /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1508) @ 100: reporter [PH_TIMEOUT] Explicit timeout of 100 hit, indicating a probable testbench issue
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 100: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :    5
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    1
// # KERNEL: ** Report counts by id
// # KERNEL: [PH_TIMEOUT]     1
// # KERNEL: [RNTST]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL: [comp]     2
// # KERNEL: [mon]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (135): $finish called.
// # KERNEL: Time: 100 ns,  Iteration: 0,  Instance: /\package uvm_1_2.uvm_pkg\/uvm_phase/uvm_phase::execute_phase,  Process: @INTERNAL#1469_3@.
// # KERNEL: stopped at time: 100 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done