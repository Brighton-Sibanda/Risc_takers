// Testbench for Northwestern - CompEng 361 - Lab2
//`include "pipelined_gutted.v"
`timescale 1ns/1ps
`include "risc_takers_v3.v"
//`include "pipeline_synth.v"

module tb;
  reg clk, rst;
  wire halt;

  // Single Cycle CPU instantiation
  // PipelinedCPU CPU (halt, clk,rst);
  RunCPU CPU (halt, clk,rst);

  // Clock Period = 10 time units
  //  (stops when halt is asserted)
  always
    #5 clk = ~clk & !halt;

  initial
  begin
    // Clock and reset steup
    #0 rst = 1;
    clk = 0;
    #0 rst = 0;
    #0 rst = 1;

    // Load program
    #0 $readmemh("mem_in.hex", CPU.IMEM.Mem);
    #0 $readmemh("mem_in.hex", CPU.DMEM.Mem);
    #0 $readmemh("regs_in.hex", CPU.RF.Mem);



    //$dumpfile("wave.vcd");
    //$dumpvars(0, tb);

    // Feel free to modify to inspect whatever you want
    //$monitor("HIGH LEVEL:PC: %08x, High level Instruction: %08x, Stages: %8b, next_stages: %8b, miss_predict: %01b, miss_predicted: %01b,  halt: %01b", CPU.PC, CPU.InstWord, CPU.stages, CPU.next_stages, CPU.miss_predict, CPU.miss_predicted, CPU.halt);
    // Exits when halt is asserted
    wait(halt);

    // Dump registers
    #400000 $writememh("regs_out.hex", CPU.RF.Mem);

    // Dump memory
    #400000 $writememh("mem_out.hex", CPU.DMEM.Mem);

    #400000 $finish;
  end


endmodule // tb

