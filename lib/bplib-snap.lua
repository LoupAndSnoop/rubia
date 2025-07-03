---CREDIT: Lesbian Mami from Cybersyn. This code is from her lovely codebase.

--------------------------------------------------------------------------------
-- SNAPPING
-- Snapping is a nightmare. This is a result of a tedious empirical reverse
-- engineering process. There is no doc on how snapping actually works and it is
-- riddled with edge cases.
--
-- There is hopefully no need to call this sublibrary from end user code as
-- it is primarily consumed by the blueprint-to-world coordinate transformation
-- code.
--------------------------------------------------------------------------------

--if ... ~= "__bplib__.snap" then return require("__bplib__.snap") end
local lib = {}

local mlib = require("__rubia__.lib.bplib-math")
--local internal = require("__bplib__.internal")
--local get_snap_data_for_direction = internal.get_snap_data_for_direction

---@param bp_entity BlueprintEntity
---@param eproto LuaEntityPrototype
---@return bplib.SnapData|nil
local function get_snap_data_for_direction(bp_entity, eproto)
	local snap_data = get_custom_entity_info(eproto)
	if not snap_data then return nil end
	local data = snap_data[bp_entity.direction or 0]
	if not data then data = snap_data[0] end
	return data
end


local floor = math.floor
local bbox_get = mlib.bbox_get
local pos_new = mlib.pos_new
local pos_add = mlib.pos_add

---Possible types of cursor snapping during relative blueprint placement.
---@enum bplib.SnapType
local SnapType = {
	"GRID_POINT",
	"TILE",
	"EVEN_GRID_POINT",
	"EVEN_TILE",
	"ODD_GRID_POINT",
	"ODD_TILE",
	GRID_POINT = 1,
	TILE = 2,
	EVEN_GRID_POINT = 3,
	EVEN_TILE = 4,
	ODD_GRID_POINT = 5,
	ODD_TILE = 6,
}
lib.SnapType = SnapType

---Snap a coordinate to the appropriate grid point or tile based on the
---snap type.
---@param coord number
---@param snap_type bplib.SnapType
---@return number
local function snap_to(coord, snap_type)
	if snap_type == SnapType.GRID_POINT then
		return floor(coord + 0.5)
	elseif snap_type == SnapType.TILE then
		return floor(coord) + 0.5
	elseif snap_type == SnapType.EVEN_GRID_POINT then
		local snapped = floor(coord)
		if snapped % 2 ~= 0 then snapped = snapped + 1 end
		return snapped
	elseif snap_type == SnapType.EVEN_TILE then
		local snapped = floor(coord)
		if snapped % 2 ~= 0 then snapped = snapped - 1 end
		return snapped + 0.5
	elseif snap_type == SnapType.ODD_GRID_POINT then
		local snapped = floor(coord)
		if snapped % 2 == 0 then snapped = snapped + 1 end
		return snapped
	elseif snap_type == SnapType.ODD_TILE then
		local snapped = floor(coord)
		if snapped % 2 == 0 then snapped = snapped - 1 end
		return snapped + 0.5
	end

	return coord -- no snapping applied.
end
lib.snap_to = snap_to

---In an absolute grid with squares sized `gx`x`gy` and a global offset of
---`(ox, oy)`, find the square containing the point `(x, y)` and return its
---bounding box.
---@param x number
---@param y number
---@param gx number Horizontal grid size
---@param gy number Vertical grid size
---@param ox number Horizontal grid offset
---@param oy number Vertical grid offset
local function get_absolute_grid_square(x, y, gx, gy, ox, oy)
	local left = floor((x - ox) / gx) * gx + ox
	local top = floor((y - oy) / gy) * gy + oy
	local right = left + gx
	local bottom = top + gy
	return left, top, right, bottom
end
lib.get_absolute_grid_square = get_absolute_grid_square

