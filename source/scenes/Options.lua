Options = {}
class("Options").extends(NobleScene)

Options.backgroundColor = Graphics.kColorBlack

local messageStyleValues = {"Dark", "Light"}

local background
local menu
local sequence

function Options:init()
	Options.super.init(self)

	background = Graphics.image.new("assets/images/bg/grad2")

	menu = Noble.Menu.new(false, Noble.Text.ALIGN_LEFT, false, Graphics.kColorBlack, 4,6,0)

	menu:addItem(
		"MessageStyle",
		function()
			local oldValue = Noble.Settings.get("MessageStyle")
			local newValue = math.ringInt(
				table.indexOfElement(messageStyleValues, oldValue) + 1,
				1,
				#messageStyleValues
			)
			Noble.Settings.set("MessageStyle", messageStyleValues[newValue])
			menu:setItemDisplayName("MessageStyle", "Message style: " .. messageStyleValues[newValue])
		end,
		nil,
		"Message style: " .. Noble.Settings.get("MessageStyle")
	)

	local skipValStr
	if Noble.Settings.get("AllowSkip") then
		skipValStr = "Yes"
	else
		skipValStr = "No"
	end
	menu:addItem(
		"AllowSkip",
		function()
			local newValue = not Noble.Settings.get("AllowSkip")
			if newValue then
				skipValStr = "Yes"
			else
				skipValStr = "No"
			end
			Noble.Settings.set("AllowSkip", newValue)
			menu:setItemDisplayName("AllowSkip", "Allow skipping: " .. skipValStr)
		end, nil,
		"Allow skipping: " .. skipValStr
	)

	local fpsValStr
	if Noble.Settings.get("FPS") then
		fpsValStr = "Yes"
	else
		fpsValStr = "No"
	end
	menu:addItem(
		"FPS",
		function()
			local newValue = not Noble.Settings.get("FPS")
			Noble.showFPS = newValue
			if newValue then
				fpsValStr = "Yes"
			else
				fpsValStr = "No"
			end
			Noble.Settings.set("FPS", newValue)
			menu:setItemDisplayName("FPS", "Show FPS: " .. fpsValStr)
		end, nil,
		"Show FPS: " .. fpsValStr
	)
	menu:addItem(
		"Back",
		function()
			Noble.transition(Title, 1, Noble.TransitionType.DIP_TO_WHITE)
		end
	)

	local crankTick = 0

	Options.inputHandler = {
		upButtonDown = function()
			menu:selectPrevious()
			Sound.tick()
		end,
		downButtonDown = function()
			menu:selectNext()
			Sound.tick()
		end,
		cranked = function(change, acceleratedChange)
			crankTick = crankTick + change
			if (crankTick > 30) then
				crankTick = 0
				menu:selectNext()
			elseif (crankTick < -30) then
				crankTick = 0
				menu:selectPrevious()
			end
		end,
		AButtonDown = function()
			menu:click()
			Sound.beep()
		end,
		BButtonDown = function()
			Noble.transition(Title, 1, Noble.TransitionType.DIP_TO_WHITE)
			Sound.back()
		end
	}
end

function Options:enter()
	Options.super.enter(self)

	sequence = Sequence.new():from(0):to(100, .5, Ease.outQuad)
	sequence:start()
end

function Options:start()
	Options.super.start(self)

	menu:activate()
end

function Options:drawBackground()
	Options.super.drawBackground(self)

	background:draw(0, 0)
end

function Options:update()
	Options.super.update(self)

	Graphics.setColor(Graphics.kColorWhite)
	Graphics.setDitherPattern(0.2, Graphics.image.kDitherTypeScreen)
	Graphics.fillRoundRect(15, (sequence:get()*0.75)+3, 185, 145, 15)
	menu:draw(30, sequence:get()-15 or 100-15)
end

function Options:exit()
	Options.super.exit(self)

	Noble.Input.setCrankIndicatorStatus(false)
	sequence = Sequence.new():from(100):to(240, 0.25, Ease.inSine)
	sequence:start()
end

function Options:finish()
	Options.super.finish(self)
end
