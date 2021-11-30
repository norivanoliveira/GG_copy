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
		local isok, errstr, errcode = true, false, false
		TryCatch(function()
			isok, errstr, errcode = os.rename(directory, directory)
		end, function(err)
			print(err)
		end)
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

local function GetComponent(path, suffix)
	local content = File.ReadAll(path)
	if content then
		return {
			Suffix = suffix,
			Content = File.ReadAll(path) .. "\n",
		}
	end
end

return function(args)
	local __minify__ = args.Minify

	local __dependencies__ = args.Dependencies
	local __components__ = args.Components
	local __backup_dir__ = args.BackupPath
	local __components_dir__ = args.ComponentsPath

	local __finish_files__ = args.FinishFiles

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
			Directory.Create(File.Path(__backup_dir__ .. "/" .. item.Suffix))
			File.WriteAll(__backup_dir__ .. "/" .. item.Suffix, item.Content)
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
