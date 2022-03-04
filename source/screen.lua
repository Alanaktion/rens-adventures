local gfx = playdate.graphics

class("Screen").extends()

Screen.currentInstance = nil
Screen.currentName = nil
Screen.lastName = nil

function Screen.change(newName, newInstance)
	print("[info] changing screen to " .. newName)
	if Screen.currentInstance ~= nil then
		Screen.currentInstance:hide()
		Screen.currentInstance = nil
		Screen.lastName = Screen.currentName
	end
	Screen.currentName = newName
	Screen.currentInstance = newInstance
	Screen.currentInstance:show()
end

function Screen.back()
	-- TODO: allow modal screens that keep previous screen instance intact
	-- but still prevent it from rendering over the "modal" screen or taking input
	local instance = nil
	if Screen.lastName == "title" then
		instance = Title()
	elseif Screen.lastName == "game" then
		instance = Game()
	elseif Screen.lastName == "over" then
		instance = Over()
	end
	Screen.change(Screen.lastName, instance)
end

function Screen:init()
	self.visible = false
	self.transitioning = false
end

function Screen:show()
	self.visible = true
end

function Screen:hide()
	gfx.sprite.removeAll()
	self.visible = false
end

local fadeToBlackPanel = gfx.image.new(400, 240, gfx.kColorBlack)
local fadeToWhitePanel = gfx.image.new(400, 240, gfx.kColorWhite)

function Screen:fadeToWhite(callback)
	if self.transitioning then
		return
	end
	self.transitionProgress = 0
	self.transitioning = true
	self.transitionCallback = callback
	self.transitionAnimator = gfx.animator.new(500, 0, 1, playdate.easingFunctions.outQuad)
	gfx.sprite.removeAll()
end

function Screen:update()
	if self.transitioning then
		if self.transitionAnimator:ended() then
			self.transitioning = false
			if self.transitionCallback ~= nil then
				self.transitionCallback()
			end
		else
			fadeToWhitePanel:drawFaded(0, 0, self.transitionAnimator:currentValue(), gfx.image.kDitherTypeBayer8x8)
		end
	else
		gfx.sprite.update()
	end
end
