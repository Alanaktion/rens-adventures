class('SaveSlotSprite').extends(NobleSprite)

function SaveSlotSprite:init(chapter, time)
	SaveSlotSprite.super.init(self)
	self:setCenter(.5, 0)
	self:setZIndex(20)
	self:setSize(200, 44)
	self.chapter = chapter
	self.time = time
	self.selected = false
end

function SaveSlotSprite:setSelected(selected)
	self.selected = selected
end

function SaveSlotSprite:draw(x, y, width, height)
	Graphics.setColor(Graphics.kColorBlack)
	Graphics.setLineWidth(1)
	Graphics.setStrokeLocation(Graphics.kStrokeInside)
	Graphics.drawRoundRect(0, 0, width, height, 5)
	if self.selected then
		Graphics.fillRoundRect(1, 1, width - 2, height - 2, 3)
		Graphics.setImageDrawMode(Graphics.kDrawModeFillWhite)
	end
	if self.chapter ~= nil then
		Graphics.drawTextInRect(self.chapter, 10, 6, width - 20, height - 16, nil, nil, kTextAlignment.left, font16)
		Graphics.drawTextInRect(self.time, 10, 24, width - 20, height - 16, nil, nil, kTextAlignment.left, font12)
	else
		Graphics.drawTextInRect("No data", 0, 16, width, height, nil, nil, kTextAlignment.center, font14)
	end
	if self.selected then
		Graphics.setImageDrawMode(Graphics.kDrawModeCopy)
	end
end
