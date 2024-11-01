`timescale 1ns / 1ps

/*
module tb();

  reg presetn = 0;
  reg pclk = 0;
  reg psel = 0;
  reg penable = 0 ;
  reg pwrite = 0;
  reg [31:0] paddr = 0, pwdata = 0;
  wire [31:0] prdata;
  wire pready, pslverr;

  apb_ram dut (presetn, pclk, psel, penable, pwrite, paddr, pwdata, prdata, pready, pslverr);

  always #10 pclk = ~pclk;

  initial begin
   presetn = 0;
   repeat(5) @(posedge pclk);
   presetn = 1;
   psel = 1;
   pwrite = 1;
   paddr = 12;
   pwdata = 35;
   @(posedge pclk);
   penable = 1;
   @(posedge pready);
   psel = 0;
   penable = 0;
   @(posedge pclk);
   psel = 1;
   pwrite = 1'b0;
   paddr = 12;
   pwdata = 35;
   @(posedge pclk);
   penable = 1'b1;
   @(posedge pready);
   psel = 0;
   penable = 0;
   @(posedge pclk);
   psel = 1;
   pwrite = 1;
   paddr = 45;
   pwdata = 35;
   @(posedge pclk);
   penable = 1;
   @(posedge pready);
   psel = 0;
   penable = 0;
   @(posedge pclk);
   psel = 1;
   pwrite = 0;
   paddr = 45;
   pwdata = 35;
   @(posedge pclk);
   penable = 1;
   @(posedge pready);
   @(posedge pclk);
   $stop();
  end


endmodule

*/

`include "uvm_macros.svh"
import uvm_pkg::*;


////////////////////////////////////////////////////////////////////////////////////
class abp_config extends uvm_object;  /////configuration of env
  `uvm_object_utils(abp_config)

  function new(string name = "abp_config");
    super.new(name);
  endfunction



  uvm_active_passive_enum is_active = UVM_ACTIVE;


endclass

///////////////////////////////////////////////////////


typedef enum bit [1:0] {
  readd = 0,
  writed = 1,
  rst = 2
} oper_mode;
//////////////////////////////////////////////////////////////////////////////////

class transaction extends uvm_sequence_item;




  rand oper_mode          op;
  rand logic              PWRITE;
  rand logic     [31 : 0] PWDATA;
  rand logic     [31 : 0] PADDR;

  // Output Signals of DUT for APB UART's transaction
  logic                   PREADY;
  logic                   PSLVERR;
  logic          [31 : 0] PRDATA;

  `uvm_object_utils_begin(transaction)
    `uvm_field_int(PWRITE, UVM_ALL_ON)
    `uvm_field_int(PWDATA, UVM_ALL_ON)
    `uvm_field_int(PADDR, UVM_ALL_ON)
    `uvm_field_int(PREADY, UVM_ALL_ON)
    `uvm_field_int(PSLVERR, UVM_ALL_ON)
    `uvm_field_int(PRDATA, UVM_ALL_ON)
    `uvm_field_enum(oper_mode, op, UVM_DEFAULT)
  `uvm_object_utils_end

  constraint addr_c {PADDR <= 31;}
  constraint addr_c_err {PADDR > 31;}

  function new(string name = "transaction");
    super.new(name);
  endfunction

endclass : transaction

