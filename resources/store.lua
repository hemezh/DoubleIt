--[[

Facebook posting

--]]

module(..., package.seeall)

-- OO functions
local class = require("class")

-- No ads product id's (Add your own product ID's to test)
local productIds = {
  ["IPHONE"] = "com.blackpearlstudios.Doubleit.tokens",
  ["ANDROID"] = "doubleit.tokens"
  }

-- Create the store class
store = inheritsFrom(baseClass)

-- Creates an instance of the store class
function new()
	local o = store:create()
	store:init(o)
	return o
end

-- Called in response to a billing event
function store:billing(event)
  if (event.type == "billingError") then
        -- game.db:addValue("tokens",-100)
        game.stats:logError("Billing Error",event.error)
  end

  if (event.type == "receiptAvailable") then
    game.db:addValue("tokens",250)
    game.gridGame.tokens = game.gridGame.tokens + 250
    storeScene:updateCurrentTokenLabel()
    -- game.stats:logEvent("Tokens Purchased",{productId = event.productId, transactionId = event.transactionId, date = event.date, receipt = event.receipt })
    if (billing:finishTransaction(event.finaliseData)) then   
      
    else 
      -- game.db:addValue("tokens",-100)
      game.stats:logError("Finish Transaction Failed",nil)
    end

	end

end

-- Initialise the store class
function store:init(o)
  self.available = false
  if (billing:isAvailable()) then
    if (billing:init()) then
      self.available = true 
      system:addEventListener("billing", self)     
    end
  end
end

-- Purchase no-ads
function store:purchaseTokens()
  -- print("buyCoinsTouch")
  if (self.available) then
    local platform = device:getInfo("platform")
    billing:purchaseProduct(productIds[platform])
    -- system:sendEvent("billing",{type="receiptAvailable", finaliseData="data"})
    -- print("buyCoinsTouch")
  end
end



