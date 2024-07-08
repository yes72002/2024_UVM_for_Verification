`include "uvm_macros.svh"
import uvm_pkg::*;

class producer extends uvm_component;
  `uvm_component_utils(producer)

  uvm_blocking_get_port #(int) port;

  // declare data that will used to store the data that we receive from a consumer.
  int data = 0;

  function new(input string path = "producer", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);
  endfunction

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    // In a case of a put port, we need to call a put method.
    // In a case of a get port, we need to call a get method.
    // in the parentheses we need to specify the storage where you want to store the data
    // that receive from a consumer.
    port.get(data);
    `uvm_info("PROD", $sformatf("Data Recv : %0d", data), UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class consumer extends uvm_component;
  `uvm_component_utils(consumer)

  int data = 12;

  uvm_blocking_get_imp#(int, consumer) imp;

  function new(input string path = "consumer", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction

  // since we want to send the data from a consumer, it is mandatory that you specify a direction
  // as an output. (consumer output)
  // default is input, so it wont need to change in previous cases
  virtual task get(output int datar);
    `uvm_info("CONS", $sformatf("Data Sent : %0d", data), UVM_NONE);
    datar = data;
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
// # KERNEL: ------------------------------------------------
// # KERNEL: Name          Type                   Size  Value
// # KERNEL: ------------------------------------------------
// # KERNEL: uvm_test_top  test                   -     @335
// # KERNEL:   e           env                    -     @348
// # KERNEL:     c         consumer               -     @357
// # KERNEL:       imp     uvm_blocking_get_imp   -     @375
// # KERNEL:     p         producer               -     @366
// # KERNEL:       port    uvm_blocking_get_port  -     @385
// # KERNEL: ------------------------------------------------
// # KERNEL:
// # KERNEL: UVM_INFO /home/runner/testbench.sv(53) @ 0: uvm_test_top.e.c [CONS] Data Sent : 12
// # KERNEL: UVM_INFO /home/runner/testbench.sv(28) @ 0: uvm_test_top.e.p [PROD] Data Recv : 12
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
// # KERNEL: Time: 0 ns,  Iteration: 195,  Instance: /tb,  Process: @INITIAL#103_0@.
// # KERNEL: stopped at time: 0 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done