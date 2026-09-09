local _ENV = (getgenv or getrenv or getfenv)()

local Utils = {}
local Settings = {}
local Threads = {}
local Fallback = {}

local Owner = "imdogkung3"
local Repository = "Xynapse"

local THREAD_HASH = tostring(os.clock() + math.random()) do
    _ENV.__THREAD_HASH = THREAD_HASH
    _ENV.GLOBALS_SETTINGS = {}
end

local function fetch(file)
    local URL = string.format(
        "https://raw.githubusercontent.com/%s/%s/main/%s",
        Owner, Repository, file
    )

    warn("Fetch : ", file)

    return loadstring(game:HttpGet(URL))()
end

local function AddModule(Name, Module)
    do Utils[Name] = Module()
        return Utils[Name]
    end
end

local UserInputService = game:GetService('UserInputService')
local TeleportService = game:GetService('TeleportService')
local HttpService = game:GetService('HttpService')
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local JobId = game.JobId

AddModule("Connections", function()
    local Connections = {}
    local Cached = _ENV.Connections or {}

    do
        _ENV.Connections = Cached

        for i = 1, #Cached do
            Cached[i]:Disconnect()
        end

        table.clear(Cached)
    end

    function Connections.Connect(Instance, Callback)
        local Connection = Instance:Connect(Callback)

        table.insert(Cached, Connection)

        return Connection
    end 

    return Connections
end)

AddModule("Configurations", function()
    local Configurations = {}
    local Files = "Xynapse"

    local makefolder = makefolder or function( ... ) return ... end
    local writefile = writefile or function( ... ) return ... end
    local isfolder = isfolder or function( ... ) return ... end
    local readfile = readfile or function( ... ) return ... end
    local isfile = isfile or function( ... ) return ... end

    Configurations.Files = Files or "Xynapse"
    Configurations.Set = `{Files}/Settings`
    Configurations.FullPaths = `{Configurations.Set}/{game.PlaceId}.json`
    Configurations.Paths = { Files, Configurations.Set }

    do
        function Configurations:Folder()
            for i = 1, #self.Paths do
                local str = self.Paths[i]

                if not isfolder(str) then
                    makefolder(str)
                end
            end
        end

        function Configurations:Default(index, value)
            if Settings[index] == nil then
                Settings[index] = value
            end
        end

        function Configurations:Save(index, value)
            if index ~= nil then
                Settings[index] = value
            end

            if not isfolder(Files) then
                makefolder(Files)
            end

            if not isfolder(Configurations.Set) then
                makefolder(Configurations.Set)
            end

            writefile(Configurations.FullPaths, HttpService:JSONEncode(Settings))
        end

        function Configurations:Load()
            if not isfile(Configurations.FullPaths) then
                self:Save()
            end

            local Reader = readfile(Configurations.FullPaths) do
                return HttpService:JSONDecode(Reader) 
            end
        end 
    end

    do Configurations:Folder()
        Configurations:Default("Success", true)
    end

    return Configurations
end)

AddModule("Others", function()
    local Others = {}

    Others.Server = (function()
        local Server = {}

        function Server:Reversed(cursor)
            local url = `https://games.roblox.com/v1/games/{PlaceId}/servers/Public?sortOrder=Asc&limit=100`

            if cursor then
                url ..= `&cursor={cursor}`
            end

            return HttpService:JSONDecode(game:HttpGet(url))
        end

        function Server:Rejoin()
            if #Players:GetPlayers() <= 1 then
                LocalPlayer:Kick("\nRejoining");wait()

                return TeleportService:Teleport(PlaceId, LocalPlayer)
            end

            return TeleportService:TeleportToPlaceInstance(PlaceId, JobId, LocalPlayer)
        end

        function Server:Change()
            local Server, Next

            repeat
                local Servers = Server:Reversed(Next)

                Server = Servers and Servers.data and Servers.data[1]
                Next = Servers and Servers.nextPageCursor
            until Server

            if not Server or not Server.id then return end
            return TeleportService:TeleportToPlaceInstance(PlaceId, Server.id, LocalPlayer)
        end

        function Server:Join(id)
            return TeleportService:TeleportToPlaceInstance(PlaceId, id, LocalPlayer)
        end

        return Server
    end)()

    Others.Optimize = (function()
        local Optimize = {}

        function Optimize:Set3d(value)
            RunService:Set3dRenderingEnabled(if value then false else true)
        end

        function Optimize:Low()
            local Terrain = workspace:FindFirstChildOfClass('Terrain') do
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 0
                game.Lighting.GlobalShadows = false
                game.Lighting.FogEnd = 9e9
                settings().Rendering.QualityLevel = 1
            end
        end

        return Optimize
    end)()

    return Others
end)

