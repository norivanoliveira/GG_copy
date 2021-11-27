local __version__ = 1.02
local __name__ = 'GGCore'

if _G.GGCore then return end

_G.GGUpdate = {
    Callbacks = {},
    DownloadFile = function(self, url, path)
        DownloadFileAsync(url, path, function() end)
    end,
    Trim = function(self, s)
        local from = s:match"^%s*()"
        return from > #s and "" or s:match(".*%S", from)
    end,
    ReadFile = function(self, path)
        local result = {}
        local file = io.open(path, "r")
        if file then
            for line in file:lines() do
                local str = self:Trim(line)
                if #str > 0 then
                    table.insert(result, str)
                end
            end
            file:close()
        end
        return result
    end,
    New = function(self, args)
        local updater = {
            Step = 1,
            Version = type(args.version) == 'number' and args.version or tonumber(args.version),
            VersionUrl = args.versionUrl,
            VersionPath = args.versionPath,
            ScriptUrl = args.scriptUrl,
            ScriptPath = args.scriptPath,
            ScriptName = args.scriptName,
            VersionType = args.versionType,
            VersionTimer = GetTickCount(),
            DownloadVersion = function(self)
                if not FileExist(self.ScriptPath) then
                    self.Step = 4
                    GGUpdate:DownloadFile(self.ScriptUrl, self.ScriptPath)
                    self.ScriptTimer = GetTickCount()
                    return
                end
                GGUpdate:DownloadFile(self.VersionUrl, self.VersionPath)
            end,
            CanUpdate = function(self, str)
                if self.VersionType == 2 then
                    self.NewVersion = str
                    if tonumber(str) > self.Version then
                        return true
                    end
                    return false
                end
                local t = assert(load(str))()
                if t and type(t) == 'table' then
                    local version = t[self.ScriptName]
                    if version then
                        --print('version valid ' .. tostring(version))
                        if version > self.Version then
                            self.NewVersion = tostring(version)--str or response[1][self.ScriptName]
                            --print('need update ' .. tostring(version))
                            return true
                        end
                    end
                end
                return false
            end,
            OnTick = function(self)
                if self.Step == 0 then
                    return
                end
                if self.Step == 1 then
                    if GetTickCount() > self.VersionTimer + 1 then
                        local response = GGUpdate:ReadFile(self.VersionPath)
                        --print(self.ScriptUrl)
                        --print(tonumber(response[1]))
                        if #response > 0 and self:CanUpdate(response[1]) then
                            self.Step = 2
                            GGUpdate:DownloadFile(self.ScriptUrl, self.ScriptPath)
                            self.ScriptTimer = GetTickCount()
                        else
                            self.Step = 3
                        end
                    end
                end
                if self.Step == 2 then
                    if GetTickCount() > self.ScriptTimer + 1 then
                        self.Step = 0
                        print(self.ScriptName .. ' - new update found! [' .. tostring(self.Version) .. ' -> ' .. self.NewVersion .. '] Please 2xf6!')
                    end
                    return
                end
                if self.Step == 3 then
                    self.Step = 0
                    return
                end
                if self.Step == 4 then
                    if GetTickCount() > self.ScriptTimer + 1 then
                        self.Step = 0
                        print(self.ScriptName .. ' - downloaded! Please 2xf6!')
                    end
                end
            end,
        }
        if updater.VersionType == nil then
            updater.VersionType = 2
        end
        if updater.VersionType > 0 then
            updater:DownloadVersion()
            --print('downloading version ' .. updater.ScriptName)
        end
        table.insert(self.Callbacks, updater)
    end
}

GGUpdate:New({
    version = __version__,
    scriptName = __name__,
    scriptPath = COMMON_PATH .. __name__ .. ".lua",
    scriptUrl = "https://raw.githubusercontent.com/gamsteron/GG/master/" .. __name__ .. ".lua",
    versionPath = COMMON_PATH .. "GGVersion.lua",
    versionUrl = "https://raw.githubusercontent.com/gamsteron/GG/master/GGVersion.lua",
    versionType = 1,
})

do
    local _GGU_Updated = false
    local _GGU_TickID = false
    local _GGU_StartTime = 0
    _GGU_TickID = Callback.Add("Tick", function()
        if _GGU_StartTime == 0 then _GGU_StartTime = os.clock() + 1 return end
        if os.clock() < _GGU_StartTime then return end
        if not _GGU_Updated then
            local ok = true
            for i = 1, #GGUpdate.Callbacks do
                local updater = GGUpdate.Callbacks[i]
                updater:OnTick()
                --print(updater.ScriptName .. ' ' .. tostring(updater.Step))
                if updater.Step > 0 then
                    ok = false
                end
            end
            if ok then
                _GGU_Updated = true
                -- if i use callbnack.dell whole script works worse, idk why. for example laneclear stops working
                --Callback.Del('Tick', _GGU_TickID)
            end
        end
    end)
