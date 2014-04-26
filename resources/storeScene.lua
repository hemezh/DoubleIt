--[[
User interface
--]]

module(..., package.seeall)

-- Globals
storeScene = nil
cost = {
	tb = 25,
	swap = 20,
	change = 10
}
spaceBetween = 50
coinToPowerScale = 1
local tweenD = 80
local tweenT = 0.5
-- Create and initialise the main menu
function init()
	-- Create a scene to contain the main menu
	storeScene = director:createScene()
	storeScene:addEventListener("enterPreTransition",enterStore)
	storeScene:addEventListener("key",keyPressed)
	
	-- Create  background
	local background = director:createSprite(director.displayCenterX, director.displayCenterY, "textures/bg.png")
	background.xAnchor = 0.5
	background.yAnchor = 0.5
	-- Fit background to screen size
	local bg_width, bg_height = background:getAtlas():getTextureSize()
	background.xScale = director.displayWidth / bg_width
	background.yScale = director.displayHeight / bg_height

	currentTokenCountLabelFactor = 1.5
	currentTokenCountLabel = director:createLabel({
		x = 0,
		y = director.displayCenterY + (20 + (70 + spaceBetween) * 3 + 30 ) * game.graphicsScale,
		text = getCurrentTokenMessage(),
		textXScale = game.fontScale * currentTokenCountLabelFactor, 
		textYScale = game.fontScale * currentTokenCountLabelFactor
		})
	 -- currentTokenCountLabel.x = director.displayWidth/2 - currentTokenCountLabel.wText/2 
	 currentTokenCountLabel.y = currentTokenCountLabel.y - currentTokenCountLabel.hText/2

	 totalWidthCurrentStats = (50) * game.graphicsScale*2.1 + currentTokenCountLabel.wText 
	-- print(director.displayCenterX - currentTokenCountLabel.wText / 2)
	--print("label width ", game.fontScale, director.displayCenterX , currentTokenCountLabel.wText/2, 50 , game.graphicsScale)
	-- print( currentTokenCountLabel.hText, game.fontScale)
	currentTokenCountCoins = director:createSprite(director.displayCenterX - totalWidthCurrentStats/2, director.displayCenterY + ( 20 + (70 + spaceBetween) * 3 + 30 ) * game.graphicsScale,"textures/coin.png")
	currentTokenCountCoins.yAnchor = 0.5
	currentTokenCountCoins.xScale = game.graphicsScale * 1.5
	currentTokenCountCoins.yScale = game.graphicsScale * 1.5

	currentTokenCountLabel.x = currentTokenCountCoins.x + currentTokenCountCoins.w * game.graphicsScale * 1.5

	minusCurrentTokenCountLabel = director:createLabel({
		x = currentTokenCountLabel.x,
		y = currentTokenCountLabel.y,
		text = "-",
		textXScale = game.fontScale * currentTokenCountLabelFactor, 
		textYScale = game.fontScale * currentTokenCountLabelFactor
		})
	minusCurrentTokenCountLabel.isVisible = false

	tbLabel = director:createLabel({
		x = 0,
		y = director.displayCenterY + (20 + 70 + spaceBetween + 70 + spaceBetween) * game.graphicsScale,
		text = getCostMessage(cost.tb),
		hAlignment = "center",
		textXScale = game.fontScale, 
		textYScale = game.fontScale
		})
	 tbLabel.y = tbLabel.y - tbLabel.hText/2
	
	tb = director:createSprite(director.displayCenterX - tbLabel.wText/2 - (70 + 70) * game.graphicsScale, director.displayCenterY + (20 + 70 + spaceBetween + 70 + spaceBetween) * game.graphicsScale,"textures/tilebreak.png")
	-- tb.xAnchor = 0.5
	tb.yAnchor = 0.5
	tb.xScale = game.graphicsScale * game.powerIconScale
	tb.yScale = game.graphicsScale * game.powerIconScale

	tbCountImage = director:createSprite({
		x = tb.x + tb.w * game.graphicsScale * game.powerIconScale,
		y = tb.y + tb.h/2 * game.graphicsScale * game.powerIconScale,
		source = "textures/noti.png",
		xScale = game.graphicsScale * game.powerCountImageScale,
		yScale = game.graphicsScale * game.powerCountImageScale,
		xAnchor = 0.66,
		yAnchor = 0.66,
		zOrder  = 1,
		})

	tbCount = director:createLabel({
		x = tb.x + (tb.w) * game.graphicsScale * game.powerIconScale,
		y = tb.y + tb.h/2 * game.graphicsScale * game.powerIconScale - 23 * game.graphicsScale,
		text = tostring(game.gridGame.tileBreakCount),
		textXScale = game.fontScale * game.powerFontFactor, 
		textYScale = game.fontScale * game.powerFontFactor,
		-- color = {246, 205, 89}
		zOrder = 2
		})
	setCountPos(tbCount,game.gridGame.tileBreakCount)

	tbCoins = director:createSprite(director.displayCenterX + tbLabel.wText/2 - 100 * game.graphicsScale, director.displayCenterY + (20 + 70 + spaceBetween + 70 + spaceBetween) * game.graphicsScale, "textures/coin.png")
	-- tbCoins.xAnchor = 0.5
	tbCoins.yAnchor = 0.5
	tbCoins.xScale = game.graphicsScale
	tbCoins.yScale = game.graphicsScale

	tbBuy = director:createSprite({
		x = director.displayCenterX + (tbLabel.wText/2) + (60) *game.graphicsScale,
		y = tb.y, 
		yAnchor = 0.5,
		source = "textures/buy.png",
		xScale = game.graphicsScale,
		yScale = game.graphicsScale
		})
	
	tbBuy:addEventListener("touch",buyTileBreak)

	swapLabel = director:createLabel({
		x = 0, --director.displayCenterX - tbLabel.wText/2,
		y = director.displayCenterY + (20 + 70 + spaceBetween) * game.graphicsScale, 
		text = getCostMessage(cost.swap),
		textXScale = game.fontScale, 
		textYScale = game.fontScale
		})
		swapLabel.hAlignment = "center"
		swapLabel.y = swapLabel.y - swapLabel.hText/2

	swapStore = director:createSprite(tb.x, director.displayCenterY + (20 + 70 + spaceBetween) * game.graphicsScale,"textures/swap.png")
	swapStore.yAnchor = 0.5
	-- tb.yAnchor = 0.5
	swapStore.xScale = game.graphicsScale * game.powerIconScale
	swapStore.yScale = game.graphicsScale * game.powerIconScale

	swapCountImage = director:createSprite({
		x = swapStore.x + swapStore.w * game.graphicsScale * game.powerIconScale,
		y = swapStore.y + swapStore.h/2 * game.graphicsScale * game.powerIconScale,
		source = "textures/noti.png",
		xScale = game.graphicsScale * game.powerCountImageScale,
		yScale = game.graphicsScale * game.powerCountImageScale,
		xAnchor = 0.66,
		yAnchor = 0.66,
		zOrder  = 1,
		})


	swapCount = director:createLabel({
		x = swapStore.x + (swapStore.w) * game.graphicsScale * game.powerIconScale,
		y = swapStore.y + swapStore.h/2 * game.graphicsScale * game.powerIconScale - 23 * game.graphicsScale,
		text = tostring(game.gridGame.swapTileCount),
		textXScale = game.fontScale * game.powerFontFactor, 
		textYScale = game.fontScale * game.powerFontFactor,
		-- color = {246, 205, 89}
		zOrder = 2
		})
	setCountPos(swapCount,game.gridGame.swapTileCount)

	swapCoins = director:createSprite(tbCoins.x, director.displayCenterY + (20 + 70 + spaceBetween) * game.graphicsScale,"textures/coin.png")
	-- swapCoins.xAnchor = 0.5
	swapCoins.yAnchor = 0.5
	swapCoins.xScale = game.graphicsScale*coinToPowerScale
	swapCoins.yScale = game.graphicsScale*coinToPowerScale

	swapBuy = director:createSprite({
		x = tbBuy.x,
		y = swapStore.y, 
		yAnchor = 0.5,
		source = "textures/buy.png",
		xScale = game.graphicsScale,
		yScale = game.graphicsScale
		})
	swapBuy:addEventListener("touch", buySwap)


	cntLabel = director:createLabel({
		x = 0, --director.displayCenterX - tbLabel.wText/2,
		y = director.displayCenterY + 20 *game.graphicsScale, 
		text = getCostMessage(cost.change),
		textXScale = game.fontScale, 
		textYScale = game.fontScale
		})
	cntLabel.hAlignment = "center"
	cntLabel.y = cntLabel.y - cntLabel.hText/2
	cntStore = director:createSprite(tb.x, director.displayCenterY + 20 *game.graphicsScale,"textures/change.png")
	cntStore.yAnchor = 0.5
	-- tb.yAnchor = 0.5
	cntStore.xScale = game.graphicsScale * game.powerIconScale
	cntStore.yScale = game.graphicsScale * game.powerIconScale

	swapCountImage = director:createSprite({
		x = cntStore.x + cntStore.w * game.graphicsScale * game.powerIconScale,
		y = cntStore.y + cntStore.h/2 * game.graphicsScale * game.powerIconScale,
		source = "textures/noti.png",
		xScale = game.graphicsScale * game.powerCountImageScale,
		yScale = game.graphicsScale * game.powerCountImageScale,
		xAnchor = 0.66,
		yAnchor = 0.66,
		zOrder  = 1,
		})

	cntCount = director:createLabel({
		x = cntStore.x + (cntStore.w) * game.graphicsScale * game.powerIconScale,
		y = cntStore.y + cntStore.h/2 * game.graphicsScale * game.powerIconScale - 24 * game.graphicsScale,
		text = tostring(game.gridGame.changeNextTileCount),
		textXScale = game.fontScale * game.powerFontFactor, 
		textYScale = game.fontScale * game.powerFontFactor,
		zOrder = 2
		-- color = tbCount.color
		})
	setCountPos(cntCount,game.gridGame.changeNextTileCount)

	cntCoins = director:createSprite(tbCoins.x, director.displayCenterY + 20 *game.graphicsScale, "textures/coin.png")
	-- cntCoins.xAnchor = 0.5
	cntCoins.yAnchor = 0.5
	cntCoins.xScale = game.graphicsScale*coinToPowerScale
	cntCoins.yScale = game.graphicsScale*coinToPowerScale


	cntBuy = director:createSprite({
		x = tbBuy.x,
		y = cntStore.y, 
		yAnchor = 0.5,
		source = "textures/buy.png",
		xScale = game.graphicsScale,
		yScale = game.graphicsScale
		})
	cntBuy:addEventListener("touch",buyCnt)


	back = director:createSprite(director.displayCenterX, director.displayHeight / 2 , "textures/back.png")
	local back_width, back_height = back:getAtlas():getTextureSize()
	back.y = director.displayHeight / 2 - ( ( 70 + back_height)  * game.graphicsScale)
	back.xAnchor = 0.5
	back.xScale = game.graphicsScale
	back.yScale = game.graphicsScale
	back:addEventListener("touch", backTouch)

	newGameStore = director:createSprite(director.displayCenterX, director.displayHeight / 2 , "textures/newgame.png")
	-- local back_width, back_height = back:getAtlas():getTextureSize()
	newGameStore.y = director.displayHeight / 2 - ( ( 70 + back_height)  * game.graphicsScale) -- back.y - ( (back_height + 50)  * game.graphicsScale)
	newGameStore.xAnchor = 0.5
	newGameStore.xScale = game.graphicsScale
	newGameStore.yScale = game.graphicsScale
	newGameStore:addEventListener("touch", newGameStoreTouch)

	-- buyCoins = director:createSprite(director.displayCenterX, director.displayHeight / 2 , "textures/buy.png")
	-- --local back_width, back_height = back:getAtlas():getTextureSize()
	-- buyCoins.y = back.y - ( back_height + 0)  * game.graphicsScale
	-- -- buyCoins.xAnchor = 0.5
	-- buyCoins.xScale = game.graphicsScale*coinToPowerScale
	-- buyCoins.yScale = game.graphicsScale*coinToPowerScale
	-- buyCoins:addEventListener("touch", buyCoinsTouch)

	buySomeCoins = director:createSprite({
		x = director.displayCenterX,
		xAnchor = 0.5,
		y = back.y - (back_height + 30) * game.graphicsScale,
		source = "textures/buy250.png",
		xScale = game.graphicsScale,
		yScale = game.graphicsScale
		})
	buySomeCoins:addEventListener("touch", buyCoinsTouch)

	if game.store.available == false then
		buySomeCoins.isVisible = false
	end

	-- buyCoinsLabel = director:createLabel({
	-- 	x = 0,
	-- 	hAlignment = "center",
	-- 	y = back.y - ( back_height/2)  * game.graphicsScale,
	-- 	text = "Buy 100",
	-- 	textXScale = game.fontScale, 
	-- 	textYScale = game.fontScale
	-- 	})
	-- buyCoinsLabel.y = buyCoinsLabel.y - buyCoinsLabel.hText/2 -- (70 + 20) * game.graphicsScale
	-- buyCoinsLabel:addEventListener("touch", buyCoinsTouch)

	-- buyCoinsSprite = director:createSprite(director.displayWidth/2 + buyCoinsLabel.wText/2 + 10 * game.graphicsScale, back.y - ( back_height/2)  * game.graphicsScale, "textures/coin.png")
	-- -- local back_width, back_height = back:getAtlas():getTextureSize()
	-- buyCoinsSprite.yAnchor = 0.5
	-- buyCoinsSprite.xScale = game.graphicsScale*coinToPowerScale
	-- buyCoinsSprite.yScale = game.graphicsScale*coinToPowerScale
	-- buyCoinsSprite:addEventListener("touch", buyCoinsTouch)

	-- buyCoins.isVisible = false
	-- buyCoinsLabel.isVisible = false
	-- buyCoinsSprite.isVisible = false
	
