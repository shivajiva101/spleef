
-- /spleef_pos set/set1/set2/get
-- Since this is copied from Areas which copies WorldEdit it is licensed under the AGPL.

spleef.marker1 = {}
spleef.marker2 = {}
spleef.set_pos = {}
spleef.pos1 = {}
spleef.pos2 = {}

minetest.register_chatcommand("spleef_pos", {
	params = "set/set1/set2/get",
	description = "Set spleef floor region, position 1, or position 2"
		.." by punching nodes, or display the region",
	func = function(name, param)
		if param == "set" then -- Set both area positions
			spleef.set_pos[name] = "pos1"
			return true, "Select positions by punching two nodes."
		elseif param == "set1" then -- Set area position 1
			spleef.set_pos[name] = "pos1only"
			return true, "Select position 1 by punching a node."
		elseif param == "set2" then -- Set area position 2
			spleef.set_pos[name] = "pos2"
			return true, "Select position 2 by punching a node."
		elseif param == "get" then -- Display current area positions
			local pos1str, pos2str = "Position 1: ", "Position 2: "
			if spleef.pos1[name] then
				pos1str = pos1str..minetest.pos_to_string(spleef.pos1[name])
			else
				pos1str = pos1str.."<not set>"
			end
			if spleef.pos2[name] then
				pos2str = pos2str..minetest.pos_to_string(spleef.pos2[name])
			else
				pos2str = pos2str.."<not set>"
			end
			return true, pos1str.."\n"..pos2str
		else
			return false, "Unknown subcommand: "..param
		end
	end,
})

function spleef:getPos(playerName)
	local pos1, pos2 = spleef.pos1[playerName], spleef.pos2[playerName]
	if not (pos1 and pos2) then
		return nil
	end
	-- Copy positions so that the area table doesn't contain multiple
	-- references to the same position.
	pos1, pos2 = vector.new(pos1), vector.new(pos2)
	return spleef:sortPos(pos1, pos2)
end

function spleef:setPos1(playerName, pos)
	spleef.pos1[playerName] = pos
	spleef.markPos1(playerName)
end

function spleef:setPos2(playerName, pos)
	spleef.pos2[playerName] = pos
	spleef.markPos2(playerName)
end

-- Marks position 1
spleef.markPos1 = function(name)
	local pos = spleef.pos1[name]
	if spleef.marker1[name] ~= nil then -- Marker already exists
		spleef.marker1[name]:remove() -- Remove marker
		spleef.marker1[name] = nil
	end
	if pos ~= nil then -- Add marker
		spleef.marker1[name] = minetest.add_entity(pos, "spleef:pos1")
		spleef.marker1[name]:get_luaentity().active = true
	end
end

-- Marks position 2
spleef.markPos2 = function(name)
	local pos = spleef.pos2[name]
	if spleef.marker2[name] ~= nil then -- Marker already exists
		spleef.marker2[name]:remove() -- Remove marker
		spleef.marker2[name] = nil
	end
	if pos ~= nil then -- Add marker
		spleef.marker2[name] = minetest.add_entity(pos, "spleef:pos2")
		spleef.marker2[name]:get_luaentity().active = true
	end
end

minetest.register_on_punchnode(function(pos, node, puncher)
	local name = puncher:get_player_name()
	-- Currently setting position
	if name ~= "" and spleef.set_pos[name] then
		if spleef.set_pos[name] == "pos1" then
			spleef.pos1[name] = pos
			spleef.markPos1(name)
			spleef.set_pos[name] = "pos2"
			minetest.chat_send_player(name,
					"Position 1 set to "
					..minetest.pos_to_string(pos))
		elseif spleef.set_pos[name] == "pos1only" then
			spleef.pos1[name] = pos
			spleef.markPos1(name)
			spleef.set_pos[name] = nil
			minetest.chat_send_player(name,
					"Position 1 set to "
					..minetest.pos_to_string(pos))
		elseif spleef.set_pos[name] == "pos2" then
			spleef.pos2[name] = pos
			spleef.markPos2(name)
			spleef.set_pos[name] = nil
			minetest.chat_send_player(name,
					"Position 2 set to "
					..minetest.pos_to_string(pos))
		end
	end
end)

-- Modifies positions `pos1` and `pos2` so that each component of `pos1`
-- is less than or equal to its corresponding component of `pos2`,
-- returning the two positions.
function spleef:sortPos(pos1, pos2)
	if pos1.x > pos2.x then
		pos2.x, pos1.x = pos1.x, pos2.x
	end
	if pos1.y > pos2.y then
		pos2.y, pos1.y = pos1.y, pos2.y
	end
	if pos1.z > pos2.z then
		pos2.z, pos1.z = pos1.z, pos2.z
	end
	return pos1, pos2
end

minetest.register_entity("spleef:pos1", {
	initial_properties = {
		visual = "cube",
		visual_size = {x=1.1, y=1.1},
		textures = {"spleef_pos1.png", "spleef_pos1.png",
		            "spleef_pos1.png", "spleef_pos1.png",
		            "spleef_pos1.png", "spleef_pos1.png"},
		collisionbox = {-0.55, -0.55, -0.55, 0.55, 0.55, 0.55},
	},
	on_step = function(self, dtime)
		if self.active == nil then
			self.object:remove()
		end
	end,
	on_punch = function(self, hitter)
		self.object:remove()
		local name = hitter:get_player_name()
		spleef.marker1[name] = nil
	end,
})

minetest.register_entity("spleef:pos2", {
	initial_properties = {
		visual = "cube",
		visual_size = {x=1.1, y=1.1},
		textures = {"spleef_pos2.png", "spleef_pos2.png",
		            "spleef_pos2.png", "spleef_pos2.png",
		            "spleef_pos2.png", "spleef_pos2.png"},
		collisionbox = {-0.55, -0.55, -0.55, 0.55, 0.55, 0.55},
	},
	on_step = function(self, dtime)
		if self.active == nil then
			self.object:remove()
		end
	end,
	on_punch = function(self, hitter)
		self.object:remove()
		local name = hitter:get_player_name()
		spleef.marker2[name] = nil
	end,
})

