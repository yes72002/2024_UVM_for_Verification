`include "uvm_macros.svh"
import uvm_pkg::*;

class obj extends uvm_object;
  // The firsting that you need to kwown is when you are specifying an implementation
  // of a core method. You don't need to register your data member with the field macro.
  `uvm_object_utils(obj)

  function new(string path="OBJ");
    super.new(path);
  endfunction

  bit [3:0] a = 4;
  string b = "UVM";
  real c = 12.34;

  // refer to uvm_object.svh
  virtual function string convert2string();
    string s = super.convert2string();
    s = {s, $sformatf("a : %0d ", a)};
    s = {s, $sformatf("b : %0s ", b)};
    s = {s, $sformatf("c : %0f ", c)};
    return s;
  endfunction
endclass

module tb;
  obj o;

  initial begin
    o = obj::type_id::create("o");
    o.convert2string();
    $display("%0s", o.convert2string());
    `uvm_info("TB_TOP", $sformatf("%0s", o.convert2string()), UVM_NONE);
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: a : 4 b : UVM c : 12.340000
// # KERNEL: UVM_INFO /home/runner/testbench.sv(34) @ 0: reporter [TB_TOP] a : 4 b : UVM c : 12.340000
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done
// Display in single line
// But you do not get an information such as which line number is sending
// the data as well as which component is sending the data.
// 如果要知道是哪個component的data，可以用uvm_info
