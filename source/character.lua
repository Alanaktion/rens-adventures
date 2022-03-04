local gfx = playdate.graphics

class('Character').extends(gfx.sprite)

function Character:init(name)
	Character.super.init(self)
	self.chara = name
	self:setImage(gfx.image.new('images/chara/' .. name))
	self:setCenter(.5, 1)
	self:setZIndex(20)
end
