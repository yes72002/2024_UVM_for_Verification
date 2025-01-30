// `timescale 1ns / 1ps
// We will be hiding
`include "uvm_macros.svh"
import uvm_pkg::*;

class config_dff extends uvm_object;
  `uvm_object_utils(config_dff)

  uvm_active_passive_enum agent_type = UVM_ACTIVE;

  function new(input string path = "config_dff");
    super.new(path);
  endfunction
endclass

class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction)

  rand bit rst;
  rand bit din;
       bit dout;

  function new(input string path = "transaction");
    super.new(path);
  endfunction

  // `uvm_object_utils_begin(transaction)
  //   `uvm_field_int(a, UVM_DEFAULT)
  //   `uvm_field_int(b, UVM_DEFAULT)
  //   `uvm_field_int(y, UVM_DEFAULT)
  // `uvm_object_utils_end
endclass

class valid_din extends uvm_sequence #(transaction);

  `uvm_object_utils(valid_din)

  transaction tr;

  function new(input string path = "valid_din");
    super.new(path);
  endfunction

  virtual task body();
    repeat(15) begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize());
      tr.rst = 1'b0;
      `uvm_info("SEQ", $sformatf("rst = %0b, din = %0b, dout = %0b", tr.rst, tr.din, tr.dout), UVM_NONE);
      finish_item(tr);
    end
  endtask
endclass //valid_din extends uvm_sequence

class rst_dff extends uvm_sequence#(transaction);
  `uvm_object_utils(rst_dff)

  transaction tr;

  function new(input string path = "rst_dff");
    super.new(path);
  endfunction

  virtual task body();
    repeat(15) begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize());
      tr.rst = 1'b1;
      `uvm_info("SEQ", $sformatf("rst = %0b, din = %0b, dout = %0b", tr.rst, tr.din, tr.dout), UVM_NONE);
      finish_item(tr);
    end
  endtask
endclass //rst_dff extends uvm_sequence

class rand_din_rst extends uvm_sequence #(transaction);
  // randomly apply the reset and the value to our DFF
  `uvm_object_utils(rand_din_rst)

  transaction tr;

  function new(input string path = "rand_din_rst");
    super.new(path);
  endfunction

  virtual task body();
    repeat(15) begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize());
      `uvm_info("SEQ", $sformatf("rst = %0b, din = %0b, dout = %0b", tr.rst, tr.din, tr.dout), UVM_NONE);
      finish_item(tr);
    end
  endtask
endclass //rand_din_rst extends uvm_sequence

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

