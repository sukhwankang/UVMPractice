`ifndef MY_DRIVER_SVH
`define MY_DRIVER_SVH

`include "my_scoreboard.svh"
`include "my_monitor.svh"

class my_driver extends uvm_driver #(my_transaction);

  `uvm_component_utils(my_driver)
  my_scoreboard scoreboard;
  my_monitor monitor;
  
  virtual dut_if dut_vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    // Get interface reference from config database
    if(!uvm_config_db#(virtual dut_if)::get(this, "", "dut_vif", dut_vif)) begin 
      `uvm_error("", "uvm_config_db::get failed")
    end
    // Get scoreboard handle from config database
    if (!uvm_config_db#(my_scoreboard)::get(this, "", "scoreboard", scoreboard)) begin
      `uvm_error("", "uvm_config_db::get failed for scoreboard")
    end
    // Debug message for scoreboard handle
    `uvm_info("DEBUG", $sformatf("Scoreboard handle: %p", scoreboard), UVM_MEDIUM);
    // Check if scoreboard is initialized properly
    if (scoreboard == null) begin
      `uvm_error("SCOREBOARD", "Scoreboard is not initialized properly.")
    end

  endfunction 

  task run_phase(uvm_phase phase);
    // First toggle reset
    dut_vif.reset = 1;
    @(posedge dut_vif.clock);
    #1;
    dut_vif.reset = 0;
    
    forever begin
      seq_item_port.get_next_item(req);
      `uvm_info("DRIVER", $sformatf("Driving: cmd=%0b, addr=0x%2h, data=0x%2h", req.cmd, req.addr, req.data), UVM_MEDIUM)
      dut_vif.cmd  = req.cmd;
      dut_vif.addr = req.addr;
      dut_vif.data = req.data;
      // Set expected values in the scoreboard
      scoreboard.set_expected_values(req.cmd, req.addr, req.data);
      @(posedge dut_vif.clock);
      `uvm_info(get_type_name(), "Transaction completed.", UVM_MEDIUM)
      seq_item_port.item_done();
    end
    
  endtask
  
endclass: my_driver

`endif // MY_DRIVER_SVH