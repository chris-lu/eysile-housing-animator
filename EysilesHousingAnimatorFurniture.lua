EHAFurniture = {}

-- Let's not use real OOP as serializeing them will lead to recursive save
function EHAFurniture:new(furnitureId)
  local o = {}
  o.id = furnitureId
  o.cid = GetCollectibleIdFromFurnitureId(StringToId64(furnitureId))
  o.x, o.y, o.z = HousingEditorGetFurnitureWorldPosition(StringToId64(furnitureId ))
  o.pitch, o.yaw, o.roll = HousingEditorGetFurnitureOrientation(StringToId64(furnitureId))
  o.state = GetPlacedHousingFurnitureCurrentObjectStateIndex(StringToId64(furnitureId))
  o.duration = nil
  
  return o
end

function EHAFurniture:deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[EHAFurniture:deepcopy(orig_key)] = EHAFurniture:deepcopy(orig_value)
        end
        setmetatable(copy, EHAFurniture:deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end