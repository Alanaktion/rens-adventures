Game = {}
class("Game").extends(NobleScene)

Game.backgroundColor = Graphics.kColorWhite

local screenWidth = playdate.display.getWidth()
local screenHeight = playdate.display.getHeight()

local allowSkip
local darkStyle

local background
local txtName
local txtQuote
local txtTitle
-- TODO: maybe draw these as rounded rects instead of images? could match name width, etc.
local darkImages = {
	message = Graphics.image.new("assets/images/message"),
	messageWithName = Graphics.image.new("assets/images/message-with-name")
}
local lightImages = {
	message = Graphics.image.new("assets/images/message-light"),
	messageWithName = Graphics.image.new("assets/images/message-light-with-name")
}
local images
local eventCg
local messageBox
local characters

local inputMode
local scriptIndex
local chapter
local chapterIndex
local choice
local choiceMenu

function Game:init()
	Game.super.init(self)

	allowSkip = Noble.Settings.get("AllowSkip")
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

	txtTitle = Text()
	txtTitle:setFontSize(16)
	txtTitle:setRect(6, screenHeight / 2 - 32, screenWidth - 12, 64)
	txtTitle:setAlignment(kTextAlignment.center)

	if darkStyle then
		images = darkImages
	else
		images = lightImages
	end

	eventCg = NobleSprite()
	eventCg:setCenter(0, 0)
	eventCg:moveTo(0, 0)
	eventCg:setZIndex(80)

	messageBox = NobleSprite()
	messageBox:setImage(images.message)
	messageBox:setCenter(0, 1)
	messageBox:moveTo(0, screenHeight)
	messageBox:setZIndex(90)

	inputMode = "script"
	characters = {}
	choice = nil
	choiceMenu = nil

	self:setChapter(SaveData.current.chapter)
	if SaveData.current.chapterIndex > 0 then
		self:seekScript(SaveData.current.chapterIndex)
	end

	local crankTick = 0

	Game.inputHandler = {
		crankUndocked = function()
			-- TODO: show message history
		end,
		crankDocked = function()
			-- TODO: hide message history
		end,
		cranked = function(change, acceleratedChange)
			crankTick = crankTick + change
			if (crankTick > 30) then
				crankTick = 0
				-- TODO: navigate forward in message history
			elseif (crankTick < -30) then
				crankTick = 0
				-- TODO: navigate back in message history
			end
		end,
		upButtonDown = function()
			if inputMode == "choice" then
				choiceMenu:selectPrevious()
				Sound.beep()
			end
		end,
		downButtonDown = function()
			if inputMode == "choice" then
				choiceMenu:selectNext()
				Sound.beep()
			end
		end,
		AButtonDown = function()
			if inputMode == "script" then
				self:advanceScript()
			elseif inputMode == "choice" then
				choiceMenu:click()
				Sound.confirm()
				inputMode = "script"
				self:advanceScript()
			end
		end,
		BButtonDown = function()
			if inputMode == "choice" then
				for key, value in next, choice do
					if value.default then
						choiceMenu:select(key)
						Sound.beep()
						return
					end
				end
			end
		end,
		BButtonHold = function()
			if inputMode == "script" and allowSkip then
				self:advanceScript()
			end
		end
	}
end

function Game:enter()
	Game.super.enter(self)
	self:advanceScript()
end

function Game:update()
	Game.super.update(self)

	if choice ~= nil then
		choiceMenu:draw(8, 8)
	end
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
	eventCg:remove()
	txtName:remove()
	txtQuote:remove()
	txtTitle:remove()
	messageBox:remove()
end

function Game:nextChapter()
	if scriptIndex == #script then
		print("end of script")
		-- Delete autosave after game ends?
		-- SaveData.delete()
		Noble.transition(Ending, 2, Noble.TransitionType.DIP_TO_BLACK)
	else
		self:cleanup()
		chapterIndex = 0
		scriptIndex += 1
		chapter = script[scriptIndex].sequence
		SaveData.current.chapter = script[scriptIndex].name
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
		SaveData.current.chapter = script[scriptIndex].name
	else
		print("Unknown script chapter " .. chapterName)
	end
end

