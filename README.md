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
        + 123
    + Fundamentals P2
    + Fundamentals P3
    + Target
        + `aaa`
    + Creating Class
    + Deriving class from UVM_OBJECT
    + Using Field Macros P1 : INT
    + Using Field Macros P2 : INT cont
    + Using Field Macros P2 : ENUM, REAL
    + Using Field Macros P3 : OBJECT
    + Using Field Macros P4 : Arrays
    + Copy and Clone Method
    + Shallow Vs Deep Copy
    + Copy and Clone Method
    + Compare Method
    + Create Method
    + Factory Override : new vs create method
    + do_print Method
    + convert2string method
    + do_copy method
    + do_compare
    + A21
    + A22
+ Class 4: UVM_COMPONENT
    + Agenda
    + Understanding UVM TREE
    + Creating UVM_COMPONENT class
    + Creating UVM_TREE P1
    + Creating UVM_TREE P2
+ Class 5: config_db
    + Agenda
    + Understanding typical format of config_db
    + Demonstration P1
    + Demonstration P2
    + Demonstration P3
    + Demonstration P4
    + Used Case
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
    + Drain Time : Individual Component
    + Drain Time : Multiple Components
    + Phase Debug
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


