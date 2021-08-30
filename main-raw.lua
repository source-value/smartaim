local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

local Window = Library.CreateLib("SmartAim - Phantom Forces", "GrapeTheme")
local Main = Window:NewTab("Main")

local EspTab = Window:NewTab("Chams")

local SilentSection = Main:NewSection("Silent Aim")
local EspSection = EspTab:NewSection("Chams")
local RandomSection = Main:NewSection("Random")

local BindsTab = Window:NewTab("Binds")
local BindsSection = BindsTab:NewSection("Keybinds")
local Credit = Window:NewTab("Credits")
local CreditSection = Credit:NewSection("Credits")

-------------------------------------------------------------------

BindsSection:NewKeybind("Toggle UI", "F", Enum.KeyCode.F, function()
	Library:ToggleUI()
end)

EspSection:NewButton("Enable Chams","This cannot be disabled once enabled.", function()
local color = BrickColor.new(255,0,0)
local transparency = .5

local Players = game:GetService("Players")
local function _ESP(c)
  repeat wait() until c.PrimaryPart ~= nil
  for i,p in pairs(c:GetChildren()) do
    if p.ClassName == "Part" or p.ClassName == "MeshPart" then
      if p:FindFirstChild("shit") then p.shit:Destroy() end
      local a = Instance.new("BoxHandleAdornment",p)
      a.Name = "Part"
      a.Size = p.Size
      a.Color = color
      a.Transparency = transparency
      a.AlwaysOnTop = true    
      a.Visible = true    
      a.Adornee = p
      a.ZIndex = true    

    end
  end
end
local function ESP()
  for i,v in pairs(Players:GetChildren()) do
    if v ~= game.Players.LocalPlayer then
      if v.Character then
        _ESP(v.Character)
      end
      v.CharacterAdded:Connect(function(chr)
        _ESP(chr)
      end)
    end
  end
  Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(chr)
      _ESP(chr)
    end)  
  end)
end
ESP()
end)

SilentSection:NewButton("Enable Silent Aim","This cannot be disabled once enabled.", function()
    local cur = os.clock()

local rsRunner

for i,v in pairs(getconnections(game:GetService("RunService").RenderStepped)) do
    if v.Function then
        local taskManager = debug.getupvalues(v.Function)[1]
        if type(taskManager) == "table" and rawget(taskManager, "_taskContainers") then
            rsRunner = taskManager
            break
        end
    end
end

local charStep = next(rsRunner._taskContainers.char.tasks).task

local pf = {}
pf.menu = debug.getupvalue(charStep, 27)
pf.sound = debug.getupvalue(charStep, 24)
pf.roundsystem = debug.getupvalue(charStep, 17)
pf.cframe = debug.getupvalue(charStep, 15)
pf.char = debug.getupvalue(charStep, 3)
pf.camera = debug.getupvalue(charStep, 2)
pf.network = debug.getupvalue(pf.char.setmovementmode, 20)
pf.hud = debug.getupvalue(pf.char.setmovementmode, 10)
pf.input = debug.getupvalue(pf.char.setmovementmode, 17)
pf.gamelogic = debug.getupvalue(pf.char.setsprint, 1)
pf.replication = debug.getupvalue(pf.hud.attachflag, 1)

do
    local receive = getconnections(debug.getupvalue(pf.network.send, 1).OnClientEvent)[1].Function
    pf.networkCache = debug.getupvalue(receive, 1)
end

local fakeBarrel = Instance.new("Part")
fakeBarrel.CanCollide = false
fakeBarrel.Size = Vector3.new(1,1,1)
fakeBarrel.Transparency = 1 -- comment out if you wanna see it in action or whatever
fakeBarrel.Parent = workspace

local lp = game:GetService("Players").LocalPlayer

local currentgun = pf.gamelogic.currentgun
setmetatable(pf.gamelogic, {
    __index = function(t,k)
        if k == "currentgun" then
            return currentgun
        end
    end,
    __newindex = function(t,k,v)
        if k == "currentgun" then
            currentgun = v
            
            
            
            if v ~= nil and v.step ~= nil then
                local gunStep = debug.getupvalues(v.step)
                gunStep = gunStep[#gunStep]
                
                if not gunStep or type(gunStep) ~= "function" or is_synapse_function(gunStep) then
                    return    
                end
                
                debug.setupvalue(gunStep, 38, fakeBarrel)
                
                local gunInfo = debug.getupvalue(gunStep, 6)
                gunInfo.choke = false
                gunInfo.hipchoke = false
                gunInfo.aimchoke = false
                
                local hook
                hook = hookfunction(gunStep, function(...)
                    if currentgun == v then
                        
                        local nearestDist = math.huge
                        local nearest
                        
                        for o,p in pairs(game:GetService("Players"):GetPlayers()) do
                            if pf.hud:isplayeralive(p) and p.TeamColor ~= lp.TeamColor then
                                local _, headPos = pf.replication.getupdater(p).getpos()
                                
                                local viewportHead, onScreen = pf.camera.currentcamera:WorldToViewportPoint(headPos)
                                
                                local distFromCursor = (Vector2.new(viewportHead.x, viewportHead.y) - (pf.camera.currentcamera.ViewportSize / 2)).magnitude
                                
                                if distFromCursor < nearestDist then
                                    nearestDist = distFromCursor
                                    nearest = p
                                end
                            end
                        end
                        
                        if nearest then
                            local _, headPos = pf.replication.getupdater(nearest).getpos()
                            
                            fakeBarrel.CFrame = CFrame.lookAt(v.barrel.Position, headPos)
                        
                            debug.setupvalue(hook, 9, false)
                        else
                            fakeBarrel.CFrame = v.barrel.CFrame
                        end
                    end
                    return hook(...)
                end)
            end
        end
    end
})
pf.gamelogic.currentgun = nil


for i,v in pairs(pf.networkCache) do
    if debug.getconstants(v)[24] == " : " then
        v({Name = "gamign", TeamColor = BrickColor.White()}, "loaded! (took " .. math.round((os.clock() - cur) * 1000000) .. " ns)")
        break
    end
end
end)

RandomSection:NewButton("Qoute Spam Bot","Created by el3tric", function()
    local Qoutes = require(game:GetService("ReplicatedFirst").SharedModules.SharedConfigs.Quotes)
    local Network = require(game:GetService("ReplicatedFirst").ClientModules.Old.framework.network)

    task.spawn(function()
    while (wait(math.random(1, 2))) do
        Network:send("chatted", Qoutes[math.random(#Qoutes)])
    end
end)
end)

CreditSection:NewLabel("Created by Walnut#0424")
CreditSection:NewLabel("Qoute Bot by el3tric")
