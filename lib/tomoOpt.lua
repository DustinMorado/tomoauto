local string, io = string, io
local tomoOpt = {}

local function shiftArg(arg, shift)
   local length = #arg
   local toRemove = shift
   for i = length, 1, -1 do
      if i > shift then
         arg[i - shift] = arg[i]
         if toRemove > 0 then
            table.remove(arg)
            toRemove = toRemove - 1
         end
      elseif i > (length - shift) then
         table.remove(arg)
      end
   end
end

function tomoOpt.get(arg, shortString, longString)
   local optArray = {}
   local shortOpts = {}
   local longOpts = {}
   local index = 1
   local shift = 0

   for letter in shortString:gmatch('%a%:?') do
      table.insert(optArray, letter)
      shortOpts[letter] = false
   end
   
   for word in longString:gmatch('([%a%-]+)%,?') do
      longOpts[word] = optArray[index]
      index = index + 1
   end

   for i = 1, #arg do
      option = tostring(arg[i]):match('%-([%a%-])') -- finds option

      if option then
         if option == '-' then -- long option
            longOption = arg[i]:sub(3)
            if longOption == '' then -- found '--' end
               shift = i
               shiftArg(arg, shift)
               return arg, shortOpts
            else
               if longOpts[longOption]:len() == 2 then -- option requires arg
                  shortOpts[longOpts[longOption]] = arg[i+1]
                  shift = shift + 2 
               elseif longOpts[longOption]:len() == 1 then -- option is flag
                  shortOpts[longOpts[longOption]] = true
                  shift = shift + 1
               else error('Weird unexplained long option error!\n')
               end
            end
         elseif shortOpts[option .. ':'] ~= nil then -- option requires an argument
            shortOpts[option .. ':'] = arg[i+1]
            shift = shift + 2
         elseif shortOpts[option] ~= nil then -- option is flag
            shortOpts[option] = true
            shift = shift +1
         else error('Weird unexplained short option error!\n')
         end
      end
   end
   shiftArg(arg, shift)
   return arg, shortOpts
end
return tomoOpt
