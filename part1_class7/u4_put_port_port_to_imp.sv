`include "uvm_macros.svh"
import uvm_pkg::*;

class subproducer extends uvm_component;
  `uvm_component_utils(subproducer)

  int data = 12;

  uvm_blocking_put_port #(int) subport;

  function new(input string path = "subproducer", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    subport = new("subport", this);
  endfunction

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    subport.put(data);
    `uvm_info("SUBPROD", $sformatf("Data Sent: %0d", data), UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class producer extends uvm_component;
  `uvm_component_utils(producer)

  subproducer sub;

  uvm_blocking_put_port #(int) port;

  function new(input string path = "producer", uvm_component parent = null);
    // we won't be adding anything other than super.new in constructor (function new)
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);
    sub = subproducer::type_id::create("sub", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // port connect to port
    // sub.subport.connect(this.port); also work
    sub.subport.connect(port);
  endfunction

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("PROD", $sformatf("Data Received in Producer: %0d", sub.data), UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class consumer extends uvm_component;
  `uvm_component_utils(consumer)

  uvm_blocking_put_imp #(int, consumer) impl;

  function new(input string path = "consumer", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    impl = new("impl", this);
  endfunction

  // task put(int data_rec);
  //   `uvm_info("CONS", $sformatf("Data Received: %0d", data_rec), UVM_NONE);
  // endtask
  function void put(int data_rec);
    `uvm_info("CONS", $sformatf("Data Received: %0d", data_rec), UVM_NONE);
  endfunction
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
    e = env::type_id::create("e", this);
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
// # KERNEL: ---------------------------------------------------
// # KERNEL: Name             Type                   Size  Value
// # KERNEL: ---------------------------------------------------
// # KERNEL: uvm_test_top     test                   -     @335
// # KERNEL:   e              env                    -     @348
// # KERNEL:     c            consumer               -     @366
// # KERNEL:       impl       uvm_blocking_put_imp   -     @375
// # KERNEL:     p            producer               -     @357
// # KERNEL:       port       uvm_blocking_put_port  -     @385
// # KERNEL:       sub        subproducer            -     @395
// # KERNEL:         subport  uvm_blocking_put_port  -     @404
// # KERNEL: ---------------------------------------------------
// # KERNEL:
// # KERNEL: UVM_INFO /home/runner/testbench.sv(55) @ 0: uvm_test_top.e.p [PROD] Data Received in Producer: 12
// # KERNEL: UVM_INFO /home/runner/testbench.sv(78) @ 0: uvm_test_top.e.c [CONS] Data Received: 12
// # KERNEL: UVM_INFO /home/runner/testbench.sv(23) @ 0: uvm_test_top.e.p.sub [SUBPROD] Data Sent: 12
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :    6
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [CONS]     1
// # KERNEL: [PROD]     1
// # KERNEL: [RNTST]     1
// # KERNEL: [SUBPROD]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL: [UVMTOP]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 0 ns,  Iteration: 195,  Instance: /tb,  Process: @INITIAL#127_0@.
// # KERNEL: stopped at time: 0 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done