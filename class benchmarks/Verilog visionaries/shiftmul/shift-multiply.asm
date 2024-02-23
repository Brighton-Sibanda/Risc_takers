# set up a0 and a1 with the two numbers to multiply
addi a0, a0, 2047
addi a1, a1, 2047

mul_start:
xor t0, t0, t0 # t0 will be the temp results
addi t1, zero, 32 # t1 will be a loop counter to go thru all 32 digits

mul_loop:
andi t2, a1, 1 # t2 now matches lsb of a1
beq t2, zero, mul_skip # if t2 is not zero, we want to add this

mul_add:
add t0, t0, a0 # if we didn’t skip, add digit to t0 now

mul_skip:
srai a1, a1, 1 # shift a1 logical right to get next digit
slli a0, a0, 1 # shift a0 left, for next comparison
addi t1, t1, -1 # decrement counter
bne t1, zero, mul_loop # if not zero, loop again

mul_end:
add a0, t0, zero # now t0 contains bottom 32 bits of a0 * a1, so put in a0