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

`include "instructions.sv"


module FSM #(
  parameter M = 4, // size of register address
  parameter N = 4, // size of register data
  parameter P = 6  // PC size and instruction memory address
) (
  input  logic clk,
  input  logic rst_n,
  output logic ov_warning,
  /* ---------------------- signals to/from register file --------------------- */
  output logic [  1:0] select_source,
  output logic [M-1:0] write_address,
  output logic             write_en,
  output logic [M-1:0] read_address_A, read_address_B,
  output logic select_destination_A, select_destination_B,
  output logic [N-1:0] immediate_value,
  /* --------------------------- signals to/from ALU -------------------------- */
  output logic [2:0] OP,
  output logic       s_rst,
  input  logic [2:0] ONZ,
  output logic       enable,
  /* --------------------------- signals from instruction memory -------------- */
  input  logic [4+2*M-1:0] instruction_in,
  output logic             en_read_instr,
  output logic [P-1:0]     read_address_instr,
  /*---------------------------Signals to the data memory--------------*/
  output logic SRAM_readEnable,
  output logic SRAM_writeEnable
);

enum logic [1:0] { idle = 2'b11, fetch = 2'b00, decode = 2'b01, execute= 2'b10} state, next;




/* ----------------------------- PROGRAM COUNTER ---------------------------- */
logic [  P-1:0] PC     ;
logic [  P-1:0] PC_next;
logic           ov     ;
logic           ov_reg ;
logic [2*M-1:0] offset ;

/*-----------------------------------------------------------------------------*/
// Add signals and logic here
logic [4+2*M-1:0] instruction_reg;
logic [2:0] ONZ_reg;
logic [2:0] ONZ_next;
logic take_branch;

parameter Source_A = 0; 
parameter Source_B = 1; 
parameter Source_C = 2;
parameter dest_ALU = 0; 
parameter dest_MEM = 1;
/*-----------------------------------------------------------------------------*/

//State register
always @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    state <= idle;
  end else begin
    state <= next;
  end
end

/*-----------------------------------------------------------------------------*/
// Describe your next state and output logic here

// Next state logic
always_comb begin
case (state)
 idle: begin 
    if(ov_reg) next = idle;
    else next = fetch;
 end

 fetch: begin
    next = decode;
 end

 decode: begin
    next = execute;
 end

 execute: begin
    if(ov) next = idle;
    else next = fetch;
 end
 default: begin
  next = idle;
 end
endcase
end

// Combinational output logic
always_comb begin
  ONZ_next = ONZ;
  case(state) 
    idle: begin 
      if(ov_reg) ov_warning = 1;
      else begin
        ov_warning = 0;
        ov = 0;
        PC_next = 0;
      end
      // deassert all ctrl signals
      select_source         = 0;
      write_address         = 0;
      write_en              = 0;
      read_address_A        = 0;
      read_address_B        = 0;
      select_destination_A  = 0;
      select_destination_B  = 0;
      immediate_value       = 0;
      OP                    = 0;
      s_rst                 = 0;
      enable                = 0;
      en_read_instr         = 0;
      read_address_instr    = 0;
      SRAM_readEnable       = 0;
      SRAM_writeEnable      = 0;
      ONZ_next              = 0;
    end

    fetch: begin 
      write_en = 0;
      immediate_value  = 0;
      SRAM_readEnable  = 0;
      SRAM_writeEnable = 0;
      en_read_instr = 1; //assert
      read_address_instr = PC;
    end

    decode: begin 
      take_branch = 0;
      case(instruction_in[4+2*M-1:2*M])
        ADD: begin
          //RF signlas
          read_address_A = instruction_in[2*M:M]; //operand A
          read_address_B = instruction_in[M-1:0]; //operand B
          select_destination_A = dest_ALU;
          select_destination_B = dest_ALU;

          //ALU signals
          OP = 3'b000;
          enable = 1'b1;
        end

        SUB: begin
          //RF signlas
          read_address_A = instruction_in[2*M:M]; //operand A
          read_address_B = instruction_in[M-1:0]; //operand B
          select_destination_A = dest_ALU;
          select_destination_B = dest_ALU;

          //ALU signals
          OP = 3'b001;
          enable = 1'b1;
        end

        AND: begin
          //RF signlas
          read_address_A = instruction_in[2*M:M]; //operand A
          read_address_B = instruction_in[M-1:0]; //operand B
          select_destination_A = dest_ALU;
          select_destination_B = dest_ALU;

          //ALU signals
          OP = 3'b010;
          enable = 1'b1;
        end

        OR: begin
          //RF signlas
          read_address_A = instruction_in[2*M:M]; //operand A
          read_address_B = instruction_in[M-1:0]; //operand B
          select_destination_A = dest_ALU;
          select_destination_B = dest_ALU;

          //ALU signals
          OP = 3'b011;
          enable = 1'b1;
        end
        
        XOR: begin
          //RF signlas
          read_address_A = instruction_in[2*M:M]; //operand A
          read_address_B = instruction_in[M-1:0]; //operand B
          select_destination_A = dest_ALU;
          select_destination_B = dest_ALU;

          //ALU signals
          OP = 3'b100;
          enable = 1'b1;
        end

        NOT: begin
          //RF signlas
          read_address_A = instruction_in[2*M:M]; //operand A
          //not needed but ALU does not care
          read_address_B = instruction_in[M-1:0]; //operand B
          select_destination_A = dest_ALU;
          select_destination_B = dest_ALU;

          //ALU signals
          OP = 3'b101;
          enable = 1'b1;
        end

        MOV: begin
          //RF signlas
          read_address_A = instruction_in[2*M:M]; //operand A
          //not needed
          read_address_B = instruction_in[M-1:0]; //operand B
          select_destination_A = dest_ALU;
          select_destination_B = dest_ALU;

          //ALU signals
          OP = 3'b110;
          enable = 1'b1;
        end

        NOP: begin
          //do nothing
        end

        LOAD: begin
          read_address_A = instruction_in[M-1:0]; //operand B
          select_destination_A = dest_MEM;

          SRAM_readEnable = 1;
        end

        STORE: begin
          read_address_A = instruction_in[M-1:0]; //operand B
          read_address_B = instruction_in[2*M:M]; //operand A
          select_destination_B = dest_MEM;
          select_destination_A = dest_MEM;

          SRAM_writeEnable = 1;
        end

        
        LOAD_IM: begin
          write_address = instruction_in[2*M:M]; //operand A

          immediate_value = (N)' (instruction_in[M-1:0]); //sign extend operand B (DATA)
          select_source = Source_C;
          write_en = 1;

          
        end
                
        BRN_Z: begin
          s_rst = 1;
          if(ONZ[0]) take_branch = 1;
        end

        BRN_N: begin
          s_rst = 1;
          if(ONZ[1]) take_branch = 1;
        end    
        
        BRN_O: begin
          s_rst = 1;
          if(ONZ[2]) take_branch = 1;
        end

        BRN: begin
          s_rst = 1;
          take_branch = 1;
        end

        default: begin
          // deassert all ctrl signals
          select_source         = 0;
          write_address         = 0;
          write_en              = 0;
          read_address_A        = 0;
          read_address_B        = 0;
          select_destination_A  = 0;
          select_destination_B  = 0;
          immediate_value       = 0;
          OP                    = 0;
          s_rst                 = 0;
          enable                = 0;
          en_read_instr         = 0;
          read_address_instr    = 0;
          SRAM_readEnable       = 0;
          SRAM_writeEnable      = 0;
        end
      endcase
    end
      
      execute: begin
        en_read_instr = 0; //deassert
        case(instruction_reg[4+2*M-1: 2*M])
          ADD: begin
            //RF signals
            select_source = Source_A;
            write_address = instruction_reg[2*M:M]; //operand A
            write_en = 1'b1;

            //ALU signals
            enable = 0;
          end

          SUB: begin
            //RF signals
            select_source = Source_A;
            write_address = instruction_reg[2*M:M]; //operand A
            write_en = 1'b1;

            //ALU signals
            enable = 0;
          end

          AND: begin
            //RF signals
            select_source = Source_A;
            write_address = instruction_reg[2*M:M]; //operand A
            write_en = 1'b1;

            //ALU signals
            enable = 0;
          end
  
          OR: begin
            //RF signals
            select_source = Source_A;
            write_address = instruction_reg[2*M:M]; //operand A
            write_en = 1'b1;

            //ALU signals
            enable = 0;
          end
          
          XOR: begin
            //RF signals
            select_source = Source_A;
            write_address = instruction_reg[2*M:M]; //operand A
            write_en = 1'b1;

            //ALU signals
            enable = 0;
          end
  
          NOT: begin
            //RF signlas
            select_source = Source_A;
            write_address = instruction_reg[2*M:M]; //operand A
            write_en = 1'b1;
  
            //ALU signals
            enable = 1'b0;
          end
  
          MOV: begin
            //RF signlas
            select_source = Source_A;
            write_address = instruction_reg[2*M:M]; //operand A
            write_en = 1;
  
            //ALU signal
            enable = 1'b0;
          end
  
          NOP: begin
          //do nothing
          end
  
          LOAD: begin
            select_source = Source_B;
            write_address = instruction_reg[2*M:M]; //operand A
            write_en = 1;

            //SRAM_readEnable = 0;
          end
  
          STORE: begin
            SRAM_writeEnable = 0;
          end
  
          
          LOAD_IM: begin
            //write_en = 0;
            //immediate_value = '0;
          end
                  
          BRN_Z: begin
            s_rst = 0;
          end
  
          BRN_N: begin
            s_rst = 0;
          end    
          
          BRN_O: begin
            s_rst = 0;
          end
  
          BRN: begin
            s_rst = 0;
          end

          default: begin
            // deassert all ctrl signals
            select_source         = 0;
            write_address         = 0;
            write_en              = 0;
            read_address_A        = 0;
            read_address_B        = 0;
            select_destination_A  = 0;
            select_destination_B  = 0;
            immediate_value       = 0;
            OP                    = 0;
            s_rst                 = 0;
            enable                = 0;
            en_read_instr         = 0;
            read_address_instr    = 0;
            SRAM_readEnable       = 0;
            SRAM_writeEnable      = 0;
          end
        endcase
        offset = instruction_reg[2*M-1:0];
        if(!take_branch) begin // if branch not taken or not branch instruction
          {ov,PC_next} = PC +1;
        end else begin // if branch is taken
          {ov,PC_next} = (offset[2*M-1] == 1) ? PC- offset[2*M-2:0] : PC + offset[2*M-2:0];
        end
        take_branch = 0; // reset branch signal
    end
    default: begin
      // deassert all ctrl signals
      select_source         = 0;
      write_address         = 0;
      write_en              = 0;
      read_address_A        = 0;
      read_address_B        = 0;
      select_destination_A  = 0;
      select_destination_B  = 0;
      immediate_value       = 0;
      OP                    = 0;
      s_rst                 = 0;
      enable                = 0;
      en_read_instr         = 0;
      read_address_instr    = 0;
      SRAM_readEnable       = 0;
      SRAM_writeEnable      = 0;
    end
  endcase

end
/*
Example of how to update the PC counter
if (offset[2*M-1]==1) begin
{ov,PC_next} = PC - offset[2*M-2:0];
end  else begin
{ov,PC_next} = PC + offset[2*M-2:0];
end
*/
/*-----------------------------------------------------------------------------*/





// Registered the output of the FSM when required
always_ff @(posedge clk, negedge rst_n) begin
  if(!rst_n) begin
    instruction_reg <= 0;
    ONZ_reg <= 0;
  end else begin
    instruction_reg <= instruction_in;
    ONZ_reg <= ONZ_next;
  end

end

// PC and overflow
always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    PC      <= 0;
    ov_reg  <= 0;
  end else begin
    PC     <= PC_next;
    ov_reg <= ov;
  end
end

endmodule