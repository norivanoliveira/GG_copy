working_dir = "../../"
gos_ext_dir = love.filesystem.getAppdataDirectory() .. "/GamingOnSteroids/LOLEXT/"

print = require("print").add

function string:CountCharacter(c)
	local count = 0
	for i = 1, #self do
		if self:sub(i, i) == c then
			count = count + 1
		end
	end
	return count
end

function TryCatch(f, catch_f)
	local status, exception = pcall(f)
	if not status and catch_f then
		catch_f(exception)
		return true
	end
	return false
end

File = require("file")
Path = require("path")
Directory = require("directory")
Projects = require("projects")

local d = {
	working_dir .. "GG/Headers.lua",
	working_dir .. "GG/Methods.lua",
}

local Project = require("project")

Project("GGAIO", "GG/AIO", true, 0, d).Merge()

Project("GGOrbwalker", "GG/Orbwalker", true, 0, d).Merge()

Project("GGPrediction", "GG/Prediction", true, 1, d).Merge()

Project("GGCore", "GG/Core", true, 1, d).Merge()

Project("GGData", "GG/Data", true, 1, d).Merge()

--Project("GG", "GG" true, 0, d).Merge()

print("Finish!")

-- love.event.quit()
