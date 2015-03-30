local euler = {}
local math = math

--                   z
--                   ^
--                   |
--                   |
--                   |  
--                   |        y
--                   |_________>
--                  /
--                 /
--              x /
--               L    
               
euler.get_cw_rotm_x = function(theta) -- degrees
    local t_rad = theta * math.pi / 180 -- radians
    local rotm_x = {
        {1, 0,                    0              },
        {0, math.cos(t_rad), -1 * math.sin(t_rad)},
        {0, math.sin(t_rad), math.cos(t_rad)     }
    }
    return rotm_x
end

euler.get_cw_rotm_y = function(theta)
    local t_rad = theta * math.pi / 180
    local rotm_y = {
        {math.cos(t_rad),      0, math.sin(t_rad)},
        {0,                    1, 0              },
        {-1 * math.sin(t_rad), 0, math.cos(t_rad)}
    }
    return rotm_y
end

euler.get_cw_rotm_z = function(theta)
    local t_rad = theta * math.pi / 180
    local rotm_z = {
        {math.cos(t_rad), -1 * math.sin(t_rad), 0},
        {math.sin(t_rad), math.cos(t_rad),      0},
        {0,               0,                    1}
    }
    return rotm_z
end

euler.get_ccw_rotm_x = function(theta) -- degrees
    local t_rad = theta * math.pi / 180 -- radians
    local rotm_x = {
        {1, 0,                    0              },
        {0, math.cos(t_rad),      math.sin(t_rad)},
        {0, -1 * math.sin(t_rad), math.cos(t_rad)}
    }
    return rotm_x
end

euler.get_ccw_rotm_y = function(theta)
    local t_rad = theta * math.pi / 180
    local rotm_y = {
        {math.cos(t_rad), 0, -1 * math.sin(t_rad)},
        {0,               1, 0                   },
        {math.sin(t_rad), 0, math.cos(t_rad)     }
    }
    return rotm_y
end

euler.get_ccw_rotm_z = function(theta)
    local t_rad = theta * math.pi / 180
    local rotm_z = {
        {math.cos(t_rad),      math.sin(t_rad), 0},
        {-1 * math.sin(t_rad), math.cos(t_rad), 0},
        {0,                    0,               1}
    }
    return rotm_z
end

euler.rotm_multiply = function(rotm1, rotm2)
    local result = {{}, {}, {}}
    for i = 1, 3 do
        for j = 1, 3 do
            result[i][j] = 0
            for k = 1, 3 do
                result[i][j] = (rotm1[i][k] * rotm2[k][j]) + result[i][j]
            end
        end
    end
    return result
end

euler.rotm_print = function(rotm)
    print('\n')
    for i = 1, 3 do
        print(string.format('\t%12.6f\t%12.6f\t%12.6f\n\n',
            table.unpack(rotm[i])))
    end
end
return euler
