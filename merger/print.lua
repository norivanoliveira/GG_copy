local x = 0
local y = 0
local i = 0
local toprint = {}
local graphics = love.graphics

local function getColor(c)
	if c then
		return { c[1] / 255, c[2] / 255, c[3] / 255, c[4] / 255 }
	end
	return { 1, 1, 1, 1 }
end

function love.draw()
	local r, g, b, a = graphics.getColor()
	for j = 1, i do
		local item = toprint[j]
		graphics.setColor(item[3])
		graphics.printf(item[2], x, item[1], 600, "left")
	end
	graphics.setColor(r, g, b, a)
end

return {
	add = function(text, color)
		text = tostring(text)
		i = i + 1
		toprint[i] = { y, text, getColor(color) }
		y = y + 15
		y = y + (15 * text:CountCharacter("\n"))
	end,
	cls = function()
		y = 0
		i = 1
		toprint = {}
	end,
}
