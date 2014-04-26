
module(..., package.seeall)


require("class")
-- require("marmalade/crypto")

database = inheritsFrom(baseClass)

function new()
	local obj = database:create()
	database:init(obj)
	return obj
end

function database:init(obj)
	obj.map = {
		demo = "demo.txt",
		sound = "sound.txt",
		highScore = "highScore.txt",
		tokens = "token.txt",
		tileBreak = "tb.txt",
		swap = "swap.txt",
		changeNextTile = "change.txt"
	}
	obj.startingCount = {
		demo = 1,
		sound = 1,
		highScore = 0,
		tokens = 100,
		tileBreak = 2,
		swap = 5,
		changeNextTile = 10
	}
	
end

function database:getValue(name)
	-- print("hulla hulla")
	local file
	if self:fileExists(self.map[name]) == false then
		file = io.open(self.map[name], "w")
		local data = crypto:base64Encode(tostring(self.startingCount[name]))
		file:write(data)
		file:close()
	end
	file = io.open(self.map[name], "r")
    if (file ~= nil) then
      local en = file:read("*all")
      file:close()
      local decrypt = crypto:base64Decode(en)
      	-- print(tonumber(decrypt))
      	return tonumber(decrypt)
    end
end

function database:setValue(name,value)
	local file = io.open(self.map[name], "w")
	-- print("*****************   setting value ", name, value)
	local encrypt = crypto:base64Encode(tostring(value))
    file:write(encrypt)
    file:close()
	-- body
end

function database:fileExists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function database:addValue(name,value)
	local currentValue = self:getValue(name)
	local newValue = currentValue + value
	self:setValue(name,newValue)
end