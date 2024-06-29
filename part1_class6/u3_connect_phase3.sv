`include "uvm_macros.svh"
import uvm_pkg::*;

// make monitor connect phase before driver
class driver extends uvm_driver;
  `uvm_component_utils(driver)

  function new(string path = "driver", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("driver", "Driver Build Phase Executed", UVM_NONE);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("driver", "Driver Connect Phase Executed", UVM_NONE);
  endfunction
endclass

// not recommended to copy
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  function new(string path = "monitor", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("monitor", "Monitor Build Phase Executed", UVM_NONE);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("monitor", "Monitor Connect Phase Executed", UVM_NONE);
  endfunction
endclass

// not recommended to copy
class env extends uvm_env;
  `uvm_component_utils(env)

  monitor m;
  driver d;

  function new(string path = "env", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m = monitor::type_id::create("m", this);
    d = driver::type_id::create("d", this);
    m.build_phase(phase);
    d.build_phase(phase);
    `uvm_info("env", "Env Build Phase Executed", UVM_NONE);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m.connect_phase(phase);
    d.connect_phase(phase);
    `uvm_info("env", "Env Connect Phase Executed", UVM_NONE);
  endfunction
endclass

// not recommended to copy
class test extends uvm_test;
  `uvm_component_utils(test)

  env e;

  function new(string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  // a build phase we have utilized to create an object
  // whenever we are in a situation where we want to create an object, we will be always
  // utilizing a build_phase.
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("e", this);
    `uvm_info("test", "Test Build Phase Executed", UVM_NONE);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("test","Test Connect Phase Executed", UVM_NONE);
  endfunction
endclass

module tb;
  initial begin
    run_test("test");
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(79) @ 0: uvm_test_top [test] Test Build Phase Executed
// # KERNEL: UVM_WARNING @ 0: uvm_test_top.e.m [UVM_DEPRECATED] build()/build_phase() has been called explicitly, outside of the phasing system. This usage of build is deprecated and may lead to unexpected behavior.
// # KERNEL: UVM_INFO /home/runner/testbench.sv(31) @ 0: uvm_test_top.e.m [monitor] Monitor Build Phase Executed
// # KERNEL: UVM_WARNING @ 0: uvm_test_top.e.d [UVM_DEPRECATED] build()/build_phase() has been called explicitly, outside of the phasing system. This usage of build is deprecated and may lead to unexpected behavior.
// # KERNEL: UVM_INFO /home/runner/testbench.sv(13) @ 0: uvm_test_top.e.d [driver] Driver Build Phase Executed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(56) @ 0: uvm_test_top.e [env] Env Build Phase Executed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(18) @ 0: uvm_test_top.e.d [driver] Driver Connect Phase Executed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 0: uvm_test_top.e.m [monitor] Monitor Connect Phase Executed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 0: uvm_test_top.e.m [monitor] Monitor Connect Phase Executed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(18) @ 0: uvm_test_top.e.d [driver] Driver Connect Phase Executed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(63) @ 0: uvm_test_top.e [env] Env Connect Phase Executed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(84) @ 0: uvm_test_top [test] Test Connect Phase Executed
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :   12
// # KERNEL: UVM_WARNING :    2
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [RNTST]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL: [UVM_DEPRECATED]     2
// # KERNEL: [driver]     3
// # KERNEL: [env]     2
// # KERNEL: [monitor]     3
// # KERNEL: [test]     2
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 0 ns,  Iteration: 195,  Instance: /tb,  Process: @INITIAL#89_0@.
// # KERNEL: stopped at time: 0 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done