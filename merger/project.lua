local working_dir, Path, Projects = working_dir, Path, Projects
return function(_name, _path, _minify, _finish_file)
	local name = _name
	local path = _path
	local minify = _minify
	local finish_file = _finish_file

	local __args__ = {
		Minify = minify,
		BackupPath = Path.Backup(".backup/" .. path),
		ComponentsPath = Path.Components(path),

		Dependencies = {
			working_dir .. "GG/Headers.lua",
			working_dir .. "GG/Methods.lua",
		},
		Components = Projects[name],

		FinishFiles = {
			working_dir .. "/.new." .. name .. ".lua",
			finish_file and finish_file .. "/" .. name .. ".lua",
		},
	}

	return {
		Merge = function()
			print(name)
			require("merger")(__args__)
		end,
	}
end
