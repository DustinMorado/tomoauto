--[[
  Copyright (c) 2015 Dustin Reed Morado

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
--]]

--- Geometrical Transform library
-- This module provides a bare library for handling some conversion between
-- different geometrical transformation formats mainly right now between protomo
-- and Dynamo
-- @module transforms
-- @author Dustin Reed Morado
-- @license MIT
-- @release 0.2.30

local math, table = math, table
local type = type

_ENV = nil 

local transforms = {}

--- Initialize an empty matrix with the given dimensions.
-- @tparam number row_dimension Row dimension of matrix.
-- @tparam number col_dimension Column dimension of matrix.
-- @return Returns a table describing a matrix of the given dimensions.
function transforms.new_matrix (row_dimension, col_dimension)
  if type(row_dimension) ~= 'number' then
    return nil, '\n\nERROR: tomoauto.transforms.new_matrix:\n  ' ..
                'Row dimension must be given and be a number type.\n'
  elseif type(col_dimension) ~= 'number' then
    return nil, '\n\nERROR: tomoauto.transforms.new_matrix:\n  ' ..
                'Column dimension must be given and be a number type.\n'
  elseif row_dimension < 1 then
    return nil, '\n\nERROR: tomoauto.transforms.new_matrix:\n  ' ..
                'Row dimension must be greater than or equal to 1.\n'
  elseif col_dimension < 1 then
    return nil, '\n\nERROR: tomoauto.transforms.new_matrix:\n  ' ..
                'Column dimension must be greater than or equal to 1.\n'
  end

  local matrix = { n = row_dimension }
  for i = 1, matrix.n do
    matrix[i] = { n = col_dimension }
  end

  return matrix
end

--- Creates a valid matrix object from an appropriate table.
-- @tparam table matrix A table describing a matrix or vector
-- @return Returns a table describing the given matrix properly.
function transforms.initialize_matrix (matrix)
  if type(matrix) ~= 'table' or type(matrix) ~= 'number' then
    return nil, '\n\nERROR: tomoauto.transforms.initialize_matrix:\n  ' ..
                'Matrix must be given and be a table or number type.\n'
  elseif type(matrix) == 'number' then
    return table.pack(table.pack(matrix))
  elseif #matrix <= 0 then
    return nil, '\n\nERROR: tomoauto.transforms.initialize_matrix:\n  ' ..
                'Matrix table must not be empty.\n'
  else
  end
end

--- Checks whether the given table is a valid matrix or vector
-- @tparam table matrix A table describing a matrix or vector
-- @return Returns true if the table describes a matrix or vector or nil and an
-- error message otherwise.
function transforms.is_matrix (matrix)
  if type(matrix) ~= 'table' then
    return nil, '\n\nERROR: tomoauto.transforms.is_matrix:\n  ' ..
                'Matrix must be given and be a table type.\n'
  elseif type(matrix.n) ~= 'number' then
    return nil, '\n\nERROR: tomoauto.transforms.is_matrix:\n  ' ..
                'Matrix must have a number in "n" field (length attribute).\n'
  elseif matrix.n < 1 then
    return nil, '\n\nERROR: tomoauto.transforms.is_matrix:\n  ' ..
                'Matrix must have a row dimension greater than or equal to 1.\n'
  end

  for i = 1, matrix.n do
    if type(matrix[i]) ~= 'table' then
      return nil, '\n\nERROR: tomoauto.transforms.is_matrix:\n  ' ..
                  'Vector component of matrix must be a table type.\n'
    elseif type(matrix[i].n) ~= 'number' then
      return nil, '\n\nERROR: tomoauto.transforms.is_matrix:\n  ' ..
                  'Vector component of matrix must have a number in "n" ' ..
                  'field (length attribute).\n'
    elseif matrix[i].n < 1 then
      return nil, '\n\nERROR: tomoauto.transforms.is_matrix:\n  ' ..
                  'Vector component of matrix must have a column dimension ' ..
                  'greater than or equal to 1.\n'
    elseif matrix[i].n ~= matrix[1].n then
      return nil, '\n\nERROR: tomoauto.transforms.is_matrix:\n  ' ..
                  'Vector components of matrix must all have the same ' ..
                  'column dimension.\n'
    end

    for j = 1, matrix[i].n do
      local component = matrix[i][j]
      if component and type(component) ~= 'number' then
        return nil, '\n\nERROR: tomoauto.transforms.is_matrix:\n  ' ..
                    'Components of vector in matrix must be a number type ' ..
                    'if they are non-nil.\n'
      end
    end
  end
