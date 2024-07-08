`include "uvm_macros.svh"
import uvm_pkg::*;

class producer extends uvm_component;
  `uvm_component_utils(producer)

  uvm_analysis_port #(int) port;

  int data = 12;

  function new(input string path = "producer", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port   = new("port", this);
  endfunction

  // in the main phase, we add the write method to send the data to the consumers.
  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
      `uvm_info("PROD", $sformatf("Data Broadcasted : %0d", data), UVM_NONE);
      // our analysis port has a name as port
      // () put the name of data
      port.write(data);
    phase.drop_objection(this);
  endtask
endclass

class consumer1 extends uvm_component;
  `uvm_component_utils(consumer1)

  // 2 parameter, first one is datatype
  // second one is the class where you will be specifying an implementation.
  uvm_analysis_imp#(int, consumer1) imp;

  function new(input string path = "consumer1", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction

  virtual function void write(int datar);
    `uvm_info("CONS1", $sformatf("Data Recv : %0d", datar), UVM_NONE);
  endfunction
endclass

class consumer2 extends uvm_component;
  `uvm_component_utils(consumer2)

  // multiple class could have the same name for an analysis implementation. (OOP)
  // This makes sense because this will be restircted to this consumer2 class only.
  uvm_analysis_imp#(int, consumer2) imp;

  function new(input string path = "consumer2", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction

  virtual function void write(int datar);
    `uvm_info("CONS2", $sformatf("Data Recv : %0d", datar), UVM_NONE);
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env)

  producer p;
  consumer1 c1;
  consumer2 c2;

  function new(input string path = "env", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    c1 = consumer1::type_id::create("c1", this);
    c2 = consumer2::type_id::create("c2", this);
    p = producer::type_id::create("p",this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    p.port.connect(c1.imp);
    p.port.connect(c2.imp);
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
// # KERNEL: UVM_INFO /home/runner/testbench.sv(23) @ 0: uvm_test_top.e.p [PROD] Data Broadcasted : 12
// # KERNEL: UVM_INFO /home/runner/testbench.sv(48) @ 0: uvm_test_top.e.c1 [CONS1] Data Recv : 12
// # KERNEL: UVM_INFO /home/runner/testbench.sv(69) @ 0: uvm_test_top.e.c2 [CONS2] Data Recv : 12
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :    5
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [CONS1]     1
// # KERNEL: [CONS2]     1
// # KERNEL: [PROD]     1
// # KERNEL: [RNTST]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 0 ns,  Iteration: 195,  Instance: /tb,  Process: @INITIAL#115_0@.
// # KERNEL: stopped at time: 0 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done