

util.AddNetworkString( "StaminaDrowning" )
util.AddNetworkString( "StaminaSpawn" )


net.Receive("StaminaDrowning", function(len,ply)

	local dmg = DamageInfo()
	dmg:AddDamage(10)
	dmg:SetDamageType(DMG_DROWN)
	dmg:SetAttacker(ply)
	dmg:SetInflictor(ply)
	
	ply:TakeDamageInfo(dmg)


end)

hook.Add("PlayerSpawn","Stamina Reset Variables",StaminaResetVariables)
hook.Add("PlayerInitialSpawn","Stamina Reset Variables",StaminaResetVariables)



