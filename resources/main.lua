-- Your app starts here!

-- Enable ZeroBraneStudio debugging
-- require("mobdebug").start()

userSetup()

system:setFrameRateLimit(30)

-- debugLabel = director:createLabel({
-- 	x = director.displayCenterX,
-- 	y = director.displayCenterY,
-- 	text = "0"
-- 	})

-- inmobiAd = quick.QInmobi:new()
-- print("Lua Ads started\n")
-- debugLabel.text = "1"

-- if  inmobiAd:isAvailable() == true then
-- 	-- print("Lua In mobi ads available\n")
-- 	-- debugLabel.text = ""
-- 	inmobiAd:init(1)
-- 	print("Mydebug: tying interstitialAd")
-- 	-- inmobiAd:bannerAd(0, director.displayHeight-90)
-- 	inmobiAd:interstitialAd()
-- 	end

-- quitDialog = quick.QDialog:new()
-- if quitDialog:isAvailable() then 
-- 			print("Mydebug: Quit Dialog Called")
-- end

-- Create and initialise the game
local game = require("game")
game.init()


function exit(event)
  -- game.stats:endSession()
	-- dbg.print("unrequiring")
	-- print("Quick Mydebug: totalGamesPlayed  "..tostring(game.totalGamesPlayed) .. " totalGamesEnded ".. tostring(game.totalGamesEnded))
	game.stats:logEvent("totalGamesPLayed",{totalGamesPlayed = tostring(game.totalGamesPlayed), totalGamesEnded = tostring(game.totalGamesEnded) })
	game.stats:endSession()
	
	unrequire('tile')
	unrequire('backtile')
	unrequire('database')
	unrequire("class")
	unrequire("game")
	unrequire("grid")
	unrequire("gameEnd")
	unrequire("mainMenu")
	unrequire("pauseMenu")
	unrequire("storeScene")
	unrequire("adverts")
 	unrequire("social")
 	unrequire("store")
 	unrequire("stats")
end
system:addEventListener("exit", exit)

-- Switch to specific scene
function switchToScene(scene_name)
	if (scene_name == "gameFromHome") or (scene_name == "gameFromDemo")  then
		director:moveToScene(game.gameScene, {transitionType="fade", transitionTime=0.5})
	elseif (scene_name == "gameFromPause") or (scene_name == "gameFromStore") then
		director:moveToScene(game.gameScene, {transitionType="fade", transitionTime=0.5})
	elseif (scene_name == "home") then
		director:moveToScene(mainMenu.menuScene, {transitionType="fade", transitionTime=0.5})
	elseif (scene_name == "pause") then
		director:moveToScene(pauseMenu.pauseScene, {transitionType="fade", transitionTime=0.5})
	elseif (scene_name == "pauseFromStore") then
		director:moveToScene(pauseMenu.pauseScene, {transitionType="fade", transitionTime=0.5})
	elseif (scene_name == "gameEnd") then
		director:moveToScene(gameEnd.gameEndScene, {transitionType="fade", transitionTime=1})
	elseif (scene_name == "store") then
		director:moveToScene(storeScene.storeScene, {transitionType="fade", transitionTime=0.5})
	elseif (scene_name == "demo") then
		director:moveToScene(demo.demoScene, {transitionType="fade", transitionTime=0.5})
	end
end

-- print("This is my app!")

