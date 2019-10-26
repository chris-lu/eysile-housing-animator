EysilesHousingAnimator = {
    name = "EysilesHousingAnimator",
    
    options = {
        type = "panel",
        name = "Eysile's Housing Animator",
        author = "mouton",
        version = "1.0"
    },

    command =  "/eha",
    
    templates = {},
    settings = {},
    
    defaultSettings = {
      refreshRate = 100,
      scenes = {},
      variableVersion = 1,
      debug = false,
    }
}

-- Local references to important objects
local EHA = EysilesHousingAnimator
local MAX_STACK = 50
local houseId = 0
local scene = {}
local furnitures = {}
local latestFurnitureId = nil
local latestCollectible = nil

function EHA.OnAddOnLoaded(event, addonName)
  if addonName ~= EHA.name then return end

  EHA:Initialize()
end

-- EVENT_HOUSING_EDITOR_COMMAND_RESULT, number eventCode, number HousingEditorCommandResult result
function EHA.DebugEditorCommand(eventCode, result)
  -- d("EVENT_HOUSING_EDITOR_COMMAND_RESULT", eventCode, result)
end

-- EVENT_HOUSING_EDITOR_LINK_TARGET_CHANGED, number eventCode
function EHA.DebugEditorLink(eventCode)
  -- d("EVENT_HOUSING_EDITOR_LINK_TARGET_CHANGED", eventCode)
end

-- EVENT_HOUSING_EDITOR_MODE_CHANGED, number eventCode, HousingEditorMode oldMode, HousingEditorMode newMode
function EHA.DebugEditorMode(eventCode, oldMode, newMode)
  -- d("EVENT_HOUSING_EDITOR_MODE_CHANGED", eventCode, oldMode, newMode)
end

-- EVENT_HOUSING_EDITOR_REQUEST_RESULT, number eventCode, HousingRequestResult requestResult
function EHA.DebugEditorRequest(eventCode, requestResult)
  -- d("EVENT_HOUSING_EDITOR_REQUEST_RESULT", eventCode, requestResult)
end

-- EVENT_HOUSING_FURNITURE_MOVED, number eventCode, id64 furnitureId
function EHA.FurnitureMoved(eventCode, furnitureId)
  if GetHousingEditorMode() ~= HOUSING_EDITOR_MODE_DISABLED then
    -- d("EVENT_HOUSING_FURNITURE_MOVED", eventCode, furnitureId)
    latestFurnitureId = Id64ToString(furnitureId)
  end
end

-- EVENT_HOUSING_FURNITURE_PLACED, number eventCode, id64 furnitureId, number collectibleId
function EHA.FurniturePlaced(eventCode, furnitureId, collectibleId)
  if GetHousingEditorMode() ~= HOUSING_EDITOR_MODE_DISABLED then
    -- d("EVENT_HOUSING_FURNITURE_PLACED", eventCode, furnitureId, collectibleId)
    latestFurnitureId = Id64ToString(furnitureId)
  end
end

-- EVENT_HOUSING_FURNITURE_REMOVED, number eventCode, id64 furnitureId, number collectibleId
function EHA.FurnitureRemoved(eventCode, furnitureId, collectibleId)
  -- d("EVENT_HOUSING_FURNITURE_REMOVED", eventCode, furnitureId, collectibleId)
  EHA.removeFurniture(Id64ToString(furnitureId))
end

-- EVENT_HOUSING_PLAYER_INFO_CHANGED, number eventCode, boolean wasOwner, boolean oldCanEdit, HousingVisitorRole oldVisitorRole
function EHA.DebugPlayerInfo(eventCode, wasOwner, oldCanEdit, oldVisitorRole)
  -- d("EVENT_HOUSING_PLAYER_INFO_CHANGED", eventCode, wasOwner, oldCanEdit, oldVisitorRole)
end

function EHA.addToStack()
  EHA.stackFurniture(latestFurnitureId)
end 
  
function EHA.removeFromStack()
  EHA.unstackFurniture()
end 
  
function EHA.OnUpdate() 
  if GetHousingEditorMode() ~= HOUSING_EDITOR_MODE_DISABLED then
    return
  end

  for name, a in pairs( scene ) do    
    if a.plays then 
      EHAAnimation:play(a)
    end
  end
end

