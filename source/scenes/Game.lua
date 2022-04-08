Game = {}
class("Game").extends(NobleScene)

Game.backgroundColor = Graphics.kColorWhite

local screenWidth <const> = playdate.display.getWidth()
local screenHeight <const> = playdate.display.getHeight()

local allowSkip
local darkStyle

local background
local txtName
local txtQuote
local txtTitle
local eventCg
local messageBox
local characters

local inputMode
local scriptIndex
local chapter
local chapterIndex
local choice
local choiceMenu
local bgm

function Game:init()
	Game.super.init(self)

	allowSkip = Noble.Settings.get("AllowSkip")
	darkStyle = Noble.Settings.get("MessageStyle") == "Dark"

	txtName = Text()
	txtName:setFontSize(12)
	txtName:moveTo(14, screenHeight - 80)
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

	eventCg = NobleSprite()
	eventCg:setCenter(0, 0)
	eventCg:moveTo(0, 0)
	eventCg:setZIndex(80)

	messageBox = MessageBox()
	messageBox:setDark(darkStyle)
	messageBox:moveTo(0, screenHeight)

	inputMode = "script"
	characters = {}
	choice = nil
	choiceMenu = nil

	self:setChapter(SaveData.current.chapterFile)
	if SaveData.current.chapterIndex > 0 then
		self:seekScript(SaveData.current.chapterIndex)
	end

	local crankTick = 0

	Game.inputHandler = {
		crankUndocked = function()
			if inputMode == "script" then
				Noble.transition(MessageLog, .5, Noble.TransitionType.CROSS_DISSOLVE)
			end
		end,
		upButtonDown = function()
			if inputMode == "script" then
				Noble.transition(MessageLog, .5, Noble.TransitionType.CROSS_DISSOLVE)
			elseif inputMode == "choice" then
				choiceMenu:selectPrevious()
				Sound.tick()
			end
		end,
		downButtonDown = function()
			if inputMode == "choice" then
				choiceMenu:selectNext()
				Sound.tick()
			end
		end,
		AButtonDown = function()
			if inputMode == "script" then
				self:advanceScript()
			elseif inputMode == "choice" then
				choiceMenu:click()
				Sound.confirm()
				choice = nil
				choiceMenu = nil
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
		local rad, padding = 4, 4
		local w = choiceMenu.width + choiceMenu.selectedOutlineThickness * 2
		local h = #choiceMenu.itemNames * 22 + padding * 2 + choiceMenu.selectedOutlineThickness * 2
		local x, y = (screenWidth - w) / 2
		if txtQuote.text == "" then
			y = math.max((screenHeight - h) / 2, 0)
		else
			y = math.max((screenHeight - 60 - h) / 2, 0)
		end
		Graphics.setStrokeLocation(Graphics.kStrokeInside)
		if darkStyle then
			Graphics.setColor(Graphics.kColorBlack)
		else
			Graphics.setColor(Graphics.kColorWhite)
		end
		Graphics.fillRoundRect(x, y, w, h, rad)
		if darkStyle then
			Graphics.setColor(Graphics.kColorWhite)
		else
			Graphics.setColor(Graphics.kColorBlack)
		end
		Graphics.drawRoundRect(x, y, w, h, rad)
		if darkStyle then
			Graphics.setColor(Graphics.kColorBlack)
			Graphics.drawRoundRect(x - 1, y - 1, w + 2, h + 2, rad + 1)
		end

		choiceMenu:draw(x + padding, y + padding)
	end
end

function Game:drawBackground()
	Game.super.drawBackground(self)
	if background ~= nil then
		background:draw(0, 0)
	end
end

function Game:finish()
	Game.super.finish(self)
	self:cleanup()
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

function Game:nextChapter(jumpToName)
	if bgm ~= nil then
		if bgm:sub(-4) == '.mid' then
			Sound.stopMIDI()
		else
			Sound.stop()
		end
	end
	if jumpToName ~= nil then
		self:setChapter(jumpToName)
		self:advanceScript()
	elseif scriptIndex == #script then
		print("end of script")
		-- Delete autosave after game ends?
		-- SaveData.delete()
		Noble.transition(Ending, 2, Noble.TransitionType.DIP_TO_BLACK)
	else
		self:cleanup()
		chapterIndex = 0
		scriptIndex += 1
		self:setChapter(script[scriptIndex].file)
		self:advanceScript()
	end
end

function Game:setChapter(chapterFilename)
	chapterIndex = 0
	scriptIndex = nil
	for key, value in next, script do
		if value.file == chapterFilename then
			scriptIndex = key
		end
	end
	if scriptIndex ~= nil then
		scriptSequence = playdate.file.run("scripts/" .. chapterFilename)
		chapter = scriptSequence
		SaveData.current.chapterName = script[scriptIndex].name
		SaveData.current.chapterFile = script[scriptIndex].file
	else
		print("Unknown script chapter " .. chapterFilename)
	end
end

function Game:seekScript(__index)
	local index = __index - 1
	print("Seeking to index " .. index)

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
						local char = chara[key]
						if value.image ~= nil then
							char.image = value.image
						end
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
		self:setBg(bg)
	end
	if cg ~= nil then
		self:setCg(cg)
	end
	if #chara then
		for key, value in next, chara do
			local char = Character(Game.mapValue("chara", value.image))
			if value.center then
				char:setCenter(value.center.x, value.center.y)
			end
			if value.pos then
				local pos = Game.mapValue("pos", value.pos)
				char:moveTo(pos.x * screenWidth, pos.y * screenHeight)
			else
				char:moveTo(screenWidth / 2, screenHeight)
			end
			if value.flip then
				char:setImageFlip(Graphics.kImageFlippedX)
			end
			characters[key] = char
			char:add()
		end
	end
	self:setMessage(text, name)
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
				self:advanceScript()
				return
			end
		end

		-- Jump to a new chapter/position
		if cur.jump ~= nil then
			self:setChapter(cur.jump)
			return
		end

		-- Set background
		if cur.bg ~= nil then
			self:setBg(cur.bg)
		end

		-- Show CG
		if cur.cg ~= nil then
			self:setCg(cur.cg)
		end

		-- TODO: support altering z-index of individual characters and the message box

		-- Reveal new characters
		if cur.reveal ~= nil then
			for key, value in next, cur.reveal do
				local char = Character(Game.mapValue("chara", value.image))
				if value.center then
					char:setCenter(value.center.x, value.center.y)
				end
				if value.pos then
					local pos = Game.mapValue("pos", value.pos)
					char:moveTo(pos.x * screenWidth, pos.y * screenHeight)
				else
					char:moveTo(screenWidth / 2, screenHeight)
				end
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
					if value.image ~= nil then
						char:changeImage(Game.mapValue("chara", value.image))
					end
					if value.pos then
						local pos = Game.mapValue("pos", value.pos)
						char:moveTo(pos.x * screenWidth, pos.y * screenHeight)
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
			self:setMessage(cur.text, cur.name)
		else
			self:setMessage()
		end

		-- Show title text
		if cur.title ~= nil then
			txtTitle:setText(cur.title)
			txtTitle:setInvert(cur.titleInvert == true)
			txtTitle:add()
		else
			txtTitle:remove()
		end

		-- Play/stop BGM
		if cur.bgm ~= nil then
			self:setBgm(Game.mapValue("bgm", cur.bgm))
		end

		-- Show choice
		if cur.choice ~= nil then
			choice = cur.choice

			local menuColor
			if darkStyle then
				menuColor = Graphics.kColorWhite
			else
				menuColor = Graphics.kColorBlack
			end
			choiceMenu = Noble.Menu.new(
				true, -- activate
				Noble.Text.ALIGN_LEFT,
				false, -- localized
				menuColor,
				4 -- padding
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

function Game.mapValue(type, default)
	if default == nil then
		return nil
	end
	if scriptMap[type] and scriptMap[type][default] ~= nil then
		return scriptMap[type][default]
	end
	return default
end

function Game:setBg(__bg)
	local bg = Game.mapValue("bg", __bg)
	if bg then
		background = Graphics.image.new("assets/images/bg/" .. bg)
	else
		background = nil
	end
end

function Game:setCg(__cg)
	local cg = Game.mapValue("cg", __cg)
	if cg then
		local img = Graphics.image.new("assets/images/cg/" .. cg)
		eventCg:setImage(img)
		eventCg:add()
	else
		eventCg:remove()
	end
end

function Game:setMessage(text, __name)
	local name = Game.mapValue("name", __name)
	if text == nil then
		txtName:remove()
		txtQuote:remove()
		messageBox:remove()
		return
	end
	if name then
		messageBox:setName(name)
		txtName:add()
		txtName:setText(name)
	else
		messageBox:setName(false)
		txtName:remove()
	end
	txtQuote:setText(text)
	txtQuote:add()
	messageBox:add()
end

function Game:setBgm(__newBgm)
	local newBgm = Game.mapValue("bgm", __newBgm)
	if newBgm then
		bgm = newBgm
		if newBgm:sub(-4) == '.mid' then
			Sound.playMIDI(newBgm)
		else
			Sound.play(newBgm)
		end
	else
		if bgm == nil then
			return
		end
		if bgm:sub(-4) == '.mid' then
			Sound.stopMIDI()
		else
			Sound.stop()
		end
		bgm = nil
	end
end
