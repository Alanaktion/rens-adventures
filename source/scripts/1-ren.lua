return {{
	title = "Chapter 2: Ren",
}, {
	cg = "ren-face",
	text = "...",
},{
	cg = false,
	name = "Ren",
	text = "This is the second chapter!",
},{
	choice = {{
		text = "The first option",
		callback = function()
			print("picked 1")
			SaveData.current.scriptData.renChoice = 1
		end
	}, {
		text = "The 'default' option",
		callback = function()
			print("picked 2")
			SaveData.current.scriptData.renChoice = 2
		end,
		default = true
	}},
	text = "Choose a thing"
}}
