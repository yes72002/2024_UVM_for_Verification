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

  // rhs an aurgument where the user will be adding an object
  // and we need to copy the data from an argument into the data members
  virtual function void do_copy(uvm_object rhs);
    obj temp;
    // cast will be able to do two things.
    // first one is it will make sure that the temp and origins both are
    // of the same type that is object.
    // second thing is we get an axis or we get an handle (連接關係) of an rhs.
    $cast(temp, rhs);
    super.do_copy(rhs);
    // this = this object, this class = self in python
    // 其實可省略，https://www.chipverify.com/uvm/uvm-object-copy-clone
    this.a = temp.a;
    this.b = temp.b;
  endfunction
endclass

module tb;
  obj o1, o2;

  initial begin
    o1 = obj::type_id::create("o1");
    o2 = obj::type_id::create("o2");
    // call do_print的寫法跟core method一樣
    o1.randomize();
    o1.print();
    o2.print();

    o2.copy(o1);
    o1.print();
    o2.print();
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: ---------------------------
// # KERNEL: Name  Type      Size  Value
// # KERNEL: ---------------------------
// # KERNEL: o1    obj       -     @335
// # KERNEL:   a   integral  4     'd6
// # KERNEL:   b   integral  5     'd5
// # KERNEL: ---------------------------
// # KERNEL: ---------------------------
// # KERNEL: Name  Type      Size  Value
// # KERNEL: ---------------------------
// # KERNEL: o2    obj       -     @336
// # KERNEL:   a   integral  4     'd0
// # KERNEL:   b   integral  5     'd0
// # KERNEL: ---------------------------
// # KERNEL: ---------------------------
// # KERNEL: Name  Type      Size  Value
// # KERNEL: ---------------------------
// # KERNEL: o1    obj       -     @335
// # KERNEL:   a   integral  4     'd6
// # KERNEL:   b   integral  5     'd5
// # KERNEL: ---------------------------
// # KERNEL: ---------------------------
// # KERNEL: Name  Type      Size  Value
// # KERNEL: ---------------------------
// # KERNEL: o2    obj       -     @336
// # KERNEL:   a   integral  4     'd6
// # KERNEL:   b   integral  5     'd5
// # KERNEL: ---------------------------
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done
// 原本o2.data是0，copy後改成6跟5