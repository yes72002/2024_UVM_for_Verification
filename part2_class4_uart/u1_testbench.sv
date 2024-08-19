// `timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

typedef enum bit [1:0] {reset_asserted = 0, random_baud = 1} oper_mode;

class config_dff extends uvm_object;
  `uvm_object_utils(config_dff)

  uvm_active_passive_enum agent_type = UVM_ACTIVE;

  function new(input string path = "config_dff");
    super.new(path);
  endfunction
endclass

class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction)

  oper_mode oper;
  rand logic [16:0] baud;
  logic tx_clk;
  real period;

  constraint baud_c {baud inside {4800,9600,14400,19200,38400,57600};}

  function new(input string path = "transaction");
    super.new(path);
  endfunction
endclass

class reset_clk extends uvm_sequence #(transaction);
  `uvm_object_utils(reset_clk)

  transaction tr;

  function new(input string path = "reset_clk");
    super.new(path);
  endfunction

  virtual task body();
    repeat(5) begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      // assert(tr.randomize());
      assert(tr.randomize);
      // only thing that we need to de is to update an operating mode
      // so operating mode is rest_asserted
      tr.oper = reset_asserted;
      // `uvm_info("SEQ", $sformatf("rst = %0b, din = %0b, dout = %0b", tr.rst, tr.din, tr.dout), UVM_NONE);
      finish_item(tr);
    end
  endtask
endclass

class variable_baud extends uvm_sequence#(transaction);
  `uvm_object_utils(variable_baud)

  transaction tr;

  function new(input string path = "variable_baud");
    super.new(path);
  endfunction

  virtual task body();
    repeat(5) begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      // assert(tr.randomize());
      assert(tr.randomize);
      tr.oper = random_baud;
      // `uvm_info("SEQ", $sformatf("rst = %0b, din = %0b, dout = %0b", tr.rst, tr.din, tr.dout), UVM_NONE);
      finish_item(tr);
    end
  endtask
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
      // `uvm_info("GEN",$sformatf("Data send to Driver a :%0d, b :%0d, y :%0d",tr.a,tr.b,tr.y), UVM_NONE);
      finish_item(tr);
    end
  endtask
endclass

