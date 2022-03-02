local screenWidth = playdate.display.getWidth()
local gfx = playdate.graphics

class('Text').extends(gfx.sprite)

function Text:init()
	Text.super.init(self)
	self.invert = false
	self:setFontSize(14)
	self:setCenter(0,0)
	self:setText("")
	self:moveTo(0, 0)
	self:setZIndex(100)
end

function Text:setFontSize(size)
	if size == 12 then
		self.font = gfx.font.new('fonts/Pedallica/font-pedallica')
		self.font:setTracking(1)
	elseif size == 16 then
		self.font = gfx.font.new('fonts/Pedallica/font-pedallica-fun-16')
	else
		self.font = gfx.font.new('fonts/Pedallica/font-pedallica-fun-14')
	end
	print(self.font)
end

function Text:setInvert(invert)
	self.invert = invert
end

-- TODO: add size constraint with line wrapping

function Text:setText(newText)
	self.text = newText

	gfx.setFont(self.font)
	local width, height = gfx.getTextSize(self.text)
	self:setSize(width, height)
	self:markDirty()
end

-- draw callback from the sprite library
function Text:draw(x, y, width, height)
	gfx.setFont(self.font)
	if self.invert then
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	end
	gfx.drawText(self.text, 0, 0)
	if self.invert then
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	end
end
