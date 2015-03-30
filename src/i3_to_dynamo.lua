local particle_index = 1
local sel_filename= arg[1]
local sel_file = io.open(sel_filename, 'r')
if not sel_file then
    error('Cannot open/read ' .. sel_filename)
end
for line in io.lines(sel_file) do
    local pos_filename = string.gsub(line, 'low1%.mrc', 'pos')
    local pos_file = io.open(pos_filename, 'r')
    if not pos_file then
        error('Cannot open/read ' .. pos_filename)
    end
    local pos = pos_file:read()
    pos_file:close()
    local fields = {}
    for field in string.gmatch(pos, '%S+') do
        table.insert(fields, field)
    end
    local i3_euler = { fields[8], fields[9], fields[10] }
    local dynamo_euler
    if i3_euler[2] == 0 or i3_euler[2] == 180 then
        dynamo_euler = { 0, i3_euler[2], i3_euler[1] }
    else
        local rot_mat = os.execute(
