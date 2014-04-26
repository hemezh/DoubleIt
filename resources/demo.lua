--[[
User interface
--]]

module(..., package.seeall)

require('tile')
require('backtile')
require('game')

swipeLeft = 'Left'
swipeRight = 'Right'
swipeUp = 'Up'
swipeDown = 'Down'

tweenId = nil

-- Globals
demoScene = nil
local tileCountX = 4
local tileCountY = 2
local gridOffsetX = 0                    
local gridOffsetY = 0  
local touchX = -1
local touchY = -1
local touchMoved = false

local touchThreshold = 3/2
local minSwipeFactor = 7
local tileGrid


demoStates = {
	firstSwipe = 5,
	secondSwipe = 10,
	thirdSwipe = 15,
	fourthSwipe = 20,
	tilebreak = 25,
	tbTile = 30,
	swap = 35,
	swapFirst = 40,
	swapSecond = 45,
	cnt = 50
}

local demoState = demoStates.firstSwipe
local demoGrid

fontScale = game.fontScale
graphicsScale = game.graphicsScale
powerIconScale = game.powerIconScale
powerFontFactor = game.powerFontFactor
powerCountImageScale = game.powerCountImageScale

-- print(" ********* powerFontFactor ", game.powerFontFactor)
-- print(" ********* graphicsScale ", game.graphicsScale)

function init()

	demoScene = director:createScene()
	demoScene:addEventListener("enterPreTransition", enterDemo)
	demoScene:addEventListener("key",keyPressed)

	initDemoUI()
	demoGrid = grid.new(tileCountX, tileCountY, gridOffsetX, gridOffsetY)
	demoGrid:setBackTiles()
	-- demoGrid:initDemo()
	demoGrid.backTileGrid[2][2].sprite:addEventListener("touch",tbTileTouched)
	demoGrid.backTileGrid[1][1].sprite:addEventListener("touch",swapFirstTileTouched)
	demoGrid.backTileGrid[2][1].sprite:addEventListener("touch",swapSecondTileTouched)
	-- changeNT(1)
	

end -- end of init

