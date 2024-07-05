local GunMode = "Auto" --No other Modes are scripted in so don't change this
local MagCap = 35 --Magazine Capacity
local RateOfFire = .125 --How often a new Beam will be shot
local HeadDamage = 14 --Damage when hitting the Head of other player
local TorsoDamage = 11 --Damage when hitting Torso or HumanoidRootPart of other player
local LimbDamage = 8 --Damage when hitting Arms or Legs of other player (This also includes the damage for when the opponent's gun is hit)
local Ammo = MagCap --The current amount of Ammo in the gun; never change this variable; refer to "local MagCap" for consistency
local ReloadTime = 2.5 --Rate at which the gun reloads
local Reloading = false
local Shooting = false
local Equipped = false

local FriendlyFireEnabled = false --Set this to true for Friendly Fire to be operational

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GunFiringEvent = ReplicatedStorage:FindFirstChild("GunFiringEvent")
local AnimationEvent = ReplicatedStorage:FindFirstChild("AnimationEvent")
local DamageMarker = ReplicatedStorage:FindFirstChild("DamageMarker")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local PLRS = game:GetService("Players") --This is every player including you
local PLR = PLRS.LocalPlayer --This is your client
local Gun = script.Parent
local Handle = Gun.Handle
repeat wait() until game.Players.LocalPlayer.Character
local CHR = PLR.Character --This is your physical character
local Head = CHR:WaitForChild("Head")
local Torso = CHR:WaitForChild("Torso")
local Humanoid = CHR:WaitForChild("Humanoid")
local RightArm = CHR:WaitForChild("Right Arm")
local LeftArm = CHR:WaitForChild("Left Arm")

local AllUI = PLR.PlayerGui.TVU_UserInterface.AllUI
local AmmoUI = AllUI.AmmoUI
local BulletCountUI = AmmoUI.BulletCountUI
local BulletCapacityUI = AmmoUI.BulletCapacityUI

local Sprinting = false
local Crouching = false

local Mouse = PLR:GetMouse()
local MouseToggled = false
local DefaultMouseCursor = [[]]
local GunMouseCursor = "http://www.roblox.com/asset/?id=131718469"
local EnemeyMouseCursor = "http://www.roblox.com/asset/?id=131718495"
local FriendlyMouseCursor = "http://www.roblox.com/asset/?id=131718487"

local GamePadUsed = false

local MouseMarkerGUI = Instance.new("ImageLabel") --Creates the "cursor" that will be used with a Gamepad
MouseMarkerGUI.Parent = AllUI
MouseMarkerGUI.Position = UDim2.new(0.497, 0, 0.3, 0)
MouseMarkerGUI.Size = UDim2.new(0, 10, 0, 10)
MouseMarkerGUI.BackgroundTransparency = 0
MouseMarkerGUI.Image = "http://www.roblox.com/asset/?id=6631155345"
MouseMarkerGUI.BackgroundTransparency = 1

UserInputService.InputChanged:Connect(function(input, gameProcessed) --Finds out whether or not a Gamepad is being used at any point; automatically switches controls depending on what was last giving input 
	if input.UserInputType == Enum.UserInputType.Gamepad1 then
		GamePadUsed = true
		MouseMarkerGUI.Visible = true
		MouseMarkerGUI.ImageColor3 = Color3.new(255, 255, 255)
		local UnitRay = workspace.CurrentCamera:ScreenPointToRay(MouseMarkerGUI.AbsolutePosition.X, MouseMarkerGUI.AbsolutePosition.Y)
		local UnitRay2 = Ray.new(UnitRay.Origin, UnitRay.Direction * 300)
		local Hitting, Position = game.Workspace:FindPartOnRayWithIgnoreList(UnitRay2, {CHR, Gun, workspace.TVURays})
		if Hitting and Hitting.Parent and Hitting.Parent.Parent and (Hitting.Parent:FindFirstChild("Humanoid") or Hitting.Parent.Parent:FindFirstChild("Humanoid")) then
			local OtherPlayer = PLRS:GetPlayerFromCharacter(Hitting.Parent) or PLRS:GetPlayerFromCharacter(Hitting.Parent.Parent)
			print(Hitting.Name)
			if OtherPlayer then
				if PLR.TeamColor == OtherPlayer.TeamColor then
					if FriendlyFireEnabled == false then
						MouseMarkerGUI.ImageColor3 = Color3.new(0, 0.666667, 0)
						print'Green'
					else
						MouseMarkerGUI.ImageColor3 = Color3.new(0.647059, 0, 0)
						print'Red'
					end
				else
					MouseMarkerGUI.ImageColor3 = Color3.new(0.647059, 0, 0)
					print'Red'
				end
			else
				MouseMarkerGUI.ImageColor3 = Color3.new(0.647059, 0, 0)
				print'White'
			end
		end
	else
		--input.UserInputType == Enum.
		GamePadUsed = false
		MouseMarkerGUI.Visible = false
	end
end)

function Crouch()
	print 'Crouching'
end

function Sprint() --Makes you sprint
	print 'Sprinting'
	if not Sprinting then
		Sprinting = true
		Humanoid.WalkSpeed = 23 --Sets value to how fast you are when sprinting
	else
		Sprinting = false
		Humanoid.WalkSpeed = 16 --Sets value to how fast you are when not sprinting
	end
end

function Reload() --Takes care of Reloading the gun and it's respective sound
	print 'Reloading'
	Reloading = true
	if Ammo <= 0 then
		Handle.OutOfAmmo:Play()
		if Handle.OutOfAmmo.Ended then
			wait(ReloadTime)
			Handle.Reloaded:Play()
			Ammo = MagCap
			Reloading = false
			BulletCountUI.Text = Ammo
			print 'Reloaded'
		end
	else
		Handle.Reload.PlaybackSpeed = .01
		Handle.Reload.Pitch = 1
		wait(ReloadTime)
		Handle.Reloaded:Play()
		Ammo = MagCap
		Reloading = false
		BulletCountUI.Text = Ammo
		print 'Reloaded'
	end
end

function ChangeCursor() --This only changes the cursor when a Mouse is being used
	local Hit = Mouse.Target
	if Equipped and Mouse ~= nil and not GamePadUsed then
		--print(Hit)
		Mouse.Icon = GunMouseCursor
		if Hit and Hit.Parent and Hit.Parent.Parent and (Hit.Parent:FindFirstChild("Humanoid") or Hit.Parent.Parent:FindFirstChild("Humanoid")) then
			local OtherPlayer = PLRS:GetPlayerFromCharacter(Hit.Parent) or PLRS:GetPlayerFromCharacter(Hit.Parent.Parent)
			if OtherPlayer then
				print(OtherPlayer.Name)
				if PLR.TeamColor == OtherPlayer.TeamColor then
					if FriendlyFireEnabled == false then
						Mouse.Icon = FriendlyMouseCursor
					else
						Mouse.Icon = EnemeyMouseCursor
					end
				else
					Mouse.Icon = EnemeyMouseCursor
				end
			else
				Mouse.Icon = EnemeyMouseCursor
			end
		end
	end
end

--Mouse and Keyboard Controls

function CastRay() --Draws new client-side only raycast and sends raycasting data to server
	local Origin = (Handle.CFrame * CFrame.new(0, 0, 0)).p
	local StartingPosition = (Head.CFrame * CFrame.new(1, -1, 0)).p
	local RayBeam = nil
	local CameraRay = nil
	local UnitRay = nil
	local UnitRay2 = nil
	if GamePadUsed then
		UnitRay = workspace.CurrentCamera:ScreenPointToRay(MouseMarkerGUI.AbsolutePosition.X, MouseMarkerGUI.AbsolutePosition.Y)
		UnitRay2 = Ray.new(UnitRay.Origin, UnitRay.Direction * 300)
		local Hitting, Position = game.Workspace:FindPartOnRayWithIgnoreList(UnitRay2, {CHR, Gun, workspace.TVURays})
		RayBeam = Ray.new(StartingPosition, (Position - StartingPosition).unit * 300) --This Raybeam is drawn when a Gamepad is being used
	else
		RayBeam = Ray.new(StartingPosition, (Mouse.Hit.p - StartingPosition).unit * 300) --This Raybeam is drawn when a Mouse is being used
	end
	local Hitting, Position = game.Workspace:FindPartOnRayWithIgnoreList(RayBeam, {CHR, Gun, workspace.TVURays})
	local Distance = (Position - Handle.CFrame.p).magnitude
	
	local RayPart = Instance.new("Part") --The beam itself
	RayPart.Parent = workspace.TVURays
	RayPart.Name = "RayPart"
	RayPart.Transparency = .4
	RayPart.FormFactor = "Custom"
	RayPart.Size = Vector3.new(.2,.2,Distance)
	RayPart.Anchored = true
	RayPart.CanCollide = false
	RayPart.CastShadow = false
	RayPart.CFrame = CFrame.new(Position, Origin) * CFrame.new(0,0, -Distance/2) + Vector3.new(0,.1,0)
	game.Debris:AddItem(RayPart, .05)
	
	local ServerRayBeam = RayBeam
	local ServerHitting, ServerPosition = game.Workspace:FindPartOnRayWithIgnoreList(ServerRayBeam, {CHR, Gun, workspace.TVURays})
	local ServerDistance = (ServerPosition - Handle.CFrame.p).magnitude
	
	if ServerHitting and ServerHitting.Parent and (ServerHitting.Parent:FindFirstChild("Humanoid") or ServerHitting.Parent.Parent:FindFirstChild("Humanoid")) then
		local OtherHumanoid = ServerHitting.Parent:FindFirstChild("Humanoid") or ServerHitting.Parent.Parent:FindFirstChild("Humanoid")
		if OtherHumanoid then
			local HitPlayer = game.Players:GetPlayerFromCharacter(OtherHumanoid.Parent)
			if HitPlayer then
				if HitPlayer.TeamColor ~= PLR.TeamColor then
					local SelectionBox = Instance.new("SelectionBox")
					SelectionBox.Parent = ServerHitting
					SelectionBox.Adornee = ServerHitting
					SelectionBox.LineThickness = .075
					SelectionBox.Color3 = Color3.new(85,0,0)
					game.Debris:AddItem(SelectionBox, .05)
				else
					if FriendlyFireEnabled then
						local SelectionBox = Instance.new("SelectionBox")
						SelectionBox.Parent = ServerHitting
						SelectionBox.Adornee = ServerHitting
						SelectionBox.LineThickness = .075
						SelectionBox.Color3 = Color3.new(85,0,0)
						game.Debris:AddItem(SelectionBox, .05)
					end
				end
			else
				local SelectionBox = Instance.new("SelectionBox")
				SelectionBox.Parent = ServerHitting
				SelectionBox.Adornee = ServerHitting
				SelectionBox.LineThickness = .075
				SelectionBox.Color3 = Color3.new(85,0,0)
				game.Debris:AddItem(SelectionBox, .05)
			end
		end
	end

	print(ServerHitting)

	local ServerRayPartCFrame = CFrame.new(ServerPosition, Origin) * CFrame.new(0,0, -ServerDistance/2) + Vector3.new(0,.1,0)
	local ServerRayPartSize = Vector3.new(.2,.2,ServerDistance)
	
	GunFiringEvent:FireServer(Humanoid, Mouse.Hit.p, Handle, CHR, Gun, Mouse.Target, HeadDamage, TorsoDamage, LimbDamage, FriendlyFireEnabled, ServerRayBeam, ServerHitting, ServerDistance, ServerRayPartCFrame, ServerRayPartSize) --Sends info to server
	BulletCountUI.Text = Ammo
	print 'Gun Fired'
end

local DamageGivenAmount = 0
local CurrentOtherHumanoid = nil
local PreviousTime = 0
local CurrentTime = 0

function DrawDamageMarker(DamageGiven, OtherHumanoid, ServerHitting, TeamColorIsDifferent)
	print(TeamColorIsDifferent)
	if DamageGiven and TeamColorIsDifferent == true then
		PreviousTime = CurrentTime
		CurrentTime = tick()
		local PassedTime = CurrentTime - PreviousTime
		if PassedTime >= 1.2 then --Maximum length for the Damage Marker to stack after hitting enemy; defined after >=
			DamageGivenAmount = 0
			CurrentOtherHumanoid = nil
		end
		--[[OtherHumanoid.Died:connect(function()
			print(PLR.Name.." killed "..OtherHumanoid.Parent.Name)
		end)]]
		
		local DamageMarkerGUI = Instance.new("TextLabel")
		DamageMarkerGUI.Parent = AllUI
		DamageMarkerGUI.BackgroundTransparency = 1
		DamageMarkerGUI.TextSize = 25
		DamageMarkerGUI.Font = Enum.Font.Oswald
		DamageMarkerGUI.TextStrokeTransparency = 0
		if ServerHitting.Name == "Head" then
			DamageMarkerGUI.TextColor3 = Color3.new(1, 0.152941, 0.168627)
		else
			DamageMarkerGUI.TextColor3 = Color3.new(255,255,255)
		end
		if not GamePadUsed then
			DamageMarkerGUI.Position = UDim2.new(0, Mouse.X + 20, 0, Mouse.Y - 15)
			DamageMarkerGUI:TweenPosition(UDim2.new(0, Mouse.X + 20, 0, DamageMarkerGUI.Position.X.Scale - 20), "Out", "Quad", 5, true)
		else
			DamageMarkerGUI.Position = MouseMarkerGUI.Position + UDim2.new(0,30,0,0)
			DamageMarkerGUI:TweenPosition(MouseMarkerGUI.Position + UDim2.new(0, 30, 0, -100), "Out", "Quad", 5, true)
		end
		game.Debris:AddItem(DamageMarkerGUI, .15)
		
		if DamageGivenAmount == 0 then
			CurrentOtherHumanoid = OtherHumanoid.Parent
			DamageGivenAmount = DamageGivenAmount + DamageGiven
			DamageMarkerGUI.Text = DamageGivenAmount
		else
			if CurrentOtherHumanoid and CurrentOtherHumanoid ~= OtherHumanoid.Parent then
				CurrentOtherHumanoid = OtherHumanoid.Parent
				DamageGivenAmount = 0 + DamageGiven
				DamageMarkerGUI.Text = DamageGivenAmount
			else
				DamageGivenAmount = DamageGivenAmount + DamageGiven
				DamageMarkerGUI.Text = DamageGivenAmount
			end
		end
	end
end

DamageMarker.OnClientEvent:Connect(DrawDamageMarker)

Gun.Equipped:Connect(function()
	Equipped = true
	Mouse.Icon = GunMouseCursor
	print 'Equipped'
	MouseMove = Mouse.Move:Connect(ChangeCursor)
end)

Gun.Unequipped:Connect(function()
	Equipped = false
	MouseToggled = false
	Mouse.Icon = [[]]
	MouseMove:Disconnect()
	print 'Unequipped'
end)

UserInputService.InputBegan:Connect(function(KeyPressed)
	if Equipped and not Reloading and Ammo < MagCap and KeyPressed.KeyCode == Enum.KeyCode.R or KeyPressed.KeyCode == Enum.KeyCode.ButtonX then
		Reload()
	end
	if KeyPressed.KeyCode == Enum.KeyCode.F or KeyPressed.KeyCode == Enum.KeyCode.ButtonL3 then
		print'works'
		if not Shooting and not Crouching then
			Sprint()
		end
		if not Shooting and Crouching then
			Crouching = false
			Sprint()
		end
	end
	if KeyPressed.KeyCode == Enum.KeyCode.C then
		if not Sprinting then
			Crouch()
		else
			Humanoid.WalkSpeed = 16
			Sprinting = false
			Crouch()
		end
	end
end)

Gun.Activated:Connect(function() --Mouse Down Events
	MouseToggled = true
	Humanoid.WalkSpeed = 16
	Sprinting = false
	if GunMode == "Auto" then
		if not Shooting then
			while Equipped and MouseToggled and not Reloading and Ammo > 0 do
				Shooting = true
				Handle.Fire.Pitch = 1
				Handle.Fire:Play()
				Ammo = Ammo - 1
				CastRay()
				wait(RateOfFire)
			end
			Shooting = false
		end
	end
	if Ammo <= 0 and not Shooting and not Reloading then
		Reload()
	end
end)

Gun.Deactivated:Connect(function() --Mouse Up Events
	MouseToggled = false
end)

Humanoid.Died:Connect(function()
	Mouse.Icon = DefaultMouseCursor
	Gun:Destroy()
end)
