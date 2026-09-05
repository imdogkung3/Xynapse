local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)
local InputService, TextService, CoreGui = cloneref(game:GetService'UserInputService'), cloneref(game:GetService'TextService'), cloneref(game:GetService'CoreGui')

cloneref(game:GetService'Teams')

local Players, RunService = cloneref(game:GetService'Players'), cloneref(game:GetService'RunService')

cloneref(game:GetService'TweenService')

local RenderStepped, LocalPlayer = RunService.RenderStepped, Players.LocalPlayer
local Mouse, _, ProtectGui, GetHUI, ScreenGui = LocalPlayer:GetMouse(), typeof(Drawing) == 'table' and Drawing or {drawing_replaced = true}, protectgui or (function(
) end), gethui or (function()
    return CoreGui
end), Instance.new'ScreenGui'

pcall(ProtectGui, ScreenGui)

ScreenGui.DisplayOrder = 999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local Parented = pcall(function()
    ScreenGui.Parent = GetHUI()
end)

if not Parented then
    ScreenGui.Parent = LocalPlayer:WaitForChild('PlayerGui', 9e9)
end

local Toggles, Options, Labels, Buttons = {}, {}, {}, {}

getgenv().Linoria = {
    Toggles = Toggles,
    Options = Options,
    Labels = Labels,
    Buttons = Buttons,
}
getgenv().Toggles = Toggles
getgenv().Options = Options

local LibraryMainOuterFrame, Library = nil, {
    Registry = {},
    RegistryMap = {},
    HudRegistry = {},
    FontColor = Color3.fromRGB(255, 255, 255),
    MainColor = Color3.fromRGB(28, 28, 28),
    BackgroundColor = Color3.fromRGB(20, 20, 20),
    AccentColor = Color3.fromRGB(0, 85, 255),
    OutlineColor = Color3.fromRGB(50, 50, 50),
    RiskColor = Color3.fromRGB(255, 50, 50),
    Black = Color3.new(0, 0, 0),
    Font = Enum.Font.Code,
    OpenedFrames = {},
    DependencyBoxes = {},
    UnloadSignals = {},
    Signals = {},
    ScreenGui = ScreenGui,
    ActiveTab = nil,
    Toggled = false,
    MinSize = Vector2.new(550, 300),
    IsMobile = false,
    DevicePlatform = Enum.Platform.None,
    CanDrag = true,
    CantDragForced = false,
    NotifySide = 'Left',
    ShowCustomCursor = true,
    ShowToggleFrameInKeybinds = true,
    VideoLink = '',
    TotalTabs = 0,
    Toggles = Toggles,
    Options = Options,
    Labels = Labels,
    Buttons = Buttons,
}

pcall(function()
    Library.DevicePlatform = InputService:GetPlatform()
end)

Library.IsMobile = (Library.DevicePlatform == Enum.Platform.Android or Library.DevicePlatform == Enum.Platform.IOS)

if Library.IsMobile then
    Library.MinSize = Vector2.new(550, 200)
end

local RainbowStep, Hue = 0, 0

table.insert(Library.Signals, RenderStepped:Connect(function(Delta)
    RainbowStep = RainbowStep + Delta

    if RainbowStep >= (1.6666666666666665E-2) then
        RainbowStep = 0
        Hue = Hue + (2.5E-3)

        if Hue > 1 then
            Hue = 0
        end

        Library.CurrentRainbowHue = Hue
        Library.CurrentRainbowColor = Color3.fromHSV(Hue, 0.8, 1)
    end
end))

function Library.SafeCallback(self, f, ...)
    if (not f) then
        return
    end
    if not Library.NotifyOnError then
        return f(...)
    end

    local success, event = pcall(f, ...)

    if not success then
        local _, i = event:find':%d+: '

        if not i then
            return Library:Notify(event)
        end

        return Library:Notify(event:sub(i + 1), 3)
    end
end
function Library.AttemptSave(self)
    if Library.SaveManager then
        Library.SaveManager:Save()
    end
end
function Library.Create(self, Class, Properties)
    local _Instance = Class

    if typeof(Class) == 'string' then
        _Instance = Instance.new(Class)
    end

    for Property, Value in next, Properties do
        local success, err = pcall(function()
            _Instance[Property] = Value
        end)

        if (not success) then
            warn(err)
        end
    end

    return _Instance
end
function Library.ApplyTextStroke(self, Inst)
    Inst.TextStrokeTransparency = 1

    return Library:Create('UIStroke', {
        Color = Color3.new(0, 0, 0),
        Thickness = 1,
        LineJoinMode = Enum.LineJoinMode.Miter,
        Parent = Inst,
    })
end
function Library.CreateLabel(self, Properties, IsHud)
    local _Instance = Library:Create('TextLabel', {
        BackgroundTransparency = 1,
        Font = Library.Font,
        TextColor3 = Library.FontColor,
        TextSize = 16,
        TextStrokeTransparency = 0,
    })

    Library:ApplyTextStroke(_Instance)
    Library:AddToRegistry(_Instance, {
        TextColor3 = 'FontColor',
    }, IsHud)

    return Library:Create(_Instance, Properties)
end
function Library.MakeDraggable(self, Instance, Cutoff, IsMainWindow)
    Instance.Active = true

    if Library.IsMobile == false then
        Instance.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if IsMainWindow == true and Library.CantDragForced == true then
                    return
                end

                local ObjPos = Vector2.new(Mouse.X - Instance.AbsolutePosition.X, Mouse.Y - Instance.AbsolutePosition.Y)

                if ObjPos.Y > (Cutoff or 40) then
                    return
                end

                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    Instance.Position = UDim2.new(0, Mouse.X - ObjPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X), 0, Mouse.Y - ObjPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y))

                    RenderStepped:Wait()
                end
            end
        end)
    else
        Instance.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                if IsMainWindow == true and Library.CantDragForced == true then
                    return
                end

                local ObjPos = Vector2.new(Mouse.X - Instance.AbsolutePosition.X, Mouse.Y - Instance.AbsolutePosition.Y)

                if ObjPos.Y > (Cutoff or 40) then
                    return
                end

                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    Instance.Position = UDim2.new(0, Mouse.X - ObjPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X), 0, Mouse.Y - ObjPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y))

                    RenderStepped:Wait()
                end
            end
        end)
        InputService.TouchMoved:Connect(function(Input)
            if IsMainWindow == true and Library.CantDragForced == true then
                Dragging = false

                return
            end
            if Input == DraggingInput and Dragging and (IsMainWindow == true and (Library.CanDrag == true and Library.Window.Holder.Visible == true) or true) then
                local OffsetPos = Input.Position - DraggingStart

                Instance.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + OffsetPos.X, StartPosition.Y.Scale, StartPosition.Y.Offset + OffsetPos.Y)
            end
        end)
        InputService.TouchEnded:Connect(function(Input)
            if Input == DraggingInput then
                Dragging = false
            end
        end)
    end
end
function Library.MakeDraggableUsingParent(
    self,
    Instance,
    Parent,
    Cutoff,
    IsMainWindow
)
    Instance.Active = true

    if Library.IsMobile == false then
        Instance.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if IsMainWindow == true and Library.CantDragForced == true then
                    return
                end

                local ObjPos = Vector2.new(Mouse.X - Parent.AbsolutePosition.X, Mouse.Y - Parent.AbsolutePosition.Y)

                if ObjPos.Y > (Cutoff or 40) then
                    return
                end

                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    Parent.Position = UDim2.new(0, Mouse.X - ObjPos.X + (Parent.Size.X.Offset * Parent.AnchorPoint.X), 0, Mouse.Y - ObjPos.Y + (Parent.Size.Y.Offset * Parent.AnchorPoint.Y))

                    RenderStepped:Wait()
                end
            end
        end)
    else
        Library:MakeDraggable(Parent, Cutoff, IsMainWindow)
    end
end
function Library.MakeResizable(self, Instance, MinSize)
    if Library.IsMobile then
        return
    end

    Instance.Active = true

    local ResizerImage_Size, ResizerImage_HoverTransparency, Resizer = 25, 0.5, Library:Create('Frame', {
        SizeConstraint = Enum.SizeConstraint.RelativeXX,
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -30, 1, -30),
        Visible = true,
        ClipsDescendants = true,
        ZIndex = 1,
        Parent = Instance,
    })
    local ResizerImage = Library:Create('ImageButton', {
        BackgroundColor3 = Library.AccentColor,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(2, 0, 2, 0),
        Position = UDim2.new(1, -30, 1, -30),
        ZIndex = 2,
        Parent = Resizer,
    })
    local ResizerImageUICorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(0.5, 0),
        Parent = ResizerImage,
    })

    Library:AddToRegistry(ResizerImage, {
        BackgroundColor3 = 'AccentColor',
    })

    Resizer.Size = UDim2.fromOffset(ResizerImage_Size, ResizerImage_Size)
    Resizer.Position = UDim2.new(1, -ResizerImage_Size, 1, -ResizerImage_Size)
    MinSize = MinSize or Library.MinSize

    local OffsetPos

    Resizer.Parent = Instance

    local function FinishResize(Transparency)
        ResizerImage.Position = UDim2.new()
        ResizerImage.Size = UDim2.new(2, 0, 2, 0)
        ResizerImage.Parent = Resizer
        ResizerImage.BackgroundTransparency = Transparency
        ResizerImageUICorner.Parent = ResizerImage
        OffsetPos = nil
    end

    ResizerImage.MouseButton1Down:Connect(function()
        if not OffsetPos then
            OffsetPos = Vector2.new(Mouse.X - (Instance.AbsolutePosition.X + Instance.AbsoluteSize.X), Mouse.Y - (Instance.AbsolutePosition.Y + Instance.AbsoluteSize.Y))
            ResizerImage.BackgroundTransparency = 1
            ResizerImage.Size = UDim2.fromOffset(Library.ScreenGui.AbsoluteSize.X, Library.ScreenGui.AbsoluteSize.Y)
            ResizerImage.Position = UDim2.new()
            ResizerImageUICorner.Parent = nil
            ResizerImage.Parent = Library.ScreenGui
        end
    end)
    ResizerImage.MouseMoved:Connect(function()
        if OffsetPos then
            local MousePos = Vector2.new(Mouse.X - OffsetPos.X, Mouse.Y - OffsetPos.Y)
            local FinalSize = Vector2.new(math.clamp(MousePos.X - Instance.AbsolutePosition.X, MinSize.X, math.huge), math.clamp(MousePos.Y - Instance.AbsolutePosition.Y, MinSize.Y, math.huge))

            Instance.Size = UDim2.fromOffset(FinalSize.X, FinalSize.Y)
        end
    end)
    ResizerImage.MouseEnter:Connect(function()
        FinishResize(ResizerImage_HoverTransparency)
    end)
    ResizerImage.MouseLeave:Connect(function()
        FinishResize(1)
    end)
    ResizerImage.MouseButton1Up:Connect(function()
        FinishResize(ResizerImage_HoverTransparency)
    end)
end
function Library.isHolding(self, instance)
    local lastClickTime = 0

    if instance then
        local isTouching, isHolding, inputConnection, inputEndedConnection, inputChangedConnection = false, false, nil, nil, nil

        inputConnection = InputService.InputBegan:Connect(function(
            input,
            gameProcessedEvent
        )
            if not gameProcessedEvent and input.UserInputType == Enum.UserInputType.Touch then
                local currentTime, touchPosition, instancePosition, instanceSize = tick(), input.Position, instance.AbsolutePosition, instance.AbsoluteSize

                isTouching = (touchPosition.X >= instancePosition.X and touchPosition.X <= instancePosition.X + instanceSize.X and touchPosition.Y >= instancePosition.Y and touchPosition.Y <= instancePosition.Y + instanceSize.Y)
                lastClickTime = currentTime
            end
        end)
        inputEndedConnection = InputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                isTouching, isHolding = false, false
            end
        end)
        inputChangedConnection = InputService.InputChanged:Connect(function(
            input
        )
            if input.UserInputType == Enum.UserInputType.Touch and isTouching then
                local touchPosition, instancePosition, instanceSize = input.Position, instance.AbsolutePosition, instance.AbsoluteSize

                isHolding = (touchPosition.X >= instancePosition.X and touchPosition.X <= instancePosition.X + instanceSize.X and touchPosition.Y >= instancePosition.Y and touchPosition.Y <= instancePosition.Y + instanceSize.Y) and (currentTime - lastClickTime) > 0.3 and (currentTime - lastClickTime) <= doubleClickThreshold
            end
        end)

        instance.AncestryChanged:Connect(function(_, parent)
            if not parent then
                inputConnection:Disconnect()
                inputEndedConnection:Disconnect()
                inputChangedConnection:Disconnect()
            end
        end)

        return isHolding
    end

    return false
end
function Library.AddToolTip(self, InfoStr, HoverInstance)
    local X, Y = Library:GetTextBounds(InfoStr, Library.Font, 14)
    local Tooltip = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.OutlineColor,
        Size = UDim2.fromOffset(X + 5, Y + 4),
        ZIndex = 100,
        Parent = Library.ScreenGui,
        Visible = false,
    })
    local Label = Library:CreateLabel{
        Position = UDim2.fromOffset(3, 1),
        Size = UDim2.fromOffset(X, Y),
        TextSize = 14,
        Text = InfoStr,
        TextColor3 = Library.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = Tooltip.ZIndex + 1,
        Parent = Tooltip,
    }

    Library:AddToRegistry(Tooltip, {
        BackgroundColor3 = 'MainColor',
        BorderColor3 = 'OutlineColor',
    })
    Library:AddToRegistry(Label, {
        TextColor3 = 'FontColor',
    })

    local IsHovering = false

    HoverInstance.MouseEnter:Connect(function()
        if Library:MouseIsOverOpenedFrame() then
            return
        end

        IsHovering = true
        Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12)
        Tooltip.Visible = true

        while IsHovering do
            RunService.Heartbeat:Wait()

            Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12)
        end
    end)
    HoverInstance.MouseLeave:Connect(function()
        IsHovering = false
        Tooltip.Visible = false
    end)

    if LibraryMainOuterFrame then
        LibraryMainOuterFrame:GetPropertyChangedSignal'Visible':Connect(function(
        )
            if LibraryMainOuterFrame.Visible == false then
                IsHovering = false
                Tooltip.Visible = false
            end
        end)
    end
end
function Library.OnHighlight(
    self,
    HighlightInstance,
    Instance,
    Properties,
    PropertiesDefault,
    condition
)
    local function undoHighlight()
        local Reg = Library.RegistryMap[Instance]

        for Property, ColorIdx in next, PropertiesDefault do
            Instance[Property] = Library[ColorIdx] or ColorIdx

            if Reg and Reg.Properties[Property] then
                Reg.Properties[Property] = ColorIdx
            end
        end
    end
    local function doHighlight()
        if condition and not condition() then
            undoHighlight()

            return
        end

        local Reg = Library.RegistryMap[Instance]

        for Property, ColorIdx in next, Properties do
            Instance[Property] = Library[ColorIdx] or ColorIdx

            if Reg and Reg.Properties[Property] then
                Reg.Properties[Property] = ColorIdx
            end
        end
    end

    HighlightInstance.MouseEnter:Connect(function()
        doHighlight()
    end)
    HighlightInstance.MouseMoved:Connect(function()
        doHighlight()
    end)
    HighlightInstance.MouseLeave:Connect(function()
        undoHighlight()
    end)
