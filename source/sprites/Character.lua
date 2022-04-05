class('Character').extends(NobleSprite)

function Character:init(name)
	Character.super.init(self, 'assets/images/chara/' .. name)
	self.chara = name
	self:setCenter(.5, 1)
	self:setZIndex(20)
end

function Character:changeImage(name)
	self:setImage(Graphics.image.new('assets/images/chara/' .. name))
end
