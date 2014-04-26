--[[
Main game logic
--]]

module(..., package.seeall)

-- Global design time constants
tileCountX = 4										    
tileCountY = 4	
fontHeight = 60										-- Pixel height of font
fontDesignWidth = 768								-- Font was designed to be displayed on a 480 wide screen
graphicDesignWidth = 768						-- Graphics were designed to be displayed on a 480 wide screen

fontScale = director.displayWidth / fontDesignWidth	-- Font is correct size on 480 wide screen so we scale to match native screen size	
actualFontHeight = fontHeight * fontScale			      -- The actual pixel height of the font						    	
-- defaultFont = director:createFont("fonts/ComicSans24.fnt")
graphicsScale = director.displayWidth / graphicDesignWidth
--gridActualHeight =  *graphicsScale			    -- The actual device coordinate height of the gems grid
gridOffsetX = 0                    -- Grid offset screen position on x-axis
gridOffsetY = 0                   -- Grid offset screen position on y-axis
nextTile = nil
highScoreLabel = nil
inmobiAd = nil
gameStates = {
	playing						= 5,
	gameProcessing				= 7,
	tileBreakSelected			= 10,
	swapSelected				= 15,
	swapFirstTileSelected		= 20,
	pauseSelected				= 25,
	gameEnded					= 30,
}

powerFontFactor = 0.6
powerIconScale = 0.40
powerCountImageScale = 0.45
totalGamesPlayed = 1
totalGamesEnded = 0

local gameState = gameStates.playing

local class = require("class")
require("grid")
require("adverts")
require("social")
require("store")
require("stats")
require("mainMenu")
require("demo")
require("storeScene")
require("pauseMenu")
require("gameEnd")
require("storeScene")
require("database")

-- Local Constants
gridGame = nil
gameScene = nil
nextTile = nil
newGame = false
isHomeScreen = true
storeFrom = "home"


local touchX = -1
local touchY = -1
local touchMoved = false
local swapFirstTile = {}
local swapSecondTile = {}
local gameEndScoreLabel = {}
local topOffset = 10
local sideOffset = 10
local powerSpacing = 55
local remainingTilesScore = 0
local wrongCoord = {-1, -1}



-- More constants
-- wallAdd = adverts.new()
-- adverts = adverts.new()       -- Create adverts class
social = social.new()         -- create social class
store = store.new()           -- Create store class
stats = stats.new()           -- Create stats class
db = database.new()			  -- Create databse class


offSet = {
	options = {
		x = 20 * graphicsScale,
		y = director.displayHeight - (70 + 45) * graphicsScale,
		w = 212 * graphicsScale * powerIconScale,
		h = 212 * graphicsScale * powerIconScale
	},
	score = {
		x = ( 20 + 70 + 30) * graphicsScale,
		y = director.displayHeight - (55 + 45)*graphicsScale,
		w = 50,
		h = 50
	},
	tileBreak = {
		x = director.displayWidth/2 - (106 + powerSpacing + 212) * graphicsScale * powerIconScale,
		y = director.displayHeight - (70 + 45)*graphicsScale,
		w = 212 * graphicsScale * powerIconScale,
		h = 212 * graphicsScale * powerIconScale
	},
	swap = {
		x = director.displayWidth/2 - (106)*graphicsScale * powerIconScale, -- - (20 + tile.actualWidth + powerSpacing + 70 + powerSpacing + 70) * graphicsScale,
		y = director.displayHeight - (70 + 45)*graphicsScale,
		w = 212*graphicsScale * powerIconScale,
		h = 212*graphicsScale * powerIconScale,
	},
	changeNextTile = {
		x = director.displayWidth/2 + (powerSpacing + 106) * graphicsScale * powerIconScale,
		y = director.displayHeight - (70 + 45)*graphicsScale,
		w = 212*graphicsScale * powerIconScale,
		h = 212*graphicsScale * powerIconScale,
	},
	highScore = {
		x = ( 20 + 80 + 20) * graphicsScale,
		y = director.displayHeight - (70 + 25)*graphicsScale,
		w = 50,
		h = 50
	},
	nextTile = {
		x = director.displayWidth - tile.actualWidth*graphicsScale - 20 * graphicsScale ,
		y = director.displayHeight - (tile.actualHeight + 25) * graphicsScale ,
		w = tile.actualWidth * graphicsScale,
		h = tile.actualHeight * graphicsScale
	}
}