end

_G.GGCore = true
_G.DownloadingGGCore = true
if not FileExist(COMMON_PATH .. "GGData.lua") then
    if not _G.DownloadingGGData then
        DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GG/master/GGData.lua", COMMON_PATH .. "GGData.lua", function() end)
        print('GGData - downloaded! Please 2xf6!')
        _G.DownloadingGGData = true
    end
    return
end
require('GGData')

if not FileExist(COMMON_PATH .. "GGPrediction.lua") then
    if not _G.DownloadingGGPrediction then
        DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GG/master/GGPrediction.lua", COMMON_PATH .. "GGPrediction.lua", function() end)
        print('GGPrediction - downloaded! Please 2xf6!')
        _G.DownloadingGGPrediction = true
    end
    return
end
require('GGPrediction')

local PermaShow

local GameResolution = Game.Resolution()

local DrawText = Draw.Text
local DrawRect = Draw.Rect

local AminoFont = Draw.Font('Arimo-Regular.ttf', 'Arimo')
local ColorWhite = Draw.Color(255, 255, 255, 255)
local ColorDarkGreen = Draw.Color(255, 0, 100, 0)
local ColorDarkRed = Draw.Color(255, 139, 0, 0)
local ColorDarkBlue = Draw.Color(255, 0, 0, 139)
local ColorTransparentBlack = Draw.Color(150, 0, 0, 0)
local ColorOrange = Draw.Color(255, 252, 186, 3)
local ColorBlue = Draw.Color(255, 0, 255, 0)
PermaShow = {
    X = GameResolution.x * 0.592435991,--0.582457,
    Y = GameResolution.y * 0.608780119,--0.057884,
    MoveX = 0,
    MoveY = 0,
    Moving = false,
    Width = 0,
    Height = 0,
    Count = 0,
    Groups = {},
    ValidGroups = {},
    MaxTitleWidth = 0,
    MaxLabelWidth = 0,
    MaxValueWidth = 0,
    Margin = 10,
    ItemSpaceX = 75,
    ItemSpaceY = 2,
    GroupSpaceY = 12,
    PrintTitle = true,
    DefaultValueWidth = Draw.FontRect('Space', 13, AminoFont).x + 22,
    InfoPath = COMMON_PATH .. 'GGPermaShowInfo.lua',

    UpdateGroupPosition = function(self)
        self.Height = self.Margin * 0.5
        self.Width = self.Width + self.ItemSpaceX + self.Margin * 2
        for i = 1, #self.ValidGroups do
            local group = self.ValidGroups[i]
            if PermaShow.PrintTitle then group.Title:UpdatePos() end
            for j = 1, #group.Items do
                local item = group.Items[j]
                item:UpdatePos(self.Margin)
                if j < #group.Items then
                    self.Height = self.Height + self.ItemSpaceY
                end
            end
            if i < #self.ValidGroups then
                self.Height = self.Height + self.GroupSpaceY
            end
        end
        self.Height = self.Height + self.Margin * 0.5
        self:OnHeightChange()
    end,

    OnWidthChange = function(self)
        local diffX = (self.X + self.Width) - GameResolution.x
        if diffX > 0 then
            self.X = self.X - diffX
            self:Write()
        end
    end,

    OnHeightChange = function(self)
        local diffY = (self.Y + self.Height) - GameResolution.y
        if diffY > 0 then
            self.Y = self.Y - diffY
            self:Write()
        end
    end,

    OnUpdate = function(self)
        self.MaxValueWidth = self.DefaultValueWidth
        for i = 1, #self.ValidGroups do
            local group = self.ValidGroups[i]
            local items = group.Items
            for j = 1, #items do
                local item = items[j]
                if item.Value.Width > self.MaxValueWidth then
                    self.MaxValueWidth = item.Value.Width
                end
            end
        end
        local width = self.MaxLabelWidth + self.MaxValueWidth
        if PermaShow.PrintTitle and self.MaxTitleWidth > width then
            width = self.MaxTitleWidth
        end
        if width ~= self.Width then
            self.Width = width
            self:OnWidthChange()
        end
        self:UpdateGroupPosition()
    end,

    OnItemChange = function(self)
        for i = #self.ValidGroups, 1, -1 do
            table.remove(self.ValidGroups, i)
        end
        self.MaxTitleWidth = 0
        self.MaxLabelWidth = 0
        self.MaxValueWidth = self.DefaultValueWidth
        for i = 1, #self.Groups do
            local group = self.Groups[i]
            local items = group.Items
            if #items > 0 then
                table.insert(self.ValidGroups, group)
                local title = group.Title
                self.Height = self.Height + title.Height
                if title.Width > self.MaxTitleWidth then
                    self.MaxTitleWidth = title.Width
                end
                for j = 1, #items do
                    local item = items[j]
                    if item.Label.Width > self.MaxLabelWidth then
                        self.MaxLabelWidth = item.Label.Width
                    end
                    if item.Value.Width > self.MaxValueWidth then
                        self.MaxValueWidth = item.Value.Width
                    end
                end
            end
        end
        local width = self.MaxLabelWidth + self.MaxValueWidth
        if PermaShow.PrintTitle and self.MaxTitleWidth > width then
            width = self.MaxTitleWidth
        end
        if width ~= self.Width then
            self.Width = width
            self:OnWidthChange()
        end
        self:UpdateGroupPosition()
    end,

    WndMsg = function(self, msg, wParam)
        if self.Count < 1 then return end
        if msg == 513 and wParam == 0 then
            local x1, y1, x2, y2 = cursorPos.x, cursorPos.y, self.X, self.Y
            if x1 >= x2 and x1 <= x2 + self.Width then
                if y1 >= y2 and y1 <= y2 + self.Height then
                    self.MoveX = x2 - x1
                    self.MoveY = y2 - y1
                    self.Moving = true
                    --print('started')
                end
            end
        end
        if msg == 514 and wParam == 1 and self.Moving then
            self.Moving = false
            self:Write()
            --print('stopped')
        end
    end,

    Draw = function(self)
        if self.Count < 1 then return end
        if self.Moving then
            local cpos = cursorPos
            self.X = cpos.x + self.MoveX
            self.Y = cpos.y + self.MoveY
        end
        DrawRect(self.X, self.Y, self.Width, self.Height, ColorTransparentBlack)
        for i = 1, #self.ValidGroups do
            self.ValidGroups[i]:Draw()
        end
    end,

    Read = function(self)
        local f = io.open(self.InfoPath, 'r')
        if f then
            local pos = assert(load(f:read('*all')))()
            self.X, self.Y = pos[1], pos[2]
            --print(self.X/GameResolution.x)
            --print(self.Y/GameResolution.y)
            f:close()
        end

    end,

    Write = function(self)
        local f = io.open(self.InfoPath, 'w')
        if f then
            f:write('return{' .. self.X .. ',' .. self.Y .. '}')
            f:close()
        end
    end,

    Group = function(self, id, name)return{
        Id = id,
        Title = self:GroupTitle(name):Init(),
        Items = {},
        Draw = function(self)
            if PermaShow.PrintTitle then self.Title:Draw() end
            for i = 1, #self.Items do
                self.Items[i]:Draw()
            end
    	end,
    }end,

    GroupTitle = function(self, name)return{
        X = 0,
        Y = 0,
        Name = name,

        UpdatePos = function(self)
            local height = PermaShow.Height
            self.X = (PermaShow.Width - PermaShow.MaxValueWidth - self.Width) / 2
            self.Y = height
            PermaShow.Height = self.Y + self.Height + 3
        end,

        Draw = function(self)
        	DrawText(self.Name, 13, PermaShow.X + self.X, PermaShow.Y + self.Y, ColorWhite, AminoFont)
            local x = PermaShow.X + self.X
            local y = PermaShow.Y + self.Y + self.Height + 1
            Draw.Line(x, y, x + self.Width, y, 1, ColorWhite)
    	end,

        Init = function(self)
            local size = Draw.FontRect(self.Name, 13, AminoFont)
            self.Width = size.x
            self.Height = size.y
            return self
        end,
    }end,

    GroupItem = function(self, name, menuItem)return{
        X = 0,
        Y = 0,
        Label = self:ItemLabel(name),
        Value = self:ItemValue(),
        MenuItem = menuItem,

        UpdatePos = function(self, margin, spaceY)
            local height = PermaShow.Height
            self.X = margin
            self.Y = height
            PermaShow.Height = self.Y + self.Height
            self.Label:UpdatePos(self)
            self.Value:UpdatePos(self, margin)
        end,

        Init = function(self)
            self.Label:Init()
            self.MenuItem.ParmaShowOnValueChange = function()
                self:Update()
            end
            self:Update()
            return self
        end,

        Draw = function(self)
        	self.Label:Draw()
        	self.Value:Draw()
    	end,

        Update = function(self)
            self.Value:Update(self.MenuItem)
            self.Width = self.Label.Width + self.Value.Width
            self.Height = self.Label.Height > self.Value.Height
            and self.Label.Height
            or self.Value.Height
            PermaShow:OnUpdate()
        end,

        Dispose = function(self)
            self.MenuItem.ParmaShowOnValueChange = false
        end,
    }end,

    ItemLabel = function(self, name)return{
        X = 0,
        Y = 0,
        Name = name,

        UpdatePos = function(self, parent)
            self.X = parent.X--(PermaShow.Width - self.Width - PermaShow.MaxValueWidth - 10) / 2--parent.X
            self.Y = parent.Y + (parent.Height - self.Height) / 2
        end,

        Draw = function(self)
        	DrawText(self.Name, 13, PermaShow.X + self.X, PermaShow.Y + self.Y, ColorWhite, AminoFont)
    	end,

        Init = function(self)
            local size = Draw.FontRect(self.Name, 13, AminoFont)
            self.Width = size.x
            self.Height = size.y
        end,
    }end,

    ItemValue = function(self)return{
        X = 0,
        Y = 0,
        RectX = 0,
        RectY = 0,
        RectColor = ColorDarkBlue,

        UpdatePos = function(self, parent, margin)
            local rectMargin = 0--12
            self.RectX = PermaShow.Width - PermaShow.MaxValueWidth - margin - rectMargin
            self.RectY = parent.Y + (parent.Height - self.Height) / 2
            self.RectWidth = PermaShow.Width - self.RectX  - margin
            self.RectHeight = self.Height
            self.X = self.RectX + (self.RectWidth - self.Width) / 2
            self.Y = self.RectY + (self.RectHeight - self.Height) / 2
        end,

        Draw = function(self)
        	DrawRect(PermaShow.X + self.RectX, PermaShow.Y + self.RectY, self.RectWidth, self.RectHeight, self.RectColor)
        	DrawText(self.Name, 13, PermaShow.X + self.X, PermaShow.Y + self.Y, ColorWhite, AminoFont)
    	end,

        Update = function(self, menuItem)
            self.Value = menuItem:GetValue()
            if menuItem.Type ~= 4 then
                self.RectColor = self.Value and ColorDarkGreen or ColorDarkRed
            end

            self.Name = menuItem:ToString()
            local size = Draw.FontRect(self.Name, 13, AminoFont)
            self.Width = size.x
            self.Height = size.y
        end,
    }end,

    AddGroup = function(self, group)
        table.insert(self.Groups, self:Group(group.Id, group.Name))
        return true
    end,

    AddItem = function(self, name, menuItem)
        for i = 1, #self.Groups do
            local group = self.Groups[i]
            if menuItem.PermaShowID == group.Id then
                table.insert(group.Items, self:GroupItem(name, menuItem):Init())
                self.Count = self.Count + 1
                self:OnItemChange()
                return true
            end
        end
        return false
    end,

    RemoveItem = function(self, menuItem)
        for i = 1, #self.Groups do
            local group = self.Groups[i]
            if group.Id == menuItem.PermaShowID then
                for j = 1, #group.Items do
                    if group.Items[j].Value.Id == menuItem.Id then
                        group.Items[j]:Dispose()
                        table.remove(group.Items, j)
                        self.Count = self.Count - 1
                        self:OnItemChange()
                        return true
                    end
                end
            end
        end
        return false
    end,
}
class 'ScriptMenu'

