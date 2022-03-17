-- Put your utilities and other helper functions here.
-- The "Utilities" table is already defined in "noble/Utilities.lua."
-- Try to avoid name collisions.

function Utilities.getZero()
	return 0
end

function Utilities.formatDateTime(time)
	local str = ""
	local months = {
		"January",
		"February",
		"March",
		"April",
		"May",
		"June",
		"July",
		"August",
		"September",
		"October",
		"November",
		"December",
	}
	str = time.day .. " " .. months[time.month] .. " " .. time.year
	str = str .. "  " .. string.format("%02d:%02d:%02d", time.hour, time.minute, time.second)
	return str
end