function init()

	device:setBacklightAlways(false)
	initGameUI()

	gridGame = grid.new(tileCountX, tileCountY,gridOffsetX, gridOffsetY)
	gridGame:setBackTiles()
	gridGame:initGame()

	gameEndScoreLabelInit()

	-- highScoreLabel.text = tostring(gridGame.highScore)
	tileBreakPower.text = tostring(gridGame.tileBreakCount)
	setPowerCountPos(tileBreakPower,gridGame.tileBreakCount,offSet.tileBreak.x + offSet.tileBreak.w)
	swapTilePower.text = tostring(gridGame.swapTileCount)
	setPowerCountPos(swapTilePower,gridGame.swapTileCount,offSet.swap.x + offSet.swap.w)
	changeNextTilePower.text = tostring(gridGame.changeNextTileCount)
	setPowerCountPos(changeNextTilePower,gridGame.changeNextTileCount,offSet.changeNextTile.x + offSet.changeNextTile.w)

	pauseMenu.init()
	storeScene.init()
	gameEnd.init()
	demo.init()
	mainMenu.init()
	
	quitDialog = quick.QDialog:new()
	inmobiAd = quick.QInmobi:new()
	
	
	
end

function loadBannerAd()
	if  inmobiAd:isAvailable() == true then
		inmobiAd:init()
		inmobiScale = director.displayWidth/320
		inmobiAd:bannerAd((director.displayWidth), director.displayHeight)
	end
end

