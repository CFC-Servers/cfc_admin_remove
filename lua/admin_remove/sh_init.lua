AddCSLuaFile()

local IsValid = IsValid

hook.Add( "InitPostEntity", "AdminRemove_Setup", function()
    local property = properties.List.remove

    property.Filter = function( self, ent, ply )
        if not IsValid( ent ) then return false end
        if ent:IsPlayer() then return false end

        if ply:IsAdmin() then return true end
        if not gamemode.Call( "CanProperty", ply, "remover", ent ) then return false end

        return true
    end

    if SERVER then
        -- Have to override this because it's a network receiver
        -- It's identical to gmod's except for the alerting logic in the timer
        property.Receive = function( self, length, ply )
            if not IsValid( ply ) then return end

            local ent = net.ReadEntity()
            if not IsValid( ent ) then return end

            if not properties.CanBeTargeted( ent, ply ) then return end
            if not self:Filter( ent, ply ) then return end

            constraint.RemoveAll( ent )

            timer.Simple( 1, function()
                if IsValid( ent ) then
                    local owner = ent:CPPIGetOwner()

                    if owner and ply:IsAdmin() and owner ~= ply then
                        ulx.fancyLogAdmin( ply, "#A removed a #s owned by #T", ent:GetClass(), ply )
                    end

                    SafeRemoveEntity( ent )
                end
            end )

            ent:SetNotSolid( true )
            ent:SetMoveType( MOVETYPE_NONE )
            ent:SetNoDraw( true )

            local ed = EffectData()
            ed:SetEntity( ent )
            util.Effect( "entity_remove", ed, true, true )

            ply:SendLua( "achievements.Remover()" )
        end
    end

end )
