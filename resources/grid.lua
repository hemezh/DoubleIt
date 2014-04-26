
module(..., package.seeall)

require('tile')
require('backtile')
require('class')
require('database')
-- require("mobdebug").start()



-- graphicsScale = director.displayWidth / 480
grid = inheritsFrom(baseClass)


swipeLeft = 'Left'
swipeRight = 'Right'
swipeUp = 'Up'
swipeDown = 'Down'


local touchThreshold = 3/2
local minSwipeFactorX = 7
local minSwipeFactorY = 10
local tileGrid
local startingTilesRange = 4
local set = {1,2,4,8}
local maxTileNumber = 8192
local maxSetElement = 256
local filePath = "textures/tile-"
local extension = ".png"


function new(tileCountX, tileCountY,gridOffsetX, gridOffsetY)
	local obj = grid:create()
	grid:init(obj, tileCountX, tileCountY, gridOffsetX, gridOffsetY)
	return obj
end

function grid:init(o, tileCountX, tileCountY, gridOffsetX, gridOffsetY)

	o.totalTiles = tileCountX * tileCountY
	
	o.width = tileCountX
	o.height = tileCountY
	o.offsetX = gridOffsetX
	o.offsetY = gridOffsetY
	o.score = 0
	o.presentTiles = 0
	o.moveAvailable = true
	o.nextTile = 0
	o.nextTileUI = nil
	--director.displayCenterX
	--director.displayCenterY
	o.gemsGrid = {}
	o.backTileGrid = {}

	o.highScore = 0
	o.tokens = 0
	o.tileBreakCount = 0
	o.swapTileCount = 0
	o.changeNextTileCount = 0

	o.tbUsed = 0
	o.swapUsed = 0
	o.cntUsed = 0

	o.db = database.new()
	for row = 1, tileCountX do 
		o.gemsGrid[row] = {}
		o.backTileGrid[row] = {}
	end
end



function grid:initGame()

	math.randomseed( os.time() )
	math.random(); math.random(); math.random()
	local numberOfTiles = math.random(startingTilesRange) + 2

	local positions = {}
	self.score = 0
	self.presentTiles = numberOfTiles
	self.moveAvailable = true
	self.highScore = self:getHighScore()
	self.tokens = self:getTokens()
	self.tileBreakCount = self:getTileBreakCount()
	self.swapTileCount = self:getSwapTileCount()
	self.changeNextTileCount = self:getChangeNextTileCount()

	self.tbUsed = 0
	self.swapUsed = 0
	self.cntUsed = 0

	set = {1,2,4,8}

	for i = 1, self.width do
		for j = 1, self.height do 
			table.insert(positions, i * self.totalTiles + j)
		end
	end

	
	-- print("tile resoltuin", tile.actualWidth * game.graphicsScale,tile.actualHeight * game.graphicsScale)
	size = self.totalTiles 
	for count = 1, numberOfTiles do
		pos = math.random(size)
		cell = positions[pos]
		for i = 1, size do
			if i >= pos then
				positions[i] = positions[i + 1]
			end
		end
		positions[size] = nil

		x = cell%self.totalTiles
		y = math.floor(cell/self.totalTiles)
		number = self:getNewTileNumber()	
		coord = self:getTilePosition(x,y)
		self.gemsGrid[x][y] = tile.new(number, coord[1], coord[2])
		size = size - 1
	end

	self.nextTileUI = tile.new(0, game.offSet.nextTile.x,game.offSet.nextTile.y)

	self:changeNextTile("initGame")

	-- game.highScoreLabel.text = tostring(self.highScore)

end

