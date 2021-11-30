local File, Directory = File, Directory
return function(args)
	local __minify__ = args.Minify

	local __dependencies__ = args.Dependencies
	local __components__ = args.Components
	local __backup_dir__ = args.BackupPath
	local __components_dir__ = args.ComponentsPath

	local __finish_files__ = args.FinishFiles

	local function GetComponent(_path, _suffix)
		local content = File.ReadAll(_path)
		if content then
			return {
				Suffix = _suffix,
				Content = File.ReadAll(_path) .. "\n",
			}
		end
	end

	Directory.Create(__backup_dir__)
	Directory.Create(__components_dir__)

	local Result = {}
	for i, component in pairs(__dependencies__) do
		Result[#Result + 1] = GetComponent(component)
	end
	for i, component in pairs(__components__) do
		Result[#Result + 1] = GetComponent(__components_dir__ .. component, component)
	end

	for _, item in pairs(Result) do
		if item.Suffix then
			Directory.Create(File.Path(__backup_dir__ .. item.Suffix))
			File.WriteAll(__backup_dir__ .. item.Suffix, item.Content)
		end
	end

	local FinishContent = ""
	for _, item in pairs(Result) do
		FinishContent = FinishContent .. item.Content
	end

	Directory.Create(__backup_dir__ .. "/")
	File.WriteAll(__backup_dir__ .. "/.old." .. File.NameExtension(__finish_files__[2]), FinishContent)

	for _, finishFile in pairs(__finish_files__) do
		Directory.Create(File.Path(finishFile))
		File.WriteAll(finishFile, FinishContent)
	end

	if __minify__ then
		TryCatch(function()
			FinishContent = require("minify")(FinishContent)
			for i = 2, #__finish_files__ do
				local f = __finish_files__[i]
				File.WriteAll(File.Path(f) .. File.Name(f) .. ".Minified" .. File.Extension(f), FinishContent)
			end
		end, function(err)
			print(__components_dir__)
			print(err)
		end)
	end
end
