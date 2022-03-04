local gfx = playdate.graphics
local screenWidth = playdate.display.getWidth()
local screenHeight = playdate.display.getHeight()

class('Options').extends(Screen)

function Options:init()
	Options.super.init(self)

	self.title = Text()
	self.title:setFontSize(16)
	self.title:setText("Options")
	self.title:moveTo(6, 10)

	self.back = Text()
	self.back:setFontSize(14)
	self.back:setCenter(0, 1)
	self.back:setText("Ⓑ back")
	self.back:moveTo(4, screenHeight - 2)
end

function Options:show()
	Options.super.show(self)
	self.title:add()
	self.back:add()
end

function Options:update()
	Options.super.update(self)

	if playdate.buttonJustPressed(playdate.kButtonB) then
		Screen.back()
	end
end
