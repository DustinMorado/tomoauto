local getOpt = {}

function getOpt.parse(arg, shortString, longString)
   local sOpts = {}
   local oSopts = {}
   local lOpts = {}
   local oLopts = {}
   local newArg = {}
   local stringArg = ' '
   local shift = 0 
   for l in shortString:gmatch('%a_?') do
      table.insert(oSopts, l)
      sOpts[l] = false 
   end
   for lOpt in longString:gmatch('%w+') do
      table.insert(oLopts, lOpt)
   end
   assert(#oLopts == #oSopts,
      'Error: the number of short options and long options do not match.')
   for i,opt in ipairs(oLopts) do
      lOpts[opt] = oSopts[i]
   end
   oSopts = nil; oLopts = nil
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
            return arg, sOpts
         elseif option:find('=') then -- has argument
            local i = option:find('=')
            local opt = option:sub(2, i-1)
            local arg = option:sub(i+1)
            local index = lOpts[opt]
            sOpts[index] = arg
         elseif lOpts[option:sub(2)] then
            local opt = option:sub(2)
            local index = lOpts[opt]
            sOpts[lOpts[opt]] = true
         else
            error('Invalid long option, please check usage.')
         end
      elseif #option == 1 then -- short option
         if sOpts[option .. '_'] ~= nil then -- has argument
            shift = shift + 1
            sOpts[option .. '_'] = arg[shift]
         elseif sOpts[option] ~= nil then
            sOpts[option] = true
         else
            print(option)
            error('Invalid short option, please check usage.')
         end
      else -- globbed short options
         for i = 1, #option do
            local letter = option:sub(i,i)
            if sOpts[letter] ~= nil then
               sOpts[letter] = true
            elseif sOpts[letter .. '_'] ~= nil then
               if i == #option then
                  shift = shift + 1
                  sOpts[letter .. '_'] = arg[shift]
               else
                  local j = i+1
                  local argWord = option:sub(j)
                  sOpts[letter .. '_'] = argWord
               end
            end
         end
      end
   end
   for i = 1, (#arg - shift) do
      newArg[i] = arg[shift + i]
   end
   arg = newArg
   return arg, sOpts
end
return getOpt
