import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "character"
import "text"

playdate.display.setRefreshRate(30)

local gfx = playdate.graphics
local screenWidth = playdate.display.getWidth()
local screenHeight = playdate.display.getHeight()

gfx.setColor(gfx.kColorWhite)
gfx.fillRect(0, 0, screenWidth, screenHeight)
gfx.setBackgroundColor(gfx.kColorWhite)

-- local kScreens = {title, game, over}
-- local currentScreen = kScreens.title

local ball = gfx.sprite:new()
ball:setImage(gfx.image.new('ball'))
ball:moveTo(screenWidth / 2, screenHeight / 2)
ball:setZIndex(200)
ball:addSprite()

local txtName = Text()
txtName:setFontSize(12)
txtName:setInvert(true)
txtName:setCenter(.5,0)
txtName:moveTo(32, screenHeight - 80)
txtName:setText("Misha")
txtName:addSprite()

local txtQuote = Text()
txtQuote:setText("You like chess, don't you? Yeah, you do, definitely!")
txtQuote:setInvert(true)
txtQuote:moveTo(6, screenHeight - 58)
txtQuote:addSprite()

local txtStatus = Text()
txtStatus:setText("press a d-pad button")
txtStatus:moveTo(2, 2)
txtStatus:addSprite()

local hana = Character()
hana:setCharacter("hanako")
hana:moveTo(300, screenHeight - 20)
hana:addSprite()

local shizu = Character()
shizu:setCharacter("shizune")
shizu:moveTo(120, screenHeight - 20)
shizu:setImageFlip(gfx.kImageFlippedX)
shizu:addSprite()

local messageBox = gfx.sprite.new()
messageBox:setImage(gfx.image.new('images/message-dark'))
messageBox:setCenter(0, 1)
messageBox:moveTo(0, screenHeight)
messageBox:setZIndex(90)
messageBox:addSprite()

elapsedTime = 0
dx, dy = 0, 0

function playdate.leftButtonDown()
  dx -= 1
  print("Left Down")
  msgStatus:setText("Left")
end

function playdate.rightButtonDown()
  dx += 1
	print("Right Down")
  msgStatus:setText("Right")
end

function playdate.upButtonDown()
  dy -= 1
  print("Up Down")
  msgStatus:setText("Up")
end

function playdate.downButtonDown()
  dy += 1
  print("Down Down")
  msgStatus:setText("Down")
end

function playdate.leftButtonUp()
  dx += 1
  print("Left Up")
end

function playdate.rightButtonUp()
  dx -= 1
  print("Right Up")
end

function playdate.upButtonUp()
  dy += 1
  print("Up Up")
end

function playdate.downButtonUp()
  dy -= 1
  print("Down Up")
end

function playdate.update()
  -- Move ball by dx/dy values
  dt = 1/20
  elapsedTime = elapsedTime + dt
  moveDistance = 100 * dt
  ball:moveTo(ball.x + dx * moveDistance, ball.y + dy * moveDistance)

  gfx.sprite.update()
end