end

--- Get the dimensions of a matrix or vector.
-- @tparam table matrix A table describing a matrix or vector
-- @treturn number Returns the row dimension first.
-- @treturn number Returns the column dimension second.
function transforms.dimension (matrix)
  local is_matrix, err = transforms.is_matrix(matrix)
  if not is_matrix then
    return nil, '\n\nERROR: tomoauto.transforms.dimension:\n  ' ..
                err .. '\n'
  end

  return matrix.n, matrix[1].n
end

--- Calculate transpose of a vector or matrix.
-- @tparam table matrix A table describing a matrix or vector.
-- @return Returns the transpose of matrix.
function transforms.transpose (matrix)
  local is_matrix, err = transforms.is_matrix(matrix)
  if not is_matrix then
    return nil, '\n\nERROR: tomoauto.transforms.transpose:\n  ' ..
                err .. '\n'
  end

  local transpose = transforms.new_matrix(matrix[1].n, matrix.n)
  for i = 1, transpose.n do
    for j = 1, transpose[i].n do
      transpose[i][j] = matrix[j][i]
    end
  end

  return transpose
end

--- Normalizes a vector within a specified tolerance
-- @tparam table vector A n-dimensional array describing a row vector
-- @treturn table normalized vector
function transforms.normalize (vector)
  local is_matrix, err = transforms.is_matrix(vector)
  if not is_matrix then
    return nil, '\n\nERROR: tomoauto.transforms.normalize:\n  ' ..
                err .. '\n'
  elseif vector.n ~= 1 and vector[1].n ~= 1 then
    return nil, '\n\nERROR: tomoauto.transforms.normalize:\n  ' ..
                'Vector must be a row or column vector.\n'
  end

  local EPSILON = 1E-12
  local norm = 0
  if vector.n == 1 then -- Row Vector
    for j = 1, vector[1].n do
      norm = vector[1][j] and norm + vector[1][j] ^ 2 or norm
    end

    norm = math.sqrt(norm)
    local inverse_norm = norm > EPSILON and 1 / norm or 0
    local normalized_vector = transforms.new_matrix(1, vector[1].n)
    for j = 1, vector[1].n do
      normalized_vector[1][j] = vector[1][j] and vector[1][j] * inverse_norm
    end

    return normalized_vector
  else -- Column Vector
    for i = 1, vector.n do
      norm = vector[i][1] and norm + vector[i][1] ^ 2 or norm
    end

    norm = math.sqrt(norm)
    local inverse_norm = norm > EPSILON and 1 / norm or 0
    local normalized_vector = transforms.new_matrix(vector.n, 1)
    for i = 1, vector.n do
      normalized_vector[i][1] = vector[i][1] and vector[i][1] * inverse_norm
    end

    return normalized_vector
  end
end