end
function enterStore(event)
	if game.storeFrom == "home" or game.storeFrom == "pause" then
		back.isVisible = true
		newGameStore.isVisible = false
	elseif game.storeFrom == "gameEnd" then
		back.isVisible = false
		newGameStore.isVisible = true
	end
	updateCurrentTokenLabel()
	tbCount.text = tostring(game.gridGame.tileBreakCount)
	setCountPos(tbCount,game.gridGame.tileBreakCount)
	swapCount.text = tostring(game.gridGame.swapTileCount)
	setCountPos(swapCount,game.gridGame.swapTileCount)
	cntCount.text = tostring(game.gridGame.changeNextTileCount)
	setCountPos(cntCount,game.gridGame.changeNextTileCount)
	-- if (game.adverts.enabled == true) then
	--     game.adverts:visibility(true)
	-- end
	game.stats:logEvent("Store Scene Entered",nil)
end

function exitStore(event)
	if (game.adverts.enabled == true) then
	    game.adverts:visibility(true)
	end
end
function backTouch(event)
	game.buttonPressed(back, event)
	if event.phase == "ended" and game.storeFrom == "home" then
		switchToScene("home")
	elseif event.phase == "ended" and game.storeFrom == "pause" then
		switchToScene("pauseFromStore")
	end
