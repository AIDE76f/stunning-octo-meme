-- ==========================================
-- الخدمات الأساسية
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- الإعدادات والمتغيرات (Settings)
-- ==========================================
local Settings = {
    Aimbot = {
        Enabled = false,
        ShowFOV = false,
        FOV_Radius = 120,
        TriggerBot = false,
        HitboxExpander = false,
        HitboxSize = 25
    },
    ESP = {
        Enabled = false,
        ShowNames = false,
        Chams = false
    },
    Combo = {
        SpeedBoost = false,
        SpeedMultiplier = 2,
        InfiniteJump = false,
        Noclip = false,
        GodMode = false,
        InfAmmo = false,
        SetHealth = false,
        CustomHealthValue = 100
    }
}

local function GetMapDefaultHealth()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        return LocalPlayer.Character:FindFirstChildOfClass("Humanoid").MaxHealth
    end
    return 100
end

Settings.Combo.CustomHealthValue = GetMapDefaultHealth()

-- ==========================================
-- GUI
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LegendaryMobileHub_V11"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP_Folder"
ESPFolder.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 420)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,10)

-- ==========================================
-- Title
-- ==========================================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,35)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-70,1,0)
Title.Position = UDim2.new(0,10,0,0)
Title.BackgroundTransparency = 1
Title.Text = "👑 Hub الأساطير V11"
Title.TextColor3 = Color3.fromRGB(255,215,0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local function CreateTitleBtn(text,color,x)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,25,0,25)
    btn.Position = UDim2.new(1,x,0.5,-12.5)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = TitleBar

    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)

    return btn
end

local CloseBtn = CreateTitleBtn("X",Color3.fromRGB(255,65,65),-30)
local MinBtn = CreateTitleBtn("-",Color3.fromRGB(0,170,255),-60)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local minimized = false

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized

    TweenService:Create(
        MainFrame,
        TweenInfo.new(0.25,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
        {
            Size = minimized and UDim2.new(0,260,0,35)
            or UDim2.new(0,260,0,420)
        }
    ):Play()

    MinBtn.Text = minimized and "+" or "-"
end)

-- ==========================================
-- Drag
-- ==========================================
local dragging = false
local dragInput
local dragStart
local startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then

        local delta = input.Position - dragStart

        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ==========================================
-- Tabs
-- ==========================================
local TabsContainer = Instance.new("Frame")
TabsContainer.Size = UDim2.new(1,-10,0,30)
TabsContainer.Position = UDim2.new(0,5,0,40)
TabsContainer.BackgroundTransparency = 1
TabsContainer.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.Padding = UDim.new(0,5)
TabLayout.Parent = TabsContainer

local function CreateScroll()
    local scroll = Instance.new("ScrollingFrame")

    scroll.Size = UDim2.new(1,-10,1,-80)
    scroll.Position = UDim2.new(0,5,0,75)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.Visible = false
    scroll.Parent = MainFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,6)
    layout.Parent = scroll

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
    end)

    return scroll
end

local AimbotScroll = CreateScroll()
local ESPScroll = CreateScroll()
local ComboScroll = CreateScroll()

AimbotScroll.Visible = true

local tabButtons = {}

local function CreateTabButton(text,target)
    local btn = Instance.new("TextButton")

    btn.Size = UDim2.new(0,75,1,0)
    btn.BackgroundColor3 = target.Visible and Color3.fromRGB(0,170,255)
    or Color3.fromRGB(35,35,40)

    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.Parent = TabsContainer

    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)

    table.insert(tabButtons,btn)

    btn.MouseButton1Click:Connect(function()

        AimbotScroll.Visible = target == AimbotScroll
        ESPScroll.Visible = target == ESPScroll
        ComboScroll.Visible = target == ComboScroll

        for _,b in ipairs(tabButtons) do
            TweenService:Create(
                b,
                TweenInfo.new(0.2),
                {
                    BackgroundColor3 =
                        (b == btn)
                        and Color3.fromRGB(0,170,255)
                        or Color3.fromRGB(35,35,40)
                }
            ):Play()
        end
    end)
end

CreateTabButton("Aimbot",AimbotScroll)
CreateTabButton("ESP",ESPScroll)
CreateTabButton("Combo",ComboScroll)

