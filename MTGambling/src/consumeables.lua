SMODS.ConsumableType {
    key = 'support_spells',
    default = 'c_support_spells',
    loc_txt = {
 		name = 'Support Spell',
 		collection = 'Support Spells',
 		undiscovered = { -- description for undiscovered cards in the collection
 			name = 'Undiscovered',
 			text = { 'Acquire this spell during a run to discover it' },
 		},
 	},
    primary_colour = HEX('404040'), -- same colour is used for erebos_black, how to make colour a global variable?
    secondary_colour = HEX('404040'),
    collection_rows = { 3, 3 },
    shop_rate = 0
}

SMODS.Atlas {
	key = "TherosBD_support",
	path = "TherosBD_support.png",
	px = 71,
	py = 95
}

SMODS.Consumable {
    key = "erebos_favour",
    set = "support_spells",
    loc_txt = {
		name = 'Erebos\' favour',
		text = {
			"Lose {C:money}#1#${} and draw #1# at next draw.",
            "Whenever a card is {C:attention}destroyed{}",
            "increase the {C:money}cost{} and draw count by #2#."
		}
	},
    config = { extra = { money = 1, increase = 1 } },
    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.money, card.ability.extra.increase } }
	end,
	atlas = 'TherosBD_support',
    pos = {x = 0 , y = 0},
    cost = -1,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                card:juice_up(0.3, 0.5)
                ease_dollars(-card.ability.extra.money, true)
                SMODS.draw_cards(card.ability.extra.money)
                G.hand:sort()
                return true
            end
        }))
        delay(0.6)
    end,
    can_use = function(self, card)
        return G.GAME.dollars >= card.ability.extra.money
    end,
    calculate = function(self, card, context)
		if context.remove_playing_cards and context.removed and #context.removed > 0 then

			for key, value in pairs(context.removed) do
				card.ability.extra.money = card.ability.extra.money + card.ability.extra.increase
			end

			return {
				message = "Upgraded",
				colour = G.C.Black
			}
		end
	end
}