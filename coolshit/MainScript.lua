--[[
    Shnicker Ware - Vape-style GUI Modular Edition
]]

local DISCORD_LINK = "https://discord.gg/YOURINVITE"
local WEBSITE_LINK = "https://example.com"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local plr = Players.LocalPlayer

-- Configuration
local BASE_URL = "https://raw.githubusercontent.com/WhichChapter/shnicker-Ware/refs/heads/main/coolshit/garbage/"

------------------------------------------------------------ assets
local BASE = "Render/assets/"
local RAW = "https://raw.githubusercontent.com/WhichChapter/shnicker-Ware/main/assets/"
pcall(function()
	if makefolder then
		if not isfolder("Render") then makefolder("Render") end
		if not isfolder("Render/assets") then makefolder("Render/assets") end
	end
end)

local cache = {}
local function asset(name)
	if cache[name] ~= nil then return cache[name] end
	local result = ""
	pcall(function()
		if not (getcustomasset and isfile and writefile) then return end
		if not isfile(BASE .. name) then
			local data = game:HttpGet(RAW .. name)
			if data and #data > 0 then writefile(BASE .. name, data) end
		end
		if isfile(BASE .. name) then result = getcustomasset(BASE .. name) end
	end)
	cache[name] = result
	return result
end

------------------------------------------------------------ helpers
local C = {
	bg = Color3.fromRGB(26, 25, 26),
	head = Color3.fromRGB(34, 33, 34),
	off = Color3.fromRGB(30, 29, 30),
	hover = Color3.fromRGB(40, 39, 40),
	settings = Color3.fromRGB(22, 21, 22),
	text = Color3.fromRGB(225, 225, 225),
	dim = Color3.fromRGB(150, 150, 150),
	accent = Color3.fromRGB(5, 134, 105),
}

local function make(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	o.Parent = parent
	return o
end
local function tw(o, t, props)
	TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad), props):Play()
end
local function corner(o, r) make("UICorner", {CornerRadius = UDim.new(0, r or 4)}, o) end
local function listLayout(o, pad)
	return make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, pad or 0)}, o)
end
local function isPress(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end
local function label(parent, text, size, pos, color, align)
	return make("TextLabel", {
		BackgroundTransparency = 1, Text = text, Font = Enum.Font.Gotham, TextSize = 14,
		TextColor3 = color or C.text, TextXAlignment = align or Enum.TextXAlignment.Left,
		Size = size, Position = pos or UDim2.new(),
	}, parent)
end
local function arrowButton(parent, pos)
	local img = asset("ToggleArrow.png")
	if img ~= "" then
		return make("ImageButton", {BackgroundTransparency = 1, Image = img, Size = UDim2.fromOffset(14, 14),
			Position = pos, ImageColor3 = C.dim, AnchorPoint = Vector2.new(0.5, 0.5)}, parent)
	end
	return make("TextButton", {BackgroundTransparency = 1, Text = "v", Font = Enum.Font.GothamBold, TextSize = 14,
		TextColor3 = C.dim, Size = UDim2.fromOffset(14, 14), Position = pos, AnchorPoint = Vector2.new(0.5, 0.5)}, parent)
end

------------------------------------------------------------ library + gui
local Library = {Windows = {}, Lists = {}, Modules = {}, ToggleKey = Enum.KeyCode.RightShift, Visible = true}
local conns = {}
local function connect(sig, fn) local c = sig:Connect(fn); table.insert(conns, c); return c end

local Gui = Instance.new("ScreenGui")
Gui.Name = "RenderGUI"; Gui.ResetOnSpawn = false; Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() if syn and syn.protect_gui then syn.protect_gui(Gui) end end)
if not pcall(function() Gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end) then
	Gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

local Root = make("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1)}, Gui)
local NotifHolder = make("Frame", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -16, 1, -16), Size = UDim2.fromOffset(270, 400)}, Gui)
make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6),
	HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Bottom}, NotifHolder)

local Blur = make("BlurEffect", {Size = 0}, Lighting)
tw(Blur, 0.3, {Size = 12})

-- dragging
local drag
connect(UIS.InputChanged, function(i)
	if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
		local d = i.Position - drag.start
		drag.frame.Position = UDim2.fromOffset(drag.origin.X + d.X, drag.origin.Y + d.Y)
	end
end)
connect(UIS.InputEnded, function(i) if isPress(i) then drag = nil end end)

