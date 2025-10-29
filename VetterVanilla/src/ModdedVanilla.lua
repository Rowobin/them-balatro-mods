SMODS.Atlas {
    key = "ModdedVanilla",
    path = "ModdedVanilla.png",
    px = 71,
    py = 95
}

SMODS.Joker {
    key = "bitjoker",
    loc_txt = {
        name = "8-Bit J0ker",
        text = {
            "Each played {C:attention}8{}, {C:attention}4{} or {C:attention}2{}",
            "gives {C:chips}+#1#{} Chips and",
            "{X:mult,C:white}X#2#{} Mult when scored"
        }
    },
    config = { extra = { chips = 8, xmult = 2 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.xmult } }
    end,
    rarity = 2,
    atlas = "ModdedVanilla",
    pos = { x = 0, y = 0 },
    cost = 8,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 8 or context.other_card:get_id() == 4 or context.other_card:get_id() == 2 then
                return {
                    chips = card.ability.extra.chips,
                    xmult = card.ability.extra.xmult,
                    card = context.other_card
                }
            end
        end
    end
}