function initGameUI()
	
	gameScene = director:createScene()
	
	gameScene:addEventListener("enterPreTransition", enterPre)
	gameScene:addEventListener("key", keyPressed)

	local background = director:createSprite(director.displayCenterX, director.displayCenterY, "textures/bg.png")
	background.xAnchor = 0.5
	background.yAnchor = 0.5
	local bg_width, bg_height = background:getAtlas():getTextureSize()
	background.xScale = director.displayWidth / bg_width
	background.yScale = director.displayHeight / bg_height

	gridOffsetX = director.displayCenterX -  (tileCountX * tile.actualWidth * graphicsScale) / 2
	gridOffsetY = director.displayCenterY - (tileCountY * tile.actualHeight * graphicsScale) / 2

	-- gridSprite = director:createSprite( {
	-- 	x = director.displayCenterX, y = director.displayCenterY, 
	-- 	xAnchor = 0.5, yAnchor = 0.5, 
	-- 	xScale = graphicsScale, 
	-- 	yScale = graphicsScale, 
	-- 	source = "textures/grid.jpg",		
	-- } )
	-- gridSprite:addEventListener("touch", gridTouch)


	options = director:createSprite(offSet.options.x, offSet.options.y, "textures/options.png")
	options.xScale = graphicsScale * powerIconScale
	options.yScale = graphicsScale * powerIconScale
	-- options:addEventListener("touch", optionsTouch)

	scoreLabel = director:createLabel({ 
		x = offSet.score.x, 
		y = offSet.options.y + (options.h/2) * graphicsScale * powerIconScale,
		h = actualFontHeight,
		text = "0",
		textXScale = game.fontScale, 
		textYScale = game.fontScale 
		})
	 -- scoreLabel.vAlignment = "middle"
	scoreLabel.y = scoreLabel.y - actualFontHeight/2

	addScoreLabel = director:createLabel({
		x = offSet.score.x, 
		y = offSet.score.y, 
		h = actualFontHeight,
		text = "+",
		textXScale = game.fontScale * powerFontFactor, 
		textYScale = game.fontScale * powerFontFactor 
		})

	addScoreLabel.isVisible = false


	-- nextTile = tile.new(0, offSet.nextTile.x,offSet.nextTile.y)
	
	changeNextTile = director:createSprite(offSet.changeNextTile.x, offSet.changeNextTile.y, "textures/change.png")
	changeNextTile.xScale = graphicsScale * powerIconScale
	changeNextTile.yScale = graphicsScale * powerIconScale
	-- changeNextTile:addEventListener("touch",changeNextTileTouch)
	-- changeNextTile:addEventListener("touch", testGameEnd)
	changeNextTilePowerImage = director:createSprite({
		x = offSet.changeNextTile.x + changeNextTile.w * graphicsScale * powerIconScale,
		y = offSet.changeNextTile.y+ changeNextTile.h * graphicsScale * powerIconScale,
		source = "textures/noti.png",
		xScale = graphicsScale * powerCountImageScale,
		yScale = graphicsScale * powerCountImageScale,
		xAnchor = 0.66,
		yAnchor = 0.66,
		zOrder  = 1,
		})

	changeNextTilePower = director:createLabel(changeNextTile.x + offSet.changeNextTile.w, changeNextTile.y + offSet.changeNextTile.h - 24 * graphicsScale, "0" )
	changeNextTilePower.textXScale = fontScale * powerFontFactor
	changeNextTilePower.textYScale = fontScale * powerFontFactor
	-- changeNextTilePower.color = {160, 80, 140} -- {107, 7, 144} 
	setPowerCountPos(changeNextTilePower,0,offSet.changeNextTile.x + offSet.changeNextTile.w)
	changeNextTilePower.zOrder = 2
	
	
	
	tileBreak = director:createSprite(offSet.tileBreak.x, offSet.tileBreak.y, "textures/tilebreak.png")
	tileBreak.xScale = graphicsScale * powerIconScale
	tileBreak.yScale = graphicsScale * powerIconScale
	-- tileBreak:addEventListener("touch", tileBreakTouch)
	-- tileBreak.isVisible = false
	tileBreakPowerImage = director:createSprite({
		x = offSet.tileBreak.x + tileBreak.w * graphicsScale * powerIconScale,
		y = offSet.tileBreak.y+ tileBreak.h * graphicsScale * powerIconScale,
		source = "textures/noti.png",
		xScale = graphicsScale * powerCountImageScale,
		yScale = graphicsScale * powerCountImageScale,
		xAnchor = 0.66,
		yAnchor = 0.66,
		zOrder  = 1,
		})
	-- tileBreakPowerImage.isVisible =false
	-- 1 digit 15 20 22 10-19 19
	tileBreakPower = director:createLabel(tileBreak.x + offSet.tileBreak.w, tileBreak.y + offSet.tileBreak.h - 24 *graphicsScale , "0")
	tileBreakPower.textXScale = fontScale * powerFontFactor
	tileBreakPower.textYScale = fontScale * powerFontFactor
	setPowerCountPos(tileBreakPower,0,offSet.tileBreak.x + offSet.tileBreak.w)
	-- tileBreakPower.xAnchor = 0.1
	-- tileBreakPower.yAnchor = 0.1
	-- tileBreakPower.color = changeNextTilePower.color
	tileBreakPower.zOrder = 2

	swapTile = director:createSprite(offSet.swap.x, offSet.swap.y , "textures/swap.png")
	swapTile.xScale = graphicsScale * powerIconScale
	swapTile.yScale = graphicsScale * powerIconScale

	-- swapTile.isVisible = false
	-- swapTile:addEventListener("touch",swapTileTouch)

	swapPowerImage = director:createSprite({
		x = offSet.swap.x + swapTile.w * graphicsScale * powerIconScale,
		y = offSet.swap.y+ swapTile.h * graphicsScale * powerIconScale,
		source = "textures/noti.png",
		xScale = graphicsScale * powerCountImageScale,
		yScale = graphicsScale * powerCountImageScale,
		xAnchor = 0.66,
		yAnchor = 0.66,
		zOrder  = 1,
		})

	swapTilePower = director:createLabel(swapTile.x + offSet.swap.w , swapTile.y +offSet.swap.h - 24 * graphicsScale,"0")
	swapTilePower.textXScale = fontScale * powerFontFactor
	swapTilePower.textYScale = fontScale * powerFontFactor
	-- swapTilePower.color = changeNextTilePower.color
	setPowerCountPos(swapTilePower,0,offSet.swap.x + offSet.swap.w)
	swapTilePower.zOrder = 2

	-- touchLabel = director:createLabel({
	-- 	x = director.displayCenterX,
	-- 	y = director.displayCenterY,
	-- 	text = "0, 0",
	-- 	textXScale = fontScale * powerFontFactor,
	-- 	textYScale = fontScale * powerFontFactor
	-- 	})

	-- highScoreLabel = director:createLabel(offSet.highScore.x, offSet.highScore.y, "0")


	background:addEventListener("touch", gameSceneTouch)

	glowRectangle = director:createRectangle({
	    x = 0, y = 0,
	    -- xAnchor=0.5, yAnchor=0.5, -- x, y now specify the centre
	    w = 10 , h = 10,
	    strokeWidth=3, strokeColor = {255, 255, 255}, strokeAlpha=1,
	    alpha = 0
    } )
	glowRectangle.isVisible = false

	glowTileRectangle = director:createRectangle({
	    x = 0, y = 0,
	    -- xAnchor=0.5, yAnchor=0.5, -- x, y now specify the centre
	    w = 10 , h = 10,
	    strokeWidth=3, strokeColor= {255, 255, 255}, strokeAlpha=1,
	    alpha=0
    } )
	glowTileRectangle.isVisible = false

	
	

