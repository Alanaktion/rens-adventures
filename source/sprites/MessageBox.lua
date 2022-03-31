MessageBox = {}
class('MessageBox').extends(NobleSprite)

local screenWidth <const> = playdate.display.getWidth()
local nameFontFamily <const> = {
	[Graphics.font.kVariantNormal] = font12
}

function MessageBox:init()
	MessageBox.super.init(self)
	self:setCenter(0, 1)
	self:setZIndex(90)
	self:setSize(screenWidth, 83)
end

function MessageBox:setDark(dark)
	self.dark = dark
	self:markDirty()
end

function MessageBox:setName(name)
	self.name = name
	self:markDirty()
end

function MessageBox:draw(x, y, width, height)
	Graphics.setLineWidth(1)
	Graphics.setStrokeLocation(Graphics.kStrokeInside)

	Graphics.setColor(Graphics.kColorBlack)
	Graphics.fillRect(0, 43, screenWidth, 40)

	self:drawRoundedBox(0, 16, screenWidth, 67)

	if self.name then
		local width, _ = Graphics.getTextSize(self.name, nameFontFamily)
		self:drawRoundedBox(8, 1, width + 12, 20)
	end
end

function MessageBox:drawRoundedBox(x, y, w, h)
	local rad = 4
	if self.dark then
		Graphics.setColor(Graphics.kColorBlack)
	else
		Graphics.setColor(Graphics.kColorWhite)
	end
	Graphics.fillRoundRect(x, y, w, h, rad)
	if self.dark then
		Graphics.setColor(Graphics.kColorWhite)
	else
		Graphics.setColor(Graphics.kColorBlack)
	end
	Graphics.drawRoundRect(x, y, w, h, rad)
	if self.dark then
		Graphics.setColor(Graphics.kColorBlack)
		Graphics.drawRoundRect(x - 1, y - 1, w + 2, h + 2, rad + 1)
	end
end
