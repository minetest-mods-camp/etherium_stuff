local function on_flood(pos, oldnode, newnode)
	minetest.add_item(pos, ItemStack("etherium_stuff:torch 1"))
	-- Play flame-extinguish sound if liquid is not an 'igniter'
	local nodedef = minetest.registered_items[newnode.name]
	if not (nodedef and nodedef.groups and
			nodedef.groups.igniter and nodedef.groups.igniter > 0) then
		minetest.sound_play(
			"default_cool_lava",
			{pos = pos, max_hear_distance = 16, gain = 0.1}
		)
	end
	-- Remove the torch node
	return false
end

minetest.register_node("etherium_stuff:torch", {
	description = "Etherium Torch",
	drawtype = "mesh",
	mesh = "torch_floor.obj",
	inventory_image = "etherium_torch_on_floor.png",
	wield_image = "etherium_torch_on_floor.png",
	tiles = {{
		    name = "etherium_torch_on_floor_animated.png",
		    animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
	}},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	liquids_pointable = false,
	light_source = default.LIGHT_MAX,
	groups = {choppy=2, dig_immediate=3, flammable=1, attached_node=1, torch=1},
	drop = "etherium_stuff:torch",
	selection_box = {
		type = "wallmounted",
		wall_bottom = {-1/8, -1/2, -1/8, 1/8, 2/16, 1/8},
	},
	sounds = default.node_sound_wood_defaults(),
	on_place = function(itemstack, placer, pointed_thing)
		local under = pointed_thing.under
		local node = minetest.get_node(under)
		local def = minetest.registered_nodes[node.name]
		if def and def.on_rightclick and
			not (placer and placer:is_player() and
			placer:get_player_control().sneak) then
			return def.on_rightclick(under, node, placer, itemstack,
				pointed_thing) or itemstack
		end

		local above = pointed_thing.above
		local wdir = minetest.dir_to_wallmounted(vector.subtract(under, above))
		local fakestack = itemstack
		if wdir == 0 then
			fakestack:set_name("etherium_stuff:torch_ceiling")
		elseif wdir == 1 then
			fakestack:set_name("etherium_stuff:torch")
		else
			fakestack:set_name("etherium_stuff:torch_wall")
		end

		itemstack = minetest.item_place(fakestack, placer, pointed_thing, wdir)
		itemstack:set_name("etherium_stuff:torch")

		return itemstack
	end,
	floodable = true,
	on_flood = on_flood,
	on_rotate = false
})

minetest.register_node("etherium_stuff:torch_wall", {
	drawtype = "mesh",
	mesh = "torch_wall.obj",
	tiles = {{
		    name = "etherium_torch_on_floor_animated.png",
		    animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
	}},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	light_source = default.LIGHT_MAX,
	groups = {choppy=2, dig_immediate=3, flammable=1, not_in_creative_inventory=1, attached_node=1, torch=1},
	drop = "etherium_stuff:torch",
	selection_box = {
		type = "wallmounted",
		wall_side = {-1/2, -1/2, -1/8, -1/8, 1/8, 1/8},
	},
	sounds = default.node_sound_wood_defaults(),
	floodable = true,
	on_flood = on_flood,
	on_rotate = false
})

minetest.register_node("etherium_stuff:torch_ceiling", {
	drawtype = "mesh",
	mesh = "torch_ceiling.obj",
	tiles = {{
		    name = "etherium_torch_on_floor_animated.png",
		    animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
	}},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	light_source = default.LIGHT_MAX,
	groups = {choppy=2, dig_immediate=3, flammable=1, not_in_creative_inventory=1, attached_node=1, torch=1},
	drop = "etherium_stuff:torch",
	selection_box = {
		type = "wallmounted",
		wall_top = {-1/8, -1/16, -5/16, 1/8, 1/2, 1/8},
	},
	sounds = default.node_sound_wood_defaults(),
	floodable = true,
	on_flood = on_flood,
	on_rotate = false
})

minetest.register_lbm({
	name = "etherium_stuff:3dtorch",
	nodenames = {"etherium_stuff:torch", "torches:floor", "torches:wall"},
	action = function(pos, node)
		if node.param2 == 0 then
			minetest.set_node(pos, {name = "etherium_stuff:torch_ceiling",
				param2 = node.param2})
		elseif node.param2 == 1 then
			minetest.set_node(pos, {name = "etherium_stuff:torch",
				param2 = node.param2})
		else
			minetest.set_node(pos, {name = "etherium_stuff:torch_wall",
				param2 = node.param2})
		end
	end
})
