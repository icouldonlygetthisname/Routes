----------------------------------
--[[
Ant Colony Optimization (ACO) for Travelling Salesman Problem (TSP)
for Routes (a World of Warcraft addon)

Copyright (C) 2011 Xinhuan

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
Street, Fifth Floor, Boston, MA  02110-1301, USA.
]]

---------------------------------
--[[
Ant Colony Optimization and the Travelling Salesman Problem

The Travelling Salesman Problem (TSP) consists of finding the shortest tour
between n cities visiting each once only and ending at the starting point. Let
d(i,j) be the distance between cities i and j and t(i,j) the amount of pheromone
on the edge that connects i and j. t(i,j) is initially set to a small value
t(0), the same for all edges (i,j). The algorithm consists of a series of
iterations.

One iteration of the simplest ACO algorithm applied to the TSP can be summarized
as follows: (1) a set of m artificial ants are initially located at randomly
selected cities; (2) each ant, denoted by k, constructs a complete tour,
visiting each city exactly once, always maintaining a list J(k) of cities that
remain to be visited; (3) an ant located at city i hops to a city j, selected
among the cities that have not yet been visited, according to probability
p(k,i,j) = (t(i,j)^a * d(i,j)^-b) / sum(t(i,l)^a * d(i,l)^-b, all l in J(k))
where a and b are two positive parameters which govern the respective influences
of pheromone and distance; (4) when every ant has completed a tour, pheromone
trails are updated: t(i,j) = (1-p) * t(i,j) + D(t(i,j)), where p is the
evaporation rate and D(t(i,j)) is the amount of reinforcement received by edge
(i,j). D(t(i,j)) is proportional to the quality of the solutions in which (i,j)
was used by one ant or more. More precisely, if L(k) is the length of the tour
T(k) constructed by ant k, then D(t(i,j)) = sum(D(t(k,i,j)), 1 to m) with
D(t(k,i,j)) = Q / L(k) if (i,j) is in T(k) and D(t(k,i,j)) = 0 otherwise, where
Q is a positive parameter. This reinforcement procedure reflects the idea that
pheromone density should be lower on a longer path because a longer trail is
more difficult to maintain.

Steps (1) to (4) are repeated either a predefined number of times or until a
satisfactory solution has been found. The algorithm works by reinforcing
portions of solutions that belong to good solutions and by applying a
dissipation mechanism, pheromone evaporation, which ensures that the system does
not converge early toward a poor solution. When a = 0, the algorithm implements
a probabilistic greedy search, whereby the next city is selected solely on the
basis of its distance from the current city. When b = 0, only the pheromone is
used to guide the search, which would react the way the ants do it. However, the
explicit use of distance as a criterion for path selection appears to improve
the algorithm's performance. In all other optimization applications also, an
improvement in the algorithm's performance is observed when a local measure of
greed, similar to the inverse of distance for the TSP, is included into the
local selection of portions of solution by the agents. Typical parameter values
are: m = n, a = 1, b = 5, p = 0.5, t(0) = 1e-6.

-- Inspiration for optimization from social insect behaviour
-- by E. Bonabeau, M. Dorigo & G. Theraulaz
-- NATURE, VOL 406, 6 JULY 2000, www.nature.com
]]

-- Note:
-- The functions in this file are written specifically for use with Routes
-- in mind and is not a general TSP library.

----------------------------------
-- Localize some globals
local ipairs, pairs, type = ipairs, pairs, type
local random = random
local floor, ceil = floor, ceil
local coroutine = coroutine
local tinsert, tremove = tinsert, tremove
local debugprofilestop = debugprofilestop
local inf = math.huge

local pathR = {}
local lastpath
local Routes = LibStub("AceAddon-3.0"):GetAddon("Routes")
local L = LibStub("AceLocale-3.0"):GetLocale("Routes")
local TSP = {}
Routes.TSP = TSP


--------------------------------
-- Background execution

local nextYield = 0
local function yield()
	local t = debugprofilestop()
	if t > nextYield then
		nextYield = t + 30
		coroutine.yield()
	elseif t < nextYield then
		-- Someone called debugprofilestart(), we need to reset our timer, yield anyway
		nextYield = t + 30
		coroutine.yield()
	end
end


-----------------------------------------------------
-- Function to get the intersection point of 2 lines (x1,y1)-(x2,y2) and (sx,sy)-(ex,ey)
--[[ Unused function, its inlined in SolveTSP()
function TSP:GetIntersection(x1, y1, x2, y2, sx, sy, ex, ey)
	local dx = x2-x1
	local dy = y2-y1
	local numer = dx*(sy-y1) - dy*(sx-x1)
	local demon = dx*(sy-ey) + dy*(ex-sx)
	if demon == 0 or dx == 0 then
		return false
	else
		local u = numer / demon
		local t = (sx + (ex-sx)*u - x1)/dx
		if u >= 0 and u <= 1 and t >= 0 and t <= 1 then
			--return sx + (ex-sx)*u, sy + (ey-sy)*u -- coordinate of intersection
			return true
		end
	end
end]]


-----------------------------------------------------
-- Coroutine code to allow background pathing

local TSPUpdateFrame = CreateFrame("Frame")
TSPUpdateFrame.running = false

function TSPUpdateFrame:OnUpdate(elapsed)
	local status, path, meta, shortestPathLength, count, timetaken = coroutine.resume(self.co)
	if status then
		if coroutine.status(self.co) == "dead" then
			-- Function finished, return results
			self:SetScript("OnUpdate", nil)
			self.running = false
			self.finishFunc(path, meta, shortestPathLength, count, timetaken)
			self.finishFunc = nil
			self.statusFunc = nil
			self.co = nil
			self.nodes = nil
		end
	else
		-- An error occured in the coroutine, abort and print the error
		self:SetScript("OnUpdate", nil)
		self.running = false
		self.co = nil
		self.finishFunc = nil
		self.statusFunc = nil
		self.nodes = nil
		Routes:Print(L["The following error occured in the background path generation coroutine, please report to Grum or Xinhuan:"])
		Routes:Print(path)
	end
end

local TSPClusterFrame = CreateFrame("Frame")
TSPClusterFrame.running = false

function TSPClusterFrame:OnUpdate(elapsed)
	local status, nodes, metadata, pathLength = coroutine.resume(self.co)
	if status then
		if coroutine.status(self.co) == "dead" then
			-- Function finished, return results
			self:SetScript("OnUpdate", nil)
			self.running = false
			self.finishFunc(nodes, metadata, pathLength)
			self.finishFunc = nil
			self.statusFunc = nil
			self.co = nil
		end
	else
		-- An error occured in the coroutine, abort and print the error
		self:SetScript("OnUpdate", nil)
		self.running = false
		self.co = nil
		self.finishFunc = nil
		self.statusFunc = nil
		Routes:Print(L["The following error occured in the background clustering coroutine, please report to Grum or Xinhuan:"])
		Routes:Print(nodes)
	end
end

function TSP:IsTSPRunning()
	return TSPUpdateFrame.running, TSPUpdateFrame.nodes
end

