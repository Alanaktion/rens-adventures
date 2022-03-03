import "scripts/intro"

local gfx = playdate.graphics
local screenWidth = playdate.display.getWidth()
local screenHeight = playdate.display.getHeight()

class("Game").extends(Screen)

local script = intro

function Game:init()
	Game.super.init(self)

	self.txtName = Text()
	self.txtName:setFontSize(12)
	self.txtName:setInvert(true)
	self.txtName:setCenter(.5,0)
	self.txtName:moveTo(35, screenHeight - 80)

	self.txtQuote = Text()
	self.txtQuote:setInvert(true)
	self.txtQuote:setRect(6, screenHeight - 58, screenWidth - 12, 54)

	self.images = {
		message = gfx.image.new("images/message"),
		messageWithName = gfx.image.new("images/message-with-name")
	}

	self.messageBox = gfx.sprite.new()
	self.messageBox:setImage(self.images.message)
	self.messageBox:setCenter(0, 1)
	self.messageBox:moveTo(0, screenHeight)
	self.messageBox:setZIndex(90)

	self.prompt = Text()
	self.prompt:setFontSize(12)
	self.prompt:setText("Ⓐ")
	self.prompt:setCenter(1, 1)
	self.prompt:moveTo(screenWidth - 2, screenHeight)

	self.characters = {}
	self.scriptIndex = 0
	self.bHeldDuration = 0
end

function Game:show()
	Game.super.show(self)
	self.txtName:add()
	self.txtQuote:add()
	self.messageBox:add()
	self.prompt:add()
	self:advanceScript()
end

function Game:advanceScript()
	self.scriptIndex += 1
	local cur = script[self.scriptIndex]
	if cur then

		-- Reveal new characters
		if cur.reveal then
			for key, value in next, cur.reveal do
				char = Character()
				char:setCharacter(value.image)
				char:moveTo(value.pos.x * screenWidth, value.pos.y * screenHeight)
				if value.flip then
					char:setImageFlip(gfx.kImageFlippedX)
				end
				self.characters[key] = char
				char:add()
			end
		end

		-- Animate characters with motion
		-- TODO: implement a simple way to move characters around with easing

		-- Hide departing characters
		if cur.hide then
			for key, value in next, cur.hide do
				if self.characters[value] then
					self.characters[value]:remove()
					self.characters[value] = nil
				else
					print("Cannot hide character " .. value .. " that does not exist.")
				end
			end
		end

		-- Show message text
		if cur.text then
			self.messageBox:add()
			self.prompt:setInvert(true)
			if cur.name then
				self.messageBox:setImage(self.images.messageWithName)
				self.txtName:add()
				self.txtName:setText(cur.name)
			else
				self.messageBox:setImage(self.images.message)
				self.txtName:remove()
			end
			self.txtQuote:setText(cur.text)
		else
			self.messageBox:remove()
			self.prompt:setInvert(false)
		end

	else
		print("end of script")
		Screen.change("over", Over())
	end
end

function Game:update()
	Game.super.update(self)

	-- Press A to advance the script
	if playdate.buttonJustPressed(playdate.kButtonA) then
		self:advanceScript()
	end

	-- Hold B to return to title screen
	if playdate.buttonIsPressed(playdate.kButtonB) then
		self.bHeldDuration += 1/20
		if self.bHeldDuration >= 1 then
			Screen.change("title", Title())
		end
	end
	if playdate.buttonJustReleased(playdate.kButtonB) then
		self.bHeldDuration = 0
	end

end
