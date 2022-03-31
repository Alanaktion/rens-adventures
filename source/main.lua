import 'libraries/noble/Noble'
import 'libraries/animated-sprite/AnimatedSprite'

import 'utilities/Utilities'
import 'utilities/SaveData'
import 'utilities/Sound'

import 'sprites/Text'
import 'sprites/MessageBox'
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

local menu <const> = playdate.getSystemMenu()
menu:addMenuItem("title screen", function()
	SaveData.init() -- Reset game state since we're exiting the game
	Noble.transition(Title, .5, Noble.TransitionType.CROSS_DISSOLVE)
end)
menu:addMenuItem("save", function()
	-- TODO: add/remove this menu item when entering and exiting the game screen
	if Noble.currentSceneName() == "Game" then
		Noble.transition(SaveGame, .5, Noble.TransitionType.DIP_TO_WHITE)
	end
end)
menu:addMenuItem("load", function()
	Noble.transition(LoadGame, .5, Noble.TransitionType.DIP_TO_WHITE)
end)
