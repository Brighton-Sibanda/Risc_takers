
module ExecutionUnit(out, opA, opB, func, auxFunc);
  output [31:0] out;
  input [31:0]  opA, opB;
  input [2:0] 	 func;
  input [6:0] 	 auxFunc;

  // Only supports add and subtract ,, commenting the code below, do we need it?
  // wire [31:0] 	 addSub;

  // assign addSub = (auxFunc == 7'b0100000) ? (opA - opB) : (opA + opB);
  // assign out = (func == 3'b000) ? addSub : 32'hXXXXXXXX;

  // execution code for single cycle as in lab 1.
  reg [31:0] myOutput;
  wire signed [31:0] signedopA = $signed(opA);
  wire signed [31:0] signedopB = $signed(opB);
  reg enable = 1'b0;
  wire [31:0] mul_out;

  BM bm1(.signedopA(signedopA), .signedopB(signedopB), .out(mul_out), .enable(enable));

  always @*
  begin

    //check each bit of the input to classify them
    case (func[2:0])
      //Arithmetic
      3'b000:
        if (auxFunc[5] == 1'b1)
        begin
          myOutput = opA - opB;
        end
        else if (auxFunc[0] == 1'b1)
        begin
          $display("multiplication answer is %8x", mul_out);
          enable = 1'b1;
        end
        else
        begin
          myOutput = opA + opB;
        end
      // SRL and SRA
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

module BM(signedopA, signedopB, out, enable);

  input wire signed [31:0] signedopA;
  input wire signed [31:0] signedopB;
  input wire enable;
  output wire signed [31:0] out;


  wire signed [31:0] signedopB_neg;
  wire signed [64:0] partial_products [31:0];
  wire signed [63:0] product_accumulator;
  wire signed [63:0] shifted;

  assign signedopB_neg = ~signedopB + 1;

  assign partial_products[0]  = signedopA[0]  ? {{32{1'b0}}, signedopA} + (signedopB_neg << 32) : {{32{1'b0}}, signedopA};

  assign partial_products[1]  = (partial_products[0][0] == partial_products[0][1])  ? (partial_products[0] >>> 1)  : (partial_products[0][1]) ? 
  ((partial_products[0] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[0] >>> 1));

  assign partial_products[2]  = (partial_products[1][0] == partial_products[1][1])  ? (partial_products[1] >>> 1)  : (partial_products[1][1]) ? 
  ((partial_products[1] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[1] >>> 1));

  assign partial_products[3]  = (partial_products[2][0] == partial_products[2][1])  ? (partial_products[2] >>> 1)  : (partial_products[2][1]) ? 
  ((partial_products[2] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[2] >>> 1));

  assign partial_products[4]  = (partial_products[3][0] == partial_products[3][1])  ? (partial_products[3] >>> 1)  : (partial_products[3][1]) ? 
  ((partial_products[3] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[3] >>> 1));

  assign partial_products[5]  = (partial_products[4][0] == partial_products[4][1])  ? (partial_products[4] >>> 1)  : (partial_products[4][1]) ? 
  ((partial_products[4] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[4] >>> 1));

  assign partial_products[6]  = (partial_products[5][0] == partial_products[5][1])  ? (partial_products[5] >>> 1)  : (partial_products[5][1]) ? 
  ((partial_products[5] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[5] >>> 1));

  assign partial_products[7]  = (partial_products[6][0] == partial_products[6][1])  ? (partial_products[6] >>> 1)  : (partial_products[6][1]) ? 
  ((partial_products[6] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[6] >>> 1));

  assign partial_products[8]  = (partial_products[7][0] == partial_products[7][1])  ? (partial_products[7] >>> 1)  : (partial_products[7][1]) ? 
  ((partial_products[7] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[7] >>> 1));

  assign partial_products[9]  = (partial_products[8][0] == partial_products[8][1])  ? (partial_products[8] >>> 1)  : (partial_products[8][1]) ? 
  ((partial_products[8] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[8] >>> 1));

  assign partial_products[10]  = (partial_products[9][0] == partial_products[9][1])  ? (partial_products[9] >>> 1)  : (partial_products[9][1]) ? 
  ((partial_products[9] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[9] >>> 1));

  assign partial_products[11]  = (partial_products[10][0] == partial_products[10][1])  ? (partial_products[10] >>> 1)  : (partial_products[10][1]) ? 
  ((partial_products[10] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[10] >>> 1));

  assign partial_products[12]  = (partial_products[11][0] == partial_products[11][1])  ? (partial_products[11] >>> 1)  : (partial_products[11][1]) ? 
  ((partial_products[11] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[11] >>> 1));

  assign partial_products[13]  = (partial_products[12][0] == partial_products[12][1])  ? (partial_products[12] >>> 1)  : (partial_products[12][1]) ?
  ((partial_products[12] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[12] >>> 1));

  assign partial_products[14]  = (partial_products[13][0] == partial_products[13][1])  ? (partial_products[13] >>> 1)  : (partial_products[13][1]) ? 
  ((partial_products[13] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[13] >>> 1));

  assign partial_products[15]  = (partial_products[14][0] == partial_products[14][1])  ? (partial_products[14] >>> 1)  : (partial_products[14][1]) ? 
  ((partial_products[14] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[14] >>> 1));

  assign partial_products[16]  = (partial_products[15][0] == partial_products[15][1])  ? (partial_products[15] >>> 1)  : (partial_products[15][1]) ? 
  ((partial_products[15] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[15] >>> 1));

  assign partial_products[17]  = (partial_products[16][0] == partial_products[16][1])  ? (partial_products[16] >>> 1)  : (partial_products[16][1]) ? 
  ((partial_products[16] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[16] >>> 1));

  assign partial_products[18]  = (partial_products[17][0] == partial_products[17][1])  ? (partial_products[17] >>> 1)  : (partial_products[17][1]) ? 
  ((partial_products[17] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[17] >>> 1));

  assign partial_products[19]  = (partial_products[18][0] == partial_products[18][1])  ? (partial_products[18] >>> 1)  : (partial_products[18][1]) ? 
  ((partial_products[18] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[18] >>> 1));
  
   assign partial_products[20]  = (partial_products[19][0] == partial_products[19][1])  ? (partial_products[19] >>> 1)  : (partial_products[19][1]) ? 
  ((partial_products[19] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[19] >>> 1));
  
   assign partial_products[21]  = (partial_products[20][0] == partial_products[20][1])  ? (partial_products[20] >>> 1)  : (partial_products[20][1]) ? 
  ((partial_products[20] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[20] >>> 1));
  
   assign partial_products[22]  = (partial_products[21][0] == partial_products[21][1])  ? (partial_products[21] >>> 1)  : (partial_products[21][1]) ? 
  ((partial_products[21] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[21] >>> 1));
  
   assign partial_products[23]  = (partial_products[22][0] == partial_products[22][1])  ? (partial_products[22] >>> 1)  : (partial_products[22][1]) ? 
  ((partial_products[22] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[22] >>> 1));
  
   assign partial_products[24]  = (partial_products[23][0] == partial_products[23][1])  ? (partial_products[23] >>> 1)  : (partial_products[23][1]) ? 
  ((partial_products[23] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[23] >>> 1));
  
   assign partial_products[25]  = (partial_products[24][0] == partial_products[24][1])  ? (partial_products[24] >>> 1)  : (partial_products[24][1]) ? 
  ((partial_products[24] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[24] >>> 1));
  
   assign partial_products[26]  = (partial_products[25][0] == partial_products[25][1])  ? (partial_products[25] >>> 1)  : (partial_products[25][1]) ? 
  ((partial_products[25] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[25] >>> 1));
  
   assign partial_products[27]  = (partial_products[26][0] == partial_products[26][1])  ? (partial_products[26] >>> 1)  : (partial_products[26][1]) ? 
  ((partial_products[26] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[26] >>> 1));
  
   assign partial_products[28]  = (partial_products[27][0] == partial_products[27][1])  ? (partial_products[27] >>> 1)  : (partial_products[27][1]) ? 
  ((partial_products[27] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[27] >>> 1));
  
   assign partial_products[29]  = (partial_products[28][0] == partial_products[28][1])  ? (partial_products[28] >>> 1)  : (partial_products[28][1]) ? 
  ((partial_products[28] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[28] >>> 1));
  
   assign partial_products[30]  = (partial_products[29][0] == partial_products[29][1])  ? (partial_products[29] >>> 1)  : (partial_products[29][1]) ? 
  ((partial_products[29] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[29] >>> 1));
  
   assign partial_products[31]  = (partial_products[30][0] == partial_products[30][1])  ? (partial_products[30] >>> 1)  : (partial_products[30][1]) ? 
  ((partial_products[30] >>> 1)+(signedopB_neg << 32)) : ((signedopB << 32) + (partial_products[30] >>> 1));
  


  assign shifted = partial_products[31];


  assign out = shifted >> 1;

endmodule