`include "uvm_macros.svh"
import uvm_pkg::*;

class array extends uvm_object;
  // Static array
  int arr1[3] = {1,2,3};

  // Dynamic array
  int arr2[];

  // Queue
  int arr3[$];

  // Associative array
  int arr4[int];

  function new(string path="array");
    super.new(path);
  endfunction

  `uvm_object_utils_begin(array);
    `uvm_field_sarray_int(arr1, UVM_DEFAULT);
    `uvm_field_array_int(arr2, UVM_DEFAULT);
    `uvm_field_queue_int(arr3, UVM_DEFAULT);
    `uvm_field_aa_int_int(arr4, UVM_DEFAULT);
  `uvm_object_utils_end

  task  run();
    // Dynamic array value update
    arr2 = new[3]; // add three elements in dynamic array
    arr2[0] = 2;
    arr2[1] = 2;
    arr2[2] = 2;

    // Queue
    arr3.push_front(3);
    arr3.push_front(3);

    // Associative arrays
    arr4[1] = 4;
    arr4[2] = 4;
    arr4[3] = 4;
    arr4[4] = 4;
  endtask
endclass

module tb;
  array a;

  initial begin
    a = new("array");
    a.run();
    a.print();
  end
endmodule

// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: ----------------------------------
// # KERNEL: Name     Type          Size  Value
// # KERNEL: ----------------------------------
// # KERNEL: array    array         -     @335
// # KERNEL:   arr1   sa(integral)  3     -
// # KERNEL:     [0]  integral      32    'h1
// # KERNEL:     [1]  integral      32    'h2
// # KERNEL:     [2]  integral      32    'h3
// # KERNEL:   arr2   da(integral)  3     -
// # KERNEL:     [0]  integral      32    'h2
// # KERNEL:     [1]  integral      32    'h2
// # KERNEL:     [2]  integral      32    'h2
// # KERNEL:   arr3   da(integral)  2     -
// # KERNEL:     [0]  integral      32    'h3
// # KERNEL:     [1]  integral      32    'h3
// # KERNEL:   arr4   aa(int,int)   4     -
// # KERNEL:     [1]  integral      32    'h4
// # KERNEL:     [2]  integral      32    'h4
// # KERNEL:     [3]  integral      32    'h4
// # KERNEL:     [4]  integral      32    'h4
// # KERNEL: ----------------------------------
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done