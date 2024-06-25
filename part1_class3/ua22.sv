`include "uvm_macros.svh"
import uvm_pkg::*;

class my_object extends uvm_object;
  `uvm_object_utils(my_object)

  function new(string path="my_object");
    super.new(path);
  endfunction

  rand bit [1:0] a;
  rand bit [3:0] b;
  rand bit [7:0] c;

  virtual function void do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_field_int("a", a, $bits(a), UVM_HEX);
    printer.print_field_int("b", b, $bits(b), UVM_HEX);
    printer.print_field_int("c", c, $bits(c), UVM_HEX);
  endfunction

  virtual function void do_copy(uvm_object rhs);
    my_object temp;
    $cast(temp, rhs);
    super.do_copy(rhs);
    this.a = temp.a;
    this.b = temp.b;
    this.c = temp.c;
  endfunction
endclass

module tb;
  my_object my1, my2;
  int status;

  initial begin
    my1 = my_object::type_id::create("my1");
    // my2 = my_object::type_id::create("my2");

    my1.randomize();
    my1.print();
    // my2.print();
    $cast(my2, my1.clone());

    my1.print();
    my2.print();

    status = my1.compare(my2);
    $display("Status = %0d", status);
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: ----------------------------
// # KERNEL: Name  Type       Size  Value
// # KERNEL: ----------------------------
// # KERNEL: my1   my_object  -     @335
// # KERNEL:   a   integral   2     'h2
// # KERNEL:   b   integral   4     'h5
// # KERNEL:   c   integral   8     'h23
// # KERNEL: ----------------------------
// # KERNEL: ----------------------------
// # KERNEL: Name  Type       Size  Value
// # KERNEL: ----------------------------
// # KERNEL: my1   my_object  -     @335
// # KERNEL:   a   integral   2     'h2
// # KERNEL:   b   integral   4     'h5
// # KERNEL:   c   integral   8     'h23
// # KERNEL: ----------------------------
// # KERNEL: ----------------------------
// # KERNEL: Name  Type       Size  Value
// # KERNEL: ----------------------------
// # KERNEL: my1   my_object  -     @336
// # KERNEL:   a   integral   2     'h2
// # KERNEL:   b   integral   4     'h5
// # KERNEL:   c   integral   8     'h23
// # KERNEL: ----------------------------
// # KERNEL: Status = 1
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done