end
function newGameStoreTouch(event)
	game.buttonPressed(newGameStore, event)
	if event.phase == "ended" and game.storeFrom == "gameEnd" then
		-- print("New Game on Store Touched")
		game.stats:logEvent("newGame on Store Touched",nil)
		game.newGame = true
		switchToScene("gameFromStore")
	end
end

function getCostMessage(price)
	local message = "-        "..tostring(price)
	-- print(message)
	return message
end

function getCurrentTokenMessage()
	local message = game:getTokens()
	-- print(message)
	return message
end

function updateCurrentTokenLabel()
	currentTokenCountLabel.text = getCurrentTokenMessage()
end

function buyTileBreak(event)
	if event.phase == "ended" then
	 -- print(game.gridGame.tokens, cost.tb)
		if game.gridGame.tokens >= cost.tb then
			game.gridGame.tokens = game.gridGame.tokens - cost.tb
			game.gridGame.tileBreakCount = game.gridGame.tileBreakCount + 1
			game.gridGame:setTokens(game.gridGame.tokens)
			game.gridGame:setTileBreakCount(game.gridGame.tileBreakCount)
			minusCurrentTokenCountLabel.text = "-"..tostring(cost.tb)
			minusCurrentTokenCountLabel.isVisible = true
			tween:to(minusCurrentTokenCountLabel,{y = minusCurrentTokenCountLabel.y + tweenD * game.graphicsScale, time = tweenT, onComplete=setMinusCurrentTokenCountLabel})
			updateCurrentTokenLabel()
			tbCount.text = tostring(game.gridGame.tileBreakCount)
			setCountPos(tbCount,game.gridGame.tileBreakCount)
			game.stats:logEvent("Tile Break Purhased",nil)
		end
	end