-- ==========================================
-- Controls
-- ==========================================
local function CreateToggleItem(parent,text,callback)
    local btn = Instance.new("TextButton")

    btn.Size = UDim2.new(1,-10,0,35)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,45)
    btn.Text = " "..text
    btn.TextColor3 = Color3.fromRGB(200,200,200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = parent

    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0,15,0,15)
    indicator.Position = UDim2.new(1,-25,0.5,-7.5)
    indicator.BackgroundColor3 = Color3.fromRGB(255,50,50)
    indicator.Parent = btn

    Instance.new("UICorner",indicator).CornerRadius = UDim.new(1,0)

    local state = false

    btn.MouseButton1Click:Connect(function()

        state = not state

        TweenService:Create(
            indicator,
            TweenInfo.new(0.2),
            {
                BackgroundColor3 = state
                and Color3.fromRGB(50,255,50)
                or Color3.fromRGB(255,50,50)
            }
        ):Play()

        callback(state)
    end)
end

local function CreateInputItem(parent,text,placeholder,callback)

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,-10,0,35)
    container.BackgroundColor3 = Color3.fromRGB(40,40,45)
    container.Parent = parent

    Instance.new("UICorner",container).CornerRadius = UDim.new(0,6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6,0,1,0)
    label.Position = UDim2.new(0,10,0,0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.3,0,0.7,0)
    box.Position = UDim2.new(0.65,0,0.15,0)
    box.BackgroundColor3 = Color3.fromRGB(25,25,30)
    box.Text = placeholder
    box.TextColor3 = Color3.new(1,1,1)
    box.Parent = container

    Instance.new("UICorner",box).CornerRadius = UDim.new(0,4)

    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then
            callback(num)
        end
    end)
end

