--[[
Copyright (c) 2015 Dustin Reed Morado

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

--- Yet Another Lua Get Opts - Command line argument parser.
-- @module yalgo
-- @author Dustin Reed Morado
-- @license MIT
-- @release 0.2.0
local yalgo = {}
local io, string, table = io, string, table
local default_argument = rawget(_G, 'arg')

--- Creates a new parser object.
-- Returns a parser with the given description, and standard help options.
-- @usage parser = yalgo:new_parser('A sample program description.')
-- @param description A description for the CLI program you are parsing
-- @return A parser table
function yalgo:new_parser (description)
  local parser = {
    description = description or '',
    arguments = { },
    positional_index = 1
  }

  setmetatable(parser, self)
  self.__index = self

  -- We need to prevent this parser from calling new itself
  function parser:new_parser ()
    error('ERROR: yalgo:new_parser: Do not call new from a local parser.')
  end

  parser:add_argument({
    name = 'help',
    long_option = '--help',
    short_option = '-h',
    description = 'Display this help and exit.'
  })

  return parser
end

local function sort_arguments (argument_1, argument_2)
  -- Returns true if argument_1 comes before argument_2

  -- Positional arguments always come after optional arguments
  if argument_1.is_positional and not argument_2.is_positional then
    return false

  elseif not argument_1.is_positional and argument_2.is_positional then
    return true

  -- If argument_1 and argument_2 are both postional then sort by position
  elseif argument_1.is_positional and argument_2.is_positional then
    return argument_1.position < argument_2.position

  -- If argument_1 and argument_2 are both optional then sort by option flags
  -- If argument_1 and argument_2 both have long options sort alphabetically
  elseif argument_1.long_option and argument_2.long_option then
    return argument_1.long_option < argument_2.long_option

  -- If one argument has long option and the other argument doesn't then sort by
  -- the first non-dash character alphabetically with short options before long
  elseif argument_1.long_option then
    local argument_1_character = string.sub(argument_1.long_option, 3, 3)
    local argument_2_character = string.sub(argument_2.short_option, 2, 2)
    return argument_1_character < argument_2_character

  elseif argument_2.long_option then
    local argument_1_character = string.sub(argument_1.short_option, 2, 2)
    local argument_2_character = string.sub(argument_2.long_option, 3, 3)
    return argument_1_character <= argument_2_character

  -- If both arguments don't have long option sort short options alphabetically
  else
    return argument_1.short_option < argument_2.short_option
  end
end

--- Argument Template.
-- Sample argument table for passing into add_argument.
-- long_option and short_option flags cannot be used for positional arguments,
-- but at least one must be given for an option argument.
-- Option arguments cannot be required and not take arguments.
-- Positional arguments cannot take arguments themselves.
-- Required arguments cannot specify a default value.
yalgo.template_argument = {
  name = 'option', -- Argument name used as key in returned option table.
  long_option = '--option', -- Specifies long option style flag
  short_option = '-o', -- Specifies short option style flag
  is_positional = false, -- Indicaties whether argument is positional
  has_argument = true, -- Indicates whether option takes an argument
  is_required = false, -- Indicates whether argument is mandatory or not
  default_value = 10, -- Specifies a default value to be used for the argument
  description = 'lorem ipsum', -- Description to be used for display_help()
  meta_value = 'ARG', -- Argument placeholder string used in display_help()
}

--- Add an argument to parser.arguments table.
-- @usage parser:add_argument(template_argument)
-- @param argument A table as described in template_argument
function yalgo:add_argument (argument)
  -- Initial error handling for the most general errors
  -- Argument has to have a name
  if not argument.name or type(argument.name) ~= 'string' then
    error('ERROR: yalgo:add_argument: You must provide a string name.')

  -- parser cannot have two arguments with the same name
  elseif self.arguments[argument.name] then
    error('ERROR: yalgo:add_argument: Option already exists.')

  -- Optional argument long flag must be a string of the form '--option'
  elseif argument.long_option and (type(argument.long_option) ~= 'string' or
         string.match(argument.long_option, '^%-%-%w[%w_-]+$') ~=
         argument.long_option) then
    error('ERROR: yalgo:add_argument: long_option must be a valid string.')

  -- Optional argument short flag must be a string of the form '-x'
  elseif argument.short_option and (type(argument.short_option) ~= 'string' or
         string.match(argument.short_option, '^%-%w$') ~= argument.short_option)
         then
    error('ERROR: yalgo:add_argument: short_option must be a valid string.')

  -- Argument description must be a string
  elseif argument.description and type(argument.description) ~= 'string' then
    error('ERROR: yalgo:add_argument: description must be a string.')

  -- Argument meta value must be a string
  elseif argument.meta_value and type(argument.meta_value) ~= 'string' then
    error('ERROR: yalgo:add_argument: meta_value must be a string.')

  -- Positional arguments cannot take their own arguments
  elseif argument.is_positional and argument.has_argument then
    error('ERROR: yalgo:add_argument: Positionals can\'t take arguments.')

  -- Positional arguments cannot have long or short option flags
  elseif argument.is_positional and (argument.long_option or
         argument.short_option) then
    error('ERROR: yalgo:add_argument: Positionals can\'t have long or short ' ..
          'option values.')

  -- Postional arguments cannot be required and have a default value
  elseif argument.is_positional and argument.is_required and
         argument.default_value then
    error('ERROR: yalgo:add_argument: Positionals can\'t be required and ' ..
          'have a default value.')

  -- Positional arguments cannot be required if all previous positionals aren't
  elseif argument.is_positional and argument.is_required then
    for _, _argument in ipairs(self.arguments) do
      if _argument.is_positional and not _argument.is_required then
        error('ERROR: yalgo:add_argument: Positionals can\'t be required ' ..
              'if prior positionals are not.')
      end
    end

  elseif not argument.is_positional and not argument.long_option and
         not argument.short_option then
    error('ERROR: yalgo:add_argument: Optional arguments must specify ' ..
          'a long and or short option flag.')

  elseif not argument.is_positional and argument.is_required and
         not argument.has_argument then
    error('ERROR: yalgo:add_argument: Required option arguments must ' ..
          'take an argument themselves.')

  elseif not argument.is_positional then
    for _, _argument in ipairs(self.arguments) do
      if (argument.long_option and _argument.long_option ==
         argument.long_option) or (argument.short_option and
         _argument.short_option == argument.short_option) then
        error('ERROR: yalgo:add_argument: Duplicate options specified.')
      end
    end
  end

  table.insert(self.arguments, {
    position = argument.is_positional and #self.arguments or nil,
    name = argument.name,
    long_option = argument.long_option,
    short_option = argument.short_option,
    is_positional = argument.is_positional,
    has_argument = argument.has_argument,
    is_required = argument.is_required,
    default_value = argument.default_value,
    description = argument.description or '',
    meta_value = argument.meta_value or ''
  })

  self.positional_index = argument.is_positional and self.positional_index or
                          self.positional_index + 1

  self.arguments[argument.name] = self.arguments[#self.arguments]
  table.sort(self.arguments, sort_arguments)
end

--- Display program help.
-- Shows usage and details optional and positional arguments
-- @usage parser:display_help()
-- @param program_name Program name which by default is _G.arg[0]
function yalgo:display_help (program_name)
  program_name = program_name or default_argument[0]

  -- Create and setup tables for Usage and arguments descriptions
  local arguments_usage, arguments_description = {}, {}
  table.insert(arguments_usage, 'USAGE:')
  table.insert(arguments_usage, program_name)
  table.insert(arguments_description, 'OPTIONS:\n')

  -- We need to keep track when we switch from optional to positional
  local positional_switch = false
  for _, argument in ipairs(self.arguments) do
    local argument_usage, argument_description
    -- Handle positional arguments first
    if argument.is_positional and not positional_switch then
      positional_switch = true
      table.insert(arguments_description, 'ARGUMENTS:\n')
    end

    if argument.is_positional and argument.is_required then
      argument_usage = argument.meta_value
      argument_description = '\t' .. argument.meta_value .. '\n\t\t' ..
                             '[REQUIRED]: ' ..  argument.description .. '\n'

    elseif argument.is_positional then
      argument_usage = '[' .. argument.meta_value .. ']'
      argument_description = '\t' .. argument.meta_value .. '\n\t\t' ..
                             argument.description .. '\n'

    elseif argument.is_required and argument.long_option and
           argument.short_option then
      argument_usage = argument.long_option .. '|' .. argument.short_option ..
                       ' ' .. argument.meta_value
      argument_description = '\t' .. argument.long_option .. ', ' ..
                             argument.short_option .. ' ' ..
                             argument.meta_value .. '\n\t\t[REQUIRED]: ' ..
                             argument.description .. '\n'

    elseif argument.is_required and argument.long_option then
      argument_usage = argument.long_option .. ' ' .. argument.meta_value
      argument_description = '\t' .. argument.long_option .. ' ' ..
                             argument.meta_value .. '\n\t\t' ..
                             '[REQUIRED]: ' .. argument.description .. '\n'

    elseif argument.is_required and argument.short_option then
      argument_usage = argument.short_option .. ' ' .. argument.meta_value
      argument_description = '\t' .. argument.short_option .. ' ' ..
                             argument.meta_value .. '\n\t\t' ..
                             '[REQUIRED]: ' .. argument.description .. '\n'

    elseif argument.has_argument and argument.long_option and
           argument.short_option then
      argument_usage = '[' .. argument.long_option .. '|' ..
                       argument.short_option .. ' ' ..  argument.meta_value ..
                       ']'

      argument_description = '\t' .. argument.long_option .. ', ' ..
                             argument.short_option .. ' ' ..
                             argument.meta_value .. '\n\t\t' ..
                             argument.description .. '\n'

    elseif argument.has_argument and argument.long_option then
      argument_usage = '[' .. argument.long_option .. ' ' ..
                       argument.meta_value .. ']'

      argument_description = '\t' .. argument.long_option .. ' ' ..
                             argument.meta_value .. '\n\t\t' ..
                             argument.description .. '\n'

    elseif argument.has_argument and argument.short_option then
      argument_usage = '[' .. argument.short_option .. ' ' ..
                       argument.meta_value .. ']'

      argument_description = '\t' .. argument.short_option .. ' ' ..
                             argument.meta_value .. '\n\t\t' ..
                             argument.description .. '\n'

    elseif argument.long_option and argument.short_option then
      argument_usage = '[' .. argument.long_option .. '|' ..
                       argument.short_option .. ']'

      argument_description = '\t' .. argument.long_option .. ', ' ..
                             argument.short_option .. '\n\t\t' ..
                             argument.description .. '\n'

    elseif argument.long_option then
      argument_usage = '[' .. argument.long_option .. ']'
      argument_description = '\t' .. argument.long_option .. '\n\t\t' ..
                             argument.description .. '\n'

    elseif argument.short_option then
      argument_usage = '[' .. argument.short_option .. ']'
      argument_description = '\t' .. argument.short_option .. '\n\t\t' ..
                             argument.description .. '\n'
    end

    table.insert(arguments_usage, argument_usage)
    table.insert(arguments_description, argument_description)
  end

  io.write(self.description .. '\n')
  io.write(table.concat(arguments_usage, ' ') .. '\n')
  io.write(table.concat(arguments_description, '') .. '\n')
end

local function is_option (argument)
  if not argument or argument == '-' or argument == '--' then
    return false

  elseif string.match(argument, '^%-%-?') then
    return true

  else
    return false
  end
end

local function is_long_option (argument)
  return string.sub(argument, 1, 2) == '--' and true or false
end

local function find_option_name (arguments, argument)
  for _, _argument in ipairs(arguments) do
    if (is_long_option(argument) and
        string.match(argument, '^--[%w_-]+') == _argument.long_option) or
       (not is_long_option(argument) and
        string.sub(argument, 1, 2) == _argument.short_option) then
      return _argument.name
    end
  end
  error('ERROR: yalgo:get_arguments: invalid argument given.', 2)
end

local function find_option_argument_and_shift (option, arguments)
  local equal_index = string.find(arguments[1], '=')
  local has_equals = not not equal_index
  local long_option = is_long_option(arguments[1])
  local is_globbed = not long_option and string.len(arguments[1]) > 2 and
                     equal_index ~= 3

  if has_equals and not is_globbed and not option.has_argument then
    error('ERROR: yalgo:get_arguments: option does not take arguments.', 2)

  elseif option.has_argument and not (has_equals or arguments[2] or is_globbed)
         then
    error('ERROR: yalgo:get_arguments: option requires an argument.', 2)

  elseif has_equals and not is_globbed then
    return string.sub(table.remove(arguments, 1), equal_index + 1)

  elseif option.has_argument and not is_globbed then
    table.remove(arguments, 1)
    return table.remove(arguments, 1)

  elseif option.has_argument then
    return string.sub(table.remove(arguments, 1), 3)

  elseif is_globbed then
    arguments[1] = '-' .. string.sub(arguments[1], 3)
    return nil

  else
    table.remove(arguments, 1)
    return nil
  end
end

--- Get arguments.
-- Takes a table similar to and by default _G.arg, and returns a table of
-- options storing the found and default values.
-- @usage options = my_parser:get_arguments()
-- @param arguments Sequence of arguments by default _G.arg
-- @return A table indexed by parser.arguments[name]
function yalgo:get_arguments (arguments)
  arguments = arguments or default_argument
  local options = {}
  -- Setup the return table with default values from the parser
  for _, _argument in ipairs(self.arguments) do
    options[_argument.name] = _argument.default_value
  end

  if #arguments == 0 then
    for _, _argument in ipairs(self.arguments) do
      if _argument.is_required then
        error('ERROR: yalgo:get_arguments: Required argument was not given.')
      end
    end
    return options
  end

  -- Handle optional arguments
  while is_option(arguments[1]) do
    local option_name = find_option_name(self.arguments, arguments[1])
    if option_name == 'help' then
      self:display_help(arguments[0])
      os.exit(0)
    end

    local option_argument = find_option_argument_and_shift(
                              self.arguments[option_name], arguments)
    options[option_name] = option_argument or options[option_name] or true
  end

  -- Handle positional arguments
  for i = self.positional_index, #self.arguments  do
      options[self.arguments[i].name] = arguments[1] and
                                        table.remove(arguments, 1) or
                                        options[self.arguments[i].name]
  end

  -- Check for all required arguments
  for _, _argument in ipairs(self.arguments) do
    if _argument.is_required and not options[_argument.name] then
      error('ERROR: yalgo.:get_arguments: Required argument not given.', 2)
    end
  end

  return options
end

return yalgo
