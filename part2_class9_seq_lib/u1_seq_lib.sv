import uvm_pkg::*;
`include "uvm_macros.svh"

class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction)

  // rand bit [3:0] a;
  // rand bit [3:0] b;
  bit [3:0] a;
  bit [3:0] b;

  function new(string name = "transaction");
    super.new(name);
  endfunction
endclass


typedef class seq_library;


class seq1 extends uvm_sequence #(transaction);
  `uvm_object_utils(seq1)
  //`uvm_add_to_seq_lib(seq1, seq_library)

  transaction tr;

  function new(string name = "seq1");
    super.new(name);
  endfunction

  virtual task body();
    tr = transaction::type_id::create("tr");
    start_item(tr);
    tr.a = 4;
    tr.b = 4;
    finish_item(tr);
  endtask
endclass

class seq2 extends uvm_sequence #(transaction);
  `uvm_object_utils(seq2)
  //`uvm_add_to_seq_lib(seq2, seq_library)

  transaction tr;

  function new(string name = "seq2");
    super.new(name);
  endfunction

  virtual task body();
    tr = transaction::type_id::create("tr");
    start_item(tr);
    tr.a = 5;
    tr.b = 5;
    finish_item(tr);
  endtask
endclass

class seq_library extends uvm_sequence_library #(transaction);
  // regiter our sequence to the factory
  `uvm_object_utils(seq_library)
  // This is required when we want to use the uvm_sequence_library
  // This is make sure that our sequences are perfectly created and executed on the sequencer.
  `uvm_sequence_library_utils(seq_library)

  function new(string name = "seq_library");
    super.new(name);
    add_typewide_sequence(seq1::get_type());
    add_typewide_sequence(seq2::get_type());
    // or we can write as below
    // add_typewide_sequence(seq1.get_type);
    // add_typewide_sequence(seq2.get_type);

    //  assert(seqlib.randomize());
  endfunction
endclass

class driver extends uvm_driver #(transaction);
  `uvm_component_utils(driver)

  transaction tr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(tr);
      `uvm_info(get_type_name(), $sformatf("a : %0d  b : %0d", tr.a, tr.b), UVM_NONE);
      #10;
      seq_item_port.item_done();
    end
  endtask
endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent)

  function new(input string inst = "agent", uvm_component parent = null);
    super.new(inst, parent);
  endfunction

  driver d;
  uvm_sequencer #(transaction) seqr;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    d = driver::type_id::create("d", this);
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

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a = agent::type_id::create("a", this);
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test)

  env e;
  seq_library seqlib;

  function new(input string inst = "test", uvm_component c);
    super.new(inst, c);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("e", this);
    seqlib = seq_library::type_id::create("seqlib");
    seqlib.selection_mode = UVM_SEQ_LIB_RANDC;
    seqlib.min_random_count = 5;
    seqlib.max_random_count = 10;
    seqlib.init_sequence_library();
    seqlib.print();
  endfunction

  virtual task run_phase(uvm_phase phase);
    // uvm_config_db#(uvm_sequence_base)::set(this,"e.a.seqr.run_phase", "default_sequence",seqlib);
    phase.raise_objection(this);
    // this will randomly pick up the sequence depending on the selection mode that we specified.
    assert (seqlib.randomize());
    // we need to manually do this before, but now, it is automatical.
    seqlib.start(e.a.seqr);
    phase.drop_objection(this);
  endtask
endclass

module top ();
  initial begin
    run_test("test");
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: --------------------------------------------------------------------
// # KERNEL: Name                  Type                   Size  Value
// # KERNEL: --------------------------------------------------------------------
// # KERNEL: seqlib                seq_library            -     @357
// # KERNEL:   min_random_count    int unsigned           32    'd5
// # KERNEL:   max_random_count    int unsigned           32    'd10
// # KERNEL:   selection_mode      uvm_sequence_lib_mode  32    UVM_SEQ_LIB_RANDC
// # KERNEL:   sequence_count      int unsigned           32    'd10
// # KERNEL:   typewide_sequences  queue_object_types     0     -
// # KERNEL:   sequences           queue_object_types     2     -
// # KERNEL:     [0]               uvm_object_wrapper     45    seq1
// # KERNEL:     [1]               uvm_object_wrapper     45    seq2
// # KERNEL:   seqs_distrib        as_int_string          0     -
// # KERNEL: --------------------------------------------------------------------
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/seq/uvm_sequence_library.svh(663) @ 0: uvm_test_top.e.a.seqr@@seqlib [SEQLIB/START] Starting sequence library seq_library in unknown phase: 8 iterations in mode UVM_SEQ_LIB_RANDC
// # KERNEL: UVM_INFO /home/runner/testbench.sv(92) @ 0: uvm_test_top.e.a.d [driver] a : 4  b : 4
// # KERNEL: UVM_INFO /home/runner/testbench.sv(92) @ 10: uvm_test_top.e.a.d [driver] a : 5  b : 5
// # KERNEL: UVM_INFO /home/runner/testbench.sv(92) @ 20: uvm_test_top.e.a.d [driver] a : 4  b : 4
// # KERNEL: UVM_INFO /home/runner/testbench.sv(92) @ 30: uvm_test_top.e.a.d [driver] a : 5  b : 5
// # KERNEL: UVM_INFO /home/runner/testbench.sv(92) @ 40: uvm_test_top.e.a.d [driver] a : 5  b : 5
// # KERNEL: UVM_INFO /home/runner/testbench.sv(92) @ 50: uvm_test_top.e.a.d [driver] a : 4  b : 4
// # KERNEL: UVM_INFO /home/runner/testbench.sv(92) @ 60: uvm_test_top.e.a.d [driver] a : 5  b : 5
// # KERNEL: UVM_INFO /home/runner/testbench.sv(92) @ 70: uvm_test_top.e.a.d [driver] a : 4  b : 4
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/seq/uvm_sequence_library.svh(737) @ 80: uvm_test_top.e.a.seqr@@seqlib [SEQLIB/END] Ending sequence library in phase unknown
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_objection.svh(1271) @ 80: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 80: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :   13
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [RNTST]     1
// # KERNEL: [SEQLIB/END]     1
// # KERNEL: [SEQLIB/START]     1
// # KERNEL: [TEST_DONE]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL: [driver]     8
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 80 ns,  Iteration: 65,  Instance: /top,  Process: @INITIAL#169_0@.
// # KERNEL: stopped at time: 80 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done