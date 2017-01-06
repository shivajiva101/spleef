-- Minetest mod for creating spleef arenas by shivajiva101@hotmail.com

spleef = {}
spleef.arena = {}
spleef.colours = {
  {"white", "White"},
  {"grey", "Grey"},
  {"black", "Black"},
  {"red", "Red"},
  {"yellow", "Yellow"},
  {"green", "Green"},
  {"cyan", "Cyan"},
  {"blue", "Blue"},
  {"magenta", "Magenta"},
  {"orange", "Orange"},
  {"violet", "Violet"},
  {"brown", "Brown"},
  {"pink", "Pink"},
  {"dark_grey", "Dark Grey"},
  {"dark_green", "Dark Green"},
}

-- Load files
dofile(minetest.get_modpath(minetest.get_current_modname()).."/pos.lua");

local schempath = minetest.get_modpath(minetest.get_current_modname())..'/schems'

minetest.register_chatcommand("spleef_add", {
    params = "<name>",
    description = "Adds a spleef arena to the list",
    privs = {server=true},

    func = function(name, param)

      if param == "" then
        return false, "Invalid usage, see /help spleef_add."
      end

      -- return if name already in use
      if spleef.arena[param] then
        minetest.chat_send_player(name, param.." is already in use!")
        return
      end

      -- check area has been selected
      local pos1, pos2 = spleef:getPos(name)
      if not (pos1 and pos2) then
        return false, "You need to select an area first."
      end

      -- save schematic of area
      if minetest.create_schematic(pos1, pos2, {}, schempath.."/"..param..".mts") == nil then
        minetest.chat_send_player(name, "Failed to create "..param.." schematic file")
      else
        spleef.arena[param] = {x=pos1.x, y=pos1.y, z=pos1.z} -- add arena name and pos1 to table
        spleef.save_data() -- save data to file
        minetest.chat_send_player(name, "You added "..param.." to the spleef arena list") -- confirm action to player
      end

    end,
  })

minetest.register_chatcommand("spleef_remove", {
    params = "<name>",
    description = "Removes a spleef arena from the list",
    privs = {server=true},

    func = function(name, param)

      if param == "" then
        return false, "Invalid usage, see /help spleef_remove."
      end

      -- remove entry
      if spleef.arena[param] then
        spleef.arena[param] = nil
        -- save arena to file
        spleef.save_data()
        minetest.chat_send_player(name, param.." arena removed!")
        return
      else
        -- return if name doesn't exist
        minetest.chat_send_player(name, param.." doesn't exist!")
      end
    end,
  })

minetest.register_chatcommand("spleef_list", {
    params = "",
    description = "List spleef arenas.",
    privs = {server=true},

    func = function(name)
      local arenaStrings = {}
      for key, value in pairs(spleef.arena) do
        table.insert(arenaStrings, key)
      end
      if #arenaStrings == 0 then
        return true, "No spleef arenas."
      end
      return true, table.concat(arenaStrings, "\n")
    end,
  })

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
        { -6/16, -6/16, 6/16, 6/16, 6/16, 8/16 }, -- the thin plate behind the button
        { -4/16, -2/16, 4/16, 4/16, 2/16, 6/16 } -- the button itself
      }
    },
    groups = {unbreakable = 1, not_in_creative_inventory = 1},
    description = "Spleef Button",

    on_construct = function(pos)
      local meta = minetest.get_meta(pos)
      -- text entry formspec
      meta:set_string("formspec", "field[text;" .. "Enter game name" .. ";${arena}]")
      meta:set_string("infotext", "Right-click to set")
    end,

    on_punch = function (pos, node, puncher)
      -- change button preserving metadata
      minetest.swap_node(pos, {name = "spleef:button_on", param2=node.param2})
      minetest.sound_play("button_push", {pos=pos})
      minetest.after(0.5, spleef.button_turnoff, pos)
      local meta = minetest.get_meta(pos)
      local name = meta:get_string("arena")
      if spleef.arena[name] then
        local pos = { x=spleef.arena[name].x, y=spleef.arena[name].y, z=spleef.arena[name].z }
        if minetest.place_schematic(pos, schempath.."/"..name..".mts") == nil then
          minetest.chat_send_player(puncher:get_player_name(), "Failed to reset "..name.." spleef arena!")
        else
          minetest.chat_send_player(puncher:get_player_name(), name.." spleef arena reset!")
        end
      else
        minetest.chat_send_player(puncher:get_player_name(), name.." doesn't exist!")
      end
    end,

    on_receive_fields = function(pos, formname, fields, sender)

      local name = sender:get_player_name()
      local game = fields.text

      if not minetest.check_player_privs(name, {server = true}) then
        return
      end

      if game ~= "" then
        if spleef.arena[game] then
          local meta = minetest.get_meta(pos)
          meta:set_string("arena", fields.text)
          meta:set_string("infotext", "reset "..fields.text.." arena")
        else
          minetest.chat_send_player(name, "That arena does not exist...\nTry adding it first!")
        end
      else
        minetest.chat_send_player(name, "arena missing, unable to set button!")
      end

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
    light_source = 7,
    sunlight_propagates = true,
    selection_box = {
      type = "fixed",
      fixed = { -6/16, -6/16, 5/16, 6/16, 6/16, 8/16 }
    },
    node_box = {
      type = "fixed",
      fixed = {
        { -6/16, -6/16, 6/16, 6/16, 6/16, 8/16 },
        { -4/16, -2/16, 11/32, 4/16, 2/16, 6/16 }
      }
    },
    groups = {unbreakable = 1, not_in_creative_inventory=1},
    drop = 'spleef:button_off',
    description = "Spleef Button",
    sounds = default.node_sound_stone_defaults(),
  })

-- register nodes
for _, row in ipairs(spleef.colours) do
  local name = row[1]
  local desc = row[2]
  -- Node Definition
  minetest.register_node("spleef:spleef_block_"..name, {
      description = desc.." Spleef Block",
      range = 15,
      paramtype = "light",
      sunlight_propogates = false,
      walkable = true,
      tiles = {"wool_"..name..".png"},
      is_ground_content = false,
      groups = {dig_immediate=3, not_in_creative_inventory=1},
      sounds = default.node_sound_glass_defaults(),
      drop = "",
    })
    minetest.register_alias("spleef_"..name, "spleef:spleef_block_"..name)
end

-- Save & load functions
spleef.save_data = function()
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

spleef.load_data = function()
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
spleef.load_data()

-- Register aliases
minetest.register_alias("spleef_button", "spleef:button_off")
