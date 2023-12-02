
module ALU  #(parameter N = 8) (
    input logic [2:0] OP, 
    input logic signed [N-1:0] A, 
    input logic signed [N-1:0] B, 
    /* --------------------------------- Outputs -------------------------------- */
    output logic  [2:0] ONZ,
    output logic signed [N-1:0] Result 
);
  // Add your ALU description here
  logic [N:0]Result_temp;
  always_comb begin 
     //Initalise flags to 000
    ONZ = 3'b000;
    case (OP)

        //Addition
        3'b000 : begin
          Result_temp = (N+1)'(A) + (N+1)'(B);
        end

        //Subtraction
        3'b001 : begin
          Result_temp = (N+1)' (A) - (N+1)'(B);
        end

        //AND
        3'b010 : begin
          Result_temp = A & B;
        end
        //OR
        3'b011 : begin
          Result_temp = A | B;
        end

        //XOR
        3'b100 : begin
          Result_temp = A^B;
        end

        //Increment
        3'b101 : begin
          Result_temp = (N+1)'(A) + 4'b0001;
        end
        //MOV A
        3'b110 : begin
          Result_temp = A;
        end
        //MOV B
        3'b111 : begin 
          Result_temp = B;
        end  
        default : Result_temp  = 0; 
    endcase

    // if addition or subtraction set overflow flag
    if(!(OP[2] | OP[1])) begin
      if(Result_temp[N] != Result_temp[N-1])
        ONZ[2] = 1'b1;
    end

    // if the result is negative.
     if(Result_temp[N-1] == 1'b1)
       ONZ[1] = 1'b1;

      //if the all bits are 0
      if(Result_temp === 0)
        ONZ[0] = 1'b1;
  

    assign Result = Result_temp[N-1:0];
  end
endmodule
