
--[[
    Shnicker Ware
    MainScript.lua
    GitHub Module Loader
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local plr = Players.LocalPlayer

-- Configuration
local BASE_URL =
    "https://raw.githubusercontent.com/WhichChapter/shnicker-Ware/refs/heads/main/coolshit/garbage/"

-- Rayfield
local Rayfield = loadstring(
    game:HttpGet("https://sirius.menu/rayfield")
)()

local Window = Rayfield:CreateWindow({
    Name = "Shnicker Ware",
    LoadingTitle = "Shnicker Ware",
    LoadingSubtitle = "Modular Edition",
    ConfigurationSaving = {
        Enabled = false
    },
    KeySystem = false
})

-- Tabs
local PlayerTab = Window:CreateTab("Player", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483362458)
local UtilityTab = Window:CreateTab("Utilities", 4483362458)
local BlatantTab = Window:CreateTab("Blatant", 4483362458)

-- Shared dependencies
local Shared = {
    Players = Players,
    RunService = RunService,
    UserInputService = UIS,
    LocalPlayer = plr,
    Rayfield = Rayfield,
    Window = Window,
    PlayerTab = PlayerTab,
    VisualTab = VisualTab,
    UtilityTab = UtilityTab,
    BlatantTab = BlatantTab
}

-- Module registry
local Modules = {
    {
        Name = "Infinite Jump",
        File = "InfiniteJump",
        Tab = PlayerTab
    },
    {
        Name = "Kill Aura",
        File = "KillAura",
        Tab = BlatantTab
    },
    {
        Name = "Fly",
        File = "Fly",
        Tab = PlayerTab
    },
    {
        Name = "Reach",
        File = "Reach",
        Tab = BlatantTab
    },
    {
        Name = "Speed",
        File = "Speed",
        Tab = PlayerTab
    },
    {
        Name = "China Hat",
        File = "ChinaHat",
        Tab = PlayerTab
    },
    {
        Name = "Teleport",
        File = "Teleport",
        Tab = PlayerTab
    },
    {
        Name = "Player ESP",
        File = "ESP",
        Tab = VisualTab
    },
    {
        Name = "X-Ray",
        File = "XRay",
        Tab = VisualTab
    },
    {
        Name = "Bed ESP",
        File = "BedESP",
        Tab = VisualTab
    },
    {
        Name = "FPS Counter",
        File = "FPS",
        Tab = UtilityTab
    },
    {
        Name = "Ping Display",
        File = "Ping",
        Tab = UtilityTab
    },
    {
        Name = "Keystrokes",
        File = "Keystrokes",
        Tab = UtilityTab
    },
    {
        Name = "Custom Crosshair",
        File = "Crosshair",
        Tab = UtilityTab
    },
    {
        Name = "Combat Status HUD",
        File = "CombatHUD",
        Tab = UtilityTab
    },
    {
        Name = "Target Info (Mouseover)",
        File = "TargetInfo",
        Tab = UtilityTab
    },
    {
        Name = "AutoJump",
        File = "AutoJump",
        Tab = PlayerTab
    },
    {
        Name = "AutoLeave (Low Health)",
        File = "AutoLeave",
        Tab = PlayerTab
    },
    {
        Name = "Report Player",
        File = "AutoReport",
        Tab = UtilityTab
    }
}

-- Loading protection
local LoadedModules = {}

local function LoadModule(module)
    if LoadedModules[module.File] then
        return true
    end

    local url = BASE_URL .. module.File .. ".lua"

    local success, result = pcall(function()
        local source = game:HttpGet(url)

        assert(
            type(source) == "string" and #source > 0,
            "Empty module source"
        )

        local compiled, compileError = loadstring(source)

        assert(compiled, compileError)

        local initialize = compiled()

        assert(
            type(initialize) == "function",
            "Module must return an initialization function"
        )

        initialize(Shared)

        LoadedModules[module.File] = true
    end)

    if success then
        Rayfield:Notify({
            Title = "Shnicker Ware",
            Content = module.Name .. " loaded successfully",
            Duration = 3
        })

        return true
    else
        warn("[Shnicker Ware] " .. module.File .. ": " .. tostring(result))

        Rayfield:Notify({
            Title = "Module Error",
            Content = module.Name .. " failed to load",
            Duration = 5
        })

        return false
    end
end

-- Load all modules
PlayerTab:CreateButton({
    Name = "Load All Player Modules",
    Callback = function()
        for _, module in ipairs(Modules) do
            if module.Tab == PlayerTab then
                LoadModule(module)
            end
        end
    end
})

VisualTab:CreateButton({
    Name = "Load All Visual Modules",
    Callback = function()
        for _, module in ipairs(Modules) do
            if module.Tab == VisualTab then
                LoadModule(module)
            end
        end
    end
})

BlatantTab:CreateButton({
    Name = "Load All Blatant Modules",
    Callback = function()
        for _, module in ipairs(Modules) do
            if module.Tab == BlatantTab then
                LoadModule(module)
            end
        end
    end
})

-- Individual loading buttons
for _, module in ipairs(Modules) do
    module.Tab:CreateButton({
        Name = "Load " .. module.Name,
        Callback = function()
            LoadModule(module)
        end
    })
end

-- Status
Rayfield:Notify({
    Title = "Shnicker Ware",
    Content = "Main interface loaded!",
    Duration = 5
})

print("[Shnicker Ware] MainScript initialized")