function initDemoUI()

	local background = director:createSprite(director.displayCenterX, director.displayCenterY, "textures/bg.png")
	background.xAnchor = 0.5
	background.yAnchor = 0.5
	local bg_width, bg_height = background:getAtlas():getTextureSize()
	background.xScale = director.displayWidth / bg_width
	background.yScale = director.displayHeight / bg_height

	gridOffsetX = director.displayCenterX -  (tileCountX * tile.actualWidth * game.graphicsScale) / 2
	gridOffsetY = director.displayCenterY - (tileCountY * tile.actualHeight * game.graphicsScale) / 2

	scoreLabelDemo = director:createLabel({ 
		x = game.offSet.score.x, 
		y = game.offSet.score.y, 
		h = game.actualFontHeight,
		text = "0",
		textXScale = game.fontScale, 
		textYScale = game.fontScale 
		})


	addScoreLabelDemo = director:createLabel({
		x = game.offSet.score.x, 
		y = game.offSet.score.y, 
		h = game.actualFontHeight,
		text = "+",
		textXScale = game.fontScale * powerFontFactor, 
		textYScale = game.fontScale * powerFontFactor 
		})

	addScoreLabelDemo.isVisible = false
	

	changeNextTileDemo = director:createSprite(game.offSet.changeNextTile.x, game.offSet.changeNextTile.y, "textures/change.png")
	changeNextTileDemo.xScale = game.graphicsScale * powerIconScale
	changeNextTileDemo.yScale = graphicsScale * powerIconScale
	changeNextTileDemo:addEventListener("touch",changeNextTileDemoTouch)
	-- changeNextTile:addEventListener("touch", testGameEnd)
	changeNextTilePowerImageDemo = director:createSprite({
		x = game.offSet.changeNextTile.x + changeNextTileDemo.w * graphicsScale * powerIconScale,
		y = game.offSet.changeNextTile.y+ changeNextTileDemo.h * graphicsScale * powerIconScale,
		source = "textures/noti.png",
		xScale = graphicsScale * powerCountImageScale,
		yScale = graphicsScale * powerCountImageScale,
		xAnchor = 0.66,
		yAnchor = 0.66,
		zOrder  = 1,
		})

	changeNextTilePowerDemo = director:createLabel(changeNextTileDemo.x + game.offSet.changeNextTile.w - 14*graphicsScale, changeNextTileDemo.y + game.offSet.changeNextTile.h - 24 * graphicsScale, "0" )
	changeNextTilePowerDemo.textXScale = fontScale * powerFontFactor
	changeNextTilePowerDemo.textYScale = fontScale * powerFontFactor
	-- changeNextTilePower.color = {160, 80, 140} -- {107, 7, 144} 
	-- setPowerCountPos(changeNextTilePowerDemo,0,offSet.changeNextTile.x + offSet.changeNextTile.w)
	changeNextTilePowerDemo.zOrder = 2

	
	
	
	tileBreakDemo = director:createSprite(game.offSet.tileBreak.x, game.offSet.tileBreak.y, "textures/tilebreak.png")
	tileBreakDemo.xScale = graphicsScale * powerIconScale
	tileBreakDemo.yScale = graphicsScale * powerIconScale
	tileBreakDemo:addEventListener("touch", tileBreakDemoTouch)
	-- tileBreak.isVisible = false
	tileBreakPowerImageDemo = director:createSprite({
		x = game.offSet.tileBreak.x + tileBreakDemo.w * graphicsScale * powerIconScale,
		y = game.offSet.tileBreak.y+ tileBreakDemo.h * graphicsScale * powerIconScale,
		source = "textures/noti.png",
		xScale = graphicsScale * powerCountImageScale,
		yScale = graphicsScale * powerCountImageScale,
		xAnchor = 0.66,
		yAnchor = 0.66,
		zOrder  = 1,
		})
	-- tileBreakPowerImage.isVisible =false
	-- 1 digit 15 20 22 10-19 19
	tileBreakPowerDemo = director:createLabel(tileBreakDemo.x + game.offSet.tileBreak.w - 14 * graphicsScale, tileBreakDemo.y + game.offSet.tileBreak.h - 24 *graphicsScale , "0")
	tileBreakPowerDemo.textXScale = fontScale * powerFontFactor
	tileBreakPowerDemo.textYScale = fontScale * powerFontFactor
	-- setPowerCountPos(tileBreakPowerDemo,0,offSet.tileBreak.x + offSet.tileBreak.w)
	-- tileBreakPower.xAnchor = 0.1
	-- tileBreakPower.yAnchor = 0.1
	-- tileBreakPower.color = changeNextTilePower.color
	tileBreakPowerDemo.zOrder = 2

	swapTileDemo = director:createSprite(game.offSet.swap.x, game.offSet.swap.y , "textures/swap.png")
	swapTileDemo.xScale = graphicsScale * powerIconScale
	swapTileDemo.yScale = graphicsScale * powerIconScale

	-- swapTile.isVisible = false
	swapTileDemo:addEventListener("touch",swapTileDemoTouched)

	swapPowerImageDemo = director:createSprite({
		x = game.offSet.swap.x + swapTileDemo.w * graphicsScale * powerIconScale,
		y = game.offSet.swap.y+ swapTileDemo.h * graphicsScale * powerIconScale,
		source = "textures/noti.png",
		xScale = graphicsScale * powerCountImageScale,
		yScale = graphicsScale * powerCountImageScale,
		xAnchor = 0.66,
		yAnchor = 0.66,
		zOrder  = 1,
		})

	swapTilePowerDemo = director:createLabel(swapTileDemo.x + game.offSet.swap.w - 14 * game.graphicsScale, swapTileDemo.y + game.offSet.swap.h - 24 * graphicsScale,"0")
	swapTilePowerDemo.textXScale = fontScale * powerFontFactor
	swapTilePowerDemo.textYScale = fontScale * powerFontFactor
	-- swapTilePower.color = changeNextTilePower.color
	-- setPowerCountPos(swapTilePower,0,offSet.swap.x + offSet.swap.w)
	swapTilePowerDemo.zOrder = 2


	glowRectangleDemo = director:createRectangle({
	    x = 0, y = 0,
	    -- xAnchor=0.5, yAnchor=0.5, -- x, y now specify the centre
	    w = 10 , h = 10,
	    strokeWidth=3, strokeColor = {255, 255, 255}, strokeAlpha=1,
	    alpha = 0
    } )
	glowRectangleDemo.isVisible = false

	glowTileRectangleDemo = director:createRectangle({
	    x = 0, y = 0,
	    -- xAnchor=0.5, yAnchor=0.5, -- x, y now specify the centre
	    w = 10 , h = 10,
	    strokeWidth=3, strokeColor= {255, 255, 255}, strokeAlpha=1,
	    alpha=0
    } )
	glowTileRectangleDemo.isVisible = false

	

	successMessage = director:createLabel({
		x = 0,
		y = director.displayCenterY + (tile.actualHeight + 20) * game.graphicsScale,
		hAlignment = "center",
		text = "How To Play DoubleIt !",
		textXScale = game.fontScale * 1.5,-- * 0.750,
		textYScale = game.fontScale * 1.5,-- * 0.750,
		zOrder = 2
		-- color = {246, 205, 89}
		})

	instMessage = director:createLabel({
		x = 0,
		y = director.displayCenterY - (tile.actualHeight + 20) * game.graphicsScale ,
		hAlignment = "centre",
		text = "Swipe Left To Start",
		textXScale = game.fontScale,-- * 0.75,
		textYScale = game.fontScale,-- * 0.75,
		color = {246, 205, 89},
		zOrder = 2
		})
	instMessage.y = instMessage.y - instMessage.hText 

	playDemo = director:createSprite(director.displayCenterX, director.displayHeight / 2 , "textures/play.png")
	local play_width, play_height = playDemo:getAtlas():getTextureSize()
	playDemo.y = instMessage.y - ( (play_height + 20 )  * game.graphicsScale)
	playDemo.xAnchor = 0.5
	playDemo.xScale = game.graphicsScale
	playDemo.yScale = game.graphicsScale
	playDemo:addEventListener("touch", startGameFromDemo)
	playDemo.isVisible = false


	arrow = director:createSprite({
		x = 0,
		y = 0,
		source = "textures/arrow.png",
		xScale = graphicsScale,
		yScale = graphicsScale,
		zOrder  = 1,
		})
	-- homeDemo:addEventListener("touch",backToHome)
	background:addEventListener("touch", demoSceneTouch)

