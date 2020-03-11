local EHA = EysilesHousingAnimator

EHAUI = { 
  prefix = 'ehaui',
  window = nil,
  panelData = {
      type = "panel",
      name = "Window Title",
      displayName = "Longer Window Title",
      author = "Seerah",
      version = "1.3",
      slashCommand = "/myaddon",	--(optional) will register a keybind to open to this panel
      registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
      registerForDefaults = true,	--boolean (optional) (will set all options controls back to default values)
  }
}

EHAUI.optionsTable = {
    [1] = {
        type = "header",
        name = "My Header",
        width = "full",	--or "half" (optional)
    },
    [2] = {
        type = "description",
        --title = "My Title",	--(optional)
        title = nil,	--(optional)
        text = "My description text to display. blah blah blah blah blah blah blah - even more sample text!!",
        width = "full",	--or "half" (optional)
    },
    [3] = {
        type = "dropdown",
        name = "My Dropdown",
        tooltip = "Dropdown's tooltip text.",
        choices = {"table", "of", "choices"},
        getFunc = function() return "of" end,
        setFunc = function(var) print(var) end,
        width = "half",	--or "half" (optional)
        warning = "Will need to reload the UI.",	--(optional)
    },
    [4] = {
        type = "dropdown",
        name = "My Dropdown",
        tooltip = "Dropdown's tooltip text.",
        choices = {"table", "of", "choices"},
        getFunc = function() return "of" end,
        setFunc = function(var) print(var) end,
        width = "half",	--or "half" (optional)
        warning = "Will need to reload the UI.",	--(optional)
    },
    [5] = {
        type = "slider",
        name = "My Slider",
        tooltip = "Slider's tooltip text.",
        min = 0,
        max = 20,
        step = 1,	--(optional)
        getFunc = function() return 3 end,
        setFunc = function(value) d(value) end,
        width = "half",	--or "half" (optional)
        default = 5,	--(optional)
    },
    [6] = {
        type = "button",
        name = "My Button",
        tooltip = "Button's tooltip text.",
        func = function() d("button pressed!") end,
        width = "half",	--or "half" (optional)
        warning = "Will need to reload the UI.",	--(optional)
    },
    [7] = {
        type = "submenu",
        name = "Submenu Title",
        tooltip = "My submenu tooltip",	--(optional)
        controls = {
            [1] = {
                type = "checkbox",
                name = "My Checkbox",
                tooltip = "Checkbox's tooltip text.",
                getFunc = function() return true end,
                setFunc = function(value) d(value) end,
                width = "half",	--or "half" (optional)
                warning = "Will need to reload the UI.",	--(optional)
            },
            [2] = {
                type = "colorpicker",
                name = "My Color Picker",
                tooltip = "Color Picker's tooltip text.",
                getFunc = function() return 1, 0, 0, 1 end,	--(alpha is optional)
                setFunc = function(r,g,b,a) print(r, g, b, a) end,	--(alpha is optional)
                width = "half",	--or "half" (optional)
                warning = "warning text",
            },
            [3] = {
                type = "editbox",
                name = "My Editbox",
                tooltip = "Editbox's tooltip text.",
                getFunc = function() return "this is some text" end,
                setFunc = function(text) print(text) end,
                isMultiline = false,	--boolean
                width = "half",	--or "half" (optional)
                warning = "Will need to reload the UI.",	--(optional)
                default = "",	--(optional)
            },
        },
    },
    [8] = {
        type = "custom",
        reference = "MyAddonCustomControl",	--unique name for your control to use as reference
        refreshFunc = function(customControl) end,	--(optional) function to call when panel/controls refresh
        width = "half",	--or "half" (optional)
    },
    [9] = {
        type = "texture",
        image = "EsoUI\\Art\\ActionBar\\abilityframe64_up.dds",
        imageWidth = 64,	--max of 250 for half width, 510 for full
        imageHeight = 64,	--max of 100
        tooltip = "Image's tooltip text.",	--(optional)
        width = "half",	--or "half" (optional)
    },
}

local LAM = LibStub("LibAddonMenu-2.0")

