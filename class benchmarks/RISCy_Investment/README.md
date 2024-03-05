Basic Benchmark 1: String Length
This benchmark calculates the cumulative length of a bunch of strings in memory. It fetches one byte at a time and checks if it is a null terminator. If it is, it resets the counter and stores the length memory. If not, it iterates the counter and loads the next byte from memory. The benchmark ends the calculation when it encounters two consecutive null terminators. While there is a provided data_mem-in, the list of strings can be easily changed if further testing is desired. 

Basic Benchmark 2: Matrix Multiply
This benchmark calculates the product of two 3x3 matrices. The matrices are stored in memory and loaded in for the calculation and the result is stored back in memory after the starting matrices. The matrices are supplied in data_mem-in and can be edited for different results. Additionally matrices are stored a, b, c, . . ., i with a being the top left and i being the bottom right. 

Advanced Benchmark 1: Division
This benchmark calculates a quotient of a given dividend and given divisor. The algorithm is very simple and assumes positive integers for all values. It will check if the divisor is zero and exit if this is the case (to avoid an infinite loop among other things). As you may have guessed by now, the dividend and divisor are supplied in data_mem-in and can easily be changed to conduct different tests. But the quotient and remainder can be found in registers x4 and x5 respectively in the supplied reg-out.

Advanced Benchmark 2: Matrix to a Power
This benchmark raises a 3x3 matrix to a power. The algorithm performs the computation for each power, storing each consecutive power in memory (starting with 1). A sample matrix is provided in data_mem-in but can be edited for further testing. The default power is set to 11 but can be changed in the 4th instruction (addi x12, x0, 10). Do note that depending on the starting matrix and the power, you may encounter overflow as the matrix values will get very large. 