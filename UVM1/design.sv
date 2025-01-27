// This is the SystemVerilog interface that we will use to connect
// our design to our UVM testbench.
interface dut_if;
  logic clock, reset;
  logic cmd;
  logic [7:0] addr;
  logic [7:0] data;
  logic out_cmd;
  logic [7:0] out_addr;
  logic [7:0] out_data;
endinterface

`include "uvm_macros.svh"

// This is our design module.
// 
// It is an empty design that simply prints a message whenever
// the clock toggles.
module dut(dut_if dif);
  import uvm_pkg::*;
  always @(posedge dif.clock)
    if (dif.reset != 1) begin
      `uvm_info("2.DUT",
                $sformatf("Received cmd=%b, addr=0x%2h, data=0x%2h",
                          dif.cmd, dif.addr, dif.data), UVM_MEDIUM)
      dif.out_cmd<=dif.cmd;
      dif.out_addr<=dif.addr;
      dif.out_data<=dif.data;
    end
endmodule