class drv extends uvm_driver #(transaction);
  `uvm_component_utils(drv)

  transaction tr;
  virtual dff_if dif;

  function new(input string path = "drv", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual dff_if)::get(this,"","dif",dif)) //uvm_test_top.env.agent.drv.dif
      `uvm_error("drv", "Unable to access Interface");
  endfunction

  virtual task run_phase(uvm_phase phase);
    tr = transaction::type_id::create("tr");
    forever begin
      seq_item_port.get_next_item(tr);
      dif.rst <= tr.rst;
      dif.din <= tr.din;
      `uvm_info("drv", $sformatf("rst = %0b, din = %0b, dout = %0b", tr.rst, tr.din, tr.dout), UVM_NONE);
      seq_item_port.item_done();
      // delay could also be added before seq_item_port.item_done()
      // this will wait for 2 clock before we actually send the new transaction to a DUT.
      repeat(2) @(posedge dif.clk);
      // #20;
    end
  endtask
endclass

class mon extends uvm_monitor;
  `uvm_component_utils(mon)

  uvm_analysis_port #(transaction) send;
  transaction tr;
  virtual dff_if dif;

  function new(input string path = "monitor", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr = transaction::type_id::create("tr");
    send = new("send", this);
    if(!uvm_config_db #(virtual dff_if)::get(this,"","dif",dif)) // uvm_test_top.env.agent.mon.dif
      `uvm_error("mon", "Unable to access Interface");
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      // the same delay in the driver
      repeat(2) @(posedge dif.clk);
      tr.rst = dif.rst;
      tr.din = dif.din;
      tr.dout = dif.dout;
      `uvm_info("mon", $sformatf("rst = %0b, din = %0b, dout = %0b", tr.rst, tr.din, tr.dout), UVM_NONE);
      send.write(tr);
    end
  endtask
endclass

class sco extends uvm_scoreboard;
  `uvm_component_utils(sco)

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
  `uvm_info("sco",$sformatf("rst = %0b, din = %0b, dout = %0b", tr.rst, tr.din, tr.dout), UVM_NONE)
    if(tr.rst == 1'b1)
      `uvm_info("SCO", "DFF Reset", UVM_NONE)
    else if (tr.rst == 1'b0 && (tr.din == tr.dout))
      `uvm_info("sco", "TEST PASSED", UVM_NONE)
    else
      `uvm_info("sco", "TEST FAILED", UVM_NONE)
    $display("---------------------------------------------------");
  endfunction
endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent)

  function new(input string inst = "agent", uvm_component parent=null);
    super.new(inst, parent);
  endfunction

  mon m;
  drv d;
  uvm_sequencer #(transaction) seqr;

  // we add an instance of our config class.
  config_dff cfg;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m = mon::type_id::create("m",this);
    cfg = config_dff::type_id::create("cfg");
    if (!uvm_config_db #(config_dff)::get(this,"","cfg", cfg))
      `uvm_error("agent", "Failed to access config");

    if (cfg.agent_type == UVM_ACTIVE) begin
      d = drv::type_id::create("d",this);
      seqr = uvm_sequencer #(transaction)::type_id::create("seqr",this);
    end
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
  config_dff cfg;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a = agent::type_id::create("a",this);
    s = sco::type_id::create("s",this);
    cfg = config_dff::type_id::create("cfg");
    // provide an access to an agent (a)
    uvm_config_db #(config_dff)::set(this, "a", "cfg", cfg);
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
  valid_din    vdin;
  rst_dff      rff;
  rand_din_rst rdin;
  // generator gen;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("e",this);
    vdin = valid_din::type_id::create("vdin");
    rff = rst_dff::type_id::create("rff");
    rdin = rand_din_rst::type_id::create("rdin");
    // gen = generator::type_id::create("gen");
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    // start our sequence
    rff.start(e.a.seqr);
    #40;
    vdin.start(e.a.seqr);
    #40;
    rdin.start(e.a.seqr);
    #40;
    // gen.start(e.a.seqr);
    // #20;
    phase.drop_objection(this);
  endtask
endclass


module tb();
  // when you add in interface in a test benchtop, we need to add parenthesis
  dff_if dif();
  dff dut (.clk(dif.clk), .rst(dif.rst), .din(dif.din), .dout(dif.dout));

  initial begin
    uvm_config_db #(virtual dff_if)::set(null, "*", "dif", dif);
    run_test("test");
  end

  initial begin
    dif.clk = 0;
  end

  always #10 dif.clk = ~dif.clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(71) @ 0: uvm_test_top.e.a.seqr@@rff [SEQ] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 0: uvm_test_top.e.a.d [drv] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 30: uvm_test_top.e.a.m [mon] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 30: uvm_test_top.e.s [sco] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(205) @ 30: uvm_test_top.e.s [SCO] DFF Reset
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(71) @ 30: uvm_test_top.e.a.seqr@@rff [SEQ] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 30: uvm_test_top.e.a.d [drv] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 70: uvm_test_top.e.a.m [mon] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 70: uvm_test_top.e.s [sco] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(205) @ 70: uvm_test_top.e.s [SCO] DFF Reset
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(71) @ 70: uvm_test_top.e.a.seqr@@rff [SEQ] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 70: uvm_test_top.e.a.d [drv] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 110: uvm_test_top.e.a.m [mon] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 110: uvm_test_top.e.s [sco] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(205) @ 110: uvm_test_top.e.s [SCO] DFF Reset
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(71) @ 110: uvm_test_top.e.a.seqr@@rff [SEQ] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 110: uvm_test_top.e.a.d [drv] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 150: uvm_test_top.e.a.m [mon] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 150: uvm_test_top.e.s [sco] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(205) @ 150: uvm_test_top.e.s [SCO] DFF Reset
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(71) @ 150: uvm_test_top.e.a.seqr@@rff [SEQ] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 150: uvm_test_top.e.a.d [drv] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 190: uvm_test_top.e.a.m [mon] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 190: uvm_test_top.e.s [sco] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(205) @ 190: uvm_test_top.e.s [SCO] DFF Reset
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(71) @ 190: uvm_test_top.e.a.seqr@@rff [SEQ] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 190: uvm_test_top.e.a.d [drv] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 230: uvm_test_top.e.a.m [mon] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 230: uvm_test_top.e.s [sco] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(205) @ 230: uvm_test_top.e.s [SCO] DFF Reset
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(71) @ 230: uvm_test_top.e.a.seqr@@rff [SEQ] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 230: uvm_test_top.e.a.d [drv] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 270: uvm_test_top.e.a.m [mon] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 270: uvm_test_top.e.s [sco] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(205) @ 270: uvm_test_top.e.s [SCO] DFF Reset
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(71) @ 270: uvm_test_top.e.a.seqr@@rff [SEQ] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 270: uvm_test_top.e.a.d [drv] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 310: uvm_test_top.e.a.m [mon] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 310: uvm_test_top.e.s [sco] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(205) @ 310: uvm_test_top.e.s [SCO] DFF Reset
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(71) @ 310: uvm_test_top.e.a.seqr@@rff [SEQ] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 310: uvm_test_top.e.a.d [drv] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 350: uvm_test_top.e.a.m [mon] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 350: uvm_test_top.e.s [sco] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(205) @ 350: uvm_test_top.e.s [SCO] DFF Reset
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(71) @ 350: uvm_test_top.e.a.seqr@@rff [SEQ] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 350: uvm_test_top.e.a.d [drv] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 390: uvm_test_top.e.a.m [mon] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 390: uvm_test_top.e.s [sco] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(205) @ 390: uvm_test_top.e.s [SCO] DFF Reset
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(71) @ 390: uvm_test_top.e.a.seqr@@rff [SEQ] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 390: uvm_test_top.e.a.d [drv] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 430: uvm_test_top.e.a.m [mon] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 430: uvm_test_top.e.s [sco] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(205) @ 430: uvm_test_top.e.s [SCO] DFF Reset
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(71) @ 430: uvm_test_top.e.a.seqr@@rff [SEQ] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 430: uvm_test_top.e.a.d [drv] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 470: uvm_test_top.e.a.m [mon] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 470: uvm_test_top.e.s [sco] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(205) @ 470: uvm_test_top.e.s [SCO] DFF Reset
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(71) @ 470: uvm_test_top.e.a.seqr@@rff [SEQ] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 470: uvm_test_top.e.a.d [drv] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 510: uvm_test_top.e.a.m [mon] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 510: uvm_test_top.e.s [sco] rst = 1, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(205) @ 510: uvm_test_top.e.s [SCO] DFF Reset
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(71) @ 510: uvm_test_top.e.a.seqr@@rff [SEQ] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 510: uvm_test_top.e.a.d [drv] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 550: uvm_test_top.e.a.m [mon] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 550: uvm_test_top.e.s [sco] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(205) @ 550: uvm_test_top.e.s [SCO] DFF Reset
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(71) @ 550: uvm_test_top.e.a.seqr@@rff [SEQ] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 550: uvm_test_top.e.a.d [drv] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 590: uvm_test_top.e.a.m [mon] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 590: uvm_test_top.e.s [sco] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(205) @ 590: uvm_test_top.e.s [SCO] DFF Reset
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(50) @ 590: uvm_test_top.e.a.seqr@@vdin [SEQ] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 590: uvm_test_top.e.a.d [drv] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 630: uvm_test_top.e.a.m [mon] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 630: uvm_test_top.e.s [sco] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(207) @ 630: uvm_test_top.e.s [sco] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(50) @ 630: uvm_test_top.e.a.seqr@@vdin [SEQ] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 630: uvm_test_top.e.a.d [drv] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 670: uvm_test_top.e.a.m [mon] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 670: uvm_test_top.e.s [sco] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(207) @ 670: uvm_test_top.e.s [sco] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(50) @ 670: uvm_test_top.e.a.seqr@@vdin [SEQ] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 670: uvm_test_top.e.a.d [drv] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 710: uvm_test_top.e.a.m [mon] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 710: uvm_test_top.e.s [sco] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(207) @ 710: uvm_test_top.e.s [sco] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(50) @ 710: uvm_test_top.e.a.seqr@@vdin [SEQ] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 710: uvm_test_top.e.a.d [drv] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 750: uvm_test_top.e.a.m [mon] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 750: uvm_test_top.e.s [sco] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(207) @ 750: uvm_test_top.e.s [sco] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(50) @ 750: uvm_test_top.e.a.seqr@@vdin [SEQ] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 750: uvm_test_top.e.a.d [drv] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 790: uvm_test_top.e.a.m [mon] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 790: uvm_test_top.e.s [sco] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(207) @ 790: uvm_test_top.e.s [sco] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(50) @ 790: uvm_test_top.e.a.seqr@@vdin [SEQ] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 790: uvm_test_top.e.a.d [drv] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 830: uvm_test_top.e.a.m [mon] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 830: uvm_test_top.e.s [sco] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(207) @ 830: uvm_test_top.e.s [sco] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(50) @ 830: uvm_test_top.e.a.seqr@@vdin [SEQ] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 830: uvm_test_top.e.a.d [drv] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 870: uvm_test_top.e.a.m [mon] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 870: uvm_test_top.e.s [sco] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(207) @ 870: uvm_test_top.e.s [sco] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(50) @ 870: uvm_test_top.e.a.seqr@@vdin [SEQ] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 870: uvm_test_top.e.a.d [drv] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 910: uvm_test_top.e.a.m [mon] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 910: uvm_test_top.e.s [sco] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(207) @ 910: uvm_test_top.e.s [sco] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(50) @ 910: uvm_test_top.e.a.seqr@@vdin [SEQ] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 910: uvm_test_top.e.a.d [drv] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 950: uvm_test_top.e.a.m [mon] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 950: uvm_test_top.e.s [sco] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(207) @ 950: uvm_test_top.e.s [sco] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(50) @ 950: uvm_test_top.e.a.seqr@@vdin [SEQ] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 950: uvm_test_top.e.a.d [drv] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 990: uvm_test_top.e.a.m [mon] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 990: uvm_test_top.e.s [sco] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(207) @ 990: uvm_test_top.e.s [sco] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(50) @ 990: uvm_test_top.e.a.seqr@@vdin [SEQ] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 990: uvm_test_top.e.a.d [drv] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 1030: uvm_test_top.e.a.m [mon] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 1030: uvm_test_top.e.s [sco] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(207) @ 1030: uvm_test_top.e.s [sco] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(50) @ 1030: uvm_test_top.e.a.seqr@@vdin [SEQ] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 1030: uvm_test_top.e.a.d [drv] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 1070: uvm_test_top.e.a.m [mon] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 1070: uvm_test_top.e.s [sco] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(207) @ 1070: uvm_test_top.e.s [sco] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(50) @ 1070: uvm_test_top.e.a.seqr@@vdin [SEQ] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 1070: uvm_test_top.e.a.d [drv] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 1110: uvm_test_top.e.a.m [mon] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 1110: uvm_test_top.e.s [sco] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(207) @ 1110: uvm_test_top.e.s [sco] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(50) @ 1110: uvm_test_top.e.a.seqr@@vdin [SEQ] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 1110: uvm_test_top.e.a.d [drv] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 1150: uvm_test_top.e.a.m [mon] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 1150: uvm_test_top.e.s [sco] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(207) @ 1150: uvm_test_top.e.s [sco] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(50) @ 1150: uvm_test_top.e.a.seqr@@vdin [SEQ] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 1150: uvm_test_top.e.a.d [drv] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 1190: uvm_test_top.e.a.m [mon] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 1190: uvm_test_top.e.s [sco] rst = 0, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(207) @ 1190: uvm_test_top.e.s [sco] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(92) @ 1190: uvm_test_top.e.a.seqr@@rdin [SEQ] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 1190: uvm_test_top.e.a.d [drv] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 1230: uvm_test_top.e.a.m [mon] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 1230: uvm_test_top.e.s [sco] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(205) @ 1230: uvm_test_top.e.s [SCO] DFF Reset
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(92) @ 1230: uvm_test_top.e.a.seqr@@rdin [SEQ] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 1230: uvm_test_top.e.a.d [drv] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 1270: uvm_test_top.e.a.m [mon] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 1270: uvm_test_top.e.s [sco] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(207) @ 1270: uvm_test_top.e.s [sco] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(92) @ 1270: uvm_test_top.e.a.seqr@@rdin [SEQ] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 1270: uvm_test_top.e.a.d [drv] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 1310: uvm_test_top.e.a.m [mon] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 1310: uvm_test_top.e.s [sco] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(207) @ 1310: uvm_test_top.e.s [sco] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(92) @ 1310: uvm_test_top.e.a.seqr@@rdin [SEQ] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 1310: uvm_test_top.e.a.d [drv] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 1350: uvm_test_top.e.a.m [mon] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 1350: uvm_test_top.e.s [sco] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(205) @ 1350: uvm_test_top.e.s [SCO] DFF Reset
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(92) @ 1350: uvm_test_top.e.a.seqr@@rdin [SEQ] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 1350: uvm_test_top.e.a.d [drv] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 1390: uvm_test_top.e.a.m [mon] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 1390: uvm_test_top.e.s [sco] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(205) @ 1390: uvm_test_top.e.s [SCO] DFF Reset
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(92) @ 1390: uvm_test_top.e.a.seqr@@rdin [SEQ] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 1390: uvm_test_top.e.a.d [drv] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 1430: uvm_test_top.e.a.m [mon] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 1430: uvm_test_top.e.s [sco] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(207) @ 1430: uvm_test_top.e.s [sco] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(92) @ 1430: uvm_test_top.e.a.seqr@@rdin [SEQ] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 1430: uvm_test_top.e.a.d [drv] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 1470: uvm_test_top.e.a.m [mon] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 1470: uvm_test_top.e.s [sco] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(207) @ 1470: uvm_test_top.e.s [sco] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(92) @ 1470: uvm_test_top.e.a.seqr@@rdin [SEQ] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 1470: uvm_test_top.e.a.d [drv] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 1510: uvm_test_top.e.a.m [mon] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 1510: uvm_test_top.e.s [sco] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(205) @ 1510: uvm_test_top.e.s [SCO] DFF Reset
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(92) @ 1510: uvm_test_top.e.a.seqr@@rdin [SEQ] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 1510: uvm_test_top.e.a.d [drv] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 1550: uvm_test_top.e.a.m [mon] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 1550: uvm_test_top.e.s [sco] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(205) @ 1550: uvm_test_top.e.s [SCO] DFF Reset
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(92) @ 1550: uvm_test_top.e.a.seqr@@rdin [SEQ] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 1550: uvm_test_top.e.a.d [drv] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 1590: uvm_test_top.e.a.m [mon] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 1590: uvm_test_top.e.s [sco] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(207) @ 1590: uvm_test_top.e.s [sco] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(92) @ 1590: uvm_test_top.e.a.seqr@@rdin [SEQ] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 1590: uvm_test_top.e.a.d [drv] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 1630: uvm_test_top.e.a.m [mon] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 1630: uvm_test_top.e.s [sco] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(207) @ 1630: uvm_test_top.e.s [sco] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(92) @ 1630: uvm_test_top.e.a.seqr@@rdin [SEQ] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 1630: uvm_test_top.e.a.d [drv] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 1670: uvm_test_top.e.a.m [mon] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 1670: uvm_test_top.e.s [sco] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(205) @ 1670: uvm_test_top.e.s [SCO] DFF Reset
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(92) @ 1670: uvm_test_top.e.a.seqr@@rdin [SEQ] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 1670: uvm_test_top.e.a.d [drv] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 1710: uvm_test_top.e.a.m [mon] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 1710: uvm_test_top.e.s [sco] rst = 1, din = 0, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(205) @ 1710: uvm_test_top.e.s [SCO] DFF Reset
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(92) @ 1710: uvm_test_top.e.a.seqr@@rdin [SEQ] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 1710: uvm_test_top.e.a.d [drv] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 1750: uvm_test_top.e.a.m [mon] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 1750: uvm_test_top.e.s [sco] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(207) @ 1750: uvm_test_top.e.s [sco] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(92) @ 1750: uvm_test_top.e.a.seqr@@rdin [SEQ] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(143) @ 1750: uvm_test_top.e.a.d [drv] rst = 0, din = 1, dout = 0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(179) @ 1790: uvm_test_top.e.a.m [mon] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(203) @ 1790: uvm_test_top.e.s [sco] rst = 0, din = 1, dout = 1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(207) @ 1790: uvm_test_top.e.s [sco] TEST PASSED
// # KERNEL: ---------------------------------------------------
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_objection.svh(1271) @ 1790: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 1790: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :  228
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [RNTST]     1
// # KERNEL: [SCO]    22
// # KERNEL: [SEQ]    45
// # KERNEL: [TEST_DONE]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL: [drv]    45
// # KERNEL: [mon]    45
// # KERNEL: [sco]    68
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 1790 ns,  Iteration: 57,  Instance: /tb,  Process: @INITIAL#315_0@.
// # KERNEL: stopped at time: 1790 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Finding VCD file...
// ./dump.vcd
// [2024-08-17 07:19:54 UTC] Opening EPWave...
// Done