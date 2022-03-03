import "CoreLibs/graphics"
import "CoreLibs/animation"
import "CoreLibs/sprites"
import "text"
import "character"
import "screen"
import "screens/title"
import "screens/game"
import "screens/over"

playdate.display.setRefreshRate(30)

local gfx = playdate.graphics

gfx.setColor(gfx.kColorBlack)
gfx.setBackgroundColor(gfx.kColorWhite)
gfx.clear()

Screen.change("title", Title())

local menu = playdate.getSystemMenu()
local menuItem, error = menu:addMenuItem("title screen", function()
	Screen.change("title", Title())
end)

function playdate.update()
	Screen.currentInstance:update()
end