-- Same arguments as TSP:SolveTSP(), without the "nonblocking" argument
function TSP:SolveTSPBackground(nodes, metadata, taboos, zoneID, parameters, path)
	if not TSPUpdateFrame.running then
		TSPUpdateFrame.co = coroutine.create(TSP.SolveTSP)
		TSPUpdateFrame:SetScript("OnUpdate", TSPUpdateFrame.OnUpdate)
		TSPUpdateFrame.running = true
		TSPUpdateFrame.nodes = nodes
		local status = coroutine.resume(TSPUpdateFrame.co, TSP, nodes, metadata, taboos, zoneID, parameters, path, true)
		if status then
			-- Do nothing, path isn't complete because at least 1 yield() is called.
			return 1
		else
			-- An error occured in the coroutine, abort and return the error message.
			TSPUpdateFrame.running = false
			TSPUpdateFrame:SetScript("OnUpdate", nil)
			TSPUpdateFrame.co = nil
			return 3, path
		end
	else
		-- There is already a TSP running
		return 2
	end
end

function TSP:SetFinishFunction(func)
	assert(type(func) == "function", "SetFinishFunction() expected function in 1st argument, got "..type(func).." instead.")
	TSPUpdateFrame.finishFunc = func
end

function TSP:SetStatusFunction(func)
	assert(type(func) == "function", "SetStatusFunction() expected function in 1st argument, got "..type(func).." instead.")
	TSPUpdateFrame.statusFunc = func
end


-----------------------------------
-- Solver for routes that are too large for the ant colony solver.
-- The ant colony solver needs NxN tables, and WoW limits a table to 2^19 entries,
-- so it cannot handle more than 724 nodes. This builds a nearest neighbour tour and
-- improves it with 2-opt moves restricted to each node's closest neighbours, which
-- only needs memory proportional to the number of nodes.
local MAX_ACO_NODES = 724
local NUM_NEIGHBOURS = 10

