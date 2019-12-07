function EysilesHousingAnimator.displayClosest()
	local id = GetNextPlacedHousingFurnitureId()
  local pX, pY, pZ, _ = GetPlayerWorldPositionInHouse()
  local objects = {}

	while id do
    local itemName, _, furnitureDataId = GetPlacedHousingFurnitureInfo(id)
    local furniture = EHAFurniture:new(Id64ToString(id))
    local distance = math.sqrt( ( ( pX - furniture.x ) ^ 2 ) + ( ( pY - furniture.y ) ^ 2 ) + ( ( pZ - furniture.z ) ^ 2 ) )
    
    if distance < 20000 then
      local count = objects[itemName] or 0
      objects[itemName] = count + 1
      -- d(itemName .. ": " .. tostring(distance) .. "m")
    end

    --HousingEditorRequestRemoveFurniture    
		id = GetNextPlacedHousingFurnitureId( id )
	end
  
  for name, count in pairs(objects) do
    d(count .. "x " .. name)
  end
  
  EHA.settings.backup_maison_list = objects
end

-- 
function EysilesHousingAnimator.listClosest()
  local id = GetNextPlacedHousingFurnitureId()
  local pX, pY, pZ, _ = GetPlayerWorldPositionInHouse()
  local backup = {}

	while id do
    local itemName, _, furnitureDataId = GetPlacedHousingFurnitureInfo(id)
    local furniture = EHAFurniture:new(Id64ToString(id))
    local distance = math.sqrt( ( ( pX - furniture.x ) ^ 2 ) + ( ( pY - furniture.y ) ^ 2 ) + ( ( pZ - furniture.z ) ^ 2 ) )
    
    if distance < 20000 then
      furniture.name = itemName
      furniture.dataId = furnitureDataId
      
      table.insert(backup, furniture)
    end

    --HousingEditorRequestRemoveFurniture    
		id = GetNextPlacedHousingFurnitureId( id )
	end
  
  EHA.settings.backup_maison = backup
end


-- Replace all Haies
function EysilesHousingAnimator.placeClosest()
  EHAPlacedFurnitures = {}
  EHACurrentId = GetNextPlacedHousingFurnitureId()
  EysilesHousingAnimator.placeClosestNext()
end

function EysilesHousingAnimator.placeClosestNext()
  local backup = EHA.settings.backup_maison or {}
	local id = EHACurrentId
  local delay = 100
  local pX, pY, pZ, _ = GetPlayerWorldPositionInHouse()
  
	if id then
    local itemName, _, furnitureDataId = GetPlacedHousingFurnitureInfo(id)
    local furniture = EHAFurniture:new(Id64ToString(id))
    local distance = math.sqrt( ( ( pX - furniture.x ) ^ 2 ) + ( ( pY - furniture.y ) ^ 2 ) + ( ( pZ - furniture.z ) ^ 2 ) )
    
    if distance < 20000 then
      local found = false
      local p = EHAPlacedFurnitures[furnitureDataId] or 0
      for i, f in pairs(backup) do
        if(p < i and f.dataId == furnitureDataId) then
          found = true
          d('Furniture ' .. itemName .. ' is matching, placing it.')
          EHAPlacedFurnitures[furnitureDataId] = i
          
          HousingEditorRequestChangePositionAndOrientation (id,  f.x, f.y, f.z, f.pitch, f.yaw, f.roll)
          break
        end
      end
      if found == false then
        d(itemName .. " was not found ?")
      end
    else
      --d(itemName .. " won't be placed")
      delay = 0
    end
    
    EHACurrentId = GetNextPlacedHousingFurnitureId( id )
    
    zo_callLater( EysilesHousingAnimator.placeClosestNext, delay )
	end
end


-- Backup all Haies
function EysilesHousingAnimator.listAll()
  local backup = {}

	local id = GetNextPlacedHousingFurnitureId()
	while id do
    -- Haie, verte haute  (2955)
    -- Haie, longue en bataille (5079)
    -- Haie, en bataille (5078)
    -- Haie, mur arqué (3146)
    -- Haie, verte courte (2953)
    -- Haie, petit fer à cheval (2952)

    local itemName, _, furnitureDataId = GetPlacedHousingFurnitureInfo(id)
    if string.match(itemName, "Haie") then
      local furniture = EHAFurniture:new(Id64ToString(id))
      furniture.name = itemName
      furniture.dataId = furnitureDataId
      
      table.insert(backup, furniture)
    end

    --HousingEditorRequestRemoveFurniture    
		id = GetNextPlacedHousingFurnitureId( id )
	end
  
  EHA.settings.backup = backup
end

-- Remove all Haies
function EysilesHousingAnimator.removeAll()
	EHACurrentId = GetNextPlacedHousingFurnitureId()
  EysilesHousingAnimator.removeNext()
end

function EysilesHousingAnimator.removeNext()
	local id = EHACurrentId
  local delay = 100
  
	if id then
    local itemName, _, furnitureDataId = GetPlacedHousingFurnitureInfo(id)
    if string.match(itemName, "Haie") then
      HousingEditorRequestRemoveFurniture( id )
    else
      delay = 0
    end

    --HousingEditorRequestRemoveFurniture    
		EHACurrentId = GetNextPlacedHousingFurnitureId( id )
    
    zo_callLater( EysilesHousingAnimator.removeNext, delay )
	end
end


-- Replace all Haies
function EysilesHousingAnimator.placeAll()
  EHAPlacedFurnitures = {}
  EHACurrentId = GetNextPlacedHousingFurnitureId()
  EysilesHousingAnimator.placeNext()
end

function EysilesHousingAnimator.placeNext()
  local backup = EHA.settings.backup or {}
	local id = EHACurrentId
  local delay = 100
  
	if id then
    local itemName, _, furnitureDataId = GetPlacedHousingFurnitureInfo(id)
    if string.match(itemName, "Haie") then
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
      d(itemName .. " won't be placed")
      delay = 0
    end
    
    EHACurrentId = GetNextPlacedHousingFurnitureId( id )
    
    zo_callLater( EysilesHousingAnimator.placeNext, delay )
	end
end

