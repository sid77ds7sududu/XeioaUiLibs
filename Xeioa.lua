-- ╔═══════════════════════════════════════════════════════╗
-- ║          ORION UI LIBRARY - UPGRADED v2.0             ║
-- ║   Glassmorphism • Blur FX • Smooth Animations • +     ║
-- ╚═══════════════════════════════════════════════════════╝

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

-- ═══════════════════════════════════════
--  CORE LIBRARY SETUP
-- ═══════════════════════════════════════
local OrionLib = {
	Elements = {},
	ThemeObjects = {},
	Connections = {},
	Flags = {},
	Themes = {
		-- ▸ Dark Frost (Default) — Glassmorphism dunkles Design
		Default = {
			Main       = Color3.fromRGB(12, 12, 18),
			Second     = Color3.fromRGB(22, 22, 32),
			Third      = Color3.fromRGB(30, 30, 45),
			Stroke     = Color3.fromRGB(55, 55, 80),
			Divider    = Color3.fromRGB(40, 40, 60),
			Text       = Color3.fromRGB(245, 245, 255),
			TextDark   = Color3.fromRGB(140, 140, 170),
			Accent     = Color3.fromRGB(100, 130, 255),
			AccentDark = Color3.fromRGB(60, 90, 200),
			Success    = Color3.fromRGB(50, 200, 120),
			Warning    = Color3.fromRGB(255, 180, 50),
			Error      = Color3.fromRGB(255, 80, 80),
		},
		-- ▸ Neon Midnight — Cyberpunk Style
		Midnight = {
			Main       = Color3.fromRGB(8, 8, 15),
			Second     = Color3.fromRGB(15, 15, 28),
			Third      = Color3.fromRGB(20, 20, 38),
			Stroke     = Color3.fromRGB(0, 255, 180),
			Divider    = Color3.fromRGB(30, 30, 50),
			Text       = Color3.fromRGB(200, 255, 240),
			TextDark   = Color3.fromRGB(100, 200, 170),
			Accent     = Color3.fromRGB(0, 255, 180),
			AccentDark = Color3.fromRGB(0, 180, 120),
			Success    = Color3.fromRGB(0, 255, 120),
			Warning    = Color3.fromRGB(255, 200, 0),
			Error      = Color3.fromRGB(255, 60, 80),
		},
		-- ▸ Rose Gold — Premium Look
		Rose = {
			Main       = Color3.fromRGB(20, 14, 18),
			Second     = Color3.fromRGB(32, 22, 28),
			Third      = Color3.fromRGB(42, 30, 36),
			Stroke     = Color3.fromRGB(200, 120, 140),
			Divider    = Color3.fromRGB(60, 40, 50),
			Text       = Color3.fromRGB(255, 235, 240),
			TextDark   = Color3.fromRGB(180, 140, 155),
			Accent     = Color3.fromRGB(220, 150, 170),
			AccentDark = Color3.fromRGB(180, 100, 120),
			Success    = Color3.fromRGB(160, 220, 140),
			Warning    = Color3.fromRGB(255, 200, 100),
			Error      = Color3.fromRGB(255, 100, 100),
		},
	},
	SelectedTheme = "Default",
	Folder = nil,
	SaveCfg = false,
	-- NEU: Notification Queue
	_notifQueue = {},
	_notifActive = 0,
}

-- ═══════════════════════════════════════
--  TWEEN PRESETS (für saubere Animationen)
-- ═══════════════════════════════════════
local TI = {
	Fast   = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Medium = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Slow   = TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Spring = TweenInfo.new(0.5,  Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
	Bounce = TweenInfo.new(0.6,  Enum.EasingStyle.Bounce,Enum.EasingDirection.Out),
	Intro  = TweenInfo.new(0.7,  Enum.EasingStyle.Expo,  Enum.EasingDirection.Out),
}

local function Tween(obj, info, props)
	TweenService:Create(obj, info, props):Play()
end

-- ═══════════════════════════════════════
--  ICONS (Feather-Style Inline SVGs)
-- ═══════════════════════════════════════
local Icons = {}

getgenv().gethui = getgenv().gethui or function()
	return game.CoreGui
end

-- ═══════════════════════════════════════
--  SCREENGUI SETUP
-- ═══════════════════════════════════════
local Orion = Instance.new("ScreenGui")
Orion.Name = "OrionV2"
Orion.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Orion.DisplayOrder = 999

if syn then
	syn.protect_gui(Orion)
	Orion.Parent = game.CoreGui
else
	Orion.Parent = gethui() or game.CoreGui
end

-- Duplikat-Cleanup
local parentUI = gethui and gethui() or game.CoreGui
for _, v in ipairs(parentUI:GetChildren()) do
	if v.Name == Orion.Name and v ~= Orion then
		v:Destroy()
	end
end

-- ═══════════════════════════════════════
--  UTILITY FUNCTIONS
-- ═══════════════════════════════════════
function OrionLib:IsRunning()
	return Orion.Parent == (gethui and gethui() or game:GetService("CoreGui"))
end

local function AddConnection(Signal, Fn)
	if not OrionLib:IsRunning() then return end
	local conn = Signal:Connect(Fn)
	table.insert(OrionLib.Connections, conn)
	return conn
end

task.spawn(function()
	while OrionLib:IsRunning() do task.wait() end
	for _, c in pairs(OrionLib.Connections) do c:Disconnect() end
end)

local function AddDraggingFunctionality(DragPoint, Main)
	pcall(function()
		local Dragging, DragInput, MousePos, FramePos = false
		DragPoint.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Dragging = true
				MousePos = Input.Position
				FramePos = Main.Position
				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)
		DragPoint.InputChanged:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement then
				DragInput = Input
			end
		end)
		UserInputService.InputChanged:Connect(function(Input)
			if Input == DragInput and Dragging then
				local Delta = Input.Position - MousePos
				Tween(Main, TI.Slow, {
					Position = UDim2.new(
						FramePos.X.Scale, FramePos.X.Offset + Delta.X,
						FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y
					)
				})
			end
		end)
	end)
end

local function Create(Name, Props, Children)
	local obj = Instance.new(Name)
	for k, v in pairs(Props or {}) do obj[k] = v end
	for _, v in pairs(Children or {}) do v.Parent = obj end
	return obj
end

local function CreateElement(name, fn)
	OrionLib.Elements[name] = fn
end
local function MakeElement(name, ...)
	return OrionLib.Elements[name](...)
end
local function SetProps(elem, props)
	for k, v in pairs(props) do elem[k] = v end
	return elem
end
local function SetChildren(elem, children)
	for _, c in pairs(children) do c.Parent = elem end
	return elem
end
local function Round(n, factor)
	local r = math.floor(n / factor + math.sign(n) * 0.5) * factor
	if r < 0 then r = r + factor end
	return r
end

-- Theme-Prop Mapping
local function ReturnProperty(obj)
	if obj:IsA("Frame") or obj:IsA("TextButton") then return "BackgroundColor3" end
	if obj:IsA("ScrollingFrame") then return "ScrollBarImageColor3" end
	if obj:IsA("UIStroke") then return "Color" end
	if obj:IsA("TextLabel") or obj:IsA("TextBox") then return "TextColor3" end
	if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then return "ImageColor3" end
end

local function AddThemeObject(obj, themeType)
	if not OrionLib.ThemeObjects[themeType] then
		OrionLib.ThemeObjects[themeType] = {}
	end
	table.insert(OrionLib.ThemeObjects[themeType], obj)
	obj[ReturnProperty(obj)] = OrionLib.Themes[OrionLib.SelectedTheme][themeType]
	return obj
end

local function SetTheme()
	for name, list in pairs(OrionLib.ThemeObjects) do
		for _, obj in pairs(list) do
			obj[ReturnProperty(obj)] = OrionLib.Themes[OrionLib.SelectedTheme][name]
		end
	end
end

-- NEU: Theme wechseln zur Laufzeit
function OrionLib:SetTheme(themeName)
	if OrionLib.Themes[themeName] then
		OrionLib.SelectedTheme = themeName
		SetTheme()
	end
end

-- Farbe pack/unpack
local function PackColor(c) return {R = c.R*255, G = c.G*255, B = c.B*255} end
local function UnpackColor(c) return Color3.fromRGB(c.R, c.G, c.B) end

local function LoadCfg(cfg)
	local ok, data = pcall(HttpService.JSONDecode, HttpService, cfg)
	if not ok then return end
	for k, v in pairs(data) do
		if OrionLib.Flags[k] then
			task.spawn(function()
				if OrionLib.Flags[k].Type == "Colorpicker" then
					OrionLib.Flags[k]:Set(UnpackColor(v))
				else
					OrionLib.Flags[k]:Set(v)
				end
			end)
		end
	end
