`include "uvm_macros.svh"
import uvm_pkg::*;

// configuration of env
class spi_config extends uvm_object;
  `uvm_object_utils(spi_config)

  function new(string name = "spi_config");
    super.new(name);
  endfunction

  uvm_active_passive_enum is_active = UVM_ACTIVE;
endclass

typedef enum bit [2:0] {
  readd = 0,
  writed = 1,
  rstdut = 2,
  writeerr = 3, // write with error
  readerr = 4  // read with error
} oper_mode;

class transaction extends uvm_sequence_item;
  rand oper_mode op;
  logic wr;
  logic rst;
  // randc indicate that we won't be able to see repetition in an address as long as we complete
  // all the possible addresses within the range.
  randc logic [7:0] addr;
  rand logic [7:0] din;
  logic [7:0] dout;
  logic done;
  logic err;

  `uvm_object_utils_begin(transaction)
    `uvm_field_int(wr, UVM_ALL_ON)
    `uvm_field_int(rst, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(din, UVM_ALL_ON)
    `uvm_field_int(dout, UVM_ALL_ON)
    `uvm_field_int(done, UVM_ALL_ON)
    `uvm_field_int(err, UVM_ALL_ON)
    `uvm_field_enum(oper_mode, op, UVM_DEFAULT)
  `uvm_object_utils_end

  constraint addr_c {addr <= 10;}
  constraint addr_c_err {addr > 31;}

  // uvm_object
  function new(string name = "transaction");
    super.new(name);
  endfunction
endclass : transaction

// write seq
class write_data extends uvm_sequence #(transaction);
  `uvm_object_utils(write_data)

  transaction tr;

  function new(string name = "write_data");
    super.new(name);
  endfunction

  virtual task body();
    repeat (15) begin
      tr = transaction::type_id::create("tr");
      // addr_c less than 10
      tr.addr_c.constraint_mode(1);
      tr.addr_c_err.constraint_mode(0);
      start_item(tr);
      assert (tr.randomize);
      tr.op = writed;
      finish_item(tr);
    end
  endtask
endclass

class write_err extends uvm_sequence #(transaction);
  `uvm_object_utils(write_err)

  transaction tr;

  function new(string name = "write_err");
    super.new(name);
  endfunction

  virtual task body();
    repeat (15) begin
      tr = transaction::type_id::create("tr");
      tr.addr_c_err.constraint_mode(1);
      // the only thing need to do is disable the first constraint
      tr.addr_c.constraint_mode(0);
      start_item(tr);
      assert (tr.randomize);
      tr.op = writed;
      finish_item(tr);
    end
  endtask
endclass

class read_data extends uvm_sequence #(transaction);
  `uvm_object_utils(read_data)

  transaction tr;

  function new(string name = "read_data");
    super.new(name);
  endfunction

  virtual task body();
    repeat (15) begin
      tr = transaction::type_id::create("tr");
      // turn on the valid constraint
      tr.addr_c.constraint_mode(1);
      // disable the error constraint
      tr.addr_c_err.constraint_mode(0);
      start_item(tr);
      assert (tr.randomize);
      tr.op = readd;
      finish_item(tr);
    end
  endtask
endclass

class read_err extends uvm_sequence #(transaction);
  `uvm_object_utils(read_err)

  transaction tr;

  function new(string name = "read_err");
    super.new(name);
  endfunction

  virtual task body();
    repeat (15) begin
      tr = transaction::type_id::create("tr");
      tr.addr_c.constraint_mode(0);
      tr.addr_c_err.constraint_mode(1);
      start_item(tr);
      assert (tr.randomize);
      tr.op = readd;
      finish_item(tr);
    end
  endtask
endclass

