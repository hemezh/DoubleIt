--[[
User interface
--]]

module(..., package.seeall)

-- Globals
menuScene = nil
bgstream = "audio/h2o.mp3"
local adLoaded = 0
-- End start button animation (starts the game)
function startGame(event)
	game.buttonPressed(play, event)
	if(event.phase == "ended") then
		if game.db:getValue("demo") ~= 1729 then
			game.stats:logEvent("First Time Demo Played",nil)
			switchToScene("demo")
		else
			switchToScene("gameFromHome")
		end
	end
end

-- Create and initialise the main menu
function init()
	-- Create a scene to contain the main menu
	menuScene = director:createScene()
	menuScene:addEventListener("enterPreTransition", enterMainMenu)
	menuScene:addEventListener("key",keyPressed)
	menuScene:addEventListener("exitPreTransition",exitMainMenu)



	-- Create menu background
	local background = director:createSprite(director.displayCenterX, director.displayCenterY, "textures/bg.png")
	background.xAnchor = 0.5
	background.yAnchor = 0.5
	-- Fit background to screen size
	local bg_width, bg_height = background:getAtlas():getTextureSize()
	background.xScale = director.displayWidth / bg_width
	background.yScale = director.displayHeight / bg_height

	
	play = director:createSprite(director.displayCenterX, director.displayHeight / 2 , "textures/play.png")
	local play_width, play_height = play:getAtlas():getTextureSize()
	play.y = director.displayHeight / 2 - ( (play_height)  * game.graphicsScale)
	play.xAnchor = 0.5
	play.xScale = game.graphicsScale
	play.yScale = game.graphicsScale
	play:addEventListener("touch", startGame)

	shop = director:createSprite(director.displayCenterX, play.y - (50 + play_height) * game.graphicsScale, "textures/shop.png")
	shop.xAnchor = 0.5
	shop.xScale = game.graphicsScale
	shop.yScale = game.graphicsScale

	shop:addEventListener("touch",storeHomeTouch)


	local logo = director:createSprite(director.displayCenterX, play.y + (2*play_height + 20)*game.graphicsScale, "textures/logo.png")
	logo.xAnchor = 0.5
	logo.xScale = game.graphicsScale
	logo.yScale = game.graphicsScale
	-- print(play.w, play.h)

	starFactor = 0.25

	starRating = director:createSprite(20*game.graphicsScale, 20*game.graphicsScale, "textures/star.png")
	starRating.xScale = game.graphicsScale * starFactor
	starRating.yScale = game.graphicsScale * starFactor
	starRating:addEventListener("touch",starRatingTouch)

	

	soundon = director:createSprite(starRating.x  + (80 + starRating.w) * game.graphicsScale * starFactor, 15*game.graphicsScale, "textures/soundon.png")
	soundon.xScale = game.graphicsScale * starFactor * 2
	soundon.yScale = game.graphicsScale * starFactor * 2
	soundon:addEventListener("touch",soundonTouch)

	soundoff = director:createSprite(starRating.x  + (80 +starRating.w) * game.graphicsScale * starFactor, 15*game.graphicsScale, "textures/soundoff.png")
	soundoff.xScale = game.graphicsScale * starFactor * 2  
	soundoff.yScale = game.graphicsScale * starFactor * 2 
	soundoff:addEventListener("touch",soundoffTouch)

	infoIcon = director:createSprite(soundon.x +(80 + starRating.w) * game.graphicsScale * starFactor, 15*game.graphicsScale, "textures/info.png")
	infoIcon.xScale = game.graphicsScale * starFactor
	infoIcon.yScale = game.graphicsScale * starFactor
	infoIcon:addEventListener("touch",startDemo)

	socialFactor = 0.35

	tw = director:createSprite(0, 20*game.graphicsScale, "textures/tw.png")
	local tw_width, tw_height = tw:getAtlas():getTextureSize()
	tw.x = director.displayWidth  - ( (20  * game.graphicsScale) + tw_width * game.graphicsScale * socialFactor)
	-- print(tw.x)
	tw.xScale = game.graphicsScale * socialFactor
	tw.yScale = game.graphicsScale * socialFactor
	tw:addEventListener("touch",twTouch)

	fb = director:createSprite(0, 20*game.graphicsScale, "textures/fb.png")
	local fb_width, fb_height = fb:getAtlas():getTextureSize()
	fb.x = director.displayWidth  - ( (20 + 20)  * game.graphicsScale + (fb_width + tw_width) * game.graphicsScale * socialFactor)
	-- print(fb.x)
	fb.xScale = game.graphicsScale * socialFactor
	fb.yScale = game.graphicsScale * socialFactor
	fb:addEventListener("touch",fbTouch)

	-- tw.y = fb.y - ( 44 ) * game.graphicsScale

	-- socialSharing = director:createSprite({
	-- 	x = director.displayWidth,
	-- 	y = 20 * game.graphicsScale,
	-- 	source = "textures/fb-tw.png",
	-- 	xScale = game.graphicsScale * 0.35,
	-- 	yScale = game.graphicsScale * 0.35
	-- 	})
	-- ss_width, ss_height = socialSharing:getAtlas():getTextureSize()
	-- socialSharing.x = socialSharing.x - (ss_width + 20 ) * game.graphicsScale * 0.35
	-- socialSharing:addEventListener("touch",socialSharingTouch)

	highScoreSprite = director:createSprite({
		x = 20 * game.graphicsScale,
		y = director.displayHeight - (50 ) * game.graphicsScale,
		yAnchor = 0.5,
		source = "textures/highscore.png",
		xScale = game.graphicsScale, 
		yScale = game.graphicsScale 
		})
	highScoreLabel = director:createLabel( {
		x = (20 + highScoreSprite.w + 10) * game.graphicsScale, 
		y = director.displayHeight - (50) * game.graphicsScale ,
		text = tostring(game:getHighScore()),
		textXScale = game.fontScale, 
		textYScale = game.fontScale 
		})
	highScoreLabel.y = highScoreLabel.y - highScoreLabel.hText/2
	
	tokensLabel = director:createLabel({
		x = director.displayWidth - 20 * game.graphicsScale,
		y = director.displayHeight - (50) * game.graphicsScale,
		text = tostring(game:getTokens()) ,
		textXScale = game.fontScale, 
		textYScale = game.fontScale 
		})
	
	tokensLabel.x = tokensLabel.x - tokensLabel.wText
	tokensLabel.y = tokensLabel.y - tokensLabel.hText/2

	tokenImage = director:createSprite({
		x = tokensLabel.x - (10 + 50) * game.graphicsScale,
		y = director.displayHeight - (50) * game.graphicsScale,
		yAnchor = 0.5,
		xScale = game.graphicsScale,
		yScale = game.graphicsScale,
		source = "textures/coin.png"
		})

	-- testImage = director:createSprite(0, 100, "textures/coin.png")
	-- testImage:addEventListener("touch",quit)
	

	if game.db:getValue("sound") == 1 then
		soundoff.isVisible = false 
		audio:playStream(bgstream, true)
	else
		soundon.isVisible = false
	end
	
