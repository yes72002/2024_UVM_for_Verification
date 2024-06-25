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

// clone method
module tb;
  second s1, s2;

  // clone method is copy method + constructor, we can guess that it's deep copy
  // but let us give a try and observe ir right
  initial begin
    s1 = new("s1");
    // s2 = new("s2");

    s1.f.randomize();

    $cast(s2, s1.clone());
    s1.print();
    s2.print();

    s2.f.data = 12;
    // if we are able to see 12 in both instance, than clone method is shallow copy
    // else if we see different, then clone method is deep copy
    // -> clone method is deep copy
    s1.print();
    s2.print();
  end
endmodule
