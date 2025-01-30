`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

class transaction extends uvm_sequence_item;
  rand bit [3:0] a;
  rand bit [3:0] b;
  bit [4:0] y;

  function new(input string path = "transaction");
    super.new(path);
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
  integer i;

  function new(input string path = "generator");
    super.new(path);
  endfunction

  virtual task body();
    t = transaction::type_id::create("t");
    repeat (10) begin
      start_item(t);
      t.randomize();
      `uvm_info("GEN", $sformatf("Data send to Driver a :%0d , b :%0d", t.a, t.b), UVM_NONE);
      finish_item(t);
    end
  endtask
endclass

class driver extends uvm_driver #(transaction);
  `uvm_component_utils(driver)

  function new(input string path = "driver", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  transaction tc;
  // add a vritual keywork to get an access of an interface
  virtual add_if aif;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tc = transaction::type_id::create("tc");
    if(!uvm_config_db #(virtual add_if)::get(this,"","aif",aif))
      `uvm_error("DRV", "Unable to access uvm_config_db");
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(tc);
      // If you are working in a sequential circuit on the correct positive edge of a clock,
      // if we utilize the blocking assignment operator so it won't be waiting for the valid clock edge,
      // it will be applying the stimuli to a DUT as when it's ready.
      // So whenever you are triggering an interface, use non-blocking assignment operator
      // 因為sequential circuit還沒準備好，所以要用non-blocking
      // whereas whenever you are updating the data member of a transaction class use blocking assignment operator
      // because non-blocking assignment operator is not allow.
      // For example, when we see the monitor where we receive a response from a DUT, you could see
      // we update the interface contained to the data member of a transaction.
      // here we need to use blocking assignment operator.
      // monitor會更新傳來的值，就要用blocking
      aif.a <= tc.a;
      aif.b <= tc.b;
      `uvm_info("DRV", $sformatf("Trigger DUT a: %0d,b : %0d", tc.a, tc.b), UVM_NONE);
      seq_item_port.item_done();
      #10;
    end
  endtask
endclass

class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  uvm_analysis_port #(transaction) send;

  function new(input string path = "monitor", uvm_component parent = null);
    super.new(path, parent);
    send = new("send", this);
  endfunction

  transaction t;
  virtual add_if aif;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    t = transaction::type_id::create("t");
    if(!uvm_config_db #(virtual add_if)::get(this,"","aif",aif))
      `uvm_error("MON","Unable to access uvm_config_db");
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      // waiting for the delay in the driver (use the same delay)
      #10;
      // capturing the response of an outtput port as an input port
      // and then we are storing it into the respective data member of a transaction.
      t.a = aif.a;
      t.b = aif.b;
      t.y = aif.y;
      `uvm_info("MON", $sformatf("Data send to Scoreboard a : %0d , b : %0d and y : %0d", t.a,t.b,t.y), UVM_NONE);
      // send that data to the scoreboard, we just need to call a write method.
      send.write(t);
    end
  endtask
endclass

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)

  uvm_analysis_imp #(transaction,scoreboard) recv;

  transaction tr;

  function new(input string path = "scoreboard", uvm_component parent = null);
    super.new(path, parent);
    recv = new("recv", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr = transaction::type_id::create("tr");
  endfunction

  virtual function void write(input transaction t);
    // What we are doing here is the transaction object that we have created.
    // We will be updating it with the data that we reveive from a monitor and then we start comparation.
    tr = t;
    `uvm_info("SCO",$sformatf("Data rcvd from Monitor a: %0d , b : %0d and y : %0d",tr.a,tr.b,tr.y), UVM_NONE);

    if(tr.y == tr.a + tr.b)
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

  function new(input string inst = "ENV", uvm_component c);
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

  function new(input string inst = "TEST", uvm_component c);
    super.new(inst, c);
  endfunction

  generator gen;
  env e;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    gen = generator::type_id::create("gen");
    e = env::type_id::create("e",this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    // start our sequence
    gen.start(e.a.seqr);
    // to get the report of monitor and scoreboard
    // scoreboard can also finish the comparison
    // we could also use the drain_time
    #50;
    phase.drop_objection(this);
  endtask
endclass


module add_tb();
  // when you add in interface in a test benchtop, we need to add parenthesis
  add_if aif();
  add dut (.a(aif.a), .b(aif.b), .y(aif.y));

  initial begin
    // so that we are able to analyze the signal values on EPWave
    $dumpfile("dump.vcd");
    $dumpvars;
  end

  initial begin
    // monitor and driver are required to access the interface which are present in an environment.
    // so we need to write uvm_test_top.e.a*, so that every components under the agent can access the interface.
    uvm_config_db #(virtual add_if)::set(null, "uvm_test_top.e.a*", "aif", aif);
    run_test("test");
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 0: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :3 , b :14
// # KERNEL: UVM_INFO /home/runner/testbench.sv(76) @ 0: uvm_test_top.e.a.d [DRV] Trigger DUT a: 3,b : 14
// # KERNEL: UVM_INFO /home/runner/testbench.sv(109) @ 10000: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 3 , b : 14 and y : 17
// # KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 10000: uvm_test_top.e.s [SCO] Data rcvd from Monitor a: 3 , b : 14 and y : 17
// # KERNEL: UVM_INFO /home/runner/testbench.sv(137) @ 10000: uvm_test_top.e.s [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 10000: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :0 , b :7
// # KERNEL: UVM_INFO /home/runner/testbench.sv(76) @ 10000: uvm_test_top.e.a.d [DRV] Trigger DUT a: 0,b : 7
// # KERNEL: UVM_INFO /home/runner/testbench.sv(109) @ 20000: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 0 , b : 7 and y : 7
// # KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 20000: uvm_test_top.e.s [SCO] Data rcvd from Monitor a: 0 , b : 7 and y : 7
// # KERNEL: UVM_INFO /home/runner/testbench.sv(137) @ 20000: uvm_test_top.e.s [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 20000: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :10 , b :9
// # KERNEL: UVM_INFO /home/runner/testbench.sv(76) @ 20000: uvm_test_top.e.a.d [DRV] Trigger DUT a: 10,b : 9
// # KERNEL: UVM_INFO /home/runner/testbench.sv(109) @ 30000: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 10 , b : 9 and y : 19
// # KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 30000: uvm_test_top.e.s [SCO] Data rcvd from Monitor a: 10 , b : 9 and y : 19
// # KERNEL: UVM_INFO /home/runner/testbench.sv(137) @ 30000: uvm_test_top.e.s [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 30000: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :1 , b :4
// # KERNEL: UVM_INFO /home/runner/testbench.sv(76) @ 30000: uvm_test_top.e.a.d [DRV] Trigger DUT a: 1,b : 4
// # KERNEL: UVM_INFO /home/runner/testbench.sv(109) @ 40000: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 1 , b : 4 and y : 5
// # KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 40000: uvm_test_top.e.s [SCO] Data rcvd from Monitor a: 1 , b : 4 and y : 5
// # KERNEL: UVM_INFO /home/runner/testbench.sv(137) @ 40000: uvm_test_top.e.s [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 40000: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :5 , b :8
// # KERNEL: UVM_INFO /home/runner/testbench.sv(76) @ 40000: uvm_test_top.e.a.d [DRV] Trigger DUT a: 5,b : 8
// # KERNEL: UVM_INFO /home/runner/testbench.sv(109) @ 50000: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 5 , b : 8 and y : 13
// # KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 50000: uvm_test_top.e.s [SCO] Data rcvd from Monitor a: 5 , b : 8 and y : 13
// # KERNEL: UVM_INFO /home/runner/testbench.sv(137) @ 50000: uvm_test_top.e.s [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 50000: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :6 , b :5
// # KERNEL: UVM_INFO /home/runner/testbench.sv(76) @ 50000: uvm_test_top.e.a.d [DRV] Trigger DUT a: 6,b : 5
// # KERNEL: UVM_INFO /home/runner/testbench.sv(109) @ 60000: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 6 , b : 5 and y : 11
// # KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 60000: uvm_test_top.e.s [SCO] Data rcvd from Monitor a: 6 , b : 5 and y : 11
// # KERNEL: UVM_INFO /home/runner/testbench.sv(137) @ 60000: uvm_test_top.e.s [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 60000: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :4 , b :11
// # KERNEL: UVM_INFO /home/runner/testbench.sv(76) @ 60000: uvm_test_top.e.a.d [DRV] Trigger DUT a: 4,b : 11
// # KERNEL: UVM_INFO /home/runner/testbench.sv(109) @ 70000: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 4 , b : 11 and y : 15
// # KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 70000: uvm_test_top.e.s [SCO] Data rcvd from Monitor a: 4 , b : 11 and y : 15
// # KERNEL: UVM_INFO /home/runner/testbench.sv(137) @ 70000: uvm_test_top.e.s [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 70000: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :15 , b :10
// # KERNEL: UVM_INFO /home/runner/testbench.sv(76) @ 70000: uvm_test_top.e.a.d [DRV] Trigger DUT a: 15,b : 10
// # KERNEL: UVM_INFO /home/runner/testbench.sv(109) @ 80000: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 15 , b : 10 and y : 25
// # KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 80000: uvm_test_top.e.s [SCO] Data rcvd from Monitor a: 15 , b : 10 and y : 25
// # KERNEL: UVM_INFO /home/runner/testbench.sv(137) @ 80000: uvm_test_top.e.s [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 80000: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :7 , b :2
// # KERNEL: UVM_INFO /home/runner/testbench.sv(76) @ 80000: uvm_test_top.e.a.d [DRV] Trigger DUT a: 7,b : 2
// # KERNEL: UVM_INFO /home/runner/testbench.sv(109) @ 90000: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 7 , b : 2 and y : 9
// # KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 90000: uvm_test_top.e.s [SCO] Data rcvd from Monitor a: 7 , b : 2 and y : 9
// # KERNEL: UVM_INFO /home/runner/testbench.sv(137) @ 90000: uvm_test_top.e.s [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 90000: uvm_test_top.e.a.seqr@@gen [GEN] Data send to Driver a :12 , b :3
// # KERNEL: UVM_INFO /home/runner/testbench.sv(76) @ 90000: uvm_test_top.e.a.d [DRV] Trigger DUT a: 12,b : 3
// # KERNEL: UVM_INFO /home/runner/testbench.sv(109) @ 100000: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 12 , b : 3 and y : 15
// # KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 100000: uvm_test_top.e.s [SCO] Data rcvd from Monitor a: 12 , b : 3 and y : 15
// # KERNEL: UVM_INFO /home/runner/testbench.sv(137) @ 100000: uvm_test_top.e.s [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(109) @ 110000: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 12 , b : 3 and y : 15
// # KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 110000: uvm_test_top.e.s [SCO] Data rcvd from Monitor a: 12 , b : 3 and y : 15
// # KERNEL: UVM_INFO /home/runner/testbench.sv(137) @ 110000: uvm_test_top.e.s [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(109) @ 120000: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 12 , b : 3 and y : 15
// # KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 120000: uvm_test_top.e.s [SCO] Data rcvd from Monitor a: 12 , b : 3 and y : 15
// # KERNEL: UVM_INFO /home/runner/testbench.sv(137) @ 120000: uvm_test_top.e.s [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(109) @ 130000: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 12 , b : 3 and y : 15
// # KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 130000: uvm_test_top.e.s [SCO] Data rcvd from Monitor a: 12 , b : 3 and y : 15
// # KERNEL: UVM_INFO /home/runner/testbench.sv(137) @ 130000: uvm_test_top.e.s [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(109) @ 140000: uvm_test_top.e.a.m [MON] Data send to Scoreboard a : 12 , b : 3 and y : 15
// # KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 140000: uvm_test_top.e.s [SCO] Data rcvd from Monitor a: 12 , b : 3 and y : 15
// # KERNEL: UVM_INFO /home/runner/testbench.sv(137) @ 140000: uvm_test_top.e.s [SCO] Test Passed
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_objection.svh(1271) @ 140000: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 140000: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :   65
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [DRV]    10
// # KERNEL: [GEN]    10
// # KERNEL: [MON]    14
// # KERNEL: [RNTST]     1
// # KERNEL: [SCO]    28
// # KERNEL: [TEST_DONE]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 140 ns,  Iteration: 56,  Instance: /add_tb,  Process: @INITIAL#223_1@.
// # KERNEL: stopped at time: 140 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done
