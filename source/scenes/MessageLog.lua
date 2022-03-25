MessageLog = {}
class("MessageLog").extends(NobleScene)

MessageLog.backgroundColor = Graphics.kColorWhite

local screenWidth <const> = playdate.display.getWidth()
local screenHeight <const> = playdate.display.getHeight()

local font <const> = font14
local fontHeight <const> = font:getHeight()
local lineHeight <const> = fontHeight + 4
local lineCount <const> = math.ceil(screenHeight / lineHeight)
local margin <const> = 5

local text
local textIndex
local textPosition

-- Based on Reader implementation by Diefonk
-- https://devforum.play.date/t/simple-text-reader/1614

function MessageLog:init()
	MessageLog.super.init(self)

	text = {}

	MessageLog.inputHandler = {
		crankDocked = function()
			Noble.transition(Game, .5, Noble.TransitionType.CROSS_DISSOLVE)
			Sound.back()
		end,
		cranked = function(change, acceleratedChange)
			self:scroll(change)
		end,
		upButtonHold = function()
			self:scroll(-100 / playdate.display.getRefreshRate())
		end,
		downButtonHold = function()
			self:scroll(100 / playdate.display.getRefreshRate())
		end,
		leftButtonDown = function ()
			-- Seek to start
			textPosition = 0
			textIndex = 1
			self:drawText()
		end,
		rightButtonDown = function ()
			-- Seek to end
			textPosition = 0
			textIndex = math.max(#text - lineCount + 2, 1)
			self:drawText()
		end,
		BButtonDown = function()
			Noble.transition(Game, .5, Noble.TransitionType.CROSS_DISSOLVE)
			Sound.back()
		end
	}
end

function MessageLog:enter()
	MessageLog.super.enter(self)
	self:loadText()
	self:splitLines()
	textPosition = 0
	textIndex = math.max(#text - lineCount + 2, 1)
end

function MessageLog:update()
	MessageLog.super.update(self)
	self:drawText()
end

function MessageLog:drawText()
	Graphics.clear(Graphics.kColorWhite)
	local endIndex = textIndex + lineCount + 1
	if #text < endIndex then
		endIndex = #text
	end
	for index = textIndex, endIndex do
		if index == 1 then
			-- Draw header as larger, centered text
			-- Uses an empty string in line 2 to simplify spacing/scrolling
			font16:drawTextAligned(text[index], screenWidth / 2, textPosition + margin + 10, kTextAlignment.center)
		elseif textIndex == 2 and index == 2 then
			-- Draw partial header in normal position when second line of text is visible
			font16:drawTextAligned(text[1], screenWidth / 2, textPosition + margin + 10 - lineHeight, kTextAlignment.center)
		else
			Graphics.drawText(text[index], margin, textPosition + margin + lineHeight * (index - textIndex))
		end
	end
end

function MessageLog:scroll(change)
	textPosition -= change
	print(#text, lineCount, textIndex, textPosition, change)
	while textPosition < 0 - fontHeight and textIndex < #text - lineCount + 2 do
		textIndex += 1
		textPosition += lineHeight
	end
	if textPosition < 0 and textIndex > #text - lineCount + 1 then
		textPosition = 0
	end
	while textPosition > 0 and textIndex > 1 do
		textIndex -= 1
		textPosition -= lineHeight
	end
	if textPosition > 0 and textIndex == 1 then
		textPosition = 0
	end
	print(#text, lineCount, textIndex, textPosition)
	self:drawText()
end

function MessageLog:loadText()
	text = {"Message Log", ""}

	local chapter = self:getChapter(SaveData.current.chapter)
	local endIndex = SaveData.current.chapterIndex
	for index = 1, endIndex do
		local cur = chapter[index]
		if cur.check ~= nil and cur.check() == false then
			-- Skip message
		elseif cur.text ~= nil then
			if cur.name then
				table.insert(text, "*" .. cur.name .. "*")
				table.insert(text, cur.text)
			else
				table.insert(text, "_" .. cur.text .. "_")
			end
		end
	end
end

function MessageLog:getChapter(chapterName)
	for key, value in next, script do
		if value.name == chapterName then
			return value.sequence
		end
	end
end

function MessageLog:splitLines()
	local index = 1
	while index <= #text do
		if font:getTextWidth(text[index]) > screenWidth - margin * 2 then
			local line = text[index]
			for index2 = 1, #line do
				if font:getTextWidth(line:sub(1, index2)) > screenWidth - margin * 2 then
					local spaceIndex = index2
					while spaceIndex > 1 do
						if line:sub(spaceIndex, spaceIndex) == " " then
							break
						end
						spaceIndex -= 1
					end
					if spaceIndex > 1 then
						text[index] = line:sub(1, spaceIndex - 1)
						table.insert(text, index + 1, line:sub(spaceIndex + 1))
					else
						text[index] = line:sub(1, index2 - 1)
						table.insert(text, index + 1, line:sub(index2))
					end
					break
				end
			end
		end
		index += 1
	end
end