function grid:initDemo()

	math.randomseed( os.time() )
	math.random(); math.random(); math.random()
	local numberOfTiles = 4

	local positions = {}
	self.score = 0
	self.presentTiles = numberOfTiles
	self.moveAvailable = true
	self.highScore = self:getHighScore()
	self.tokens = self:getTokens()
	self.tileBreakCount = 1
	self.swapTileCount = 1
	self.changeNextTileCount = 1

	set = {1,2,4,8}

	for i = 1, self.width do
		for j = 1, self.height do
			if self.gemsGrid[i][j] ~= nil then
				self.gemsGrid[i][j].sprite.isVisible = false
				self.gemsGrid[i][j]:deleteTile()
				self.gemsGrid[i][j] = nil
			end
		end
	end
	if self.nextTileUI ~= nil then
		self.nextTileUI.sprite.isVisible = false
		self.nextTileUI:deleteTile()
		self.nextTileUI = nil
	end

	coord = self:getTilePosition(1, 1)
	self.gemsGrid[1][1] = tile.new(2, coord[1], coord[2])
	coord = self:getTilePosition(1, 2)
	self.gemsGrid[1][2] = tile.new(1, coord[1], coord[2])
	coord = self:getTilePosition(2, 1)
	self.gemsGrid[2][1] = tile.new(1, coord[1], coord[2])
	coord = self:getTilePosition(4, 2)
	self.gemsGrid[4][2] = tile.new(1, coord[1], coord[2])
	
	self.nextTileUI = tile.new(0, game.offSet.nextTile.x,game.offSet.nextTile.y)
	-- self:changeNextTile("demo")
	-- game.highScoreLabel.text = tostring(self.highScore)

end

function grid:setBackTiles()
	for i = 1, self.width do
		for j = 1, self.height do
			coord = self:getTilePosition(i, j)
			self.backTileGrid[i][j] = backtile.new(number, coord[1], coord[2])
		end
	end
end
	

function grid:swipeMade(event, touchX, touchY)
		
		dx = event.x - touchX
		dy = event.y - touchY
		-- print(dx, dy)
		if( math.abs(dx) > math.abs(dy) and math.abs(dx) > director.displayWidth/minSwipeFactorX ) then
			if (math.abs(dy) <= math.abs(dx)/touchThreshold) then 
				if (dx > 0 ) then 
						self:handleSwipe(swipeRight)  
				else
						self:handleSwipe(swipeLeft)
				end
			end
		elseif ( math.abs(dy) > director.displayHeight/minSwipeFactorY ) then
			if (math.abs(dx) <= math.abs(dy)/touchThreshold) then 
				if (dy > 0) then
						self:handleSwipe(swipeUp)
				else
						self:handleSwipe(swipeDown)
				end
			end
		end
end

function grid:handleSwipe(swipe)
	-- print(swipe)
	local oldScore = self.score
	local isMoved = false
	local rc = false
	local map = {0,0,0,0}
	local gameEnd = false
	if swipe == swipeRight then 
		for i = self.width-1, 1, -1  do
			for j = 1, self.height do 
				rc = self:moveTile({i, j}, {i+1, j})
				if rc == true then 
					map[j] = 1 
					isMoved = rc 
				end
			end
		end
	elseif swipe == swipeLeft then
		for i = 2, self.width  do
			for j = 1, self.height do 
				rc = self:moveTile({i, j}, {i-1, j})
				if rc == true then 
					map[j] = 1 
					isMoved = rc 
				end
			end
		end
	elseif swipe == swipeUp then
		for i = 1, self.width  do
			for j = self.height-1, 1, -1 do 
				rc = self:moveTile({i, j}, {i, j+1})
				if rc == true then 
					map[i] = 1 
					isMoved = rc 
				end
			end
		end	
	elseif swipe == swipeDown then
		for i = 1, self.width  do
			for j = 2, self.height do 
				rc = self:moveTile({i, j}, {i, j-1})
				if rc == true then 
					map[i] = 1 
					isMoved = rc 
				end
			end
		end	 
	end	

	if isMoved == true then
		-- audio:playSound("audio/woosh.raw")
		self:insertNewTile(swipe, map)
		if oldScore < self.score then
			self:addScoreAnimate(self.score - oldScore)
		end
	end
	-- Check if Game ends
	gameEnd = self:checkGameEnd()
	if gameEnd == true then
		self.moveAvailable = false
	end

end

