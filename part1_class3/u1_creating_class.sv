class first;
  rand bit [3:0] data;

endclass

module tb;
  first f;

  initial begin
    // f = new("DRV", null);
    f = new();
    f.randomize();
    $display("Value of data: %0d", f.data);
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: Value of data: 6
// # KERNEL: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done