------------------------------------------------------------ notifications
function Library:Notify(title, text, duration, warn)
	duration = duration or 4
	local n = make("Frame", {BackgroundColor3 = C.bg, Size = UDim2.fromOffset(260, 58), ClipsDescendants = true}, NotifHolder)
	corner(n, 5)
	make("ImageLabel", {BackgroundTransparency = 1, Image = asset("NotificationBackground.png"),
		ScaleType = Enum.ScaleType.Stretch, Size = UDim2.fromScale(1, 1)}, n)
	make("ImageLabel", {BackgroundTransparency = 1, Image = asset(warn and "WarningNotification.png" or "InfoNotification.png"),
		Size = UDim2.fromOffset(34, 34), Position = UDim2.fromOffset(10, 10)}, n)
	label(n, title, UDim2.new(1, -60, 0, 18), UDim2.fromOffset(52, 8)).Font = Enum.Font.GothamBold
	label(n, text, UDim2.new(1, -60, 0, 18), UDim2.fromOffset(52, 28), C.dim).TextSize = 12
	local bar = make("Frame", {BackgroundColor3 = warn and Color3.fromRGB(200, 70, 60) or C.accent,
		BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 3), Position = UDim2.new(0, 0, 1, -3)}, n)
	tw(bar, duration, {Size = UDim2.new(0, 0, 0, 3)})
	task.delay(duration, function() if n.Parent then n:Destroy() end end)
end

local function copy(text, what)
	local ok = pcall(function() setclipboard(text) end)
	Library:Notify(ok and "Copied" or "Couldn't copy", ok and (what .. " copied to clipboard") or "No setclipboard in your executor", 3, not ok)
end

