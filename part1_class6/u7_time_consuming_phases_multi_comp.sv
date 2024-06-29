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
endclass

class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  function new(string path = "monitor", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("mon", "Monitor Reset Started", UVM_NONE);
    #300;
    `uvm_info("mon", "Monitor Reset Ended", UVM_NONE);
    phase.drop_objection(this);
  endtask

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("mon", "Monitor Main Phase Started", UVM_NONE);
    #400;
    `uvm_info("mon", "Monitor Main Phase Ended", UVM_NONE);
    phase.drop_objection(this);
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
endclass


module tb;
  initial begin
    run_test("test");
  end
endmodule


// 先來猜猜看先後順序，reset_phase先執行，driver跟monitor都在同一層，所以看字順序
// 我原本的答案
// Driver Reset Started
// #100;
// Driver Reset Ended
// Monitor Reset Started
// #300;
// Monitor Reset Ended
// Driver Main Phase Started
// #100;
// Driver Main Phase Ended
// Monitor Main Phase Started
// #400;
// Monitor Main Phase Ended
// 錯錯錯，結果居然是main的driver跟monitor一起執行，
// monitor main跟driver main一起執行
// 開始delay
// delay 100us換driver main
// delay 300us換monitor main
// 因為是一起執行的，所以兩個delay會同時計時
// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(38) @ 0: uvm_test_top.e.m [mon] Monitor Reset Started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(14) @ 0: uvm_test_top.e.d [drv] Driver Reset Started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(16) @ 100: uvm_test_top.e.d [drv] Driver Reset Ended
// # KERNEL: UVM_INFO /home/runner/testbench.sv(40) @ 300: uvm_test_top.e.m [mon] Monitor Reset Ended
// # KERNEL: UVM_INFO /home/runner/testbench.sv(46) @ 300: uvm_test_top.e.m [mon] Monitor Main Phase Started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(22) @ 300: uvm_test_top.e.d [drv] Driver Main Phase Started
// # KERNEL: UVM_INFO /home/runner/testbench.sv(24) @ 400: uvm_test_top.e.d [drv] Driver Main Phase Ended
// # KERNEL: UVM_INFO /home/runner/testbench.sv(48) @ 700: uvm_test_top.e.m [mon] Monitor Main Phase Ended
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 700: reporter [UVM/REPORT/SERVER]
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
// # KERNEL: [drv]     4
// # KERNEL: [mon]     4
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 700 ns,  Iteration: 89,  Instance: /tb,  Process: @INITIAL#87_0@.
// # KERNEL: stopped at time: 700 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done
