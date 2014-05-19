local string, table = string, table
local yago = {}
function yago.getOpt(Arg, shorts, longs)
   -- Short and long option tables
   local sOpts = {}
   local lOpts = {}

   -- Ordered short and long option tables
   local oSopts = {}
   local oLopts = {}

   -- Determines whether non-options are option arguments or function arguments.
   local skip = false

   for i in string.gmatch(shorts, '%w_?') do
      table.insert(oSopts, i)
      sOpts[i] = false
   end

   for i in string.gmatch(longs, '%w+') do
      table.insert(oLopts, i)
   end

   for i, v in ipairs(oLopts) do
      lOpts[oLopts[i]] = oSopts[i]
   end
   oSopts, oLopts = nil

   if #Sopts ~= #Lopts then
      error('\n\nError: The number of short opts and long opts do not match.\n')
   end

   for num, arg in ipairs(Arg) do

      -- Check for short options (simple or globbed)
      if string.match(arg, '^%-%w') then
         arg  = string.gsub(arg, '^%-', '')
         arg_ = arg .. '_'

         -- Simple short option
         if string.len(arg) == 1 then
            if sOpts[arg] or sOpts[arg] == false then
               sOpts[arg] = true

            -- Option requires argument
            elseif sOpts[arg_] or sOpts[arg_] == false then
               sOpts[arg_] = Arg[num + 1]
               skip = true

            else
               error(string.format(
                  '\n\nError: Invalid simple short option %s.\n', arg))
            end

         -- Globbed short options
         elseif string.len(arg) > 1 then
            local i = 0
            for j in string.gmatch(arg, '%w') do
               local j_ = j .. '_'
               i = i + 1
               
               -- Simple globbed short option
               if sOpts[j] or sOpts[j] == false then
                  sOpts[j] = true

               -- Option requires argument
               elseif sOpts[j_] or sOpts[j_] == false then

                  -- Option argument is not globbed with options
                  if i == #arg then
                     sOpts[j_] = Arg[num + 1]
                     skip = true

                  -- Option argument is globbed with options
                  else
                     sOpts[j_] = string.sub(arg, i + 1, -1)
                     break
                  end
               else
                  error(string.format(
                     '\n\nError: Invalid globbed short option %s.\n', j))
               end
            end
         end

      -- Check for long options
      elseif string.match(arg, '^%-%-%w') then
         arg = string.gsub(arg, '^%-%-', '')
         local hasArg = string.find(arg, '=')
         if hasArg then
            local lhs = string.sub(arg, 1, hasArg - 1)
            local rhs = string.sub(arg, hasArg + 1, -1)
            local l2s = lOpts[lhs]
            if sOpts[l2s] or sOpts[l2s] == false then
               sOpts[l2s] = rhs
            else
               error(string.format(
                  '\n\nError: Invalid long option %s.\n', lhs))
            end
         else
            if lOpts[arg] == nil then
               error(string.format(
                  '\n\nError: Invalid long option %s.\n', arg))
            end
            if string.len(lOpts[arg]) == 1 then
               local l2s = lOpts[arg]
               if sOpts[l2s] == false then
                  sOpts[l2s] = true
               elseif sOpts[l2s] then
                  sOpts[l2s] = true
               end
            else
               local l2s = lOpts[arg]
               if sOpts[l2s] == false then
                  sOpts[l2s] = Arg[num + 1]
                  skip = true
               elseif sOpts[l2s] then
                  sOpts[l2s] = Arg[num + 1]
                  skip = true
               end
            end
         end
      elseif string.match(arg, '^%-%-$') then
         for i = 1, num do
            table.remove(Arg, 1)
         end
         return Arg, sOpts
      else
         if skip then
            skip = false
         elseif not skip then
            for i = 1, num - 1 do
               table.remove(Arg, 1)
            end
            return Arg, sOpts
         end
      end
   end
end
return yago
