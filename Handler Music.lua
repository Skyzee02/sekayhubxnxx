-- Handler Music.lua - Server-side Music Handler (Global Music)
-- Versi final: sinkron dengan GUI MUsic.lua
-- Fitur: Play by ID, playlists (sample), global sound per server, queue, skip vote 10, favorites

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Ensure remote exists or create
local function ensureRemote(name)
	local r = ReplicatedStorage:FindFirstChild(name)
	if not r then
		r = Instance.new("RemoteEvent")
		r.Name = name
		r.Parent = ReplicatedStorage
	end
	return r
end

local RequestSong = ensureRemote("RequestSong")        -- client -> server
local UpdateQueue = ensureRemote("UpdateQueue")        -- server -> client
local PlaySongEvent = ensureRemote("PlaySongEvent")    -- server -> client
local UpdateFavorites = ensureRemote("UpdateFavorites")-- client <-> server
local SkipVote = ensureRemote("SkipVote")              -- client -> server (vote skip)

-- Global state
local Queue = {}        -- list of entries { song={id,title,assetId,length}, requester, requesterUserId, skipVoters = {} }
local NowPlaying = nil
local CurrentSound = nil
local Favorites = {}    -- Favorites[userId] = { ... }
local SKIP_THRESHOLD = 10

-- Example catalog and playlists (extend as needed)
local Catalog = {
	byId = {
		["118627301596738"] = { id = "118627301596738", title = "GGS.2FR", assetId = "118627301596738" },
		["133423678986106"] = { id = "133423678986106", title = "DJ BILA KAU DISAMPINGKU", assetId = "133423678986106" },
		["116390106794002"] = { id = "116390106794002", title = "Cartel MIX", assetId = "116390106794002" },
		["123456"] = { id = "123456", title = "RAVE Anthem", assetId = "123456" },
		["234567"] = { id = "234567", title = "Breakbeat Mix", assetId = "234567" },
	},
	playlists = {
		popular = {"118627301596738","133423678986106","116390106794002","123456","234567"},
		chill = {"123456"},
		edm = {"116390106794002"},
		hiphop = {"133423678986106"}
	}
}

local function getSongById(id)
	if not id then return nil end
	return Catalog.byId[tostring(id)]
end

-- send sanitized queue to clients
local function broadcastQueue()
	local serial = {}
	for i, entry in ipairs(Queue) do
		serial[i] = {
			song = { id = entry.song.id, title = entry.song.title, assetId = entry.song.assetId, length = entry.song.length },
			requester = entry.requester,
			requesterUserId = entry.requesterUserId
		}
	end
	UpdateQueue:FireAllClients(serial)
end

-- send now playing (optionally include skip status string)
local function broadcastNowPlaying(skipStatus)
	if NowPlaying then
		local n = {
			song = { id = NowPlaying.song.id, title = NowPlaying.song.title, assetId = NowPlaying.song.assetId, length = NowPlaying.song.length },
			requester = NowPlaying.requester,
			requesterUserId = NowPlaying.requesterUserId
		}
		PlaySongEvent:FireAllClients(n, skipStatus)
	else
		PlaySongEvent:FireAllClients(nil, skipStatus)
	end
end

-- destroy old sound safely
local function destroyCurrentSound()
	if CurrentSound then
		pcall(function()
			CurrentSound:Stop()
			CurrentSound:Destroy()
		end)
		CurrentSound = nil
	end
end

-- create and play global sound for entry
local function createGlobalSoundForEntry(entry)
	if not entry or not entry.song then return end

	-- cleanup previous
	destroyCurrentSound()

	local assetId = entry.song.assetId or entry.song.id
	if not assetId then
		entry.song.length = entry.song.length or 0
		return
	end

	local sound = Instance.new("Sound")
	sound.Name = "GlobalMusicSound"
	sound.Archivable = false
	sound.Looped = false
	sound.Volume = 1
	sound.SoundId = "rbxassetid://" .. tostring(assetId)
	sound.Parent = Workspace
	CurrentSound = sound

	-- play and monitor length
	pcall(function() sound:Play() end)

	-- attempt to get length after loaded
	task.spawn(function()
		local tries = 0
		while tries < 60 do -- ~6s
			local ok, len = pcall(function() return sound.TimeLength end)
			if ok and type(len) == "number" and len > 0 then
				entry.song.length = len
				break
			end
			tries = tries + 1
			task.wait(0.1)
		end
		-- broadcast now playing (so clients get length)
		broadcastNowPlaying()
	end)

	-- Ended handler
	local conn
	conn = sound.Ended:Connect(function()
		if conn then conn:Disconnect() end
		-- advance
		if #Queue > 0 then
			NowPlaying = table.remove(Queue,1)
			NowPlaying.skipVoters = {}
			createGlobalSoundForEntry(NowPlaying)
			broadcastQueue()
			broadcastNowPlaying()
		else
			NowPlaying = nil
			destroyCurrentSound()
			broadcastQueue()
			broadcastNowPlaying()
		end
	end)
end

-- function to start next
local function playNext()
	-- reset skip voters for server-wide counting
	if NowPlaying then NowPlaying.skipVoters = {} end
	if #Queue > 0 then
		NowPlaying = table.remove(Queue,1)
		NowPlaying.skipVoters = {}
		createGlobalSoundForEntry(NowPlaying)
	else
		NowPlaying = nil
		destroyCurrentSound()
	end
	broadcastQueue()
	broadcastNowPlaying()
end

