--[[

Analytics

--]]

module(..., package.seeall)

-- OO functions
local class = require("class")
local apiKey = {
  ["IPHONE"] = "C47SBPGQB65YGNB46RG5",
  ["ANDROID"] = "C4PHWXXZFPCVNSPZMWR7"
  }

-- Create the stats class
stats = inheritsFrom(baseClass)

-- Creates an instance of the stats class
function new()
	local o = stats:create()
	stats:init(o)
	return o
end

-- Initialise the stats class
function stats:init(o)
  self.available = false
  if (analytics:isAvailable()) then
    self.available = true
    -- Start session
    local platform = device:getInfo("platform")
    analytics:startSession(apiKey[platform]) -- change this to the app ID provided to you by Flurry
  end
end

-- Log an event
function stats:logEvent(message, params)
  -- print(message)
  if (self.available) then
   	analytics:logEvent(message, params)
  end
end

-- Log an error
function stats:logError(name, message)
  if (self.available) then
    analytics:logError(name, message)
  end
end

-- End session
function stats:endSession()
  if (self.available) then
    analytics:endSession()
  end
end


