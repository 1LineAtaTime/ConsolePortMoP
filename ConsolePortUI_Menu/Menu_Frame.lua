local UI, an, L = ConsolePortUI, ...
local db = ConsolePort:GetData()
local CPAPI = db.CPAPI
local ICON = 'Interface\\Icons\\%s'
local Button = L.Button

-- Loot header specifics
local LootButton = L.LootButton
local lootButtonProbeScript = L.lootButtonProbeScript
local lootHeaderOnSetScript = L.lootHeaderOnSetScript

-- Check if game client is a custom client.
local IsCustomClient = CPAPI.IsCustomClient()

-- Dropdown button templates 
local maskTemplates = {'CPUIMenuButtonBaseTemplate', IsCustomClient and 'SecureUnitButtonTemplate' or 'SecureActionButtonTemplate'}
local baseTemplates = {'CPUIMenuButtonMaskTemplate', IsCustomClient and 'SecureUnitButtonTemplate' or 'SecureActionButtonTemplate'}


local Menu =  UI:CreateFrame('Frame', an, IsCustomClient and EscapeMenu or GameMenuFrame, 'SecureHandlerStateTemplate, CPUIMenuTemplate', {
	{
		Character = {
			Type 	= 'CheckButton',
			Setup 	= {
				'SecureHandlerBaseTemplate',
				'SecureHandlerClickTemplate',
				'CPUIListCategoryTemplate',
			},
			Text	= '|TInterface\\Store\\category-icon-armor:18:18:-4:0:64:64:14:50:14:50|t' .. CHARACTER,
			ID = 1,
			SetAttribute = {'_onclick', 'control:RunFor(self:GetParent(), self:GetParent():GetAttribute("ShowHeader"), self:GetID())'},
			{
				Info  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 1,
					Point 	= {'TOP', 'parent', 'BOTTOM', 0, -16},
					Desc	= CHARACTER_BUTTON,
					Attrib 	= {hidemenu = true},
					UpdateLevel = function(self, newLevel)
						local level = newLevel or UnitLevel('player')
						if ( level and level < MAX_PLAYER_LEVEL ) then
							self.Level:SetTextColor(1, 0.8, 0)
							self.Level:SetText(level)
						else
							self.Level:SetTextColor(CPAPI:GetItemLevelColor())
							self.Level:SetText(CPAPI:GetAverageItemLevel())
						end
					end,
					OnClick = function(self) ToggleCharacter('PaperDollFrame') end,
					OnEvent = function(self, event, ...)
						if event == 'UNIT_PORTRAIT_UPDATE' then
							SetPortraitTexture(self.Icon, 'player')
						elseif event == 'PLAYER_LEVEL_UP' then
							self:UpdateLevel(...)
						else
							SetPortraitTexture(self.Icon, 'player')
							self:UpdateLevel()
						end
					end,
					Events = {
						'UNIT_PORTRAIT_UPDATE',
						'PLAYER_ENTERING_WORLD',
						'PLAYER_LEVEL_UP',
					},
					{
						Level = {
							Type 	= 'FontString',
							Setup 	= {'OVERLAY'},
							Font 	= {GameFontNormal:GetFont()},
							AlignH 	= 'RIGHT',
							Point 	= {'RIGHT', -10, 0},
						},
					},
				},
				Inventory  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 2,
					Point 	= {'TOP', 'parent.Info', 'BOTTOM', 0, 0},
					Desc	= INVENTORY_TOOLTIP,
					Img 	= [[Interface\ICONS\INV_Misc_Bag_22]],
					Events 	= {'BAG_UPDATE'},
					Attrib 	= {hidemenu = true},
					OnClick = CPAPI.ToggleAllBags,
					OnEvent = function(self, event, ...)
						local totalFree, numSlots, freeSlots, bagFamily = 0, 0
						for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
							freeSlots, bagFamily = GetContainerNumFreeSlots(i)
							if ( bagFamily == 0 ) then
								totalFree = totalFree + freeSlots
								numSlots = numSlots + GetContainerNumSlots(i)
							end
						end
						self.Count:SetFormattedText('%s\n|cFFAAAAAA%s|r', totalFree, numSlots)
					end,
					{
						Count = {
							Type 	= 'FontString',
							Setup 	= {'OVERLAY'},
							Font 	= {GameFontNormal:GetFont()},
							AlignH 	= 'RIGHT',
							Point 	= {'RIGHT', -10, 0},
						},
					},
				},
				Spec  = {
					Type 	= 'Button',
					Setup 	= maskTemplates,
					Mixin 	= Button,
					ID 		= 3,
					Point 	= {'TOP', 'parent.Inventory', 'BOTTOM', 0, 0},
					Desc	= TALENTS_BUTTON,
					RefTo 	= TalentMicroButton,
					Attrib 	= {hidemenu = true},
					EvaluateAlertVisibility = function(self)
						-- If we just unspecced, and we have unspent talent points, it's probably spec-specific talents that were just wiped.  Show the tutorial box.
					--	if not AreTalentsLocked() and GetNumUnspentTalents() > 0 and (not PlayerTalentFrame or not PlayerTalentFrame:IsShown()) then
					--		self.tooltipText = TALENT_MICRO_BUTTON_UNSPENT_TALENTS
					--		self:SetPulse(true)
					--		return
					--	end
					--	if GetNumUnspentPvpTalents() > 0 and (not PlayerTalentFrame or not PlayerTalentFrame:IsShown()) then
					--		self.tooltipText = TALENT_MICRO_BUTTON_UNSPENT_HONOR_TALENTS
					--		self:SetPulse(true)
					--		return
					--	end
					end,
					OnEnterScript = function(self)
						if self.tooltipText then
							GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
							GameTooltip:SetText(self.tooltipText)
							self.tooltipText = nil
							self.hideTooltipOnLeave = true
						end
					end,
					OnLeaveHook = function(self)
						if self.hideTooltipOnLeave then
							GameTooltip:Hide()
							self.hideTooltipOnLeave = nil
						end
					end,
					OnLoadHook = function(self)
						SetPortraitToTexture(self.Icon, [[Interface\Icons\Ability_Mage_StudentOfTheMind]])

						self:RegisterEvent('PLAYER_LEVEL_UP')
						self:RegisterEvent('UPDATE_BINDINGS')
						self:RegisterEvent('PLAYER_TALENT_UPDATE')
						self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
						-- The four below are Legion-era and do not exist on MoP.
						-- Registering an unknown event raises, so use the same
						-- pcall guard the core uses in Core/Events.lua.
						for _, event in pairs({
							'HONOR_LEVEL_UPDATE',
							'HONOR_PRESTIGE_UPDATE',
							'PLAYER_PVP_TALENT_UPDATE',
							'PLAYER_CHARACTER_UPGRADE_TALENT_COUNT_CHANGED' }) do
							pcall(self.RegisterEvent, self, event)
						end
					end,
					OnEvent = function(self, event, ...)
						self.tooltipText = nil
						if ( event == 'PLAYER_LEVEL_UP' ) then
							local level = ...
							if (level == SHOW_SPEC_LEVEL) then
								self.tooltipText = TALENT_MICRO_BUTTON_SPEC_TUTORIAL
								self:SetPulse(true)
							elseif (level == SHOW_TALENT_LEVEL) then
								self.tooltipText = TALENT_MICRO_BUTTON_TALENT_TUTORIAL
								self:SetPulse(true)
							end
						elseif ( event == 'PLAYER_SPECIALIZATION_CHANGED' ) then
							self:EvaluateAlertVisibility()
						elseif ( event == 'PLAYER_TALENT_UPDATE' or event == 'NEUTRAL_FACTION_SELECT_RESULT' or
							event == 'HONOR_LEVEL_UPDATE' or event == 'HONOR_PRESTIGE_UPDATE' or event == 'PLAYER_PVP_TALENT_UPDATE' ) then
							self:EvaluateAlertVisibility()

							-- On the first update from the server, flash the button if there are unspent points
							-- Small hack: GetNumSpecializations should return 0 if talents haven't been initialized yet
							--if (not self.receivedUpdate and GetNumSpecializations(false) > 0) then
							--	self.receivedUpdate = true;
							--	local shouldPulseForTalents = GetNumUnspentTalents() > 0 or GetNumUnspentPvpTalents() > 0 and not AreTalentsLocked()
							--	if (UnitLevel('player') >= SHOW_SPEC_LEVEL and (not GetSpecialization() or shouldPulseForTalents)) then
							--		self:SetPulse(true)
							--	end
							--end
						elseif ( event == 'PLAYER_CHARACTER_UPGRADE_TALENT_COUNT_CHANGED' ) then
							local prev, current = ...
							if ( prev == 0 and current > 0 ) then
								self.tooltipText = TALENT_MICRO_BUTTON_TALENT_TUTORIAL
								self:SetPulse(true)
							elseif ( prev ~= current ) then
								self.tooltipText = TALENT_MICRO_BUTTON_UNSPENT_TALENTS
								self:SetPulse(true)
							end
						end
					end,
				},
				Spellbook  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 4,
					Point 	= {'TOP', 'parent.Spec', 'BOTTOM', 0, 0},
					Desc	= SPELLBOOK_BUTTON,
					Img 	= [[Interface\Spellbook\Spellbook-Icon]],
					RefTo 	= SpellbookMicroButton,
					Attrib 	= {hidemenu = true},
				}, 
				Totem  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 5,
					Point 	= {'TOP', 'parent.Spellbook', 'BOTTOM', 0, 0},
					Desc	= db.CUSTOMBINDS.CP_TOTEMFRAME,
					Img 	= [[Interface\Icons\Spell_Shaman_TotemRecall]],
					OnLoadHook = function(self) SetPortraitToTexture(self.Icon, ICON:format('Spell_Shaman_TotemRecall')) end,
					RefTo 	= ConsolePortTotemToggle,
					Attrib 	= {
						hidemenu = true, 
						condition = string.format('return %s', tostring(select(2, UnitClass("player")) == "SHAMAN"))
					},
				},
				Collections  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 6,
					Point 	= {'TOP', select(2, UnitClass("player")) == "SHAMAN" and 'parent.Totem' or 'parent.Spellbook', 'BOTTOM', 0, 0},
					Desc	= MOUNTS.." & "..PETS,
					Img 	= [[Interface\ICONS\Ability_Mount_BigBlizzardBear]], 
					Attrib 	= {hidemenu = true},	
					OnLoadHook = function(self)
						local mountIcon = [[Interface\ICONS\Ability_Mount_BigBlizzardBear]]
	
						local pAlliance = {["Human"]=1, ["NightElf"]=1, ["Dwarf"]=1, ["Gnome"]=1, ["Draenei"]=1}
						local pHorde = {["Orc"]=1, ["Troll"]=1, ["Scourge"]=1, ["Tauren"]=1, ["BloodElf"]=1}
						local punitRace, punitRaceEn = UnitRace("player");

						if(pHorde[punitRaceEn]) then
							mountIcon = [[Interface\ICONS\Ability_Mount_BlackDireWolf]]
						elseif(pAlliance[punitRaceEn]) then
							mountIcon = [[Interface\ICONS\Ability_Mount_RidingHorse]] 
						end

						SetPortraitToTexture(self.Icon, mountIcon)
					end, 
					-- MoP has no CollectionsMicroButton (that is Legion), and the
					-- old fallback opened PetPaperDollFrame -- the hunter/warlock
					-- pet STATS tab, not the mount collection. The 5.4.8 mount and
					-- pet collection is PetJournalParent from Blizzard_PetJournal,
					-- which is load-on-demand, with tab 1 = Mounts, tab 2 = Pets.
					RefTo   = _G["CollectionsMicroButton"] or _G["CompanionsMicroButton"],
					OnClick = (not _G["CollectionsMicroButton"] and not _G["CompanionsMicroButton"]) and function(self)
						if not IsAddOnLoaded('Blizzard_PetJournal') then
							UIParentLoadAddOn('Blizzard_PetJournal')
						end
						if PetJournalParent then
							ToggleFrame(PetJournalParent)
							if PetJournalParent:IsShown() and PetJournalParent_SetTab then
								PetJournalParent_SetTab(PetJournalParent, 1) -- Mounts
							end
						end
					end or nil,
				},
			},
		},
		Gameplay = {
			Type 	= 'CheckButton',
			Setup 	= {
				'SecureHandlerBaseTemplate',
				'SecureHandlerClickTemplate',
				'CPUIListCategoryTemplate',
			},
			Text	= '|TInterface\\Store\\category-icon-weapons:18:18:-4:0:64:64:14:50:14:50|t' .. GAME,
			ID 	= 2,
			SetAttribute = {'_onclick', 'control:RunFor(self:GetParent(), self:GetParent():GetAttribute("ShowHeader"), self:GetID())'},
			{
				WorldMap  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 1,
					Point 	= {'TOP', 'parent', 'BOTTOM', 0, -16},
					Desc	= WORLD_MAP,
					Img 	= ICON:format('INV_Misc_Map02'), 
					Attrib 	= {hidemenu = true},
					OnClick = function(self) WorldMapFrame:Show() end,
					OnLoadHook = function(self) SetPortraitToTexture(self.Icon, ICON:format('INV_Misc_Map02')) end,
				}, 
				QuestLog  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 2,
					Point 	= {'TOP', 'parent.WorldMap', 'BOTTOM', 0, 0},
					Desc	= QUEST_LOG,
					Img 	= [[Interface\QUESTFRAME\UI-QuestLog-BookIcon]],
					RefTo 	= QuestLogMicroButton,
					Attrib 	= {hidemenu = true},
					{
						Notice = {
							Type = 'Frame',
							Size = {28, 28},
							Point = {'RIGHT', -10, 0},
							--Hide = not EJMicroButton.NewAdventureNotice:IsShown(),
							{
								Texture = {
									Type = 'Texture',
									Setup = {'OVERLAY'},
									Fill = true,
									Atlas = 'adventureguide-microbutton-alert',
								},
							},
							OnLoad = function(self)
								--hooksecurefunc('EJMicroButton_UpdateNewAdventureNotice', function()
								--	if EJMicroButton.NewAdventureNotice:IsShown() then
								--		self:Show()
								--	end
								--end)
								--hooksecurefunc('EJMicroButton_ClearNewAdventureNotice', function()
								--	self:Hide()
								--end)
							end,
						},
					},
				},
				Achievements  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 3,
					Point 	= {'TOP', 'parent.QuestLog', 'BOTTOM', 0, 0},
					Desc	= ACHIEVEMENTS,
					Img 	= ICON:format('ACHIEVEMENT_WIN_WINTERGRASP'),
					RefTo 	= AchievementMicroButton,
					Attrib 	= {hidemenu = true},
					OnLoadHook = function(self) SetPortraitToTexture(self.Icon, ICON:format('ACHIEVEMENT_WIN_WINTERGRASP')) end,
				},
				PVPFinder  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 4,
					Point 	= {'TOP', 'parent.Achievements', 'BOTTOM', 0, -16},
					Desc	= BUG_CATEGORY14,
					Img 	= [[Interface\ICONS\Ability_Parry]],
					OnClick = function(self)
						-- MoP: TogglePVPFrame is gone; the PvP interface opens
						-- through TogglePVPUI (PVEFrame -> Blizzard_PVPUI).
						if TogglePVPUIFrame then
							TogglePVPUIFrame()
						elseif TogglePVPUI then
							TogglePVPUI()
						elseif TogglePVPFrame then
							TogglePVPFrame()
						end
					end,

					Attrib 	= {hidemenu = true},
					OnLoadHook = function(self) SetPortraitToTexture(self.Icon, [[Interface\ICONS\Ability_Parry]]) end,
				},
					PVEFinder  = {
						Type 	= 'Button',
						Setup 	= baseTemplates,
						Mixin 	= Button,
						ID 		= 5,
						Point 	= {'TOP', 'parent.PVPFinder', 'BOTTOM', 0, 0},
						Desc	= DUNGEONS_BUTTON,
						Img 	= [[Interface\LFGFRAME\UI-LFG-PORTRAIT]],
						RefTo 	= LFDMicroButton,
						Attrib 	= {hidemenu = true},
					},
				
				-- Custom client specifics

				PathToAscension  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 6,
					Point 	= {'TOP', 'parent.PVEFinder', 'BOTTOM', 0, 0},
					Desc	= PATH_TO_ASCENSION,
					RefTo 	= PathToAscensionMicroButton,
					Img 	= [[Interface\ICONS\inv_azeriteexplosion]],
					Attrib 	= {
						hidemenu = true, 
						condition = string.format('return %s', tostring(IsCustomClient and IsCustomClient == "Ascension"))
					},
				},


				Trials  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 7,
					Point 	= {'TOP', 'parent.PathToAscension', 'BOTTOM', 0, 0},
					Desc	= TRIALS,
					RefTo 	= ChallengesMicroButton,
					Img 	= [[Interface\ICONS\_CallToArmsRed]],
					Attrib 	= {
						hidemenu = true,
						condition = string.format('return %s', tostring(IsCustomClient and IsCustomClient == "Ascension"))
					},
				},

				EncounterJournal  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 8,
					Point 	= {'TOP', 'parent.PVEFinder', 'BOTTOM', 0, 0},
					Desc	= EncounterJournalMicroButton and EncounterJournalMicroButton.tooltipText or ENCOUNTER_JOURNAL,
					RefTo 	= EncounterJournalMicroButton,
					Img 	= [[Interface\ICONS\_CallToArmsRed]],
					Attrib 	= {
						hidemenu = true,
						condition = string.format('return %s', tostring(EncounterJournalMicroButton and true or nil))
					},
				},

				-----------

				Teleport  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 8,
					Point 	= {'TOP', IsCustomClient and 'parent.Trials' or (EncounterJournalMicroButton and 'parent.EncounterJournal' or 'parent.PVEFinder'), 'BOTTOM', 0, 0},
					Img 	= ICON:format('Spell_Shadow_Teleport'),  Attrib 	= {
						hidemenu 	= true,
						condition 	= 'return PlayerInGroup()',
					},
					OnLoadHook = function(self) SetPortraitToTexture(self.Icon, ICON:format('Spell_Shadow_Teleport')) end,
					Hooks = {
						OnShow = function(self)
							local isLFG, inDungeon = IsPartyLFG(), IsInLFGDungeon()
							self:SetText(inDungeon and TELEPORT_OUT_OF_DUNGEON or isLFG and TELEPORT_TO_DUNGEON or '|cFF757575'..TELEPORT_TO_DUNGEON)
						end,
						OnClick = function(self)
							LFGTeleport(IsInLFGDungeon())
						end,
					},
				},
			},
		},
		Social = {
			Type 	= 'CheckButton',
			Setup 	= {
				'SecureHandlerBaseTemplate',
				'SecureHandlerClickTemplate',
				'CPUIListCategoryTemplate',
			},
			Text	= '|TInterface\\Store\\category-icon-featured:18:18:-4:0:64:64:14:50:14:50|t' .. SOCIAL_BUTTON,
			ID = 3,
			SetAttribute = {'_onclick', 'control:RunFor(self:GetParent(), self:GetParent():GetAttribute("ShowHeader"), self:GetID())'},
			{	 
				Friends  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 1,
					Point 	= {'TOP', 'parent', 'BOTTOM', 0, -16},
					Desc 	= FRIENDS_LIST,
					Img 	= [[Interface\FriendsFrame\BroadcastIcon]],
					RefTo 	= FriendsMicroButton,
					Attrib 	= {hidemenu = true},
					OnEvent = function(self)
						local _, numBNetOnline = BNGetNumFriends()
						local _, numWoWOnline = GetNumFriends()
						self.Count:SetText(numBNetOnline + numWoWOnline)
					end,
					Events = {
						'FRIENDLIST_UPDATE',
						'BN_FRIEND_INFO_CHANGED',
						'PLAYER_ENTERING_WORLD',
					},
					{
						Count = {
							Type 	= 'FontString',
							Setup 	= {'OVERLAY'},
							Font 	= {GameFontNormal:GetFont()},
							AlignH 	= 'RIGHT',
							Point 	= {'RIGHT', -10, 0},
						},
					},
				},
				Guild  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 2,
					Point 	= {'TOP', 'parent.Friends', 'BOTTOM', 0, 0},
					Desc 	= GUILD,
					Img 	= ICON:format('Achievement_Reputation_01'),
					OnClick = function(self) ToggleFriendsFrame(3) end,
					Attrib 	= {hidemenu = true},
					OnLoadHook = function(self) SetPortraitToTexture(self.Icon, ICON:format('Achievement_Reputation_01')) end,
				},
				Calendar  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 3,
					Point 	= {'TOP', 'parent.Guild', 'BOTTOM', 0, 0},
					Desc 	= EVENTS_LABEL,
					Img 	= [[Interface\Calendar\MeetingIcon]],
					Attrib 	= {hidemenu = true},
					RefTo 	= GameTimeFrame,
					
				},
				Raid  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 4,
					Point 	= {'TOP', 'parent.Calendar', 'BOTTOM', 0, 0},
					Desc 	= RAID,
					Img 	= [[Interface\LFGFRAME\UI-LFR-PORTRAIT]],
                    Attrib 	= {hidemenu = true},
					OnClick = function(self) ToggleFriendsFrame(5) end, 
				},
				Party  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 5,
					Point 	= {'TOP', 'parent.Raid', 'BOTTOM', 0, -16},
					Img 	= [[Interface\LFGFRAME\UI-LFG-PORTRAIT]],
                    Attrib 	= {
						condition = 'return PlayerInGroup()',
						hidemenu = true,
					},
					Hooks = {
						OnShow = function(self)
							self:SetText(IsPartyLFG() and INSTANCE_PARTY_LEAVE or PARTY_LEAVE)
						end,
						OnClick = function(self)
							if IsPartyLFG() or IsInLFGDungeon() then
								ConfirmOrLeaveLFGParty()
							else
								LeaveParty()
							end
						end,
					},
				}, 
			},
		},
		System = {
			Type 	= 'CheckButton',
			Setup 	= {
				'SecureHandlerBaseTemplate',
				'SecureHandlerClickTemplate',
				'CPUIListCategoryTemplate',
			},
			Text	= '|TInterface\\Store\\category-icon-wow:18:18:-4:0:64:64:14:50:14:50|t' .. CHAT_MSG_SYSTEM,
			ID = 4,
			SetAttribute = {'_onclick', 'control:RunFor(self:GetParent(), self:GetParent():GetAttribute("ShowHeader"), self:GetID())'},
			{
				Return  = {
					Type 	= 'Button',
					Setup 	= maskTemplates,
					Mixin 	= Button,
					ID 		= 1,
					Point 	= {'TOP', 'parent', 'BOTTOM', 0, -16},
					Desc	= RETURN_TO_GAME,
					RefTo 	= IsCustomClient and EscapeMenuButton1 or GameMenuButtonContinue,
					Img 	= [[Interface\FriendsFrame\Battlenet-WoWicon]], 
				}, 
				Logout  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 2,
					Point 	= {'TOP', 'parent.Return', 'BOTTOM', 0, 0},
					Desc	= LOGOUT,
					RefTo 	= IsCustomClient and EscapeMenuButton3 or GameMenuButtonLogout,
					-- Both Logout and Exit raise a StaticPopup with a countdown
					-- and a confirm button. StaticPopup sits at DIALOG strata
					-- while this menu is FULLSCREEN, so without hiding the menu
					-- the popup is drawn underneath it -- the client looks like
					-- it has hung when it is really waiting on a click you
					-- cannot see or reach.
					Attrib 	= {hidemenu = true},
					Img 	= ICON:format('Ability_Paladin_BeaconOfLight'),
				--	OnLoadHook = function(self) SetPortraitToTexture(self.Icon, ICON:format('Ability_Paladin_BeaconOfLight')) end,
				},
				Exit  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 3,
					Point 	= {'TOP', 'parent.Logout', 'BOTTOM', 0, 0},
					Desc	= EXIT_GAME,
					RefTo 	= IsCustomClient and EscapeMenuButton2 or GameMenuButtonQuit,
					-- see the note on Logout: the QUIT countdown popup is buried
					-- under this menu unless the menu hides on click
					Attrib 	= {hidemenu = true},
					Img 	= [[Interface\RAIDFRAME\ReadyCheck-NotReady]],
				},
				Controller  = {
					Type 	= 'Button',
					Setup 	= maskTemplates,
					Mixin 	= Button,
					ID 		= 4,
					Point 	= {'TOP', 'parent.Exit', 'BOTTOM', 0, -16},
					Desc	= CONTROLS_LABEL,
					Img 	= db.TEXTURE.CP_X_CENTER,
                    Attrib 	= {hidemenu = true}, 
					OnLoadHook = function(self) SetPortraitToTexture(self.Icon, db.TEXTURE.CP_X_CENTER) end,
					OnClick = function() 
						if InCombatLockdown() then
							ConsolePortOldConfig:OnShow()
						else
							ConsolePortOldConfig:Show()
						end
					end,
				},
				Video  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 5,
					Point 	= {'TOP', 'parent.Controller', 'BOTTOM', 0, 0},
					Desc	= VIDEOOPTIONS_MENU, 
					RefTo 	= IsCustomClient and EscapeMenuButton4 or GameMenuButtonOptions,
					-- 5.4.8: every other entry that opens a Blizzard panel carries
					-- hidemenu. Without it the ConsolePort menu stays shown behind the
					-- options frame, and its secure environment keeps the override
					-- bindings it installs while open -- so every bound key (M, C, bags,
					-- and the menu toggle itself) is swallowed until a /reload.
					Attrib 	= {hidemenu = true},
					Img 	= [[Interface\Icons\Ability_TownWatch]], 
					OnLoadHook = function(self) SetPortraitToTexture(self.Icon, ICON:format('Ability_TownWatch')) end,
				},
				Audio  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 6,
					Point 	= {'TOP', 'parent.Video', 'BOTTOM', 0, 0},
					Desc	= VOICE_SOUND,
					-- MoP has neither GameMenuButtonAudioOptions nor
					-- GameMenuButtonSoundOptions -- audio moved inside the
					-- system options panel -- so open AudioOptionsFrame directly.
					RefTo 	= IsCustomClient and EscapeMenuButton5 or GameMenuButtonAudioOptions or GameMenuButtonSoundOptions,
					-- TAINT. This entry used to call ShowUIPanel(AudioOptionsFrame) and
					-- HideUIPanel(GameMenuFrame) from here. Both dispatch through the
					-- SECURE FramePositionDelegate (UIParent.lua:2283), so calling
					-- them from addon Lua taints the panel manager -- and after that
					-- every panel-opening binding silently stops working: M, C, bags,
					-- and the game menu itself, with no error and the bindings still
					-- perfectly intact. Escape keeps cancelling casts because that is
					-- not a panel action. That is exactly the reported symptom.
					--
					-- It is also why ONLY this entry did it. Video and Interface set
					-- RefTo, so DrawIndex turns them into a secure '/click
					-- GameMenuButtonOptions' macro, and Blizzard's own OnClick calls
					-- ShowUIPanel from untainted code. MoP has no
					-- GameMenuButtonAudioOptions, so Audio was the one entry left
					-- running insecure Lua.
					--
					-- :Show() does not go near the panel manager. The menu closes via
					-- the hidemenu macro below, which is secure.
					OnClick = (not IsCustomClient
						and not GameMenuButtonAudioOptions
						and not GameMenuButtonSoundOptions
						and AudioOptionsFrame) and function(self)
							-- OptionsFrame_OnShow clicks categoryFrame.buttons[1] and
							-- indexes its .element unguarded, so showing this frame
							-- before its category list is populated raises
							-- "attempt to index local 'panel'".
							local audio = AudioOptionsFrame
							if audio and audio.categoryList and #audio.categoryList > 0 then
								audio:Show()
							elseif VideoOptionsFrame then
								VideoOptionsFrame:Show()
							end
						end or nil,
					-- 5.4.8: every other entry that opens a Blizzard panel carries
					-- hidemenu. Without it the ConsolePort menu stays shown behind the
					-- options frame, and its secure environment keeps the override
					-- bindings it installs while open -- so every bound key (M, C, bags,
					-- and the menu toggle itself) is swallowed until a /reload.
					Attrib 	= {hidemenu = true},
					Img 	= [[Interface\FriendsFrame\PlusManz-BattleNet]],
				},
				Interface  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 7,
					Point 	= {'TOP', 'parent.Audio', 'BOTTOM', 0, 0},
					Desc	= UIOPTIONS_MENU, 
					RefTo 	= IsCustomClient and EscapeMenuButton8 or GameMenuButtonUIOptions,
					-- 5.4.8: every other entry that opens a Blizzard panel carries
					-- hidemenu. Without it the ConsolePort menu stays shown behind the
					-- options frame, and its secure environment keeps the override
					-- bindings it installs while open -- so every bound key (M, C, bags,
					-- and the menu toggle itself) is swallowed until a /reload.
					Attrib 	= {hidemenu = true},
					Img 	= [[Interface\TUTORIALFRAME\UI-TutorialFrame-GloveCursor]],
				},
				AddOns  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 8,
					Point 	= {'TOP', 'parent.Interface', 'BOTTOM', 0, 0},
					Desc	= ADDONS, 
                    Attrib 	= {hidemenu = true},
					OnClick = function(self)
						if IsCustomClient then
							ShowAddonsPanel()
							return
						end
						-- 5.4.8: PanelTemplates_SetTab only repaints the tab. The work
						-- of swapping the lists lives in InterfaceOptionsFrame_TabOnClick,
						-- which the tab's own OnClick calls -- so setting the tab and
						-- then hand-toggling the two list frames left the RIGHT-HAND
						-- pane showing whatever Blizzard category was last selected
						-- (hence the Interface > Controls panel instead of AddOns).
						-- Blizzard's own InterfaceOptionsFrame_OpenToCategory does
						-- exactly what is below: click the tab, then click a row.
						if InterfaceOptionsFrame_Show then
							InterfaceOptionsFrame_Show()
						elseif InterfaceOptionsFrame then
							InterfaceOptionsFrame:Show()
						end
						-- Tab2 only exists once at least one addon has registered a
						-- panel; with none there is no AddOns list to show at all.
						local tab = _G.InterfaceOptionsFrameTab2
						if tab and tab:IsShown() then
							tab:Click()
							-- Select the first addon so the pane is not left blank or
							-- stale on whatever was open before.
							local list = _G.InterfaceOptionsFrameAddOns
							local button = list and list.buttons and list.buttons[1]
							if button and button.element and InterfaceOptionsListButton_OnClick then
								InterfaceOptionsListButton_OnClick(button)
							end
						end
					end,
					Img 	= ICON:format('inv_misc_wrench_01'),
					OnLoadHook = function(self) SetPortraitToTexture(self.Icon, ICON:format('inv_misc_wrench_01')) end,
				},
				Macros  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 9,
					Point 	= {'TOP', 'parent.AddOns', 'BOTTOM', 0, -16},
					Desc	= MACROS, 
					RefTo 	= IsCustomClient and EscapeMenuButton11 or GameMenuButtonMacros,
					-- 5.4.8: every other entry that opens a Blizzard panel carries
					-- hidemenu. Without it the ConsolePort menu stays shown behind the
					-- options frame, and its secure environment keeps the override
					-- bindings it installs while open -- so every bound key (M, C, bags,
					-- and the menu toggle itself) is swallowed until a /reload.
					Attrib 	= {hidemenu = true},
					Img 	= ICON:format('trade_engineering'),
					LoadScript = function(self) SetPortraitToTexture(self.Icon, ICON:format('trade_engineering')) end,
				},
				KeyBindings  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 10,
					Point 	= {'TOP', 'parent.Macros', 'BOTTOM', 0, 0},
					Desc	= KEY_BINDINGS, 
					RefTo 	= IsCustomClient and EscapeMenuButton9 or GameMenuButtonKeybindings,
					-- 5.4.8: every other entry that opens a Blizzard panel carries
					-- hidemenu. Without it the ConsolePort menu stays shown behind the
					-- options frame, and its secure environment keeps the override
					-- bindings it installs while open -- so every bound key (M, C, bags,
					-- and the menu toggle itself) is swallowed until a /reload.
					Attrib 	= {hidemenu = true},
					Img 	= [[Interface\MacroFrame\MacroFrame-Icon]],
				},
				Help  = {
					Type 	= 'Button',
					Setup 	= baseTemplates,
					Mixin 	= Button,
					ID 		= 11,
					Point 	= {'TOP', 'parent.KeyBindings', 'BOTTOM', 0, 0},
					Desc	= HELP_LABEL, 
					RefTo 	= GameMenuButtonHelp and GameMenuButtonHelp or HelpMicroButton,
                    Attrib 	= {hidemenu = true},
					Img 	= ICON:format('INV_Misc_QuestionMark'),
					OnLoadHook = function(self) SetPortraitToTexture(self.Icon, ICON:format('INV_Misc_QuestionMark')) end,
				}, 
			},
		},
	},
})

