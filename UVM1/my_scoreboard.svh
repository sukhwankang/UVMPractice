`ifndef MY_SCOREBOARD_SVH
`define MY_SCOREBOARD_SVH

class my_scoreboard extends uvm_component;
  `uvm_component_utils(my_scoreboard)
  
  logic expected_cmd;
  logic [7:0] expected_addr;
  logic [7:0] expected_data;
  int i;
  
  // Analysis implementation
  uvm_analysis_imp#(my_transaction, my_scoreboard) analysis_imp; 

  function new(string name, uvm_component parent);
    super.new(name, parent);
    analysis_imp = new("analysis_imp", this);
    expected_cmd = 0;
    expected_addr = 0;
    expected_data = 0;
    i=0;
  endfunction

  virtual function void write(my_transaction tr);
        // Compare expected and monitored value
    if (tr.cmd != expected_cmd 
        || tr.addr != expected_addr
        || tr.data != expected_data) begin
          `uvm_error("SCOREBOARD", $sformatf("ERROR: 1.Got cmd=%0b, addr=0x%2h, data=0x%2h", tr.cmd, tr.addr, tr.data))
          `uvm_error("SCOREBOARD", $sformatf("ERROR: 2.Expected cmd=%0b, addr=0x%2h, data=0x%2h", expected_cmd, expected_addr, expected_data))
      ++i;
          end
    else begin
      `uvm_info("SCOREBOARD", $sformatf("MATCH: cmd=%0b, addr=0x%2h, data=0x%2h", tr.cmd, tr.addr, tr.data), UVM_MEDIUM)
      ++i;
      end
  endfunction
  
    // 기대값 설정 함수 (테스트 중에 호출되어야 함)
  function void set_expected_values(logic cmd, logic [7:0] addr, logic [7:0] data);
    expected_cmd = cmd;
    expected_addr = addr;
    expected_data = data;
  `uvm_info("DEBUG", $sformatf("DEBUG: Setting expected values complete: cmd=%0b, addr=0x%2h, data=0x%2h", expected_cmd, expected_addr, expected_data), UVM_MEDIUM)
  endfunction
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), $sformatf("Wrote %0d packets.", i), UVM_MEDIUM)
  endfunction
  
endclass

`endif // MY_SCOREBOARD_SVH