AddModule("Parallels", function()
    local Parallels = {}

    local Options = {}
    local clonedEnabled = {}
    local Functions = _ENV.FUNCTIONS or {}
    local FarmFunctions = _ENV.FARM_FUNCTIONS or {}

    local Enabled_Toggle_Debounce = false
    local Enabled_New_Values = {}

    do
        local function ShowErrorMessage(ErrorMessage)
            _ENV.OnFarm = false

            local text = (`error [ { _ENV.RunningOption or "Null" } ] { ErrorMessage }`)

            if _ENV.error_message then
                _ENV.error_message.Text ..= `\n\n{ text }`

                return nil
            end

            local Message = Instance.new("Message", workspace) do
                _ENV.error_message = Message
                Message.Text = text
            end
        end

        local function RunQueue(Options)
            local Success, ErrorMessage = pcall(function()
                local function GetQueue()
                    for _, Option in Options do

                        _ENV.RunningOption = Option.Name

                        local Method = Option.Function()

                        if Method then
                            if type(Method) == "string" then
                                _ENV.RunningMethod = Method
                            end

                            return Method
                        end
                    end

                    _ENV.RunningOption, _ENV.RunningMethod = nil, nil
                end

                while task.wait(0) do
                    if _ENV.__THREAD_HASH ~= THREAD_HASH then
                        _ENV.RunningOption, _ENV.RunningMethod = nil, nil
                        _ENV.OnFarm = false
                        warn('Break Old Queue')
                        break
                    end
                    
                    _ENV.OnFarm = if GetQueue() then true else false
                end
            end)

            if not Success then
                ShowErrorMessage(ErrorMessage)

                task.delay(3, function()
                    if _ENV.error_message then
                        _ENV.error_message.Text = "Xynapse Shield\nStart Refresh Options ..."

                        task.wait(2)

                        if _ENV.RunningOption and Fallback[_ENV.RunningOption] then
                            Fallback[_ENV.RunningOption]:SetValue(false)
                            _ENV.error_message.Text = "Xynapse Shield\nHas been Disabled " .. _ENV.RunningOption
                        end

                        task.wait(2)

                        _ENV.error_message:Destroy()
                        _ENV.error_message = nil

                        task.spawn(RunQueue, FarmFunctions)
                    end
                end)
            end
        end

        local function UpdateEnabledOptions()
            table.clear(FarmFunctions)

            for index, value in pairs(Enabled_New_Values) do
                clonedEnabled[index] = value or nil
                Enabled_New_Values[index] = nil
            end

            for i = 1, #Functions do
                local funcData = Functions[i]
                if clonedEnabled[funcData.Name] then
                    table.insert(FarmFunctions, funcData)
                end
            end
        end

        local Enabled = _ENV.ENABLED_OPTIONS or setmetatable({}, {
            __newindex = function(self, index, value)
                Enabled_New_Values[index] = value or false

                if not Enabled_Toggle_Debounce then
                    Enabled_Toggle_Debounce = false
                    task.spawn(UpdateEnabledOptions)
                end
            end,
            __index = clonedEnabled
        })

        do
            _ENV.FUNCTIONS = Functions
            _ENV.ENABLED_OPTIONS = Enabled
            _ENV.FARM_FUNCTIONS = FarmFunctions

            task.spawn(RunQueue, FarmFunctions)
        end

        do table.clear(Functions) end

        local index = {}

        local function While(a, b, c, d)
            while a do
                local t = tick()

                if c then c() end
                if d and d() then break end

                repeat
                    RunService.Heartbeat:Wait()
                until tick() - t >= (b or 0.1)
            end
        end

        local function NewOption(Tag, Function, Time)
            if Time then
                Threads[Tag] = function(Value)
                    While(Value, Time or 0.1, Function, function()
                        return not Value or _ENV.__THREAD_HASH ~= THREAD_HASH
                    end)
                end
            else
                local Data = { 
                    ["Name"] = Tag,
                    ["Function"] = Function
                }

                index[Tag] = Function
                table.insert(Functions, Data)
            end
        end

        Parallels.NewOption = NewOption
        Parallels.Options = function()
            return Enabled, Options
        end
    end

    return Parallels
end)