end

function buySwap(event)
	if event.phase == "ended" then
	 -- print(game.gridGame.swapTileCount, cost.swap)
		if game.gridGame.tokens >= cost.swap then
			game.gridGame.tokens = game.gridGame.tokens - cost.swap
			game.gridGame.swapTileCount = game.gridGame.swapTileCount + 1
			game.gridGame:setTokens(game.gridGame.tokens)
			game.gridGame:setSwapTileCount(game.gridGame.swapTileCount)
			minusCurrentTokenCountLabel.text = "-"..tostring(cost.swap)
			minusCurrentTokenCountLabel.isVisible = true
			tween:to(minusCurrentTokenCountLabel,{y = minusCurrentTokenCountLabel.y + tweenD * game.graphicsScale, time = tweenT, onComplete=setMinusCurrentTokenCountLabel})
			updateCurrentTokenLabel()
			swapCount.text = tostring(game.gridGame.swapTileCount)
			setCountPos(swapCount,game.gridGame.swapTileCount)
			game.stats:logEvent("Swap Tile Purhased",nil)
		end
	end
end

function buyCnt(event)
	if event.phase == "ended" then
	 -- print(game.gridGame.tokens, cost.tb)
		if game.gridGame.tokens >= cost.change then
			game.gridGame.tokens = game.gridGame.tokens - cost.change
			game.gridGame.changeNextTileCount = game.gridGame.changeNextTileCount + 1
			game.gridGame:setTokens(game.gridGame.tokens)
			game.gridGame:setChangeNextTileCount(game.gridGame.changeNextTileCount)
			minusCurrentTokenCountLabel.text = "-"..tostring(cost.change)
			minusCurrentTokenCountLabel.isVisible = true
			tween:to(minusCurrentTokenCountLabel,{y = minusCurrentTokenCountLabel.y + tweenD * game.graphicsScale, time = tweenT, onComplete=setMinusCurrentTokenCountLabel})
			updateCurrentTokenLabel()
			cntCount.text = tostring(game.gridGame.changeNextTileCount)
			setCountPos(cntCount,game.gridGame.changeNextTileCount)
			game.stats:logEvent("Change Next Tile Purhased",nil)
		end
	end
