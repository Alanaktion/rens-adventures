import "script"

Game = {}
class("Game").extends(NobleScene)

Game.backgroundColor = Graphics.kColorWhite

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
local cg
local messageBox
local characters
local darkStyle

local scriptIndex
local chapter
local chapterIndex

function Game:init()
	Game.super.init(self)

	self:setChapter(script[1].name)

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

	cg = NobleSprite()
	cg:setCenter(0, 0)
	cg:moveTo(0, 0)
	cg:setZIndex(80)

	messageBox = NobleSprite()
	messageBox:setImage(images.message)
	messageBox:setCenter(0, 1)
	messageBox:moveTo(0, screenHeight)
	messageBox:setZIndex(90)

	characters = {}

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
	if background ~= nil then
		background:draw(0, 0)
	end
end

function Game:cleanup()
	background = nil
	for key, value in next, characters do
		value:remove()
	end
	characters = {}
	cg:remove()
	txtName:remove()
	txtQuote:remove()
	messageBox:remove()
end

function Game:nextChapter()
	if scriptIndex == #script then
		print("end of script")
		Noble.transition(Ending, 2, Noble.TransitionType.DIP_TO_BLACK)
	else
		self:cleanup()
		chapterIndex = 0
		scriptIndex += 1
		chapter = script[scriptIndex].sequence
		self:advanceScript()
	end
end

function Game:setChapter(chapterName)
	chapterIndex = 0
	scriptIndex = nil
	for key, value in next, script do
		if value.name == chapterName then
			scriptIndex = key
		end
	end
	if scriptIndex ~= nil then
		chapter = script[scriptIndex].sequence
	else
		print("Unknown script chapter " .. chapterName)
	end
end

function Game:seekScript(index)
	-- TODO: seek to a specific point in a script, tracking all of the bg/cg/character
	-- changes without rendering anything. Should roughly implement the Game:advanceScript()
	-- logic to actually render the intended frame once the index is reached.
end

function Game:advanceScript()
	chapterIndex += 1
	local cur = chapter[chapterIndex]
	if cur then

		-- Set background
		if cur.bg ~= nil then
			if cur.bg then
				background = Graphics.image.new("assets/images/bg/" .. cur.bg)
			else
				background = nil
			end
		end

		-- Show CG
		if cur.cg ~= nil then
			if cur.cg then
				local img = Graphics.image.new("assets/images/cg/" .. cur.cg)
				cg:setImage(img)
				cg:add()
			else
				cg:remove()
			end
		end

		-- TODO: support altering z-index of individual characters and the message box

		-- Reveal new characters
		if cur.reveal then
			for key, value in next, cur.reveal do
				local char = Character(value.image)
				if value.center then
					char:setCenter(value.center.x, value.center.y)
				end
				char:moveTo(value.pos.x * screenWidth, value.pos.y * screenHeight)
				if value.flip then
					char:setImageFlip(Graphics.kImageFlippedX)
				end
				characters[key] = char
				char:add()
			end
		end

		-- Move characters
		if cur.move then
			for key, value in next, cur.move do
				if characters[key] then
					local char = characters[key]
					-- TODO: implement eased movement
					if value.pos then
						char:moveTo(value.pos.x * screenWidth, value.pos.y * screenHeight)
					end
					if value.flip ~= nil then
						if value.flip then
							char:setImageFlip(Graphics.kImageFlippedX)
						else
							char:setImageFlip(Graphics.kImageUnflipped)
						end
					end
				else
					print("Cannot move character " .. key .. " that does not exist.")
				end
			end
		end

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
		print("end of chapter " .. scriptIndex)
		self:nextChapter()
	end
end