class reset_dut extends uvm_sequence #(transaction);
  `uvm_object_utils(reset_dut)

  transaction tr;

  function new(string name = "reset_dut");
    super.new(name);
  endfunction

  virtual task body();
    repeat (15) begin
      tr = transaction::type_id::create("tr");
      tr.addr_c.constraint_mode(1);
      tr.addr_c_err.constraint_mode(0);
      start_item(tr);
      assert (tr.randomize);
      tr.op = rstdut;
      finish_item(tr);
    end
  endtask
endclass

// sending the bulk write and read transaction
class writeb_readb extends uvm_sequence #(transaction);
  `uvm_object_utils(writeb_readb)

  transaction tr;

  function new(string name = "writeb_readb");
    super.new(name);
  endfunction

  virtual task body();
    repeat (10) begin
      tr = transaction::type_id::create("tr");
      tr.addr_c.constraint_mode(1);
      tr.addr_c_err.constraint_mode(0);
      start_item(tr);
      assert (tr.randomize);
      tr.op = writed;
      finish_item(tr);
    end
    repeat (10) begin
      tr = transaction::type_id::create("tr");
      tr.addr_c.constraint_mode(1);
      tr.addr_c_err.constraint_mode(0);
      start_item(tr);
      assert (tr.randomize);
      tr.op = readd;
      finish_item(tr);
    end
  endtask
endclass

