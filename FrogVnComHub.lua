local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Player = game.Players.LocalPlayer
repeat wait() until Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
local Char = Player.Character
local HRP = Char:WaitForChild("HumanoidRootPart")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local FlySpeed = 50
local Flying = false

-- Giao diện chính
local Window = Fluent:CreateWindow({
    Title = "FrogVnCom (BETA)",
    SubTitle = "Test Label",
    TabWidth = 100,
    Size = UDim2.fromOffset(500, 350),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tab Fly
local FlyTab = Window:AddTab({
    Title = "Fly",
    Icon = "🛫"
})

-- Groupbox và chức năng Fly Speed
local SpeedBox = FlyTab:AddSection("Fly Speed")

SpeedBox:AddButton({
    Title = "Fly Speed: ",
    Description = "Tăng tốc độ bay",
    Callback = function()
        FlySpeed += 10
        Fluent:Notify({ Title = "Speed", Content = "Speed hiện tại: " .. FlySpeed, Duration = 2 })
    end
})

SpeedBox:AddButton({
    Title = "-",
    Description = "Giảm tốc độ bay",
    Callback = function()
        FlySpeed = math.max(10, FlySpeed - 10)
        Fluent:Notify({ Title = "Speed", Content = "Speed hiện tại: " .. FlySpeed, Duration = 2 })
    end
})

-- Fly Script
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F then
        Flying = not Flying
        if Flying then
            RS:BindToRenderStep("FlyLoop", Enum.RenderPriority.Character.Value, function()
                local dir = Vector3.zero
                local cam = workspace.CurrentCamera
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
                HRP.Velocity = dir.Magnitude > 0 and dir.Unit * FlySpeed or Vector3.zero
            end)
        else
            RS:UnbindFromRenderStep("FlyLoop")
            HRP.Velocity = Vector3.zero
        end
    end
end)

-- Anti Ban (giảm nguy cơ bị detect hành vi bay)
pcall(function()
    settings().Physics.AllowSleep = false
    Char:WaitForChild("Humanoid").PlatformStand = false
    Char:WaitForChild("Humanoid").BreakJointsOnDeath = false
end)

Fluent:Notify({
    Title = "FrogVnCom Loaded! 🐸",
    Content = "Thanks For Using!.",
    Duration = 5
})