///////////////////////////////////////////////////////////////
/*
module tb;


  transaction tr;

  initial begin
    tr = transaction::type_id::create("tr");
    tr.randomize();
    tr.print();
  end

endmodule
*/
//////////////////////////////////////////////////////////////////
///////////////////write seq
class write_data extends uvm_sequence #(transaction);
  `uvm_object_utils(write_data)

  transaction tr;

  function new(string name = "write_data");
    super.new(name);
  endfunction

  virtual task body();
    repeat (15) begin
      tr = transaction::type_id::create("tr");
      tr.addr_c.constraint_mode(1);  //enable
      tr.addr_c_err.constraint_mode(0);  //disable
      start_item(tr);
      assert (tr.randomize);
      tr.op = writed;
      finish_item(tr);
    end
  endtask


endclass
//////////////////////////////////////////////////////////
////////////////////////read seq
class read_data extends uvm_sequence #(transaction);
  `uvm_object_utils(read_data)

  transaction tr;

  function new(string name = "read_data");
    super.new(name);
  endfunction

  virtual task body();
    repeat (15) begin
      tr = transaction::type_id::create("tr");
      tr.addr_c.constraint_mode(1);
      tr.addr_c_err.constraint_mode(0);  //disable
      start_item(tr);
      assert (tr.randomize);
      tr.op = readd;
      finish_item(tr);
    end
  endtask


endclass



/////////////////////////////////////////////

class write_read extends uvm_sequence #(transaction);  //////read after write
  `uvm_object_utils(write_read)

  transaction tr;

  function new(string name = "write_read");
    super.new(name);
  endfunction

  virtual task body();
    repeat (15) begin
      tr = transaction::type_id::create("tr");
      tr.addr_c.constraint_mode(1);
      tr.addr_c_err.constraint_mode(0);

      start_item(tr);
      assert (tr.randomize);
      tr.op = writed;
      finish_item(tr);

      start_item(tr);
      assert (tr.randomize);
      tr.op = readd;
      finish_item(tr);

    end
  endtask


endclass
///////////////////////////////////////////////////////
///////////////write bulk read bulk
class writeb_readb extends uvm_sequence #(transaction);
  `uvm_object_utils(writeb_readb)

  transaction tr;

  function new(string name = "writeb_readb");
    super.new(name);
  endfunction

  virtual task body();

    repeat (15) begin
      tr = transaction::type_id::create("tr");
      tr.addr_c.constraint_mode(1);
      tr.addr_c_err.constraint_mode(0);

      start_item(tr);
      assert (tr.randomize);
      tr.op = writed;
      finish_item(tr);


    end


    repeat (15) begin
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

