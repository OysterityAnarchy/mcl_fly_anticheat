if minetest.settings:get_bool("disable_fly_anticheat", false) then
	return
end

local players = {}

local pts = minetest.pos_to_string

minetest.register_on_joinplayer(function(player)
	players[player] = {
		pos = player:get_pos()
	}
end)

minetest.register_on_leaveplayer(function(player)
	players[player] = nil
end)

local function supported_by_node(pos)
	pos = vector.floor(pos)

	for y = -2, 0 do
	for x = -1, 1 do
	for z = -1, 1 do
		local v = vector.add(pos, vector.new(x, y, z))
		
		if minetest.get_node(v).name ~= "air" then
			return true
		end
	end
	end
	end
end

local i = 0

minetest.register_globalstep(function()
	i = i + 1
	
	for _, player in pairs(minetest.get_connected_players()) do
		if not minetest.check_player_privs(player:get_player_name(), {fly = true}) then
			local pos = player:get_pos()
			local old_pos = players[player].pos

			if old_pos.y < pos.y and not supported_by_node(pos) then
				player:set_pos(old_pos)
				print(i, pts(pos), pts(old_pos))
			end
		end

		players[player].pos = player:get_pos()
	end
end)
