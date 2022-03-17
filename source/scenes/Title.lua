Title = {}
class("Title").extends(NobleScene)

Title.backgroundColor = Graphics.kColorWhite

local screenWidth = playdate.display.getWidth()
local screenHeight = playdate.display.getHeight()

local menu
local menuSequence
local menuY

local line1
local line2
local ren
local renSequence

function Title:init()
	Title.super.init(self)

	line1 = Text()
	line1:setFontSize(16)
	line1:setText("Ren's Adventures")
	line1:setCenter(.5, 1)
	line1:moveTo(120, 90)

	line2 = Text()
	line2:setFontSize(16)
	line2:setText("レンのボーケン")
	line2:setCenter(.5, 0)
	line2:moveTo(120, 90)

	ren = Character("ren")
	ren:moveTo(screenWidth * 5 / 4, screenHeight)

	menu = Noble.Menu.new(false, Noble.Text.ALIGN_LEFT, true, Graphics.kColorBlack, 4,12,0, font14)

	menu:addItem(
		"menuNewGame",
		function()
			SaveData.init()
			SaveData.current.chapter = script[1].name
			Noble.transition(Game, 1, Noble.TransitionType.DIP_TO_WHITE)
		end
	)
	if SaveData.exists("auto") then
		menu:addItem(
			"menuResumeGame",
			function()
				SaveData.load()
				Noble.transition(Game, 1, Noble.TransitionType.DIP_TO_WHITE)
			end
		)
	end
	menu:addItem(
		"menuLoadGame",
		function()
			Noble.transition(LoadGame, 1, Noble.TransitionType.DIP_TO_WHITE)
		end
	)
	menu:addItem(
		"menuOptions",
		function()
			Noble.transition(Options, 1, Noble.TransitionType.DIP_TO_WHITE)
		end
	)
	menuY = screenHeight - #menu.itemNames * 20

	local crankTick = 0

	Title.inputHandler = {
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
			Sound.confirm()
		end
	}
end

function Title:enter()
	Title.super.enter(self)

	-- TODO: use menuItemCount to determine position
	menuSequence = Sequence.new():from(240):to(menuY, .5, Ease.outQuad)
	menuSequence:start()

	renSequence = Sequence.new()
		:from(screenWidth * 5 / 4)
		:to(screenWidth * 3 / 4, .5, Ease.outQuad)
	renSequence:start()

	line1:add()
	line2:add()
	ren:add()
end

function Title:start()
	Title.super.start(self)
	menu:activate()
end

function Title:update()
	Title.super.update(self)

	-- TODO: use menuItemCount to determine position
	menu:draw(8, menuSequence:get()-15 or 100-15)

	if not renSequence:isDone() then
		ren:moveTo(renSequence:get(), screenHeight)
	end
end

function Title:exit()
	Title.super.exit(self)

	-- TODO: use menuItemCount to determine position
	menuSequence = Sequence.new():from(menuY):to(240, 0.25, Ease.inSine)
	menuSequence:start()

	renSequence = Sequence.new()
		:from(screenWidth * 3 / 4)
		:to(screenWidth * 5 / 4, .25, Ease.inSine)
	renSequence:start()
end
