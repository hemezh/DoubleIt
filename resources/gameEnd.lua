--[[
User interface
--]]

module(..., package.seeall)

-- Globals
gameEndScene = nil
local oldScore = 0
local tweenObj = nil

-- Create and initialise the main menu
function init()
	-- Create a scene to contain the main menu
	gameEndScene = director:createScene()
	gameEndScene:addEventListener("enterPreTransition", enterGameEndScene)
	gameEndScene:addEventListener("enterPostTransition", enterPostGameEndScene)
	-- gameEndScene:addEventListener("exitPostTransition", exitGameEnd)

	gameEndScene:addEventListener("key",keyPressed)

	
	-- Create  background
	local background = director:createSprite(director.displayCenterX, director.displayCenterY, "textures/bg.png")
	background.xAnchor = 0.5
	background.yAnchor = 0.5
	-- Fit background to screen size
	local bg_width, bg_height = background:getAtlas():getTextureSize()
	background.xScale = director.displayWidth / bg_width
	background.yScale = director.displayHeight / bg_height

	
	gameEndNewGame = director:createSprite(director.displayCenterX, director.displayHeight / 2, "textures/newgame.png")
	local ng_width, ng_height = gameEndNewGame:getAtlas():getTextureSize()
	gameEndNewGame.y = gameEndNewGame.y - (ng_height) * game.graphicsScale
	-- print("y of gameEnd newGame", gameEndNewGame.y)
	gameEndNewGame.xAnchor = 0.5
	gameEndNewGame.xScale = game.graphicsScale
	gameEndNewGame.yScale = game.graphicsScale
	gameEndNewGame:addEventListener("touch", newGameTouch)

	

	gameEndShop_y = gameEndNewGame.y - ( (ng_height + 30)  * game.graphicsScale) -- Assuming that both are of same height
	-- print("y of gameEnd SHop", gameEndShop_y)
	gameEndShop = director:createSprite(director.displayCenterX, gameEndShop_y, "textures/shop.png")
	gameEndShop.xAnchor = 0.5
	gameEndShop.xScale = game.graphicsScale
	gameEndShop.yScale = game.graphicsScale
	gameEndShop:addEventListener("touch",gameEndShopTouch)

	twShare = director:createSprite( director.displayCenterX, gameEndNewGame.y + (ng_height + 30) * game.graphicsScale, "textures/tw.png")
	-- twShare.xAnchor = 0.5
	twShare.xScale = game.graphicsScale * 0.35
	twShare.yScale = game.graphicsScale * 0.35
	twShare:addEventListener("touch",twShareTouch)

	-- tokensLabel = director:createLabel(director.displayWidth/2, director.displayHeight - 250 * game.graphicsScale, tostring(game.gridGame.score))
	shareLabel = director:createLabel({
	x =  director.displayCenterX, -- twShare.w/2 * game.graphicsScale * 0.35,
	y =  twShare.y,
	text = "Share ",
	-- hAlignment = "center",
	textXScale = game.fontScale, 
	textYScale = game.fontScale
	})
	shareLabel.x = shareLabel.x - shareLabel.wText  - 20 * game.graphicsScale
	
	--+ twShare.w/2 * game.graphicsScale * 0.35

	fbShare = director:createSprite( director.displayCenterX + twShare.w * game.graphicsScale * 0.35 + 30*game.graphicsScale, twShare.y, "textures/fb.png")
	fbShare.xScale = game.graphicsScale * 0.35
	fbShare.yScale = game.graphicsScale * 0.35
	fbShare:addEventListener("touch",fbShareTouch)

	ifSharedLabel = director:createLabel({
		x = fbShare.x + fbShare.w * game.graphicsScale * 0.35 + 20 * game.graphicsScale,
		y = shareLabel.y,
		text = "Successfully‎ Shared!",
		-- hAlignment = "center",
		textXScale = game.fontScale * 0.50, 
		textYScale = game.fontScale * 0.50,
		color = {246, 205, 89}
		})
	ifSharedLabel.isVisible = false

	currentHighScoreLabel = director:createLabel({
		x = 0,
		hAlignment = "center",
		y = shareLabel.y + 30  * game.graphicsScale + game.actualFontHeight,
		text = "Highscore: "..tostring(game.gridGame.score),
		textXScale = game.fontScale, 
		textYScale = game.fontScale,
		color = {246, 205, 89} --{215,165,56}
		})

	scoreLabel = director:createLabel({
		x = 0, 
		y = currentHighScoreLabel.y + 30  * game.graphicsScale + game.actualFontHeight ,
		text = tostring(game.gridGame.score),
		-- hAlignment = "center",
		textXScale = game.fontScale,
		textYScale = game.fontScale
		})
		scoreLabel.x = director.displayWidth/2 - scoreLabel.wText/2
		
	gameEndLabel = director:createLabel({
		x = 0, 
		y = scoreLabel.y +  30 * game.graphicsScale + game.actualFontHeight,
		text = "No More Moves",
		hAlignment = "center",
		textXScale = game.fontScale, 
		textYScale = game.fontScale
	})

	tokensGameEndLabel = director:createLabel({
		x = director.displayWidth - 20 * game.graphicsScale,
		y = director.displayHeight - (50) * game.graphicsScale,
		text = tostring(game:getTokens()),
		textXScale = game.fontScale, 
		textYScale = game.fontScale 
		})
	tokensGameEndLabel.x = tokensGameEndLabel.x - tokensGameEndLabel.wText
	tokensGameEndLabel.y = tokensGameEndLabel.y - tokensGameEndLabel.hText/2
	
	tokenImageGameEnd = director:createSprite({
		x = tokensGameEndLabel.x - (10 + 50) * game.graphicsScale,
		y = director.displayHeight - (50) * game.graphicsScale,
		yAnchor = 0.5,
		xScale = game.graphicsScale,
		yScale = game.graphicsScale,
		source = "textures/coin.png"
		})

	
	-- print(scoreLabel.x, scoreLabel.wText)

	earnedTokensLabel = director:createLabel({
		x = scoreLabel.x, 
		y = scoreLabel.y,
		text = "+"..tostring(getTokensEarned()),
		-- hAlignment = "center",
		textXScale = game.fontScale, 
		textYScale = game.fontScale
		})
	earnedTokensLabel.isVisible = false




	loadAd = director:createSprite({
		x = director.displayCenterX,
		y = director.displayCenterY,
		xAnchor = 0.5,
		yAnchor = 0.5,
		source = "/textures/loader.png",
		xScale = game.graphicsScale,
		yScale = game.graphicsScale
		})
	loadAd.isVisible = false
