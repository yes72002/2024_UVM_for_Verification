# 2024_UVM_for_Verification
# UVM for Verification Part 1 ~ 3
## Course Source
[UVM for Verification Part 1: Fundamentals](https://www.udemy.com/share/1074Wu3@SIYN9x_9O3MiPuRKwehEkBqPR2QqYXpqhLwqNlFp-PsHqctfk36vm3wqFpFBdxH7aA==/)

[UVM for Verification Part 2: Projects](https://www.udemy.com/share/107zqQ3@C3T5WRSqJzvznKD9Td1cMv3k-FkT9qMezmn5Z7mf0Di6YXVAMy0TD3qW54PFEsiiWw==/)

[UVM for Verification Part 3: Register Abstraction Layer (RAL)](https://www.udemy.com/share/108nOi3@pu982UMJRokmg3dLvVuHPgz956hZDHqTPcWZghqD5mCfYmaws_P_hmqari0TTi1zMw==/)


## Starting Time
2024.06.06 ~ 2024.6.12 (now)

## Course Content
### UVM for Verification Part 1: Fundamentals

<!-- ${\textsf{\color{lightgreen}Green}}$ -->

<!-- ${\textsf{\color{green}Green}}$ -->
<!-- + ${\textsf{\color{red} uvminfo}}$, -->

+ Class 1 - How to use IDE
    + Series Intro
    + Agenda
    + Use this code for understanding IDE's
    + EDAplayground Link
    + Working with EDAP
    + Working with Vivado
    + Working with Questa
+ Class 2: Reporting Mechanism
    + Agenda
    + Different Reporting Macros
        + `uvm_info`, `uvm_warning`, `uvm_error`, `uvm_fatal`
    + Working with Reporting Macros
        + `uvm_info`
    + Priniting Values of Variables without automation
        + `$sformatf`
    + Working with Verbosity Level
        + `get_report_verbosity_level`
        + `UVM_NONE`, `UVM_LOW`, `UVM_MEDIUM`, `UVM_HIGH`, `UVM_FULL`
    + Working with Verbosity Level and ID
        + `set_report_id_verbosity`
    + Working with Individual Component
        + `set_report_verbosity_level`
    + Working with Hierarchy
        + `set_report_verbosity_level_hier`
    + Other Reporting Macros
        + `uvm_info`, `uvm_warning`, `uvm_error`, `uvm_fatal`
    + Changing Severity of Macros
        + `set_report_severity_override`
        + `set_report_severity_id_override`
    + Changing Associated Actions of Macros
        + `set_report_severity_action`
        + `UVM_NO_ACTION`, `UVM_DISPLAY`, `UVM_LOG`, `UVM_COUNT`, `UVM_EXIT`, `UVM_CALL_HOOK`, `UVM_STOP`, `UVM_RM_RECORD`
    + Working with quit_count and UVM_ERROR
        + `set_report_max_quit_count`
    + Working with log file
        + `set_report_default_file`
        + `UVM_LOG`
    + A11
    + A12
    + A13
    + A14
    + A15
+ Class 3: Getting Started with Base : UVM_OBJECT
    + Agenda
    + Fundamentals P1
        + `uvm_object`, `uvm_component`
    + Fundamentals P2
        + `uvm_transaction`, `uvm_sequence_item`, `uvm_sequence`
        + `uvm_driver`, `uvm_sequencer`, `uvm_monitor`, `uvm_agent`, `uvm_scoreboard`, `uvm_env`, `uvm_test`
    + Fundamentals P3
        + `Core Methods`, `Do methods`
    + Target
    + Creating Class
    + Deriving class from UVM_OBJECT
        + `uvm_object_utils`
    + Using Field Macros P1 : INT
        + `UVM_ALL_ON`, `UVM_DEFAULT`, `UVM_NOCOPY`, `UVM_NOCOMPARE`, `UVM_NOPRINT`, `UVM_NODEFPRINT`, `UVM_NOPACK`, `UVM_PHYSICAL`, `UVM_ABSTRACT`, `UVM_READONLY`
        + `UVM_BIN`, `UVM_DEC`, `UVM_UNSIGNED`, `UVM_OCT`, `UVM_HEX`, `UVM_STRING`, `UVM_TIME`
    + Using Field Macros P2 : INT cont
        + `uvm_default_tree_printer`, `uvm_default_line_printer`, `uvm_default_table_printer`
        + `UVM_DEFAULT`, `UVM_BIN`, `UVM_HEX`, `UVM_DEC`,
    + Using Field Macros P2 : ENUM, REAL
        + `uvm_field_enum`, `uvm_field_string`, `uvm_field_real`
    + Using Field Macros P3 : OBJECT
        + `uvm_field_object`
    + Using Field Macros P4 : Arrays
        + `uvm_field_sarray_int`, `uvm_field_array_int`, `uvm_field_queue_int`, `uvm_field_aa_int_int`
    + Copy and Clone Method
        + `s.copy(f);`, `$cast(s, f.clone());`
    + Shallow Vs Deep Copy
        + `s.copy(f);`, `$cast(s, f.clone());`
    + Copy and Clone Method
        + `s.copy(f);`, `$cast(s, f.clone());`
    + Compare Method
        + `status = f1.compare(f2);`
    + Create Method
        + `object = object_type::type_id::create("instance name(path_name)")'`
    + Factory Override : new vs create method
        + `comp.set_type_override_by_type`
    + do_print Method
        + `do_print`
    + convert2string method
        + `convert2string`
    + do_copy method
        + `do_copy`
    + do_compare
        + `do_compare`
    + A21
    + A22
+ Class 4: UVM_COMPONENT
    + Agenda
    + Understanding UVM TREE
    + Creating UVM_COMPONENT class
        + `class comp extends uvm_component;`
        + `function new(string path="comp", uvm_component parent=null);`
    + Creating UVM_TREE P1
        + `uvm_top.print_topology();`
    + Creating UVM_TREE P2
+ Class 5: config_db
    + Agenda
    + Understanding typical format of config_db
        + `uvm_config_db#(int)::get(null, "uvm_test_top", "data", data)`
    + Demonstration P1
        + `uvm_config_db#(int)::get(null, "uvm_test_top", "data", data)`
        + `uvm_config_db#(int)::set(null, "uvm_test_top", "data", 12)`
    + Demonstration P2
    + Demonstration P3
        + `uvm_config_db#(int)::get(this, "", "data", data1)`
        + `uvm_config_db#(int)::set(null, "uvm_test_top.env.agent.comp1", "data", data);`
    + Demonstration P4
        + `uvm_config_db#(int)::get(this, "", "data", data1)`
        + `uvm_config_db#(int)::set(null, "uvm_test_top.env.agent.comp*", "data", data);`
    + Used Case
        + `uvm_config_db#(virtual adder_if)::get(this, "", "aif", aif)`
        + `uvm_config_db#(virtual adder_if)::set(null, "uvm_test_top.env.agent.drv", "aif", aif)`
+ Class 6: UVM_PHASES
    + Agenda
    + Fundamentals of Phases
    + Classification of Phases : Methods Used
    + Classification of Phases : Specific Purposes P1
    + Classification of Phases : Specific Purposes P2
    + Classification of Phases : Specific Purposes P3
    + Classification Summary
    + How we override phases
    + Understanding execuction of build_phase in multiple components
    + Understanding execution of connect_phase
    + Execution of Multiple instance phases
    + Raising Objection
    + How Time consuming phases works in Single Component
    + Time Consuming phases in multiple components
    + Timeout
        + `uvm_top.set_timeout(100ns, 0);`
    + Drain Time : Individual Component
        + `phase.phase_done.set_drain_time(this,drain_time);`
    + Drain Time : Multiple Components
        + `phase.phase_done.set_drain_time(this,drain_time);`
    + Phase Debug
        + `+access+r +UVM_PHASE_TRACE`
    + Phase Debug Switch
    + Objection Debug
    + Objection Debug Switch
    + A51
+ Class 7: TLM
    + Agenda
    + Fundamentals
    + Blocking PUT Operation P1
    + Adding IMP to Blocking PUT Operation
    + Port to IMP
    + PORT-PORT to IMP
    + Port to Export-IMP
    + Get Operation
    + Transport Port
    + Analysis Port
    + A71
    + A72
+ Class 8: Sequence
    + Agenda
    + Fundamentals
    + Creating Sequences
    + Understanding Flow
    + Sending Data to Sequencer
    + Sending Data to Driver Method 2 P1
    + Sending Data to Driver Method 2 P2
    + Multiple Sequence in Parallel
    + Changing Arbitration Mechanism Pt
    + Changing Arbitration Mechanism P2
    + Ways to Hold access of Sequencer
    + Holding Access of Sequencer P1
    + Holding access of Sequencer P2 : Priority
    + Holding access of Sequencer P3 : Lock Method
+ Class 9: Projects: Combinational Adder
    + Agenda
    + Summary of the Verification Environment
    + Verification of Combinational adder : DUT
    + Transaction Class
    + Sequence Class
    + Driver Class
    + Monitor Class
    + Scoreboard Class
    + Agent Class
    + Environment Class
    + Test Class
    + Testbench Top
    + DUT + Interface
    + Testbench
    + A91
+ Class 10: Projects: Verification of Sequential Adder
    + Design + Interface
    + Transaction + Generator
    + Driver
    + Monitor + Scoreboard
    + Agent + ENV + TEST
    + Testbench Top
    + DUT + Interface
    + Testbench
    + A101
+ Class 11: Next Course of UVM Series
    + UVM for Verification Part 2: Projects

### UVM for Verification Part 2: Projects
+ Class 1- Agenda
+ Class 2- Verification of Combinational Circuit : 4-bit Multiplier
+ Class 3- Verification of Sequential Circuit : Data Flipflop
+ Class 4- Verification of UART
+ Class 5- Verification of SPI Memory
+ Class 6- Verification of I2C Memory
+ Class 7- Veriicantion of APB_ RAM
+ Class 8- Verification of AXI Memory
+ Class 9- Understanding usage of Sequence Library
+ Class 10- Understanding TLM Analysis FIFO
+ Class 11- Understanding Virtual Sequencer
+ Class 12- Next Course of UVM Series

### UVM for Verification Part 3: Register Abstraction Layer (RAL)
+ Class 1- Adding Register and Memory to Verification Environment
+ Class 2- Adding Register Block
+ Class 3- Understanding Adapter
+ Class 4- Different Register Method
+ Class 5- Different ways of accessing Register and Memories
+ Class 6- Explicit Predictor and Coverage
+ Class 7- Working with Memories
+ Class 8- Complete Project

## Notes
<!-- + Still working on this challenge -->
<!-- + Since the rest of the courses are about web developers, and I don't want to be a web developer, so this project stops here. -->
## Has My Life Changed?
> **Absolutely YES!**
> **Don't hesitate, come and take this class!**
> **Strongly Recommended!**


