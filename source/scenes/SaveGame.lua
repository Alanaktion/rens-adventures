import 'sprites/SaveSlot'

SaveGame = {}
class("SaveGame").extends(NobleScene)

SaveGame.backgroundColor = Graphics.kColorWhite

local screenWidth = playdate.display.getWidth()
local screenHeight = playdate.display.getHeight()

local text1
local text2
local slotData
local selected
local slotSprites

function SaveGame:init()
	SaveGame.super.init(self)

	text1 = Text()
	text1:setText("Ⓑ Back")
	text1:setCenter(0, 1)
	text1:moveTo(4, screenHeight - 2)

	text2 = Text()
	text2:setText("Ⓐ Save")
	text2:setCenter(1, 1)
	text2:moveTo(screenWidth - 6, screenHeight - 2)

	slotData = {}
	for i = 1, 4 do
		if SaveData.exists(i) then
			local data = SaveData.getAll(i)
			slotData[i] = {
				chapter = data.chapter,
				time = Utilities.formatDateTime(data.time)
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

	SaveGame.inputHandler = {
		upButtonDown = function()
			SaveGame:selectPrevious()
			Sound.tick()
		end,
		downButtonDown = function()
			SaveGame:selectNext()
			Sound.tick()
		end,
		AButtonDown = function()
			SaveGame:click()
			Sound.confirm()
		end,
		BButtonDown = function()
			Noble.transition(Game, 1, Noble.TransitionType.DIP_TO_WHITE)
			Sound.back()
		end
	}
end

function SaveGame:enter()
	SaveGame.super.enter(self)
	text1:add()
	text2:add()
	for _, value in next, slotSprites do
		value:add()
	end
end

function SaveGame:selectPrevious()
	slotSprites[selected]:setSelected(false)
	selected -= 1
	if selected == 0 then
		selected = #slotSprites
	end
	slotSprites[selected]:setSelected(true)
end

function SaveGame:selectNext()
	slotSprites[selected]:setSelected(false)
	selected += 1
	if selected > #slotSprites then
		selected = 1
	end
	slotSprites[selected]:setSelected(true)
end

function SaveGame:click()
	if slotData[selected] ~= nil then
		-- TODO: confirm overwriting save
		print('Overwriting save slot!')
	end
	SaveData.save(selected)
	Noble.transition(Game, 1, Noble.TransitionType.DIP_TO_WHITE)
end
