`include "uvm_macros.svh"
import uvm_pkg::*;


class sender extends uvm_component;
  `uvm_component_utils(sender)

  logic [3:0] data;

  uvm_blocking_put_port #(logic [3:0]) send;

  function new(input string path = "sender", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    send = new("send", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      for (int i = 0; i < 5; i++) begin
        data = $random;
        `uvm_info("sender", $sformatf("Data : %0d iteration : %0d", data, i), UVM_NONE);
        send.put(data);
        #20;
      end
    end
  endtask
endclass

class receiver extends uvm_component;
  `uvm_component_utils(receiver)

  logic [3:0] datar;

  uvm_blocking_get_port #(logic [3:0]) recv;

  function new(input string path = "receiver", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv = new("recv", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      for (int i = 0; i < 5; i++) begin
        #40;
        recv.get(datar);
        `uvm_info("receiver", $sformatf("Data : %0d iteration : %0d", datar, i), UVM_NONE);
      end
    end
  endtask
endclass

class test extends uvm_test;
  `uvm_component_utils(test)

  uvm_tlm_fifo #(logic [3:0]) fifo;
  sender s;
  receiver r;

  function new(input string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    fifo = new("fifo", this, 10);
    s = sender::type_id::create("s", this);
    r = receiver::type_id::create("r", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    s.send.connect(fifo.put_export);
    r.recv.connect(fifo.get_export);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #200;
    phase.drop_objection(this);
  endtask
endclass

module tb;
  initial begin
    run_test("test");
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(25) @ 0: uvm_test_top.s [sender] Data : 4 iteration : 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(25) @ 20: uvm_test_top.s [sender] Data : 1 iteration : 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(54) @ 40: uvm_test_top.r [receiver] Data : 4 iteration : 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(25) @ 40: uvm_test_top.s [sender] Data : 9 iteration : 2
// # KERNEL: UVM_INFO /home/runner/testbench.sv(25) @ 60: uvm_test_top.s [sender] Data : 3 iteration : 3
// # KERNEL: UVM_INFO /home/runner/testbench.sv(54) @ 80: uvm_test_top.r [receiver] Data : 1 iteration : 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(25) @ 80: uvm_test_top.s [sender] Data : 13 iteration : 4
// # KERNEL: UVM_INFO /home/runner/testbench.sv(25) @ 100: uvm_test_top.s [sender] Data : 13 iteration : 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(54) @ 120: uvm_test_top.r [receiver] Data : 9 iteration : 2
// # KERNEL: UVM_INFO /home/runner/testbench.sv(25) @ 120: uvm_test_top.s [sender] Data : 5 iteration : 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(25) @ 140: uvm_test_top.s [sender] Data : 2 iteration : 2
// # KERNEL: UVM_INFO /home/runner/testbench.sv(54) @ 160: uvm_test_top.r [receiver] Data : 3 iteration : 3
// # KERNEL: UVM_INFO /home/runner/testbench.sv(25) @ 160: uvm_test_top.s [sender] Data : 1 iteration : 3
// # KERNEL: UVM_INFO /home/runner/testbench.sv(25) @ 180: uvm_test_top.s [sender] Data : 13 iteration : 4
// # KERNEL: UVM_INFO /home/runner/testbench.sv(54) @ 200: uvm_test_top.r [receiver] Data : 13 iteration : 4
// # KERNEL: UVM_INFO /home/runner/testbench.sv(25) @ 200: uvm_test_top.s [sender] Data : 6 iteration : 0
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_objection.svh(1271) @ 200: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 200: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :   19
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [RNTST]     1
// # KERNEL: [TEST_DONE]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL: [receiver]     5
// # KERNEL: [sender]    11
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 200 ns,  Iteration: 56,  Instance: /tb,  Process: @INITIAL#95_0@.
// # KERNEL: stopped at time: 200 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done