class driver extends uvm_driver #(transaction);
  `uvm_component_utils(driver)

  transaction tr;
  virtual clk_if vif;

  function new(input string path = "driver", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // this tr is where we will be receiving a data of our sequencer
    // 之前不是寫在run_phase嗎，現在怎麼移到build_phase
    // 用法不同，一個宣告一次就固定了，一個會一直跑一直宣告，各有各的好
    tr = transaction::type_id::create("tr");
    if(!uvm_config_db #(virtual clk_if)::get(this,"","vif",vif)) //uvm_test_top.env.agent.driver.vif
      `uvm_error("driver", "Unable to access Interface");
  endfunction

  virtual task run_phase(uvm_phase phase);
    // tr = transaction::type_id::create("tr");
    forever begin
      seq_item_port.get_next_item(tr);
      if (tr.oper == reset_asserted) begin
        vif.rst <= 1'b1;
        @(posedge vif.clk);
      end
      else if (tr.oper == random_baud) begin
        // in this case, we need to send our baud to our clock generator
        `uvm_info("DRV", $sformatf("Baud : %0d", tr.baud), UVM_NONE);
        vif.rst <= 1'b0;
        vif.baud <= tr.baud;
        // again wait for a positive edge of a clock, this is to make the delay equivalent in both if and else if block
        @(posedge vif.clk);
        // in a monitor and the scoreboard, we need to perform a computation of a clock period.
        // to achive that, we have added a weight of two positive edge of tx_clk
        // tx_clk is slow clock, vif.clk is fast clock
        @(posedge vif.tx_clk);
        @(posedge vif.tx_clk);
      end
      seq_item_port.item_done();
    end
  endtask
endclass

class mon extends uvm_monitor;
  `uvm_component_utils(mon)

  uvm_analysis_port #(transaction) send;
  transaction tr;
  virtual clk_if vif;
  // This will be mainly for sampling the period.
  real ton = 0;
  real toff = 0;

  function new(input string path = "mon", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr = transaction::type_id::create("tr");
    send = new("send", this);
    if(!uvm_config_db #(virtual clk_if)::get(this,"","vif",vif)) // uvm_test_top.env.agent.mon.vif
      `uvm_error("mon", "Unable to access Interface");
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      // in a driver we apply the stimulit then wait.
      // in a monitor we will be waiting and then collecting the response
      @(posedge vif.clk);
      if (vif.rst) begin
        tr.oper = reset_asserted;
        ton = 0;
        toff = 0;
        `uvm_info("MON", "SYSTEM RESET DETECTED", UVM_NONE);
        send.write(tr);
      end
      else begin
        tr.baud = vif.baud;
        tr.oper = random_baud;
        ton = 0;
        toff = 0;
        @(posedge vif.tx_clk);
        // we are calling a real time function, this allows us to sample the current simulation time and store it into ton,
        ton = $realtime;
        // or then we wait for the second positive edge of the clock
        @(posedge vif.tx_clk);
        toff = $realtime;
        tr.period = toff - ton;
        `uvm_info("MON", $sformatf("Baud : %0d Period : %0f", tr.baud, tr.period), UVM_NONE);
        // send the data to the scoreboard
        send.write(tr);
      end
    end
  endtask
endclass

class sco extends uvm_scoreboard;
  `uvm_component_utils(sco)

  real count = 0;
  real baudcount = 0;
  uvm_analysis_imp #(transaction,sco) recv;

  // transaction tr;

  function new(input string path = "sco", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // tr = transaction::type_id::create("tr");
    recv = new("recv", this);
  endfunction

  virtual function void write(transaction tr);
    count = tr.period / 20;
    baudcount = count;
    `uvm_info("SCO",$sformatf("BAUD : %0d, count : %0f, baudcount : %0f", tr.baud, count, baudcount), UVM_NONE);

    case(tr.baud)
        4800: begin
          if (baudcount == 10418)
            `uvm_info("SCO", "TEST PASSED", UVM_NONE)
          else
            `uvm_error("SCO", "TEST FAILED")
        end
        9600: begin
          if (baudcount == 5210) // 5208 + 2
            `uvm_info("SCO", "TEST PASSED", UVM_NONE)
          else
            `uvm_error("SCO", "TEST FAILED")
        end
        14400: begin
          if (baudcount == 3474)
            `uvm_info("SCO", "TEST PASSED", UVM_NONE)
          else
            `uvm_error("SCO", "TEST FAILED")
        end
        19200: begin
          if (baudcount == 2606)
            `uvm_info("SCO", "TEST PASSED", UVM_NONE)
          else
            `uvm_error("SCO", "TEST FAILED")
        end
        38400: begin
          if (baudcount == 1304)
            `uvm_info("SCO", "TEST PASSED", UVM_NONE)
          else
            `uvm_error("SCO", "TEST FAILED")
        end
        57600: begin
          if (baudcount == 870)
            `uvm_info("SCO", "TEST PASSED", UVM_NONE)
          else
            `uvm_error("SCO", "TEST FAILED")
        end
        // default: tx_max <= 14'5208;
      endcase
    $display("---------------------------------------------------");
  endfunction
endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent)

  function new(input string inst = "agent", uvm_component parent=null);
    super.new(inst, parent);
  endfunction

  mon m;
  driver d;
  uvm_sequencer #(transaction) seqr;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m = mon::type_id::create("m",this);
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

  agent a;
  sco s;
  // config_dff cfg;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a = agent::type_id::create("a",this);
    s = sco::type_id::create("s",this);
    // cfg = config_dff::type_id::create("cfg");
    // uvm_config_db #(config_dff)::set(this, "a", "cfg", cfg);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    a.m.send.connect(s.recv);
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test)

  env e;
  variable_baud vbar;
  reset_clk rclk;
  // generator gen;

  function new(input string inst = "test", uvm_component c);
    super.new(inst, c);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("env",this);
    vbar = variable_baud::type_id::create("vbar");
    rclk = reset_clk::type_id::create("rclk");
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    // start our sequence
    vbar.start(e.a.seqr);
    #20;
    phase.drop_objection(this);
  endtask
endclass


module tb();
  // when you add in interface in a test benchtop, we need to add parenthesis
  clk_if vif();
  clk_gen dut (.clk(vif.clk), .rst(vif.rst), .baud(vif.baud), .tx_clk(vif.tx_clk));

  initial begin
    vif.clk <= 0;
  end

  always #10 vif.clk <= ~vif.clk;

  initial begin
    uvm_config_db #(virtual clk_if)::set(null, "*", "vif", vif);
    run_test("test");
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(133) @ 0: uvm_test_top.env.a.d [DRV] Baud : 19200
// # KERNEL: UVM_INFO /home/runner/testbench.sv(195) @ 52130: uvm_test_top.env.a.m [MON] Baud : 19200 Period : 52120.000000
// # KERNEL: UVM_INFO /home/runner/testbench.sv(225) @ 52130: uvm_test_top.env.s [SCO] BAUD : 19200, count : 2606.000000, baudcount : 2606.000000
// # KERNEL: UVM_INFO /home/runner/testbench.sv(248) @ 52130: uvm_test_top.env.s [SCO] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(133) @ 52130: uvm_test_top.env.a.d [DRV] Baud : 57600
// # KERNEL: UVM_INFO /home/runner/testbench.sv(195) @ 86930: uvm_test_top.env.a.m [MON] Baud : 57600 Period : 17400.000000
// # KERNEL: UVM_INFO /home/runner/testbench.sv(225) @ 86930: uvm_test_top.env.s [SCO] BAUD : 57600, count : 870.000000, baudcount : 870.000000
// # KERNEL: UVM_INFO /home/runner/testbench.sv(260) @ 86930: uvm_test_top.env.s [SCO] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(133) @ 86930: uvm_test_top.env.a.d [DRV] Baud : 14400
// # KERNEL: UVM_INFO /home/runner/testbench.sv(195) @ 225890: uvm_test_top.env.a.m [MON] Baud : 14400 Period : 69480.000000
// # KERNEL: UVM_INFO /home/runner/testbench.sv(225) @ 225890: uvm_test_top.env.s [SCO] BAUD : 14400, count : 3474.000000, baudcount : 3474.000000
// # KERNEL: UVM_INFO /home/runner/testbench.sv(242) @ 225890: uvm_test_top.env.s [SCO] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(133) @ 225890: uvm_test_top.env.a.d [DRV] Baud : 38400
// # KERNEL: UVM_INFO /home/runner/testbench.sv(195) @ 278050: uvm_test_top.env.a.m [MON] Baud : 38400 Period : 26080.000000
// # KERNEL: UVM_INFO /home/runner/testbench.sv(225) @ 278050: uvm_test_top.env.s [SCO] BAUD : 38400, count : 1304.000000, baudcount : 1304.000000
// # KERNEL: UVM_INFO /home/runner/testbench.sv(254) @ 278050: uvm_test_top.env.s [SCO] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(133) @ 278050: uvm_test_top.env.a.d [DRV] Baud : 19200
// # KERNEL: UVM_INFO /home/runner/testbench.sv(195) @ 382290: uvm_test_top.env.a.m [MON] Baud : 19200 Period : 52120.000000
// # KERNEL: UVM_INFO /home/runner/testbench.sv(225) @ 382290: uvm_test_top.env.s [SCO] BAUD : 19200, count : 2606.000000, baudcount : 2606.000000
// # KERNEL: UVM_INFO /home/runner/testbench.sv(248) @ 382290: uvm_test_top.env.s [SCO] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_objection.svh(1271) @ 382310: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 382310: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :   23
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [DRV]     5
// # KERNEL: [MON]     5
// # KERNEL: [RNTST]     1
// # KERNEL: [SCO]    10
// # KERNEL: [TEST_DONE]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 382310 ns,  Iteration: 57,  Instance: /tb,  Process: @INITIAL#359_2@.
// # KERNEL: stopped at time: 382310 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Finding VCD file...
// ./dump.vcd
// [2024-08-18 08:34:45 UTC] Opening EPWave...
// Done