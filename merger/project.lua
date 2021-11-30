local working_dir, Path, Projects = working_dir, Path, Projects

return function(_name, _path, _minify, _gos_path, _dependencies)
	local name = _name
	local path = _path
	local minify = _minify
	local dependencies = _dependencies
	local finish_file = _gos_path == 0 and Path.LOLEXT("Scripts") or Path.LOLEXT("Scripts/Common")

	local __args__ = {
		Minify = minify,
		BackupPath = Path.Backup(".backup/" .. path),
		ComponentsPath = Path.Components(path),

		Dependencies = dependencies,
		Components = Projects[name],

		FinishFiles = {
			working_dir .. "/.new." .. name .. ".lua",
		},

		GosFinishFile = finish_file and finish_file .. "/" .. name .. ".lua",
	}

	return {
		Merge = function()
			print(name)
			require("merger")(__args__)
		end,
	}
end