end

function buyCoinsTouch(event)
	game.buttonPressed(buySomeCoins, event)
	if event.phase == "ended" then
		-- print("buyCoinsTouch")
		game.stats:logEvent("Buy Coins Touched",nil)
		game.store:purchaseTokens()
		-- updateCurrentTokenLabel()
	end
end

function setMinusCurrentTokenCountLabel()
	minusCurrentTokenCountLabel.x = currentTokenCountLabel.x
	minusCurrentTokenCountLabel.y = director.displayCenterY + (70 + spaceBetween) * 3 * game.graphicsScale
	minusCurrentTokenCountLabel.text = "-"
	
	minusCurrentTokenCountLabel.isVisible = false
end

function keyPressed(event)
	if event.phase == "released" then
		if event.keyCode == key.back then
			if game.storeFrom == "home" then
				switchToScene("home")
			elseif game.storeFrom == "pause" then
				switchToScene("pauseFromStore")
			elseif game.storeFrom == "gameEnd" then			
				game.newGame = true
				switchToScene("gameFromStore")
			end
		end
	end
end

function setCountPos(obj,newCount)
	-- 1 digit = 15 , >20 = 22 ,10-19 19
	local OrigPosition = tb.x + (tb.w) * game.graphicsScale * game.powerIconScale
	-- print(obj, newCount, OrigPosition)
	if newCount < 10 then
		obj.x = OrigPosition - 35 * game.graphicsScale * game.powerIconScale
	elseif newCount < 20 then
		obj.x = OrigPosition - 45 * game.graphicsScale * game.powerIconScale
	else
		obj.x = OrigPosition - 50 * game.graphicsScale * game.powerIconScale
	end
	-- print(obj.x)
end