end
function Library.MouseIsOverOpenedFrame(self, Input)
    local Pos = Mouse

    if Library.IsMobile and Input then
        Pos = Input.Position
    end

    for Frame, _ in next, Library.OpenedFrames do
        local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize

        if Pos.X >= AbsPos.X and Pos.X <= AbsPos.X + AbsSize.X and Pos.Y >= AbsPos.Y and Pos.Y <= AbsPos.Y + AbsSize.Y then
            return true
        end
    end
end
function Library.MouseIsOverFrame(self, Frame, Input)
    local Pos = Mouse

    if Library.IsMobile and Input then
        Pos = Input.Position
    end

    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize

    if Pos.X >= AbsPos.X and Pos.X <= AbsPos.X + AbsSize.X and Pos.Y >= AbsPos.Y and Pos.Y <= AbsPos.Y + AbsSize.Y then
        return true
    end
end
function Library.UpdateDependencyBoxes(self)
    for _, Depbox in next, Library.DependencyBoxes do
        Depbox:Update()
    end
end
function Library.MapValue(self, Value, MinA, MaxA, MinB, MaxB)
    return (1 - ((Value - MinA) / (MaxA - MinA))) * MinB + ((Value - MinA) / (MaxA - MinA)) * MaxB
end
function Library.GetTextBounds(self, Text, Font, Size, Resolution)
    local Bounds = TextService:GetTextSize(Text, Size, Font, Resolution or Vector2.new(1920, 1080))

    return Bounds.X, Bounds.Y
end
function Library.GetDarkerColor(self, Color)
    local H, S, V = Color3.toHSV(Color)

    return Color3.fromHSV(H, S, V / 1.5)
end

Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor)

function Library.AddToRegistry(self, Instance, Properties, IsHud)
    local Idx = #Library.Registry + 1
    local Data = {
        Instance = Instance,
        Properties = Properties,
        Idx = Idx,
    }

    table.insert(Library.Registry, Data)

    Library.RegistryMap[Instance] = Data

    if IsHud then
        table.insert(Library.HudRegistry, Data)
    end
end
function Library.RemoveFromRegistry(self, Instance)
    local Data = Library.RegistryMap[Instance]

    if Data then
        for Idx = #Library.Registry, 1, -1 do
            if Library.Registry[Idx] == Data then
                table.remove(Library.Registry, Idx)
            end
        end
        for Idx = #Library.HudRegistry, 1, -1 do
            if Library.HudRegistry[Idx] == Data then
                table.remove(Library.HudRegistry, Idx)
            end
        end

        Library.RegistryMap[Instance] = nil
    end
end
function Library.UpdateColorsUsingRegistry(self)
    for Idx, Object in next, Library.Registry do
        for Property, ColorIdx in next, Object.Properties do
            if typeof(ColorIdx) == 'string' then
                Object.Instance[Property] = Library[ColorIdx]
            elseif typeof(ColorIdx) == 'function' then
                Object.Instance[Property] = ColorIdx()
            end
        end
    end
end
function Library.GiveSignal(self, Signal)
    table.insert(Library.Signals, Signal)
end
function Library.Unload(self)
    for Idx = #Library.Signals, 1, -1 do
        local Connection = table.remove(Library.Signals, Idx)

        Connection:Disconnect()
    end

    for _, UnloadCallback in pairs(Library.UnloadSignals)do
        Library:SafeCallback(UnloadCallback)
    end

    ScreenGui:Destroy()
end
function Library.OnUnload(self, Callback)
    table.insert(Library.UnloadSignals, Callback)
end

Library:GiveSignal(ScreenGui.DescendantRemoving:Connect(function(Instance)
    if Library.RegistryMap[Instance] then
        Library:RemoveFromRegistry(Instance)
    end
end))

local BaseAddons = {}