function EHAUI:CreateWindow()
		EHAUI.window = WINDOW_MANAGER:CreateTopLevelWindow( EHA.name .. "Wnd" )	
		EHAUI.window:SetDimensions( 100, 100 )
		EHAUI.window:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, 50, 50 )
		EHAUI.window:SetMovable( true )
		EHAUI.window:SetMouseEnabled( true )
		EHAUI.window:SetClampedToScreen( true )
		EHAUI.window:SetHidden( false )
end

function EHAUI:CreateAndAnchorWidget(parent, widgetData, offsetX, offsetY, anchorTarget, wasHalf)
  local widget
  local status, err = pcall(function() widget = LAMCreateControl[widgetData.type](parent, widgetData) end)
  if not status then
      return err or true, offsetY, anchorTarget, wasHalf
  else
      local isHalf = (widgetData.width == "half")
      if not anchorTarget then -- the first widget in a panel is just placed in the top left corner
          widget:SetAnchor(TOPLEFT)
          anchorTarget = widget
      elseif wasHalf and isHalf then -- when the previous widget was only half width and this one is too, we place it on the right side
          widget.lineControl = anchorTarget
          isHalf = false
          offsetY = 0
          anchorTarget = TwinOptionsContainer(parent, anchorTarget, widget)
      else -- otherwise we just put it below the previous one normally
          widget:SetAnchor(TOPLEFT, anchorTarget, BOTTOMLEFT, 0, 15)
          offsetY = 0
          anchorTarget = widget
      end
      return false, offsetY, anchorTarget, isHalf
  end
end

-- EHAUI:CreateWindow()
-- EHAUI:InitPanel(EHAUI.window, EHAUI.optionsTable)
function EHAUI:InitPanel(panel, optionsTable)
  
  local THROTTLE_TIMEOUT, THROTTLE_COUNT = 10, 20
  local fifo = {}
  local anchorOffset, lastAddedControl, wasHalf
  local CreateWidgetsInPanel, err

  local function PrepareForNextPanel()
      anchorOffset, lastAddedControl, wasHalf = 0, nil, false
  end

  local function SetupCreationCalls(parent, widgetDataTable)
      fifo[#fifo + 1] = PrepareForNextPanel
      local count = #widgetDataTable
      for i = 1, count, THROTTLE_COUNT do
          fifo[#fifo + 1] = function()
              CreateWidgetsInPanel(parent, widgetDataTable, i, zo_min(i + THROTTLE_COUNT - 1, count))
          end
      end
      return count ~= NonContiguousCount(widgetDataTable)
  end

  CreateWidgetsInPanel = function(parent, widgetDataTable, startIndex, endIndex)
      for i=startIndex,endIndex do
          local widgetData = widgetDataTable[i]
          if not widgetData then
              d("Skipped creation of missing entry in the settings menu of " .. addonID .. ".")
          else
              local widgetType = widgetData.type
              local offsetX = 0
              local isSubmenu = (widgetType == "submenu")
              if isSubmenu then
                  wasHalf = false
                  offsetX = 5
              end

              err, anchorOffset, lastAddedControl, wasHalf = CreateAndAnchorWidget(parent, widgetData, offsetX, anchorOffset, lastAddedControl, wasHalf)
              if err then
                  d(("Could not create %s '%s' of %s."):format(widgetData.type, GetStringFromValue(widgetData.name or "unnamed"), addonID))
                  if logger then
                      logger:Error(err)
                  end
              end

              if isSubmenu then
                  if SetupCreationCalls(lastAddedControl, widgetData.controls) then
                      d(("The sub menu '%s' of %s is missing some entries."):format(GetStringFromValue(widgetData.name or "unnamed"), addonID))
                  end
              end
          end
      end
  end
  
  if SetupCreationCalls(panel, optionsTable) then
    d(("The settings menu of %s is missing some entries."):format(addonID))
  end
        
end

function EHAUI:Debug()
  EHAUI:CreateWindow()
  EHAUI:InitPanel(EHAUI.window, EHAUI.optionsTable)
  EHAUI.window:SetHidden( false )
end
 