/////////////////////////////////////////////////////////////////
//////////////////////slv_error_write
class write_err extends uvm_sequence #(transaction);
  `uvm_object_utils(write_err)

  transaction tr;

  function new(string name = "write_err");
    super.new(name);
  endfunction

  virtual task body();
    repeat (15) begin
      tr = transaction::type_id::create("tr");
      tr.addr_c.constraint_mode(0);
      tr.addr_c_err.constraint_mode(1);

      start_item(tr);
      assert (tr.randomize);
      tr.op = writed;
      finish_item(tr);
    end
  endtask


endclass
///////////////////////////////////////////////////////////////
/////////////////////////read err


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

///////////////////////////////////////////////////////////////

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
      tr.op = rst;
      finish_item(tr);
    end
  endtask


endclass



////////////////////////////////////////////////////////////
class driver extends uvm_driver #(transaction);
  `uvm_component_utils(driver)

  virtual apb_if vif;
  transaction tr;


  function new(input string path = "drv", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr = transaction::type_id::create("tr");

    if (!uvm_config_db#(virtual apb_if)::get(
            this, "", "vif", vif
        ))  //uvm_test_top.env.agent.drv.aif
      `uvm_error("drv", "Unable to access Interface");
  endfunction



  task reset_dut();

    repeat (5) begin
      vif.presetn <= 1'b0;
      vif.paddr   <= 'h0;
      vif.pwdata  <= 'h0;
      vif.pwrite  <= 'b0;
      vif.psel    <= 'b0;
      vif.penable <= 'b0;
      `uvm_info("DRV", "System Reset : Start of Simulation", UVM_MEDIUM);
      @(posedge vif.pclk);
    end
  endtask

  task drive();
    reset_dut();
    // call forever begin, because we need to be always ready to receive the data from a sequencer.
    forever begin

      seq_item_port.get_next_item(tr);


      if (tr.op == rst) begin
        vif.presetn <= 1'b0;
        vif.paddr   <= 'h0;
        vif.pwdata  <= 'h0;
        vif.pwrite  <= 'b0;
        vif.psel    <= 'b0;
        vif.penable <= 'b0;
        @(posedge vif.pclk);
      end else if (tr.op == writed) begin
        vif.psel    <= 1'b1;
        vif.paddr   <= tr.PADDR;
        vif.pwdata  <= tr.PWDATA;
        vif.presetn <= 1'b1;
        vif.pwrite  <= 1'b1;
        @(posedge vif.pclk);
        vif.penable <= 1'b1;
        `uvm_info("DRV", $sformatf("mode:%0s, addr:%0d, wdata:%0d, rdata:%0d, slverr:%0d",
          tr.op.name(), tr.PADDR, tr.PWDATA, tr.PRDATA, tr.PSLVERR), UVM_NONE);
        @(negedge vif.pready);
        vif.penable <= 1'b0;
        tr.PSLVERR = vif.pslverr;

      end else if (tr.op == readd) begin
        vif.psel    <= 1'b1;
        vif.paddr   <= tr.PADDR;
        vif.presetn <= 1'b1;
        vif.pwrite  <= 1'b0;
        @(posedge vif.pclk);
        vif.penable <= 1'b1;
        `uvm_info("DRV", $sformatf("mode:%0s, addr:%0d, wdata:%0d, rdata:%0d, slverr:%0d",
          tr.op.name(), tr.PADDR, tr.PWDATA, tr.PRDATA, tr.PSLVERR), UVM_NONE);
        @(negedge vif.pready);
        vif.penable <= 1'b0;
        tr.PRDATA  = vif.prdata;
        tr.PSLVERR = vif.pslverr;
      end
      // notify the sequencer to send the next transaction.
      seq_item_port.item_done();
    end
  endtask

  virtual task run_phase(uvm_phase phase);
    drive();
  endtask

endclass

//////////////////////////////////////////////////////////////////

class mon extends uvm_monitor;
  `uvm_component_utils(mon)

  uvm_analysis_port #(transaction) send;
  transaction tr;
  virtual apb_if vif;

  function new(input string inst = "mon", uvm_component parent = null);
    super.new(inst, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr   = transaction::type_id::create("tr");
    send = new("send", this);
    if (!uvm_config_db#(virtual apb_if)::get(
            this, "", "vif", vif
        ))  //uvm_test_top.env.agent.drv.aif
      `uvm_error("MON", "Unable to access Interface");
  endfunction


  virtual task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.pclk);
      if (!vif.presetn) begin
        tr.op = rst;
        `uvm_info("MON", "SYSTEM RESET DETECTED", UVM_NONE);
        send.write(tr);
      end else if (vif.presetn && vif.pwrite) begin
        @(negedge vif.pready);
        tr.op      = writed;
        tr.PWDATA  = vif.pwdata;
        tr.PADDR   = vif.paddr;
        tr.PSLVERR = vif.pslverr;
        `uvm_info("MON", $sformatf("DATA WRITE addr:%0d data:%0d slverr:%0d", tr.PADDR, tr.PWDATA,
                                   tr.PSLVERR), UVM_NONE);
        send.write(tr);
      end else if (vif.presetn && !vif.pwrite) begin
        @(negedge vif.pready);
        tr.op      = readd;
        tr.PADDR   = vif.paddr;
        tr.PRDATA  = vif.prdata;
        tr.PSLVERR = vif.pslverr;
        `uvm_info("MON", $sformatf("DATA READ addr:%0d data:%0d slverr:%0d", tr.PADDR, tr.PRDATA,
                                   tr.PSLVERR), UVM_NONE);
        send.write(tr);
      end

    end
  endtask

endclass

/////////////////////////////////////////////////////////////////////


class sco extends uvm_scoreboard;
  `uvm_component_utils(sco)

  uvm_analysis_imp#(transaction,sco) recv;
  // 32 is the depth
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
    if (tr.op == rst) begin
      `uvm_info("SCO", "SYSTEM RESET DETECTED", UVM_NONE);
    end else if (tr.op == writed) begin
      if (tr.PSLVERR == 1'b1) begin
        `uvm_info("SCO", "SLV ERROR during WRITE OP", UVM_NONE);
      end else begin
        arr[tr.PADDR] = tr.PWDATA;
        `uvm_info("SCO", $sformatf("DATA WRITE OP  addr:%0d, wdata:%0d arr_wr:%0d",
          tr.PADDR, tr.PWDATA, arr[tr.PADDR]), UVM_NONE);
      end
    end else if (tr.op == readd) begin
      if (tr.PSLVERR == 1'b1) begin
        `uvm_info("SCO", "SLV ERROR during READ OP", UVM_NONE);
      end else begin
        data_rd = arr[tr.PADDR];
        if (data_rd == tr.PRDATA)
          `uvm_info("SCO", $sformatf("DATA MATCHED : addr:%0d, rdata:%0d",
          tr.PADDR, tr.PRDATA), UVM_NONE)
        else
          `uvm_info("SCO", $sformatf("TEST FAILED : addr:%0d, rdata:%0d data_rd_arr:%0d",
            tr.PADDR, tr.PRDATA, data_rd), UVM_NONE)
      end
    end
    $display("----------------------------------------------------------------");
  endfunction