end
function enterPre()
	isNewGame()
	tileBreakPower.text = tostring(gridGame.tileBreakCount)
	-- print("enterpre  ",gridGame.tileBreakCount,offSet.tileBreak.x + offSet.tileBreak.w)
	setPowerCountPos(tileBreakPower,gridGame.tileBreakCount,offSet.tileBreak.x + offSet.tileBreak.w)
	swapTilePower.text = tostring(gridGame.swapTileCount)
	setPowerCountPos(swapTilePower,gridGame.swapTileCount,offSet.swap.x + offSet.swap.w)
	changeNextTilePower.text = tostring(gridGame.changeNextTileCount)
	setPowerCountPos(changeNextTilePower,gridGame.changeNextTileCount,offSet.changeNextTile.x + offSet.changeNextTile.w)
	if (adverts.enabled == true) then
		    adverts:visibility(true)
	end
end


function  isNewGame()
	if newGame == true then
		newGame = false
		restartGame()
	end
end
function restartGame()
	changeGameState(gameStates.playing)
	scoreLabel.text = "0"
	collectgarbage("collect")
	director:cleanupTextures()
	-- gameEndLabel.text = "Status"
 	gridGame:reMakeGrid()
end

function initAudio()
	-- Preload sound effects
	audio:loadStream("audio/h2o.mp3")
-- 	audio:loadSound("audio/gem_destroyed.raw")

end


function optionsTouch(event)
	if event.phase == "ended" then
		switchToScene("pause")
	end
