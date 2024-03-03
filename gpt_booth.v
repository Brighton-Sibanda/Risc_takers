

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
  wire [63:0] mul_out;
  Booth_multiplication booth1(signedopA, signedopB, mul_out, enable);

  always @(*)
  begin
    //check each bit of the input to classify them
    enable = 1'b0;
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
  assign out = enable ? mul_out[31:0] :  myOutput ;
endmodule // ExecutionUnit




module Booth_multiplication(
  input signed [31:0] multiplicand,
  input signed [31:0] multiplier,
  output reg signed [63:0] product,
  input enable
);

  reg signed [63:0] partial_product;
  reg [2:0] state;
  reg signed [31:0] multiplicand_reg;

  integer i;

  always begin
    partial_product = 0;
    multiplicand_reg = multiplicand;
    for (i = 31; i >= 0; i = i - 1) begin
      case (state)
        3'b000: begin // Initialize
          state <= 3'b001;
        end
        3'b001: begin // Loop through multiplier bits
          if (multiplier[i:i-1] == 2'b00) begin // Two zeros, shift only
            partial_product = partial_product >> 1;
          end else if (multiplier[i:i-1] == 2'b11) begin // Two ones, subtract and shift
            partial_product = partial_product - multiplicand_reg;
            state = 3'b010;
          end else begin // One zero and one one, add and shift
            partial_product = partial_product + multiplicand_reg;
            state = 3'b011;
          end
          multiplier = multiplier >> 1;
        end
        3'b010: begin // After subtraction, possible correction needed
          if (multiplier[i-1] == 0) begin // No correction needed
            state = 3'b001;
          end else begin // Add back multiplicand
            partial_product = partial_product + multiplicand_reg;
            state = 3'b001;
          end
        end
        3'b011: begin // After addition, possible correction needed
          if (multiplier[i-1] == 1) begin // No correction needed
            state = 3'b001;
          end else begin // Subtract back multiplicand
            partial_product = partial_product - multiplicand_reg;
            state = 3'b001;
          end
        end
      endcase
    end
    product = partial_product;
  end

endmodule
