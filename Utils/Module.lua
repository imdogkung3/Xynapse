AddModule("Plugins", function()
    local Plugins = {}
    
    local Configurations = Utils.Configurations
    local Parallels = Utils.Parallels
    local Others = Utils.Others
    
    local Enabled, Options = Parallels.Options()
    
    local Fetching = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/MerrySubs4t/Softwork/refs/heads/main/Fetching/Framework/Mains",
        true
    ))()
    
    function Plugins:Window(Info)
        self.Base = Fetching:Window({
            Logo = Info[3],
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
            Desc = Info[2],
            Callback = Callback
        })
    end
    
    function Plugins:Toggle(Section, Info, Flag, Callback)
        local Thread = nil

        Fallback[Flag] = Section:CreateToggle({
            Title = Info[1],
            Desc = Info[2],
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
            Desc = Info[2],
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
            Desc = Info[2],
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
            Desc = Info[2],
            Icon = Info[3],
            Text = Info[4]
        })
    end

    function Plugins:Keybind(Section, Info, Flag, Callback)
        return Section:CreateKeybind({
            Title = Info[1],
            Desc = Info[2],
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
            Desc = Info[2],
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
            Desc = Info[2],
            Icon = Info[3],
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
            Desc = Info[2],
            Icon = Info[3]
        })
    end

    function Plugins:Line(Section)
        return Section:Line()
    end
    
    function Plugins:Managers()
        local Managers = Plugins:NewPage({ "Managers", 134261589888025 }) do
            local _1 = Plugins:Section(Managers, { "Server", Color3.fromRGB(85, 255, 127) }) do
                Configurations:Default("JobId", JobId)

                Plugins:Input(_1, { "JobId", "Put the job id." }, "JobId")

                Plugins:Button(_1, { "Join", "Connect to the server using the provided JobId." }, function()
                    Others.Server:Join(Settings["JobId"])
                end)

                Plugins:Button(_1, { "Change", "Teleport to a different public server instance." }, function()
                    Others.Server:Change()
                end)

                Plugins:Button(_1, { "Rejoin", "Reconnect to the current server instance." }, function()
                    Others.Server:Rejoin()
                end)
            end
            
            local _2 = Plugins:Section(Managers, { "Optimization", Color3.fromRGB(85, 255, 127) }) do
                Plugins:Toggle(_2, { "White Screen", "Disabled 3D Rendering to improve performance" }, "White Screen", function(Value)
                    Others.Optimize:Set3d(Value)
                end)

                Plugins:Button(_2, { "Fast Mode", "Set graphics quality to low" }, function()
                    Others.Optimize:Low()
                end)
            end
            
            local _3 = Plugins:Section(Managers, { "Configurations", Color3.fromRGB(85, 255, 127) }) do
                Plugins:Button(_3, { "Remove Workspace", "Reset save setting file to default value." }, function()
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