end
function  gameSceneTouch(event)


	if (event.phase == "began") then
		-- touchLabel.text = "began "..tostring(event.x)..", "..tostring(event.y)
		touchX = event.x
		touchY = event.y
		touchMoved = false
		-- print("touched event began\n")
	end
	if (event.phase == "moved") then
		-- touchLabel.text = "moved "..tostring(event.x)..", "..tostring(event.y)
		touchMoved = true
		-- print("touched event moved\n")
	end
	if (event.phase == "ended" ) then
		if checkClick(event, touchX, touchY) == true  then
			touchMoved = false
		end
		if ( touchMoved == true and gameState == gameStates.playing ) then -- if swipe was Done
			
			changeGameState(gameStates.gameProcessing)
			gridGame:swipeMade(event, touchX, touchY)
			if gridGame.moveAvailable == false then
				-- gameEndLabel.text = "Game End"
				changeGameState(gameStates.gameEnded)
				gameEndScreen()
			else 
				changeGameState(gameStates.playing)
			end
			return
		elseif touchMoved == true and gameState ~= gameStates.gameEnded and gameState ~= gameStates.playing then
			changeGameState(gameStates.playing)
			return
		end
		if touchMoved == false then
			if gameState == gameStates.playing then -- touch was made
					-- touchLabel.text = "ended  "..tostring(event.x)..", "..tostring(event.y)
					-- check which power/sprite/tile was touched
					if whichPowerSelected(event) == false then
					end
					
					isOptionsTouched(event)
					-- changeGameState(gameStates.playing)
			elseif  gameState == gameStates.tileBreakSelected then -- touch was made
					-- check which power/sprite/tile was touched
					tileBreakTile = whichTileSelected(event)
					if tileBreakTile ~= wrongCoord and gridGame.presentTiles > 1 then
						gridGame:tileBreak(tileBreakTile)
						gridGame.presentTiles = gridGame.presentTiles - 1
						gridGame.tileBreakCount = gridGame.tileBreakCount -1
						gridGame:setTileBreakCount(gridGame.tileBreakCount)
						tileBreakPower.text = tostring(gridGame.tileBreakCount)
						gridGame.tbUsed = gridGame.tbUsed + 1
						setPowerCountPos(tileBreakPower,gridGame.tileBreakCount,offSet.tileBreak.x + offSet.tileBreak.w)
						-- hideGlow()
					end
					changeGameState(gameStates.playing)
			elseif  gameState == gameStates.swapSelected then -- touch was made
					-- check which power/sprite/tile was touched
					swapFirstTile = whichTileSelected(event)
					if swapFirstTile ~= wrongCoord and gridGame.gemsGrid[swapFirstTile[1]][swapFirstTile[2]] ~= nil then
						glowTile({ gridGame.gemsGrid[swapFirstTile[1]][swapFirstTile[2]].sprite.x, 
											gridGame.gemsGrid[swapFirstTile[1]][swapFirstTile[2]].sprite.y,
											tile.actualWidth * graphicsScale,
											tile.actualHeight * graphicsScale })
						changeGameState(gameStates.swapFirstTileSelected)
					else
						changeGameState(gameStates.playing)
					end
			elseif gameState == gameStates.swapFirstTileSelected then -- touch was made
					-- check which power/sprite/tile was touched
					swapSecondTile = whichTileSelected(event)
					if  math.abs(swapSecondTile[1] - swapFirstTile[1]) + math.abs(swapSecondTile[2] - swapFirstTile[2])  == 1 then
						if swapSecondTile ~= wrongCoord and gridGame.gemsGrid[swapSecondTile[1]][swapSecondTile[2]] ~= nil then
							gridGame:swapTiles(swapFirstTile, swapSecondTile)
							gridGame.swapTileCount = gridGame.swapTileCount -1
							gridGame:setSwapTileCount(gridGame.swapTileCount)
							swapTilePower.text = tostring(gridGame.swapTileCount)
							gridGame.swapUsed = gridGame.swapUsed + 1
							setPowerCountPos(swapTilePower,gridGame.swapTileCount,offSet.swap.x + offSet.swap.w)
						end
					end
					changeGameState(gameStates.playing)
			end
		end
		touchMoved = false
	end
	
end



 function changeNextTileTouch(event)
 	if event.phase == "ended" then
	 	if gridGame.changeNextTileCount > 0 then
			gridGame:changeNextTile("power")
			changeNextTilePower.text = tostring(gridGame.changeNextTileCount)
			setPowerCountPos(changeNextTilePower,gridGame.changeNextTileCount,offSet.changeNextTile.x + offSet.changeNextTile.w)
		end
	end
 end

 function tileBreakTouch(event)
 	if event.phase == "ended" then
	 	if gridGame.tileBreakCount > 0 then
	 		glowPower({offSet.tileBreak.x, offSet.tileBreak.y, offSet.tileBreak.w, offSet.tileBreak.h})
			changeGameState(gameStates.tileBreakSelected)
		end
	end
 end

 function swapTileTouch(event)
 	if event.phase == "ended" then
	 	if gridGame.swapTileCount > 0 then
	 		glowPower({offSet.swap.x, offSet.swap.y, offSet.swap.w, offSet.swap.h})
			changeGameState(gameStates.swapSelected)
		end
	end
 end

 function changeGameState(game_state)
	gameState = game_state
	-- print("Changing Game State to ",game_state)
	if gameState == gameStates.playing then
		hidePowerGlow()
		hideTileGlow()
	elseif (gameState == gameStates.tileBreakSelected) then
		-- Hide selector
		
	elseif (gameState == gameStates.swapSelected) then
		
		
	elseif (gameState == gameStates.swapFirstTileSelected) then
		-- Hide selector
		
	end
