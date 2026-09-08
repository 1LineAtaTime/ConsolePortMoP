local addOn, Language = ...
local Keyboard = ConsolePortKeyboard
local class = select(2, UnitClass("player"))
local cc = RAID_CLASS_COLORS[class]
local Fade = ConsolePort:GetData().UIFrameFadeIn
---------------------------------------------------------------
-- EditBox mime (mimicks entered text in focused editbox)
---------------------------------------------------------------
local Mime = CreateFrame("EditBox", "$parentMime", Keyboard)
-- Restored (upstream has this active; ConsolePortLK commented it out, and that
-- one character is the whole bug). Mime is an EditBox parented to the on-screen
-- keyboard. Left ENABLED it can take keyboard focus itself -- and Update.lua
-- reacts to "an EditBox has focus" by opening the keyboard for it. So the
-- keyboard opens for its own mime, GetCurrentKeyBoardFocus() never returns nil
-- again, Keyboard:CLOSE() is never reached, and the frame holds every keystroke
-- in the game until /reload. Disabled it cannot take focus, which is the point.
Mime:Disable()
Mime:SetPoint("LEFT", Keyboard, "CENTER", 0, 70)
Mime:SetSize(1, 1)
Mime.Text = Mime:CreateFontString("$parentText", "BACKGROUND")
Mime.Text:SetFont("Interface\\AddOns\\ConsolePortKeyboard\\Fonts\\arial.TTF", 18)
Mime.Text:SetShadowColor(0, 0, 0, 1)
Mime.Text:SetShadowOffset(2, -2)
Mime.Text:SetPoint("LEFT", Mime, "LEFT", 0, 0)

Mime.Backdrop = Keyboard:CreateTexture(nil, "BACKGROUND")
Mime.Backdrop:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
Mime.Backdrop:SetBlendMode("ADD")
Mime.Backdrop:SetVertexColor(cc.r, cc.g, cc.b, 0.25)
Mime.Backdrop:SetAlpha(0)
Mime.Backdrop:SetPoint("CENTER", Keyboard, 0, 70)
Mime.Backdrop:SetSize(300, 30)

Mime.offset = 0

Mime.AniGroup = Mime:CreateAnimationGroup()
Mime.Animation = Mime.AniGroup:CreateAnimation("Translation")
Mime.Animation:SetDuration(0.2)
Mime.Animation:SetSmoothing("OUT")

Keyboard.Mime = Mime

function Mime:OnTextSet()
	local text = self:GetText()
	Fade(self.Backdrop, 0.2, self.Backdrop:GetAlpha(), text:trim() == "" and 0 or 0.25)
	for pattern, replacement in pairs(Language.Markers) do
		text = text:gsub(pattern:gsub("%%", "%%%%"), replacement)
	end
	self.Text:SetText(text)
	self.Text:SetTextColor(self:GetTextColor())
	self:Animate()
end

function Mime:OnFinished()
	local self = self:GetParent()
	self:ClearAllPoints()
	self:SetPoint("LEFT", Keyboard, "CENTER", -self.Text:GetWidth()/2, 70)
end

function Mime:Animate()
	local newX = self.Text:GetWidth()/2
	Mime.Animation:SetOffset(self.offset-newX, 0)
	Mime.AniGroup:Play()
	self.offset = newX
end

function Mime:Hide()
	self:SetText("")
end

Mime.AniGroup:SetScript("OnFinished", Mime.OnFinished)
Mime:SetScript("OnTextSet", Mime.OnTextSet)
Mime:SetScript("OnHide", Mime.Hide)