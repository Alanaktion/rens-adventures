return {{
	bg = "20%",
	reveal = {
		shi = {
			image = "shizune",
			pos = {x=.25, y=1},
			flip = true
		},
		hana = {
			image = "hanako",
			pos = {x=.75, y=1}
		}
	}
}, {
	name = "Misha",
	text = "You like chess, don't you? Yeah, you do, definitely!",
}, {
	name = "Hanako",
	text = "Uhm..."
}, {
	check = function()
		return false
	end,
	text = "This message SHOULD NEVER SHOW!"
}, {
	name = "Misha",
	text = "Wahaha~!",
	move = {
		hana = {
			pos = {x=.5, y=1}
		}
	},
	hide = {"shi"}
}, {
	-- Blank sequence items are allowed!
	-- No message will display, character sprites are left unchanged
}, {
	text = "...",
	hide = {"hana"}
}, {
	name = "Ren",
	text = "Wait, when do I come into this?",
	reveal = {
		ren = {
			image = "ren",
			pos = {x=.6, y=1}
		}
	}
}}