end


function whichTileSelected(event)
	gridOffsetX = director.displayCenterX -  (tileCountX * tile.actualWidth * graphicsScale) / 2
	gridOffsetY = director.displayCenterY - (tileCountY * tile.actualHeight * graphicsScale) / 2
	local x, y = event.x, event.y
	if x < gridOffsetX or x > gridOffsetX + tileCountX * tile.actualWidth * graphicsScale or y < gridOffsetY or y > gridOffsetY + tileCountY * tile.actualHeight * graphicsScale then
		return wrongCoord
	end
	local a = math.floor( (x - gridOffsetX) / (tile.actualWidth*graphicsScale) ) + 1
	local b = math.floor( (y - gridOffsetY) / (tile.actualHeight*graphicsScale) ) + 1
	-- print(a, b)
	return {a, b}
end


function whichPowerSelected(event)
	local x, y = event.x, event.y
	if insideRectangle(x, y, offSet.tileBreak.x, offSet.tileBreak.y, offSet.tileBreak.w, offSet.tileBreak.h) then
		tileBreakTouch(event)
		-- print("tileBreak")
		return true
	end
	if insideRectangle(x, y, offSet.swap.x, offSet.swap.y, offSet.swap.w, offSet.swap.h) then
		swapTileTouch(event)
		-- print("swap")
		return true
	end
	if insideRectangle(x, y, offSet.changeNextTile.x, offSet.changeNextTile.y, offSet.changeNextTile.w, offSet.changeNextTile.h) then
		changeNextTileTouch(event)
		-- print("changeNextTile")
		return true
	end
	return false
end
function  isOptionsTouched(event)
	local x, y = event.x, event.y
	-- print(x, y, offSet.options.x, offSet.options.y, offSet.options.w, offSet.options.h)
	-- touchLabel.text = tostring(event.x)..", "..tostring(event.y).."\n"..tostring(math.floor(options.x))..", "..tostring(math.floor(options.y))
	if insideRectangle(event.x, event.y, math.floor(options.x), math.floor(options.y), offSet.options.w, offSet.options.h) then
		optionsTouch(event)
		-- print("optionsTouch")
		return true
	end
	return false
end
function insideRectangle(i, j, x, y, w, h)
	-- print(i, j, x, x+w, y, y+h, w, h)
	-- touchLabel.text = tostring(i)..": "..tostring(j)..": "..tostring(x)..": "..tostring(x+w)..": "..tostring(y)..": "..tostring(y+h)
	-- print(touchLabel.text)
	if i < x or i > x + w or j < y or j > y + h then
		return false
	end
	return true
end


function glowPower(coordinates)

		-- print("inglow")
		-- print(coordinates[1], coordinates[2], coordinates[3], coordinates[4])
	    glowRectangle.x = coordinates[1]
	    glowRectangle.y = coordinates[2]
	    glowRectangle.w = coordinates[3]
	    glowRectangle.h = coordinates[4]
	    glowRectangle.isVisible = true
end

function hidePowerGlow()
	glowRectangle.isVisible = false
end

function glowTile(coordinates)

		-- print("inTileglow")
		-- print(coordinates[1], coordinates[2], coordinates[3], coordinates[4])
	    glowTileRectangle.x = coordinates[1]
	    glowTileRectangle.y = coordinates[2]
	    glowTileRectangle.w = coordinates[3]
	    glowTileRectangle.h = coordinates[4]
	    glowTileRectangle.isVisible = true
end

function hideTileGlow()
	glowTileRectangle.isVisible = false
end

function getHighScore()
 	return db:getValue("highScore")
end

function getTokens()
 	return db:getValue("tokens")
end

function getTileBreakCount()
 	return db:getValue("tileBreak")
end

