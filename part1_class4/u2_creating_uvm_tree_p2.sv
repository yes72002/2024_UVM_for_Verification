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
    a_inst.build_phase(null);
    b_inst.build_phase(null);
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

// if you want to manually specify that your uvm test top is class c,
// that could also be done. but that's not recommended.
module tb;
  // initial begin
  //   run_test("c");
  // end
  c c_inst;
  initial begin
    c_inst = c::type_id::create("c_inst", null);
    c_inst.build_phase(null);
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_WARNING @ 0: c_inst [UVM_DEPRECATED] build()/build_phase() has been called explicitly, outside of the phasing system. This usage of build is deprecated and may lead to unexpected behavior.
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done
// 因為我們只有呼叫c_inst的build_phase方法，沒有呼叫a跟b的build_phase方法，所以不會顯示
// 等加了a_inst.build_phase(null);就有下面的result了
// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_WARNING @ 0: c_inst [UVM_DEPRECATED] build()/build_phase() has been called explicitly, outside of the phasing system. This usage of build is deprecated and may lead to unexpected behavior.
// # KERNEL: UVM_WARNING @ 0: c_inst.a_inst [UVM_DEPRECATED] build()/build_phase() has been called explicitly, outside of the phasing system. This usage of build is deprecated and may lead to unexpected behavior.
// # KERNEL: UVM_INFO /home/runner/testbench.sv(16) @ 0: c_inst.a_inst [a] class a executed
// # KERNEL: UVM_WARNING @ 0: c_inst.b_inst [UVM_DEPRECATED] build()/build_phase() has been called explicitly, outside of the phasing system. This usage of build is deprecated and may lead to unexpected behavior.
// # KERNEL: UVM_INFO /home/runner/testbench.sv(31) @ 0: c_inst.b_inst [b] class b executed
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done
// 但還是有warning，所以we do not need to create an instance of uvm_test_top
// we just need to spedify the name of a class in a run_test and
// uvm will automatically create an instance of an uvm_test_top