function grid:moveTile(from, to)
	local i, j = from[1], from[2]
	local ii, jj = to[1], to[2]
	local isMoved = false

	if self.gemsGrid[i][j] ~= nil and  
		(self.gemsGrid[ii][jj] == nil or self.gemsGrid[i][j].number == self.gemsGrid[ii][jj].number ) then 
		-- audio:playStream("audio/woosh.mp3")
		if self.gemsGrid[ii][jj] ~=nil and self.gemsGrid[ii][jj].number == maxTileNumber then
			return isMoved
		end
		self:animateMoveTile({i, j}, {ii, jj}) -- i,j is old pos, and ii, jj is new pos
		if self.gemsGrid[ii][jj] ~= nil then
			self:addToScore(self.gemsGrid[i][j].number * 2)
			-- Add New Element to Set
			if 2 * self.gemsGrid[i][j].number > set[table.getn(set)] and 2*self.gemsGrid[i][j].number <= maxSetElement then
				table.insert(set, 2 * self.gemsGrid[i][j].number)
			end
			self.presentTiles = self.presentTiles - 1
			local newNumber = self.gemsGrid[i][j].number + self.gemsGrid[ii][jj].number
			-- self.gemsGrid[ii][jj].sprite.isVisible = false
			self.gemsGrid[i][j].sprite.isVisible = false
			self.gemsGrid[i][j]:deleteTile()
			self.gemsGrid[i][j] = nil
			-- self.gemsGrid[ii][jj]:deleteTile()
			-- self.gemsGrid[ii][jj] = nil
			
			local coord = self:getTilePosition(ii,jj)
			local localTile = tile.new(newNumber, coord[1], coord[2])
			tween:dissolve(self.gemsGrid[ii][jj].sprite, localTile.sprite, 0.5, 0)

			self.gemsGrid[ii][jj]:deleteTile()
			self.gemsGrid[ii][jj] = nil
			self.gemsGrid[ii][jj] = localTile
			-- self.gemsGrid[ii][jj].sprite.isVisible = false
			-- print(filePath..tostring(self.gemsGrid[i][j].number)..extension)
		else 
			self.gemsGrid[ii][jj] = self.gemsGrid[i][j]
			self.gemsGrid[i][j] = nil
		end
		isMoved = true
	end
	return isMoved
end

function grid:insertNewTile(direction, map)
	local moved = {}
	local number = self.nextTile
	if direction == swipeRight then
		for j = 1, self.height do 
			if self.gemsGrid[1][j] == nil and map[j] == 1 then
				table.insert(moved, j)
			end
		end
		local size = table.getn(moved)
		local index = moved[math.random(size)]
		self:bringInNewTile(number, {0, index}, {1, index})
	elseif direction == swipeLeft then
		for j = 1, self.height do 
			if self.gemsGrid[self.width][j] == nil and map[j] == 1 then
				table.insert(moved, j)
			end
		end
		local size = table.getn(moved)
		local index = moved[math.random(size)]
		self:bringInNewTile(number, {self.width + 1, index}, {self.width, index})
	elseif direction == swipeUp then
		for i = 1, self.width do 
			if self.gemsGrid[i][1] == nil and map[i] == 1 then
				table.insert(moved, i)
			end
		end
		local size = table.getn(moved)
		local index = moved[math.random(size)]
		self:bringInNewTile(number, {index, 0}, {index, 1})
	elseif direction == swipeDown then
		for i = 1, self.width do 
			if self.gemsGrid[i][self.height] == nil and map[i] == 1 then
				table.insert(moved, i)
			end
		end
		local size = table.getn(moved)
		local index = moved[math.random(size)]
		self:bringInNewTile(number, {index, self.height+1}, {index, self.height})
	end
	self:changeNextTile("initGame")
end

function grid:bringInNewTile(number, from, to) 
	local fromX, fromY = from[1], from[2]
	local toX, toY = to[1], to[2]
	local coord = self:getTilePosition(fromX, fromY)
	self.gemsGrid[toX][toY] = tile.new(number, coord[1], coord[2])
	self:animateMoveTile({fromX, fromY}, {toX, toY}, self.gemsGrid[toX][toY])
	self.presentTiles = self.presentTiles + 1
end

function grid:animateMoveTile(from, to, tile)
	
	if tile == nil then 
		tile = self.gemsGrid[from[1]][from[2]]
	end
	local xx = to[1]
	local yy = to[2]
	local coord = self:getTilePosition(xx, yy)
	tween:to(tile.sprite, { x = coord[1], y = coord[2], time=0.2, easingValue=4.0, easing=ease.powInOut} )
		-- tween:to(tile.label, { x = coord[1], y = coord[2], time=0.2, easingValue=4.0, easing=ease.powInOut} )
