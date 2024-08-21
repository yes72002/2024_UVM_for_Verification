// `timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

class uart_config extends uvm_object;
  `uvm_object_utils(uart_config)

  uvm_active_passive_enum is_active = UVM_ACTIVE;

  function new(input string path = "uart_config");
    super.new(path);
  endfunction
endclass

typedef enum bit [3:0] {rand_baud_1_stop = 0,  rand_length_1_stop = 1,  length5wp = 2,  length6wp = 3,  length7wp = 4,  length8wp = 5,  length5wop = 6,  length6wop = 7,  length7wop = 8,  length8wop = 9,  rand_baud_2_stop = 11,  rand_length_2_stop = 12} oper_mode;
  // these are the series of mode that we're going to verify.
  // length8wop = 10

class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction)

  // rand oper_mode op;
  oper_mode op;
      logic tx_start, rx_start;
      logic rst;
  rand logic [7:0] tx_data;
  rand logic [16:0] baud;
  rand logic [3:0] length;
  rand logic parity_type, parity_en;
      logic stop2;
      logic tx_done, rx_done, tx_err, rx_err;
      logic [7:0] rx_out;

  constraint baud_c {baud inside {4800, 9600, 14400, 19200, 38400, 57600};}
  constraint length_c {length inside {5, 6, 7, 8};}

  function new(input string path = "transaction");
    super.new(path);
  endfunction
endclass : transaction

// rand_baud_1_stop
class rand_baud extends uvm_sequence #(transaction);
  // random baud
  // fixed length = 8
  // parity enable
  // parity type: random
  // single stop
  `uvm_object_utils(rand_baud)

  transaction tr;

  function new(input string name = "rand_baud");
    super.new(name);
  endfunction

  virtual task body();
    repeat(5) begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize);
      tr.op = rand_baud_1_stop;
      tr.length = 8;
      tr.rst = 1'b0;
      tr.rx_start = 1'b1;
      tr.tx_start = 1'b1;
      tr.parity_en = 1'b1;
      tr.stop2 = 1'b0;
      finish_item(tr);
    end
  endtask
endclass

