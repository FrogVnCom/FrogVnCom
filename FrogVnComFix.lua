local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "FrogVnCom (BETA)",
    SubTitle = "",
    TabWidth = 100,
    Size = UDim2.fromOffset(480, 300),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Fly variables
local flying = false
local flyspeed = 2

-- ESP toggle
local espEnabled = false

-- Fly tab
local TabFly = Window:AddTab({ Title = "Fly", Icon = "🛫" })
TabFly:AddParagraph({ Title = "Fly Speed", Content = "" })
TabFly:AddButton({ Title = "+", Callback = function() flyspeed = flyspeed + 1 end })
TabFly:AddButton({ Title = "-", Callback = function() flyspeed = math.max(flyspeed - 1, 1) end })

-- ESP tab
local TabESP = Window:AddTab({ Title = "ESP", Icon = "👁" })
TabESP:AddToggle({
    Title = "ESP",
    Default = false,
    Callback = function(state)
        espEnabled = state
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                if state then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Name = "ESPBox"
                    box.Adornee = player.Character
                    box.AlwaysOnTop = true
                    box.ZIndex = 5
                    box.Size = player.Character:GetExtentsSize()
                    box.Color3 = Color3.fromRGB(0, 255, 0)
                    box.Transparency = 0.5
                    box.Parent = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Head")

                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "ESPName"
                    billboard.Size = UDim2.new(0, 100, 0, 40)
                    billboard.AlwaysOnTop = true
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.Adornee = player.Character:FindFirstChild("Head")

                    local name = Instance.new("TextLabel")
                    name.Text = player.Name
                    name.Size = UDim2.new(1, 0, 1, 0)
                    name.TextColor3 = Color3.new(1,1,1)
                    name.BackgroundTransparency = 1
                    name.Parent = billboard
                    billboard.Parent = player.Character
                else
                    for _, part in ipairs(player.Character:GetDescendants()) do
                        if part:IsA("BoxHandleAdornment") or part:IsA("BillboardGui") then
                            part:Destroy()
                        end
                    end
                end
            end
        end
    end
})

-- Fly logic
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local lp = game.Players.LocalPlayer
local hrp = lp.Character:WaitForChild("HumanoidRootPart")

uis.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F then
        flying = not flying
        if flying then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "FlyVelocity"
            bv.MaxForce = Vector3.new(1,1,1) * math.huge
            bv.Velocity = Vector3.zero
            bv.Parent = hrp
            rs:BindToRenderStep("FlyMovement", Enum.RenderPriority.Input.Value, function()
                local vel = Vector3.zero
                if uis:IsKeyDown(Enum.KeyCode.W) then vel += workspace.CurrentCamera.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.S) then vel -= workspace.CurrentCamera.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.A) then vel -= workspace.CurrentCamera.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.D) then vel += workspace.CurrentCamera.CFrame.RightVector end
                hrp.FlyVelocity.Velocity = vel.Unit * flyspeed
                if vel.Magnitude == 0 then
                    hrp.FlyVelocity.Velocity = Vector3.zero
                end
            end)
        else
            rs:UnbindFromRenderStep("FlyMovement")
            if hrp:FindFirstChild("FlyVelocity") then
                hrp.FlyVelocity:Destroy()
            end
        end
    end
end)

-- Status text
Fluent:Notify({ Title = "FrogVnCom", Content = "Loading...", Duration = 8 })