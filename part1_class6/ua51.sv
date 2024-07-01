`include "uvm_macros.svh"
import uvm_pkg::*;

class driver extends uvm_driver;
  `uvm_component_utils(driver)

  function new(string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("drv","Driver Build Phase Executed", UVM_NONE);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info("drv","Driver end_of_elaboration Phase Executed", UVM_NONE);
  endfunction
endclass

class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  function new(string path = "monitor", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("mon","Monitor Build Phase Executed", UVM_NONE);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info("mon","Monitor end_of_elaboration Phase Executed", UVM_NONE);
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env)

  driver drv;
  monitor mon;

  function new(string path = "env", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("env","Env Build Phase Executed", UVM_NONE);
    drv = driver::type_id::create("drv", this);
    mon = monitor::type_id::create("mon", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info("env","Env end_of_elaboration Phase Executed", UVM_NONE);
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test)

  env e;

  function new(string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("test","Test Build Phase Executed", UVM_NONE);
    e = env::type_id::create("e", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info("test","Test end_of_elaboration Phase Executed", UVM_NONE);
  endfunction
endclass


module tb;
  initial begin
    run_test("test");
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(74) @ 0: uvm_test_top [test] Test Build Phase Executed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(52) @ 0: uvm_test_top.e [env] Env Build Phase Executed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(13) @ 0: uvm_test_top.e.drv [drv] Driver Build Phase Executed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(31) @ 0: uvm_test_top.e.mon [mon] Monitor Build Phase Executed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(18) @ 0: uvm_test_top.e.drv [drv] Driver end_of_elaboration Phase Executed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 0: uvm_test_top.e.mon [mon] Monitor end_of_elaboration Phase Executed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(59) @ 0: uvm_test_top.e [env] Env end_of_elaboration Phase Executed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(80) @ 0: uvm_test_top [test] Test end_of_elaboration Phase Executed
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :   10
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [RNTST]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL: [drv]     2
// # KERNEL: [env]     2
// # KERNEL: [mon]     2
// # KERNEL: [test]     2
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 0 ns,  Iteration: 195,  Instance: /tb,  Process: @INITIAL#86_0@.
// # KERNEL: stopped at time: 0 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done