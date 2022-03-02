import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "text"
import "character"
import "screens/title"
import "screens/game"

playdate.display.setRefreshRate(30)

local gfx = playdate.graphics
local screenWidth = playdate.display.getWidth()
local screenHeight = playdate.display.getHeight()

gfx.setColor(gfx.kColorWhite)
gfx.fillRect(0, 0, screenWidth, screenHeight)
gfx.setBackgroundColor(gfx.kColorWhite)

local screens = {
  title = Title(),
  game = Game()
}
local currentScreen = screens.title
screens.title:show()

elapsedTime = 0
dx, dy = 0, 0

function playdate.leftButtonDown()
  dx -= 1
  print("Left Down")
  -- txtStatus:setText("Left")
end

function playdate.rightButtonDown()
  dx += 1
	print("Right Down")
  -- txtStatus:setText("Right")
end

function playdate.upButtonDown()
  dy -= 1
  print("Up Down")
  -- txtStatus:setText("Up")
end

function playdate.downButtonDown()
  dy += 1
  print("Down Down")
  -- txtStatus:setText("Down")
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

function playdate.AButtonDown()
  if currentScreen == screens.title then
    screens.title:hide()
    screens.game:show()
    currentScreen = screens.game
    print(currentScreen)
  elseif currentScreen == screens.game then
    screens.game:hide()
    screens.title:show()
    currentScreen = screens.title
    print(currentScreen)
  end
end

function playdate.update()
  if currentScreen == screens.game then
    screens.game:update(dx, dy)
  end
  gfx.sprite.update()
end
