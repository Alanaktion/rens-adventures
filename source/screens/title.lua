local gfx = playdate.graphics
local screenWidth = playdate.display.getWidth()
local screenHeight = playdate.display.getHeight()

class('Title').extends()

function Title:init()
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

    self.shizu = Character()
    self.shizu:setCharacter("shizune")
    self.shizu:moveTo(320, screenHeight)

    self.startText = Text()
    self.startText:setFontSize(14)
    self.startText:setCenter(0, 1)
    self.startText:setText("Ⓐ start game")
    self.startText:moveTo(4, screenHeight - 2)
end

function Title:show()
    self.line1:add()
    self.line2:add()
    self.shizu:add()
    self.startText:add()
end

function Title:hide()
    self.line1:remove()
    self.line2:remove()
    self.shizu:remove()
    self.startText:remove()
end
