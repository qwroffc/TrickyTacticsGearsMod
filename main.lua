local mod = RegisterMod("testmod", 1)
local ITEM_ID = Isaac.GetItemIdByName("Honey band-aid")

function mod:onTearCollision(tear, collider, low)
    local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
    if not player then return end
    if not player:HasCollectible(ITEM_ID) then return end

    local npc = collider and collider:ToNPC()
    if not npc then return end
    if npc:IsDead() or not npc:IsVulnerableEnemy() then return end

    -- чтобы одна слеза не триггерилась 10 раз
    if tear:GetData().HoneyProc then return end
    tear:GetData().HoneyProc = true

    -- ===== ШАНС =====
    local baseChance = 0.05
    local luckBonus = (math.min(player.Luck, 15) / 15) * 0.45
    local chance = baseChance + luckBonus

    if math.random() <= chance then
        
        local before = player:GetSoulHearts()
        player:AddSoulHearts(1)
        local after = player:GetSoulHearts()

        -- если не добавилось — значит не влезло
        if after == before then
            Isaac.Spawn(
                EntityType.ENTITY_PICKUP,
                PickupVariant.PICKUP_HEART,
                HeartSubType.HEART_HALF_SOUL,
                npc.Position,
                Vector.Zero,
                player
            )
        end

        player:PlaySound(SoundEffect.SOUND_SOUL_HEART, 1.0)
    end
end


local function AddEID()
    if EID then
        
        -- English
        EID:addCollectible(
            ITEM_ID,
            "5% chance to gain a {{SoulHeart}} half soul heart when hitting an enemy.#" ..
            "If all heart slots are full, a {{SoulHeart}} half soul heart drops on the ground.#" ..
            "50% chance with 15+ luck.",
            "Honey band-aid",
            "en_us"
        )

        -- Russian
        EID:addCollectible(
            ITEM_ID,
            "5% шанс при попадании по врагу получить {{SoulHeart}} половинку сердца души.#" ..
            "Если все ячейки сердец заполнены, то {{SoulHeart}} половинка сердца души выпадает на землю.#" ..
            "50% шанс при 15+ удачи.",
            "Медовый пластырь",
            "ru"
        )
    end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, AddEID)
 

mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, mod.onTearCollision)