// rand_baud_2_stop
class rand_baud_with_stop extends uvm_sequence #(transaction);
  // random baud
  // fixed length = 8
  // parity enable
  // parity type: random
  // two stop
  `uvm_object_utils(rand_baud_with_stop)

  transaction tr;

  function new(input string name = "rand_baud_with_stop");
    super.new(name);
  endfunction

  virtual task body();
    repeat(5) begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize);
      tr.op = rand_baud_2_stop;
      tr.rst = 1'b0;
      tr.length = 8;
      tr.rx_start = 1'b1;
      tr.tx_start = 1'b1;
      tr.parity_en = 1'b1;
      tr.stop2 = 1'b1;
      finish_item(tr);
    end
  endtask
endclass

// length5wp
class rand_baud_len5p extends uvm_sequence #(transaction);
  // random baud
  // fixed length = 5
  // parity enable
  // parity type: random
  // one stop
  `uvm_object_utils(rand_baud_len5p)

  transaction tr;

  function new(input string name = "rand_baud_len5p");
    super.new(name);
  endfunction

  virtual task body();
    repeat(5) begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize);
      tr.op = length5wp;
      tr.rst = 1'b0;
      tr.tx_data = {3'b000, tr.tx_data[7:3]}; // the MSB site will be shift to right
      tr.length = 5;
      tr.rx_start = 1'b1;
      tr.tx_start = 1'b1;
      tr.parity_en = 1'b1;
      tr.stop2 = 1'b0;
      finish_item(tr);
    end
  endtask
endclass

// length6wp
class rand_baud_len6p extends uvm_sequence #(transaction);
  // random baud
  // fixed length = 6
  // parity enable
  // parity type: random
  // one stop
  `uvm_object_utils(rand_baud_len6p)

  transaction tr;

  function new(input string name = "rand_baud_len6p");
    super.new(name);
  endfunction

  virtual task body();
    repeat(5) begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize);
      tr.op = length6wp;
      tr.rst = 1'b0;
      tr.tx_data = {2'b00, tr.tx_data[7:2]};
      tr.length = 6;
      tr.rx_start = 1'b1;
      tr.tx_start = 1'b1;
      tr.parity_en = 1'b1;
      tr.stop2 = 1'b0;
      finish_item(tr);
    end
  endtask
endclass

// length7wp
class rand_baud_len7p extends uvm_sequence #(transaction);
  // random baud
  // fixed length = 7
  // parity enable
  // parity type: random
  // one stop
  `uvm_object_utils(rand_baud_len7p)

  transaction tr;

  function new(input string name = "rand_baud_len7p");
    super.new(name);
  endfunction

  virtual task body();
    repeat(5) begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize);
      tr.op = length7wp;
      tr.rst = 1'b0;
      tr.tx_data = {1'b0, tr.tx_data[7:1]};
      tr.length = 7;
      tr.rx_start = 1'b1;
      tr.tx_start = 1'b1;
      tr.parity_en = 1'b1;
      tr.stop2 = 1'b0;
      finish_item(tr);
    end
  endtask
endclass

// length8wp
class rand_baud_len8p extends uvm_sequence #(transaction);
  // random baud
  // fixed length = 8
  // parity enable
  // parity type: random
  // one stop
  `uvm_object_utils(rand_baud_len8p)

  transaction tr;

  function new(input string name = "rand_baud_len8p");
    super.new(name);
  endfunction

  virtual task body();
    repeat(5) begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize);
      tr.op = length8wp;
      tr.rst = 1'b0;
      tr.tx_data = tr.tx_data[7:0];
      tr.length = 8;
      tr.rx_start = 1'b1;
      tr.tx_start = 1'b1;
      tr.parity_en = 1'b1;
      tr.stop2 = 1'b0;
      finish_item(tr);
    end
  endtask
endclass

// length5wop
class rand_baud_len5 extends uvm_sequence #(transaction);
  // random baud
  // fixed length = 5
  // parity disable
  // parity type: random
  // one stop
  `uvm_object_utils(rand_baud_len5)

  transaction tr;

  function new(input string name = "rand_baud_len5");
    super.new(name);
  endfunction

  virtual task body();
    repeat(5) begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize);
      tr.op = length5wop;
      tr.rst = 1'b0;
      tr.tx_data = {3'b000, tr.tx_data[7:3]};
      tr.length = 5;
      tr.rx_start = 1'b1;
      tr.tx_start = 1'b1;
      tr.parity_en = 1'b0;
      tr.stop2 = 1'b0;
      finish_item(tr);
    end
  endtask
endclass

// length6wop
class rand_baud_len6 extends uvm_sequence #(transaction);
  // random baud
  // fixed length = 6
  // parity disable
  // parity type: random
  // one stop
  `uvm_object_utils(rand_baud_len6)

  transaction tr;

  function new(input string name = "rand_baud_len6");
    super.new(name);
  endfunction

  virtual task body();
    repeat(5) begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize);
      tr.op = length6wop;
      tr.rst = 1'b0;
      tr.tx_data = {2'b00, tr.tx_data[7:2]};
      tr.length = 6;
      tr.rx_start = 1'b1;
      tr.tx_start = 1'b1;
      tr.parity_en = 1'b0;
      tr.stop2 = 1'b0;
      finish_item(tr);
    end
  endtask
endclass

// length7wop
class rand_baud_len7 extends uvm_sequence #(transaction);
  // random baud
  // fixed length = 7
  // parity disable
  // parity type: random
  // one stop
  `uvm_object_utils(rand_baud_len7)

  transaction tr;

  function new(input string name = "rand_baud_len7");
    super.new(name);
  endfunction

  virtual task body();
    repeat(5) begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize);
      tr.op = length7wop;
      tr.rst = 1'b0;
      tr.tx_data = {1'b0, tr.tx_data[7:1]};
      tr.length = 7;
      tr.rx_start = 1'b1;
      tr.tx_start = 1'b1;
      tr.parity_en = 1'b0;
      tr.stop2 = 1'b0;
      finish_item(tr);
    end
  endtask
endclass

// length8wop
class rand_baud_len8 extends uvm_sequence #(transaction);
  // random baud
  // fixed length = 8
  // parity disable
  // parity type: random
  // one stop
  `uvm_object_utils(rand_baud_len8)

  transaction tr;

  function new(input string name = "rand_baud_len8");
    super.new(name);
  endfunction

  virtual task body();
    repeat(5) begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize);
      tr.op = length8wop;
      tr.rst = 1'b0;
      tr.tx_data = tr.tx_data[7:0];
      tr.length = 8;
      tr.rx_start = 1'b1;
      tr.tx_start = 1'b1;
      tr.parity_en = 1'b0;
      tr.stop2 = 1'b0;
      finish_item(tr);
    end
  endtask
endclass

class driver extends uvm_driver #(transaction);
  `uvm_component_utils(driver)

  transaction tr;
  virtual uart_if vif;

  function new(input string path = "drv", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr = transaction::type_id::create("tr");
    if(!uvm_config_db #(virtual uart_if)::get(this,"","vif",vif))
      `uvm_error("drv", "Unable to access Interface");
  endfunction

  task reset_dut();
    repeat(5) begin
      vif.rst <= 1'b1; // acitve high reset
      vif.tx_start <= 1'b0;
      vif.rx_start <= 1'b0;
      vif.tx_data <= 8'h00;
      vif.baud <= 16'h0;
      vif.length <= 4'h0;
      vif.parity_type <= 1'b0;
      vif.parity_en <= 1'b0;
      vif.stop2 <= 1'b0;
      `uvm_info("drv", "Syetem Reset: Start of Simulation", UVM_MEDIUM);
      @(posedge vif.clk);
    end
  endtask

  task drive();
    reset_dut();
    forever begin
      seq_item_port.get_next_item(tr);
      vif.rst         <= 1'b0;
      vif.tx_start    <= tr.tx_start;
      vif.rx_start    <= tr.rx_start;
      vif.tx_data     <= tr.tx_data;
      vif.baud        <= tr.baud;
      vif.length      <= tr.length;
      vif.parity_type <= tr.parity_type;
      vif.parity_en   <= tr.parity_en;
      vif.stop2       <= tr.stop2;
      `uvm_info("drv", $sformatf("baud: %0d, len: %0d, par_en: %0d, stop2: %0d, tx_data: %0d", tr.baud,tr.length,tr.parity_en,tr.stop2,tr.tx_data), UVM_NONE);
      @(posedge vif.clk);
      @(posedge vif.tx_done);
      @(posedge vif.rx_done);
      seq_item_port.item_done();
    end
  endtask
  virtual task run_phase(uvm_phase phase);
    drive();
  endtask
endclass

class mon extends uvm_monitor;
  `uvm_component_utils(mon)

  uvm_analysis_port #(transaction) send;
  transaction tr;
  virtual uart_if vif;

  function new(input string path = "mon", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr = transaction::type_id::create("tr");
    send = new("send", this);
    if(!uvm_config_db #(virtual uart_if)::get(this,"","vif",vif)) // uvm_test_top.env.agent.mon.vif
      `uvm_error("mon", "Unable to access Interface");
  endfunction

  virtual task run_phase(uvm_phase phase);
    // here the run_phase is a bit interesting
    forever begin
      // in a driver we apply the stimulit then wait.
      // in a monitor we will be waiting and then collecting the response
      // driver 是在最後等posedge vif.clk，而monitor會先來等posedge vif.clk
      // here we first to wait and tne start sampling the signals of the dut
      @(posedge vif.clk);
      if (vif.rst) begin
        tr.rst = 1'b1;
        `uvm_info("mon", "SYSTEM RESET DETECTED", UVM_NONE);
        send.write(tr);
      end
      else begin
        @(negedge vif.tx_done);
        tr.rst         = 1'b0;
        tr.tx_start    = vif.tx_start;
        tr.rx_start    = vif.rx_start;
        tr.tx_data     = vif.tx_data;
        tr.baud        = vif.baud;
        tr.length      = vif.length;
        tr.parity_type = vif.parity_type;
        tr.parity_en   = vif.parity_en;
        tr.stop2       = vif.stop2;
        @(negedge vif.rx_done);
        tr.rx_out      = vif.rx_out;
        `uvm_info("mon", $sformatf("baud: %0d, len: %0d, par_type: %0d, par_en: %0d, stop2: %0d, tx_data: %0d, rx_data: %0d", tr.baud,tr.length,tr.parity_type,tr.parity_en,tr.stop2,tr.tx_data,tr.rx_out), UVM_NONE);
        send.write(tr);
      end
    end
  endtask
endclass

class sco extends uvm_scoreboard;
  `uvm_component_utils(sco)

  uvm_analysis_imp #(transaction,sco) recv;

  function new(input string path = "sco", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv = new("recv", this);
  endfunction

  virtual function void write(transaction tr);
    // TODO
    // `uvm_info("sco", $sformatf("baud: %0d, len: %0d, par_type: %0d, par_en: %0d, stop2: %0d, tx_data: %0d, rx_out: %0d", tr.baud,tr.length,tr.parity_type,tr.parity_en,tr.stop2,tr.tx_data,tr.rx_out), UVM_NONE);
    `uvm_info("SCO", $sformatf("BAUD:%0d LEN:%0d PAR_T:%0d PAR_EN:%0d STOP:%0d TX_DATA:%0d RX_DATA:%0d", tr.baud, tr.length, tr.parity_type, tr.parity_en, tr.stop2, tr.tx_data, tr.rx_out), UVM_NONE);

    if (tr.rst == 1'b1)
      `uvm_info("sco", "Syetem Reset", UVM_NONE)
    else if (tr.tx_data == tr.rx_out)
      `uvm_info("sco", "Test Passed", UVM_NONE)
    else
      `uvm_info("sco", "Test Passed", UVM_NONE)
    $display("---------------------------------------------------");
  endfunction
endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent)
  uart_config cfg;

  function new(input string inst = "agent", uvm_component parent=null);
    super.new(inst, parent);
  endfunction

  mon m;
  driver d;
  uvm_sequencer #(transaction) seqr;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m = mon::type_id::create("m",this);
    cfg = uart_config::type_id::create("cfg");

    if (cfg.is_active == UVM_ACTIVE) begin
      d = driver::type_id::create("d",this);
      seqr = uvm_sequencer #(transaction)::type_id::create("seqr",this);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (cfg.is_active == UVM_ACTIVE) begin
      d.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env)

  function new(input string inst = "env", uvm_component c);
    super.new(inst, c);
  endfunction

  agent a;
  sco s;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a = agent::type_id::create("a",this);
    s = sco::type_id::create("s",this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    a.m.send.connect(s.recv);
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test)

  env e;
  rand_baud rb;
  rand_baud_with_stop rbs;
  rand_baud_len5p rb5l;
  rand_baud_len6p rb6l;
  rand_baud_len7p rb7l;
  rand_baud_len8p rb8l;
  rand_baud_len5 rb5lwop;
  rand_baud_len6 rb6lwop;
  rand_baud_len7 rb7lwop;
  rand_baud_len8 rb8lwop;
  // rand_baud_2_stop rand_baud_2_stop;
  // rand_length_2_stop rand_length_2_stop;

  function new(input string inst = "test", uvm_component c);
    super.new(inst, c);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("env",this);
    rb = rand_baud::type_id::create("rb");
    rbs = rand_baud_with_stop::type_id::create("rbs");
    rb5l = rand_baud_len5p::type_id::create("rb5l");
    rb6l = rand_baud_len6p::type_id::create("rb6l");
    rb7l = rand_baud_len7p::type_id::create("rb7l");
    rb8l = rand_baud_len8p::type_id::create("rb8l");
    rb5lwop = rand_baud_len5::type_id::create("rb5lwop");
    rb6lwop = rand_baud_len6::type_id::create("rb6lwop");
    rb7lwop = rand_baud_len7::type_id::create("rb7lwop");
    rb8lwop = rand_baud_len8::type_id::create("rb8lwop");
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    // start our sequence
    rb.start(e.a.seqr);
    #20;
    rbs.start(e.a.seqr);
    #20;
    phase.drop_objection(this);
  endtask
endclass


module tb();
  // when you add in interface in a test benchtop, we need to add parenthesis
  uart_if vif();
  uart_top dut (
    .clk(vif.clk),
    .rst(vif.rst),
    .tx_start(vif.tx_start),
    .rx_start(vif.rx_start),
    .tx_data(vif.tx_data),
    .baud(vif.baud),
    .length(vif.length),
    .parity_type(vif.parity_type),
    .parity_en(vif.parity_en),
    .stop2(vif.stop2),
    .tx_done(vif.tx_done),
    .rx_done(vif.rx_done),
    .tx_err(vif.tx_err),
    .rx_err(vif.rx_err),
    .rx_out(vif.rx_out)
  );

  initial begin
    vif.clk <= 0;
  end

  always #10 vif.clk <= ~vif.clk;

  initial begin
    uvm_config_db #(virtual uart_if)::set(null, "*", "vif", vif);
    run_test("test");
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule

