-- This was mostly stolen from Bartender4.
-- This code snippet hides and modifies the default action bars.

local _, ab = ...
local db = ConsolePort:GetData()
local CPAPI = db.CPAPI

local Bar = ab.bar
local red, green, blue = ab.data.Atlas.GetCC()

do
	-- Hidden parent frame
	local UIHider = CreateFrame('Frame')

	-------------------------------------------
	---		UI hider -> dispose of blizzbars
	-------------------------------------------

	UIHider:Hide()
	Bar.UIHider = UIHider

	-- Nil entries here are simply skipped by the table constructor, so the
	-- WotLK-only names (VehicleMenuBar, BonusActionBarFrame) are harmless.
	for _, bar in pairs({
		MainMenuBarArtFrame,
		MainMenuBarMaxLevelBar,
		VehicleMenuBar,
		BonusActionBarFrame,
		MultiCastActionBarFrame,
		MultiBarLeft,
		MultiBarRight,
		MultiBarBottomLeft,
		MultiBarBottomRight }) do
		bar:SetParent(UIHider)
	end

	MainMenuBarArtFrame:Hide()

	-- Hide MultiBar Buttons, but keep the bars alive.
	-- MoP: there is no BonusActionButton set -- bonus/stance bars are paged onto
	-- ActionButton1-12 -- so the name below resolved to nil and this loop errored
	-- at load, which is what kept ConsolePortBar from starting at all.
	for _, n in pairs({
		'ActionButton',
		'BonusActionButton',
		'MultiBarLeftButton',
		'MultiBarRightButton',
		'MultiBarBottomLeftButton',
		'MultiBarBottomRightButton'	}) do
		for i=1, 12 do
			local b = _G[n .. i]
			if b then
				b:Hide()
				b:UnregisterAllEvents()
				b:SetAttribute('statehidden', true)
			end
		end
	end

	-- MoP's UIPARENT_MANAGED_FRAME_POSITIONS drops ShapeshiftBarFrame/BonusActionBar
	-- and adds ExtraActionBarFrame, so clear the MoP keys too. Harmless where a
	-- key does not exist.
	for _, key in pairs({
		'MainMenuBar', 'BonusActionBar', 'ShapeshiftBarFrame', 'StanceBarFrame',
		'PossessBarFrame', 'PETACTIONBAR_YPOS', 'MULTICASTACTIONBAR_YPOS',
		'MultiCastActionBarFrame', 'ExtraActionBarFrame' }) do
		UIPARENT_MANAGED_FRAME_POSITIONS[key] = nil
	end

	-------------------------------------------
	--- 	Micro buttons
	-------------------------------------------
	-- On 3.3.5 these are children of MainMenuBarArtFrame, so hiding that frame
	-- hid them for free. In MoP they are parented directly to UIParent, so they
	-- stayed on screen -- a live audit found 12 of the 13 still visible. Hide
	-- them explicitly and keep them hidden: MainMenuBarMicroButtons.lua calls
	-- UpdateMicroButtons() constantly and will happily re-Show them. Reparenting
	-- to a hidden frame wins that fight permanently -- a :Show() on a child of a
	-- hidden parent still paints nothing.
	--
	-- Their events are deliberately LEFT REGISTERED. ConsolePortUI_Menu drives
	-- these same buttons with '/click <name>' macros (Menu_Frame.lua:968), and
	-- /click works on a hidden button but NOT on a disabled one -- so
	-- UpdateMicroButtons() must keep running to maintain the enabled state.
	if type(MICRO_BUTTONS) == 'table' then
		local microHider = CreateFrame('Frame')
		microHider:Hide()
		for _, name in pairs(MICRO_BUTTONS) do
			local button = _G[name]
			if button then
				button:SetParent(microHider)
				button:Hide()
			end
		end
		-- MicroButtonPulse draws attention to a button we have hidden; silence it.
		if MicroButtonPulse then
			MicroButtonPulse = function() end
		end

		-- Blizzard_AchievementUI.lua:816 does:
		--     if ( not AchievementMicroButton:IsShown() ) then
		--         AchievementMicroButton_Update();
		--     end
		-- and AchievementMicroButton_Update is defined NOWHERE in 5.4.8 -- that
		-- line is a latent bug in the stock client. It never fires normally
		-- because the micro button is always shown; hiding the micro buttons (just
		-- above) makes the guard true and the nil call real, once per
		-- CRITERIA_UPDATE. Define the missing function rather than un-hide the
		-- button. A no-op is correct: the real function does not exist on this
		-- client, so nothing can depend on it doing anything.
		if not AchievementMicroButton_Update then
			AchievementMicroButton_Update = function() end
		end
	end

	-------------------------------------------
	--- 	ActionBarController
	-------------------------------------------
	-- New in Cataclysm and load-bearing: on every vehicle, stance and pet-battle
	-- transition it runs MultiActionBar_Update, UIParent_ManageFramePositions and
	-- ValidateActionBarTransition, which re-Show MainMenuBar, MultiBarRight and
	-- OverrideActionBar with slide animations -- fighting this addon each time.
	-- Bartender and Dominos solve it the same way. ConsolePort drives its own
	-- paging from Core/Bar.lua, so nothing here needs the controller.
	if ActionBarController then
		ActionBarController:UnregisterAllEvents()
		ActionBarController:SetParent(UIHider)
	end

	MainMenuBar:EnableMouse(false)
	if MicroButtonAndBagsBar then MicroButtonAndBagsBar:Hide() end
	if StatusTrackingBarManager then StatusTrackingBarManager:Hide() end
	if MainMenuExpBar then MainMenuExpBar:SetParent(UIHider) end
	if ExhaustionTick then ExhaustionTick:SetParent(UIHider) end
	if MainMenuBarPerformanceBar then MainMenuBarPerformanceBar:SetParent(UIHider) end
	if ReputationWatchBar then ReputationWatchBar:SetParent(UIHider) end

