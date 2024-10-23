`include "uvm_macros.svh"
import uvm_pkg::*;


class transaction extends uvm_sequence_item;
  rand bit [3:0] a;
  rand bit [3:0] b;
  rand bit [3:0] c;
  rand bit [3:0] d;
  rand bit [1:0] sel;
  bit [3:0] y;

  function new(input string path = "transaction");
    super.new(path);
  endfunction

  `uvm_object_utils_begin(transaction)
    `uvm_field_int(a, UVM_DEFAULT)
    `uvm_field_int(b, UVM_DEFAULT)
    `uvm_field_int(c, UVM_DEFAULT)
    `uvm_field_int(d, UVM_DEFAULT)
    `uvm_field_int(sel, UVM_DEFAULT)
    `uvm_field_int(y, UVM_DEFAULT)
  `uvm_object_utils_end
endclass

class generator extends uvm_sequence #(transaction);
  `uvm_object_utils(generator)

  transaction tr;

  function new(input string path = "generator");
    super.new(path);
  endfunction

  virtual task body();
    repeat (15) begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      assert (tr.randomize());
      `uvm_info("SEQ", $sformatf("a:%0d  b:%0d c:%0d d:%0d sel:%0d y:%0d",
        tr.a, tr.b, tr.c, tr.d, tr.sel, tr.y), UVM_NONE);
      finish_item(tr);
    end
  endtask
endclass

class drv extends uvm_driver #(transaction);
  `uvm_component_utils(drv)

  transaction tr;
  virtual mux_if mif;

  function new(input string path = "drv", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual mux_if)::get(
            this, "", "mif", mif
        ))  //uvm_test_top.env.agent.drv.aif
      `uvm_error("drv", "Unable to access Interface");
  endfunction

  virtual task run_phase(uvm_phase phase);
    tr = transaction::type_id::create("tr");
    forever begin
      seq_item_port.get_next_item(tr);
      mif.a   <= tr.a;
      mif.b   <= tr.b;
      mif.c   <= tr.c;
      mif.d   <= tr.d;
      mif.sel <= tr.sel;
      `uvm_info("DRV", $sformatf("a:%0d  b:%0d c:%0d d:%0d sel:%0d y:%0d",
        tr.a, tr.b, tr.c, tr.d, tr.sel, tr.y), UVM_NONE);
      seq_item_port.item_done();
      #20;
    end
  endtask
endclass

