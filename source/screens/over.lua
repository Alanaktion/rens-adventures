local gfx = playdate.graphics
local screenWidth = playdate.display.getWidth()
local screenHeight = playdate.display.getHeight()

class('Over').extends(Screen)

function Over:init()
	Over.super.init(self)

	self.line1 = Text()
	self.line1:setFontSize(16)
	self.line1:setText("The End")
	self.line1:setCenter(.5, 1)
	self.line1:moveTo(screenWidth / 2, screenHeight / 2)

	self.heart = gfx.sprite.new()
	self.heart:setImage(gfx.image.new('images/heart'))
	self.heart:setCenter(.5, 0)
	self.heart:moveTo(screenWidth / 2, screenHeight / 2)
end

function Over:show()
	Over.super.show(self)
	self.line1:add()
	self.heart:add()
end

function Over:update()
	Over.super.update(self)
	if playdate.buttonJustPressed(playdate.kButtonA) then
		Screen.change("title", Title())
	elseif playdate.buttonJustPressed(playdate.kButtonB) then
		Screen.change("title", Title())
	end
end
