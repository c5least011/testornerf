local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Builetuananh1/Allusive/refs/heads/main/Library.lua"))()

local mainDistance = 0
local main = Library.new()
local rage = main:create_tab('Blatant', 'rbxassetid://76499042599127')

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local Ball = workspace:WaitForChild("GameBall")


local justParry = false
local previousDistanceBall = nil
local currentBallSpeed = 0
local distanceBall = 0
local dynamicDistance = 0

local sliderValue = 100
local minDistance = 15
local lastParryFrame = 0
local frameCount = 0

local function AccuracyDistance(value)
return 16 + ((value - 1) / 99) * 5
end

local function gigachad_dynamic_math(speed)
local s2 = speed * speed

return 25 * (1 - math.exp(-speed / 30)) + 16 * (s2 / (150000 + s2)) + 0.007 * speed

end

local module = rage:create_module({
title = 'Auto Parry',
flag = 'Auto_Parry',
description = 'Automatically parries ball',
section = 'left',
callback = function(value: boolean)
if getgenv().AutoParryNotify then
Library.SendNotification({
title = "Module Notification",
text = "Auto Parry has been turned " .. (value and "ON" or "OFF"),
duration = 3
})
end

if value then  
        if getgenv().AutoParryConnection then  
            getgenv().AutoParryConnection:Disconnect()  
        end  

        getgenv().AutoParryConnection = RunService.RenderStepped:Connect(function(dt)  
            if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end  
            if not Ball or not Ball:IsA("MeshPart") then return end  

            frameCount = frameCount + 1  

distanceBall = (Player.Character.HumanoidRootPart.Position - Ball.Position).Magnitude  

if previousDistanceBall and dt > 0 then
    local distanceClosed = previousDistanceBall - distanceBall
    
   currentBallSpeed = distanceClosed / dt 
else
    currentBallSpeed = 0
end
previousDistanceBall = distanceBall


              
            dynamicDistance = gigachad_dynamic_math(currentBallSpeed)  + currentBallSpeed / 95
            
            if currentBallSpeed <= 100 then
              mainDistance = minDistance + dynamicDistance 
            else
              mainDistance = minDistance + dynamicDistance + currentBallSpeed / 95
            end

            local isRed = (Ball.Color == Color3.fromRGB(202, 56, 30))  
            local condition = isRed and distanceBall <= mainDistance

            
            if condition and (currentBallSpeed <= 1000) then  
                if not justParry then  
                    justParry = true  
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)  
                    task.wait()  
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)  
                      
                    print(string.format(  
                        "[AutoParry] Fired via Click | BallSpeed: %.2f | Distance: %.2f | Range: %.2f",  
                        currentBallSpeed,  
                        distanceBall,  
                        mainDistance  
                    ))    
                end  
            end  

            local charContainer = workspace:FindFirstChild("Characters") or workspace:FindFirstChild("Character")
            local targetChar = charContainer and charContainer:FindFirstChild(Player.Name) or workspace:FindFirstChild(Player.Name)
            
            local targetHighlight = targetChar and (targetChar:FindFirstChild("PlayerBallHighlight") or targetChar:FindFirstChild("PlayerBallHightlight"))
            
            if not targetHighlight then  
                justParry = false  
            end  
        end)  
    else  
        if getgenv().AutoParryConnection then  
            getgenv().AutoParryConnection:Disconnect()  
            getgenv().AutoParryConnection = nil  
            justParry = false  
        end  
    end  
end

})

module:create_slider({
title = 'Parry Accuracy',
flag = 'Parry_Accuracy',
maximum_value = 100,
minimum_value = 1,
value = 1,
round_number = true,
callback = function(value)
sliderValue = value
minDistance = AccuracyDistance(sliderValue)
end
})


main:load()