class mon extends uvm_monitor;
  `uvm_component_utils(mon)

  uvm_analysis_port #(transaction) send;
  transaction tr;
  virtual mux_if mif;

  function new(input string inst = "mon", uvm_component parent = null);
    super.new(inst, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr   = transaction::type_id::create("tr");
    send = new("send", this);
    if (!uvm_config_db#(virtual mux_if)::get(
            this, "", "mif", mif
        ))  //uvm_test_top.env.agent.drv.aif
      `uvm_error("drv", "Unable to access Interface");
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      #20;
      tr.a   = mif.a;
      tr.b   = mif.b;
      tr.c   = mif.c;
      tr.d   = mif.d;
      tr.sel = mif.sel;
      tr.y   = mif.y;
      `uvm_info("MON_DUT", $sformatf("a:%0d  b:%0d c:%0d d:%0d sel:%0d y:%0d",
        tr.a, tr.b, tr.c, tr.d, tr.sel, tr.y), UVM_NONE);
      send.write(tr);
    end
  endtask
endclass

// reference model
class ref_model extends uvm_monitor;
  `uvm_component_utils(ref_model)

  uvm_analysis_port #(transaction) send_ref;
  transaction tr;
  virtual mux_if mif;

  function new(input string inst = "ref_model", uvm_component parent = null);
    super.new(inst, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr = transaction::type_id::create("tr");
    send_ref = new("send_ref", this);
    if (!uvm_config_db#(virtual mux_if)::get(this, "", "mif", mif)) // uvm_test_top.env.agent.drv.aif
      `uvm_error("ref_model", "Unable to access Interface");
  endfunction

  function void predict();
    case (tr.sel)
      2'b00: tr.y = tr.a;
      2'b01: tr.y = tr.b;
      2'b10: tr.y = tr.c;
      2'b11: tr.y = tr.d;
    endcase
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      #20;
      tr.a   = mif.a;
      tr.b   = mif.b;
      tr.c   = mif.c;
      tr.d   = mif.d;
      tr.sel = mif.sel;
      predict();
      `uvm_info("MON_REF", $sformatf("a:%0d  b:%0d c:%0d d:%0d sel:%0d y:%0d",
        tr.a, tr.b, tr.c, tr.d, tr.sel, tr.y), UVM_NONE);
      send_ref.write(tr);
    end
  endtask
endclass

class sco extends uvm_scoreboard;
  `uvm_component_utils(sco)

  transaction tr, trref;

  uvm_tlm_analysis_fifo #(transaction) sco_data;
  uvm_tlm_analysis_fifo #(transaction) sco_data_ref;

  function new(input string inst = "sco", uvm_component parent = null);
    super.new(inst, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr    = transaction::type_id::create("tr");
    trref = transaction::type_id::create("tr_ref");
    sco_data = new("sco_data", this);
    sco_data_ref = new("sco_data_ref", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      sco_data.get(tr);
      sco_data_ref.get(trref);

      if (tr.compare(trref)) `uvm_info("SCO", "Test Passed", UVM_NONE)
      else `uvm_info("SCO", "Test Failed", UVM_NONE)
    end
  endtask
endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent)

  function new(input string inst = "agent", uvm_component parent = null);
    super.new(inst, parent);
  endfunction

  drv d;
  uvm_sequencer #(transaction) seqr;
  mon m;
  ref_model mref;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    d    = drv::type_id::create("d",this);
    m    = mon::type_id::create("m",this);
    mref = ref_model::type_id::create("mref",this);
    seqr = uvm_sequencer#(transaction)::type_id::create("seqr", this);
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
  sco   s;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a = agent::type_id::create("agent", this);
    s = sco::type_id::create("sco", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    a.m.send.connect(s.sco_data.analysis_export);
    a.mref.send_ref.connect(s.sco_data_ref.analysis_export);
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
    e   = env::type_id::create("env", this);
    gen = generator::type_id::create("gen");
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    gen.start(e.a.seqr);
    #20;
    phase.drop_objection(this);
  endtask
endclass


module tb;

  mux_if mif ();

  mux dut (
      .a  (mif.a),
      .b  (mif.b),
      .c  (mif.c),
      .d  (mif.d),
      .sel(mif.sel),
      .y  (mif.y)
  );

  initial begin
    uvm_config_db#(virtual mux_if)::set(null, "*", "mif", mif);
    run_test("test");
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(52) @ 0: uvm_test_top.env.agent.seqr@@gen [SEQ] a:4  b:8 c:8 d:10 sel:3 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(88) @ 0: uvm_test_top.env.agent.d [DRV] a:4  b:8 c:8 d:10 sel:3 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(181) @ 20: uvm_test_top.env.agent.mref [MON_REF] a:4  b:8 c:8 d:10 sel:3 y:10
// # KERNEL: UVM_INFO /home/runner/testbench.sv(130) @ 20: uvm_test_top.env.agent.m [MON_DUT] a:4  b:8 c:8 d:10 sel:3 y:10
// # KERNEL: UVM_INFO /home/runner/testbench.sv(225) @ 20: uvm_test_top.env.sco [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(52) @ 20: uvm_test_top.env.agent.seqr@@gen [SEQ] a:1  b:1 c:13 d:11 sel:0 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(88) @ 20: uvm_test_top.env.agent.d [DRV] a:1  b:1 c:13 d:11 sel:0 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(181) @ 40: uvm_test_top.env.agent.mref [MON_REF] a:1  b:1 c:13 d:11 sel:0 y:1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(130) @ 40: uvm_test_top.env.agent.m [MON_DUT] a:1  b:1 c:13 d:11 sel:0 y:1
// # KERNEL: UVM_INFO /home/runner/testbench.sv(225) @ 40: uvm_test_top.env.sco [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(52) @ 40: uvm_test_top.env.agent.seqr@@gen [SEQ] a:11  b:3 c:7 d:13 sel:2 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(88) @ 40: uvm_test_top.env.agent.d [DRV] a:11  b:3 c:7 d:13 sel:2 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(181) @ 60: uvm_test_top.env.agent.mref [MON_REF] a:11  b:3 c:7 d:13 sel:2 y:7
// # KERNEL: UVM_INFO /home/runner/testbench.sv(130) @ 60: uvm_test_top.env.agent.m [MON_DUT] a:11  b:3 c:7 d:13 sel:2 y:7
// # KERNEL: UVM_INFO /home/runner/testbench.sv(225) @ 60: uvm_test_top.env.sco [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(52) @ 60: uvm_test_top.env.agent.seqr@@gen [SEQ] a:2  b:14 c:6 d:0 sel:1 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(88) @ 60: uvm_test_top.env.agent.d [DRV] a:2  b:14 c:6 d:0 sel:1 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(181) @ 80: uvm_test_top.env.agent.mref [MON_REF] a:2  b:14 c:6 d:0 sel:1 y:14
// # KERNEL: UVM_INFO /home/runner/testbench.sv(130) @ 80: uvm_test_top.env.agent.m [MON_DUT] a:2  b:14 c:6 d:0 sel:1 y:14
// # KERNEL: UVM_INFO /home/runner/testbench.sv(225) @ 80: uvm_test_top.env.sco [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(52) @ 80: uvm_test_top.env.agent.seqr@@gen [SEQ] a:6  b:2 c:10 d:4 sel:1 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(88) @ 80: uvm_test_top.env.agent.d [DRV] a:6  b:2 c:10 d:4 sel:1 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(181) @ 100: uvm_test_top.env.agent.mref [MON_REF] a:6  b:2 c:10 d:4 sel:1 y:2
// # KERNEL: UVM_INFO /home/runner/testbench.sv(130) @ 100: uvm_test_top.env.agent.m [MON_DUT] a:6  b:2 c:10 d:4 sel:1 y:2
// # KERNEL: UVM_INFO /home/runner/testbench.sv(225) @ 100: uvm_test_top.env.sco [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(52) @ 100: uvm_test_top.env.agent.seqr@@gen [SEQ] a:7  b:15 c:3 d:9 sel:2 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(88) @ 100: uvm_test_top.env.agent.d [DRV] a:7  b:15 c:3 d:9 sel:2 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(181) @ 120: uvm_test_top.env.agent.mref [MON_REF] a:7  b:15 c:3 d:9 sel:2 y:3
// # KERNEL: UVM_INFO /home/runner/testbench.sv(130) @ 120: uvm_test_top.env.agent.m [MON_DUT] a:7  b:15 c:3 d:9 sel:2 y:3
// # KERNEL: UVM_INFO /home/runner/testbench.sv(225) @ 120: uvm_test_top.env.sco [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(52) @ 120: uvm_test_top.env.agent.seqr@@gen [SEQ] a:5  b:5 c:1 d:15 sel:0 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(88) @ 120: uvm_test_top.env.agent.d [DRV] a:5  b:5 c:1 d:15 sel:0 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(181) @ 140: uvm_test_top.env.agent.mref [MON_REF] a:5  b:5 c:1 d:15 sel:0 y:5
// # KERNEL: UVM_INFO /home/runner/testbench.sv(130) @ 140: uvm_test_top.env.agent.m [MON_DUT] a:5  b:5 c:1 d:15 sel:0 y:5
// # KERNEL: UVM_INFO /home/runner/testbench.sv(225) @ 140: uvm_test_top.env.sco [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(52) @ 140: uvm_test_top.env.agent.seqr@@gen [SEQ] a:0  b:4 c:4 d:6 sel:3 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(88) @ 140: uvm_test_top.env.agent.d [DRV] a:0  b:4 c:4 d:6 sel:3 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(181) @ 160: uvm_test_top.env.agent.mref [MON_REF] a:0  b:4 c:4 d:6 sel:3 y:6
// # KERNEL: UVM_INFO /home/runner/testbench.sv(130) @ 160: uvm_test_top.env.agent.m [MON_DUT] a:0  b:4 c:4 d:6 sel:3 y:6
// # KERNEL: UVM_INFO /home/runner/testbench.sv(225) @ 160: uvm_test_top.env.sco [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(52) @ 160: uvm_test_top.env.agent.seqr@@gen [SEQ] a:8  b:12 c:12 d:14 sel:3 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(88) @ 160: uvm_test_top.env.agent.d [DRV] a:8  b:12 c:12 d:14 sel:3 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(181) @ 180: uvm_test_top.env.agent.mref [MON_REF] a:8  b:12 c:12 d:14 sel:3 y:14
// # KERNEL: UVM_INFO /home/runner/testbench.sv(130) @ 180: uvm_test_top.env.agent.m [MON_DUT] a:8  b:12 c:12 d:14 sel:3 y:14
// # KERNEL: UVM_INFO /home/runner/testbench.sv(225) @ 180: uvm_test_top.env.sco [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(52) @ 180: uvm_test_top.env.agent.seqr@@gen [SEQ] a:13  b:13 c:9 d:7 sel:0 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(88) @ 180: uvm_test_top.env.agent.d [DRV] a:13  b:13 c:9 d:7 sel:0 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(181) @ 200: uvm_test_top.env.agent.mref [MON_REF] a:13  b:13 c:9 d:7 sel:0 y:13
// # KERNEL: UVM_INFO /home/runner/testbench.sv(130) @ 200: uvm_test_top.env.agent.m [MON_DUT] a:13  b:13 c:9 d:7 sel:0 y:13
// # KERNEL: UVM_INFO /home/runner/testbench.sv(225) @ 200: uvm_test_top.env.sco [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(52) @ 200: uvm_test_top.env.agent.seqr@@gen [SEQ] a:15  b:7 c:11 d:1 sel:2 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(88) @ 200: uvm_test_top.env.agent.d [DRV] a:15  b:7 c:11 d:1 sel:2 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(181) @ 220: uvm_test_top.env.agent.mref [MON_REF] a:15  b:7 c:11 d:1 sel:2 y:11
// # KERNEL: UVM_INFO /home/runner/testbench.sv(130) @ 220: uvm_test_top.env.agent.m [MON_DUT] a:15  b:7 c:11 d:1 sel:2 y:11
// # KERNEL: UVM_INFO /home/runner/testbench.sv(225) @ 220: uvm_test_top.env.sco [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(52) @ 220: uvm_test_top.env.agent.seqr@@gen [SEQ] a:14  b:10 c:2 d:12 sel:1 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(88) @ 220: uvm_test_top.env.agent.d [DRV] a:14  b:10 c:2 d:12 sel:1 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(181) @ 240: uvm_test_top.env.agent.mref [MON_REF] a:14  b:10 c:2 d:12 sel:1 y:10
// # KERNEL: UVM_INFO /home/runner/testbench.sv(130) @ 240: uvm_test_top.env.agent.m [MON_DUT] a:14  b:10 c:2 d:12 sel:1 y:10
// # KERNEL: UVM_INFO /home/runner/testbench.sv(225) @ 240: uvm_test_top.env.sco [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(52) @ 240: uvm_test_top.env.agent.seqr@@gen [SEQ] a:10  b:6 c:14 d:8 sel:1 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(88) @ 240: uvm_test_top.env.agent.d [DRV] a:10  b:6 c:14 d:8 sel:1 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(181) @ 260: uvm_test_top.env.agent.mref [MON_REF] a:10  b:6 c:14 d:8 sel:1 y:6
// # KERNEL: UVM_INFO /home/runner/testbench.sv(130) @ 260: uvm_test_top.env.agent.m [MON_DUT] a:10  b:6 c:14 d:8 sel:1 y:6
// # KERNEL: UVM_INFO /home/runner/testbench.sv(225) @ 260: uvm_test_top.env.sco [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(52) @ 260: uvm_test_top.env.agent.seqr@@gen [SEQ] a:3  b:11 c:15 d:5 sel:2 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(88) @ 260: uvm_test_top.env.agent.d [DRV] a:3  b:11 c:15 d:5 sel:2 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(181) @ 280: uvm_test_top.env.agent.mref [MON_REF] a:3  b:11 c:15 d:5 sel:2 y:15
// # KERNEL: UVM_INFO /home/runner/testbench.sv(130) @ 280: uvm_test_top.env.agent.m [MON_DUT] a:3  b:11 c:15 d:5 sel:2 y:15
// # KERNEL: UVM_INFO /home/runner/testbench.sv(225) @ 280: uvm_test_top.env.sco [SCO] Test Passed
// # KERNEL: UVM_INFO /home/runner/testbench.sv(52) @ 280: uvm_test_top.env.agent.seqr@@gen [SEQ] a:9  b:9 c:5 d:3 sel:0 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(88) @ 280: uvm_test_top.env.agent.d [DRV] a:9  b:9 c:5 d:3 sel:0 y:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(181) @ 300: uvm_test_top.env.agent.mref [MON_REF] a:9  b:9 c:5 d:3 sel:0 y:9
// # KERNEL: UVM_INFO /home/runner/testbench.sv(130) @ 300: uvm_test_top.env.agent.m [MON_DUT] a:9  b:9 c:5 d:3 sel:0 y:9
// # KERNEL: UVM_INFO /home/runner/testbench.sv(225) @ 300: uvm_test_top.env.sco [SCO] Test Passed
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_objection.svh(1271) @ 300: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 300: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :   78
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [DRV]    15
// # KERNEL: [MON_DUT]    15
// # KERNEL: [MON_REF]    15
// # KERNEL: [RNTST]     1
// # KERNEL: [SCO]    15
// # KERNEL: [SEQ]    15
// # KERNEL: [TEST_DONE]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 300 ns,  Iteration: 56,  Instance: /tb,  Process: @INITIAL#331_0@.
// # KERNEL: stopped at time: 300 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done