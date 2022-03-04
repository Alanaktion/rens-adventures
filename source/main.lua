import 'libraries/noble/Noble'
import 'libraries/animated-sprite/AnimatedSprite'

import 'utilities/Utilities'

import 'sprites/Text'
import 'sprites/Character'

import 'scenes/Title'
import 'scenes/Game'
import 'scenes/Ending'
import 'scenes/Options'

Noble.Settings.setup({
	MessageStyle = "Dark",
	FPS = false
})

Noble.GameData.setup({
	Score = 0
})

Noble.showFPS = Noble.Settings.get("FPS")

Noble.new(Title, .5, Noble.TransitionType.CROSS_DISSOLVE, true)

local menu = playdate.getSystemMenu()
menu:addMenuItem("title screen", function()
	Noble.transition(Title, .5, Noble.TransitionType.CROSS_DISSOLVE)
end)
