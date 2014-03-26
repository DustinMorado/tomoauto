local getOpt = {}

function getOpt.parse(arg, shortString, longString)
   local optTable = {}
   local mapOpts = {}
   local longOptTable = {}
   local mapLongOpts = {}
   local newArg = {}
   local stringArg = ' '
   local shift = 0 
   for l in shortString:gmatch('(%a_?),?') do
      table.insert(mapOpts, l)
      optTable[l] = false 
   end
   for lOpt in longString:gmatch('(%w+),?') do
      table.insert(mapLongOpts, lOpt)
   end
   assert(#mapLongOpts == #mapOpts,
      'Error: the number of short options and long options do not match.')
   for i,opt in ipairs(mapLongOpts) do
      longOptTable[opt] = mapOpts[i]
   end
   mapOpts = nil; mapLongOpts = nil
   for _,v in ipairs(arg) do 
      stringArg = stringArg .. v .. ', '
   end
   for option in stringArg:gmatch('%s%-([%w._=%-]+),') do
      shift = shift + 1
      local i1 = option:sub(1,1)
      local i2 = option:sub(2,2)
      if i1 == '-' then -- long option
         if i2 == '-' then 
            for i = 1, (#arg - shift) do
               newArg[i] = arg[shift + i]
            end
            arg = newArg
            return arg, optTable
         elseif option:find('=') then -- has argument
            local i = option:find('=')
            local opt = option:sub(2, i-1)
            local arg = option:sub(i+1)
            local index = longOptTable[opt]
            optTable[index] = arg
         elseif longOptTable[option:sub(2)] then
            local opt = option:sub(2)
            local index = longOptTable[opt]
            optTable[longOptTable[opt]] = true
         else
            error('Invalid long option, please check usage.')
         end
      elseif #option == 1 then -- short option
         if optTable[option .. '_'] ~= nil then -- has argument
            shift = shift + 1
            optTable[option .. '_'] = arg[shift]
         elseif optTable[option] ~= nil then
            optTable[option] = true
         else
            error('Invalid short option, please check usage.')
         end
      else -- globbed short options
         for i = 1, #option do
            local letter = option:sub(i,i)
            if optTable[letter] ~= nil then
               optTable[letter] = true
            elseif optTable[letter .. '_'] ~= nil then
               if i == #option then
                  shift = shift + 1
                  optTable[letter .. '_'] = arg[shift]
               else
                  local j = i+1
                  local argWord = option:sub(j)
                  optTable[letter .. '_'] = argWord
               end
            end
         end
      end
   end
   for i = 1, (#arg - shift) do
      newArg[i] = arg[shift + i]
   end
   arg = newArg
   return arg, optTable
end
return getOpt
