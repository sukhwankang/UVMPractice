`ifndef MY_MONITOR_SVH
`define MY_MONITOR_SVH

class my_monitor extends uvm_monitor;

  //  `uvm_component_utils(my_monitor)
  int i=0;
  `uvm_component_utils_begin(my_monitor)
  `uvm_field_int(i, UVM_ALL_ON)
  `uvm_component_utils_end
  
  virtual dut_if dut_vif;
  uvm_analysis_port#(my_transaction) analysis_port; // Analysis port

  function new(string name, uvm_component parent);
    super.new(name, parent);
    analysis_port = new("analysis_port", this); 
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual dut_if)::get(this, "", "dut_vif", dut_vif)) begin
      `uvm_error("", "uvm_config_db::get failed")
    end
  endfunction

  task run_phase(uvm_phase phase);
    my_transaction tr;
    tr = my_transaction::type_id::create("tr", this);
    
    forever begin
      @(posedge dut_vif.clock);
      if(dut_vif.reset == 0) begin
      tr.cmd = dut_vif.out_cmd; 
      tr.addr = dut_vif.out_addr; 
      tr.data = dut_vif.out_data; 
      `uvm_info("MONITOR", $sformatf("DUT Received cmd=%0b, addr=0x%2h, data=0x%2h", tr.cmd, tr.addr, tr.data), UVM_MEDIUM)
      ++i;
      analysis_port.write(tr); // Send transction to analysis port
      end
    end
  endtask
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), $sformatf("Processed %0d packets.", i), UVM_MEDIUM)
  endfunction

endclass: my_monitor

`endif  // MY_MONITOR_SVH