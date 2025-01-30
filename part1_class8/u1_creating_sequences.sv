`include "uvm_macros.svh"
import uvm_pkg::*;

class transaction extends uvm_sequence_item;
  // for an input port, we like to take the help of pseudo random number generator to generate the random stimuli.
  rand bit [3:0] a;
  rand bit [3:0] b;
       bit [4:0] y;

  function new(input string path = "transaction");
    super.new(path);
  endfunction

  // we also like to have field automation for all the data member.
  // Hence we utilize the field macros for your data member.
  // these allows us to access the uvm core methods, including printing and creating a deep copy.
  `uvm_object_utils_begin(transaction)
    `uvm_field_int(a, UVM_DEFAULT)
    `uvm_field_int(b, UVM_DEFAULT)
    `uvm_field_int(y, UVM_DEFAULT)
  `uvm_object_utils_end
endclass

// you need to specify the parameter, parameter will be in most of the cases of transaction class
// We rarely do something more in uvm_sequence, usually use by default, or change the name
class sequence1 extends uvm_sequence#(transaction);
  `uvm_object_utils(sequence1)

    function new(input string path = "sequence1");
      super.new(path);
    endfunction

    // These are the methods that are automatically called when you start a sequence.
    // UVM will call the sequence in the test - run_phase - seq1.start
    // that will consume a simulation time and that represents our main task of applying stimuli to a DUT.
    // As soon as you call a START method, this method will be automatically executed in a sequence
    // need to use the same name
    virtual task pre_body();
      `uvm_info("SEQ1", "PRE-BODY EXECUTED", UVM_NONE);
    endtask

    virtual task body();
      `uvm_info("SEQ1", "BODY EXECUTED", UVM_NONE);
      // 1. sequence.create_item
      // 2. sequence request to sequencer
      // 3. sequence wait for grant
      // 6. sequencer request grant from sequence (sequencer向sequence請求授權)
      // 7. sequence receive the grant
      // 8. sequence.randomize()
      // 9. sequence.send_request()
      // 10. sequence.wait for item done
      // 11. sequence send the sequence to the sequencer
      // 12. sequencer send the sequence to the driver
      // 15. driver send item_done to sequencer
      // 16. sequencer send item_done to sequence
      // 17. sequence receive item_done and go to next sequence
    endtask

    virtual task post_body();
      `uvm_info("SEQ1", "POST-BODY EXECUTED", UVM_NONE);
    endtask
endclass

// Driver is to access the data from a sequencer and apply to a DUT
// we also have specified that we will working on a transaction class.
class driver extends uvm_driver#(transaction);
  // sequence and transaction class are dynamic component
  // driver will stay for an entire simulation furation, belongs to the static component
  `uvm_component_utils(driver)

  // Whatever data that we receive from a sequencer will be storing in it
  transaction t;

  function new(input string path = "DRV", uvm_component parent = null);
    super.new(path,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    t = transaction::type_id::create("t");
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      // This signifies to a sequencer that the driver is ready to receive the data from a sequencer.
      // And the sequencer will convert that data to a sequence and then we will be getting a sequence from a sequencer.
      // This will tell the sequencer that you cna send the sequence to a driver.
      seq_item_port.get_next_item(t);
      // 4. get next item
      // 5. req for sequencer
      // 13. driver apply the sequence to the DUT
      // apply seq to DUT
      // we are already to receive the next sequence.
      // this acknoledgement is non-blocking in nature (by default).
      // we do not need to wait for sending the request for a next sequence until we receive the ack
      // for the previous sequence.
      // -> before item_done, it will still get_next_item
      seq_item_port.item_done();
      // 14. item done
    end
  endtask
endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent)

  function new(input string path = "agent", uvm_component parent = null);
    super.new(path,parent);
  endfunction

  driver d;
  uvm_sequencer #(transaction) seqr;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    d = driver::type_id::create("d",this);
    seqr = uvm_sequencer #(transaction)::type_id::create("seqr",this);
  endfunction

  // we need to specify the connection of a sequencer and the driver in a agent
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    d.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env)

  function new(input string path = "env", uvm_component parent= null);
    super.new(path,parent);
  endfunction

  agent a;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a = agent::type_id::create("a",this);
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test)

  function new(input string path = "test", uvm_component parent = null);
    super.new(path,parent);
  endfunction

	sequence1 seq1;
	env e;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("e",this);
    seq1 = sequence1::type_id::create("seq1"); // only single argument
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
      // just start the sequence, and put the sequencer inside
      seq1.start(e.a.seqr);
    phase.drop_objection(this);
  endtask
endclass

module ram_tb;
  initial begin
    run_test("test");
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
// # KERNEL: UVM_INFO /home/runner/testbench.sv(39) @ 0: uvm_test_top.e.a.seqr@@seq1 [SEQ1] PRE-BODY EXECUTED
// # KERNEL: UVM_INFO /home/runner/testbench.sv(43) @ 0: uvm_test_top.e.a.seqr@@seq1 [SEQ1] BODY EXECUTED
// # KERNEL: UVM_INFO /home/runner/testbench.sv(47) @ 0: uvm_test_top.e.a.seqr@@seq1 [SEQ1] POST-BODY EXECUTED
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_objection.svh(1271) @ 0: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :    6
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [RNTST]     1
// # KERNEL: [SEQ1]     3
// # KERNEL: [TEST_DONE]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 0 ns,  Iteration: 195,  Instance: /ram_tb,  Process: @INITIAL#153_0@.
// # KERNEL: stopped at time: 0 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done