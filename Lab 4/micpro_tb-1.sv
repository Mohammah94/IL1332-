//-------------- Copyright (c) notice -----------------------------------------
//
// The SV code, the logic and concepts described in this file constitute
// the intellectual property of the authors listed below, who are affiliated
// to KTH (Kungliga Tekniska Högskolan), School of EECS, Kista.
// Any unauthorised use, copy or distribution is strictly prohibited.
// Any authorised use, copy or distribution should carry this copyright notice
// unaltered.
//-----------------------------------------------------------------------------
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
//                                                                         #
//This file is part of IL1332 and IL2234 course.                           #
//                                                                         #
//    The source code is distributed freely: you can                       #
//    redistribute it and/or modify it under the terms of the GNU          #
//    General Public License as published by the Free Software Foundation, #
//    either version 3 of the License, or (at your option) any             #
//    later version.                                                       #
//                                                                         #
//    It is distributed in the hope that it will be useful,                #
//    but WITHOUT ANY WARRANTY; without even the implied warranty of       #
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        #
//    GNU General Public License for more details.                         #
//                                                                         #
//    See <https://www.gnu.org/licenses/>.                                 #
//                                                                         #
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
module micpro_tb ();
  logic clk        = 0;
  logic rst_n      = 0;
  logic overflowPC    ;

  parameter N               = 8;
  parameter ROM_addressBits = 6;
  parameter RF_addressBits  = 3;

  microprocessor_n_memory #(N,ROM_addressBits,RF_addressBits) DUT (clk,rst_n,overflowPC);

  always #5ns clk = ~clk;

  initial begin
    //reset to zero RF etc
    rst_n = 0;
    #10ns;
    rst_n = 1;
  end
  always @(posedge clk) begin
    if (overflowPC) begin
      assert (DUT.U_SRAM.SRAM_memory[0]==2) $display("Data in SRAM 0 location are correct");
      else   $error("Data in the SRAM 0 location are wrong");
      assert (DUT.U_SRAM.SRAM_memory[1]==3) $display("Data in SRAM 0 location are correct");
      else   $error("Data in the SRAM 1 location are wrong");
      assert (DUT.U_SRAM.SRAM_memory[2]==4) $display("Data in SRAM 0 location are correct");
      else   $error("Data in the SRAM 2 location are wrong");
      assert (DUT.U_SRAM.SRAM_memory[3]==5) $display("Data in SRAM 0 location are correct");
      else   $error("Data in the SRAM 3 location are wrong");
      assert (DUT.U_SRAM.SRAM_memory[4]==6) $display("Data in SRAM 0 location are correct");
      else   $error("Data in the SRAM 4 location are wrong");
      assert (DUT.U_SRAM.SRAM_memory[5]==7) $display("Data in SRAM 0 location are correct");
      else   $error("Data in the SRAM 5 location are wrong");
      $finish;
    end
  end
endmodule