do
    local Funcs = {}

    function Funcs.AddColorPicker(self, Idx, Info)
        local ParentObj, ToggleLabel = self, self.TextLabel

        assert(Info.Default, 'AddColorPicker: Missing default value.')

        local ColorPicker = {
            Value = Info.Default,
            Transparency = Info.Transparency or 0,
            Type = 'ColorPicker',
            Title = typeof(Info.Title) == 'string' and Info.Title or 'Color picker',
            Callback = Info.Callback or function(Color) end,
        }

        function ColorPicker.SetHSVFromRGB(self, Color)
            local H, S, V = Color3.toHSV(Color)

            ColorPicker.Hue = H
            ColorPicker.Sat = S
            ColorPicker.Vib = V
        end

        ColorPicker:SetHSVFromRGB(ColorPicker.Value)

        local DisplayFrame = Library:Create('Frame', {
            BackgroundColor3 = ColorPicker.Value,
            BorderColor3 = Library:GetDarkerColor(ColorPicker.Value),
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(0, 28, 0, 14),
            ZIndex = 6,
            Parent = ToggleLabel,
        })

        Library:Create('ImageLabel', {
            BorderSizePixel = 0,
            Size = UDim2.new(0, 27, 0, 13),
            ZIndex = 5,
            Image = 'http://www.roblox.com/asset/?id=12977615774',
            Visible = not not Info.Transparency,
            Parent = DisplayFrame,
        })

        local PickerFrameOuter = Library:Create('Frame', {
            Name = 'Color',
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18),
            Size = UDim2.fromOffset(230, Info.Transparency and 271 or 253),
            Visible = false,
            ZIndex = 15,
            Parent = ScreenGui,
        })

        DisplayFrame:GetPropertyChangedSignal'AbsolutePosition':Connect(function(
        )
            PickerFrameOuter.Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18)
        end)

        local PickerFrameInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 16,
            Parent = PickerFrameOuter,
        })
        local Highlight, SatVibMapOuter = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 2),
            ZIndex = 17,
            Parent = PickerFrameInner,
        }), Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0),
            Position = UDim2.new(0, 4, 0, 25),
            Size = UDim2.new(0, 200, 0, 200),
            ZIndex = 17,
            Parent = PickerFrameInner,
        })
        local SatVibMapInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 18,
            Parent = SatVibMapOuter,
        })
        local SatVibMap = Library:Create('ImageLabel', {
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 18,
            Image = 'rbxassetid://4155801252',
            Parent = SatVibMapInner,
        })
        local CursorOuter = Library:Create('ImageLabel', {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(0, 6, 0, 6),
            BackgroundTransparency = 1,
            Image = 'http://www.roblox.com/asset/?id=9619665977',
            ImageColor3 = Color3.new(0, 0, 0),
            ZIndex = 19,
            Parent = SatVibMap,
        })

        Library:Create('ImageLabel', {
            Size = UDim2.new(0, CursorOuter.Size.X.Offset - 2, 0, CursorOuter.Size.Y.Offset - 2),
            Position = UDim2.new(0, 1, 0, 1),
            BackgroundTransparency = 1,
            Image = 'http://www.roblox.com/asset/?id=9619665977',
            ZIndex = 20,
            Parent = CursorOuter,
        })

        local HueSelectorOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0),
            Position = UDim2.new(0, 208, 0, 25),
            Size = UDim2.new(0, 15, 0, 200),
            ZIndex = 17,
            Parent = PickerFrameInner,
        })
        local HueSelectorInner = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 18,
            Parent = HueSelectorOuter,
        })
        local HueCursor, HueBoxOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(1, 1, 1),
            AnchorPoint = Vector2.new(0, 0.5),
            BorderColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(1, 0, 0, 1),
            ZIndex = 18,
            Parent = HueSelectorInner,
        }), Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0),
            Position = UDim2.fromOffset(4, 228),
            Size = UDim2.new(0.5, -6, 0, 20),
            ZIndex = 18,
            Parent = PickerFrameInner,
        })
        local HueBoxInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 18,
            Parent = HueBoxOuter,
        })

        Library:Create('UIGradient', {
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212)),
            },
            Rotation = 90,
            Parent = HueBoxInner,
        })

        local HueBox = Library:Create('TextBox', {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 5, 0, 0),
            Size = UDim2.new(1, -5, 1, 0),
            Font = Library.Font,
            PlaceholderColor3 = Color3.fromRGB(190, 190, 190),
            PlaceholderText = 'Hex color',
            Text = '#FFFFFF',
            TextColor3 = Library.FontColor,
            TextSize = 14,
            TextStrokeTransparency = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 20,
            Parent = HueBoxInner,
        })

        Library:ApplyTextStroke(HueBox)

        local RgbBoxBase = Library:Create(HueBoxOuter:Clone(), {
            Position = UDim2.new(0.5, 2, 0, 228),
            Size = UDim2.new(0.5, -6, 0, 20),
            Parent = PickerFrameInner,
        })
        local RgbBox, TransparencyBoxOuter, TransparencyBoxInner, TransparencyCursor = Library:Create(RgbBoxBase.Frame:FindFirstChild'TextBox', {
            Text = '255, 255, 255',
            PlaceholderText = 'RGB color',
            TextColor3 = Library.FontColor,
        }), nil, nil, nil

        if Info.Transparency then
            TransparencyBoxOuter = Library:Create('Frame', {
                BorderColor3 = Color3.new(0, 0, 0),
                Position = UDim2.fromOffset(4, 251),
                Size = UDim2.new(1, -8, 0, 15),
                ZIndex = 19,
                Parent = PickerFrameInner,
            })
            TransparencyBoxInner = Library:Create('Frame', {
                BackgroundColor3 = ColorPicker.Value,
                BorderColor3 = Library.OutlineColor,
                BorderMode = Enum.BorderMode.Inset,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 19,
                Parent = TransparencyBoxOuter,
            })

            Library:AddToRegistry(TransparencyBoxInner, {
                BorderColor3 = 'OutlineColor',
            })
            Library:Create('ImageLabel', {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Image = 'http://www.roblox.com/asset/?id=12978095818',
                ZIndex = 20,
                Parent = TransparencyBoxInner,
            })

            TransparencyCursor = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(1, 1, 1),
                AnchorPoint = Vector2.new(0.5, 0),
                BorderColor3 = Color3.new(0, 0, 0),
                Size = UDim2.new(0, 1, 1, 0),
                ZIndex = 21,
                Parent = TransparencyBoxInner,
            })
        end

        Library:CreateLabel{
            Size = UDim2.new(1, 0, 0, 14),
            Position = UDim2.fromOffset(5, 5),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 14,
            Text = ColorPicker.Title,
            TextWrapped = false,
            ZIndex = 16,
            Parent = PickerFrameInner,
        }

        local ContextMenu = {}

        do
            ContextMenu.Options = {}
            ContextMenu.Container = Library:Create('Frame', {
                BorderColor3 = Color3.new(),
                ZIndex = 14,
                Visible = false,
                Parent = ScreenGui,
            })
            ContextMenu.Inner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor,
                BorderColor3 = Library.OutlineColor,
                BorderMode = Enum.BorderMode.Inset,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 15,
                Parent = ContextMenu.Container,
            })

            Library:Create('UIListLayout', {
                Name = 'Layout',
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = ContextMenu.Inner,
            })
            Library:Create('UIPadding', {
                Name = 'Padding',
                PaddingLeft = UDim.new(0, 4),
                Parent = ContextMenu.Inner,
            })

            local function updateMenuPosition()
                ContextMenu.Container.Position = UDim2.fromOffset((DisplayFrame.AbsolutePosition.X + DisplayFrame.AbsoluteSize.X) + 4, DisplayFrame.AbsolutePosition.Y + 1)
            end
            local function updateMenuSize()
                local menuWidth = 60

                for i, label in next, ContextMenu.Inner:GetChildren()do
                    if label:IsA'TextLabel' then
                        menuWidth = math.max(menuWidth, label.TextBounds.X)
                    end
                end

                ContextMenu.Container.Size = UDim2.fromOffset(menuWidth + 8, ContextMenu.Inner.Layout.AbsoluteContentSize.Y + 4)
            end

            DisplayFrame:GetPropertyChangedSignal'AbsolutePosition':Connect(updateMenuPosition)
            ContextMenu.Inner.Layout:GetPropertyChangedSignal'AbsoluteContentSize':Connect(updateMenuSize)
            task.spawn(updateMenuPosition)
            task.spawn(updateMenuSize)
            Library:AddToRegistry(ContextMenu.Inner, {
                BackgroundColor3 = 'BackgroundColor',
                BorderColor3 = 'OutlineColor',
            })

            function ContextMenu.Show(self)
                if Library.IsMobile then
                    Library.CanDrag = false
                end

                self.Container.Visible = true
            end
            function ContextMenu.Hide(self)
                if Library.IsMobile then
                    Library.CanDrag = true
                end

                self.Container.Visible = false
            end
            function ContextMenu.AddOption(self, Str, Callback)
                if typeof(Callback) ~= 'function' then
                    Callback = function() end
                end

                local Button = Library:CreateLabel{
                    Active = false,
                    Size = UDim2.new(1, 0, 0, 15),
                    TextSize = 13,
                    Text = Str,
                    ZIndex = 16,
                    Parent = self.Inner,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }

                Library:OnHighlight(Button, Button, {
                    TextColor3 = 'AccentColor',
                }, {
                    TextColor3 = 'FontColor',
                })
                Button.InputBegan:Connect(function(Input)
                    if Input.UserInputType ~= Enum.UserInputType.MouseButton1 or Input.UserInputType ~= Enum.UserInputType.Touch then
                        return
                    end

                    Callback()
                end)
            end

            ContextMenu:AddOption('Copy color', function()
                Library.ColorClipboard = ColorPicker.Value

                Library:Notify('Copied color!', 2)
            end)
            ContextMenu:AddOption('Paste color', function()
                if not Library.ColorClipboard then
                    return Library:Notify('You have not copied a color!', 2)
                end

                ColorPicker:SetValueRGB(Library.ColorClipboard)
            end)
            ContextMenu:AddOption('Copy HEX', function()
                pcall(setclipboard, ColorPicker.Value:ToHex())
                Library:Notify('Copied hex code to clipboard!', 2)
            end)
            ContextMenu:AddOption('Copy RGB', function()
                pcall(setclipboard, table.concat({
                    math.floor(ColorPicker.Value.R * 255),
                    math.floor(ColorPicker.Value.G * 255),
                    math.floor(ColorPicker.Value.B * 255),
                }, ', '))
                Library:Notify('Copied RGB values to clipboard!', 2)
            end)
        end

        ColorPicker.ContextMenu = ContextMenu

        Library:AddToRegistry(PickerFrameInner, {
            BackgroundColor3 = 'BackgroundColor',
            BorderColor3 = 'OutlineColor',
        })
        Library:AddToRegistry(Highlight, {
            BackgroundColor3 = 'AccentColor',
        })
        Library:AddToRegistry(SatVibMapInner, {
            BackgroundColor3 = 'BackgroundColor',
            BorderColor3 = 'OutlineColor',
        })
        Library:AddToRegistry(HueBoxInner, {
            BackgroundColor3 = 'MainColor',
            BorderColor3 = 'OutlineColor',
        })
        Library:AddToRegistry(RgbBoxBase.Frame, {
            BackgroundColor3 = 'MainColor',
            BorderColor3 = 'OutlineColor',
        })
        Library:AddToRegistry(RgbBox, {
            TextColor3 = 'FontColor',
        })
        Library:AddToRegistry(HueBox, {
            TextColor3 = 'FontColor',
        })

        local SequenceTable = {}

        for Hue = 0, 1, 0.1 do
            table.insert(SequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)))
        end

        Library:Create('UIGradient', {
            Color = ColorSequence.new(SequenceTable),
            Rotation = 90,
            Parent = HueSelectorInner,
        })
        HueBox.FocusLost:Connect(function(enter)
            if enter then
                local success, result = pcall(Color3.fromHex, HueBox.Text)

                if success and typeof(result) == 'Color3' then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(result)
                end
            end

            ColorPicker:Display()
        end)
        RgbBox.FocusLost:Connect(function(enter)
            if enter then
                local r, g, b = RgbBox.Text:match'(%d+),%s*(%d+),%s*(%d+)'

                if r and g and b then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(Color3.fromRGB(r, g, b))
                end
            end

            ColorPicker:Display()
        end)

        function ColorPicker.Display(self)
            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib)
            SatVibMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1)

            Library:Create(DisplayFrame, {
                BackgroundColor3 = ColorPicker.Value,
                BackgroundTransparency = ColorPicker.Transparency,
                BorderColor3 = Library:GetDarkerColor(ColorPicker.Value),
            })

            if TransparencyBoxInner then
                TransparencyBoxInner.BackgroundColor3 = ColorPicker.Value
                TransparencyCursor.Position = UDim2.new(1 - ColorPicker.Transparency, 0, 0, 0)
            end

            CursorOuter.Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0)
            HueCursor.Position = UDim2.new(0, 0, ColorPicker.Hue, 0)
            HueBox.Text = '#' .. ColorPicker.Value:ToHex()
            RgbBox.Text = table.concat({
                math.floor(ColorPicker.Value.R * 255),
                math.floor(ColorPicker.Value.G * 255),
                math.floor(ColorPicker.Value.B * 255),
            }, ', ')

            Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value)
            Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value)
        end
        function ColorPicker.OnChanged(self, Func)
            ColorPicker.Changed = Func

            Func(ColorPicker.Value)
        end

        if ParentObj.Addons then
            table.insert(ParentObj.Addons, ColorPicker)
        end

        function ColorPicker.Show(self)
            for Frame, Val in next, Library.OpenedFrames do
                if Frame.Name == 'Color' then
                    Frame.Visible = false
                    Library.OpenedFrames[Frame] = nil
                end
            end

            PickerFrameOuter.Visible = true
            Library.OpenedFrames[PickerFrameOuter] = true
        end
        function ColorPicker.Hide(self)
            PickerFrameOuter.Visible = false
            Library.OpenedFrames[PickerFrameOuter] = nil
        end
        function ColorPicker.SetValue(self, HSV, Transparency)
            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3])

            ColorPicker.Transparency = Transparency or 0

            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Display()
        end
        function ColorPicker.SetValueRGB(self, Color, Transparency)
            ColorPicker.Transparency = Transparency or 0

            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Display()
        end

        SatVibMap.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1 or Enum.UserInputType.Touch) do
                    local MinX = SatVibMap.AbsolutePosition.X
                    local MaxX = MinX + SatVibMap.AbsoluteSize.X
                    local MouseX, MinY = math.clamp(Mouse.X, MinX, MaxX), SatVibMap.AbsolutePosition.Y
                    local MaxY = MinY + SatVibMap.AbsoluteSize.Y
                    local MouseY = math.clamp(Mouse.Y, MinY, MaxY)

                    ColorPicker.Sat = (MouseX - MinX) / (MaxX - MinX)
                    ColorPicker.Vib = 1 - ((MouseY - MinY) / (MaxY - MinY))

                    ColorPicker:Display()
                    RenderStepped:Wait()
                end

                Library:AttemptSave()
            end
        end)
        HueSelectorInner.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1 or Enum.UserInputType.Touch) do
                    local MinY = HueSelectorInner.AbsolutePosition.Y
                    local MaxY = MinY + HueSelectorInner.AbsoluteSize.Y
                    local MouseY = math.clamp(Mouse.Y, MinY, MaxY)

                    ColorPicker.Hue = ((MouseY - MinY) / (MaxY - MinY))

                    ColorPicker:Display()
                    RenderStepped:Wait()
                end

                Library:AttemptSave()
            end
        end)
        DisplayFrame.InputBegan:Connect(function(Input)
            if Library:MouseIsOverOpenedFrame() then
                return
            end
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                if PickerFrameOuter.Visible then
                    ColorPicker:Hide()
                else
                    ContextMenu:Hide()
                    ColorPicker:Show()
                end
            elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
                ContextMenu:Show()
                ColorPicker:Hide()
            end
        end)

        if TransparencyBoxInner then
            TransparencyBoxInner.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1 or Enum.UserInputType.Touch) do
                        local MinX = TransparencyBoxInner.AbsolutePosition.X
                        local MaxX = MinX + TransparencyBoxInner.AbsoluteSize.X
                        local MouseX = math.clamp(Mouse.X, MinX, MaxX)

                        ColorPicker.Transparency = 1 - ((MouseX - MinX) / (MaxX - MinX))

                        ColorPicker:Display()
                        RenderStepped:Wait()
                    end

                    Library:AttemptSave()
                end
            end)
        end

        Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                local AbsPos, AbsSize = PickerFrameOuter.AbsolutePosition, PickerFrameOuter.AbsoluteSize

                if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then
                    ColorPicker:Hide()
                end
                if not Library:MouseIsOverFrame(ContextMenu.Container) then
                    ContextMenu:Hide()
                end
            end
            if Input.UserInputType == Enum.UserInputType.MouseButton2 and ContextMenu.Container.Visible then
                if not Library:MouseIsOverFrame(ContextMenu.Container) and not Library:MouseIsOverFrame(DisplayFrame) then
                    ContextMenu:Hide()
                end
            end
        end))
        ColorPicker:Display()

        ColorPicker.DisplayFrame = DisplayFrame
        Options[Idx] = ColorPicker

        return self
    end
    function Funcs.AddKeyPicker(self, Idx, Info)
        local ParentObj, ToggleLabel, _ = self, self.TextLabel, self.Container

        assert(Info.Default, 'AddKeyPicker: Missing default value.')

        local KeyPicker = {
            Value = Info.Default,
            Toggled = false,
            Mode = Info.Mode or 'Toggle',
            Type = 'KeyPicker',
            Callback = Info.Callback or function(Value) end,
            ChangedCallback = Info.ChangedCallback or function(New) end,
            SyncToggleState = Info.SyncToggleState or false,
        }

        if KeyPicker.SyncToggleState then
            Info.Modes = {
                'Toggle',
            }
            Info.Mode = 'Toggle'
        end

        local PickOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0),
            BorderColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(0, 28, 0, 15),
            ZIndex = 6,
            Parent = ToggleLabel,
        })
        local PickInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 7,
            Parent = PickOuter,
        })

        Library:AddToRegistry(PickInner, {
            BackgroundColor3 = 'BackgroundColor',
            BorderColor3 = 'OutlineColor',
        })

        local DisplayLabel, ModeSelectOuter = Library:CreateLabel{
            Size = UDim2.new(1, 0, 1, 0),
            TextSize = 13,
            Text = Info.Default,
            TextWrapped = true,
            ZIndex = 8,
            Parent = PickInner,
        }, Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0),
            Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y + 1),
            Size = UDim2.new(0, 60, 0, 47),
            Visible = false,
            ZIndex = 14,
            Parent = ScreenGui,
        })

        ToggleLabel:GetPropertyChangedSignal'AbsolutePosition':Connect(function()
            ModeSelectOuter.Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y + 1)
        end)

        local ModeSelectInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 15,
            Parent = ModeSelectOuter,
        })

        Library:AddToRegistry(ModeSelectInner, {
            BackgroundColor3 = 'BackgroundColor',
            BorderColor3 = 'OutlineColor',
        })
        Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = ModeSelectInner,
        })

        local KeybindsToggle = {}

        do
            local KeybindsToggleContainer = Library:Create('Frame', {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                Visible = false,
                ZIndex = 110,
                Parent = Library.KeybindContainer,
            })
            local KeybindsToggleOuter = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(0, 0, 0),
                BorderColor3 = Color3.new(0, 0, 0),
                Size = UDim2.new(0, 13, 0, 13),
                Position = UDim2.new(0, 0, 0, 6),
                Visible = true,
                ZIndex = 110,
                Parent = KeybindsToggleContainer,
            })

            Library:AddToRegistry(KeybindsToggleOuter, {
                BorderColor3 = 'Black',
            })

            local KeybindsToggleInner = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor,
                BorderColor3 = Library.OutlineColor,
                BorderMode = Enum.BorderMode.Inset,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 111,
                Parent = KeybindsToggleOuter,
            })

            Library:AddToRegistry(KeybindsToggleInner, {
                BackgroundColor3 = 'MainColor',
                BorderColor3 = 'OutlineColor',
            })

            local KeybindsToggleLabel = Library:CreateLabel{
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 216, 1, 0),
                Position = UDim2.new(1, 6, 0, -1),
                TextSize = 14,
                Text = '',
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 111,
                Parent = KeybindsToggleInner,
            }

            Library:Create('UIListLayout', {
                Padding = UDim.new(0, 4),
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = KeybindsToggleLabel,
            })

            local KeybindsToggleRegion = Library:Create('Frame', {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 170, 1, 0),
                ZIndex = 113,
                Parent = KeybindsToggleOuter,
            })

            Library:OnHighlight(KeybindsToggleRegion, KeybindsToggleOuter, {
                BorderColor3 = 'AccentColor',
            }, {
                BorderColor3 = 'Black',
            }, function()
                return true
            end)

            function KeybindsToggle.Display(self, State)
                KeybindsToggleInner.BackgroundColor3 = State and Library.AccentColor or Library.MainColor
                KeybindsToggleInner.BorderColor3 = State and Library.AccentColorDark or Library.OutlineColor
                KeybindsToggleLabel.TextColor3 = State and Library.AccentColor or Library.FontColor
                Library.RegistryMap[KeybindsToggleInner].Properties.BackgroundColor3 = State and 'AccentColor' or 'MainColor'
                Library.RegistryMap[KeybindsToggleInner].Properties.BorderColor3 = State and 'AccentColorDark' or 'OutlineColor'
                Library.RegistryMap[KeybindsToggleLabel].Properties.TextColor3 = State and 'AccentColor' or 'FontColor'
            end
            function KeybindsToggle.SetText(self, text)
                KeybindsToggleLabel.Text = text
            end
            function KeybindsToggle.SetVisibility(self, bool)
                KeybindsToggleContainer.Visible = bool
            end
            function KeybindsToggle.SetNormal(self, bool)
                KeybindsToggle.Normal = bool
                KeybindsToggleOuter.BackgroundTransparency = KeybindsToggle.Normal and 1 or 0
                KeybindsToggleInner.BackgroundTransparency = KeybindsToggle.Normal and 1 or 0
                KeybindsToggleInner.BorderSizePixel = KeybindsToggle.Normal and 0 or 1
                KeybindsToggleLabel.Position = (KeybindsToggle.Normal and {
                    (UDim2.new(1, -13, 0, -1)),
                } or {
                    (UDim2.new(1, 6, 0, -1)),
                })[1]
            end

            Library:GiveSignal(KeybindsToggleRegion.InputBegan:Connect(function(
                Input
            )
                if KeybindsToggle.Normal then
                    return
                end
                if (Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame()) or Input.UserInputType == Enum.UserInputType.Touch then
                    KeyPicker.Toggled = not KeyPicker.Toggled

                    KeyPicker:DoClick()
                end
            end))

            KeybindsToggle.Loaded = true
        end

        local Modes, ModeButtons = Info.Modes or {
            'Always',
            'Toggle',
            'Hold',
        }, {}

        for Idx, Mode in next, Modes do
            local ModeButton, Label = {}, Library:CreateLabel{
                Active = false,
                Size = UDim2.new(1, 0, 0, 15),
                TextSize = 13,
                Text = Mode,
                ZIndex = 16,
                Parent = ModeSelectInner,
            }

            function ModeButton.Select(self)
                for _, Button in next, ModeButtons do
                    Button:Deselect()
                end

                KeyPicker.Mode = Mode
                Label.TextColor3 = Library.AccentColor
                Library.RegistryMap[Label].Properties.TextColor3 = 'AccentColor'
                ModeSelectOuter.Visible = false
            end
            function ModeButton.Deselect(self)
                KeyPicker.Mode = nil
                Label.TextColor3 = Library.FontColor
                Library.RegistryMap[Label].Properties.TextColor3 = 'FontColor'
            end

            Label.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    ModeButton:Select()
                    Library:AttemptSave()
                end
            end)

            if Mode == KeyPicker.Mode then
                ModeButton:Select()
            end

            ModeButtons[Mode] = ModeButton
        end

        function KeyPicker.Update(self)
            if Info.NoUI then
                return
            end

            local State, ShowToggle = KeyPicker:GetState(), Library.ShowToggleFrameInKeybinds and KeyPicker.Mode == 'Toggle'

            if ShowToggle then
                if KeybindsToggle.Loaded then
                    KeybindsToggle:SetNormal(false)
                    KeybindsToggle:SetVisibility(true)
                    KeybindsToggle:SetText(string.format('[%s] %s (%s)', KeyPicker.Value, Info.Text, KeyPicker.Mode))
                    KeybindsToggle:Display(State)
                end
            else
                if KeybindsToggle.Loaded then
                    KeybindsToggle:SetNormal(true)
                end
            end
            if KeybindsToggle.Loaded then
                if ShowToggle then
                    KeybindsToggle:SetNormal(false)
                else
                    KeybindsToggle:SetNormal(true)
                end

                KeybindsToggle:SetVisibility(true)
                KeybindsToggle:SetText(string.format('[%s] %s (%s)', KeyPicker.Value, Info.Text, KeyPicker.Mode))
                KeybindsToggle:Display(State)
            end

            local YSize, XSize = 0, 0

            for _, Frame in next, Library.KeybindContainer:GetChildren()do
                local __DARKLUA_CONTINUE_24 = false

                repeat
                    if Frame:IsA'Frame' and Frame.Visible then
                        YSize = YSize + 18

                        local Label = Frame:FindFirstChild('TextLabel', true)

                        if not Label then
                            __DARKLUA_CONTINUE_24 = true

                            break
                        end
                        if (Label.TextBounds.X > XSize) then
                            XSize = Label.TextBounds.X + 20
                        end
                    end

                    __DARKLUA_CONTINUE_24 = true
                until true

                if not __DARKLUA_CONTINUE_24 then
                    break
                end
            end

            Library.KeybindFrame.Size = UDim2.new(0, math.max(XSize + 10, 210), 0, YSize + 23 + 6)
        end
        function KeyPicker.GetState(self)
            if KeyPicker.Mode == 'Always' then
                return true
            elseif KeyPicker.Mode == 'Hold' then
                if KeyPicker.Value == 'None' then
                    return false
                end

                local Key = KeyPicker.Value

                if Key == 'MB1' or Key == 'MB2' then
                    return Key == 'MB1' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or Key == 'MB2' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
                else
                    return InputService:IsKeyDown(Enum.KeyCode[KeyPicker.Value]) and not InputService:GetFocusedTextBox()
                end
            else
                return KeyPicker.Toggled
            end
        end
        function KeyPicker.SetValue(self, Data)
            local Key, Mode = Data[1], Data[2]

            DisplayLabel.Text = Key
            KeyPicker.Value = Key

            if ModeButtons[Mode] then
                ModeButtons[Mode]:Select()
            end

            KeyPicker:Update()
        end
        function KeyPicker.OnClick(self, Callback)
            KeyPicker.Clicked = Callback
        end
        function KeyPicker.OnChanged(self, Callback)
            KeyPicker.Changed = Callback

            Callback(KeyPicker.Value)
        end

        if ParentObj.Addons then
            table.insert(ParentObj.Addons, KeyPicker)
        end

        function KeyPicker.DoClick(self)
            if ParentObj.Type == 'Toggle' and KeyPicker.SyncToggleState then
                ParentObj:SetValue(not ParentObj.Value)
            end

            Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
            Library:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled)
        end
        function KeyPicker.SetModePickerVisibility(self, bool)
            ModeSelectOuter.Visible = bool
        end
        function KeyPicker.GetModePickerVisibility(self)
            return ModeSelectOuter.Visible
        end

        local Picking = false

        PickOuter.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                Picking = true
                DisplayLabel.Text = ''

                local Break, Text = nil, ''

                task.spawn(function()
                    while(not Break) do
                        if Text == '...' then
                            Text = ''
                        end

                        Text = Text .. '.'
                        DisplayLabel.Text = Text

                        task.wait(0.4)
                    end
                end)
                task.wait(0.2)

                local Event

                Event = InputService.InputBegan:Connect(function(Input)
                    local Key

                    if Input.UserInputType == Enum.UserInputType.Keyboard then
                        Key = Input.KeyCode.Name
                    elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Key = 'MB1'
                    elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
                        Key = 'MB2'
                    end

                    Break = true
                    Picking = false
                    DisplayLabel.Text = Key
                    KeyPicker.Value = Key

                    Library:SafeCallback(KeyPicker.ChangedCallback, Input.KeyCode or Input.UserInputType)
                    Library:SafeCallback(KeyPicker.Changed, Input.KeyCode or Input.UserInputType)
                    Library:AttemptSave()
                    Event:Disconnect()
                end)
            elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame() then
                KeyPicker:SetModePickerVisibility(not KeyPicker:GetModePickerVisibility())
            end
        end)
        Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
            if KeyPicker.Value == 'Unknown' then
                return
            end
            if (not Picking) and (not InputService:GetFocusedTextBox()) then
                if KeyPicker.Mode == 'Toggle' then
                    local Key = KeyPicker.Value

                    if Key == 'MB1' or Key == 'MB2' then
                        if Key == 'MB1' and Input.UserInputType == Enum.UserInputType.MouseButton1 or Key == 'MB2' and Input.UserInputType == Enum.UserInputType.MouseButton2 then
                            KeyPicker.Toggled = not KeyPicker.Toggled

                            KeyPicker:DoClick()
                        end
                    elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                        if Input.KeyCode.Name == Key then
                            KeyPicker.Toggled = not KeyPicker.Toggled

                            KeyPicker:DoClick()
                        end
                    end
                end

                KeyPicker:Update()
            end
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                local AbsPos, AbsSize = ModeSelectOuter.AbsolutePosition, ModeSelectOuter.AbsoluteSize

                if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then
                    KeyPicker:SetModePickerVisibility(false)
                end
            end
        end))
        Library:GiveSignal(InputService.InputEnded:Connect(function(Input)
            if (not Picking) then
                KeyPicker:Update()
            end
        end))
        KeyPicker:Update()

        KeyPicker.DisplayFrame = PickOuter
        Options[Idx] = KeyPicker

        return self
    end

    BaseAddons.__index = Funcs
    BaseAddons.__namecall = function(Table, Key, ...)
        return Funcs[Key](...)
    end
