local gfx = playdate.graphics
local screenWidth = playdate.display.getWidth()
local screenHeight = playdate.display.getHeight()

class("Title").extends(Screen)

function Title:init()
	Title.super.init(self)

	self.line1 = Text()
	self.line1:setFontSize(16)
	self.line1:setText("Ren's Adventures")
	self.line1:setCenter(.5, 1)
	self.line1:moveTo(screenWidth / 3, screenHeight / 2)

	self.line2 = Text()
	self.line2:setFontSize(16)
	self.line2:setText("レンのボーケン")
	self.line2:setCenter(.5, 0)
	self.line2:moveTo(screenWidth / 3, screenHeight / 2)

	self.ren = Character()
	self.ren:setCharacter("ren")
	self.ren:moveTo(screenWidth * 5 / 4, screenHeight)

	self.renAnim = gfx.animator.new(250, screenWidth * 5 / 4, screenWidth * 3 / 4, playdate.easingFunctions.outQuad)

	self.startText = Text()
	self.startText:setFontSize(14)
	self.startText:setCenter(0, 1)
	self.startText:setText("Ⓐ start game")
	self.startText:moveTo(4, screenHeight - 2)

	-- self.anims = {}
	-- local starImages = gfx.imagetable.new("images/star/star")
	-- self.anims.star = gfx.animation.loop.new(100, starImages)
end

function Title:show()
	Title.super.show(self)
	self.line1:add()
	self.line2:add()
	self.ren:add()
	self.startText:add()
end

function Title:update()
	Title.super.update(self)

	-- self.anims.star:draw(screenWidth - 40, screenHeight - 40)

	-- Start game with A button
	if playdate.buttonJustPressed(playdate.kButtonA) then
		self:fadeToWhite(function()
			Screen.change("game", Game())
		end)
	end

	-- Update character position with animation
	if not self.renAnim:ended() then
		self.ren:moveTo(self.renAnim:currentValue(), screenHeight)
	end
end