end


function grid:getTilePosition(x, y)
	local coord = {}
	table.insert(coord, (x - 1) * tile.actualWidth * game.graphicsScale  + self.offsetX)  
	table.insert(coord, (y - 1) * tile.actualHeight * game.graphicsScale + self.offsetY)
	return coord
end

function grid:getNewTileNumber()
	-- math.randomseed( os.time() )
	math.random(); math.random(); math.random()
	
	 local size = table.getn(set)
	 local max = set[size]
	 local sum = 2 * max - 1
	 local currentSum = 1
	 local typeValue = math.random(sum)
	 local step = 1

	while step <= size do
		-- print(step, typeValue, currentSum)
		if typeValue <= currentSum then
			-- print("blah ", set[size - step + 1])
			return set[size - step + 1]
		end
		step = step + 1
		currentSum = currentSum + set[step]
	end
	return 1
end

function grid:reMakeGrid()

	for i = 1, self.width do
		for j = 1, self.height do
			if self.gemsGrid[i][j] ~= nil then
				self.gemsGrid[i][j].sprite.isVisible = false
				self.gemsGrid[i][j]:deleteTile()
				-- self.gemsGrid[i][j].label.isVisible = false
				self.gemsGrid[i][j] = nil
			end
		end
	end
	self.nextTileUI.sprite.isVisible = false
	self.nextTileUI:deleteTile()
	self.nextTileUI = nil
	game.stats:logEvent("Powers Used in Game",{tileBreak = self.tbUsed, swapTiles = self.swapUsed, changeNextTile = self.cntUsed})
	self:initGame()
	game.totalGamesPlayed = game.totalGamesPlayed + 1
	
end

function grid:addToScore(number)
	self.score = self.score + number
end
function grid:addScoreAnimate(number)
	game.scoreLabel.text = tostring(self.score)
	game.addScoreLabel.text = "+"..tostring(number)
	game.addScoreLabel.isVisible = true
	tween:to(game.addScoreLabel, {x = game.offSet.score.x, y = game.offSet.score.y + 50*game.graphicsScale, time = 0.5, onComplete=setAddScoreLabel} )
end
function setAddScoreLabel()
	game.addScoreLabel.isVisible = false
	game.addScoreLabel.y = game.offSet.score.y
end
function grid:checkGameEnd()

	if self.presentTiles < self.totalTiles then
		return false
	end
	--for Right Swipe
	for i = self.width-1, 1, -1  do
		for j = 1, self.height do
			if self.gemsGrid[i][j].number == self.gemsGrid[i+1][j].number then
				return false
			end
		end
	end
	-- for Left Swipe
	for i = 2, self.width  do
		for j = 1, self.height do 
			if self.gemsGrid[i][j].number == self.gemsGrid[i-1][j].number then
				return false
			end
		end
	end
	-- for up Swipe
	for i = 1, self.width  do
		for j = self.height-1, 1, -1 do 
			if self.gemsGrid[i][j].number == self.gemsGrid[i][j+1].number then
				return false
			end
		end
	end
	-- for Down Swipe
	for i = 1, self.width  do
		for j = 2, self.height do
			if self.gemsGrid[i][j].number == self.gemsGrid[i][j-1].number then
				return false
			end
		end
	end

	return true
end

function grid:getNextTile()

	self.nextTile = self:getNewTileNumber()
	-- self:changeNextTile("initGame")

end

function grid:getHighScore()
 	return self.db:getValue("highScore")
end
function grid:getTileBreakCount()
 	return self.db:getValue("tileBreak")	
end
function grid:getSwapTileCount()
 	return self.db:getValue("swap")	
end
function grid:getChangeNextTileCount ()
 	return self.db:getValue("changeNextTile")	
end
function grid:getTokens()
 	return self.db:getValue("tokens")
end

function grid:setTokens(score)
	self.db:setValue("tokens",score)
end
function grid:setHighScore(score)
	self.db:setValue("highScore",score)
end
function grid:setTileBreakCount(score)
	self.db:setValue("tileBreak",score)
end
function grid:setSwapTileCount(score)
	self.db:setValue("swap",score)
