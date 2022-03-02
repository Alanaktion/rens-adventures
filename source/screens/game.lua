local gfx = playdate.graphics
local screenWidth = playdate.display.getWidth()
local screenHeight = playdate.display.getHeight()

class('Game').extends()

function Game:init()
    self.ball = gfx.sprite.new()
    self.ball:setImage(gfx.image.new('ball'))
    self.ball:moveTo(screenWidth / 2, screenHeight / 2)
    self.ball:setZIndex(200)

    self.txtName = Text()
    self.txtName:setFontSize(12)
    self.txtName:setInvert(true)
    self.txtName:setCenter(.5,0)
    self.txtName:moveTo(32, screenHeight - 80)
    self.txtName:setText("Misha")

    self.txtQuote = Text()
    self.txtQuote:setText("You like chess, don't you? Yeah, you do, definitely!")
    self.txtQuote:setInvert(true)
    self.txtQuote:moveTo(6, screenHeight - 58)

    -- self.txtStatus = Text()
    -- self.txtStatus:setText("press a d-pad button")
    -- self.txtStatus:moveTo(2, 2)

    self.hana = Character()
    self.hana:setCharacter("hanako")
    self.hana:moveTo(300, screenHeight - 20)

    self.shizu = Character()
    self.shizu:setCharacter("shizune")
    self.shizu:moveTo(120, screenHeight - 20)
    self.shizu:setImageFlip(gfx.kImageFlippedX)

    self.messageBox = gfx.sprite.new()
    self.messageBox:setImage(gfx.image.new('images/message-dark'))
    self.messageBox:setCenter(0, 1)
    self.messageBox:moveTo(0, screenHeight)
    self.messageBox:setZIndex(90)
end

function Game:show()
    self.visible = true
    self.ball:add()
    self.txtName:add()
    self.txtQuote:add()
    -- self.txtStatus:add()
    self.hana:add()
    self.shizu:add()
    self.messageBox:add()
end

function Game:update(dx, dy)
    -- Move ball by dx/dy values
    dt = 1/20
    elapsedTime = elapsedTime + dt
    moveDistance = 100 * dt
    self.ball:moveTo(self.ball.x + dx * moveDistance, self.ball.y + dy * moveDistance)
end

function Game:hide()
    self.ball:remove()
    self.txtName:remove()
    self.txtQuote:remove()
    -- self.txtStatus:remove()
    self.hana:remove()
    self.shizu:remove()
    self.messageBox:remove()
end