-- RequestSong handler
RequestSong.OnServerEvent:Connect(function(player, payload)
	if not payload then return end

	local function enqueue(song)
		local copy = { id = tostring(song.id or song.assetId or ""), title = tostring(song.title or ("Song "..(song.id or song.assetId or "-"))), assetId = song.assetId and tostring(song.assetId) or song.id and tostring(song.id) or nil, length = song.length }
		local entry = { song = copy, requester = player.Name, requesterUserId = player.UserId, skipVoters = {} }
		table.insert(Queue, entry)
	end

	if type(payload) == "table" and payload.playlist then
		local pl = tostring(payload.playlist):lower()
		local ids = Catalog.playlists[pl]
		if ids then
			for _, id in ipairs(ids) do
				local s = getSongById(id)
				if s then enqueue(s) end
			end
		end
	elseif type(payload) == "string" then
		local s = getSongById(payload)
		if s then enqueue(s) else enqueue({id = payload, title = "Song "..payload, assetId = payload}) end
	elseif type(payload) == "table" then
		-- if id present and matches catalog, use catalog metadata
		if payload.id then
			local s = getSongById(payload.id)
			if s then enqueue(s) else enqueue(payload) end
		else
			enqueue(payload)
		end
	end

	-- if nothing playing, start now
	if not NowPlaying then
		NowPlaying = table.remove(Queue,1)
		if NowPlaying then
			NowPlaying.skipVoters = {}
			createGlobalSoundForEntry(NowPlaying)
		end
	end

	broadcastQueue()
	broadcastNowPlaying()
end)

-- Favorites toggle
UpdateFavorites.OnServerEvent:Connect(function(player, song, action)
	local uid = player.UserId
	if not Favorites[uid] then Favorites[uid] = {} end

	if action == "love" then
		local found = false
		for _, s in ipairs(Favorites[uid]) do
			if (s.assetId and song.assetId and s.assetId == song.assetId) or (s.id and song.id and s.id == song.id) then
				found = true
				break
			end
		end
		if not found then table.insert(Favorites[uid], song) end
	elseif action == "unlove" then
		for i, s in ipairs(Favorites[uid]) do
			if (s.assetId and song.assetId and s.assetId == song.assetId) or (s.id and song.id and s.id == song.id) then
				table.remove(Favorites[uid], i)
				break
			end
		end
	end

	-- push to that player
	UpdateFavorites:FireClient(player, Favorites[uid] or {})
end)

-- Skip voting
SkipVote.OnServerEvent:Connect(function(player)
	if not NowPlaying then return end
	NowPlaying.skipVoters = NowPlaying.skipVoters or {}
	if NowPlaying.skipVoters[player.UserId] then
		-- already voted
		-- optionally notify player, but we keep silent
		return
	end
	NowPlaying.skipVoters[player.UserId] = true

	local count = 0
	for _ in pairs(NowPlaying.skipVoters) do count = count + 1 end
	local status = "SKIP/PASS "..tostring(count).."/"..tostring(SKIP_THRESHOLD)

	-- broadcast with status
	broadcastNowPlaying(status)

	if count >= SKIP_THRESHOLD then
		-- immediate skip
		if CurrentSound then
			pcall(function() CurrentSound:Stop() end)
			pcall(function() CurrentSound:Destroy() end)
			CurrentSound = nil
		end
		-- advance
		if #Queue > 0 then
			NowPlaying = table.remove(Queue,1)
			if NowPlaying then NowPlaying.skipVoters = {} end
			createGlobalSoundForEntry(NowPlaying)
		else
			NowPlaying = nil
			destroyCurrentSound()
		end
		-- reset skip voters handled per NowPlaying
		broadcastQueue()
		broadcastNowPlaying()
	end
end)

-- Player events
Players.PlayerAdded:Connect(function(player)
	-- send queue
	local serial = {}
	for i, entry in ipairs(Queue) do
		serial[i] = { song = { id = entry.song.id, title = entry.song.title, assetId = entry.song.assetId, length = entry.song.length }, requester = entry.requester, requesterUserId = entry.requesterUserId }
	end
	UpdateQueue:FireClient(player, serial)

	-- send now playing
	if NowPlaying then
		local n = { song = { id = NowPlaying.song.id, title = NowPlaying.song.title, assetId = NowPlaying.song.assetId, length = NowPlaying.song.length }, requester = NowPlaying.requester, requesterUserId = NowPlaying.requesterUserId }
		PlaySongEvent:FireClient(player, n)
	else
		PlaySongEvent:FireClient(player, nil)
	end

	-- send favorites
	local fav = Favorites[player.UserId] or {}
	UpdateFavorites:FireClient(player, fav)
end)

Players.PlayerRemoving:Connect(function(player)
	-- remove their skip vote from current song if present
	if NowPlaying and NowPlaying.skipVoters then
		NowPlaying.skipVoters[player.UserId] = nil
	end
end)

-- Safety polling fallback (in case Ended missed)
task.spawn(function()
	while true do
		task.wait(1)
		if CurrentSound then
			local ok, isPlaying = pcall(function() return CurrentSound.IsPlaying end)
			if ok and not isPlaying then
				task.wait(0.25)
				if CurrentSound and (pcall(function() return CurrentSound.IsPlaying end) == false or not pcall(function() return CurrentSound.IsPlaying end)) then
					pcall(function() CurrentSound:Destroy() end)
					CurrentSound = nil
					if #Queue > 0 then
						NowPlaying = table.remove(Queue,1)
						if NowPlaying then NowPlaying.skipVoters = {} end
						createGlobalSoundForEntry(NowPlaying)
					else
						NowPlaying = nil
					end
					broadcastQueue()
					broadcastNowPlaying()
				end
			end
		end
	end
end)

print("[Handler Music] Loaded. Ready to accept requests.")