function ScriptMenu:__init(id, name, parent, type, a, b, c, d)
    self.Id = id
    self.Name = name
    if parent == nil then
        self.ElementCount = 0
        self.Settings = {}
        self.Gos = MenuElement({type = _G.MENU, name = name, id = id})
        PermaShow:AddGroup(self)
        return
    end
    parent.ElementCount =
    parent.ElementCount + 1
    self.Type = type
    self.Parent = parent
    if self.Type == 0 then--space
        self.Gos = self.Parent.Gos:MenuElement({id = 'INFO_' .. tostring(parent.ElementCount), name = id or '', type = _G.SPACE})
        return
    end
    assert(self.Parent[self.Id] == nil, "menu: '" .. self.Parent.Id .. "' already contains '" .. self.Id .. "'")
    self.Parent[self.Id] = self
    if self.Type == 1 then--menu
        self.ElementCount = 0
        self.Gos = self.Parent.Gos:MenuElement({id = id, name = name, type = _G.MENU})
    else
        local root = self:GetRoot()
        --print(self.Id .. ' ' .. root.Id)
        assert(root.Settings[self.Id] == nil, "settings: '" .. root.Id .. "' already contains '" .. self.Id .. "'")
        self.Settings = root.Settings
        self.ParmaShowOnValueChange = false
        local args = {
            id = id,
            name = name,
            type = _G.PARAM,
            callback = function(x)
                self.Settings[self.Id] = x
                if self.ParmaShowOnValueChange then
                    self.ParmaShowOnValueChange()
                end
            end,
        }
        --OnOff
        if self.Type == 2 then
            args.value = a
            self.PermaShowID = root.Id
            --Slider
        elseif self.Type == 3 then
            args.value = a
            args.min = b
            args.max = c
            args.step = d
            --List
        elseif self.Type == 4 then
            args.value = a
            args.drop = b
            self.PermaShowID = root.Id
            self.DropList = b
            --Color
        elseif self.Type == 5 then
            args.color = a
        elseif self.Type == 6 then
            assert(_G.type(a) == 'string', 'ScriptMenu:KeyDown(id, name, key): [key] must be string')
            args.value = false
            args.key = string.byte(a)
            self.Key = a:upper()
            self.PermaShowID = root.Id
            args.onKeyChange = function(x)
                self.Key = string.char(x):upper()
                if self.ParmaShowOnValueChange then
                    self.ParmaShowOnValueChange()
                end
            end
        elseif self.Type == 7 then
            assert(_G.type(b) == 'string', 'ScriptMenu:KeyToggle(id, name, value, key: [key] must be string')
            args.value = a
            args.key = string.byte(b)
            args.toggle = true
            self.Key = b:upper()
            self.PermaShowID = root.Id
            args.onKeyChange = function(x)
                self.Key = string.char(x):upper()
                if self.ParmaShowOnValueChange then
                    self.ParmaShowOnValueChange()
                end
            end
        end
        self.Gos = self.Parent.Gos:MenuElement(args)
        if self.Type >= 6 then
            self.Key = string.char(self.Gos.__key):upper()
        end
        --print('prev ' .. tostring(self.Settings[self.Id]))
        self.Settings[self.Id] = self.Gos:Value()
        --print('post ' .. tostring(self.Settings[self.Id]))
    end
