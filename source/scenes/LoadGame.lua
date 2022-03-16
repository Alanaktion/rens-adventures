import 'sprites/SaveSlot'

LoadGame = {}
class("LoadGame").extends(NobleScene)

LoadGame.backgroundColor = Graphics.kColorWhite

local screenWidth = playdate.display.getWidth()
local screenHeight = playdate.display.getHeight()

local text1
local text2
local slotData
local selected
local slotSprites

local function formatTime(time)
	local str = ""
	local months = {
		"January",
		"February",
		"March",
		"April",
		"May",
		"June",
		"July",
		"August",
		"September",
		"October",
		"November",
		"December",
	}
	str = time.day .. " " .. months[time.month] .. " " .. time.year
	str = str .. "  " .. string.format("%02d:%02d:%02d", time.hour, time.minute, time.second)
	return str
end

function LoadGame:init()
	LoadGame.super.init(self)

	text1 = Text()
	text1:setText("Ⓑ Back")
	text1:setCenter(0, 1)
	text1:moveTo(4, screenHeight - 2)

	text2 = Text()
	text2:setText("Ⓐ Load")
	text2:setCenter(1, 1)
	text2:moveTo(screenWidth - 6, screenHeight - 2)

	slotData = {}
	for i = 1, 4 do
		if SaveData.exists(i) then
			local data = SaveData.getAll(i)
			slotData[i] = {
				chapter = data.chapter,
				time = formatTime(data.time)
			}
		end
	end

	selected = 1
	slotSprites = {}
	for i = 1, 4 do
		local chapter
		local time
		if slotData[i] ~= nil then
			chapter = slotData[i].chapter
			time = slotData[i].time
		end
		local slotSprite = SaveSlotSprite(chapter, time)
		slotSprite:moveTo(screenWidth / 2, 10 + 50 * (i - 1))
		slotSprites[i] = slotSprite
	end
	slotSprites[1]:setSelected(true)

	LoadGame.inputHandler = {
		upButtonDown = function()
			LoadGame:selectPrevious()
		end,
		downButtonDown = function()
			LoadGame:selectNext()
		end,
		AButtonDown = function()
			LoadGame:click()
		end,
		BButtonDown = function()
			Noble.transition(Title, 1, Noble.TransitionType.DIP_TO_WHITE)
		end
	}
end

function LoadGame:enter()
	LoadGame.super.enter(self)
	text1:add()
	text2:add()
	for _, value in next, slotSprites do
		value:add()
	end
end

function LoadGame:selectPrevious()
	slotSprites[selected]:setSelected(false)
	selected -= 1
	if selected == 0 then
		selected = #slotSprites
	end
	slotSprites[selected]:setSelected(true)
end

function LoadGame:selectNext()
	slotSprites[selected]:setSelected(false)
	selected += 1
	if selected > #slotSprites then
		selected = 1
	end
	slotSprites[selected]:setSelected(true)
end

function LoadGame:click()
	if saveData[selected] ~= nil then
		SaveData.load(selected)
		Noble.transition(Game, 1, Noble.TransitionType.DIP_TO_WHITE)
	else
		Sound.buzz()
	end
end