end


function enterDemo ()
	demoGrid:initDemo()
	changeDemoState(demoStates.firstSwipe)
	playDemo.isVisible = false
	tileBreakPowerDemo.text = "1"
	swapTilePowerDemo.text = "1"
	changeNextTilePowerDemo.text = "1"
	scoreLabelDemo.text = "0"

	changeNT(1)
	if tweenId ~= nil then
		tween:cancel(tweenId)
	end
			
	arrow.isVisible = true
	arrow.rotation = 0
	arrow.x = director.displayCenterX + arrow.w * graphicsScale / 2
	arrow.y = instMessage.y - (arrow.h + 30)* graphicsScale
	print("arrow x and y ", arrow.x, arrow.y)
	tweenId = tween:to(arrow,{x = director.displayCenterX - arrow.w * graphicsScale, time=1, mode="repeat"})


	successMessage.text = "How To Play!"
	successMessage.hAlignment = "centre"
	instMessage.text = "Swipe Left to start"
	instMessage.hAlignment = "centre"
	
	game.db:setValue("demo",1729)
	
	if (game.adverts.enabled == true) then
		    game.adverts:visibility(true)
	end
end

function keyPressed(event)
	if event.phase == "released" then
		if event.keyCode == key.back then
			switchToScene("home")
		end
	end
end


function  demoSceneTouch(event)


	if (event.phase == "began") then
		
		touchX = event.x
		touchY = event.y
		touchMoved = false
		-- print("touched event began\n")
	end
	if (event.phase == "moved") then
		
		touchMoved = true
		-- print("touched event moved\n")
	end
	if (event.phase == "ended" ) then
		-- print("here")
		if ( touchMoved == true ) then -- if swipe was Done
			-- print("swipe made")
			swipeMade(event, touchX, touchY)
		end	
		touchMoved = false
	end
	
end
function changeDemoState(demo_state)
	-- print(demo_state)
	demoState = demo_state
	-- print("Changing Demo State to ",game_state)
end