-- In case we're adding the loot dropdown
tinsert(maskTemplates, 'SecureHandlerBaseTemplate')
local lootWireFrame = {
	Loot = {
		Type 	= 'CheckButton',
		Setup 	= {
			'SecureHandlerBaseTemplate',
			'SecureHandlerShowHideTemplate',
			'SecureHandlerClickTemplate',
			'CPUIListCategoryTemplate',
		},
		Point 	= {'CENTER', 490, 0},
		Text	= [[|TInterface\Buttons\UI-GroupLoot-Dice-Up:24:24:0:-2|t]],
		Width 	= 50,
		ID = 5,
		OnLoad = function(self)
			CPAPI.SetShown(self,
				GroupLootFrame1:IsVisible() or
				GroupLootFrame2:IsVisible() or
				GroupLootFrame3:IsVisible() or
				GroupLootFrame4:IsVisible())-- or
				--BonusRollFrame:IsVisible())
		end,
		HideOtherHeader = function(self, headername)
			ret = {}
			for i = 1, select('#', _G[headername]:GetChildren()) do
				ret[i] = select(i, _G[headername]:GetChildren())
			end
		 
			local buttons = ret
			_G[headername]:SetAttribute('focused', false)
			for _, button in pairs(buttons) do
				button:Hide()
			end
		end,
		Multiple = {
			Probe = {
				{GroupLootFrame1, 'showhide'},
				{GroupLootFrame2, 'showhide'},
				{GroupLootFrame3, 'showhide'},
				{GroupLootFrame4, 'showhide'},
			--	{BonusRollFrame, 'showhide'},
			},
			SetAttribute = {
				{'_onclick', [[
				--control:RunFor(self:GetParent(), self:GetParent():GetAttribute("ShowHeader"), self:GetID()) 
				local currHeader = self:GetParent():GetAttribute("currentHeader")
				if(currHeader) then
					control:CallMethod('HideOtherHeader', currHeader)
				end
				local buttons = newtable(self:GetChildren())
				for _, button in pairs(buttons) do
					local condition = button:GetAttribute('condition')
					if condition then
						local show = control:Run(condition)
						if show then
							button:Show()
						else
							button:Hide()
						end
					else
						button:Show()
					end
				end
				self:GetParent():SetAttribute("currentHeader", self:GetName())
				]]},
				{'onheaderset', lootHeaderOnSetScript},
			},
		},
		{
			Loot1  = {
				Type 	= 'Button',
				Setup 	= maskTemplates,
				Mixin 	= LootButton,
				ID 		= 1,
				Img 	= ICON:format('INV_Misc_QuestionMark'),
				Obj 	= GroupLootFrame1,
				Probe 	= {GroupLootFrame1, 'probescript', nil, lootButtonProbeScript},
				RegisterForClicks = {'AnyUp', 'AnyDown'},
				Multiple = {
					SetAttribute = {
						{'circleclick', 'control:CallMethod("OnCircleClicked")'},
						{'squareclick', 'control:CallMethod("OnSquareClicked")'},
						{'triangleclick', 'control:CallMethod("OnTriangleClicked")'},
						{'pc', 0},
						{'condition', 'return false'},
					},
				},
			},
			Loot2  = {
				Type 	= 'Button',
				Setup 	= maskTemplates,
				Mixin 	= LootButton,
				ID 		= 2,
				Obj 	= GroupLootFrame2,
				Img 	= ICON:format('INV_Misc_QuestionMark'),
				Probe 	= {GroupLootFrame2, 'probescript', nil, lootButtonProbeScript},
				RegisterForClicks = {'AnyUp', 'AnyDown'},
				Multiple = {
					SetAttribute = {
						{'circleclick', 'control:CallMethod("OnCircleClicked")'},
						{'squareclick', 'control:CallMethod("OnSquareClicked")'},
						{'triangleclick', 'control:CallMethod("OnTriangleClicked")'},
						{'pc', 0},
						{'condition', 'return false'},
					},
				},
			},
			Loot3  = {
				Type 	= 'Button',
				Setup 	= maskTemplates,
				Mixin 	= LootButton,
				ID 		= 3,
				Obj 	= GroupLootFrame3,
				Img 	= ICON:format('INV_Misc_QuestionMark'),
				Probe 	= {GroupLootFrame3, 'probescript', nil, lootButtonProbeScript},
				RegisterForClicks = {'AnyUp', 'AnyDown'},
				Multiple = {
					SetAttribute = {
						{'circleclick', 'control:CallMethod("OnCircleClicked")'},
						{'squareclick', 'control:CallMethod("OnSquareClicked")'},
						{'triangleclick', 'control:CallMethod("OnTriangleClicked")'},
						{'pc', 0},
						{'condition', 'return false'},
					},
				},
			},
			Loot4  = {
				Type 	= 'Button',
				Setup 	= maskTemplates,
				Mixin 	= LootButton,
				ID 		= 4,
				Obj 	= GroupLootFrame4,
				Img 	= ICON:format('INV_Misc_QuestionMark'),
				Probe 	= {GroupLootFrame4, 'probescript', nil, lootButtonProbeScript},
				RegisterForClicks = {'AnyUp', 'AnyDown'},
				Multiple = {
					SetAttribute = {
						{'circleclick', 'control:CallMethod("OnCircleClicked")'},
						{'squareclick', 'control:CallMethod("OnSquareClicked")'},
						{'triangleclick', 'control:CallMethod("OnTriangleClicked")'},
						{'pc', 0},
						{'condition', 'return false'},
					},
				},
			},
			-- Bonus  = {
			-- 	Type 	= 'Button',
			-- 	Setup 	= maskTemplates,
			-- 	Mixin 	= LootButton,
			-- 	ID 		= 5,
			-- 	NoMask 	= true,
			-- 	Obj 	= BonusRollFrame,
			-- 	Img 	= ICON:format('INV_Misc_QuestionMark'),
			-- 	Probe 	= {BonusRollFrame, 'probescript', nil, lootButtonProbeScript},
			-- 	RegisterForClicks = {'AnyUp', 'AnyDown'},
			-- 	Multiple = {
			-- 		SetAttribute = {
			-- 			{'pc', 0},
			-- 			{'condition', 'return false'},
			-- 		},
			-- 	},
			-- },
		},
	},
}

