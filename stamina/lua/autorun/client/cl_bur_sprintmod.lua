CreateClientConVar("cl_bur_sprintmod_enablehud",1,true,false)
CreateClientConVar("cl_bur_sprintmod_fade",1,true,false)


local SCPTEAM = {
    ["SCP-999"] = true,
    ["SCP-131"] = true,
    ["SCP-527"] = true,
	["SCP-173"] = true,
	["SCP-006-FR"] = true,
	["SCP-457"] = true,
	["SCP-049"] = true,
	["SCP-079 *WL*"] = true,
	["SCP-096"] = true,
	["SCP-939"] = true,
	["SCP-106 *WL*"] = true,
	["SCP-682 *WL*"] = true,
	["SCP-738 *STAFF*"] = true,
	["SCP-●●|●●●●●|●●|● *STAFF*"] = true,
	["SCP-1048"] = true,
	["SCP-076-2"] = true,
	
    ["Intelligence Artificielle *WL*"] = true,
}

net.Receive("StaminaSpawn", function(len)

	local ply = LocalPlayer()


	local MaxStamina = net.ReadFloat()
	local RegenMul = net.ReadFloat()
	local DecayMul = net.ReadFloat()
	
	
	ply.BurgerStamina = 100
	ply.BurgerMaxStamina = 100
	ply.BurgerDecayMul = 1.15
	ply.BurgerRegenMul = 1.2
	

end)

local JumpLatch = 0

function GetClientMove(cmd)

	local ply = LocalPlayer()

	local NewButtons = cmd:GetButtons()
	
	local Change = FrameTime() * 5
	
	if not first then
	
		ply.BurgerStamina = 100
		ply.BurgerMaxStamina = 100

		if SCPTEAM[ply:getJobTable().name] then
			ply.BurgerDecayMul = 0
			ply.BurgerRegenMul = 0
		else
			ply.BurgerDecayMul = 1.15
			ply.BurgerRegenMul = 1.2
		end
		
		
		
		ply.NextRegen = 0
		ply.WaterTick = 0
		
		first = true
		
	end


	if cmd:KeyDown(IN_SPEED) and ( cmd:KeyDown(IN_FORWARD) or cmd:KeyDown(IN_BACK) or cmd:KeyDown(IN_MOVELEFT) or cmd:KeyDown(IN_MOVERIGHT) ) and (ply:GetVelocity():Length() > 100) and ( ply:OnGround() or ply:WaterLevel() ~= 0 ) and !ply:InVehicle() then
	
		if SCPTEAM[ply:getJobTable().name] then
			return false
		else
			if ply.BurgerStamina <= 0 then
		
				NewButtons = NewButtons - IN_SPEED

			else
				
				ply.BurgerStamina = math.Clamp(ply.BurgerStamina - Change * (0.8 * ply.BurgerDecayMul) ,0,ply.BurgerMaxStamina + 50)
				ply.NextRegen = CurTime() + 1.25

			end
		end
		
	end
	
	if SCPTEAM[ply:getJobTable().name] then
		return
	else
		--Jumping code provided by bobbleheadbob
		if cmd:KeyDown(IN_JUMP) and ply:OnGround() and !ply:InVehicle() then

			if ply.BurgerStamina <= 5 then
			
				NewButtons = NewButtons - IN_JUMP
				
			else

				if not JumpLatch then

					if cmd:KeyDown(IN_SPEED) and ( cmd:KeyDown(IN_FORWARD) or cmd:KeyDown(IN_BACK) or cmd:KeyDown(IN_MOVELEFT) or cmd:KeyDown(IN_MOVERIGHT) ) then
						ply.BurgerStamina = math.Clamp(ply.BurgerStamina - 6.2*ply.BurgerDecayMul,0,ply.BurgerMaxStamina + 50)
					else
						ply.BurgerStamina = math.Clamp(ply.BurgerStamina - 4.3*ply.BurgerDecayMul,0,ply.BurgerMaxStamina + 50)
					end

				end
				
				ply.NextRegen = CurTime() + 1.25
				
			end


			JumpLatch = true
			
			
		elseif not cmd:KeyDown(IN_JUMP) then
			JumpLatch = false
		end
	end
	
	if SCPTEAM[ply:getJobTable().name] then
		return
	else
		if ply:WaterLevel() == 3 then

			ply.NextRegen = CurTime() + 1.25
		
			if ply.BurgerStamina ~= 0 then
			
				ply.BurgerStamina = math.Clamp(ply.BurgerStamina - Change*0.5*ply.BurgerDecayMul ,0,ply.BurgerMaxStamina)
				
			else
			
				if ply.WaterTick <= CurTime() then
						
					net.Start("StaminaDrowning")
						net.WriteFloat(1)
					net.SendToServer()
						
					ply.WaterTick = CurTime() + 1
				
				end
				
			end
			
				
		end
	end
	
	
	if ply.NextRegen then
	
		if ply.NextRegen < CurTime() then
			
			
			if (cmd:KeyDown(IN_FORWARD) or cmd:KeyDown(IN_BACK) or cmd:KeyDown(IN_MOVELEFT) or cmd:KeyDown(IN_MOVERIGHT)) then
					ply.BurgerStamina = math.Clamp(ply.BurgerStamina + ( Change * 0.45 * ply.BurgerRegenMul ) ,0,ply.BurgerMaxStamina)
				else
					ply.BurgerStamina = math.Clamp(ply.BurgerStamina + ( Change * 0.65 * ply.BurgerRegenMul ) ,0,ply.BurgerMaxStamina)
			end
			
		end
		
	end
	

	cmd:SetButtons(NewButtons)

end


hook.Add("CreateMove","Burger Sprint",GetClientMove)

hook.Add( "HUDPaint", "blurstamina", function()
	local ply = LocalPlayer()

	if ply.BurgerStamina >= 25 then return end

	DrawToyTown( ( 35 + ( 0 - (ply.BurgerStamina/3) ) ) * 0.1  , ScrH() * 2 * ( 1 ) )
end )


