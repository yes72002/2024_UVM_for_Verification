`include "uvm_macros.svh"
import uvm_pkg::*;


// We have two components present in our entire test environment,
// which are used to send and receive the data from our test bench top.
class comp1 extends uvm_component;
  `uvm_component_utils(comp1)

  // add one data member inside the class whose value
  // we will be updating from other class (for understanding config_db)
  int data1 = 0;

  function new(string path="comp1", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // check access or error
    if (!uvm_config_db#(int)::get(null, "uvm_test_top", "data", data1))
      `uvm_error("comp1", "Unable to access Interface.");
      // if uvm_error is triggered, it will automatically stop simulation.
      // 原本只有uvm_fatal會stop，但因為這個uvm_error在build_phase裡面，所以會$finish
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("comp1", $sformatf("Data rcvd comp1 : %0d", data1), UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class comp2 extends uvm_component;
  `uvm_component_utils(comp2)

  // add one data member inside the class whose value
  // we will be updating from other class (for understanding config_db)
  int data2 = 0;

  function new(string path="comp2", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // check access or error
    if (!uvm_config_db#(int)::get(null, "uvm_test_top", "data", data2))
      `uvm_error("comp2", "Unable to access Interface.");
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("comp2", $sformatf("Data rcvd comp2 : %0d", data2), UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent)

  function new(string inst="agent", uvm_component c);
    super.new(inst, c);
  endfunction

  comp1 c1;
  comp2 c2;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    c1 = comp1::type_id::create("c1", this);
    c2 = comp2::type_id::create("c2", this);
  endfunction
endclass

// agent is the child of an environment
class env extends uvm_env;
  `uvm_component_utils(env)

  function new(string inst="env", uvm_component c);
    super.new(inst, c);
  endfunction

  agent a;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a = agent::type_id::create("AGENT", this);
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test)

  function new(string inst="test", uvm_component c);
    super.new(inst, c);
  endfunction

  env e;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("ENV", this);
  endfunction
endclass


module tb;
  // initialize the variable (data) to 256 and this is going to share between the component.
  int data = 256;

  initial begin
    uvm_config_db#(int)::set(null, "uvm_test_top", "data", data); // uvm_test_top.data
    run_test("test");
  end

  // we are not analuzing a values of a varialbe on a wavefrom,
  // so you could ignore adding the random file.
  // initial begin
  //   $dumpfile("dump.vcd");
  //   $dumpvars;
  // end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(54) @ 0: uvm_test_top.ENV.AGENT.c2 [comp2] Data rcvd comp2 : 256
// # KERNEL: UVM_INFO /home/runner/testbench.sv(29) @ 0: uvm_test_top.ENV.AGENT.c1 [comp1] Data rcvd comp1 : 256
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_objection.svh(1271) @ 0: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :    5
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [RNTST]     1
// # KERNEL: [TEST_DONE]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL: [comp1]     1
// # KERNEL: [comp2]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 0 ns,  Iteration: 195,  Instance: /tb,  Process: @INITIAL#112_0@.
// # KERNEL: stopped at time: 0 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done