function EHA.SlashCommand( commandArgs )
  local options = { }
  local searchResult = { string.match( commandArgs, "^((%S*)%s*)*$" ) }

  for w in commandArgs:gmatch("%S+") do
    options[ #options + 1 ] = string.lower( w )
  end
  
  local animations = {}
  local name = options[2]
  
  if name == "all" then 
    animations = scene
  elseif scene[name] then
    animations[name] = scene[name]
  end
  
  -- Templates commands
  if options[1] == "load"  then EHA.loadTemplates(name) end
  
  -- Stack commands
  if options[1] == "create"  then EHA.animationCreate(name, tonumber(options[3]) or 2) end
  if options[1] == "replace" then EHA.animationReplaceKeyframe(name, tonumber(options[3]) or 1, tonumber(options[4]) or 1) end
  if options[1] == "delete"  then EHA.animationDelete(name) end
  if options[1] == "empty"   then EHA.stackEmpty() end
  
  -- Animation: commands
  if options[1] == "set"     then for n, a in pairs( animations ) do EHAAnimation:setParameter(a, options[3], options[4], options[5]) end end
  if options[1] == "set-force" then for n, a in pairs( animations ) do a[options[3]] = options[4] end end
  if options[1] == "reset"   then for n, a in pairs( animations ) do EHAAnimation:reset(a)  end end
  if options[1] == "play"    then for n, a in pairs( animations ) do EHAAnimation:start(EHA.trigger(a))  end end
  if options[1] == "stop"    then for n, a in pairs( animations ) do EHAAnimation:stop(a)  end end
  if options[1] == "activate"  then for n, a in pairs( animations ) do EHAInteract.activate(a, tonumber((options[3] or "on") ~= "on")) end end
  if options[1] == "actoggle"  then for n, a in pairs( animations ) do EHAInteract.toggle(a) end end
  if options[1] == "toggle"  then for n, a in pairs( animations ) do EHAAnimation:toggle(EHA.trigger(a)) end end
  if options[1] == "list"    then for n, a in pairs( animations ) do d(n, a) end end

  -- Scene commands
  if options[1] == "save"    then EHA.sceneSave() end
  if options[1] == "reload"  then EHA.sceneReload() end
  if options[1] == "clear"   then EHA.sceneClear() end

  if options[1] == "debug"   then EHA.settings.debug = not EHA.settings.debug end

end

function EHA.loadTemplates(name)
  if EHA.templates[name] then
    for n, s in pairs( EHA.templates[name] ) do
      scene[n] = EHAFurniture:deepcopy(s)
      EHA.d("Loading animations " .. n)
    end
    d("Loading animation from template " .. name)
  else
    d("Could not find template " .. name)
  end
end

function EHA.sceneSave()
  EHA.settings.scenes[houseId] = scene
  d("Scene saved")
end

function EHA.sceneReload()
  scene = EHA.settings.scenes[houseId]
  d("Scene reloaded")
end

function EHA.sceneClear()
  scene = {}
  d("Scene cleared")
end

function EHA.stackEmpty()
  furnitures = {}
  d("Furniture stack cleared")
end

function EHA.animationStart(name)
  if(scene[name]) then
    EHAAnimation:start(EHA.trigger(scene[name]))
  end
end


function EHA.animationToggle(name)
  if(scene[name]) then
    EHAAnimation:toggle(EHA.trigger(scene[name]))
  end
end

function EHA.animationDelete(name)
  scene[name] = nil 
  d("Animation: " .. name .. " deleted")
end

function EHA.animationCreate(name, number)
  local fs = {}
  local i = number
  for _, f in ipairs( furnitures ) do
      fs[i] = f
      i = i - 1

      if i < 1 then break end
  end
  local anim = EHAAnimation:new()
  EHAAnimation:addFurnitures(anim, fs)
  EHAAnimation:reset(anim)
  scene[name] = anim
  
  d("Saved animation to " .. name .. " with " .. #fs .. " keyframes")  
end

function EHA.animationReplaceKeyframe(name, number, pos)
  local i = number
  for _, f in ipairs( furnitures ) do
      EHAAnimation:setFurniture(scene[name], pos, f)
      i = i - 1
    pos = pos + 1
      
      if i < 1 then break end
  end
  
  d("Replaced " .. number .. " keyframe in " .. name)  
end

function EHA.stackFurniture(furnitureId) 
  if furnitureId then 
    local fs = {}
    local i = 2
  
    fs[1] = EHAFurniture:new(furnitureId)
  
    for _, f in ipairs( furnitures ) do
      fs[i] = f
      i = i + 1
      
      if i > MAX_STACK then break end
    end
  
    furnitures = fs
  
    d("Stacked 1 furniture, total " .. #furnitures)
  end
end

function EHA.unstackFurniture() 
  local fs = {}
  local i = 2
  local furniture = furnitures[1]
  
  for _, f in ipairs( furnitures ) do
    fs[i - 1] = f
    fs[i] = nil
      i = i + 1
      
      if i > MAX_STACK then break end
  end
  
  d("Unstack 1 furniture, total " .. #furnitures)
  return furniture  
end

function EHA.removeFurniture(furnitureId) 
  local fs = {}
  local i = 1
  
  -- Remove all furniture, keep MAX_STACK
  for _, f in ipairs( furnitures ) do
    if f.id ~= furnitureId then
      fs[i] = f
      i = i + 1
    end
    
    if i > MAX_STACK then break end
  end
  
  furnitures = fs
  
  d("Removed 1 furniture, total " .. #furnitures)
end

-- https://esoitem.uesp.net/viewlog.php?record=collectibles
function EHA.trigger(animation)
  if animation.trigger and animation.trigger ~= 0 then
    EHA.d("Triggerring collectible " .. animation.trigger)
    UseCollectible(animation.trigger)
  end
  
  return animation
end

function EHA.getItemList() 
    local furnitureId = nil

    repeat 
      furnitureId = GetNextPlacedHousingFurnitureId(furnitureId)

      if furnitureId then
        local itemName, icon, furnitureDataId = GetPlacedHousingFurnitureInfo(furnitureId)
        
        if string.match(itemName, "fragment") then 
          EHA.d(itemName .. " found with id " .. Id64ToString(furnitureId))
        end 
      end
      
    until furnitureId == nil
end

function EHA.d(...)
  if EHA.settings.debug then
    d(...)
  end
end

function EHA.init()
  local currentHouseId = GetCurrentZoneHouseId()
  houseId = GetCollectibleIdForHouse(currentHouseId)
  
  if houseId and HasPermissionSettingForCurrentHouse(HOUSE_PERMISSION_SETTING_MOVE_FURNITURE) then 
    scene = EHA.settings.scenes[houseId] or {}
  
    EVENT_MANAGER:RegisterForUpdate(EHA.name, tonumber(EHA.settings.refreshRate) or 100, EHA.OnUpdate)
--  EVENT_MANAGER:RegisterForEvent(EHA.name, EVENT_HOUSING_EDITOR_COMMAND_RESULT, EHA.DebugEditorCommand)
    EVENT_MANAGER:RegisterForEvent(EHA.name, EVENT_HOUSING_EDITOR_LINK_TARGET_CHANGED, EHA.DebugEditorLink)
    EVENT_MANAGER:RegisterForEvent(EHA.name, EVENT_HOUSING_EDITOR_MODE_CHANGED, EHA.DebugEditorMode)
    EVENT_MANAGER:RegisterForEvent(EHA.name, EVENT_HOUSING_EDITOR_REQUEST_RESULT, EHA.DebugEditorRequest)
    EVENT_MANAGER:RegisterForEvent(EHA.name, EVENT_HOUSING_FURNITURE_MOVED, EHA.FurnitureMoved)
    EVENT_MANAGER:RegisterForEvent(EHA.name, EVENT_HOUSING_FURNITURE_PLACED, EHA.FurniturePlaced)
    EVENT_MANAGER:RegisterForEvent(EHA.name, EVENT_HOUSING_FURNITURE_REMOVED, EHA.FurnitureRemoved)
    EVENT_MANAGER:RegisterForEvent(EHA.name, EVENT_HOUSING_PLAYER_INFO_CHANGED, EHA.DebugPlayerInfo)
    EVENT_MANAGER:RegisterForEvent(EHA.name, EVENT_CLIENT_INTERACT_RESULT, EHA.ClientInteractResult)

    EHA.d("Eysile's HousingTools is now active")
  else 
    EVENT_MANAGER:UnregisterForUpdate(EHA.name)
--  EVENT_MANAGER:UnregisterForEvent(EHA.name, EVENT_HOUSING_EDITOR_COMMAND_RESULT)
    EVENT_MANAGER:UnregisterForEvent(EHA.name, EVENT_HOUSING_EDITOR_LINK_TARGET_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EHA.name, EVENT_HOUSING_EDITOR_MODE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EHA.name, EVENT_HOUSING_EDITOR_REQUEST_RESULT)
    EVENT_MANAGER:UnregisterForEvent(EHA.name, EVENT_HOUSING_FURNITURE_MOVED)
    EVENT_MANAGER:UnregisterForEvent(EHA.name, EVENT_HOUSING_FURNITURE_PLACED)
    EVENT_MANAGER:UnregisterForEvent(EHA.name, EVENT_HOUSING_FURNITURE_REMOVED)
    EVENT_MANAGER:UnregisterForEvent(EHA.name, EVENT_HOUSING_PLAYER_INFO_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EHA.name, EVENT_CLIENT_INTERACT_RESULT)

    EVENT_MANAGER:UnregisterForEvent(EHA.name, EVENT_COLLECTIBLE_USE_RESULT)
    EHA.d("Eysile's HousingTools is now Inactive")
  end
end

function EHA:Initialize()
  EHA.settings = ZO_SavedVars:NewAccountWide(EHA.name .. "Variables", EHA.defaultSettings.variableVersion, nil, EHA.defaultSettings)
  
  EHA:CreateAddonMenu()

  SLASH_COMMANDS[ EHA.command ] = EHA.SlashCommand
  
  EVENT_MANAGER:RegisterForEvent(EHA.name, EVENT_PLAYER_ACTIVATED, EHA.init) 
  
  EVENT_MANAGER:UnregisterForEvent(EHA.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(EHA.name, EVENT_ADD_ON_LOADED, EHA.OnAddOnLoaded)
