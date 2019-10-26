local strings = {
	SI_BINDING_NAME_EysilesHousingAnimator_KEY_ADD_STACK = "Add the latest moved item to the stack",
	SI_BINDING_NAME_EysilesHousingAnimator_KEY_REMOVE_STACK = "Remove the latest object piled on the stack",
  EHA_OPTION_DESCRITPION = "Eysile's HousingTools",
  EHA_OPTION_REFRESH_TIME_DESCRIPTION = "Refresh rate",
  EHA_OPTION_REFRESH_TIME_TOOLTIP = "Time between each frame of the animation (in ms)",
  EHA_OPTION_REFRESH_TIME_WARNING = "Setting this time to a low value may kick you out of the game"
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
