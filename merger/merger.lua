local File, Directory

File = {

	Exists = function(file)
		local f = io.open(file, "r")
		if f then
			f:close()
			return true
		end
		return false
	end,

	ReadAll = function(file)
		local f = io.open(file, "r")
		if f then
			local content = f:read("*all")
			f:close()
			return content
		end
		assert(true, print("ERROR File.ReadAll"))
		return false
	end,

	WriteAll = function(file, text)
		local f = io.open(file, "w")
		f:write(text)
		f:close()
	end,

	Path = function(file)
		return file:match("(.*[/\\])")
	end,

	Name = function(file)
		return file:match("[^/]*.$"):match("(.+)%..+$")
	end,

	Extension = function(file)
		return file:match("^.+(%..+)$")
	end,

	NameExtension = function(file)
		return file:match("[^/]*.$")
	end,
}

Directory = {

	Create = function(directory)
		if not Directory.Exists(directory) then
			os.execute('mkdir "' .. directory .. '"')
			while not Directory.Exists(directory) do
				print("creating directory...")
			end
		end
	end,

	Exists = function(directory)
		local isok, errstr, errcode = os.rename(directory, directory)
		if isok == nil then
			if errcode == 13 then
				-- Permission denied, but it exists
				return true
			end
			return false
		end
		return true
	end,
}

return function(args)
	local __minify__ = args.Minify

	local __components__ = args.Components
	local __backup_path__ = args.BackupPath
	local __components_path__ = args.ComponentsPath

	local __finish_files__ = args.FinishFiles

	Directory.Create(__backup_path__)
	Directory.Create(__components_path__)

	local Result = {}
	for _, component in pairs(__components__) do
		Result[#Result + 1] = {
			Path = component,
			Content = File.ReadAll(__components_path__ .. component) .. "\n",
		}
	end

	for _, item in pairs(Result) do
		Directory.Create(File.Path(__backup_path__ .. "src/" .. item.Path))
		File.WriteAll(__backup_path__ .. "src/" .. item.Path, item.Content)
	end

	local FinishContent = ""
	for _, item in pairs(Result) do
		FinishContent = FinishContent .. item.Content
	end

	Directory.Create(__backup_path__ .. "bin/")
	File.WriteAll(__backup_path__ .. "bin/" .. File.NameExtension(__finish_files__[1]), FinishContent)

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
			print(__components_path__)
			print(err)
		end)
	end
end
