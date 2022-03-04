# Ren's Adventures

A simple test game featuring セキレン

This is a simple visual novel coded in Lua for the Playdate handheld console. It is developed as an example to build other, more complex and complete games around. It's built on [Noble Engine](https://github.com/NobleRobot/NobleEngine), mostly because it's scene handlers are really nice.

This project includes example font and image assets from Panic, Inc. licensed under Creative Commons 4.0.

Things that work now:

- Title/end screens
- Character sprites
- Scene transitions
- Dialogue progression

Things that still need to be implemented:

- Decision trees
- Save states
- Character position transitions
- Animated character sprites

## Usage

This is a pretty straightforward template to build off of, but there are a few important things to note.

### Scripts

Story scenes run in sequence from a "script" file, like `scripts/intro.lua`. Scripts are made up of a numerically-indexed table that contains tables with messages, character reveals, etc. Each sub-table can include these items:

- `text`: A message to show in a text box
- `name`: A character name to show with the message
- `reveal`: A table of new characters to reveal. Each character should have a named key, and the following items:
	- `image`: The image file name for the character in the `images/chara/` directory
	- `pos`: The x/y coordinates to place the character at. `{x=0, y=1}` will place the character at the bottom left of the screen, with the center of the image at the left.
	- `flip`: This optional bool will flip the character image horizontally
	- `center`: This optional table value will invoke `sprite:setCenter(x, y)` when revealing the character. It uses the same `{x=0, y=0}` syntax as `pos`. By default, characters use `{x=.5, y=1}`.
- `hide`: A table of character keys to hide, for example `{"ren"}` will hide a `ren={...}` character that was previously revealed.
