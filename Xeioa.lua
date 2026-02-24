local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

local ModernLib = {
	Elements = {},
	ThemeObjects = {},
	Connections = {},
	Flags = {},
	Windows = {},
	Notifications = {},
	Themes = {
		Dark = {
			Main = Color3.fromRGB(18, 18, 18),
			Second = Color3.fromRGB(25, 25, 25),
			Third = Color3.fromRGB(35, 35, 35),
			Stroke = Color3.fromRGB(45, 45, 45),
			Text = Color3.fromRGB(255, 255, 255),
			TextDark = Color3.fromRGB(170, 170, 170),
			Accent = Color3.fromRGB(0, 153, 255),
			Success = Color3.fromRGB(0, 200, 100),
			Danger = Color3.fromRGB(255, 70, 70),
			Warning = Color3.fromRGB(255, 170, 0)
		},
		Midnight = {
			Main = Color3.fromRGB(8, 8, 15),
			Second = Color3.fromRGB(15, 15, 25),
			Third = Color3.fromRGB(25, 25, 40),
			Stroke = Color3.fromRGB(45, 45, 70),
			Text = Color3.fromRGB(220, 220, 255),
			TextDark = Color3.fromRGB(150, 150, 200),
			Accent = Color3.fromRGB(100, 100, 255),
			Success = Color3.fromRGB(70, 200, 70),
			Danger = Color3.fromRGB(255, 80, 80),
			Warning = Color3.fromRGB(255, 180, 50)
		},
		Light = {
			Main = Color3.fromRGB(245, 245, 245),
			Second = Color3.fromRGB(235, 235, 235),
			Third = Color3.fromRGB(225, 225, 225),
			Stroke = Color3.fromRGB(200, 200, 200),
			Text = Color3.fromRGB(20, 20, 20),
			TextDark = Color3.fromRGB(100, 100, 100),
			Accent = Color3.fromRGB(0, 120, 255),
			Success = Color3.fromRGB(0, 150, 50),
			Danger = Color3.fromRGB(200, 50, 50),
			Warning = Color3.fromRGB(200, 130, 0)
		}
	},
	SelectedTheme = "Dark",
	Folder = nil,
	SaveCfg = false,
	Version = "2.0"
}

-- Verbesserte Icon-Integration
local Icons = {
	home = "rbxassetid://4483345998",
	settings = "rbxassetid://4483345875",
	user = "rbxassetid://4483345981",
	close = "rbxassetid://4483344457",
	minimize = "rbxassetid://4483344549",
	maximize = "rbxassetid://4483344530",
	chevron_down = "rbxassetid://4483344443",
	chevron_up = "rbxassetid://4483344450",
	check = "rbxassetid://4483344436",
	search = "rbxassetid://4483344576",
	refresh = "rbxassetid://4483344569",
	trash = "rbxassetid://4483344627",
	download = "rbxassetid://4483344495",
	upload = "rbxassetid://4483344620",
	lock = "rbxassetid://4483344527",
	unlock = "rbxassetid://4483344613",
	info = "rbxassetid://4483344512",
	warning = "rbxassetid://4483344636",
	error = "rbxassetid://4483344503",
	success = "rbxassetid://4483344583"
}

-- Verbesserte UI-Elemente mit Schatten und Glow-Effekten
local function CreateShadow(parent, size, transparency)
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.BackgroundTransparency = 1
	shadow.Size = UDim2.new(1, size*2, 1, size*2)
	shadow.Position = UDim2.new(0, -size, 0, -size)
	shadow.Image = "rbxassetid://6015897843"
	shadow.ImageColor3 = Color3.new(0, 0, 0)
	shadow.ImageTransparency = transparency or 0.7
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(10, 10, 118, 118)
	shadow.Parent = parent
	return shadow
end

local function CreateGlow(parent, color, size)
	local glow = Instance.new("ImageLabel")
	glow.Name = "Glow"
	glow.BackgroundTransparency = 1
	glow.Size = UDim2.new(1, size*2, 1, size*2)
	glow.Position = UDim2.new(0, -size, 0, -size)
	glow.Image = "rbxassetid://6015897843"
	glow.ImageColor3 = color
	glow.ImageTransparency = 0.8
	glow.ScaleType = Enum.ScaleType.Slice
	glow.SliceCenter = Rect.new(10, 10, 118, 118)
	glow.Parent = parent
	return glow
