local string, table = string, table
local yago = {}
function yago.get_options(Arg, short_options, long_options)
   -- Short and long option tables
   local short_options_table = {}
   local long_options_table  = {}

   -- Ordered short and long option tables
   local ordered_short_options = {}
   local ordered_long_options = {}

   -- Determines whether non-options are option arguments or function arguments.
   local skip = false

   -- Let's hold onto the hidden entry of arg
   local arg_zero         = nil
   local arg_negative_one = nil
   if Arg[0] then
      arg_zero = Arg[0]
   end
   if Arg[-1] then
      arg_negative_one = Arg[-1]
   end

   for i in string.gmatch(short_options, '%w_?') do
      table.insert(ordered_short_options, i)
      short_options_table[i] = false
   end

   for i in string.gmatch(long_options, '%w+') do
      table.insert(ordered_long_options, i)
   end

   for i, v in ipairs(ordered_long_options) do
      long_options_table[ordered_long_options[i]] = ordered_short_options[i]
   end
   ordered_short_options = nil
   ordered_long_options  = nil

   if #short_options_table ~= #long_options_table then
      error(
         '\n\nError: The number of short options and \z
         long options do not match.\n',
         0
      )
   end

   for index, argument in ipairs(Arg) do

      -- Check for short options (simple or globbed)
      if string.match(argument, '^%-%w') then
         argument  = string.gsub(argument, '^%-', '')
         argument_ = argument .. '_'

         -- Simple short option
         if string.len(argument) == 1 then
            if short_options_table[argument] or
               short_options_table[argument] == false
            then
               short_options_table[argument] = true

            -- Option requires argument
            elseif short_options_table[argument_] or
               short_options_table[argument_] == false
            then
               short_options_table[argument_] = Arg[index + 1]
               skip = true

            else
               error(
                  string.format(
                     '\n\nError: Invalid simple short option %s.\n',
                     argument
                  ), 0
               )
            end

         -- Globbed short options
         elseif string.len(argument) > 1 then
            local i = 0
            for option in string.gmatch(argument, '%w') do
               local option_ = option .. '_'
               i = i + 1

               -- Simple globbed short option
               if short_options_table[option] or
                  short_options_table[option] == false
               then
                  short_options_table[option] = true

               -- Option requires argument
               elseif short_options_table[option_] or
                  short_options_table[option_] == false
               then

                  -- Option argument is not globbed with options
                  if i == #argument then
                     short_options_table[option_] = Arg[index + 1]
                     skip = true

                  -- Option argument is globbed with options
                  else
                     short_options_table[option_] = string.sub(
                        argument,
                        i + 1,
                        -1
                     )
                     break
                  end
               else
                  error(
                     string.format(
                        '\n\nError: Invalid globbed short option %s.\n',
                        option
                     )
                  )
               end
            end
         end

      -- Check for long options
      elseif string.match(argument, '^%-%-%w') then
         argument = string.gsub(argument, '^%-%-', '')
         local has_argument = string.find(argument, '=')
         if has_argument then
            local left_hand_side  = string.sub(argument, 1, has_argument - 1)
            local right_hand_side = string.sub(argument, has_argument + 1, -1)
            local long_to_short = long_options_table[left_hand_side]
            if short_options_table[long_to_short] or
               short_options_table[long_to_short] == false
            then
               short_options_table[long_to_short] = right_hand_side
            else
               error(
                  string.format(
                     '\n\nError: Invalid long option %s.\n',
                     left_hand_side
                  ), 0
               )
            end
         else
            if long_options_table[argument] == nil then
               error(
                  string.format(
                     '\n\nError: Invalid long option %s.\n',
                     argument
                  ), 0
               )
            end
            if string.len(long_options_table[argument]) == 1 then
               local long_to_short = long_options_table[argument]
               if short_options_table[long_to_short] == false then
                  short_options_table[long_to_short] = true
               elseif short_options_table[long_to_short] then
                  short_options_table[long_to_short] = true
               end
            else
               local long_to_short = long_options_table[argument]
               if short_options_table[long_to_short] == false then
                  short_options_table[long_to_short] = Arg[index + 1]
                  skip = true
               elseif short_options_table[long_to_short] then
                  short_options_table[long_to_short] = Arg[index + 1]
                  skip = true
               end
            end
         end
      elseif string.match(argument, '^%-%-$') then
         for i = 1, index do
            table.remove(Arg, 1)
         end
         if arg_zero then
            Arg[0] = arg_zero
         end
         if arg_negative_one then
            Arg[-1] = arg_negative_one
         end
         return Arg, short_options_table
      else
         if skip then
            skip = false
         elseif not skip then
            for i = 1, index - 1 do
               table.remove(Arg, 1)
            end
            if arg_zero then
               Arg[0] = arg_zero
            end
            if arg_negative_one then
               Arg[-1] = arg_negative_one
            end
            return Arg, short_options_table
         end
      end

      -- If a function has no arguments only options
      if index == #Arg then
         Arg = {}
         if arg_zero then
            Arg[0] = arg_zero
         end
         if arg_negative_one then
            Arg[-1] = arg_negative_one
         end
         return Arg, short_options_table
      end
   end
end
return yago