end

local BaseGroupbox = {}

do
    local Funcs = {}

    function Funcs.AddBlank(self, Size, Visible)
        local Groupbox = self
        local Container = Groupbox.Container

        return Library:Create('Frame', {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Size),
            Visible = typeof(Visible) ~= 'boolean' and true or Visible,
            ZIndex = 1,
            Parent = Container,
        })
    end
    function Funcs.AddLabel(self, ...)
        local Data = {}

        if select(2, ...) ~= nil and typeof(select(2, ...)) == 'table' then
            if select(1, ...) ~= nil then
                assert(typeof(select(1, ...)) == 'string', 'Expected string for Idx, got ' .. typeof(select(1, 
...)))
            end

            local Params = select(2, ...)

            Data.Text = Params.Text or ''
            Data.DoesWrap = Params.DoesWrap or false
            Data.Idx = select(1, ...)
        else
            Data.Text = select(1, ...) or ''
            Data.DoesWrap = select(2, ...) or false
            Data.Idx = select(3, ...) or nil
        end

        Data.OriginalText = Data.Text

        local Label, Blank, Groupbox = {}, nil, self
        local Container = Groupbox.Container
        local TextLabel = Library:CreateLabel{
            Size = UDim2.new(1, -4, 0, 15),
            TextSize = 14,
            Text = Data.Text,
            TextWrapped = Data.DoesWrap or false,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5,
            Parent = Container,
            RichText = true,
        }

        if Data.DoesWrap then
            local Y = select(2, Library:GetTextBounds(Data.Text, Library.Font, 14, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))

            TextLabel.Size = UDim2.new(1, -4, 0, Y)
        else
            Library:Create('UIListLayout', {
                Padding = UDim.new(0, 4),
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = TextLabel,
            })
        end

        Label.TextLabel = TextLabel
        Label.Container = Container

        function Label.SetText(self, Text)
            TextLabel.Text = Text

            if Data.DoesWrap then
                local Y = select(2, Library:GetTextBounds(Text, Library.Font, 14, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))

                TextLabel.Size = UDim2.new(1, -4, 0, Y)
            end

            Groupbox:Resize()
        end

        if (not Data.DoesWrap) then
            setmetatable(Label, BaseAddons)
        end

        Blank = Groupbox:AddBlank(5)

        Groupbox:Resize()

        if Data.Idx then
            Labels[Data.Idx] = Label
        else
            table.insert(Labels, Label)
        end

        return Label
    end
    function Funcs.AddButton(self, ...)
        local Button = typeof(select(1, ...)) == 'table' and select(1, ...) or {
            Text = select(1, ...),
            Func = select(2, ...),
        }

        Button.OriginalText = Button.Text

        assert(typeof(Button.Func) == 'function', 'AddButton: `Func` callback is missing.')

        local Blank, Groupbox = nil, self
        local Container, IsVisible = Groupbox.Container, typeof(Button.Visible) ~= 'boolean' and true or Button.Visible

        local function CreateBaseButton(Button)
            local Outer = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(0, 0, 0),
                BorderColor3 = Color3.new(0, 0, 0),
                Size = UDim2.new(1, -4, 0, 20),
                Visible = IsVisible,
                ZIndex = 5,
            })
            local Inner = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor,
                BorderColor3 = Library.OutlineColor,
                BorderMode = Enum.BorderMode.Inset,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 6,
                Parent = Outer,
            })
            local Label = Library:CreateLabel{
                Size = UDim2.new(1, 0, 1, 0),
                TextSize = 14,
                Text = Button.Text,
                ZIndex = 6,
                Parent = Inner,
            }

            Library:Create('UIGradient', {
                Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212)),
                },
                Rotation = 90,
                Parent = Inner,
            })
            Library:AddToRegistry(Outer, {
                BorderColor3 = 'Black',
            })
            Library:AddToRegistry(Inner, {
                BackgroundColor3 = 'MainColor',
                BorderColor3 = 'OutlineColor',
            })
            Library:OnHighlight(Outer, Outer, {
                BorderColor3 = 'AccentColor',
            }, {
                BorderColor3 = 'Black',
            })

            return Outer, Inner, Label
        end
        local function InitEvents(Button)
            local function WaitForEvent(event, timeout, validator)
                local bindable = Instance.new'BindableEvent'
                local connection = event:Once(function(...)
                    if typeof(validator) == 'function' and validator(...) then
                        bindable:Fire(true)
                    else
                        bindable:Fire(false)
                    end
                end)

                task.delay(timeout, function()
                    connection:disconnect()
                    bindable:Fire(false)
                end)

                return bindable.Event:Wait()
            end
            local function ValidateClick(Input)
                if Library:MouseIsOverOpenedFrame(Input) then
                    return false
                end
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    return true
                elseif Input.UserInputType == Enum.UserInputType.Touch then
                    return true
                else
                    return false
                end
            end

            Button.Outer.InputBegan:Connect(function(Input)
                if not ValidateClick(Input) then
                    return
                end
                if Button.Locked then
                    return
                end
                if Button.DoubleClick then
                    Library:RemoveFromRegistry(Button.Label)
                    Library:AddToRegistry(Button.Label, {
                        TextColor3 = 'AccentColor',
                    })

                    Button.Label.TextColor3 = Library.AccentColor
                    Button.Label.Text = 'Are you sure?'
                    Button.Locked = true

                    local clicked = WaitForEvent(Button.Outer.InputBegan, 0.5, ValidateClick)

                    Library:RemoveFromRegistry(Button.Label)
                    Library:AddToRegistry(Button.Label, {
                        TextColor3 = 'FontColor',
                    })

                    Button.Label.TextColor3 = Library.FontColor
                    Button.Label.Text = Button.Text

                    task.defer(rawset, Button, 'Locked', false)

                    if clicked then
                        Library:SafeCallback(Button.Func)
                    end

                    return
                end

                Library:SafeCallback(Button.Func)
            end)
        end

        Button.Outer, Button.Inner, Button.Label = CreateBaseButton(Button)
        Button.Outer.Parent = Container

        InitEvents(Button)

        function Button.AddTooltip(self, tooltip)
            if typeof(tooltip) == 'string' then
                Library:AddToolTip(tooltip, self.Outer)
            end

            return self
        end
        function Button.AddButton(self, ...)
            local SubButton = typeof(select(1, ...)) == 'table' and select(1, 
...) or {
                Text = select(1, ...),
                Func = select(2, ...),
            }

            assert(typeof(SubButton.Func) == 'function', 'AddButton: `Func` callback is missing.')

            self.Outer.Size = UDim2.new(0.5, -2, 0, 20)
            SubButton.Outer, SubButton.Inner, SubButton.Label = CreateBaseButton(SubButton)
            SubButton.Outer.Position = UDim2.new(1, 3, 0, 0)
            SubButton.Outer.Size = UDim2.new(1, -3, 1, 0)
            SubButton.Outer.Parent = self.Outer

            function SubButton.AddTooltip(self, tooltip)
                if typeof(tooltip) == 'string' then
                    Library:AddToolTip(tooltip, self.Outer)
                end

                return SubButton
            end

            if typeof(SubButton.Tooltip) == 'string' then
                SubButton:AddTooltip(SubButton.Tooltip)
            end

            InitEvents(SubButton)

            return SubButton
        end

        if typeof(Button.Tooltip) == 'string' then
            Button:AddTooltip(Button.Tooltip)
        end

        function Button.SetVisible(self, Visibility)
            IsVisible = Visibility
            Button.Outer.Visible = IsVisible

            if Blank then
                Blank.Visible = IsVisible
            end

            Groupbox:Resize()
        end
        function Button.SetText(self, Text)
            if typeof(Text) == 'string' then
                Button.Text = Text
                Button.Label.Text = Button.Text
            end
        end

        Blank = Groupbox:AddBlank(5, IsVisible)

        Groupbox:Resize()
        table.insert(Buttons, Button)

        return Button
    end
    function Funcs.AddDivider(self)
        local Groupbox, Container = self, self.Container

        Groupbox:AddBlank(2)

        local DividerOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0),
            BorderColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(1, -4, 0, 5),
            ZIndex = 5,
            Parent = Container,
        })
        local DividerInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 6,
            Parent = DividerOuter,
        })

        Library:AddToRegistry(DividerOuter, {
            BorderColor3 = 'Black',
        })
        Library:AddToRegistry(DividerInner, {
            BackgroundColor3 = 'MainColor',
            BorderColor3 = 'OutlineColor',
        })
        Groupbox:AddBlank(9)
        Groupbox:Resize()
    end
    function Funcs.AddInput(self, Idx, Info)
        assert(Info.Text, 'AddInput: Missing `Text` string.')

        local Textbox, Groupbox = {
            Value = Info.Default or '',
            Numeric = Info.Numeric or false,
            Finished = Info.Finished or false,
            Type = 'Input',
            Callback = Info.Callback or function(Value) end,
        }, self
        local Container = Groupbox.Container

        Library:CreateLabel{
            Size = UDim2.new(1, 0, 0, 15),
            TextSize = 14,
            Text = Info.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5,
            Parent = Container,
        }
        Groupbox:AddBlank(1)

        local TextBoxOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0),
            BorderColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(1, -4, 0, 20),
            ZIndex = 5,
            Parent = Container,
        })
        local TextBoxInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 6,
            Parent = TextBoxOuter,
        })

        Library:AddToRegistry(TextBoxInner, {
            BackgroundColor3 = 'MainColor',
            BorderColor3 = 'OutlineColor',
        })
        Library:OnHighlight(TextBoxOuter, TextBoxOuter, {
            BorderColor3 = 'AccentColor',
        }, {
            BorderColor3 = 'Black',
        })

        if typeof(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, TextBoxOuter)
        end

        Library:Create('UIGradient', {
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212)),
            },
            Rotation = 90,
            Parent = TextBoxInner,
        })

        local Container = Library:Create('Frame', {
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Position = UDim2.new(0, 5, 0, 0),
            Size = UDim2.new(1, -5, 1, 0),
            ZIndex = 7,
            Parent = TextBoxInner,
        })
        local Box = Library:Create('TextBox', {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromScale(5, 1),
            Font = Library.Font,
            PlaceholderColor3 = Color3.fromRGB(190, 190, 190),
            PlaceholderText = Info.Placeholder or '',
            Text = Info.Default or '',
            TextColor3 = Library.FontColor,
            TextSize = 14,
            TextStrokeTransparency = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = (typeof(Info.ClearTextOnFocus) ~= 'boolean' and true or Info.ClearTextOnFocus),
            ZIndex = 7,
            Parent = Container,
        })

        Library:ApplyTextStroke(Box)

        function Textbox.SetValue(self, Text)
            if Info.MaxLength and #Text > Info.MaxLength then
                Text = Text:sub(1, Info.MaxLength)
            end
            if Textbox.Numeric then
                if (not tonumber(Text)) and Text:len() > 0 then
                    Text = Textbox.Value
                end
            end

            Textbox.Value = Text
            Box.Text = Text

            Library:SafeCallback(Textbox.Callback, Textbox.Value)
            Library:SafeCallback(Textbox.Changed, Textbox.Value)
        end

        if Textbox.Finished then
            Box.FocusLost:Connect(function(enter)
                if not enter then
                    return
                end

                Textbox:SetValue(Box.Text)
                Library:AttemptSave()
            end)
        else
            Box:GetPropertyChangedSignal'Text':Connect(function()
                Textbox:SetValue(Box.Text)
                Library:AttemptSave()
            end)
        end

        local function Update()
            local PADDING, reveal = 2, Container.AbsoluteSize.X

            if not Box:IsFocused() or Box.TextBounds.X <= reveal - 2 * PADDING then
                Box.Position = UDim2.new(0, PADDING, 0, 0)
            else
                local cursor = Box.CursorPosition

                if cursor ~= -1 then
                    local subtext = string.sub(Box.Text, 1, cursor - 1)
                    local width = TextService:GetTextSize(subtext, Box.TextSize, Box.Font, Vector2.new(math.huge, math.huge)).X
                    local currentCursorPos = Box.Position.X.Offset + width

                    if currentCursorPos < PADDING then
                        Box.Position = UDim2.fromOffset(PADDING - width, 0)
                    elseif currentCursorPos > reveal - PADDING - 1 then
                        Box.Position = UDim2.fromOffset(reveal - width - PADDING - 1, 0)
                    end
                end
            end
        end

        task.spawn(Update)
        Box:GetPropertyChangedSignal'Text':Connect(Update)
        Box:GetPropertyChangedSignal'CursorPosition':Connect(Update)
        Box.FocusLost:Connect(Update)
        Box.Focused:Connect(Update)
        Library:AddToRegistry(Box, {
            TextColor3 = 'FontColor',
        })

        function Textbox.OnChanged(self, Func)
            Textbox.Changed = Func

            Func(Textbox.Value)
        end

        Groupbox:AddBlank(5)
        Groupbox:Resize()

        Options[Idx] = Textbox

        return Textbox
    end
    function Funcs.AddToggle(self, Idx, Info)
        assert(Info.Text, 'AddInput: Missing `Text` string.')

        local Toggle, Blank, Groupbox = {
            Value = Info.Default or false,
            Type = 'Toggle',
            Visible = typeof(Info.Visible) ~= 'boolean' and true or Info.Visible,
            OriginalText = Info.Text,
            Text = Info.Text,
            Callback = Info.Callback or function(Value) end,
            Addons = {},
            Risky = Info.Risky,
        }, nil, self
        local Container = Groupbox.Container
        local ToggleOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0),
            BorderColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(0, 13, 0, 13),
            Visible = Toggle.Visible,
            ZIndex = 5,
            Parent = Container,
        })

        Library:AddToRegistry(ToggleOuter, {
            BorderColor3 = 'Black',
        })

        local ToggleInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 6,
            Parent = ToggleOuter,
        })

        Library:AddToRegistry(ToggleInner, {
            BackgroundColor3 = 'MainColor',
            BorderColor3 = 'OutlineColor',
        })

        local ToggleLabel = Library:CreateLabel{
            Size = UDim2.new(0, 216, 1, 0),
            Position = UDim2.new(1, 6, 0, -1),
            TextSize = 14,
            Text = Info.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 6,
            Parent = ToggleInner,
        }

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 4),
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = ToggleLabel,
        })

        local ToggleRegion = Library:Create('Frame', {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 170, 1, 0),
            ZIndex = 8,
            Parent = ToggleOuter,
        })

        Library:OnHighlight(ToggleRegion, ToggleOuter, {
            BorderColor3 = 'AccentColor',
        }, {
            BorderColor3 = 'Black',
        }, function()
            for _, Addon in next, Toggle.Addons do
                if Library:MouseIsOverFrame(Addon.DisplayFrame) then
                    return false
                end
            end

            return true
        end)

        function Toggle.UpdateColors(self)
            Toggle:Display()
        end

        if typeof(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, ToggleRegion)
        end

        function Toggle.Display(self)
            ToggleInner.BackgroundColor3 = Toggle.Value and Library.AccentColor or Library.MainColor
            ToggleInner.BorderColor3 = Toggle.Value and Library.AccentColorDark or Library.OutlineColor
            Library.RegistryMap[ToggleInner].Properties.BackgroundColor3 = Toggle.Value and 'AccentColor' or 'MainColor'
            Library.RegistryMap[ToggleInner].Properties.BorderColor3 = Toggle.Value and 'AccentColorDark' or 'OutlineColor'
        end
        function Toggle.OnChanged(self, Func)
            Toggle.Changed = Func

            Func(Toggle.Value)
        end
        function Toggle.SetValue(self, Bool)
            Bool = (not not Bool)
            Toggle.Value = Bool

            Toggle:Display()

            for _, Addon in next, Toggle.Addons do
                if Addon.Type == 'KeyPicker' and Addon.SyncToggleState then
                    Addon.Toggled = Bool

                    Addon:Update()
                end
            end

            Library:SafeCallback(Toggle.Callback, Toggle.Value)
            Library:SafeCallback(Toggle.Changed, Toggle.Value)
            Library:UpdateDependencyBoxes()
        end
        function Toggle.SetVisible(self, Visibility)
            Toggle.Visible = Visibility
            ToggleOuter.Visible = Toggle.Visible

            if Blank then
                Blank.Visible = Toggle.Visible
            end

            Groupbox:Resize()
        end
        function Toggle.SetText(self, Text)
            if typeof(Text) == 'string' then
                Toggle.Text = Text
                ToggleLabel.Text = Toggle.Text
            end
        end

        ToggleRegion.InputBegan:Connect(function(Input)
            if (Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame()) or Input.UserInputType == Enum.UserInputType.Touch then
                for _, Addon in next, Toggle.Addons do
                    if Library:MouseIsOverFrame(Addon.DisplayFrame) then
                        return
                    end
                end

                Toggle:SetValue(not Toggle.Value)
                Library:AttemptSave()
            end
        end)

        if Toggle.Risky then
            Library:RemoveFromRegistry(ToggleLabel)

            ToggleLabel.TextColor3 = Library.RiskColor

            Library:AddToRegistry(ToggleLabel, {
                TextColor3 = 'RiskColor',
            })
        end

        Toggle:Display()

        Blank = Groupbox:AddBlank(Info.BlankSize or 7, Toggle.Visible)

        Groupbox:Resize()

        Toggle.TextLabel = ToggleLabel
        Toggle.Container = Container

        setmetatable(Toggle, BaseAddons)

        Toggles[Idx] = Toggle

        Library:UpdateDependencyBoxes()

        return Toggle
    end
    function Funcs.AddSlider(self, Idx, Info)
        assert(Info.Default, 'AddSlider: Missing default value.')
        assert(Info.Text, 'AddSlider: Missing slider text.')
        assert(Info.Min, 'AddSlider: Missing minimum value.')
        assert(Info.Max, 'AddSlider: Missing maximum value.')
        assert(Info.Rounding, 'AddSlider: Missing rounding value.')

        local Slider, Blanks, SliderText, Groupbox = {
            Value = Info.Default,
            Min = Info.Min,
            Max = Info.Max,
            Rounding = Info.Rounding,
            MaxSize = 232,
            Type = 'Slider',
            Visible = typeof(Info.Visible) ~= 'boolean' and true or Info.Visible,
            Callback = Info.Callback or function(Value) end,
            OriginalText = Info.Text,
            Text = Info.Text,
        }, {}, nil, self
        local Container = Groupbox.Container

        if not Info.Compact then
            SliderText = Library:CreateLabel{
                Size = UDim2.new(1, 0, 0, 10),
                TextSize = 14,
                Text = Info.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Bottom,
                Visible = Slider.Visible,
                ZIndex = 5,
                Parent = Container,
            }

            table.insert(Blanks, Groupbox:AddBlank(3, Slider.Visible))
        end

        local SliderOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0),
            BorderColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(1, -4, 0, 13),
            Visible = Slider.Visible,
            ZIndex = 5,
            Parent = Container,
        })

        SliderOuter:GetPropertyChangedSignal'AbsoluteSize':Connect(function()
            Slider.MaxSize = SliderOuter.AbsoluteSize.X - 2
        end)
        Library:AddToRegistry(SliderOuter, {
            BorderColor3 = 'Black',
        })

        local SliderInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 6,
            Parent = SliderOuter,
        })

        Library:AddToRegistry(SliderInner, {
            BackgroundColor3 = 'MainColor',
            BorderColor3 = 'OutlineColor',
        })

        local Fill = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor,
            BorderColor3 = Library.AccentColorDark,
            Size = UDim2.new(0, 0, 1, 0),
            ZIndex = 7,
            Parent = SliderInner,
        })

        Library:AddToRegistry(Fill, {
            BackgroundColor3 = 'AccentColor',
            BorderColor3 = 'AccentColorDark',
        })

        local HideBorderRight = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor,
            BorderSizePixel = 0,
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(0, 1, 1, 0),
            ZIndex = 8,
            Parent = Fill,
        })

        Library:AddToRegistry(HideBorderRight, {
            BackgroundColor3 = 'AccentColor',
        })

        local DisplayLabel = Library:CreateLabel{
            Size = UDim2.new(1, 0, 1, 0),
            TextSize = 14,
            Text = 'Infinite',
            ZIndex = 9,
            Parent = SliderInner,
        }

        Library:OnHighlight(SliderOuter, SliderOuter, {
            BorderColor3 = 'AccentColor',
        }, {
            BorderColor3 = 'Black',
        })

        if typeof(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, SliderOuter)
        end

        function Slider.UpdateColors(self)
            Fill.BackgroundColor3 = Library.AccentColor
            Fill.BorderColor3 = Library.AccentColorDark
        end
        function Slider.Display(self)
            local Suffix = Info.Suffix or ''

            if Info.Compact then
                DisplayLabel.Text = Slider.Text .. ': ' .. Slider.Value .. Suffix
            elseif Info.HideMax then
                DisplayLabel.Text = string.format('%s', Slider.Value .. Suffix)
            else
                DisplayLabel.Text = string.format('%s/%s', Slider.Value .. Suffix, Slider.Max .. Suffix)
            end

            local X = Library:MapValue(Slider.Value, Slider.Min, Slider.Max, 0, 1)

            Fill.Size = UDim2.new(X, 0, 1, 0)
            HideBorderRight.Visible = not (X == 1 or X == 0)
        end
        function Slider.OnChanged(self, Func)
            Slider.Changed = Func

            Func(Slider.Value)
        end

        local function Round(Value)
            if Slider.Rounding == 0 then
                return math.floor(Value)
            end

            return tonumber(string.format('%.' .. Slider.Rounding .. 'f', Value))
        end

        function Slider.GetValueFromXScale(self, X)
            return Round(Library:MapValue(X, 0, 1, Slider.Min, Slider.Max))
        end
        function Slider.SetMax(self, Value)
            assert(Value > Slider.Min, 'Max value cannot be less than the current min value.')

            Slider.Value = math.clamp(Slider.Value, Slider.Min, Value)
            Slider.Max = Value

            Slider:Display()
        end
        function Slider.SetMin(self, Value)
            assert(Value < Slider.Max, 'Min value cannot be greater than the current max value.')

            Slider.Value = math.clamp(Slider.Value, Value, Slider.Max)
            Slider.Min = Value

            Slider:Display()
        end
        function Slider.SetValue(self, Str)
            local Num = tonumber(Str)

            if (not Num) then
                return
            end

            Num = math.clamp(Num, Slider.Min, Slider.Max)
            Slider.Value = Num

            Slider:Display()
            Library:SafeCallback(Slider.Callback, Slider.Value)
            Library:SafeCallback(Slider.Changed, Slider.Value)
        end
        function Slider.SetVisible(self, Visibility)
            Slider.Visible = Visibility

            if SliderText then
                SliderText.Visible = Slider.Visible
            end

            SliderOuter.Visible = Slider.Visible

            for _, Blank in pairs(Blanks)do
                Blank.Visible = Slider.Visible
            end

            Groupbox:Resize()
        end
        function Slider.SetText(self, Text)
            if typeof(Text) == 'string' then
                Slider.Text = Text

                if SliderText then
                    SliderText.Text = Slider.Text
                end

                Slider:Display()
            end
        end

        SliderInner.InputBegan:Connect(function(Input)
            if (Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame()) or Input.UserInputType == Enum.UserInputType.Touch then
                if Library.IsMobile then
                    Library.CanDrag = false
                end

                local Sides = {}

                if Library.Window then
                    Sides = Library.Window.Tabs[Library.ActiveTab]:GetSides()
                end

                for _, Side in pairs(Sides)do
                    if typeof(Side) == 'Instance' then
                        if Side:IsA'ScrollingFrame' then
                            Side.ScrollingEnabled = false
                        end
                    end
                end

                local mPos, gPos = Mouse.X, Fill.AbsoluteSize.X
                local Diff = mPos - (Fill.AbsolutePosition.X + gPos)

                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1 or Enum.UserInputType.Touch) do
                    local nMPos = Mouse.X
                    local nXOffset = math.clamp(gPos + (nMPos - mPos) + Diff, 0, Slider.MaxSize)
                    local nXScale = Library:MapValue(nXOffset, 0, Slider.MaxSize, 0, 1)
                    local nValue, OldValue = Slider:GetValueFromXScale(nXScale), Slider.Value

                    Slider.Value = nValue

                    Slider:Display()

                    if nValue ~= OldValue then
                        Library:SafeCallback(Slider.Callback, Slider.Value)
                        Library:SafeCallback(Slider.Changed, Slider.Value)
                    end

                    RenderStepped:Wait()
                end

                if Library.IsMobile then
                    Library.CanDrag = true
                end

                for _, Side in pairs(Sides)do
                    if typeof(Side) == 'Instance' then
                        if Side:IsA'ScrollingFrame' then
                            Side.ScrollingEnabled = true
                        end
                    end
                end

                Library:AttemptSave()
            end
        end)
        Slider:Display()
        table.insert(Blanks, Groupbox:AddBlank(Info.BlankSize or 6, Slider.Visible))
        Groupbox:Resize()

        Options[Idx] = Slider

        return Slider
    end
    function Funcs.AddDropdown(self, Idx, Info)
        assert(Info.Text and Info.Values, 'Bad Dropdown Data')

        local Dropdown, Groupbox = {
            Values = Info.Values,
            Value = Info.Multi and {},
            Multi = Info.Multi,
            Type = 'Dropdown',
            Callback = Info.Callback,
        }, self
        local Container, RelativeOffset = Groupbox.Container, 0

        if not Info.Compact then
            Library:CreateLabel{
                Size = UDim2.new(1, 0, 0, 10),
                TextSize = 14,
                Text = Info.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Bottom,
                ZIndex = 5,
                Parent = Container,
            }
            Groupbox:AddBlank(3)
        end

        for _, Element in next, Container:GetChildren()do
            if not Element:IsA'UIListLayout' then
                RelativeOffset = RelativeOffset + Element.Size.Y.Offset
            end
        end

        local DropdownOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0),
            BorderColor3 = Color3.new(0, 0, 0),
            Size = UDim2.new(1, -4, 0, 20),
            ZIndex = 5,
            Parent = Container,
        })

        Library:AddToRegistry(DropdownOuter, {
            BorderColor3 = 'Black',
        })

        local DropdownInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 6,
            Parent = DropdownOuter,
        })

        Library:AddToRegistry(DropdownInner, {
            BackgroundColor3 = 'MainColor',
            BorderColor3 = 'OutlineColor',
        })
        Library:Create('UIGradient', {
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212)),
            },
            Rotation = 90,
            Parent = DropdownInner,
        })

        local DropdownArrow, ItemList = Library:Create('ImageLabel', {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -16, 0.5, 0),
            Size = UDim2.new(0, 12, 0, 12),
            Image = 'http://www.roblox.com/asset/?id=6282522798',
            ZIndex = 8,
            Parent = DropdownInner,
        }), Library:CreateLabel{
            Position = UDim2.new(0, 5, 0, 0),
            Size = UDim2.new(1, -5, 1, 0),
            TextSize = 14,
            Text = '--',
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            ZIndex = 7,
            Parent = DropdownInner,
        }

        Library:OnHighlight(DropdownOuter, DropdownOuter, {
            BorderColor3 = 'AccentColor',
        }, {
            BorderColor3 = 'Black',
        })

        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, DropdownOuter)
        end

        local MAX_DROPDOWN_ITEMS, ListOuter = (Info.MaxItems or 8), Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0),
            BorderColor3 = Color3.new(0, 0, 0),
            ZIndex = 20,
            Visible = false,
            Parent = ScreenGui,
        })

        local function RecalculateListPosition()
            ListOuter.Position = UDim2.fromOffset(DropdownOuter.AbsolutePosition.X, DropdownOuter.AbsolutePosition.Y + DropdownOuter.Size.Y.Offset + 1)
        end
        local function RecalculateListSize(YSize)
            ListOuter.Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X, YSize or (MAX_DROPDOWN_ITEMS * 20 + 2))
        end

        RecalculateListPosition()
        RecalculateListSize()
        DropdownOuter:GetPropertyChangedSignal'AbsolutePosition':Connect(RecalculateListPosition)

        local ListInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 21,
            Parent = ListOuter,
        })

        Library:AddToRegistry(ListInner, {
            BackgroundColor3 = 'MainColor',
            BorderColor3 = 'OutlineColor',
        })

        local Scrolling = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 21,
            Parent = ListInner,
            TopImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
            BottomImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Library.AccentColor,
        })

        Library:AddToRegistry(Scrolling, {
            ScrollBarImageColor3 = 'AccentColor',
        })
        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 0),
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = Scrolling,
        })

        function Dropdown.Display(self)
            local Values, Str = Dropdown.Values, ''

            if Info.Multi then
                for Idx, Value in next, Values do
                    if Dropdown.Value[Value] then
                        Str = Str .. Value .. ', '
                    end
                end

                Str = Str:sub(1, #Str - 2)
            else
                Str = Dropdown.Value or ''
            end

            ItemList.Text = (Str == '' and '--' or Str)
        end
        function Dropdown.GetActiveValues(self)
            if Info.Multi then
                local T = {}

                for Value, Bool in next, Dropdown.Value do
                    table.insert(T, Value)
                end

                return T
            else
                return Dropdown.Value and 1 or 0
            end
        end
        function Dropdown.BuildDropdownList(self)
            local Values, Buttons = Dropdown.Values, {}

            for _, Element in next, Scrolling:GetChildren()do
                if not Element:IsA'UIListLayout' then
                    Element:Destroy()
                end
            end

            local Count = 0

            for Idx, Value in next, Values do
                local Table = {}

                Count = Count + 1

                local Button = Library:Create('Frame', {
                    BackgroundColor3 = Library.MainColor,
                    BorderColor3 = Library.OutlineColor,
                    BorderMode = Enum.BorderMode.Middle,
                    Size = UDim2.new(1, -1, 0, 20),
                    ZIndex = 23,
                    Active = true,
                    Parent = Scrolling,
                })

                Library:AddToRegistry(Button, {
                    BackgroundColor3 = 'MainColor',
                    BorderColor3 = 'OutlineColor',
                })

                local ButtonLabel, Clicking = Library:CreateLabel{
                    Active = false,
                    Size = UDim2.new(1, -6, 1, 0),
                    Position = UDim2.new(0, 6, 0, 0),
                    TextSize = 14,
                    Text = Value,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 25,
                    Parent = Button,
                }, Library:Create('TextButton', {
                    Size = UDim2.new(1, 0, 1, 0),
                    TextSize = 18,
                    Text = '',
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    ZIndex = 26,
                    Parent = Button,
                })

                Library:OnHighlight(Button, Button, {
                    BorderColor3 = 'AccentColor',
                    ZIndex = 24,
                }, {
                    BorderColor3 = 'OutlineColor',
                    ZIndex = 23,
                })

                local Selected

                if Info.Multi then
                    Selected = Dropdown.Value[Value]
                else
                    Selected = Dropdown.Value == Value
                end

                function Table.UpdateButton(self)
                    if Info.Multi then
                        Selected = Dropdown.Value[Value]
                    else
                        Selected = Dropdown.Value == Value
                    end

                    ButtonLabel.TextColor3 = Selected and Library.AccentColor or Library.FontColor
                    Library.RegistryMap[ButtonLabel].Properties.TextColor3 = Selected and 'AccentColor' or 'FontColor'
                end

                Clicking.MouseButton1Click:Connect(function()
                    if not Library:isHolding(ButtonLabel) then
                        local Try = not Selected

                        if Dropdown:GetActiveValues() == 1 and (not Try) and (not Info.AllowNull) then
                        else
                            if Info.Multi then
                                Selected = Try

                                if Selected then
                                    Dropdown.Value[Value] = true
                                else
                                    Dropdown.Value[Value] = nil
                                end
                            else
                                Selected = Try

                                if Selected then
                                    Dropdown.Value = Value
                                else
                                    Dropdown.Value = nil
                                end

                                for _, OtherButton in next, Buttons do
                                    OtherButton:UpdateButton()
                                end
                            end

                            Table:UpdateButton()
                            Dropdown:Display()
                            Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
                            Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
                            Library:AttemptSave()
                        end
                    end
                end)
                Table:UpdateButton()
                Dropdown:Display()

                Buttons[Button] = Table
            end

            Scrolling.CanvasSize = UDim2.fromOffset(0, (Count * 20) + 1)

            local Y = math.clamp(Count * 20, 0, MAX_DROPDOWN_ITEMS * 20) + 1

            RecalculateListSize(Y)
        end
        function Dropdown.SetValues(self, NewValues)
            if NewValues then
                Dropdown.Values = NewValues
            end

            Dropdown:BuildDropdownList()
        end
        function Dropdown.OpenDropdown(self)
            if Library.IsMobile then
                Library.CanDrag = false
            end

            ListOuter.Visible = true
            Library.OpenedFrames[ListOuter] = true
            DropdownArrow.Rotation = 180
        end
        function Dropdown.CloseDropdown(self)
            if Library.IsMobile then
                Library.CanDrag = true
            end

            ListOuter.Visible = false
            Library.OpenedFrames[ListOuter] = nil
            DropdownArrow.Rotation = 0
        end
        function Dropdown.OnChanged(self, Func)
            Dropdown.Changed = Func

            Func(Dropdown.Value)
        end
        function Dropdown.SetValue(self, Val)
            if Dropdown.Multi then
                local nTable = {}

                for Value, Bool in next, Val do
                    if table.find(Dropdown.Values, Value) then
                        nTable[Value] = true
                    end
                end

                Dropdown.Value = nTable
            else
                if (not Val) then
                    Dropdown.Value = nil
                elseif table.find(Dropdown.Values, Val) then
                    Dropdown.Value = Val
                end
            end

            Dropdown:BuildDropdownList()
            Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
            Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
        end

        DropdownOuter.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch and not Library:MouseIsOverOpenedFrame() then
                if ListOuter.Visible then
                    Dropdown:CloseDropdown()
                else
                    Dropdown:OpenDropdown()
                end
            end
        end)
        InputService.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                local AbsPos, AbsSize = ListOuter.AbsolutePosition, ListOuter.AbsoluteSize

                if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then
                    Dropdown:CloseDropdown()
                end
            end
        end)
        Dropdown:BuildDropdownList()
        Dropdown:Display()

        local Defaults = {}

        if type(Info.Default) == 'string' then
            local Idx = table.find(Dropdown.Values, Info.Default)

            if Idx then
                table.insert(Defaults, Idx)
            end
        elseif type(Info.Default) == 'table' then
            for _, Value in next, Info.Default do
                local Idx = table.find(Dropdown.Values, Value)

                if Idx then
                    table.insert(Defaults, Idx)
                end
            end
        elseif type(Info.Default) == 'number' and Dropdown.Values[Info.Default] ~= nil then
            table.insert(Defaults, Info.Default)
        end
        if next(Defaults) then
            for i = 1, #Defaults do
                local Index = Defaults[i]

                if Info.Multi then
                    Dropdown.Value[Dropdown.Values[Index] ] = true
                else
                    Dropdown.Value = Dropdown.Values[Index]
                end
                if (not Info.Multi) then
                    break
                end
            end

            Dropdown:BuildDropdownList()
            Dropdown:Display()
        end

        Groupbox:AddBlank(Info.BlankSize or 5)
        Groupbox:Resize()

        Options[Idx] = Dropdown

        return Dropdown
    end
    function Funcs.AddDependencyBox(self)
        local Depbox, Groupbox = {Dependencies = {}}, self
        local Container = Groupbox.Container
        local Holder = Library:Create('Frame', {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Visible = false,
            Parent = Container,
        })
        local Frame = Library:Create('Frame', {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = true,
            Parent = Holder,
        })
        local Layout = Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = Frame,
        })

        function Depbox.Resize(self)
            Holder.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y)

            Groupbox:Resize()
        end

        Layout:GetPropertyChangedSignal'AbsoluteContentSize':Connect(function()
            Depbox:Resize()
        end)
        Holder:GetPropertyChangedSignal'Visible':Connect(function()
            Depbox:Resize()
        end)

        function Depbox.Update(self)
            for _, Dependency in next, Depbox.Dependencies do
                local Elem, Value = Dependency[1], Dependency[2]

                if (Elem.Multi and {
                    (not table.find(Elem:GetActiveValues(), Value)),
                } or {
                    (Elem.Value ~= Value),
                })[1] then
                    Holder.Visible = false

                    Depbox:Resize()

                    return
                end
            end

            Holder.Visible = true

            Depbox:Resize()
        end
        function Depbox.SetupDependencies(self, Dependencies)
            for _, Dependency in next, Dependencies do
                assert(typeof(Dependency) == 'table', 'SetupDependencies: Dependency is not of type `table`.')
                assert(Dependency[1], 'SetupDependencies: Dependency is missing element argument.')
                assert(Dependency[2] ~= nil, 'SetupDependencies: Dependency is missing value argument.')
            end

            Depbox.Dependencies = Dependencies

            Depbox:Update()
        end

        Depbox.Container = Frame

        setmetatable(Depbox, BaseGroupbox)
        table.insert(Library.DependencyBoxes, Depbox)

        return Depbox
    end

    BaseGroupbox.__index = Funcs
    BaseGroupbox.__namecall = function(Table, Key, ...)
        return Funcs[Key](...)
    end
