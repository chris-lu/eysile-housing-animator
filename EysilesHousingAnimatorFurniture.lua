EHAFurniture = {}

-- Let's not use real OOP as serializeing them will lead to recursive save
function EHAFurniture:new(furnitureId)
  local o = {}
  o.id = furnitureId
  o.name, _ --[[ o.icon ]] , o.data_id  = GetPlacedHousingFurnitureInfo(StringToId64(furnitureId))  
  o.cid = GetCollectibleIdFromFurnitureId(StringToId64(furnitureId))
  o.x, o.y, o.z = HousingEditorGetFurnitureWorldPosition(StringToId64(furnitureId ))
  o.pitch, o.yaw, o.roll = HousingEditorGetFurnitureOrientation(StringToId64(furnitureId))
  o.state = GetPlacedHousingFurnitureCurrentObjectStateIndex(StringToId64(furnitureId))
  o.duration = nil
  return o
end
