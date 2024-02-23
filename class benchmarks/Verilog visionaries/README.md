This benchmarks folder contains 4 benchmarks.

2 basic benchmarks 
  1. "addsubedge" or edge cases for add, sub, and addi
  2. "muledge" or edge cases for mul

2 advanced benchmarks
  1. "gcd" which takes two inputs and returns their GCD
  2. "shiftmul" which takes two inputs and returns (the lower 32 bits of) their product

the basic benchmarks are meant to run as they are using the provided test hex without 
modification, and can be verified using the provided regs_out file
remember to rename the test-specific hex if your testbench requires them to be named "mem_in.hex"

the advanced benchmarks may run for different amounts depending on the inputs,
and the regs_out file is only intended to match the default inputs that we provided.
the programs provide an instruction count in x20 to use for timing purposes

all regs_in files are all 0's, as we modify the values at the start of each program
there should be no difference between mem_in and mem_out, as we do not have any
direct memory effects built into our tests

for a clearer look at how these programs work, we have provided commented .asm
files that show the RISC-V instructions before they are translated to hex

if you want to simulate these to verify behavior, or adjust them to your
specific needs, this site may be useful: https://creatorsim.github.io/creator/ 

i have also included scrub.py, which is a python script i used to turn the 
memory dump of the .text section from that website into hex to test 