function swipeMade(event, touchX, touchY)
		
		dx = event.x - touchX
		dy = event.y - touchY
		-- print(dx, dy)
		if( math.abs(dx) > math.abs(dy) and math.abs(dx) > director.displayWidth/minSwipeFactor ) then
			if (math.abs(dy) <= math.abs(dx)/touchThreshold) then 
				if (dx > 0 ) then 
						-- print("right")
						handleSwipe(swipeRight)  
				else
						-- print("left")
						handleSwipe(swipeLeft)
				end
			end
		elseif ( math.abs(dy) > director.displayHeight/minSwipeFactor ) then
			if (math.abs(dx) <= math.abs(dy)/touchThreshold) then 
				if (dy > 0) then
						-- print("up")
						handleSwipe(swipeUp)
				else
						-- print("down")
						handleSwipe(swipeDown)
				end
			end
		end
end

function handleSwipe(swipe)

	if swipe == swipeLeft then
		-- print("swipeleft")
		if demoState == demoStates.firstSwipe then
			-- print("firstSwipe")
			moveTile(4, 2, 3, 2)

			changeNT(2)

			demoGrid:bringInNewTile(1,{5,2},{4,2})
			changeDemoState(demoStates.secondSwipe)
			-- successMessage.text = "Tiles move by one step in swipe direction"
			successMessage.text = ""
			successMessage.hAlignment = "centre"
			instMessage.text = "Swipe down to move tiles"
			instMessage.hAlignment = "centre"

			tween:cancel(tweenId)
			arrow.rotation = 270
			arrow.x = director.displayCenterX + (2 * tile.actualWidth + 30 + arrow.h ) * graphicsScale
			arrow.y = director.displayCenterY + (arrow.w) * graphicsScale
			tweenId = tween:to(arrow,{y = director.displayCenterY - (arrow.w) * graphicsScale, time=1, mode="repeat"})

		elseif demoState == demoStates.thirdSwipe then
							----
			mergeTile(3, 1, 2, 1)
			
			moveTile(4, 1, 3, 1)

			moveTile(4, 2, 3, 2)
				----
			demoGrid:bringInNewTile(4,{5,1},{4,1})

			changeNT(1)
			changeDemoState(demoStates.fourthSwipe)
			successMessage.text = "2 + 2 = 4"
			successMessage.hAlignment = "centre"
			instMessage.text = "Bigger tiles get higher score"
			instMessage.hAlignment = "centre"
		
		elseif demoState == demoStates.fourthSwipe then
			
			mergeTile(2, 1, 1, 1)		
				----
			moveTile(3, 2, 2, 2)

			moveTile(3, 1, 2, 1)
			moveTile(4, 1, 3, 1)
				----
			demoGrid:bringInNewTile(1,{5,1},{4,1})	
			-- successMessage.text = "Almost done!"
			successMessage.text = ""
			successMessage.hAlignment = "centre"
			instMessage.text = "Use hammer to break tiles"
			instMessage.hAlignment = "centre"
				----
			changeNT(2)

			-- tween:cancel(tweenId)
			-- arrow.isVisible = false
			tween:cancel(tweenId)
			arrow.rotation = 90
			arrow.x = tileBreakDemo.x + (tileBreakDemo.w/2) * graphicsScale * powerIconScale - (arrow.h/2) * graphicsScale
			arrow.y = tileBreakDemo.y - (60 )* graphicsScale 
			tweenId = tween:to(arrow,{y = tileBreakDemo.y - (10)* graphicsScale, time=0.5, mode="mirror"})
			changeDemoState(demoStates.tilebreak)
		end 
	elseif swipe == swipeDown then
		-- print("swipeDown")
		if demoState == demoStates.secondSwipe then
			-- print("secondSwipe")
				----
			moveTile(3, 2, 3, 1)
				-----
			moveTile(4, 2, 4, 1)
			changeNT(4)
			demoGrid:bringInNewTile(2,{4,3},{4,2})
			successMessage.text = "1 + 1 = 2"
			successMessage.hAlignment = "centre"
			instMessage.text = "Swipe left to merge tiles"
			instMessage.hAlignment = "centre"
			
			changeDemoState(demoStates.thirdSwipe)
			tween:cancel(tweenId)
			arrow.rotation = 0
			arrow.x = director.displayCenterX + arrow.w * graphicsScale / 2
			arrow.y = instMessage.y - (arrow.h + 30)* graphicsScale
			tweenId = tween:to(arrow,{x = director.displayCenterX - arrow.w * graphicsScale, time=1, mode="mode"})
		end
	end
