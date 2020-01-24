local EHA = EysilesHousingAnimator
EHAInteract = { callbacks = {} }

-- Let's not use real OOP as serializeing them will lead to recursive save
function EHAInteract:new(o)
  local o = o or {}
  local t = { furnitures = {}, run = {'', '', '', '', '', '', '', '', ''}}
  
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

function EHAInteract.triggerCreate(name, number)
  local fs = {}
  local i = number
  for _, f in ipairs( EHA.furnitures ) do
      fs[i] = f
      i = i - 1

      if i < 1 then break end
  end
  local trigger = EHAInteract:new()
  EHAInteract.addFurnitures(trigger, fs)
  EHA.interacts[name] = trigger
  
  d("Saved trigger to " .. name .. " with " .. #fs .. " keyframes")  
end

------------------------------------------------------------------------------

function EHAInteract.ClientInteractResult( event, result, targetName )
	if result ~= CLIENT_INTERACT_RESULT_SUCCESS or nil == targetName or "" == targetName then return end

	targetName = ZO_StripGrammarMarkupFromCharacterName( targetName )
  
  -- d('Activated ' .. targetName)
end

function EHAInteract.ClientInteract( event, result, targetName )
  d(GetGameCameraInteractableActionInfo())
end

function EHAInteract.setState(furnitureId, state, try)
  local prevState = GetPlacedHousingFurnitureCurrentObjectStateIndex( StringToId64(furnitureId) )
  if prevState == nil or prevState ~= state then
    local resultCode = HousingEditorRequestChangeState( StringToId64(furnitureId), state )
    if resultCode == HOUSING_REQUEST_RESULT_SET_STATE_FAILED then 
      try = (try or 0) + 1
      if try < 50 then
        EHA.d('Could not set state of object ' .. furnitureId .. ', try ' .. tostring(try))
        EHAInteract.callbacks[furnitureId] = function() 
          EHAInteract.setState(furnitureId, state, try)
        end
      end
    else
      EHA.d("Changing state of " .. furnitureId .. " to " .. tostring(state))
    end
  end
end

function EHAInteract.activate(a, state)
  for furnitureId, f in pairs(a.furnitures) do
    EHAInteract.callbacks[furnitureId] = function() 
      EHAInteract.setState(furnitureId, state)
    end
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
    -- If multiple, all states should be saved state to trigger the action
    local count = 0
    for furnitureId, f in pairs(t.furnitures) do
      count = count + 1 
    end

    if count > 1 then
      EHAInteract.handleMultiple(t)
    else
      EHAInteract.handleSingle(t) 
    end
  end

  for id, t in pairs( EHAInteract.callbacks ) do
    local fnc = t
    EHAInteract.callbacks[id] = nil
    fnc();
  end
end

function EHAInteract.handleSingle(t) 
  for furnitureId, f in pairs(t.furnitures) do
    if f.previousState == nil then 
      f.previousState = GetPlacedHousingFurnitureCurrentObjectStateIndex( StringToId64(f.id) )
      EHA.d("Saving primary state")
    else
      local state = GetPlacedHousingFurnitureCurrentObjectStateIndex( StringToId64(f.id) )
      if f.previousState ~= state then
        if t.run[state + 1] then
          EHA.d("Trigerring command from: " .. t.run[state + 1])
          EHA.SlashCommand(t.run[state + 1])
        end

        f.previousState = state
      end
    end
  end
end

function EHAInteract.handleMultiple(t) 
  local correct = true

  for furnitureId, f in pairs(t.furnitures) do
    local state = GetPlacedHousingFurnitureCurrentObjectStateIndex( StringToId64(f.id) )
    correct = correct and (f.state == state)
  end

  if t.previousState == nil then
    t.previousState = correct
    EHA.d("Saving primary state")
  end

  if correct ~= t.previousState then
    local command = 1
    if correct then
      command = 2
    end

    if t.run[command] then
      EHA.d("Trigerring command from multiple: " .. tostring(t.run[command]))
      EHA.SlashCommand(t.run[command])
    end

    t.previousState = correct
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
  if options[2] == "create"  then EHAInteract.triggerCreate(name, tonumber(options[4]) or 1) end
  if options[2] == "set" then for n, i in pairs( interacts ) do EHAInteract.setParameter(i, options[4], options[5], options[6]) end end
end
