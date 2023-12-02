`timescale 10ns/1ns

module TB();
    parameter N = 4;
    logic [2:0] OP;
    logic signed [N-1:0] A; 
    logic signed [N-1:0] B; 
    /* --------------------------------- Outputs -------------------------------- */
    logic [2:0] ONZ;
    logic signed [N-1:0] Result;
    logic [N:0] Result_temp;
    logic [5:0] error_counter;

    ALU #(N) DUT (OP,A,B,ONZ,Result);

    initial begin
        error_counter = 6'b0;
        for(int k = 0; k < 8; k++) begin
            OP = k;
            for (int i = 0; i < 5 ; i++ ) begin
                for (int j  = 0; j < N ; j++ ) begin
                    A[j] = $random;
                    B[j] = $random;
                end
            case (OP)
                0: begin // addition
                    Result_temp[N:0] = (N+1)'(A) + (N+1)'(B);
                    #5;
                    assert( Result_temp[N-1:0] == Result[N-1:0]) $display ("OK. A + B");
                    else begin
                        $error("addition gone wrong");
                        error_counter++;
                    end 
                end
                1: begin //subtarction
                    Result_temp[N:0] = (N+1)' (A) - (N+1)'(B);
                    #5;
                    assert( Result_temp[N-1:0] == Result[N-1:0]) $display ("OK. A - B");
                    else begin
                        $error("Subtarction gone wrong");
                        error_counter++;
                    end

                    // check overflow flag
                    if(Result_temp[N] != Result_temp[N-1])
                    assert (ONZ[2] == 1'b1) $display ("Overflow flag correct");
                    else begin
                        $error("Overflow flag wrong");
                        error_counter++;
                    end 
                    else begin
                        assert ((ONZ[2] == 1'b0)) $display ("Overflow flag correct");
                        else begin
                            $error("Overflow flag wrong");
                            error_counter++;
                        end 
                    end
                end
                2: begin // AND
                    Result_temp = A & B;
                    #5;
                    assert( Result_temp[N-1:0] == Result[N-1:0]) $display ("OK. A & B");
                    else begin
                        $error("AND gone wrong");
                        error_counter++;
                    end
                end
                3: begin // OR
                    Result_temp = A | B;
                    #5;
                    assert( Result_temp[N-1:0] == Result[N-1:0]) $display ("OK. A | B");
                    else begin
                        $error("OR gone wrong");
                        error_counter++;
                    end
                end
                4: begin // XOR
                    Result_temp = A ^ B;
                    #5;
                    assert( Result_temp[N-1:0] == Result[N-1:0]) $display ("OK. A ^ B");
                    else begin
                        $error("XOR gone wrong");
                        error_counter++;
                    end
                end
                5: begin // INCREMENT A
                    Result_temp = (N+1)'(A) + 4'b0001;
                    #5;;
                    assert( Result_temp[N-1:0] == Result[N-1:0]) $display ("OK. INC A");
                    else begin
                        $error("INC gone wrong");
                        error_counter++;
                    end
                end
                6: begin // MOV A
                    Result_temp = A;
                    #5;
                    assert( Result_temp[N-1:0] == Result[N-1:0]) $display ("OK. MOV A");
                    else begin
                        $error("MOV A gone wrong");
                        error_counter++;
                    end
                end
                7:begin  // MOV B
                    Result_temp = B;
                    #5;
                    assert( Result_temp[N-1:0] == Result[N-1:0]) $display ("OK. MOV B");
                    else begin
                        $error("MOV B gone wrong");
                        error_counter++;
                    end
                end
                default:begin
                    $error("Faulty OP-code");
                    error_counter++;
                    #1;
                end    
            endcase

            // check overflow for addition and subtratction.
            if((OP == 0) || (OP == 1)) begin 
                if(Result_temp[N] != Result_temp[N-1])
                assert (ONZ[2] == 1'b1) $display ("Overflow flag correct");
                else begin
                    $error("Overflow flag wrong");
                    error_counter++;
                end 
                else begin
                    assert ((ONZ[2] == 1'b0)) $display ("Overflow flag correct");
                    else begin
                        $error("Overflow flag wrong");
                        error_counter++;
                    end 
                end
            end
            //check Overflow flag otherwise
            else begin
                assert ((ONZ[2] == 1'b0)) $display ("Overflow flag correct");
                else begin
                    $error("Overflow flag wrong");
                    error_counter++;
                end 
            end

            //check Negative flag
            if(Result_temp[N-1] == 1'b1) begin
                assert(ONZ[1] == 1'b1)  $display ("Negative flag correct");
                else begin
                    $error("Negative flag wrong");
                    error_counter++;
                end 
            end
            else begin
                assert(ONZ[1] == 1'b0)  $display ("Negative flag correct");
                else begin
                    $error("Negative flag wrong");
                    error_counter++;
                end 
            end
            //check Zero flag
            if(Result_temp[N-1:0] === 0) begin
                assert(ONZ[0] == 1'b1)  $display ("Zero flag correct");
                else begin
                    $error("Zero flag wrong");
                    error_counter++;
                end 
            end
            else begin
                assert(ONZ[0] == 1'b0)  $display ("Zero flag correct");
                else begin
                    $error("Zero flag wrong");
                    error_counter++;
                end 
            end
                
        end
        #5;
    end
    #5;
    $display("Total %d wrong results", error_counter);
end
    
endmodule