------------------------------------------------------------ category windows
function Library:CreateCategory(name, icon, pos)
	local idx = #self.Windows
	local cat = {Name = name, Modules = {}}
	local frame = make("Frame", {Name = name, BackgroundColor3 = C.bg, ClipsDescendants = true,
		AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.fromOffset(220, 0),
		Position = pos or UDim2.fromOffset(30 + (idx % 6) * 235, 90 + math.floor(idx / 6) * 70)}, Root)
	corner(frame, 5); listLayout(frame)
	cat.Frame = frame

	local head = make("Frame", {BackgroundColor3 = C.head, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = 0}, frame)
	make("ImageLabel", {BackgroundTransparency = 1, Image = icon or "", Size = UDim2.fromOffset(20, 20),
		Position = UDim2.fromOffset(10, 10)}, head)
	label(head, name, UDim2.new(1, -100, 1, 0), UDim2.fromOffset(38, 0)).Font = Enum.Font.GothamBold
	local arrow = arrowButton(head, UDim2.new(1, -20, 0.5, 0))
	local pin = make("ImageButton", {BackgroundTransparency = 1, Image = asset("PinButton.png"), ImageColor3 = C.dim,
		Size = UDim2.fromOffset(14, 14), Position = UDim2.new(1, -54, 0.5, -7)}, head)
	pin.MouseButton1Click:Connect(function()
		cat.Pinned = not cat.Pinned
		tw(pin, 0.15, {ImageColor3 = cat.Pinned and C.accent or C.dim})
	end)

	local body = make("Frame", {BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 1}, frame)
	listLayout(body)
	cat.Body = body

	head.InputBegan:Connect(function(i)
		if isPress(i) and not cat.Pinned then
			drag = {frame = frame, start = i.Position, origin = frame.AbsolutePosition}
			frame.ZIndex = 2
			for _, w in ipairs(Library.Windows) do if w.Frame ~= frame then w.Frame.ZIndex = 1 end end
		end
	end)
	arrow.MouseButton1Click:Connect(function()
		body.Visible = not body.Visible
		tw(arrow, 0.15, {Rotation = body.Visible and 0 or 180})
	end)

	function cat:CreateButton(text, callback)
		local b = make("TextButton", {BackgroundColor3 = C.off, BorderSizePixel = 0, Text = "", AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 36), LayoutOrder = #body:GetChildren()}, body)
		label(b, text, UDim2.new(1, -24, 1, 0), UDim2.fromOffset(12, 0), C.dim)
		b.MouseEnter:Connect(function() tw(b, 0.1, {BackgroundColor3 = C.hover}) end)
		b.MouseLeave:Connect(function() tw(b, 0.1, {BackgroundColor3 = C.off}) end)
		b.MouseButton1Click:Connect(function() if callback then task.spawn(callback) end end)
		return b
	end

	function cat:CreateModule(opts)
		local mod = {Name = opts.Name, Enabled = false, Key = nil}
		local holder = make("Frame", {BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0), LayoutOrder = #body:GetChildren()}, body)
		listLayout(holder)
		mod.Holder = holder

		local btn = make("TextButton", {BackgroundColor3 = C.off, BorderSizePixel = 0, Text = "", AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 36), LayoutOrder = 0}, holder)
		local lbl = label(btn, opts.Name, UDim2.new(1, -44, 1, 0), UDim2.fromOffset(12, 0), C.dim)
		local arrowM = arrowButton(btn, UDim2.new(1, -20, 0.5, 0))
		local sFrame = make("Frame", {BackgroundColor3 = C.settings, BorderSizePixel = 0, Visible = false,
			AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 1}, holder)
		listLayout(sFrame)
		make("UIPadding", {PaddingBottom = UDim.new(0, 4), PaddingTop = UDim.new(0, 4)}, sFrame)

		function mod:SetEnabled(v)
			self.Enabled = v
			tw(btn, 0.15, {BackgroundColor3 = v and C.accent or C.off})
			tw(lbl, 0.15, {TextColor3 = v and Color3.new(1, 1, 1) or C.dim})
			if opts.Callback then
				task.spawn(function()
					local ok, err = pcall(opts.Callback, v)
					if not ok then warn("[Render] " .. self.Name .. ": " .. tostring(err)) end
				end)
			end
		end
		local function toggleSettings()
			sFrame.Visible = not sFrame.Visible
			tw(arrowM, 0.15, {Rotation = sFrame.Visible and 180 or 0})
		end

		btn.MouseEnter:Connect(function() if not mod.Enabled then tw(btn, 0.1, {BackgroundColor3 = C.hover}) end end)
		btn.MouseLeave:Connect(function() if not mod.Enabled then tw(btn, 0.1, {BackgroundColor3 = C.off}) end end)
		btn.MouseButton1Click:Connect(function() mod:SetEnabled(not mod.Enabled) end)
		btn.MouseButton2Click:Connect(toggleSettings)
		arrowM.MouseButton1Click:Connect(toggleSettings)

		function mod:CreateToggle(o)
			local state = o.Default or false
			local r = make("TextButton", {BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 30),
				LayoutOrder = #sFrame:GetChildren()}, sFrame)
			label(r, o.Name, UDim2.new(1, -60, 1, 0), UDim2.fromOffset(14, 0), C.dim).TextSize = 13
			local pill = make("Frame", {BackgroundColor3 = state and C.accent or Color3.fromRGB(60, 60, 60),
				Size = UDim2.fromOffset(30, 16), Position = UDim2.new(1, -44, 0.5, -8)}, r)
			corner(pill, 8)
			local knob = make("Frame", {BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromOffset(12, 12),
				Position = state and UDim2.fromOffset(16, 2) or UDim2.fromOffset(2, 2)}, pill)
			corner(knob, 6)
			local function set(v)
				state = v
				tw(pill, 0.12, {BackgroundColor3 = v and C.accent or Color3.fromRGB(60, 60, 60)})
				tw(knob, 0.12, {Position = v and UDim2.fromOffset(16, 2) or UDim2.fromOffset(2, 2)})
				if o.Callback then task.spawn(o.Callback, v) end
			end
			r.MouseButton1Click:Connect(function() set(not state) end)
			return {Set = set, Get = function() return state end}
		end

		function mod:CreateSlider(o)
			local min, max, dec = o.Min or 0, o.Max or 100, o.Decimals or 0
			local value = o.Default or min
			local r = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 42), LayoutOrder = #sFrame:GetChildren()}, sFrame)
			label(r, o.Name, UDim2.new(1, -80, 0, 20), UDim2.fromOffset(14, 2), C.dim).TextSize = 13
			local vl = label(r, "", UDim2.new(0, 60, 0, 20), UDim2.new(1, -74, 0, 2), C.text, Enum.TextXAlignment.Right)
			vl.TextSize = 13
			local hit = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, -28, 0, 18), Position = UDim2.fromOffset(14, 22)}, r)
			local bar = make("Frame", {BackgroundColor3 = Color3.fromRGB(50, 50, 50), BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0, 0, 0.5, -2)}, hit)
			corner(bar, 2)
			local fill = make("Frame", {BackgroundColor3 = C.accent, BorderSizePixel = 0, Size = UDim2.new(0, 0, 1, 0)}, bar)
			corner(fill, 2)
			local function set(v, silent)
				local m = 10 ^ dec
				value = math.clamp(math.floor(v * m + 0.5) / m, min, max)
				fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
				vl.Text = tostring(value) .. (o.Suffix or "")
				if not silent and o.Callback then task.spawn(o.Callback, value) end
			end
			set(value, true)
			local sliding = false
			local function fromX(x) set(min + (max - min) * math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)) end
			hit.InputBegan:Connect(function(i) if isPress(i) then sliding = true; fromX(i.Position.X) end end)
			connect(UIS.InputChanged, function(i)
				if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then fromX(i.Position.X) end
			end)
			connect(UIS.InputEnded, function(i) if isPress(i) then sliding = false end end)
			return {Set = set, Get = function() return value end}
		end

		function mod:CreateDropdown(o)
			local opts2, i = o.Options, table.find(o.Options, o.Default) or 1
			local r = make("TextButton", {BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 30),
				LayoutOrder = #sFrame:GetChildren()}, sFrame)
			local l = label(r, "", UDim2.new(1, -28, 1, 0), UDim2.fromOffset(14, 0), C.dim)
			l.TextSize = 13
			local function show() l.Text = o.Name .. ":  " .. opts2[i] end
			show()
			r.MouseButton1Click:Connect(function()
				i = i % #opts2 + 1; show()
				if o.Callback then task.spawn(o.Callback, opts2[i]) end
			end)
			return {Get = function() return opts2[i] end}
		end

		function mod:CreateKeybind()
			local r = make("TextButton", {BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 30),
				LayoutOrder = #sFrame:GetChildren()}, sFrame)
			local l = label(r, "Keybind:  None", UDim2.new(1, -44, 1, 0), UDim2.fromOffset(14, 0), C.dim)
			l.TextSize = 13
			make("ImageLabel", {BackgroundTransparency = 1, Image = asset("KeybindIcon.png"),
				Size = UDim2.fromOffset(14, 14), Position = UDim2.new(1, -30, 0.5, -7)}, r)
			r.MouseButton1Click:Connect(function()
				l.Text = "Keybind:  press a key..."
				Library.Listener = function(input)
					if input.KeyCode == Enum.KeyCode.Escape then mod.Key = nil; l.Text = "Keybind:  None"
					else mod.Key = input.KeyCode; l.Text = "Keybind:  " .. input.KeyCode.Name end
				end
			end)
		end

		table.insert(cat.Modules, mod)
		table.insert(Library.Modules, mod)
		return mod
	end

	table.insert(self.Windows, cat)
	return cat
end

------------------------------------------------------------ list windows
function Library:CreateList(name, icon, pos, onChange)
	local cat = self:CreateCategory(name, icon, pos)
	local list = {}
	self.Lists[name] = list
	local wrap = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = 0}, cat.Body)
	local box = make("TextBox", {BackgroundColor3 = C.off, Text = "", PlaceholderText = "Add name + Enter",
		PlaceholderColor3 = C.dim, TextColor3 = C.text, Font = Enum.Font.Gotham, TextSize = 13, ClearTextOnFocus = false,
		Size = UDim2.new(1, -52, 0, 28), Position = UDim2.fromOffset(10, 6)}, wrap)
	corner(box, 4)
	local addBtn = make("ImageButton", {BackgroundTransparency = 1, Image = asset("AddItem.png"),
		Size = UDim2.fromOffset(22, 22), Position = UDim2.new(1, -36, 0, 9)}, wrap)
	local function render()
		for _, c in ipairs(cat.Body:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
		for n, v in ipairs(list) do
			local b = make("TextButton", {BackgroundColor3 = C.off, BorderSizePixel = 0, Text = v .. "   (click to remove)",
				Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = C.dim, Size = UDim2.new(1, 0, 0, 28), LayoutOrder = n}, cat.Body)
			b.MouseButton1Click:Connect(function() table.remove(list, table.find(list, v)); render(); if onChange then onChange(list) end end)
		end
	end
	local function commit()
		local t = box.Text:gsub("^%s+", ""):gsub("%s+$", "")
		if t ~= "" and not table.find(list, t) then
			table.insert(list, t); render(); if onChange then onChange(list) end
		end
		box.Text = ""
	end
	box.FocusLost:Connect(function(enter) if enter then commit() end end)
	addBtn.MouseButton1Click:Connect(commit)
	return cat, list
end

------------------------------------------------------------ top bar
local Bar = make("Frame", {BackgroundColor3 = C.bg, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 12),
	Size = UDim2.fromOffset(460, 42)}, Root)
