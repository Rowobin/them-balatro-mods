SMODS.ConsumableType {
    key = 'spells',
    default = 'c_spells',
    loc_txt = {
 		name = 'Spell',
 		collection = 'Spells',
 		undiscovered = { -- description for undiscovered cards in the collection
 			name = 'Undiscovered',
 			text = { 'Acquire this spell during a run to discover it' },
 		},
 	},
    primary_colour = HEX('ff3333'),
    secondary_colour = HEX('ff3333'),
    collection_rows = { 4, 3 },
    shop_rate = 4
}

SMODS.Atlas {
	key = "TherosBD_spells",
	path = "TherosBD_spells.png",
	px = 71,
	py = 95
}

SMODS.Consumable {
    key = "shatter_sky",
    set = "spells",
    loc_txt = {
		name = 'Shatter The Sky',
		text = {
            "{C:attention}Destroy{} all cards in hand",
            "with rank #1# or lower",
		}
	},
    config = { extra = { limit_rank = 4 } },
    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.limit_rank } }
	end,
	atlas = 'TherosBD_spells',
    pos = {x = 0 , y = 0},
    cost = 3,
    use = function(self, card, area, copier)

        local destroy_cards = {}

        for _, playing_card in ipairs(G.hand.cards) do 
            if playing_card:get_id() <= card.ability.extra.limit_rank then
                destroy_cards[#destroy_cards+1] = playing_card
            end
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                return true
            end
        }))
        delay(0.2)

        SMODS.destroy_cards(destroy_cards)
    end,
    can_use = function(self, card)
        return G.hand and #G.hand.cards > 0
    end
}

local oldcreatecard = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    if G.GAME.mtgg_next_shop_uncommon_joker and key_append == 'sho' then
        _type, _rarity = 'Joker', 'Uncommon'
        G.GAME.mtgg_next_shop_uncommon_joker = false
    end
    return oldcreatecard(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
end

SMODS.Consumable {
    key = "idyllic_tutor",
    set = "spells",
    loc_txt = {
		name = 'Idyllic Tutor',
		text = {
            "When used, next shop",
            "includes an {C:green}Uncommon{} Joker"
		}
	},
	atlas = 'TherosBD_spells',
    pos = {x = 1 , y = 0},
    cost = 2,
    use = function(self, card, area, copier)

        G.GAME.mtgg_next_shop_uncommon_joker = true

    end,
    can_use = function (self, card)
        return true
    end
}

SMODS.Consumable {
    key = "funeral_rites",
    set = "spells",
    loc_txt = {
		name = 'Funeral Rites',
		text = {
            "{C:blue}Draw{} #1#",
            "{C:attention}Destroy{} the #1# lowest",
            "rank cards in hand",
            "Lose {C:money}#1#${}"
		}
	},
	atlas = 'TherosBD_spells',
    pos = {x = 2 , y = 0},
    config = { extra = { amount = 2 } },
    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.amount } }
	end,
    cost = 2,
    use = function(self, card, area, copier)

        SMODS.draw_cards(card.ability.extra.amount)

        delay(0.5)
        
        local temp_hand = {}
        for _, playing_card in ipairs(G.hand.cards) do temp_hand[#temp_hand + 1] = playing_card end
        table.sort(temp_hand,
            function(a, b)
                return a:get_id() < b: get_id()
            end
        )

        local destroyed_cards = {}
        for i = 1, card.ability.extra.amount do destroyed_cards[#destroyed_cards + 1] = temp_hand[i] end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        SMODS.destroy_cards(destroyed_cards)

        delay(0.5)
        ease_dollars(-card.ability.extra.amount)
        delay(0.3)

    end,
    can_use = function (self, card)
        if G.hand and G.hand.cards then
            return G.GAME.blind and G.GAME.blind.chips > 0 and G.GAME.dollars >= G.GAME.bankrupt_at + card.ability.extra.amount
        end
        return false
    end
}

SMODS.Consumable {
    key = "agonizing_remorse",
    set = "spells",
    loc_txt = {
		name = 'Agonizing Remorse',
		text = {
            "Destroy #1# selected card",
            "Gain {C:money}#1#${}"
		}
	},
	atlas = 'TherosBD_spells',
    pos = {x = 3 , y = 0},
    config = { extra = { amount = 1 } },
    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.amount } }
	end,
    cost = 2,
    use = function(self, card, area, copier)

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                SMODS.destroy_cards(G.hand.highlighted)
                return true
            end
        }))

        ease_dollars(card.ability.extra.amount)

    end,
    can_use = function (self, card)
        return G.hand and #G.hand.highlighted == card.ability.extra.amount
    end
}

SMODS.Consumable {
    key = "sweet_oblivion",
    set = "spells",
    loc_txt = {
		name = 'Sweet Oblivion',
		text = {
            "{C:attention}Destroy{} the top {C:blue}#1#{}",
            "cards of the deck"
		}
	},
	atlas = 'TherosBD_spells',
    pos = {x = 4 , y = 0},
    config = { extra = { amount = 4 } },
    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.amount } }
	end,
    cost = 2,
    use = function(self, card, area, copier)

        local destroy_cards = {}
        if G.deck then

            local destroy_amount = card.ability.extra.amount
            if #G.deck.cards < destroy_amount then
                destroy_amount = #G.deck.cards
            end

            for i = 1, card.ability.extra.amount, 1 do
                destroy_cards[#destroy_cards+1] = G.deck.cards[i]
            end
        end
        

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                SMODS.destroy_cards(destroy_cards)
                return true
            end
        }))


    end,
    can_use = function (self, card)
        if G.deck and G.deck.cards then
            return G.GAME.blind and G.GAME.blind.chips > 0
        end
        return false
    end
}

local evaluate_play_ref = G.FUNCS.evaluate_play

function G.FUNCS:evaluate_play(e)
    evaluate_play_ref(e)

    local play_score = G.GAME.chips + math.floor(hand_chips*mult)
    if (not G.GAME.mtgg_best_hand or G.GAME.mtgg_best_hand.best_score < play_score) then
        G.GAME.mtgg_best_hand = {best_score = play_score, cards = {}}
        for _, card in pairs(G.play.cards) do
            G.GAME.mtgg_best_hand.cards[#G.GAME.mtgg_best_hand.cards+1] = card.unique_val
        end
    end

end

SMODS.Consumable {
    key = "sea_gods_scorn",
    set = "spells",
    loc_txt = {
		name = 'Sea God\'s Scorn',
		text = {
            "{C:blue}Draw{} the {C:attention}highest{} score {C:blue}hand{}",
            "of the previous round"
		}
	},
	atlas = 'TherosBD_spells',
    pos = {x = 5 , y = 0},
    cost = 3,
    use = function(self, card, area, copier)

        local temp_hand = {}
        for _, playing_card in ipairs(G.GAME.mtgg_best_hand.cards) do temp_hand[#temp_hand + 1] = playing_card end

        for key, deck_card in ipairs(G.deck.cards) do
            for _, best_card in pairs(temp_hand) do
                if deck_card.unique_val == best_card then
                    --[[ print("---- Found highest score card ----")
                    print(deck_card.base.value)
                    print(deck_card.base.suit) ]]
                    draw_card(G.deck,G.hand, 100,'up', true,deck_card)
                end
            end
        end

    end,
    can_use = function (self, card)
        if G.hand and G.hand.cards then
            return G.GAME.blind and G.GAME.blind.chips > 0
        end
        return false
    end
}