local function SolveLarge(nodes, metadata, taboos, zoneID, path, nonblocking, startTime)
	local n = #nodes
	local zoneW, zoneH = Routes.Dragons:GetZoneSize(zoneID)
	local xs, ys = {}, {}
	for i = 1, n do
		xs[i], ys[i] = floor(nodes[i] / 10000) / 10000, (nodes[i] % 10000) / 10000
	end

	-- Flatten the taboo regions into a list of segments
	local tsx, tsy, tex, tey = {}, {}, {}, {}
	for m = 1, #taboos do
		local taboo_data = taboos[m].route
		local last_point = taboo_data[ #taboo_data ]
		local sx, sy = floor(last_point / 10000) / 10000, (last_point % 10000) / 10000
		for k = 1, #taboo_data do
			local point = taboo_data[k]
			local ex, ey = floor(point / 10000) / 10000, (point % 10000) / 10000
			local s = #tsx + 1
			tsx[s], tsy[s], tex[s], tey[s] = sx, sy, ex, ey
			sx, sy = ex, ey
		end
	end
	local numSegments = #tsx

	-- Distance between node i and j, biased the same way as SolveTSP() when the line crosses a taboo region
	local function dist(i, j)
		local x1, y1, x2, y2 = xs[i], ys[i], xs[j], ys[j]
		local w = (((x2 - x1)*zoneW)^2 + ((y2 - y1)*zoneH)^2)^0.5
		if numSegments > 0 then
			local dx, dy = x2-x1, y2-y1
			for s = 1, numSegments do
				local sx, sy, ex, ey = tsx[s], tsy[s], tex[s], tey[s]
				local numer = dx*(sy-y1) - dy*(sx-x1)
				local demon = dx*(sy-ey) + dy*(ex-sx)
				if demon ~= 0 and dx ~= 0 then
					local u = numer / demon
					local t = (sx + (ex-sx)*u - x1)/dx
					if u >= 0 and u <= 1 and t >= 0 and t <= 1 then
						return w * 2 + zoneW
					end
				end
			end
		end
		return w
	end

	-- Spatial grid with about 2 nodes per cell
	local cellSize = (zoneW * zoneH * 2 / n) ^ 0.5
	local gridMax = floor(zoneW / cellSize) + floor(zoneH / cellSize) + 2
	local grid = {}
	local gxs, gys = {}, {}
	for i = 1, n do
		local gx, gy = floor(xs[i] * zoneW / cellSize), floor(ys[i] * zoneH / cellSize)
		gxs[i], gys[i] = gx, gy
		local col = grid[gx]
		if not col then
			col = {}
			grid[gx] = col
		end
		local cell = col[gy]
		if not cell then
			cell = {}
			col[gy] = cell
		end
		cell[i] = true
	end
	-- Calls func(j) for every node in the ring of cells at distance r around node i
	local function forRing(i, r, func)
		local cx, cy = gxs[i], gys[i]
		for gx = cx-r, cx+r do
			local col = grid[gx]
			if col then
				local step = (gx == cx-r or gx == cx+r) and 1 or 2*r
				for gy = cy-r, cy+r, step > 0 and step or 1 do
					local cell = col[gy]
					if cell then
						for j in pairs(cell) do
							func(j)
						end
					end
				end
			end
		end
	end
	local function plainDist(i, j)
		return (((xs[j] - xs[i])*zoneW)^2 + ((ys[j] - ys[i])*zoneH)^2)^0.5
	end

	-- Step 1: Find the closest neighbours of every node, these are the candidates for 2-opt moves
	local neighbours = {}
	for i = 1, n do
		local list, dists = {}, {}
		local function consider(j)
			if j == i then return end
			local d = plainDist(i, j)
			local count = #list
			if count == NUM_NEIGHBOURS and d >= dists[count] then return end
			local k = count < NUM_NEIGHBOURS and count + 1 or count
			while k > 1 and dists[k-1] > d do
				list[k], dists[k] = list[k-1], dists[k-1]
				k = k - 1
			end
			list[k], dists[k] = j, d
		end
		for r = 0, gridMax do
			forRing(i, r, consider)
			if #list == NUM_NEIGHBOURS and dists[#list] <= r * cellSize then break end
		end
		neighbours[i] = list
		if nonblocking then
			yield()
		end
	end

	-- Step 2: Build a nearest neighbour tour, starting at the first node of the existing route
	local tour, pos = {}, {}
	local remaining = n
	local cur = 1
	for k = 1, n do
		tour[k], pos[cur] = cur, k
		grid[gxs[cur]][gys[cur]][cur] = nil
		remaining = remaining - 1
		if remaining == 0 then break end
		local best, bestD = nil, inf
		local function consider(j)
			local d = plainDist(cur, j)
			if d < bestD or (d == bestD and j < best) then
				best, bestD = j, d
			end
		end
		for r = 0, gridMax do
			forRing(cur, r, consider)
			if best and bestD <= r * cellSize then break end
		end
		cur = best
		if nonblocking then
			yield()
		end
	end

	-- Step 3: Improve the tour with 2-opt moves until no improving move is left
	local function reverse(i, j) -- reverse the tour from position i to j (inclusive, wrapping around)
		local len = (j - i) % n + 1
		if len * 2 > n then
			-- reversing the other part of the tour gives the same route and is shorter
			i, j = j % n + 1, (i - 2) % n + 1
			len = n - len
		end
		for s = 1, floor(len / 2) do
			local a, b = tour[i], tour[j]
			tour[i], tour[j] = b, a
			pos[b], pos[a] = i, j
			i = i % n + 1
			j = (j - 2) % n + 1
		end
	end

	local queue, queued, tail = {}, {}, n
	for i = 1, n do
		queue[i] = tour[i]
		queued[tour[i]] = true
	end
	local function push(a)
		if not queued[a] then
			queued[a] = true
			tail = tail + 1
			queue[tail] = a
		end
	end
	local moves, head = 0, 1
	local maxMoves = n * 50 -- safety net, 2-opt normally converges long before this
	while head <= tail and moves < maxMoves do
		local a = queue[head]
		queue[head] = nil
		head = head + 1
		queued[a] = nil
		local improved = true
		while improved do
			improved = false
			local pa = pos[a]
			local succA = tour[pa % n + 1]
			local predA = tour[(pa - 2) % n + 1]
			local dSucc, dPred = dist(a, succA), dist(predA, a)
			local list = neighbours[a]
			for m = 1, #list do
				local c = list[m]
				-- neighbours are sorted by plain distance, and the taboo bias only adds to it, so nothing better is left
				if plainDist(a, c) >= dSucc and plainDist(a, c) >= dPred then break end
				local dac = dist(a, c)
				local pc = pos[c]
				-- edges (a, succA) and (c, succC) become (a, c) and (succA, succC)
				local succC = tour[pc % n + 1]
				if dac < dSucc and c ~= succA and succC ~= a then
					if dac + dist(succA, succC) < dSucc + dist(c, succC) - 1e-7 then
						reverse(pa % n + 1, pc)
						push(succA) push(c) push(succC)
						improved = true
						break
					end
				end
				-- edges (predA, a) and (predC, c) become (predC, predA) and (a, c)
				local predC = tour[(pc - 2) % n + 1]
				if dac < dPred and c ~= predA and predC ~= a then
					if dac + dist(predA, predC) < dPred + dist(predC, c) - 1e-7 then
						reverse(pa, (pc - 2) % n + 1)
						push(predA) push(c) push(predC)
						improved = true
						break
					end
				end
			end
			if improved then
				moves = moves + 1
			end
		end
		if nonblocking then
			if TSPUpdateFrame.statusFunc and head % 50 == 0 then
				TSPUpdateFrame.statusFunc(1, head / tail)
			end
			yield()
		end
	end

	-- Step 4: Keep the original route if it is shorter (lengths include the taboo bias)
	local newLength, oldLength = 0, 0
	for i = 1, n do
		newLength = newLength + dist(tour[i], tour[i % n + 1])
		oldLength = oldLength + dist(i, i % n + 1)
	end
	if oldLength < newLength then
		for i = 1, n do
			path[i] = nodes[i]
		end
	else
		local meta
		if metadata then
			meta = {}
		end
		for i = 1, n do
			path[i] = nodes[tour[i]]
			if metadata then
				meta[i] = metadata[tour[i]]
			end
		end
		metadata = meta
	end

	local length = TSP:PathLength(path, zoneID)
	if nonblocking then
		startTime = GetTime() - startTime
	else
		startTime = (debugprofilestop() - startTime) / 1000
	end
	return path, metadata, length, moves, startTime
end


-----------------------------------
-- TSP:SolveTSP(nodes, metadata, zoneID, parameters, path, nonblocking)
-- Arguments
--   nodes       - The table containing a list of Routes node IDs to path
--                 This list should only contain nodes on the same map. This
--                 table should be indexed numerically from nodes[1] to nodes[n].
--   metadata    - The table containing the cluster metadata, if available
--   taboos      - A table containing a table of taboo regions to use.
--   zoneID      - The map area ID of the map that the route is to be generated on.
--   parameters  - The table containing the ACO parameters to use.
--   path        - An optional input table that is used to supply the result
--                 table. If this is nil, the function returns a new table.
--   nonblocking - A boolean to indicate whether the function should yield() regularly.
-- Returns
--   path        - The result TSP path is a table indexed numerically from path[1]
--                 to path[n], a list of Routes node IDs.
--   metadata    - The table containing the cluster metadata, if available
--   length      - The length in yards of the path returned.
--   iteration   - Number of interations taken.
--   timeTaken   - Number of seconds used.
-- Notes: A new nodes[] and metadata[] table is returned. The original tables
--        sent in are unmodified.
function TSP:SolveTSP(nodes, metadata, taboos, zoneID, parameters, path, nonblocking)
	-- Notes: Some of these code might look convoluted, with seemingly unnecessary use of too many locals
	-- and make the code look longer. But they are for speed optimization.
	assert(type(nodes) == "table", "SolveTSP() expected table in 1st argument, got "..type(nodes).." instead.")
	assert(type(taboos) == "table", "SolveTSP() expected table in 3rd argument, got "..type(taboos).." instead.")
	assert(type(parameters) == "table", "SolveTSP() expected table in 5th argument, got "..type(parameters).." instead.")
	if type(path) == "table" then
		wipe(path)
	else
		path = {}
	end

	if nonblocking then
		-- Ensure that at least 1 yield() is called in a nonblocking call
		coroutine.yield()
	end

	-- Check for trivial problem of 3 or less nodes
	local numNodes = #nodes
	if numNodes < 4 then
		-- Trivial solution for an input size of 3 or less nodes
		for i = 1, numNodes do
			path[i] = nodes[i]
		end
		-- Create a copy of the metadata[] table too, if there is one
		local metadata2
		if metadata then
			metadata2 = {}
			for i = 1, numNodes do
				metadata2[i] = {}
				for j = 1, #metadata[i] do
					metadata2[i][j] = metadata[i][j]
				end
			end
		end
		return path, metadata2, TSP:PathLength(path, zoneID), 0, 0
	end

	-- Create a copy of the nodes[] table and use this instead of the original because data could get changed
	local nodes2 = {}
	for i = 1, numNodes do
		nodes2[i] = nodes[i]
	end
	local nodes = nodes2
	-- Create a copy of the metadata[] table too, if there is one
	local metadata2
	if metadata then
		metadata2 = {}
		for i = 1, numNodes do
			metadata2[i] = {}
			for j = 1, #metadata[i] do
				metadata2[i][j] = metadata[i][j]
			end
		end
	end
	local metadata = metadata2
	
	-- Setup ACO parameters
	local startTime
	if nonblocking then
		startTime = GetTime()
	else
		startTime = debugprofilestop()
	end
	if numNodes > MAX_ACO_NODES then
		-- too many nodes for the NxN tables used below
		return SolveLarge(nodes, metadata, taboos, zoneID, path, nonblocking, startTime)
	end
	local zoneW, zoneH	= Routes.Dragons:GetZoneSize(zoneID)

	local INITIAL_PHEROMONE = parameters.initial_pheromone or 0.1   -- Parameter: Initial pheromone trail value
	local ALPHA             = parameters.alpha or 1                 -- Parameter: Likelihood of ants to follow pheromone trails (larger value == more likely)
	local BETA              = parameters.beta or 6                  -- Parameter: Likelihood of ants to choose closer nodes (larger value == more likely)
	local LOCALDECAY        = parameters.local_decay or 0.2         -- Parameter: Governs local trail decay rate [0, 1]
	local LOCALUPDATE       = parameters.local_update or 0.4        -- Parameter: Amount of pheromone to reinforce local trail update by
	local GLOBALDECAY       = parameters.global_decay or 0.2        -- Parameter: Governs global trail decay rate [0, 1]
	local TWOOPTPASSES      = parameters.twoopt_passes or 3         -- Parameter: Number of times to perform 2-opt passes
	local TWOPOINTFIVEOPT   = parameters.two_point_five_opt or false-- Parameter: Run improved 2-opt pass?
	local QUALITY           = 2 * zoneH                             -- Parameter: Tunable parameter that should be somewhat close to 1/4 to 1/2 (distance) of a good solution
	local numAnts           = ceil(2 * numNodes ^ 0.5)              -- Parameter: Number of ants.
	local LOCALDECAYUPDATE  = LOCALDECAY * LOCALUPDATE              -- Just a constant.
	-- If ALPHA = 0, the closest cities are more likely to be selected.
	-- If BETA = 0, only pheromone amplifications is at work.
	-- The number of ants will directly determine the speed of the algorithm proportionally. More ants will get more optimal results, but don't use more ants than the number of nodes.
	-- You need more ants when there are more nodes to have more chances to find a good path quickly. The usual default is numAnts = numNodes, but this takes too long in WoW.
	local PRUNEDIST         = zoneW * 0.30                          -- Another constant for our own pruning

	local shortestPathLength = math.huge
	local shortestPath = {}

	-- Step 1	- Initialize and generate the weight matrix, the pheromone matrix and the ants
	local weight = {}
	local phero = {}
	local ants = {}
	local prune = {}
	local antprob = {}
	for i = 1, numNodes do
		prune[i] = {}
	end

	for i = 1, numNodes do
		local x1, y1 = floor(nodes[i] / 10000) / 10000, (nodes[i] % 10000) / 10000
		local u = i*numNodes-i
		weight[u] = 0
		phero[u] = INITIAL_PHEROMONE
		for j = i+1, numNodes do
			local x2, y2 = floor(nodes[j] / 10000) / 10000, (nodes[j] % 10000) / 10000
			local u, v = i*numNodes-j, j*numNodes-i
			weight[u] = (((x2 - x1)*zoneW)^2 + ((y2 - y1)*zoneH)^2)^0.5 -- Calc distance between each node pair
			weight[v] = weight[u]
			phero[u] = INITIAL_PHEROMONE -- All pheromone trails start
			phero[v] = INITIAL_PHEROMONE -- with a initial small value
			-- Table containing data for 2-opt pruning operations. This is just a list of nodes that are near each node.
			if weight[u] < PRUNEDIST then
				tinsert(prune[i], j)
				tinsert(prune[j], i)
			end
			-- For taboo regions
			local flag = false
			for m = 1, #taboos do -- loop over every taboo
				local taboo_data = taboos[m].route
				local last_point = taboo_data[ #taboo_data ]
				local sx, sy = floor(last_point / 10000) / 10000, (last_point % 10000) / 10000
				for n = 1, #taboo_data do
					local point = taboo_data[n]
					local ex, ey = floor(point / 10000) / 10000, (point % 10000) / 10000
					-- inlined the intersection check so that it is faster
					local dx = x2-x1
					local dy = y2-y1
					local numer = dx*(sy-y1) - dy*(sx-x1)
					local demon = dx*(sy-ey) + dy*(ex-sx)
					if demon ~= 0 and dx ~= 0 then
						local u = numer / demon
						local t = (sx + (ex-sx)*u - x1)/dx
						if u >= 0 and u <= 1 and t >= 0 and t <= 1 then
							flag = true
							break
						end
					end
					sx, sy = ex, ey
					last_point = point
				end
				if flag then break end
			end
			if flag then -- we increase/bias the weight by a constant factor and by the zone width, since it passes thru a taboo region
				weight[u] = weight[u] * 2 + zoneW
				weight[v] = weight[u]
			end

			-- Initialize the probability table of travelling from city i to j
			antprob[u] = phero[u] ^ ALPHA / weight[u] ^ BETA
			antprob[v] = antprob[u]
		end
	end
	for k = 1, numAnts do
		ants[k] = {}
		local antpath = ants[k] -- This table will stores both the partially constructed path (from 1 to j) and the remainder unvisited nodes (from j+1 to N)
		for j = 1, numNodes do
			antpath[j] = j
		end
	end

	-- Step 2	- Loop until path has small to no changes over the last MAXUNCHANGEDINTERATION iterations
	local nochanges = 0
	local count = 0
	local MAXUNCHANGEDINTERATION = 3
	if numAnts >= 25 then
		MAXUNCHANGEDINTERATION = 2
	end
	while nochanges < MAXUNCHANGEDINTERATION do
		nochanges = nochanges + 1
		count = count + 1
		
		-- Step 3	- Each ant k starts at a randomly selected node
		for k = 1, numAnts do
			local antpath = ants[k]
			local p = random(numNodes)
			antpath[1], antpath[p] = antpath[p], antpath[1]
		end

		-- Step 4	- Construct/path the next N-1 nodes...
		for j = 1, numNodes-1 do
			-- Step 5	- ...for each ant k
			for k = 1, numAnts do
				-- Step 6	- Calculate the probability of visiting each remainder node, and the total probability
				local antpath = ants[k]
				local curnode = antpath[j] -- j is the "current node" index in the path
				local totalprob = 0
				for i = j+1, numNodes do
					local u = curnode*numNodes-antpath[i]
					totalprob = totalprob + antprob[u]
				end
				-- Step 7	- Now randomly choose one of these nodes to go to based on the calculated probabilities
				local p = totalprob * random()
				totalprob = 0
				for i = j+1, numNodes do
					local u = curnode*numNodes-antpath[i]
					totalprob = totalprob + antprob[u]
					if p <= totalprob then
						antpath[j+1], antpath[i] = antpath[i], antpath[j+1]
						phero[u] = (1 - LOCALDECAY) * phero[u] + LOCALDECAYUPDATE -- Perform local pheromone update
						antprob[u] = phero[u] ^ ALPHA / weight[u] ^ BETA -- Update the probability
						break
					end
				end
			end
			if nonblocking then
				yield()
			end
		end

		for k = 1, numAnts do
			-- Send out status update if requested  (this loop is the one that actually takes lots of time)
			if nonblocking and TSPUpdateFrame.statusFunc then
				TSPUpdateFrame.statusFunc(count, (k-1)/numAnts)
			end
			-- Step 8	-- Perform local pheromone update on the path from the last node to the first node for each ant k
			local antpath = ants[k]
			local curnode = antpath[numNodes]
			local nextnode = antpath[1]
			local u = curnode*numNodes-nextnode
			phero[u] = (1 - LOCALDECAY) * phero[u] + LOCALDECAYUPDATE
			antprob[u] = phero[u] ^ ALPHA / weight[u] ^ BETA

			-- Step 9	-- Perform 2-opt on the path to improve it
			--[[for i = 1, TWOOPTPASSES do
				if nonblocking then
					yield()
				end
				if TSP:TwoOpt(antpath, weight, prune) == 0 then
					break
				end
			end]]
			while TSP:TwoOpt(antpath, weight, prune, TWOPOINTFIVEOPT, nonblocking) > 0 do
				-- Cycle the last 3 nodes so that the 2-opt algorithm will work on the last
				-- 3 nodes in the path that got missed (the loop goes from 1 to N-3)
				tinsert(antpath, tremove(antpath, 1))
				tinsert(antpath, tremove(antpath, 1))
				tinsert(antpath, tremove(antpath, 1))
				if nonblocking then
					yield()
				end
			end

			-- Step 10	-- At the same time, we also calculate the length of each ant's tour
			local pathLength = 0
			curnode = antpath[numNodes]
			for i = 1, numNodes do
				nextnode = antpath[i]
				pathLength = pathLength + weight[curnode*numNodes-nextnode]
				curnode = nextnode
			end

			-- Step 11	-- If this ant's path is shorter than the global shortest known solution, copy it
			if pathLength < shortestPathLength then
				shortestPathLength = pathLength
				for i = 1, numNodes do
					shortestPath[i] = antpath[i]
				end
				nochanges = 0 -- There were changes, so reset nochanges counter to 0
			end
		
		end
			
		-- Step 12	- Perform global pheromone trail update on the best known solution
		local curnode = shortestPath[numNodes]
		local tempConstant = GLOBALDECAY * QUALITY / shortestPathLength
		for i = 1, numNodes do
			local nextnode = shortestPath[i]
			local u = curnode*numNodes-nextnode
			phero[u] = (1 - GLOBALDECAY) * phero[u] + tempConstant
			antprob[u] = phero[u] ^ ALPHA / weight[u] ^ BETA -- Update the probability
			curnode = nextnode
		end
		
		-- report how long path this round found (with progress==1)
		if nonblocking and TSPUpdateFrame.statusFunc then
			TSPUpdateFrame.statusFunc(count, 1, shortestPathLength)
			yield()
		end
	end

	do
		-- Perform a non-pruned 2-opt on the final path so that there is absolutely no criss-cross
		local noprune = {}
		for i = 1, numNodes do
			noprune[i] = {}
		end
		for i = 1, numNodes do
			for j = i+1, numNodes do
				tinsert(noprune[i], j)
				tinsert(noprune[j], i)
			end
		end
		while TSP:TwoOpt(shortestPath, weight, noprune, TWOPOINTFIVEOPT, nonblocking) > 0 do
			tinsert(shortestPath, tremove(shortestPath, 1))
			tinsert(shortestPath, tremove(shortestPath, 1))
			tinsert(shortestPath, tremove(shortestPath, 1))
			if nonblocking then
				yield()
			end
		end
		
		-- Recompute the path length
		shortestPathLength = 0
		local curnode = shortestPath[numNodes]
		for i = 1, numNodes do
			local nextnode = shortestPath[i]
			shortestPathLength = shortestPathLength + weight[curnode*numNodes-nextnode]
			curnode = nextnode
		end
	end

	-- Step 13	-- Check the length of the original tour that was sent in in nodes[]
	local pathLength = 0
	for i = 2, numNodes do
		pathLength = pathLength + weight[(i-1)*numNodes-i]
	end
	pathLength = pathLength + weight[numNodes*numNodes-1]

	-- Step 14	-- Check solution with original that was sent in
	if pathLength < shortestPathLength then
		-- TSP didn't find a shorter solution, so copy the input to the output
		for i = 1, numNodes do
			path[i] = nodes[i]
		end
		shortestPathLength = pathLength
	else
		-- TSP found a shorter path than the original, convert our shortest path to the output format wanted
		local meta
		if metadata then
			meta = {}
		end
		for i = 1, numNodes do
			path[i] = nodes[shortestPath[i]]
			if metadata then
				meta[i] = metadata[shortestPath[i]]
			end
		end
		metadata = meta -- prev metadata[] not recycled here, will go out of scope at function end and get GCed
	end

	lastpath = nil

	-- This step is necessary because our pathlength above is calculated from biased data from taboos
	shortestPathLength = TSP:PathLength(path, zoneID)

	if nonblocking then
		startTime = GetTime() - startTime
	else
		startTime = debugprofilestop() - startTime
		startTime = startTime / 1000
	end
	return path, metadata, shortestPathLength, count, startTime
end

-- TSP:TwoOpt(path, weight)
-- Arguments
--   path   - The table containing a TSP path to improve. Input must have node IDs 1-N, numerically indexed.
--   weight - The table containing the NxN weight matrix.
--   prune  - The table containing the list of neighbouring nodes for each node.
--   twoPointFiveOpt - A boolean indicating whether to perform 2.5-opt.
--   nonblocking - A boolean indicating whether the function should yield() regularly.
-- Returns
--   count  - The number of 2-opt replacements made to path[]
--[[
Typically TSP tour refinement takes place by "flipping" edges. For example, if
the tour contains the edges (v1, w1) and (w2, v2) in that order, then these two
edges can always be flipped to create (v1, w2) and (w1, v2). This sort of step
forms the basis of the 2-opt algorithm which is a steepest descent approach,
repeatedly flipping pairs of edges if they improve the tour quality until it
reaches a local minimum of the objective function and no more such flips exist.

In a similar vein, the 3-opt algorithm exchanges 3 edges at a time. These are
more specific versions of the Lin-Kernighan (LK) algorithm or better known as
the N-opt or variable-opt algorithm.

-- A Multilevel Lin-Kernighan-Helsgaun Algorithm for the Travelling Salesman Problem
-- Chris Walshaw, September 27, 2001.
]]
function TSP:TwoOpt(path, weight, prune, twoPointFiveOpt, nonblocking)
	local count = 0
	local numNodes = #path
	local pathR = pathR

	-- Generate reverse lookup table
	if lastpath ~= path then
		for i = 1, numNodes do
			pathR[path[i]] = i
		end
	end

	-- Perform normal 2-opt
	for i = 1, numNodes-3 do
		local a, b = path[i], path[i+1]
		local z = weight[a*numNodes-b]
		--for j = i+2, numNodes-1 do
		for m = 1, #prune[a] do
			local j = pathR[prune[a][m]]
			if j > i+1 and j ~= numNodes then
				local c, d = path[j], path[j+1]
				local currW = z + weight[c*numNodes-d]
				local newW = weight[a*numNodes-c] + weight[b*numNodes-d]
				if newW < currW then
					-- Swap these 2 edges to get a shorter path
					-- This is done by reversing the node order between i+1 to j
					local left = i+1
					local right = j
					while left < right do
						local L, R = path[right], path[left]
						path[left], path[right] = L, R
						pathR[L], pathR[R] = left, right
						left = left + 1
						right = right - 1
					end
					b = path[i+1]
					z = weight[a*numNodes-b]
					count = count + 1
				end
			end
		end
	end

	-- Then perform 2.5-opt
	if twoPointFiveOpt then
		if nonblocking then
			yield()
		end
		for i = 1, numNodes-4 do
			local a, b, c = path[i], path[i+1], path[i+2]
			local z = weight[a*numNodes-b] + weight[b*numNodes-c]
			for m = 1, #prune[a] do
				local j = pathR[prune[a][m]]
				if j > i+2 and j ~= numNodes then
					local d, e = path[j], path[j+1]
					local currW = z + weight[d*numNodes-e]
					local newW = weight[a*numNodes-c] + weight[d*numNodes-b] + weight[b*numNodes-e]
					if newW < currW then
						-- Remove node b from the path, then reinsert it between d and e
						for q = i+1, j-1 do
							path[q] = path[q+1]
							pathR[path[q]] = q
						end
						path[j] = b
						pathR[b] = j
						b, c = path[i+1], path[i+2]
						z = weight[a*numNodes-b] + weight[b*numNodes-c]
						count = count + 1
					end
				end
			end
		end
	end

	lastpath = path
	return count
end

-- Helper function for TSP:InsertNode()
-- Tries to insert node into an existing cluster
-- Returns true if successful, false otherwise
local function tryInsert(nodes, metadata, insertPoint, nodeID, radius, zoneW, zoneH)
	local x, y = floor(nodeID / 10000) / 10000, (nodeID % 10000) / 10000
	local x2, y2 = floor(nodes[insertPoint] / 10000) / 10000, (nodes[insertPoint] % 10000) / 10000
	-- Calculate the new centroid and coord
	local num = #metadata[insertPoint]
	x2, y2 = (x2*num+x)/(num+1), (y2*num+y)/(num+1)
	local coord = floor(x2 * 10000 + 0.5) * 10000 + floor(y2 * 10000 + 0.5)
	x2, y2 = floor(coord / 10000) / 10000, (coord % 10000) / 10000 -- to round off the coordinate
	-- Check that the merged point is valid
	for i = 1, num do
		local coord = metadata[insertPoint][i]
		local x, y = floor(coord / 10000) / 10000, (coord % 10000) / 10000
		local t = (((x2 - x)*zoneW)^2 + ((y2 - y)*zoneH)^2)^0.5
		if t > radius then
			return false
		end
	end
	tinsert(metadata[insertPoint], nodeID)
	nodes[insertPoint] = coord
	return true
end

-- TSP:InsertNode(nodes, zoneID, nodeID, twoOpt, path)
--   Inserts a node into an existing route.
-- Arguments
--   nodes       - The table containing a list of Routes node IDs to path
--                 This list should only contain nodes on the same map. This
--                 table should be indexed numerically from nodes[1] to nodes[n].
--   metadata    - The table containing the cluster metadata, if available
--   zoneID      - The map area ID of the map that the route is on.
--   nodeID      - The Routes node ID to insert into the route.
-- Returns
--   pathLength  - The length of the route in yards.
-- Notes: This function modifies the original nodes[] and metadata[] tables
--        directly
function TSP:InsertNode(nodes, metadata, zoneID, nodeID, radius)
	assert(type(nodes) == "table", "InsertNode() expected table in 1st argument, got "..type(nodes).." instead.")

	-- Check for trivial problem of 2 or less nodes
	local numNodes = #nodes
	if numNodes < 3 then
		-- Trivial solution for an input size of 2 or less nodes
		nodes[numNodes+1] = nodeID
		if metadata then
			metadata[numNodes+1] = {nodeID}
		end
		return TSP:PathLength(nodes, zoneID)
	end

	-- Insert the node to be added at the end of the list.
	tinsert(nodes, nodeID)
	numNodes = #nodes

	-- Step 1	- Initialize and generate the weight matrix, and prune matrix if doing 2-opt
	local zoneW, zoneH = Routes.Dragons:GetZoneSize(zoneID)
	local weight = {}

	-- Not doing a twoopt means we only need to generate O(2n) entries in the weight table
	local x, y, x2, y2
	for i = 1, numNodes-2 do
		-- for every node i, calculate its distance to node i+1
		x, y = floor(nodes[i] / 10000) / 10000, (nodes[i] % 10000) / 10000
		x2, y2 = floor(nodes[i+1] / 10000) / 10000, (nodes[i+1] % 10000) / 10000
		weight[i*numNodes-(i+1)] = (((x2 - x)*zoneW)^2 + ((y2 - y)*zoneH)^2)^0.5 -- Calc distance
	end
	-- do looparound node
	x, y = floor(nodes[numNodes-1] / 10000) / 10000, (nodes[numNodes-1] % 10000) / 10000
	x2, y2 = floor(nodes[1] / 10000) / 10000, (nodes[1] % 10000) / 10000
	weight[(numNodes-1)*numNodes-1] = (((x2 - x)*zoneW)^2 + ((y2 - y)*zoneH)^2)^0.5 -- Calc distance
	-- calc distance for every node to the node to be inserted
	x2, y2 = floor(nodes[numNodes] / 10000) / 10000, (nodes[numNodes] % 10000) / 10000
	for i = 1, numNodes-1 do
		x, y = floor(nodes[i] / 10000) / 10000, (nodes[i] % 10000) / 10000
		local u, v = i*numNodes-numNodes, numNodes*numNodes-i
		weight[u] = (((x2 - x)*zoneW)^2 + ((y2 - y)*zoneH)^2)^0.5 -- Calc distance
		weight[v] = weight[u]
	end

	-- Step 2	- Find the best place to insert the node
	local shortestPathLength = math.huge -- Some large value
	local insertPoint
	for i = 1, numNodes-2 do
		local z = weight[i*numNodes-numNodes] + weight[numNodes*numNodes-(i+1)] - weight[i*numNodes-(i+1)]
		if z < shortestPathLength then
			shortestPathLength = z
			insertPoint = i + 1
		end
	end
	if weight[(numNodes-1)*numNodes-numNodes] + weight[numNodes*numNodes-1] - weight[(numNodes-1)*numNodes-1] < shortestPathLength then
		-- Do nothing, inserting the node at the last place is the best, already inserted here.
		if metadata then
			tremove(nodes)
			local try1, try2 = numNodes-1, 1
			if weight[(numNodes-1)*numNodes-numNodes] > weight[numNodes*numNodes-1] then
				try1, try2 = try2, try1 -- try the closer node first
			end
			local flag = tryInsert(nodes, metadata, try1, nodeID, radius, zoneW, zoneH)
			if not flag then
				flag = tryInsert(nodes, metadata, try2, nodeID, radius, zoneW, zoneH)
			end
			if not flag then -- both clusters failed, so insert a new cluster
				tinsert(nodes, nodeID)
				tinsert(metadata, {nodeID})
			end
		end
	else
		-- Remove it from the last place in the path and insert it at the best place found.
		tremove(nodes)
		if metadata then
			local try1, try2 = insertPoint-1, insertPoint
			if weight[(insertPoint-1)*numNodes-numNodes] > weight[numNodes*numNodes-insertPoint] then
				try1, try2 = try2, try1
			end
			local flag = tryInsert(nodes, metadata, try1, nodeID, radius, zoneW, zoneH)
			if not flag then
				flag = tryInsert(nodes, metadata, try2, nodeID, radius, zoneW, zoneH)
			end
			if not flag then
				tinsert(nodes, insertPoint, nodeID)
				tinsert(metadata, insertPoint, {nodeID})
			end
		else
			tinsert(nodes, insertPoint, nodeID)
		end
	end

	return TSP:PathLength(nodes, zoneID)
end


-- TSP:PathLength(nodes, zoneID)
--   Returns how long a given route is in yards.
-- Arguments
--   nodes      - The table containing a list of Routes node IDs to path
--                This list should only contain nodes on the same map. This
--                table should be indexed numerically from nodes[1] to nodes[n].
--   zoneID     - The map area ID of the map that the route is on.
-- Returns
--   pathLength - The length of the route in yards.
function TSP:PathLength(nodes, zoneID)
	assert(type(nodes) == "table", "PathLength() expected table in 1st argument, got "..type(nodes).." instead.")
	local zoneW, zoneH = Routes.Dragons:GetZoneSize(zoneID)
	local numNodes = #nodes
	local pathLength = 0

	-- Check for trivial problem of 1 or less nodes
	if numNodes <= 1 then
		return 0
	end

	-- Get coordinate of last node
	local x2, y2 = floor(nodes[numNodes] / 10000) / 10000, (nodes[numNodes] % 10000) / 10000
	for i = 1, #nodes do
		local x, y = floor(nodes[i] / 10000) / 10000, (nodes[i] % 10000) / 10000
		pathLength = pathLength + (((x2 - x)*zoneW)^2 + ((y2 - y)*zoneH)^2)^0.5
		x2, y2 = x, y
	end

	return pathLength
end

-- TSP:ClusterRoute(nodes, zoneID, radius)
-- Arguments
--   nodes    - The table containing a list of Routes node IDs to path
--              This list should only contain nodes on the same map. This
--              table should be indexed numerically from nodes[1] to nodes[n].
--   zoneID   - The map area ID the route is in
--   radius   - The radius in yards to cluster
-- Returns
--   path     - The result TSP path is a table indexed numerically from path[1]
--              to path[n], a list of Routes node IDs. n is usually smaller than
--              the original input
--   metadata - The metadata table for path[] containing the original nodes
--              clustered
--   length   - The length of the new route in yards
-- Notes: The original table sent in is unmodified. New tables are returned.
--[[
Hierarchical Agglomerative Clustering

Data clustering algorithms can be hierarchical or partitional. Hierarchical
algorithms find successive clusters using previously established clusters,
whereas partitional algorithms determine all clusters at once. Hierarchical
algorithms can be agglomerative ("bottom-up") or divisive ("top-down").
Agglomerative algorithms begin with each element as a separate cluster and
merge them into successively larger clusters. Divisive algorithms begin with
the whole set and proceed to divide it into successively smaller clusters.

This method (Agglomerative) builds the hierarchy from the individual elements
by progressively merging clusters. The first step is to determine which
elements to merge in a cluster. Usually, we want to take the two closest
elements, according to the chosen distance.

Optionally, one can also construct a distance matrix at this stage, where the
number in the i-th row j-th column is the distance between the i-th and j-th
elements. Then, as clustering progresses, rows and columns are merged as the
clusters are merged and the distances updated. This is a common way to
implement this type of clustering, and has the benefit of catching distances
between clusters.

-- From Wikipedia, Cluster analysis
-- http://en.wikipedia.org/wiki/Cluster_analysis
-- 25 January 2008
]]
function TSP:ClusterRoute(nodes, zoneID, radius, nonblocking)
	local numNodes = #nodes
	local zoneW, zoneH = Routes.Dragons:GetZoneSize(zoneID)
	local diameter = radius * 2

	-- Per cluster data, indexed by the original node index. Clusters that get merged away are
	-- flagged inactive instead of being removed, so indices stay stable and the original order is kept.
	local coords, metadata, nx, ny, active = {}, {}, {}, {}, {}
	-- version[i] is bumped whenever cluster i changes, which invalidates its old taboos
	local version = {}
	-- nn[i] is the closest cluster cluster i may merge with, nnd[i] the distance to it
	local nn, nnd = {}, {}
	-- taboo[i][j] holds the versions of i and j for which merging them failed
	local taboo = {}

	-- Spatial grid with cells the size of the merge diameter, so only clusters
	-- in the surrounding 3x3 cells need to be looked at for merge candidates
	local cellSize = diameter > 0 and diameter or 1
	local grid = {}
	local function cellPos(i)
		return floor(nx[i] * zoneW / cellSize), floor(ny[i] * zoneH / cellSize)
	end
	local function gridAdd(i)
		local cx, cy = cellPos(i)
		local key = cx * 1000000 + cy
		local cell = grid[key]
		if not cell then
			cell = {}
			grid[key] = cell
		end
		cell[i] = true
	end
	local function gridRemove(i)
		local cx, cy = cellPos(i)
		grid[cx * 1000000 + cy][i] = nil
	end

	local function distance(i, j)
		return (((nx[j] - nx[i])*zoneW)^2 + ((ny[j] - ny[i])*zoneH)^2)^0.5
	end
	local function isTabooed(i, j)
		local t = taboo[i] and taboo[i][j]
		return t and t[1] == version[i] and t[2] == version[j]
	end
	local function setTaboo(i, j)
		taboo[i] = taboo[i] or {}
		taboo[j] = taboo[j] or {}
		taboo[i][j] = {version[i], version[j]}
		taboo[j][i] = {version[j], version[i]}
	end
	-- is j a better merge candidate for i than its current one (ties go to the lower index)
	local function isCloser(i, j, d)
		return d <= diameter and (d < nnd[i] or (d == nnd[i] and j < nn[i])) and not isTabooed(i, j)
	end
	local function findNearest(i)
		nn[i], nnd[i] = nil, inf
		local cx, cy = cellPos(i)
		for gx = cx-1, cx+1 do
			for gy = cy-1, cy+1 do
				local cell = grid[gx * 1000000 + gy]
				if cell then
					for j in pairs(cell) do
						if j ~= i then
							local d = distance(i, j)
							if isCloser(i, j, d) then
								nn[i], nnd[i] = j, d
							end
						end
					end
				end
			end
		end
	end

	-- Step 1: Setup the clusters, one per node, and find their closest neighbours
	for i = 1, numNodes do
		local coord = nodes[i]
		coords[i] = coord
		metadata[i] = { coord }
		nx[i], ny[i] = floor(coord / 10000) / 10000, (coord % 10000) / 10000
		active[i] = true
		version[i] = 0
		gridAdd(i)
	end
	for i = 1, numNodes do
		findNearest(i)
		if nonblocking then
			yield()
		end
	end

	-- ensure one yield is always called
	if nonblocking then
		coroutine.yield()
	end

	-- Step 4: ...and loop until there is no such pair of nodes
	while true do
		-- Step 2: Find the closest pair of nodes within the merge radius
		local node1, smallestDist = nil, inf
		for i = 1, numNodes do
			if active[i] and nnd[i] < smallestDist then
				node1, smallestDist = i, nnd[i]
			end
		end
		if not node1 then
			break -- loop termination
		end
		local node2 = nn[node1]
		if node2 < node1 then
			node1, node2 = node2, node1 -- the lower index survives, to keep the route order
		end

		-- Step 3: Merge node2 into node1...
		local m1, m2 = metadata[node1], metadata[node2]
		local node1num, node2num = #m1, #m2
		local totalnum = node1num + node2num
		-- Calculate the new centroid of node1
		local node1x = ( nx[node1] * node1num + nx[node2] * node2num ) / totalnum
		local node1y = ( ny[node1] * node1num + ny[node2] * node2num ) / totalnum
		-- Calculate the new coord from the new (x,y)
		local coord = floor(node1x * 10000 + 0.5) * 10000 + floor(node1y * 10000 + 0.5)
		node1x, node1y = floor(coord / 10000) / 10000, (coord % 10000) / 10000 -- to round off the coordinate
		-- Check that the merged point is valid, ie. not too far away from any of the original points
		local valid = true
		for m = 1, 2 do
			local members = m == 1 and m1 or m2
			for i = 1, #members do
				local c = members[i]
				local x, y = floor(c / 10000) / 10000, (c % 10000) / 10000
				if (((node1x - x)*zoneW)^2 + ((node1y - y)*zoneH)^2)^0.5 > radius then
					valid = false
					break
				end
			end
			if not valid then break end
		end

		if not valid then
			-- Merging would move the point too far away from an original point, so taboo
			-- this pair until either of them changes
			setTaboo(node1, node2)
			findNearest(node1)
			findNearest(node2)
		else
			-- Merge the metadata of node2 into node1
			for i = 1, node2num do
				m1[#m1+1] = m2[i]
			end
			-- Remove node2, and move node1 to its new coord
			gridRemove(node1)
			gridRemove(node2)
			active[node2] = false
			nn[node2], nnd[node2] = nil, inf
			metadata[node2] = nil
			coords[node1] = coord
			nx[node1], ny[node1] = node1x, node1y
			version[node1] = version[node1] + 1 -- this can untaboo nodes
			gridAdd(node1)
			findNearest(node1)
			-- Update everything that wanted to merge with node1 or node2, or is now closer to node1
			for k = 1, numNodes do
				if active[k] and k ~= node1 then
					if nn[k] == node1 or nn[k] == node2 then
						findNearest(k)
					else
						local d = distance(k, node1)
						if isCloser(k, node1, d) then
							nn[k], nnd[k] = node1, d
						end
					end
				end
			end
		end

		if nonblocking then
			yield()
		end
	end

	-- Collect the remaining clusters in their original order
	local newNodes, newMetadata = {}, {}
	for i = 1, numNodes do
		if active[i] then
			newNodes[#newNodes+1] = coords[i]
			newMetadata[#newMetadata+1] = metadata[i]
		end
	end

	-- Get the new pathLength
	local count = #newNodes
	local pathLength = 0
	for i = 1, count do
		local c1, c2 = newNodes[i], newNodes[i % count + 1]
		local x1, y1 = floor(c1 / 10000) / 10000, (c1 % 10000) / 10000
		local x2, y2 = floor(c2 / 10000) / 10000, (c2 % 10000) / 10000
		pathLength = pathLength + (((x2 - x1)*zoneW)^2 + ((y2 - y1)*zoneH)^2)^0.5
	end

	return newNodes, newMetadata, pathLength
end

function TSP:ClusterRouteBackground(nodes, zoneID, radius, finishFunc)
	if not TSPClusterFrame.running then
		TSPClusterFrame.co = coroutine.create(TSP.ClusterRoute)
		TSPClusterFrame.finishFunc = finishFunc
		TSPClusterFrame:SetScript("OnUpdate", TSPClusterFrame.OnUpdate)
		TSPClusterFrame.running = true
		local status = coroutine.resume(TSPClusterFrame.co, TSP, nodes, zoneID, radius, true)
		if status then
			-- Do nothing, path isn't complete because at least 1 yield() is called.
			return 1
		else
			-- An error occured in the coroutine, abort and return the error message.
			TSPClusterFrame.running = false
			TSPClusterFrame:SetScript("OnUpdate", nil)
			TSPClusterFrame.co = nil
			return 3
		end
	else
		return 2
	end
end

-- TSP:DecrossRoute(nodes)
-- Arguments
--   nodes    - The table containing a list of Routes node IDs to path
--              This list should only contain nodes on the same map. This
--              table should be indexed numerically from nodes[1] to nodes[n].
-- Returns nothing
-- Notes: The original table sent in is modified directly
-- 
-- This function is contributed by Polarina for quickly solving a TSP in
-- O(n log n). The method merely calculates a centroid, and compares the angle
-- of every node with the centroid and sorts it that way, resulting in a tour
-- that doesn't cross itself, but obviously not ideal. Used for initial route
-- creation to get an initial quality value.
function TSP:DecrossRoute(nodes)
	local numNodes = #nodes
	local math_atan2 = math.atan2

	-- Find the nodes centroid
	local x, y = 0, 0
	for index, value in ipairs(nodes) do
		x = x + floor(value / 1e4)
		y = y + value % 1e4
	end
	x = x / numNodes
	y = y / numNodes

	-- From the middle, link all nodes in a circle
	table.sort(nodes, function(a, b)
		local aX = floor(a / 1e4)
		local aY = a % 1e4
		local bX = floor(b / 1e4)
		local bY = b % 1e4
		return math_atan2(aY - y, aX - x) < math_atan2(bY - y, bX - x)
	end)

	--[[
	local weight = {}
	local path = {}
	local prune = {}
	for i = 1, numNodes do
		prune[i] = {}
	end

	for i = 1, numNodes do
		local x1, y1 = floor(nodes[i] / 10000) / 10000, (nodes[i] % 10000) / 10000
		local u = i*numNodes-i
		weight[u] = 0
		for j = i+1, numNodes do
			local x2, y2 = floor(nodes[j] / 10000) / 10000, (nodes[j] % 10000) / 10000
			local u, v = i*numNodes-j, j*numNodes-i
			weight[u] = ((x2 - x1)^2 + (y2 - y1)^2)^0.5 -- Calc distance between each node pair
			weight[v] = weight[u]
			--if weight[u] < 0.4 then
				tinsert(prune[i], j)
				tinsert(prune[j], i)
			--end
		end
		path[i] = i
	end

	while TSP:TwoOpt(path, weight, prune, false, false) > 0 do end

	local newpath = {}
	for i = 1, numNodes do
		newpath[i] = nodes[ path[i] ]
	end

	return newpath]]

	return nodes
end

-- vim: ts=4 noexpandtab
