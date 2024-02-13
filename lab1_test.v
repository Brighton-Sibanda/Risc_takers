`include "Synthesis/struct_exec_unit.v"
module ExecutionUnit_tb;

    // Inputs
    reg [31:0] opA, opB;
    reg [2:0] func;
    reg [6:0] auxFunc;
    
    // Output
    wire [31:0] out;

    // Instantiate the ExecutionUnit module
    ExecutionUnit UUT (
        .out(out),
        .opA(opA),
        .opB(opB),
        .func(func),
        .auxFunc(auxFunc)
    );

    // Clock generation
    reg clk = 0;
    always #5 clk = ~clk;

    // Testbench stimulus
    initial begin
        $dumpfile("ExecutionUnit_tb.vcd");
        $dumpvars(0, ExecutionUnit_tb);
        
        // Test Case 1: Addition (func=000, auxFunc[5]=0)
        opA = 10;
        opB = 5;
        func = 3'b000;
        auxFunc = 7'b0000000;
        #10;
        if (out !== 15) $display("Test Case 1 Failed");
        
        // Test Case 1.5: Subtraction (func=000, auxFunc[5]=1)
        opA = 10;
        opB = 5;
        func = 3'b000;
        auxFunc = 7'b0100000;
        #10;
	if (out !== 5) $display("Subtraction Failed");

        // Test Case 2: SLL (func=001)
        opA = 8;
        opB = 2;
        func = 3'b001;
        #10;
        if (out !== 32) $display("Test Case 2 Failed");

        // Test Case 3: SRA (func=101, auxFunc[5]=1)
        opA = -20;
        opB = 1;
        func = 3'b101;
        auxFunc = 7'b0100000;
        #20;
        if (out !== -10) $display("Test Case 3 Failed");
        
        // Test Case 3: SRL (func=101, auxFunc[5]=0)
	opA = 16;
        opB = 2;
        func = 3'b101;
        auxFunc = 7'b0000000;
        #10;
        if (out !== 4) $display("Logical shit right Failed");


        // Test Case 4: AND (func=111)
        opA = 5;
        opB = 3;
        func = 3'b111;
        #10;
        if (out !== 1) $display("Test Case 4 Failed");

        // Test Case 5: XOR (func=100)
        opA = 5;
        opB = 3;
        func = 3'b100;
        #10;
        if (out !== 6) $display("Test Case 5 Failed");
        
        // Test Case 6: OR (func=110)
        opA = 5;
        opB = 3;
        func = 3'b110;
        #10;
        if (out !== 7) $display("Test Case 6 Failed");

        // Test Case 7: SLT (func=010)
        opA = 5;
        opB = 8;
        func = 3'b010;
        #10;
        if (out !== 1) $display("Test Case 7 Failed");

     // Test Case 7.5: SLT (func=010)
        opA = -5;
        opB = -8;
        func = 3'b010;
        #10;
	if (out !== 0) $display("signed comparison Failed");

        
        // Test Case 8: SLTU (func=011)
        opA = -5;
        opB = -8;
        func = 3'b011;
        #10;
        if (out !== 0) $display("Test Case 8 Failed");

    // Test Case 9: MUL (func=011)
        opA = 8;
        opB = 3;
        func = 3'b000;
        auxFunc = 7'b1;
        #100;
        //if (out !== 0) $display("Test Case 9 Failed");


        $finish;
    end

    always begin
        #1 clk = ~clk;
    end
endmodule
