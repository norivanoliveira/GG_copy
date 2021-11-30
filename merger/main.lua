local love = love
local unpack = unpack

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
			table.insert(files, prefix and prefix .. line or line)
		end
		f:close()
		return files
	end,
}

local function GetMergeArgs(name, path, minify, components, finish_file)
	print(name)

	return {

		Minify = minify,
		BackupPath = Path.Backup(".backup/" .. path),
		ComponentsPath = Path.Components(path),

		Dependencies = {
			working_dir .. "GG/Headers.lua",
			working_dir .. "GG/Methods.lua",
		},
		Components = components,

		FinishFiles = {
			working_dir .. "/.new." .. name .. ".lua",
			finish_file and finish_file .. "/" .. name .. ".lua",
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
			unpack(Directory.Files(working_dir .. "GG/AIO/Champions/", "Champions/")),
		}

		local args = GetMergeArgs("GGAIO", "GG/AIO", true, components, Path.LOLEXT("Scripts"))

		require("merger")(args)
	end,

	GGOrbwalker = function()
		local components = {
			"Updater.lua",
			"Headers.lua",
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

		local args = GetMergeArgs("GGOrbwalker", "GG/Orbwalker", true, components, Path.LOLEXT("Scripts"))

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

		local args = GetMergeArgs("GGPrediction", "GG/Prediction", true, components, Path.LOLEXT("Scripts/Common"))

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

		local args = GetMergeArgs("GGCore", "GG/Core", true, components, Path.LOLEXT("Scripts/Common"))

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

		local args = GetMergeArgs("GGData", "GG/Data", true, components, Path.LOLEXT("Scripts/Common"))

		require("merger")(args)
	end,

	--[[GG = function()
		local components = {
			"Headers.lua",
			"Methods.lua",
			"GGCore.lua",
			"GGData.lua",
			"GGPrediction.lua",
			"GGOrbwalker.lua",
			"GGAIO.lua",
		}

		local args = GetMergeArgs("GG", "GG" true, components, Path.LOLEXT("Scripts"))

		require("merger")(args)
	end,]]
}

Projects.GGAIO()
Projects.GGOrbwalker()
Projects.GGPrediction()
Projects.GGCore()
Projects.GGData()
--Projects.GG()

print("Finish!")

-- love.event.quit()
