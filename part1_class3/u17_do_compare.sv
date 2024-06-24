`include "uvm_macros.svh"
import uvm_pkg::*;

class obj extends uvm_object;
  `uvm_object_utils(obj)

  function new(string path="obj");
    super.new(path);
  endfunction

  rand bit [3:0] a;
  rand bit [4:0] b;

  virtual function void do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_field_int("a =", a, $bits(a), UVM_DEC);
    printer.print_field_int("b =", b, $bits(b), UVM_DEC);
  endfunction

  virtual function void do_copy(uvm_object rhs);
    obj temp;
    $cast(temp, rhs);
    super.do_copy(rhs);
    this.a = temp.a;
    this.b = temp.b;
  endfunction

  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    obj temp;
    int status;
    $cast(temp, rhs);
    status = super.do_compare(rhs, comparer) && (a == temp.a) && (b == temp.b);
    return status;
  endfunction
endclass

module tb;
  obj o1, o2;
  int status;

  initial begin
    o1 = obj::type_id::create("o1");
    o2 = obj::type_id::create("o2");

    o1.randomize();
    o1.print();
    o2.print();
    status = o2.compare(o1);
    $display("Status = %0d", status);

    o2.copy(o1);
    o1.print();
    o2.print();
    status = o2.compare(o1);
    $display("Status = %0d", status);
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: ----------------------------
// # KERNEL: Name   Type      Size  Value
// # KERNEL: ----------------------------
// # KERNEL: o1     obj       -     @335
// # KERNEL:   a =  integral  4     'd6
// # KERNEL:   b =  integral  5     'd5
// # KERNEL: ----------------------------
// # KERNEL: ----------------------------
// # KERNEL: Name   Type      Size  Value
// # KERNEL: ----------------------------
// # KERNEL: o2     obj       -     @336
// # KERNEL:   a =  integral  4     'd0
// # KERNEL:   b =  integral  5     'd0
// # KERNEL: ----------------------------
// # KERNEL: Status = 0
// # KERNEL: ----------------------------
// # KERNEL: Name   Type      Size  Value
// # KERNEL: ----------------------------
// # KERNEL: o1     obj       -     @335
// # KERNEL:   a =  integral  4     'd6
// # KERNEL:   b =  integral  5     'd5
// # KERNEL: ----------------------------
// # KERNEL: ----------------------------
// # KERNEL: Name   Type      Size  Value
// # KERNEL: ----------------------------
// # KERNEL: o2     obj       -     @336
// # KERNEL:   a =  integral  4     'd6
// # KERNEL:   b =  integral  5     'd5
// # KERNEL: ----------------------------
// # KERNEL: Status = 1
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done
// copy之前，status是0，copy之後，status是1