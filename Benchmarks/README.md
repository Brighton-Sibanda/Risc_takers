# Risc Takers Benchmarks

## Advanced Benchmark 1: Digit Counter Base 3

- Program will take the largest positive immediate value (2047)
- Multiply this value by 100
- Compute the number of base 3 digits in nested loops which execute a total of 102357 times
- Now it goes into memory, computes and stores the first 10 powers of 3 (starting at MEMORY Location -x80)
- Note that powers of 3 each represent an increment to the base 3 digits of numbers.

## Advanced Benchmark 2: Prime or Not?

- This program will determine if the argument (the value of x1 in the reg_in file, which is customizable) is prime or not
- The output (the value of x2 in the reg_out file) is 1 if the argument is prime; 0 if not
- In its current state, the argument is 1933 and that is prime, so in the reg_out x2 should equal 1

## Basic Benchmark 1:

- This program will test the basic opcodes that your cpu should be able to perform. The following opcodes are tested:
  -  auipc, jal, jalr, beq, bne, blt, bge, bltu, bgeu, addi, slti, xori, ori, andi, slli, srli, srai, add, sub, sll, slt, sltu, xor, srl, sra, or, and
- The program can be ran alone and requires no input
- The output should remain consistent after each run

## Basic Benchmark 2:

- This program will test the mult opcode of your cpu by multiplying each element of an array by a constant factor and stores the result in another array
- The input requires you to store an array in memory with the address of that array stored in the register x10, and a multiplier of your choice in x12
- The program then loops through, multiplying each element in the array, and then storing the base address of the result array into x13
