# ADDI test 1
# add -1 to 0
# expected value: 0xffffffff
addi x11, x0, -1

# ADDI test 2
# add 1 to -1
# expected value: 0x0
addi x12, x11, 1

# ADDI test 3
# underflow
# expected value: 0x7fffffff
lui x1, 0x80000
addi x13, x1, -1

# ADDI test 4
# overflow
# expected value: 0x80000000
addi x14, x13, 1

# ADDI test 5
# adding 0
# expected value: 0x0
addi x15, x0, 0

# ADD test 1
# add -1 to 0
# expected value: 0xffffffff
add x16, x0, x11

# ADD test 2
# add 1 to -1
# expected value: 0x0
addi x17, x0, 1
addi x2, x0, -1
add x17, x17, x2

# ADD test 3
# underflow
# expected value: 0x7fffffff
addi x18, x0, -1
add x18, x18, x1

# ADD test 4
# overflow
# expected value: 0x80000000
addi x19, x0, 1
add x19, x19, x18

# ADD test 5
# adding 0
# expected value: 0x0
add x20, x0, x0

# SUB test 1
# sub 1 from 0
# expected value: 0xffffffff
addi x3, x0, 1
sub x21, x0, x3

# SUB test 2
# sub -1 from 1
# expected value: 0x2
sub x22, x3, x2

# SUB test 3
# underflow
# expected value: 0x7fffffff
sub x23, x1, x3

# SUB test 4
# overflow
# expected value: 0x80000000
sub x24, x23, x2

# SUB test 5
# sub 0
# expected value: 0x0
sub x25, x0, x0
