// `timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction)

  rand bit [3:0] a;
  rand bit [3:0] b;
       bit [7:0] y;

  function new(input string path = "transaction");
    super.new(path);
  endfunction

  // `uvm_object_utils_begin(transaction)
  //   `uvm_field_int(a, UVM_DEFAULT)
  //   `uvm_field_int(b, UVM_DEFAULT)
  //   `uvm_field_int(y, UVM_DEFAULT)
  // `uvm_object_utils_end
endclass

class generator extends uvm_sequence #(transaction);
  `uvm_object_utils(generator)

  transaction tr;

  function new(input string path = "generator");
    super.new(path);
  endfunction

  // we know that when we call the start method of the sequence,
  // it will automatically call a body
  // virtual task body
  virtual task body();
    repeat(15) begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      tr.randomize();
      // y won't play any role in the generator, but to keep our data uniform, we also print the value of y
      `uvm_info("GEN",$sformatf("Data send to Driver a :%0d, b :%0d, y :%0d",tr.a,tr.b,tr.y), UVM_NONE);
      finish_item(tr);
    end
  endtask
endclass

class driver extends uvm_driver #(transaction);
  `uvm_component_utils(driver)

  transaction tr;
  virtual mul_if mif;

  function new(input string path = "driver", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual mul_if)::get(this,"","mif",mif)) //uvm_test_top.env.agent.driver.mif
      `uvm_error("DRV", "Unable to access Interface");
  endfunction

  virtual task run_phase(uvm_phase phase);
    tr = transaction::type_id::create("tr");
    forever begin
      seq_item_port.get_next_item(tr);
      mif.a <= tr.a;
      mif.b <= tr.b;
      `uvm_info("DRV", $sformatf("Trigger DUT a: %0d,b : %0d, y :%0d",tr.a,tr.b,tr.y), UVM_NONE);
      seq_item_port.item_done();
      #20;
    end
  endtask
endclass

class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  uvm_analysis_port #(transaction) send;
  transaction tr;
  virtual mul_if mif;

  function new(input string path = "monitor", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr = transaction::type_id::create("tr");
    send = new("send", this);
    if(!uvm_config_db #(virtual mul_if)::get(this,"","mif",mif)) // uvm_test_top.env.agent.monitor.mif
      `uvm_error("MON", "Unable to access uvm_config_db");
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      // the same delay in the driver
      #20;
      tr.a = mif.a;
      tr.b = mif.b;
      tr.y = mif.y;
      `uvm_info("MON", $sformatf("Data send to Scoreboard a : %0d, b : %0d, y : %0d", tr.a,tr.b,tr.y), UVM_NONE);
      send.write(tr);
    end
  endtask
endclass

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)

  uvm_analysis_imp #(transaction,scoreboard) recv;

  // transaction tr;

  function new(input string path = "scoreboard", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // tr = transaction::type_id::create("tr");
    recv = new("recv", this);
  endfunction

  virtual function void write(transaction tr);
    if(tr.y == tr.a * tr.b)
      `uvm_info("SCO",$sformatf("Test Passed -> a: %0d, b : %0d, and y : %0d",tr.a,tr.b,tr.y), UVM_NONE)
    else
      `uvm_error("SCO",$sformatf("Test Failed -> a: %0d, b : %0d, and y : %0d",tr.a,tr.b,tr.y));
    $$display("---------------------------------------------------");
  endfunction
endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent)

  function new(input string inst = "agent", uvm_component parent=null);
    super.new(inst, parent);
  endfunction

  monitor m;
  driver d;
  uvm_sequencer #(transaction) seqr;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m = monitor::type_id::create("m",this);
    d = driver::type_id::create("d",this);
    seqr = uvm_sequencer #(transaction)::type_id::create("seqr",this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    d.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env)

  function new(input string inst = "env", uvm_component c);
    super.new(inst, c);
  endfunction

  scoreboard s;
  agent a;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    s = scoreboard::type_id::create("s",this);
    a = agent::type_id::create("a",this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    a.m.send.connect(s.recv);
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test)

  function new(input string inst = "test", uvm_component c);
    super.new(inst, c);
  endfunction

  env e;
  generator gen;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("e",this);
    gen = generator::type_id::create("gen");
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    // start our sequence
    gen.start(e.a.seqr);
    #20;
    phase.drop_objection(this);
  endtask
endclass


module mul_tb();
  // when you add in interface in a test benchtop, we need to add parenthesis
  mul_if mif();
  mul dut (.a(mif.a), .b(mif.b), .y(mif.y));

  initial begin
    uvm_config_db #(virtual mul_if)::set(null, "*", "mif", mif);
    run_test("test");
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(41) @ 0: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :15, b :3, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(69) @ 0: uvm_test_top.e.a.d [DRV] Trigger DUT a: 15,b : 3, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(102) @ 20: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 15, b : 3, y : 45
// # KERNEL: UVM_INFO /home/runner/testbench.sv(127) @ 20: uvm_test_top.e.s [SCO] Test Passed -> a: 15, b : 3, and y : 45
// # KERNEL: UVM_INFO /home/runner/testbench.sv(41) @ 20: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :12, b :12, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(69) @ 20: uvm_test_top.e.a.d [DRV] Trigger DUT a: 12,b : 12, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(102) @ 40: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 12, b : 12, y : 144
// # KERNEL: UVM_INFO /home/runner/testbench.sv(127) @ 40: uvm_test_top.e.s [SCO] Test Passed -> a: 12, b : 12, and y : 144
// # KERNEL: UVM_INFO /home/runner/testbench.sv(41) @ 40: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :6, b :14, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(69) @ 40: uvm_test_top.e.a.d [DRV] Trigger DUT a: 6,b : 14, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(102) @ 60: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 6, b : 14, y : 84
// # KERNEL: UVM_INFO /home/runner/testbench.sv(127) @ 60: uvm_test_top.e.s [SCO] Test Passed -> a: 6, b : 14, and y : 84
// # KERNEL: UVM_INFO /home/runner/testbench.sv(41) @ 60: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :13, b :9, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(69) @ 60: uvm_test_top.e.a.d [DRV] Trigger DUT a: 13,b : 9, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(102) @ 80: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 13, b : 9, y : 117
// # KERNEL: UVM_INFO /home/runner/testbench.sv(127) @ 80: uvm_test_top.e.s [SCO] Test Passed -> a: 13, b : 9, and y : 117
// # KERNEL: UVM_INFO /home/runner/testbench.sv(41) @ 80: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :1, b :13, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(69) @ 80: uvm_test_top.e.a.d [DRV] Trigger DUT a: 1,b : 13, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(102) @ 100: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 1, b : 13, y : 13
// # KERNEL: UVM_INFO /home/runner/testbench.sv(127) @ 100: uvm_test_top.e.s [SCO] Test Passed -> a: 1, b : 13, and y : 13
// # KERNEL: UVM_INFO /home/runner/testbench.sv(41) @ 100: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :2, b :10, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(69) @ 100: uvm_test_top.e.a.d [DRV] Trigger DUT a: 2,b : 10, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(102) @ 120: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 2, b : 10, y : 20
// # KERNEL: UVM_INFO /home/runner/testbench.sv(127) @ 120: uvm_test_top.e.s [SCO] Test Passed -> a: 2, b : 10, and y : 20
// # KERNEL: UVM_INFO /home/runner/testbench.sv(41) @ 120: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :0, b :0, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(69) @ 120: uvm_test_top.e.a.d [DRV] Trigger DUT a: 0,b : 0, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(102) @ 140: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 0, b : 0, y : 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(127) @ 140: uvm_test_top.e.s [SCO] Test Passed -> a: 0, b : 0, and y : 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(41) @ 140: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :11, b :15, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(69) @ 140: uvm_test_top.e.a.d [DRV] Trigger DUT a: 11,b : 15, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(102) @ 160: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 11, b : 15, y : 165
// # KERNEL: UVM_INFO /home/runner/testbench.sv(127) @ 160: uvm_test_top.e.s [SCO] Test Passed -> a: 11, b : 15, and y : 165
// # KERNEL: UVM_INFO /home/runner/testbench.sv(41) @ 160: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :3, b :7, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(69) @ 160: uvm_test_top.e.a.d [DRV] Trigger DUT a: 3,b : 7, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(102) @ 180: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 3, b : 7, y : 21
// # KERNEL: UVM_INFO /home/runner/testbench.sv(127) @ 180: uvm_test_top.e.s [SCO] Test Passed -> a: 3, b : 7, and y : 21
// # KERNEL: UVM_INFO /home/runner/testbench.sv(41) @ 180: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :8, b :8, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(69) @ 180: uvm_test_top.e.a.d [DRV] Trigger DUT a: 8,b : 8, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(102) @ 200: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 8, b : 8, y : 64
// # KERNEL: UVM_INFO /home/runner/testbench.sv(127) @ 200: uvm_test_top.e.s [SCO] Test Passed -> a: 8, b : 8, and y : 64
// # KERNEL: UVM_INFO /home/runner/testbench.sv(41) @ 200: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :10, b :2, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(69) @ 200: uvm_test_top.e.a.d [DRV] Trigger DUT a: 10,b : 2, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(102) @ 220: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 10, b : 2, y : 20
// # KERNEL: UVM_INFO /home/runner/testbench.sv(127) @ 220: uvm_test_top.e.s [SCO] Test Passed -> a: 10, b : 2, and y : 20
// # KERNEL: UVM_INFO /home/runner/testbench.sv(41) @ 220: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :9, b :5, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(69) @ 220: uvm_test_top.e.a.d [DRV] Trigger DUT a: 9,b : 5, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(102) @ 240: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 9, b : 5, y : 45
// # KERNEL: UVM_INFO /home/runner/testbench.sv(127) @ 240: uvm_test_top.e.s [SCO] Test Passed -> a: 9, b : 5, and y : 45
// # KERNEL: UVM_INFO /home/runner/testbench.sv(41) @ 240: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :5, b :1, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(69) @ 240: uvm_test_top.e.a.d [DRV] Trigger DUT a: 5,b : 1, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(102) @ 260: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 5, b : 1, y : 5
// # KERNEL: UVM_INFO /home/runner/testbench.sv(127) @ 260: uvm_test_top.e.s [SCO] Test Passed -> a: 5, b : 1, and y : 5
// # KERNEL: UVM_INFO /home/runner/testbench.sv(41) @ 260: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :14, b :6, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(69) @ 260: uvm_test_top.e.a.d [DRV] Trigger DUT a: 14,b : 6, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(102) @ 280: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 14, b : 6, y : 84
// # KERNEL: UVM_INFO /home/runner/testbench.sv(127) @ 280: uvm_test_top.e.s [SCO] Test Passed -> a: 14, b : 6, and y : 84
// # KERNEL: UVM_INFO /home/runner/testbench.sv(41) @ 280: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :4, b :4, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(69) @ 280: uvm_test_top.e.a.d [DRV] Trigger DUT a: 4,b : 4, y :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(102) @ 300: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 4, b : 4, y : 16
// # KERNEL: UVM_INFO /home/runner/testbench.sv(127) @ 300: uvm_test_top.e.s [SCO] Test Passed -> a: 4, b : 4, and y : 16
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_objection.svh(1271) @ 300: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 300: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :   63
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [DRV]    15
// # KERNEL: [GEN]    15
// # KERNEL: [MON]    15
// # KERNEL: [RNTST]     1
// # KERNEL: [SCO]    15
// # KERNEL: [TEST_DONE]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 300 ns,  Iteration: 56,  Instance: /mul_tb,  Process: @INITIAL#211_0@.
// # KERNEL: stopped at time: 300 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done