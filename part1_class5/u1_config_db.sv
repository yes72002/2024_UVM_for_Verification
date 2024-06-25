`include "uvm_macros.svh"
import uvm_pkg::*;


// uvm_env is static component built using uvm_component hence the macro for
// factory registration is `uvm_component_utils
class env extends uvm_env;
  `uvm_component_utils(env)

  // add one data member inside the class whose value
  // we will be updating from other class (for understanding config_db)
  int data;

  function new(string path="env", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // check access or error
    if (uvm_config_db#(int)::get(null, "uvm_test_top", "data", data))
      // `uvm_info("ENV", $sformatf("Value of data : %0d", data), UVM_NONE);
      // 加了分號compile就會不過，超怪
      `uvm_info("ENV", $sformatf("Value of data : %0d", data), UVM_NONE)
    else
      `uvm_error("ENV", "Unable to access the Value.");
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test)

  env e;

  function new(string path="test", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("e", this);
    // use config_db
    // four arguments
    // context, instance name, key, value
    // for example, if you add null over here, this indicate that the value
    // that you are providing is accessible to all the components which are present
    // in a test bench environment.
    // every component can access value.data可以被其他所有class取用
    // 如果放其他值，代表只能改那class取用
    // second = instance name
    uvm_config_db#(int)::set(null, "uvm_test_top", "data", 12);
  endfunction
endclass

module tb;
  initial begin
    run_test("test");
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(25) @ 0: uvm_test_top.e [ENV] Value of data : 12
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :    3
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [ENV]     1
// # KERNEL: [RNTST]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 0 ns,  Iteration: 195,  Instance: /tb,  Process: @INITIAL#57_0@.
// # KERNEL: stopped at time: 0 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done
// you can see: uvm_test_top.e [ENV] Value of data : 12