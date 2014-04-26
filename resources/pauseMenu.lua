--[[
User interface
--]]

module(..., package.seeall)

-- Globals
pauseScene = nil


-- Create and initialise the main menu
function init()
	-- Create a scene to contain the main menu
	pauseScene = director:createScene()
	pauseScene:addEventListener("enterPreTransition", enterPauseScene)
	pauseScene:addEventListener("key",keyPressed)
	
	-- Create  background
	local background = director:createSprite(director.displayCenterX, director.displayCenterY, "textures/bg.png")
	background.xAnchor = 0.5
	background.yAnchor = 0.5
	-- Fit background to screen size
	local bg_width, bg_height = background:getAtlas():getTextureSize()
	background.xScale = director.displayWidth / bg_width
	background.yScale = director.displayHeight / bg_height

	
	newGame = director:createSprite(director.displayCenterX, director.displayHeight / 2, "textures/newgame.png")
	local ng_width, ng_height = newGame:getAtlas():getTextureSize()
	newGame.xAnchor = 0.5
	newGame.xScale = game.graphicsScale
	newGame.yScale = game.graphicsScale
	newGame:addEventListener("touch", newGameTouch)

	resume_y = newGame.y + ( (ng_height + 40)  * game.graphicsScale)
	resume = director:createSprite(director.displayCenterX, resume_y , "textures/resume.png")
	resume.xAnchor = 0.5
	resume.xScale = game.graphicsScale
	resume.yScale = game.graphicsScale
	resume:addEventListener("touch", resumeTouch)


	currentScoreLabel = director:createLabel({
		x = 0,
		hAlignment = "center",
		y = resume_y + (ng_height + 70) * game.graphicsScale,
		text = "Score: "..tostring(game.gridGame.score),
		textXScale = game.fontScale, 
		textYScale = game.fontScale
		})

	gamePausedLabel = director:createLabel({
		x = 0,
		hAlignment = "center",
		y = currentScoreLabel.y + 30 * game.graphicsScale +  game.actualFontHeight,
		text = "Game Paused",
		textXScale = game.fontScale, 
		textYScale = game.fontScale
		})

	pauseShop_y = newGame.y - ( (ng_height + 40)  * game.graphicsScale)
	pauseShop = director:createSprite(director.displayCenterX, pauseShop_y, "textures/shop.png")
	pauseShop.xAnchor = 0.5
	pauseShop.xScale = game.graphicsScale
	pauseShop.yScale = game.graphicsScale
	pauseShop:addEventListener("touch",storeTouch)

	local home_y = pauseShop.y -  (40 + ng_height)  * game.graphicsScale  -- Assuming Shop and leaderboard of same sizes
	home = director:createSprite(director.displayCenterX, home_y, "textures/home.png")
	home.xAnchor = 0.5
	home.xScale = game.graphicsScale
	home.yScale = game.graphicsScale
	home:addEventListener("touch",homeTouch)

	local starFactor = 0.25

	pauseSoundon = director:createSprite(director.displayWidth - 20 * game.graphicsScale, director.displayHeight - 20*game.graphicsScale, "textures/soundon.png")
	pauseSoundon.xScale = game.graphicsScale * starFactor * 2
	pauseSoundon.yScale = game.graphicsScale * starFactor * 2
	pauseSoundon:addEventListener("touch",pauseSoundonTouch)
	
	pauseSoundon.x = pauseSoundon.x - pauseSoundon.w * game.graphicsScale * starFactor * 2
	pauseSoundon.y = pauseSoundon.y - pauseSoundon.h * game.graphicsScale * starFactor * 2


	pauseSoundoff = director:createSprite(director.displayWidth - 20 * game.graphicsScale, director.displayHeight - 20*game.graphicsScale, "textures/soundoff.png")
	pauseSoundoff.xScale = game.graphicsScale * starFactor * 2  
	pauseSoundoff.yScale = game.graphicsScale * starFactor * 2 
	pauseSoundoff:addEventListener("touch",pauseSoundoffTouch)

	pauseSoundoff.x = pauseSoundoff.x - pauseSoundoff.w * game.graphicsScale * starFactor * 2
	pauseSoundoff.y = pauseSoundoff.y - pauseSoundoff.h * game.graphicsScale * starFactor * 2


	-- Start menu music
	-- audio:playStream("audio/frontend.mp3", true)
end

function enterPauseScene( event )
	currentScoreLabel.text = "Score: "..tostring(game.gridGame.score)
	currentScoreLabel.hAlignment = "center"
	if game.db:getValue("sound") == 1 then
		-- print("Mydebug: Soundoff isVisible false")
		pauseSoundoff.isVisible = false 
		pauseSoundon.isVisible = true
		-- audio:playStream(bgstream, true)
	else
		-- print("Mydebug: Soundon isVisible false")
		pauseSoundon.isVisible = false
		pauseSoundoff.isVisible = true
	end
	-- if (game.adverts.enabled == true) then
	--     game.adverts:visibility(true)
	-- end
end
function resumeTouch(event)
	game.buttonPressed(resume, event)
	if(event.phase == "ended") then
		switchToScene("gameFromPause")
	end
end

function homeTouch(event)
	game.buttonPressed(home, event)
	if(event.phase == "ended") then
		game.newGame = true
		game.stats:logEvent("To Home From Pause",nil)
		switchToScene("home")
	end
end

function newGameTouch(event)		
	game.buttonPressed(newGame, event)
	if(event.phase == "ended") then
		game.newGame = true
		game.stats:logEvent("Game Restarted In Between",nil)
		switchToScene("gameFromPause")
	end
end

function storeTouch(event)
	game.buttonPressed(pauseShop, event)
	if(event.phase == "ended") then
		game.storeFrom = "pause"
		game.stats:logEvent("To Store From Pause",nil)
		switchToScene("store")
	end
end

function keyPressed(event)
	if event.phase == "released" then
		if event.keyCode == key.back then
			switchToScene("gameFromPause")
		end
	end
end

function pauseSoundonTouch(event)	
	if event.phase == "ended" then
		if game.db:getValue("sound") == 0 then 
			-- print("Mydebug: 1")
			return false
		end
		pauseSoundoff.isVisible = true
		pauseSoundon.isVisible = false
		-- print("sound on")
		audio:stopStream()
		game.stats:logEvent("Music Turned Off from Pause",nil)
		game.db:setValue("sound", 0)
		-- print("Mydebug: 2")
		return true
	end
	
end

function pauseSoundoffTouch(event)
	if event.phase == "ended" then
		-- print("Mydebug: 3")
		pauseSoundoff.isVisible = false
		pauseSoundon.isVisible = true
		-- print("Mydebug: "..mainMenu.bgstream)
		audio:playStream(mainMenu.bgstream, true)
		game.stats:logEvent("Music Turned On from Pause",nil)
		game.db:setValue("sound", 1)
	end
end