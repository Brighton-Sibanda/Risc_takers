#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jan 11 01:48:58 2024

@author: brightonsibanda
"""
global var
var = 0

## I'm using var to track iteration counts


def num_digits_base_3(n):
  global var
  """
  Calculates the number of digits a number has when represented in base 3.

  Args:
    n: The number to convert.

  Returns:
    The number of digits in the base 3 representation of n.
  """

  if n == 0:
    return 1

  digits = 0
  while n > 0:
    var += 1
    digits += 1
    # n //= 3 # floor division is needed for 
    n = floor_division(n, 3)

  return digits


# Just in case: floor division algorithm:
def floor_division(dividend, divisor):
  global var
  """
  Performs floor division without using the // operator.

  Args:
    dividend: The number to be divided.
    divisor: The number to divide by.

  Returns:
    The integer quotient of the division.
  """

  # Handle zero divisor to avoid division by zero errors
  if divisor == 0:
    raise ZeroDivisionError("Cannot divide by zero")

  # Determine the sign of the result based on the signs of the inputs
  sign = -1 if (dividend < 0) ^ (divisor < 0) else 1

  # Take absolute values for calculations
  dividend = abs(dividend)
  divisor = abs(divisor)

  # Subtract the divisor repeatedly until the dividend is less than the divisor
  quotient = 0
  while dividend >= divisor:
    dividend -= divisor
    quotient += 1
    var += 1

  # Apply the sign to the result
  return sign * quotient



# Example usage
number = 100
num_digits = num_digits_base_3(number)
print(f"{number} has {num_digits} digits in base 3")
