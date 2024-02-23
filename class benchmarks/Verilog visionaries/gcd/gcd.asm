main:
	  addi x20, x20, 5
	  # put input values into t0, t1
    # default inputs are the 24th and 25th fibonacci numbers, 46368 and 75025, which have a GCD of 1
    # remember that the addi for counting instructions at the beginning of each section will be wrong
    # if you change the number of instructions to load values
    lui t0, 0xB
    addi t0, t0, 0x520
    lui t1, 0x12
    addi t1, t1, 0x511
    # alternatively, can load values from memory addresses contained in a0 and a1 
    # lw t0, 0(a0)
    # lw t1, 0(a1)

gcd_loop:
	addi x20, x20, 5
    beq t0, t1, end_gcd_loop     # If t0 == t1, GCD is found
    blt t0, t1, less_than        # If t0 < t1, go to less_than
    sub t0, t0, t1               # Else, t0 = t0 - t1
    beq x0, x0, gcd_loop         # Unconditional jump back to the start of the loop

less_than:
	addi x20, x20, 3
    sub t1, t1, t0               # t1 = t1 - t0
    beq x0, x0, gcd_loop         # Unconditional jump back to the start of the loop

end_gcd_loop:
    # t0 now holds GCD
	add x0, x0, x0