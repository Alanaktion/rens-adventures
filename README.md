# Ren's Adventures

A simple test game featuring セキレン

This is a simple visual novel coded in Lua for the Playdate handheld console. It is developed as an example to build other, more complex and complete games around. It's built on [Noble Engine](https://github.com/NobleRobot/NobleEngine), mostly because its scene handlers are really nice.

This project includes example font and image assets from Panic, Inc. licensed under Creative Commons 4.0.

Things that work now:

- Title/end screens
- Screen transitions
- Showing/moving character sprites
- Dialogue progression
- Background changing
- Showing CGs

Things that still need to be implemented:

- Chapters
- Decision trees
- Save states
- Character movement transitions
- Animated character sprites

## Usage

This is a pretty straightforward template to build off of, but there are a few important things to note.

### Scripts

Story chapters run in sequence from a chapter "script" file, like `scripts/intro.lua`. Scripts are made up of a numerically-indexed table that contains tables with messages, character reveals, etc. Each sub-table can include these items:

- `text`: A message to show in a text box
- `name`: A character name to show with the message
- `reveal`: A table of new characters to reveal. Each character should have a named key, and the following items:
	- `image`: The image file name for the character in the `assets/images/chara/` directory
	- `pos`: The x/y coordinates to place the character at as a percentage of the screen dimensions. `{x=0, y=1}` will place the character at the bottom left of the screen, with the center of the image at the left.
	- `flip`: This optional bool will flip the character image horizontally
	- `center`: This optional table value will invoke `sprite:setCenter(x, y)` when revealing the character. It uses the same `{x=0, y=0}` syntax as `pos`. By default, characters use `{x=.5, y=1}`.
- `move`: A table of characters to move. Characters should have the same keys as when they were added via `reveal`, and can include any of the following items:
	- `pos`: The x/y coordinates to move the character to
	- `flip`: Change whether the character sprite is flipped horizontally
	- `duration`: The duration in ms to move the character to the new position (not yet implemented)
	- `ease`: The easing function from `playdate.easingFunctions` to use when animating with `duration`. `inOutQuad` will be used by default.
- `hide`: A table of character keys to hide, for example `{"ren"}` will hide a `ren={...}` character that was previously revealed.
- `bg`: Shows a background image from `assets/images/bg/` with the specified name, or removes the current background when `false`.
- `cg`: Shows a CG image from `assets/images/cg/` with the specified name, or removes the current CG when `false`.