--- Calculates the cross product of two vectors in R3.
-- @tparam table vector_1 A 3-dimensional array describing a row vector.
-- @tparam table vector_2 A 3-dimensional array describing a row vector.
-- @treturn table Returns the cross product of vector_1 and vector_2.
function transforms.cross_product (vector_1, vector_2)
  local is_matrix_1, err_1 = transforms.is_matrix(vector_1)
  local is_matrix_2, err_2 = transforms.is_matrix(vector_2)
  if not is_matrix_1 then
    return nil, '\n\nERROR: tomoauto.transforms.cross_product:\n  ' ..
                err_1 .. '\n'
  elseif not is_matrix_2 then
    return nil, '\n\nERROR: tomoauto.transforms.cross_product:\n  ' ..
                err_2 .. '\n'
  elseif vector_1.n ~= 1 and vector_1[1].n ~= 1 then
    return nil, '\n\nERROR: tomoauto.transforms.cross_product:\n  ' ..
                'Vector 1 must be a row or column vector.\n'
  elseif vector_1.n ~= 3 and vector_1[1].n ~= 3 then
    return nil, '\n\nERROR: tomoauto.transforms.cross_product:\n  ' ..
                'Vector 1 must be a row or column vector in R^3.\n'
  elseif vector_2.n ~= 1 and vector_2[1].n ~= 1 then
    return nil, '\n\nERROR: tomoauto.transforms.cross_product:\n  ' ..
                'Vector 2 must be a row or column vector.\n'
  elseif vector_2.n ~= 3 and vector_2[1].n ~= 3 then
    return nil, '\n\nERROR: tomoauto.transforms.cross_product:\n  ' ..
                'Vector 2 must be a row or column vector in R^3.\n'
  elseif vector_1.n ~= vector_2.n then
    return nil, '\n\nERROR: tomoauto.transforms.cross_product:\n  ' ..
                'Vector 1 and Vector 2 must both be row or column vectors.\n'
  end

  if vector_1.n == 1 then -- Row Vectors
    return { n = 1,
      { n = 3,
        vector_1[1][2] * vector_2[1][3] - vector_1[1][3] * vector_2[1][2],
        vector_1[1][3] * vector_2[1][1] - vector_1[1][1] * vector_2[1][3],
        vector_1[1][1] * vector_2[1][2] - vector_1[1][2] * vector_2[1][1]
      }
    }
  else -- Column Vectors
    return { n = 3,
      { n = 1,
        vector_1[2][1] * vector_2[3][1] - vector_1[3][1] * vector_2[2][1]
      },
      { n = 1,
        vector_1[3][1] * vector_2[1][1] - vector_1[1][1] * vector_2[3][1]
      },
      { n = 1,
        vector_1[1][1] * vector_2[2][1] - vector_1[2][1] * vector_2[1][1]
      }
    }
  end
end

--- Calculates the product of a scalar and a matrix
-- @tparam number scalar A scalar.
-- @tparam table matrix A table describing a matrix or vector.
-- @return Returns the scalar product.
function transforms.scalar_product (scalar, matrix)
  if type(scalar) ~= 'number' then
    return nil, '\n\nERROR: tomoauto.transforms.scalar_product:\n  ' ..
                'Scalar must be given and be a number type.\n'
  end

  local is_matrix, err = transforms.is_matrix(matrix)
  if not is_matrix then
    return nil, '\n\nERROR: tomoauto.transforms.scalar_product:\n  ' ..
                err .. '\n'
  end

  local scalar_product = transforms.new_matrix(matrix.n, matrix[1].n)
  for i = 1, matrix.n do
    for j = 1, matrix[i].n do
      scalar_product[i][j] = matrix[i][j] and scalar * matrix[i][j]
    end
  end

  return scalar_product
end

--- Calculates the product of two matrices.
-- @tparam table matrix_1 A table describing a matrix or vector.
-- @tparam table matrix_2 A table describing a matrix or vector.
-- @return Returns the product of the given matrices.
function transforms.matrix_product (matrix_1, matrix_2)
  local is_matrix_1, err_1 = transforms.is_matrix(matrix_1)
  local is_matrix_2, err_2 = transforms.is_matrix(matrix_2)
  if not is_matrix_1 then
    return nil, '\n\nERROR: tomoauto.transforms.matrix_product:\n  ' ..
                err_1 .. '\n'
  elseif not is_matrix_2 then
    return nil, '\n\nERROR: tomoauto.transforms.matrix_product:\n  ' ..
                err_2 .. '\n'
  elseif matrix_1[1].n ~= matrix_2.n then
    return nil, '\n\nERROR: tomoauto.transforms.matrix_product:\n  ' ..
                'Column dimension of matrix 1 must be equal to row ' ..
                'dimension of matrix 2.\n'
  end

  local matrix = transforms.new_matrix(matrix_1.n, matrix_2[1].n)
  for i = 1, matrix.n do
    for j = 1, matrix[1].n do
      local value
      for k = 1, matrix_1[1].n do
        if matrix_1[i][k] and matrix_2[k][j] then
          value = value or 0
          value = value + matrix_1[i][k] * matrix_2[k][j]
        end
      end

      matrix[i][j] = value
    end
  end

  return matrix
end