end
function grid:setChangeNextTileCount(score)
	self.db:setValue("changeNextTile",score)
end


function grid:changeNextTile(source)

	if source == "demo" then
		  
	else
		self:getNextTile()
	end
	-- print(self.nextTile)
	-- game.nextTile.sprite.source = filePath..self.nextTile..extension
	if source == "power" then
		self.changeNextTileCount = self.changeNextTileCount - 1
		self.cntUsed = self.cntUsed + 1
		self:setChangeNextTileCount(self.changeNextTileCount)
	end
	-- tween:to(game.nextTile.sprite, {x = game.offSet.nextTile.x, y = director.displayHeight, time = 0.2} )
	self.nextTileUI.sprite.isVisible = false
	self.nextTileUI:deleteTile()
	self.nextTileUI = nil
	self.nextTileUI = tile.new(self.nextTile, game.offSet.nextTile.x, director.displayHeight)
	tween:to(self.nextTileUI.sprite, {x = game.offSet.nextTile.x, y = game.offSet.nextTile.y, time = 0.5} )

end

function grid:tileBreak(tiletoBreak)
	local i, j = tiletoBreak[1], tiletoBreak[2]
	if self.gemsGrid[i][j] ~= nil and self.gemsGrid[i][j].number ~= maxTileNumber then 
			-- local particles = director:createParticles("textures/explosion.plist")
			-- particles.sourcePos.x = (self.gemsGrid[i][j].sprite.x / game.graphicsScale) + (122 * game.graphicsScale / 2 )
			-- particles.sourcePos.y = (self.gemsGrid[i][j].sprite.y / game.graphicsScale) + (166 * game.graphicsScale / 2)
				local x = self.gemsGrid[i][j].sprite.x / game.graphicsScale + tile.actualWidth / 2
				local y = self.gemsGrid[i][j].sprite.y / game.graphicsScale + tile.actualHeight / 2
						local particles = director:createParticles( {
						    emitterMode = particles.modeGravity, emitterRate=100,
						    sourcePos = { x, y },
						    source = "textures/star-tb.png",
						    duration = 0.2,
						    modeGravity = {
						        gravity={0, 0},
						        radialAccel=10, radialAccelVar=0,
						        speed=100, speedVar=50,
						        tangentialAccel=0,
						        },
						    angle=90, angleVar=360,
						    life=1.0, lifeVar=0,
						    startColor={0xaf, 0xaf, 0xaf, 0xff}, startColorVar={0x80, 0x80, 0x80, 25},
						    endColor={25, 25, 25, 0},
						    startSize=30.0, startSizeVar=20.0,
						    endSize=particles.startSizeEqualToEndSize,
						} )
						particles.xScale = game.graphicsScale
						particles.yScale = game.graphicsScale
		self.gemsGrid[i][j].sprite.isVisible = false
		self.gemsGrid[i][j]:deleteTile()
		-- self.gemsGrid[i][j].label.isVisible = false
		self.gemsGrid[i][j] = nil
		
	else
		-- print("error")
	end
end

function grid:swapTiles(first, second)
	local i, j, ii, jj = first[1], first[2], second[1], second[2]

	-- print(i, j, ii, jj)
	-- print(self.gemsGrid[i][j].label.text, self.gemsGrid[ii][jj].label.text, self.gemsGrid[ii][jj].label.text, self.gemsGrid[i][j].label.text)
	-- if self.gemsGrid[ii][jj] ~= nil then
		-- self.gemsGrid[i][j].label.text, self.gemsGrid[ii][jj].label.text = self.gemsGrid[ii][jj].label.text, self.gemsGrid[i][j].label.text
		self:animateMoveTile(first,second)
		self:animateMoveTile(second,first)
		self.gemsGrid[i][j], self.gemsGrid[ii][jj] = self.gemsGrid[ii][jj], self.gemsGrid[i][j]
		-- self.gemsGrid[i][j].sprite.source, self.gemsGrid[ii][jj].sprite.source = self.gemsGrid[ii][jj].sprite.source, self.gemsGrid[i][j].sprite.source
		-- self.gemsGrid[i][j].label = se
	-- end
	
end


function grid:reducePowerCount(power)

end




