Options = {}
class("Options").extends(NobleScene)

Options.backgroundColor = Graphics.kColorBlack

local messageStyleValues = {"Dark", "Light"}

local background
local logo
local menu
local sequence

function Options:init()
	Options.super.init(self)

	background = Graphics.image.new("assets/images/background2")
	logo = Graphics.image.new("libraries/noble/assets/images/NobleRobotLogo")

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
	local valString
	if Noble.Settings.get("FPS") then
		valString = "Yes"
	else
		valString = "No"
	end
	menu:addItem(
		"FPS",
		function()
			local oldValue = Noble.Settings.get("FPS")
			local newValue = not oldValue
			Noble.showFPS = newValue
			local valString
			if newValue then
				valString = "Yes"
			else
				valString = "No"
			end
			Noble.Settings.set("FPS", newValue)
			menu:setItemDisplayName("FPS", "Show FPS: " .. valString)
		end, nil,
		"Show FPS: " .. valString
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
		end,
		downButtonDown = function()
			menu:selectNext()
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
		end,
		BButtonDown = function()
			Noble.transition(Title, 1, Noble.TransitionType.DIP_TO_WHITE)
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

	Graphics.setColor(Graphics.kColorBlack)
	Graphics.fillRoundRect(260, -20, 130, 65, 15)
	logo:setInverted(false)
	logo:draw(275, 8)
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