-- ==========================================
-- قائمة اللاعبين الجديدة
-- ==========================================
local function CreatePlayerTeleportList(parent)

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1,-10,0,40)
    holder.BackgroundColor3 = Color3.fromRGB(40,40,45)
    holder.ClipsDescendants = true
    holder.Parent = parent

    Instance.new("UICorner",holder).CornerRadius = UDim.new(0,6)

    local open = false

    local mainBtn = Instance.new("TextButton")
    mainBtn.Size = UDim2.new(1,0,0,40)
    mainBtn.BackgroundTransparency = 1
    mainBtn.Text = "📋 الانتقال الى اللاعبين"
    mainBtn.TextColor3 = Color3.new(1,1,1)
    mainBtn.Font = Enum.Font.GothamBold
    mainBtn.TextSize = 13
    mainBtn.Parent = holder

    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Position = UDim2.new(0,0,0,45)
    listFrame.Size = UDim2.new(1,0,0,0)
    listFrame.BackgroundTransparency = 1
    listFrame.ScrollBarThickness = 3
    listFrame.CanvasSize = UDim2.new(0,0,0,0)
    listFrame.Parent = holder

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,5)
    layout.Parent = listFrame

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        listFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
    end)

    local function RefreshPlayers()

        listFrame:ClearAllChildren()
        layout.Parent = listFrame

        for _,player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then

                local item = Instance.new("Frame")
                item.Size = UDim2.new(1,-5,0,50)
                item.BackgroundColor3 = Color3.fromRGB(30,30,35)
                item.Parent = listFrame

                Instance.new("UICorner",item).CornerRadius = UDim.new(0,6)

                local avatar = Instance.new("ImageLabel")
                avatar.Size = UDim2.new(0,35,0,35)
                avatar.Position = UDim2.new(0,5,0.5,-17)
                avatar.BackgroundTransparency = 1
                avatar.Parent = item

                local thumb = Players:GetUserThumbnailAsync(
                    player.UserId,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size100x100
                )

                avatar.Image = thumb

                local name = Instance.new("TextLabel")
                name.Size = UDim2.new(0.5,0,1,0)
                name.Position = UDim2.new(0,50,0,0)
                name.BackgroundTransparency = 1
                name.Text = player.Name
                name.TextColor3 = Color3.new(1,1,1)
                name.Font = Enum.Font.GothamSemibold
                name.TextSize = 12
                name.TextXAlignment = Enum.TextXAlignment.Left
                name.Parent = item

                local tp = Instance.new("TextButton")
                tp.Size = UDim2.new(0,70,0,28)
                tp.Position = UDim2.new(1,-80,0.5,-14)
                tp.BackgroundColor3 = Color3.fromRGB(0,170,255)
                tp.Text = "Teleport"
                tp.TextColor3 = Color3.new(1,1,1)
                tp.Font = Enum.Font.GothamBold
                tp.TextSize = 11
                tp.Parent = item

                Instance.new("UICorner",tp).CornerRadius = UDim.new(0,6)

                tp.MouseButton1Click:Connect(function()

                    if LocalPlayer.Character
                    and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    and player.Character
                    and player.Character:FindFirstChild("HumanoidRootPart") then

                        LocalPlayer.Character.HumanoidRootPart.CFrame =
                            player.Character.HumanoidRootPart.CFrame
                            + Vector3.new(2,0,2)
                    end
                end)
            end
        end
    end

    mainBtn.MouseButton1Click:Connect(function()

        open = not open

        if open then

            RefreshPlayers()

            TweenService:Create(
                holder,
                TweenInfo.new(0.25,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
                {
                    Size = UDim2.new(1,-10,0,220)
                }
            ):Play()

            TweenService:Create(
                listFrame,
                TweenInfo.new(0.25,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
                {
                    Size = UDim2.new(1,0,1,-50)
                }
            ):Play()

        else

            TweenService:Create(
                holder,
                TweenInfo.new(0.25,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
                {
                    Size = UDim2.new(1,-10,0,40)
                }
            ):Play()

            TweenService:Create(
                listFrame,
                TweenInfo.new(0.25,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
                {
                    Size = UDim2.new(1,0,0,0)
                }
            ):Play()
        end
    end)

    Players.PlayerAdded:Connect(RefreshPlayers)
    Players.PlayerRemoving:Connect(RefreshPlayers)
end

-- ==========================================
-- Combo
-- ==========================================
CreateToggleItem(ComboScroll,"اختراق الجدران",function(s)
    Settings.Combo.Noclip = s
end)

CreateToggleItem(ComboScroll,"تفعيل مضاعف السرعة",function(s)
    Settings.Combo.SpeedBoost = s
end)

CreateInputItem(ComboScroll,"مضاعف السرعة:","2",function(v)
    Settings.Combo.SpeedMultiplier = v
end)

CreateToggleItem(ComboScroll,"قفز لا نهائي",function(s)
    Settings.Combo.InfiniteJump = s
end)

CreateToggleItem(ComboScroll,"صحة لا نهائية",function(s)
    Settings.Combo.GodMode = s
end)

CreateToggleItem(ComboScroll,"ذخيرة لا نهائية",function(s)
    Settings.Combo.InfAmmo = s
end)

local healthPlaceholder = tostring(GetMapDefaultHealth())

CreateInputItem(
    ComboScroll,
    "تحديد قيمة الصحة:",
    healthPlaceholder,
    function(v)
        Settings.Combo.CustomHealthValue = v
    end
)

CreateToggleItem(ComboScroll,"تثبيت الصحة 💉",function(s)
    Settings.Combo.SetHealth = s
end)

-- القائمة الجديدة
CreatePlayerTeleportList(ComboScroll)

-- ==========================================
-- Anti AFK
-- ==========================================
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ==========================================
-- Loops
-- ==========================================
RunService.Heartbeat:Connect(function()

    local char = LocalPlayer.Character

    if char and char:FindFirstChildOfClass("Humanoid") then

        local hum = char:FindFirstChildOfClass("Humanoid")

        if Settings.Combo.SetHealth then
            hum.Health = Settings.Combo.CustomHealthValue
        end

        if Settings.Combo.GodMode
        and hum.Health > 0
        and hum.Health < hum.MaxHealth then

            hum.Health = hum.MaxHealth
        end

        if Settings.Combo.SpeedBoost then
            hum.WalkSpeed = 16 * Settings.Combo.SpeedMultiplier
        end

        if Settings.Combo.Noclip then
            for _,v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end
end)
