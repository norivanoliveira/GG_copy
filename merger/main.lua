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

local app_data_path = love.filesystem.getAppdataDirectory()
local gos_ext_dir = app_data_path .. "/GamingOnSteroids/LOLEXT/"
local working_dir = "../../"

local Path = {

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

local Directory = {

	Files = function(directory, prefix)
		local files = {}
		local f = assert(io.popen('dir /b "' .. directory .. '"'))
		for line in f:lines() do
			table.insert(files, prefix ~= nil and prefix .. line or line)
		end
		f:close()
		return files
	end,
}

local function GetMergeArgs(name, minify, components, finish_file)
	print(name)

	return {

		Minify = minify,
		BackupPath = Path.Backup(name .. "/backup"),
		ComponentsPath = Path.Components(name .. "/src"),

		Components = components,

		FinishFiles = {
			working_dir .. name .. ".lua",
			working_dir .. name .. "/bin/" .. name .. ".lua",
			finish_file,
		},
	}
end

local Projects = {

	GGAIO = function()
		local components = {
			"Updater.lua",
			"Headers.lua",
			"Methods.lua",
			"Menu.lua",
			"Main.lua",
			unpack(Directory.Files(working_dir .. "GGAIO/src/Champions/", "Champions/")),
		}

		local args = GetMergeArgs("GGAIO", true, components, Path.LOLEXT("Scripts/GGAIO.lua"))

		require("merger")(args)
	end,

	GGOrbwalker = function()
		local components = {
			"Updater.lua",
			"Headers.lua",
			"Functions.lua",
			"ChampionInfo.lua",
			"FlashHelper.lua",
			"Cached.lua",
			"Icons.lua",
			"Menu.lua",
			"Color.lua",
			"Action.lua",
			"Buff.lua",
			"Damage.lua",
			"Data.lua",
			"Spell.lua",
			"SummonerSpell.lua",
			"Item.lua",
			"Object.lua",
			"Target.lua",
			"Health.lua",
			"Movement.lua",
			"Override.lua",
			"Cursor.lua",
			"Attack.lua",
			"Orbwalker.lua",
			"Main.lua",
		}

		local args = GetMergeArgs("GGOrbwalker", true, components, Path.LOLEXT("Scripts/GGOrbwalker.lua"))

		require("merger")(args)
	end,

	GGPrediction = function()
		local components = {
			"Updater.lua",
			"Headers.lua",
			"Menu.lua",
			"Immobile.lua",
			"Vector2D.lua",
			"Path.lua",
			"UnitData.lua",
			"ObjectManager.lua",
			"Collision.lua",
			"Prediction.lua",
			"Main.lua",
		}

		local args = GetMergeArgs("GGPrediction", true, components, Path.LOLEXT("Scripts/Common/GGPrediction.lua"))

		require("merger")(args)
	end,

	GGCore = function()
		local components = {
			"Updater.lua",
			"Headers.lua",
			"PermaShow.lua",
			"Menu.lua",
			"Main.lua",
		}

		local args = GetMergeArgs("GGCore", true, components, Path.LOLEXT("Scripts/Common/GGCore.lua"))

		require("merger")(args)
	end,

	GGData = function()
		local components = {
			"Updater.lua",
			"Headers.lua",
			"Hero/Immobile.lua",
			-- 'Hero/Info.lua',
			-- 'Hero/PassiveDamage.lua',
			-- 'Hero/SpellInfo.lua',
			-- 'Item/PassiveDamage.lua',
			"Main.lua",
		}

		local args = GetMergeArgs("GGData", true, components, Path.LOLEXT("Scripts/Common/GGData.lua"))

		require("merger")(args)
	end,
}

Projects.GGAIO()
Projects.GGOrbwalker()
Projects.GGPrediction()
Projects.GGCore()
Projects.GGData()

print("Finish!")

-- love.event.quit()
