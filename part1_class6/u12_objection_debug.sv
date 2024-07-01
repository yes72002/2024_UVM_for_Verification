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
    `uvm_info("comp","Reset Aplied", UVM_NONE);
    #100;
    `uvm_info("comp","Reset Removed", UVM_NONE);
    phase.drop_objection(this);
  endtask

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("comp", "Random Stimulus Applied", UVM_NONE);
    #500;
    `uvm_info("comp", "Random Stimulus Removed", UVM_NONE);
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
// # KERNEL: UVM_INFO @ 0: reset_objection [OBJTN_TRC] Object uvm_test_top raised 1 objection(s): count=1  total=1
// # KERNEL: UVM_INFO @ 0: reset_objection [OBJTN_TRC] Object uvm_top added 1 objection(s) to its total (raised from source object uvm_test_top): count=0  total=1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(14) @ 0: uvm_test_top [comp] Reset Aplied
// # KERNEL: UVM_INFO /home/runner/testbench.sv(16) @ 100: uvm_test_top [comp] Reset Removed
// # KERNEL: UVM_INFO @ 100: reset_objection [OBJTN_TRC] Object uvm_test_top dropped 1 objection(s): count=0  total=0
// # KERNEL: UVM_INFO @ 100: reset_objection [OBJTN_TRC] Object uvm_test_top all_dropped 1 objection(s): count=0  total=0
// # KERNEL: UVM_INFO @ 100: reset_objection [OBJTN_TRC] Object uvm_top subtracted 1 objection(s) from its total (dropped from source object uvm_test_top): count=0  total=0
// # KERNEL: UVM_INFO @ 100: reset_objection [OBJTN_TRC] Object uvm_top subtracted 1 objection(s) from its total (all_dropped from source object uvm_test_top): count=0  total=0
// # KERNEL: UVM_INFO @ 100: main_objection [OBJTN_TRC] Object uvm_test_top raised 1 objection(s): count=1  total=1
// # KERNEL: UVM_INFO @ 100: main_objection [OBJTN_TRC] Object uvm_top added 1 objection(s) to its total (raised from source object uvm_test_top): count=0  total=1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(22) @ 100: uvm_test_top [comp] Random Stimulus Applied
// # KERNEL: UVM_INFO /home/runner/testbench.sv(24) @ 600: uvm_test_top [comp] Random Stimulus Removed
// # KERNEL: UVM_INFO @ 600: main_objection [OBJTN_TRC] Object uvm_test_top dropped 1 objection(s): count=0  total=0
// # KERNEL: UVM_INFO @ 600: main_objection [OBJTN_TRC] Object uvm_test_top all_dropped 1 objection(s): count=0  total=0
// # KERNEL: UVM_INFO @ 600: main_objection [OBJTN_TRC] Object uvm_top subtracted 1 objection(s) from its total (dropped from source object uvm_test_top): count=0  total=0
// # KERNEL: UVM_INFO @ 600: main_objection [OBJTN_TRC] Object uvm_top subtracted 1 objection(s) from its total (all_dropped from source object uvm_test_top): count=0  total=0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(29) @ 600: uvm_test_top [mon]  Post-Main Phase Started
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 600: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :   19
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [OBJTN_TRC]    12
// # KERNEL: [RNTST]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL: [comp]     4
// # KERNEL: [mon]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 600 ns,  Iteration: 89,  Instance: /tb,  Process: @INITIAL#39_0@.
// # KERNEL: stopped at time: 600 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done
// OBJTN_TRC = objection trace
// @ 0: Object uvm_test_top raised 1 objection(s): count=1  total=1
// @ 100: drop an objection
// @ 100: main_objection raised 1 objection
// @ 600: Object uvm_test_top dropped 1 objection(s): count=0  total=0