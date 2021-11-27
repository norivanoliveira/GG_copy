local __version__ = 1.01
local __name__ = 'GGData'

if _G.GGData then return end

if not FileExist(COMMON_PATH .. "GGCore.lua") then
    if not _G.DownloadingGGCore then
        DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GG/master/GGCore.lua", COMMON_PATH .. "GGCore.lua", function() end)
        print('GGCore - downloaded! Please 2xf6!')
        _G.DownloadingGGCore = true
    end
    return
end
require('GGCore')

GGUpdate:New({
    version = __version__,
    scriptName = __name__,
    scriptPath = COMMON_PATH .. __name__ .. ".lua",
    scriptUrl = "https://raw.githubusercontent.com/gamsteron/GG/master/" .. __name__ .. ".lua",
    versionPath = COMMON_PATH .. "GGVersion.lua",
    versionType = 0,
})

_G.GGData = true
_G.DownloadingGGData = true
local HeroSpellInfo
local HeroPassiveDamage
local ItemPassiveDamage
--["bardrstasis"] = true, --bard R statis prediction (zhonya etc)

local DEBUG_ENABLED = false

local BUFF_STOPPREDICT = 10
local BUFF_STOPSTUNSPELLS = 11
local BUFF_STOPSTUNSPELLS_MSHIELD = 12
local BUFF_SLOWMS = 13
local BUFF_FASTMS = 14
local BUFF_FASTMS_CUSTOM = 15
local BUFF_DASH = 20
local BUFF_DASH_AHRI = 21--ahriseducedoom
local BUFF_DASH_FIDDLE = 22
local BUFF_DASH_RAMMUS = 23
local BUFF_DASH_EVELYNN = 24
local BUFF_DASH_SHEN = 25
local BUFF_DASH_GALIO = 26
local BUFF_STUN = 30
local BUFF_STUN_IFNOTDASH = 31
local BUFF_STUN_BELOW05 = 32
local BUFF_STUN_ABOVE05 = 33
local BUFF_INTERRUPTABLE_SLOW = 40
local BUFF_INTERRUPTABLE_IFHITBEFOREEND = 41
local BUFF_INTERRUPTABLE_STUN = 42
local SPELL_STOPPREDICT = 50
local SPELL_DASH = 60
local SPELL_DASH_STOP = 61
local SPELL_STUN = 70
local SPELL_STUN_IFNOTDASH = 71
local SPELL_STUN_IFNOTDASH_AATROX = 72
local SPELL_STUN_03 = 73
local SPELL_STUN_ENDTIME = 74
local SPELL_STUN_015 = 75
local SPELL_INTERRUPTABLE = 80
local SPELL_INTERRUPTABLEDEF = 81
local SPELL_INTERRUPTABLE_IFHITBEFOREEND = 82
local SPELL_INTERRUPTABLE_IHBE_MINUS15 = 83--IFHITBEFOREEND
local SPELL_INTERRUPTABLE_IHBE_MINUS1 = 84--IFHITBEFOREEND
local SPELL_INTERRUPTABLE_SPEED = 85
local SPELL_INTERRUPTABLE_SLOW = 86
local SPELL_INTERRUPTABLE_UNKNOWN = 87
local SPELL_BLINK_STOP = 90
local SPELL_BLINK = 91
local SPELL_BLINK_IFHITBEFOREEND = 92

local IsAttackSpell = {
    ['CaitlynHeadshotMissile'] = true,
    ['GarenQAttack'] = true,
    ['KennenMegaProc'] = true,
    ['MordekaiserQAttack'] = true,
    ['MordekaiserQAttack1'] = true,
    ['MordekaiserQAttack2'] = true,
    ['QuinnWEnhanced'] = true,
    ['BlueCardPreAttack'] = true,
    ['RedCardPreAttack'] = true,
    ['GoldCardPreAttack'] = true,
    -- 9.9 patch
    ['RenektonSuperExecute'] = true,
    ['RenektonExecute'] = true,
    ['XinZhaoQThrust1'] = true,
    ['XinZhaoQThrust2'] = true,
    ['XinZhaoQThrust3'] = true,
    ['MasterYiDoubleStrike'] = true,
}

local IsNotAttack = {
    ['GravesAutoAttackRecoil'] = true,
    ['LeonaShieldOfDaybreakAttack'] = true,
}

local BD = {}
local SD = {}

