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
            "Draw #1#",
            "{C:attention}Destroy{} the #1# lowest rank cards in hand",
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
        if G.hand then
            return #G.hand.highlighted > 0 and G.GAME.dollars >= G.GAME.bankrupt_at + card.ability.extra.amount
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

