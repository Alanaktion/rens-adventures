local screenWidth = playdate.display.getWidth()
local gfx = playdate.graphics

local font12 = gfx.font.new('fonts/Pedallica/font-pedallica')
font12:setTracking(1)
local font14 = gfx.font.new('fonts/Pedallica/font-pedallica-fun-14')
local font16 = gfx.font.new('fonts/Pedallica/font-pedallica-fun-16')

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
		self.font = font12
	elseif size == 16 then
		self.font = font16
	else
		self.font = font14
	end
	self.currentFontFamily = {
		[gfx.font.kVariantNormal] = self.font
	}
end

function Text:setInvert(invert)
	self.invert = invert
	self:markDirty()
end

-- Constrain text to a rectangle and enable wrapping
function Text:setRect(x, y, width, height)
	self.rect = {
		x = x,
		y = y,
		width = width,
		height = height
	}
	self:moveTo(x, y)
	self:setSize(width, height)
end

function Text:setText(newText)
	self.text = newText
	if self.rect == nil then
		local width, height = gfx.getTextSize(self.text, self.currentFontFamily)
		self:setSize(width, height)
	end
	self:markDirty()
end

-- draw callback from the sprite library
function Text:draw(x, y, width, height)
	if self.invert then
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	end
	if self.rect ~= nil then
		local w, h, trunc = gfx.drawTextInRect(self.text, 0, 0, self.rect.width, self.rect.height, nil, nil, kTextAlignment.left, self.font)
		if trunc then
			print("[warn] rendered text was truncated")
		end
	else
		gfx.drawText(self.text, 0, 0, self.currentFontFamily)
	end
	if self.invert then
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	end
end