end

function ScriptMenu:Space(id, name)
    return ScriptMenu('', name, self, 0)
end

function ScriptMenu:Info(id, name)
    return ScriptMenu(id, name, self, 0)
end

function ScriptMenu:Menu(id, name)
    return ScriptMenu(id, name, self, 1)
end

function ScriptMenu:OnOff(id, name, value)
    return ScriptMenu(id, name, self, 2, value)
end

function ScriptMenu:Slider(id, name, value, min, max, step)
    return ScriptMenu(id, name, self, 3, value, min, max, step)
end

function ScriptMenu:List(id, name, value, drop)
    return ScriptMenu(id, name, self, 4, value, drop)
end

function ScriptMenu:Color(id, name, color)
    return ScriptMenu(id, name, self, 5, color)
end

function ScriptMenu:KeyDown(id, name, key)
    return ScriptMenu(id, name, self, 6, key)
end

function ScriptMenu:KeyToggle(id, name, value, key)
    return ScriptMenu(id, name, self, 7, value, key)
end

function ScriptMenu:Hide(value)
    self.Gos:Hide(value)
end

function ScriptMenu:Remove()
    self.Gos:Remove()
end

function ScriptMenu:GetRoot()
    local root = self.Parent
    while true do
        if root.Parent == nil then
            break
        end
        root = root.Parent
    end
    return root
end

function ScriptMenu:ToString()
    if self.Type == 4 then
        return self.DropList[self.Settings[self.Id]]
    end
    if self.Type >= 6 then
        return self.Key == ' ' and 'Space' or self.Key
    end
    if self.Type == 2 then
        return self.Settings[self.Id] and 'On' or 'Off'
    end
    return tostring(self.Settings[self.Id])
end

function ScriptMenu:GetValue()
    return self.Settings[self.Id]
end

function ScriptMenu:PermaShow(text, value)
    --print(text)
    if self.Type == nil or self.Type < 2 or self.Type == 3 or self.Type == 5 then return end
    if value == nil then value = true end
    if value then
        PermaShow:AddItem(text, self)
    else
        PermaShow:RemoveItem(self)
    end
end
PermaShow:Read()

local function DrawCallback()
	PermaShow:Draw()
end

local function WndMsgCallback(msg, wParam)
	PermaShow:WndMsg(msg, wParam)
end

Callback.Add('Draw', DrawCallback)
Callback.Add('WndMsg', WndMsgCallback)

--LLOMVPF