--- Calculates the dot product of two vectors.
-- @tparam table vector_1 A n-dimensional array describing a row vector.
-- @tparam table vector_2 A n-dimensional array describing a row vector.
-- @treturn number The dot product of vector_1 and vector_2.
function transforms.dot_product (vector_1, vector_2)
  local is_matrix_1, err_1 = transforms.is_matrix(vector_1)
  local is_matrix_2, err_2 = transforms.is_matrix(vector_2)
  if not is_matrix_1 then
    return nil, '\n\nERROR: tomoauto.transforms.dot_product:\n  ' ..
                err_1 .. '\n'
  elseif not is_matrix_2 then
    return nil, '\n\nERROR: tomoauto.transforms.dot_product:\n  ' ..
                err_2 .. '\n'
  elseif vector_1.n ~= 1 and vector_1[1].n ~= 1 then
    return nil, '\n\nERROR: tomoauto.transforms.dot_product:\n  ' ..
                'Vector 1 must be a row or column vector.\n'
  elseif vector_2.n ~= 1 and vector_2[1].n ~= 1 then
    return nil, '\n\nERROR: tomoauto.transforms.dot_product:\n  ' ..
                'Vector 2 must be a row or column vector.\n'
  elseif vector_1.n == vector_2.n and vector_1[1].n ~= vector_2[1].n then
    return nil, '\n\nERROR: tomoauto.transforms.dot_product:\n  ' ..
                'Vectors must both have same dimension.\n'
  elseif vector_1[1].n == vector_2[1].n and vector_1.n ~= vector_2.n then
    return nil, '\n\nERROR: tomoauto.transforms.dot_product:\n  ' ..
                'Vectors must both have same dimension.\n'
  elseif vector_1[1].n == vector_2.n and vector_1.n ~= vector_2[1].n then
    return nil, '\n\nERROR: tomoauto.transforms.dot_product:\n  ' ..
                'Vectors must both have same dimension.\n'
  elseif vector_1.n == vector_2[1].n and vector_1[1].n ~= vector_2.n then
    return nil, '\n\nERROR: tomoauto.transforms.dot_product:\n  ' ..
                'Vectors must both have same dimension.\n'
  end

  local row, col
  row = vector_1.n    == 1 and vector_1 or transforms.transpose(vector_1)
  col = vector_2[1].n == 1 and vector_2 or transforms.transpose(vector_2)
  return transforms.matrix_product(row, col)[1][1]
end

--- Calculate axis angle representation for two vectors in R3
-- This function determines the axis angle representation describing the
-- rotation from one vector to another.
--
--    vector_1 . vector_2    = || vector_1 || * || vector_2 || * cos(angle)
-- || vector_1 x vector_2 || = || vector_1 || * || vector_2 || * sin(angle)
--
-- @tparam table vector_1 A 3-dimensional array describing a row vector in R3.
-- @tparam table vector_2 A 3-dimensional array describing a row vector in R3.
-- @return axis A 3-dimensional sequence of the unit axis of rotation
-- @return angle The angle describing the rotation.
function transforms.axis_angle (vector_1, vector_2)
  local unit_vector_1, unit_vector_2, dot_product, cross_product
  local axis, angle, err
  unit_vector_1, err = transforms.normalize(vector_1)
  if not unit_vector_1 then
    return nil, '\n\nERROR: tomoauto.transforms.axis_angle:\n  ' ..
                err .. '\n'
  end

  unit_vector_2, err = transforms.normalize(vector_2)
  if not unit_vector_2 then
    return nil, '\n\nERROR: tomoauto.transforms.axis_angle:\n  ' ..
                err .. '\n'
  end

  dot_product, err = transforms.dot_product(unit_vector_1, unit_vector_2)
  if not dot_product then
    return nil, '\n\nERROR: tomoauto.transforms.axis_angle:\n  ' ..
                err .. '\n'
  end

  cross_product, err = transforms.cross_product(unit_vector_1, unit_vector_2)
  if not cross_product then
    return nil, '\n\nERROR: tomoauto.transforms.axis_angle:\n  ' ..
                err .. '\n'
  end

  angle = math.acos(dot_product)
  axis  = transforms.scalar_product( 1 / math.sin(angle), cross_product)
  return axis, angle
end

