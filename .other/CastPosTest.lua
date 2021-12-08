local function GetDistance(p1, p2)
    local dx = p1.x - p2.x
    local dy = p1.z - p2.z
    return math.sqrt(dx * dx + dy * dy)
end

local TestPos = {

	PosChanged = false,

	OnValueChange = function(self, value, mode)
		if value then
            self.PosChanged = true
			print("key pressed " .. os.clock())
            if mode == "normal" then
                Control.SetCursorPos(myHero.pos)
            elseif mode == "zero" then
                Control.SetCursorPos(Vector(myHero.pos.x, 0, myHero.pos.z))
            end
            self.Mode = mode
            self.PrevPos = mousePos
		end
	end,

    OnPosChanged = function(self)
        self.PosChanged = false
        print("pos changed " .. os.clock())
        print(self.Mode .. ' ' .. GetDistance(mousePos, myHero.pos))
    end,

	OnUpdate = function(self)
        if self.PosChanged then
            self.PostPos = mousePos
            if self:HasChangedPos() then
                self:OnPosChanged()
            end
        end
	end,

    HasChangedPos = function(self)
        return GetDistance(self.PrevPos, self.PostPos) > 10
    end,
}

Callback.Add("Load", function()
	local Main = MenuElement({ id = "CastPosTest", name = "CastPos Test", type = MENU })

	Main:MenuElement({
		id = "CastPosNormal",
		name = "CastPos Normal",
		key = string.byte("N"),
		callback = function(value)
			TestPos:OnValueChange(value, "normal")
		end,
	})

	Main:MenuElement({
		id = "CastPosZero",
		name = "CastPos Zero",
		key = string.byte("Z"),
		callback = function(value)
			TestPos:OnValueChange(value, "zero")
		end,
	})

	Callback.Add("Tick", function()
        print(myHero.pos.y)
		TestPos:OnUpdate()
	end)
end)
