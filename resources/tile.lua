
module(..., package.seeall)


require("class")

tile = inheritsFrom(baseClass)
actualWidth = 122
actualHeight = 166
local gemAtlases = {}

function new(number, x, y)
	local obj = tile:create()
	tile:init(obj, number, x, y)
	return obj
end

function tile:init(o, number, x, y)
	o.number = number
	--print(x, y)
	
	o.sprite = director:createSprite( {
		x = x, y = y,
		-- xAnchor = 2.5, yAnchor = 2.5, 
		xScale = game.graphicsScale, 
		yScale = game.graphicsScale, 
		source = "textures/tile-"..tostring(number)..".png"
	} )
	

	-- obj.label = director:createLabel( {
 --    x = x, y = y,
 --    text = tostring(number),
 -- 	textXScale = director.displayWidth / 240,
	-- textYScale = 2
 --    } )
end

function tile:deleteTile()
	
	local myAtlas = self.sprite.animation.usedAtlases
	local myAnimation = self.sprite.animation

	director:getCurrentScene():releaseAtlas(myAtlas)
    director:getCurrentScene():releaseAnimation(myAnimation)
    self.sprite = self.sprite:removeFromParent()
end