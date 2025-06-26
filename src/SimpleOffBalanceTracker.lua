SOBT = { name = "SimpleOffBalanceTracker" }

SOBT.defaults = {
	colorR = 0.0,
	colorG = 1.0,
	colorB = 0.0,
	colorA = 1.0,
	colorR_Cooldown = 1.0,
	colorG_Cooldown = 1.0,
	colorB_Cooldown = 0.0,
	colorA_Cooldown = 1.0,
	colorR_Inactive = 1.0,
	colorG_Inactive = 0.0,
	colorB_Inactive = 0.0,
	colorA_Inactive = 1.0,
	inCombatOnly = true,
	selectedText_font = "34",
	selectedFont = "ZoFontGamepad34",
	selectedText_pos = "Top Left",
	selectedPos = 3,
	checked = false,
	offset_x = 0,
	offset_y = 0,
}

function SOBT.onCombat(code, inCombat)
	if inCombat == true then
		if SOBT.savedVariables.inCombatOnly then
			OBIndicator:SetHidden(SOBT.savedVariables.checked)
		end
	else
		if SOBT.savedVariables.inCombatOnly then
			OBIndicator:SetHidden(true)
		end
	end
end

function SOBT.OnUpdate()
	--Off balance: 39077 (7 seconds)
	--Off balance immunity: 134599 (15 seconds)
	
	if DoesUnitExist("reticleover") == true and IsUnitAttackable("reticleover") == true then
		local hasOffBalance = false
		for i=1, GetNumBuffs("reticleover") do
			local _, _, endTime, _, _, _, _, _, _, _, abilityID, _, _ = GetUnitBuffInfo("reticleover", i)
			local timeRemaining = math.floor((endTime-(GetGameTimeMilliseconds()/1000))*10)/10 -- precision to 0.1 seconds
			if abilityID == 39077 or 
				abilityID == 45902 or --OB from blocking charge attack.
				abilityID == 2727 or --Generic off balance
				abilityID == 120014 or --trial dummy off balance
				abilityID == 23808 or --lava whip off balance
				abilityID == 20806 or --molten whip off balance
				abilityID == 34117 or --flame lash off balance
				abilityID == 25256 or --veiled strike
				abilityID == 34733 or --surprise attack
				abilityID ==34737 or --concealed weapon
				abilityID == 130129 or --dive
				abilityID == 130139 or --cutting dive
				abilityID == 130145 or --screaming cliff racer
				abilityID == 125650 or --ruinous scythe
				abilityID == 131562 or --dizzying swing
				abilityID == 62968 or --concussed (wall)
				abilityID == 39077 or --concussed (unstable)
				abilityID == 62988 or --concussed (blockade
				abilityID == 137257 or --roar
				abilityID == 45834 or --ferocious roar
				abilityID == 137312 --deafening roar
			then
				if timeRemaining > 2 then
					timeRemaining = math.floor(timeRemaining)
				end
				OBIndicatorLabel:SetText(timeRemaining)
				OBIndicatorLabel:SetColor(SOBT.savedVariables.colorR, SOBT.savedVariables.colorG, SOBT.savedVariables.colorB)
				OBIndicatorLabel:SetAlpha(SOBT.savedVariables.colorA)
				hasOffBalance = true
				break
			elseif abilityID == 134599 then
				if timeRemaining > 2 then
					timeRemaining = math.floor(timeRemaining)
				end
				OBIndicatorLabel:SetText(timeRemaining)
				OBIndicatorLabel:SetColor(SOBT.savedVariables.colorR_Cooldown, SOBT.savedVariables.colorG_Cooldown, SOBT.savedVariables.colorB_Cooldown)
				OBIndicatorLabel:SetAlpha(SOBT.savedVariables.colorA_Cooldown)
				hasOffBalance = true
				break
			end
		end
		if hasOffBalance == false then
			OBIndicatorLabel:SetText("0")
			OBIndicatorLabel:SetColor(SOBT.savedVariables.colorR_Inactive, SOBT.savedVariables.colorG_Inactive, SOBT.savedVariables.colorB_Inactive)
			OBIndicatorLabel:SetAlpha(SOBT.savedVariables.colorA_Inactive)
		end
	end
end

function SOBT.Initialize()
	--Load and apply saved variables
	SOBT.savedVariables = ZO_SavedVars:NewAccountWide("SOBTSavedVariables", 1, nil, SOBT.defaults, GetWorldName())
	if SOBT.savedVariables.inCombatOnly == false then
		OBIndicator:SetHidden(SOBT.savedVariables.checked)
	elseif IsUnitInCombat("player") then
		OBIndicator:SetHidden(SOBT.savedVariables.checked)
	else
		OBIndicator:SetHidden(true)
	end
	OBIndicatorLabel:SetColor(SOBT.savedVariables.colorR_Inactive, SOBT.savedVariables.colorG_Inactive, SOBT.savedVariables.colorB_Inactive)
	OBIndicatorLabel:SetAlpha(SOBT.savedVariables.colorA_Inactive)
	OBIndicatorLabel:SetFont(SOBT.savedVariables.selectedFont)
	OBIndicator:ClearAnchors()
	OBIndicator:SetAnchor(SOBT.savedVariables.selectedPos, GuiRoot, SOBT.savedVariables.selectedPos, SOBT.savedVariables.offset_x, SOBT.savedVariables.offset_y)
	OBIndicatorLabel:ClearAnchors()
	OBIndicatorLabel:SetAnchor(SOBT.savedVariables.selectedPos, OBIndicator, SOBT.savedVariables.selectedPos, SOBT.savedVariables.offset_x, SOBT.savedVariables.offset_y)
	
	
	--Settings
	local settings = LibHarvensAddonSettings:AddAddon("Simple Off Balance Tracker")
	local areSettingsDisabled = false
	
	local generalSection = {type = LibHarvensAddonSettings.ST_SECTION,label = "General",}
	local textSection = {type = LibHarvensAddonSettings.ST_SECTION,label = "Text",}
	local positionSection = {type = LibHarvensAddonSettings.ST_SECTION,label = "Position",}
	
	local toggle = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Hide Tracker?", 
        tooltip = "Disables the tracker when set to \"On\"",
        default = SOBT.defaults.checked,
        setFunction = function(state) 
            SOBT.savedVariables.checked = state
			OBIndicator:SetHidden(state)
        end,
        getFunction = function() 
            return SOBT.savedVariables.checked
        end,
        disable = function() return areSettingsDisabled end,
    }
	
	local toggle_combat = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Only In Combat", 
        tooltip = "Disables the tracker outside of combat when set to \"On\"",
        default = SOBT.defaults.inCombatOnly,
        setFunction = function(state) 
            SOBT.savedVariables.inCombatOnly = state
			if SOBT.savedVariables.inCombatOnly == false then
				OBIndicator:SetHidden(SOBT.savedVariables.checked)
			elseif IsUnitInCombat("player") then
				OBIndicator:SetHidden(SOBT.savedVariables.checked)
			else
				OBIndicator:SetHidden(true)
			end
        end,
        getFunction = function() 
            return SOBT.savedVariables.inCombatOnly
        end,
        disable = function() return areSettingsDisabled end,
    }
	
	local resetDefaults = {
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Reset Defaults",
        tooltip = "",
        buttonText = "RESET",
        clickHandler = function(control, button)
			SOBT.savedVariables.colorR = SOBT.defaults.colorR
			SOBT.savedVariables.colorG = SOBT.defaults.colorG
			SOBT.savedVariables.colorB = SOBT.defaults.colorB
			SOBT.savedVariables.colorA = SOBT.defaults.colorA
			SOBT.savedVariables.colorR_Cooldown = SOBT.defaults.colorR_Cooldown
			SOBT.savedVariables.colorG_Cooldown = SOBT.defaults.colorG_Cooldown
			SOBT.savedVariables.colorB_Cooldown = SOBT.defaults.colorB_Cooldown
			SOBT.savedVariables.colorA_Cooldown = SOBT.defaults.colorA_Cooldown
			SOBT.savedVariables.selectedText_font = SOBT.defaults.selectedText_font
			SOBT.savedVariables.selectedFont = SOBT.defaults.selectedFont
			SOBT.savedVariables.selectedText_pos = SOBT.defaults.selectedText_pos
			SOBT.savedVariables.selectedPos = SOBT.defaults.selectedPos
			SOBT.savedVariables.checked = SOBT.defaults.checked
			SOBT.savedVariables.inCombatOnly = SOBT.defaults.inCombatOnly
			SOBT.savedVariables.offset_x = SOBT.defaults.offset_x
			SOBT.savedVariables.offset_y = SOBT.defaults.offset_y
			
			if SOBT.savedVariables.inCombatOnly == false then
				OBIndicator:SetHidden(SOBT.savedVariables.checked)
			elseif IsUnitInCombat("player") then
				OBIndicator:SetHidden(SOBT.savedVariables.checked)
			else
				OBIndicator:SetHidden(true)
			end
			
			OBIndicatorLabel:SetColor(SOBT.savedVariables.colorR, SOBT.savedVariables.colorG, SOBT.savedVariables.colorB)
			OBIndicatorLabel:SetAlpha(SOBT.savedVariables.colorA)
			OBIndicatorLabel:SetFont(SOBT.savedVariables.selectedFont)
			
			OBIndicator:ClearAnchors()
			OBIndicator:SetAnchor(SOBT.savedVariables.selectedPos, GuiRoot, SOBT.savedVariables.selectedPos, SOBT.savedVariables.offset_x, SOBT.savedVariables.offset_y)
			OBIndicatorLabel:ClearAnchors()
			OBIndicatorLabel:SetAnchor(SOBT.savedVariables.selectedPos, OBIndicator, SOBT.savedVariables.selectedPos, SOBT.savedVariables.offset_x, SOBT.savedVariables.offset_y)
		end,
        disable = function() return areSettingsDisabled end,
    }
	
    local color = {
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Active Color",
        tooltip = "Change the color of the text for when off balance is active.",
        setFunction = function(...) --newR, newG, newB, newA
            SOBT.savedVariables.colorR, SOBT.savedVariables.colorG, SOBT.savedVariables.colorB, SOBT.savedVariables.colorA = ...
			OBIndicatorLabel:SetColor(SOBT.savedVariables.colorR, SOBT.savedVariables.colorG, SOBT.savedVariables.colorB)
			OBIndicatorLabel:SetAlpha(SOBT.savedVariables.colorA)
        end,
        default = {SOBT.defaults.colorR, SOBT.defaults.colorG, SOBT.defaults.colorB, SOBT.defaults.colorA},
        getFunction = function()
            return SOBT.savedVariables.colorR, SOBT.savedVariables.colorG, SOBT.savedVariables.colorB, SOBT.savedVariables.colorA
        end,
        disable = function() return areSettingsDisabled end,
    }
	
	 local color_Cooldown = {
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Cooldown Color",
        tooltip = "Change the color of the text for when off balance is on cooldown.",
        setFunction = function(...) --newR, newG, newB, newA
            SOBT.savedVariables.colorR_Cooldown, SOBT.savedVariables.colorG_Cooldown, SOBT.savedVariables.colorB_Cooldown, SOBT.savedVariables.colorA_Cooldown = ...
			OBIndicatorLabel:SetColor(SOBT.savedVariables.colorR_Cooldown, SOBT.savedVariables.colorG_Cooldown, SOBT.savedVariables.colorB_Cooldown)
			OBIndicatorLabel:SetAlpha(SOBT.savedVariables.colorA_Cooldown)
        end,
        default = {SOBT.defaults.colorR_Cooldown, SOBT.defaults.colorG_Cooldown, SOBT.defaults.colorB_Cooldown, SOBT.defaults.colorA_Cooldown},
        getFunction = function()
            return SOBT.savedVariables.colorR_Cooldown, SOBT.savedVariables.colorG_Cooldown, SOBT.savedVariables.colorB_Cooldown, SOBT.savedVariables.colorA_Cooldown
        end,
        disable = function() return areSettingsDisabled end,
    }
	
	local color_Inactive = {
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Inactive Color",
        tooltip = "Change the text color of the text for when off balance is neither active nor on cooldown.",
        setFunction = function(...) --newR, newG, newB, newA
            SOBT.savedVariables.colorR_Inactive, SOBT.savedVariables.colorG_Inactive, SOBT.savedVariables.colorB_Inactive, SOBT.savedVariables.colorA_Inactive= ...
			OBIndicatorLabel:SetColor(SOBT.savedVariables.colorR_Inactive, SOBT.savedVariables.colorG_Inactive, SOBT.savedVariables.colorB_Inactive)
			OBIndicatorLabel:SetAlpha(SOBT.savedVariables.colorA_Inactive)
        end,
        default = {SOBT.defaults.colorR_Inactive, SOBT.defaults.colorG_Inactive, SOBT.defaults.colorB_Inactive, SOBT.defaults.colorA_Inactive},
        getFunction = function()
            return SOBT.savedVariables.colorR_Inactive, SOBT.savedVariables.colorG_Inactive, SOBT.savedVariables.colorB_Inactive, SOBT.savedVariables.colorA_Inactive
        end,
        disable = function() return areSettingsDisabled end,
    }
	
    local dropdown_font = {
        type = LibHarvensAddonSettings.ST_DROPDOWN,
        label = "Font Size",
        tooltip = "Change the size of the tracker.",
        setFunction = function(combobox, name, item)
			OBIndicatorLabel:SetFont(item.data)
			SOBT.savedVariables.selectedText_font = name
			SOBT.savedVariables.selectedFont = item.data
        end,
        getFunction = function()
            return SOBT.savedVariables.selectedText_font
        end,
        default = SOBT.defaults.selectedText_font,
        items = {
            {
                name = "18",
                data = "ZoFontGamepad18"
            },
            {
                name = "20",
                data = "ZoFontGamepad20"
            },
            {
                name = "22",
                data = "ZoFontGamepad22"
            },
            {
                name = "25",
                data = "ZoFontGamepad25"
            },
            {
                name = "34",
                data = "ZoFontGamepad34"
            },
            {
                name = "36",
                data = "ZoFontGamepad36"
            },
            {
                name = "42",
                data = "ZoFontGamepad42"
            },
            {
                name = "54",
                data = "ZoFontGamepad54"
            },
            {
                name = "61",
                data = "ZoFontGamepad61"
            },
        },
        disable = function() return areSettingsDisabled end,
    }
	
    local dropdown_pos = {
        type = LibHarvensAddonSettings.ST_DROPDOWN,
        label = "Tracker Position",
        tooltip = "",
        setFunction = function(combobox, name, item)
			SOBT.savedVariables.selectedText_pos = name
			SOBT.savedVariables.selectedPos = item.data
			
			OBIndicator:ClearAnchors()
			OBIndicator:SetAnchor(SOBT.savedVariables.selectedPos, GuiRoot, SOBT.savedVariables.selectedPos, SOBT.savedVariables.offset_x, SOBT.savedVariables.offset_y)
			OBIndicatorLabel:ClearAnchors()
			OBIndicatorLabel:SetAnchor(SOBT.savedVariables.selectedPos, OBIndicator, SOBT.savedVariables.selectedPos, SOBT.savedVariables.offset_x, SOBT.savedVariables.offset_y)
        end,
        getFunction = function()
            return SOBT.savedVariables.selectedText_pos
        end,
        default = SOBT.defaults.selectedText_pos,
        items = {
            {
                name = "Top Left",
                data = 3
            },
			{
                name = "Top",
                data = 1
            },
            {
                name = "Top Right",
                data = 9
            },
			{
                name = "Left",
                data = 2
            },
			{
                name = "Center",
                data = 128
            },
			{
                name = "Right",
                data = 8
            },
			{
                name = "Bottom Left",
                data = 6
            },
			{
                name = "Bottom",
                data = 4
            },
			{
                name = "Bottom Right",
                data = 12
            },
        },
        disable = function() return areSettingsDisabled end,
    }
	
	--x position offset
	local slider_x = {
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "X Offset",
        tooltip = "",
        setFunction = function(value)
			SOBT.savedVariables.offset_x = value
			
			OBIndicator:ClearAnchors()
			OBIndicator:SetAnchor(SOBT.savedVariables.selectedPos, GuiRoot, SOBT.savedVariables.selectedPos, SOBT.savedVariables.offset_x, SOBT.savedVariables.offset_y)
			OBIndicatorLabel:ClearAnchors()
			OBIndicatorLabel:SetAnchor(SOBT.savedVariables.selectedPos, OBIndicator, SOBT.savedVariables.selectedPos, SOBT.savedVariables.offset_x, SOBT.savedVariables.offset_y)
        end,
        getFunction = function()
            return SOBT.savedVariables.offset_x
        end,
        default = 0,
        min = -750,
        max = 750,
        step = 5,
        unit = "", --optional unit
        format = "%d", --value format
        disable = function() return areSettingsDisabled end,
    }
	
	--y position offset
	local slider_y = {
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Y Offset",
        tooltip = "",
        setFunction = function(value)
			SOBT.savedVariables.offset_y = value
			
			OBIndicator:ClearAnchors()
			OBIndicator:SetAnchor(SOBT.savedVariables.selectedPos, GuiRoot, SOBT.savedVariables.selectedPos, SOBT.savedVariables.offset_x, SOBT.savedVariables.offset_y)
			OBIndicatorLabel:ClearAnchors()
			OBIndicatorLabel:SetAnchor(SOBT.savedVariables.selectedPos, OBIndicator, SOBT.savedVariables.selectedPos, SOBT.savedVariables.offset_x, SOBT.savedVariables.offset_y)
        end,
        getFunction = function()
            return SOBT.savedVariables.offset_y
        end,
        default = 0,
        min = -750,
        max = 750,
        step = 5,
        unit = "", --optional unit
        format = "%d", --value format
        disable = function() return areSettingsDisabled end,
    }
	
	settings:AddSettings({generalSection, toggle, toggle_combat, resetDefaults})
	settings:AddSettings({textSection, dropdown_font, color, color_Cooldown, color_Inactive})
	settings:AddSettings({positionSection, dropdown_pos, slider_x, slider_y})
	
	EVENT_MANAGER:RegisterForUpdate(SOBT.name, 100, SOBT.OnUpdate)
	EVENT_MANAGER:RegisterForEvent(SOBT.name, EVENT_PLAYER_COMBAT_STATE, SOBT.onCombat)
end

function SOBT.OnAddOnLoaded(event, addonName)
	if addonName == SOBT.name then
		SOBT.Initialize()
		EVENT_MANAGER:UnregisterForEvent(SOBT.name, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(SOBT.name, EVENT_ADD_ON_LOADED, SOBT.OnAddOnLoaded)