end

function changeNT(number)
	demoGrid.nextTile = number
	demoGrid:changeNextTile("demo")
end

function moveTile(i, j, ii, jj)
			
			demoGrid:animateMoveTile({i, j},{ii, jj})

			demoGrid.gemsGrid[ii][jj] = demoGrid.gemsGrid[i][j]
			demoGrid.gemsGrid[i][j] = nil
end

function mergeTile(i, j, ii, jj)
			
			demoGrid:animateMoveTile({i, j},{ii, jj})
			
			local newNumber = demoGrid.gemsGrid[i][j].number + demoGrid.gemsGrid[ii][jj].number
			demoGrid.gemsGrid[i][j].sprite.isVisible = false
			demoGrid.gemsGrid[i][j]:deleteTile()
			demoGrid.gemsGrid[i][j] = nil
			
			local coord = demoGrid:getTilePosition(ii, jj)
			local localTile = tile.new(newNumber, coord[1], coord[2])
			tween:dissolve(demoGrid.gemsGrid[ii][jj].sprite, localTile.sprite, 0.5, 0)

			demoGrid.gemsGrid[ii][jj]:deleteTile()
			demoGrid.gemsGrid[ii][jj] = nil
			demoGrid.gemsGrid[ii][jj] = localTile

			addScoreLabelDemo.text = "+"..tostring(newNumber)
			addScoreLabelDemo.isVisible = true
			tween:to(addScoreLabelDemo,{y = addScoreLabelDemo.y + 60 * game.graphicsScale, onComplete=setAddScoreLabelDemo})
			scoreLabelDemo.text = tostring( tonumber(scoreLabelDemo.text) + newNumber ) 
end

function setAddScoreLabelDemo()
	addScoreLabelDemo.isVisible = false
	addScoreLabelDemo.y = game.offSet.score.y

end
 function tileBreakDemoTouch(event)
 	if event.phase == "ended" and demoState == demoStates.tilebreak then
 		glowPowerDemo({game.offSet.tileBreak.x, game.offSet.tileBreak.y, game.offSet.tileBreak.w, game.offSet.tileBreak.h})
 		-- successMessage.text = "Tile break power is selected"
 		-- successMessage.text = "Break this tile"
		successMessage.hAlignment = "centre"
		instMessage.text = "Tap on the tile to break it"
		instMessage.hAlignment = "centre"

		tween:cancel(tweenId)
		arrow.rotation = 270
		arrow.x = director.displayCenterX - (tile.actualWidth/2 - arrow.h/2) * graphicsScale
		arrow.y = director.displayCenterY + (tile.actualHeight + 70)* graphicsScale 
		tweenId = tween:to(arrow,{y = director.displayCenterY + (tile.actualHeight + 10)* graphicsScale , time=0.5, mode="mirror"})
		changeDemoState(demoStates.tbTile)
	end
 end

 function glowPowerDemo(coordinates)

		glowRectangleDemo.x = coordinates[1]
	    glowRectangleDemo.y = coordinates[2]
	    glowRectangleDemo.w = coordinates[3]
	    glowRectangleDemo.h = coordinates[4]
	    glowRectangleDemo.isVisible = true
end


function glowTileDemo(coordinates)

	    glowTileRectangleDemo.x = coordinates[1]
	    glowTileRectangleDemo.y = coordinates[2]
	    glowTileRectangleDemo.w = coordinates[3]
	    glowTileRectangleDemo.h = coordinates[4]
	    glowTileRectangleDemo.isVisible = true
end

function tbTileTouched(event)
	if event.phase == "ended" and demoState == demoStates.tbTile then
		demoGrid:tileBreak({2,2})
		glowRectangleDemo.isVisible = false
		changeDemoState(demoStates.swap)
		tileBreakPowerDemo.text = "0"
		-- successMessage.text = "The selected tile is gone"
		successMessage.text = ""
		successMessage.hAlignment = "centre"
		instMessage.text = "Select swap tiles power"
		instMessage.hAlignment = "centre"

		tween:cancel(tweenId)
		arrow.rotation = 90
		arrow.x = swapTileDemo.x + (swapTileDemo.w/2) * graphicsScale * powerIconScale - (arrow.h/2) * graphicsScale
		arrow.y = swapTileDemo.y - (70 )* graphicsScale 
		tweenId = tween:to(arrow,{y = swapTileDemo.y - (10)* graphicsScale, time=0.5, mode="mirror"})
	end
