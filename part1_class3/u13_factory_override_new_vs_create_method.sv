`include "uvm_macros.svh"
import uvm_pkg::*;

// 我們想要多加一個訊號ack在我們的transaction class
// transaction class這裡就指的是first
// 用extend (inherit)繼承的方式來新增
// we extend the transaction class and add the new signal to it.

class first extends uvm_object;
  rand bit [3:0] data;

  // 因為是利用extend來創建的，需要加上constructor
  // 這個就是可以給別人來建立constructor跑的function
  // 如果有人要建立constructor，就可以來call this function
  // function new需要path name，這裡"first"是default value
  function new(string path="first");
    super.new(path);
  endfunction

  // 我們利用field macro來讓data有core method可以用
  // uvm_object_utils_begin參數裡面要放class的名稱
  // uvm_field_int參數裡面要放變數跟flag
  `uvm_object_utils_begin(first);
    `uvm_field_int(data, UVM_DEFAULT);
  `uvm_object_utils_end
endclass

// 繼承first並且多加一個訊號ack
// creating our new transaction class by extending the old transaction class
class first_mod extends first;
  rand bit ack;

  function new(string path="first_mod");
    super.new(path);
  endfunction

  // 我們也打算讓這個ack訊號有可以使用core method
  `uvm_object_utils_begin(first_mod)
    `uvm_field_int(ack, UVM_DEFAULT);
  `uvm_object_utils_end
endclass

// override method 需要有UVM component，但還沒教，下堂課會教，現在就先使用
class comp extends uvm_component;
  // we have a specific macro for the string and component to a class
  // 對於object，我們有uvm_object_utils
  // 對於component，我們有uvm_component_utils
  // register our class to a factory
  `uvm_component_utils(comp)

  first f;
  // the constructor of UVM component consists of two arguments.
  // 第一個是path，第二個是你需要給定uvm component的parent
  // (you need to specify the parent of an uvm component)
  // 這在建立uvm tree的時候很好用
  // 當我們建立uvm object的時候，只有一個參數path
  // 當我們建立uvm component的時候，有兩個參數path跟component的上層

  function new(string path="second", uvm_component parent=null);
    // 還是一樣要寫super.new
    super.new(path, parent);
    // usually in the real test bench, 只會寫super.new
    // 但為了教學，特別寫詳細
    // creating an object
    f = first::type_id::create("f");
    f.randomize();
    f.print();
    // as soon as you add a constructor to a component, it will create
    // an object of the transaciton class, randomize the data and
    // generate the random value for our data member.
  endfunction
endclass //comp extends uvm_component

module tb;
  // create an instance of our component
  comp c;

  initial begin
    // c.set_type_override_by_type(first::get_type, first_mod::get_type);
    // create method to create
    // uvm component 會有 2 argumments: path and null/none
    // path will be the same name that we have used for an instance.
    // null: null之後會教，通常這裡會是none或是null，至於怎麼選，下堂課component會教
    c = comp::type_id::create("c", null);
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: -----------------------------
// # KERNEL: Name    Type      Size  Value
// # KERNEL: -----------------------------
// # KERNEL: f       first     -     @344
// # KERNEL:   data  integral  4     'h3
// # KERNEL: -----------------------------
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done
// 只有一個data signal
// u13_factory_override_new_vs_create_method2.sv 把type改掉，多了ack signal