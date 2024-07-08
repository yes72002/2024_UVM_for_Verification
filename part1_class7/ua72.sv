`include "uvm_macros.svh"
import uvm_pkg::*;

class producer extends uvm_component;
  `uvm_component_utils(producer)

  uvm_analysis_port #(string) port;

  // int data = 12;
  string str = "ZEN";

  function new(input string path = "producer", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);
  endfunction

  // in the main phase, we add the write method to send the data to the consumers.
  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
      `uvm_info("PROD", $sformatf("Data Broadcasted : %s", str), UVM_NONE);
      port.write(str);
    phase.drop_objection(this);
  endtask
endclass

class subscriber1 extends uvm_component;
  `uvm_component_utils(subscriber1)

  uvm_analysis_imp#(string, subscriber1) imp;

  function new(input string path = "subscriber1", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction

  virtual function void write(string datar);
    `uvm_info("SUB1", $sformatf("Data Recv : %s", datar), UVM_NONE);
  endfunction
endclass

class subscriber2 extends uvm_component;
  `uvm_component_utils(subscriber2)

  uvm_analysis_imp#(string, subscriber2) imp;

  function new(input string path = "subscriber2", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction

  virtual function void write(string datar);
    `uvm_info("SUB2", $sformatf("Data Recv : %s", datar), UVM_NONE);
  endfunction
endclass

class subscriber3 extends uvm_component;
  `uvm_component_utils(subscriber3)

  uvm_analysis_imp#(string, subscriber3) imp;

  function new(input string path = "subscriber3", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction

  virtual function void write(string datar);
    `uvm_info("SUB3", $sformatf("Data Recv : %s", datar), UVM_NONE);
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env)

  producer prod;
  subscriber1 sub1;
  subscriber2 sub2;
  subscriber3 sub3;

  function new(input string path = "env", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sub1 = subscriber1::type_id::create("sub1", this);
    sub2 = subscriber2::type_id::create("sub2", this);
    sub3 = subscriber3::type_id::create("sub3", this);
    prod = producer::type_id::create("prod",this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    prod.port.connect(sub1.imp);
    prod.port.connect(sub2.imp);
    prod.port.connect(sub3.imp);
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test)

  env e;

  function new(input string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("e",this);
  endfunction
endclass


module tb;
  initial begin
    run_test("test");
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(24) @ 0: uvm_test_top.e.prod [PROD] Data Broadcasted : ZEN
// # KERNEL: UVM_INFO /home/runner/testbench.sv(45) @ 0: uvm_test_top.e.sub1 [SUB1] Data Recv : ZEN
// # KERNEL: UVM_INFO /home/runner/testbench.sv(64) @ 0: uvm_test_top.e.sub2 [SUB2] Data Recv : ZEN
// # KERNEL: UVM_INFO /home/runner/testbench.sv(83) @ 0: uvm_test_top.e.sub3 [SUB3] Data Recv : ZEN
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :    6
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [PROD]     1
// # KERNEL: [RNTST]     1
// # KERNEL: [SUB1]     1
// # KERNEL: [SUB2]     1
// # KERNEL: [SUB3]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 0 ns,  Iteration: 195,  Instance: /tb,  Process: @INITIAL#132_0@.
// # KERNEL: stopped at time: 0 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done