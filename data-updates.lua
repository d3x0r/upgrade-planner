--[[
local function fix_tiles(object)
    for _, __ in pairs(object) do
	if( _ == "can_be_part_of_blueprint" ) then
		object[_] = true;
        elseif type(__) == "table" then
	        fix_tiles( __ );
	end
    end
end
fix_tiles( data.raw.tile );
]]


data.raw["tile"]["grass-1"].can_be_part_of_blueprint = true
data.raw["tile"]["grass-2"].can_be_part_of_blueprint = true
data.raw["tile"]["grass-3"].can_be_part_of_blueprint = true
data.raw["tile"]["grass-4"].can_be_part_of_blueprint = true

--data.raw["tile"]["red-desert"].can_be_part_of_blueprint = true