end
do
    Library.LeftNotificationArea = Library:Create('Frame', {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(0, 300, 0, 200),
        ZIndex = 100,
        Parent = ScreenGui,
    })

    Library:Create('UIListLayout', {
        Padding = UDim.new(0, 4),
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Library.LeftNotificationArea,
    })

    Library.RightNotificationArea = Library:Create('Frame', {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 0, 0, 40),
        Size = UDim2.new(0, 300, 0, 200),
        ZIndex = 100,
        Parent = ScreenGui,
    })

    Library:Create('UIListLayout', {
        Padding = UDim.new(0, 4),
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Library.RightNotificationArea,
    })

    local WatermarkOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0),
        Position = UDim2.new(0, 166, 0, -35),
        Size = UDim2.new(0, 213, 0, 20),
        ZIndex = 200,
        Visible = false,
        Parent = ScreenGui,
    })
    local WatermarkInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.AccentColor,
        BorderMode = Enum.BorderMode.Inset,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 201,
        Parent = WatermarkOuter,
    })

    Library:AddToRegistry(WatermarkInner, {
        BorderColor3 = 'AccentColor',
    })

    local InnerFrame = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = 202,
        Parent = WatermarkInner,
    })
    local Gradient = Library:Create('UIGradient', {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
            ColorSequenceKeypoint.new(1, Library.MainColor),
        },
        Rotation = -90,
        Parent = InnerFrame,
    })

    Library:AddToRegistry(Gradient, {
        Color = function()
            return ColorSequence.new{
                ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                ColorSequenceKeypoint.new(1, Library.MainColor),
            }
        end,
    })

    local WatermarkLabel = Library:CreateLabel{
        Position = UDim2.new(0, 5, 0, 0),
        Size = UDim2.new(1, -4, 1, 0),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 203,
        Parent = InnerFrame,
    }

    Library.Watermark = WatermarkOuter
    Library.WatermarkText = WatermarkLabel

    InnerFrame.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch and not Library:MouseIsOverOpenedFrame() then
            task.spawn(Library.Toggle)
        end
    end)

    local KeybindOuter = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0, 0.5),
        BorderColor3 = Color3.new(0, 0, 0),
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.new(0, 210, 0, 20),
        Visible = false,
        ZIndex = 100,
        Parent = ScreenGui,
    })
    local KeybindInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.OutlineColor,
        BorderMode = Enum.BorderMode.Inset,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 101,
        Parent = KeybindOuter,
    })

    Library:AddToRegistry(KeybindInner, {
        BackgroundColor3 = 'MainColor',
        BorderColor3 = 'OutlineColor',
    }, true)

    local ColorFrame = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2),
        ZIndex = 102,
        Parent = KeybindInner,
    })

    Library:AddToRegistry(ColorFrame, {
        BackgroundColor3 = 'AccentColor',
    }, true)
    Library:CreateLabel{
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.fromOffset(5, 2),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = 'Keybinds',
        ZIndex = 104,
        Parent = KeybindInner,
    }
    Library:MakeDraggable(KeybindOuter)

    local KeybindContainer = Library:Create('Frame', {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -20),
        Position = UDim2.new(0, 0, 0, 20),
        ZIndex = 1,
        Parent = KeybindInner,
    })

    Library:Create('UIListLayout', {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = KeybindContainer,
    })
    Library:Create('UIPadding', {
        PaddingLeft = UDim.new(0, 5),
        Parent = KeybindContainer,
    })

    Library.KeybindFrame = KeybindOuter
    Library.KeybindContainer = KeybindContainer

    Library:MakeDraggable(KeybindOuter)
