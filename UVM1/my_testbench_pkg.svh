package my_testbench_pkg;
  import uvm_pkg::*;

  `include "my_sequence.svh"
  `include "my_driver.svh"
  `include "my_monitor.svh"
  `include "my_scoreboard.svh"

  // The agent contains sequencer, driver, and monitor
  class my_agent extends uvm_agent;
    `uvm_component_utils(my_agent)

    my_driver driver;
    uvm_sequencer #(my_transaction) sequencer;  // uvm_sequencer
    my_monitor monitor;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      driver = my_driver::type_id::create("driver", this);
      sequencer = uvm_sequencer#(my_transaction)::type_id::create("sequencer", this);
      monitor = my_monitor::type_id::create("monitor", this);
    endfunction

    // Connect the sequencer to the driver.
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

    task run_phase(uvm_phase phase);
      // We raise objection to keep the test from completing
      phase.raise_objection(this);
      begin
        my_sequence seq;
        seq = my_sequence::type_id::create("seq");
        // Start the sequence on the sequencer
        seq.start(sequencer);
      end
      // We drop objection to allow the test to complete
      phase.drop_objection(this);
    endtask

  endclass : my_agent

  // The environment contains agent and scoreboard
  class my_env extends uvm_env;
    `uvm_component_utils(my_env)

    my_agent agent;
    my_scoreboard scoreboard;

    function new(string name, uvm_component parent);
      super.new(name, parent);
      uvm_top.enable_print_topology = 1;
    endfunction

    function void build_phase(uvm_phase phase);
      agent = my_agent::type_id::create("agent", this);
      scoreboard = my_scoreboard::type_id::create("scoreboard", this);
      // Set Scoreboard handle to UVM configuration database
      uvm_config_db#(my_scoreboard)::set(this, "*", "scoreboard", scoreboard);
    endfunction

    // Connect the monitor to the scoreboard
    function void connect_phase(uvm_phase phase);
      agent.monitor.analysis_port.connect(scoreboard.analysis_imp);
    endfunction

  endclass : my_env

  // The test contains environment
  class my_test extends uvm_test;
    `uvm_component_utils(my_test)

    my_env env;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      env = my_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
      // We raise objection to keep the test from completing
      phase.raise_objection(this);
      //#10;
      `uvm_warning("", "Start test")
      // We drop objection to allow the test to complete
      phase.drop_objection(this);
    endtask

  endclass : my_test

endpackage