do	
	ConsolePortUIConfig.Menu = ConsolePortUIConfig.Menu or {}

	local cfg = ConsolePortUIConfig.Menu

	cfg.lootprobe = cfg.lootprobe and true or false 
	cfg.scale = cfg.scale or 1

	if cfg.lootprobe then
		UI:BuildFrame(Menu, lootWireFrame)
	end

	lootWireFrame = nil
	maskTemplates = nil
	baseTemplates = nil

	CPAPI.Mixin(Menu, ConsolePortMenuSecureMixin, ConsolePortMenuArtMixin)

	Menu:StartEnvironment()
	Menu:Execute('hID, bID = 4, 1')
	Menu:DrawIndex(function(header)
		-- Same treatment as the buttons: this client will not render the
		-- XML-declared <ButtonText> on the SELECTED header, so build the caption
		-- in Lua where no XML parsing is involved. See the long note in
		-- Menu_Button.lua for the evidence.
		if header.CreateFontString and not header.CPCaption then
			local caption = header:CreateFontString(nil, 'OVERLAY')
			caption:SetFontObject(AchievementPointsFont or GameFontNormal)
			if not caption:GetFont() then
				caption:SetFont([[Fonts\FRIZQT__.TTF]], 16)
			end
			caption:SetPoint('CENTER', header, 'CENTER', 0, 0)
			caption:SetJustifyH('CENTER')
			caption:SetText(header:GetText() or '')
			caption:Show()
			header.CPCaption = caption
			local old = header.GetFontString and header:GetFontString()
			if old then old:Hide() end
			if header.SetFontString then header:SetFontString(caption) end
		end

		-- CPUIListCategoryTemplate's OnFocusAnim uses childKey / fromScaleX /
		-- toScaleX, none of which exist in 5.4.8's schema. With them dropped the
		-- Scale targets the header itself and defaults to zero, so playing it on
		-- selection is at best meaningless and at worst destructive. The mixin
		-- only plays it `if header.OnFocusAnim`, so clearing it disables it.
		if header.OnFocusAnim then
			pcall(function() header.OnFocusAnim:Stop() end)
			header.OnFocusAnim = nil
		end

		for i, button in ipairs({header:GetChildren()}) do

			

			if button:GetAttribute('hidemenu') then
				button:SetAttribute('type', 'macro')

				if(IsCustomClient) then
					button:SetAttribute('macrotext', '/click EscapeMenuButton1')
				else
					button:SetAttribute('macrotext', '/click GameMenuButtonContinue')
				end

			end
			if button.RefTo then
				local macrotext = button:GetAttribute('macrotext')
				local prefix = (macrotext and macrotext .. '\n') or ''  
				button:SetAttribute('macrotext', prefix .. '/click ' .. button.RefTo:GetName())
				button:SetAttribute('type', 'macro')  

			end
			button:Hide()
			header:SetFrameRef(tostring(button:GetID()), button)
		end
	end)


	UI:RegisterFrame(Menu, 'Menu', false, true)
	UI:HideFrame(IsCustomClient and EscapeMenu or GameMenuFrame, true)

	Menu:SetScale(cfg.scale)
	Menu:LoadArt()

	L.Menu = Menu
end

--[[

Character
	Character Info
	Backpack (inventory)
	Spec&Talents
	Spell book
	Collections
Gameplay
	Quest/Map
	Adventure Guide
	Group Finder
	Achievements
	What's New
	Shop
- 	Teleport
Social
	Friends List
	Guild (guild finder)
	Raid
	Events (Calendar)
-	Leave Group
System
	Return to game
	Logout
	Exit Game

	Controller
	System (settings)
	Interface

	AddOns
	Macros

	Key bindings
	Help
]]