endclass

/////////////////////////////////////////////////////////////////////

class agent extends uvm_agent;
  `uvm_component_utils(agent)

  abp_config cfg;

  function new(input string inst = "agent", uvm_component parent = null);
    super.new(inst, parent);
  endfunction

  driver d;
  uvm_sequencer #(transaction) seqr;
  mon m;


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cfg = abp_config::type_id::create("cfg");
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

//////////////////////////////////////////////////////////////////////////////////

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

//////////////////////////////////////////////////////////////////////////

class test extends uvm_test;
  `uvm_component_utils(test)

  function new(input string inst = "test", uvm_component c);
    super.new(inst, c);
  endfunction

  env e;
  write_read wrrd;
  writeb_readb wrrdb;
  write_data wdata;
  read_data rdata;
  write_err werr;
  read_err rerr;
  reset_dut rstdut;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e      = env::type_id::create("env", this);
    wrrd   = write_read::type_id::create("wrrd");
    wdata  = write_data::type_id::create("wdata");
    rdata  = read_data::type_id::create("rdata");
    wrrdb  = writeb_readb::type_id::create("wrrdb");
    werr   = write_err::type_id::create("werr");
    rerr   = read_err::type_id::create("rerr");
    rstdut = reset_dut::type_id::create("rstdut");
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    // wrrdb.start(e.a.seqr);
    werr.start(e.a.seqr);
    #20;
    phase.drop_objection(this);
  endtask
endclass

//////////////////////////////////////////////////////////////////////
module tb;


  apb_if vif ();

  apb_ram dut (
      .presetn(vif.presetn),
      .pclk(vif.pclk),
      .psel(vif.psel),
      .penable(vif.penable),
      .pwrite(vif.pwrite),
      .paddr(vif.paddr),
      .pwdata(vif.pwdata),
      .prdata(vif.prdata),
      .pready(vif.pready),
      .pslverr(vif.pslverr)
  );

  initial begin
    vif.pclk <= 0;
  end

  always #10 vif.pclk <= ~vif.pclk;

  initial begin
    uvm_config_db#(virtual apb_if)::set(null, "*", "vif", vif);
    run_test("test");
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule



// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(393) @ 0: uvm_test_top.env.a.d [DRV] System Reset : Start of Simulation
// # KERNEL: UVM_INFO /home/runner/testbench.sv(485) @ 10000: uvm_test_top.env.a.m [MON] SYSTEM RESET DETECTED
// # KERNEL: UVM_INFO /home/runner/testbench.sv(540) @ 10000: uvm_test_top.env.s [SCO] SYSTEM RESET DETECTED
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(393) @ 10000: uvm_test_top.env.a.d [DRV] System Reset : Start of Simulation
// # KERNEL: UVM_INFO /home/runner/testbench.sv(485) @ 30000: uvm_test_top.env.a.m [MON] SYSTEM RESET DETECTED
// # KERNEL: UVM_INFO /home/runner/testbench.sv(540) @ 30000: uvm_test_top.env.s [SCO] SYSTEM RESET DETECTED
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(393) @ 30000: uvm_test_top.env.a.d [DRV] System Reset : Start of Simulation
// # KERNEL: UVM_INFO /home/runner/testbench.sv(485) @ 50000: uvm_test_top.env.a.m [MON] SYSTEM RESET DETECTED
// # KERNEL: UVM_INFO /home/runner/testbench.sv(540) @ 50000: uvm_test_top.env.s [SCO] SYSTEM RESET DETECTED
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(393) @ 50000: uvm_test_top.env.a.d [DRV] System Reset : Start of Simulation
// # KERNEL: UVM_INFO /home/runner/testbench.sv(485) @ 70000: uvm_test_top.env.a.m [MON] SYSTEM RESET DETECTED
// # KERNEL: UVM_INFO /home/runner/testbench.sv(540) @ 70000: uvm_test_top.env.s [SCO] SYSTEM RESET DETECTED
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(393) @ 70000: uvm_test_top.env.a.d [DRV] System Reset : Start of Simulation
// # KERNEL: UVM_INFO /home/runner/testbench.sv(485) @ 90000: uvm_test_top.env.a.m [MON] SYSTEM RESET DETECTED
// # KERNEL: UVM_INFO /home/runner/testbench.sv(540) @ 90000: uvm_test_top.env.s [SCO] SYSTEM RESET DETECTED
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(425) @ 110000: uvm_test_top.env.a.d [DRV] mode:writed, addr:7, wdata:2958126451, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(495) @ 170000: uvm_test_top.env.a.m [MON] DATA WRITE addr:7 data:2958126451 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(551) @ 170000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:7, wdata:2958126451 arr_wr:2958126451
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(425) @ 190000: uvm_test_top.env.a.d [DRV] mode:writed, addr:29, wdata:662555780, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(495) @ 230000: uvm_test_top.env.a.m [MON] DATA WRITE addr:29 data:662555780 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(551) @ 230000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:29, wdata:662555780 arr_wr:662555780
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(425) @ 250000: uvm_test_top.env.a.d [DRV] mode:writed, addr:10, wdata:366381734, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(495) @ 290000: uvm_test_top.env.a.m [MON] DATA WRITE addr:10 data:366381734 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(551) @ 290000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:10, wdata:366381734 arr_wr:366381734
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(425) @ 310000: uvm_test_top.env.a.d [DRV] mode:writed, addr:14, wdata:2069604313, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(495) @ 350000: uvm_test_top.env.a.m [MON] DATA WRITE addr:14 data:2069604313 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(551) @ 350000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:14, wdata:2069604313 arr_wr:2069604313
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(425) @ 370000: uvm_test_top.env.a.d [DRV] mode:writed, addr:8, wdata:1477256221, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(495) @ 410000: uvm_test_top.env.a.m [MON] DATA WRITE addr:8 data:1477256221 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(551) @ 410000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:8, wdata:1477256221 arr_wr:1477256221
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(425) @ 430000: uvm_test_top.env.a.d [DRV] mode:writed, addr:24, wdata:2884304754, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(495) @ 470000: uvm_test_top.env.a.m [MON] DATA WRITE addr:24 data:2884304754 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(551) @ 470000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:24, wdata:2884304754 arr_wr:2884304754
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(425) @ 490000: uvm_test_top.env.a.d [DRV] mode:writed, addr:31, wdata:1995782616, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(495) @ 530000: uvm_test_top.env.a.m [MON] DATA WRITE addr:31 data:1995782616 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(551) @ 530000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:31, wdata:1995782616 arr_wr:1995782616
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(425) @ 550000: uvm_test_top.env.a.d [DRV] mode:writed, addr:29, wdata:3106657103, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(495) @ 590000: uvm_test_top.env.a.m [MON] DATA WRITE addr:29 data:3106657103 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(551) @ 590000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:29, wdata:3106657103 arr_wr:3106657103
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(425) @ 610000: uvm_test_top.env.a.d [DRV] mode:writed, addr:17, wdata:1921960919, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(495) @ 650000: uvm_test_top.env.a.m [MON] DATA WRITE addr:17 data:1921960919 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(551) @ 650000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:17, wdata:1921960919 arr_wr:1921960919
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(425) @ 670000: uvm_test_top.env.a.d [DRV] mode:writed, addr:27, wdata:2736661360, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(495) @ 710000: uvm_test_top.env.a.m [MON] DATA WRITE addr:27 data:2736661360 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(551) @ 710000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:27, wdata:2736661360 arr_wr:2736661360
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(425) @ 730000: uvm_test_top.env.a.d [DRV] mode:writed, addr:28, wdata:1255791130, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(495) @ 770000: uvm_test_top.env.a.m [MON] DATA WRITE addr:28 data:1255791130 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(551) @ 770000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:28, wdata:1255791130 arr_wr:1255791130
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(425) @ 790000: uvm_test_top.env.a.d [DRV] mode:writed, addr:20, wdata:1774317525, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(495) @ 830000: uvm_test_top.env.a.m [MON] DATA WRITE addr:20 data:1774317525 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(551) @ 830000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:20, wdata:1774317525 arr_wr:1774317525
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(425) @ 850000: uvm_test_top.env.a.d [DRV] mode:writed, addr:2, wdata:4292240545, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(495) @ 890000: uvm_test_top.env.a.m [MON] DATA WRITE addr:2 data:4292240545 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(551) @ 890000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:2, wdata:4292240545 arr_wr:4292240545
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(425) @ 910000: uvm_test_top.env.a.d [DRV] mode:writed, addr:6, wdata:219625598, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(495) @ 950000: uvm_test_top.env.a.m [MON] DATA WRITE addr:6 data:219625598 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(551) @ 950000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:6, wdata:219625598 arr_wr:219625598
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(425) @ 970000: uvm_test_top.env.a.d [DRV] mode:writed, addr:1, wdata:2441374572, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(495) @ 1010000: uvm_test_top.env.a.m [MON] DATA WRITE addr:1 data:2441374572 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(551) @ 1010000: uvm_test_top.env.s [SCO] DATA WRITE OP  addr:1, wdata:2441374572 arr_wr:2441374572
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(439) @ 1030000: uvm_test_top.env.a.d [DRV] mode:readd, addr:19, wdata:2367552875, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(505) @ 1070000: uvm_test_top.env.a.m [MON] DATA READ addr:19 data:0 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(564) @ 1070000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:19, rdata:0
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(439) @ 1090000: uvm_test_top.env.a.d [DRV] mode:readd, addr:27, wdata:4293127803, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(505) @ 1130000: uvm_test_top.env.a.m [MON] DATA READ addr:27 data:2736661360 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(564) @ 1130000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:27, rdata:2736661360
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(439) @ 1150000: uvm_test_top.env.a.d [DRV] mode:readd, addr:25, wdata:3923132060, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(505) @ 1190000: uvm_test_top.env.a.m [MON] DATA READ addr:25 data:0 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(564) @ 1190000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:25, rdata:0
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(439) @ 1210000: uvm_test_top.env.a.d [DRV] mode:readd, addr:14, wdata:1257565646, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(505) @ 1250000: uvm_test_top.env.a.m [MON] DATA READ addr:14 data:2069604313 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(564) @ 1250000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:14, rdata:2069604313
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(439) @ 1270000: uvm_test_top.env.a.d [DRV] mode:readd, addr:26, wdata:591395857, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(505) @ 1310000: uvm_test_top.env.a.m [MON] DATA READ addr:26 data:0 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(564) @ 1310000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:26, rdata:0
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(439) @ 1330000: uvm_test_top.env.a.d [DRV] mode:readd, addr:28, wdata:1924622693, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(505) @ 1370000: uvm_test_top.env.a.m [MON] DATA READ addr:28 data:1255791130 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(564) @ 1370000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:28, rdata:1255791130
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(439) @ 1390000: uvm_test_top.env.a.d [DRV] mode:readd, addr:20, wdata:962278858, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(505) @ 1430000: uvm_test_top.env.a.m [MON] DATA READ addr:20 data:1774317525 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(564) @ 1430000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:20, rdata:1774317525
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(439) @ 1450000: uvm_test_top.env.a.d [DRV] mode:readd, addr:3, wdata:1999331648, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(505) @ 1490000: uvm_test_top.env.a.m [MON] DATA READ addr:3 data:0 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(564) @ 1490000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:3, rdata:0
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(439) @ 1510000: uvm_test_top.env.a.d [DRV] mode:readd, addr:9, wdata:740813767, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(505) @ 1550000: uvm_test_top.env.a.m [MON] DATA READ addr:9 data:0 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(564) @ 1550000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:9, rdata:0
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(439) @ 1570000: uvm_test_top.env.a.d [DRV] mode:readd, addr:5, wdata:1481692511, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(505) @ 1610000: uvm_test_top.env.a.m [MON] DATA READ addr:5 data:0 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(564) @ 1610000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:5, rdata:0
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(439) @ 1630000: uvm_test_top.env.a.d [DRV] mode:readd, addr:23, wdata:4221967880, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(505) @ 1670000: uvm_test_top.env.a.m [MON] DATA READ addr:23 data:0 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(564) @ 1670000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:23, rdata:0
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(439) @ 1690000: uvm_test_top.env.a.d [DRV] mode:readd, addr:0, wdata:371705282, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(505) @ 1730000: uvm_test_top.env.a.m [MON] DATA READ addr:0 data:0 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(564) @ 1730000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:0, rdata:0
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(439) @ 1750000: uvm_test_top.env.a.d [DRV] mode:readd, addr:0, wdata:2815806605, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(505) @ 1790000: uvm_test_top.env.a.m [MON] DATA READ addr:0 data:0 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(564) @ 1790000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:0, rdata:0
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(439) @ 1810000: uvm_test_top.env.a.d [DRV] mode:readd, addr:22, wdata:2964337257, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(505) @ 1850000: uvm_test_top.env.a.m [MON] DATA READ addr:22 data:0 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(564) @ 1850000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:22, rdata:0
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/runner/testbench.sv(439) @ 1870000: uvm_test_top.env.a.d [DRV] mode:readd, addr:2, wdata:817297238, rdata:x, slverr:x
// # KERNEL: UVM_INFO /home/runner/testbench.sv(505) @ 1910000: uvm_test_top.env.a.m [MON] DATA READ addr:2 data:4292240545 slverr:0
// # KERNEL: UVM_INFO /home/runner/testbench.sv(564) @ 1910000: uvm_test_top.env.s [SCO] DATA MATCHED : addr:2, rdata:4292240545
// # KERNEL: ----------------------------------------------------------------
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_objection.svh(1271) @ 1930000: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 1930000: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :  108
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [DRV]    35
// # KERNEL: [MON]    35
// # KERNEL: [RNTST]     1
// # KERNEL: [SCO]    35
// # KERNEL: [TEST_DONE]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 1930 ns,  Iteration: 57,  Instance: /tb,  Process: @INITIAL#695_2@.
// # KERNEL: stopped at time: 1930 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done
