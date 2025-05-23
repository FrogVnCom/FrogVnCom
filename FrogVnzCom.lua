local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Player = game.Players.LocalPlayer
repeat wait() until Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
local Char = Player.Character
local HRP = Char:WaitForChild("HumanoidRootPart")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local FlySpeed = 50
local Flying = false
local ESPEnabled = false
local ESPConnections = {}

-- Giao diện chính
local Window = Fluent:CreateWindow({
    Title = "FrogVnCom (BETA)",
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

-- Tab ESP
local ESPTab = Window:AddTab({
    Title = "ESP",
    Icon = "👁️"
})

-- Fly Speed Controls
local SpeedBox = FlyTab:AddSection("Fly Speed")

SpeedBox:AddButton({
    Title = "+",
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

-- ESP Setup
local function AddESPToPlayer(plr)
    if plr.Character and plr.Character:FindFirstChild("Head") and not plr.Character.Head:FindFirstChild("ESP") then
        local Billboard = Instance.new("BillboardGui")
        Billboard.Name = "ESP"
        Billboard.Adornee = plr.Character.Head
        Billboard.Size = UDim2.new(0, 100, 0, 30)
        Billboard.StudsOffset = Vector3.new(0, 2, 0)
        Billboard.AlwaysOnTop = true

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = plr.Name
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextStrokeTransparency = 0.5
        Label.Font = Enum.Font.SourceSansBold
        Label.TextScaled = true
        Label.Parent = Billboard

        Billboard.Parent = plr.Character.Head
    end
end

local function RemoveESPFromPlayer(plr)
    if plr.Character and plr.Character:FindFirstChild("Head") then
        local esp = plr.Character.Head:FindFirstChild("ESP")
        if esp then esp:Destroy() end
    end
end

local function ToggleESP(state)
    ESPEnabled = state
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= Player then
            if ESPEnabled then
                AddESPToPlayer(plr)
            else
                RemoveESPFromPlayer(plr)
            end
        end
    end
end

-- ESP Toggle UI
local ESPBox = ESPTab:AddSection("ESP")

ESPBox:AddToggle({
    Title = "Bật / Tắt ESP Nhân Vật",
    Default = false,
    Callback = function(state)
        ToggleESP(state)
    end
})

-- Tự động thêm ESP cho người chơi mới nếu bật
local function SetupESPConnection(plr)
    local con = plr.CharacterAdded:Connect(function()
        wait(1)
        if ESPEnabled then
            AddESPToPlayer(plr)
        end
    end)
    table.insert(ESPConnections, con)
end

for _, plr in pairs(game.Players:GetPlayers()) do
    if plr ~= Player then
        SetupESPConnection(plr)
    end
end

game.Players.PlayerAdded:Connect(function(plr)
    SetupESPConnection(plr)
    if ESPEnabled then
        plr.CharacterAdded:Wait()
        wait(1)
        AddESPToPlayer(plr)
    end
end)

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

-- Anti Ban Settings
pcall(function()
    settings().Physics.AllowSleep = false
    Char:WaitForChild("Humanoid").PlatformStand = false
    Char:WaitForChild("Humanoid").BreakJointsOnDeath = false
end)

Fluent:Notify({
    Title = "FrogVnCom Loaded! 🐸",
    Content = "Chào mừng bạn đã đến với Bình Nguyên Vô Tận!",
    Duration = 10
})