end

function Library.SetWatermarkVisibility(self, Bool)
    Library.Watermark.Visible = Bool
end
function Library.SetWatermark(self, Text)
    local X, Y = Library:GetTextBounds(Text, Library.Font, 14)

    Library.Watermark.Size = UDim2.new(0, X + 15, 0, (Y * 1.5) + 3)

    Library:SetWatermarkVisibility(true)

    Library.WatermarkText.Text = Text
end
function Library.Notify(self, Text, Time, SoundId)
    local Side = string.lower(Library.NotifySide)

    if Side == 'right' then
        Library:RightNotify(Text, Time, SoundId)
    else
        Library:LeftNotify(Text, Time, SoundId)
    end
end
function Library.LeftNotify(self, Text, Time, SoundId)
    local XSize, YSize = Library:GetTextBounds(Text, Library.Font, 14)

    YSize = YSize + 7

    local NotifyOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0),
        Size = UDim2.new(0, 0, 0, YSize),
        ClipsDescendants = true,
        ZIndex = 100,
        Parent = Library.LeftNotificationArea,
    })
    local NotifyInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.OutlineColor,
        BorderMode = Enum.BorderMode.Inset,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 101,
        Parent = NotifyOuter,
    })

    Library:AddToRegistry(NotifyInner, {
        BackgroundColor3 = 'MainColor',
        BorderColor3 = 'OutlineColor',
    }, true)

    local InnerFrame = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = 102,
        Parent = NotifyInner,
    })
    local Gradient = Library:Create('UIGradient', {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
            ColorSequenceKeypoint.new(1, Library.MainColor),
        },
        Rotation = -90,
        Parent = InnerFrame,
    })

    Library:AddToRegistry(Gradient, {
        Color = function()
            return ColorSequence.new{
                ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                ColorSequenceKeypoint.new(1, Library.MainColor),
            }
        end,
    })
    Library:CreateLabel{
        Position = UDim2.new(0, 4, 0, 0),
        Size = UDim2.new(1, -4, 1, 0),
        Text = Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 14,
        ZIndex = 103,
        Parent = InnerFrame,
    }

    local SideColor = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, -1, 0, -1),
        Size = UDim2.new(0, 3, 1, 2),
        ZIndex = 104,
        Parent = NotifyOuter,
    })

    Library:AddToRegistry(SideColor, {
        BackgroundColor3 = 'AccentColor',
    }, true)

    if SoundId then
        Library:Create('Sound', {
            SoundId = 'rbxassetid://' .. tostring(SoundId):gsub('rbxassetid://', ''),
            Volume = 3,
            PlayOnRemove = true,
            Parent = game:GetService'SoundService',
        }):Destroy()
    end

    pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, XSize + 8 + 4, 0, YSize), 'Out', 'Quad', 0.4, true)
    task.spawn(function()
        if typeof(Time) == 'Instance' then
            Time.Destroying:Wait()
        else
            task.wait(Time or 5)
        end

        pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, 0, 0, YSize), 'Out', 'Quad', 0.4, true)
        task.wait(0.4)
        NotifyOuter:Destroy()
    end)
