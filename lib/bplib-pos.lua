---CREDIT: Lesbian Mami from Cybersyn. This code is from her lovely codebase.

--------------------------------------------------------------------------------
-- POSITIONS
-- Compute and transform entity positions.
--------------------------------------------------------------------------------

--if ... ~= "__bplib__.pos" then return require("__bplib__.pos") end
local lib = {}

local mlib = require("__rubia__.lib.bplib-math")
local snap_lib = require("__rubia__.lib.bplib-snap")

local floor = math.floor
local pos_get = mlib.pos_get
local pos_set = mlib.pos_set
local pos_new = mlib.pos_new
local pos_add = mlib.pos_add
local pos_rotate_ortho = mlib.pos_rotate_ortho
local pos_set_center = mlib.pos_set_center
local bbox_new = mlib.bbox_new
local bbox_rotate_ortho = mlib.bbox_rotate_ortho
local bbox_translate = mlib.bbox_translate
local bbox_get = mlib.bbox_get
local bbox_set = mlib.bbox_set
local bbox_flip_horiz = mlib.bbox_flip_horiz
local bbox_flip_vert = mlib.bbox_flip_vert
local get_bp_relative_snapping = snap_lib.get_bp_relative_snapping
local snap_to = snap_lib.snap_to
local get_absolute_grid_square = snap_lib.get_absolute_grid_square

local ZERO = { 0, 0 }

---Transform a single entity's position in blueprint space based on rotation
---and flip parameters of the blueprint placement operation.
---@param bp_entity BlueprintEntity
---@param bp_center MapPosition
---@param bp_rot_n int Rotation of the blueprint in 90 degree increments.
---@param flip_horizontal boolean?
---@param flip_vertical boolean?
local function get_blueprint_entity_pos(
	bp_entity,
	bp_center,
	bp_rot_n,
	flip_horizontal,
	flip_vertical
)
	-- Get bpspace position
	local epos = pos_new(bp_entity.position)
	-- Move to central frame of reference
	pos_add(epos, -1, bp_center)
	-- Apply flip
	local rx, ry = pos_get(epos)
	if flip_horizontal then rx = -rx end
	if flip_vertical then ry = -ry end
	pos_set(epos, rx, ry)
	-- Apply blueprint rotation
	pos_rotate_ortho(epos, ZERO, -bp_rot_n)
	return epos
end
lib.get_blueprint_entity_pos = get_blueprint_entity_pos

---@return {[uint]: MapPosition} bp_to_world_pos A mapping of blueprint entity indices to world positions.

