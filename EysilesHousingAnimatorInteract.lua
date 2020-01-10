local EHA = EysilesHousingAnimator
EHAInteract = { latestCommandResult = 0}

-- Let's not use real OOP as serializeing them will lead to recursive save
function EHAInteract:new(o)
  local o = o or {}
  local t = { furnitures = {}, commands = {'', '', '', '', '', '', '', '', ''}}
  
  for k, v in pairs(o) do
    t[k] = v
  end
  
  return t
end

function EHAInteract.addFurnitures(t, furnitures)
  for _, f in ipairs(furnitures) do
    t.furnitures[f.id] = f
  end
end

function EHAInteract.setParameter(t, param, value, position)
  if param ~= nil and value ~= nil and t[param] ~= nil then 
    if type(t[param])  == "number" then
      t[param] = tonumber(value)
    elseif type(t[param])  == "boolean" then
      t[param] = value ~= "0"
    elseif type(t[param])  == "table" and position ~= nil then
      EHAInteract.setParameter(t[param], tonumber(position), value)
    elseif type(t[param])  ~= "table" then
      t[param] = value
    end
    
    d("Setting value of " .. param .. " to " .. tostring(t[param]))
    return t[param]
  else 
    d("Cannot set value of " .. tostring(param) .. " to " .. tostring(value))
  end
end

------------------------------------------------------------------------------

function EHA.ClientInteractResult( event, result, targetName )
	if result ~= CLIENT_INTERACT_RESULT_SUCCESS or nil == targetName or "" == targetName then return end

	targetName = ZO_StripGrammarMarkupFromCharacterName( targetName )
  
  -- d('Activated ' .. targetName)
end

function EHAInteract.ClientInteract( event, result, targetName )
  d(GetGameCameraInteractableActionInfo())
end

function EHAInteract.setState(furnitureId, state)
  local prevState = GetPlacedHousingFurnitureCurrentObjectStateIndex( StringToId64(furnitureId) )
  if(prevState == nil or prevState ~= state) then
	  EHA.d("Changing state of " .. furnitureId .. " to " .. tostring(state))
    EHAInteract.latestCommandResult = HousingEditorRequestChangeState( StringToId64(furnitureId), state )
  end
end

function EHAInteract.activate(a, state)
  for furnitureId, f in pairs(a.furnitures) do
    EHAInteract.setState( furnitureId, state )
  end
end

---- tests 

function EHAInteract.activateAll(state)
	local id = GetNextPlacedHousingFurnitureId()
	while id do
		HousingEditorRequestChangeState(id, state)
		id = GetNextPlacedHousingFurnitureId( id )
	end
end

function EHAInteract.toggle(a)
  for furnitureId, f in pairs(a.furnitures) do
    local stateIndex = GetPlacedHousingFurnitureCurrentObjectStateIndex( StringToId64(furnitureId) )

    if nil == stateIndex then return nil end
    local stateName = GetPlacedFurniturePreviewVariationDisplayName( StringToId64(furnitureId), stateIndex + 1 )
  end
end

function EHAInteract.OnUpdate() 
  if GetHousingEditorMode() ~= HOUSING_EDITOR_MODE_DISABLED then
    return
  end

  for name, t in pairs( EHA.interacts ) do
    for furnitureId, f in pairs(t.furnitures) do
      if f.previousState == nil then 
        f.previousState = GetPlacedHousingFurnitureCurrentObjectStateIndex( StringToId64(f.id) )
        EHA.d("Saving primary state")
      else
        local state = GetPlacedHousingFurnitureCurrentObjectStateIndex( StringToId64(f.id) )
        EHAInteract.latestCommandResult = 0
        if f.previousState ~= state then
          if t.commands[state + 1] then
            EHA.d("Trigerring command: " .. t.commands[state + 1])
            EHA.SlashCommand(t.commands[state + 1])
          end
          
          if EHAInteract.latestCommandResult == 0 then 
            f.previousState = state
          else
            EHA.d('Could not set command ' .. t.commands[state + 1] .. ' (Status: ' .. tostring(EHAInteract.latestCommandResult))
          end
        end
      end
    end
  end
end

function EHAInteract.SlashCommand( options )
  local interacts = {}
  local name = options[3]
  
  if name == "all" then 
    interacts = EHA.interacts
  elseif EHA.interacts[name] then
    interacts[name] = EHA.interacts[name]
  end

  -- Trigger commands
  if options[2] == "create"  then EHA.triggerCreate(name, tonumber(options[4]) or 1) end
  if options[2] == "set" then for n, i in pairs( interacts ) do EHAInteract.setParameter(i, options[4], options[5], options[6]) end end
end
