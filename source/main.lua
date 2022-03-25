import 'libraries/noble/Noble'
import 'libraries/animated-sprite/AnimatedSprite'

import 'utilities/Utilities'
import 'utilities/SaveData'
import 'utilities/Sound'

import 'sprites/Text'
import 'sprites/Character'

import 'script'

import 'scenes/Title'
import 'scenes/LoadGame'
import 'scenes/SaveGame'
import 'scenes/Game'
import 'scenes/MessageLog'
import 'scenes/Ending'
import 'scenes/Options'

Noble.Settings.setup({
	MessageStyle = "Dark",
	FPS = false,
	AllowSkip = false,
})

Noble.showFPS = Noble.Settings.get("FPS")

Noble.new(Title, .5, Noble.TransitionType.CROSS_DISSOLVE, true)

function playdate.gameWillTerminate()
	print("Auto-saving before terminate")
	SaveData.save()
end
function playdate.deviceWillSleep()
	print("Auto-saving before sleep")
	SaveData.save()
end
function playdate.deviceWillLock()
	print("Auto-saving before lock")
	SaveData.save()
end

local menu = playdate.getSystemMenu()
menu:addMenuItem("title screen", function()
	-- TODO: maybe auto-save when returning to title? idk
	SaveData.init() -- Reset game state since we're exiting the game
	Noble.transition(Title, .5, Noble.TransitionType.CROSS_DISSOLVE)
end)
menu:addMenuItem("save", function()
	-- TODO: only allow saving when in a game
	-- Should probably add/remove this menu item when entering and exiting the game screen
	Noble.transition(SaveGame, .5, Noble.TransitionType.DIP_TO_WHITE)
end)
menu:addMenuItem("load", function()
	Noble.transition(LoadGame, .5, Noble.TransitionType.DIP_TO_WHITE)
end)
