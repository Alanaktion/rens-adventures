Ending = {}
class("Ending").extends(NobleScene)

Ending.backgroundColor = Graphics.kColorBlack

local screenWidth = playdate.display.getWidth()
local screenHeight = playdate.display.getHeight()

local line1
local heart

function Ending:init()
	Ending.super.init(self)

	line1 = Text()
	line1:setFontSize(16)
	line1:setText("The End")
	line1:setInvert(true)
	line1:setCenter(.5, 1)
	line1:moveTo(screenWidth / 2, screenHeight / 2)

	-- The NobleSprite animation code is very unfinished, so I'm using a different lib.
	local heartTable = Graphics.imagetable.new('assets/images/heart-anim')
	heart = AnimatedSprite.new(heartTable)
	heart:addState("idle", 1, #heartTable, {tickStep = 2, yoyo = true})
	heart:setCenter(.5, 0)
	heart:moveTo(screenWidth / 2, screenHeight / 2)
	heart:playAnimation()
	heart:setImageDrawMode(Graphics.kDrawModeInverted)

	Ending.inputHandler = {
		AButtonDown = function()
			Noble.transition(Title, 1, Noble.TransitionType.DIP_TO_BLACK)
		end,
		BButtonDown = function()
			Noble.transition(Title, 1, Noble.TransitionType.DIP_TO_BLACK)
		end
	}
end

function Ending:enter()
	Ending.super.enter(self)
	line1:add()
	Noble.currentScene():addSprite(heart)
end