end
function Library.RightNotify(self, Text, Time, SoundId)
    local XSize, YSize = Library:GetTextBounds(Text, Library.Font, 14)

    YSize = YSize + 7

    local NotifyOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0),
        Size = UDim2.new(0, 0, 0, YSize),
        ClipsDescendants = true,
        ZIndex = 100,
        Parent = Library.RightNotificationArea,
    })
    local NotifyInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.OutlineColor,
        BorderMode = Enum.BorderMode.Inset,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 101,
        Parent = NotifyOuter,
    })

    Library:AddToRegistry(NotifyInner, {
        BackgroundColor3 = 'MainColor',
        BorderColor3 = 'OutlineColor',
    }, true)

    local InnerFrame = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = 102,
        Parent = NotifyInner,
    })
    local Gradient = Library:Create('UIGradient', {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
            ColorSequenceKeypoint.new(1, Library.MainColor),
        },
        Rotation = -90,
        Parent = InnerFrame,
    })

    Library:AddToRegistry(Gradient, {
        Color = function()
            return ColorSequence.new{
                ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                ColorSequenceKeypoint.new(1, Library.MainColor),
            }
        end,
    })
    Library:CreateLabel{
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -4, 0, 0),
        Size = UDim2.new(1, -4, 1, 0),
        Text = Text,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextSize = 14,
        ZIndex = 103,
        Parent = InnerFrame,
    }

    local SideColor = Library:Create('Frame', {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Library.AccentColor,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -1, 0, -1),
        Size = UDim2.new(0, 3, 1, 2),
        ZIndex = 104,
        Parent = NotifyOuter,
    })

    Library:AddToRegistry(SideColor, {
        BackgroundColor3 = 'AccentColor',
    }, true)

    if SoundId then
        Library:Create('Sound', {
            SoundId = 'rbxassetid://' .. tostring(SoundId):gsub('rbxassetid://', ''),
            Volume = 3,
            PlayOnRemove = true,
            Parent = game:GetService'SoundService',
        }):Destroy()
    end

    pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, XSize + 8 + 4, 0, YSize), 'Out', 'Quad', 0.4, true)
    task.spawn(function()
        if typeof(Time) == 'Instance' then
            Time.Destroying:Wait()
        else
            task.wait(Time or 5)
        end

        pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, 0, 0, YSize), 'Out', 'Quad', 0.4, true)
        task.wait(0.4)
        NotifyOuter:Destroy()
    end)
