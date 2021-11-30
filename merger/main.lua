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

local Project = require("project")

Project("GGAIO", "GG/AIO", true, Path.LOLEXT("Scripts")):Merge()

Project("GGOrbwalker", "GG/Orbwalker", true, Path.LOLEXT("Scripts")):Merge()

Project("GGPrediction", "GG/Prediction", true, Path.LOLEXT("Scripts/Common")):Merge()

Project("GGCore", "GG/Core", true, Path.LOLEXT("Scripts/Common")):Merge()

Project("GGData", "GG/Data", true, Path.LOLEXT("Scripts/Common")):Merge()

--Project("GG", "GG" true, Path.LOLEXT("Scripts")):Merge()

print("Finish!")

-- love.event.quit()
