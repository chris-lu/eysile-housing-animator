local EHA = EysilesHousingAnimator
local EHACurrentId = nil
local EHAPlacedFurnitures = {}

EHAInteract = {}


function EHA.ClientInteractResult( event, result, targetName )
	if result ~= CLIENT_INTERACT_RESULT_SUCCESS or nil == targetName or "" == targetName then return end

	targetName = ZO_StripGrammarMarkupFromCharacterName( targetName )
  
  -- d('Activated ' .. targetName)
end

function EHAInteract.setState(furnitureId, state)
  local prevState = GetPlacedHousingFurnitureCurrentObjectStateIndex( StringToId64(furnitureId) )
  if(prevState == nil or prevState ~= state) then
	EHA.d("Changing state of " .. furnitureId .. " to " .. tostring(state))
    HousingEditorRequestChangeState( StringToId64(furnitureId), state )
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