end

function swapTileDemoTouched(event)
	if event.phase == "ended" and demoState == demoStates.swap then
		glowPowerDemo({game.offSet.swap.x, game.offSet.swap.y, game.offSet.swap.w, game.offSet.swap.h})
		-- successMessage.text = "Swap tiles power is selected"
		successMessage.hAlignment = "centre"
		instMessage.text = "Select first tile"
		instMessage.hAlignment = "centre"

		tween:cancel(tweenId)
		arrow.rotation = 90
		arrow.x = director.displayCenterX - (3*tile.actualWidth/2 + arrow.h/2) * graphicsScale
		arrow.y = director.displayCenterY - (tile.actualHeight + 70)* graphicsScale 
		tweenId = tween:to(arrow,{y = director.displayCenterY - (tile.actualHeight + 10)* graphicsScale , time=0.5, mode="mirror"})

		changeDemoState(demoStates.swapFirst)
	end
end

function swapFirstTileTouched(event)
	if event.phase == "ended" and demoState == demoStates.swapFirst then
		local ss = demoGrid.gemsGrid[1][1].sprite
		glowTileDemo({ss.x, ss.y, ss.w * game.graphicsScale, ss.h * game.graphicsScale})
		-- successMessage.text = "First tile is selected"
		successMessage.hAlignment = "centre"
		instMessage.text = "Swap it"
		instMessage.hAlignment = "centre"

		tween:cancel(tweenId)
		arrow.rotation = 90
		-- director.displayCenterX - (tile.actualWidth/2 - arrow.h/2) * graphicsScale
		arrow.x = director.displayCenterX - (tile.actualWidth/2 + arrow.h/2) * graphicsScale
		arrow.y = director.displayCenterY - (tile.actualHeight + 70)* graphicsScale 
		tweenId = tween:to(arrow,{y = director.displayCenterY - (tile.actualHeight + 10)* graphicsScale , time=0.5, mode="mirror"})

		changeDemoState(demoStates.swapSecond)
	end
end

function swapSecondTileTouched(event)
	if event.phase == "ended" and demoState == demoStates.swapSecond then
		
		demoGrid:swapTiles({1, 1}, {2, 1})

		glowTileRectangleDemo.isVisible = false
		glowRectangleDemo.isVisible = false
		swapTilePowerDemo.text = "0"
		-- successMessage.text = "Both the selected tiles has been swapped"
		successMessage.text = ""
		successMessage.hAlignment = "centre"
		instMessage.text = "Tap to change upcoming tile"
		instMessage.hAlignment = "centre"

		tween:cancel(tweenId)
		arrow.rotation = 90
		arrow.x = changeNextTileDemo.x + (changeNextTileDemo.w/2) * graphicsScale * powerIconScale - (arrow.h/2) * graphicsScale
		arrow.y = changeNextTileDemo.y - (70 )* graphicsScale 
		tweenId = tween:to(arrow,{y = changeNextTileDemo.y - (10)* graphicsScale, time=0.5, mode="mirror"})

		changeDemoState(demoStates.cnt)
	end
end

function changeNextTileDemoTouch(event)
	if event.phase == "ended" and demoState == demoStates.cnt then
 		demoGrid:changeNextTile("demo")
 		changeNextTilePowerDemo.text = "0"
		changeDemoState(demoStates.demoEnded)
		-- successMessage.text = "The next incoming tiles has been changed"
		successMessage.text = "Tutorial Complete"
		successMessage.hAlignment = "centre"
		instMessage.text = "Great! You are good to go."
		instMessage.hAlignment = "centre"
		arrow.isVisible = false
		playDemo.isVisible = true
	end
end

function startGameFromDemo(event)
	if event.phase == "ended" and demoState == demoStates.demoEnded then
		switchToScene("gameFromDemo")
	end
end