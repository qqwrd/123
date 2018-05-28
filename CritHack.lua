local CritHack = {}

CritHack.CritMode = 0

CritHack.CritKey = Menu.AddKeyOption({"Hero Specific", "CritHack"}, "Crit Key", Enum.ButtonCode.KEY_F)
CritHack.Font = Renderer.LoadFont("Tahoma", 24, Enum.FontWeight.EXTRABOLD)

CritHack.NPCs = {}

CritHack.HeroList = {
    "npc_dota_hero_phantom_assassin",
    "npc_dota_hero_skeleton_king",
    "npc_dota_hero_juggernaut",
    "npc_dota_hero_chaos_knight",
    "npc_dota_hero_brewmaster",
    "npc_dota_hero_pangolier",
    "npc_dota_hero_morphling"
}

CritHack.CritAnimationList = {
    "phantom_assassin_attack_crit_anim",
    "attack_crit_alt_anim",
    "attack_crit_anim",
    "Attack Critical_anim",
    "attack_event"
}

CritHack.NormalAnimationList = {
    "phantom_assassin_attack_anim",
    "phantom_assassin_attack_alt1_anim",
    "attack_anim",
    "attack2_anim",
    "attack3_anim",
    "Attack Alternate_anim",
    "Attack_anim",
    "attack_alt1_anim",
    "attack01_fast",
    "attack01_faster",
    "attack01_fastest",
    "attack02_fast",
    "attack02_faster",
    "attack02_fastest",
    "attack_03",
    "attack_03_fast",      
    "attack_03_faster",
    "attack_03_fastest",
    "attack",
    "attack_fast",
    "attack_faster",
    "attack_fastest",
    "attack02_stab",
    "attack02_stab_fast",
    "attack02_stab_faster",
    "attack02_stab_fastest"
}

function CritHack.OnGameStart()
    CritHack.CritMode = 0
    CritHack.NPCs = {}
end

function CritHack.OnUnitAnimation(animation)
    if not animation then return end
    if not Heroes.GetLocal() then return end

    -- for i, v in ipairs(CritHack.HeroList) do
    --     if NPC.GetUnitName(animation.unit) == v then
    --         Log.Write("unit: " .. tostring(NPC.GetUnitName(animation.unit)))
    --         Log.Write("sequenceVariant:" .. tostring(animation.sequenceVariant))
    --         Log.Write("playbackRate:" .. tostring(animation.playbackRate))
    --         Log.Write("type:" .. tostring(animation.type))
    --         Log.Write("activity:" .. tostring(animation.activity))
    --         Log.Write("sequence:" .. tostring(animation.sequence))
    --         Log.Write("sequenceName:" .. tostring(animation.sequenceName))
    --     end
    -- end

    for i, v in ipairs(CritHack.HeroList) do
        if NPC.GetUnitName(animation.unit) == v then
            if CritHack.CritMode == 1 then
                for i, v in ipairs(CritHack.NormalAnimationList) do
                    if animation.sequenceName == v then
                        for k, v in ipairs(CritHack.NPCs) do
                            if v[1] == animation.unit then
                                table.remove(CritHack.NPCs, k)
                            end
                        end

                        Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_STOP, nil, Vector(0, 0, 0), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, animation.unit, false)
                        local increasedAS = NPC.GetIncreasedAttackSpeed(animation.unit)
                        local attackTime = NPC.GetAttackTime(animation.unit)
                        local attackPoint = .30
                        if NPC.GetUnitName(animation.unit) == "npc_dota_hero_phantom_assassin" then
                            attackPoint = .30
                        elseif NPC.GetUnitName(animation.unit) == "npc_dota_hero_skeleton_king" then 
                            attackPoint = .56
                        elseif NPC.GetUnitName(animation.unit) == "npc_dota_hero_juggernaut" then 
                            attackPoint = .33
                        elseif NPC.GetUnitName(animation.unit) == "npc_dota_hero_chaos_knight" then  
                            attackPoint = .50
                        elseif NPC.GetUnitName(animation.unit) == "npc_dota_hero_brewmaster" then  
                            attackPoint = .35
                        elseif NPC.GetUnitName(animation.unit) == "npc_dota_hero_pangolier" then  
                            attackPoint = .34
                        elseif NPC.GetUnitName(animation.unit) == "npc_dota_hero_morphling" then  
                            attackPoint = .51
                        end
                        local attackSpeed = attackPoint / (1 + (increasedAS/100))
                        local attackTime = GameRules.GetGameTime() + attackSpeed + (attackPoint*.17)
                        table.insert(CritHack.NPCs, {animation.unit, GameRules.GetGameTime(), attackTime})
                    end
                end
            end
        end
    end
end

function CritHack.OnUpdate()
    if not Heroes.GetLocal() then return end
    for i, v in ipairs(CritHack.HeroList) do
        if Menu.IsKeyDownOnce(CritHack.CritKey) then
            if CritHack.CritMode == 1 then
                CritHack.CritMode = 0
            else
                CritHack.CritMode = 1
            end
        end
    
        if CritHack.CritMode == 1 then
            for k, v in ipairs(CritHack.NPCs) do
                if v[1] and v[2] and v[3] then
                    if not Entity.IsAlive(v[1]) then
                        table.remove(CritHack.NPCs, k)
                    elseif GameRules.GetGameTime() >= v[3] then
                        Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE, nil, Vector(0, 0, 0), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, v[1], false)
                        table.remove(CritHack.NPCs, k)
                    end
                end
            end
        end
    end
end

function CritHack.OnDraw()
    if not GameRules.GetGameState() == 5 then return end
    if not Heroes.GetLocal() then return end
    local myHero = Heroes.GetLocal()

    local pos = Entity.GetAbsOrigin(myHero)
    local x, y, visible = Renderer.WorldToScreen(pos)

    if visible and pos and CritHack.CritMode == 1 then
      Renderer.SetDrawColor(255, 255, 255, 255)
      Renderer.DrawText(CritHack.Font, x+15, y+15, "Crit", 1)
    end
end


return CritHack