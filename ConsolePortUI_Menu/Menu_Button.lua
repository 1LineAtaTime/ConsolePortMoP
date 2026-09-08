local _, L = ...
local db = ConsolePort:GetData()
local CPAPI = db.CPAPI
local Button  = {}
L.Button = Button

function Button:OnHide()
	self:OnLeave()
	db.UIFrameFadeOut(self, 0.1, self:GetAlpha(), 0)
end

function Button:OnShow()
	self:Animate()
end

function Button:Animate()
	local id = self:GetID() or 1
	CPAPI.TimerAfter(id * 0.01, function()
		db.UIFrameFadeIn(self, 0.1, self:GetAlpha(), 1)
	end)
end

function Button:OnLoad()
	CPAPI.Mixin(self, ConsolePortMenuButtonMixin)  
	self.Icon = _G[self:GetName().."Icon"]
	self:SetHint(ConsolePortUIHandle, db.KEY.CROSS, ACCEPT)
	self:SetHintTriggers(true)
	self.Icon:SetTexture(self.Img)
	self:SetText(self.Desc)

	-- 5.4.8: the XML-declared <ButtonText> on this template will not render on
	-- this client. Every property is provably correct and identical to a button
	-- that DOES render -- text, font file, font height 12, measured string width
	-- 62.9px, colour, alpha 1, IsVisible true, position inside the button, draw
	-- layer OVERLAY, same font objects, same button state. Hiding every child
	-- frame and the highlight texture changed nothing, so it is not occlusion.
	-- Nothing exposed through the Lua API distinguishes the two.
	--
	-- This client also demonstrably mis-parses parts of these templates: the
	-- dotted $parent.Key anchors in FrameXML.log, the <MaskTexture> element it
	-- has no schema for, the childKey/fromScaleX animation attributes, and the
	-- <NormalFont> elements added earlier that never took effect. So rather than
	-- keep guessing which attribute got dropped, stop trusting the XML for this
	-- widget and build the label in Lua -- which is exactly what upstream did
	-- before the 2.0.0 refactor moved it into XML (commit 743bcf41).
	local label = self.Label or (self.GetFontString and self:GetFontString())
	if label and label.Hide then
		label:Hide()          -- retire the XML one, keep it for reference
	end

	local text = self:CreateFontString(nil, 'OVERLAY')
	text:SetFontObject(GameFontNormal)
	-- explicit SetFont as well: if the font object itself is what this client
	-- fails to resolve for these frames, this bypasses it entirely
	if not text:GetFont() then
		text:SetFont([[Fonts\FRIZQT__.TTF]], 12)
	end
	text:SetPoint('LEFT', self, 'LEFT', 60, 0)
	text:SetWidth(150)
	text:SetJustifyH('LEFT')
	text:SetJustifyV('MIDDLE')
	text:SetTextColor(1, 0.82, 0, 1)
	text:SetText(self.Desc)
	text:Show()

	self.CPLabel = text
	if self.SetFontString then
		self:SetFontString(text)
	end

	if self.OnLoadHook then
		self:OnLoadHook()
		self.OnLoadHook = nil
	end
end