---If a blueprint with the given entities were stamped in the world with
---the given parameters, determine the resulting world position of
---each entity of the blueprint.
---@param bp_entities BlueprintEntity[] A *nonempty* set of blueprint entities
---@param bp_entity_filter? fun(bp_entity: BlueprintEntity): boolean Filters which blueprint entities will have their positions computed. Filtering can save some work in handling large blueprints. (Note that you MUST NOT prefilter the blueprint entities array before calling this function.)
---@param bbox BoundingBox As computed by `get_blueprint_bbox`.
---@param snap_index uint? As computed by `get_blueprint_bbox`.
---@param position MapPosition Placement position of the blueprint in worldspace.
---@param direction defines.direction Placement direction of the blueprint.
---@param flip_horizontal boolean? Whether the blueprint is flipped horizontally.
---@param flip_vertical boolean? Whether the blueprint is flipped vertically.
---@param snap TilePosition? If given, the size of the absolute grid to snap to.
---@param snap_offset TilePosition? If given, offset from the absolute grid.
---@param debug_render_surface LuaSurface? If given, debug graphics will be drawn on the given surface showing blueprint placement computations.
---@return data.BoundingBox placement_bbox bounding box for the area being affected
local function get_blueprint_bounding_box(
	bp_entities,
	bp_entity_filter,
	bbox,
	snap_index,
	position,
	direction,
	flip_horizontal,
	flip_vertical,
	snap,
	snap_offset,
	debug_render_surface
)
	local l, t, r, b = bbox_get(bbox)
	local bp_center = { (l + r) / 2, (t + b) / 2 }

	-- Round blueprint rotation to 90 deg increments.
	local rotation, bp_rot_n = direction, 0
	if rotation % 4 == 0 then bp_rot_n = floor(rotation / 4) end

	-- Base coordinates
	local x, y = pos_get(position)
	local translation_center = pos_new()
	if debug_render_surface then
		-- Debug: draw purple circle at mouse pos
		rendering.draw_circle({
			color = { r = 1, g = 0, b = 1, a = 0.75 },
			width = 1,
			filled = true,
			target = position,
			radius = 0.3,
			surface = debug_render_surface,
			time_to_live = 1800,
		})
	end

	-- Grid snapping
	local placement_bbox = bbox_new(bbox)
	if snap then
		-- Absolute snapping case
		-- When absolute snapping, the mouse cursor is snapped to a grid square
		-- first, then the zero of BP space is made to match the topleft of that grid square.
		local gx, gy = pos_get(snap)
		local ox, oy = pos_get(snap_offset or ZERO)
		local gl, gt, gr, gb = get_absolute_grid_square(x, y, gx, gy, ox, oy)
		local rot_center = { (gl + gr) / 2, (gt + gb) / 2 }
		bbox_set(placement_bbox, l + gl, t + gt, r + gl, b + gt)

		-- In absolute snapping, rotation is about the center of the gridsquare.
		if flip_horizontal then bbox_flip_horiz(placement_bbox, rot_center[1]) end
		if flip_vertical then bbox_flip_vert(placement_bbox, rot_center[2]) end
		bbox_rotate_ortho(placement_bbox, rot_center, -bp_rot_n)
		local pl, pt, pr, pb = bbox_get(placement_bbox)

		if debug_render_surface then
			-- Debug: draw green box around computed absolute gridsquare
			rendering.draw_rectangle({
				color = { r = 0, g = 1, b = 0, a = 1 },
				width = 1,
				filled = false,
				left_top = { gl, gt },
				right_bottom = { gr, gb },
				surface = debug_render_surface,
				time_to_live = 1800,
			})
			-- Debug: draw blue box around worldspace bbox
			rendering.draw_rectangle({
				color = { r = 0, g = 0, b = 1, a = 1 },
				width = 1,
				filled = false,
				left_top = { pl, pt },
				right_bottom = { pr, pb },
				surface = debug_render_surface,
				time_to_live = 1800,
			})
		end
	else
		-- Relative snapping case.
		-- Compute bbox center
		local cx, cy = (l + r) / 2, (t + b) / 2
		-- Zero the center
		bbox_translate(placement_bbox, 1, -cx, -cy)
		-- Enact flip/rot
		if flip_horizontal then bbox_flip_horiz(placement_bbox, 0) end
		if flip_vertical then bbox_flip_vert(placement_bbox, 0) end
		bbox_rotate_ortho(placement_bbox, ZERO, -bp_rot_n)

		local snap_entity = bp_entities[snap_index]
		local xst, yst, xso, yso
		if snap_entity then
			-- Transform snap entity position and compute snapping based on that
			local snap_entity_pos = get_blueprint_entity_pos(
				snap_entity,
				bp_center,
				bp_rot_n,
				flip_horizontal,
				flip_vertical
			)
			xst, yst, xso, yso = get_bp_relative_snapping(
				placement_bbox,
				snap_entity,
				snap_entity_pos,
				bp_rot_n
			)
		else
			-- Compute relative snapping based on bbox dimensions only (1x1 snapping)
			xst, yst, xso, yso = get_bp_relative_snapping(placement_bbox, nil)
		end
		bbox_translate(placement_bbox, 1, xso, yso)

		local sx, sy = snap_to(x, xst), snap_to(y, yst)
		if debug_render_surface then
			-- Debug: blue circle at snap point
			rendering.draw_circle({
				color = { r = 0, g = 0, b = 1, a = 0.75 },
				width = 1,
				filled = true,
				target = { sx, sy },
				radius = 0.3,
				surface = debug_render_surface,
				time_to_live = 1800,
			})
		end

		-- Map center of bbox to snapped x,y
		bbox_translate(placement_bbox, 1, sx, sy)

		if debug_render_surface then
			-- Debug: draw world bbox in blue
			local pl, pt, pr, pb = bbox_get(placement_bbox)
			rendering.draw_rectangle({
				color = { r = 0, g = 0, b = 1, a = 1 },
				width = 1,
				filled = false,
				left_top = { pl, pt },
				right_bottom = { pr, pb },
				surface = debug_render_surface,
				time_to_live = 1800,
			})
		end
	end
	pos_set_center(translation_center, placement_bbox)

	return placement_bbox

end
--[[
	-- Compute per-entity positions
	local bp_to_world_pos = {}
	for i = 1, #bp_entities do
		local bp_entity = bp_entities[i]
		if bp_entity_filter and not bp_entity_filter(bp_entity) then
			goto continue
		end

		-- Get bpspace position
		local epos = get_blueprint_entity_pos(
			bp_entity,
			bp_center,
			bp_rot_n,
			flip_horizontal,
			flip_vertical
		)
		-- Translate back to worldspace
		pos_add(epos, 1, translation_center)

		if debug_render_surface then
			-- Debug: blue square at computed entity pos.
			-- This should overlap precisely with the green square drawn by the F4
			-- debug mode when showing entity positions.
			rendering.draw_rectangle({
				color = { r = 0, g = 0, b = 1, a = 1 },
				width = 1,
				filled = true,
				left_top = { epos[1] - 0.2, epos[2] - 0.2 },
				right_bottom = { epos[1] + 0.2, epos[2] + 0.2 },
				surface = debug_render_surface,
				time_to_live = 1800,
			})
		end

		bp_to_world_pos[i] = epos
		::continue::
	end

	return bp_to_world_pos
end]]
lib.get_blueprint_bounding_box = get_blueprint_bounding_box

return lib