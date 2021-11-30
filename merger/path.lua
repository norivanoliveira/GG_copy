local os, working_dir, gos_ext_dir = os, working_dir, gos_ext_dir

return {
	Backup = function(fileName)
		return working_dir .. fileName .. "/" .. os.date("%d.%m.%Y") .. "/" .. os.date("%H %M %S") .. "/"
	end,

	Components = function(fileName)
		return working_dir .. fileName .. "/"
	end,

	LOLEXT = function(file)
		return gos_ext_dir .. file
	end,
}