function gameEndScoreLabelInit()
	gameEndScoreLabel = {}
	local x, y = 0, 0
	for i = 1, gridGame.width do
		gameEndScoreLabel[i] = {}
		for j = 1, gridGame.height do
			local coord = gridGame:getTilePosition(i, j)
			x = coord[1] + tile.actualWidth * game.graphicsScale/ 2
			y = coord[2] + tile.actualHeight * game.graphicsScale / 2
				
			gameEndScoreLabel[i][j] = director:createLabel({
					x = x,
					y=  y,
					text = "+",
					textXScale = game.fontScale, 
					textYScale = game.fontScale 
					})
			gameEndScoreLabel[i][j].isVisible = false
			gameEndScoreLabel[i][j].zOrder = 1
		end
	end
end

function gameEndScreen()
	-- if event.phase ~= "ended" then return end
	remainingTilesScore = 0
	
	
	for i = 1, gridGame.width do
		for j = 1, gridGame.height do
			if gridGame.gemsGrid[i][j] ~= nil then
				remainingTilesScore = remainingTilesScore + gridGame.gemsGrid[i][j].number
				gameEndScoreLabel[i][j].text = "+"..tostring(gridGame.gemsGrid[i][j].number)
				gameEndScoreLabel[i][j].isVisible = true
				tween:to(gameEndScoreLabel[i][j], {x = gameEndScoreLabel[i][j].x, y = gameEndScoreLabel[i][j].y + tile.actualHeight * game.graphicsScale/ 2, time = 0.8} )
				-- tween:to(gameEndScoreLabel[i][j], {alpha=0, delay=0.8, time = 0.1} )
			end
		end
	end
	
	gridGame.score = gridGame.score + remainingTilesScore
	-- scoreLabel.text = tostring(gridGame.score)
	gridGame:addScoreAnimate(remainingTilesScore)
	if gridGame.score > gridGame.highScore then
			gridGame.highScore = gridGame.score
			gridGame:setHighScore(gridGame.score)
	end
	tween:to(gameScene, {alpha = 1 ,delay = 1, time = 0, onComplete=switchToGameEnd})
end

function switchToGameEnd()
	local x, y = 0, 0
	for i = 1, gridGame.width do
		for j = 1, gridGame.height do
			local coord = gridGame:getTilePosition(i, j)
			x = coord[1] + tile.actualWidth * game.graphicsScale/ 2
			y = coord[2] + tile.actualHeight * game.graphicsScale / 2
			gameEndScoreLabel[i][j].x = x
			gameEndScoreLabel[i][j].y = y
			gameEndScoreLabel[i][j].isVisible = false
		end
	end
	totalGamesEnded = totalGamesEnded + 1
	switchToScene("gameEnd")
end

function keyPressed(event)
	if event.phase == "released" then
		if event.keyCode == key.back then
			switchToScene("pause")
		end
	end
end

-- function testGameEnd(event)
-- 	print("here")
-- 	gameEndScreen(event)
-- end

function buttonPressed(button, event)
	if event.phase == "began" then
		button.alpha = 0.5
		system:addTimer({timer=showButton,obj=button},0.5, 1, 0)
	elseif event.phase == "ended" then
		-- print("QUICK MYdebug: ended")
		button.alpha = 1
		-- print("QUICK MYdebug:")
	end
end

function showButton(param)
	-- print("QUICK MYdebug: showbutton alpha 1")
	param.obj.alpha = 1
	-- print("QUICK MYdebug: showbutton alpha 1 end")
end

function setPowerCountPos(obj,newCount,OrigPosition)
	-- 1 digit = 15 , >20 = 22 ,10-19 19
	-- print(obj, newCount, OrigPosition)
	if newCount < 10 then
		obj.x = OrigPosition - 15 * graphicsScale
	elseif newCount < 20 then
		obj.x = OrigPosition - 19 * graphicsScale
	else
		obj.x = OrigPosition - 21 * graphicsScale
	end
	-- print(obj.x)
end

function checkClick(event, touchX, touchY)
		dx = event.x - touchX
		dy = event.y - touchY
		-- print(dx, dy)
		-- print("Quick Mydebug: dx ", math.abs(dx)," dy ", math.abs(dy))
		if math.abs(dx) < 20 * graphicsScale and math.abs(dy) < 20 * graphicsScale then
			-- print("Quick Mydebug: dx dy", math.abs(dx), math.abs(dy))
			return true
		end
		return false
end