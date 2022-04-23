<?php

// This script hackily attempts to convert a Ren'Py script file to a Ren's Adventures-style Playdate Lua table. It's really janky but it saves time compared to manually doing _everything_. You should have your input .rpy scripts in support/rpy/ and it'll generate corresponding lua files in support/lua/.

// Written in PHP because ¯\_(ツ)_/¯

// Important things this does not handle:
// - Choices (menu:)
// - Conditional display
// - Jumping to labels
// Basically anywhere it adds a comment in the Lua file is somewhere that probably needs manual corrections.

if (empty($argv[1])) {
	echo "Usage: php {$argv[0]} <rpy name>";
	exit(1);
}

if (!is_dir('lua')) {
	shell_exec('mkdir lua');
}
$file = $argv[1];
if (str_contains($file, '/')) {
	// This terrible hack brought to you by convert-rpy.sh
	$file = substr($file, 4, -4);
}
$rpy="rpy/{$file}.rpy";
$lua="lua/{$file}.lua";

$in = file_get_contents($rpy);
$in = str_replace("\r\n", "\n", $in);
$blocks = explode("\n\n", $in);

$result = "return {\n";

// Array of character names currently revealed
// Determines whether reveal/move is added to lua
$chara = [];
$curCg = null;
$curBg = null;

foreach ($blocks as $bi=>$block) {
	if (trim($block) == '') continue;
	$result .= "{\n";

	$lines = explode("\n", $block);
	foreach ($lines as $i=>$line) {
		$line = trim($line);
		if ($line == '') continue;

		// We don't care about manual message box control
		if (str_starts_with($line, 'window ')) continue;
		// We don't have transitions
		if (str_starts_with($line, 'with ')) continue;
		// We don't have a full-screen message box
		if (str_starts_with($line, 'nvl ')) continue;

		// Labels
		if (str_starts_with($line, 'label ')) {
			$result .= "\t-- " . rtrim(trim($line), ':') . "\n";
			continue;
		}

		// New scene - clear visible characters
		if (str_starts_with($line, 'scene ') && $chara) {
			$result .= "\thide = {\"";
			$result .= implode('", "', array_keys($chara));
			$result .= "\"},\n";
			$chara = [];
		}

		// BG
		if (str_starts_with($line, 'scene bg ')) {
			if ($curCg) {
				$result .= "\tcg = false,\n";
				$curCg = false;
			}
			$bg = explode(' ', $line)[2];
			$curBg = $bg;
			$result .= "\tbg = \"$bg\",\n";
			continue;
		}

		// CG
		if (
			str_starts_with($line, 'scene ev ') ||
			str_starts_with($line, 'scene evh ')
		) {
			$cg = explode(' ', $line)[2];
			$curCg = $cg;
			$result .= "\tcg = \"$cg\",\n";
			continue;
		}

		// Black scene hack
		if ($line == 'scene black') {
			if (!$curBg && !$curCg) {
				$result .= "\tbg = false, -- this is fine\n";
				echo "Set scene to black but no cg/bg was set.", PHP_EOL;
			}
			if ($curBg) {
				$result .= "\tbg = false,\n";
				$curBg = null;
			}
			if ($curCg) {
				$result .= "\tcg = false,\n";
				$curCg = null;
			}
			continue;
		}

		// Character reveal/move/hide
		// TODO: support multiple "show" lines in a block correctly
		if (str_starts_with($line, 'show ')) {
			$parts = explode(' ', rtrim($line, ':'));
			$name = $parts[1];
			if ($name == 'bg') {
				if ($curCg) {
					$result .= "\tcg = false,\n";
					$curCg = false;
				}
				$bg = $parts[2];
				$curBg = $bg;
				$result .= "\tbg = \"$bg\",\n";
				continue;
			}
			$image = isset($parts[2]) ? "{$name}_{$parts[2]}" : $name;
			$mode = array_key_exists($name, $chara) ? 'move' : 'reveal';
			$result .= "\t$mode = {\n";
			$result .= "\t\t$name = {\n";
			$result .= "\t\t\timage = \"{$image}\",\n";
			// Add named position aliases
			if (
				isset($parts[3]) &&
				$parts[3] == "at" &&
				isset($parts[4])
			) {
				if (preg_match('/^[a-z_]+$/i', $parts[4])) {
					$result .= "\t\t\tpos = \"{$parts[4]}\",\n";
				} else {
					$partCount = count($parts);
					$result .= "\t\t\t-- pos =";
					for ($i = 4; $i < $partCount; $i ++) {
						$result .= ' ' . $parts[$i];
					}
					$result .= ",\n";
				}
			}
			$result .= "\t\t},\n";
			$result .= "\t},\n";
			$chara[$name] = $image;
			continue;
		}
		// TODO: support hiding multiple characters in a block correctly
		if (str_starts_with($line, 'hide ')) {
			$parts = explode(' ', $line);
			$name = $parts[1];
			$result .= "\thide = {\"$name\"},\n";
			unset($chara[$name]);
			continue;
		}

		// Sound
		if (str_starts_with($line, 'play music')) {
			$bgm = explode(' ', $line)[2];
			$result .= "\tbgm = \"$bgm\",\n";
			continue;
		}
		if (str_starts_with($line, 'stop music')) {
			$result .= "\tbgm = false,\n";
			continue;
		}
		if (str_starts_with($line, 'play sound')) {
			$se = explode(' ', $line)[2];
			$result .= "\tse = \"$se\",\n";
			continue;
		}

		// Text
		if (str_starts_with($line, '"')) {
			if (str_contains($line, '" "')) {
				// Named one-off characters
				// This is a bad hack but probably works
				$parts = explode('" "', $line, 2);
				$result .= "\tname = {$parts[0]}\",\n";
				$text = str_replace(['“', '”'], '\\"', $parts[1]);
				$result .= "\ttext = \"$text\n";
			} else {
				// Unnamed text/thoughts
				$text = str_replace(['“', '”'], '\\"', $line);
				$result .= "\ttext = $text\n";
			}
			continue;
		}
		// This converts the full-screen messages to small message boxes, probably lots of truncation 😅
		if (str_starts_with($line, 'n "')) {
			$text = str_replace(['“', '”'], '\\"', substr($line, 2));
			$text = str_replace('\\n', '', $line);
			$result .= "\ttext = $text\n";
			continue;
		}
		if (preg_match('/^([a-z_]+) ("[^"]+")$/', $line, $matches)) {
			$result .= "\tname = \"{$matches[1]}\",\n";
			$text = str_replace(['“', '”'], '\\"', $matches[2]);
			$result .= "\ttext = $text\n";
			continue;
		}

		$result .= "\t-- " . $line . "\n";
		echo 'Unhandled line: ', $line, PHP_EOL;
	}

	$result .= "}, ";
}

$result .= "}\n";

// Remove blocks where literally nothing happened.
$result = str_replace(", {\n}", '', $result);

file_put_contents($lua, $result);
