---CREDIT: Lesbian Mami from Cybersyn. This code is from her lovely codebase.

--------------------------------------------------------------------------------
-- SINGLE-ENTITY BBOXES
--
-- The factorio documentation for computing bounding boxes is basically
-- completely false for rails, particularly curved rails. The following code
-- is an attempt to empirically reverse engineer the behavior of rails wrt
-- bounding boxes and snapping, while falling back on factorio api
-- information for most entities where they are reliable.
--------------------------------------------------------------------------------

if ... ~= "__rubia__.lib.bplib-bbox" then return require("__rubia__.lib.bplib-bbox") end
local lib = {}

local mlib = require("__rubia__.lib.bplib-math")

local pos_get = mlib.pos_get
local bbox_new = mlib.bbox_new
local bbox_rotate_ortho = mlib.bbox_rotate_ortho
local bbox_translate = mlib.bbox_translate
local bbox_union = mlib.bbox_union
local bbox_round = mlib.bbox_round
local floor = math.floor
local ZERO = { 0, 0 }

local internal = require("__rubia__.lib.bplib-internal")
local get_snap_data_for_direction = internal.get_snap_data_for_direction
local empty = {}

---Generically compute the bounding box of a blueprint entity in blueprint space.
---Works for all entities that obey the factorio docs.
---@param bp_entity BlueprintEntity
---@param eproto LuaEntityPrototype
local function default_bbox(bp_entity, eproto)
	local ebox = bbox_new(eproto.collision_box)
	local dir = bp_entity.direction or 0
	bbox_rotate_ortho(ebox, ZERO, floor(dir / 4))
	bbox_translate(ebox, 1, bp_entity.position)
	return ebox
end

---Compute bbox of a blueprint entity using custom snap data.
---@param bp_entity BlueprintEntity
---@param snap bplib.SnapData
local function custom_bbox(bp_entity, snap)
	local x, y = pos_get(bp_entity.position)
	return {
		{ x + snap[1], y + snap[2] },
		{ x + snap[3], y + snap[4] },
	}
end

---Compute the bounding box of a blueprint entity in blueprint space.
---@param bp_entity BlueprintEntity
---@return BoundingBox
function lib.get_blueprint_entity_bbox(bp_entity)
	local eproto = prototypes.entity[bp_entity.name]
	local snap_data = get_snap_data_for_direction(bp_entity, eproto)
	if snap_data then
		return custom_bbox(bp_entity, snap_data)
	else
		return default_bbox(bp_entity, eproto)
	end
end

---Get the net bounding box of an entire set of BP entities. Also locates an
---entity within the blueprint that will cause implied snapping for relative
---placement, if any.
---@param bp_entities BlueprintEntity[] A *nonempty* set of blueprint entities.
---@param entity_bounding_boxes? BoundingBox[] If provided, will be filled with the bounding boxes of each entity by index.
---@return BoundingBox bbox The bounding box of the blueprint in blueprint space
---@return uint? snap_index The index of the entity that causes implied snapping, if any.
function lib.get_blueprint_bbox(bp_entities, entity_bounding_boxes)
	local snap_index = nil

	local e1x, e1y = pos_get(bp_entities[1].position)
	---@type BoundingBox
	local bpspace_bbox = { { e1x, e1y }, { e1x, e1y } }

	for i = 1, #bp_entities do
		local bp_entity = bp_entities[i]
		local eproto = prototypes.entity[bp_entity.name]
		local snap_data = get_snap_data_for_direction(bp_entity, eproto)

		-- Detect entities which cause implied snapping of the blueprint.
		if snap_index == nil and snap_data and snap_data[5] then snap_index = i end

		-- Get bbox for entity and union it with existing bbox.
		local ebox = snap_data and custom_bbox(bp_entity, snap_data)
			or default_bbox(bp_entity, eproto)
		if entity_bounding_boxes then entity_bounding_boxes[i] = ebox end
		bbox_union(bpspace_bbox, ebox)
	end

	bbox_round(bpspace_bbox)

	return bpspace_bbox, snap_index
end

return lib