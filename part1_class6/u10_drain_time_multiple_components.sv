`include "uvm_macros.svh"
import uvm_pkg::*;

class driver extends uvm_driver;
  `uvm_component_utils(driver)

  function new(string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("drv", "Driver Reset Started", UVM_NONE);
    #100;
    `uvm_info("drv", "Driver Reset Ended", UVM_NONE);
    phase.drop_objection(this);
  endtask

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("drv", "Driver Main Phase Started", UVM_NONE);
    #100;
    `uvm_info("drv", "Driver Main Phase Ended", UVM_NONE);
    phase.drop_objection(this);
  endtask

  task post_main_phase(uvm_phase phase);
    `uvm_info("drv", "Driver Post-Main Phase Started", UVM_NONE);
  endtask
endclass


class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  function new(string path = "monitor", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("mon", "Monitor Reset Started", UVM_NONE);
    #150;
    `uvm_info("mon", "Monitor Reset Ended", UVM_NONE);
    phase.drop_objection(this);
  endtask

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("mon", "Monitor Main Phase Started", UVM_NONE);
    #200;
    `uvm_info("mon", "Monitor Main Phase Ended", UVM_NONE);
    phase.drop_objection(this);
  endtask

  task post_main_phase(uvm_phase phase);
    `uvm_info("mon", "Monitor Post-Main Phase Started", UVM_NONE);
  endtask
endclass

class env extends uvm_env;
  `uvm_component_utils(env)

  driver d;
  monitor m;

  function new(string path = "env", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    d = driver::type_id::create("d", this);
    m = monitor::type_id::create("m", this);
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
    e = env::type_id::create("e", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    // We want to add the drain time for all the components which are present in our environment.
    // First, we need to get an access to a main phase.
    // we declare one variable which is uvm_phase and we name this as main_phase.
    uvm_phase main_phase;
    super.end_of_elaboration_phase(phase);
    // we use a method defined by name and then we specify main .
    // as soon as we are able to find the "main", we are able to get an access of the main phse.
    main_phase = phase.find_by_name("main", 0);
    main_phase.phase_done.set_drain_time(this, 100);
  endfunction
endclass

module tb;
  initial begin
    run_test("test");
  end
endmodule


// 自己試試看可不可以分析出時間跟print
// @ 0: uvm_test_top.e.d [drv] Driver Reset Started
// @ 0: uvm_test_top.e.m [mon] Monitor Reset Started
// @ 100: uvm_test_top.e.m [drv] Driver Reset Ended
// @ 150: uvm_test_top.e.m [mon] Monitor Reset Ended

// @ 150: uvm_test_top.e.d [drv] Driver Main Phase Started
// @ 150: uvm_test_top.e.m [mon] Monitor Main Phase Started
// @ 250: uvm_test_top.e.d [drv] Driver Main Phase Ended
// @ 350: uvm_test_top.e.m [mon] Monitor Main Phase Ended

// @ 450: uvm_test_top.e.d [drv] Driver Post-Main Phase Started
// @ 450: uvm_test_top.e.m [mon] Monitor Post-Main Phase Started
// 實際console log，OK沒問題，跟上面一樣
// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(42) @ 0: uvm_test_top.e.m [mon] Monitor Reset Started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(13) @ 0: uvm_test_top.e.d [drv] Driver Reset Started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(15) @ 100: uvm_test_top.e.d [drv] Driver Reset Ended
// # KERNEL: UVM_INFO /home/runner/testbench.sv(44) @ 150: uvm_test_top.e.m [mon] Monitor Reset Ended
// # KERNEL: UVM_INFO /home/runner/testbench.sv(50) @ 150: uvm_test_top.e.m [mon] Monitor Main Phase Started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(21) @ 150: uvm_test_top.e.d [drv] Driver Main Phase Started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(23) @ 250: uvm_test_top.e.d [drv] Driver Main Phase Ended
// # KERNEL: UVM_INFO /home/runner/testbench.sv(52) @ 350: uvm_test_top.e.m [mon] Monitor Main Phase Ended
// # KERNEL: UVM_INFO /home/runner/testbench.sv(57) @ 450: uvm_test_top.e.m [mon] Monitor Post-Main Phase Started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(28) @ 450: uvm_test_top.e.d [drv] Driver Post-Main Phase Started
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 450: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :   12
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [RNTST]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL: [drv]     5
// # KERNEL: [mon]     5
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 450 ns,  Iteration: 89,  Instance: /tb,  Process: @INITIAL#106_0@.
// # KERNEL: stopped at time: 450 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done