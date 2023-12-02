
module ALU_reg  #(parameter N = 8) (
    input clk, rst_n, rst, Enable,
    input logic [2:0] OP, 
    input logic signed [N-1:0] A, 
    input logic signed [N-1:0] B, 
    /* --------------------------------- Outputs -------------------------------- */
    output logic  [2:0] ONZ,
    output logic signed [N-1:0] Result 
);
  // Add your ALU description here
  logic [N:0]Result_temp;

  
  //Output register
  logic [N:0]Result_temp_next;

  always_ff @( posedge clk, negedge rst_n) begin
    if(!rst_n)
      Result_temp <= '0;
    else begin
      Result_temp <= Result_temp_next;
    end
    
  end

  //ONZ register
  logic [2:0] ONZ_next;
  always_ff @( posedge clk, negedge rst_n ) begin 
    if(!rst_n | rst) ONZ <= '0;
    else if (Enable) begin
      ONZ <= ONZ_next;
    end
  end



  always_comb begin 
     //Initalise flags to 000
    ONZ_next = 3'b000;
    case (OP)

        //Addition
        3'b000 : begin
          Result_temp_next = (N+1)'(A) + (N+1)'(B);
        end

        //Subtraction
        3'b001 : begin
          Result_temp_next = (N+1)' (A) - (N+1)'(B);
        end

        //AND
        3'b010 : begin
          Result_temp_next = A & B;
        end
        //OR
        3'b011 : begin
          Result_temp_next = A | B;
        end

        //XOR
        3'b100 : begin
          Result_temp_next = A^B;
        end

        //Increment
        3'b101 : begin
          Result_temp_next = (N+1)'(A) + 4'b0001;
        end
        //MOV A
        3'b110 : begin
          Result_temp_next = A;
        end
        //MOV B
        3'b111 : begin 
          Result_temp_next = B;
        end  
        default : Result_temp_next  = 0; 
    endcase

    // if addition or subtraction set overflow flag
    if(!(OP[2] | OP[1])) begin
      if(Result_temp_next[N] != Result_temp_next[N-1])
        ONZ_next[2] = 1'b1;
    end

    // if the result is negative.
    if(Result_temp_next[N-1] == 1'b1)
      ONZ_next[1] = 1'b1;

      //if the all bits are 0
    if(Result_temp_next === 0)
      ONZ_next[0] = 1'b1;
  

    assign Result = Result_temp[N-1:0];
  end




endmodule