end
function Library.CreateWindow(self, ...)
    local Arguments, Config = {...}, {
        AnchorPoint = Vector2.zero,
    }

    if typeof(...) == 'table' then
        Config = ...
    else
        Config.Title = Arguments[1]
    end
    if typeof(Config.Title) ~= 'string' then
        Config.Title = 'No title'
    end
    if typeof(Config.TabPadding) ~= 'number' then
        Config.TabPadding = 0
    end
    if typeof(Config.MenuFadeTime) ~= 'number' then
        Config.MenuFadeTime = 0.2
    end
    if typeof(Config.NotifySide) ~= 'string' then
        Library.NotifySide = 'Left'
    else
        Library.NotifySide = Config.NotifySide
    end
    if typeof(Config.ShowCustomCursor) ~= 'boolean' then
        Library.ShowCustomCursor = true
    else
        Library.ShowCustomCursor = Config.ShowCustomCursor
    end
    if typeof(Config.Position) ~= 'UDim2' then
        Config.Position = UDim2.fromOffset(175, 50)
    end
    if typeof(Config.Size) ~= 'UDim2' then
        Config.Size = UDim2.fromOffset(550, 600)

        if Library.IsMobile then
            local ViewportSizeYOffset = tonumber(workspace.CurrentCamera.ViewportSize.Y) - 35

            if ViewportSizeYOffset >= 200 and ViewportSizeYOffset <= 300 then
                Config.Size = UDim2.fromOffset(550, ViewportSizeYOffset)
            else
                Config.Size = UDim2.fromOffset(550, 300)
            end
        end
    end
    if Config.TabPadding <= 0 then
        Config.TabPadding = 1
    end
    Config.Position = UDim2.new(0.5, -Config.Size.X.Offset / 2, 0.5, -Config.Size.Y.Offset / 2 - 2)

    local Window, Outer = {
        Tabs = {},
        OriginalTitle = Config.Title,
        Title = Config.Title,
    }, Library:Create('Frame', {
        AnchorPoint = Config.AnchorPoint,
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        Position = Config.Position,
        Size = Config.Size,
        Visible = false,
        ZIndex = 1,
        Parent = ScreenGui,
    })

    LibraryMainOuterFrame = Outer

    Library:MakeDraggable(Outer, 25, true)

    Library:MakeResizable(Outer, Library.MinSize)

    local Inner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.AccentColor,
        BorderMode = Enum.BorderMode.Inset,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = 1,
        Parent = Outer,
    })

    Library:AddToRegistry(Inner, {
        BackgroundColor3 = 'MainColor',
        BorderColor3 = 'AccentColor',
    })

    local WindowLabel, MainSectionOuter = Library:CreateLabel{
        Position = UDim2.new(0, 7, 0, 0),
        Size = UDim2.new(0, 0, 0, 25),
        Text = Config.Title or '',
        RichText = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 1,
        Parent = Inner,
    }, Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor,
        BorderColor3 = Library.OutlineColor,
        Position = UDim2.new(0, 8, 0, 25),
        Size = UDim2.new(1, -16, 1, -33),
        ZIndex = 1,
        Parent = Inner,
    })

    Library:AddToRegistry(MainSectionOuter, {
        BackgroundColor3 = 'BackgroundColor',
        BorderColor3 = 'OutlineColor',
    })

    local MainSectionInner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor,
        BorderColor3 = Color3.new(0, 0, 0),
        BorderMode = Enum.BorderMode.Inset,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 1,
        Parent = MainSectionOuter,
    })

    Library:AddToRegistry(MainSectionInner, {
        BackgroundColor3 = 'BackgroundColor',
    })

    local TabArea = Library:Create('ScrollingFrame', {
        ScrollingDirection = Enum.ScrollingDirection.X,
        CanvasSize = UDim2.new(0, 0, 2, 0),
        HorizontalScrollBarInset = Enum.ScrollBarInset.Always,
        AutomaticCanvasSize = Enum.AutomaticSize.XY,
        ScrollBarThickness = 0,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8 - Config.TabPadding, 0, 4),
        Size = UDim2.new(1, -10, 0, 26),
        ZIndex = 1,
        Parent = MainSectionInner,
    })
    local TabListLayout = Library:Create('UIListLayout', {
        Padding = UDim.new(0, Config.TabPadding),
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Parent = TabArea,
    })

    Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor,
        BorderColor3 = Library.OutlineColor,
        Size = UDim2.new(0, 0, 0, 0),
        LayoutOrder = -1,
        BackgroundTransparency = 1,
        ZIndex = 1,
        Parent = TabArea,
    })
    Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor,
        BorderColor3 = Library.OutlineColor,
        Size = UDim2.new(0, 0, 0, 0),
        LayoutOrder = 9999999,
        BackgroundTransparency = 1,
        ZIndex = 1,
        Parent = TabArea,
    })

    local TabContainer = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.OutlineColor,
        Position = UDim2.new(0, 8, 0, 30),
        Size = UDim2.new(1, -16, 1, -38),
        ZIndex = 2,
        Parent = MainSectionInner,
    })
    local InnerVideoBackground = Library:Create('VideoFrame', {
        BackgroundColor3 = Library.MainColor,
        BorderMode = Enum.BorderMode.Inset,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = 2,
        Visible = false,
        Volume = 0,
        Looped = true,
        Parent = TabContainer,
    })

    Library.InnerVideoBackground = InnerVideoBackground

    Library:AddToRegistry(TabContainer, {
        BackgroundColor3 = 'MainColor',
        BorderColor3 = 'OutlineColor',
    })

    function Window.SetWindowTitle(self, Title)
        if typeof(Title) == 'string' then
            Window.Title = Title
            WindowLabel.Text = Window.Title
        end
    end
    function Window.AddTab(self, Name)
        local Tab = {
            Groupboxes = {},
            Tabboxes = {},
            OriginalName = Name,
            Name = Name,
        }
        local TabButtonWidth = Library:GetTextBounds(Tab.Name, Library.Font, 16)
        local TabButton = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor,
            BorderColor3 = Library.OutlineColor,
            Size = UDim2.new(0, TabButtonWidth + 8 + 4, 0.85, 0),
            ZIndex = 1,
            Parent = TabArea,
        })

        Library:AddToRegistry(TabButton, {
            BackgroundColor3 = 'BackgroundColor',
            BorderColor3 = 'OutlineColor',
        })

        local TabButtonLabel, Blocker = Library:CreateLabel{
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, -1),
            Text = Tab.Name,
            ZIndex = 1,
            Parent = TabButton,
        }, Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundTransparency = 1,
            ZIndex = 3,
            Parent = TabButton,
        })

        Library:AddToRegistry(Blocker, {
            BackgroundColor3 = 'MainColor',
        })

        local TabFrame, TopBar, TopBarInner, TopBarLabel, TopBarTextLabel = Library:Create('Frame', {
            Name = 'TabFrame',
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            ZIndex = 2,
            Parent = TabContainer,
        }), nil, nil, nil, nil

        do
            TopBar = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor,
                BorderColor3 = Color3.fromRGB(248, 51, 51),
                BorderMode = Enum.BorderMode.Inset,
                Position = UDim2.new(0, 7, 0, 7),
                Size = UDim2.new(1, -13, 0, 0),
                ZIndex = 2,
                Parent = TabFrame,
                Visible = false,
            })
            TopBarInner = Library:Create('Frame', {
                BackgroundColor3 = Color3.fromRGB(117, 22, 17),
                BorderColor3 = Color3.new(),
                Size = UDim2.new(1, -2, 1, -2),
                Position = UDim2.new(0, 1, 0, 1),
                ZIndex = 4,
                Parent = TopBar,
            })

            Library:Create('Frame', {
                BackgroundColor3 = Color3.fromRGB(255, 75, 75),
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 2),
                ZIndex = 5,
                Parent = TopBarInner,
            })

            TopBarLabel = Library:Create('TextLabel', {
                BackgroundTransparency = 1,
                Font = Library.Font,
                TextStrokeTransparency = 0,
                Size = UDim2.new(1, 0, 0, 18),
                Position = UDim2.new(0, 4, 0, 2),
                TextSize = 14,
                Text = 'Text',
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = Color3.fromRGB(255, 55, 55),
                ZIndex = 5,
                Parent = TopBarInner,
            })

            local TopBarLabelStroke = Library:ApplyTextStroke(TopBarLabel)

            TopBarLabelStroke.Color = Color3.fromRGB(174, 3, 3)
            TopBarTextLabel = Library:CreateLabel{
                Position = UDim2.new(0, 4, 0, 20),
                Size = UDim2.new(1, -4, 0, 14),
                TextSize = 14,
                Text = 'Text',
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                ZIndex = 5,
                Parent = TopBarInner,
            }

            Library:Create('Frame', {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 5),
                Visible = true,
                ZIndex = 1,
                Parent = TopBarInner,
            })
        end

        local LeftSide, RightSide = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 7, 0, 7),
            Size = UDim2.new(0.5, -10, 1, -14),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            BottomImage = '',
            TopImage = '',
            ScrollBarThickness = 0,
            ZIndex = 2,
            Parent = TabFrame,
        }), Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 5, 0, 7),
            Size = UDim2.new(0.5, -10, 1, -14),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            BottomImage = '',
            TopImage = '',
            ScrollBarThickness = 0,
            ZIndex = 2,
            Parent = TabFrame,
        })

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Parent = LeftSide,
        })
        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Parent = RightSide,
        })

        if Library.IsMobile then
            local SidesValues = {
                Left = tick(),
                Right = tick(),
            }

            LeftSide:GetPropertyChangedSignal'CanvasPosition':Connect(function()
                Library.CanDrag = false

                local ChangeTick = tick()

                SidesValues.Left = ChangeTick

                task.wait(0.15)

                if SidesValues.Left == ChangeTick then
                    Library.CanDrag = true
                end
            end)
            RightSide:GetPropertyChangedSignal'CanvasPosition':Connect(function()
                Library.CanDrag = false

                local ChangeTick = tick()

                SidesValues.Right = ChangeTick

                task.wait(0.15)

                if SidesValues.Right == ChangeTick then
                    Library.CanDrag = true
                end
            end)
        end

        for _, Side in next, {LeftSide, RightSide}do
            Side:WaitForChild'UIListLayout':GetPropertyChangedSignal'AbsoluteContentSize':Connect(function(
            )
                Side.CanvasSize = UDim2.fromOffset(0, Side.UIListLayout.AbsoluteContentSize.Y)
            end)
        end

        function Tab.Resize(self)
            if TopBar.Visible == true then
                local Size = 5

                for _, Element in next, TopBarInner:GetChildren()do
                    local __DARKLUA_CONTINUE_45 = false

                    repeat
                        if (not Element:IsA'UIListLayout') and Element.Visible then
                            if Element == TopBarTextLabel then
                                Size = Size + Element.TextBounds.Y
                                __DARKLUA_CONTINUE_45 = true

                                break
                            end

                            Size = Size + Element.Size.Y.Offset
                        end

                        __DARKLUA_CONTINUE_45 = true
                    until true

                    if not __DARKLUA_CONTINUE_45 then
                        break
                    end
                end

                TopBar.Size = UDim2.new(1, -13, 0, Size)
                Size = Size + 10
                LeftSide.Position = UDim2.new(0, 7, 0, 7 + Size)
                LeftSide.Size = UDim2.new(0.5, -10, 1, -14 - Size)
                RightSide.Position = UDim2.new(0.5, 5, 0, 7 + Size)
                RightSide.Size = UDim2.new(0.5, -10, 1, -14 - Size)
            else
                LeftSide.Position = UDim2.new(0, 7, 0, 7)
                LeftSide.Size = UDim2.new(0.5, -10, 1, -14)
                RightSide.Position = UDim2.new(0.5, 5, 0, 7)
                RightSide.Size = UDim2.new(0.5, -10, 1, -14)
            end
        end
        function Tab.UpdateWarningBox(self, Info)
            if typeof(Info.Visible) == 'boolean' then
                TopBar.Visible = Info.Visible

                Tab:Resize()
            end
            if typeof(Info.Title) == 'string' then
                TopBarLabel.Text = Info.Title
            end
            if typeof(Info.Text) == 'string' then
                TopBarTextLabel.Text = Info.Text

                local Y = select(2, Library:GetTextBounds(Info.Text, Library.Font, 14, Vector2.new(TopBarTextLabel.AbsoluteSize.X, math.huge)))

                TopBarTextLabel.Size = UDim2.new(1, -4, 0, Y)

                Tab:Resize()
            end
        end
        function Tab.ShowTab(self)
            Library.ActiveTab = Name

            for _, Tab in next, Window.Tabs do
                Tab:HideTab()
            end

            Blocker.BackgroundTransparency = 0
            TabButton.BackgroundColor3 = Library.MainColor
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'MainColor'
            TabFrame.Visible = true

            Tab:Resize()
        end
        function Tab.HideTab(self)
            Blocker.BackgroundTransparency = 1
            TabButton.BackgroundColor3 = Library.BackgroundColor
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'BackgroundColor'
            TabFrame.Visible = false
        end
        function Tab.SetLayoutOrder(self, Position)
            TabButton.LayoutOrder = Position

            TabListLayout:ApplyLayout()
        end
        function Tab.GetSides(self)
            return {
                Left = LeftSide,
                Right = RightSide,
            }
        end
        function Tab.SetName(self, Name)
            if typeof(Name) == 'string' then
                Tab.Name = Name

                local TabButtonWidth = Library:GetTextBounds(Tab.Name, Library.Font, 16)

                TabButton.Size = UDim2.new(0, TabButtonWidth + 8 + 4, 0.85, 0)
                TabButtonLabel.Text = Tab.Name
            end
        end
        function Tab.AddGroupbox(self, Info)
            local Groupbox, BoxOuter = {}, Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor,
                BorderColor3 = Library.OutlineColor,
                BorderMode = Enum.BorderMode.Inset,
                Size = UDim2.new(1, 0, 0, 509),
                ZIndex = 2,
                Parent = Info.Side == 1 and LeftSide or RightSide,
            })

            Library:AddToRegistry(BoxOuter, {
                BackgroundColor3 = 'BackgroundColor',
                BorderColor3 = 'OutlineColor',
            })

            local BoxInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor,
                BorderColor3 = Color3.new(0, 0, 0),
                Size = UDim2.new(1, -2, 1, -2),
                Position = UDim2.new(0, 1, 0, 1),
                ZIndex = 4,
                Parent = BoxOuter,
            })

            Library:AddToRegistry(BoxInner, {
                BackgroundColor3 = 'BackgroundColor',
            })

            local Highlight = Library:Create('Frame', {
                BackgroundColor3 = Library.AccentColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 2),
                ZIndex = 5,
                Parent = BoxInner,
            })

            Library:AddToRegistry(Highlight, {
                BackgroundColor3 = 'AccentColor',
            })
            Library:CreateLabel{
                Size = UDim2.new(1, 0, 0, 18),
                Position = UDim2.new(0, 4, 0, 2),
                TextSize = 14,
                Text = Info.Name,
                TextXAlignment = Enum.TextXAlignment.Center,
                ZIndex = 5,
                Parent = BoxInner,
            }

            local Container = Library:Create('Frame', {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 4, 0, 20),
                Size = UDim2.new(1, -4, 1, -20),
                ZIndex = 1,
                Parent = BoxInner,
            })

            Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = Container,
            })

            function Groupbox.Resize(self)
                local Size = 0

                for _, Element in next, Groupbox.Container:GetChildren()do
                    if (not Element:IsA'UIListLayout') and Element.Visible then
                        Size = Size + Element.Size.Y.Offset
                    end
                end

                BoxOuter.Size = UDim2.new(1, 0, 0, 20 + Size + 2 + 2)
            end

            Groupbox.Container = Container

            setmetatable(Groupbox, BaseGroupbox)
            Groupbox:AddBlank(3)
            Groupbox:Resize()

            Tab.Groupboxes[Info.Name] = Groupbox

            return Groupbox
        end
        function Tab.AddLeftGroupbox(self, Name)
            return Tab:AddGroupbox{
                Side = 1,
                Name = Name,
            }
        end
        function Tab.AddRightGroupbox(self, Name)
            return Tab:AddGroupbox{
                Side = 2,
                Name = Name,
            }
        end
        function Tab.AddTabbox(self, Info)
            local Tabbox, BoxOuter = {Tabs = {}}, Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor,
                BorderColor3 = Library.OutlineColor,
                BorderMode = Enum.BorderMode.Inset,
                Size = UDim2.new(1, 0, 0, 0),
                ZIndex = 2,
                Parent = Info.Side == 1 and LeftSide or RightSide,
            })

            Library:AddToRegistry(BoxOuter, {
                BackgroundColor3 = 'BackgroundColor',
                BorderColor3 = 'OutlineColor',
            })

            local BoxInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor,
                BorderColor3 = Color3.new(0, 0, 0),
                Size = UDim2.new(1, -2, 1, -2),
                Position = UDim2.new(0, 1, 0, 1),
                ZIndex = 4,
                Parent = BoxOuter,
            })

            Library:AddToRegistry(BoxInner, {
                BackgroundColor3 = 'BackgroundColor',
            })

            local Highlight = Library:Create('Frame', {
                BackgroundColor3 = Library.AccentColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 2),
                ZIndex = 10,
                Parent = BoxInner,
            })

            Library:AddToRegistry(Highlight, {
                BackgroundColor3 = 'AccentColor',
            })

            local TabboxButtons = Library:Create('Frame', {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 1),
                Size = UDim2.new(1, 0, 0, 18),
                ZIndex = 5,
                Parent = BoxInner,
            })

            Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = TabboxButtons,
            })

            function Tabbox.AddTab(self, Name)
                local Tab, Button = {}, Library:Create('Frame', {
                    BackgroundColor3 = Library.MainColor,
                    BorderColor3 = Color3.new(0, 0, 0),
                    Size = UDim2.new(0.5, 0, 1, 0),
                    ZIndex = 6,
                    Parent = TabboxButtons,
                })

                Library:AddToRegistry(Button, {
                    BackgroundColor3 = 'MainColor',
                })
                Library:CreateLabel{
                    Size = UDim2.new(1, 0, 1, 0),
                    TextSize = 14,
                    Text = Name,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ZIndex = 7,
                    Parent = Button,
                }

                local Block = Library:Create('Frame', {
                    BackgroundColor3 = Library.BackgroundColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, 0),
                    Size = UDim2.new(1, 0, 0, 1),
                    Visible = false,
                    ZIndex = 9,
                    Parent = Button,
                })

                Library:AddToRegistry(Block, {
                    BackgroundColor3 = 'BackgroundColor',
                })

                local Container = Library:Create('Frame', {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 4, 0, 20),
                    Size = UDim2.new(1, -4, 1, -20),
                    ZIndex = 1,
                    Visible = false,
                    Parent = BoxInner,
                })

                Library:Create('UIListLayout', {
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = Container,
                })

                function Tab.Show(self)
                    for _, Tab in next, Tabbox.Tabs do
                        Tab:Hide()
                    end

                    Container.Visible = true
                    Block.Visible = true
                    Button.BackgroundColor3 = Library.BackgroundColor
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor'

                    Tab:Resize()
                end
                function Tab.Hide(self)
                    Container.Visible = false
                    Block.Visible = false
                    Button.BackgroundColor3 = Library.MainColor
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor'
                end
                function Tab.Resize(self)
                    local TabCount = 0

                    for _, Tab in next, Tabbox.Tabs do
                        TabCount = TabCount + 1
                    end
                    for _, Button in next, TabboxButtons:GetChildren()do
                        if not Button:IsA'UIListLayout' then
                            Button.Size = UDim2.new(1 / TabCount, 0, 1, 0)
                        end
                    end

                    if (not Container.Visible) then
                        return
                    end

                    local Size = 0

                    for _, Element in next, Tab.Container:GetChildren()do
                        if (not Element:IsA'UIListLayout') and Element.Visible then
                            Size = Size + Element.Size.Y.Offset
                        end
                    end

                    BoxOuter.Size = UDim2.new(1, 0, 0, 20 + Size + 2 + 2)
                end

                Button.InputBegan:Connect(function(Input)
                    if (Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame()) or Input.UserInputType == Enum.UserInputType.Touch then
                        Tab:Show()
                        Tab:Resize()
                    end
                end)

                Tab.Container = Container
                Tabbox.Tabs[Name] = Tab

                setmetatable(Tab, BaseGroupbox)
                Tab:AddBlank(3)
                Tab:Resize()

                if #TabboxButtons:GetChildren() == 2 then
                    Tab:Show()
                end

                return Tab
            end

            Tab.Tabboxes[Info.Name or ''] = Tabbox

            return Tabbox
        end
        function Tab.AddLeftTabbox(self, Name)
            return Tab:AddTabbox{
                Name = Name,
                Side = 1,
            }
        end
        function Tab.AddRightTabbox(self, Name)
            return Tab:AddTabbox{
                Name = Name,
                Side = 2,
            }
        end

        TabButton.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Tab:ShowTab()
            end
        end)
        TopBar:GetPropertyChangedSignal'Visible':Connect(function()
            Tab:Resize()
        end)

        Library.TotalTabs = Library.TotalTabs + 1

        if Library.TotalTabs == 1 then
            Tab:ShowTab()
        end

        Window.Tabs[Name] = Tab

        return Tab
    end

    local ModalElement = Library:Create('TextButton', {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 0),
        Visible = true,
        Text = '',
        Modal = false,
        Parent = ScreenGui,
    })

    function Library.Toggle()
        Outer.Visible = not Outer.Visible
        ModalElement.Modal = Outer.Visible

        local _, _, Cursor = Mouse.Icon, InputService.MouseIconEnabled, Drawing.new'Triangle'

        Cursor.Thickness = 1
        Cursor.Filled = true

        while Outer.Visible and ScreenGui.Parent do
            local mPos = InputService:GetMouseLocation()

            Cursor.Color = Library.AccentColor
            Cursor.PointA = Vector2.new(mPos.X, mPos.Y)
            Cursor.PointB = Vector2.new(mPos.X, mPos.Y) + Vector2.new(6, 14)
            Cursor.PointC = Vector2.new(mPos.X, mPos.Y) + Vector2.new(-6, 14)
            Cursor.Visible = not InputService.MouseIconEnabled

            RenderStepped:Wait()
        end

        Cursor:Remove()
    end

    Library:GiveSignal(InputService.InputBegan:Connect(function(
        Input,
        Processed
    )
        if type(Library.ToggleKeybind) == 'table' and Library.ToggleKeybind.Type == 'KeyPicker' then
            if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Library.ToggleKeybind.Value then
                task.spawn(Library.Toggle)
            end
        elseif Input.KeyCode == Enum.KeyCode.RightControl or (Input.KeyCode == Enum.KeyCode.RightShift and (not Processed)) then
            task.spawn(Library.Toggle)
        end
    end))

    task.spawn(Library.Toggle)

    Window.Holder = Outer
    Library.Window = Window

    return Window
end
return Library
