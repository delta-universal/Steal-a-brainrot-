--[[
    🌸 XENHUB V5 — Pantalla de carga + Xenhub Joiner
    Hecho para Delta (móvil / PC). Pegar y ejecutar.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

---------------------------------------------------------------------
-- CONFIG
---------------------------------------------------------------------
local LOAD_TIME = 15       -- segundos de la pantalla de carga
local JOIN_TIME = 5        -- segundos de la animación del botón Joiner
local FEED_INTERVAL = 1    -- cada cuánto entra un Brainrot nuevo
local MAX_ROWS = 50        -- máximo de filas en la lista

local PINK   = Color3.fromRGB(255, 105, 180)
local PINK_L = Color3.fromRGB(255, 170, 214)
local WHITE  = Color3.fromRGB(255, 255, 255)
local BLACK  = Color3.fromRGB(0, 0, 0)
local BG     = Color3.fromRGB(14, 10, 16)
local BG2    = Color3.fromRGB(27, 19, 29)
local MUTED  = Color3.fromRGB(182, 152, 174)

local ES, ED = Enum.EasingStyle, Enum.EasingDirection
local rng = Random.new()

---------------------------------------------------------------------
-- DATOS (nombres conocidos + inventados)
---------------------------------------------------------------------
local NAMES = {
    "Dragón Canelloni", "Capitano Moby", "La Grande Combinasion", "Garama and Madundung",
    "Los Combinasionas", "Nuclearo Dinossauro", "Chicleteira Bicicleteira", "Graipuss Medussi",
    "Strawberry Elephant", "Ballerina Cappuccina", "Tung Tung Tung Sahur", "Tralalero Tralala",
    "Bombardiro Crocodilo", "Brr Brr Patapim", "Cappuccino Assassino", "Chimpanzini Bananini",
    "Trippi Troppi", "Frigo Camelo", "Orcalero Orcala", "La Vacca Saturno Saturnita",
    "Los Tralaleritos", "Las Tralaleritas", "Torrtuginni Dragonfrutini", "Odin Din Din Dun",
    "Spaghetti Tualetti", "Ketupat Kepat", "Ganganzelli Trulala", "Cocofanto Elefanto",
    "Girafa Celestre", "Glorbo Fruttodrillo", "Zibra Zubra Zibralini", "Blueberrinni Octopussini",
    "Pingüino Espagueti", "Sandía Turbo Sahur", "Cangrejo Mafioso", "Tostadora Cósmica",
    "Llama Spaghettini", "Burrito Bandito Supremo", "Mango Rinoceronte", "Pizzarino Volador",
    "Gallina Nuclearini", "Tiburón Tostadini", "Abuelo Mozzarello", "Koala Karaokini",
}
local VALUES = { "$15M/s", "$50M/s", "$120M/s", "$240M/s", "$500M/s", "$1B/s", "$2.5B/s", "$10B/s" }

local lastName
local function pickEntry()
    local name
    repeat
        name = NAMES[rng:NextInteger(1, #NAMES)]
    until name ~= lastName
    lastName = name
    return {
        name = name,
        value = VALUES[rng:NextInteger(1, #VALUES)],
        players = rng:NextInteger(1, 8),
    }
end

---------------------------------------------------------------------
-- UTILIDADES
---------------------------------------------------------------------
local function new(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then
        inst.Parent = parent
    end
    return inst
end

local function corner(parent, radius)
    return new("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function stroke(parent, color, thickness, transparency)
    return new("UIStroke", {
        Color = color,
        Thickness = thickness,
        Transparency = transparency,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function ti(time, style, dir, ...)
    return TweenInfo.new(time, style or ES.Quad, dir or ED.Out, ...)
end

local function tween(inst, info, props)
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end

local function mount(gui)
    local target
    pcall(function()
        if gethui then
            target = gethui()
        end
    end)
    if not target then
        pcall(function()
            target = game:GetService("CoreGui")
        end)
    end

    local ok = false
    if target then
        ok = pcall(function()
            gui.Parent = target
        end)
    end
    if not ok or not gui.Parent then
        gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
end

local function destroyOld(names)
    local places = {}
    pcall(function()
        if gethui then
            table.insert(places, gethui())
        end
    end)
    pcall(function()
        table.insert(places, game:GetService("CoreGui"))
    end)
    pcall(function()
        table.insert(places, Players.LocalPlayer:WaitForChild("PlayerGui"))
    end)
    for _, place in ipairs(places) do
        for _, name in ipairs(names) do
            local old = place:FindFirstChild(name)
            if old then
                pcall(function()
                    old:Destroy()
                end)
            end
        end
    end
end

---------------------------------------------------------------------
-- 1) PANTALLA DE CARGA
---------------------------------------------------------------------
local function runLoading()
    local gui = new("ScreenGui", {
        Name = "XenhubV5_Loading",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 999999,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    pcall(function()
        gui.ScreenInsets = Enum.ScreenInsets.None
    end)
    mount(gui)

    local root = new("CanvasGroup", {
        Name = "Root",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = BLACK,
        BorderSizePixel = 0,
        GroupTransparency = 0,
    }, gui)

    local flowerLayer = new("Frame", {
        Name = "Flowers",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, root)

    local content = new("Frame", {
        Name = "Content",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, root)
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 14),
    }, content)

    -- Título con degradado rosa/blanco animado
    local title = new("TextLabel", {
        Name = "Title",
        LayoutOrder = 1,
        Size = UDim2.new(0.9, 0, 0, 64),
        BackgroundTransparency = 1,
        Text = "Xenhub V5",
        Font = Enum.Font.GothamBlack,
        TextScaled = true,
        TextColor3 = WHITE,
    }, content)
    new("UITextSizeConstraint", { MinTextSize = 22, MaxTextSize = 60 }, title)
    local titleGrad = new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, PINK),
            ColorSequenceKeypoint.new(0.5, WHITE),
            ColorSequenceKeypoint.new(1, PINK),
        }),
        Offset = Vector2.new(-1, 0),
    }, title)
    local gradTween = tween(titleGrad, TweenInfo.new(2.4, ES.Linear, ED.Out, -1), {
        Offset = Vector2.new(1, 0),
    })

    -- Barra de progreso
    local barHolder = new("Frame", {
        Name = "BarHolder",
        LayoutOrder = 2,
        Size = UDim2.new(0.6, 0, 0, 12),
        BackgroundTransparency = 1,
    }, content)
    new("UISizeConstraint", {
        MinSize = Vector2.new(200, 12),
        MaxSize = Vector2.new(480, 12),
    }, barHolder)

    local track = new("Frame", {
        Name = "Track",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(28, 20, 30),
        BorderSizePixel = 0,
    }, barHolder)
    corner(track, 6)
    stroke(track, PINK, 1, 0.55)

    local fill = new("Frame", {
        Name = "Fill",
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = WHITE,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, track)
    corner(fill, 6)
    new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, PINK),
            ColorSequenceKeypoint.new(0.6, PINK_L),
            ColorSequenceKeypoint.new(1, WHITE),
        }),
    }, fill)

    local shine = new("Frame", {
        Name = "Shine",
        Size = UDim2.fromScale(0.45, 1),
        Position = UDim2.fromScale(-0.5, 0),
        BackgroundColor3 = WHITE,
        BorderSizePixel = 0,
    }, fill)
    new("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0.35),
            NumberSequenceKeypoint.new(1, 1),
        }),
    }, shine)
    local shineTween = tween(shine, TweenInfo.new(1.2, ES.Sine, ED.InOut, -1, false, 0.2), {
        Position = UDim2.fromScale(1.05, 0),
    })

    local pct = new("TextLabel", {
        Name = "Percent",
        LayoutOrder = 3,
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        Text = "0%",
        Font = Enum.Font.GothamMedium,
        TextSize = 16,
        TextColor3 = PINK_L,
    }, content)

    -- Flores 🌸
    local running = true
    local active = 0
    local MAX_FLOWERS = 28

    local function spawnFlower()
        local cam = workspace.CurrentCamera
        local vp = cam and cam.ViewportSize or Vector2.new(800, 400)
        local minDim = math.min(vp.X, vp.Y)

        local depth = rng:NextNumber() ^ 1.5 -- más flores pequeñas que grandes
        local size = math.clamp(math.floor(minDim * (0.035 + depth * 0.15)), 14, 100)
        local life = math.max(3, 7 - depth * 3 + rng:NextNumber(-0.5, 1))
        local peak = 0.6 - depth * 0.5 -- las grandes se ven más
        local x0, y0 = rng:NextNumber(0.02, 0.98), rng:NextNumber(0.02, 0.98)
        local dx, dy = rng:NextNumber(-0.2, 0.2), rng:NextNumber(-0.28, 0.28)
        local rot0 = rng:NextNumber(-30, 30)

        local f = new("TextLabel", {
            Text = "🌸",
            Font = Enum.Font.GothamBold,
            TextSize = size,
            TextColor3 = WHITE,
            TextTransparency = 1,
            Size = UDim2.fromOffset(size * 1.6, size * 1.6),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(x0, y0),
            Rotation = rot0,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        }, flowerLayer)

        active = active + 1
        local fade = life * 0.3

        tween(f, TweenInfo.new(life, ES.Sine, ED.InOut), {
            Position = UDim2.fromScale(x0 + dx, y0 + dy),
            Rotation = rot0 + rng:NextNumber(-45, 45),
        })
        tween(f, TweenInfo.new(fade, ES.Sine, ED.Out), { TextTransparency = peak })

        task.delay(life - fade, function()
            if f.Parent then
                tween(f, TweenInfo.new(fade, ES.Sine, ED.In), { TextTransparency = 1 })
            end
        end)
        task.delay(life + 0.1, function()
            active = active - 1
            f:Destroy()
        end)
    end

    task.spawn(function()
        while running do
            if active < MAX_FLOWERS then
                spawnFlower()
            end
            task.wait(rng:NextNumber(0.08, 0.2))
        end
    end)

    -- Progreso real (lineal) durante LOAD_TIME segundos
    local startT = os.clock()
    local lastPct = -1
    local finished = false
    local conn
    conn = RunService.Heartbeat:Connect(function()
        local p = math.clamp((os.clock() - startT) / LOAD_TIME, 0, 1)
        fill.Size = UDim2.new(p, 0, 1, 0)
        local n = math.floor(p * 100 + 0.5)
        if n ~= lastPct then
            lastPct = n
            pct.Text = n .. "%"
        end
        if p >= 1 then
            conn:Disconnect()
            finished = true
        end
    end)

    repeat
        task.wait()
    until finished

    task.wait(0.25)

    -- Salida suave
    local out = tween(root, ti(0.8, ES.Sine, ED.InOut), { GroupTransparency = 1 })
    out.Completed:Wait()

    running = false
    gradTween:Cancel()
    shineTween:Cancel()
    gui:Destroy()
