# initialize some values we will use in test cases
# x1 is 1
addi x1, x0, 1
# x2 is -1
addi x2, x0, -1
# x3 is max negative value
lui x3, 0x80000
# x4 is max positive value
add x4, x3, x2
# x5 is 2
addi x5, x0, 2
# x6 is -2
addi x6, x0, -2

# MUL test 1
# multiplying by 0
# expected value: 0
mul x11, x1, x0

# MUL test 2
# multiplying by 1
# expected value: 1
mul x12, x1, x1

# MUL test 3
# multiplying by -1
# expected value: -1
mul x13, x1, x2

# MUL test 4
# multiplying -1 by -1
# expected value: 1
mul x14, x2, x2

# MUL test 5
# multiplying 2 by max negative value
# expected value: 0
mul x15, x5, x3

# MUL test 6
# multiplying 2 by max positive value
# expected value: -2
mul x16, x5, x4

# MUL test 7
# multiplying max negative by itself
# expected value: 0
mul x17, x3, x3

# MUL test 8
# multiplying max positive by itself
# expected value: 0 
mul x18, x4, x4