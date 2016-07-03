-- Minetest mod for creating spleef arenas by shivajiva101@hotmail.com

spleef = {}
spleef.arena = {}

-- Load files
dofile(minetest.get_modpath(minetest.get_current_modname()).."/pos.lua");

local schempath = minetest.get_modpath(minetest.get_current_modname())..'/schems'
local rpos ={}

minetest.register_chatcommand("spleef_add", {
	params = "<name>",
	description = "Adds a spleef arena to the list",
	privs = { server = true },
	func = function(name, param)
		if param == "" then
			return false, "Invalid usage, see /help protect."
		end
		-- return if name is used
		if spleef.arena[param] then
		    minetest.chat_send_player(name, param.." is already assigned in the spleef arena list")
		    return
		  end
		end
		-- check area is selected
		local pos1, pos2 = spleef:getPos(name)
		if not (pos1 and pos2) then
			return false, "You need to select an area first."
		end
		-- save schematic of the selected area
		minetest.create_schematic(pos1, pos2, {}, schempath.."/"..param..".mts")
		
		-- add arena name and pos1 to table
		spleef.arena[param] = {x=pos1.x, y=pos1.y, z=pos1.z}
		-- save data to file
		save_data()
		-- confirm action to player
		minetest.chat_send_player(name, "You added "..param.." to the spleef arena list")
	end,


})

-- Add gui
function add_gui(name)
	minetest.show_formspec(name, "spleef:form",
	"size[4,3]"..
	"label[0,0;Spleef Arena]"..
	"field[1,1.5;3,1;name;Name;]"..
	"button_exit[1,2;2,1;exit;Save]")
  
end

-- Register callback
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "spleef:form" then
		-- exit callback.
		return false
	end
	-- Store name in metadata for node
	if fields.name then
	  local meta = minetest.get_meta(rpos)
	  meta:set_string("arena", fields.name)
	end
	
	return true
end)

-- Momentary Button action
spleef.button_turnoff = function (pos)
	local node = minetest.get_node(pos)
	if node.name=="spleef:button_on" then --has not been dug
		minetest.swap_node(pos, {name = "spleef:button_off", param2=node.param2})
		minetest.sound_play("button_pop", {pos=pos})
	end
end

-- Register nodes --
-- Register reset button 
minetest.register_node("spleef:button_off", {
	drawtype = "nodebox",
	tiles = {
	"jeija_wall_button_sides.png",
	"jeija_wall_button_sides.png",
	"jeija_wall_button_sides.png",
	"jeija_wall_button_sides.png",
	"jeija_wall_button_sides.png",
	"jeija_wall_button_off.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_wallmounted = true,
	walkable = false,
	sunlight_propagates = true,
	selection_box = {
	type = "fixed",
		fixed = { -6/16, -6/16, 5/16, 6/16, 6/16, 8/16 }
	},
	node_box = {
		type = "fixed",
		fixed = {
		{ -6/16, -6/16, 6/16, 6/16, 6/16, 8/16 },	-- the thin plate behind the button
		{ -4/16, -2/16, 4/16, 4/16, 2/16, 6/16 }	-- the button itself
	}
	},
	groups = {unbreakable = 1, not_in_creative_inventory = 1},
	description = "Spleef Button",
	on_punch = function (pos, node, puncher)
		minetest.swap_node(pos, {name = "spleef:button_on", param2=node.param2})
		minetest.sound_play("button_push", {pos=pos})
		minetest.after(0.5, spleef.button_turnoff, pos)
		local meta = minetest.get_meta(pos)
		local name = meta:get_string("arena")
		  if spleef.arena[name] then
		    local pos = { x=spleef.arena[name].x, y=spleef.arena[name].y, z=spleef.arena[name].z }
		    if minetest.place_schematic(pos, schempath.."/"..name..".mts") == nil then
		      minetest.chat_send_player(puncher:get_player_name(), "Failed to reset "..name.." arena!")
		    else
		      minetest.chat_send_player(puncher:get_player_name(), name.." reset!")
		    end
		  end
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
	-- show the gui
	local name = placer:get_player_name()
	rpos = pos
	add_gui(name)
	end,
	sounds = default.node_sound_stone_defaults(),
})

-- Register reset button ON state
minetest.register_node("spleef:button_on", {
	drawtype = "nodebox",
	tiles = {
		"jeija_wall_button_sides.png",
		"jeija_wall_button_sides.png",
		"jeija_wall_button_sides.png",
		"jeija_wall_button_sides.png",
		"jeija_wall_button_sides.png",
		"jeija_wall_button_on.png"
		},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_wallmounted = true,
	walkable = false,
	light_source = default.LIGHT_MAX-7,
	sunlight_propagates = true,
	selection_box = {
		type = "fixed",
		fixed = { -6/16, -6/16, 5/16, 6/16, 6/16, 8/16 }
	},
	node_box = {
	type = "fixed",
	fixed = {
		{ -6/16, -6/16,  6/16, 6/16, 6/16, 8/16 },
		{ -4/16, -2/16, 11/32, 4/16, 2/16, 6/16 }
	}
    },
	groups = {unbreakable = 1, not_in_creative_inventory=1},
	drop = 'spleef:button_off',
	description = "Spleef Button",
	sounds = default.node_sound_stone_defaults(),
})

-- white block
minetest.register_node("spleef:spleef_block_white", {
	description = "White Spleef Block",
	drawtype = "glasslike",
	range = 12,
	visualscale = 1.0,
	paramtype = "light",
	sunlight_propogates = false,
	walkable = true,
	tiles = {"spleef_white.png"},
	drop = "",
	sounds = default.node_sound_glass_defaults(),
	groups = {dig_immediate=3, not_in_creative_inventory=1}
	})

-- black block
minetest.register_node("spleef:spleef_block_black", {
	description = "Black Spleef Block",
	drawtype = "glasslike",
	range = 12,
	visualscale = 1.0,
	paramtype = "light",
	sunlight_propogates = false,
	walkable = true,
	tiles = {"spleef_black.png"},
	drop = "",
	sounds = default.node_sound_glass_defaults(),
	groups = {dig_immediate=3, not_in_creative_inventory=1}
	})

-- Save & load functions
function save_data()
	if spleef.arena == nil then
		return
	end
	print("[spleef] Saving data")
	local file = io.open(minetest.get_worldpath().."/spleef.txt", "w")
	if file then
		file:write(minetest.serialize(spleef.arena))
		file:close()
	end
end

function load_data()
	local file = io.open(minetest.get_worldpath().."/spleef.txt", "r")
	if file then
		local table = minetest.deserialize(file:read("*all"))
		if type(table) == "table" then
			spleef.arena = table
			return
		end
	end
end

-- load data from file
load_data()

-- Register aliases
minetest.register_alias("spleef_button", "spleef:button_off")
minetest.register_alias("spleef_black", "spleef:spleef_block_black")
minetest.register_alias("spleef_white", "spleef:spleef_block_white")

