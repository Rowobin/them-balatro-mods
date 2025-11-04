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
    rarity = 4,
    atlas = "ModdedJokers",
    pos = { x = 0, y = 0 },
    cost = 8,
    blueprint_compat = true,
    eternal_compat = true,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 8 or context.other_card:get_id() == 4 or context.other_card:get_id() == 2 then
                return {
                    chips = card.ability.extra.chips,
                    xmult = card.ability.extra.xmult,
                    card = card,
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
    eternal_compat = true,
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

SMODS.Joker {
    key = "spaceorange",
    loc_txt = {
        name = "Space Orange",
        text = {
            "Increases level of first",
            "played hand. {C:green}#1# іn #2#{} chance",
            "this card is destroyed at",
            "end of round."
        }
    },
    config = { extra = { odds = 6 } },
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'spaceorange')
        return { vars = { numerator, denominator } }
    end,
    rarity = 2,
    atlas = "ModdedJokers",
    pos = { x = 2, y = 0 },
    cost = 5,
    blueprint_compat = true,
    eternal_compat = false,
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            if SMODS.pseudorandom_probability(card, 'spaceorange', 1, card.ability.extra.odds) then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = localize('k_extinct_ex')
                }
            else
                return {
                    message = localize('k_safe_ex')
                }
            end
        end
        if context.first_hand_drawn and not context.blueprint then
            local eval = function() return G.GAME.current_round.hands_played == 0 and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
        end
        if context.before and G.GAME.current_round.hands_played == 0 then
            return {
                level_up = true,
                message = localize("k_level_up_ex")
            }
        end
    end
}

SMODS.Joker {
    key = "coolerspaceorange",
    loc_txt = {
        name = "Cooler Space Orange",
        text = {
            "Increases level of played hand.",
            "{C:green}#1# іn #2#{} chance this card is",
            "destroyed at end of round."
        }
    },
    config = { extra = { odds = 1000 } },
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'coolerspaceorange')
        return { vars = { numerator, denominator } }
    end,
    rarity = 3,
    atlas = "ModdedJokers",
    pos = { x = 3, y = 0 },
    cost = 5,
    blueprint_compat = true,
    eternal_compat = false,
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            if SMODS.pseudorandom_probability(card, 'coolerspaceorange', 1, card.ability.extra.odds) then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = localize('k_extinct_ex')
                }
            else
                return {
                    message = localize('k_safe_ex')
                }
            end
        end
        if context.before then
            return {
                level_up = true,
                message = localize("k_level_up_ex")
            }
        end
    end
}

-- Joker Ideas
-- Joker that gives you "your score DIV needed score" in cash at the end of the round (rounded up)
-- Apple joker. Does nothing. When destroyed, gives polychrome to a random joker. 1/6 chance of being destroyed.
-- Golden Apple joker. Does nothing. When destroyed, gives mega polychrome (x15) to a random joker. 1/1000 change of being destroyed.
-- Orange joker. Levels up played hand. 1/8 change of disappearing.
-- (Legendary) Converts played cards into enhanced aces
-- (Legendary) Alien Joker. Levels up played hand.
-- (Common) Turn all played cards into Hearts/Spades/Diamonds/Clovers
-- (Uncommon) Selling a card or consumable increases a random hand's level
-- (Common) Rank up each scored card.
-- (Common) Non-scoring played cards get destroyed.
-- (Uncommon) Destroys face cards, non-face cards get +8 mult.
-- (Common) Deal with the devil: if played hand contains a 3, create a tarot card, if it contains a 6, create a spectral card.

-- Spectral card Ideas
-- Delete two jokers, create legendary joker
-- If next played hand is a flush, your entire deck will get that suit

-- Booster pack idea
-- 20$ booster pack with a single legendary joker

-- Deck Ideas
-- No discards, 5 Hands, start with undestroyable knife joker, 0 cash
-- Glass card deck
