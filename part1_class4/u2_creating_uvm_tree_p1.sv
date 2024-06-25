`include "uvm_macros.svh"
import uvm_pkg::*;

class a extends uvm_component;
  // register the component to a factory
  `uvm_component_utils(a)

  function new(string path="a", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    // build phase will be executed prior to the simulation.
    // so in most of the cases it is used to create an object of a class.
    super.build_phase(phase);
    `uvm_info("a", "class a executed", UVM_NONE);
  endfunction
endclass

class b extends uvm_component;
  `uvm_component_utils(b)

  function new(string path="b", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    // build phase will be executed prior to the simulation.
    // so in most of the cases it is used to create an object of a class.
    super.build_phase(phase);
    `uvm_info("b", "class b executed", UVM_NONE);
  endfunction
endclass

class c extends uvm_component;
  `uvm_component_utils(c)

  a a_inst;
  b b_inst;

  function new(string path="c", uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // second argument is parent, and c is this component
    a_inst = a::type_id::create("a_inst", this);
    b_inst = b::type_id::create("b_inst", this);
  endfunction

  // if you wish to observe a hierachy, you could take the help of end
  // of elaboration phase.
  // 之後會教
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    // print the hierachy
    uvm_top.print_topology();
  endfunction
endclass

module tb;
  initial begin
    // run_test, specify the name of a class, and it will automatically
    // execute that component.
    run_test("c");
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test c...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(16) @ 0: uvm_test_top.a_inst [a] class a executed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(31) @ 0: uvm_test_top.b_inst [b] class b executed
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_root.svh(583) @ 0: reporter [UVMTOP] UVM testbench topology:
// # KERNEL: -------------------------------
// # KERNEL: Name          Type  Size  Value
// # KERNEL: -------------------------------
// # KERNEL: uvm_test_top  c     -     @335
// # KERNEL:   a_inst      a     -     @348
// # KERNEL:   b_inst      b     -     @357
// # KERNEL: -------------------------------
// # KERNEL:
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :    5
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [RNTST]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL: [UVMTOP]     1
// # KERNEL: [a]     1
// # KERNEL: [b]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 0 ns,  Iteration: 195,  Instance: /tb,  Process: @INITIAL#63_0@.
// # KERNEL: stopped at time: 0 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done