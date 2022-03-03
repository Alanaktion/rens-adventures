local gfx = playdate.graphics

class('Character').extends(gfx.sprite)

function Character:init()
	Character.super.init(self)
	self:setCenter(.5, 1)
	self:setZIndex(20)
end

function Character:setCharacter(newChara)
	self.chara = newChara
	self:setImage(gfx.image.new('images/chara/' .. newChara))
	self:markDirty()
end