AddModule("Plugins", function()
    local Plugins = {}
    
    local Configurations = Utils.Configurations
    local Parallels = Utils.Parallels
    local Others = Utils.Others
    
    local Enabled, Options = Parallels.Options()
    
    local Fetching = loadstring(game:HttpGet(
        "https://pastebin.com/raw/SpjJfaMj",
        true
    ))()
    
    function Plugins:Window(Info)
        self.Base = Fetching:Window({
            Logo = Info[1],
            Size = UDim2.new(0, 500, 0, 375),
            MainColor = Color3.fromRGB(0, 170, 255),
            DropColor = Color3.fromRGB(105, 94, 255),
            Keybind = Enum.KeyCode.B
        })
        
        return self.Base
    end
    
    function Plugins:NewPage(Icon)
        return self.Base:CreateTab({
            Title = Icon[1],
            Icon = Icon[2]
        })
    end
    
    function Plugins:Section(Page, Info, Side)
        return Page:CreateSection({
            Title = Info[1],
            Side = Side
        })
    end
    
    function Plugins:Button(Section, Info, Callback)
        return Section:CreateButton({
            Title = Info[1],
            Callback = Callback
        })
    end
    
    function Plugins:Toggle(Section, Info, Flag, Callback)
        local Thread = nil

        Fallback[Flag] = Section:CreateToggle({
            Title = Info[1],
            Value = Settings[Flag] or false,

            CallBack = function(Value)
                _ENV.GLOBALS_SETTINGS[Flag] = Value

                Settings[Flag] = Value
                Configurations:Save(Flag, Value)
                Enabled[Flag] = Value

                if Value then
                    if Threads[Flag] then
                        Thread = task.spawn(function()
                            Threads[Flag](Settings[Flag])
                        end)
                    end
                else
                    if Thread then
                        task.cancel(Thread)
                        Thread = nil
                    end
                end

                if Callback then Callback(Value) end
            end
        })

        return Fallback[Flag]
    end

    function Plugins:Slider(Section, Info, Value, Flag, Callback)
        return Section:CreateSlider({
            Title = Info[1],
            Min = Value[1],
            Max = Value[2],
            Rounding = Value[3],
            Value = Settings[Flag] or Value[1],

            CallBack = function(Value)
                Settings[Flag] = Value
                Configurations:Save(Flag, Value)
                _ENV.GLOBALS_SETTINGS[Flag] = Value

                if Callback then Callback(Value) end
            end
        })
    end
    
    function Plugins:Dropdown(Section, Info, List, Flag, Callback, Multi)
        return Section:CreateDropdown({
            Title = Info,
            List = List,
            Multi = Multi or false,
            Value = Settings[Flag] or if Multi then {} else "None",

            Callback = function(Value)
                Settings[Flag] = Value
                Configurations:Save(Flag, Value)
                _ENV.GLOBALS_SETTINGS[Flag] = Value

                if Callback then Callback(Value) end
            end
        })
    end
    
    function Plugins:Input(Section, Info, Flag, Callback)
        return Section:CreateTextbox({
            Title = Info[1],
            Text = Settings[Flag] or "None",

            Callback = function(Value)
                Settings[Flag] = Value
                Configurations:Save(Flag, Value)
                _ENV.GLOBALS_SETTINGS[Flag] = Value

                if Callback then Callback(Value) end
            end
        })
    end
    
    function Plugins:TextLabel(Section, Info)
        return Section:CreateTextLabel({
            Title = Info[1],
            Icon = Info[3],
            Text = Info[4]
        })
    end

    function Plugins:Keybind(Section, Info, Flag, Callback)
        return Section:CreateKeybind({
            Title = Info[1],
            Key = Settings[Flag] or Enum.KeyCode.B,

            Callback = function(Value)
                Settings[Flag] = Value
                Configurations:Save(Flag, Value)
                _ENV.GLOBALS_SETTINGS[Flag] = Value

                if Callback then Callback(Value) end
            end
        })
    end

    function Plugins:Select(Section, Info, List, Flag, Callback)
        return Section:CreateSelect({
            Title = Info[1],
            List = List,
            Value = Settings[Flag] or List[1],

            Callback = function(Value)
                Settings[Flag] = Value
                Configurations:Save(Flag, Value)
                _ENV.GLOBALS_SETTINGS[Flag] = Value

                if Callback then Callback(Value) end
            end
        })
    end

    function Plugins:ButtonImage(Section, Info, Callback)
        return Section:ButtonImage({
            Title = Info[1],
            Icon = Info[2],
            Callback = Callback
        })
    end

    function Plugins:ToggleImage(Section, Info, Flag, Callback)
        Fallback[Flag] = Section:ImageToggle({
            Title = Info[1],
            Icon = Info[2],
            Value = Settings[Flag] or false,

            CallBack = function(Value)
                _ENV.GLOBALS_SETTINGS[Flag] = Value

                Settings[Flag] = Value
                Configurations:Save(Flag, Value)
                Enabled[Flag] = Value

                if Callback then Callback(Value) end
            end
        })

        return Fallback[Flag]
    end

    function Plugins:Image(Section, Info)
        return Section:CreateImage({
            Title = Info[1],
            Icon = Info[2]
        })
    end

    function Plugins:Line(Section)
        return Section:Line()
    end
    
    function Plugins:Managers()
        local Managers = Plugins:NewPage({ "Managers", 134261589888025 }) do
            local _1 = Plugins:Section(Managers, { "Server", Color3.fromRGB(85, 255, 127) }) do
                Configurations:Default("JobId", JobId)

                Plugins:Input(_1, { "JobId" }, "JobId")

                Plugins:Button(_1, { "Join" }, function()
                    Others.Server:Join(Settings["JobId"])
                end)

                Plugins:Button(_1, { "Change" }, function()
                    Others.Server:Change()
                end)

                Plugins:Button(_1, { "Rejoin" }, function()
                    Others.Server:Rejoin()
                end)
            end
            
            local _2 = Plugins:Section(Managers, { "Optimization", Color3.fromRGB(85, 255, 127) }) do
                Plugins:Toggle(_2, { "White Screen" }, "White Screen", function(Value)
                    Others.Optimize:Set3d(Value)
                end)

                Plugins:Button(_2, { "Fast Mode" }, function()
                    Others.Optimize:Low()
                end)
            end
            
            local _3 = Plugins:Section(Managers, { "Configurations", Color3.fromRGB(85, 255, 127) }) do
                Plugins:Button(_3, { "Remove Workspace" }, function()
                    local Files = Configurations.FullPaths

                    if Files and isfile(Files) then
                        pcall(delfile, Files)
                        warn("Remove Success")
                    else
                        warn("File not found")
                    end
                end)
            end
        end
        
        return Managers
    end
    
    return Plugins
end)

do
    Settings = Utils.Configurations:Load()
    Utils.Settings = Settings
end

return Utils