corner(Bar, 5)
make("ImageLabel", {BackgroundTransparency = 1, Image = asset("rendericon2.png"), ScaleType = Enum.ScaleType.Fit,
	Size = UDim2.fromOffset(32, 32), Position = UDim2.fromOffset(8, 5)}, Bar)
label(Bar, "Render", UDim2.fromOffset(60, 42), UDim2.fromOffset(46, 0)).Font = Enum.Font.GothamBold
local search = make("TextBox", {BackgroundColor3 = C.off, Text = "", PlaceholderText = "Search modules", PlaceholderColor3 = C.dim,
	TextColor3 = C.text, Font = Enum.Font.Gotham, TextSize = 13, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
	Size = UDim2.fromOffset(190, 24), Position = UDim2.fromOffset(112, 9)}, Bar)
corner(search, 4)
make("UIPadding", {PaddingLeft = UDim.new(0, 26)}, search)
make("ImageLabel", {BackgroundTransparency = 1, Image = asset("SearchBarIcon.png"), Size = UDim2.fromOffset(14, 14),
	Position = UDim2.fromOffset(116, 14)}, Bar)
search:GetPropertyChangedSignal("Text"):Connect(function()
	local q = search.Text:lower()
	for _, m in ipairs(Library.Modules) do
		m.Holder.Visible = q == "" or m.Name:lower():find(q, 1, true) ~= nil
	end
end)
local function barButton(img, x, cb)
	local b = make("ImageButton", {BackgroundTransparency = 1, Image = asset(img), Size = UDim2.fromOffset(22, 22),
		Position = UDim2.new(1, x, 0, 10)}, Bar)
	b.MouseButton1Click:Connect(cb)
	return b