class driver extends uvm_driver #(transaction);
  `uvm_component_utils(driver)

  virtual spi_i vif;
  transaction   tr;

  function new(input string path = "drv", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr = transaction::type_id::create("tr");

    if (!uvm_config_db#(virtual spi_i)::get(this, "", "vif", vif))  //uvm_test_top.env.agent.drv.aif
      `uvm_error("drv", "Unable to access Interface");
  endfunction

  task reset_dut();
    repeat (5) begin
      vif.rst  <= 1'b1;  // active high reset
      vif.addr <= 'h0;
      vif.din  <= 'h0;
      vif.wr   <= 1'b0;
      `uvm_info("DRV", "System Reset : Start of Simulation", UVM_MEDIUM);
      @(posedge vif.clk);
    end
  endtask

  task drive();
    reset_dut();
    forever begin
      // send the grant to a sequence
      seq_item_port.get_next_item(tr);

      if (tr.op == rstdut) begin
        vif.rst <= 1'b1;
        @(posedge vif.clk);
      end else if (tr.op == writed) begin
        vif.rst  <= 1'b0;
        vif.wr   <= 1'b1;
        vif.addr <= tr.addr;
        vif.din  <= tr.din;
        @(posedge vif.clk);
        `uvm_info("DRV", $sformatf("mode : Write addr:%0d din:%0d", vif.addr, vif.din), UVM_NONE);
        @(posedge vif.done);
      end else if (tr.op == readd) begin
        vif.rst  <= 1'b0;
        vif.wr   <= 1'b0;
        vif.addr <= tr.addr;
        vif.din  <= tr.din;
        @(posedge vif.clk);
        `uvm_info("DRV", $sformatf("mode : Read addr:%0d din:%0d", vif.addr, vif.din), UVM_NONE);
        // wait for operation to complete
        @(posedge vif.done);
      end
      // get new sequence
      seq_item_port.item_done();
    end
  endtask

  virtual task run_phase(uvm_phase phase);
    drive();
  endtask
endclass

class mon extends uvm_monitor;
  // opposite with driver
  `uvm_component_utils(mon)

  uvm_analysis_port #(transaction) send;
  transaction tr;
  virtual spi_i vif;

  function new(input string inst = "mon", uvm_component parent = null);
    super.new(inst, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr   = transaction::type_id::create("tr");
    send = new("send", this);
    if (!uvm_config_db#(virtual spi_i)::get(this, "", "vif", vif))  //uvm_test_top.env.agent.drv.aif
      `uvm_error("MON", "Unable to access Interface");
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.clk);
      if (vif.rst) begin
        tr.op = rstdut;
        `uvm_info("MON", "SYSTEM RESET DETECTED", UVM_NONE);
        send.write(tr);
      end else if (!vif.rst && vif.wr) begin
        @(posedge vif.done);
        tr.op   = writed;
        tr.din  = vif.din;
        tr.addr = vif.addr;
        tr.err  = vif.err;
        `uvm_info("MON", $sformatf("DATA WRITE addr:%0d data:%0d err:%0d", tr.addr, tr.din, tr.err), UVM_NONE);
        send.write(tr);
      end else if (!vif.rst && !vif.wr) begin
        @(posedge vif.done);
        tr.op   = readd;
        tr.addr = vif.addr;
        tr.err  = vif.err;
        tr.dout = vif.dout;
        `uvm_info("MON", $sformatf("DATA READ addr:%0d data:%0d slverr:%0d", tr.addr, tr.dout, tr.err), UVM_NONE);
        send.write(tr);
      end
    end
  endtask
endclass

class sco extends uvm_scoreboard;
  `uvm_component_utils(sco)

  uvm_analysis_imp #(transaction,sco) recv;
  bit [31:0] arr[32] = '{default:0};
  bit [31:0] addr    = 0;
  bit [31:0] data_rd = 0;

  function new(input string inst = "sco", uvm_component parent = null);
    super.new(inst, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv = new("recv", this);
  endfunction

  virtual function void write(transaction tr);
    if (tr.op == rstdut) begin
      `uvm_info("SCO", "SYSTEM RESET DETECTED", UVM_NONE);
    end else if (tr.op == writed) begin
      if (tr.err == 1'b1) begin
        `uvm_info("SCO", "SLV ERROR during WRITE OP", UVM_NONE);
      end else begin
        arr[tr.addr] = tr.din;
        `uvm_info("SCO", $sformatf("DATA WRITE OP addr:%0d, wdata:%0d arr_wr:%0d", tr.addr, tr.din, arr[tr.addr]), UVM_NONE);
      end
    end else if (tr.op == readd) begin
      if (tr.err == 1'b1) begin
        `uvm_info("SCO", "SLV ERROR during READ OP", UVM_NONE);
      end else begin
        data_rd = arr[tr.addr];
        if (data_rd == tr.dout)
          `uvm_info("SCO", $sformatf("DATA MATCHED : addr:%0d, rdata:%0d", tr.addr, tr.dout), UVM_NONE)
        else
          `uvm_info("SCO", $sformatf("TEST FAILED : addr:%0d, rdata:%0d data_rd_arr:%0d", tr.addr, tr.dout, data_rd), UVM_NONE)
      end
    end
    $display("----------------------------------------------------------------");
  endfunction
endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent)

  spi_config cfg;

  function new(input string inst = "agent", uvm_component parent = null);
    super.new(inst, parent);
  endfunction

  driver d;
  uvm_sequencer #(transaction) seqr;
  mon m;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cfg = spi_config::type_id::create("cfg");
    m   = mon::type_id::create("m", this);

    if (cfg.is_active == UVM_ACTIVE) begin
      d = driver::type_id::create("d", this);
      seqr = uvm_sequencer#(transaction)::type_id::create("seqr", this);
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
  sco   s;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a = agent::type_id::create("a", this);
    s = sco::type_id::create("s", this);
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
  write_data wdata;
  write_err werr;

  read_data rdata;
  read_err rerr;

  writeb_readb wrrdb;
  reset_dut rstdut;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // env belongs to uvm_component
    e      = env::type_id::create("env", this);
    // others belong to uvm_object
    wdata  = write_data::type_id::create("wdata");
    werr   = write_err::type_id::create("werr");
    rdata  = read_data::type_id::create("rdata");
    wrrdb  = writeb_readb::type_id::create("wrrdb");
    rerr   = read_err::type_id::create("rerr");
    rstdut = reset_dut::type_id::create("rstdut");
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    wrrdb.start(e.a.seqr);
    #20;
    phase.drop_objection(this);
  endtask
endclass

module tb;
  spi_i vif ();

  top dut (
      .wr  (vif.wr),
      .clk (vif.clk),
      .rst (vif.rst),
      .addr(vif.addr),
      .din (vif.din),
      .dout(vif.dout),
      .done(vif.done),
      .err (vif.err)
  );

  initial begin
    vif.clk <= 0;
  end

  always #10 vif.clk <= ~vif.clk;

  initial begin
    uvm_config_db#(virtual spi_i)::set(null, "*", "vif", vif);
    run_test("test");
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule


// UVM_INFO C:/Users/jimli/OneDrive - NVIDIA Corporation/NVIDIA/SystemVerilog/part2_class5_spi/project_u1_spi/project_u1_spi.srcs/sim_1/imports/part2_class4_uart/u3_spi_tb.sv(221) @ 0: uvm_test_top.env.a.d [DRV] System Reset : Start of Simulation
// UVM_INFO C:/Users/jimli/OneDrive - NVIDIA Corporation/NVIDIA/SystemVerilog/part2_class5_spi/project_u1_spi/project_u1_spi.srcs/sim_1/imports/part2_class4_uart/u3_spi_tb.sv(221) @ 10000: uvm_test_top.env.a.d [DRV] System Reset : Start of Simulation
// UVM_INFO C:/Users/jimli/OneDrive - NVIDIA Corporation/NVIDIA/SystemVerilog/part2_class5_spi/project_u1_spi/project_u1_spi.srcs/sim_1/imports/part2_class4_uart/u3_spi_tb.sv(284) @ 10000: uvm_test_top.env.a.m [MON] SYSTEM RESET DETECTED
// UVM_INFO C:/Users/jimli/OneDrive - NVIDIA Corporation/NVIDIA/SystemVerilog/part2_class5_spi/project_u1_spi/project_u1_spi.srcs/sim_1/imports/part2_class4_uart/u3_spi_tb.sv(328) @ 10000: uvm_test_top.env.s [SCO] SYSTEM RESET DETECTED
// ----------------------------------------------------------------


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(221) @ 0: uvm_test_top.env.a.d [DRV] System Reset : Start of Simulation
// # KERNEL: UVM_INFO /home/runner/testbench.sv(284) @ 10000: uvm_test_top.env.a.m [MON] SYSTEM RESET DETECTED
// # KERNEL: UVM_INFO /home/runner/testbench.sv(328) @ 10000: uvm_test_top.env.s [SCO] SYSTEM RESET DETECTED
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(221) @ 10000: uvm_test_top.env.a.d [DRV] System Reset : Start of Simulation
// # KERNEL: UVM_INFO /home/runner/testbench.sv(284) @ 30000: uvm_test_top.env.a.m [MON] SYSTEM RESET DETECTED
// # KERNEL: UVM_INFO /home/runner/testbench.sv(328) @ 30000: uvm_test_top.env.s [SCO] SYSTEM RESET DETECTED
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(221) @ 30000: uvm_test_top.env.a.d [DRV] System Reset : Start of Simulation
// # KERNEL: UVM_INFO /home/runner/testbench.sv(284) @ 50000: uvm_test_top.env.a.m [MON] SYSTEM RESET DETECTED
// # KERNEL: UVM_INFO /home/runner/testbench.sv(328) @ 50000: uvm_test_top.env.s [SCO] SYSTEM RESET DETECTED
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(221) @ 50000: uvm_test_top.env.a.d [DRV] System Reset : Start of Simulation
// # KERNEL: UVM_INFO /home/runner/testbench.sv(284) @ 70000: uvm_test_top.env.a.m [MON] SYSTEM RESET DETECTED
// # KERNEL: UVM_INFO /home/runner/testbench.sv(328) @ 70000: uvm_test_top.env.s [SCO] SYSTEM RESET DETECTED
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(221) @ 70000: uvm_test_top.env.a.d [DRV] System Reset : Start of Simulation
// # KERNEL: UVM_INFO /home/runner/testbench.sv(284) @ 90000: uvm_test_top.env.a.m [MON] SYSTEM RESET DETECTED
// # KERNEL: UVM_INFO /home/runner/testbench.sv(328) @ 90000: uvm_test_top.env.s [SCO] SYSTEM RESET DETECTED
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(240) @ 110000: uvm_test_top.env.a.d [DRV] mode : Write addr:4 din:234
// # KERNEL: UVM_INFO /home/runner/testbench.sv(293) @ 550000: uvm_test_top.env.a.m [MON] DATA WRITE addr:4 data:234 err:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(335) @ 550000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:4, wdata:234 arr_wr:234
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(240) @ 570000: uvm_test_top.env.a.d [DRV] mode : Write addr:8 din:39
// # KERNEL: UVM_INFO /home/runner/testbench.sv(293) @ 1010000: uvm_test_top.env.a.m [MON] DATA WRITE addr:8 data:39 err:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(335) @ 1010000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:8, wdata:39 arr_wr:39
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(240) @ 1030000: uvm_test_top.env.a.d [DRV] mode : Write addr:6 din:161
// # KERNEL: UVM_INFO /home/runner/testbench.sv(293) @ 1470000: uvm_test_top.env.a.m [MON] DATA WRITE addr:6 data:161 err:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(335) @ 1470000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:6, wdata:161 arr_wr:161
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(240) @ 1490000: uvm_test_top.env.a.d [DRV] mode : Write addr:10 din:88
// # KERNEL: UVM_INFO /home/runner/testbench.sv(293) @ 1930000: uvm_test_top.env.a.m [MON] DATA WRITE addr:10 data:88 err:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(335) @ 1930000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:10, wdata:88 arr_wr:88
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(240) @ 1950000: uvm_test_top.env.a.d [DRV] mode : Write addr:6 din:76
// # KERNEL: UVM_INFO /home/runner/testbench.sv(293) @ 2390000: uvm_test_top.env.a.m [MON] DATA WRITE addr:6 data:76 err:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(335) @ 2390000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:6, wdata:76 arr_wr:76
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(240) @ 2410000: uvm_test_top.env.a.d [DRV] mode : Write addr:9 din:209
// # KERNEL: UVM_INFO /home/runner/testbench.sv(293) @ 2850000: uvm_test_top.env.a.m [MON] DATA WRITE addr:9 data:209 err:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(335) @ 2850000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:9, wdata:209 arr_wr:209
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(240) @ 2870000: uvm_test_top.env.a.d [DRV] mode : Write addr:3 din:235
// # KERNEL: UVM_INFO /home/runner/testbench.sv(293) @ 3310000: uvm_test_top.env.a.m [MON] DATA WRITE addr:3 data:235 err:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(335) @ 3310000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:3, wdata:235 arr_wr:235
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(240) @ 3330000: uvm_test_top.env.a.d [DRV] mode : Write addr:8 din:150
// # KERNEL: UVM_INFO /home/runner/testbench.sv(293) @ 3770000: uvm_test_top.env.a.m [MON] DATA WRITE addr:8 data:150 err:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(335) @ 3770000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:8, wdata:150 arr_wr:150
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(240) @ 3790000: uvm_test_top.env.a.d [DRV] mode : Write addr:8 din:126
// # KERNEL: UVM_INFO /home/runner/testbench.sv(293) @ 4230000: uvm_test_top.env.a.m [MON] DATA WRITE addr:8 data:126 err:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(335) @ 4230000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:8, wdata:126 arr_wr:126
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(240) @ 4250000: uvm_test_top.env.a.d [DRV] mode : Write addr:1 din:255
// # KERNEL: UVM_INFO /home/runner/testbench.sv(293) @ 4690000: uvm_test_top.env.a.m [MON] DATA WRITE addr:1 data:255 err:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(335) @ 4690000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:1, wdata:255 arr_wr:255
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(248) @ 4710000: uvm_test_top.env.a.d [DRV] mode : Read addr:2 din:5
// # KERNEL: UVM_INFO /home/runner/testbench.sv(302) @ 5170000: uvm_test_top.env.a.m [MON] DATA READ addr:2 data:0 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(344) @ 5170000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:2, rdata:0
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(248) @ 5190000: uvm_test_top.env.a.d [DRV] mode : Read addr:1 din:108
// # KERNEL: UVM_INFO /home/runner/testbench.sv(302) @ 5650000: uvm_test_top.env.a.m [MON] DATA READ addr:1 data:255 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(344) @ 5650000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:1, rdata:255
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(248) @ 5670000: uvm_test_top.env.a.d [DRV] mode : Read addr:6 din:128
// # KERNEL: UVM_INFO /home/runner/testbench.sv(302) @ 6130000: uvm_test_top.env.a.m [MON] DATA READ addr:6 data:76 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(344) @ 6130000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:6, rdata:76
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(248) @ 6150000: uvm_test_top.env.a.d [DRV] mode : Read addr:7 din:153
// # KERNEL: UVM_INFO /home/runner/testbench.sv(302) @ 6610000: uvm_test_top.env.a.m [MON] DATA READ addr:7 data:0 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(344) @ 6610000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:7, rdata:0
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(248) @ 6630000: uvm_test_top.env.a.d [DRV] mode : Read addr:4 din:239
// # KERNEL: UVM_INFO /home/runner/testbench.sv(302) @ 7090000: uvm_test_top.env.a.m [MON] DATA READ addr:4 data:234 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(344) @ 7090000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:4, rdata:234
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(248) @ 7110000: uvm_test_top.env.a.d [DRV] mode : Read addr:5 din:242
// # KERNEL: UVM_INFO /home/runner/testbench.sv(302) @ 7570000: uvm_test_top.env.a.m [MON] DATA READ addr:5 data:0 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(344) @ 7570000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:5, rdata:0
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(248) @ 7590000: uvm_test_top.env.a.d [DRV] mode : Read addr:3 din:82
// # KERNEL: UVM_INFO /home/runner/testbench.sv(302) @ 8050000: uvm_test_top.env.a.m [MON] DATA READ addr:3 data:235 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(344) @ 8050000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:3, rdata:235
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(248) @ 8070000: uvm_test_top.env.a.d [DRV] mode : Read addr:4 din:95
// # KERNEL: UVM_INFO /home/runner/testbench.sv(302) @ 8530000: uvm_test_top.env.a.m [MON] DATA READ addr:4 data:234 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(344) @ 8530000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:4, rdata:234
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(248) @ 8550000: uvm_test_top.env.a.d [DRV] mode : Read addr:10 din:169
// # KERNEL: UVM_INFO /home/runner/testbench.sv(302) @ 9010000: uvm_test_top.env.a.m [MON] DATA READ addr:10 data:88 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(344) @ 9010000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:10, rdata:88
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(248) @ 9030000: uvm_test_top.env.a.d [DRV] mode : Read addr:7 din:48
// # KERNEL: UVM_INFO /home/runner/testbench.sv(302) @ 9490000: uvm_test_top.env.a.m [MON] DATA READ addr:7 data:0 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(344) @ 9490000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:7, rdata:0
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_objection.svh(1271) @ 9510000: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 9510000: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :   78
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [DRV]    25
// # KERNEL: [MON]    25
// # KERNEL: [RNTST]     1
// # KERNEL: [SCO]    25
// # KERNEL: [TEST_DONE]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 9510 ns,  Iteration: 58,  Instance: /tb,  Process: @INITIAL#465_2@.
// # KERNEL: stopped at time: 9510 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done