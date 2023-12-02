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
`timescale 1ns/1ps

module FSM_TB ();
`include "instructions.sv"

  parameter M     = 4; // size of register address
  parameter N     = 4; // size of register data
  parameter P     = 6; // PC size and instruction memory address
  logic     clk      ;
  logic     rst_n    ;
  /* ---------------------- signals to/from register file --------------------- */
  logic [  1:0] select_source       ;
  logic [M-1:0] write_address       ;
  logic         write_en            ;
  logic [M-1:0] read_address_A      ;
  logic [M-1:0] read_address_B      ;
  logic         select_destination_A;
  logic         select_destination_B;
  logic [N-1:0] immediate_value     ;
  /* --------------------------- signals to/from ALU -------------------------- */
  logic [2:0] OP    ;
  logic       s_rst ;
  logic [2:0] ONZ   ;
  logic       enable;
  /* --------------------------- signals from instruction memory -------------- */
  logic [4+2*M-1:0] instruction_in    ;
  logic [4+2*M-1:0] instruction_reg   ;
  logic             en_read_instr     ;
  logic [    P-1:0] read_address_instr;
  /*Signals to the data memory*/
  logic SRAM_readEnable ;
  logic SRAM_writeEnable;
  logic ov_warning      ;

  FSM #(M,N,P) DUT (.*);
  fsm_prog_tb #(M,N,P) TB (.*);

  logic [P-1:0] tb_PC;
  logic         ov   ;

  initial
  begin
    clk = 0;
    rst_n = 0;
    #5;
    clk= 1'b1;
    #5;
    rst_n = 1;
    forever
    begin
      clk = ~clk;
      #5;
    end
  end


  initial
  begin
    forever
    begin
      @(DUT.ov);
      if(DUT.ov==1'b1)
        $finish;
    end
  end

endmodule

module fsm_prog_tb #(
    parameter M = 4, // size of register address
    parameter N = 4, // size of register data
    parameter P = 6  // PC size and instruction memory address
  ) (
    input  logic             clk                 ,
    input  logic             rst_n               ,
    /* ---------------------- signals to/from register file --------------------- */
    input logic [      1:0] select_source       ,
    input logic [    M-1:0] write_address       ,
    input logic             write_en            ,
    input logic [    M-1:0] read_address_A, read_address_B,
    input logic             select_destination_A, select_destination_B,
    input logic [    N-1:0] immediate_value     ,
    /* --------------------------- signals to/from ALU -------------------------- */
    input logic [      2:0] OP                  ,
    input logic             s_rst               ,
    output  logic [      2:0] ONZ                 ,
    input logic enable,
    /* --------------------------- signals from instruction memory -------------- */
    output  logic [4+2*M-1:0] instruction_in      ,
    input logic             en_read_instr       ,
    input logic [    P-1:0] read_address_instr,
    /*Signals to the data memory*/
    input logic SRAM_readEnable,
    input logic SRAM_writeEnable);

`include "instructions.sv"

  parameter logic [3:0] test_code[13:0] = { ADD,  SUB, AND, OR, XOR, NOT, BRN_Z, BRN_N, BRN_O, BRN, MOV, NOP, LOAD, STORE, LOAD_IM};

  logic [3:0] ra;
  logic [3:0] rb;
  int rand_c;

  initial
  begin
    instruction_in = 0;
    ONZ = 0;
    @(posedge(rst_n));
    for(int i = 0; i < 4; i=i+1)
    begin
      ONZ=0;
      if (i==3)
        ONZ = 0;
      else
        ONZ[i]=1'b1;
      foreach (test_code[i])
      begin
        @(posedge en_read_instr);
        //@(posedge clk);
        //#1ps;

        if ((test_code[i]== BRN_Z)||(test_code[i]== BRN_O)||(test_code[i]== BRN_N)||(test_code[i]== BRN))
        begin
          rand_c = $urandom_range(4,0);
          case (rand_c)
            0 :
            begin
              ra = 4'b1000;
              rb = 4'b0010;
            end

            1 :
            begin
              ra = 4'b0000;
              rb = 4'b0010;
            end

            2:
            begin
              ra = 4'b1000;
              rb = 4'b0011;
            end

            3:
            begin
              ra = 4'b0000;
              rb = 4'b0011;
            end
          endcase
        end
        else
        begin
          ra = $random;
          rb = $random;
        end
        instruction_in = {test_code[i], ra, rb};
      end
    end
    forever
    begin
      @(en_read_instr==1);
      @(posedge clk);
      //#1ps;
      instruction_in = {4'b0111, ra, rb};
    end
  end

endmodule