end
Library.LegitMode = false
barButton("LegitModeIcon.png", -98, function()
	Library.LegitMode = not Library.LegitMode
	Library:Notify("Legit mode", Library.LegitMode and "Enabled" or "Disabled", 2)
end)
barButton("DiscordIcon.png", -66, function() copy(DISCORD_LINK, "Discord invite") end)
barButton("ExitIcon1.png", -34, function() Library:SetVisible(false) end)

make("ImageLabel", {BackgroundTransparency = 1, Image = asset("VapeLogo1.png"), ImageTransparency = 0.35,
	ScaleType = Enum.ScaleType.Fit, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 16, 1, -16),
	Size = UDim2.fromOffset(110, 44)}, Root)

function Library:SetVisible(v)
	self.Visible = v
	Root.Visible = v
	tw(Blur, 0.25, {Size = v and 12 or 0})
	if not v then self:Notify("Render", "Press " .. self.ToggleKey.Name .. " to reopen", 3) end
end
function Library:Destroy()
	for _, c in ipairs(conns) do c:Disconnect() end
	Blur:Destroy(); Gui:Destroy()
end

connect(UIS.InputBegan, function(input, gp)
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	if Library.Listener then local f = Library.Listener; Library.Listener = nil; f(input); return end
	if input.KeyCode == Library.ToggleKey then Library:SetVisible(not Library.Visible); return end
	if gp then return end
	for _, m in ipairs(Library.Modules) do
		if m.Key == input.KeyCode then m:SetEnabled(not m.Enabled) end
	end
end)

------------------------------------------------------------ UI Tabs Setup
local PlayerTab  = Library:CreateCategory("Player",  asset("CombatIcon.png"))
local BlatantTab = Library:CreateCategory("Blatant", asset("BlatantIcon.png"))
local VisualTab  = Library:CreateCategory("Visuals", asset("RadarIcon1.png"))
local UtilityTab = Library:CreateCategory("Utility", asset("UtilityIcon.png"))

Library:CreateList("Friends", asset("FriendsIcon.png"))
Library:CreateList("Targets", asset("TargetIcon.png"))
local Settings   = Library:CreateCategory("Settings", asset("SettingsWheel1.png"))

