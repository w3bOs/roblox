local httprequest = (syn and syn.request) or http and http.request or http_request or (fluxus and fluxus.request) or request
local queueonteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
local httpservice = game:GetService("HttpService")
local Players = game:GetService("Players")
local unclaimed = {}
local booths = {
    ["1"] = "72, 3, 36",
    ["2"] = "83, 3, 161",
    ["3"] = "11, 3, 36",
    ["4"] = "100, 3, 59",
    ["5"] = "72, 3, 166",
    ["6"] = "2, 3, 42",
    ["7"] = "-9, 3, 52",
    ["8"] = "10, 3, 166",
    ["9"] = "-17, 3, 60",
    ["10"] = "35, 3, 173",
    ["11"] = "24, 3, 170",
    ["12"] = "48, 3, 29",
    ["13"] = "24, 3, 33",
    ["14"] = "101, 3, 142",
    ["15"] = "-18, 3, 142",
    ["16"] = "60, 3, 33",
    ["17"] = "35, 3, 29",
    ["18"] = "0, 3, 160",
    ["19"] = "48, 3, 173",
    ["20"] = "61, 3, 170",
    ["21"] = "91, 3, 151",
    ["22"] = "-24, 3, 72",
    ["23"] = "-28, 3, 88",
    ["24"] = "92, 3, 51",
    ["25"] = "-28, 3, 112",
    ["26"] = "-24, 3, 129",
    ["27"] = "83, 3, 42",
    ["28"] = "-8, 3, 151"
}

local function antiafk()
	local Module = require(game:GetService("Players").LocalPlayer.PlayerScripts.ClientMain.Replications.Workers.WalkDummy)
	setconstant(Module,34,function()
	   game:GetService("RunService").Heartbeat:Wait()
	end)
end

local function serverHop()
    local gameId = "8737602449"
    if vcEnabled and getgenv().settings.vcServer then
        gameId = "8943844393"
    end
    local servers = {}
    local req = httprequest({Url = "https://games.roblox.com/v1/games/".. gameId.."/servers/Public?sortOrder=Desc&limit=100"})
   	local body = httpservice:JSONDecode(req.Body)
    if body and body.data then
        for i, v in next, body.data do
   	        if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.playing > 19 then
  		        table.insert(servers, 1, v.id)
 	        end 
        end
    end
    if #servers > 0 then
		game:GetService("TeleportService"):TeleportToPlaceInstance(gameId, servers[math.random(1, #servers)], Players.LocalPlayer)
    end
    game:GetService("TeleportService").TeleportInitFailed:Connect(function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(gameId, servers[math.random(1, #servers)], Players.LocalPlayer)
    end)
end
local function findUnclaimed()
    for i, v in pairs(Players.LocalPlayer.PlayerGui.MapUIContainer.MapUI.BoothUI:GetChildren()) do
        if (v.Details.Owner.Text == "unclaimed") then
            table.insert(unclaimed, tonumber(string.match(tostring(v), "%d+")))
        end
    end
end
local function boothclaim()
    require(game.ReplicatedStorage.Remotes).Event("ClaimBooth"):InvokeServer(unclaimed[1])
    if not string.find(Players.LocalPlayer.PlayerGui.MapUIContainer.MapUI.BoothUI:FindFirstChild(tostring("BoothUI".. unclaimed[1])).Details.Owner.Text, Players.LocalPlayer.DisplayName) then
        wait(5)
        if not string.find(Players.LocalPlayer.PlayerGui.MapUIContainer.MapUI.BoothUI:FindFirstChild(tostring("BoothUI".. unclaimed[1])).Details.Owner.Text, Players.LocalPlayer.DisplayName) then
            error()
        end
    end
end
local function walktobooth()
	Players.LocalPlayer.Character.Humanoid:MoveTo(Vector3.new(booths[tostring(unclaimed[1])]:match("(.+), (.+), (.+)")))
	local atBooth = false
	Players.LocalPlayer.Character.Humanoid.MoveToFinished:Connect(function(reached)
		atBooth = true
	end)
end
local function refresh()
	require(game.ReplicatedStorage.Remotes).Event("RefreshItems"):InvokeServer()
end
antiafk()
findUnclaimed()
boothclaim()
walktobooth()
refresh()
queueonteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/w3bOs/roblox/main/donateme.lua'))()")
wait(30)
serverHop()
