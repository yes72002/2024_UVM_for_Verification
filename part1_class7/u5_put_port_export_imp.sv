`include "uvm_macros.svh"
import uvm_pkg::*;

class producer extends uvm_component;
  `uvm_component_utils(producer)

  int data = 12;

  uvm_blocking_put_port #(int) port;

  function new(input string path = "producer", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);
  endfunction

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    port.put(data);
    `uvm_info("PROD", $sformatf("Data Sent: %0d", data), UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class subconsumer extends uvm_component;
  `uvm_component_utils(subconsumer)

  uvm_blocking_put_imp #(int, subconsumer) impl;

  function new(input string path = "subconsumer", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    impl = new("impl", this);
  endfunction

  // both works
  task put(int data_rec);
    `uvm_info("SUBCONS", $sformatf("Data Received: %0d", data_rec), UVM_NONE);
  endtask
  // function void put(int data_rec);
  //   `uvm_info("SUBCONS", $sformatf("Data Received: %0d", data_rec), UVM_NONE);
  // endfunction
endclass

class consumer extends uvm_component;
  `uvm_component_utils(consumer)

  uvm_blocking_put_export #(int) expo;
  subconsumer sub;

  function new(input string path = "consumer", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    expo = new("expo", this);
    sub = subconsumer::type_id::create("sub", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // export - implementation
    this.expo.connect(sub.impl);
  endfunction

  // task put(int data_rec);
  //   `uvm_info("CONS", $sformatf("Data Received: %0d", data_rec), UVM_NONE);
  // endtask
endclass

class env extends uvm_env;
`uvm_component_utils(env)

  producer p;
  consumer c;

  function new(input string path = "env", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    p = producer::type_id::create("p", this);
    c = consumer::type_id::create("c", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // port - export
    p.port.connect(c.expo);
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

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
endclass


module tb;
  initial begin
    run_test("test");
  end
endmodule


// console 跟 port -> export -> implementation 沒有差別
// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_root.svh(583) @ 0: reporter [UVMTOP] UVM testbench topology:
// # KERNEL: --------------------------------------------------
// # KERNEL: Name          Type                     Size  Value
// # KERNEL: --------------------------------------------------
// # KERNEL: uvm_test_top  test                     -     @335
// # KERNEL:   e           env                      -     @348
// # KERNEL:     c         consumer                 -     @366
// # KERNEL:       expo    uvm_blocking_put_export  -     @375
// # KERNEL:       sub     subconsumer              -     @385
// # KERNEL:         impl  uvm_blocking_put_imp     -     @394
// # KERNEL:     p         producer                 -     @357
// # KERNEL:       port    uvm_blocking_put_port    -     @404
// # KERNEL: --------------------------------------------------
// # KERNEL:
// # KERNEL: UVM_INFO /home/runner/testbench.sv(47) @ 0: uvm_test_top.e.c.sub [SUBCONS] Data Received: 12
// # KERNEL: UVM_INFO /home/runner/testbench.sv(23) @ 0: uvm_test_top.e.p [PROD] Data Sent: 12
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :    5
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [PROD]     1
// # KERNEL: [RNTST]     1
// # KERNEL: [SUBCONS]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL: [UVMTOP]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 0 ns,  Iteration: 195,  Instance: /tb,  Process: @INITIAL#123_0@.
// # KERNEL: stopped at time: 0 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done