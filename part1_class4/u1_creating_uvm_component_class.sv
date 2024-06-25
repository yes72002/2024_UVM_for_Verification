`include "uvm_macros.svh"
import uvm_pkg::*;

class comp extends uvm_component;
  // register the class to a factory
  `uvm_component_utils(comp)

  function new(string path="comp", uvm_component parent=null);
    super.new(path, parent);
  endfunction
  // 之後會教phases，phases basically mean, if you want to reset your system,
  // you have a specific phases that will perform that operation.
  // everything that you do in the uvm is handled by the phases.
  // it my either be a time consuming task where you sedn the stimulus to a duty,
  // or it could also be a configuration which need to be done prior to a
  // simulation time.
  // Everything that you required in verification environment is handled by phases.
  virtual function void build_phase(uvm_phase phase);
    // wherever in our phase, you see a function, you need to add the method.
    // This will be eligible for all the phases where you have the skeleton
    // consisting of a function.
    super.build_phase(phase);
    `uvm_info("COMP", "Build phase of comp executed", UVM_NONE);
  endfunction
endclass

// module tb;
//   initial begin
//     // run_test, specify the name of a class, and it will automatically
//     // execute that component.
//     run_test("comp");
//   end
// endmodule

module tb;
  comp c;

  initial begin
    // create the constructor of our class
    // why null, because there is no parent of the uvm_top
    // so once you add the uvm component or a parent as a null,
    // in that case, the class becomes the child to uvm_top.
    // 也就是說當null是parent的時候，uvm_top就變成child
    c = comp::type_id::create("c", null);
    c.build_phase(null); // no uvm phase in a test bench top

  end
endmodule


// both get the same console result
// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test comp...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(28) @ 0: uvm_test_top [COMP] Build phase of comp executed
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :    3
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [COMP]     1
// # KERNEL: [RNTST]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 0 ns,  Iteration: 195,  Instance: /tb,  Process: @INITIAL#42_0@.
// # KERNEL: stopped at time: 0 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done