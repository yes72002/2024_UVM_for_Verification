`include "uvm_macros.svh"
import uvm_pkg::*;

// Send the data in the both direction that is achieved with the help of a transport port.
// transport port can work in blocking, non-blocking, and combination.
class producer extends uvm_component;
  `uvm_component_utils(producer)

  // first one is the data type of the data send to the consumer.
  // second one is the data type of the data receiving for a consumer.
  uvm_blocking_transport_port #(int, int) port;

  int datas = 12;
  int datar = 0;

  function new(input string path = "producer", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);
  endfunction

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    // the method that we get with the transport port is port.transport
    port.transport(datas, datar);
    `uvm_info("PROD", $sformatf("Data Sent : %0d, Data Recv : %0d", datas, datar), UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class consumer extends uvm_component;
  `uvm_component_utils(consumer)

  // datas is the data that we're going to send to the producer.
  int datas = 13;
  int datar = 0;

  uvm_blocking_transport_imp #(int, int, consumer) imp;

  function new(input string path = "consumer", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction

  // first is the data that procuces senders, so this do not have any direction and we know that
  // the default direction is input.
  // datar represent the data that we receive from a producer.
  // ouput represent the data that we're going to send to a producer.
  virtual task transport(input int datar, output int datas);
    datas = this.datas; // 13
    `uvm_info("CONS", $sformatf("Data Sent : %0d, Data Recv : %0d", datas, datar), UVM_NONE);
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
    c = consumer::type_id::create("c", this);
    p = producer::type_id::create("p",this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // port - implementation
    p.port.connect(c.imp);
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


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_root.svh(583) @ 0: reporter [UVMTOP] UVM testbench topology:
// # KERNEL: ------------------------------------------------------
// # KERNEL: Name          Type                         Size  Value
// # KERNEL: ------------------------------------------------------
// # KERNEL: uvm_test_top  test                         -     @335
// # KERNEL:   e           env                          -     @348
// # KERNEL:     c         consumer                     -     @357
// # KERNEL:       imp     uvm_blocking_transport_imp   -     @375
// # KERNEL:     p         producer                     -     @366
// # KERNEL:       port    uvm_blocking_transport_port  -     @385
// # KERNEL: ------------------------------------------------------
// # KERNEL:
// # KERNEL: UVM_INFO /home/runner/testbench.sv(58) @ 0: uvm_test_top.e.c [CONS] Data Sent : 13, Data Recv : 12
// # KERNEL: UVM_INFO /home/runner/testbench.sv(29) @ 0: uvm_test_top.e.p [PROD] Data Sent : 12, Data Recv : 13
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :    5
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [CONS]     1
// # KERNEL: [PROD]     1
// # KERNEL: [RNTST]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL: [UVMTOP]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 0 ns,  Iteration: 195,  Instance: /tb,  Process: @INITIAL#107_0@.
// # KERNEL: stopped at time: 0 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done