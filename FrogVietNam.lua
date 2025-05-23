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

-- ESP Setup (Full Body Box + Name)
local function AddESP(plr)
    if plr == Player then return end
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    if not char:FindFirstChild("_FROG_ESP") then
        -- Create ESP folder
        local folder = Instance.new("Folder")
        folder.Name = "_FROG_ESP"
        folder.Parent = char

        -- Name Tag
        local head = char:FindFirstChild("Head")
        if head then
            local Billboard = Instance.new("BillboardGui")
            Billboard.Name = "NameTag"
            Billboard.Adornee = head
            Billboard.Size = UDim2.new(0, 100, 0, 20)
            Billboard.StudsOffset = Vector3.new(0, 2, 0)
            Billboard.AlwaysOnTop = true
            Billboard.Parent = folder

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = plr.Name
            Label.TextColor3 = Color3.new(1, 1, 1)
            Label.TextStrokeTransparency = 0.5
            Label.Font = Enum.Font.SourceSansBold
            Label.TextScaled = true
            Label.Parent = Billboard
        end

        -- Box ESP
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                local box = Instance.new("BoxHandleAdornment")
                box.Name = "BoxESP"
                box.Adornee = part
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Size = part.Size
                box.Color3 = Color3.fromRGB(0, 255, 0)
                box.Transparency = 0.5
                box.Parent = folder
            end
        end
    end
end

local function RemoveESP(plr)
    local char = plr.Character
    if char and char:FindFirstChild("_FROG_ESP") then
        char:FindFirstChild("_FROG_ESP"):Destroy()
    end
end

local function ToggleESP(state)
    ESPEnabled = state
    for _, plr in pairs(game.Players:GetPlayers()) do
        if state then
            AddESP(plr)
        else
            RemoveESP(plr)
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
            AddESP(plr)
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
        AddESP(plr)
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
    Content = "Welcome!",
    Duration = 8
})