end

getgenv().gethui = function() 
	return game:GetService("CoreGui")
end

local Modern = Instance.new("ScreenGui")
Modern.Name = "ModernUI"
Modern.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Modern.DisplayOrder = 999

if syn and syn.protect_gui then
	syn.protect_gui(Modern)
	Modern.Parent = game.CoreGui
elseif gethui then
	Modern.Parent = gethui()
else
	Modern.Parent = game:GetService("CoreGui")
end

-- Cleanup alte Instanzen
for _, gui in ipairs(Modern.Parent:GetChildren()) do
	if gui.Name == Modern.Name and gui ~= Modern then
		gui:Destroy()
	end
end

function ModernLib:IsRunning()
	return Modern and Modern.Parent ~= nil
end

local function AddConnection(signal, func)
	if not ModernLib:IsRunning() then return end
	local conn = signal:Connect(func)
	table.insert(ModernLib.Connections, conn)
	return conn
end

task.spawn(function()
	while ModernLib:IsRunning() do
		task.wait()
	end
	for _, conn in ipairs(ModernLib.Connections) do
		conn:Disconnect()
	end
end)

-- Verbesserte Drag-Funktion mit Smoothing
local function AddDragging(DragPoint, Main, DragFrame)
	local dragging = false
	local dragInput, dragStart, startPos
	
	local function update(input)
		if not dragging then return end
		local delta = input.Position - dragStart
		local newPos = UDim2.new(
			startPos.X.Scale, 
			startPos.X.Offset + delta.X,
			startPos.Y.Scale, 
			startPos.Y.Offset + delta.Y
		)
		TweenService:Create(Main, TweenInfo.new(0.08, Enum.EasingStyle.Sine), {Position = newPos}):Play()
	end
	
	DragPoint.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Main.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	DragPoint.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	AddConnection(UserInputService.InputChanged, function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

-- Verbesserte UI-Erstellung
local function CreateUI(className, properties, children)
	local obj = Instance.new(className)
	for prop, value in pairs(properties or {}) do
		pcall(function() obj[prop] = value end)
	end
	for _, child in ipairs(children or {}) do
		child.Parent = obj
	end
	return obj
end

-- Haupt-Window Erstellung
function ModernLib:CreateWindow(config)
	config = config or {}
	config.Name = config.Name or "Modern UI"
	config.Theme = config.Theme or "Dark"
	config.Size = config.Size or UDim2.new(0, 700, 0, 450)
	config.Position = config.Position or UDim2.new(0.5, -350, 0.5, -225)
	config.ConfigFolder = config.ConfigFolder or "ModernConfig"
	config.AutoSave = config.AutoSave or false
	config.Keybind = config.Keybind or Enum.KeyCode.RightShift
	
	ModernLib.SelectedTheme = config.Theme
	ModernLib.Folder = config.ConfigFolder
	ModernLib.SaveCfg = config.AutoSave
	
	local theme = ModernLib.Themes[config.Theme]
	local windowVisible = true
	local minimized = false
	
	-- Main Container mit Shadow
	local MainShadow = CreateUI("ImageLabel", {
		Parent = Modern,
		Position = config.Position + UDim2.new(0, 10, 0, 10),
		Size = config.Size,
		BackgroundTransparency = 1,
		Image = "rbxassetid://6015897843",
		ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = 0.8,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(10, 10, 118, 118)
	})
	
	local Main = CreateUI("Frame", {
		Parent = Modern,
		Position = config.Position,
		Size = config.Size,
		BackgroundColor3 = theme.Main,
		BorderSizePixel = 0,
		ClipsDescendants = true
	}, {
		CreateUI("UICorner", {CornerRadius = UDim.new(0, 8)}),
		CreateUI("UIStroke", {
			Color = theme.Stroke,
			Thickness = 1,
			Transparency = 0.5
		})
	})
	
	-- Title Bar
	local TitleBar = CreateUI("Frame", {
		Parent = Main,
		Size = UDim2.new(1, 0, 0, 45),
		BackgroundColor3 = theme.Second,
		BorderSizePixel = 0
	}, {
		CreateUI("UICorner", {CornerRadius = UDim.new(0, 8)}),
		CreateUI("UIStroke", {
			Color = theme.Stroke,
			Thickness = 1,
			Transparency = 0.3
		})
	})
	
	-- Window Title mit Icon
	if config.Icon then
		CreateUI("ImageLabel", {
			Parent = TitleBar,
			Position = UDim2.new(0, 15, 0.5, -12),
			Size = UDim2.new(0, 24, 0, 24),
			Image = config.Icon,
			BackgroundTransparency = 1
		})
	end
	
	CreateUI("TextLabel", {
		Parent = TitleBar,
		Position = UDim2.new(0, config.Icon and 45 or 15, 0.5, -10),
		Size = UDim2.new(0, 200, 0, 20),
		BackgroundTransparency = 1,
		Text = config.Name,
		TextColor3 = theme.Text,
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	-- Window Controls
	local ControlFrame = CreateUI("Frame", {
		Parent = TitleBar,
		Position = UDim2.new(1, -100, 0.5, -15),
		Size = UDim2.new(0, 90, 0, 30),
		BackgroundTransparency = 1
	})
	
	local MinimizeBtn = CreateUI("TextButton", {
		Parent = ControlFrame,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, 30, 1, 0),
		BackgroundTransparency = 1,
		Text = ""
	}, {
		CreateUI("ImageLabel", {
			Position = UDim2.new(0.5, -9, 0.5, -9),
			Size = UDim2.new(0, 18, 0, 18),
			Image = Icons.minimize,
			BackgroundTransparency = 1,
			ImageColor3 = theme.Text
		})
	})
	
	local CloseBtn = CreateUI("TextButton", {
		Parent = ControlFrame,
		Position = UDim2.new(0, 60, 0, 0),
		Size = UDim2.new(0, 30, 1, 0),
		BackgroundTransparency = 1,
		Text = ""
	}, {
		CreateUI("ImageLabel", {
			Position = UDim2.new(0.5, -9, 0.5, -9),
			Size = UDim2.new(0, 18, 0, 18),
			Image = Icons.close,
			BackgroundTransparency = 1,
			ImageColor3 = theme.Text
		})
	})
	
	-- Hover Effects
	local function createHover(btn, color)
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
		end)
	end
	createHover(MinimizeBtn)
	createHover(CloseBtn)
	
	-- Tabs Container
	local TabsContainer = CreateUI("Frame", {
		Parent = Main,
		Position = UDim2.new(0, 10, 0, 55),
		Size = UDim2.new(0, 150, 1, -65),
		BackgroundColor3 = theme.Second,
		BorderSizePixel = 0
	}, {
		CreateUI("UICorner", {CornerRadius = UDim.new(0, 8)}),
		CreateUI("UIStroke", {
			Color = theme.Stroke,
			Thickness = 1,
			Transparency = 0.3
		}),
		CreateUI("ScrollingFrame", {
			Name = "TabList",
			Position = UDim2.new(0, 5, 0, 5),
			Size = UDim2.new(1, -10, 1, -10),
			BackgroundTransparency = 1,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = theme.Accent,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y
		}, {
			CreateUI("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 5)
			})
		})
	})
	
	-- Content Container
	local ContentContainer = CreateUI("Frame", {
		Parent = Main,
		Position = UDim2.new(0, 170, 0, 55),
		Size = UDim2.new(1, -180, 1, -65),
		BackgroundColor3 = theme.Second,
		BorderSizePixel = 0
	}, {
		CreateUI("UICorner", {CornerRadius = UDim.new(0, 8)}),
		CreateUI("UIStroke", {
			Color = theme.Stroke,
			Thickness = 1,
			Transparency = 0.3
		})
	})
	
	AddDragging(TitleBar, Main, MainShadow)
	
	-- Window Controls Logic
	CloseBtn.MouseButton1Click:Connect(function()
		windowVisible = false
		Main.Visible = false
		MainShadow.Visible = false
		ModernLib:Notify({
			Title = "UI Hidden",
			Content = "Press " .. config.Keybind.Name .. " to reopen",
			Duration = 3,
			Type = "info"
		})
	end)
	
	AddConnection(UserInputService.InputBegan, function(input)
		if input.KeyCode == config.Keybind and not windowVisible then
			windowVisible = true
			Main.Visible = true
			MainShadow.Visible = true
		end
	end)
	
	MinimizeBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			TweenService:Create(Main, TweenInfo.new(0.3), {Size = UDim2.new(0, 700, 0, 45)}):Play()
			TweenService:Create(MainShadow, TweenInfo.new(0.3), {Size = UDim2.new(0, 700, 0, 45)}):Play()
			TabsContainer.Visible = false
			ContentContainer.Visible = false
		else
			TweenService:Create(Main, TweenInfo.new(0.3), {Size = config.Size}):Play()
			TweenService:Create(MainShadow, TweenInfo.new(0.3), {Size = config.Size}):Play()
			task.wait(0.1)
			TabsContainer.Visible = true
			ContentContainer.Visible = true
		end
	end)
	
	-- Tab System
	local tabs = {}
	local currentTab = nil
	
	function tabs:CreateTab(name, icon)
		local tabBtn = CreateUI("TextButton", {
			Parent = TabsContainer.TabList,
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundColor3 = theme.Third,
			BackgroundTransparency = 0.7,
			BorderSizePixel = 0,
			Text = ""
		}, {
			CreateUI("UICorner", {CornerRadius = UDim.new(0, 6)}),
			CreateUI("ImageLabel", {
				Name = "Icon",
				Position = UDim2.new(0, 10, 0.5, -10),
				Size = UDim2.new(0, 20, 0, 20),
				Image = Icons[icon] or icon,
				BackgroundTransparency = 1,
				ImageColor3 = theme.Text
			}),
			CreateUI("TextLabel", {
				Name = "Title",
				Position = UDim2.new(0, 35, 0, 0),
				Size = UDim2.new(1, -40, 1, 0),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = theme.Text,
				TextSize = 14,
				Font = Enum.Font.GothamSemibold,
				TextXAlignment = Enum.TextXAlignment.Left
			})
		})
		
		local tabContent = CreateUI("ScrollingFrame", {
			Parent = ContentContainer,
			Size = UDim2.new(1, -20, 1, -20),
			Position = UDim2.new(0, 10, 0, 10),
			BackgroundTransparency = 1,
			ScrollBarThickness = 5,
			ScrollBarImageColor3 = theme.Accent,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false
		}, {
			CreateUI("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8)
			}),
			CreateUI("UIPadding", {
				PaddingLeft = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
				PaddingTop = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 5)
			})
		})
		
		tabBtn.MouseButton1Click:Connect(function()
			if currentTab then
				currentTab.Visible = false
				for _, btn in ipairs(TabsContainer.TabList:GetChildren()) do
					if btn:IsA("TextButton") then
						btn.BackgroundTransparency = 0.7
					end
				end
			end
			tabBtn.BackgroundTransparency = 0
			tabContent.Visible = true
			currentTab = tabContent
		end)
		
		if not currentTab then
			tabBtn.BackgroundTransparency = 0
			tabContent.Visible = true
			currentTab = tabContent
		end
		
		-- Element Creation Functions
		local elements = {}
		
		function elements:AddButton(text, callback)
			local btn = CreateUI("TextButton", {
				Parent = tabContent,
				Size = UDim2.new(1, 0, 0, 35),
				BackgroundColor3 = theme.Third,
				BorderSizePixel = 0,
				Text = ""
			}, {
				CreateUI("UICorner", {CornerRadius = UDim.new(0, 6)}),
				CreateUI("TextLabel", {
					Position = UDim2.new(0, 12, 0.5, -10),
					Size = UDim2.new(1, -24, 0, 20),
					BackgroundTransparency = 1,
					Text = text,
					TextColor3 = theme.Text,
					TextSize = 15,
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Left
				})
			})
			
			btn.MouseButton1Click:Connect(callback)
			
			btn.MouseEnter:Connect(function()
				TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(
					theme.Third.R * 255 + 20,
					theme.Third.G * 255 + 20,
					theme.Third.B * 255 + 20
				)}):Play()
			end)
			
			btn.MouseLeave:Connect(function()
				TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = theme.Third}):Play()
			end)
			
			return btn
		end
		
		function elements:AddToggle(config)
			config = config or {}
			config.Title = config.Title or "Toggle"
			config.Default = config.Default or false
			config.Callback = config.Callback or function() end
			
			local toggle = {Value = config.Default}
			
			local frame = CreateUI("Frame", {
				Parent = tabContent,
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = theme.Third,
				BorderSizePixel = 0
			}, {
				CreateUI("UICorner", {CornerRadius = UDim.new(0, 6)}),
				CreateUI("TextLabel", {
					Position = UDim2.new(0, 12, 0.5, -10),
					Size = UDim2.new(0.8, -12, 0, 20),
					BackgroundTransparency = 1,
					Text = config.Title,
					TextColor3 = theme.Text,
					TextSize = 15,
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Left
				})
			})
			
			local toggleBtn = CreateUI("TextButton", {
				Parent = frame,
				Position = UDim2.new(1, -35, 0.5, -12),
				Size = UDim2.new(0, 24, 0, 24),
				BackgroundColor3 = config.Default and theme.Success or theme.Stroke,
				BorderSizePixel = 0,
				Text = ""
			}, {
				CreateUI("UICorner", {CornerRadius = UDim.new(0, 6)}),
				CreateUI("ImageLabel", {
					Position = UDim2.new(0.5, -8, 0.5, -8),
					Size = UDim2.new(0, 16, 0, 16),
					Image = Icons.check,
					BackgroundTransparency = 1,
					ImageColor3 = theme.Text,
					ImageTransparency = config.Default and 0 or 1
				})
			})
			
			function toggle:Set(value)
				toggle.Value = value
				TweenService:Create(toggleBtn, TweenInfo.new(0.2), {
					BackgroundColor3 = value and theme.Success or theme.Stroke
				}):Play()
				TweenService:Create(toggleBtn.ImageLabel, TweenInfo.new(0.2), {
					ImageTransparency = value and 0 or 1
				}):Play()
				config.Callback(value)
			end
			
			toggleBtn.MouseButton1Click:Connect(function()
				toggle:Set(not toggle.Value)
			end)
			
			if config.Flag then
				ModernLib.Flags[config.Flag] = toggle
			end
			
			return toggle
		end
		
		function elements:AddSlider(config)
			config = config or {}
			config.Title = config.Title or "Slider"
			config.Min = config.Min or 0
			config.Max = config.Max or 100
			config.Default = config.Default or 50
			config.Unit = config.Unit or ""
			config.Callback = config.Callback or function() end
			
			local slider = {Value = config.Default}
			local dragging = false
			
			local frame = CreateUI("Frame", {
				Parent = tabContent,
				Size = UDim2.new(1, 0, 0, 70),
				BackgroundColor3 = theme.Third,
				BorderSizePixel = 0
			}, {
				CreateUI("UICorner", {CornerRadius = UDim.new(0, 6)}),
				CreateUI("TextLabel", {
					Position = UDim2.new(0, 12, 0, 10),
					Size = UDim2.new(1, -24, 0, 20),
					BackgroundTransparency = 1,
					Text = config.Title,
					TextColor3 = theme.Text,
					TextSize = 15,
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Left
				}),
				CreateUI("Frame", {
					Name = "SliderBar",
					Position = UDim2.new(0, 12, 0, 40),
					Size = UDim2.new(1, -24, 0, 20),
					BackgroundColor3 = theme.Stroke,
					BorderSizePixel = 0
				}, {
					CreateUI("UICorner", {CornerRadius = UDim.new(0, 4)}),
					CreateUI("Frame", {
						Name = "Fill",
						Size = UDim2.new((config.Default - config.Min) / (config.Max - config.Min), 0, 1, 0),
						BackgroundColor3 = theme.Accent,
						BorderSizePixel = 0
					}, {
						CreateUI("UICorner", {CornerRadius = UDim.new(0, 4)}),
						CreateUI("TextLabel", {
							Name = "Value",
							Position = UDim2.new(1, 5, 0, 0),
							Size = UDim2.new(0, 50, 1, 0),
							BackgroundTransparency = 1,
							Text = config.Default .. config.Unit,
							TextColor3 = theme.Text,
							TextSize = 12,
							Font = Enum.Font.Gotham,
							TextXAlignment = Enum.TextXAlignment.Left
						})
					})
				})
			})
			
			local sliderBar = frame.SliderBar
			local fill = sliderBar.Fill
			
			local function updateSlider(input)
				if not dragging then return end
				local pos = UDim2.new(
					math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1),
					0,
					1,
					0
				)
				fill.Size = pos
				local value = config.Min + ((config.Max - config.Min) * pos.X.Scale)
				value = math.floor(value * 100) / 100
				fill.Value.Text = value .. config.Unit
				slider.Value = value
				config.Callback(value)
			end
			
			sliderBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					updateSlider(input)
				end
			end)
			
			sliderBar.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)
			
			AddConnection(UserInputService.InputChanged, function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					updateSlider(input)
				end
			end)
			
			function slider:Set(value)
				value = math.clamp(value, config.Min, config.Max)
				local scale = (value - config.Min) / (config.Max - config.Min)
				fill.Size = UDim2.new(scale, 0, 1, 0)
				fill.Value.Text = value .. config.Unit
				slider.Value = value
				config.Callback(value)
			end
			
			if config.Flag then
				ModernLib.Flags[config.Flag] = slider
			end
			
			return slider
		end
		
		function elements:AddDropdown(config)
			config = config or {}
			config.Title = config.Title or "Dropdown"
			config.Options = config.Options or {}
			config.Default = config.Default or ""
			config.Callback = config.Callback or function() end
			
			local dropdown = {Value = config.Default, Open = false}
			
			local frame = CreateUI("Frame", {
				Parent = tabContent,
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = theme.Third,
				BorderSizePixel = 0,
				ClipsDescendants = true
			}, {
				CreateUI("UICorner", {CornerRadius = UDim.new(0, 6)}),
				CreateUI("TextLabel", {
					Position = UDim2.new(0, 12, 0.5, -10),
					Size = UDim2.new(0.7, -12, 0, 20),
					BackgroundTransparency = 1,
					Text = config.Title,
					TextColor3 = theme.Text,
					TextSize = 15,
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Left
				}),
				CreateUI("TextLabel", {
					Name = "Selected",
					Position = UDim2.new(0.7, 0, 0.5, -10),
					Size = UDim2.new(0.2, -24, 0, 20),
					BackgroundTransparency = 1,
					Text = config.Default,
					TextColor3 = theme.TextDark,
					TextSize = 13,
					Font = Enum.Font.Gotham,
					TextXAlignment = Enum.TextXAlignment.Right
				}),
				CreateUI("ImageLabel", {
					Position = UDim2.new(0.9, -10, 0.5, -8),
					Size = UDim2.new(0, 16, 0, 16),
					Image = Icons.chevron_down,
					BackgroundTransparency = 1,
					ImageColor3 = theme.TextDark
				}),
				CreateUI("ScrollingFrame", {
					Name = "Options",
					Position = UDim2.new(0, 0, 0, 40),
					Size = UDim2.new(1, 0, 0, 0),
					BackgroundTransparency = 1,
					ScrollBarThickness = 3,
					ScrollBarImageColor3 = theme.Accent,
					Visible = false
				}, {
					CreateUI("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 2)
					}),
					CreateUI("UIPadding", {
						PaddingLeft = UDim.new(0, 5),
						PaddingRight = UDim.new(0, 5),
						PaddingBottom = UDim.new(0, 5)
					})
				})
			})
			
			local optionsFrame = frame.Options
			
			for _, option in ipairs(config.Options) do
				local btn = CreateUI("TextButton", {
					Parent = optionsFrame,
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundColor3 = theme.Second,
					BackgroundTransparency = 0.5,
					BorderSizePixel = 0,
					Text = ""
				}, {
					CreateUI("UICorner", {CornerRadius = UDim.new(0, 4)}),
					CreateUI("TextLabel", {
						Position = UDim2.new(0, 8, 0.5, -8),
						Size = UDim2.new(1, -16, 0, 16),
						BackgroundTransparency = 1,
						Text = option,
						TextColor3 = theme.Text,
						TextSize = 13,
						Font = Enum.Font.Gotham,
						TextXAlignment = Enum.TextXAlignment.Left
					})
				})
				
				btn.MouseButton1Click:Connect(function()
					frame.Selected.Text = option
					dropdown.Value = option
					config.Callback(option)
					toggleDropdown()
				end)
			end
			
			local function toggleDropdown()
				dropdown.Open = not dropdown.Open
				local targetSize = dropdown.Open and UDim2.new(1, 0, 0, 40 + math.min(#config.Options * 32, 150)) or UDim2.new(1, 0, 0, 40)
				TweenService:Create(frame, TweenInfo.new(0.2), {Size = targetSize}):Play()
				TweenService:Create(frame.ImageLabel, TweenInfo.new(0.2), {
					Rotation = dropdown.Open and 180 or 0
				}):Play()
				optionsFrame.Visible = dropdown.Open
			end
			
			frame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					toggleDropdown()
				end
			end)
			
			function dropdown:Set(value)
				if table.find(config.Options, value) then
					frame.Selected.Text = value
					dropdown.Value = value
					config.Callback(value)
				end
			end
			
			function dropdown:Refresh(newOptions)
				config.Options = newOptions
				for _, child in ipairs(optionsFrame:GetChildren()) do
					if child:IsA("TextButton") then
						child:Destroy()
					end
				end
				for _, option in ipairs(newOptions) do
					-- Recreate buttons
				end
			end
			
			if config.Flag then
				ModernLib.Flags[config.Flag] = dropdown
			end
			
			return dropdown
		end
		
		return elements
	end
	
	return tabs
end

-- Verbessertes Notification System
function ModernLib:Notify(config)
	config = config or {}
	config.Title = config.Title or "Notification"
	config.Content = config.Content or ""
	config.Duration = config.Duration or 5
	config.Type = config.Type or "info" -- info, success, warning, error
	
	local theme = ModernLib.Themes[ModernLib.SelectedTheme]
	local colors = {
		info = theme.Accent,
		success = theme.Success,
		warning = theme.Warning,
		error = theme.Danger
	}
	
	local notifFrame = CreateUI("Frame", {
		Parent = Modern,
		Position = UDim2.new(1, 320, 0, 30),
		Size = UDim2.new(0, 300, 0, 0),
		BackgroundColor3 = theme.Second,
		BorderSizePixel = 0,
		ClipsDescendants = true
	}, {
		CreateUI("UICorner", {CornerRadius = UDim.new(0, 8)}),
		CreateUI("UIStroke", {
			Color = colors[config.Type],
			Thickness = 2
		}),
		CreateUI("Frame", {
			Name = "Progress",
			Position = UDim2.new(0, 0, 1, -3),
			Size = UDim2.new(1, 0, 0, 3),
			BackgroundColor3 = colors[config.Type],
			BorderSizePixel = 0
		}, {
			CreateUI("UICorner", {CornerRadius = UDim.new(0, 3)})
		}),
		CreateUI("TextLabel", {
			Position = UDim2.new(0, 15, 0, 15),
			Size = UDim2.new(1, -30, 0, 20),
			BackgroundTransparency = 1,
			Text = config.Title,
			TextColor3 = colors[config.Type],
			TextSize = 16,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left
		}),
		CreateUI("TextLabel", {
			Position = UDim2.new(0, 15, 0, 40),
			Size = UDim2.new(1, -30, 0, 0),
			BackgroundTransparency = 1,
			Text = config.Content,
			TextColor3 = theme.Text,
			TextSize = 13,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			AutomaticSize = Enum.AutomaticSize.Y
		})
	})
	
	local textSize = notifFrame:FindFirstChildOfClass("TextLabel").TextBounds.Y
	notifFrame.Size = UDim2.new(0, 300, 0, textSize + 55)
	
	-- Animation
	TweenService:Create(notifFrame, TweenInfo.new(0.5), {Position = UDim2.new(1, -320, 0, 30)}):Play()
	
	-- Progress bar animation
	local progress = notifFrame.Progress
	TweenService:Create(progress, TweenInfo.new(config.Duration), {Size = UDim2.new(0, 0, 0, 3)}):Play()
	
	task.wait(config.Duration)
	
	-- Fade out
	TweenService:Create(notifFrame, TweenInfo.new(0.3), {
		Position = UDim2.new(1, 320, 0, 30),
		BackgroundTransparency = 1
	}):Play()
	
	task.wait(0.3)
	notifFrame:Destroy()
end

function ModernLib:SetTheme(theme)
	if ModernLib.Themes[theme] then
		ModernLib.SelectedTheme = theme
		-- Update all theme objects
	end
end

function ModernLib:Destroy()
	for _, conn in ipairs(self.Connections) do
		conn:Disconnect()
	end
	Modern:Destroy()
end

return ModernLib