local ChampionData =
{
    --[[
Vex
Seraphine
Rell
]]
    --rell
    --seraphine
    ["Aatrox"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["AatroxQWrapperCast"] = SPELL_STUN_IFNOTDASH_AATROX, --CASTENDTIME q immobile -> only if E dash is not ready
            ["AatroxW"] = SPELL_STUN, --CASTENDTIME w immobile
        },
    },
    ["Ahri"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["AhriSeduce"] = SPELL_STUN, --CASTENDTIME e immobile
            ["AhriOrbofDeception"] = SPELL_STUN, --CASTENDTIME q immobile
        },
    },
    ["Akali"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["AkaliEb"] = SPELL_DASH, --dash
            ["AkaliR"] = SPELL_DASH, --dash
            ["AkaliQ"] = SPELL_STUN, --immobile
            ["AkaliRb"] = SPELL_DASH, --dash
            ["AkaliE"] = SPELL_DASH, --dash
        },
    },
    ["Akshan"] =
    {
        Buffs =
        {
            ["akshanpassivemovementspeed"] = BUFF_FASTMS_CUSTOM, --speed - increase move speed in akshan calculations if has not this buff
            ["akshanqhaste"] = BUFF_FASTMS, --speed - stop predict if is moving + has this buff
        },
        Spells =
        {
            ["AkshanQ"] = SPELL_STUN, --immobile
            ["AkshanRMissile"] = SPELL_STUN, --immobile
        },
    },
    ["Alistar"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["Pulverize"] = SPELL_STUN, --alistar q - immobile
            ["FerociousHowl"] = SPELL_STUN, --alistar r - immobile
        },
    },
    ["Amumu"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["BandageToss"] = SPELL_STOPPREDICT, --dash spell but there is chance to miss, skip this spell
            ["CurseoftheSadMummy"] = SPELL_STUN, --amumu R - immobile
            ["Tantrum"] = SPELL_STUN, --amumu E - immobile
        },
    },
    ["Anivia"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["Frostbite"] = SPELL_STUN, --e immobile
            ["FlashFrostSpell"] = SPELL_STUN, --q immobile
            ["Crystallize"] = SPELL_STUN, --w immobile
        },
    },
    ["Annie"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["AnnieQ"] = SPELL_STUN, --immobile
            ["AnnieR"] = SPELL_STUN, --immobile
            ["AnnieW"] = SPELL_STUN, --immobile
        },
    },
    ["Aphelios"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["ApheliosR"] = SPELL_STUN, --CASTENDTIME r immobile
            ["ApheliosGravitumQ"] = SPELL_STUN, --CASTENDTIME q immobile
            ["ApheliosCalibrumQ"] = SPELL_STUN, --CASTENDTIME q immobile
            ["ApheliosInfernumQ"] = SPELL_STUN, --CASTENDTIME q immobile
            ["ApheliosCrescendumQ"] = SPELL_STUN, --CASTENDTIME q immobile
        },
    },
    ["Ashe"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["VolleyRank5"] = SPELL_STUN, --ashe w - immobile
            ["VolleyRank2"] = SPELL_STUN, --ashe w - immobile
            ["EnchantedCrystalArrow"] = SPELL_STUN, --ashe r - immobile
            ["VolleyRank3"] = SPELL_STUN, --ashe w - immobile
            ["VolleyRank4"] = SPELL_STUN, --ashe w - immobile
            ["Volley"] = SPELL_STUN, --ashe w - immobile
            ["AsheSpiritOfTheHawk"] = SPELL_STUN, --ashe e - immobile
        },
    },
    ["AurelionSol"] =
    {
        Buffs =
        {
            ["aurelionsolelinearflight"] = BUFF_DASH, --aurelion E dash
        },
        Spells =
        {
            ["AurelionSolR"] = SPELL_STUN, --immobile, can cancel/interrupt
        },
    },
    ["Azir"] =
    {
        Buffs =
        {
            ["AzirE"] = BUFF_STOPPREDICT, --azir E dashing, stop predict!
        },
        Spells =
        {
            ["AzirR"] = SPELL_STUN, --azir R immobile - maybe can interrupt
            ["AzirQ"] = SPELL_STUN, --azir Q immobile
        },
    },
    ["Bard"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["BardR"] = SPELL_STUN, --CASTENDTIME r immobile
            ["BardWHealthPack"] = SPELL_STUN, --CASTENDTIME w immobile
            ["BardQ"] = SPELL_STUN, --CASTENDTIME q immobile
        },
    },
    ["Blitzcrank"] =
    {
        Buffs =
        {
            --["slow"] = BUFF_SLOWMS, --slow: priority in prediction
            ["Overdrive"] = BUFF_FASTMS, --speed: stop predict
        },
        Spells =
        {
            ["StaticField"] = SPELL_STUN, -- blitz r immobile, maybe can interrupt
            ["RocketGrab"] = SPELL_STUN_03, -- blitz q, add 0.3 to castendtime!
        },
    },
    ["Brand"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["BrandR"] = SPELL_STUN, --immobile
            ["BrandQ"] = SPELL_STUN, --immobile
            ["BrandE"] = SPELL_STUN, --immobile
            ["BrandW"] = SPELL_STUN, --immobile
        },
    },
    ["Braum"] =
    {
        Buffs =
        {
            ["braumeshieldbuff"] = BUFF_STOPPREDICT, --braum shield stop predict!
        },
        Spells =
        {
            ["BraumQ"] = SPELL_STUN, --immobile
            ["BraumRWrapper"] = SPELL_STUN, --immobile
        },
    },
    ["Caitlyn"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["CaitlynAceintheHole"] = SPELL_INTERRUPTABLE, --ENDTIME - Game.Timer()||| cait R immobile
            ["CaitlynYordleTrap"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| cait W immobile
            ["CaitlynPiltoverPeacemaker"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| cait Q immobile
        },
    },
    ["Camille"] =
    {
        Buffs =
        {
            ["camilleedash1"] = BUFF_STOPPREDICT, --camille E dash 1 - only if castpos is between start and end pos, stop using if will not hit
            ["CamilleEDash2"] = BUFF_DASH, --camille E dash 2 - only if castpos is between start and end pos, stop using if will not hit
        },
        Spells =
        {
        },
    },
    ["Cassiopeia"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["CassiopeiaR"] = SPELL_STUN, --CASTENDTIME r immobile
            ["CassiopeiaQ"] = SPELL_STUN, --CASTENDTIME q immobile
            ["CassiopeiaW"] = SPELL_STUN, --CASTENDTIME w immobile
        },
    },
    ["Chogath"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["Rupture"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| Q - immobile
            ["Feast"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| R - immobile
            ["FeralScream"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| W - immobile
        },
    },
    ["Corki"] =
    {
        Buffs =
        {
            ["valkyriesound"] = BUFF_DASH, --corkBi W dash or W package dash
            ["corkiloadedspeed"] = BUFF_FASTMS, --corki package W speed - stop predict in high hitchance, corki too fast or can use W
        },
        Spells =
        {
            ["MissileBarrageMissile2"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| R - immobile
            ["PhosphorusBomb"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| Q - immobile
            ["MissileBarrageMissile"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| R - immobile
        },
    },
    ["Darius"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["DariusExecute"] = SPELL_STUN_IFNOTDASH, --CASTENDTIME r immobile dash cast to endpos
            ["DariusAxeGrabCone"] = SPELL_STUN, --CASTENDTIME e immobile
        },
    },
    ["Diana"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["DianaR"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| R - immobile
            ["DianaQ"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| Q - immobile
        },
    },
    ["DrMundo"] =
    {
        Buffs =
        {
            ["DrMundoPImmunity"] = BUFF_STOPSTUNSPELLS, --stop predict stun spells - mundo passive
        },
        Spells =
        {
            ["DrMundoQ"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| Q - immobile
        },
    },
    ["Draven"] =
    {
        Buffs =
        {
            ["DravenFury"] = BUFF_FASTMS, --draven W speed - stop predict in high hitchance
        },
        Spells =
        {
            ["DravenRCast"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| R - immobile
            ["DravenDoubleShot"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| E - immobile
        },
    },
    ["Ekko"] =
    {
        Buffs =
        {
            ["EkkoPassiveSpeed"] = BUFF_FASTMS, --speed - stop predict in high hitchance
        },
        Spells =
        {
            ["EkkoQ"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| Q - immobile
            ["EkkoW"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| W - immobile
            ["EkkoEAttack"] = SPELL_BLINK_STOP,
        },
    },
    ["Elise"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["EliseHumanW"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| W - immobile
            ["EliseHumanQ"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| Q - immobile
            ["EliseHumanE"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| E - immobile
        },
    },
    ["Evelynn"] =
    {
        Buffs =
        {
            ["evelynnehaste"] = BUFF_FASTMS, --speed - stop predict in high hitchance
        },
        Spells =
        {
            ["EvelynnQ"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| Q - immobile
            ["EvelynnE"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| E - immobile
            ["EvelynnWApplyMark"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| W - immobile
        },
    },
    ["Ezreal"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["EzrealR"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| E - immobile
            ["EzrealE"] = SPELL_BLINK, --CASTENDTIME - Game.Timer()||| E - dash
            ["EzrealQ"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| E - immobile
            ["EzrealW"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| E - immobile
        },
    },
    ["FiddleSticks"] = --Fiddlesticks in riot json
    {
        Buffs =
        {
        },
        Spells =
        {
            ["FiddleSticksE"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| E - immobile
            ["FiddleSticksW"] = SPELL_INTERRUPTABLEDEF, --ENDTIME - Game.Timer()||| W - immobile - can interrupt
            ["FiddleSticksQ"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| Q - immobile
            ["FiddleSticksR"] = SPELL_INTERRUPTABLE_IFHITBEFOREEND, --ENDTIME - Game.Timer()||| R - immobile - can interrupt
        },
    },
    ["Fiora"] =
    {
        Buffs =
        {
            ["FioraQ"] = BUFF_DASH, --dash
        },
        Spells =
        {
        },
    },
    ["Fizz"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["FizzR"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| R - immobile
        },
    },
    ["Galio"] =
    {
        Buffs =
        {
            ["GalioW"] = BUFF_SLOWMS, --galio w slow
            ["galioemove"] = BUFF_STOPPREDICT, --stop predict galio e dash, can hit target
        },
        Spells =
        {
            ["GalioQ"] = SPELL_STUN, --CASTENDTIME q immobile
            ["GalioE"] = SPELL_STOPPREDICT, --stop predict galio first part e dash
            ["GalioR"] = SPELL_INTERRUPTABLE_IHBE_MINUS15, --ENDTIME r immobile only > 1.5sec duration - can interrupt
        },
    },
    ["Gangplank"] =
    {
        Buffs =
        {
            ["gangplankpassivehaste"] = BUFF_FASTMS, --speed - stop predict in high hitchance
        },
        Spells =
        {
            ["GangplankQProceed"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| Q - immobile
            ["GangplankE"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| E - immobile
            ["GangplankW"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| W - immobile
            ["GangplankQProceedCrit"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| Q - immobile
            ["GangplankR"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| R - immobile
        },
    },
    ["Garen"] =
    {
        Buffs =
        {
            ["garenqhaste"] = BUFF_FASTMS, --speed - stop in high hitchance
        },
        Spells =
        {
            ["GarenR"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| R - immobile
            ["GarenQAttack"] = SPELL_STUN_IFNOTDASH, --predict to endPos -> dash attack
        },
    },
    ["Gnar"] =
    {
        Buffs =
        {
            ["GnarE"] = BUFF_STOPPREDICT, --gnar e stop predict, can double dash
        },
        Spells =
        {
            ["GnarR"] = SPELL_STUN, --CASTENDTIME r immobile
            ["GnarBigW"] = SPELL_STUN, --CASTENDTIME w immobile
            ["GnarBigQMissile"] = SPELL_STUN, --CASTENDTIME q immobile
            ["GnarQMissile"] = SPELL_STUN, --CASTENDTIME q immobile
        },
    },
    ["Gragas"] =
    {
        Buffs =
        {
            ["GragasE"] = SPELL_STOPPREDICT, --stop predict, dash can hit target
        },
        Spells =
        {
            ["GragasQ"] = SPELL_STUN, --CASTENDTIME q immobile
            ["GragasR"] = SPELL_STUN, --CASTENDTIME r immobile
        },
    },
    ["Graves"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["GravesChargeShot"] = SPELL_STOPPREDICT, --stop predict
            ["GravesQLineSpell"] = SPELL_STUN, --CASTENDTIME q immobile
            ["GravesSmokeGrenade"] = SPELL_STUN, --CASTENDTIME w immobile
        },
    },
    ["Gwen"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["GwenQ"] = SPELL_STUN,
        },
    },
    ["Hecarim"] =
    {
        Buffs =
        {
            ["hecarimrampspeed"] = BUFF_FASTMS,
        },
        Spells =
        {
        },
    },
    ["Heimerdinger"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["HeimerdingerQ"] = SPELL_STUN,
            ["HeimerdingerWUlt"] = SPELL_STUN,
            ["HeimerdingerEUlt"] = SPELL_STUN,
            ["HeimerdingerQUlt"] = SPELL_STUN,
            ["HeimerdingerE"] = SPELL_STUN,
            ["HeimerdingerW"] = SPELL_STUN,
        },
    },
    ["Illaoi"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["IllaoiE"] = SPELL_STUN_ENDTIME,
            ["IllaoiR"] = SPELL_STUN,
            ["IllaoiQ"] = SPELL_STUN,
        },
    },
    ["Irelia"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["IreliaW"] = SPELL_INTERRUPTABLEDEF,
            ["IreliaR"] = SPELL_STUN,
            ["IreliaW2"] = SPELL_STUN,
        },
    },
    ["Ivern"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["IvernQ"] = SPELL_STUN,
            ["IvernW"] = SPELL_STUN,
            ["IvernR"] = SPELL_STUN,
        },
    },
    ["Janna"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["SowTheWind"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| W - immobile
            ["ReapTheWhirlwind"] = SPELL_INTERRUPTABLEDEF, --ENDTIME - Game.Timer()||| R - immobile - can interrupt
        },
    },
    ["JarvanIV"] =
    {
        Buffs =
        {
            ["jarvanivcataclysmsound"] = BUFF_DASH, --j4 dash
        },
        Spells =
        {
            ["JarvanIVDragonStrike"] = SPELL_STOPPREDICT,
        },
    },
    ["Jax"] =
    {
        Buffs =
        {
            --["JaxEmpowerTwo"] = true,--increased attack range jax W
        },
        Spells =
        {
        },
    },
    ["Jayce"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["JayceThunderingBlow"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| E - immobile
            ["JayceShockBlast"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| Q - immobile
        },
    },
    ["Jhin"] =
    {
        Buffs =
        {
            ["jhinpassivehaste"] = BUFF_FASTMS, --speed - lower hitchance
        },
        Spells =
        {
            ["JhinR"] = SPELL_INTERRUPTABLE, --ENDTIME - Game.Timer()||| R - immobile -- can interrupt
            ["JhinW"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| W - immobile
            ["JhinE"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| E - immobile
            ["JhinQ"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| Q - immobile
        },
    },
    ["Jinx"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["JinxR"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| R - immobile
            ["JinxWMissile"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| W - immobile
        },
    },
    ["Kaisa"] =
    {
        Buffs =
        {
            ["KaisaE"] = BUFF_FASTMS, --speed stop predict if kaisa hasmovepath
        },
        Spells =
        {
            ["KaisaW"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| W - immobile
        },
    },
    ["Kalista"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["KalistaW"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| W - immobile
            ["KalistaExpunge"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| E - immobile
        },
    },
    ["Karma"] =
    {
        Buffs =
        {
            ["KarmaQ"] = BUFF_FASTMS, --speed - karma E (game mistake)
        },
        Spells =
        {
            ["KarmaSpiritBind"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| W - immobile
            ["KarmaQ"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| Q - immobile
        },
    },
    ["Karthus"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["KarthusWallOfPain"] = SPELL_STUN,
            ["KarthusFallenOne"] = SPELL_INTERRUPTABLE,
            ["KarthusLayWasteA1"] = SPELL_STUN,
        },
    },
    ["Kassadin"] =
    {
        Buffs =
        {
            --["NetherBlade"] = true,-- orbwalker increased attack range
        },
        Spells =
        {
            ["ForcePulse"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| E - immobile
            ["RiftWalk"] = SPELL_BLINK, --CASTENDTIME - Game.Timer()||| R - dash
            ["NullLance"] = SPELL_STUN, --CASTENDTIME - Game.Timer()||| Q - immobile
        },
    },
    ["Katarina"] =
    {
        Buffs =
        {
            ["katarinawhaste"] = BUFF_FASTMS, --katarina w speed
        },
        Spells =
        {
            ["KatarinaE"] = SPELL_BLINK_STOP, --CASTENDTIME katarina E dash
            ["KatarinaR"] = SPELL_INTERRUPTABLE, --ENDTIME katarina R - immobile can interrupt
            ["KatarinaQ"] = SPELL_STUN, --CASTENDTIME katarina Q immobile
            ["KatarinaEDagger"] = SPELL_BLINK_STOP, --CASTENDTIME katarina E dash
        },
    },
    ["Kayle"] =
    {
        Buffs =
        {
            ["KayleW"] = BUFF_FASTMS, -- speed
        },
        Spells =
        {
            ["KayleWHeal"] = SPELL_STUN, --CASTENDTIME W immobile
            ["KayleQ"] = SPELL_STUN, --CASTENDTIME Q immobile
        },
    },
    ["Kayn"] =
    {
        Buffs =
        {
            ["KaynR"] = BUFF_STOPPREDICT,
        },
        Spells =
        {
            ["KaynRJumpOut"] = SPELL_STOPPREDICT,
            ["KaynW"] = SPELL_STUN_015,
        },
    },
    ["Kennen"] =
    {
        Buffs =
        {
            ["KennenLightningRush"] = BUFF_FASTMS, --speed
        },
        Spells =
        {
            ["KennenShurikenStorm"] = SPELL_STUN, --r
            ["KennenShurikenHurlMissile1"] = SPELL_STUN, --q
            --["KennenMegaProc"] = true,??
            ["KennenBringTheLight"] = SPELL_STUN, --w
        },
    },
    ["Khazix"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["KhazixWLong"] = SPELL_STUN,
            ["KhazixQLong"] = SPELL_STUN,
            ["KhazixW"] = SPELL_STUN,
            ["KhazixQ"] = SPELL_STUN,
            ["KhazixQEvo"] = SPELL_STUN,
            ["KhazixWEvo"] = SPELL_STUN,
            ["KhazixEEvo"] = SPELL_STUN,
            ["KhazixREvo"] = SPELL_STUN,
        },
    },
    ["Kindred"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["KindredFakeCastTimeSpell"] = SPELL_STUN,
            ["KindredE"] = SPELL_STUN,
        },
    },
    ["Kled"] =
    {
        Buffs =
        {
            --[[["kledrshieldcounter"] = true,
            ["KledE2"] = true,
            ["KledW"] = true,
            ["kledespeedbuff"] = true,
            ["kledrchargeshield"] = true,
            ["KledRDash"] = true,
            ["KledRChargeAllySpeedBuff"] = true,
            ["KledRunCycleManager"] = true,
            ["KledPassive"] = true,
            ["kledwactive"] = true,]]
        },
        Spells =
        {
            ["KledQ"] = SPELL_STUN,
        },
    },
    ["KogMaw"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["KogMawQ"] = SPELL_STUN, --CASTENDTIME Q immobile
            ["KogMawLivingArtillery"] = SPELL_STUN, --CASTENDTIME R immobile
            ["KogMawVoidOozeMissile"] = SPELL_STUN, --CASTENDTIME E immobile
        },
    },
    ["Leblanc"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["LeblancRE"] = SPELL_STUN, --CASTENDTIME E immobile
            ["LeblancE"] = SPELL_STUN, --CASTENDTIME E immobile
            ["LeblancRQ"] = SPELL_STUN, --CASTENDTIME Q immobile
            ["LeblancQ"] = SPELL_STUN, --CASTENDTIME Q immobile
        },
    },
    ["LeeSin"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["BlindMonkRKick"] = SPELL_STUN,
            ["BlindMonkEOne"] = SPELL_STUN,
            ["BlindMonkQOne"] = SPELL_STOPPREDICT,
        },
    },
    ["Leona"] =
    {
        Buffs =
        {
            --["LeonaShieldOfDaybreak"] = true,--orbwalker increased attack range
        },
        Spells =
        {
            ["LeonaZenithBlade"] = SPELL_STOPPREDICT, --stop predict! dash spell but can miss!
            ["LeonaSolarFlare"] = SPELL_STUN, --CASTENDTIME R immobile
        },
    },
    ["Lillia"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["LilliaE"] = SPELL_STUN,
        },
    },
    ["Lissandra"] =
    {
        Buffs =
        {
            ["LissandraE"] = BUFF_STOPPREDICT,
            ["LissandraRSelf"] = BUFF_STOPPREDICT,
        },
        Spells =
        {
            ["LissandraREnemy"] = SPELL_STUN,
            ["LissandraEMissile"] = SPELL_STOPPREDICT,
            ["LissandraQMissile"] = SPELL_STUN,
        },
    },
    ["Lucian"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["LucianW"] = SPELL_STUN, --CASTENDTIME W immobile
            ["LucianQ"] = SPELL_STUN, --CASTENDTIME Q immobile
        },
    },
    ["Lulu"] =
    {
        Buffs =
        {
            ["luluwbuff"] = BUFF_FASTMS, --speed
        },
        Spells =
        {
            ["LuluQ"] = SPELL_STUN, --CASTENDTIME Q immobile
        },
    },
    ["Lux"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["LuxRMis"] = SPELL_STUN, --CASTENDTIME R immobile
            ["LuxPrismaticWave"] = SPELL_STUN, --CASTENDTIME W immobile
            ["LuxLightBinding"] = SPELL_STUN, --CASTENDTIME Q immobile
            ["LuxLightStrikeKugel"] = SPELL_STUN, --CASTENDTIME E immobile
        },
    },
    ["Malphite"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["SeismicShard"] = SPELL_STUN, --CASTENDTIME Q immobile
            ["Landslide"] = SPELL_STUN, --CASTENDTIME E immobile
        },
    },
    ["Malzahar"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["MalzaharR"] = SPELL_INTERRUPTABLE,
            ["MalzaharE"] = SPELL_STUN,
            ["MalzaharQ"] = SPELL_STUN,
        },
    },
    ["Maokai"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["MaokaiE"] = SPELL_STUN,
            ["MaokaiR"] = SPELL_STUN,
            ["MaokaiQ"] = SPELL_STUN,
        },
    },
    ["MasterYi"] =
    {
        Buffs =
        {
            ["AlphaStrike"] = BUFF_STOPPREDICT, --stop predict, yi in Q
            ["Highlander"] = BUFF_FASTMS, --yi r speed
        },
        Spells =
        {
            ["Meditate"] = SPELL_INTERRUPTABLEDEF, --ENDTIME W immobile - can interrupt
        },
    },
    ["MissFortune"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["MissFortuneScattershot"] = SPELL_STUN, --CASTENDTIME E immobile
            ["MissFortuneBulletTime"] = SPELL_INTERRUPTABLE, --ENDTIME R immobile
            ["MissFortuneRicochetShot"] = SPELL_STUN, --CASTENDTIME Q immobile
        },
    },
    ["Mordekaiser"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["MordekaiserR"] = SPELL_STOPPREDICT,
            ["MordekaiserE"] = SPELL_STUN,
            ["MordekaiserQ"] = SPELL_STUN,
        },
    },
    ["Morgana"] =
    {
        Buffs =
        {
            ["MorganaE"] = BUFF_STOPSTUNSPELLS_MSHIELD, --stop predict stun spells if has magic shield
        },
        Spells =
        {
            ["MorganaQ"] = SPELL_STUN, --CASTENDTIME Q immobile
            ["MorganaW"] = SPELL_STUN, --CASTENDTIME W immobile
            ["MorganaR"] = SPELL_STUN, --CASTENDTIME R immobile
        },
    },
    ["Nami"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["NamiR"] = SPELL_STUN,
            ["NamiQ"] = SPELL_STUN,
            ["NamiW"] = SPELL_STUN,
        },
    },
    ["Nasus"] =
    {
        Buffs =
        {
            --["NasusQ"] = true,--orb increased attack range
        },
        Spells =
        {
            ["NasusW"] = SPELL_STUN, --CASTENDTIME W immobile
            ["NasusE"] = SPELL_STUN, --CASTENDTIME E immobile
            ["NasusR"] = SPELL_STUN, --CASTENDTIME R immobile
        },
    },
    ["Nautilus"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["NautilusSplashZone"] = SPELL_STUN,
            ["NautilusGrandLine"] = SPELL_STUN,
            ["NautilusAnchorDragMissile"] = SPELL_STOPPREDICT,
        },
    },
    ["Neeko"] =
    {
        Buffs =
        {
            ["neekor2"] = BUFF_STUN,
        },
        Spells =
        {
            ["NeekoQ"] = SPELL_STUN,
            ["NeekoE"] = SPELL_STUN,
        },
    },
    ["Nidalee"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["PrimalSurge"] = SPELL_STUN, --CASTENDTIME E immobile
            ["Swipe"] = SPELL_STUN, --CASTENDTIME E immobile
            ["Bushwhack"] = SPELL_STUN, --CASTENDTIME W immobile
            ["JavelinToss"] = SPELL_STUN, --CASTENDTIME Q immobile
        },
    },
    ["Nocturne"] =
    {
        Buffs =
        {
            ["nocturneparanoiadash"] = BUFF_DASH,
        },
        Spells =
        {
            ["NocturneDuskbringer"] = BUFF_STUN,
        },
    },
    ["Nunu"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["NunuW"] = SPELL_INTERRUPTABLE_SPEED, --ENDTIME W immobile can interrupt
            ["NunuR"] = SPELL_INTERRUPTABLE, --ENDTIME R immobile can interrupt
            ["NunuQ"] = SPELL_STUN, --CASTENDTIME Q immobile
        },
    },
    ["Olaf"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["OlafAxeThrowCast"] = SPELL_STUN, --CASTENDTIME Q immobile
            ["OlafRecklessStrike"] = SPELL_STUN, --CASTENDTIME E immobile
        },
    },
    ["Orianna"] =
    {
        Buffs =
        {
            ["orianahaste"] = BUFF_FASTMS, --speed
        },
        Spells =
        {
            ["OrianaDetonateCommand"] = SPELL_STUN, --CASTENDTIME R immobile
        },
    },
    ["Ornn"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["OrnnR"] = SPELL_STUN,
            ["OrnnQ"] = SPELL_STUN,
            ["OrnnE"] = SPELL_STOPPREDICT, --dash can hit wall
        },
    },
    ["Pantheon"] =
    {
        Buffs =
        {
            ["PantheonQ"] = BUFF_SLOWMS,
        },
        Spells =
        {
            ["PantheonR"] = SPELL_INTERRUPTABLE_IHBE_MINUS1,
            ["PantheonE"] = SPELL_STOPPREDICT,
            ["PantheonQTap"] = SPELL_STUN,
            ["PantheonQMissile"] = SPELL_STUN,
        },
    },
    ["Poppy"] =
    {
        Buffs =
        {
            --["poppywzone"] = true,--cant use dash spells on this target
            ["PoppyR"] = BUFF_INTERRUPTABLE_SLOW, --interruptable poppy R loading
        },
        Spells =
        {
            ["PoppyQSpell"] = SPELL_STUN, --CASTENDTIME Q immobile
            ["PoppyRSpell"] = SPELL_STUN_ENDTIME, --ENDTIME R immobile --but cant interrupt!
            ["PoppyRSpellInstant"] = SPELL_STUN_ENDTIME, --ENDTIME R immobile --but cant interrupt!
        },
    },
    ["Pyke"] =
    {
        Buffs =
        {
            ["PykeQ"] = BUFF_INTERRUPTABLE_SLOW, --interruptable pyke Q loading
        },
        Spells =
        {
            ["PykeQMelee"] = SPELL_STUN, --CASTENDTIME Q immobile
            ["PykeQRange"] = SPELL_STUN_03, --CASTENDTIME Q immobile + 0.3 sec like thresh q or blitz q
            ["PykeR"] = SPELL_STOPPREDICT, --stop predict - can miss R so pyke can dash to startpos!
            ["PykeE"] = SPELL_DASH, --dash
        },
    },
    ["Qiyana"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["QiyanaQ_Rock"] = SPELL_STUN,
            ["QiyanaQ"] = SPELL_STUN,
            ["QiyanaR"] = SPELL_STUN,
            ["QiyanaQ_Water"] = SPELL_STUN,
            ["QiyanaQ_Grass"] = SPELL_STUN,
        },
    },
    ["Quinn"] =
    {
        Buffs =
        {
            ["QuinnE"] = BUFF_STOPPREDICT, --stop predict too fast and double dash
            ["QuinnESecond"] = BUFF_STOPPREDICT, --stop predict too fast and double dash
        },
        Spells =
        {
            ["QuinnR"] = SPELL_INTERRUPTABLEDEF, --ENDTIME R immobile -- can interrupt
            ["QuinnQ"] = SPELL_STUN, --CASTENDTIME Q immobile
        },
    },
    ["Rakan"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["RakanW"] = SPELL_STUN_IFNOTDASH,
            ["RakanWCast"] = SPELL_STUN,
            ["RakanQ"] = SPELL_STUN,
        },
    },
    ["Rammus"] =
    {
        Buffs =
        {
            ["DefensiveBallCurl"] = BUFF_SLOWMS, --rammus W slowed - priority
        },
        Spells =
        {
            ["PuncturingTaunt"] = SPELL_STUN, --CASTENDTIME E immobile
            ["PowerBall"] = SPELL_INTERRUPTABLE_SPEED, --ENDTIME Q speed -- can interrupt but hard to hit
        },
    },
    ["RekSai"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["RekSaiE"] = SPELL_STUN,
            ["RekSaiR"] = SPELL_STOPPREDICT,
            ["RekSaiQBurrowed"] = SPELL_STUN,
        },
    },
    --rell
    ["Renekton"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["RenektonExecute"] = SPELL_STUN_ENDTIME,
            ["RenektonReignOfTheTyrant"] = SPELL_STUN,
            ["RenektonSuperExecute"] = SPELL_STUN_ENDTIME,
        },
    },
    ["Rengar"] =
    {
        Buffs =
        {
            ["rengarpassiveempoweredms"] = BUFF_FASTMS, --rengar empowered W speed
        },
        Spells =
        {
            ["RengarE"] = SPELL_STUN, --CASTENDTIME E immobile
            ["RengarEEmp"] = SPELL_STUN, --CASTENDTIME E immobile
        },
    },
    ["Riven"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["RivenMartyr"] = SPELL_STUN,
            ["RivenIzunaBlade"] = SPELL_STUN,
            ["RivenFengShuiEngine"] = SPELL_STUN,
        },
    },
    ["Rumble"] =
    {
        Buffs =
        {
            ["rumbleshieldbuff"] = BUFF_FASTMS,
        },
        Spells =
        {
            ["RumbleGrenade"] = SPELL_STUN,
            ["RumbleCarpetBombDummy"] = SPELL_STUN,
        },
    },
    ["Ryze"] =
    {
        Buffs =
        {
            ["RyzeQMS"] = BUFF_FASTMS, --ryze speed
        },
        Spells =
        {
            ["RyzeQ"] = SPELL_STUN, --CASTENDTIME Q immobile
            ["RyzeE"] = SPELL_STUN, --CASTENDTIME E immobile
            ["RyzeW"] = SPELL_STUN, --CASTENDTIME W immobile
        },
    },
    ["Samira"] =
    {
        Buffs =
        {
            ["SamiraW"] = BUFF_STOPPREDICT,
        },
        Spells =
        {
            ["SamiraW"] = SPELL_STOPPREDICT,
            ["SamiraQSword"] = SPELL_STUN,
            ["SamiraQGun"] = SPELL_STUN,
        },
    },
    ["Sejuani"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["SejuaniR"] = SPELL_STUN, --CASTENDTIME R immobile
            ["SejuaniE2"] = SPELL_STUN, --CASTENDTIME E immobile
        },
    },
    ["Senna"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["SennaQCast"] = SPELL_STUN,
            ["SennaR"] = SPELL_STUN,
            ["SennaW"] = SPELL_STUN,
        },
    },
    --seraphine
    ["Sett"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["SettE"] = SPELL_STUN_03, --CASTENDTIME E immobile + 0.3sec
            ["SettW"] = SPELL_STUN, --CASTENDTIME W immobile
        },
    },
    ["Shaco"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["HallucinateFull"] = SPELL_INTERRUPTABLE_IHBE_MINUS1,
            ["TwoShivPoison"] = SPELL_STUN,
            ["JackInTheBox"] = SPELL_STUN,
        },
    },
    ["Shen"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["ShenR"] = SPELL_INTERRUPTABLE_IFHITBEFOREEND,
        },
    },
    ["Shyvana"] =
    {
        Buffs =
        {
            ["ShyvanaImmolateDragon"] = BUFF_FASTMS,
            ["ShyvanaTransformLeap"] = BUFF_DASH,
            ["ShyvanaImmolationAura"] = BUFF_FASTMS,
        },
        Spells =
        {
            ["ShyvanaFireball"] = SPELL_STUN,
            ["ShyvanaFireballDragon2"] = SPELL_STUN,
            ["ShyvanaTransformLeap"] = SPELL_DASH, --only if dashing
        },
    },
    ["Singed"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["MegaAdhesive"] = SPELL_STUN, --CASTENDTIME W immobile
            ["Fling"] = SPELL_STUN, --CASTENDTIME E immobile
        },
    },
    ["Sion"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["SionQ"] = SPELL_INTERRUPTABLE,
            ["SionE"] = SPELL_STUN,
        },
    },
    ["Sivir"] =
    {
        Buffs =
        {
            ["SivirE"] = BUFF_STOPPREDICT,
            ["sivirpassivespeed"] = BUFF_FASTMS,
            ["SivirR"] = BUFF_FASTMS,
        },
        Spells =
        {
            ["SivirQ"] = SPELL_STUN,
        },
    },
    ["Skarner"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["SkarnerFractureMissile"] = SPELL_STUN,
            ["SkarnerImpale"] = SPELL_STUN,
        },
    },
    ["Sona"] =
    {
        Buffs =
        {
            ["sonaeselfhaste"] = BUFF_FASTMS,
        },
        Spells =
        {
            ["SonaR"] = SPELL_STUN,
        },
    },
    ["Soraka"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["SorakaR"] = SPELL_STUN,
            ["SorakaQ"] = SPELL_STUN,
            ["SorakaW"] = SPELL_STUN,
            ["SorakaE"] = SPELL_STUN,
        },
    },
    ["Swain"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["SwainE"] = SPELL_STUN,
            ["SwainW"] = SPELL_STUN,
            ["SwainQ"] = SPELL_STUN,
        },
    },
    ["Sylas"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["SylasE2"] = SPELL_STOPPREDICT,
            ["SylasR"] = SPELL_STUN,
            ["SylasQ"] = SPELL_STUN,
        },
    },
    ["Syndra"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["SyndraE5"] = SPELL_STUN,
            ["SyndraRCastTime"] = SPELL_STUN,
            ["SyndraE"] = SPELL_STUN,
        },
    },
    ["TahmKench"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["TahmKenchW"] = SPELL_STOPPREDICT,
            ["TahmKenchR"] = SPELL_STUN_03,
            ["TahmKenchQ"] = SPELL_STUN_015,
        },
    },
    ["Taliyah"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["TaliyahQ"] = SPELL_STUN,
            ["TaliyahWVC"] = SPELL_STUN,
            ["TaliyahR"] = SPELL_INTERRUPTABLE_UNKNOWN,
            ["TaliyahE"] = SPELL_STUN,
        },
    },
    ["Talon"] =
    {
        Buffs =
        {
            ["TalonRHaste"] = BUFF_FASTMS,
            ["TalonEHop"] = BUFF_DASH,
        },
        Spells =
        {
            ["TalonW"] = SPELL_STUN,
            ["TalonQAttack"] = SPELL_STUN_015,
        },
    },
    ["Taric"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["TaricQ"] = SPELL_STUN,
            ["TaricR"] = SPELL_STUN,
            ["TaricW"] = SPELL_STUN,
        },
    },
    ["Teemo"] =
    {
        Buffs =
        {
            ["MoveQuick"] = BUFF_FASTMS,
        },
        Spells =
        {
            ["TeemoRCast"] = SPELL_STUN,
            ["BlindingDart"] = SPELL_STUN,
        },
    },
    ["Thresh"] =
    {
        Buffs =
        {
            ["ThreshQPullMissile"] = BUFF_STOPPREDICT,
        },
        Spells =
        {
            ["ThreshQInternal"] = SPELL_STUN_015,
            ["ThreshRPenta"] = SPELL_STUN,
            ["ThreshE"] = SPELL_STUN_015,
        },
    },
    ["Tristana"] =
    {
        Buffs =
        {
            ["TristanaW"] = BUFF_DASH,
            ["tristanawtrailsound"] = BUFF_DASH,
        },
        Spells =
        {
            ["TristanaR"] = BUFF_STUN,
            ["TristanaE"] = BUFF_STUN,
            ["TristanaW"] = BUFF_STOPPREDICT,
        },
    },
    ["Trundle"] =
    {
        Buffs =
        {
            ["trundledesecratebuffs"] = BUFF_FASTMS,
        },
        Spells =
        {
            ["TrundlePain"] = SPELL_STUN,
            ["TrundleCircle"] = SPELL_STUN,
            ["TrundleQ"] = SPELL_STUN,
        },
    },
    ["Tryndamere"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["TryndamereW"] = SPELL_STUN,
        },
    },
    ["TwistedFate"] =
    {
        Buffs =
        {
            ["Gate"] = BUFF_INTERRUPTABLE_IFHITBEFOREEND,
        },
        Spells =
        {
            ["WildCards"] = SPELL_STUN,
            ["GoldCardPreAttack"] = SPELL_STUN,
            ["RedCardPreAttack"] = SPELL_STUN,
            ["BlueCardPreAttack"] = SPELL_STUN,
        },
    },
    ["Twitch"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["TwitchExpunge"] = SPELL_STUN,
            ["TwitchVenomCask"] = SPELL_STUN,
        },
    },
    ["Udyr"] =
    {
        Buffs =
        {
            ["udyrbearactivation"] = BUFF_FASTMS,
        },
        Spells =
        {
        },
    },
    ["Urgot"] =
    {
        Buffs =
        {
            ["UrgotW"] = BUFF_SLOWMS,
        },
        Spells =
        {
            ["UrgotQ"] = SPELL_STUN,
            ["UrgotE"] = SPELL_DASH_STOP,
            ["UrgotR"] = SPELL_STUN,
        },
    },
    ["Varus"] =
    {
        Buffs =
        {
            ["VarusQ"] = BUFF_SLOWMS,
        },
        Spells =
        {
            ["VarusE"] = SPELL_STUN,
            ["VarusR"] = SPELL_STUN,
            ["VarusQ"] = SPELL_INTERRUPTABLE_SLOW,
        },
    },
    ["Vayne"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["VayneCondemn"] = SPELL_STUN,
        },
    },
    ["Veigar"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["VeigarR"] = SPELL_STUN,
            ["VeigarEventHorizon"] = SPELL_STUN,
            ["VeigarBalefulStrike"] = SPELL_STUN,
            ["VeigarDarkMatterCastLockout"] = SPELL_STUN,
        },
    },
    ["Velkoz"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["VelkozE"] = SPELL_STUN,
            ["VelkozR"] = SPELL_INTERRUPTABLE,
            ["VelkozQ"] = SPELL_STUN,
        },
    },
    ["Vi"] =
    {
        Buffs =
        {
            ["ViR"] = BUFF_STOPPREDICT,
            ["virdunktargetself"] = BUFF_DASH,
            ["ViQLaunch"] = BUFF_INTERRUPTABLE_SLOW,
            ["ViQDash"] = BUFF_STOPPREDICT,
        },
        Spells =
        {
            ["ViR"] = SPELL_STOPPREDICT,
        },
    },
    ["Viego"] =
    {
        Buffs =
        {
            ["ViegoW"] = BUFF_STOPPREDICT,
            ["viegowdash"] = BUFF_DASH,
        },
        Spells =
        {
            ["ViegoW"] = SPELL_STOPPREDICT,
            ["ViegoR"] = SPELL_BLINK,
            ["ViegoQ"] = SPELL_STUN,
            ["ViegoRCast"] = SPELL_STUN,
        },
    },
    ["Viktor"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["ViktorQBuff"] = SPELL_STUN,
            ["ViktorPowerTransfer"] = SPELL_STUN,
            ["ViktorChaosStorm"] = SPELL_STUN,
            ["ViktorGravitonField"] = SPELL_STUN,
        },
    },
    ["Vladimir"] =
    {
        Buffs =
        {
            ["VladimirE"] = BUFF_SLOWMS,
        },
        Spells =
        {
            ["VladimirQ"] = SPELL_STUN,
        },
    },
    ["Volibear"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["VolibearQAttack"] = SPELL_DASH,
            ["VolibearW"] = SPELL_STUN,
        },
    },
    ["Warwick"] =
    {
        Buffs =
        {
            ["WarwickQ"] = BUFF_DASH,
            ["warwickrmiss"] = BUFF_STOPPREDICT, --weird dash, too fast
        },
        Spells =
        {
            ["WarwickQ"] = SPELL_DASH,
            ["WarwickR"] = SPELL_STOPPREDICT, -- dash after
            ["WarwickRChannel"] = SPELL_INTERRUPTABLE, --r hit
        },
    },
    ["MonkeyKing"] = --Wukong
    {
        Buffs =
        {
        },
        Spells =
        {
        },
    },
    ["Xayah"] =
    {
        Buffs =
        {
        },
        Spells =
        {
        },
    },
    ["Xerath"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["XerathMageSpear"] = SPELL_STUN,
            ["XerathLocusOfPower2"] = SPELL_INTERRUPTABLE,
            ["XerathArcanopulseChargeUp"] = SPELL_INTERRUPTABLE_SLOW,
            ["XerathArcaneBarrage2"] = SPELL_STUN,
        },
    },
    ["XinZhao"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["XinZhaoR"] = SPELL_STUN,
            ["XinZhaoW"] = SPELL_STUN,
            ["XinZhaoQThrust1"] = SPELL_STUN,
            ["XinZhaoQThrust3"] = SPELL_STUN,
            ["XinZhaoQThrust2"] = SPELL_STUN,
        },
    },
    ["Yasuo"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["YasuoQ2"] = SPELL_STUN,
            ["YasuoQ3"] = SPELL_STUN,
            ["YasuoQ1"] = SPELL_STUN,
        },
    },
    ["Yone"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["YoneQ"] = SPELL_STUN,
            ["YoneR"] = SPELL_DASH_STOP,
            ["YoneW"] = SPELL_STUN,
            ["YoneQ3"] = SPELL_DASH,
        },
    },
    ["Yorick"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["YorickR"] = SPELL_STUN,
            ["YorickE"] = SPELL_STUN,
        },
    },
    ["Yuumi"] =
    {
        Buffs =
        {
        },
        Spells =
        {
        },
    },
    ["Zac"] =
    {
        Buffs =
        {
            ["ZacE"] = BUFF_INTERRUPTABLE_STUN,
            ["zacemove"] = BUFF_DASH,
        },
        Spells =
        {
            ["ZacR"] = SPELL_STUN,
            ["ZacQ"] = SPELL_STUN_015,
        },
    },
    ["Zed"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["ZedQ"] = SPELL_STUN,
        },
    },
    ["Ziggs"] =
    {
        Buffs =
        {
            ["ziggsmoveawaycollision"] = BUFF_DASH,
        },
        Spells =
        {
            ["ZiggsE"] = SPELL_STUN,
            ["ZiggsR"] = SPELL_STUN,
            ["ZiggsQ"] = SPELL_STUN,
            ["ZiggsW"] = SPELL_STUN,
        },
    },
    ["Zilean"] =
    {
        Buffs =
        {
            ["TimeWarp"] = BUFF_FASTMS,
        },
        Spells =
        {
            ["ZileanQ"] = SPELL_STUN,
        },
    },
    ["Zoe"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["ZoeE"] = SPELL_STUN,
            ["ZoeQMissile"] = SPELL_STUN,
            ["ZoeR"] = SPELL_BLINK_IFHITBEFOREEND,
        },
    },
    ["Zyra"] =
    {
        Buffs =
        {
        },
        Spells =
        {
            ["ZyraQ"] = SPELL_STUN,
            ["ZyraE"] = SPELL_STUN_03,
            ["ZyraR"] = SPELL_STUN,
        },
    },
    ["PracticeTool_TargetDummy"] =
    {
        Buffs =
        {
            ["IvernRMissile"] = BUFF_STUN,
            ["IvernQ"] = BUFF_STUN,
            ["viktorgravitonfieldstun"] = BUFF_STUN,
            ["LilliaE"] = BUFF_SLOWMS,
            ["LilliaRSleep"] = BUFF_STUN,
            ["kledqvisionshare"] = BUFF_STOPPREDICT,
            ["kledqmark"] = BUFF_STOPPREDICT,
            ["kledqslow"] = BUFF_STOPPREDICT,
            ["kledrbump"] = BUFF_DASH,
            ["kledqbump"] = BUFF_DASH,
            ["yuumircc"] = BUFF_STUN,
            ["ViegoWMis"] = BUFF_STUN,
            ["RekSaiEBurrowed"] = BUFF_DASH,
            ["reksaiwknockup"] = BUFF_STUN,
            ["reksaiwslow"] = BUFF_SLOWMS,
            ["namirwavestun"] = BUFF_STUN_IFNOTDASH,
            ["NamiQDebuff"] = BUFF_STUN,
            ["namirwaveslow"] = BUFF_SLOWMS,
            ["namieslow"] = BUFF_SLOWMS,
            ["threshestun"] = BUFF_DASH,
            ["ThreshQ"] = BUFF_STUN_BELOW05,
            ["threshqfakeknockup"] = BUFF_STOPPREDICT,
            ["threshrslow"] = BUFF_SLOWMS,
            ["monkeykingspinknockup"] = BUFF_DASH,
            ["LissandraWFrozen"] = BUFF_STUN,
            ["LissandraREnemy2"] = BUFF_STUN,
            ["LissandraRSlow"] = BUFF_SLOWMS,
            ["SkarnerImpale"] = BUFF_STOPPREDICT,
            ["skarnerpassivestun"] = BUFF_STUN,
            ["skarnerimpaleflashlock"] = BUFF_STOPPREDICT,
            ["skarnerfractureslow"] = BUFF_SLOWMS,
            ["globalwallpush"] = BUFF_DASH,
            ["zyrarknockup"] = BUFF_STUN,
            ["zyraehold"] = BUFF_STUN,
            ["gwenrdebuff"] = BUFF_SLOWMS,
            ["illaoitentacleslow"] = BUFF_SLOWMS,
            ["neekorstun"] = BUFF_STUN,
            ["neekoeroot"] = BUFF_STUN,
            ["ornneknockup"] = BUFF_STUN,
            ["globalwallpush"] = BUFF_STOPPREDICT,
            ["ornnrknockup"] = BUFF_STUN,
            ["sennawroot"] = BUFF_STUN,
            ["urgotrsuppress"] = BUFF_STOPPREDICT,
            ["urgotestun"] = BUFF_STUN_IFNOTDASH,
            ["urgotetoss"] = BUFF_DASH,
            ["varusrroot"] = BUFF_STUN,
            ["varuseslow"] = BUFF_SLOWMS,
            ["velkozestun"] = BUFF_DASH,
            ["velkozqslow"] = BUFF_SLOWMS,
            ["yonerknockup"] = BUFF_STUN,
            ["yonerstun"] = BUFF_STOPPREDICT,
            ["yoneq3knockup"] = BUFF_STUN,
            ["yonerknockback"] = BUFF_STOPPREDICT,
            ["zoeesleepcountdownslow"] = BUFF_STOPPREDICT, --soon stun
            ["zoeesleepstun"] = BUFF_STUN, --zoe e stun
            ["suppression"] = BUFF_STUN, --warwick r
            ["warwickeinternalfearbuff"] = BUFF_DASH, --no dash but slow dash, cast to endpos
            ["VayneCondemnMissile"] = BUFF_STOPPREDICT, --can hit wall - different distances from the wall
            ["Stun"] = BUFF_STUN_IFNOTDASH, --vayne e to wall
            ["veigareventhorizonstun"] = BUFF_STUN,
            ["XinZhaoQKnockup"] = BUFF_STUN,
            ["xinzhaorknockback"] = BUFF_DASH,
            ["slow"] = BUFF_SLOWMS, --xin slow w
            ["timewarpslow"] = BUFF_SLOWMS,
            ["ZileanStunAnim"] = BUFF_STUN,
            ["moveawaycollision"] = BUFF_STUN_IFNOTDASH,
            ["zedeslow"] = BUFF_SLOWMS,
            ["zacehitstun"] = BUFF_STUN_IFNOTDASH,
            ["zacrknockup"] = BUFF_DASH,
            ["zacqslow"] = BUFF_SLOWMS,
            ["zacrslow"] = BUFF_SLOWMS,
            ["yasuorknockup"] = BUFF_STUN,
            ["YasuoQ3Mis"] = BUFF_DASH,
            ["Stun"] = BUFF_STUN_IFNOTDASH, --xerath e stun
            ["xerathwslow"] = BUFF_SLOWMS,
            ["XayahE"] = BUFF_STUN,
            ["VolibearRImpactSlow"] = BUFF_SLOWMS,
            ["VolibearESlow"] = BUFF_SLOWMS,
            ["VolibearQAttack"] = BUFF_STUN,
            ["vladimireslow"] = BUFF_SLOWMS,
            ["vladimirsanguinepoolslow"] = BUFF_SLOWMS,
            ["virknockup"] = BUFF_STUN,
            ["virdunkstun"] = BUFF_STUN,
            ["virknockdown"] = BUFF_STUN,
            ["viqknockback"] = BUFF_DASH,
            ["Stun"] = BUFF_STUN_IFNOTDASH, --udyr e stun
            ["TwitchVenomCaskDebuff"] = BUFF_SLOWMS,
            ["cardmasterslow"] = BUFF_SLOWMS,
            ["tryndamerewslow"] = BUFF_SLOWMS,
            ["trundleqslow"] = BUFF_SLOWMS,
            ["trundlecircleslow"] = BUFF_SLOWMS,
            ["trundlewallbounce"] = BUFF_DASH,
            ["TristanaR"] = BUFF_DASH,
            ["tristanawslow"] = BUFF_SLOWMS,
            ["bantamtrapslow"] = BUFF_SLOWMS,
            ["taricestun"] = BUFF_STUN,
            ["talonwslow"] = BUFF_SLOWMS,
            ["taliyahwmovebuff"] = BUFF_DASH,
            ["taliyahemineslow"] = BUFF_SLOWMS,
            ["taliyahrknockaside"] = BUFF_DASH,
            ["tahmkenchrtargetactualcc"] = BUFF_STOPPREDICT,
            ["tahmkenchrtargetenemy"] = BUFF_STOPPREDICT,
            ["tahmkenchwknockup"] = BUFF_STUN_IFNOTDASH,
            ["tahmkenchqstun"] = BUFF_STUN,
            ["tahmkenchr2targetspit"] = BUFF_STOPPREDICT,
            ["tahmkenchqslow"] = BUFF_SLOWMS,
            ["SyndraEDebuff"] = BUFF_STOPPREDICT, --syndra e dash can stun EQ, fast dash no stun
            ["syndraebump"] = BUFF_STOPPREDICT,
            ["syndrawslow"] = BUFF_SLOWMS,
            ["sylaseknockup"] = BUFF_STUN, --dash but dist from start and end pos < 30
            ["SwainPassivePullMoveBuff"] = BUFF_DASH,
            ["swaineroot"] = BUFF_STOPPREDICT, --only if SwainPassivePullMoveBuff, 1 attack = dash
            --["slow"] = true, --swain w
            ["SorakaQ"] = BUFF_SLOWMS,
            ["sorakaesnare"] = BUFF_STUN,
            ["sonaepassivedebuff"] = BUFF_SLOWMS,
            ["sonaehaste"] = BUFF_FASTMS,
            ["sionrtarget"] = BUFF_STUN_IFNOTDASH,
            ["sionqslow"] = BUFF_SLOWMS,
            ["sioneslow"] = BUFF_SLOWMS,
            ["sionqknockup"] = BUFF_STUN_IFNOTDASH,
            ["sionrslow"] = BUFF_SLOWMS,
            ["shyvanatransformdamage"] = BUFF_DASH, --dash
            ["Taunt"] = BUFF_DASH_SHEN, --shen E - stun, works like dash, but enemy can attack, worse version of charm
            ["shenqslow"] = BUFF_SLOWMS,
            ["shacoboxslow"] = BUFF_DASH, --shaco W stun, flee works like slow dash - endPos
            --["slow"] = true, --shaco e
            ["rumblecarpetbombslow"] = BUFF_SLOWMS,
            ["rumblegrenadeslow"] = BUFF_SLOWMS,
            ["Stun"] = BUFF_STUN_IFNOTDASH, -- riven w
            ["rivenknockback"] = BUFF_STUN_IFNOTDASH, --riven q3
            ["Stun"] = BUFF_STUN_IFNOTDASH, --rene w
            ["rakanwcharm"] = BUFF_STUN, --rakan w stun
            ["rakanrdebuff"] = BUFF_DASH, --rakan r charm -> stun works like slow dash
            ["qiyanaqslow"] = BUFF_SLOWMS, --qiyana q slow
            ["qiyanaqroot"] = BUFF_STUN, --qiyana q stun
            ["qiyanarstun"] = BUFF_STUN, --qiyana r stun
            ["qiyanarknockback"] = BUFF_DASH, --qiyana r dash
            ["Stun"] = BUFF_STUN_IFNOTDASH, --pant w
            ["nocturefleeslow"] = BUFF_DASH, --not dashing but slowed dash - priority, very high hitchance flee
            ["nautilusminorknockaway"] = BUFF_STOPPREDICT,
            ["nautilusanchordragglobalroot"] = BUFF_STOPPREDICT,
            ["nautilusknockup"] = BUFF_STUN_IFNOTDASH,
            ["nautilussplashzoneslow"] = BUFF_SLOWMS,
            ["nautiluspassiveroot"] = BUFF_STUN,
            ["mordekaiserepull"] = BUFF_DASH,
            ["maokaiwroot"] = BUFF_STUN,
            ["maokairroot"] = BUFF_STUN,
            ["maokaiqknockback"] = BUFF_DASH,
            ["MalzaharR"] = BUFF_STUN,
            ["BlindMonkETwoMissile"] = BUFF_SLOWMS,
            ["blindmonkrroot"] = BUFF_STOPPREDICT,
            ["BlindMonkRKick"] = BUFF_DASH,
            ["KindredESlow"] = BUFF_SLOWMS, --slow
            ["khazixwisolatedslow"] = BUFF_SLOWMS, --kha w slow
            ["Stun"] = BUFF_STUN_IFNOTDASH, --kennen stun
            ["kaynwknockup"] = BUFF_STUN, --kayn w stun
            ["kaynwslow"] = BUFF_SLOWMS, --kayn w slow
            ["karthuswallofpaintarget"] = BUFF_SLOWMS, --karthus w slow
            ["jarvanivdragonstrikeph2"] = BUFF_STUN, --j4 stun
            ["ireliarslow"] = BUFF_SLOWMS, --irelia R slow
            ["Stun"] = BUFF_STUN_IFNOTDASH, --irelia E only if has ireliamark buff
            --["ireliamark"] = true, --itelia e, r - Stun if has Stun buff
            ["HeimerdingerESpell"] = BUFF_STUN_ABOVE05, --slow >0sec, stun > 0.5sec
            ["HeimerdingerESpell_ult"] = BUFF_STUN_ABOVE05, --slow >0sec, stun > 0.5sec
            ["heimerdingerultturretslow"] = BUFF_SLOWMS, --slow
            ["hecarimrampattackknockback"] = BUFF_DASH, --hecarim E dash
            ["hecarimultinternalfearbuff"] = BUFF_DASH, --hecarim R fear - to endpos - not dash but it's like dash
            ["gravessmokegrenadeboomslow"] = BUFF_SLOWMS, --graves W slow
            ["aatroxwbump"] = BUFF_STUN_IFNOTDASH, --aatrox w dash - immobile after dash, calc dash pos
            --["aatroxwslow"] = BUFF_SLOWMS,--aatrox w slow -> CAN DASH BEFORE HIT
            ["aatroxqknockback"] = BUFF_STUN_IFNOTDASH, --aatrox q stun and dash -> cast to dash endpos, and check immobile time
            ["akaliqslow"] = BUFF_SLOWMS, --slow: priority in prediction
            --["Charm"] = true,--ahri e stun/slow dash
            ["AhriSeduce"] = BUFF_DASH_AHRI, --ahri e stun/slow dash
            ["Stun"] = BUFF_STUN_IFNOTDASH, --ashe r; amumu q, r; alistar W, E and more champs - ok if has not headbutttarget buff or headbutttarget buff has <= 0 duration
            ["headbutttarget"] = BUFF_STOPPREDICT, --alistar W - stop calculating prediction, target is dashing, but alistar can use Q
            ["Pulverize"] = BUFF_STUN, --alistar Q - ok target is stunned
            ["CurseoftheSadMummy"] = BUFF_STUN, --amumu R
            ["aniviachilled"] = BUFF_SLOWMS, --anivia slow
            ["globalwallpush"] = BUFF_DASH, --anivia w dash
            ["FlashFrostSpell"] = BUFF_STUN, --anivia q stun immobile
            ["anniepassivestun"] = BUFF_STUN, --annie stun
            ["ApheliosGravitumDebuff"] = BUFF_SLOWMS, --aphelios slow
            ["ApheliosGravitumRoot"] = BUFF_STUN, --aphelios stun
            ["ashepassiveslow"] = BUFF_SLOWMS, --slow: priority in prediction
            ["aurelionsolrslow"] = BUFF_SLOWMS, --slow: priority in prediction, only if target is not dashing, has not aurelionsolrknockback buff
            ["aurelionsolrknockback"] = BUFF_DASH, --dash, stop predict
            ["aurelionsolqstun"] = BUFF_STUN, --aurelion q stun
            ["azirrbump"] = BUFF_DASH, -- azir R: stop predict!
            ["azirqslow"] = BUFF_SLOWMS, -- azir Q slow: priority in prediction
            ["BardQInitialTargetDebuff"] = BUFF_SLOWMS, --bard q slow
            ["BardQShackleDebuff"] = BUFF_STUN, --bard q stun
            ["rocketgrab2"] = BUFF_DASH, --blitz Q: stop predict!
            ["powerfistslow"] = BUFF_STUN, --blitz E: stun
            ["braumpulselineslow"] = BUFF_SLOWMS, --braum r slow: priority in prediction
            ["braumstundebuff"] = BUFF_STUN, --braum stun
            ["braumqslow"] = BUFF_SLOWMS, --braum q slow: priority in prediction
            ["caitlynyordletrapdebuff"] = BUFF_STUN, --cait w stun
            ["camilleestun"] = BUFF_STUN_IFNOTDASH, --camille E stun - only if has not camilleeknockback2 buff
            ["camillewconeslashslow"] = BUFF_SLOWMS, -- camille W slow - priority in prediction
            ["camilleeknockback2"] = BUFF_DASH, -- camille E stun dash - stop predict
            ["CassiopeiaRStun"] = BUFF_STUN, --cass r stun immobile
            ["CassiopeiaR"] = BUFF_SLOWMS, -- cass r slow
            ["CassiopeiaWSlow"] = BUFF_SLOWMS, -- cass w slow
            ["vorpalspikesdebuff"] = BUFF_SLOWMS, -- cho E slow - priority in prediction
            ["rupturelaunch"] = BUFF_STUN, -- cho Q stun - immobile
            ["rupturetarget"] = BUFF_SLOWMS, -- cho Q slow - priority in prediction
            ["corkibombmoveaway"] = BUFF_DASH, --corki W package knockback - stop predict or if can hit in dash line!
            ["DangerZoneLoadedTarget"] = BUFF_SLOWMS, --corki package W slow - very strong slow
            ["DariusNoxianTacticsSlow"] = BUFF_SLOWMS, --darius w slow
            ["dariuseslow"] = BUFF_SLOWMS, --darius e slow, stun if has not buff DariusAxeGrabCone
            ["DariusAxeGrabCone"] = BUFF_STOPPREDICT, --stop predict weird dash darius E
            --["slow"] = BUFF_SLOWMS, --slow - priority predict, can be good slow for example diana R
            ["dianarvacuum"] = BUFF_DASH, --diana r knockback - stop predict!
            ["DravenDoubleShot"] = BUFF_DASH, --draven E knockback - stop predict!
            ["DravenDoubleShotMissile"] = BUFF_SLOWMS, --draven E slow - priority predict
            ["ekkoslow"] = BUFF_SLOWMS, --ekko q slow - priority predict
            ["ekkowstun"] = BUFF_STUN, --ekko w stun - immobile
            ["EliseHumanE"] = BUFF_STUN, --elise E stun - immobile
            ["evelynnwcharmslow"] = BUFF_DASH_EVELYNN, --evelynn stun - immobile
            --["Flee"] = ???, --fiddle Q, E, R -> dash, calc endPos-startPos prediction
            ["fleeslow"] = BUFF_DASH_FIDDLE, --fiddle Q, E, R -> dash, calc endPos-startPos prediction
            --["FiddleSticksTerrifyBuff"] = BUFF_DASH_FIDDLE, --fiddle Q Flee -> dash, calc endPos-startPos prediction
            --["fiddlesticksesilence"] = BUFF_DASH_FIDDLE, --fiddle E Silence/Flee -> dash, calc endPos-startPos prediction
            ["fiorawstun"] = BUFF_STUN, --fiora W stun - immobile
            ["fiorawslow"] = BUFF_SLOWMS, --fiora W slow - priority
            ["fizzrknockup"] = BUFF_DASH, --fizz r knockup - dash
            ["fizzeslow"] = BUFF_SLOWMS, --fizz e slow
            ["fizzrslow"] = BUFF_SLOWMS, --fizz r slow
            ["galioknockup"] = BUFF_DASH, --galio e, r dash
            ["galiowslow"] = BUFF_DASH_GALIO, --galio W stun, dash castpos to endpos
            ["gnarstun"] = BUFF_STUN, --gnar w,r stun
            ["gnarrknockbackcc"] = BUFF_DASH, --gnar r dash
            ["gnarrknockback"] = BUFF_DASH, --gnar r dash
            ["gnarqslow"] = BUFF_SLOWMS, --gnar q slow
            ["gragasrmoveaway"] = BUFF_DASH, --good dash gragas R
            ["gragasestun"] = BUFF_DASH, --gragas e dash
            --["Stun"] = true,--gragas E, Stun is good only if target is not dashing
            ["gangplankrslow"] = BUFF_SLOWMS, --gp r slow
            ["gangplankeslow"] = BUFF_SLOWMS, --gp e slow
            --["Silence"] = true,--fiddle Q, garen Q (BAD) etc
            ["jannamoveaway"] = BUFF_DASH, --janna r - dash
            ["HowlingGaleSpell"] = BUFF_STUN, --janna q stun - immobile
            --["slow"] = true,
            --["Stun"] = true,--jax e -> no other buff for jax e
            ["jayceslow"] = BUFF_SLOWMS, --jayce slow - priority
            ["jayceknockedbuff"] = BUFF_DASH, --jayce knockback -> dash
            ["jhinetrapslow"] = BUFF_SLOWMS, -- jhin E slow
            ["JhinW"] = BUFF_STUN, -- jhin W stun - immobile
            ["jhinrslow"] = BUFF_SLOWMS, -- jhin R slow
            ["JinxEMineSnare"] = BUFF_STUN, -- jinx stun E
            ["jinxwsight"] = BUFF_SLOWMS, -- jinx slow W
            ["kalistaeslow"] = BUFF_SLOWMS, --kalista e slow
            ["KalistaRAllyStun"] = BUFF_STUN, --kalista r stun
            ["KarmaQMissileMantraSlow"] = BUFF_SLOWMS, --karma q slow
            ["KarmaQMissileSlow"] = BUFF_SLOWMS, --karma q slow
            ["karmaspiritbindroot"] = BUFF_STUN, --karma W stun - immobile
            --["slow"] = true,--slow kassadin E no other buff name
            ["KayleQ"] = BUFF_SLOWMS, --kayle q slow
            ["kogmawvoidoozeslow"] = BUFF_SLOWMS, --kogmaw E slow
            ["leblanceroot"] = BUFF_STUN, --lb e stun - immobile
            ["leblancreroot"] = BUFF_STUN, --lb e stun - immobile
            --["Stun"] = true,--leona Q, R
            --["leonasolarflareslow"] = true, --leona R - slow or immobile if has Stun buff too, else it's only slow
            ["leonazenithbladeroot"] = BUFF_STUN, --leona E stun
            ["lulurboom"] = BUFF_DASH, --lulu r knockback - dash
            ["luluqslow"] = BUFF_SLOWMS, --lulu q slow
            ["lulurslow"] = BUFF_SLOWMS, --lulu r slow
            ["LuxLightBindingMis"] = BUFF_STUN, --lux q stun immobile
            ["luxeslow"] = BUFF_SLOWMS, --lux e slow
            ["UnstoppableForceStun"] = BUFF_STUN, --malph r stun
            ["SeismicShardBuff"] = BUFF_SLOWMS, --malph q slow
            ["missfortunescattershotslow"] = BUFF_SLOWMS, --mf e slow
            ["MorganaQ"] = BUFF_STUN, --morgana q stun immobile
            ["morganarstun"] = BUFF_STUN, --morgana r stun immobile
            ["morganarslow"] = BUFF_SLOWMS, --morgana r slow
            ["NasusW"] = BUFF_SLOWMS, --nasus w slow
            ["nunueroot"] = BUFF_STUN, --nunu e stun immobile
            --["slow"] = true,--nunu r slow
            ["nunuwknockup"] = BUFF_STUN, --nunu w stun immobile
            ["olafslow"] = BUFF_SLOWMS, --olaf q slow
            ["orianastun"] = BUFF_DASH, --orianna R knockback - dash
            ["moveawaycollision"] = BUFF_STUN, --orianna R knockback - if has not orianastun it's stun immobile else dash
            ["orianaslow"] = BUFF_SLOWMS, --orianna W slow
            ["poppyepushenemy"] = BUFF_DASH, --poppy E on target, target dashing
            ["poppyqslow"] = BUFF_SLOWMS, --poppy q slow
            --["Stun"] = true,--poppy E to wall stun immobile
            ["PykeQMelee"] = BUFF_SLOWMS, --pyke q slow
            ["PykeQRange"] = BUFF_DASH, --pyke q dash
            ["PykeEMissile"] = BUFF_STUN, --pyke e stun immobile
            ["quinneroot"] = BUFF_DASH, --quin e target dashing
            ["powerballslow"] = BUFF_SLOWMS, --rammus q slow
            ["tremorsslow"] = BUFF_SLOWMS, --rammus r slow
            ["powerballstun"] = BUFF_DASH, --rammus q stun - dash
            ["puncturingtauntbuff"] = BUFF_DASH_RAMMUS, --rammus e stun - target can moving but cant cancel move
            ["RengarE"] = BUFF_SLOWMS, --rengar E slow
            ["RengarEEmp"] = BUFF_STUN, --rengar E stun - immobile
            ["ryzewroot"] = BUFF_STUN, --ryze w stun immobile
            ["RyzeW"] = BUFF_SLOWMS, --ryze w slow
            ["sejuanistun"] = BUFF_STUN, --sejuani e, r stun immobile
            ["sejuaniqknockup"] = BUFF_DASH, --sejuani q stun dash
            ["sejuanislow"] = BUFF_SLOWMS, --sejuani r slow
            ["SettSlow"] = BUFF_SLOWMS, --ok slow, but only if has not below sett buffs
            ["SettE"] = BUFF_STOPPREDICT, --stop predict! target dashing (but pathing.isDashing = false)
            ["settrsuppression"] = BUFF_STOPPREDICT, --stop predict! target dashing (but pathing.isDashing = false)
            ["settrgrabbed"] = BUFF_STOPPREDICT, --stop predict! target dashing (but pathing.isDashing = false)
            ["settewallricochet"] = BUFF_STOPPREDICT, --stop predict! target dashing (but pathing.isDashing = false)
            ["megaadhesivesnare"] = BUFF_STUN, --singed w stun immobile
            ["megaadhesiveslow"] = BUFF_SLOWMS, --singed w slow
            ["Fling"] = BUFF_DASH, --singed e target is dashing -> -1sec bad timers in gos
        },
        Spells =
        {
        },
    },
}