end

---------------------------------------------------------------------
-- 2) PANEL XENHUB JOINER
---------------------------------------------------------------------
local function buildMain()
    local gui = new("ScreenGui", {
        Name = "XenhubV5_Main",
        ResetOnSpawn = false,
        DisplayOrder = 999998,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    mount(gui)

    local alive, minimized, animating = true, false, false
    local conns = {}
    gui.Destroying:Connect(function()
        alive = false
        for _, c in ipairs(conns) do
            pcall(function()
                c:Disconnect()
            end)
        end
    end)

    -- Panel
    local panel = new("Frame", {
        Name = "Panel",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.56, 0.8),
        BackgroundColor3 = BG,
        BorderSizePixel = 0,
    }, gui)
    new("UISizeConstraint", {
        MinSize = Vector2.new(300, 240),
        MaxSize = Vector2.new(480, 390),
    }, panel)
    corner(panel, 16)
    stroke(panel, PINK, 1.5, 0.1)
    new("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new(Color3.fromRGB(25, 16, 27), Color3.fromRGB(11, 8, 13)),
    }, panel)
    local panelScale = new("UIScale", { Scale = 0 }, panel)

    -- Cabecera
    local header = new("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundTransparency = 1,
        Active = true,
    }, panel)

    new("TextLabel", {
        Position = UDim2.fromOffset(16, 7),
        Size = UDim2.new(1, -70, 0, 22),
        BackgroundTransparency = 1,
        RichText = true,
        Text = 'Xenhub <font color="#FF69B4">Joiner</font>',
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = WHITE,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, header)

    local dot = new("Frame", {
        Position = UDim2.fromOffset(17, 35),
        Size = UDim2.fromOffset(7, 7),
        BackgroundColor3 = PINK,
        BorderSizePixel = 0,
    }, header)
    corner(dot, 4)
    tween(dot, TweenInfo.new(0.9, ES.Sine, ED.InOut, -1, true), { BackgroundTransparency = 0.7 })

    new("TextLabel", {
        Position = UDim2.fromOffset(30, 29),
        Size = UDim2.new(1, -90, 0, 18),
        BackgroundTransparency = 1,
        Text = "En vivo",
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = PINK_L,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, header)

    local minBtn = new("TextButton", {
        Name = "Minimize",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 12),
        Size = UDim2.fromOffset(28, 28),
        BackgroundColor3 = BG2,
        AutoButtonColor = false,
        Text = "—",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = WHITE,
        BorderSizePixel = 0,
    }, header)
    corner(minBtn, 8)
    stroke(minBtn, PINK, 1, 0.55)

    new("Frame", {
        Position = UDim2.fromOffset(12, 52),
        Size = UDim2.new(1, -24, 0, 1),
        BackgroundColor3 = PINK,
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
    }, panel)

    -- Subcabecera de la lista
    new("TextLabel", {
        Position = UDim2.fromOffset(16, 60),
        Size = UDim2.new(0.5, -16, 0, 16),
        BackgroundTransparency = 1,
        Text = "LIVE FEED",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = PINK,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, panel)

    local countLabel = new("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -16, 0, 60),
        Size = UDim2.new(0.5, -16, 0, 16),
        BackgroundTransparency = 1,
        Text = "0 detectados",
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextColor3 = MUTED,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, panel)

    -- Lista con scroll
    local list = new("ScrollingFrame", {
        Name = "List",
        Position = UDim2.fromOffset(10, 82),
        Size = UDim2.new(1, -20, 1, -92),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = PINK,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, panel)
    new("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
    }, list)
    new("UIPadding", { PaddingRight = UDim.new(0, 6) }, list)

    -- Seguir el final de la lista solo si el usuario ya estaba abajo
    local followUntil = 0
    table.insert(conns, RunService.RenderStepped:Connect(function()
        if os.clock() < followUntil then
            local maxY = math.max(0, list.AbsoluteCanvasSize.Y - list.AbsoluteWindowSize.Y)
            list.CanvasPosition = Vector2.new(0, maxY)
        end
    end))

    ---------------------------------------------------------------
    -- Filas
    ---------------------------------------------------------------
    local WRAP_H, ROW_H = 60, 52
    local seq, detected = 0, 0
    local entries = {}

    local function addRow(instant)
        seq = seq + 1
        detected = detected + 1
        countLabel.Text = detected .. " detectados"
        local d = pickEntry()

        local wasAtBottom = list.CanvasPosition.Y >= list.AbsoluteCanvasSize.Y - list.AbsoluteWindowSize.Y - 24

        local wrapper = new("Frame", {
            Name = "Entry",
            LayoutOrder = seq,
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Size = UDim2.new(1, 0, 0, instant and WRAP_H or 0),
        }, list)

        local row = new("Frame", {
            Name = "Row",
            Position = UDim2.new(instant and 0 or 0.25, 1, 0, 1),
            Size = UDim2.new(1, -2, 0, ROW_H),
            BackgroundColor3 = BG2,
            BorderSizePixel = 0,
        }, wrapper)
        corner(row, 10)
        local rowStroke = stroke(row, PINK, 1, 0.75)

        local accent = new("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 9, 0.5, 0),
            Size = UDim2.fromOffset(3, 30),
            BackgroundColor3 = PINK,
            BorderSizePixel = 0,
        }, row)
        corner(accent, 2)

        new("TextLabel", {
            Position = UDim2.fromOffset(22, 7),
            Size = UDim2.new(1, -128, 0, 20),
            BackgroundTransparency = 1,
            Text = d.name,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextColor3 = WHITE,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, row)

        local baseSub = string.format(
            '<font color="#FF8FC7">%s</font>  ·  Jugadores: %d/8',
            d.value,
            d.players
        )
        local sub = new("TextLabel", {
            Position = UDim2.fromOffset(22, 28),
            Size = UDim2.new(1, -128, 0, 16),
            BackgroundTransparency = 1,
            RichText = true,
            Text = baseSub,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextColor3 = MUTED,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, row)

        local btn = new("TextButton", {
            Name = "Joiner",
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -10, 0.5, -2),
            Size = UDim2.fromOffset(92, 30),
            BackgroundColor3 = PINK,
            AutoButtonColor = false,
            Text = "Joiner",
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = WHITE,
            BorderSizePixel = 0,
        }, row)
        corner(btn, 8)
        local btnScale = new("UIScale", { Scale = 1 }, btn)

        -- Barra de progreso de la animación de 5 segundos
        local jTrack = new("Frame", {
            Visible = false,
            Position = UDim2.new(0, 12, 1, -7),
            Size = UDim2.new(1, -24, 0, 3),
            BackgroundColor3 = PINK,
            BackgroundTransparency = 0.8,
            BorderSizePixel = 0,
        }, row)
        corner(jTrack, 2)
        local jFill = new("Frame", {
            Size = UDim2.fromScale(0, 1),
            BackgroundColor3 = WHITE,
            BorderSizePixel = 0,
        }, jTrack)
        corner(jFill, 2)
        new("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, PINK),
                ColorSequenceKeypoint.new(1, WHITE),
            }),
        }, jFill)

        local busy = false

        btn.MouseEnter:Connect(function()
            if not busy then
                tween(btn, ti(0.15), { BackgroundColor3 = PINK_L })
            end
        end)
        btn.MouseLeave:Connect(function()
            if not busy then
                tween(btn, ti(0.15), { BackgroundColor3 = PINK })
            end
            tween(btnScale, ti(0.1), { Scale = 1 })
        end)
        btn.MouseButton1Down:Connect(function()
            tween(btnScale, ti(0.08), { Scale = 0.93 })
        end)
        btn.MouseButton1Up:Connect(function()
            tween(btnScale, ti(0.12), { Scale = 1 })
        end)

        btn.Activated:Connect(function()
            if busy then
                return
            end
            busy = true

            task.spawn(function()
                -- Estado "procesando"
                tween(btn, ti(0.2), { BackgroundColor3 = Color3.fromRGB(66, 34, 58) })
                btn.TextColor3 = PINK_L
                sub.Text = '<font color="#FFB6DC">Uniendo a ' .. d.name .. "…</font>"
                jTrack.Visible = true
                jFill.Size = UDim2.fromScale(0, 1)
                tween(jFill, TweenInfo.new(JOIN_TIME, ES.Linear), { Size = UDim2.fromScale(1, 1) })
                tween(rowStroke, ti(0.2), { Transparency = 0.1 })
                tween(accent, ti(0.2), { BackgroundColor3 = WHITE })

                local t0 = os.clock()
                local step = 0
                while os.clock() - t0 < JOIN_TIME do
                    if not row.Parent then
                        return
                    end
                    btn.Text = "Uniendo" .. string.rep(".", step % 3 + 1)
                    step = step + 1
                    task.wait(0.3)
                end

                if not row.Parent then
                    return
                end

                -- Volver a la normalidad
                btn.Text = "Joiner"
                btn.TextColor3 = WHITE
                sub.Text = baseSub
                jTrack.Visible = false
                tween(btn, ti(0.2), { BackgroundColor3 = PINK })
                tween(rowStroke, ti(0.25), { Transparency = 0.75 })
                tween(accent, ti(0.25), { BackgroundColor3 = PINK })
                busy = false
            end)
        end)

        -- Animación de entrada
        if not instant then
            tween(wrapper, ti(0.3), { Size = UDim2.new(1, 0, 0, WRAP_H) })
            tween(row, ti(0.35, ES.Quint), { Position = UDim2.new(0, 1, 0, 1) })
        end
        if wasAtBottom then
            followUntil = os.clock() + 0.5
        end

        -- Límite de filas (sin mover la vista si el usuario está leyendo arriba)
        table.insert(entries, wrapper)
        if #entries > MAX_ROWS then
            local old = table.remove(entries, 1)
            local h = old.AbsoluteSize.Y
            old:Destroy()
            if not wasAtBottom then
                list.CanvasPosition = Vector2.new(0, math.max(0, list.CanvasPosition.Y - h))
            end
        end
    end

    ---------------------------------------------------------------
    -- Minimizar / restaurar
    ---------------------------------------------------------------
    local pill = new("TextButton", {
        Name = "Restore",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 14),
        Size = UDim2.fromOffset(112, 34),
        BackgroundColor3 = BG,
        AutoButtonColor = false,
        Text = "🌸 Xenhub",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = WHITE,
        BorderSizePixel = 0,
        Visible = false,
    }, gui)
    corner(pill, 17)
    stroke(pill, PINK, 1.5, 0.1)
    local pillScale = new("UIScale", { Scale = 0 }, pill)

    local function minimize()
        if animating or minimized then
            return
        end
        animating = true
        minimized = true
        tween(panelScale, ti(0.25, ES.Back, ED.In), { Scale = 0 }).Completed:Wait()
        panel.Visible = false
        pillScale.Scale = 0
        pill.Visible = true
        tween(pillScale, ti(0.3, ES.Back, ED.Out), { Scale = 1 }).Completed:Wait()
        animating = false
    end

    local function restore()
        if animating or not minimized then
            return
        end
        animating = true
        tween(pillScale, ti(0.15, ES.Quad, ED.In), { Scale = 0 }).Completed:Wait()
        pill.Visible = false
        panel.Visible = true
        tween(panelScale, ti(0.35, ES.Back, ED.Out), { Scale = 1 }).Completed:Wait()
        minimized = false
        animating = false
    end

    minBtn.Activated:Connect(minimize)
    pill.Activated:Connect(restore)
    minBtn.MouseEnter:Connect(function()
        tween(minBtn, ti(0.15), { BackgroundColor3 = Color3.fromRGB(52, 30, 48) })
    end)
    minBtn.MouseLeave:Connect(function()
        tween(minBtn, ti(0.15), { BackgroundColor3 = BG2 })
    end)

    ---------------------------------------------------------------
    -- Arrastrar el panel desde la cabecera
    ---------------------------------------------------------------
    local dragging, dragStart, startPos = false, nil, nil

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = panel.Position
            local c
            c = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    c:Disconnect()
                end
            end)
        end
    end)

    table.insert(conns, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local scr = gui.AbsoluteSize
            local half = panel.AbsoluteSize / 2
            local cx = startPos.X.Scale * scr.X + startPos.X.Offset + delta.X
            local cy = startPos.Y.Scale * scr.Y + startPos.Y.Offset + delta.Y
            cx = math.max(half.X, math.min(cx, scr.X - half.X))
            cy = math.max(half.Y, math.min(cy, scr.Y - half.Y))
            panel.Position = UDim2.fromOffset(cx, cy)
        end
    end))

    ---------------------------------------------------------------
    -- Arranque: entrada del panel + feed en vivo
    ---------------------------------------------------------------
    for _ = 1, 3 do
        addRow(true)
    end
    tween(panelScale, ti(0.5, ES.Back, ED.Out), { Scale = 1 })

    task.spawn(function()
        while alive do
            task.wait(FEED_INTERVAL)
            if alive and not minimized then
                addRow(false)
            end
        end
    end)
end

---------------------------------------------------------------------
-- EJECUCIÓN
---------------------------------------------------------------------
destroyOld({ "XenhubV5_Loading", "XenhubV5_Main" })

local okLoad, errLoad = pcall(runLoading)
if not okLoad then
    warn("[Xenhub V5] Error en la carga: " .. tostring(errLoad))
    destroyOld({ "XenhubV5_Loading" })
end

local okMain, errMain = pcall(buildMain)
if not okMain then
    warn("[Xenhub V5] Error en el panel: " .. tostring(errMain))
end
