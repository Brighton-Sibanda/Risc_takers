// 
// Groupname: Risc Takers
// NetIDs: 

// Some useful defines...please add your own
`define OPCODE_COMPUTE    7'b0110011
`define OPCODE_IMM        7'b0010011
`define OPCODE_BRANCH     7'b1100011
`define OPCODE_LOAD       7'b0000011
`define OPCODE_STORE      7'b0100011
`define OPCODE_LUI        7'b0110111
`define OPCODE_JAL        7'b1101111
`define OPCODE_JALR       7'b1100111
`define OPCODE_AUIPC      7'b0010111
`define FUNC_ADD      3'b000
`define AUX_FUNC_ADD  7'b0000000
`define AUX_FUNC_SUB  7'b0100000
`define SIZE_BYTE  2'b00
`define SIZE_HWORD 2'b01
`define SIZE_WORD  2'b10

`include "lib_lab2.v"

module RunCPU(halt, clk, rst);
  
  output halt;
  input clk, rst;
  wire [31:0] PC, InstWord, DataAddr, StoreData, DataWord;
  wire [31:0]  Rdata1, Rdata2, RWrdata, NPC;
  wire [4:0] Rsrc1, Rsrc2, Rdst;
  wire [1:0] MemSize;
  wire MemWrEn, RWrEn;

  InstMem IMEM(.Addr(PC), .Size(`SIZE_WORD), .DataOut(InstWord), .CLK(clk));
  DataMem DMEM(.Addr(DataAddr), .Size(MemSize), .DataIn(StoreData), .DataOut(DataWord), .WEN(MemWrEn), .CLK(clk));

  RegFile RF(.AddrA(Rsrc1), .DataOutA(Rdata1),
              .AddrB(Rsrc2), .DataOutB(Rdata2),
              .AddrW(Rdst), .DataInW(RWrdata), .WenW(RWrEn), .CLK(clk));

  Reg PC_REG(.Din(NPC), .Qout(PC), .WEN(1'b0), .CLK(clk), .RST(rst));

  PipelinedCPU PCPU (.halt(halt), .clk(clk), .rst(rst), .Rsrc1(Rsrc1), .Rsrc2(Rsrc2), .Rdst(Rdst),
                     .DataAddr(DataAddr), .StoreData(StoreData), .NPC(NPC), .RWrdata(RWrdata),
                     .PC(PC), .MemSize(MemSize), .MemWrEn(MemWrEn), .RWrEn(RWrEn),
                     .InstWord(InstWord), .DataWord(DataWord), .Rdata1(Rdata1), .Rdata2(Rdata2));


endmodule

module PipelinedCPU(halt, clk, rst, Rsrc1, Rsrc2, Rdst,
                     DataAddr, StoreData, NPC, RWrdata, PC, MemSize, MemWrEn, RWrEn,
                     InstWord, DataWord, Rdata1, Rdata2);
  output halt;
  input clk, rst;

  // sent to other modules because we edit them to input back
  output [31:0] DataAddr, StoreData, NPC, RWrdata;
  output [4:0] Rsrc1, Rsrc2, Rdst;
  output [1:0] MemSize;
  output MemWrEn, RWrEn;
  input [31:0] InstWord, DataWord, Rdata1, Rdata2, PC; 

  // received from other modules

  // Pipeline variables
  reg [31:0] loops = 1;
  reg [31:0] loops_next;
  reg [4:0] stages= 5'b00000;
  reg[4:0] next_stages= 5'b00001;
  reg [31:0] fetch_reg, fetch_reg_dec, fetch_reg_ex, fetch_reg_mem, fetch_reg_wb;
  reg [31:0] fetch_reg_dec_next, fetch_reg_ex_next, fetch_reg_mem_next, fetch_reg_wb_next;
  reg [4:0]  Rsrc1_reg, Rsrc2_reg, Rdst_reg, Rsrc1_reg_ex, Rsrc2_reg_ex, Rdst_reg_ex;
  reg [4:0]  Rsrc1_reg_ex_next, Rsrc2_reg_ex_next, Rdst_reg_ex_next;
  reg [2:0]  funct3_reg, funct3_reg_ex;
  reg [2:0]  funct3_reg_ex_next;
  reg [31:0] DataAddrRegEx, DataAddrRegMem, DataAddrRegWb;
  reg [31:0] DataAddrMem, DataAddrMem_next;
  reg [31:0] DataAddrRegMem_next, DataAddrRegWb_next;
  reg [31:0] StoreDataRegEx, StoreDataRegMem, StoreDataRegWb, RWrdataRegEx, RWrdataRegMem, RWrdataRegWb;
  reg [1:0]  RWrEnRegMem;
  reg [1:0]  RWrEnRegMem_next;
  reg [31:0] StoreDataRegEx_next, StoreDataRegMem_next, StoreDataRegWb_next, RWrdataRegEx_next, RWrdataRegMem_next, RWrdataRegWb_next;
  reg [1:0]  RWrEnRegWb, MemWrEnRegMem, MemWrEnRegWb, MemSizeRegEx, MemSizeRegMem, MemSizeRegWb;
  reg [1:0]  RWrEnRegWb_next, MemWrEnRegMem_next, MemWrEnRegWb_next, MemSizeRegEx_next, MemSizeRegMem_next, MemSizeRegWb_next;
  reg [6:0] opcode_reg, opcode_reg_ex, opcode_reg_mem, opcode_reg_wb;
  reg [6:0] opcode_reg_next, opcode_reg_ex_next, opcode_reg_mem_next, opcode_reg_wb_next;
  reg [6:0] funct7RegEx, funct7RegMem, funct7RegWb;
  reg [6:0] funct7RegEx_next, funct7RegMem_next, funct7RegWb_next;
  reg [31:0] PCRegDec, PCRegEx, PCRegMem, PCRegWb;
  reg [31:0] PCRegDec_next, PCRegEx_next, PCRegMem_next, PCRegWb_next;
  reg [31:0] imm_reg, imm_reg_ex, imm_reg_mem;
  reg [31:0] imm_reg_ex_next, imm_reg_mem_next;
  reg [31:0] opA_immRegEx, opA_immRegMem, opA_immRegWb;
  reg [31:0] opA_immRegMem_next, opA_immRegWb_next;
  reg [31:0] opB_immRegEx, opB_immRegMem, opB_immRegWb;
  reg [31:0] opB_immRegMem_next, opB_immRegWb_next;
  reg [31:0] opA_alt, Rdata1_fin, Rdata2_fin, opA_alt2, opA_alt3;
  reg [14:0] forward_signals = 1'b0;
  reg [1:0] forward_index = 2'b10;
  // end of pipeline variables

  //wire [31:0] PC, InstWord;
  //wire [31:0] DataAddr, StoreData, DataWord;
  //wire [1:0]  MemSize;
  //wire        MemWrEn;

  //wire [4:0]  Rsrc1, Rsrc2, Rdst;
  //wire [31:0] Rdata1, Rdata2, RWrdata;
  wire [31:0] RWrdataWire;
  wire        RWrEn;

  // wire [31:0] NPC, 
  wire [31:0] PC_Plus_4;
  wire [6:0]  opcode;

  wire [6:0]  funct7;
  wire [2:0]  funct3;


  // Additionaly registers for easy usage
  reg [31:0] PCReg, InstWordReg;
  reg [31:0] DataAddrReg, StoreDataReg, DataWordReg;
  reg [1:0]  MemSizeReg;
  reg        MemWrEnReg;

  reg [4:0]  Rsrc1Reg, Rsrc2Reg, RdstReg, RdstRegMem, RdstRegMem_next, RdstRegWb, RdstRegWb_next;
  reg [31:0] Rdata1Reg, Rdata2Reg, RWrdataReg;
  reg        RWrEnReg;

  reg [31:0] NPCReg, PC_Plus_4Reg;
  reg [6:0]  opcodeReg;

  reg [6:0]  funct7Reg;
  reg [2:0]  funct3Reg;

  // Additional Wires for easy usage
  wire [31:0] imm;
  wire [31:0] opB_imm, opA_imm;

  reg [31:0] immReg;
  reg [31:0] opB_immReg, opA_immReg;
  reg        haltFlagReg;
  reg [31:0] temp_addrReg;
  reg signed [31:0] signed_tempReg;
  reg signed [31:0] signed_temp_twoReg;
  reg [31:0] tempReg;

  // ***** NEW REG VARS HERE ******** /////
  reg [1:0] branch_predictor; 
  reg [1:0] branch_predictor_next; 
  reg [31:0] btb;
  reg took_branch; 
  reg [31:0] took_branch_addr;
  reg [31:0] btb_next;

  reg took_branch_ex; 
  reg [31:0] took_branch_addr_ex;


  reg startReg = 1'b0;

  reg miss_predict = 1'b0; //MUST GET RESET EVERY CLOCK EDGE!

  // end of additional wires

  reg [5:0] ex_ford_lab, mem_ford_lab;
  reg [5:0] ex_ford_lab_next, mem_ford_lab_next;

  reg[31:0 ]ex_ford, mem_ford;
  reg[31:0 ]ex_ford_next, mem_ford_next;

  reg loadHalt = 1'b0;
  reg loadHalted = 1'b0;


  reg miss_predicted = 1'b0; //MUST GET RESET EVERY CLOCK EDGE!
  // halt on haltflagreg
  assign halt = haltFlagReg;

  // System State (everything is neg assert)

  ExecutionUnit EU(.out(RWrdataWire), .opA(opA_imm), .opB(opB_imm), .func(funct3), .auxFunc(funct7));
  // Fetch Address Datapath
  assign PC_Plus_4 = PC + 4;

  //register output works for execute stage ( no other stages use it? )
  assign Rsrc1 = fetch_reg_ex[19:15]; //Rsrc is based off the execute, that is where we use the output
  assign Rsrc2 = fetch_reg_ex[24:20];
  assign Rdst = RdstReg;

  //Asign
  assign DataAddr = DataAddrReg;
  assign MemSize = MemSizeReg;
  assign StoreData = StoreDataReg;
  assign MemWrEn = MemWrEnReg;

  assign RWrdata = RWrdataReg;
  assign RWrEn = RWrEnReg;
  assign Rdst = RdstReg;
  assign opA_imm = opA_immReg;
  assign opB_imm = opB_immReg;
  assign funct7 = funct7Reg;
  assign funct3 = funct3Reg;
  assign NPC = PCReg;

  always @(negedge clk)
  begin
    fetch_reg_dec = fetch_reg_dec_next;
    fetch_reg_ex =  fetch_reg_ex_next;
    fetch_reg_mem = fetch_reg_mem_next;
    fetch_reg_wb = fetch_reg_wb_next;
    opA_immRegMem = opA_immRegMem_next;
    opA_immRegWb = opA_immRegWb_next;
    opB_immRegMem = opA_immRegMem_next;
    opB_immRegWb = opA_immRegWb_next;
    opcode_reg_ex = opcode_reg_ex_next;
    opcode_reg_mem = opcode_reg_mem_next;
    opcode_reg_wb = opcode_reg_wb_next;
    funct3_reg_ex = funct3_reg_ex_next;
    funct7RegMem = funct7RegMem_next;
    funct7RegWb = funct7RegWb_next;
    Rsrc1_reg_ex = Rsrc1_reg_ex_next;
    Rsrc2_reg_ex = Rsrc2_reg_ex_next;
    Rdst_reg_ex = Rdst_reg_ex_next;
    stages = next_stages;
    imm_reg_ex  = imm_reg_ex_next;

    took_branch_ex = took_branch;
    took_branch_addr_ex = took_branch_addr;
    branch_predictor = branch_predictor_next;
    loops = loops_next;

    //reset miss-predict so it can be used again
    miss_predicted = miss_predict;
    miss_predict = 1'b0;

    loadHalted = loadHalt;
    loadHalt = 1'b0;

    PCRegDec = PCRegDec_next;
    PCRegEx = PCRegEx_next;
    PCRegMem = PCRegMem_next;
    PCRegWb = PCRegWb_next;

    DataAddrMem= DataAddrMem_next;
    MemWrEnRegMem = MemWrEnRegMem_next;
    RWrEnRegMem = RWrEnRegMem_next;
    RdstRegMem = RdstRegMem_next;
    RWrdataRegMem = RWrdataRegMem_next;
    MemSizeRegMem = MemSizeRegMem_next;
    StoreDataRegMem = StoreDataRegMem_next;

    RdstRegWb = RdstRegWb_next;
    RWrdataRegWb = RWrdataRegWb_next;
    RWrEnRegWb = RWrEnRegWb_next;

    ex_ford_lab = ex_ford_lab_next;
    mem_ford_lab = mem_ford_lab_next;
    ex_ford = ex_ford_next;
    mem_ford= mem_ford_next;

    btb = btb_next;

  end

  always @*
  begin
    //Setup PC reg for the next Instruction
    PCReg = PC_Plus_4;
    haltFlagReg = 1'b0;
    loops_next = loops + 1;

    if (branch_predictor_next === 2'bxx)
    begin
      branch_predictor_next = 2'b00;
    end

    //If all stages are done, we are done so halt
    if (stages == 5'b0)
    begin
      $display("halt1");
      haltFlagReg = 1'b1;
    end

    // INSTRUCTION FETCH

    //If this stage is 0, set the next stage to 0 (propage the 0 through)
    if ((stages[0] == 1'b0))   // TODO: need to make this happen somewhere
    begin
      next_stages[1] = 1'b0;
      PCReg = PCReg-4;
      //if we missed a predict, so the cleanup killed both the fetch and decode stages, we need to restart it
      //now with the correct address for the next cylce (which is handled by the branch setting NPC to the new address)
      if ((miss_predict == 1'b1) | (miss_predicted == 1'b1) | (loadHalted == 1'b1))
      begin
        next_stages[0] = 1'b1;
        $display("load halted bro");
      end
    end
    //Otherwse, normal execution
    else if (stages[0] == 1'b1)
    begin
      fetch_reg_dec_next = InstWord; //Give the next decoder the instruction
      //this stage keeps going and the next one should go too
      PCRegDec_next = PC; //propage the PC address we are at

      //we reached 0 instrucion, stop and let everything else go through!
      if ((InstWord == 32'b0))
      begin
        // $display("I a am at the end of the file :()");
        next_stages[1] = 1'b0;
        PCReg = PCReg-4;
        next_stages[0] = 1'b0;
      end
      else
      begin
        next_stages[0] = 1'b1;
        next_stages[1] = 1'b1;
      end
    end

    // INSTRUCTION DECODE
    if (stages[1] == 1'b1)
    begin
      //Decode and propagate to the next stage
      PCRegEx_next = PCRegDec;
      next_stages[2] = 1'b1;
      opcode_reg_ex_next =  fetch_reg_dec[6:0];
      funct3_reg_ex_next = fetch_reg_dec[14:12];
      Rsrc1_reg_ex_next = fetch_reg_dec[19:15];
      Rsrc2_reg_ex_next = fetch_reg_dec[24:20];
      Rdst_reg_ex_next = fetch_reg_dec[11:7];
      imm_reg_ex_next = {20'b0, fetch_reg_dec[31:20]};
      //pass the instruction along too (we are lazy)
      fetch_reg_ex_next = fetch_reg_dec;

      if (opcode_reg_ex_next == 7'b1100011)
      begin
        if (branch_predictor[1] == 1'b1)
        begin
          // next_stages[1] = 1'b0; /// TODO: check if this cancels the previous instruction
          next_stages[1] = 1'b0; 
          next_stages[0] = 1'b1; 
          PCReg = btb;
          took_branch_addr = btb;
          took_branch = 1;
        end
        else
        begin
          took_branch = 0;
        end
      end

      //Branch Predict here! for now, both jumps and branches will predict not-taken
    end
    else if (stages[1] == 1'b0)
    begin
      next_stages[2] = 1'b0;
    end

    // EXECUTE STAGE
    if (stages[2] == 1'b0)
    begin
      next_stages[3] = 1'b0;
      ex_ford_lab_next[5] = 1'b0;
    end
    else if (stages[2] == 1'b1)
    begin
      PCRegMem_next = PCRegEx;
      next_stages[3] = 1'b1;
      fetch_reg_mem_next = fetch_reg_ex;

      //By default:
      MemWrEnRegMem_next = 1'b1; //no writing to mem
      RWrEnRegMem_next = 1'b1; //no writing to registers


      Rdata1_fin = Rdata1; //defaul take the vaule from the reg
      Rdata2_fin = Rdata2;
      //if its in mem, takeit
      if ((ex_ford_lab[5] == 1'b1) && (fetch_reg_ex[19:15] == ex_ford_lab[4:0]))
      begin
        Rdata1_fin = ex_ford;
      end
      //if it is in ex take it
      else if ((mem_ford_lab[5] == 1'b1) && (fetch_reg_ex[19:15] == mem_ford_lab[4:0]))
      begin
        Rdata1_fin = mem_ford;
      end

      //if its in mem, takeit
      if ((ex_ford_lab[5] == 1'b1) && (fetch_reg_ex[24:20] == ex_ford_lab[4:0]))
      begin
        Rdata2_fin = ex_ford;
      end
      //if it is in ex tqake it
      else if ((mem_ford_lab[5] == 1'b1) && (fetch_reg_ex[24:20] == mem_ford_lab[4:0]))
      begin
        Rdata2_fin = mem_ford;
      end

      //IF no memory write, need to have MemWrEnRegMem_next = 1'b1;
      //if no reg write back, need to have RWrEnRegMem_next = 1'b1;

      // for calculation here; use the ex extention stuff
      if (fetch_reg_ex[6:0] == `OPCODE_COMPUTE)
      begin
        //opA and B reg are assigned to the wire that goes into the eu
        opB_immReg   = Rdata2_fin;
        opA_immReg   = Rdata1_fin;
        //Same with funct7reg
        funct3Reg = funct3_reg_ex;
        funct7Reg = imm_reg_ex[11:5];
        //Just needs to do register write back, no need to do memory anything:
        RdstRegMem_next = Rdst_reg_ex;
        RWrdataRegMem_next = RWrdataWire; //output of the eu to write back
        RWrEnRegMem_next = 1'b0;

      end
      else if (fetch_reg_ex[6:0] == `OPCODE_IMM)
      begin

        funct3Reg = funct3_reg_ex;
        //$display("Funct3Reg: %3b", funct3Reg);
        if ((funct3_reg_ex == 3'b001 || funct3_reg_ex == 3'b101))
        begin
          funct7Reg   = imm_reg_ex[11:5];
          opB_immReg   = {{27{imm_reg_ex[4]}}, imm_reg_ex[4:0]};
          //$display("OPB: %5b", funct7Reg);
        end
        else
        begin
          funct7Reg   = `AUX_FUNC_ADD;
          opB_immReg   = {{20{imm_reg_ex[11]}}, imm_reg_ex[11:0]};
        end
        opA_immReg = Rdata1_fin;
        //$display("OPA: %5b", opA_immReg);

        //Just needs to do register write back, no need to do memory anything:
        RdstRegMem_next = Rdst_reg_ex;
        RWrdataRegMem_next = RWrdataWire; //output of the eu to write back
        RWrEnRegMem_next = 1'b0;
      end

      else if (fetch_reg_ex[6:0] == `OPCODE_LOAD)
      begin
        signed_tempReg = {{20{fetch_reg_ex[31]}}, fetch_reg_ex[31:20]};
        temp_addrReg = signed_tempReg + Rdata1_fin;
        loadHalt = 1;
        next_stages[0] = 0;
        next_stages[1] = 0;
        next_stages[2] = 0; // new addition
        PCReg = PCRegEx + 4;
        if (fetch_reg_ex[14:12] == 3'b000)
        begin // LB
          DataAddrMem_next   = temp_addrReg; //address
          MemSizeRegMem_next   = `SIZE_BYTE; //size
          RdstRegMem_next = Rdst_reg_ex; //Reg address
          //RWrdataRegMem_next   = {{24{DataWord[7]}}, DataWord[7:0]}; //data (fetched)
          RWrEnRegMem_next = 1'b0; //do write to register
          //dont write to memory (default)
        end
        else if (fetch_reg_ex[14:12] == 3'b001)
        begin // LH
          $display("halt2");
          haltFlagReg   = temp_addrReg[0]; //if address wrong halt
          DataAddrMem_next   = temp_addrReg; //address
          MemSizeRegMem_next   = `SIZE_HWORD; //size
          RdstRegMem_next = Rdst_reg_ex; //Reg address
          //RWrdataRegMem_next   = {{16{DataWord[15]}}, DataWord[15:0]}; //data (fetched)
          RWrEnRegMem_next = 1'b0; //do write to register
          //dont write to memory (default)
        end
        else if (fetch_reg_ex[14:12] == 3'b010)
        begin // LW
          $display("halt3");
          haltFlagReg   = temp_addrReg[0] | temp_addrReg[1];
          DataAddrMem_next   = temp_addrReg; //address
          MemSizeRegMem_next   = `SIZE_WORD; //size
          RdstRegMem_next = Rdst_reg_ex; //Reg address
          //RWrdataRegMem_next   = DataWord; //data (fetched)
          RWrEnRegMem_next = 1'b0; //do write to register
          //dont write to memory (default)
        end
        else if (fetch_reg_ex[14:12] == 3'b100)
        begin // LBU
          DataAddrMem_next   = temp_addrReg; //address
          MemSizeRegMem_next   = `SIZE_BYTE; //size
          RdstRegMem_next = Rdst_reg_ex; //Reg address
          //RWrdataRegMem_next   = {{24{1'b0}}, DataWord[7:0]}; //data (fetched)
          RWrEnRegMem_next = 1'b0; //do write to register
          //dont write to memory (default)
        end
        else if (fetch_reg_ex[14:12] == 3'b101)
        begin // LHU
          $display("halt4");
          haltFlagReg   = temp_addrReg[0]; //if address wrong halt
          DataAddrMem_next   = temp_addrReg; //address
          MemSizeRegMem_next   = `SIZE_HWORD; //size
          RdstRegMem_next = Rdst_reg_ex; //Reg address
          //RWrdataRegMem_next   = {{16{1'b0}}, DataWord[15:0]}; //data (fetched)
          RWrEnRegMem_next = 1'b0; //do write to register
          //dont write to memory (default)
        end
      end

      else if (fetch_reg_ex[6:0] == `OPCODE_STORE)
      begin
        signed_tempReg = {{20{fetch_reg_ex[31]}}, fetch_reg_ex[31:25], fetch_reg_ex[11:7]};
        temp_addrReg = signed_tempReg + Rdata1_fin;

        if (fetch_reg_ex[14:12] == 3'b000)
        begin // SB
          DataAddrMem_next = temp_addrReg; //set address for next stage
          MemSizeRegMem_next = `SIZE_BYTE; //set size
          StoreDataRegMem_next = Rdata2_fin; //set data to write to address
          MemWrEnRegMem_next = 1'b0; //let it write
          //don't write to register (defualt) don't need to set rdst.
        end
        else if (fetch_reg_ex[14:12] == 3'b001)
        begin // SH
          DataAddrMem_next = temp_addrReg; //set address for next stage
          MemSizeRegMem_next = `SIZE_HWORD; //set size
          StoreDataRegMem_next = Rdata2_fin; //set data to write to address
          MemWrEnRegMem_next = 1'b0; //let it write
          //don't write to register (defualt) don't need to set rdst.
        end
        else if (fetch_reg_ex[14:12] == 3'b010)
        begin // SW
          DataAddrMem_next = temp_addrReg; //set address for next stage
          MemSizeRegMem_next = `SIZE_WORD; //set size
          StoreDataRegMem_next = Rdata2_fin; //set data to write to address
          MemWrEnRegMem_next = 1'b0; //let it write
          //don't write to register (defualt) don't need to set rdst.
        end
      end

      else if (fetch_reg_ex[6:0] == `OPCODE_LUI)
      begin
        RdstRegMem_next = Rdst_reg_ex;
        RWrdataRegMem_next = {fetch_reg_ex[31:12], 12'b0}
                           ; //output of the eu to write back
        RWrEnRegMem_next = 1'b0; //do write to the register, dont write to mem (default)
      end
      else if (fetch_reg_ex[6:0] == `OPCODE_AUIPC)
      begin
        RdstRegMem_next = Rdst_reg_ex;
        RWrdataRegMem_next = PCRegEx + {fetch_reg_ex[31:12], 12'b0}
                           ;
        ; //output of the eu to write back
        RWrEnRegMem_next = 1'b0;
      end

      else if (fetch_reg_ex[6:0] == `OPCODE_JAL)
      begin
        signed_tempReg   = {{12{fetch_reg_ex[31]}}, fetch_reg_ex[19:12], fetch_reg_ex[20], fetch_reg_ex[30:21], 1'b0};
        temp_addrReg   = signed_tempReg + PCRegEx;
        $display("halt5");
        haltFlagReg   = temp_addrReg[0] | temp_addrReg[1];
        // additional code:
        RdstRegMem_next = Rdst_reg_ex;
        RWrdataRegMem_next = PCRegEx + 4;
        RWrEnRegMem_next = 1'b0;

        if ((PCRegEx) != temp_addrReg)
        begin
          //NPC is going to be PCReg, so we are over writting it with this rather than PCplus4
          PCReg  = temp_addrReg;
          // $display("jump success %8x", temp_addrReg);
          // $display("offset from pc %8x", signed_tempReg);
          //We need to do some clean up now as we predicted wrong
          miss_predict = 1;
          next_stages[0] = 0;
          next_stages[1] = 0;
          next_stages[2] = 0;
          //stages 2 - 4 can continue, 2 is this one which is fine as it doesn't do anything in later stages
          //3 and 4 are previous code that is still correct and should continue
        end
      end
      else if (fetch_reg_ex[6:0] == `OPCODE_JALR)
      begin
        signed_tempReg = Rdata1_fin;
        temp_addrReg   = 32'hfffffffe & (signed_tempReg + {{20{fetch_reg_ex[31]}}, fetch_reg_ex[31:20]});
        $display("halt6");
        haltFlagReg   = temp_addrReg[0] | temp_addrReg[1];
        // $display("stored address is %8x, PC is %8x", signed_tempReg, PCReg);
        // $display("address to be jumped to is %8x", temp_addrReg);

        // additional code:
        RdstRegMem_next = Rdst_reg_ex;
        RWrdataRegMem_next = PCRegEx + 4;
        RWrEnRegMem_next = 1'b0;

        if ((PCRegEx) != temp_addrReg)
        begin
          //NPC is going to be PCReg, so we are over writting it with this rather than PCplus4
          PCReg   = temp_addrReg;
          //We need to do some clean up now as we predicted wrong
          miss_predict = 1;
          next_stages[0] = 0;
          next_stages[1] = 0;
          next_stages[2] = 0;
          //stages 2 - 4 can continue, 2 is this one which is fine as it doesn't do anything in later stages
          //3 and 4 are previous code that is still correct and should continue
        end

      end

      else if (fetch_reg_ex[6:0] == `OPCODE_BRANCH)
      begin
        signed_tempReg = {{20{fetch_reg_ex[31]}}, fetch_reg_ex[7], fetch_reg_ex[30:25], fetch_reg_ex[11:8], 1'b0};
        temp_addrReg  = PCRegEx + signed_tempReg;
        //Really if any of these enter, we mis-predicted. We are always going to predict not taken, so instead of just writing the address
        //We are going to need to flush the pipline and fetch the next register...
        //That also means there is really no point in delaying anything, we are not doing anything else with branch so to need to wait for right back
        //to fix things
        // $display("in the branch, want to go to: %8x", temp_addrReg);
        //if we dont, we have already finished the branch, nothing happens in the next stages.
        if (funct3_reg_ex == 3'b000)
        begin // BEQ
          if (Rdata1_fin == Rdata2_fin) // SHOULD HAVE TAKEN
          begin
            if (((took_branch_ex == 1) && (took_branch_addr_ex != temp_addrReg)) | (took_branch_ex == 0))
            begin
              miss_predict = 1;
              next_stages[0] = 0;
              next_stages[1] = 0;
              next_stages[2] = 0;
              PCReg = temp_addrReg; // TODO: check if this is the right variable for next address
              btb_next = temp_addrReg;
            end

            if (branch_predictor != 2'b11)
            begin
              branch_predictor_next = branch_predictor + 1;
            end
            else 
            begin
              branch_predictor_next = branch_predictor;
            end
          end
          else // SHOULD HAVE NOT TAKEN
          begin
            if (took_branch_ex == 1)
            begin
              miss_predict = 1;
              next_stages[0] = 0;
              next_stages[1] = 0;
              next_stages[2] = 0;
              PCReg = PCRegEx + 4; // TODO: check if this is the right variable for next address
            end
            if (branch_predictor != 2'b00)
              begin
                branch_predictor_next = branch_predictor - 1;
              end
              else begin 
                branch_predictor_next = branch_predictor;
              end
          end
        end
        else if (funct3_reg_ex == 3'b001)
        begin // BNE
          if (Rdata1_fin != Rdata2_fin)
          begin
            if (((took_branch_ex == 1) && (took_branch_addr_ex != temp_addrReg)) | (took_branch_ex == 0))
            begin
              miss_predict = 1;
              next_stages[0] = 0;
              next_stages[1] = 0;
              next_stages[2] = 0;
              PCReg = temp_addrReg; // TODO: check if this is the right variable for next address
              btb_next = temp_addrReg;
            end
            if (branch_predictor != 2'b11)
            begin
              branch_predictor_next = branch_predictor + 1;
            end
            else 
            begin 
              branch_predictor_next = branch_predictor;
            end
          end
          else // SHOULD HAVE NOT TAKEN
          begin
            if (took_branch_ex == 1)
            begin
              miss_predict = 1;
              next_stages[0] = 0;
              next_stages[1] = 0;
              next_stages[2] = 0;
              PCReg = PCRegEx + 4; // TODO: check if this is the right variable for next address
            end
            if (branch_predictor != 2'b00)
              begin
                branch_predictor_next = branch_predictor - 1;
              end
              else begin 
                branch_predictor_next = branch_predictor;
              end
          end
        end
        else if (funct3_reg_ex == 3'b100)
        begin // BLT
          signed_tempReg   = Rdata1_fin;
          signed_temp_twoReg  = Rdata2_fin;
          $display("Comparison: A: %08x, B: %08x", Rdata1_fin, Rdata2_fin);
          $display("took branch? %08x", took_branch_ex);
          if (signed_tempReg < signed_temp_twoReg)
          begin

            if (((took_branch_ex == 1) & (took_branch_addr_ex != temp_addrReg)) | (took_branch_ex == 0))
            begin

              miss_predict = 1;
              next_stages[0] = 0;
              next_stages[1] = 0;
              next_stages[2] = 0;
              PCReg = temp_addrReg; // TODO: check if this is the right variable for next address
              btb_next = temp_addrReg;
            end
              if (branch_predictor != 2'b11)
              begin
                branch_predictor_next = branch_predictor + 1;
              end
              else
              begin 
                branch_predictor_next = branch_predictor;
              end
          end
          else // SHOULD HAVE NOT TAKEN
          begin
            if (took_branch_ex == 1)
            begin
              miss_predict = 1;
              next_stages[0] = 0;
              next_stages[1] = 0;
              next_stages[2] = 0;
              PCReg = PCRegEx + 4; // TODO: check if this is the right variable for next address
            end
            if (branch_predictor != 2'b00)
              begin
                branch_predictor_next = branch_predictor - 1;
              end
              else begin 
                branch_predictor_next = branch_predictor;
              end
          end
        end
        else if (funct3_reg_ex == 3'b101)
        begin // BGE
          signed_tempReg   = Rdata1_fin;
          signed_temp_twoReg   = Rdata2_fin;
          if (signed_tempReg >= signed_temp_twoReg)
          begin
          if (((took_branch_ex == 1) && (took_branch_addr_ex != temp_addrReg)) | (took_branch_ex == 0))
            begin
              miss_predict = 1;
              next_stages[0] = 0;
              next_stages[1] = 0;
              next_stages[2] = 0;
              PCReg = temp_addrReg; // TODO: check if this is the right variable for next address
              btb_next = temp_addrReg;
            end
            if (branch_predictor != 2'b11)
            begin
              branch_predictor_next = branch_predictor + 1;
            end
            else 
            begin 
              branch_predictor_next = branch_predictor;
            end
          end
          else // SHOULD HAVE NOT TAKEN
          begin
            if (took_branch_ex == 1)
            begin
              miss_predict = 1;
              next_stages[0] = 0;
              next_stages[1] = 0;
              next_stages[2] = 0;
              PCReg = PCRegEx + 4; // TODO: check if this is the right variable for next address
            end
            if (branch_predictor != 2'b00)
              begin
                branch_predictor_next = branch_predictor - 1;
              end
              else begin 
                branch_predictor_next = branch_predictor;
              end
          end
        end
        else if (funct3_reg_ex == 3'b110)
        begin // BLTU
          if (Rdata1_fin < Rdata2_fin)
          begin
            if (((took_branch_ex == 1) && (took_branch_addr_ex != temp_addrReg)) | (took_branch_ex == 0))
            begin
              miss_predict = 1;
              next_stages[0] = 0;
              next_stages[1] = 0;
              next_stages[2] = 0;
              PCReg = temp_addrReg; // TODO: check if this is the right variable for next address
              btb_next = temp_addrReg;
            end
            if (branch_predictor != 2'b11)
            begin
              branch_predictor_next = branch_predictor + 1;
            end
            else 
            begin 
              branch_predictor_next = branch_predictor;
            end
          end
          else // SHOULD HAVE NOT TAKEN
          begin
            if (took_branch_ex == 1)
            begin
              miss_predict = 1;
              next_stages[0] = 0;
              next_stages[1] = 0;
              next_stages[2] = 0;
              PCReg = PCRegEx + 4; // TODO: check if this is the right variable for next address
            end
            if (branch_predictor != 2'b00)
              begin
                branch_predictor_next = branch_predictor - 1;
              end
              else begin 
                branch_predictor_next = branch_predictor;
              end
          end
        end
        else if (funct3_reg_ex == 3'b111)
        begin // BGEU
          if (Rdata1_fin >= Rdata2_fin)
          begin
            if (((took_branch_ex == 1) & (took_branch_addr_ex != temp_addrReg)) | (took_branch_ex == 0))
            begin
              miss_predict = 1;
              next_stages[0] = 0;
              next_stages[1] = 0;
              next_stages[2] = 0;
              PCReg = temp_addrReg; // TODO: check if this is the right variable for next address
              btb_next = temp_addrReg;
            end
            if (branch_predictor != 2'b11)
            begin
              branch_predictor_next = branch_predictor + 1;
            end
            else 
            begin 
              branch_predictor_next = branch_predictor;
            end
          end
          else // SHOULD HAVE NOT TAKEN
          begin
            if (took_branch_ex == 1)
            begin
              miss_predict = 1;
              next_stages[0] = 0;
              next_stages[1] = 0;
              next_stages[2] = 0;
              PCReg = PCRegEx + 4; // TODO: check if this is the right variable for next address
            end
            if (branch_predictor != 2'b00)
              begin
                branch_predictor_next = branch_predictor - 1;
              end
              else begin 
                branch_predictor_next = branch_predictor;
              end
          end
        end
        else
        begin
          $display("halt7");
          haltFlagReg   = 1'b1;
        end
      end

      // try to forward from execute stage
      ex_ford_lab_next[5] = 1'b0;
      if (RWrEnRegMem_next == 1'b0)
      begin
        ex_ford_lab_next[5] = 1'b1;
        ex_ford_lab_next[4:0] = fetch_reg_mem_next[11:7];
        ex_ford_next = RWrdataRegMem_next;
        // $display("just chucked in execute %8x, into %8x", ex_ford, ex_ford_lab[4:0]);
      end

    end






    // MEMORY WRITE OR READ STAGE

    if (stages[3] == 1'b0)
    begin
      next_stages[4] = 1'b0;
      mem_ford_lab_next[5] = 1'b0;
    end
    else if (stages[3] == 1'b1)
    begin
      PCRegWb_next = PCRegMem;
      next_stages[4] = 1'b1;
      fetch_reg_wb_next = fetch_reg_mem;

      //Memory (now time)
      DataAddrReg = DataAddrMem; //set address
      MemSizeReg = MemSizeRegMem; //set size
      StoreDataReg = StoreDataRegMem; //if we are storing, store data
      MemWrEnReg = MemWrEnRegMem; //enable writing
      //$display("address: %08x, memsize: %02b, StoreData: %08x, MemWrEn: %1b, dataword: %08x", DataAddrReg, MemSizeReg,StoreDataReg, MemWrEnReg, DataWord);

      //Reg wb info to propagate:
      RdstRegWb_next = RdstRegMem; //reg to write to propagate
      RWrdataRegWb_next = RWrdataRegMem; //This changes on a load, its the data to write
      RWrEnRegWb_next = RWrEnRegMem; // enable write or not

      //On a load we need to acatually get the data and send it to reg write back
      //since we set the address and memsize, dataword is the real data we are looking for!
      if (fetch_reg_mem[6:0] == `OPCODE_LOAD)
      begin

        if (fetch_reg_mem[14:12] == 3'b000)
        begin // LB
          RWrdataRegWb_next   = {{24{DataWord[7]}}, DataWord[7:0]}; //data (fetched)
        end
        else if (fetch_reg_mem[14:12] == 3'b001)
        begin // LH
          RWrdataRegWb_next   = {{16{DataWord[15]}}, DataWord[15:0]}; //data (fetched)
        end
        else if (fetch_reg_mem[14:12] == 3'b010)
        begin // LW
          // $display("Loading word");
          RWrdataRegWb_next   = DataWord; //data (fetched)
          // $display("dataword: %08x", DataWord);
        end
        else if (fetch_reg_mem[14:12] == 3'b100)
        begin // LBU
          RWrdataRegWb_next   = {{24{1'b0}}, DataWord[7:0]}; //data (fetched)
        end
        else if (fetch_reg_mem[14:12] == 3'b101)
        begin // LHU
          RWrdataRegWb_next   = {{16{1'b0}}, DataWord[15:0]}; //data (fetched)
        end


      end

      mem_ford_lab_next[5] = 1'b0;
      if (RWrEnRegWb_next == 1'b0)
      begin
        mem_ford_lab_next[5] = 1'b1;
        mem_ford_lab_next[4:0] = fetch_reg_wb_next[11:7];
        mem_ford_next = RWrdataRegWb_next;
        // $display("just chucked in mem %8x, into %8x", mem_ford, mem_ford_lab[4:0]);
      end
    end

    // Register Write back starts here

    if (stages[4] == 1'b1)
    begin
      //just do the write back now
      RdstReg = RdstRegWb;
      RWrdataReg = RWrdataRegWb;
      RWrEnReg = RWrEnRegWb;

    end

  end

endmodule


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
  BM booth1(signedopA, signedopB, mul_out, enable);

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