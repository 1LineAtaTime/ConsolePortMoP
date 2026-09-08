---------------------------------------------------------------
-- Lookup.lua: Lookup tables for all intents and purposes
---------------------------------------------------------------
-- Tables/functions in this file are used to get information
-- used when generating settings and game state data.

local addOn, db = ...
---------------------------------------------------------------
local tonumber, ipairs, pairs = tonumber, ipairs, pairs
local spairs, copy = db.table.spairs, db.table.copy
---------------------------------------------------------------
local Controller
---------------------------------------------------------------
function ConsolePort:LoadLookup()
    Controller = db.Controllers[db('type')]
    self.LoadLookup = nil
end
---------------------------------------------------------------
-- Plug-in access to addon table
---------------------------------------------------------------
function ConsolePort:GetData(...) 
    if select('#', ...) > 0 then
        return db(...)
    end
    return db
end

---------------------------------------------------------------
-- Integer keys for UI operations
---------------------------------------------------------------
local KEY, KEY_INV, KEY_TO_BIND, BIND_TO_KEY
---------------------------------------------------------------
db.KEY = {
    CROSS    = 1,
    TRIANGLE = 2,
    CIRCLE   = 3,
    SQUARE   = 4,
    UP       = 5,
    DOWN     = 6,
    LEFT     = 7,
    RIGHT    = 8,
    SHARE    = 9,
    OPTIONS  = 10,
    CENTER   = 11,
    T1       = 12,
    T2       = 13,
    M1       = 14,
    M2       = 15,
    STATE_UP    = 'up',
    STATE_DOWN  = 'down',
}
setmetatable(db.KEY, {__newindex = function() end})
---------------------------------------------------------------
KEY, KEY_INV = db.KEY, db.table.flip(db.KEY)
---------------------------------------------------------------
BIND_TO_KEY = {
    -- Right side
    CP_R_UP     = KEY.TRIANGLE,
    CP_R_DOWN   = KEY.CROSS,
    CP_R_LEFT   = KEY.SQUARE,
    CP_R_RIGHT  = KEY.CIRCLE,
    -- Left side
    CP_L_UP     = KEY.UP,
    CP_L_DOWN   = KEY.DOWN,
    CP_L_LEFT   = KEY.LEFT,
    CP_L_RIGHT  = KEY.RIGHT,
    -- Option buttons
    CP_X_LEFT   = KEY.SHARE,
    CP_X_CENTER = KEY.CENTER,
    CP_X_RIGHT  = KEY.OPTIONS,
    -- Triggers
    CP_T1       = KEY.T1,
    CP_T2       = KEY.T2,
    -- Modifiers
    CP_M1       = KEY.M1,
    CP_M2       = KEY.M2,
}
KEY_TO_BIND = db.table.flip(BIND_TO_KEY)
---------------------------------------------------------------
-- Get the binding/integer key used to perform UI operations
---------------------------------------------------------------
function ConsolePort:IterateUIControlKeys()
    return ipairs(KEY_INV)
end

function ConsolePort:GetUIControlKey(binding)
    return BIND_TO_KEY[binding]
end

function ConsolePort:GetUIControlBinding(key)
    return KEY_TO_BIND[key]
end

function ConsolePort:GetUIControlKeyFromInput(binding)
    local action = GetBindingAction(binding or '')
    return self:GetUIControlKey(action)
end

---------------------------------------------------------------
-- Action IDs and their corresponding binding
---------------------------------------------------------------
local actionIDs = {
	-- Main bar 							-- Second page
	[1] 	= 'ACTIONBUTTON1',				[13] 	= 'ACTIONBUTTON1',
	[2] 	= 'ACTIONBUTTON2',				[14] 	= 'ACTIONBUTTON2',
	[3] 	= 'ACTIONBUTTON3',				[15] 	= 'ACTIONBUTTON3',
	[4] 	= 'ACTIONBUTTON4',				[16] 	= 'ACTIONBUTTON4',
	[5] 	= 'ACTIONBUTTON5',				[17] 	= 'ACTIONBUTTON5',
	[6] 	= 'ACTIONBUTTON6',				[18] 	= 'ACTIONBUTTON6',
	[7] 	= 'ACTIONBUTTON7',				[19] 	= 'ACTIONBUTTON7',
	[8] 	= 'ACTIONBUTTON8',				[20] 	= 'ACTIONBUTTON8',
	[9] 	= 'ACTIONBUTTON9',				[21] 	= 'ACTIONBUTTON9',
	[10] 	= 'ACTIONBUTTON10',				[22] 	= 'ACTIONBUTTON10',
	[11] 	= 'ACTIONBUTTON11',				[23] 	= 'ACTIONBUTTON11',
	[12] 	= 'ACTIONBUTTON12',				[24] 	= 'ACTIONBUTTON12',
	-- Right 								-- Left
	[25] 	= 'MULTIACTIONBAR3BUTTON1',		[37] 	= 'MULTIACTIONBAR4BUTTON1',
	[26] 	= 'MULTIACTIONBAR3BUTTON2',		[38] 	= 'MULTIACTIONBAR4BUTTON2',
	[27] 	= 'MULTIACTIONBAR3BUTTON3',		[39] 	= 'MULTIACTIONBAR4BUTTON3',
	[28] 	= 'MULTIACTIONBAR3BUTTON4',		[40] 	= 'MULTIACTIONBAR4BUTTON4',
	[29] 	= 'MULTIACTIONBAR3BUTTON5',		[41] 	= 'MULTIACTIONBAR4BUTTON5',
	[30] 	= 'MULTIACTIONBAR3BUTTON6',		[42] 	= 'MULTIACTIONBAR4BUTTON6',
	[31] 	= 'MULTIACTIONBAR3BUTTON7',		[43] 	= 'MULTIACTIONBAR4BUTTON7',
	[32] 	= 'MULTIACTIONBAR3BUTTON8',		[44] 	= 'MULTIACTIONBAR4BUTTON8',
	[33] 	= 'MULTIACTIONBAR3BUTTON9',		[45] 	= 'MULTIACTIONBAR4BUTTON9',
	[34] 	= 'MULTIACTIONBAR3BUTTON10',	[46] 	= 'MULTIACTIONBAR4BUTTON10',
	[35] 	= 'MULTIACTIONBAR3BUTTON11',	[47] 	= 'MULTIACTIONBAR4BUTTON11',
	[36] 	= 'MULTIACTIONBAR3BUTTON12',	[48] 	= 'MULTIACTIONBAR4BUTTON12',
	-- Bottom Right 						-- Bottom Left
	[49] 	= 'MULTIACTIONBAR2BUTTON1',		[61] 	= 'MULTIACTIONBAR1BUTTON1',
	[50] 	= 'MULTIACTIONBAR2BUTTON2',		[62] 	= 'MULTIACTIONBAR1BUTTON2',
	[51] 	= 'MULTIACTIONBAR2BUTTON3',		[63] 	= 'MULTIACTIONBAR1BUTTON3',
	[52] 	= 'MULTIACTIONBAR2BUTTON4',		[64] 	= 'MULTIACTIONBAR1BUTTON4',
	[53] 	= 'MULTIACTIONBAR2BUTTON5',		[65] 	= 'MULTIACTIONBAR1BUTTON5',
	[54] 	= 'MULTIACTIONBAR2BUTTON6',		[66] 	= 'MULTIACTIONBAR1BUTTON6',
	[55] 	= 'MULTIACTIONBAR2BUTTON7',		[67] 	= 'MULTIACTIONBAR1BUTTON7',
	[56] 	= 'MULTIACTIONBAR2BUTTON8',		[68] 	= 'MULTIACTIONBAR1BUTTON8',
	[57] 	= 'MULTIACTIONBAR2BUTTON9',		[69] 	= 'MULTIACTIONBAR1BUTTON9',
	[58] 	= 'MULTIACTIONBAR2BUTTON10',	[70] 	= 'MULTIACTIONBAR1BUTTON10',
	[59] 	= 'MULTIACTIONBAR2BUTTON11',	[71] 	= 'MULTIACTIONBAR1BUTTON11',
	[60] 	= 'MULTIACTIONBAR2BUTTON12',	[72] 	= 'MULTIACTIONBAR1BUTTON12',
	-- Bonusbar 7							-- Bonusbar 8
	[73] 	= 'ACTIONBUTTON1',				[85] 	= 'ACTIONBUTTON1',
	[74] 	= 'ACTIONBUTTON2',				[86] 	= 'ACTIONBUTTON2',
	[75] 	= 'ACTIONBUTTON3',				[87] 	= 'ACTIONBUTTON3',
	[76] 	= 'ACTIONBUTTON4',				[88] 	= 'ACTIONBUTTON4',
	[77] 	= 'ACTIONBUTTON5',				[89] 	= 'ACTIONBUTTON5',
	[78] 	= 'ACTIONBUTTON6',				[90] 	= 'ACTIONBUTTON6',
	[79] 	= 'ACTIONBUTTON7',				[91] 	= 'ACTIONBUTTON7',
	[80] 	= 'ACTIONBUTTON8',				[92] 	= 'ACTIONBUTTON8',
	[81] 	= 'ACTIONBUTTON9',				[93] 	= 'ACTIONBUTTON9',
	[82] 	= 'ACTIONBUTTON10',				[94] 	= 'ACTIONBUTTON10',
	[83] 	= 'ACTIONBUTTON11',				[95] 	= 'ACTIONBUTTON11',
	[84] 	= 'ACTIONBUTTON12',				[96] 	= 'ACTIONBUTTON12',
	-- Bonusbar 9 (druid / monk only) 		-- Bonusbar 10 (druid only)
	[97] 	= 'ACTIONBUTTON1',				[109] 	= 'ACTIONBUTTON1',
	[98] 	= 'ACTIONBUTTON2',				[110] 	= 'ACTIONBUTTON2',
	[99] 	= 'ACTIONBUTTON3',				[111] 	= 'ACTIONBUTTON3',
	[100] 	= 'ACTIONBUTTON4',				[112] 	= 'ACTIONBUTTON4',
	[101] 	= 'ACTIONBUTTON5',				[113] 	= 'ACTIONBUTTON5',
	[102] 	= 'ACTIONBUTTON6',				[114] 	= 'ACTIONBUTTON6',
	[103] 	= 'ACTIONBUTTON7',				[115] 	= 'ACTIONBUTTON7',
	[104] 	= 'ACTIONBUTTON8',				[116] 	= 'ACTIONBUTTON8',
	[105] 	= 'ACTIONBUTTON9',				[117] 	= 'ACTIONBUTTON9',
	[106] 	= 'ACTIONBUTTON10',				[118] 	= 'ACTIONBUTTON10',
	[107] 	= 'ACTIONBUTTON11',				[119] 	= 'ACTIONBUTTON11',
	[108] 	= 'ACTIONBUTTON12',				[120] 	= 'ACTIONBUTTON12',

	-- Pages 11-15, read from the live 5.4.8 client rather than guessed:
	--   GetMultiCastBarIndex()        = 11  -> slots 121-132
	--   GetVehicleBarIndex()          = 12  -> slots 133-144
	--   GetTempShapeshiftBarIndex()   = 13  -> slots 145-156
	--   GetOverrideBarIndex()         = 14  -> slots 157-168
	--   GetExtraBarIndex()            = 15  -> slots 169-180
	-- Each page is NUM_ACTIONBAR_BUTTONS (12) slots wide, so page N covers
	-- (N-1)*12+1 .. N*12. Only 133-138 and 169 existed before, which is why
	-- hotkey glyphs disappeared on the totem, vehicle, stance and override
	-- bars -- those slots resolved to nil and were silently dropped.
	-- (The old comment called 133-138 the OverrideBar; it is really the
	--  vehicle bar. The override bar is page 14.)

	-- Multi-cast / totem bar (page 11, shaman)
	[121] 	= 'MULTICASTACTIONBUTTON1',
	[122] 	= 'MULTICASTACTIONBUTTON2',
	[123] 	= 'MULTICASTACTIONBUTTON3',
	[124] 	= 'MULTICASTACTIONBUTTON4',
	[125] 	= 'MULTICASTACTIONBUTTON5',
	[126] 	= 'MULTICASTACTIONBUTTON6',
	[127] 	= 'MULTICASTACTIONBUTTON7',
	[128] 	= 'MULTICASTACTIONBUTTON8',
	[129] 	= 'MULTICASTACTIONBUTTON9',
	[130] 	= 'MULTICASTACTIONBUTTON10',
	[131] 	= 'MULTICASTACTIONBUTTON11',
	[132] 	= 'MULTICASTACTIONBUTTON12',

	-- Vehicle bar (page 12)
	[133] 	= 'ACTIONBUTTON1',
	[134] 	= 'ACTIONBUTTON2',
	[135] 	= 'ACTIONBUTTON3',
	[136] 	= 'ACTIONBUTTON4',
	[137] 	= 'ACTIONBUTTON5',
	[138] 	= 'ACTIONBUTTON6',
	[139] 	= 'ACTIONBUTTON7',
	[140] 	= 'ACTIONBUTTON8',
	[141] 	= 'ACTIONBUTTON9',
	[142] 	= 'ACTIONBUTTON10',
	[143] 	= 'ACTIONBUTTON11',
	[144] 	= 'ACTIONBUTTON12',

	-- Temporary shapeshift bar (page 13)
	[145] 	= 'ACTIONBUTTON1',
	[146] 	= 'ACTIONBUTTON2',
	[147] 	= 'ACTIONBUTTON3',
	[148] 	= 'ACTIONBUTTON4',
	[149] 	= 'ACTIONBUTTON5',
	[150] 	= 'ACTIONBUTTON6',
	[151] 	= 'ACTIONBUTTON7',
	[152] 	= 'ACTIONBUTTON8',
	[153] 	= 'ACTIONBUTTON9',
	[154] 	= 'ACTIONBUTTON10',
	[155] 	= 'ACTIONBUTTON11',
	[156] 	= 'ACTIONBUTTON12',

	-- Override bar (page 14)
	[157] 	= 'ACTIONBUTTON1',
	[158] 	= 'ACTIONBUTTON2',
	[159] 	= 'ACTIONBUTTON3',
	[160] 	= 'ACTIONBUTTON4',
	[161] 	= 'ACTIONBUTTON5',
	[162] 	= 'ACTIONBUTTON6',
	[163] 	= 'ACTIONBUTTON7',
	[164] 	= 'ACTIONBUTTON8',
	[165] 	= 'ACTIONBUTTON9',
	[166] 	= 'ACTIONBUTTON10',
	[167] 	= 'ACTIONBUTTON11',
	[168] 	= 'ACTIONBUTTON12',

	-- Extra action button (page 15)
	[169] 	= 'EXTRAACTIONBUTTON1',

	['StanceButton1']	 	= 'SHAPESHIFTBUTTON1',
	['StanceButton2']	 	= 'SHAPESHIFTBUTTON2',
	['StanceButton3']	 	= 'SHAPESHIFTBUTTON3',
	['StanceButton4']	 	= 'SHAPESHIFTBUTTON4',
	['StanceButton5']	 	= 'SHAPESHIFTBUTTON5',
	['StanceButton6']	 	= 'SHAPESHIFTBUTTON6',
	['StanceButton7']	 	= 'SHAPESHIFTBUTTON7',
	['StanceButton8']	 	= 'SHAPESHIFTBUTTON8',
	['StanceButton9']	 	= 'SHAPESHIFTBUTTON9',
	['StanceButton10']	 	= 'SHAPESHIFTBUTTON10',
	['PetActionButton1']	= 'BONUSACTIONBUTTON1',
	['PetActionButton2']	= 'BONUSACTIONBUTTON2',
	['PetActionButton3']	= 'BONUSACTIONBUTTON3',
	['PetActionButton4']	= 'BONUSACTIONBUTTON4',
	['PetActionButton5']	= 'BONUSACTIONBUTTON5',
	['PetActionButton6']	= 'BONUSACTIONBUTTON6',
	['PetActionButton7']	= 'BONUSACTIONBUTTON7',
	['PetActionButton8']	= 'BONUSACTIONBUTTON8',
	['PetActionButton9']	= 'BONUSACTIONBUTTON9',
	['PetActionButton10']	= 'BONUSACTIONBUTTON10',

}

