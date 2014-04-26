--[[

Facebook posting

--]]

module(..., package.seeall)

-- OO functions
local class = require("class")

-- Create the social class
social = inheritsFrom(baseClass)

-- Creates an instance of the social class
function new()
	local o = social:create()
	social:init(o)
	return o
end
-- Initialise the social class
function social:init(o)
  self.available = false
  self.loggedIn = false
  self.shared = false
  self.currentScore = 0
  if (facebook:isAvailable()) then
    self.available = true
    facebook:register("222188814637721", "610151761a95e9faf18eadc263ab426e")
    system:addEventListener("facebook", self)
  end
end

function social:facebook(event)
  if event.type == "login" then
    if (event.result) then
      self.loggedIn = true
      self:postUpdate()
    end
  end
end


function social:postUpdate()
  self.currentScore = game.gridGame.score
  local message = self:shareMessage("fb")
  self.shared = facebook:postUpdate(message)
  if self.shared == true then
    gameEnd.ifSharedLabel.isVisible = true
  end
end


-- Post score and level 
function social:postScoreUpdate(score)
  self.shared = false
  self.currentScore = score
  if self.available == false then
    return 
  end
  -- print("facebook available", self.shared)
  if (self.loggedIn == false) then
    facebook:login()
  else
    self:postUpdate()
  end
end


function social:shareMessage(source)
  local appUrl = "http://bit.ly/DoubleItGame"
  local twUrl = "https://twitter.com/intent/tweet?url="..appUrl.."&text="
  local message1 = "I just scored " .. game.gridGame.score
  local message2 = " in @doubleItgame."
  local message3 = " Damn, It's addictive. "

  if source == "tw" then
      return twUrl..message1..message2..message3
  elseif source == "fb" then
    return message1.." in Doubleit Game."..message3..appUrl 
  end

end

-- function social:postGameStatus()

--   if self.available == false then
--     return 
--   end
--   if (self.loggedIn == false) then
--     facebook:login()
--   else
--     local message1 = "Play Double It on your mobile. It's Awesome :-). Play at "..self.appURL
--     facebook:postUpdate(message1)
--   end
-- end