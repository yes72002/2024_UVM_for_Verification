`include "uvm_macros.svh"
import uvm_pkg::*;
// Default Timeout = 9200sec

class comp extends uvm_component;
  `uvm_component_utils(comp)

  function new(string path = "comp", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("comp","Reset Aplied", UVM_NONE);
    #100;
    `uvm_info("comp","Reset Removed", UVM_NONE);
    phase.drop_objection(this);
  endtask

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("comp", "Random Stimulus Applied", UVM_NONE);
    #500;
    `uvm_info("comp", "Random Stimulus Removed", UVM_NONE);
    phase.drop_objection(this);
  endtask

  task post_main_phase(uvm_phase phase);
    `uvm_info("mon", " Post-Main Phase Started", UVM_NONE);
  endtask

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
endclass


module tb;
  initial begin
   // uvm_top.set_timeout(100ns, 0);
    run_test("comp");
  end
endmodule


// # KERNEL: ASDB file was created in location /home/runner/dataset.asdb
// # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test comp...
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 0: reporter [PH/TRC/STRT] Phase 'common' (id=21) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 0: reporter [PH/TRC/DONE] Phase 'common' (id=21) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 0: reporter [PH/TRC/SCHEDULED] Phase 'common.build' (id=24) Scheduled from phase common
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 0: reporter [PH/TRC/STRT] Phase 'common.build' (id=24) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 0: reporter [PH/TRC/DONE] Phase 'common.build' (id=24) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 0: reporter [PH/TRC/SCHEDULED] Phase 'common.connect' (id=31) Scheduled from phase common.build
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 0: reporter [PH/TRC/STRT] Phase 'common.connect' (id=31) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 0: reporter [PH/TRC/DONE] Phase 'common.connect' (id=31) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 0: reporter [PH/TRC/SCHEDULED] Phase 'common.end_of_elaboration' (id=34) Scheduled from phase common.connect
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 0: reporter [PH/TRC/STRT] Phase 'common.end_of_elaboration' (id=34) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 0: reporter [PH/TRC/DONE] Phase 'common.end_of_elaboration' (id=34) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 0: reporter [PH/TRC/SCHEDULED] Phase 'common.start_of_simulation' (id=37) Scheduled from phase common.end_of_elaboration
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 0: reporter [PH/TRC/STRT] Phase 'common.start_of_simulation' (id=37) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 0: reporter [PH/TRC/DONE] Phase 'common.start_of_simulation' (id=37) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 0: reporter [PH/TRC/SCHEDULED] Phase 'common.run' (id=40) Scheduled from phase common.start_of_simulation
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 0: reporter [PH/TRC/SCHEDULED] Phase 'uvm' (id=60) Scheduled from phase common.start_of_simulation
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 0: reporter [PH/TRC/STRT] Phase 'common.run' (id=40) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 0: reporter [PH/TRC/STRT] Phase 'uvm' (id=60) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 0: reporter [PH/TRC/DONE] Phase 'uvm' (id=60) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 0: reporter [PH/TRC/SCHEDULED] Phase 'uvm.uvm_sched' (id=62) Scheduled from phase uvm
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 0: reporter [PH/TRC/STRT] Phase 'uvm.uvm_sched' (id=62) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 0: reporter [PH/TRC/DONE] Phase 'uvm.uvm_sched' (id=62) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 0: reporter [PH/TRC/SCHEDULED] Phase 'uvm.uvm_sched.pre_reset' (id=65) Scheduled from phase uvm.uvm_sched
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 0: reporter [PH/TRC/STRT] Phase 'uvm.uvm_sched.pre_reset' (id=65) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1439) @ 0: reporter [PH/TRC/SKIP] Phase 'common.run' (id=40) No objections raised, skipping phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1439) @ 0: reporter [PH/TRC/SKIP] Phase 'uvm.uvm_sched.pre_reset' (id=65) No objections raised, skipping phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 0: reporter [PH/TRC/DONE] Phase 'uvm.uvm_sched.pre_reset' (id=65) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 0: reporter [PH/TRC/SCHEDULED] Phase 'uvm.uvm_sched.reset' (id=74) Scheduled from phase uvm.uvm_sched.pre_reset
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 0: reporter [PH/TRC/STRT] Phase 'uvm.uvm_sched.reset' (id=74) Starting phase
// # KERNEL: UVM_INFO /home/runner/testbench.sv(14) @ 0: uvm_test_top [comp] Reset Aplied
// # KERNEL: UVM_INFO /home/runner/testbench.sv(16) @ 100: uvm_test_top [comp] Reset Removed
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 100: reporter [PH/TRC/DONE] Phase 'uvm.uvm_sched.reset' (id=74) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 100: reporter [PH/TRC/SCHEDULED] Phase 'uvm.uvm_sched.post_reset' (id=83) Scheduled from phase uvm.uvm_sched.reset
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 100: reporter [PH/TRC/STRT] Phase 'uvm.uvm_sched.post_reset' (id=83) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1439) @ 100: reporter [PH/TRC/SKIP] Phase 'uvm.uvm_sched.post_reset' (id=83) No objections raised, skipping phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 100: reporter [PH/TRC/DONE] Phase 'uvm.uvm_sched.post_reset' (id=83) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 100: reporter [PH/TRC/SCHEDULED] Phase 'uvm.uvm_sched.pre_configure' (id=92) Scheduled from phase uvm.uvm_sched.post_reset
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 100: reporter [PH/TRC/STRT] Phase 'uvm.uvm_sched.pre_configure' (id=92) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1439) @ 100: reporter [PH/TRC/SKIP] Phase 'uvm.uvm_sched.pre_configure' (id=92) No objections raised, skipping phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 100: reporter [PH/TRC/DONE] Phase 'uvm.uvm_sched.pre_configure' (id=92) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 100: reporter [PH/TRC/SCHEDULED] Phase 'uvm.uvm_sched.configure' (id=101) Scheduled from phase uvm.uvm_sched.pre_configure
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 100: reporter [PH/TRC/STRT] Phase 'uvm.uvm_sched.configure' (id=101) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1439) @ 100: reporter [PH/TRC/SKIP] Phase 'uvm.uvm_sched.configure' (id=101) No objections raised, skipping phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 100: reporter [PH/TRC/DONE] Phase 'uvm.uvm_sched.configure' (id=101) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 100: reporter [PH/TRC/SCHEDULED] Phase 'uvm.uvm_sched.post_configure' (id=110) Scheduled from phase uvm.uvm_sched.configure
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 100: reporter [PH/TRC/STRT] Phase 'uvm.uvm_sched.post_configure' (id=110) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1439) @ 100: reporter [PH/TRC/SKIP] Phase 'uvm.uvm_sched.post_configure' (id=110) No objections raised, skipping phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 100: reporter [PH/TRC/DONE] Phase 'uvm.uvm_sched.post_configure' (id=110) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 100: reporter [PH/TRC/SCHEDULED] Phase 'uvm.uvm_sched.pre_main' (id=119) Scheduled from phase uvm.uvm_sched.post_configure
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 100: reporter [PH/TRC/STRT] Phase 'uvm.uvm_sched.pre_main' (id=119) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1439) @ 100: reporter [PH/TRC/SKIP] Phase 'uvm.uvm_sched.pre_main' (id=119) No objections raised, skipping phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 100: reporter [PH/TRC/DONE] Phase 'uvm.uvm_sched.pre_main' (id=119) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 100: reporter [PH/TRC/SCHEDULED] Phase 'uvm.uvm_sched.main' (id=128) Scheduled from phase uvm.uvm_sched.pre_main
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 100: reporter [PH/TRC/STRT] Phase 'uvm.uvm_sched.main' (id=128) Starting phase
// # KERNEL: UVM_INFO /home/runner/testbench.sv(23) @ 100: uvm_test_top [comp] Random Stimulus Applied
// # KERNEL: UVM_INFO /home/runner/testbench.sv(25) @ 600: uvm_test_top [comp] Random Stimulus Removed
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 600: reporter [PH/TRC/DONE] Phase 'uvm.uvm_sched.main' (id=128) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 600: reporter [PH/TRC/SCHEDULED] Phase 'uvm.uvm_sched.post_main' (id=137) Scheduled from phase uvm.uvm_sched.main
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 600: reporter [PH/TRC/STRT] Phase 'uvm.uvm_sched.post_main' (id=137) Starting phase
// # KERNEL: UVM_INFO /home/runner/testbench.sv(30) @ 600: uvm_test_top [mon]  Post-Main Phase Started
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1439) @ 600: reporter [PH/TRC/SKIP] Phase 'uvm.uvm_sched.post_main' (id=137) No objections raised, skipping phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 600: reporter [PH/TRC/DONE] Phase 'uvm.uvm_sched.post_main' (id=137) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 600: reporter [PH/TRC/SCHEDULED] Phase 'uvm.uvm_sched.pre_shutdown' (id=146) Scheduled from phase uvm.uvm_sched.post_main
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 600: reporter [PH/TRC/STRT] Phase 'uvm.uvm_sched.pre_shutdown' (id=146) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1439) @ 600: reporter [PH/TRC/SKIP] Phase 'uvm.uvm_sched.pre_shutdown' (id=146) No objections raised, skipping phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 600: reporter [PH/TRC/DONE] Phase 'uvm.uvm_sched.pre_shutdown' (id=146) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 600: reporter [PH/TRC/SCHEDULED] Phase 'uvm.uvm_sched.shutdown' (id=155) Scheduled from phase uvm.uvm_sched.pre_shutdown
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 600: reporter [PH/TRC/STRT] Phase 'uvm.uvm_sched.shutdown' (id=155) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1439) @ 600: reporter [PH/TRC/SKIP] Phase 'uvm.uvm_sched.shutdown' (id=155) No objections raised, skipping phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 600: reporter [PH/TRC/DONE] Phase 'uvm.uvm_sched.shutdown' (id=155) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 600: reporter [PH/TRC/SCHEDULED] Phase 'uvm.uvm_sched.post_shutdown' (id=164) Scheduled from phase uvm.uvm_sched.shutdown
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 600: reporter [PH/TRC/STRT] Phase 'uvm.uvm_sched.post_shutdown' (id=164) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1439) @ 600: reporter [PH/TRC/SKIP] Phase 'uvm.uvm_sched.post_shutdown' (id=164) No objections raised, skipping phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 600: reporter [PH/TRC/DONE] Phase 'common.run' (id=40) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 600: reporter [PH/TRC/SCHEDULED] Phase 'common.extract' (id=49) Scheduled from phase common.run
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 600: reporter [PH/TRC/DONE] Phase 'uvm.uvm_sched.post_shutdown' (id=164) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 600: reporter [PH/TRC/SCHEDULED] Phase 'uvm.uvm_sched_end' (id=63) Scheduled from phase uvm.uvm_sched.post_shutdown
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 600: reporter [PH/TRC/STRT] Phase 'uvm.uvm_sched_end' (id=63) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 600: reporter [PH/TRC/DONE] Phase 'uvm.uvm_sched_end' (id=63) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 600: reporter [PH/TRC/SCHEDULED] Phase 'uvm.uvm_end' (id=61) Scheduled from phase uvm.uvm_sched_end
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 600: reporter [PH/TRC/STRT] Phase 'uvm.uvm_end' (id=61) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 600: reporter [PH/TRC/DONE] Phase 'uvm.uvm_end' (id=61) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 600: reporter [PH/TRC/STRT] Phase 'common.extract' (id=49) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 600: reporter [PH/TRC/DONE] Phase 'common.extract' (id=49) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 600: reporter [PH/TRC/SCHEDULED] Phase 'common.check' (id=52) Scheduled from phase common.extract
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 600: reporter [PH/TRC/STRT] Phase 'common.check' (id=52) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 600: reporter [PH/TRC/DONE] Phase 'common.check' (id=52) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 600: reporter [PH/TRC/SCHEDULED] Phase 'common.report' (id=55) Scheduled from phase common.check
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 600: reporter [PH/TRC/STRT] Phase 'common.report' (id=55) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 600: reporter [PH/TRC/DONE] Phase 'common.report' (id=55) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 600: reporter [PH/TRC/SCHEDULED] Phase 'common.final' (id=58) Scheduled from phase common.report
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 600: reporter [PH/TRC/STRT] Phase 'common.final' (id=58) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 600: reporter [PH/TRC/DONE] Phase 'common.final' (id=58) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1655) @ 600: reporter [PH/TRC/SCHEDULED] Phase 'common.common_end' (id=22) Scheduled from phase common.final
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1345) @ 600: reporter [PH/TRC/STRT] Phase 'common.common_end' (id=22) Starting phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1620) @ 600: reporter [PH/TRC/DONE] Phase 'common.common_end' (id=22) Completed phase
// # KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 600: reporter [UVM/REPORT/SERVER]
// # KERNEL: --- UVM Report Summary ---
// # KERNEL:
// # KERNEL: ** Report counts by severity
// # KERNEL: UVM_INFO :   98
// # KERNEL: UVM_WARNING :    0
// # KERNEL: UVM_ERROR :    0
// # KERNEL: UVM_FATAL :    0
// # KERNEL: ** Report counts by id
// # KERNEL: [PH/TRC/DONE]    27
// # KERNEL: [PH/TRC/SCHEDULED]    26
// # KERNEL: [PH/TRC/SKIP]    11
// # KERNEL: [PH/TRC/STRT]    27
// # KERNEL: [RNTST]     1
// # KERNEL: [UVM/RELNOTES]     1
// # KERNEL: [comp]     4
// # KERNEL: [mon]     1
// # KERNEL:
// # RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
// # KERNEL: Time: 600 ns,  Iteration: 89,  Instance: /tb,  Process: @INITIAL#40_0@.
// # KERNEL: stopped at time: 600 ns
// # VSIM: Simulation has finished. There are no more test vectors to simulate.
// # VSIM: Simulation has finished.
// Done
// PH/TRC = phase trace