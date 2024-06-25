`include "uvm_macros.svh"
import uvm_pkg::*;

// how we use config_db in a real verificaiton environment

// our agneda will be to keep entire code very simple.
// hence we have considered only a driver present in our verification environment.
// sequencer, sequence, monitor and scoreboard is not in the code.
class drv extends uvm_driver;
  `uvm_component_utils(drv)

  // whenever we want to access an interface in a dynamic component,
  // we need to add a "virtual" keyword.
  // This is how we get an access to interface.
  virtual adder_if aif;

  function new(string path="drv", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // be aware of #(virtual adder_if)
    // this = uvm_test_top.env.agent.drv
    // aif = aif
    // this + aif = uvm_test_top.env.agent.drv.aif
    if (!uvm_config_db#(virtual adder_if)::get(this, "", "aif", aif)) // uvm_test_top.env.agent.drv.aif
      `uvm_error("drv", "Unable to access Interface.");
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    // apply the 10 random stimulus to a DUT
    for(int i = 0; i< 10; i++) begin // 0~9
      aif.a <= $urandom;
      aif.b <= $urandom;
      #10;
    end
    phase.drop_objection(this);
  endtask
endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent)

  function new(string inst="agent", uvm_component c);
    super.new(inst, c);
  endfunction

  drv d;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    d = drv::type_id::create("drv", this);
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
    a = agent::type_id::create("agent", this);
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
    e = env::type_id::create("env", this);
  endfunction
endclass


module tb;
  adder_if aif();

  adder dut (.a(aif.a), .b(aif.b), .y(aif.y));

  initial begin
    uvm_config_db#(virtual adder_if)::set(null, "uvm_test_top.env.agent.drv", "aif", aif); // 可以
    run_test("test");
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule

// Enable "Open EPWave after run" in EDAPlayground
// if you analyze, we are able to get an access of an interface and both the inputs have a random stimulus
// at the interval of 10ns
// Get Signals，tb/aif，a[3:0], b[3:0], y[4:0]
// This demonstrate how you get an axis of an virtual interface which we frequently do with the help of config_fb.
// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_objection.svh(1271) @ 100: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 100: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :    3
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [RNTST]     1
// # KERNEL: [TEST_DONE]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 100 ns,  Iteration: 56,  Instance: /tb,  Process: @INITIAL#89_0@.
// # KERNEL: stopped at time: 100 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Finding VCD file...
// ./dump.vcd
// [2024-06-25 11:54:42 UTC] Opening EPWave...
// Done