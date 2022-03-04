import "CoreLibs/graphics"
import "CoreLibs/animation"
import "CoreLibs/sprites"
import "text"
import "character"
import "screen"
import "screens/title"
import "screens/game"
import "screens/over"
import "screens/options"

playdate.display.setRefreshRate(30)

local gfx = playdate.graphics

gfx.setColor(gfx.kColorBlack)
gfx.setBackgroundColor(gfx.kColorWhite)
gfx.clear()

Screen.change("title", Title())

local menu = playdate.getSystemMenu()
menu:addMenuItem("title screen", function()
	Screen.change("title", Title())
end)
menu:addMenuItem("options", function()
	Screen.change("options", Options())
end)

function playdate.update()
	Screen.currentInstance:update()
end
