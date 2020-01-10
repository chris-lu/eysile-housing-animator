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
    furnitures = {},
    animations = {},
    interacts = {},
    
    defaultSettings = {
      refreshRate = 100,
      animations = {},
      interacts = {},
      backup = {},
      variableVersion = 1,
      debug = false,
    }
}

-- Local references to important objects
local EHA = EysilesHousingAnimator
local MAX_STACK = 50
local houseId = 0
local latestFurnitureId = nil
local latestCollectible = nil


function EHA.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[EHA.deepcopy(orig_key)] = EHA.deepcopy(orig_value)
        end
        setmetatable(copy, EHA.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

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
  
function EHA.SlashCommand( commandArgs )
  local options = { }

  for w in commandArgs:gmatch("%S+") do
    options[ #options + 1 ] = string.gsub(string.lower( w ), '+', ' ')
  end

  -- Scene commands
  if options[1] == "save"    then EHA.sceneSave() end
  if options[1] == "reload"  then EHA.sceneReload() end
  if options[1] == "clear"   then EHA.sceneClear() end
  if options[1] == "empty"   then EHA.stackEmpty() end

  if options[1] == "debug"   then EHA.settings.debug = not EHA.settings.debug end
  
  -- Templates commands
  if options[1] == "load"  then EHA.loadTemplates(options[2]) end

  if options[1] == "animation" or options[1] == "a"  then EHAAnimation.SlashCommand( options ) end
  if options[1] == "trigger" or options[1] == "t"  then EHAInteract.SlashCommand( options ) end
end

function EHA.loadTemplates(name)
  if EHA.templates[name] then
    for n, s in pairs( EHA.templates[name].animations ) do
      EHA.animations[n] = EHA.deepcopy(s)
      EHA.d("Loading animation " .. n)
    end
    for n, s in pairs( EHA.templates[name].interacts ) do
      EHA.interacts[n] = EHA.deepcopy(s)
      EHA.d("Loading trigger " .. n)
    end
    d("Loading animation from template " .. name)
  else
    d("Could not find template " .. name)
  end
end

function EHA.sceneSave()
  EHA.settings.animations[houseId] = EHA.animations
  EHA.settings.interacts[houseId] = EHA.interacts
  d("Scene saved")
end

function EHA.sceneReload()
  EHA.animations = EHA.settings.animations[houseId]
  EHA.interacts = EHA.settings.interacts[houseId]
  d("Scene reloaded")
end

function EHA.sceneClear()
  EHA.animations = {}
  EHA.interacts = {}
  d("Scene cleared")
end

function EHA.stackEmpty()
  EHA.furnitures = {}
  d("Furniture stack cleared")
end

function EHA.stackFurniture(furnitureId) 
  if furnitureId then 
    local fs = {}
    local i = 2
  
    fs[1] = EHAFurniture:new(furnitureId)
  
    for _, f in ipairs( EHA.furnitures ) do
      fs[i] = f
      i = i + 1
      
      if i > MAX_STACK then break end
    end
  
    EHA.furnitures = fs
  
    d("Stacked 1 furniture, total " .. #EHA.furnitures)
  end
end

function EHA.unstackFurniture() 
  local fs = {}
  local i = 2
  local furniture = EHA.furnitures[1]
  
  for _, f in ipairs( EHA.furnitures ) do
    fs[i - 1] = f
    fs[i] = nil
      i = i + 1
      
      if i > MAX_STACK then break end
  end
  
  d("Unstack 1 furniture, total " .. #EHA.furnitures)
  return furniture  
end

function EHA.removeFurniture(furnitureId) 
  local fs = {}
  local i = 1
  
  -- Remove all furniture, keep MAX_STACK
  for _, f in ipairs( EHA.furnitures ) do
    if f.id ~= furnitureId then
      fs[i] = f
      i = i + 1
    end
    
    if i > MAX_STACK then break end
  end
  
  EHA.furnitures = fs
  
  d("Removed 1 furniture, total " .. #EHA.furnitures)
end

function EHA.triggerCreate(name, number)
  local fs = {}
  local i = number
  for _, f in ipairs( EHA.furnitures ) do
      fs[i] = f
      i = i - 1

      if i < 1 then break end
  end
  local trigger = EHATrigger:new()
  EHATrigger.addFurnitures(trigger, fs)
  EHA.interacts[name] = trigger
  
  d("Saved trigger to " .. name .. " with " .. #fs .. " keyframes")  
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
    EHA.animations = EHA.settings.animations[houseId] or {}
    EHA.interacts = EHA.settings.interacts[houseId] or {}
  
    EVENT_MANAGER:RegisterForUpdate(EHA.name .. 'Animations', tonumber(EHA.settings.refreshRate) or 100, EHAAnimation.OnUpdate)
    EVENT_MANAGER:RegisterForUpdate(EHA.name .. 'Interact', tonumber(EHA.settings.refreshRate) or 100, EHAInteract.OnUpdate)
    EVENT_MANAGER:RegisterForEvent(EHA.name, EVENT_HOUSING_EDITOR_LINK_TARGET_CHANGED, EHA.DebugEditorLink)
    EVENT_MANAGER:RegisterForEvent(EHA.name, EVENT_HOUSING_EDITOR_MODE_CHANGED, EHA.DebugEditorMode)
    EVENT_MANAGER:RegisterForEvent(EHA.name, EVENT_HOUSING_EDITOR_REQUEST_RESULT, EHA.DebugEditorRequest)
    EVENT_MANAGER:RegisterForEvent(EHA.name, EVENT_HOUSING_FURNITURE_MOVED, EHA.FurnitureMoved)
    EVENT_MANAGER:RegisterForEvent(EHA.name, EVENT_HOUSING_FURNITURE_PLACED, EHA.FurniturePlaced)
    EVENT_MANAGER:RegisterForEvent(EHA.name, EVENT_HOUSING_FURNITURE_REMOVED, EHA.FurnitureRemoved)
    EVENT_MANAGER:RegisterForEvent(EHA.name, EVENT_HOUSING_PLAYER_INFO_CHANGED, EHA.DebugPlayerInfo)
    EVENT_MANAGER:RegisterForEvent(EHA.name, EVENT_IMPACTFUL_HIT, function(event, ...) d('EVENT_IMPACTFUL_HIT') end)
--  EVENT_MANAGER:RegisterForEvent(EHA.name, EVENT_NO_INTERACT_TARGET, function(event, ...) d('EVENT_NO_INTERACT_TARGET') end)
--  EVENT_MANAGER:RegisterForEvent(EHA.name, EVENT_HOUSING_EDITOR_COMMAND_RESULT, EHA.DebugEditorCommand)
--  EVENT_MANAGER:RegisterForEvent(EHA.name, EVENT_CLIENT_INTERACT_RESULT, EHA.ClientInteractResult)
--  EVENT_MANAGER:RegisterForEvent(EHA.name, EVENT_COLLECTIBLE_USE_RESULT, EHA.CollectibleUseResult)
    EHA.d("Eysile's HousingTools is now active")
  else 
    EVENT_MANAGER:UnregisterForUpdate(EHA.name)
    EVENT_MANAGER:UnregisterForEvent(EHA.name, EVENT_HOUSING_EDITOR_LINK_TARGET_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EHA.name, EVENT_HOUSING_EDITOR_MODE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EHA.name, EVENT_HOUSING_EDITOR_REQUEST_RESULT)
    EVENT_MANAGER:UnregisterForEvent(EHA.name, EVENT_HOUSING_FURNITURE_MOVED)
    EVENT_MANAGER:UnregisterForEvent(EHA.name, EVENT_HOUSING_FURNITURE_PLACED)
    EVENT_MANAGER:UnregisterForEvent(EHA.name, EVENT_HOUSING_FURNITURE_REMOVED)
    EVENT_MANAGER:UnregisterForEvent(EHA.name, EVENT_HOUSING_PLAYER_INFO_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EHA.name, EVENT_IMPACTFUL_HIT)
--  EVENT_MANAGER:UnregisterForEvent(EHA.name, EVENT_NO_INTERACT_TARGET)
--  EVENT_MANAGER:UnregisterForEvent(EHA.name, EVENT_CLIENT_INTERACT_RESULT)
--  EVENT_MANAGER:UnregisterForEvent(EHA.name, EVENT_HOUSING_EDITOR_COMMAND_RESULT)
--  EVENT_MANAGER:UnregisterForEvent(EHA.name, EVENT_COLLECTIBLE_USE_RESULT)
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
