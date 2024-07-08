`include "uvm_macros.svh"
import uvm_pkg::*;

class transaction extends uvm_sequence_item;
  bit [3:0] a = 12;
  bit [4:0] b = 24;
  int c = 256;

  function new(string inst = "transaction");
    super.new(inst);
  endfunction

  `uvm_object_utils_begin(transaction)
    `uvm_field_int(a, UVM_DEFAULT | UVM_DEC);
    `uvm_field_int(b, UVM_DEFAULT | UVM_DEC);
    `uvm_field_int(c, UVM_DEFAULT | UVM_DEC);
  `uvm_object_utils_end
endclass

class producer extends uvm_component;
  `uvm_component_utils(producer)

  transaction transac;

  uvm_blocking_put_port #(transaction) port;

  function new(input string path = "producer", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    transac = transaction::type_id::create("transac");
    port = new("port", this);
  endfunction

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
      port.put(transac);
      transac.print();
    phase.drop_objection(this);
  endtask
endclass

class consumer extends uvm_component;
  `uvm_component_utils(consumer)

  uvm_blocking_put_imp #(transaction, consumer) impl;

  function new(input string path = "consumer", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    impl = new("impl", this);
  endfunction

  task put(transaction transac);
    transac.print();
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
    // port connect to implementation
    p.port.connect(c.impl);
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
// # KERNEL: ---------------------------------
// # KERNEL: Name     Type         Size  Value
// # KERNEL: ---------------------------------
// # KERNEL: transac  transaction  -     @385
// # KERNEL:   a      integral     4     12
// # KERNEL:   b      integral     5     24
// # KERNEL:   c      integral     32    'd256
// # KERNEL: ---------------------------------
// # KERNEL: ---------------------------------
// # KERNEL: Name     Type         Size  Value
// # KERNEL: ---------------------------------
// # KERNEL: transac  transaction  -     @385
// # KERNEL:   a      integral     4     12
// # KERNEL:   b      integral     5     24
// # KERNEL:   c      integral     32    'd256
// # KERNEL: ---------------------------------
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :    2
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [RNTST]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 0 ns,  Iteration: 195,  Instance: /tb,  Process: @INITIAL#113_0@.
// # KERNEL: stopped at time: 0 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done