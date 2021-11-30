local TryCatch = TryCatch
return {

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
		TryCatch(function()
			f:write(text)
			f:close()
		end, function(err)
			print("")
			print(file)
			print(err)
			print("")
		end)
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
