-- Need to import into local vars then add to table due to a compiler bug
-- https://devforum.play.date/t/compiler-error-importing-lua-script-file-into-table/3627
local intro = import "scripts/0-intro"
local ren = import "scripts/1-ren"

script = {
	{
		name = "intro",
		sequence = intro
	},
	{
		name = "ren",
		sequence = ren
	},
}