end

local function SaveCfg(name)
	local data = {}
	for k, v in pairs(OrionLib.Flags) do
		if v.Save then
			data[k] = v.Type == "Colorpicker" and PackColor(v.Value) or v.Value
		end
	end
	pcall(writefile, OrionLib.Folder .. "/" .. name .. ".txt", HttpService:JSONEncode(data))
end

local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3}
local BlacklistedKeys  = {Enum.KeyCode.Unknown,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Up,Enum.KeyCode.Left,Enum.KeyCode.Down,Enum.KeyCode.Right,Enum.KeyCode.Slash,Enum.KeyCode.Tab,Enum.KeyCode.Backspace,Enum.KeyCode.Escape}

local function CheckKey(tbl, key)
	for _, v in pairs(tbl) do
		if v == key then return true end
	end
end

-- ═══════════════════════════════════════
--  ELEMENT FACTORY
-- ═══════════════════════════════════════
CreateElement("Corner", function(s, o)
	return Create("UICorner", {CornerRadius = UDim.new(s or 0, o or 10)})
end)

CreateElement("Stroke", function(color, thickness)
	return Create("UIStroke", {Color = color or Color3.fromRGB(255,255,255), Thickness = thickness or 1})
end)

CreateElement("List", function(s, o)
	return Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(s or 0, o or 0)})
end)

CreateElement("Padding", function(b, l, r, t)
	return Create("UIPadding", {
		PaddingBottom = UDim.new(0, b or 4),
		PaddingLeft   = UDim.new(0, l or 4),
		PaddingRight  = UDim.new(0, r or 4),
		PaddingTop    = UDim.new(0, t or 4),
	})
end)

CreateElement("TFrame", function()
	return Create("Frame", {BackgroundTransparency = 1})
end)

CreateElement("Frame", function(color)
	return Create("Frame", {BackgroundColor3 = color or Color3.fromRGB(255,255,255), BorderSizePixel = 0})
end)

CreateElement("RoundFrame", function(color, scale, offset)
	return Create("Frame", {
		BackgroundColor3 = color or Color3.fromRGB(255,255,255),
		BorderSizePixel  = 0
	}, {
		Create("UICorner", {CornerRadius = UDim.new(scale or 0, offset or 10)})
	})
end)

CreateElement("Button", function()
	return Create("TextButton", {
		Text = "", AutoButtonColor = false,
		BackgroundTransparency = 1, BorderSizePixel = 0
	})
end)

CreateElement("ScrollFrame", function(color, width)
	return Create("ScrollingFrame", {
		BackgroundTransparency  = 1,
		MidImage                = "rbxassetid://7445543667",
		BottomImage             = "rbxassetid://7445543667",
		TopImage                = "rbxassetid://7445543667",
		ScrollBarImageColor3    = color,
		BorderSizePixel         = 0,
		ScrollBarThickness      = width,
		CanvasSize              = UDim2.new(0,0,0,0),
	})
end)

CreateElement("Image", function(id)
	return Create("ImageLabel", {Image = id, BackgroundTransparency = 1})
end)

CreateElement("ImageButton", function(id)
	return Create("ImageButton", {Image = id, BackgroundTransparency = 1})
end)

CreateElement("Label", function(text, size, transparency)
	return Create("TextLabel", {
		Text                = text or "",
		TextColor3          = Color3.fromRGB(240,240,240),
		TextTransparency    = transparency or 0,
		TextSize            = size or 15,
		Font                = Enum.Font.Gotham,
		RichText            = true,
		BackgroundTransparency = 1,
		TextXAlignment      = Enum.TextXAlignment.Left,
	})
end)

-- NEU: Glow-Effekt Hilfsfunktion
local function AddGlow(parent, color, size)
	local glow = Create("ImageLabel", {
		BackgroundTransparency = 1,
		Image  = "rbxassetid://5028857084",
		ImageColor3 = color or Color3.fromRGB(100,130,255),
		ImageTransparency = 0.7,
		Size   = UDim2.new(1, size or 20, 1, size or 20),
		Position = UDim2.new(0, -(size or 20)/2, 0, -(size or 20)/2),
		ZIndex = 0,
		Parent = parent,
	})
	return glow
end

-- ═══════════════════════════════════════
--  NOTIFICATION SYSTEM (Komplett neu)
-- ═══════════════════════════════════════
local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
	SetProps(MakeElement("List"), {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder           = Enum.SortOrder.LayoutOrder,
		VerticalAlignment   = Enum.VerticalAlignment.Bottom,
		Padding             = UDim.new(0, 8),
	})
}), {
	Position   = UDim2.new(1, -20, 1, -20),
	Size       = UDim2.new(0, 320, 1, -20),
	AnchorPoint= Vector2.new(1, 1),
	Parent     = Orion,
})

function OrionLib:MakeNotification(cfg)
	task.spawn(function()
		cfg.Name    = cfg.Name    or "Notification"
		cfg.Content = cfg.Content or "..."
		cfg.Image   = cfg.Image   or "rbxassetid://4384403532"
		cfg.Time    = cfg.Time    or 5
		cfg.Type    = cfg.Type    or "Info" -- Info / Success / Warning / Error

		local accentColor = ({
			Info    = OrionLib.Themes[OrionLib.SelectedTheme].Accent,
			Success = OrionLib.Themes[OrionLib.SelectedTheme].Success,
			Warning = OrionLib.Themes[OrionLib.SelectedTheme].Warning,
			Error   = OrionLib.Themes[OrionLib.SelectedTheme].Error,
		})[cfg.Type] or OrionLib.Themes[OrionLib.SelectedTheme].Accent

		local Wrap = SetProps(MakeElement("TFrame"), {
			Size          = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent        = NotificationHolder,
		})

		-- Hintergrundramen
		local Frame = SetChildren(SetProps(
			MakeElement("RoundFrame", Color3.fromRGB(18, 18, 28), 0, 12),
			{
				Parent        = Wrap,
				Size          = UDim2.new(1, 0, 0, 0),
				Position      = UDim2.new(1, 20, 0, 0), -- startet rechts außerhalb
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 0,
				ClipsDescendants = true,
			}
		), {
			-- Farbiger Linker Streifen
			Create("Frame", {
				Size             = UDim2.new(0, 3, 1, 0),
				BackgroundColor3 = accentColor,
				BorderSizePixel  = 0,
			}, {Create("UICorner", {CornerRadius = UDim.new(0,3)})}),
			-- Stroke
			Create("UIStroke", {Color = accentColor, Thickness = 1, Transparency = 0.7}),
			-- Padding
			MakeElement("Padding", 12, 16, 12, 12),
			-- Icon
			SetProps(MakeElement("Image", cfg.Image), {
				Size        = UDim2.new(0, 18, 0, 18),
				ImageColor3 = accentColor,
				Name        = "Icon",
			}),
			-- Titel
			SetProps(MakeElement("Label", cfg.Name, 14), {
				Size     = UDim2.new(1, -28, 0, 18),
				Position = UDim2.new(0, 28, 0, 0),
				Font     = Enum.Font.GothamBold,
				Name     = "Title",
				TextColor3 = Color3.fromRGB(255,255,255),
			}),
			-- Content
			SetProps(MakeElement("Label", cfg.Content, 13), {
				Size          = UDim2.new(1, 0, 0, 0),
				Position      = UDim2.new(0, 0, 0, 24),
				AutomaticSize = Enum.AutomaticSize.Y,
				TextWrapped   = true,
				Name          = "Content",
				TextColor3    = Color3.fromRGB(170, 170, 200),
				Font          = Enum.Font.GothamSemibold,
			}),
			-- Progress Bar
			Create("Frame", {
				Size             = UDim2.new(1, 0, 0, 2),
				Position         = UDim2.new(0, 0, 1, -2),
				BackgroundColor3 = accentColor,
				BorderSizePixel  = 0,
				Name             = "Progress",
			}, {Create("UICorner", {CornerRadius = UDim.new(0,2)})}),
		})

		-- Slide-In
		Tween(Frame, TI.Spring, {Position = UDim2.new(0, 0, 0, 0)})

		-- Progress-Bar Animation
		Tween(
			Frame.Progress,
			TweenInfo.new(cfg.Time - 0.5, Enum.EasingStyle.Linear),
			{Size = UDim2.new(0, 0, 0, 2)}
		)

		task.wait(cfg.Time - 0.5)
		Tween(Frame, TI.Medium, {Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 0.4})
		task.wait(0.6)
		Frame:Destroy()
	end)