---------------------------------------------------------------
local class = select(2, UnitClass('player'))
-- action ID thresholds
local classReserved = {
	['WARRIOR'] = 96,
	['ROGUE'] 	= 84,
	['DRUID'] 	= 120,
	['PRIEST'] 	= 84,
	-- MoP: monks page onto bonusbar 1-3 for their stances, so they need the
	-- same treatment as the other stance classes. The entry was simply never
	-- added when the class shipped, so monks fell through to the generic
	-- branch and lost their stance bars entirely.
	['MONK'] 	= 108,
}

---------------------------------------------------------------
local customRange = classReserved[class]
local ACTION_ID_RANGE = 72
local ACTION_ID_STANCE_RANGE = 120
local ACTION_ID_MAX_THRESHOLD = 180 -- was 169; the table now runs to the end of page 15
---------------------------------------------------------------
local DefaultBar = MainMenuBarArtFrame

---------------------------------------------------------------
-- Functions for grabbing action button data
---------------------------------------------------------------
-- Macro conditionals are evaluated C-side, so they appear nowhere in FrameXML and
-- cannot be checked by reading the 5.4.8 UI source -- the only honest test is to
-- ask this client to parse one. A conditional the build does not recognise makes
-- RegisterStateDriver reject the whole driver string, which would silently kill
-- action-bar paging, so probe once and cache.
local supportedConditions = {}
function ConsolePort:IsMacroConditionSupported(condition)
    if supportedConditions[condition] == nil then
        local ok, result = pcall(SecureCmdOptionParse, ('[%s] y; n'):format(condition))
        -- A conditional this client knows parses to 'y' or 'n'. An unknown one
        -- either raises or yields something else; treat both as unsupported.
        supportedConditions[condition] = (ok and (result == 'y' or result == 'n')) and true or false
    end
    return supportedConditions[condition]
end

