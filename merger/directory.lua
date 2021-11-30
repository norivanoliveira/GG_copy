local os, io, print, table, assert, TryCatch = os, io, print, table, assert, TryCatch

local function Exists(directory)
	local isok, errstr, errcode = true, false, false
	TryCatch(function()
		isok, errstr, errcode = os.rename(directory, directory)
	end, function(err)
		print("")
		print(directory)
		print(err)
		print("")
	end)
	if isok == nil then
		if errcode == 13 then
			-- Permission denied, but it exists
			return true
		end
		return false
	end
	return true
end

return {
	Exists = Exists,

	Create = function(directory)
		if not Exists(directory) then
			os.execute('mkdir "' .. directory .. '"')
			while not Exists(directory) do
				print("creating directory...")
			end
		end
	end,

	Files = function(directory, prefix)
		local files = {}
		local f = assert(io.popen('dir /b "' .. directory .. '"'))
		for line in f:lines() do
			table.insert(files, prefix and prefix .. line or line)
		end
		f:close()
		return files
	end,
}
