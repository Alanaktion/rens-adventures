local function choice1()
	print("picked 1")
	SaveData.current.scriptData.renChoice = 1
end

local function choice2()
	print("picked 2")
	SaveData.current.scriptData.renChoice = 2
end

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
		callback = choice1,
	}, {
		text = "The 'default' option",
		callback = choice2,
		default = true
	}},
	text = "Choose a thing"
}}
