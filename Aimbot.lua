local players = game:GetService("Players")
local runService = game:GetService("RunService")
local localPlayer = players.LocalPlayer

_G.Skillaimbot = true
_G.AimbotRange = 500
_G.AimBotSkillPosition = nil

local targetLine = Instance.new("LineHandleAdornment")
targetLine.Name = "CentuXin_TargetLine"
targetLine.Thickness = 2
targetLine.Color3 = Color3.fromRGB(255, 0, 0)
targetLine.AlwaysOnTop = true
targetLine.ZIndex = 10
targetLine.Parent = game:GetService("CoreGui")

local function isAllyWithMe(targetplayer)
    local myGui = localPlayer:FindFirstChild("PlayerGui")
    if not myGui then return false end

    local scrolling = myGui:FindFirstChild("Main")
        and myGui.Main:FindFirstChild("Allies")
        and myGui.Main.Allies:FindFirstChild("Container")
        and myGui.Main.Allies.Container:FindFirstChild("Allies")
        and myGui.Main.Allies.Container.Allies:FindFirstChild("ScrollingFrame")

    if scrolling then
        for _, frame in pairs(scrolling:GetDescendants()) do
            if frame:IsA("ImageButton") and frame.Name == targetplayer.Name then
                return true
            end
        end
    end
    return false
end

local function getClosestPlayer()
    local closest = nil
    local shortest = _G.AimbotRange
    local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not myRoot then return nil end

    for _, v in pairs(players:GetPlayers()) do
        if v ~= localPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
            if v.Character.Humanoid.Health > 0 then
                
                -- Team Check (Marines)
                if localPlayer.Team and v.Team then
                    if localPlayer.Team.Name == "Marines" and v.Team.Name == "Marines" then
                        continue
                    end
                end

                -- Ally Check (Gui Check)
                if isAllyWithMe(v) then
                    continue
                end

                local dist = (myRoot.Position - v.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = v.Character.HumanoidRootPart.Position
                end
            end
        end
    end
    return closest
end

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(...)
    local method = getnamecallmethod()
    local args = {...}
    if _G.Skillaimbot and _G.AimBotSkillPosition then
        if (method == "FireServer" or method == "InvokeServer") then
            for i = 2, #args do
                if typeof(args[i]) == "Vector3" then
                    args[i] = _G.AimBotSkillPosition
                elseif typeof(args[i]) == "CFrame" then
                    args[i] = CFrame.new(_G.AimBotSkillPosition)
                end
            end
            return old(unpack(args))
        end
    end
    return old(...)
end)

setreadonly(mt, true)

localPlayer.Chatted:Connect(function(msg)
    local message = msg:lower()
    if message == "/e aimbot on" then
        _G.Skillaimbot = true
    elseif message == "/e aimbot off" then
        _G.Skillaimbot = false
    end
end)

runService.Heartbeat:Connect(function()
    local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if _G.Skillaimbot and myRoot then
        _G.AimBotSkillPosition = getClosestPlayer()
        
        if _G.AimBotSkillPosition then
            targetLine.Visible = true
            targetLine.Adornee = myRoot
            targetLine.Length = (myRoot.Position - _G.AimBotSkillPosition).Magnitude
            targetLine.CFrame = CFrame.lookAt(myRoot.Position, _G.AimBotSkillPosition)
        else
            targetLine.Visible = false
        end
    else
        _G.AimBotSkillPosition = nil
        targetLine.Visible = false
    end
end)
