-- Noble.GameData is too unfinished and buggy to be useful for this, so I'm implementing it myself with something designed more specifically for VNs. An "auto" save is used by default, which is automatically written whenever the game quits or the device sleeps. Numbered save slots can be used to allow the player to explicitly load/save the game state.
SaveData = {}

-- The default keys and values for a save state
SaveData.schema = {
	chapterName = "",
	chapterFile = "",
	chapterIndex = 0,
	scriptData = {},
}

-- The current save state data
-- This is the current state of the game to use when re-entering the Game scene from elsewhere, and what to write when saving the game.
SaveData.current = {}

-- Set the current save data to the default values
function SaveData.init()
	SaveData.current = table.deepcopy(SaveData.schema)
end

-- Load save data for the given slot into SaveData.current
function SaveData.load(__slot)
	SaveData.init()
	local slot = __slot or "auto"
	local jsonData = playdate.datastore.read("SaveData-" .. slot)
	if jsonData ~= nil then
		for key, value in next, jsonData do
			SaveData.current[key] = value
		end
	end
end

-- Read data from a save file without modifying SaveData.current
function SaveData.getAll(__slot)
	local slot = __slot or "auto"
	return playdate.datastore.read("SaveData-" .. slot)
end

-- Save the current data into the given slot
function SaveData.save(__slot)
	local slot = __slot or "auto"
	SaveData.current.timestamp = playdate.getGMTTime()
	if SaveData.current.chapterFile ~= nil and SaveData.current.chapterFile ~= "" then
		playdate.datastore.write(SaveData.current, "SaveData-" .. slot, true)
		return true
	end
	return false
end

-- Delete the stored save data for a given slot
function SaveData.delete(__slot)
	local slot = __slot or "auto"
	playdate.datastore.delete("SaveData-" .. slot)
end

-- Check if the given save data exists
function SaveData.exists(__slot)
	local slot = __slot or "auto"
	return playdate.file.exists("SaveData-" .. slot .. ".json")
end
