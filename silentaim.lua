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
        v({Name = "SmartAim", TeamColor = BrickColor.Random()}, "Loaded! (took " .. math.round((os.clock() - cur) * 1000000) .. " ns)")
        break
    end
end
