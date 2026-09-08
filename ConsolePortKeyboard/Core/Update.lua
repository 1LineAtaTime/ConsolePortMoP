---------------------------------------------------------------
-- Update handler to grab the current keyboard focus
---------------------------------------------------------------
local Keyboard = ConsolePortKeyboard
local GetFocus = GetCurrentKeyBoardFocus
local isEnabled = true
local focus

-- Belt and braces for the loop described in Mime.lua: even with Mime and Auto
-- disabled, anything the keyboard owns must never count as "the user is typing
-- somewhere", or the keyboard opens for itself and can never close.
local function IsOwnEditBox(frame)
	for _ = 1, 6 do
		if not frame then return false end
		if frame == Keyboard then return true end
		frame = frame.GetParent and frame:GetParent()
	end
	return false
end

local function UpdateKeyboardFocus(self, elapsed)
	if isEnabled then
		focus = GetFocus()
		if focus and IsOwnEditBox(focus) then
			-- Treat as no focus at all, so the branch below closes the keyboard
			-- instead of re-targeting it at itself.
			focus = nil
		end
		if focus and focus:IsObjectType("EditBox") and Keyboard.Focus ~= focus then
			Keyboard:SetFocus(focus)
		elseif not focus and Keyboard.Focus then
			Keyboard:CLOSE()
		end
	end
end

function Keyboard:SetEnabled(state)
	isEnabled = state
	if isEnabled then
		ConsolePort:AddUpdateSnippet(UpdateKeyboardFocus)
	else
		ConsolePort:RemoveUpdateSnippet(UpdateKeyboardFocus)
		if Keyboard.Focus then
			Keyboard:CLOSE()
		end
	end
end