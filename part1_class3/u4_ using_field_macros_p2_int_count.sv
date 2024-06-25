`include "uvm_macros.svh"
import uvm_pkg::*;

class obj extends uvm_object;
  // `uvm_object_utils(obj)

  function new(string path="obj");
    super.new(path);
  endfunction //new()

  rand bit [3:0] a;

  `uvm_object_utils_begin(obj);
    `uvm_field_int(a, UVM_DEFAULT);
  `uvm_object_utils_end
endclass //obj extends uvm_object

module tb;
  obj o;

  initial begin
    o = new("obj");
    o.randomize();
    // `uvm_info("TB_TOP", $sformatf("Value of a: %0d", o.a), UVM_NONE);
    o.print(uvm_default_tree_printer);
  end
endmodule

// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: obj: (obj@335) {
// # KERNEL:   a: 'h6
// # KERNEL: }
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done

// o.print(uvm_default_line_printer);
// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: obj: (obj@335) { a: 'h6  }
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done

// change the format to the binary
class obj extends uvm_object;
  // `uvm_object_utils(obj)

  function new(string path="obj");
    super.new(path);
  endfunction //new()

  rand bit [3:0] a;

  `uvm_object_utils_begin(obj);
    `uvm_field_int(a, UVM_DEFAULT | UVM_BIN);
  `uvm_object_utils_end
endclass //obj extends uvm_object

module tb;
  obj o;

  initial begin
    o = new("obj");
    o.randomize();
    // `uvm_info("TB_TOP", $sformatf("Value of a: %0d", o.a), UVM_NONE);
    o.print(uvm_default_tree_printer);
  end
endmodule
// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: obj: (obj@335) { a: 'b110  }
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done