--	local animations = {MainMenuBar.slideOut:GetAnimations()}
--	animations[1]:SetOffset(0,0)

	-------------------------------------------
	--- 	Special action bars
	-------------------------------------------

	for _, bar in pairs({
		ShapeshiftBarFrame,		-- 3.3.5 only
		StanceBarFrame,			-- MoP name for the same thing
		PossessBarFrame,
		OverrideActionBar,		-- MoP: the skinned vehicle/override bar
		MultiCastActionBarFrame,
		PetActionBarFrame	}) do
		bar:UnregisterAllEvents()
		bar:SetParent(UIHider)
		bar:Hide()
	end

	-- ExtraActionBarFrame is deliberately NOT hidden: it holds a real, usable
	-- button (boss abilities, quest items) that ConsolePort binds through
	-- action slot 169. Detach it from MainMenuBar -- which we have just hidden,
	-- and which would drag it out of sight -- and park it above the bar instead.
	if ExtraActionBarFrame then
		ExtraActionBarFrame:SetParent(UIParent)
		ExtraActionBarFrame:ClearAllPoints()
		ExtraActionBarFrame:SetPoint('BOTTOM', UIParent, 'BOTTOM', 0, 220)
	end

	-- Pet battles take over the whole screen. The ConsolePort bar must get out
	-- of the way while one is running, or it draws on top of the battle UI.
	--
	-- This cannot hook PetBattleFrame directly: Blizzard_PetBattleUI is
	-- LoadOnDemand, so at the time this file runs the frame does not exist yet.
	-- The events themselves are always available.
	if C_PetBattles then
		local petBattleWatcher = CreateFrame('Frame')
		petBattleWatcher:RegisterEvent('PET_BATTLE_OPENING_START')
		petBattleWatcher:RegisterEvent('PET_BATTLE_CLOSE')
		petBattleWatcher:RegisterEvent('PET_BATTLE_OVER')
		petBattleWatcher:SetScript('OnEvent', function(self, event)
			local inBattle = ( event == 'PET_BATTLE_OPENING_START' )
			Bar:SetAlpha(inBattle and 0 or 1)
			-- EnableMouse is protected on a secure frame; a pet battle counts as
			-- combat lockdown, so only take the mouse away when it is legal to.
			if not InCombatLockdown() then
				Bar:EnableMouse(not inBattle)
			end
		end)
	end

	-------------------------------------------
	--- 	Casting bar modified
	-------------------------------------------

	local castBar, overrideCastBarPos = CastingBarFrame
	local castBarAnchor = {'BOTTOM', Bar,  'BOTTOM', 0, 0}

	hooksecurefunc(castBar, 'SetPoint', function(self, point, region, relPoint, x, y)
		if overrideCastBarPos and region ~= castBarAnchor[2] then
			self:SetPoint(unpack(castBarAnchor))
		end
	end)

	
	local function CastingBarFrame_SetLook(self, look)

		local selfName = self:GetName();
		local selfSpark = _G[selfName.."Spark"];
		local selfText = _G[selfName.."Text"];
		local selfFlash = _G[selfName.."Flash"];
		local selfIcon = _G[selfName.."Icon"];
		local selfBorder = _G[selfName.."Border"];
		local selfBorderShield = _G[selfName.."BorderShield"];

		if ( look == "CLASSIC" ) then
			self:SetWidth(195);
			self:SetHeight(13);
			-- border
			selfBorder:ClearAllPoints();
			selfBorder:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border");
			selfBorder:SetWidth(256);
			selfBorder:SetHeight(64);
			selfBorder:SetPoint("TOP", 0, 28);
			-- bordershield
			selfBorderShield:ClearAllPoints();
			selfBorderShield:SetWidth(256);
			selfBorderShield:SetHeight(64);
			selfBorderShield:SetPoint("TOP", 0, 28);
			-- text
			selfText:ClearAllPoints();
			selfText:SetWidth(185);
			selfText:SetHeight(16);
			selfText:SetPoint("TOP", 0, 5);
			selfText:SetFontObject("GameFontHighlight");
			-- icon
			selfIcon:Hide();
			-- bar spark
			selfSpark.offsetY = 2;
			-- bar flash
			selfFlash:ClearAllPoints();
			selfFlash:SetTexture("Interface\\CastingBar\\UI-CastingBar-Flash");
			selfFlash:SetWidth(256);
			selfFlash:SetHeight(64);
			selfFlash:SetPoint("TOP", 0, 28);
		elseif ( look == "UNITFRAME" ) then
			self:SetWidth(150);
			self:SetHeight(10);
			-- border
			selfBorder:ClearAllPoints();
			selfBorder:SetTexture("");
			selfBorder:SetWidth(0);
			selfBorder:SetHeight(49);
			selfBorder:SetPoint("TOPLEFT", -23, 20);
			selfBorder:SetPoint("TOPRIGHT", 23, 20);
			-- bordershield
			selfBorderShield:ClearAllPoints();
			selfBorderShield:SetWidth(0);
			selfBorderShield:SetHeight(49);
			selfBorderShield:SetPoint("TOPLEFT", -28, 20);
			selfBorderShield:SetPoint("TOPRIGHT", 18, 20);
			-- text
			selfText:ClearAllPoints();
			selfText:SetWidth(0);
			selfText:SetHeight(16);
			selfText:SetPoint("TOPLEFT", 0, 4);
			selfText:SetPoint("TOPRIGHT", 0, 4);
			selfText:SetFontObject("SystemFont_Shadow_Small");
			-- icon
			selfIcon:Show();
			-- bar spark
			selfSpark.offsetY = 0;
			-- bar flash
			selfFlash:ClearAllPoints();
			selfFlash:SetTexture("Interface\\CastingBar\\UI-CastingBar-Flash-Small");
			selfFlash:SetWidth(0);
			selfFlash:SetHeight(49);
			selfFlash:SetPoint("TOPLEFT", -23, 20);
			selfFlash:SetPoint("TOPRIGHT", 23, 20);
		end
  	end

	local function ModifyCastingBarFrame(self, isOverrideBar)
		local selfName = self:GetName();
		local selfSpark = _G[selfName.."Spark"];
		local selfText = _G[selfName.."Text"];
		local selfFlash = _G[selfName.."Flash"];
		local selfIcon = _G[selfName.."Icon"];
		local selfBorder = _G[selfName.."Border"];
		local selfBorderShield = _G[selfName.."BorderShield"];

		CastingBarFrame_SetLook(self, isOverrideBar and 'CLASSIC' or 'UNITFRAME')
		CPAPI.SetShown(selfBorder, isOverrideBar)
		if isOverrideBar then
			return
		end
		-- Text anchor
		selfText:SetPoint('TOPLEFT', 0, 0)
		selfText:SetPoint('TOPRIGHT', 0, 0)
		-- Flash at the end of a cast
		selfFlash:SetTexture('Interface\\QUESTFRAME\\UI-QuestLogTitleHighlight')
		selfFlash:SetAllPoints()
		-- Border shield for uninterruptible casts
		selfBorderShield:ClearAllPoints()
		selfBorderShield:SetTexture('Interface\\CastingBar\\UI-CastingBar-Arena-Shield')
		selfBorderShield:SetPoint('CENTER', selfIcon, 'CENTER', 10, 0)
		selfBorderShield:SetSize(49, 49)

		--local r, g, b = ab:GetRGBColorFor('exp')
		--CastingBarFrame_SetStartCastColor(self, r or 1.0, g or 0.7, b or 0.0)
	end

	local function MoveCastingBarFrame()
		local cfg = ab.cfg
		if cfg and cfg.disableCastBarHook then
			overrideCastBarPos = false
		elseif OverrideActionBar and OverrideActionBar:IsShown() or (cfg and cfg.defaultCastBar) then
			ModifyCastingBarFrame(castBar, true)
			overrideCastBarPos = false
		else
			castBarAnchor[4] = ( cfg and cfg.castbarxoffset or 0 )
			castBarAnchor[5] = ( cfg and cfg.castbaryoffset or 0 )
			ModifyCastingBarFrame(castBar, false)
			castBar:ClearAllPoints()
			castBar:SetPoint(unpack(castBarAnchor))
			castBar:SetFrameStrata("HIGH")
			castBar:SetSize(
				(cfg and cfg.castbarwidth) or (Bar:GetWidth() - 280),
				(cfg and cfg.castbarheight) or 14)
			overrideCastBarPos = true
		end
	end

	Bar:HookScript('OnSizeChanged', MoveCastingBarFrame)
	Bar:HookScript('OnShow', MoveCastingBarFrame)
	Bar:HookScript('OnHide', MoveCastingBarFrame)

	if OverrideActionBar then
		OverrideActionBar:HookScript('OnShow', MoveCastingBarFrame)
		OverrideActionBar:HookScript('OnHide', MoveCastingBarFrame)
	end 

	-------------------------------------------
	--- 	Misc changes
	-------------------------------------------

	-- MoP's quest tracker is WatchFrame; ObjectiveTrackerFrame is Legion, so this
	-- guard was never true on this client and the tracker was never repositioned.
	local tracker = ObjectiveTrackerFrame or WatchFrame
	if tracker and MinimapCluster then
		tracker:SetPoint('TOPRIGHT', MinimapCluster, 'BOTTOMRIGHT', -100, -132)
	end
	AlertFrame:SetPoint('BOTTOM', UIParent, 'BOTTOM', 0, 200)

	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
	else
		hooksecurefunc('TalentFrame_LoadUI', function()
			if PlayerTalentFrame then
				PlayerTalentFrame:UnregisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
			end 
		end)
	end

	-- Replace spell push animations. 
	--[===[
	IconIntroTracker:HookScript('OnEvent', function(self, event, ...)
		local anim = ConsolePortSpellHelperFrame
		if anim and event == 'SPELL_PUSHED_TO_ACTIONBAR' then
			for _, icon in pairs(self.iconList) do
				icon:ClearAllPoints()
				icon:SetAlpha(0)
			end

			local spellID, slotIndex, slotPos = ...
			local page = math.floor((slotIndex - 1) / NUM_ACTIONBAR_BUTTONS) + 1
			local currentPage = GetActionBarPage()
			local bonusBarIndex = GetBonusBarIndex()
			if (HasBonusActionBar() and bonusBarIndex ~= 0) then
				currentPage = bonusBarIndex
			end

			if (page ~= currentPage and page ~= MULTIBOTTOMLEFTINDEX) then
				return
			end
			
			local _, _, icon = GetSpellInfo(spellID)
			local actionID = ((page - 1) * NUM_ACTIONBAR_BUTTONS) + slotPos

			anim:OnActionPlaced(actionID, icon)
		end
	end)
	--]===]
end