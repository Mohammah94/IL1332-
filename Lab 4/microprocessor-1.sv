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
module microprocessor #(parameter N = 8, ROM_addressBits = 6, RF_addressBits = 3) (
  /* --------------------------------- Inputs --------------------------------- */
  input  logic                           clk             ,
  input  logic                           rst_n           ,
  input  logic [ 3+2*(RF_addressBits):0] ROM_data        ,
  input  logic [                  N-1:0] SRAM_data       ,
  /* --------------------------------- Outputs -------------------------------- */
  output logic                           overflowPC      ,
  //Memory
  output logic                           ROM_readEnable  ,
  output logic                           SRAM_readEnable ,
  output logic                           SRAM_writeEnable,
  output logic [    ROM_addressBits-1:0] ROM_address     ,
  output logic [(2**RF_addressBits)-1:0] SRAM_address    ,
  output logic [                  N-1:0] SRAM_data_in
);

  // Connect your components here
  parameter FSM_M = 3; //size of register adress
  parameter FSM_N = 8; //size of register data
  parameter FSM_P = 6; //size of PC and instruction address

  parameter RF_N = 8; //size of registers
  parameter RF_addressbits = 3;

  parameter ALU_N = 8;


  /* --------------------------- signals to/from ALU -------------------------- */
  logic [2:0] OP_connect;
  logic       s_rst_connect;
  logic [2:0] ONZ_connect;
  logic       enable_connect;

  logic [ALU_N-1:0] ALU_result;

  logic [RF_N-1:0] ALU_A;
  logic [RF_N-1:0] ALU_B;
 /* ---------------------- signals to/from register file --------------------- */
  logic [  1:0] select_source_connect;
  logic [FSM_M-1:0] write_address_connect;
  logic             write_en_connect;
  logic [FSM_M-1:0] read_address_A_connect, read_address_B_connect;
  logic select_destination_A_connect, select_destination_B_connect;
  logic [FSM_N-1:0] immediate_value_connect;

  FSM #(FSM_M,FSM_N,FSM_P) fsm (
    //inputs
    .clk(clk),
    .rst_n(rst_n),
    .ONZ(ONZ_connect),
    .instruction_in(ROM_data),
    //outputs
    .ov_warning(overflowPC),
      //to RF
    .select_source(select_source_connect),
    .write_address(write_address_connect),
    .write_en(write_en_connect),
    .read_address_A(read_address_A_connect),
    .read_address_B(read_address_B_connect),
    .select_destination_A(select_destination_A_connect),
    .select_destination_B(select_destination_B_connect),
    .immediate_value(immediate_value_connect),
      //to ALU
    .OP(OP_connect),
    .s_rst(s_rst_connect),
    .enable(enable_connect),
     //to instruction memory
    .en_read_instr(ROM_readEnable),
    .read_address_instr(ROM_address),
      //to data memory
    .SRAM_readEnable(SRAM_readEnable),
    .SRAM_writeEnable(SRAM_writeEnable)
  );

  RF #(RF_N,RF_addressbits) register_file (
    //inputs
    .clk(clk),
    .rst_n(rst_n),
      //from FSM
    .selectDestinationA(select_destination_A_connect),
    .selectDestinationB(select_destination_B_connect),
    .selectSource(select_source_connect),
    .writeAddress(write_address_connect),
    .write_en(write_en_connect),
    .readAddressA(read_address_A_connect),
    .readAddressB(read_address_B_connect),
      //sources
    .A(ALU_result),
    .B(SRAM_data),
    .C(immediate_value_connect),
    //outputs
    .destination1A(ALU_A),
    .destination1B(ALU_B),
    .destination2A(SRAM_address),
    .destination2B(SRAM_data_in)
  );

  ALU_reg #(ALU_N) alu (
    //inputs
    .clk(clk),
    .rst_n(rst_n),
      //from FSM
    .Enable(enable_connect),
    .OP(OP_connect),
      //from RF
    .A(ALU_A),
    .B(ALU_B),
    //outputs
    .ONZ(ONZ_connect),
    .Result(ALU_result)
  );
endmodule