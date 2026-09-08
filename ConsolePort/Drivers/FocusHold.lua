local addOn, db = ...
local CPAPI = db.CPAPI

if CPAPI:IsClassicVersion() then return end

-- This driver has never actually run on any client: the old WOW_PROJECT_ID
-- check returned true everywhere, so the line above always bailed out. With an
-- honest version check it would install here for the first time -- and its
-- snippet walks every protected frame under UIParent on each press, setting
-- unit='focus' on all of them, including action buttons that have no unit
-- attribute at all. Untested on 5.4.8, so keep it off for now.
-- To try it: delete the line below (and see the note in the port report).
if CPAPI:IsMoPVersion() then return end
---------------------------------------------------------------
-- FocusHold.lua: Reroute spells to focus target
---------------------------------------------------------------
-- Modified clicks only accept real modifiers, so this handle
-- simulates the FOCUSCAST modifier by caching secure frames
-- and temporarily setting their unit attribute to focus.
-- The net result is the same, but an edge case where a unit
-- attribute is changed between press/release will restore
-- a faulty unit on release.

local FOCUS = ConsolePortFocusButton
FOCUS:SetFrameRef('UIParent', UIParent)
FOCUS:Execute([[
	UIParent = self:GetFrameRef('UIParent')
	CACHE = newtable()
]])
FOCUS:SetAttribute('AddToCache', [[
	local node = CURRENT
	if node:GetAttribute('useparent-unit') or not node:IsProtected() then return end
	
	local children 	= newtable(node:GetChildren())
	CACHE[node] 	= false

	if children then
		for i, child in pairs(children) do
			CURRENT = child
			control:RunFor(self, self:GetAttribute('AddToCache'))
		end
	end
]])

FOCUS:SetAttribute('UpdateUnit', [[
	if CURRENT:GetAttribute('useparent-unit') then return end
	CACHE[CURRENT] = ( CURRENT:GetAttribute('unit') or false )
]])

FOCUS:SetAttribute('UpdateFrameCache', [[
	local frames = newtable(UIParent:GetChildren())
	for i, frame in ipairs(frames) do
		if frame:IsProtected() and not CACHE[frame] then
			CURRENT = frame
			control:RunFor(self, self:GetAttribute('AddToCache'))
		end
	end
	for frame in pairs(CACHE) do
		CURRENT = frame
		control:RunFor(self, self:GetAttribute('UpdateUnit'))
	end
]])

FOCUS:SetAttribute('_onclick', [[
	if down then
		control:RunFor(self, self:GetAttribute('UpdateFrameCache'))
		for node in pairs(CACHE) do
			node:SetAttribute('unit', 'focus')
		end
	else
		for node, originalUnit in pairs(CACHE) do
			node:SetAttribute('unit', originalUnit or nil)
		end
	end
]])