---@param length uint Total length of the axis in tiles
---@param target_parity 1|2 1 = odd, 2 = even
---@param half_pos int Position along the axis in half tiles
---@return bplib.SnapType snap_type World space cursor snapping method
---@return int offset Further bbox offset adjustment along this axis
local function compute_single_axis_snap_type(length, target_parity, half_pos)
	local offset = 0
	if floor(length) % 2 == 0 then
		-- Center will be on grid point, meaning we are SnapType 1,3,5
		if target_parity == 1 then
			-- Target parity is odd. If we are a multiple of 4 halfsteps away,
			-- our parity must also be odd.
			if half_pos % 4 == 0 then
				return SnapType.ODD_GRID_POINT, offset
			else
				return SnapType.EVEN_GRID_POINT, offset
			end
		else
			if half_pos % 4 == 0 then
				return SnapType.EVEN_GRID_POINT, offset
			else
				return SnapType.ODD_GRID_POINT, offset
			end
		end
	else
		-- I have ABSOLUTELY NO IDEA why this is needed but it works.
		if half_pos > 0 then
			half_pos = -half_pos
			offset = 1
		end
		-- Center will be between grid points, meaning we are SnapType 2,4,6
		if target_parity == 1 then
			-- Target parity is odd.
			if half_pos % 4 == 1 then
				-- Center of an even tile shifted by 1 half step
				-- gives an odd grid point.
				return SnapType.EVEN_TILE, offset
			else
				return SnapType.ODD_TILE, offset
			end
		else
			if half_pos % 4 == 1 then
				return SnapType.ODD_TILE, offset
			else
				return SnapType.EVEN_TILE, offset
			end
		end
	end
end

---Get information on how the cursor position needs to be snapped when placing
---a blueprint with relative positioning.
---@param bbox BoundingBox Transformed bpspace bbox.
---@param snap_entity BlueprintEntity? Entity governing snapping, if any
---@param snap_entity_pos MapPosition? Transformed bpspace position of the snap entity.
---@param bp_rot_n int? Rotation of the blueprint in 90 degree increments.
---@return bplib.SnapType xsnap Snapping type for the X-axis.
---@return bplib.SnapType ysnap Snapping type for the Y-axis.
---@return int xofs Offset to apply to the X-axis.
---@return int yofs Offset to apply to the Y-axis.
function lib.get_bp_relative_snapping(
	bbox,
	snap_entity,
	snap_entity_pos,
	bp_rot_n
)
	local l, t, r, b = bbox_get(bbox)
	local w, h = r - l, b - t
	local xsnap, ysnap = SnapType.GRID_POINT, SnapType.GRID_POINT
	local xofs, yofs = 0, 0
	if not snap_entity then
		-- Simple snapping to tile or grid point.
		if floor(w) % 2 ~= 0 then xsnap = SnapType.TILE end
		if floor(h) % 2 ~= 0 then ysnap = SnapType.TILE end
		return xsnap, ysnap, xofs, yofs
	end

	-- Find snap entity
	local proto = prototypes.entity[snap_entity.name]
	local snap_table = get_snap_data_for_direction(snap_entity, proto)
	if not snap_table then
		-- XXX: this should never happen
		return xsnap, ysnap, xofs, yofs
	end
	local snap_target_parity = { snap_table[5], snap_table[6] }
	if bp_rot_n % 2 == 1 then
		-- Swap x and y parities if the blueprint is rotated.
		snap_target_parity[1], snap_target_parity[2] =
			snap_target_parity[2], snap_target_parity[1]
	end

	-- Compute number of half integer steps from origin to controlling snap
	-- entity pos.
	local cx, cy = (l + r) / 2, (t + b) / 2
	local spos = pos_new(snap_entity_pos)
	pos_add(spos, -1, { cx, cy })
	spos[1] = mlib.round(spos[1] / 0.5, 1)
	spos[2] = mlib.round(spos[2] / 0.5, 1)

	-- Find center parity that yields desired parity at snap entity position.
	xsnap, xofs = compute_single_axis_snap_type(w, snap_target_parity[1], spos[1])
	ysnap, yofs = compute_single_axis_snap_type(h, snap_target_parity[2], spos[2])

	return xsnap, ysnap, xofs, yofs
end

return lib