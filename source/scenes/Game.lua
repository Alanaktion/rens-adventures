Game = {}
class("Game").extends(NobleScene)

Game.backgroundColor = Graphics.kColorWhite

import "scripts/intro"
local script = intro

local screenWidth = playdate.display.getWidth()
local screenHeight = playdate.display.getHeight()

local background
local txtName
local txtQuote
local darkImages = {
	message = Graphics.image.new("assets/images/message"),
	messageWithName = Graphics.image.new("assets/images/message-with-name")
}
local lightImages = {
	message = Graphics.image.new("assets/images/message-light"),
	messageWithName = Graphics.image.new("assets/images/message-light-with-name")
}
local images
local messageBox
local characters
local scriptIndex
local darkStyle

function Game:init()
	Game.super.init(self)

	background = Graphics.image.new("assets/images/background-light-pattern")

	darkStyle = Noble.Settings.get("MessageStyle") == "Dark"

	txtName = Text()
	txtName:setFontSize(12)
	txtName:setCenter(.5,0)
	txtName:moveTo(35, screenHeight - 80)
	if darkStyle then
		txtName:setInvert(true)
	end

	txtQuote = Text()
	txtQuote:setRect(6, screenHeight - 58, screenWidth - 12, 54)
	if darkStyle then
		txtQuote:setInvert(true)
	end

	if darkStyle then
		images = darkImages
	else
		images = lightImages
	end

	messageBox = NobleSprite()
	messageBox:setImage(images.message)
	messageBox:setCenter(0, 1)
	messageBox:moveTo(0, screenHeight)
	messageBox:setZIndex(90)

	characters = {}
	scriptIndex = 0

	local crankTick = 0

	Game.inputHandler = {
		cranked = function(change, acceleratedChange)
			-- TODO: show message history when crank is undocked
			crankTick = crankTick + change
			if (crankTick > 30) then
				crankTick = 0
				-- TODO: navigate forward in message history
			elseif (crankTick < -30) then
				crankTick = 0
				-- TODO: navigate back in message history
			end
		end,
		AButtonDown = function()
			self:advanceScript()
		end
	}
end

function Game:start()
	Game.super.start(self)
	self:advanceScript()
end

function Game:drawBackground()
	Game.super.drawBackground(self)
	background:draw(0, 0)
end

function Game:advanceScript()
	scriptIndex += 1
	local cur = script[scriptIndex]
	if cur then

		-- Reveal new characters
		if cur.reveal then
			for key, value in next, cur.reveal do
				char = Character(value.image)
				char:moveTo(value.pos.x * screenWidth, value.pos.y * screenHeight)
				if value.flip then
					char:setImageFlip(Graphics.kImageFlippedX)
				end
				characters[key] = char
				char:add()
			end
		end

		-- Animate characters with motion
		-- TODO: implement a simple way to move characters around with easing

		-- Hide departing characters
		if cur.hide then
			for key, value in next, cur.hide do
				if characters[value] then
					characters[value]:remove()
					characters[value] = nil
				else
					print("Cannot hide character " .. value .. " that does not exist.")
				end
			end
		end

		-- Show message text
		if cur.text then
			if cur.name then
				messageBox:setImage(images.messageWithName)
				txtName:add()
				txtName:setText(cur.name)
			else
				messageBox:setImage(images.message)
				txtName:remove()
			end
			txtQuote:setText(cur.text)
			txtQuote:add()
			messageBox:add()
		else
			txtQuote:remove()
			txtName:remove()
			messageBox:remove()
		end

	else
		print("end of script")
		Noble.transition(Ending, 2, Noble.TransitionType.DIP_TO_BLACK)
	end
end
