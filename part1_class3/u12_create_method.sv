`include "uvm_macros.svh"
import uvm_pkg::*;

class first extends uvm_object;
  rand bit [3:0] data;

  function new(string path="first");
    super.new(path);
  endfunction

  `uvm_object_utils_begin(first);
    `uvm_field_int(data, UVM_DEFAULT);
  `uvm_object_utils_end
endclass

module tb;
  first f1, f2;
  int status = 0;

  initial begin
    // create method
    // = object_type::type_id::create("instance name(path_name)");
    f1 = first::type_id::create("f1");
    f2 = first::type_id::create("f2");

    f1.randomize();
    f2.randomize();

    f1.print();
    f2.print();

    status = f1.compare(f2);
    $display("Value of status: %0d", status);
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: -----------------------------
// # KERNEL: Name    Type      Size  Value
// # KERNEL: -----------------------------
// # KERNEL: f1      first     -     @335
// # KERNEL:   data  integral  4     'h6
// # KERNEL: -----------------------------
// # KERNEL: -----------------------------
// # KERNEL: Name    Type      Size  Value
// # KERNEL: -----------------------------
// # KERNEL: f2      first     -     @336
// # KERNEL:   data  integral  4     'h2
// # KERNEL: -----------------------------
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_comparer.svh(351) @ 0: reporter [MISCMP] Miscompare for f1.data: lhs = 'h6 : rhs = 'h2
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_comparer.svh(382) @ 0: reporter [MISCMP] 1 Miscompare(s) for object f2@336 vs. f1@335
// # KERNEL: Value of status: 0
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done