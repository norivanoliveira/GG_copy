local unpack, Files = unpack, Directory.Files

return {

	GGAIO = {
		"Updater.lua",
		"Headers.lua",
		"Methods.lua",
		"Menu.lua",
		"Main.lua",
		unpack(Files(working_dir .. "GG/AIO/Champions/", "Champions/")),
	},

	GGOrbwalker = {
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
	},

	GGPrediction = {
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
	},

	GGCore = {
		"Updater.lua",
		"Headers.lua",
		"PermaShow.lua",
		"Menu.lua",
		"Main.lua",
	},

	GGData = {
		"Updater.lua",
		"Headers.lua",
		"Hero/Immobile.lua",
		-- 'Hero/Info.lua',
		-- 'Hero/PassiveDamage.lua',
		-- 'Hero/SpellInfo.lua',
		-- 'Item/PassiveDamage.lua',
		"Main.lua",
	},

	--[[GG = {
        "GGCore.lua",
        "GGData.lua",
        "GGPrediction.lua",
        "GGOrbwalker.lua",
        "GGAIO.lua",
    },]]
}
