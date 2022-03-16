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
import 'scenes/Game'
import 'scenes/Ending'
import 'scenes/Options'

Noble.Settings.setup({
	MessageStyle = "Dark",
	FPS = false
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
	Noble.transition(Title, .5, Noble.TransitionType.CROSS_DISSOLVE)
end)
menu:addMenuItem("save", function()
	SaveData.save(1)
	-- Noble.transition(SaveGame, .5, Noble.TransitionType.DIP_TO_WHITE)
end)
menu:addMenuItem("load", function()
	Noble.transition(LoadGame, .5, Noble.TransitionType.DIP_TO_WHITE)
end)