------------------------------------------------------------ Module Registry & Auto-Loader
local Shared = {
	Players = Players,
	RunService = RunService,
	UserInputService = UIS,
	LocalPlayer = plr,
	Library = Library,
	Window = Library,
	PlayerTab = PlayerTab,
	VisualTab = VisualTab,
	UtilityTab = UtilityTab,
	BlatantTab = BlatantTab
}

local Modules = {
	{ Name = "Infinite Jump", File = "InfiniteJump", Tab = PlayerTab },
	{ Name = "Kill Aura", File = "ka", Tab = BlatantTab },
	{ Name = "No Knockback", File = "NoKnockback", Tab = BlatantTab },
	{ Name = "HitBox Extender", File = "hitbox", Tab = BlatantTab },
	{ Name = "Fly", File = "Fly", Tab = PlayerTab },
	{ Name = "Reach", File = "Reach", Tab = BlatantTab },
	{ Name = "Speed", File = "Speed", Tab = PlayerTab },
	{ Name = "China Hat", File = "ChinaHat", Tab = PlayerTab },
	{ Name = "Teleport", File = "Teleport", Tab = PlayerTab },
	{ Name = "Player ESP", File = "ESP", Tab = VisualTab },
	{ Name = "Anti Void", File = "AntiVoid", Tab = UtilityTab },
	{ Name = "X-Ray", File = "XRay", Tab = VisualTab },
	{ Name = "Bed ESP", File = "BedESP", Tab = VisualTab },
	{ Name = "FPS Counter", File = "FPS", Tab = UtilityTab },
	{ Name = "Ping Display", File = "Ping", Tab = UtilityTab },
	{ Name = "Keystrokes", File = "Keystrokes", Tab = UtilityTab },
	{ Name = "Custom Crosshair", File = "Crosshair", Tab = UtilityTab },
	{ Name = "Combat Status HUD", File = "CombatHUD", Tab = UtilityTab },
	{ Name = "Target Info (Mouseover)", File = "TargetInfo", Tab = UtilityTab },
	{ Name = "AutoJump", File = "AutoJump", Tab = PlayerTab },
	{ Name = "AutoLeave (Low Health)", File = "AutoLeave", Tab = PlayerTab },
	{ Name = "Report Player", File = "AutoReport", Tab = UtilityTab }
}

local LoadedModules = {}

local function LoadAndEnableModule(moduleData)
	if LoadedModules[moduleData.File] then return end
	
	-- Create the UI toggle item under its respective category tab
	local modUI = moduleData.Tab:CreateModule({
		Name = moduleData.Name,
		Callback = function(enabled)
			-- This triggers when you toggle the module on/down in the UI
		end
	})

	-- Fetch and execute module source from GitHub
	task.spawn(function()
		local url = BASE_URL .. moduleData.File .. ".lua"
		local success, result = pcall(function()
			local source = game:HttpGet(url)
			assert(type(source) == "string" and #source > 0, "Empty module source")
			local compiled, compileError = loadstring(source)
			assert(compiled, compileError)
			local initialize = compiled()
			assert(type(initialize) == "function", "Module must return an init function")
			initialize(Shared)
			LoadedModules[moduleData.File] = true
		end)

		if success then
			-- Automatically turn the module ON immediately on load as requested
			modUI:SetEnabled(true)
		else
			warn("[Shnicker Ware] Failed to load " .. moduleData.File .. ": " .. tostring(result))
		end
	end)
end

-- Automatically load and enable all modules on startup
for _, mod in ipairs(Modules) do
	LoadAndEnableModule(mod)
end

Settings:CreateButton("Copy Discord", function() copy(DISCORD_LINK, "Discord invite") end)
Settings:CreateButton("Copy Website", function() copy(WEBSITE_LINK, "Website link") end)
Settings:CreateButton("Uninject", function() Library:Destroy() end)

-- Startup splash
local Splash = make("ImageLabel", {BackgroundTransparency = 1, Image = asset("rendericon2.png"), ScaleType = Enum.ScaleType.Fit,
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(160, 160), ZIndex = 10}, Gui)
task.delay(1.2, function()
	tw(Splash, 0.6, {ImageTransparency = 1})
	task.delay(0.7, function() Splash:Destroy() end)
end)

Library:Notify("Shnicker Ware", "All modules loaded & enabled! Press RightShift to toggle.", 5)
return Library
