`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

class transaction extends uvm_sequence_item;
  rand bit [3:0] a;
  rand bit [3:0] b;
  bit [4:0] y;

  function new(input string inst = "transaction");
    super.new(inst);
  endfunction

  `uvm_object_utils_begin(transaction)
    `uvm_field_int(a, UVM_DEFAULT)
    `uvm_field_int(b, UVM_DEFAULT)
    `uvm_field_int(y, UVM_DEFAULT)
  `uvm_object_utils_end
endclass

class generator extends uvm_sequence #(transaction);
  `uvm_object_utils(generator)

  transaction t;

  function new(input string inst = "GEN");
    super.new(inst);
  endfunction

  virtual task body();
    t = transaction::type_id::create("t");
    repeat(10) begin
      start_item(t);
      t.randomize();
      finish_item(t);
      `uvm_info("GEN",$sformatf("Data send to Driver a :%0d , b :%0d",t.a,t.b), UVM_NONE);
    end
  endtask
endclass

class driver extends uvm_driver #(transaction);
  `uvm_component_utils(driver)

  function new(input string inst = "DRV", uvm_component c);
    super.new(inst, c);
  endfunction

  // we need to store the data in a data container that we receive from the sequencer.
  transaction data;
  virtual add_if aif;

  // reset logic, reset our system
  task reset_dut();
    aif.rst <= 1'b1;
    aif.a   <= 0;
    aif.b   <= 0;
    repeat(5) @(posedge aif.clk);
    aif.rst <= 1'b0;
    `uvm_info("DRV", "Reset Done", UVM_NONE);
  endtask

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    data = transaction::type_id::create("data");
    if(!uvm_config_db #(virtual add_if)::get(this,"","aif",aif))
      `uvm_error("DRV", "Unable to access uvm_config_db");
  endfunction

  virtual task run_phase(uvm_phase phase);
    // reset our system
    reset_dut();
    forever begin
      seq_item_port.get_next_item(data);
      aif.a <= data.a;
      aif.b <= data.b;
      seq_item_port.item_done();
      `uvm_info("DRV", $sformatf("Trigger DUT a: %0d ,b :  %0d",data.a, data.b), UVM_NONE);
      // If you observe, each new transaction on a DUT will be sent after 2 clocks.
      // we are waiting for 2 clock tick before we send the next transaction to our DUT.
      // so this will make sure that the input that we apply to a DUT is successfully processed and output is available.
      @(posedge aif.clk);
      @(posedge aif.clk);
    end
  endtask
endclass

class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  uvm_analysis_port #(transaction) send;

  function new(input string inst = "MON", uvm_component c);
    super.new(inst, c);
    send = new("Write", this);
  endfunction

  transaction t;
  virtual add_if aif;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    t = transaction::type_id::create("TRANS");
    if(!uvm_config_db #(virtual add_if)::get(this,"","aif",aif))
      `uvm_error("MON","Unable to access uvm_config_db");
  endfunction

  virtual task run_phase(uvm_phase phase);
    // waiting for reset to complete
    @(negedge aif.rst);
    forever begin
      repeat(2)@(posedge aif.clk);
      // we collect the response from a DUT, store it into a data member of a transaciton
      t.a = aif.a;
      t.b = aif.b;
      t.y = aif.y;
      `uvm_info("MON", $sformatf("Data send to Scoreboard a : %0d , b : %0d and y : %0d", t.a,t.b,t.y), UVM_NONE);
      // send it to scoreboard
      send.write(t);
    end
  endtask
endclass

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)

  uvm_analysis_imp #(transaction,scoreboard) recv;

  transaction data;

  function new(input string inst = "SCO", uvm_component c);
    super.new(inst, c);
    recv = new("Read", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    data = transaction::type_id::create("TRANS");
  endfunction

  virtual function void write(input transaction t);
    data = t;
    `uvm_info("SCO",$sformatf("Data rcvd from Monitor a: %0d , b : %0d and y : %0d",t.a,t.b,t.y), UVM_NONE);

    if(data.y == data.a + data.b)
      `uvm_info("SCO", "Test Passed", UVM_NONE)
    else
      `uvm_info("SCO", "Test Failed", UVM_NONE);
  endfunction
endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent)

  function new(input string inst = "AGENT", uvm_component c);
    super.new(inst, c);
  endfunction

  monitor m;
  driver d;
  uvm_sequencer #(transaction) seq;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m = monitor::type_id::create("MON",this);
    d = driver::type_id::create("DRV",this);
    seq = uvm_sequencer #(transaction)::type_id::create("SEQ",this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    d.seq_item_port.connect(seq.seq_item_export);
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env)

  function new(input string inst = "ENV", uvm_component c);
    super.new(inst, c);
  endfunction

  scoreboard s;
  agent a;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    s = scoreboard::type_id::create("SCO",this);
    a = agent::type_id::create("AGENT",this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    a.m.send.connect(s.recv);
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test)

  function new(input string inst = "TEST", uvm_component c);
    super.new(inst, c);
  endfunction

  generator gen;
  env e;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    gen = generator::type_id::create("GEN",this);
    e = env::type_id::create("ENV",this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    gen.start(e.a.seq);
    // add a dealy so that the last stimuli that we applied to a DUT will be processed by a DUT,
    // and we also perform a comparison scoreboard.
    #60;
    phase.drop_objection(this);
  endtask
endclass

module add_tb();

  add_if aif();

  initial begin
    aif.clk = 0;
    aif.rst = 0;
  end

  always #10 aif.clk = ~aif.clk;

  add dut (.a(aif.a), .b(aif.b), .y(aif.y), .clk(aif.clk), .rst(aif.rst));

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

  initial begin
    uvm_config_db #(virtual add_if)::set(null, "*", "aif", aif);
    run_test("test");
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(59) @ 90000: uvm_test_top.ENV.AGENT.DRV [DRV] Reset Done
// # KERNEL: UVM_INFO /home/runner/testbench.sv(77) @ 90000: uvm_test_top.ENV.AGENT.DRV [DRV] Trigger DUT a: 15 ,b :  9
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 90000: uvm_test_top.ENV.AGENT.SEQ@@GEN [GEN] Data send to Driver a :15 , b :9
// # KERNEL: UVM_INFO /home/runner/testbench.sv(116) @ 130000: uvm_test_top.ENV.AGENT.MON [MON] Data send to Scoreboard a : 15 , b : 9 and y : 24
// # KERNEL: UVM_INFO /home/runner/testbench.sv(142) @ 130000: uvm_test_top.ENV.SCO [SCO] Data rcvd from Monitor a: 15 , b : 9 and y : 24
// # KERNEL: UVM_INFO /home/runner/testbench.sv(145) @ 130000: uvm_test_top.ENV.SCO [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(77) @ 130000: uvm_test_top.ENV.AGENT.DRV [DRV] Trigger DUT a: 12 ,b :  2
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 130000: uvm_test_top.ENV.AGENT.SEQ@@GEN [GEN] Data send to Driver a :12 , b :2
// # KERNEL: UVM_INFO /home/runner/testbench.sv(116) @ 170000: uvm_test_top.ENV.AGENT.MON [MON] Data send to Scoreboard a : 12 , b : 2 and y : 14
// # KERNEL: UVM_INFO /home/runner/testbench.sv(142) @ 170000: uvm_test_top.ENV.SCO [SCO] Data rcvd from Monitor a: 12 , b : 2 and y : 14
// # KERNEL: UVM_INFO /home/runner/testbench.sv(145) @ 170000: uvm_test_top.ENV.SCO [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(77) @ 170000: uvm_test_top.ENV.AGENT.DRV [DRV] Trigger DUT a: 6 ,b :  4
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 170000: uvm_test_top.ENV.AGENT.SEQ@@GEN [GEN] Data send to Driver a :6 , b :4
// # KERNEL: UVM_INFO /home/runner/testbench.sv(116) @ 210000: uvm_test_top.ENV.AGENT.MON [MON] Data send to Scoreboard a : 6 , b : 4 and y : 10
// # KERNEL: UVM_INFO /home/runner/testbench.sv(142) @ 210000: uvm_test_top.ENV.SCO [SCO] Data rcvd from Monitor a: 6 , b : 4 and y : 10
// # KERNEL: UVM_INFO /home/runner/testbench.sv(145) @ 210000: uvm_test_top.ENV.SCO [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(77) @ 210000: uvm_test_top.ENV.AGENT.DRV [DRV] Trigger DUT a: 13 ,b :  15
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 210000: uvm_test_top.ENV.AGENT.SEQ@@GEN [GEN] Data send to Driver a :13 , b :15
// # KERNEL: UVM_INFO /home/runner/testbench.sv(116) @ 250000: uvm_test_top.ENV.AGENT.MON [MON] Data send to Scoreboard a : 13 , b : 15 and y : 28
// # KERNEL: UVM_INFO /home/runner/testbench.sv(142) @ 250000: uvm_test_top.ENV.SCO [SCO] Data rcvd from Monitor a: 13 , b : 15 and y : 28
// # KERNEL: UVM_INFO /home/runner/testbench.sv(145) @ 250000: uvm_test_top.ENV.SCO [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(77) @ 250000: uvm_test_top.ENV.AGENT.DRV [DRV] Trigger DUT a: 1 ,b :  3
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 250000: uvm_test_top.ENV.AGENT.SEQ@@GEN [GEN] Data send to Driver a :1 , b :3
// # KERNEL: UVM_INFO /home/runner/testbench.sv(116) @ 290000: uvm_test_top.ENV.AGENT.MON [MON] Data send to Scoreboard a : 1 , b : 3 and y : 4
// # KERNEL: UVM_INFO /home/runner/testbench.sv(142) @ 290000: uvm_test_top.ENV.SCO [SCO] Data rcvd from Monitor a: 1 , b : 3 and y : 4
// # KERNEL: UVM_INFO /home/runner/testbench.sv(145) @ 290000: uvm_test_top.ENV.SCO [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(77) @ 290000: uvm_test_top.ENV.AGENT.DRV [DRV] Trigger DUT a: 2 ,b :  0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 290000: uvm_test_top.ENV.AGENT.SEQ@@GEN [GEN] Data send to Driver a :2 , b :0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(116) @ 330000: uvm_test_top.ENV.AGENT.MON [MON] Data send to Scoreboard a : 2 , b : 0 and y : 2
// # KERNEL: UVM_INFO /home/runner/testbench.sv(142) @ 330000: uvm_test_top.ENV.SCO [SCO] Data rcvd from Monitor a: 2 , b : 0 and y : 2
// # KERNEL: UVM_INFO /home/runner/testbench.sv(145) @ 330000: uvm_test_top.ENV.SCO [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(77) @ 330000: uvm_test_top.ENV.AGENT.DRV [DRV] Trigger DUT a: 0 ,b :  6
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 330000: uvm_test_top.ENV.AGENT.SEQ@@GEN [GEN] Data send to Driver a :0 , b :6
// # KERNEL: UVM_INFO /home/runner/testbench.sv(116) @ 370000: uvm_test_top.ENV.AGENT.MON [MON] Data send to Scoreboard a : 0 , b : 6 and y : 6
// # KERNEL: UVM_INFO /home/runner/testbench.sv(142) @ 370000: uvm_test_top.ENV.SCO [SCO] Data rcvd from Monitor a: 0 , b : 6 and y : 6
// # KERNEL: UVM_INFO /home/runner/testbench.sv(145) @ 370000: uvm_test_top.ENV.SCO [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(77) @ 370000: uvm_test_top.ENV.AGENT.DRV [DRV] Trigger DUT a: 11 ,b :  5
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 370000: uvm_test_top.ENV.AGENT.SEQ@@GEN [GEN] Data send to Driver a :11 , b :5
// # KERNEL: UVM_INFO /home/runner/testbench.sv(116) @ 410000: uvm_test_top.ENV.AGENT.MON [MON] Data send to Scoreboard a : 11 , b : 5 and y : 16
// # KERNEL: UVM_INFO /home/runner/testbench.sv(142) @ 410000: uvm_test_top.ENV.SCO [SCO] Data rcvd from Monitor a: 11 , b : 5 and y : 16
// # KERNEL: UVM_INFO /home/runner/testbench.sv(145) @ 410000: uvm_test_top.ENV.SCO [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(77) @ 410000: uvm_test_top.ENV.AGENT.DRV [DRV] Trigger DUT a: 3 ,b :  13
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 410000: uvm_test_top.ENV.AGENT.SEQ@@GEN [GEN] Data send to Driver a :3 , b :13
// # KERNEL: UVM_INFO /home/runner/testbench.sv(116) @ 450000: uvm_test_top.ENV.AGENT.MON [MON] Data send to Scoreboard a : 3 , b : 13 and y : 16
// # KERNEL: UVM_INFO /home/runner/testbench.sv(142) @ 450000: uvm_test_top.ENV.SCO [SCO] Data rcvd from Monitor a: 3 , b : 13 and y : 16
// # KERNEL: UVM_INFO /home/runner/testbench.sv(145) @ 450000: uvm_test_top.ENV.SCO [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(77) @ 450000: uvm_test_top.ENV.AGENT.DRV [DRV] Trigger DUT a: 8 ,b :  14
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 450000: uvm_test_top.ENV.AGENT.SEQ@@GEN [GEN] Data send to Driver a :8 , b :14
// # KERNEL: UVM_INFO /home/runner/testbench.sv(116) @ 490000: uvm_test_top.ENV.AGENT.MON [MON] Data send to Scoreboard a : 8 , b : 14 and y : 22
// # KERNEL: UVM_INFO /home/runner/testbench.sv(142) @ 490000: uvm_test_top.ENV.SCO [SCO] Data rcvd from Monitor a: 8 , b : 14 and y : 22
// # KERNEL: UVM_INFO /home/runner/testbench.sv(145) @ 490000: uvm_test_top.ENV.SCO [SCO] Test Passed
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_objection.svh(1271) @ 510000: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 510000: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :   54
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [DRV]    11
// # KERNEL: [GEN]    10
// # KERNEL: [MON]    10
// # KERNEL: [RNTST]     1
// # KERNEL: [SCO]    20
// # KERNEL: [TEST_DONE]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 510 ns,  Iteration: 57,  Instance: /add_tb,  Process: @INITIAL#241_3@.
// # KERNEL: stopped at time: 510 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Finding VCD file...
// ./dump.vcd
// [2024-07-22 11:31:24 UTC] Opening EPWave...
// Done