function ConsolePort:GetActionPageDriver()
    -- generate a macro condition with generic values to ensure any change pushes an update.
    -- the actual bar ID check is done in the pager (Drivers\Pager) instead.
    -- this method seems to work regardless of API changes that cause
    -- some of these macro conditions to shift around on certain specs.
    -- add any new / extra macro conditions to the list below. (as if there aren't enough already)
    local conditionFormat = '[%s] %d; '
    local count, driver = 0, ''
    for i, macroCondition in ipairs({
        ----------------------------------
        -- 'overridebar' and 'possessbar' are Cataclysm additions, so the 3.3.5
        -- backport had to drop them. MoP puts quest/scenario override bars and
        -- mind control behind exactly those two conditions, and neither of them
        -- also sets bonusbar:5 -- without them listed the state never changes,
        -- GetActionPageResponse never runs, and the pager keeps handing out the
        -- player's normal page while an override bar is on screen.
        -- ConsolePort:IsMacroConditionSupported filters the list below, so a
        -- conditional this build does not know is dropped instead of taking the
        -- whole state driver down with it.
        'vehicleui', 'bonusbar:5', 'overridebar', 'possessbar',
        'bar:2', 'bar:3', 'bar:4', 'bar:5', 'bar:6',
        'bonusbar:1', 'bonusbar:2', 'bonusbar:3', 'bonusbar:4'
        ----------------------------------
    }) do
        if ConsolePort:IsMacroConditionSupported(macroCondition) then
            count = count + 1
            driver = driver .. conditionFormat:format(macroCondition, count)
        end
    end
    driver = driver .. (count + 1) -- append the list for the default bar (1) when none of the conditions apply.
    ----------------------------------
    return driver, self:GetActionPage()
end

function ConsolePort:GetActionPageResponse()
    return ([[
        if HasVehicleActionBar and HasVehicleActionBar() then
            newstate = GetVehicleBarIndex()
        elseif HasOverrideActionBar and HasOverrideActionBar() then
            if GetOverrideBarIndex then
                newstate = GetOverrideBarIndex()
            end
        elseif HasTempShapeshiftActionBar and HasTempShapeshiftActionBar() then
            newstate = GetTempShapeshiftBarIndex()
        elseif GetBonusBarOffset() > 0 then
            newstate = GetBonusBarOffset() + %s
        else
            newstate = GetActionBarPage()
        end
        for header in pairs(headers) do
            header:SetAttribute('actionpage', newstate)
            if header:GetAttribute('pageupdate') then
                control:RunFor(header, header:GetAttribute('pageupdate'), newstate)
            end
        end
    ]]):format(NUM_ACTIONBAR_PAGES)
end

function ConsolePort:GetActionPage()
    local newstate
    if db('pagedriver') then
        newstate = SecureCmdOptionParse(db('pagedriver'))
    elseif HasVehicleActionBar and HasVehicleActionBar() then
        newstate = GetVehicleBarIndex()
    elseif HasOverrideActionBar and HasOverrideActionBar() then
        if GetOverrideBarIndex then
            newstate = GetOverrideBarIndex()
        end
    elseif HasTempShapeshiftActionBar and HasTempShapeshiftActionBar() then
        newstate = GetTempShapeshiftBarIndex()
    elseif GetBonusBarOffset() > 0 then
        newstate = GetBonusBarOffset() + NUM_ACTIONBAR_PAGES
    else
        newstate = GetActionBarPage()
    end
    return newstate
end

function ConsolePort:GetOffsetActionID(actionID)
    if actionID <= NUM_ACTIONBAR_BUTTONS then
        local page = self:GetActionPage()
        return ((page-1) * NUM_ACTIONBAR_BUTTONS) + actionID
    else
        return actionID
    end
end

function ConsolePort:GetActionBinding(id)
    local idType = type(id)
    if idType == 'number' then
        -- reserve bars for classes with stances
        if customRange then
            if (id <= customRange or id > ACTION_ID_STANCE_RANGE) then
                return actionIDs[id]
            end
        -- let other classes use bars 7-10 
        elseif (id <= ACTION_ID_RANGE or id > ACTION_ID_STANCE_RANGE) then
            return actionIDs[id]
        end
    elseif idType == 'string' then
        return actionIDs[id]
    end
end

function ConsolePort:GetActionID(bindName)
    if bindName ~= nil then
        for ID=1, ACTION_ID_MAX_THRESHOLD do
            if actionIDs[ID] == bindName then
                return tonumber(ID)
            end
        end
    end
end
function ConsolePort:GetBonusActionID(bindName) -- workaround
	if bindName ~= nil then
		for ID=73, 84 do
			local binding = actionIDs[ID]
			if binding == bindName then
				return tonumber(ID)
			end
		end
	end
end

 
function ConsolePort:GetWBonusActionID(bindName, barId) -- wacky workaround
	local retval
	if bindName ~= nil then
		if(not barId or barId == 1) then
			for ID=73, 84 do
				local binding = actionIDs[ID]
				if binding == bindName then
					retval = tonumber(ID)
				end
			end
		elseif(barId == 2) then
			for ID=85, 96 do
				local binding = actionIDs[ID]
				if binding == bindName then
					retval = tonumber(ID)
				end
			end
		elseif(barId == 3) then
			for ID=97, 108 do
				local binding = actionIDs[ID]
				if binding == bindName then
					retval = tonumber(ID)
				end
			end
		elseif(barId == 4) then
			for ID=109, 120 do
				local binding = actionIDs[ID]
				if binding == bindName then
					retval = tonumber(ID)
				end
			end
		end
	end
	if(not retval) then
		return ConsolePort:GetActionID(bindName)
	end
	return retval
end 

function ConsolePort:GetActionTexture(bindName)
    local ID = self:GetActionID(bindName)
    if ID then
        local actionpage = self:GetActionPage()
        return ID < 73 and GetActionTexture(ID + (actionpage - 1) * 12) or GetActionTexture(ID)
    end
end

---------------------------------------------------------------
-- Get the clean bindings for various uses
---------------------------------------------------------------
function ConsolePort:GetBindings(tbl) return tbl and copy(Controller.Bindings) or spairs(Controller.Bindings) end

---------------------------------------------------------------
-- Default faux binding settings
---------------------------------------------------------------
function ConsolePort:GetDefaultBinding(key) return copy(Controller.Bindings[key]) end

---------------------------------------------------------------
-- Get the currently deployed binding set (can be manipulated)
---------------------------------------------------------------
function ConsolePort:GetCurrentBindings() return copy(self:GetBindingSet()) end

---------------------------------------------------------------
-- Get the button that's currently bound to a defined ID
---------------------------------------------------------------
function ConsolePort:GetCurrentBindingOwner(bindingID, set)
    local set = set or db.Bindings
    if set then
        for key, subSet in pairs(set) do
            for mod, value in pairs(subSet) do
                if value == bindingID then
                    return key, mod
                end
            end
        end
    end
end

function ConsolePort:GetFormattedButtonCombination(key, mod, size, useLargeIcons)
    if key and mod then
        local texture_esc = '|T%s:'..format('%d:%d:0:0|t', size or 24, size or 24)
        local texTable = useLargeIcons and db.TEXTURE or db.ICONS
        local icon = texTable[key]
        if icon then
            local formattedKeys = {
                [''] = format(texture_esc, icon),
                ['SHIFT-'] = format(texture_esc, texTable.CP_M1) .. format(texture_esc, icon),
                ['CTRL-'] = format(texture_esc, texTable.CP_M2) .. format(texture_esc, icon),
                ['CTRL-SHIFT-'] = format(texture_esc, texTable.CP_M1) .. format(texture_esc, texTable.CP_M2) .. format(texture_esc, icon),
            }
            return formattedKeys[mod]
        end
    end
end

function ConsolePort:GetFormattedBindingOwner(bindingID, set, size, useLargeIcons)
    local key, mod = self:GetCurrentBindingOwner(bindingID, set)
    if key and mod then
        return self:GetFormattedButtonCombination(key, mod, size, useLargeIcons)
    end
end

---------------------------------------------------------------
-- Get the modifiers currently used by ConsolePort
---------------------------------------------------------------
local IsShiftKeyDown, IsControlKeyDown = IsShiftKeyDown, IsControlKeyDown
local modifiers = {
    ['']        = function() return ( not IsShiftKeyDown() and not IsControlKeyDown() ) end,
    ['SHIFT-']  = function() return ( IsShiftKeyDown() and not IsControlKeyDown() ) end,
    ['CTRL-']   = function() return ( IsControlKeyDown() and not IsShiftKeyDown() ) end,
    ['CTRL-SHIFT-'] = function() return ( IsShiftKeyDown() and IsControlKeyDown() ) end,
}

function ConsolePort:GetModifiers() return pairs(modifiers) end

function ConsolePort:GetCurrentModifier()
    for modifier, isCurrent in self:GetModifiers() do
        if isCurrent() then
            return modifier
        end
    end
end

---------------------------------------------------------------
-- Binding set / buttons for faux binding system
---------------------------------------------------------------
function ConsolePort:GetDefaultBindingSet()
    local bindingSet = {}
    for button in self:GetBindings() do
        bindingSet[button] = self:GetDefaultBinding(button)
    end
    return bindingSet
end

---------------------------------------------------------------
-- Default addon settings (client wide)
---------------------------------------------------------------
function ConsolePort:GetDefaultAddonSettings(setting)
    local settings = {
        ['type'] = 'PS4',
        ['UIdropDownFix'] = true,
        -------------------------------
        ['CP_M1'] = 'CP_TL1',
        ['CP_M2'] = 'CP_TL2',
        ['CP_T1'] = 'CP_TR1',
        ['CP_T2'] = 'CP_TR2', 
        -------------------------------
        ['actionBarStyle'] = 4,
        -------------------------------
        ['autoExtra'] = true,
        ['autoSellJunk'] = true,
        ['autoInteract'] = false,
        ['disableSmartMouse'] = false,
        ['preventMouseDrift'] = false,
        ['turnCharacter'] = false,
        -------------------------------
        ['mouseOnMove'] = false,
        ['mouseOnJump'] = false,
        -------------------------------
        ['unitHotkeyPool'] = 'player$;party%d$;raid%d+$',
        -------------------------------
    }
    if Controller then
        for key, value in pairs(Controller.Settings) do
            settings[key] = value
        end
    end
    if setting then
        return settings[setting]
    else
        return settings
    end
end

---------------------------------------------------------------
-- Mouse events and default cursor handler
---------------------------------------------------------------
function ConsolePort:GetDefaultMouseEvents()
    return {
        ['PLAYER_STARTED_MOVING'] = true,
        ['PLAYER_TARGET_CHANGED'] = true,
        ['GOSSIP_SHOW'] = true,
        ['GOSSIP_CLOSED'] = true,
        ['MERCHANT_SHOW'] = true,
        ['MERCHANT_CLOSED'] = true,
        ['TAXIMAP_OPENED'] = true,
        ['TAXIMAP_CLOSED'] = true,
        ['QUEST_GREETING'] = true,
        ['QUEST_DETAIL'] = true,
        ['QUEST_PROGRESS'] = true,
        ['QUEST_COMPLETE'] = true,
        ['QUEST_FINISHED'] = true,
        ['QUEST_AUTOCOMPLETE'] = true,
        ['SHIPMENT_CRAFTER_OPENED'] = true,
        ['SHIPMENT_CRAFTER_CLOSED'] = true,
        ['LOOT_OPENED'] = true,
        ['LOOT_CLOSED'] = true,
        ['UNIT_SPELLCAST_SENT'] = true,
        ['UNIT_SPELLCAST_FAILED'] = true,
    }
end

function ConsolePort:GetDefaultMouseCursor()
    return {
        Left    = 'CP_R_DOWN',
        Right   = 'CP_R_RIGHT',
        Special = 'CP_R_UP',
        Scroll  = 'CP_M1',
    }
end

---------------------------------------------------------------
-- Get all hidden customly created convenience bindings 
---------------------------------------------------------------
function ConsolePort:GetCustomBindings()
    local L = db.CUSTOMBINDS
    return {
        -- Mouse bindings
        {name = L.CP_MOUSE},
        {name = L.CAMERAORSELECTORMOVE, binding = 'CAMERAORSELECTORMOVE'},
        {name = L.TURNORACTION, binding = 'TURNORACTION'},
        -- Targeting
        {name = L.CP_TARGETING},
        {name = L.CP_FOCUSCAST, binding = 'CLICK ConsolePortFocusButton:LeftButton'},
        {name = L.CP_EM_FRAMES, binding = 'CLICK ConsolePortEasyMotionButton:LeftButton'},
        {name = L.CP_RAIDCURSOR, binding = 'CLICK ConsolePortRaidCursorToggle:LeftButton'},
        {name = L.CP_RAIDCURSOR_F, binding = 'CLICK ConsolePortRaidCursorFocus:LeftButton'},
        {name = L.CP_RAIDCURSOR_T, binding = 'CLICK ConsolePortRaidCursorTarget:LeftButton'},
        -- Utility
        {name = L.CP_UTILITY},
        {name = L.CP_UTILITYBELT, binding = 'CLICK ConsolePortUtilityToggle:LeftButton'},
        {name = L.CP_PETRING, binding = 'CLICK ConsolePortBarPet:MiddleButton'},
        {name = L.CP_TOGGLEADDON, binding = 'CLICK ConsolePortLoader:LeftButton'}, 
        {name = L.CP_TOTEMFRAME, binding = 'CLICK ConsolePortTotemToggle:LeftButton'},
        -- Pager
        {name = L.CP_PAGER},
        {name = L.CP_PAGE2, binding = 'CLICK ConsolePortPager:2'},
        {name = L.CP_PAGE3, binding = 'CLICK ConsolePortPager:3'},
        {name = L.CP_PAGE4, binding = 'CLICK ConsolePortPager:4'},
        {name = L.CP_PAGE5, binding = 'CLICK ConsolePortPager:5'},
        {name = L.CP_PAGE6, binding = 'CLICK ConsolePortPager:6'},
        -- Camera
        {name = L.CP_CAMERA},
        {name = L.CP_CAMZOOMIN, binding = 'CP_CAMZOOMIN'},
        {name = L.CP_ZOOMIN_HOLD, binding = 'CP_ZOOMIN_HOLD'},
        {name = L.CP_CAMZOOMOUT, binding = 'CP_CAMZOOMOUT'},
        {name = L.CP_ZOOMOUT_HOLD, binding = 'CP_ZOOMOUT_HOLD'},
        {name = L.CP_TOGGLEMOUSE, binding = 'CP_TOGGLEMOUSE'},
        {name = L.CP_CAMLOOKBEHIND, binding = 'CP_CAMLOOKBEHIND'},
    }
end 

function ConsolePort:GetCustomBindingsForRings()
    local L = db.CUSTOMBINDS
    return {
        {name = L.CP_PETRING, binding = 'CLICK ConsolePortBarPet:MiddleButton', texture = [[Interface\Icons\Ability_Hunter_BeastCall]]},
        {name = L.CP_TOTEMFRAME, binding = 'CLICK ConsolePortTotemToggle:LeftButton', texture = [[Interface\AddOns\ConsolePort\Textures\Icons\Totem-Earth]]},
    }
end

---------------------------------------------------------------
-- UI cursor frames to be handled with D-pad
---------------------------------------------------------------
function ConsolePort:GetDefaultUIFrames()
	-- Rebuilt for 5.4.8 (18414). Every name below was verified against Blizzard's
	-- own 5.4.8 UI source; the trailing comment is the file that defines it.
	-- Keys are load-on-demand addon names -- the frame is registered when that
	-- addon fires ADDON_LOADED. Frames that already exist when ConsolePort loads
	-- (FrameXML, plus the Blizzard_* addons flagged LoadOnDemand: 0) live under
	-- the always-loaded 'ConsolePort' key, because their ADDON_LOADED has
	-- already fired by the time we could register for it.
	--
	-- What changed: 21 frames across 5 whole keys were WoD/Legion names that can
	-- never resolve here (Artifact, Collections, Garrison, DeathRecap, Obliterum
	-- and friends); 3 were renamed to their MoP equivalents; 33 MoP panels that
	-- the cursor simply could not reach were added -- Reforging, Item Upgrade,
	-- Black Market, Glyphs, Void Storage, Transmogrify, the PvP and Group Finder
	-- tab panels, the pet/mount journal, and the rest.
	return {
		Blizzard_AchievementUI 		= {
			'AchievementFrame' },				-- Blizzard_AchievementUI.xml
		Blizzard_ArchaeologyUI 		= {
			'ArchaeologyFrame' },				-- Blizzard_ArchaeologyUI.xml
		Blizzard_AuctionUI			= {
			'AuctionFrame' },					-- Blizzard_AuctionUI.xml
		Blizzard_BarbershopUI		= {
			'BarberShopFrame' },				-- Blizzard_BarberShopUI.xml
		Blizzard_BindingUI			= {
			'KeyBindingFrame' },				-- Blizzard_BindingUI.xml
		Blizzard_BlackMarketUI		= {
			'BlackMarketFrame' },				-- Blizzard_BlackMarketUI.xml
		Blizzard_Calendar			= {
			'CalendarFrame' },					-- Blizzard_Calendar.xml
		Blizzard_ChallengesUI		= {
			'ChallengesFrame' },				-- Blizzard_ChallengesUI.xml (was ChallengesKeystoneFrame)
		Blizzard_EncounterJournal	= {
			'EncounterJournal' },				-- Blizzard_EncounterJournal.xml
		Blizzard_GMChatUI			= {
			'GMChatFrame' },					-- Blizzard_GMChatUI.xml
		Blizzard_GMSurveyUI			= {
			'GMSurveyFrame' },					-- Blizzard_GMSurveyUI.xml
		Blizzard_GlyphUI			= {
			'GlyphFrame' },						-- Blizzard_GlyphUI.xml (reparents to its host on show)
		Blizzard_GuildBankUI		= {
			'GuildBankFrame' },					-- Blizzard_GuildBankUI.xml
		Blizzard_GuildControlUI		= {
			'GuildControlUI' },					-- Blizzard_GuildControlUI.xml
		Blizzard_GuildUI			= {
			'GuildFrame' },						-- Blizzard_GuildUI.xml
		Blizzard_InspectUI			= {
			'InspectFrame' },					-- Blizzard_InspectUI.xml
		Blizzard_ItemAlterationUI	= {
			'TransmogrifyFrame' },				-- Blizzard_ItemAlterationUI.xml
		Blizzard_ItemSocketingUI	= {
			'ItemSocketingFrame' },				-- Blizzard_ItemSocketingUI.xml
		Blizzard_ItemUpgradeUI		= {
			'ItemUpgradeFrame' },				-- Blizzard_ItemUpgradeUI.xml
		Blizzard_LookingForGuildUI	= {
			'LookingForGuildFrame' },			-- Blizzard_LookingForGuildUI.xml
		Blizzard_MacroUI			= {
			'MacroFrame' },						-- Blizzard_MacroUI.xml
		Blizzard_PVPUI				= {
			'PVPUIFrame',						-- Blizzard_PVPUI.xml (replaces PVPParentFrame)
			'PVPQueueFrame',					-- Blizzard_PVPUI.xml
			'HonorFrame',						-- Blizzard_PVPUI.xml
			'ConquestFrame',					-- Blizzard_PVPUI.xml
			'WarGamesFrame' },					-- Blizzard_PVPUI.xml
		Blizzard_PetJournal			= {
			'PetJournalParent',					-- Blizzard_PetJournal.xml (tab 1 mounts, tab 2 pets)
			'MountJournal',						-- Blizzard_PetJournal.xml
			'PetJournal' },						-- Blizzard_PetJournal.xml
		Blizzard_QuestChoice		= {
			'QuestChoiceFrame' },				-- Blizzard_QuestChoice.xml
		Blizzard_ReforgingUI		= {
			'ReforgingFrame' },					-- Blizzard_ReforgingUI.xml
		Blizzard_TalentUI			= {
			'PlayerTalentFrame' },				-- Blizzard_TalentUI.xml
		Blizzard_TimeManager		= {
			'TimeManagerFrame',					-- Blizzard_TimeManager.xml (LoadOnDemand)
			'StopwatchFrame' },					-- Blizzard_TimeManager.xml
		Blizzard_TokenUI			= {
			'TokenFrame',						-- Blizzard_TokenUI.xml
			'TokenFramePopup' },				-- Blizzard_TokenUI.xml
		Blizzard_TradeSkillUI		= {
			'TradeSkillFrame' },				-- Blizzard_TradeSkillUI.xml
		Blizzard_TrainerUI			= {
			'ClassTrainerFrame' },				-- Blizzard_TrainerUI.xml
		Blizzard_VoidStorageUI		= {
			'VoidStorageFrame' },				-- Blizzard_VoidStorageUI.xml
		ConsolePort					= {
			'AudioOptionsFrame',				-- AudioOptionsFrame.xml
			'BankFrame',						-- BankFrame.xml
			'BasicScriptErrors',				-- BasicControls.xml
			'CharacterFrame',					-- CharacterFrame.xml
			'ChatConfigFrame',					-- ChatConfigFrame.xml
			'ChatMenu',							-- FloatingChatFrame.xml
			'CoinPickupFrame',					-- CoinPickupFrame.xml
			'CompactRaidFrameManager',			-- Blizzard_CompactRaidFrames (LoadOnDemand: 0)
			'CompactUnitFrameProfiles',			-- Blizzard_CUFProfiles (LoadOnDemand: 0)
			'ContainerFrame1',					-- ContainerFrame.xml
			'ContainerFrame2',
			'ContainerFrame3',
			'ContainerFrame4',
			'ContainerFrame5',
			'ContainerFrame6',
			'ContainerFrame7',
			'ContainerFrame8',
			'ContainerFrame9',
			'ContainerFrame10',
			'ContainerFrame11',
			'ContainerFrame12',
			'ContainerFrame13',
			'DressUpFrame',						-- DressUpFrames.xml
			'DropDownList1',					-- UIDropDownMenu.xml
			'DropDownList2',
			'FlexRaidFrame',					-- FlexRaidFrame.xml
			'FriendsFrame',						-- FriendsFrame.xml
			'GameMenuFrame',					-- GameMenuFrame.xml
			'GossipFrame',						-- GossipFrame.xml
			'GroupFinderFrame',					-- PVEFrame.xml
			'GroupLootFrame1',					-- LootFrame.xml
			'GroupLootFrame2',
			'GroupLootFrame3',
			'GroupLootFrame4',
			'GuildInviteFrame',					-- GuildInviteFrame.xml
			'GuildRegistrarFrame',				-- GuildRegistrarFrame.xml
			'HelpFrame',						-- HelpFrame.xml
			'InterfaceOptionsFrame',			-- InterfaceOptionsFrame.xml
			'ItemRefTooltip',					-- ItemRef.xml
			'ItemTextFrame',					-- ItemTextFrame.xml
			'LFDParentFrame',					-- LFDFrame.xml
			'LFDQueueFrame',					-- LFDFrame.xml
			'LFDRoleCheckPopup',				-- LFDFrame.xml
			'LFGDungeonReadyDialog',			-- LFGFrame.xml
			'LFGInvitePopup',					-- LFGFrame.xml
			'LootFrame',						-- LootFrame.xml
			'LossOfControlFrame',				-- LossOfControlFrame.xml
			'MailFrame',						-- MailFrame.xml
			'MerchantFrame',					-- MerchantFrame.xml
			'OpenMailFrame',					-- MailFrame.xml
			'PVEFrame',							-- PVEFrame.xml
			'PVPReadyDialog',					-- PVPHelper.xml
			'PetBattleFrame',					-- Blizzard_PetBattleUI (LoadOnDemand: 0)
			'PetStableFrame',					-- PetStable.xml
			'PetitionFrame',					-- PetitionFrame.xml
			'QuestFrame',						-- QuestFrame.xml
			'QuestLogDetailFrame',				-- QuestLogFrame.xml (was QuestLogPopupDetailFrame)
			'QuestLogFrame',					-- QuestLogFrame.xml
			'RaidBrowserFrame',					-- LFRFrame.xml
			'RaidFinderFrame',					-- RaidFinder.xml
			'RaidParentFrame',					-- RaidFrame.xml
			'ReadyCheckFrame',					-- ReadyCheck.xml
			'RecruitAFriendFrame',				-- RecruitAFriendFrame.xml
			'ScenarioFinderFrame',				-- ScenarioFinder.xml
			'SpellBookFrame',					-- SpellBookFrame.xml
			'StackSplitFrame',					-- StackSplitFrame.xml
			'StaticPopup1',						-- StaticPopup.xml
			'StaticPopup2',
			'StaticPopup3',
			'StaticPopup4',
			'TabardFrame',						-- TabardFrame.xml
			'TaxiFrame',						-- TaxiFrame.xml
			'TradeFrame',						-- TradeFrame.xml
			'TutorialFrame',					-- TutorialFrame.xml
			'VideoOptionsFrame',				-- VideoOptionsFrame.xml
			-- WatchFrame (MoP's quest tracker) is deliberately NOT registered.
			-- Everything else in this list is a panel that opens and closes, but
			-- the tracker is always visible with points set -- and UIStack.lua does
			--     if widget:IsVisible() and widget:GetPoint() then visible[widget] = true
			-- so registering it leaves the interface cursor permanently convinced a
			-- panel is open. It parks on the quest tracker and swallows A / D-pad,
			-- which is exactly the "cursor stuck on the quest log" symptom.
			'WorldMapFrame',					-- WorldMapFrame.xml
			'WorldStateScoreFrame',				-- WorldStateFrame.xml
		},
	}
end

function ConsolePort:GetDefaultFadeFrames()
    return { 
        ignore = {
            'AlertFrame';
            'ArtifactLevelUpToast';
            'ChatFrame1';
            'CastingBarFrame';
            'GameTooltip';
            'NamePlateTooltip';
            'QuickJoinToastButton';
            'StaticPopup1';
            'StaticPopup2';
            'StaticPopup3';
            'StaticPopup4';
            'SubZoneTextFrame';
            'ShoppingTooltip1';
            'ShoppingTooltip2';
            'OverrideActionBar';
            'UIErrorsFrame';
            'ZoneTextFrame';
            'TalkingHeadFrame';
        };
        force = {
            'ConsolePortBar';
            'MainMenuBar';
            'Minimap';
            'MinimapCluster';
        };
    }
end

------------------------------------------------------------------------------------------------------------
-- Cvar list and getter/setter functions
------------------------------------------------------------------------------------------------------------
local cvars = { -- value = default
    --------------------------------------------------------------------------------------------------------
    actionBarStyle          = {4        ; 'Action button hotkey style for regular action bars (1-5)'};
    allowSaveBindings       = {false    ; 'Allow binding data uploads (overwrites kb/m bindings)'};
    alwaysHighlight         = {0        ; 'Always highlight tab target (0, 1, 2)'};
    autoExtra               = {true     ; 'Automatically bind Qitems to utility ring'};
    autoInteract            = {false    ; 'Automatically moves to and interacts with NPCs (deprecated)'};
    autoLootDefault         = {true     ; 'Force auto-loot in combat'};
    autoSellJunk            = {true     ; 'Automatically sell junk'};
    cursorTrailGhost        = {false    ; 'Show cursor trail ghost'};
    cursorTrailGhostVis     = {.25      ; 'Cursor trail ghost alpha (0-1)'};
    disableCursorTrail      = {false    ; 'Disable Rclick/interact icon trailing cursor'};
    disableCvarReset        = {false    ; 'Disable console variable reset on exit/logout'};
    disableHints            = {false    ; 'Disable hint display on how certain things work'};
    disableSmartBind        = {false    ; 'Disable action/bag placement helper'};
    enablePixelBridge       = {false    ; 'Enable Pixel Bridge (experimental)'};
    enableNameplates        = {false    ; 'Enable Nameplates (requires reload)'};
    disableSmartMouse       = {false    ; 'Disable smart cursor show/hide'};
    disableStickMouse       = {false    ; 'Disable override bindings for stick buttons'};
    doubleModTap            = {true     ; 'Toggle mouselook by double tapping a modifier'};
    doubleModTapWindow      = {.25      ; 'How fast a modifier has to be tapped (seconds)'};
    enableCenterPanels      = {false    ; 'Put large panels in the center of the screen'};
    lookAround              = {false    ; 'Look around on L3 while in mouselook'};
    mouseInvertPitch        = {false    ; 'Invert mouse pitch'};
    mouseOnJump             = {false    ; 'Camera mode on jump'};
    turnCharacter           = {false    ; 'Turn instead of strafe out of mouselook'};
    preventMouseDrift       = {false    ; 'Lock mouse when drifting to screen edge'};
    raidCursorDirect        = {false    ; 'Target directly with raid cursor'};
    skipCalibration         = {false    ; 'Disable calibration check on login'};
    skipGuideBtn            = {false    ; 'Disable calibration check for the center button'};
    --------------------------------------------------------------------------------------------------------
    -- Radial properties:
    stickRadialType         = {0        ; 'Set left stick radial type (0, 1, 2)'};
    stickRadialLocal        = {false    ; 'Set left stick radial to inherit local movement keys'};
    stickRadialBindHorz     = {'H'      ; 'Default axis-dominant binding (horizontal)'};
    stickRadialBindVert     = {'V'      ; 'Default axis-dominant binding (vertical)'};
    utilityRingScale        = {1        ; 'Scale of the utility ring'};
    --------------------------------------------------------------------------------------------------------
    -- Interact button:
    interactNPC             = {false    ; 'Interact with already targeted NPCs'};
    interactCache           = {false    ; 'Cache known GUIDs to retarget when in range'};
    interactScrape          = {false    ; 'Scrape GUIDs from friendly nameplates (requires interactCache true)'};
    interactPushback        = {1        ; 'Pushback after cast to avoid cursor toggle (seconds)'};
    interactHintPosition    = {200      ; 'Interact frame Y-offset from UIParent bottom (px)'};
    interactHintLineVis     = {.5       ; 'Interact frame line texture alpha (0-1)'};
    interactHintNoLine      = {false    ; 'Disable interact frame line texture'};
    interactHintNoSticky    = {false    ; 'Disable nameplate anchoring'};
    interactWith            = {false    ; 'Standard interact button ID'};
    interactCxpWith         = {false    ; 'ConsoleXP interact button ID'};
    --------------------------------------------------------------------------------------------------------
    -- Nameplate scraping properties
    nameplateCC             = {true     ; 'Show class colors on name-only nameplates'};
    nameplateFadeIn         = {0.5      ; 'Fade in timer when using name-only nameplates'};
    nameplateNameOnly       = {false    ; 'Show only names when nameplate interaction is on'};
    nameplateTextScale      = {1        ; 'Scale on other players and minion names'};
    nameplateShowAllEnemies = {false    ; 'Show nameplates for all enemies (OFF: combat only)'};
    --------------------------------------------------------------------------------------------------------
    -- Camera yaw script specs:
    cameraYawDeadzone       = {.8       ; 'Yaw script deadzone (fraction of half of screen width)'};
    cameraYawSmoothOut      = {.085     ; 'Yaw script smooth pan out'};
    cameraYawSmoothIn       = {.155     ; 'Yaw script smooth pan in'};
    cameraYawMaxAngle       = {30       ; 'Max angle to pan before stopping'};
    --------------------------------------------------------------------------------------------------------
    -- Interface cursor:
    disableUI               = {false    ; 'Disable interface cursor'};
    UIleaveCombatDelay      = {.5       ; 'Delay before re-activating UI core after combat'};
    UIholdRepeatDelay       = {.150     ; 'Delay until a D-pad input is repeated (interface)'};
    UIdisableHoldRepeat     = {false    ; 'Disable D-pad input repeater'};
    UIdisableTooltipFix     = {false    ; 'Disable mouse cursor anchor workaround'};
    UIdropDownFix           = {true     ; 'Fix interface cursor on dropdowns'};
    --------------------------------------------------------------------------------------------------------
    -- Mouse on center lock:
    centerLockRangeX        = {70       ; 'Center mouse lock width (px)'};
    centerLockRangeY        = {180      ; 'Center mouse lock height (px)'};
    centerLockDeadzoneX     = {4        ; 'Center mouse lock deadzone width (px)'};
    centerLockDeadzoneY     = {4        ; 'Center mouse lock deadzone height (px)'};
    mouseOnCenter           = {false    ; 'Camera mode when mouseover center of UI'};
    --------------------------------------------------------------------------------------------------------
    -- Unit hotkey specific:
    unitHotkeySize          = {32       ; 'Size of unit hotkeys (px)'};
    unitHotkeyOffsetX       = {0        ; 'Offset X-placement on unit frames (px)'};
    unitHotkeyOffsetY       = {0        ; 'Offset Y-placement on unit frames (px)'};
    unitHotkeyGhostMode     = {false    ; 'Restore calculated combinations after targeting'};
    unitHotkeyIgnorePlayer  = {false    ; 'Always ignore player regardless of pool'};
    --------------------------------------------------------------------------------------------------------
    -- Texture remaps for back buttons:
    CP_M1                   = {'CP_TL1' ; 'Texture ID for modifier 1 (SHIFT)'};
    CP_M2                   = {'CP_TL2' ; 'Texture ID for modifier 2 (CTRL)'};
    CP_T1                   = {'CP_TR1' ; 'Texture ID for trigger 1'};
    CP_T2                   = {'CP_TR2' ; 'Texture ID for trigger 2'};
    --------------------------------------------------------------------------------------------------------
    -- String entries (CAUTION):
    cursorTrailGhostTex     = {[[Interface\CURSOR\Item]]    ; 'Cursor trail ghost texture'};
    exitVehicleBinding      = {'ACTIONBUTTON7'              ; 'Override vehicle exit binding from set'};
    explicitProfile         = {''                           ; 'Explicit profile ID to use for data export'};
    raidCursorModifier      = {''                           ; 'Modifier to combine with D-pad for cursor control'};
    unitHotkeyAnchor        = {'CENTER'                     ; 'Anchor point on unit frames'};
    unitHotkeyPool          = {'player;party%d$;raid%d+$'   ; 'Match criteria for unit hotkey pool, separated by semicolon'};
    unitHotkeySet           = {''                           ; 'Force button set for unit hotkey filtering. Valid: left, right'};
}   --------------------------------------------------------------------------------------------------------

---------------------------------------
-- DB Usage:
--	@set db('[pathto/]cvar', value)
--	@get db('[pathto/]cvar')
---------------------------------------
setmetatable(db, {
    __call = function(self, ...)
        local func = select('#', ...) > 1 and self.Set or self.Get
        return func(self, ...)
    end;
})

local function __cd(root, default, raw)
	local path = {strsplit('/', raw)}
	local depth = #path
	if (depth == 1) then
		return default, raw
	else
		local dest = root
		for i=1, (depth - 1) do
			dest = dest[path[i]]
			if (dest == nil) then
				return
			end
		end
		return dest, path[depth]
	end
end

function db:Set(raw, value)
	local repo, cvar = __cd(self, self.Settings, raw)
	if repo and cvar then
		repo[cvar] = value
		ConsolePort:FireVarCallback(cvar, value)
		return true 
	end
end

function db:Get(raw)
	local repo, cvar = __cd(self, self.Settings, raw)
	if repo and cvar then
		local value = repo[cvar]
		if (value == nil) then
			local cvarDefault = cvars[cvar]
			return cvarDefault and cvarDefault[1]
		end
		return value
	end
end

---------------------------------------

function ConsolePort:RefreshCVars()
    for cvar in pairs(cvars) do
        self:FireVarCallback(cvar, db:Get(cvar))
    end
end

function ConsolePort:GetCompleteCVarList()
    local cvars = copy(cvars)
    for cvar, value in pairs(db.Settings) do
        if type(value) ~= 'table' then
            if cvars[cvar] then
                cvars[cvar][1] = value
            else
                cvars[cvar] = {value}
            end
        end
    end
    return cvars
end