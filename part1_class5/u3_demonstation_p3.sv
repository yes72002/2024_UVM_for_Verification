`include "uvm_macros.svh"
import uvm_pkg::*;

// try to understand the different combinations
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
    // if (!uvm_config_db#(int)::get(null, "uvm_test_top", "data", data1)) // uvm_test_top.data
    // this 表示get en entire part of the component
    // "this" will refer to the class name
    if (!uvm_config_db#(int)::get(this, "", "data", data1)) // uvm_test_top.env.agent.comp1.data
      `uvm_error("comp1", "Unable to access Interface.");
      // `uvm_info("comp1", "Unable to access Interface.", UVM_NONE);
      // if uvm_error is triggered, it will automatically stop simulation.
      // 原本只有uvm_fatal會stop，但因為這個uvm_error在build_phase裡面，所以會$finish
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("comp1", $sformatf("Data rcvd comp1 : %0d", data1), UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

// class comp2 extends uvm_component;
//   `uvm_component_utils(comp2)

//   // add one data member inside the class whose value
//   // we will be updating from other class (for understanding config_db)
//   int data2 = 0;

//   function new(string path="comp2", uvm_component parent=null);
//     super.new(path, parent);
//   endfunction

//   virtual function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     // check access or error
//     if (!uvm_config_db#(int)::get(this, "", "data", data2)) // uvm_test_top.env.agent.comp2.data
//       `uvm_error("comp2", "Unable to access Interface.");
//   endfunction

//   virtual task run_phase(uvm_phase phase);
//     phase.raise_objection(this);
//     `uvm_info("comp2", $sformatf("Data rcvd comp2 : %0d", data2), UVM_NONE);
//     phase.drop_objection(this);
//   endtask
// endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent)

  function new(string inst="agent", uvm_component c);
    super.new(inst, c);
  endfunction

  comp1 c1;
  // comp2 c2;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    c1 = comp1::type_id::create("comp1", this);
    // c2 = comp2::type_id::create("comp2", this);
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
    // e = env::type_id::create("ENV", this);
  endfunction
endclass


module tb;
  int data = 256;

  initial begin
    // 這行其實表示的是"把uvm_test_top.data set成256"
    // 所以如果別人get的路徑不一樣，就會get不到data
    // uvm_config_db#(int)::set(null, "uvm_test_top", "data", data); // uvm_test_top.data
    uvm_config_db#(int)::set(null, "uvm_test_top.env.agent.comp1", "data", data); // uvm_test_top.env.agent.comp1.data
    // run_test下，test class的名字會叫做uvm_test_top
    run_test("test");
  end

  // we are not analuzing a values of a varialbe on a wavefrom,
  // so you could ignore adding the random file.
  // initial begin
  //   $dumpfile("dump.vcd");
  //   $dumpvars;
  // end
endmodule


// 如果create env, agent名字寫大寫呢：會找不到，uvm_test_top.ENV.agent.comp1 [comp1] Unable to access Interface.
// 如果沒有寫if(config_db)呢：即使路徑有錯，也不會找不到，不會跳fatal中斷，因為沒有寫if
// 如果有寫if(config_db)，但是裡面寫uvm_info呢：會找不到，也會顯示Unable，但不會中斷，會繼續模擬，看來只有寫uvm_error或uvm_fatal才會中斷
// 下面是跑成功的console
// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(31) @ 0: uvm_test_top.env.agent.comp1 [comp1] Data rcvd comp1 : 256
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_objection.svh(1271) @ 0: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
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
// # KERNEL: [TEST_DONE]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL: [comp1]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 0 ns,  Iteration: 195,  Instance: /tb,  Process: @INITIAL#113_0@.
// # KERNEL: stopped at time: 0 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done