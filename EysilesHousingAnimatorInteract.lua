local EHA = EysilesHousingAnimator

EHAInteract = {}


function EHA.ClientInteractResult( event, result, targetName )

  -- d(event)
  -- d(result)
  -- d(targetName)
  
	if result ~= CLIENT_INTERACT_RESULT_SUCCESS or nil == targetName or "" == targetName then return end

	targetName = ZO_StripGrammarMarkupFromCharacterName( targetName )
  
  -- d('Activated ' .. targetName)
end

function EHAInteract.activate(a, state)
  for furnitureId, f in pairs(a.furnitures) do
    HousingEditorRequestChangeState( StringToId64(furnitureId), state )
  end
end


function EHAInteract.toggle(a)
  for furnitureId, f in pairs(a.furnitures) do
    local stateIndex = GetPlacedHousingFurnitureCurrentObjectStateIndex( StringToId64(furnitureId) )
    if nil == stateIndex then return nil end
    local stateName = GetPlacedFurniturePreviewVariationDisplayName( StringToId64(furnitureId), stateIndex + 1 )
    
    d(stateIndex)
    d(stateName)
    
  end
end
