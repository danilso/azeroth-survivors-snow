-- AZS Snow: falling snow and snowdrifts overlay for Azeroth Survivors.
-- Written for the WoW 1.12 addon API (this, arg1, table.getn, math.mod; no '#' operator).
-- Pure screen overlay: it draws 2D frames over the game and does not touch the world or combat.
--
-- Depth illusion: every flake has a depth z (0 = far, 1 = near). Near flakes are bigger, faster,
-- brighter and react more to wind, turning and movement than far ones (parallax).
-- Movement/turning are estimated from the player's map position (GetPlayerMapPosition). If the
-- game does not report it, the snow simply falls without these effects.

local DEFAULTS = {
	on = true,       -- snow enabled
	density = 80,    -- number of snowflakes (0..5000)
	wind = 10,       -- horizontal drift, pixels per second (-150..150)
	drifts = true,   -- snowdrifts along the bottom edge
	grow = true,     -- drifts grow during a run (uses the game's read-only AZS_* API)
	height = 24,     -- drift height (4..80)
	top = false,     -- true: draw above the game's own HUD, false: below it
	depth = true,    -- parallax: snow reacts to movement and turning
	turn = 1,        -- strength of the turning effect (-3..3, negative inverts, 0 off)
	half = false,    -- false: every flake moves every frame (smoothest); true: half per frame (lighter)
};

local COLS = 64
local db = {}
local W, H = 1024, 768
local flakes = {}
local cols = {}
local active = 0

local function Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffAZS Snow|r: " .. msg);
end

local function Init()
	if type(AZSSnowDB) ~= "table" then AZSSnowDB = {}; end
	for k, v in pairs(DEFAULTS) do
		if AZSSnowDB[k] == nil then AZSSnowDB[k] = v; end
	end
	db = AZSSnowDB;
end

local root = CreateFrame("Frame", "AZSSnowFrame", UIParent);
root:SetAllPoints(UIParent);
root:SetFrameStrata("BACKGROUND");
root:EnableMouse(false);

local floor, sin = math.floor, math.sin

-- Does SetPoint on an already-set point replace it (standard behaviour)? Then ClearAllPoints is
-- not needed for every flake on every frame, which saves thousands of calls per second.
local needClear = true
do
	local probe = root:CreateTexture(nil, "OVERLAY");
	probe:SetPoint("TOPLEFT", root, "TOPLEFT", 0, 0);
	probe:SetPoint("TOPLEFT", root, "TOPLEFT", 5, -5);
	if probe.GetNumPoints and probe:GetNumPoints() == 1 then needClear = false; end
	probe:Hide();
end

---------------------------------------------------------------------
-- Snowflakes
---------------------------------------------------------------------

local function ResetFlake(f, anywhere)
	f.x = math.random() * W;
	if anywhere then
		f.y = math.random() * H;
	else
		f.y = -math.random() * 40;
	end
	local z = math.random() ^ 1.6;          -- depth: 0 = far, 1 = near (more far flakes than near)
	f.z = z;
	f.size = math.floor(2 + z * 4 + 0.5);   -- whole units: no shimmer
	f.speed = 18 + z * 85;
	f.amp = 4 + z * 18;
	f.freq = 0.7 + math.random() * 1.6;
	f.phase = math.random() * 6.28;
	f.wf = 0.3 + z * 0.9;                    -- how much wind moves it
	f.par = 0.6 + z * 0.6;                   -- how much turning moves it
	f.tex:SetWidth(f.size);
	f.tex:SetHeight(f.size);
	f.tex:SetAlpha(0.25 + z * 0.6);
end

local function SetFlakes(n)
	for i = 1, n do
		if not flakes[i] then
			local t = root:CreateTexture(nil, "OVERLAY");
			t:SetTexture(1, 1, 1, 1);
			flakes[i] = { tex = t };
			ResetFlake(flakes[i], true);
		elseif i > active then
			ResetFlake(flakes[i], true);
		end
		flakes[i].tex:Show();
	end
	for i = n + 1, table.getn(flakes) do
		flakes[i].tex:Hide();
	end
	active = n;
end

---------------------------------------------------------------------
-- Snowdrifts
---------------------------------------------------------------------

-- Size of the screen in the units that offsets on our frame use. UIParent:GetWidth() is in
-- UIParent's units; if the frame scales differ, convert so the field covers the whole screen.
local function ScreenSize()
	-- Offsets on this frame are in the same units as its GetLeft/GetRight/GetTop/GetBottom
	-- (measured with /snow debug: 2133x1200 while UIParent:GetWidth() says 1365x768), so use those.
	local l, r, t, b = root:GetLeft(), root:GetRight(), root:GetTop(), root:GetBottom();
	if l and r and t and b and r > l and t > b then
		return r - l, t - b;
	end
	local us = UIParent:GetEffectiveScale();
	local rs = root:GetEffectiveScale();
	if not us or not rs or rs == 0 then us, rs = 1, 1; end
	local w, h = UIParent:GetWidth(), UIParent:GetHeight();
	if not w or not h then return W, H; end
	return w * us / rs, h * us / rs;
end

local function BuildDrifts()
	local cw = W / COLS;
	for i = 1, COLS do
		local c = cols[i];
		if not c then
			c = {
				body = root:CreateTexture(nil, "ARTWORK"),
				top = root:CreateTexture(nil, "OVERLAY"),
			};
			c.body:SetTexture(0.86, 0.92, 1, 1);
			c.body:SetAlpha(0.95);
			c.top:SetTexture(1, 1, 1, 1);
			c.top:SetAlpha(1);
			-- smooth hills from two sine waves plus a little noise (design height ~24)
			c.h = 24 + 10 * math.sin(i * 0.35) + 7 * math.sin(i * 0.13 + 1.7) + math.random() * 3;
			cols[i] = c;
		end
		c.x = (i - 1) * cw;
		c.body:SetWidth(cw + 1);
		c.top:ClearAllPoints();
		c.top:SetPoint("BOTTOMLEFT", c.body, "TOPLEFT", 0, -1);
		c.top:SetWidth(cw + 1);
		c.top:SetHeight(2);
	end
end

local function GrowFactor()
	if not db.grow then return 1; end
	if AZS_GetRunTime and AZS_GetRunLength then
		local t = AZS_GetRunTime();
		local len = AZS_GetRunLength();
		if t and len and len > 0 then
			local p = t / len;
			if p > 1 then p = 1; end
			return 0.3 + 0.7 * p;
		end
	end
	return 1;
end

local function ApplyDrifts()
	local factor = GrowFactor();
	for i = 1, COLS do
		local c = cols[i];
		if c then
			if db.drifts then
				local h = c.h * db.height / 24 * factor;
				if h < 1 then h = 1; end
				-- same coordinate system as the flakes: the drift's bottom edge sits at y = H
				c.body:ClearAllPoints();
				c.body:SetPoint("TOPLEFT", root, "TOPLEFT", c.x or 0, -(H - h));
				c.body:SetHeight(h);
				c.body:Show();
				c.top:Show();
			else
				c.body:Hide();
				c.top:Hide();
			end
		end
	end
end

local function CheckSize()
	local w, h = ScreenSize();
	if w and h and w > 0 and h > 0 and (math.abs(w - W) > 1 or math.abs(h - H) > 1) then
		W, H = w, h;
		for i = 1, active do ResetFlake(flakes[i], true); end
		BuildDrifts();
	end
end

---------------------------------------------------------------------
-- Motion tracking (movement and turning, estimated from the map position)
---------------------------------------------------------------------

local track = {
	ok = false, px = nil, py = nil,
	dx = nil, dy = nil,     -- smoothed direction of travel
	heading = nil,          -- its angle
	hold = 0,               -- seconds the "moving" state is kept after the last step
	target = 0, flow = 0,   -- movement flag and its smoothed value
	rate = 0,               -- smoothed turn rate, radians per second
	vel = 0,                -- smoothed sideways snow speed caused by turning
}

local function PollMotion(pdt)
	if not GetPlayerMapPosition then track.ok = false; return; end
	local x, y = GetPlayerMapPosition("player");
	if not x or not y or (x == 0 and y == 0) then
		track.ok = false;
		track.px = nil;
		track.hold = 0;
		track.rate = 0;
		return;
	end
	track.ok = true;
	local raw = 0;
	if track.px then
		local ddx, ddy = x - track.px, y - track.py;
		local dist = math.sqrt(ddx * ddx + ddy * ddy);
		if dist > 0.00002 then
			track.hold = 0.7;
			local ux, uy = ddx / dist, ddy / dist;
			if track.dx then
				-- low-pass the direction vector (no angle wrap problems, little noise)
				track.dx = track.dx + (ux - track.dx) * 0.3;
				track.dy = track.dy + (uy - track.dy) * 0.3;
			else
				track.dx, track.dy = ux, uy;
			end
			if track.dx * track.dx + track.dy * track.dy > 0.04 then
				local hd = math.atan2(track.dy, track.dx);
				if track.heading then
					local d = hd - track.heading;
					while d > 3.14159 do d = d - 6.28318; end
					while d < -3.14159 do d = d + 6.28318; end
					raw = d / pdt;
				end
				track.heading = hd;
			end
		else
			track.hold = track.hold - pdt;
		end
	end
	track.px, track.py = x, y;
	if track.hold > 0 then
		track.target = 1;
	else
		track.target = 0;
		raw = 0;
		track.dx, track.dy, track.heading = nil, nil, nil;
	end
	if math.abs(raw) < 0.2 then raw = 0; end            -- dead zone: ignore tiny wobbles
	if raw > 2 then raw = 2; elseif raw < -2 then raw = -2; end
	track.rate = track.rate + (raw - track.rate) * 0.3;
end

---------------------------------------------------------------------
-- Update loop
---------------------------------------------------------------------

local acc = 0
local pollAcc = 0
local half = { 0, 0 }
local parity = 1

root:SetScript("OnUpdate", function()
	local dt = arg1;
	if not dt then return; end
	if dt > 0.1 then dt = 0.1; end

	acc = acc + dt;
	if acc >= 0.5 then
		acc = 0;
		CheckSize();
		ApplyDrifts();
	end

	pollAcc = pollAcc + dt;
	if pollAcc >= 0.1 then
		if db.depth then PollMotion(pollAcc); end
		pollAcc = 0;
	end

	-- optional lighter mode (/snow rate half): move half of the flakes each frame, every flake with
	-- the time since its own last move. Default is every flake on every frame.
	local first, step = 1, 1;
	if db.half and active > 300 then
		half[1] = half[1] + dt;
		half[2] = half[2] + dt;
		parity = 3 - parity;
		first, step = parity, 2;
		dt = half[parity];
		half[parity] = 0;
	end

	local wind = db.wind or 0;
	local shift, flow = 0, 0;
	if db.depth then
		-- everything is eased, nothing jumps: movement fades in/out slowly, turning is a gentle drift
		track.flow = track.flow + (track.target - track.flow) * (1 - math.exp(-dt * 1.5));
		flow = track.flow;
		local want = -track.rate * (W / 1.2) * 0.15 * (db.turn or 0);
		if want > 140 then want = 140; elseif want < -140 then want = -140; end
		track.vel = track.vel + (want - track.vel) * (1 - math.exp(-dt * 4));
		shift = track.vel;
	end
	local cx, cy = W / 2, H * 0.45;
	local zoom = flow * 0.08;

	for i = first, active, step do
		local f = flakes[i];
		f.y = f.y + f.speed * dt;
		f.phase = f.phase + f.freq * dt;
		f.x = f.x + (wind * f.wf + shift * f.par) * dt;
		if f.y > H + 6 or f.y < -60 then
			ResetFlake(f, false);
		elseif f.x > W + 20 then
			f.x = f.x - (W + 40);       -- keep the overshoot: no clump at the edge
		elseif f.x < -20 then
			f.x = f.x + (W + 40);
		end
		local px = f.x + sin(f.phase) * f.amp;
		local py = f.y;
		if zoom > 0.002 then
			-- moving: a gentle zoom from the middle of the screen, stronger for near flakes.
			-- It is only applied when drawing (the flake's real position is untouched), so it
			-- cannot pile flakes up at the edges and it relaxes smoothly when you stop.
			local m = zoom * f.z;
			px = px + (px - cx) * m;
			py = py + (py - cy) * m;
		end
		-- whole-unit positions: sub-pixel placement makes small squares shimmer
		local tex = f.tex;
		if needClear then tex:ClearAllPoints(); end
		tex:SetPoint("TOPLEFT", root, "TOPLEFT", floor(px + 0.5), -floor(py + 0.5));
	end
end);

---------------------------------------------------------------------
-- Apply settings, events, slash command
---------------------------------------------------------------------

local function Apply()
	local w, h = ScreenSize();
	if w and h and w > 0 and h > 0 then
		if math.abs(w - W) > 1 or math.abs(h - H) > 1 then
			W, H = w, h;
			for i = 1, active do ResetFlake(flakes[i], true); end
		end
	end
	root:SetFrameStrata(db.top and "FULLSCREEN" or "BACKGROUND");
	SetFlakes(db.density);
	BuildDrifts();
	ApplyDrifts();
	if db.on then root:Show(); else root:Hide(); end
end

local ev = CreateFrame("Frame");
ev:RegisterEvent("VARIABLES_LOADED");
ev:RegisterEvent("PLAYER_ENTERING_WORLD");
ev:SetScript("OnEvent", function()
	Init();
	Apply();
end);

local function OnOff(s)
	if s == "on" or s == "1" then return true; end
	if s == "off" or s == "0" then return false; end
	return nil;
end

local function YesNo(b)
	if b then return "on"; end
	return "off";
end

SLASH_AZSSNOW1 = "/snow";
SlashCmdList["AZSSNOW"] = function(msg)
	msg = string.lower(msg or "");
	local _, _, cmd, arg = string.find(msg, "^(%S*)%s*(.-)$");
	cmd = cmd or "";
	arg = arg or "";
	local n = tonumber(arg);

	if cmd == "on" then
		db.on = true;
	elseif cmd == "off" then
		db.on = false;
	elseif cmd == "toggle" then
		db.on = not db.on;
	elseif string.find(cmd, "^%d+k$") then
		-- presets: /snow 1k, /snow 2k, /snow 4k (thousands of flakes, whole screen)
		local _, _, kn = string.find(cmd, "^(%d+)k$");
		n = tonumber(kn) * 1000;
		if n > 5000 then n = 5000; end
		db.density = n;
	elseif cmd == "density" and n then
		if n < 0 then n = 0; end
		if n > 5000 then n = 5000; end
		db.density = math.floor(n);
	elseif cmd == "wind" and n then
		if n < -150 then n = -150; end
		if n > 150 then n = 150; end
		db.wind = n;
	elseif cmd == "height" and n then
		if n < 4 then n = 4; end
		if n > 80 then n = 80; end
		db.height = n;
	elseif cmd == "drifts" and OnOff(arg) ~= nil then
		db.drifts = OnOff(arg);
	elseif cmd == "grow" and OnOff(arg) ~= nil then
		db.grow = OnOff(arg);
	elseif cmd == "top" and OnOff(arg) ~= nil then
		db.top = OnOff(arg);
	elseif cmd == "depth" and OnOff(arg) ~= nil then
		db.depth = OnOff(arg);
	elseif cmd == "turn" and n then
		if n < -3 then n = -3; end
		if n > 3 then n = 3; end
		db.turn = n;
	elseif cmd == "rate" then
		if arg == "full" then
			db.half = false;
		elseif arg == "half" then
			db.half = true;
		else
			Print("/snow rate full (every flake every frame, smoothest) or /snow rate half (lighter)");
			return;
		end
	elseif cmd == "debug" then
		local function f1(x)
			if type(x) == "number" then return string.format("%.1f", x); end
			return tostring(x);
		end
		Print("UIParent " .. f1(UIParent:GetWidth()) .. "x" .. f1(UIParent:GetHeight())
			.. " scale " .. f1(UIParent:GetEffectiveScale())
			.. " | root " .. f1(root:GetWidth()) .. "x" .. f1(root:GetHeight())
			.. " scale " .. f1(root:GetEffectiveScale()));
		Print("root L " .. f1(root:GetLeft()) .. " R " .. f1(root:GetRight())
			.. " T " .. f1(root:GetTop()) .. " B " .. f1(root:GetBottom()));
		Print("field " .. f1(W) .. "x" .. f1(H) .. " | screen "
			.. f1(GetScreenWidth and GetScreenWidth()) .. "x" .. f1(GetScreenHeight and GetScreenHeight()));
		local c = cols[1];
		if c then
			Print("drift1 h " .. f1(c.body:GetHeight()) .. " w " .. f1(c.body:GetWidth())
				.. " shown " .. tostring(c.body:IsShown()) .. " visible " .. tostring(c.body:IsVisible())
				.. " alpha " .. f1(c.body:GetAlpha()) .. " L " .. f1(c.body:GetLeft())
				.. " B " .. f1(c.body:GetBottom()) .. " | flakes " .. active);
		end
		local mx, my;
		if GetPlayerMapPosition then mx, my = GetPlayerMapPosition("player"); end
		Print("map position " .. f1(mx) .. ", " .. f1(my) .. " | tracking " .. tostring(track.ok)
			.. " flow " .. f1(track.flow) .. " rate " .. f1(track.rate) .. " vel " .. f1(track.vel)
			.. " | clearPoints " .. tostring(needClear));
		return;
	elseif cmd == "reset" then
		for k, v in pairs(DEFAULTS) do db[k] = v; end
	elseif cmd ~= "" then
		Print("unknown command. Commands: on, off, toggle, 1k, 2k, 4k, density N, wind N, height N, drifts on|off, grow on|off, top on|off, depth on|off, turn N, rate full|half, debug, reset");
		return;
	end

	Apply();
	Print("snow " .. YesNo(db.on) .. ", density " .. db.density .. ", wind " .. db.wind
		.. ", drifts " .. YesNo(db.drifts) .. " (height " .. db.height .. ", grow " .. YesNo(db.grow)
		.. "), above HUD " .. YesNo(db.top) .. ", depth " .. YesNo(db.depth) .. " (turn " .. db.turn .. "), rate " .. (db.half and "half" or "full"));
end

Init();
Apply();
