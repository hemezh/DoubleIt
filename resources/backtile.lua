
module(..., package.seeall)


require("class")

backtile = inheritsFrom(baseClass)
actualWidth = 122
actualHeight = 166

function new(number, x, y)
	local obj = backtile:create()
	backtile:init(obj, number, x, y)
	return obj
end

function backtile:init(obj, number, x, y)
	obj.number = number
	--print(x, y)
	
	obj.sprite = director:createSprite( {
		x = x, y = y,
		-- xAnchor = 2.5, yAnchor = 2.5, 
		xScale = game.graphicsScale, 
		yScale = game.graphicsScale, 
		source = "textures/tile_bg.png"
	} )

end