#!/usr/bin/env lua
-- orientation2euler.lua
-- Reads a position file specifying a center and rough orientation of a particle
-- and generates a file with euler angles in the Dynamo format to be put in a
-- project table.

local io, math, table, string = io, math, table, string
local yalgo = require('yalgo')

--- Normalizes a vector within a specified tolerance
-- @param v A n-dimensional sequence describing a row vector
-- @return nv normalized v
local function normalize (v)
  local EPSILON = 1E-12

  local norm = 0
  for i = 1, #v do
    norm = norm + v[i]^2
  end

  norm = math.sqrt(norm)
  inorm = 1 / norm
  local nv = {}

  if norm <= EPSILON then
    for i = 1, #v do
      nv[i] = 0
    end
  else
    for i = 1, #v do
      nv[i] = v[i] * inorm
    end
  end

  return nv
end

--- Calculates the cross product of two vectors in R3
-- @param v1 A 3-dimensional sequence describing a vector in R3
-- @param v2 Same a v1
-- @return cp A 3-dimensional sequence describing the cross product of v1, v2
local function get_cross_product (v1, v2)
  return {
    v1[2] * v2[3] - v1[3] * v2[2],
    v1[3] * v2[1] - v1[1] * v2[3],
    v1[1] * v2[2] - v1[2] * v2[1]
  }
end

--- Calculates the dot product of two vectors
-- @param v1 A n-dimensional sequence describing a row vector in Rn
-- @param v2 Same as v2
-- @return dp The dot product of v1 and v2
local function get_dot_product (v1, v2)
  local dp = 0
  for i = 1, #v1 do
    dp = dp + v1[i] * v2[i]
  end

  return dp
end

--- Calculate axis angle representation for two vectors in R3
-- This function determines the axis angle representation describing the
-- rotation from one vector to another.
-- @param v1 A 3-dimensional sequence describing a row vector in R3
-- @param v2 Same as v2
-- @return axis A 3-dimensional sequence of the unit axis of rotation
-- @return angle The angle describing the rotation.
local function get_axis_angle (v1, v2)
  local unit_v1 = normalize(v1)
  local unit_v2 = normalize(v2)

  -- v1 . v2 = ||v1|| * ||v2|| * cos(theta)
  local angle = math.acos(get_dot_product(unit_v1, unit_v2))

  -- || v1 x v2 || = || v1|| * ||v2|| * sin(theta)
  local cp = get_cross_product(unit_v1, unit_v2)
  local a_sin = math.sin(angle)
  local a_csc = 1 / a_sin
  local axis = {}
  for i = 1, 3 do
    axis[i] = cp[i] * a_csc
  end

  return axis, angle
end

--- Convert axis angle to rotation matrix
-- Use Rodrigue's Rotation Formula to convert axis-angle to rotation matrix
-- @param axis A 3-dimensional sequence of the unit axis of rotation
-- @param angle The angle describing the rotation
-- @return R The rotation matrix
local function axis_angle_to_rotation_matrix (axis, angle)
  local a_sin = math.sin(angle)
  local a_cos = math.cos(angle)
  local a_ver = 1 - a_cos
  local x, y, z = table.unpack(axis)

  R = {
    {
      a_ver * x * x + a_cos,
      a_ver * x * y - a_sin * z,
      a_ver * x * z + a_sin * y
    },
    {
      a_ver * x * y + a_sin * z,
      a_ver * y * y + a_cos,
      a_ver * y * z - a_sin * x
    },
    {
      a_ver * x * z - a_sin * y,
      a_ver * y * z + a_sin * x,
      a_ver * z * z + a_cos
    }
  }

  return R
end

local function rotation_matrix_to_euler_angles (rotation_matrix)
  local EPSILON = 1E-4
  local eulers = {}
  if math.abs(rotation_matrix[3][3] - 1) < EPSILON then
    eulers[1] = 0
    eulers[2] = 0
    eulers[3] = math.atan(rotation_matrix[2][1], rotation_matrix[1][1])
    eulers[3] = eulers[3] * 180 / math.pi
  elseif math.abs(rotation_matrix[3][3] + 1) < EPSILON then
    eulers[1] = 0
    eulers[2] = 180
    eulers[3] = math.atan(rotation_matrix[2][1], rotation_matrix[1][1])
    eulers[3] = eulers[3] * 180 / math.pi
  else
    eulers[1] = math.atan(rotation_matrix[3][1], rotation_matrix[3][2])
    eulers[2] = math.acos(rotation_matrix[3][3])
    eulers[3] = math.atan(rotation_matrix[1][3], -1 * rotation_matrix[2][3])
    eulers[1] = eulers[1] * 180 / math.pi
    eulers[2] = eulers[2] * 180 / math.pi
    eulers[3] = eulers[3] * 180 / math.pi
  end

  return eulers
end

parser = yalgo:new_parser('Transform pos file to Euler angles')
parser:add_argument({
  name  = 'dynamo',
  long_option = '--dynamo',
  description = 'Generate Euler angles used in Dynamo table'
})

parser:add_argument({
  name  = 'i3',
  long_option = '--i3',
  description = 'Generate Euler angles used in i3 table [default]'
})

parser:add_argument({
  name  = 'input',
  is_positional = true,
  is_required = true,
  description = 'Input pos filename',
  meta_value = 'INPUT_FILE'
})

parser:add_argument({
  name = 'output',
  is_positional = true,
  description = 'Output filename [default is stdout]',
  meta_value = 'OUTPUT_FILE'
})

options = parser:get_arguments()

if options.dyanmo and options.i3 then
  error('ERROR: orientation2euler: You cannot specify both --dynamo and --i3.')
end

-- First we need to open the pos file
input_file = assert(io.open(options.input, 'r'))
reverse_eulers = not options.dynamo or options.i3

pos_table = {}
for line in input_file:lines('l') do
  table.insert(pos_table, {})
  for field in string.gmatch(line, '%d+') do
    table.insert(pos_table[#pos_table], field)
  end
end
input_file:close()
pos_start_index = #pos_table[1] - 3 + 1

coord_table = {}
for i = 1, #pos_table, 2 do
  local coord = {}
  for j = pos_start_index, #pos_table[1] do
    table.insert(coord, pos_table[i + 1][j] - pos_table[i][j])
  end

  table.insert(coord_table, coord)
end

pos_table = nil
euler_table = {}
for i = 1, #coord_table do
  local axis, angle = get_axis_angle({0, 0, 1}, coord_table[i])
  local rotation_matrix = axis_angle_to_rotation_matrix(axis, angle)
  local eulers = rotation_matrix_to_euler_angles(rotation_matrix)
  if reverse_eulers then
    local new_eulers = {
      -1 * eulers[3],
      -1 * eulers[2],
      -1 * eulers[1]
    }
    eulers = new_eulers
    new_eulers = nil
  end

  table.insert(euler_table, eulers)
end

coord_table = nil
trf_file = io.stdout
if options.output then
  trf_file = assert(io.open(options.output, 'w'))
end

for _, v in ipairs(euler_table) do
  trf_file:write(string.format('%10.4f %10.4f %10.4f\n', table.unpack(v)))
end

if options.output then
  trf_file:close()
end