class 'HeroInfo'

function HeroInfo:__init(unit)
	self.isPredictable = true
	self.unit = unit
	self.s = unit.activeSpell
	if self.s and self.s.valid then
		self.t = SD[self.s.name]
		if self.t then
			local a, b, c = self:GetSpellInfo()
			if a == -10 then
				self.isPredictable = false
				return
			end
			if a == -20 then
				self.dashing = true
				if b then
					self.immobileDuration = b
				end
			elseif a == -30 then
				self.blink = true
				self.duration = b
				self.pos = c
			elseif a == -40 then
				self.blink = true
				self.duration = b
				self.pos = c
				self.ifHit = true
			elseif a >= 0 then
				self.immobileDuration = a
				if b then
					if b == 1 then
						self.ifHit = true
					elseif b == 2 then
						self.ifHit = true
						self.targetedStunOnly = true
					elseif b == 3 then
						self.ifHit = true
						self.highHitchance = true
					end
				end
			end
		elseif self.s.target > 0 and (self.s.isAutoAttack or self:IsAttack(self.s.name)) then
        	self.immobileDuration = self.s.castEndTime - Game.Timer()
        	if self.immobileDuration > 10 then
        		self.isPredictable = false
				return
    		end
        	if self.immobileDuration < 0 then
        		self.immobileDuration = 0
    		end
        end
	end
	self.buffs = {}
    local imax = unit.buffCount
    if imax and imax >= 0 and imax < 1000 then
        for i = 0, imax do
            self.b = unit:GetBuff(i)
            if self.b and self.b.count and self.b.count > 0 then
            	self.t = BD[self.b.name]
            	if self.t then
            		local buff = {isStunnable = true, dashing = false}
            		local a, b, c = self:GetBuffInfo()
					if a == -10 then
						if b == nil then
							self.isPredictable = false
							return
						end
						if b == 1 then
							buff.isStunnable = false
						elseif b == 2 then
							buff.magicShield = true
							buff.shieldDuration = c
						end
					end
					if a == -20 then
						buff.dashing = true
						if b then
							buff.immobileDuration = b
						end
					elseif a == -25 then
						buff.dashing = true
						buff.dashDuration = b
						buff.dashPos = c
					elseif a == -100 then
						if b == 1 then
							buff.speedSlow = true
						elseif b == 2 then
							buff.speedFast = true
						end
						buff.speedDuration = c
					elseif a >= 0 then
						self.immobileDuration = a
						if b then
							if b == 1 then
								self.ifHit = true
							elseif b == 3 then
								self.ifHit = true
								self.highHitchance = true
							end
						end
					end
					self.buffs[#self.buffs+1] = buff
        		end
            end
        end
    else
    	self.isPredictable = false
	end
end

function HeroInfo:IsDashing()
    if self.dashing then return true end
    local buffs = self.buffs
    for i = 1, #buffs do
        local buff = buffs[i]
        if buff.dashing and not buff.dashDuration then
            return true
        end
    end
    return false
end

function HeroInfo:GetCustomDash()
    local buffs = self.buffs
    for i = 1, #buffs do
        local buff = buffs[i]
        if buff.dashing and buff.dashDuration then
            return buff
        end
    end
    return nil
end

function HeroInfo:IsAttack(name)
    if IsAttackSpell[name] then
        return true
    end
    if IsNotAttack[name] then
        return false
    end
    return name:lower():find('attack')
end

function HeroInfo:GetDistanceSqr(p1,p2)
    local dx = p2.x - p1.x
    local dy = (p2.z or p2.y) - (p1.z or p1.y)
	return dx * dx + dy * dy--math.sqrt(dx * dx + dy * dy)
end

function HeroInfo:GetSpellInfo()
	-- 0+ -> immobile duration
	-- 0+; 1 -> immobile duration; if can hit before duration [[[ELSE]]] if not STOP PREDICT (target teleporting/blinking) or blink prediction
	-- 0+; 2 -> immobile duration; if can hit before duration then can use only stun targeted spells like vayne E [[[ELSE]]] STOP PREDICT
	-- 0+; 3 -> immobile duration; if can hit before duration then HIGH HITCHANCE [[[ELSE]]] ELSE STOP PREDICT
	-- -10 -> stop predict (something is wrong or spell like amumu q)
	-- -20; -> dash;
	-- -20; 0+ -> dash; duration is immobile time on endPos if can't hit on the fly
	-- -30; 0+; pos -> blink; only if hit time < duration cast to unit.pos [[[ELSE]]] cast to blink pos with immobile time == cast duration; blink pos
	-- -40; 0+; pos -> blink; only if hit time < duration cast to blink pos [[[ELSE]]] cast to unit.pos with immobile time == cast duration; blink pos
	if self.t == SPELL_STOPPREDICT then
		return -10
	end

	if self.t == SPELL_DASH then
		local p = self.unit.pathing
		if p.isDashing then
			return -20
		end
		return -10
	end

	if self.t == SPELL_DASH_STOP then
		return -10
	end

	if self.t == SPELL_STUN then
		local duration = self.s.castEndTime - Game.Timer()
		if duration < 0 or duration > 10 then
			return -10
		end
		return duration
	end

	if self.t == SPELL_STUN_IFNOTDASH then
		local duration = self.s.castEndTime - Game.Timer()
		if duration < 0 or duration > 10 then
			return -10
		end
		local p = self.unit.pathing
		if p.isDashing then
			return -20, duration
		end
		if p.hasMovePath then
			return -10
		end
		return duration
	end

	if self.t == SPELL_STUN_IFNOTDASH_AATROX then
		local duration = self.s.castEndTime - Game.Timer()
		if duration < 0 or duration > 10 then
			return -10
		end
		local p = self.unit.pathing
		if p.isDashing then
			return -20, duration
		end
		local edata = self.unit:GetSpellData(_E)
		if edata and edata.level > 0 then
			if edata.currentCd == 0 then
				return -10 
			end
			local cd = edata.cd - self.s.currentCd
			if cd < duration and duration - cd > 0.2 then
				return duration - cd
			end
		end
		return duration
	end

	if self.t == SPELL_STUN_03 then
		local duration = self.s.castEndTime + 0.3 - Game.Timer()
		if duration < 0 or duration > 10 then
			return -10
		end
		return duration
	end

	if self.t == SPELL_STUN_ENDTIME then
		local duration = self.s.endTime - Game.Timer()
		if duration < 0 or duration > 10 then
			return -10
		end
		return duration
	end

	if self.t == SPELL_STUN_015 then
		local duration = self.s.castEndTime + 0.15 - Game.Timer()
		if duration < 0 or duration > 10 then
			return -10
		end
		return duration
	end

	if self.t == SPELL_INTERRUPTABLE then
		local duration = self.s.endTime - Game.Timer()
		if duration < 0 or duration > 10 then
			return -10
		end
		return duration
	end

	if self.t == SPELL_INTERRUPTABLEDEF then
		local duration = self.s.endTime - Game.Timer()
		if duration < 0 or duration > 10 then
			return -10
		end
		return duration
	end

	if self.t == SPELL_INTERRUPTABLE_IFHITBEFOREEND then
		local duration = self.s.endTime - Game.Timer()
		if duration < 0 or duration > 10 then
			return -10
		end
		return duration, 1
	end

	if self.t == SPELL_INTERRUPTABLE_IHBE_MINUS15 then
		local duration = self.s.endTime - Game.Timer() - 1.5
		if duration < 0 or duration > 10 then
			return -10
		end
		return duration, 1
	end

	if self.t == SPELL_INTERRUPTABLE_IHBE_MINUS1 then
		local duration = self.s.endTime - Game.Timer() - 1
		if duration < 0 or duration > 10 then
			return -10
		end
		return duration, 1
	end

	if self.t == SPELL_INTERRUPTABLE_SPEED then
		local duration = self.s.endTime - Game.Timer()
		if duration < 0 or duration > 50 then
			return -10
		end
		return duration, 2
	end

	if self.t == SPELL_INTERRUPTABLE_SLOW then
		local duration = self.s.endTime - Game.Timer()
		if duration < 0 or duration > 50 then
			return -10
		end
		return duration, 3
	end

	if self.t == SPELL_INTERRUPTABLE_UNKNOWN then
		local duration = self.s.endTime - Game.Timer()
		if duration < 0 or duration > 10 then
			return -10
		end
		return duration, 1
	end

	if self.t == SPELL_BLINK_STOP then
		return -10
	end

	if self.t == SPELL_BLINK then
		local duration = self.s.castEndTime - Game.Timer()
		if duration < 0 or duration > 10 then
			return -10
		end
		local pos = false
		local range = self.s.range
		local startPos = self.s.startPos
		local endPos = self.s.placementPos
		if self:GetDistanceSqr(startPos, endPos) > range * range then
			local spVector = Vector(startPos)
			local epVector = Vector(endPos)
			local direction = (epVector - spVector):Normalized()
			pos = spVector + direction * range
		else
			pos = Vector(endPos)
		end
		return -30, duration, pos
	end

	if self.t == SPELL_BLINK_IFHITBEFOREEND then
		local duration = self.s.castEndTime - Game.Timer()
		if duration < 0 or duration > 10 then
			return -10
		end
		local range = self.s.range
		local startPos = Vector(self.s.startPos)
		local endPos = Vector(self.s.placementPos)
		local direction = (endPos - startPos):Normalized()
		local pos = startPos + direction * range
		if self:GetDistanceSqr(self.unit.pos, pos) > 50 * 50 then
			return -10
		end
		return -40, duration, endPos
	end
end

function HeroInfo:GetBuffInfo()
	-- ***( duration - hit time < 0 )***(duration-hitTime<0)
	-- 0+ -> immobile duration
	-- 0+; 1 -> immobile duration; if can hit before duration [[[ELSE]]] if not STOP PREDICT (target teleporting/blinking) or blink prediction
	-- 0+; 3 -> immobile duration; if can hit before duration then HIGH HITCHANCE [[[ELSE]]] ELSE STOP PREDICT
	-- -10 -> stop predict (something is wrong or spell like amumu q)
	-- -10, 1 -> stop predict not damage stun spells like elise e
	-- -10, 2, 0+ -> if (duration-hitTime<0) castSpell [[[ELSE]]] stop predict stun spells spells like elise e, vayne e
	-- -20; -> dash;
	-- -20; 0+ -> dash; duration is immobile time on endPos if can't hit on the fly
	-- -25; 0+; pos; -> dash2; duration; -> isDashing == false, calc direction (pos-unit.pos)
	-- -100; 1, 0+; -> ms; slow; duration; duration >= slowHitTime cast normal [[[ELSE]]] source:extend(slowPosOnPathByDuration, projSpeed * duration)
	-- -100; 2, 0+; -> ms; fast; duration; duration >= fastHitTime cast normal [[[ELSE]]] source:extend(fastPosOnPathByDuration, projSpeed * duration)
	
	if self.t == BUFF_STOPPREDICT then

		return -10
	end

	if self.t == BUFF_STOPSTUNSPELLS then

		return -10, 1
	end

	if self.t == BUFF_STOPSTUNSPELLS_MSHIELD then
		local duration = self.b.duration
		if duration < 0 or duration > 50 then
			return -10
		end
		return -10, 2, duration
	end

	if self.t == BUFF_SLOWMS then
		local duration = self.b.duration
		if duration < 0 or duration > 50 then
			return -10
		end
		return -100, 1, duration
	end

	if self.t == BUFF_FASTMS then
		local duration = self.b.duration
		if duration < 0 or duration > 50 then
			return -10
		end
		return -100, 2, duration
	end

	if self.t == BUFF_FASTMS_CUSTOM then
		return 0
	end

	if self.t == BUFF_DASH then
		return -20
	end

	if self.t == BUFF_DASH_AHRI then
		local duration = self.b.duration
		if duration < 0 or duration > 50 then
			return -10
		end
		if self.unit.ms > 300 then
			return -10
		end
		local p = self.unit.pathing
		if not p.hasMovePath then
			return -10
		end
		local ahri = false
		local unitTeam = self.unit.team
		local heroCount = Game.HeroCount()
		for i = 1, heroCount do
	        local hero = Game.Hero(i)
	        if hero and hero.valid and hero.visible and hero.isAlly and hero.team ~= unitTeam and hero.charName == 'Ahri' then
	        	ahri = hero
	        	break
        	end
		end
		if not ahri then
			return -10
		end
		return -25, duration, ahri.pos
	end

	if self.t == BUFF_DASH_FIDDLE then
		local duration = self.b.duration
		if duration < 0 or duration > 50 then
			return -10
		end
		if self.unit.ms > 300 then
			return -10
		end
		local p = self.unit.pathing
		if not p.hasMovePath then
			return -10
		end
		local fiddle = false
		local unitTeam = self.unit.team
		local heroCount = Game.HeroCount()
		for i = 1, heroCount do
	        local hero = Game.Hero(i)
	        if hero and hero.valid and hero.visible and hero.isAlly and hero.team ~= unitTeam and hero.charName:lower() == 'fiddlesticks' then
	        	fiddle = hero
	        	break
        	end
		end
		if not fiddle then
			return -10
		end
		local unitPos = self.unit.pos
		local fiddlePos = fiddle.pos
		return -25, duration, unitPos + (unitPos - fiddlePos):Normalized() * 1000
	end

	if self.t == BUFF_DASH_RAMMUS then
		local duration = self.b.duration
		if duration < 0 or duration > 50 then
			return -10
		end
		local rammus = false
		local unitTeam = self.unit.team
		local heroCount = Game.HeroCount()
		for i = 1, heroCount do
	        local hero = Game.Hero(i)
	        if hero and hero.valid and hero.visible and hero.isAlly and hero.team ~= unitTeam and hero.charName == 'Rammus' then
	        	rammus = hero
	        	break
        	end
		end
		if not rammus then
			return -10
		end
		local unitPos = self.unit.pos
		local fiddlePos = fiddle.pos
		local p = self.unit.pathing
		if not p.hasMovePath then
			if unitPos:DistanceTo(fiddlePos) <= self.unit.range + self.unit.boundingRadius + fiddle.boundingRadius then
				return duration
			end
			return -10
		end
		return -25, duration, rammus.pos
	end

	if self.t == BUFF_DASH_EVELYNN then
		local duration = self.b.duration
		if duration < 0 or duration > 50 then
			return -10
		end
		if self.unit.ms > 300 then
			return -10
		end
		local p = self.unit.pathing
		if not p.hasMovePath then
			return -10
		end
		local evelynn = false
		local unitTeam = self.unit.team
		local heroCount = Game.HeroCount()
		for i = 1, heroCount do
	        local hero = Game.Hero(i)
	        if hero and hero.valid and hero.visible and hero.isAlly and hero.team ~= unitTeam and hero.charName == 'Evelynn' then
	        	evelynn = hero
	        	break
        	end
		end
		if not evelynn then
			return -10
		end
		return -25, duration, evelynn.pos
	end

	if self.t == BUFF_DASH_SHEN then
		local duration = self.b.duration
		if duration < 0 or duration > 50 then
			return -10
		end
		local shen = false
		local unitTeam = self.unit.team
		local heroCount = Game.HeroCount()
		for i = 1, heroCount do
	        local hero = Game.Hero(i)
	        if hero and hero.valid and hero.visible and hero.isAlly and hero.team ~= unitTeam and hero.charName == 'Shen' then
	        	shen = hero
	        	break
        	end
		end
		if not shen then
			return -10
		end
		local unitPos = self.unit.pos
		local shenPos = shen.pos
		local p = self.unit.pathing
		if not p.hasMovePath then
			if unitPos:DistanceTo(shenPos) <= self.unit.range + self.unit.boundingRadius + shen.boundingRadius then
				return duration
			end
			return -10
		end
		if unitPos:DistanceTo(shenPos) > 800 then
			return -10
		end
		return -25, duration, shen.pos
	end

	if self.t == BUFF_DASH_GALIO then
		local duration = self.b.duration
		if duration < 0 or duration > 50 then
			return -10
		end
		if self.unit.ms > 300 then
			return -10
		end
		local p = self.unit.pathing
		if not p.hasMovePath then
			return -10
		end
		local galio = false
		local unitTeam = self.unit.team
		local heroCount = Game.HeroCount()
		for i = 1, heroCount do
	        local hero = Game.Hero(i)
	        if hero and hero.valid and hero.visible and hero.isAlly and hero.team ~= unitTeam and hero.charName == 'Galio' then
	        	galio = hero
	        	break
        	end
		end
		if not galio then
			return -10
		end
		return -25, duration, galio.pos
	end

	if self.t == BUFF_STUN then
		local duration = self.b.duration
		if duration < 0 or duration > 50 then
			return -10
		end
		return duration
	end

	if self.t == BUFF_STUN_IFNOTDASH then
		local duration = self.b.duration
		if duration < 0 or duration > 10 then
			return -10
		end
		local p = self.unit.pathing
		if p.isDashing then
			return -20, duration
		end
		if p.hasMovePath then
			return -10
		end
		return duration
	end

	if self.t == BUFF_STUN_BELOW05 then
		local duration = self.b.duration
		if duration < 0 or duration >= 0.5 then
			return -10
		end
		return duration
	end

	if self.t == BUFF_STUN_ABOVE05 then
		local duration = self.b.duration
		if duration < 0 or duration > 50 then
			return -10
		end
		if duration > 0.5 then
			return duration - 0.5
		end
		return -100, 1, duration
	end

	if self.t == BUFF_INTERRUPTABLE_SLOW then
		local duration = self.b.duration
		if duration < 0 or duration > 50 then
			return -10
		end
		return duration, 3
	end

	if self.t == BUFF_INTERRUPTABLE_IFHITBEFOREEND then
		local duration = self.b.duration
		if duration < 0 or duration > 10 then
			return -10
		end
		return duration, 1
	end

	if self.t == BUFF_INTERRUPTABLE_STUN then
		return -10--zac E wait for dash
	end
end

if DEBUG_ENABLED then
	local function GetHeroes()
	    local result = {}
	    local count = Game.HeroCount()
	    if count and count > 0 and count < 1000 then
	        local ids = {}
	        for i = 1, count do
	            local o = Game.Hero(i)
	            if o then--and o.visible then-- and not o.dead then
	                local id = o.networkID
	                if id and ids[id] == nil then
	                    ids[id] = true
	                    table.insert(result, o)
	                end
	            end
	        end
	    end
	    return result
	end

	local function GetDistance2D(p1, p2)
	    return math.sqrt(math.pow((p2.x - p1.x), 2) + math.pow((p2.y - p1.y), 2))
	end

	local _OnWaypoint = {}
	function OnWaypoint(unit)
	    if _OnWaypoint[unit.networkID] == nil then _OnWaypoint[unit.networkID] = {pos = unit.posTo, speed = unit.ms, time = Game.Timer()} end
	    if _OnWaypoint[unit.networkID].pos ~= unit.posTo then
	        --print("OnWayPoint:"..unit.charName.." | "..math.floor(Game.Timer()))
	        _OnWaypoint[unit.networkID] = {startPos = unit.pos, pos = unit.posTo, speed = unit.ms, time = Game.Timer()}
	        DelayAction(function()
	            local time = (Game.Timer() - _OnWaypoint[unit.networkID].time)
	            local speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos, unit.pos) / (Game.Timer() - _OnWaypoint[unit.networkID].time)
	            if speed > 1250 and time > 0 and unit.posTo == _OnWaypoint[unit.networkID].pos and GetDistance(unit.pos, _OnWaypoint[unit.networkID].pos) > 200 then
	                _OnWaypoint[unit.networkID].speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos, unit.pos) / (Game.Timer() - _OnWaypoint[unit.networkID].time)
	                -- print("OnDash: "..unit.charName)
	            end
	        end, 0.05)
	    end
	    return _OnWaypoint[unit.networkID]
	end

	--Callback.Add("Tick", function()OnWaypoint(myHero)end)



	local CurrentChampionData =
	{
	}

	local ErrorBuffs =
	{
	    "wardplacementcounter",
	    "ASSETS/Perks/",
	}
	local ErrorBuffsConst =
	{
	    "PracticeTool_ControlBuff",
	    "GlobalGamePhaseAnalyzer",
	    "Banners_Manager",
	}
	local function IsErrorBuff(name)
	    for i = 1, #ErrorBuffs do
	        if name:find(ErrorBuffs[i]) then
	            return true
	        end
	    end
	    for i = 1, #ErrorBuffsConst do
	        if name == ErrorBuffsConst[i] then
	            return true
	        end
	    end
	    return false
	end

	local function GetData(o)
	    local diff = false
	    local heroName = o.charName
	    if CurrentChampionData[heroName] == nil then
	        CurrentChampionData[heroName] = {}
	        CurrentChampionData[heroName].Buffs = {}
	        CurrentChampionData[heroName].Spells = {}
	    end
	    local buffCount = o.buffCount
	    if buffCount and buffCount >= 0 and buffCount < 1000 then
	        for i = 0, buffCount do
	            local buff = o:GetBuff(i)
	            if buff and buff.count > 0 and not IsErrorBuff(buff.name) and CurrentChampionData[heroName].Buffs[buff.name] == nil then
	                diff = true
	                CurrentChampionData[heroName].Buffs[buff.name] = buff.type
	            end
	        end
	    end
	    local spell = o.activeSpell
	    if spell and spell.valid and CurrentChampionData[heroName].Spells[spell.name] == nil then
	        CurrentChampionData[heroName].Spells[spell.name] = true
	        diff = true
	    end
	    return diff
	end

	local function SaveData(o)
	    if GetData(o) then
	        local text = "local CurrentChampionData =\n{\n"
	        for cName, cData in pairs(CurrentChampionData) do
	            text = text .. '\t["' .. cName .. '"] =\n'
	            text = text .. '\t{\n'
	            text = text .. '\t\tBuffs =\n'
	            text = text .. '\t\t{\n'
	            for bName, bBool in pairs(cData.Buffs) do
	                text = text .. '\t\t\t["' .. bName .. '"] = true,\n'
	            end
	            text = text .. '\t\t},\n'
	            text = text .. '\t\tSpells =\n'
	            text = text .. '\t\t{\n'
	            for sName, sBool in pairs(cData.Spells) do
	                text = text .. '\t\t\t["' .. sName .. '"] = true,\n'
	            end
	            text = text .. '\t\t},\n'
	            text = text .. '\t},\n'
	        end
	        text = text .. '}\n'
	        local f = io.open(SCRIPT_PATH .. "_gamedata.txt", "w")
	        f:write(text)
	        f:close()
	    end
	end

	local function DrawData(o, x, y)
	    local fixedX = x
	    local fixedY = y
	    local count = o.buffCount
	    local charName = o.charName
	    charName = string.sub(charName, 1, -#charName + 2)
	    Draw.Text(charName .. " INFO:", 40, fixedX, fixedY)
	    fixedY = fixedY + 40
	    Draw.Text('ms:' .. tostring(o.ms), 20, fixedX, fixedY)
	    fixedY = fixedY + 20
	    Draw.Text(charName .. " BUFFS:", 40, fixedX, fixedY)
	    fixedY = fixedY + 40
	    if count and count >= 0 and count < 1000 then
	        local buffs = {}
	        for i = 0, count do
	            local buff = o:GetBuff(i)
	            if buff and buff.count > 0 and not IsErrorBuff(buff.name) then
	                table.insert(buffs, buff)
	            end
	        end
	        table.sort(buffs, function(a, b) return a.name:lower() < b.name:lower() end)
	        local lines = 0
	        local text = ''
	        for i = 1, #buffs do
	            lines = lines + 1
	            text = text .. buffs[i].name .. ' ' .. buffs[i].type .. ' ' .. buffs[i].duration .. '\n'
	        end
	        Draw.Text(text, 20, fixedX, fixedY)
	        fixedY = fixedY + 40 + 20 * lines
	    end
	    local path = o.pathing
	    if path then
	        Draw.Text(charName .. " PATHING:", 40, fixedX, fixedY)
	        fixedY = fixedY + 40
	        local lines = 0
	        local text = ''
	        local pathInfo = {}
	        for k, v in pairs(path) do
	            lines = lines + 1
	            table.insert(pathInfo, k)
	        end
	        table.sort(pathInfo, function(a, b) return a:lower() < b:lower() end)
	        for i = 1, #pathInfo do
	            text = text .. pathInfo[i] .. ': ' .. tostring(path[pathInfo[i]]) .. '\n'
	        end
	        Draw.Text(text, 20, fixedX, fixedY)
	        fixedY = fixedY + 40 + 20 * lines
	        --Draw.Text(text, 20, x, fixedY)
	        --Draw.Text("dashing", 15)
	    end
	    local spell = o.activeSpell
	    if spell and spell.valid then
	        local text = spell.name .. ' ' .. (spell.endTime - Game.Timer()) .. '\n' .. (spell.castEndTime - Game.Timer())
	        Draw.Text(charName .. " SPELL:", 40, fixedX, fixedY)
	        --print(spell.name)
	        fixedY = fixedY + 40
	        Draw.Text(text, 20, fixedX, fixedY)
	        fixedY = fixedY + 20
	        if spell.placementPos then
	            local range = 650
	            Draw.Line(Vector(spell.startPos):To2D(), Vector(spell.startPos):Extended(Vector(spell.placementPos), range):To2D())
	        end
	    end
	end

	local function DrawPathing(o)
	    local path = o.pathing
	    if path then
	        local istart = path.pathIndex
	        local iend = path.pathCount
	        if istart and iend and istart >= 0 and iend <= 100 then
	            for i = 0, iend do
	                local pos = o:GetPath(i)
	                Draw.Circle(pos, 50, 1, Draw.Color(255, 255, 255, 255))
	                if i > 0 then
	                    Draw.Line(o:GetPath(i - 1):To2D(), pos:To2D())
	                end
	            end
	        end
	    end
	end

	Callback.Add("Draw", function()
	    local x, y = 125, 110
	    for _, o in pairs(GetHeroes()) do
	        if o then--and o.valid then--and o.visible then-- and not o.dead then
	            SaveData(o)
	            DrawData(o, x, y)
	            DrawPathing(o)
	            local data = HeroInfo(o)
	            if data.isPredictable then
					if #data.buffs > 0 then
						local buff = data.buffs[1]
						if buff.dashing and buff.dashDuration then
							print(buff.dashDuration)
						end
					end
					if data.immobileDuration then
						print(data.immobileDuration)
					end
            	end
	            x = x + 350
	        end
	    end
	end)
end

local heroRefreshTimer = 0
local heroDone = {}
Callback.Add('Load', function()
	for k,v in pairs(ChampionData['PracticeTool_TargetDummy'].Buffs) do
		BD[k] = v
	end
	heroDone['PracticeTool_TargetDummy'] = true
	Callback.Add('Tick', function()
		if os.clock() < heroRefreshTimer + 3 then
			return
		end
		heroRefreshTimer = os.clock()
		local count = Game.HeroCount()
		for i = 1, count do
			local hero = Game.Hero(i)
			if hero and hero.valid then
				local name = hero.charName
				if not heroDone[name] and ChampionData[name] then
					for k,v in pairs(ChampionData[name].Buffs) do
						BD[k] = v
					end
					for k,v in pairs(ChampionData[name].Spells) do
						SD[k] = v
					end
					heroDone[name] = true
				end
			end
		end
	end)
end)
return {
	
}

--LLOMVPF
