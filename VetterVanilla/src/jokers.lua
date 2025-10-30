SMODS.Atlas {
    key = "ModdedJokers",
    path = "ModdedJokers.png",
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
    rarity = 3,
    atlas = "ModdedJokers",
    pos = { x = 0, y = 0 },
    cost = 8,
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 8 or context.other_card:get_id() == 4 or context.other_card:get_id() == 2 then
                return {
                    chips = card.ability.extra.chips,
                    xmult = card.ability.extra.xmult,
                    card = context.other_card,
                }
            end
        end
    end
}

SMODS.Joker {
    key = "highscorer",
    loc_txt = {
        name = "Highscorer",
        text = {
            "Gains {X:mult,C:white}X#1#{} Mult when you score",
            "over double the required score.",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)"
        }
    },
    config = { extra = { xmult_gain = 0.25, xmult = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult_gain, card.ability.extra.xmult } }
    end,
    rarity = 2,
    atlas = "ModdedJokers",
    pos = { x = 1, y = 0 },
    cost = 6,
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.round_eval then
            if G.GAME.chips / G.GAME.blind.chips >= 2.0 then
                card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.MULT,
                    message_card = card
                }
            end
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end
}



-- Joker Ideas
-- Joker that gives you "your score DIV needed score" in cash at the end of the round (rounded up)
-- Apple joker. Does nothing. When destroyed, gives polychrome to a random joker. 1/6 chance of being destroyed.
-- Golden Apple joker. Does nothing. When destroyed, gives mega polychrome (x10) to a random joker. 1/1000 change of being destroyed.
-- Orange joker. Levels up played hand. 1/8 change of disappearing.
-- (Legendary) Converts played number cards into enhanced aces
-- (Legendary) Alien Joker. Levels up played hand.

-- Spectral card Ideas
-- Delete two jokers, create legendary joker

-- Booster pack idea
-- 20$ booster pack with a single legendary joker
