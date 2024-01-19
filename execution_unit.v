/*
 Northwestern University
 CompEng361 - Fall 2023
 Lab 1
 
 Name: Ben Ferreira
 NetID: bpf2734
 
 */

module ExecutionUnit(out, opA, opB, func, auxFunc);
  output [31:0] out;
  input [31:0]  opA, opB;
  input [2:0] 	 func;
  input [6:0] 	 auxFunc;

  // Place your code here
  reg [31:0] myOutput;
  wire signed [31:0] signedopA = $signed(opA);
  wire signed [31:0] signedopB = $signed(opB);
  reg enable = 1'b0;
  wire [31:0] mul_out;
  Booth_multiplication booth1(signedopA, signedopB, mul_out, enable);

  always @(*)
  begin
    //check each bit of the input to classify them
    // enable = 1'b0;
    case (func[2:0])
      //Arithmetic
      3'b000:
        if (auxFunc[5] == 1'b1)
        begin
          myOutput = opA - opB;
        end
        else if (auxFunc[0] == 1'b1)
        begin
          enable = 1'b1;
        end
        else
        begin
          myOutput = opA + opB;
        end

      //SRL and SRA
      3'b101:
        if (auxFunc[5] == 1'b1)
        begin
          myOutput = signedopA >>> signedopB;
        end
        else
        begin
          myOutput = opA >> opB;
        end
      3'b001:
        myOutput = opA << opB;
      3'b010:
        myOutput = 1 ? signedopA < signedopB : 0;
      3'b011:
        myOutput = 1 ? opA < opB : 0;
      3'b100:
        myOutput = opA ^ opB;
      3'b110:
        myOutput = opA | opB;
      3'b111:
        myOutput = opA & opB;
      default:
        myOutput = 32'b0;
    endcase
  end
  assign out = enable ? mul_out :  myOutput ;
endmodule // ExecutionUnit


module Booth_multiplication (signedopA, signedopB, out, enable);

  input signed [31:0] signedopA, signedopB;
  input enable;
  output signed [31:0] out;
  reg [31:0] out_result;
  reg [64:0] accumulator = 64'b0;
  reg [64:0] addition_val;
  reg signed sign;
  reg signed [31:0] cmpval;
  integer i;

  assign out = accumulator[31:0];
  always @(*) begin
      if (enable == 1'b1) begin
        addition_val = {signedopA, {32'b0}};
        for (i = 0; i < 32; i = i + 1) begin
            sign = accumulator[63];
            cmpval = signedopB[i-1];
            if (i == 1'b0) begin
              cmpval = 32'b0;
            end
            if (signedopB[i] == 1'b0 && cmpval == 1'b0) begin
              accumulator = accumulator + 1'b0;
            end
            else if (signedopB[i] == 1'b0 && cmpval == 1'b1) begin
              accumulator = accumulator + addition_val;
            end
            else if (signedopB[i] == 1'b1 && cmpval == 1'b0) begin 
              accumulator = accumulator - addition_val;
            end 
            else if (signedopB[i] == 1'b1 && cmpval == 1'b1) begin 
              accumulator = accumulator + 1'b0;
            end 

            accumulator = accumulator >> 1;
            accumulator[63] = sign;  
        end
        //sign = accumulator[31];
        // accumulator = accumulator >> 1;
        $display("answer is %8x", accumulator);
        //accumulator[31] = sign; 
      end
  end 



endmodule

