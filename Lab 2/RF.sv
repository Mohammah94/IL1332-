/*********************************************************************
*  IL1332 RF in Laboration 2
* Lab group 5
* Name1: Emil Scott-Robbert
* Name2: Fedor Baskin
* Name3: Mohamad Abou Helal
*
*********************************************************************/

module RF  #(parameter N = 8, parameter addressBits = 2) ( 
    /* --------------------------------- Inputs --------------------------------- */
    input logic clk,
    input logic rst_n,
    input logic selectDestinationA,
    input logic selectDestinationB,
    
    input logic [1:0] selectSource,
    input logic [addressBits-1:0] writeAddress,
    input logic write_en,
    input logic [addressBits-1:0] readAddressA,
    input logic [addressBits-1:0] readAddressB,

    input logic [N-1:0] A, 
    input logic [N-1:0] B, 
    input logic [N-1:0] C, 
    /* --------------------------------- Outputs -------------------------------- */
    output logic [N-1:0] destination1A,
    output logic [N-1:0] destination2A,
    output logic [N-1:0] destination1B,
    output logic [N-1:0] destination2B
);
    
    logic [N-1:0] Q [2**addressBits-1:0];
    logic [N-1:0] adress_decode;

    //Register file
    genvar i;
    generate
        for(i = 0; i < N; i++)begin
            always_ff@ (posedge clk, negedge rst_n)begin
                if(!rst_n) begin
                    if(i == 1) Q[i] <= '1;
                    else Q[i] <= 0;
                end
                else if(write_en & adress_decode[i]) begin
                    case(selectSource)
                        //A
                        2'b00 : begin
                            Q[i] <= A;
                        end
                        //B
                        2'b01 : begin
                            Q[i] <= B;
                        end
                        //C
                        2'b10 : begin
                            Q[i] <= C;
                        end
                        default : begin
                            Q[i] <= 0;
                        end
                    endcase
                end
            end
        end
    endgenerate

    always_comb begin // PORT A
        for(int i = 0; i < N; i++) begin
            case(selectDestinationA)
                0: begin
                    if(readAddressA == i) begin
                        destination1A = Q[i];
                        destination2A = 0;
                    end
                end
                1: begin
                    if(readAddressA == i) begin
                        destination1A = 0;
                        destination2A = Q[i];
                    end

                end

            endcase
        end
     end

     always_comb begin // PORT B
        for(int i = 0; i < N; i++) begin
            case(selectDestinationB)
                0: begin
                    if(readAddressB == i) begin
                        destination1B = Q[i];
                        destination2B = 0;
                    end
                end
                1: begin
                    if(readAddressB == i) begin
                        destination1B = 0;
                        destination2B = Q[i];
                    end

                end

            endcase
        end
     end

    // writeAdress Decoder
    always_comb begin
        adress_decode = 0;
        for(int i = 0; i < N; i++) begin
            if( writeAddress == i) adress_decode[i] = 1;
        end
    end

endmodule

