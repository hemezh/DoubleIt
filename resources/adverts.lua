--[[
Adverts module
--]]

module(..., package.seeall)

-- OO functions
local class = require("class")

-- Create the adverts class
adverts = inheritsFrom(baseClass)

-- Creates an instance of the adverts class
function new()
	local o = adverts:create()
	adverts:init(o)
	return o
end

-- Initialise the adverts class
function adverts:init(o)
  self.initialised = false
  if (ads:isAvailable()) then
    self.enabled = true
    self.adHeight = 100
    self.yPos = 100
    -- local file = io.open("ads.txt", "r")
    -- if (file ~= nil) then
    --   local en = file:read("*all")
    --   if (en == "0") then
    --     self.enabled = false
    --   end
    -- end
  else
    self.enabled = false
  end
end

-- Returns ads enabled status
function adverts:isEnabled()
  return self.enabled
end

-- Shows ads (Add your own ad app ID's)
function adverts:show()
  if (self.enabled) then
    -- Initialise the ads system
    if (self.initialised == false) then
      ads:init()
      self.initialised = true
    end
    -- Get platform
    local platform = device:getInfo("platform")
    -- Create ad
    if (platform == "ANDROID") then
      ads:newAd(self.yPos * game.graphicsScale, self.adHeight * game.graphicsScale, "leadbolt", "banner","238970518") -- Example ID "158316107 Our ID  "238970518"
    elseif (platform == "IPHONE") then
      ads:newAd(self.yPos * game.graphicsScale, self.adHeight * game.graphicsScale, "leadbolt", "banner", "749832839")
    else
      ads:newAd(self.yPos * game.graphicsScale, self.adHeight * game.graphicsScale, "leadbolt", "banner", "238970518")
    end
  end
end


function adverts:showWallAdd()
  if (self.enabled) then
    -- Initialise the ads system
    if (self.initialised == false) then
      ads:init()
      self.initialised = true
    end
    -- Get platform
    local platform = device:getInfo("platform")
    -- Create ad
    if (platform == "ANDROID") then
      ads:newAd(director.displayHeight - 10 * game.graphicsScale, director.displayHeight - 20 * game.graphicsScale, "leadbolt", "wall","229395065")
    elseif (platform == "IPHONE") then
      ads:newAd(director.displayHeight, director.displayHeight, "leadbolt", "wall", "892873842")
    else
      ads:newAd(director.displayHeight, director.displayHeight, "leadbolt", "wall", "229395065")
    end
  end
end


-- Hide ads
function adverts:visibility(value)
  if (self.enabled and self.initialised) then
    -- Hide the ads view
    ads:show(value)
  end
end

-- Diable ads permanently
function adverts:disable()
  if (self.enabled and self.initialised) then
    -- ads.txt file contains a "0" for disabled ads or "1" for enabled ads
    local file = io.open("ads.txt", "w")
    file:write("0")
    file:close()
    self:hide()
  end
end


