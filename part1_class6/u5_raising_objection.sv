`include "uvm_macros.svh"
import uvm_pkg::*;

// Start discussing a phase that consume time
// use run_phase or the 12 self_phase (reset_phase, configure_phase, main_phase, and shutdown_phase)
class comp extends uvm_component;
  `uvm_component_utils(comp)

  function new(string path = "comp", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  // All the 12 phases in the run_phase could have a timing construct
  // because they are implemented with the task.
  // add a delay of 10ns

  // To purposely hold the simulation for the time that you require for the specific phase
  // you need to use the objection mechanism
  // So you need to raise an objection that allows us to tool the simulator that we want.
  // That the simulator must not exit before we complete our process.
  // And as we complete our process, we will be dropping an objection.
  // As soon as we drop an objection, the simulator will allow to exit.
  task reset_phase(uvm_phase phase);
    // use "this" to specify that the current phase is raising an objection, then we'll complete task.
    phase.raise_objection(this);
    `uvm_info("comp", "Reset Started", UVM_NONE);
    #10;
    `uvm_info("comp", "Reset Completed", UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

module tb;
  initial begin
    run_test("comp");
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test comp...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(26) @ 0: uvm_test_top [comp] Reset Started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(28) @ 10: uvm_test_top [comp] Reset Completed
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 10: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :    4
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [RNTST]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL: [comp]     2
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 10 ns,  Iteration: 131,  Instance: /tb,  Process: @INITIAL#34_0@.
// # KERNEL: stopped at time: 10 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done

// 如果不加raise_objection，只會印Reset Started出來，沒有印出Reset Completed
// delay is not working
// The reason being so the uvm will not automatically hold the simulator for the time that you have mentioned in phases,
// which could consume time (the delay we mentioned), so uvm won't automatically wait for 10ns delay for our task to complete.
  // task reset_phase(uvm_phase phase);
  //   `uvm_info("comp", "Reset Started", UVM_NONE);
  //   #10;
  //   `uvm_info("comp", "Reset Completed", UVM_NONE);
  // endtask
// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test comp...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(16) @ 0: uvm_test_top [comp] Reset Started
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :    3
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [RNTST]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL: [comp]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 0 ns,  Iteration: 195,  Instance: /tb,  Process: @INITIAL#35_0@.
// # KERNEL: stopped at time: 0 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done

// 如果把delay拿掉，就會印出來了
  // task reset_phase(uvm_phase phase);
  //   `uvm_info("comp", "Reset Started", UVM_NONE);
  //   `uvm_info("comp", "Reset Completed", UVM_NONE);
  // endtask
// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test comp...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(16) @ 0: uvm_test_top [comp] Reset Started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(21) @ 0: uvm_test_top [comp] Reset Completed
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :    4
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [RNTST]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL: [comp]     2
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 0 ns,  Iteration: 195,  Instance: /tb,  Process: @INITIAL#35_0@.
// # KERNEL: stopped at time: 0 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done