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

class second extends uvm_object;
  first f;

  function new(string path="second");
    super.new(path);
    f = new("parent"); // 未來會學build_phase and create method to add a constructor
  endfunction

  `uvm_object_utils_begin(second);
    `uvm_field_object(f, UVM_DEFAULT);
  `uvm_object_utils_end
endclass

// copy method
module tb;
  second s1, s2;

  initial begin
    // when we use the copy method, we need to add the constructor
    s1 = new("s1");
    s2 = new("s2");

    s1.f.randomize();

    s2.copy(s1);

    s1.print();
    s2.print();

    s2.f.data = 12;
    // if we are able to see 12 in both instance, than copy method is shallow copy
    // else if we see different, then copy method is deep copy
    // -> copy method is deep copy
    s1.print();
    s2.print();
  end
endmodule