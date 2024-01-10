#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jan 10 09:32:44 2024

@author: brightonsibanda
"""


# Multiplying two matrices, python version


def multiply(mat1, mat2):
    
    ''' This function will multiply 2 matrices. and returns 0 if the matrices cannot be multiplied.
    
    inputs: mat1 -> an m by n matrix (list of lists).
            mat2 -> an n by p matrix (list of lists).
            
    output: result -> an m by p matrix (list of lists).
    
    '''


    # Check if inner dimensions are compatible
    if len(mat1[0]) != len(mat2):
      return 0
      
    # Create the result matrix
    result = [[0 for x in range(len(mat2[0]))] for x in range(len(mat1))]
      
    # Perform element-wise multiplication and summation
    for i in range(len(mat1)):
      for j in range(len(mat2[0])):
        for k in range(len(mat2)):
          result[i][j] += mat1[i][k] * mat2[k][j]

    return result

# Example usage
mat1 = [[1, 2, 3], [4, 5, 6]]
mat2 = [[7, 8], [9, 10], [11, 12]]

product = multiply(mat1, mat2)

if product != 0:
  print("Product of matrices:")
  for row in product:
    print(row)
else:
  print("Matrices cannot be multiplied")

    