--- Convert axis angle to rotation matrix.
-- Use Rodrigue's Rotation Formula to convert axis-angle to rotation matrix
-- @tparam table axis A 3-dimensional array describing an axis of rotation.
-- @tparam number angle The angle of rotation in radians.
-- @treturn table Returns the rotation matrix describing the transformation
-- described by the given axis and angle.
function transforms.axis_angle_to_rotation_matrix (axis, angle)
  local sine, cosine, versine, x, y, z, is_matrix, err

  is_matrix, err = transforms.is_matrix(axis)
  if not is_matrix then
    return nil, '\n\nERROR: tomoauto.transforms.' ..
                'axis_angle_to_rotation_matrix:\n  ' ..
                err .. '\n'
  elseif type(angle) ~= 'number' then
    return nil, '\n\nERROR: tomoauto.transforms.' ..
                'axis_angle_to_rotation_matrix:\n  ' ..
                'Angle must be given and be a number type.\n'
  elseif axis.n ~= 1 and axis[1].n ~= 1 then
    return nil, '\n\nERROR: tomoauto.transforms.' ..
                'axis_angle_to_rotation_matrix:\n  ' ..
                'Axis must be a row or column vector.\n'
  elseif axis.n ~= 3 and axis[1].n ~= 3 then
    return nil, '\n\nERROR: tomoauto.transforms.' ..
                'axis_angle_to_rotation_matrix:\n  ' ..
                'Axis must be a row or column vector in R^3.\n'
  end

  sine    = math.sin(angle)
  cosine  = math.cos(angle)
  versine = 1 - cosine
  x       = axis[1][1] or 0
  y       = axis.n == 1 and (axis[1][2] or 0) or (axis[2][1] or 0)
  z       = axis.n == 1 and (axis[1][3] or 0) or (axis[3][1] or 0)
  return { n = 3,
    { n = 3,
      versine * x * x + cosine,
      versine * x * y - sine * z,
      versine * x * z + sine * y
    },
    { n = 3,
      versine * x * y + sine * z,
      versine * y * y + cosine,
      versine * y * z - sine * x
    },
    { n = 3,
      versine * x * z - sine * y,
      versine * y * z + sine * x,
      versine * z * z + cosine
    }
  }
end

--- Calculate Euler angles from a given rotation matrix.
-- @tparam table matrix A table describing a rotation matrix.
-- @tparam string etype An optional string describing Euler angle format such as
-- 'ZYZ' or the default 'ZXZ'.
-- @tparam boolean degrees A flag specifying whether to output angles in radians
-- or degrees.
-- @treturn number Returns the first Euler angle.
-- @treturn number Returns the second Euler angle.
-- @treturn number Returns the third Euler angle.
function transforms.rotation_matrix_to_euler_angles (matrix, etype, degrees)
  local is_matrix, err, euler_1, euler_2, euler_3, EPSILON
  is_matrix, err = transforms.is_matrix(matrix)
  if not is_matrix then
    return nil, '\n\nERROR: tomoauto.transforms.' ..
                'rotation_matrix_to_euler_angles:\n  ' ..
                err .. '\n'
  elseif matrix.n ~= 3 or matrix[1].n ~= 3 then
    return nil, '\n\nERROR: tomoauto.transforms.' ..
                'rotation_matrix_to_euler_angles:\n  ' ..
                'Matrix must be a 3x3 rotation matrix.\n'
  end

  for i = 1, matrix.n do
    for j = 1, matrix[i].n do
      matrix[i][j] = matrix[i][j] or 0
    end
  end

  EPSILON = 1E-4
  if math.abs(matrix[3][3] - 1) < EPSILON then
    euler_1 = 0
    euler_2 = 0
    euler_3 = math.atan(matrix[2][1], matrix[1][1])
    euler_3 = degrees and euler_3 * 180 / math.pi or euler_3
    return euler_1, euler_2, euler_3
  elseif math.abs(matrix[3][3] + 1) < EPSILON then
    euler_1 = 0
    euler_2 = degrees and 180 or math.pi
    euler_3 = math.atan(matrix[2][1], matrix[1][1])
    euler_3 = degrees and euler_3 * 180 / math.pi or euler_3
    return euler_1, euler_2, euler_3
  else
    euler_1 = math.atan(matrix[3][1], matrix[3][2])
    euler_2 = math.acos(matrix[3][3])
    euler_3 = math.atan(matrix[1][3], -1 * matrix[2][3])
    euler_1 = degrees and euler_1 * 180 / math.pi or euler_1
    euler_2 = degrees and euler_2 * 180 / math.pi or euler_2
    euler_3 = degrees and euler_3 * 180 / math.pi or euler_3
    return euler_1, euler_2, euler_3
  end
end
