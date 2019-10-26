local EHA = EysilesHousingAnimator

function EysilesHousingAnimator:CreateAddonMenu()
  local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")

  LAM:RegisterAddonPanel(EHA.name .. "Options", EHA.options)

  local optionsData = {
        [1] = {
            type = "description",
            title = nil,
            text = GetString(EHA_OPTION_DESCRITPION),
            width = "full",
        },
        [2] = {
            type = "header",
            name = "",
            width = "full",
        },
        [3] = {
            type = "slider",
            name = GetString(EHA_OPTION_REFRESH_TIME_DESCRIPTION),
            tooltip = GetString(EHA_OPTION_REFRESH_TIME_TOOLTIP),
            getFunc = function() return EHA.settings.refreshRate or 80 end,
            setFunc = function(value) EHA.settings.refreshRate = tonumber(value) end,
            min = 80, max = 10000, step = 10,
            decimals = 0,
            tooltip = GetString(EHA_OPTION_REFRESH_TIME_WARNING)
        }
	}
  
  LAM:RegisterOptionControls(EHA.name .. "Options", optionsData)  
end
