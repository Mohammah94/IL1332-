/*********************************************************************
*  IL1332 testbench for RF in Laboration 2
* Lab group 5
* Name1: Emil Scott-Robbert
* Name2: Fedor Baskin
* Name3: Mohamad Abou Helal
*
*********************************************************************/

module ALU_reg_tb ();
    parameter N = 8;
    logic clk, rst_n, rst, Enable;
    logic [2:0] OP;
    logic signed [N-1:0] A; 
    logic signed [N-1:0] B; 
    /* --------------------------------- Outputs -------------------------------- */
    logic [2:0] ONZ;
    logic signed [N-1:0] Result;
    logic [N:0] Result_check;
    logic [5:0] error_counter;
    logic [2:0] test;

    ALU_reg #(N) DUT (.*);

    initial begin
        clk = 1'b1;
        forever begin
            #5;
            clk = ~clk;
        end
    end

    initial begin
        error_counter = 6'b0;
        //init
        rst_n = 0;
        rst = 0;
        Enable = 0;
        OP = 0;
        A = 0;
        B = 0;
        $display ("test start");
        #10;
        //--------------------Control Signal directed testing; (Enable, rst, !rst_n)---------------------------

            //-- control signal combinations where !rst_n 
            rst_n = 0;
            for(int i = 1; i < 8; i = i + 2) begin 
                #5;
                test = i;
                rst_n = 0;
                rst = test[1];
                Enable = test[2];
            
                #1;
                assert( Result[N-1:0] == 0) $display (" Result ctrl (%d%d%d). ok", test[2], test[1], test[0]);
                else begin
                    $error("ctrl error");
                    error_counter++;
                end
                assert( ONZ == 0) $display (" ONZ ctrl (%d%d%d). ok", test[2], test[1], test[0]);
                else begin
                    $error("ctrl error");
                    error_counter++;
                end 
                #4;
    
                //-- fill registers
                #5;
                rst_n = 1;
                rst = 0;
                Enable = 1;
                OP = 0;
                A = -127;
                B = -126;
                #5;

                #5; // registered inputs reach output;
            end
            $display ("loop over");
            
            
            //----------------------------------------------
            // control signal combinations where rst is asserted
            for(int i = 0; i < 4; i++) begin
                #5;
                // fill ONZ flag register
                rst_n = 1;
                rst = 0;
                Enable = 1;
                OP = 1;
                A = 5;
                B = 10;
                #5;
                // --
                #5;
                rst = 1;
                rst_n = ~(i & 2'b01);
                Enable = (i> 1) ? 1 :  0;
                test = {Enable,rst,~rst_n};
                Result_check[N-1:0] = (N+1)' (A) - (N+1)'(B);
                #5;
                
                #5;
                rst = 0;
                if(!rst_n) begin
                    assert( Result[N-1:0] == 0) $display (" Result ctrl (%d%d%d). ok", test[2], test[1], test[0]);
                    else begin
                        $error("Result error 1");
                        error_counter++;
                end
                end else begin
                    assert( Result[N-1:0] == Result_check[N-1:0]) $display (" Result ctrl (%d%d%d). ok", test[2], test[1], test[0]);
                    else begin
                        $error("Result error 2");
                        error_counter++;
                    end
                end

                assert( ONZ == 0) $display (" ONZ ctrl (%d%d%d). ok", test[2], test[1], test[0]);
                else begin
                    $error("ONZ error");
                    error_counter++;
                end 
                #5;
                

            end

        //-------------------------------------------------------------------
        // -----control signal combinations where Enable is asserted----------
            OP = 0;
            A = 127;
            B = 127;
            for(int i = 0; i < 4; i++)begin
                //reset
                #5;
                rst_n = 0;
                rst = 0;
                #5;
                #5;
                rst_n =1;
                #5;
                //----
                #5;
                rst_n = ~(i & 2'b01);
                rst = (i > 1) ? 1 : 0;
                Enable = 1;
                test = {Enable,rst,~rst_n};
                #5;
                #5;
                Enable = 0;
                if(!rst_n | rst) begin
                    assert( ONZ == 0) $display (" ONZ ctrl (%d%d%d). ok", test[2], test[1], test[0]);
                    else begin
                        $error("ONZ error");
                        error_counter++;
                    end
                end else begin
                    assert (ONZ == 6) $display (" ONZ ctrl (%d%d%d). ok", test[2], test[1], test[0]);
                    else begin
                        $error("ONZ error");
                        error_counter++;
                    end
                end
                #5;
            end

        //---------------------------------------------------------------------

        //-----------------------------Operation random testing----------------
        Enable = 1;
        rst = 0;
        A = 0;
        B = 0;
        //init
        rst_n = 0;
        #5;
        rst_n = 1;
        #5;
        #1;

       
        for(int k = 0; k < 8; k++) begin
            for (int i = 0; i < 5 ; i++ ) begin
                #4;
                OP = k;
                for (int j  = 0; j < N ; j++ ) begin
                    A[j] = $random;
                    B[j] = $random;
                end
            case (OP)
                0: begin // addition
                    Result_check[N:0] = (N+1)'(A) + (N+1)'(B);
                    #6;
                    assert( Result_check[N-1:0] == Result[N-1:0]) $display ("OK. A + B");
                    else begin
                        $error("addition gone wrong");
                        error_counter++;
                    end 
                end
                1: begin //subtarction
                    Result_check[N:0] = (N+1)' (A) - (N+1)'(B);
                    #6;
                    assert( Result_check[N-1:0] == Result[N-1:0]) $display ("OK. A - B");
                    else begin
                        $error("Subtarction gone wrong");
                        error_counter++;
                    end

                end
                2: begin // AND
                    Result_check = A & B;
                    #6;
                    assert( Result_check[N-1:0] == Result[N-1:0]) $display ("OK. A & B");
                    else begin
                        $error("AND gone wrong");
                        error_counter++;
                    end
                end
                3: begin // OR
                    Result_check = A | B;
                    #6;
                    assert( Result_check[N-1:0] == Result[N-1:0]) $display ("OK. A | B");
                    else begin
                        $error("OR gone wrong");
                        error_counter++;
                    end
                end
                4: begin // XOR
                    Result_check = A ^ B;
                    #6;
                    assert( Result_check[N-1:0] == Result[N-1:0]) $display ("OK. A ^ B");
                    else begin
                        $error("XOR gone wrong");
                        error_counter++;
                    end
                end
                5: begin // INCREMENT A
                    Result_check = (N+1)'(A) + 4'b0001;
                    #6;
                    assert( Result_check[N-1:0] == Result[N-1:0]) $display ("OK. INC A");
                    else begin
                        $error("INC gone wrong");
                        error_counter++;
                    end
                end
                6: begin // MOV A
                    Result_check = A;
                    #6;
                    assert( Result_check[N-1:0] == Result[N-1:0]) $display ("OK. MOV A");
                    else begin
                        $error("MOV A gone wrong");
                        error_counter++;
                    end
                end
                7:begin  // MOV B
                    Result_check = B;
                    #6;
                    assert( Result_check[N-1:0] == Result[N-1:0]) $display ("OK. MOV B");
                    else begin
                        $error("MOV B gone wrong");
                        error_counter++;
                    end
                end
                default:begin
                    $error("Faulty OP-code");
                    error_counter++;
                    #6;
                end    
            endcase

            // check overflow for addition and subtratction.
            if((OP == 0) || (OP == 1)) begin 
                if(Result_check[N] != Result_check[N-1])
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
            if(Result_check[N-1] == 1'b1) begin
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
            if(Result_check[N-1:0] === 0) begin
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
    end
    //-------------------------------------------------------------------

    #5;
    $display("Total %d wrong results", error_counter);

    

end


endmodule