end

function startDemo(event)
	game.buttonPressed(infoIcon, event)
	if event.phase == "ended" then
		game.stats:logEvent("Demo Started Again",nil)
		switchToScene("demo")
	end
end

function keyPressed(event)
	if event.phase == "released" then
		if event.keyCode == key.back then
			if game.quitDialog:isAvailable() == true then 
				-- print("Mydebug: Quit Dialog Called")
				game.quitDialog:alertBox()
			else
				system:quit()
			end
		end
	end
end


function starRatingTouch(event)
	game.buttonPressed(starRating, event)
	if event.phase == "ended" and browser:isAvailable() then
	game.stats:logEvent("Rating Star Touched",nil)
		browser:launchURL("https://play.google.com/store/apps/details?id=com.blackpearlstudios.DoubleIt")
	end
end
function fbTouch(event)
	game.buttonPressed(fb, event)
	if (event.phase == "ended") then
		game.stats:logEvent("Fb Share On Home Touched",nil)
        browser:launchURL("http://www.facebook.com/pages/Doubleit-Game/649961698403199")
    end
end
function twTouch(event)
	game.buttonPressed(tw, event)
	if event.phase == "ended" and browser:isAvailable() then
		game.stats:logEvent("Twitter On Home Touched",nil)
		browser:launchURL("http://twitter.com/doubleItgame")
	end
end

function exitMainMenu(event)
	game.isHomeScreen = false
	if adLoaded == 0 then 
		game.loadBannerAd()
		adLoaded = 1
	else
		showAds()
	end
end

function enterMainMenu( event )
	game.isHomeScreen = true
	hideAds(event)
	tokensLabel.text = tostring(game:getTokens())
	highScoreLabel.text = tostring(game:getHighScore())
	if game.db:getValue("sound") == 1 then
		soundoff.isVisible = false 
		soundon.isVisible = true
		-- audio:playStream(bgstream, true)
	else
		soundon.isVisible = false
		soundoff.isVisible = true
	end
end
function hideAds(event)
	-- print("hide ads")
	-- if  inmobiAd:isAvailable() == true then
		game.inmobiAd:hideAd()
	-- end
end

function showAds(event)
	-- print("show ads")
	-- if  inmobiAd:isAvailable() == true then
		game.inmobiAd:showAd()
	-- end
end

function storeHomeTouch(event)
	game.buttonPressed(shop, event)
	if(event.phase == "ended") then
		game.storeFrom = "home"
		-- print(game.storeFrom)
		switchToScene("store")
	end
end

function soundonTouch(event)	
	if event.phase == "ended" then
		if game.db:getValue("sound") == 0 then 
			return false
		end
		soundoff.isVisible = true
		soundon.isVisible = false
		-- print("sound on")
		audio:stopStream()
		game.stats:logEvent("Music Turned Off from home",nil)
		game.db:setValue("sound", 0)
		return true
	end
	
end

function soundoffTouch(event)
	if event.phase == "ended" then
		soundoff.isVisible = false
		soundon.isVisible = true
		-- print("sound off")
		audio:playStream(bgstream, true)
		game.stats:logEvent("Music Turned On from home",nil)
		game.db:setValue("sound", 1)
	end
end

-- function socialSharingTouch(event)
-- 	print("socialSharing")
-- 	if event.phase == "ended" then
-- 		if event.x < socialSharing.x + ss_width/2 * game.graphicsScale * 0.35 then
-- 			print("fb")
-- 			fbTouch(event)
-- 		else
-- 			print("tw")
-- 			twTouch(event)
-- 		end
-- 	end
-- end