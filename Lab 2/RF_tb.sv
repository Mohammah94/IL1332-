/*********************************************************************
*  IL1332 testbench for RF in Laboration 2
* Lab group 5
* Name1: Emil Scott-Robbert
* Name2: Fedor Baskin
* Name3: Mohamad Abou Helal
*
*********************************************************************/

module RF_tb ();
    parameter N = 8;
    parameter addressBits = 2;

     //---------------------- Inputs ------------------
    logic clk, rst_n, write_en,
    selectDestinationA, selectDestinationB;
    logic [1:0] selectSource;
    logic [addressBits-1:0] writeAddress;
    logic [addressBits-1:0] readAddressA;
    logic [addressBits-1:0] readAddressB;

    logic[N-1:0] A;
    logic[N-1:0] B;
    logic[N-1:0] C;

    //---------------------- Outputs ------------------
    logic [N-1:0] destination1A;
    logic [N-1:0] destination2A;
    logic [N-1:0] destination1B;
    logic [N-1:0] destination2B;

    RF #(N,addressBits) DUT (.*);

    initial begin
        clk = 1'b1;
        forever begin
            #5;
            clk = ~clk;
        end
    end

    initial begin
        //1st cycle  init
        rst_n = 1'b0;
        write_en = 1'b0;
        {selectDestinationA,selectDestinationB} = 1'b0;
        selectSource = 1'b0;
        writeAddress = 0;
        readAddressA = 1'b0;
        readAddressB = 1'b0;
        A = 1;
        B = 2;
        C = 3;

        #10;
        //2nd cycle
        #5;
        rst_n = 1;
        write_en = 1'b1;
        #5;;

        //3rd cycle -- Read/write
        #5;
        write_en = 1'b0;
        assert (destination1A == A) $display("destination1A OK");
        else   $error("destination1A wrong");
        assert (destination2A == 0) $display("destination2A OK");
        else   $error("destination2A wrong");
        assert (destination1B == A) $display("destination1B OK");
        else   $error("destination1B wrong");
        assert (destination2B == 0) $display("destination2B OK");
        else   $error("destination2B wrong");
        #5;

        //4th cycle -- reset
        rst_n = 1'b0;
        #5;
        readAddressA = 1'b0;
        readAddressB = 1'b1;
        #5;
        assert (destination1A == 0) $display("destination1A OK");
        else   $error("destination1A wrong");
        assert (destination2A == 0) $display("destination2A OK");
        else   $error("destination2A wrong");
        assert (destination1B == '1) $display("destination1B OK");
        else   $error("destination1B wrong");
        assert (destination2B == 0) $display("destination2B OK");
        else   $error("destination2B wrong");

        //5th -- enable off
        #5;
        rst_n = 1'b1;
        writeAddress = 2;
        selectSource = 2'b01;
        #5;

        //6th (not) write to RF
        #5;
        readAddressA = 2'b10;
        selectDestinationA = 1'b1;
        #5;

        //7th verify not written
        #5;
        assert (destination1A == 0) $display("destination1A OK");
        else   $error("destination1A wrong");
        assert (destination2A != C) $display("destination2A OK");
        else   $error("destination2A wrong");
        assert (destination1B == '1) $display("destination1B OK");
        else   $error("destination1B wrong");
        assert (destination2B == 0) $display("destination2B OK");
        else   $error("destination2B wrong");
        #5;

        //8th enable on
        #5;
        write_en = 1;
        writeAddress = 1;
        selectSource = 2'b10; // source C
        #5;

        //9th write to RF
        #5;
        write_en = 0;
        readAddressB = 2'b01;
        selectDestinationB = 1'b1;
        #5;

        //10th verify written
        #5;
        assert (destination1A == 0) $display("destination1A OK");
        else   $error("destination1A wrong");
        assert (destination2A == 0) $display("destination2A OK");
        else   $error("destination2A wrong");
        assert (destination1B == 0) $display("destination1B OK");
        else   $error("destination1B wrong");
        assert (destination2B == C) $display("destination2B OK");
        else   $error("destination2B wrong");
        #5;
    end
endmodule
