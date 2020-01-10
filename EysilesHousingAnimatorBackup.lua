local EHA = EysilesHousingAnimator
EHABackup = {}

function EHABackup.listClosest(limit)
  local id = GetNextPlacedHousingFurnitureId()
  local pX, pY, pZ, _ = GetPlayerWorldPositionInHouse()
  local backup = {}

	while id do
    local itemName, _, furnitureDataId = GetPlacedHousingFurnitureInfo(id)
    local furniture = EHAFurniture:new(Id64ToString(id))
    local distance = math.sqrt( ( ( pX - furniture.x ) ^ 2 ) + ( ( pY - furniture.y ) ^ 2 ) + ( ( pZ - furniture.z ) ^ 2 ) )
    
    if distance < (limit or 20000) then
      furniture.name = itemName
      furniture.dataId = furnitureDataId
      
      table.insert(backup, furniture)
      d('Found ' .. itemName .. ' with ID ' .. Id64ToString(id)) 
    end

    --HousingEditorRequestRemoveFurniture    
		id = GetNextPlacedHousingFurnitureId( id )
	end
  
  if backup then 
    EHA.settings.backup = backup
  end
end


-- Replace all Haies
function EHABackup.placeClosest(limit)
  EHAPlacedFurnitures = {}
  EHACurrentId = GetNextPlacedHousingFurnitureId()
  EHABackup.placeClosestNext(limit)
end

function EHABackup.placeClosestNext(limit)
  local backup = EHA.settings.backup or {}
	local id = EHACurrentId
  local delay = 100
  local pX, pY, pZ, _ = GetPlayerWorldPositionInHouse()
  
	if id then
    local itemName, _, furnitureDataId = GetPlacedHousingFurnitureInfo(id)
    local furniture = EHAFurniture:new(Id64ToString(id))
    local distance = math.sqrt( ( ( pX - furniture.x ) ^ 2 ) + ( ( pY - furniture.y ) ^ 2 ) + ( ( pZ - furniture.z ) ^ 2 ) )
    
    if distance < (limit or 20000) then
      local found = false
      local p = EHAPlacedFurnitures[furnitureDataId] or 0
      for i, f in pairs(backup) do
        if(p < i and f.dataId == furnitureDataId) then
          found = true
          EHA.d('Furniture ' .. itemName .. ' is matching, placing it.')
          EHAPlacedFurnitures[furnitureDataId] = i
          
          HousingEditorRequestChangePositionAndOrientation (id,  f.x, f.y, f.z, f.pitch, f.yaw, f.roll)
          break
        end
      end
      if found == false then
        EHA.d(itemName .. " was not found ?")
      end
    else
      -- EHA.d(itemName .. " won't be placed")
      delay = 0
    end
    
    EHACurrentId = GetNextPlacedHousingFurnitureId( id )
    
    zo_callLater( function() EHABackup.placeClosestNext(limit) end, delay )
	end
end


-- Backup all Haies
function EHABackup.listAll(name)
  local backup = {}

	local id = GetNextPlacedHousingFurnitureId()
	while id do
    local itemName, _, furnitureDataId = GetPlacedHousingFurnitureInfo(id)
    if string.match(itemName, name) then
      local furniture = EHAFurniture:new(Id64ToString(id))
      furniture.name = itemName
      furniture.dataId = furnitureDataId
      
      table.insert(backup, furniture)
    end

    --HousingEditorRequestRemoveFurniture    
		id = GetNextPlacedHousingFurnitureId( id )
	end
  
  if backup then 
    EHA.settings.backup = backup
  end

end

-- Remove all Haies
function EHABackup.removeAll(name)
	EHACurrentId = GetNextPlacedHousingFurnitureId()
  EHABackup.removeNext(name)
end

function EHABackup.removeNext(name)
	local id = EHACurrentId
  local delay = 100
  
	if id then
    local itemName, _, furnitureDataId = GetPlacedHousingFurnitureInfo(id)
    if string.match(itemName, name) then
      HousingEditorRequestRemoveFurniture( id )
    else
      delay = 0
    end

    --HousingEditorRequestRemoveFurniture    
		EHACurrentId = GetNextPlacedHousingFurnitureId( id )
    
    zo_callLater( function() EHABackup.removeNext(name) end, delay )
	end
end


-- Replace all Haies
function EHABackup.placeAll(name)
  EHAPlacedFurnitures = {}
  EHACurrentId = GetNextPlacedHousingFurnitureId()
  EHABackup.placeNext(name)
end

function EHABackup.placeNext(name)
  local backup = EHA.settings.backup or {}
	local id = EHACurrentId
  local delay = 100
  
	if id then
    local itemName, _, furnitureDataId = GetPlacedHousingFurnitureInfo(id)
    if string.match(itemName, name) then
      local p = EHAPlacedFurnitures[furnitureDataId] or 0
      for i, f in pairs(backup) do
        if(p < i and f.dataId == furnitureDataId) then
          d('Furniture ' .. itemName .. ' is matching, placing it.')
          EHAPlacedFurnitures[furnitureDataId] = i
          
          HousingEditorRequestChangePositionAndOrientation (id,  f.x, f.y, f.z, f.pitch, f.yaw, f.roll)
          break
        end
      end
    else
      -- EHA.d(itemName .. " won't be placed")
      delay = 0
    end
    
    EHACurrentId = GetNextPlacedHousingFurnitureId( id )
    
    zo_callLater( function() EHABackup.placeNext(name) end, delay )
	end
end
