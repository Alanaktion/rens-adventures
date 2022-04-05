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
- Chapters
- Conditional messages
- Save states
- Skip mode
- Message log
- BGM (MIDI + WAV)
- Choice menu
- Jumping to a specific chapter from the script

Things that still need to be implemented:

- SE (Synth + WAV)
- Dynamic endings
- Character movement transitions
- Jumping to a specific position within a chapter from the script
- Typewriter effect on message display
- Moving libraries out of source and importing files explicitly needed to keep pdx bundle smaller
- CG gallery with unlocks

## Usage

This is a pretty straightforward template to build off of, but there are a few important things to note.

### Scripts

Story chapters run in sequence from the table in the `script.lua` file, like `scripts/0-intro.lua`. Each chapter file returns a numerically-indexed table, which contains tables with messages, character reveals, etc. Each sub-table can include these items:

- `text`: A message to show in a text box
- `name`: A character name to show with the message
- `reveal`: A table of new characters to reveal. Each character should have a named key, and the following items:
	- `image`: The image file name for the character in the `assets/images/chara/` directory
	- `pos`: The x/y coordinates to place the character at as a percentage of the screen dimensions. `{x=0, y=1}` will place the character at the bottom left of the screen, with the center of the image at the left. By default the character will be positioned at `{x=0.5, y=1}` if not specified.
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
- `bgm`: Plays a music file from `assets/audio/bgm/` with the specified name. MIDI sequences should end in `.mid` and have the extension included, while sampled audio should be ADPCM `.wav` files and should not have the extension included in the `bgm` value. Stops any currently-playing BGM when `false`. BGM will loop until stopped.
- `title`: Large title text to show centered on the screen, typically to introduce a new chapter. Typically used by itself, but will be drawn above character/cg images and below message boxes and choices if present.
- `titleInvert`: Draw title text in white instead of black
- `check`: An optional function to determine if the message should be rendered. Return false to skip processing anything else in the message. Typically checks something in Noble.GameData set by previous choices.
- `choice`: A table of options shown to the player, interrupting the script until the player picks an option. Other things in the sequence item like a message, cg, etc will be applied before the choice is displayed. Each choice table item should have the following items:
	- `text`: The text to display to the player
	- `callback`: The function called when the player selects that option
	- `default`: An optional key that, if `true`, will be cause that option to be selected if the player presses the B button
- `jump`: A chapter name to jump to in the script, often used with `check` to conditionally move to a different point in the script.

New chapters should be added to the table in `script.lua` to enable them in the game. The game will progress through the chapters sequentially. Chapters have names for better compatibility with save states during development, primarily to avoid a scenario where a save state includes a numeric index but that chapter was moved to a different index.

### Script Map

During development, it is often helpful to use shorthands and re-use assets. There is a mapping table in `script.lua` that allows you to map values in your script files to a new value at runtime.

This is particularly useful to shorten names and use a single asset file for multiple character images in the script. For example you may want the script to switch between different poses/expressions with `ren_normal` and `ren_excited`, but you only have one `ren.png` since the art is still WIP. You can map `ren_normal` and `ren_excited` to `ren` to ensure a character image is displayed, and remove the mappings once you have the specific images. You may also just prefer having a different (often shorter) name in the script for something, mapped to a longer or more descriptive file name.

The `scriptMap` table can contain any of these keys:

- `chara`: Character images (`ren = "ren_normal"`)
- `pos`: Character positions (`twoleft = {x=0.3, y=1}`)
- `bgm`: Background music mapping (`menu = "theme_music.mid"`)
- `bg`: BG images
- `cg`: CG images
- `name`: Character names shown with messages (`ha = "Hanako"`)

Each key should contain a table mapping the strings found in the script to the new desired values.

### Script functions

The `check` and `choice` keys in scripts require functions to control the flow of the game. While you can define these functions directly in the table, that may lead to a lot of repetition or unwanted complexity in your script.

For example, you may want to conditionally show a series of messages with `check` based on a game data value set by a previous `choice`. The function to do that is fairly simple, something like `check = function() return SaveData.current.scriptData.choice1 == true end`, but writing that over and over leads to a messy script and can be error-prone.

In cases where you need a long/complex or frequently repeated function, it may be best to define it elsewhere in your game code rather than directly within the script table. If the function is only used by one chapter of your script, you could define it before the table in that chapter's script file and reference it by name in your script. If it's used in several chapters, it's best to add it to your `script.lua` file, or in a new lua file that you `include` in your `script.lua`.
