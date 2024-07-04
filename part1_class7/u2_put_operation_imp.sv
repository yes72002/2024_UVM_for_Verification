`include "uvm_macros.svh"
import uvm_pkg::*;

class producer extends uvm_component;
  `uvm_component_utils(producer)

  // This is the data that we want to communicate to consumer.
  int data = 12;

  // send: provide the name to a class.
  uvm_blocking_put_port #(int) send;

  function new(input string path = "producer", uvm_component parent = null);
    super.new(path, parent);
    // The important thing to remember over here is we have added the class (uvm_blocking_put_port),
    // so as soon as we add the constructor to our class (producer), we also need to add the constructor
    // to this class (uvm_blocking_put_port) that we have added.
    // there are 4 auguments, but 3rd and 4th are default.
    send = new("send", this);
  endfunction

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    send.put(data);
    `uvm_info("PROD", $sformatf("Data Sent: %0d", data), UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class consumer extends uvm_component;
  `uvm_component_utils(consumer)

  uvm_blocking_put_export #(int) recv;
  // the second argument to the port implementation is where you will be implementing the method.
  // the data will be received in a consumer.
  // so here we need to add an implementation of a method so that we're able to receive the data
  // in a consumer.
  uvm_blocking_put_imp #(int, consumer) impl;

  function new(input string path = "consumer", uvm_component parent = null);
    super.new(path, parent);
    recv = new("recv", this);
    impl = new("impl", this);
  endfunction

  // The data will be the argument of this consumer.
  // whatever data that put send to us will be accessible by the argument of put method.
  task put(int data_rec);
    `uvm_info("CONS", $sformatf("Data Received: %0d", data_rec), UVM_NONE);
  endtask
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
    p = producer::type_id::create("p",this);
    c = consumer::type_id::create("c", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // How we perform a connection is
    // first thing is the port class (send) is in the producer.
    // it's name is p
    // so p.send, and then we call the connect method
    // so p.send.connect., and then we specify an export port.
    // so p.send.connect(c.recv);
    p.send.connect(c.recv);
    // connect export to an implementation
    // following the rule which is specified by uvm that is implementation port should be endpoint.
    c.recv.connect(c.impl);
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


// data and data_rec are the same, and there is no fatal error
// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(49) @ 0: uvm_test_top.e.c [CONS] Data Received: 12
// # KERNEL: UVM_INFO /home/runner/testbench.sv(25) @ 0: uvm_test_top.e.p [PROD] Data Sent: 12
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :    4
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [CONS]     1
// # KERNEL: [PROD]     1
// # KERNEL: [RNTST]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 0 ns,  Iteration: 195,  Instance: /tb,  Process: @INITIAL#101_0@.
// # KERNEL: stopped at time: 0 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done