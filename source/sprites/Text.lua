font12 = Graphics.font.new('assets/fonts/Pedallica/font-pedallica')
font12:setTracking(1)
font14 = Graphics.font.new('assets/fonts/Pedallica/font-pedallica-ren-14')
font14bold = Graphics.font.new('assets/fonts/Pedallica/font-pedallica-ren-14-bold')
font16 = Graphics.font.new('assets/fonts/Pedallica/font-pedallica-fun-16')

fontFamily = {
	[Graphics.font.kVariantNormal] = font14,
	[Graphics.font.kVariantBold] = font14bold,
	-- [Graphics.font.kVariantItalic] = font14italic,
	-- TODO: Make italic font variant, especially useful for message logs
}
Noble.Text.setFont(font14)
Graphics.setFontFamily(fontFamily)

class('Text').extends(NobleSprite)

function Text:init()
	Text.super.init(self)
	self.invert = false
	self.textAlignment = kTextAlignment.left
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
	if size == 14 then
		self.currentFontFamily = fontFamily
	else
		self.currentFontFamily = {
			[Graphics.font.kVariantNormal] = self.font
		}
	end
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

function Text:setAlignment(alignment)
	self.textAlignment = alignment
end

function Text:setText(newText)
	self.text = newText
	if self.rect == nil then
		local width, height = Graphics.getTextSize(self.text, self.currentFontFamily)
		self:setSize(width, height)
	end
	self:markDirty()
end

-- draw callback from the sprite library
function Text:draw(x, y, width, height)
	if self.invert then
		Graphics.setImageDrawMode(Graphics.kDrawModeFillWhite)
	end
	if self.rect ~= nil then
		local w, h, trunc = Graphics.drawTextInRect(self.text, 0, 0, self.rect.width, self.rect.height, nil, nil, self.textAlignment, self.font)
		if trunc then
			print("[warn] rendered text was truncated")
		end
	else
		Graphics.drawText(self.text, 0, 0, self.currentFontFamily)
	end
	if self.invert then
		Graphics.setImageDrawMode(Graphics.kDrawModeCopy)
	end
end
