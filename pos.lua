
-- /spleef_pos{1,2} [X Y Z|X,Y,Z].
-- Since this is copied from WorldEdit it is licensed under the AGPL.

spleef.marker1 = {}
spleef.marker2 = {}
spleef.pos1 = {}
spleef.pos2 = {}

minetest.register_chatcommand("spleef_pos1", {
	params = "[X Y Z|X,Y,Z]",
	description = "Set spleef arena position 1 to your"
		.." location or the coordinates specified",
	privs = { server = true },
	func = function(name, param)
		local pos = nil
		local found, _, x, y, z = param:find(
				"^(-?%d+)[, ](-?%d+)[, ](-?%d+)$")
		if found then
			pos = {x=tonumber(x), y=tonumber(y), z=tonumber(z)}
		elseif param == "" then
			local player = minetest.get_player_by_name(name)
			if player then
				pos = player:getpos()
			else
				return false, "Unable to get position."
			end
		else
			return false, "Invalid usage, see /help spleef_pos1."
		end
		pos = vector.round(pos)
		spleef:setPos1(name, pos)
		return true, "Spleef arena position 1 set to "
				..minetest.pos_to_string(pos)
	end,
})

minetest.register_chatcommand("spleef_pos2", {
	params = "[X Y Z|X,Y,Z]",
	description = "Set spleef arena position 2 to your"
		.." location or the coordinates specified",
	func = function(name, param)
		local pos = nil
		local found, _, x, y, z = param:find(
				"^(-?%d+)[, ](-?%d+)[, ](-?%d+)$")
		if found then
			pos = {x=tonumber(x), y=tonumber(y), z=tonumber(z)}
		elseif param == "" then
			local player = minetest.get_player_by_name(name)
			if player then
				pos = player:getpos()
			else
				return false, "Unable to get position."
			end
		else
			return false, "Invalid usage, see /help spleef_pos2."
		end
		pos = vector.round(pos)
		spleef:setPos2(name, pos)
		return true, "Spleef arena position 2 set to "
				..minetest.pos_to_string(pos)
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