end

-- function exitGameEnd(event)
-- 	-- print("ouououououuu")	
	
-- end
function showIntAd()
	if oldScore > 0 then
		-- print("Quick Mydebug: adsadsadasdasd")
		if  game.inmobiAd:isAvailable() == true then
			loadAd.isVisible = true
			-- print("Quick Mydebug: ijijijijijijij")
			game.inmobiAd:interstitialAd()
		end
	end
end
function twShareTouch(event)
	if (event.phase == "ended") then
		game.stats:logEvent("Twitter Share on Game End Touched",nil)
        local message = game.social:shareMessage("tw")
        browser:launchURL(message)
    end
end

function fbShareTouch(event)
	if (event.phase == "ended") then
		game.stats:logEvent("Fb Share on Game End Touched",nil)
        game.social:postScoreUpdate(game.gridGame.score)
    end
end
function newGameTouch(event)
	game.buttonPressed(gameEndNewGame, event)
	if event.phase == "ended" then
		showIntAd()
		game.newGame = true
		tweenObj = tween:to(loadAd,{rotation=270, time=1.5, onComplete=goNewGame})
	end
end
function goNewGame()
	-- print("Quick Mydebug: switch scene rotation"..tostring(loadAd.rotation))
	game.stats:logEvent("New Game from GameEnd",nil)
	switchToScene("gameFromPause")