function Game:seekScript(__index)
	local index = __index - 1

	-- Don't seek if not going anywhere :P
	if index <= 0 then
		return
	end

	-- Limit to end of chapter as a safeguard
	if index >= #chapter then
		index = #chapter - 1
	end

	local bg
	local cg
	local chara = {}
	local text
	local name
	local title
	local titleInvert

	-- Seek script to specified index, tracking changes
	while chapterIndex < index do
		repeat
			chapterIndex += 1
			local cur = chapter[chapterIndex]
			if cur == nil then
				break
			end

			if cur.check ~= nil then
				if cur.check() == false then
					break
				end
			end

			if cur.bg ~= nil then
				if cur.bg then
					bg = cur.bg
				else
					bg = nil
				end
			end

			if cur.cg ~= nil then
				if cur.cg then
					cg = cur.cg
				else
					cg = nil
				end
			end

			if cur.reveal ~= nil then
				for key, value in next, cur.reveal do
					chara[key] = value
				end
			end

			if cur.move ~= nil then
				for key, value in next, cur.move do
					if chara[key] ~= nil then
						local char = characters[key]
						if value.pos ~= nil then
							char.pos = value.pos
						end
						if value.flip ~= nil then
							char.flip = value.flip
						end
					else
						print("Cannot move character " .. key .. " that does not exist.")
					end
				end
			end

			if cur.hide ~= nil then
				for key, value in next, cur.hide do
					if chara[value] ~= nil then
						chara[value] = nil
					else
						print("Cannot hide character " .. value .. " that does not exist.")
					end
				end
			end

			text = cur.text
			name = cur.name
			title = cur.title
			titleInvert = cur.titleInvert

		until true
	end

	-- Render resulting frame
	if bg ~= nil then
		Game:setBg(bg)
	end
	if cg ~= nil then
		Game:setCg(cg)
	end
	if #chara then
		for key, value in next, chara do
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
	Game:setMessage(text, name)
	if title ~= nil then
		txtTitle:setText(title)
		txtTitle:setInvert(titleInvert == true)
		txtTitle:add()
	end
end

function Game:advanceScript()
	chapterIndex += 1
	local cur = chapter[chapterIndex]
	if cur then

		-- Conditionally skip current sequence item
		if cur.check ~= nil then
			if cur.check() == false then
				Game:advanceScript()
				return
			end
		end

		-- Set background
		if cur.bg ~= nil then
			Game:setBg(cur.bg)
		end

		-- Show CG
		if cur.cg ~= nil then
			Game:setCg(cur.cg)
		end

		-- TODO: support altering z-index of individual characters and the message box

		-- Reveal new characters
		if cur.reveal ~= nil then
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
		if cur.move ~= nil then
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
		if cur.hide ~= nil then
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
		if cur.text ~= nil then
			Game:setMessage(cur.text, cur.name)
		else
			Game:setMessage()
		end

		-- Show title text
		if cur.title ~= nil then
			txtTitle:setText(cur.title)
			txtTitle:setInvert(cur.titleInvert == true)
			txtTitle:add()
		else
			txtTitle:remove()
		end

		-- Show choice
		if cur.choice ~= nil then
			-- TODO: draw outline box
			choiceCount = #cur.choice

			choice = cur.choice
			-- TODO: position menu sensibly
			choiceMenu = Noble.Menu.new(
				true, -- activate
				Noble.Text.ALIGN_LEFT,
				false, -- localized
				Graphics.kColorBlack,
				4, -- padding
				12, -- horizontal padding
				0, -- margin
				font14 -- font
			)

			for key, value in next, choice do
				choiceMenu:addItem(
					value.text,
					function()
						value.callback()
					end
				)
			end

			inputMode = "choice"
		end

		SaveData.current.chapterIndex = chapterIndex

	else
		-- TODO: allow chapter end to have logic to go somewhere specific
		print("end of chapter " .. scriptIndex)
		self:nextChapter()
	end
end

function Game:setBg(bg)
	if bg then
		background = Graphics.image.new("assets/images/bg/" .. bg)
	else
		background = nil
	end
end

function Game:setCg(cg)
	if cg then
		local img = Graphics.image.new("assets/images/cg/" .. cg)
		eventCg:setImage(img)
		eventCg:add()
	else
		eventCg:remove()
	end
end

function Game:setMessage(text, name)
	if text == nil then
		txtName:remove()
		txtQuote:remove()
		messageBox:remove()
		return
	end
	if name then
		messageBox:setImage(images.messageWithName)
		txtName:add()
		txtName:setText(name)
	else
		messageBox:setImage(images.message)
		txtName:remove()
	end
	txtQuote:setText(text)
	txtQuote:add()
	messageBox:add()
end