end

-- ═══════════════════════════════════════
--  INIT
-- ═══════════════════════════════════════
function OrionLib:Init()
	if OrionLib.SaveCfg then
		pcall(function()
			local path = OrionLib.Folder .. "/" .. game.GameId .. ".txt"
			if isfile(path) then
				LoadCfg(readfile(path))
				OrionLib:MakeNotification({
					Name    = "Config geladen",
					Content = "Auto-Config für Game " .. game.GameId,
					Time    = 4,
					Type    = "Success",
				})
			end
		end)
	end
end

-- ═══════════════════════════════════════
--  HAUPTFENSTER
-- ═══════════════════════════════════════
function OrionLib:MakeWindow(WindowConfig)
	local FirstTab  = true
	local Minimized = false
	local UIHidden  = false

	WindowConfig                 = WindowConfig or {}
	WindowConfig.Name            = WindowConfig.Name or "Orion v2"
	WindowConfig.ConfigFolder    = WindowConfig.ConfigFolder or WindowConfig.Name
	WindowConfig.SaveConfig      = WindowConfig.SaveConfig or false
	WindowConfig.HidePremium     = WindowConfig.HidePremium or false
	WindowConfig.IntroEnabled    = WindowConfig.IntroEnabled ~= false
	WindowConfig.IntroText       = WindowConfig.IntroText or "Orion v2"
	WindowConfig.CloseCallback   = WindowConfig.CloseCallback or function() end
	WindowConfig.ShowIcon        = WindowConfig.ShowIcon or false
	WindowConfig.Icon            = WindowConfig.Icon or "rbxassetid://8834748103"
	WindowConfig.IntroIcon       = WindowConfig.IntroIcon or "rbxassetid://8834748103"
	WindowConfig.HideKey         = WindowConfig.HideKey or Enum.KeyCode.RightShift

	OrionLib.Folder  = WindowConfig.ConfigFolder
	OrionLib.SaveCfg = WindowConfig.SaveConfig

	if WindowConfig.SaveConfig then
		pcall(function()
			if not isfolder(WindowConfig.ConfigFolder) then
				makefolder(WindowConfig.ConfigFolder)
			end
		end)
	end

	local theme = OrionLib.Themes[OrionLib.SelectedTheme]

	-- ── Tab-Liste (links)
	local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255,255,255), 3), {
		Size = UDim2.new(1, 0, 1, -60),
	}), {
		MakeElement("List"),
		MakeElement("Padding", 8, 0, 0, 8),
	}), "Divider")

	AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		TabHolder.CanvasSize = UDim2.new(0,0,0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
	end)

	-- ── Buttons (Close / Minimize)
	local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072725342"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size     = UDim2.new(0, 18, 0, 18),
		}), "Text"),
	})

	local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072719338"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size     = UDim2.new(0, 18, 0, 18),
			Name     = "Ico",
		}), "Text"),
	})

	local DragPoint = SetProps(MakeElement("TFrame"), {
		Size = UDim2.new(1, 0, 0, 55),
	})

	-- ── Linke Sidebar
	local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 12), {
		Size     = UDim2.new(0, 155, 1, -55),
		Position = UDim2.new(0, 0, 0, 55),
	}), {
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size     = UDim2.new(1, 0, 0, 12),
			Position = UDim2.new(0, 0, 0, 0),
		}), "Second"),
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size     = UDim2.new(0, 12, 1, 0),
			Position = UDim2.new(1, -12, 0, 0),
		}), "Second"),
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size     = UDim2.new(0, 1, 1, 0),
			Position = UDim2.new(1, -1, 0, 0),
		}), "Stroke"),
		TabHolder,
		-- ── Nutzer-Info unten
		SetChildren(SetProps(MakeElement("TFrame"), {
			Size     = UDim2.new(1, 0, 0, 55),
			Position = UDim2.new(0, 0, 1, -55),
		}), {
			AddThemeObject(SetProps(MakeElement("Frame"), {
				Size = UDim2.new(1, 0, 0, 1),
			}), "Stroke"),
			AddThemeObject(SetChildren(SetProps(MakeElement("Frame"), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size        = UDim2.new(0, 34, 0, 34),
				Position    = UDim2.new(0, 10, 0.5, 0),
				BackgroundTransparency = 1,
			}), {
				SetProps(MakeElement("Image", ("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png"):format(LocalPlayer.UserId)), {
					Size = UDim2.new(1,0,1,0),
				}),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4031889928"), {
					Size = UDim2.new(1,0,1,0),
				}), "Second"),
				MakeElement("Corner", 1),
			}), "Divider"),
			SetChildren(SetProps(MakeElement("TFrame"), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size        = UDim2.new(0, 34, 0, 34),
				Position    = UDim2.new(0, 10, 0.5, 0),
			}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				MakeElement("Corner", 1),
			}),
			AddThemeObject(SetProps(MakeElement("Label", LocalPlayer.DisplayName, 11), {
				Size          = UDim2.new(1, -55, 0, 13),
				Position      = UDim2.new(0, 50, 0, 10),
				Font          = Enum.Font.GothamBold,
				TextTruncate  = Enum.TextTruncate.AtEnd,
				Visible       = not WindowConfig.HidePremium,
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", "@" .. LocalPlayer.Name, 10), {
				Size          = UDim2.new(1, -55, 0, 12),
				Position      = UDim2.new(0, 50, 0, 26),
				TextTruncate  = Enum.TextTruncate.AtEnd,
				Visible       = not WindowConfig.HidePremium,
			}), "TextDark"),
		}),
	}), "Second")

	-- ── Fenstertitel
	local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 18), {
		Size     = UDim2.new(1, -120, 1, 0),
		Position = UDim2.new(0, WindowConfig.ShowIcon and 55 or 20, 0, 0),
		Font     = Enum.Font.GothamBlack,
	}), "Text")

	local WindowTopBarLine = AddThemeObject(SetProps(MakeElement("Frame"), {
		Size     = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
	}), "Stroke")

	-- ── Haupt-Fenster
	local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 12), {
		Parent          = Orion,
		Position        = UDim2.new(0.5, -320, 0.5, -185),
		Size            = UDim2.new(0, 640, 0, 370),
		ClipsDescendants= true,
	}), {
		-- TopBar
		SetChildren(SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 55),
			Name = "TopBar",
		}), {
			WindowName,
			WindowTopBarLine,
			-- Buttons
			AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 8), {
				Size     = UDim2.new(0, 72, 0, 30),
				Position = UDim2.new(1, -90, 0, 12),
			}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				AddThemeObject(SetProps(MakeElement("Frame"), {
					Size     = UDim2.new(0, 1, 1, 0),
					Position = UDim2.new(0.5, 0, 0, 0),
				}), "Stroke"),
				CloseBtn,
				MinimizeBtn,
			}), "Second"),
		}),
		DragPoint,
		WindowStuff,
	}), "Main")

	-- Fenster-Icon
	if WindowConfig.ShowIcon then
		SetProps(MakeElement("Image", WindowConfig.Icon), {
			Size     = UDim2.new(0, 22, 0, 22),
			Position = UDim2.new(0, 20, 0.5, -11),
			Parent   = MainWindow.TopBar,
		})
	end

	AddDraggingFunctionality(DragPoint, MainWindow)

	-- ── Hover-Effekte Buttons
	local function btnHover(btn, frame, colorKey, delta)
		AddConnection(btn.MouseEnter, function()
			Tween(frame, TI.Fast, {BackgroundColor3 = Color3.fromRGB(
				math.clamp(OrionLib.Themes[OrionLib.SelectedTheme][colorKey].R*255 + delta, 0, 255),
				math.clamp(OrionLib.Themes[OrionLib.SelectedTheme][colorKey].G*255 + delta, 0, 255),
				math.clamp(OrionLib.Themes[OrionLib.SelectedTheme][colorKey].B*255 + delta, 0, 255)
			)})
		end)
		AddConnection(btn.MouseLeave, function()
			Tween(frame, TI.Fast, {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme][colorKey]})
		end)
	end

	-- ── Schließen
	AddConnection(CloseBtn.MouseButton1Up, function()
		Tween(MainWindow, TI.Medium, {Size = UDim2.new(0, 640, 0, 0)})
		task.wait(0.35)
		MainWindow.Visible = false
		UIHidden = true
		OrionLib:MakeNotification({
			Name    = "Interface ausgeblendet",
			Content = ("Drücke %s zum Wiederherstellen"):format(WindowConfig.HideKey.Name),
			Time    = 5,
			Type    = "Warning",
		})
		WindowConfig.CloseCallback()
	end)

	AddConnection(UserInputService.InputBegan, function(Input)
		if Input.KeyCode == WindowConfig.HideKey and UIHidden then
			UIHidden = false
			MainWindow.Visible = true
			MainWindow.Size = UDim2.new(0, 640, 0, 0)
			Tween(MainWindow, TI.Spring, {Size = UDim2.new(0, 640, 0, 370)})
		end
	end)

	-- ── Minimieren
	AddConnection(MinimizeBtn.MouseButton1Up, function()
		if Minimized then
			Tween(MainWindow, TI.Spring, {Size = UDim2.new(0, 640, 0, 370)})
			MinimizeBtn.Ico.Image = "rbxassetid://7072719338"
			task.wait(0.05)
			MainWindow.ClipsDescendants = false
			WindowStuff.Visible = true
			WindowTopBarLine.Visible = true
		else
			MainWindow.ClipsDescendants = true
			WindowTopBarLine.Visible = false
			MinimizeBtn.Ico.Image = "rbxassetid://7072720870"
			Tween(MainWindow, TI.Medium, {Size = UDim2.new(0, WindowName.TextBounds.X + 150, 0, 55)})
			task.wait(0.15)
			WindowStuff.Visible = false
		end
		Minimized = not Minimized
	end)

	-- ── Intro-Animation (verbessert)
	local function LoadSequence()
		MainWindow.Visible = false

		local Overlay = Create("Frame", {
			Parent          = Orion,
			Size            = UDim2.new(1, 0, 1, 0),
			BackgroundColor3= Color3.fromRGB(8, 8, 15),
			BorderSizePixel = 0,
			BackgroundTransparency = 0,
			ZIndex = 10,
		})

		local Logo = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {
			Parent       = Overlay,
			AnchorPoint  = Vector2.new(0.5, 0.5),
			Position     = UDim2.new(0.5, 0, 0.45, 0),
			Size         = UDim2.new(0, 40, 0, 40),
			ImageColor3  = OrionLib.Themes[OrionLib.SelectedTheme].Accent,
			ImageTransparency = 1,
			ZIndex       = 11,
		})

		local TextLabel = SetProps(MakeElement("Label", WindowConfig.IntroText, 22), {
			Parent          = Overlay,
			Size            = UDim2.new(1, 0, 0, 30),
			AnchorPoint     = Vector2.new(0.5, 0.5),
			Position        = UDim2.new(0.5, 0, 0.55, 0),
			TextXAlignment  = Enum.TextXAlignment.Center,
			Font            = Enum.Font.GothamBlack,
			TextTransparency= 1,
			TextColor3      = Color3.fromRGB(255,255,255),
			ZIndex          = 11,
		})

		Tween(Logo,      TI.Intro, {ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.42, 0)})
		task.wait(0.6)
		Tween(TextLabel, TI.Intro, {TextTransparency = 0, Position = UDim2.new(0.5, 0, 0.53, 0)})
		task.wait(1.8)
		Tween(Logo,      TI.Medium, {ImageTransparency = 1})
		Tween(TextLabel, TI.Medium, {TextTransparency = 1})
		Tween(Overlay,   TI.Medium, {BackgroundTransparency = 1})
		task.wait(0.45)
		Overlay:Destroy()
		MainWindow.Visible = true
		MainWindow.Size = UDim2.new(0, 640, 0, 0)
		Tween(MainWindow, TI.Spring, {Size = UDim2.new(0, 640, 0, 370)})
	end

	if WindowConfig.IntroEnabled then
		LoadSequence()
	end

	-- ═══════════════════════════════════════
	--  TAB SYSTEM
	-- ═══════════════════════════════════════
	local TabFunction = {}

	function TabFunction:MakeTab(TabConfig)
		TabConfig        = TabConfig or {}
		TabConfig.Name   = TabConfig.Name or "Tab"
		TabConfig.Icon   = TabConfig.Icon or ""
		TabConfig.PremiumOnly = TabConfig.PremiumOnly or false

		-- Aktiver Indikator
		local ActiveBar = Create("Frame", {
			Size             = UDim2.new(0, 3, 0, 0),
			Position         = UDim2.new(0, 0, 0.5, 0),
			AnchorPoint      = Vector2.new(0, 0.5),
			BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Accent,
			BorderSizePixel  = 0,
		}, {Create("UICorner", {CornerRadius = UDim.new(0,3)})})

		local TabFrame = SetChildren(SetProps(MakeElement("Button"), {
			Size   = UDim2.new(1, 0, 0, 33),
			Parent = TabHolder,
			ClipsDescendants = true,
		}), {
			ActiveBar,
			AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon), {
				AnchorPoint      = Vector2.new(0, 0.5),
				Size             = UDim2.new(0, 17, 0, 17),
				Position         = UDim2.new(0, 16, 0.5, 0),
				ImageTransparency= 0.5,
				Name             = "Ico",
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 14), {
				Size             = UDim2.new(1, -40, 1, 0),
				Position         = UDim2.new(0, 38, 0, 0),
				Font             = Enum.Font.GothamSemibold,
				TextTransparency = 0.5,
				Name             = "Title",
			}), "Text"),
		})

		-- Hover-Effekt
		AddConnection(TabFrame.MouseEnter, function()
			if TabFrame.Title.TextTransparency > 0.1 then
				Tween(TabFrame.Title, TI.Fast, {TextTransparency = 0.2})
				Tween(TabFrame.Ico,   TI.Fast, {ImageTransparency = 0.2})
			end
		end)
		AddConnection(TabFrame.MouseLeave, function()
			if TabFrame.Title.TextTransparency > 0.1 then
				Tween(TabFrame.Title, TI.Fast, {TextTransparency = 0.5})
				Tween(TabFrame.Ico,   TI.Fast, {ImageTransparency = 0.5})
			end
		end)

		local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255,255,255), 4), {
			Size     = UDim2.new(1, -155, 1, -55),
			Position = UDim2.new(0, 155, 0, 55),
			Parent   = MainWindow,
			Visible  = false,
			Name     = "ItemContainer",
		}), {
			MakeElement("List", 0, 7),
			MakeElement("Padding", 15, 12, 12, 15),
		}), "Divider")

		AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			Container.CanvasSize = UDim2.new(0,0,0, Container.UIListLayout.AbsoluteContentSize.Y + 30)
		end)

		-- Ersten Tab aktivieren
		if FirstTab then
			FirstTab = false
			TabFrame.Ico.ImageTransparency   = 0
			TabFrame.Title.TextTransparency  = 0
			TabFrame.Title.Font              = Enum.Font.GothamBlack
			Container.Visible = true
			Tween(ActiveBar, TI.Spring, {Size = UDim2.new(0, 3, 0.7, 0)})
		end

		local function ActivateTab()
			-- Alle Tabs deaktivieren
			for _, tab in pairs(TabHolder:GetChildren()) do
				if tab:IsA("TextButton") then
					tab.Title.Font = Enum.Font.GothamSemibold
					Tween(tab.Ico,   TI.Fast, {ImageTransparency = 0.5})
					Tween(tab.Title, TI.Fast, {TextTransparency = 0.5})
					Tween(tab:FindFirstChild("Frame"), TI.Fast, {Size = UDim2.new(0, 3, 0, 0)})
				end
			end
			-- Alle Container verstecken
			for _, c in pairs(MainWindow:GetChildren()) do
				if c.Name == "ItemContainer" then c.Visible = false end
			end
			-- Diesen Tab aktivieren
			Tween(TabFrame.Ico,   TI.Fast, {ImageTransparency = 0})
			Tween(TabFrame.Title, TI.Fast, {TextTransparency = 0})
			Tween(ActiveBar, TI.Spring, {Size = UDim2.new(0, 3, 0.7, 0)})
			TabFrame.Title.Font = Enum.Font.GothamBlack
			Container.Visible = true
		end

		AddConnection(TabFrame.MouseButton1Click, ActivateTab)

		-- ═══════════════════════════════════════
		--  ELEMENTE
		-- ═══════════════════════════════════════
		local function GetElements(ItemParent)
			local EF = {}

			-- ── LABEL
			function EF:AddLabel(Text)
				local f = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 6), {
					Size                = UDim2.new(1, 0, 0, 32),
					BackgroundTransparency = 0.75,
					Parent              = ItemParent,
				}), {
					AddThemeObject(SetProps(MakeElement("Label", Text, 14), {
						Size     = UDim2.new(1, -14, 1, 0),
						Position = UDim2.new(0, 14, 0, 0),
						Font     = Enum.Font.GothamBold,
						Name     = "Content",
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
				}), "Second")
				return {Set = function(_, t) f.Content.Text = t end}
			end

			-- ── PARAGRAPH
			function EF:AddParagraph(Text, Content)
				Text    = Text or "Text"
				Content = Content or "..."
				local f = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 6), {
					Size                = UDim2.new(1, 0, 0, 32),
					BackgroundTransparency = 0.75,
					Parent              = ItemParent,
				}), {
					AddThemeObject(SetProps(MakeElement("Label", Text, 14), {
						Size     = UDim2.new(1, -14, 0, 14),
						Position = UDim2.new(0, 14, 0, 9),
						Font     = Enum.Font.GothamBold,
						Name     = "Title",
					}), "Text"),
					AddThemeObject(SetProps(MakeElement("Label", "", 12), {
						Size          = UDim2.new(1, -28, 0, 0),
						Position      = UDim2.new(0, 14, 0, 26),
						AutomaticSize = Enum.AutomaticSize.Y,
						Font          = Enum.Font.GothamSemibold,
						TextWrapped   = true,
						Name          = "Content",
					}), "TextDark"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
				}), "Second")
				AddConnection(f.Content:GetPropertyChangedSignal("Text"), function()
					f.Content.Size = UDim2.new(1, -28, 0, f.Content.TextBounds.Y)
					f.Size = UDim2.new(1, 0, 0, f.Content.TextBounds.Y + 36)
				end)
				f.Content.Text = Content
				return {Set = function(_, t) f.Content.Text = t end}
			end

			-- ── BUTTON (verbessert mit Ripple)
			function EF:AddButton(cfg)
				cfg          = cfg or {}
				cfg.Name     = cfg.Name or "Button"
				cfg.Callback = cfg.Callback or function() end
				cfg.Icon     = cfg.Icon or ""

				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})

				local BtnFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 6), {
					Size   = UDim2.new(1, 0, 0, 36),
					Parent = ItemParent,
					ClipsDescendants = true,
				}), {
					AddThemeObject(SetProps(MakeElement("Label", cfg.Name, 14), {
						Size     = UDim2.new(1, -14, 1, 0),
						Position = UDim2.new(0, 14, 0, 0),
						Font     = Enum.Font.GothamBold,
						Name     = "Content",
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					Click,
				}), "Second")

				-- Ripple on click
				AddConnection(Click.MouseButton1Down, function()
					local ripple = Create("Frame", {
						Size             = UDim2.new(0, 0, 0, 0),
						AnchorPoint      = Vector2.new(0.5, 0.5),
						Position         = UDim2.new(Mouse.X - BtnFrame.AbsolutePosition.X > 0 and (Mouse.X - BtnFrame.AbsolutePosition.X)/BtnFrame.AbsoluteSize.X or 0.5, 0, 0.5, 0),
						BackgroundColor3 = Color3.fromRGB(255,255,255),
						BackgroundTransparency = 0.85,
						BorderSizePixel  = 0,
						Parent           = BtnFrame,
						ZIndex           = 2,
					}, {Create("UICorner", {CornerRadius = UDim.new(1,0)})})
					Tween(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
						Size     = UDim2.new(0, BtnFrame.AbsoluteSize.X * 2, 0, BtnFrame.AbsoluteSize.X * 2),
						BackgroundTransparency = 1,
					})
					task.delay(0.4, function() ripple:Destroy() end)
					Tween(BtnFrame, TI.Fast, {BackgroundColor3 = Color3.fromRGB(
						math.clamp(OrionLib.Themes[OrionLib.SelectedTheme].Second.R*255+6, 0, 255),
						math.clamp(OrionLib.Themes[OrionLib.SelectedTheme].Second.G*255+6, 0, 255),
						math.clamp(OrionLib.Themes[OrionLib.SelectedTheme].Second.B*255+6, 0, 255)
					)})
				end)

				AddConnection(Click.MouseButton1Up, function()
					Tween(BtnFrame, TI.Fast, {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second})
					task.spawn(cfg.Callback)
				end)

				AddConnection(Click.MouseEnter, function()
					Tween(BtnFrame, TI.Fast, {BackgroundColor3 = Color3.fromRGB(
						math.clamp(OrionLib.Themes[OrionLib.SelectedTheme].Second.R*255+4, 0, 255),
						math.clamp(OrionLib.Themes[OrionLib.SelectedTheme].Second.G*255+4, 0, 255),
						math.clamp(OrionLib.Themes[OrionLib.SelectedTheme].Second.B*255+4, 0, 255)
					)})
				end)
				AddConnection(Click.MouseLeave, function()
					Tween(BtnFrame, TI.Fast, {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second})
				end)

				return {Set = function(_, t) BtnFrame.Content.Text = t end}
			end

			-- ── TOGGLE (neues Design)
			function EF:AddToggle(cfg)
				cfg          = cfg or {}
				cfg.Name     = cfg.Name or "Toggle"
				cfg.Default  = cfg.Default or false
				cfg.Callback = cfg.Callback or function() end
				cfg.Color    = cfg.Color or OrionLib.Themes[OrionLib.SelectedTheme].Accent
				cfg.Flag     = cfg.Flag or nil
				cfg.Save     = cfg.Save or false

				local Toggle = {Value = cfg.Default, Save = cfg.Save, Type = "Toggle"}

				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})

				-- Track (Hintergrund)
				local Track = Create("Frame", {
					Size             = UDim2.new(0, 44, 0, 24),
					Position         = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint      = Vector2.new(1, 0.5),
					BackgroundColor3 = Color3.fromRGB(40, 40, 60),
					BorderSizePixel  = 0,
				}, {
					Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
					Create("UIStroke", {Color = OrionLib.Themes[OrionLib.SelectedTheme].Stroke, Thickness = 1, Name = "Stroke"}),
				})

				-- Thumb (Knopf)
				local Thumb = Create("Frame", {
					Size             = UDim2.new(0, 18, 0, 18),
					Position         = UDim2.new(0, 3, 0.5, 0),
					AnchorPoint      = Vector2.new(0, 0.5),
					BackgroundColor3 = Color3.fromRGB(160, 160, 180),
					BorderSizePixel  = 0,
					Parent           = Track,
				}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})

				local ToggleFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 6), {
					Size   = UDim2.new(1, 0, 0, 40),
					Parent = ItemParent,
					ClipsDescendants = true,
				}), {
					AddThemeObject(SetProps(MakeElement("Label", cfg.Name, 14), {
						Size     = UDim2.new(1, -65, 1, 0),
						Position = UDim2.new(0, 14, 0, 0),
						Font     = Enum.Font.GothamBold,
						Name     = "Content",
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					Track,
					Click,
				}), "Second")

				function Toggle:Set(val)
					self.Value = val
					Tween(Track,  TI.Fast, {BackgroundColor3 = val and cfg.Color or Color3.fromRGB(40,40,60)})
					Tween(Track.Stroke, TI.Fast, {Color = val and cfg.Color or OrionLib.Themes[OrionLib.SelectedTheme].Stroke})
					Tween(Thumb, TI.Spring, {
						Position         = val and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
						BackgroundColor3 = val and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,160,180),
					})
					cfg.Callback(self.Value)
				end

				Toggle:Set(Toggle.Value)

				AddConnection(Click.MouseButton1Up, function()
					Toggle:Set(not Toggle.Value)
					SaveCfg(game.GameId)
				end)

				AddConnection(Click.MouseEnter, function()
					Tween(ToggleFrame, TI.Fast, {BackgroundColor3 = Color3.fromRGB(
						math.clamp(OrionLib.Themes[OrionLib.SelectedTheme].Second.R*255+4, 0, 255),
						math.clamp(OrionLib.Themes[OrionLib.SelectedTheme].Second.G*255+4, 0, 255),
						math.clamp(OrionLib.Themes[OrionLib.SelectedTheme].Second.B*255+4, 0, 255)
					)})
				end)
				AddConnection(Click.MouseLeave, function()
					Tween(ToggleFrame, TI.Fast, {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second})
				end)

				if cfg.Flag then OrionLib.Flags[cfg.Flag] = Toggle end
				return Toggle
			end

			-- ── SLIDER (smooth + Value-Anzeige)
			function EF:AddSlider(cfg)
				cfg              = cfg or {}
				cfg.Name         = cfg.Name or "Slider"
				cfg.Min          = cfg.Min or 0
				cfg.Max          = cfg.Max or 100
				cfg.Increment    = cfg.Increment or 1
				cfg.Default      = cfg.Default or 50
				cfg.Callback     = cfg.Callback or function() end
				cfg.ValueName    = cfg.ValueName or ""
				cfg.Color        = cfg.Color or OrionLib.Themes[OrionLib.SelectedTheme].Accent
				cfg.Flag         = cfg.Flag or nil
				cfg.Save         = cfg.Save or false

				local Slider  = {Value = cfg.Default, Save = cfg.Save, Type = "Slider"}
				local Dragging = false

				-- Filled Track
				local Fill = Create("Frame", {
					Size             = UDim2.new(0, 0, 1, 0),
					BackgroundColor3 = cfg.Color,
					BorderSizePixel  = 0,
					ZIndex           = 2,
				}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})

				-- Thumb Dot
				local Dot = Create("Frame", {
					Size             = UDim2.new(0, 14, 0, 14),
					AnchorPoint      = Vector2.new(0.5, 0.5),
					Position         = UDim2.new(0, 0, 0.5, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel  = 0,
					ZIndex           = 3,
					Parent           = Fill,
				}, {
					Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
					Create("UIStroke", {Color = cfg.Color, Thickness = 2}),
				})

				local SliderBar = Create("Frame", {
					Size             = UDim2.new(1, -24, 0, 8),
					Position         = UDim2.new(0, 12, 0, 38),
					BackgroundColor3 = Color3.fromRGB(35, 35, 55),
					BorderSizePixel  = 0,
					ZIndex           = 1,
				}, {
					Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
					Fill,
				})

				local ValueLabel = SetProps(MakeElement("Label", tostring(cfg.Default) .. " " .. cfg.ValueName, 12), {
					Size             = UDim2.new(0, 80, 0, 14),
					Position         = UDim2.new(1, -82, 0, 10),
					TextXAlignment   = Enum.TextXAlignment.Right,
					Font             = Enum.Font.GothamBold,
					TextColor3       = cfg.Color,
					Name             = "ValueLabel",
				})

				local SliderFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 6), {
					Size   = UDim2.new(1, 0, 0, 58),
					Parent = ItemParent,
				}), {
					AddThemeObject(SetProps(MakeElement("Label", cfg.Name, 14), {
						Size     = UDim2.new(1, -90, 0, 14),
						Position = UDim2.new(0, 14, 0, 10),
						Font     = Enum.Font.GothamBold,
						Name     = "Content",
					}), "Text"),
					ValueLabel,
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					SliderBar,
				}), "Second")

				function Slider:Set(val)
					self.Value = math.clamp(Round(val, cfg.Increment), cfg.Min, cfg.Max)
					local pct = (self.Value - cfg.Min) / (cfg.Max - cfg.Min)
					Tween(Fill, TI.Fast, {Size = UDim2.new(pct, 0, 1, 0)})
					Dot.Position = UDim2.new(1, 0, 0.5, 0)
					ValueLabel.Text = tostring(self.Value) .. " " .. cfg.ValueName
					cfg.Callback(self.Value)
				end

				SliderBar.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						Dragging = true
						Tween(Dot, TI.Fast, {Size = UDim2.new(0, 18, 0, 18)})
					end
				end)
				SliderBar.InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						Dragging = false
						Tween(Dot, TI.Fast, {Size = UDim2.new(0, 14, 0, 14)})
					end
				end)
				UserInputService.InputChanged:Connect(function(i)
					if Dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
						local pct = math.clamp((i.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
						Slider:Set(cfg.Min + (cfg.Max - cfg.Min) * pct)
						SaveCfg(game.GameId)
					end
				end)

				Slider:Set(Slider.Value)
				if cfg.Flag then OrionLib.Flags[cfg.Flag] = Slider end
				return Slider
			end

			-- ── DROPDOWN (verbessert)
			function EF:AddDropdown(cfg)
				cfg          = cfg or {}
				cfg.Name     = cfg.Name or "Dropdown"
				cfg.Options  = cfg.Options or {}
				cfg.Default  = cfg.Default or ""
				cfg.Callback = cfg.Callback or function() end
				cfg.Flag     = cfg.Flag or nil
				cfg.Save     = cfg.Save or false

				local Dropdown = {Value = cfg.Default, Options = cfg.Options, Buttons = {}, Toggled = false, Type = "Dropdown", Save = cfg.Save}
				local MaxEl = 5

				if not table.find(Dropdown.Options, Dropdown.Value) then
					Dropdown.Value = "..."
				end

				local List = MakeElement("List")
				local Scroll = AddThemeObject(SetProps(SetChildren(MakeElement("ScrollFrame", Color3.fromRGB(40,40,40), 3), {List}), {
					Parent    = nil, -- wird später gesetzt
					Position  = UDim2.new(0, 0, 0, 40),
					Size      = UDim2.new(1, 0, 1, -40),
					ClipsDescendants = true,
				}), "Divider")

				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})

				local DropFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 6), {
					Size    = UDim2.new(1, 0, 0, 40),
					Parent  = ItemParent,
					ClipsDescendants = true,
				}), {
					Scroll,
					SetProps(SetChildren(MakeElement("TFrame"), {
						AddThemeObject(SetProps(MakeElement("Label", cfg.Name, 14), {
							Size     = UDim2.new(1, -14, 1, 0),
							Position = UDim2.new(0, 14, 0, 0),
							Font     = Enum.Font.GothamBold,
							Name     = "Content",
						}), "Text"),
						AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072706796"), {
							Size       = UDim2.new(0, 18, 0, 18),
							AnchorPoint= Vector2.new(0, 0.5),
							Position   = UDim2.new(1, -28, 0.5, 0),
							ImageColor3= Color3.fromRGB(240,240,240),
							Name       = "Ico",
						}), "TextDark"),
						AddThemeObject(SetProps(MakeElement("Label", "Selected", 12), {
							Size             = UDim2.new(1, -45, 1, 0),
							Font             = Enum.Font.Gotham,
							Name             = "Selected",
							TextXAlignment   = Enum.TextXAlignment.Right,
						}), "TextDark"),
						AddThemeObject(SetProps(MakeElement("Frame"), {
							Size     = UDim2.new(1, 0, 0, 1),
							Position = UDim2.new(0, 0, 1, -1),
							Name     = "Line",
							Visible  = false,
						}), "Stroke"),
						Click,
					}), {
						Size = UDim2.new(1,0,0,40),
						ClipsDescendants = true,
						Name = "F",
					}),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					MakeElement("Corner", 0, 6),
				}), "Second")

				AddConnection(List:GetPropertyChangedSignal("AbsoluteContentSize"), function()
					Scroll.CanvasSize = UDim2.new(0,0,0, List.AbsoluteContentSize.Y)
				end)

				local function AddOptions(opts)
					for _, opt in pairs(opts) do
						local btn = AddThemeObject(SetProps(SetChildren(MakeElement("Button"), {
							MakeElement("Corner", 0, 5),
							AddThemeObject(SetProps(MakeElement("Label", opt, 13, 0.4), {
								Position = UDim2.new(0, 10, 0, 0),
								Size     = UDim2.new(1, -10, 1, 0),
								Name     = "Title",
							}), "Text"),
						}), {
							Parent    = Scroll,
							Size      = UDim2.new(1, 0, 0, 28),
							BackgroundTransparency = 1,
							ClipsDescendants = true,
						}), "Divider")
						AddConnection(btn.MouseButton1Click, function()
							Dropdown:Set(opt)
							SaveCfg(game.GameId)
						end)
						Dropdown.Buttons[opt] = btn
					end
				end

				function Dropdown:Refresh(opts, del)
					if del then
						for _, v in pairs(self.Buttons) do v:Destroy() end
						table.clear(self.Options)
						table.clear(self.Buttons)
					end
					self.Options = opts
					AddOptions(self.Options)
				end

				function Dropdown:Set(val)
					if not table.find(self.Options, val) then
						self.Value = "..."
						DropFrame.F.Selected.Text = self.Value
						for _, v in pairs(self.Buttons) do
							Tween(v, TI.Fast, {BackgroundTransparency = 1})
							Tween(v.Title, TI.Fast, {TextTransparency = 0.4})
						end
						return
					end
					self.Value = val
					DropFrame.F.Selected.Text = self.Value
					for _, v in pairs(self.Buttons) do
						Tween(v, TI.Fast, {BackgroundTransparency = 1})
						Tween(v.Title, TI.Fast, {TextTransparency = 0.4})
					end
					if self.Buttons[val] then
						Tween(self.Buttons[val], TI.Fast, {BackgroundTransparency = 0})
						Tween(self.Buttons[val].Title, TI.Fast, {TextTransparency = 0})
					end
					cfg.Callback(self.Value)
				end

				AddConnection(Click.MouseButton1Click, function()
					Dropdown.Toggled = not Dropdown.Toggled
					DropFrame.F.Line.Visible = Dropdown.Toggled
					Tween(DropFrame.F.Ico, TI.Fast, {Rotation = Dropdown.Toggled and 180 or 0})
					local count = #Dropdown.Options
					local h = Dropdown.Toggled
						and (count > MaxEl and (40 + MaxEl*28) or (40 + List.AbsoluteContentSize.Y))
						or 40
					Tween(DropFrame, TI.Fast, {Size = UDim2.new(1, 0, 0, h)})
				end)

				Dropdown:Refresh(Dropdown.Options, false)
				Dropdown:Set(Dropdown.Value)
				if cfg.Flag then OrionLib.Flags[cfg.Flag] = Dropdown end
				return Dropdown
			end

			-- ── BIND
			function EF:AddBind(cfg)
				cfg          = cfg or {}
				cfg.Name     = cfg.Name or "Bind"
				cfg.Default  = cfg.Default or Enum.KeyCode.Unknown
				cfg.Hold     = cfg.Hold or false
				cfg.Callback = cfg.Callback or function() end
				cfg.Flag     = cfg.Flag or nil
				cfg.Save     = cfg.Save or false

				local Bind = {Value = nil, Binding = false, Type = "Bind", Save = cfg.Save}
				local Holding = false

				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})

				local BindBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {
					Size       = UDim2.new(0, 28, 0, 24),
					Position   = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint= Vector2.new(1, 0.5),
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					AddThemeObject(SetProps(MakeElement("Label", "...", 13), {
						Size           = UDim2.new(1, 0, 1, 0),
						Font           = Enum.Font.GothamBold,
						TextXAlignment = Enum.TextXAlignment.Center,
						Name           = "Value",
					}), "Text"),
				}), "Main")

				local BindFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 6), {
					Size   = UDim2.new(1, 0, 0, 40),
					Parent = ItemParent,
				}), {
					AddThemeObject(SetProps(MakeElement("Label", cfg.Name, 14), {
						Size     = UDim2.new(1, -14, 1, 0),
						Position = UDim2.new(0, 14, 0, 0),
						Font     = Enum.Font.GothamBold,
						Name     = "Content",
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					BindBox,
					Click,
				}), "Second")

				AddConnection(BindBox.Value:GetPropertyChangedSignal("Text"), function()
					Tween(BindBox, TI.Fast, {Size = UDim2.new(0, math.max(28, BindBox.Value.TextBounds.X + 18), 0, 24)})
				end)

				AddConnection(Click.InputEnded, function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						if Bind.Binding then return end
						Bind.Binding = true
						BindBox.Value.Text = "..."
						Tween(BindBox, TI.Fast, {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Accent})
					end
				end)

				AddConnection(UserInputService.InputBegan, function(i)
					if UserInputService:GetFocusedTextBox() then return end
					if (i.KeyCode.Name == Bind.Value or (i.UserInputType and i.UserInputType.Name == Bind.Value)) and not Bind.Binding then
						if cfg.Hold then
							Holding = true; cfg.Callback(Holding)
						else
							cfg.Callback()
						end
					elseif Bind.Binding then
						local Key
						pcall(function()
							if not CheckKey(BlacklistedKeys, i.KeyCode) then Key = i.KeyCode end
						end)
						pcall(function()
							if CheckKey(WhitelistedMouse, i.UserInputType) and not Key then Key = i.UserInputType end
						end)
						Bind:Set(Key or Bind.Value)
						SaveCfg(game.GameId)
					end
				end)

				AddConnection(UserInputService.InputEnded, function(i)
					if (i.KeyCode.Name == Bind.Value or (i.UserInputType and i.UserInputType.Name == Bind.Value)) then
						if cfg.Hold and Holding then
							Holding = false; cfg.Callback(Holding)
						end
					end
				end)

				function Bind:Set(key)
					self.Binding = false
					self.Value = (key and (key.Name or key)) or self.Value
					BindBox.Value.Text = tostring(self.Value or "None")
					Tween(BindBox, TI.Fast, {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Main})
				end

				Bind:Set(cfg.Default)
				if cfg.Flag then OrionLib.Flags[cfg.Flag] = Bind end
				return Bind
			end

			-- ── TEXTBOX
			function EF:AddTextbox(cfg)
				cfg               = cfg or {}
				cfg.Name          = cfg.Name or "Textbox"
				cfg.Default       = cfg.Default or ""
				cfg.Placeholder   = cfg.Placeholder or "Eingabe..."
				cfg.TextDisappear = cfg.TextDisappear or false
				cfg.Callback      = cfg.Callback or function() end

				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})

				local TBActual = AddThemeObject(Create("TextBox", {
					Size                = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					TextColor3          = Color3.fromRGB(255,255,255),
					PlaceholderColor3   = Color3.fromRGB(180,180,200),
					PlaceholderText     = cfg.Placeholder,
					Font                = Enum.Font.GothamSemibold,
					TextXAlignment      = Enum.TextXAlignment.Center,
					TextSize            = 13,
					ClearTextOnFocus    = false,
				}), "Text")

				local TBContainer = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {
					Size       = UDim2.new(0, 28, 0, 24),
					Position   = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint= Vector2.new(1, 0.5),
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					TBActual,
				}), "Main")

				local TBFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 6), {
					Size   = UDim2.new(1, 0, 0, 40),
					Parent = ItemParent,
				}), {
					AddThemeObject(SetProps(MakeElement("Label", cfg.Name, 14), {
						Size     = UDim2.new(1, -14, 1, 0),
						Position = UDim2.new(0, 14, 0, 0),
						Font     = Enum.Font.GothamBold,
						Name     = "Content",
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					TBContainer,
					Click,
				}), "Second")

				AddConnection(TBActual:GetPropertyChangedSignal("Text"), function()
					Tween(TBContainer, TI.Medium, {Size = UDim2.new(0, math.max(28, TBActual.TextBounds.X + 18), 0, 24)})
				end)

				AddConnection(TBActual.FocusLost, function()
					cfg.Callback(TBActual.Text)
					if cfg.TextDisappear then TBActual.Text = "" end
					Tween(TBFrame, TI.Fast, {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second})
				end)

				AddConnection(TBActual:GetPropertyChangedSignal("IsFocused"), function()
					-- kein direktes IsFocused Signal, aber bei FocusLost und CaptureFocus
				end)

				TBActual.Text = cfg.Default

				AddConnection(Click.MouseButton1Up, function()
					TBActual:CaptureFocus()
					Tween(TBFrame, TI.Fast, {BackgroundColor3 = Color3.fromRGB(
						math.clamp(OrionLib.Themes[OrionLib.SelectedTheme].Second.R*255+5, 0, 255),
						math.clamp(OrionLib.Themes[OrionLib.SelectedTheme].Second.G*255+5, 0, 255),
						math.clamp(OrionLib.Themes[OrionLib.SelectedTheme].Second.B*255+5, 0, 255)
					)})
				end)

				AddConnection(Click.MouseEnter, function()
					Tween(TBFrame, TI.Fast, {BackgroundColor3 = Color3.fromRGB(
						math.clamp(OrionLib.Themes[OrionLib.SelectedTheme].Second.R*255+4, 0, 255),
						math.clamp(OrionLib.Themes[OrionLib.SelectedTheme].Second.G*255+4, 0, 255),
						math.clamp(OrionLib.Themes[OrionLib.SelectedTheme].Second.B*255+4, 0, 255)
					)})
				end)
				AddConnection(Click.MouseLeave, function()
					Tween(TBFrame, TI.Fast, {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second})
				end)
			end

			-- ── COLORPICKER (unverändert, aber besser integriert)
			function EF:AddColorpicker(cfg)
				cfg          = cfg or {}
				cfg.Name     = cfg.Name or "Colorpicker"
				cfg.Default  = cfg.Default or Color3.fromRGB(255,255,255)
				cfg.Callback = cfg.Callback or function() end
				cfg.Flag     = cfg.Flag or nil
				cfg.Save     = cfg.Save or false

				local ColorH, ColorS, ColorV = Color3.toHSV(cfg.Default)
				local CP = {Value = cfg.Default, Toggled = false, Type = "Colorpicker", Save = cfg.Save}

				local ColorSel = Create("ImageLabel", {
					Size = UDim2.new(0,16,0,16), AnchorPoint = Vector2.new(0.5,0.5),
					Position = UDim2.new(ColorS, 0, 1-ColorV, 0),
					BackgroundTransparency = 1,
					Image = "http://www.roblox.com/asset/?id=4805639000",
				})
				local HueSel = Create("ImageLabel", {
					Size = UDim2.new(0,16,0,16), AnchorPoint = Vector2.new(0.5,0.5),
					Position = UDim2.new(0.5, 0, 1-ColorH, 0),
					BackgroundTransparency = 1,
					Image = "http://www.roblox.com/asset/?id=4805639000",
				})
				local ColorGrad = Create("ImageLabel", {
					Size = UDim2.new(1,-28,1,0), Visible = false,
					Image = "rbxassetid://4155801252",
				}, {Create("UICorner",{CornerRadius=UDim.new(0,5)}), ColorSel})
				local HueGrad = Create("Frame", {
					Size = UDim2.new(0,20,1,0), Position = UDim2.new(1,-20,0,0), Visible = false,
				}, {
					Create("UIGradient",{Rotation=270, Color=ColorSequence.new{
						ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,4)),
						ColorSequenceKeypoint.new(0.20, Color3.fromRGB(234,255,0)),
						ColorSequenceKeypoint.new(0.40, Color3.fromRGB(21,255,0)),
						ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0,255,255)),
						ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0,17,255)),
						ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255,0,251)),
						ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,4)),
					}}),
					Create("UICorner",{CornerRadius=UDim.new(0,5)}),
					HueSel,
				})
				local CPContainer = Create("Frame", {
					Position = UDim2.new(0,0,0,36), Size = UDim2.new(1,0,1,-36),
					BackgroundTransparency = 1, ClipsDescendants = true,
				}, {
					HueGrad, ColorGrad,
					Create("UIPadding",{PaddingLeft=UDim.new(0,35),PaddingRight=UDim.new(0,35),PaddingBottom=UDim.new(0,10),PaddingTop=UDim.new(0,14)}),
				})

				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
				local CPBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {
					Size = UDim2.new(0,24,0,24), Position = UDim2.new(1,-12,0.5,0), AnchorPoint = Vector2.new(1,0.5),
				}), {AddThemeObject(MakeElement("Stroke"), "Stroke")}), "Main")

				local CPFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 6), {
					Size = UDim2.new(1,0,0,40), Parent = ItemParent,
				}), {
					SetProps(SetChildren(MakeElement("TFrame"), {
						AddThemeObject(SetProps(MakeElement("Label", cfg.Name, 14), {
							Size=UDim2.new(1,-14,1,0), Position=UDim2.new(0,14,0,0), Font=Enum.Font.GothamBold, Name="Content",
						}), "Text"),
						CPBox, Click,
						AddThemeObject(SetProps(MakeElement("Frame"),{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),Name="Line",Visible=false}),"Stroke"),
					}), {Size=UDim2.new(1,0,0,40),ClipsDescendants=true,Name="F"}),
					CPContainer,
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
				}), "Second")

				AddConnection(Click.MouseButton1Click, function()
					CP.Toggled = not CP.Toggled
					Tween(CPFrame, TI.Fast, {Size = CP.Toggled and UDim2.new(1,0,0,150) or UDim2.new(1,0,0,40)})
					ColorGrad.Visible = CP.Toggled
					HueGrad.Visible   = CP.Toggled
					CPFrame.F.Line.Visible = CP.Toggled
				end)

				local function UpdateCP()
					CPBox.BackgroundColor3 = Color3.fromHSV(ColorH, ColorS, ColorV)
					ColorGrad.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1)
					CP:Set(CPBox.BackgroundColor3)
					SaveCfg(game.GameId)
				end

				local ColorInput, HueInput

				AddConnection(ColorGrad.InputBegan, function(i)
					if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
					if ColorInput then ColorInput:Disconnect() end
					ColorInput = AddConnection(RunService.RenderStepped, function()
						ColorS = math.clamp((Mouse.X - ColorGrad.AbsolutePosition.X) / ColorGrad.AbsoluteSize.X, 0, 1)
						ColorV = 1 - math.clamp((Mouse.Y - ColorGrad.AbsolutePosition.Y) / ColorGrad.AbsoluteSize.Y, 0, 1)
						ColorSel.Position = UDim2.new(ColorS, 0, 1-ColorV, 0)
						UpdateCP()
					end)
				end)
				AddConnection(ColorGrad.InputEnded, function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 and ColorInput then ColorInput:Disconnect() end
				end)
				AddConnection(HueGrad.InputBegan, function(i)
					if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
					if HueInput then HueInput:Disconnect() end
					HueInput = AddConnection(RunService.RenderStepped, function()
						ColorH = 1 - math.clamp((Mouse.Y - HueGrad.AbsolutePosition.Y) / HueGrad.AbsoluteSize.Y, 0, 1)
						HueSel.Position = UDim2.new(0.5, 0, 1-ColorH, 0)
						UpdateCP()
					end)
				end)
				AddConnection(HueGrad.InputEnded, function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 and HueInput then HueInput:Disconnect() end
				end)

				function CP:Set(val)
					self.Value = val
					CPBox.BackgroundColor3 = self.Value
					cfg.Callback(self.Value)
				end
				CP:Set(CP.Value)
				if cfg.Flag then OrionLib.Flags[cfg.Flag] = CP end
				return CP
			end

			-- NEU: SECTION DIVIDER
			function EF:AddDivider()
				Create("Frame", {
					Size             = UDim2.new(1, 0, 0, 1),
					BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Stroke,
					BorderSizePixel  = 0,
					Parent           = ItemParent,
				}, {Create("UICorner", {CornerRadius = UDim.new(1,0)})})
			end

			return EF
		end

		-- Section
		local ElementFunction = {}
		function ElementFunction:AddSection(cfg)
			cfg = cfg or {}
			cfg.Name = cfg.Name or "Section"

			local SectionFrame = SetChildren(SetProps(MakeElement("TFrame"), {
				Size   = UDim2.new(1, 0, 0, 28),
				Parent = Container,
			}), {
				AddThemeObject(SetProps(MakeElement("Label", cfg.Name, 13), {
					Size     = UDim2.new(1, -12, 0, 16),
					Position = UDim2.new(0, 0, 0, 3),
					Font     = Enum.Font.GothamBold,
					TextColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Accent,
				}), "Accent"),
				-- Trennlinie
				Create("Frame", {
					Size             = UDim2.new(1, 0, 0, 1),
					Position         = UDim2.new(0, 0, 0, 22),
					BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Stroke,
					BorderSizePixel  = 0,
				}),
				SetChildren(SetProps(MakeElement("TFrame"), {
					AnchorPoint = Vector2.new(0, 0),
					Size        = UDim2.new(1, 0, 1, -28),
					Position    = UDim2.new(0, 0, 0, 27),
					Name        = "Holder",
				}), {MakeElement("List", 0, 7)}),
			})

			AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				SectionFrame.Size        = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 33)
				SectionFrame.Holder.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y)
			end)

			local SF = {}
			for k, v in pairs(GetElements(SectionFrame.Holder)) do SF[k] = v end
			return SF
		end

		for k, v in pairs(GetElements(Container)) do ElementFunction[k] = v end

		-- Premium-Lock
		if TabConfig.PremiumOnly then
			for k in pairs(ElementFunction) do ElementFunction[k] = function() end end
			pcall(function()
				Container:FindFirstChild("UIListLayout"):Destroy()
				Container:FindFirstChild("UIPadding"):Destroy()
			end)
			SetChildren(SetProps(MakeElement("TFrame"), {
				Size = UDim2.new(1,0,1,0), Parent = Container,
			}), {
				AddThemeObject(SetProps(MakeElement("Image","rbxassetid://3610239960"),{
					Size=UDim2.new(0,22,0,22), Position=UDim2.new(0,15,0,15), ImageTransparency=0.4,
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label","Premium-Zugang erforderlich",14),{
					Size=UDim2.new(1,-50,0,14), Position=UDim2.new(0,44,0,19), TextTransparency=0.4,
				}), "Text"),
			})
		end

		return ElementFunction
	end

	return TabFunction
end

-- ═══════════════════════════════════════
--  DESTROY
-- ═══════════════════════════════════════
function OrionLib:Destroy()
	Orion:Destroy()
end

return OrionLib