end
function gameEndShopTouch(event)
	game.buttonPressed(gameEndShop, event)
	if(event.phase == "ended") then
		showIntAd()
		game.storeFrom = "gameEnd"
		tweenObj = tween:to(loadAd,{rotation=270, time=1, onComplete=goStore})
	end
end
function goStore()
	-- print("Quick Mydebug: switch scene rotation"..tostring(loadAd.rotation))
	game.stats:logEvent("Store From GameEnd",nil)
	switchToScene("store")
end

function enterGameEndScene(event)
	-- if (game.adverts.enabled == true) then
	-- 	    game.adverts:visibility(true)
	-- end
	if tweenObj ~= nil then
		tween:cancel(tweenObj)
		tweenObj = nil
	end
	loadAd.isVisible = false
	loadAd.rotation = 0
	-- print("Quick Mydebug: "..tostring(loadAd.rotation))
	scoreLabel.text = tostring(game.gridGame.score)
	-- scoreLabel.hAlignment = "center"
	scoreLabel.x = director.displayWidth/2 - scoreLabel.wText/2


	ifSharedLabel.isVisible = false

	tokensGameEndLabel.text = tostring(game:getTokens())
	oldScore = game.gridGame.score
	local high = 0
	if game.gridGame.score ~= game.gridGame.highScore then
		currentHighScoreLabel.color =  {246, 205, 89} --{215,165,56}
		currentHighScoreLabel.text = "Highscore: "..tostring(game.gridGame.highScore)
		currentHighScoreLabel.hAlignment = "center"
		high = 0
	else
		currentHighScoreLabel.color = {246, 205, 89}  --{215,165,56}
		currentHighScoreLabel.text = "New Highscore!!!"
		currentHighScoreLabel.hAlignment = "center"
		high = 1
	end

	game.gridGame.tokens = game.gridGame.tokens + getTokensEarned()
	game.gridGame.db:addValue("tokens",getTokensEarned())
	
	-- if game.social.available == false then
	-- 	shareLabel.isVisible.text = ""
	-- 	fbShare.isVisible = false
	-- else
	-- 	shareLabel.isVisible.text = "Share "
	-- 	fbShare.isVisible = true
	-- end

	game.stats:logEvent("Game End Stats",{
		score = scoreLabel.text,
		tokensEarned = tostring(getTokensEarned()),
		isHighScore = high,
		tbUsed = game.gridGame.tbUsed,
		swapUsed = game.gridGame.swapUsed,
		cntUsed = game.gridGame.cntUsed,
		})
end

function getTokensEarned()
	return math.floor(game.gridGame.score/100)
end



function enterPostGameEndScene(event)
	if getTokensEarned() > 0 then
		-- earnedTokensLabel.isVisible = true
		earnedTokensLabel.text = "+"..tostring(getTokensEarned())
		earnedTokensLabel.x = scoreLabel.x
		earnedTokensLabel.y = scoreLabel.y
		earnedTokensLabel.isVisible = true
		tween:to(earnedTokensLabel,{x = tokensGameEndLabel.x, y = tokensGameEndLabel.y, time = 1.5, onComplete = updateTokensLabel})
	end
end

function updateTokensLabel()
	tokensGameEndLabel.text = tostring(game:getTokens())
	earnedTokensLabel.x = scoreLabel.x
	earnedTokensLabel.y = scoreLabel.y
	earnedTokensLabel.isVisible = false
	-- earnedTokensLabel.hAlignment = "center"
end

function keyPressed(event)
	if event.phase == "released" then
		if event.keyCode == key.back then
			game.newGame = true
			switchToScene("gameFromPause")
		end
	end
end