--My personal atlas
SMODS.Atlas {
	-- Key for code to find it with
	key = "TherosBD",
	-- The name of the file, for the code to pull the atlas from
	path = "TherosBD.png",
	-- Width of each sprite in 1x size
	px = 71,
	-- Height of each sprite in 1x size
	py = 95
}

SMODS.Joker {
	key = 'daxos_blessed',
	loc_txt = {
		name = 'Daxos, Blessed By the Sun',
		text = {
			"Earn {C:money}$#1#{}",
			"whenever an {C:attention}Ace{}",
			"is scored"
		}
	},
	config = { extra = { money = 3 } },
	rarity = 2,
	atlas = 'TherosBD',
	blueprint_compat = true,
	pos = { x = 0, y = 0 },
	cost = 4,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.money } }
	end,
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			-- :get_id tests for the rank of the card. Other than 2-10, Jack is 11, Queen is 12, King is 13, and Ace is 14.
			if context.other_card:get_id() == 14 then
				-- Specifically returning to context.other_card is fine with multiple values in a single return value, chips/mult are different from chip_mod and mult_mod, and automatically come with a message which plays in order of return.
				return {
					dollars = card.ability.extra.money,
				}
			end
		end
	end
}

SMODS.Joker {
	key = 'tymaret_chosen',
	loc_txt = {
		name = 'Tymaret, Chosen from Death',
		text = {
			"If played hand is a {C:attention}Pair{}",
			"and only {C:attention}2{} cards",
			"destroy it and earn {C:money}$#1#{}",
			"for each destroyed card"
		}
	},
	config = { extra = { money = 1 } },
	rarity = 2,
	blueprint_compat = false,
	atlas = 'TherosBD',
	pos = { x = 1, y = 0 },
	cost = 5,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.money } }
	end,
	calculate = function(self, card, context)
		if not context.blueprint and context.destroying_card and context.scoring_name == "Pair" and #context.full_hand == 2 then
			return {
				dollars = card.ability.extra.money,
				remove = true
			}
		end
	end
}

SMODS.Joker {
	key = 'anax_hardened',
	loc_txt = {
		name = 'Anax, Hardened in the Forge',
		text = {
			"When a card is {C:attention}destroyed{}",
			"gain {C:mult}+#2#{} Mult",
			"if it was a {C:attention}face{} card",
			"gain {C:mult}+#3#{} Mult instead",
			"{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult)"
		}
	},
	config = { extra = { mult = 5 , increase = 5, face_increase = 10} },
	rarity = 2,
	atlas = 'TherosBD',
	blueprint_compat = true,
	pos = { x = 2, y = 0 },
	cost = 5,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult,  card.ability.extra.increase, card.ability.extra.face_increase} }
	end,
	calculate = function(self, card, context)
		if not context.blueprint and context.remove_playing_cards and context.removed and #context.removed > 0 then

			for key, value in pairs(context.removed) do
				if value:is_face(true) then
					card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.face_increase
				else
					card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.increase
				end
			end

			return {
				message = "Upgraded",
				colour = G.C.Mult
			}
		end

		if context.joker_main then
			return {
				mult = card.ability.extra.mult
			}
		end

	end
}

SMODS.Joker {
	key = 'renata_called',
	loc_txt = {
		name = 'Renata, Called to the Hunt',
		text = {
			"Cards that were played but",
			"not scored become {C:chips}Bonus Cards{}"
		}
	},
	config = { extra = {} },
	rarity = 2,
	atlas = 'TherosBD',
	blueprint_compat = false,
	pos = { x = 3, y = 0 },
	cost = 4,
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS.m_bonus
	end,
	calculate = function(self, card, context)
		if context.before then

			local activated = false
			local scored_lookup = {}
			for _, v in ipairs(context.scoring_hand) do
				scored_lookup[v.unique_val] = true
			end

			for key, to_bonus_card in pairs(context.full_hand) do
				if not scored_lookup[to_bonus_card.unique_val] and to_bonus_card.ability.set ~= "Enhanced" then
					to_bonus_card:set_ability('m_bonus',nil,true)
					G.E_MANAGER:add_event(Event({
					func = function()
						to_bonus_card:juice_up()
						return true
					end
					}))
					activated = true
				end
			end

			-- if scored_lookup[value.unique_val] and #SMODS.get_enhancements(value,false) == 0 then
			--		value:set_ability('m_bonus',nil,true)
			-- end

			if activated then
				return {
					message = 'Upgraded',
					colour = G.C.CHIPS
				}
			end
			
		end
	end
}

SMODS.Joker {
	key = 'callaphe_beloved',
	loc_txt = {
		name = 'Calaphe, Beloved of the Sea',
		text = {
			"Creates a {C:planet}Planet Card{} for",
			"a random {C:attention}Hand{} played this round"
		}
	},
	config = {
		extra = {
			hands_table = {},
			hand = nil
		}
  	},
	rarity = 2,
	atlas = 'TherosBD',
	blueprint_compat = true,
	pos = { x = 4, y = 0 },
	cost = 5,
	calculate = function(self, card, context)

		if context.joker_main then
			card.ability.extra.hands_table[#card.ability.extra.hands_table + 1] = context.scoring_name
			card.ability.extra.hand = pseudorandom_element(card.ability.extra.hands_table, self.key)
		end

		if context.end_of_round and context.cardarea == G.jokers then
			
			if G.consumeables.config.card_count < G.consumeables.config.card_limit then
				
				card.ability.extra.hands_table = {}

				local planet = Get_hand_planet(card.ability.extra.hand)

				return {
					message = 'Found ' .. planet.name,
					func = function()
						G.E_MANAGER:add_event(Event {
							func = function()
								if G.consumeables.config.card_limit > #G.consumeables.cards then
									play_sound('timpani')
									SMODS.add_card { key = planet.key }
								end
								return true
							end
						})
					end
				}

			end
			
		end

	end
}

SMODS.Joker {
	key = 'purphoros_bronze',
	loc_txt = {
		name = 'Purphoros, Bronze-Blooded',
		text = {
			"Creates a {C:edition}Polychrome{} copy of",
			"the most played card with a {C:red}Red Seal{}",
			"that is {C:attention}destroyed{} at round end",
			"{C:inactive}(Currently #1# played #2# times){}"
		}
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS.e_polychrome
		local card_name = "Unknown"
		if card.ability.extra.created_card and card.ability.extra.created_card.base then
			card_name = card.ability.extra.created_card.base.name
		end
		return { vars = { card_name, card.ability.extra.times_played } }
	end,
	config = {
		extra = {
			created_card = nil,
			times_played = 0,
		}
  	},
	rarity = 3,
	atlas = 'TherosBD',
	blueprint_compat = false,
	pos = { x = 5, y = 0 },
	cost = 8,

	calculate = function(self, card, context)

		local get_most_played_card = function ()

			local max_played_count = -1
            local max_played_card = G.playing_cards[0]
            for _, deck_card in pairs(G.playing_cards) do
                if deck_card.base.times_played > max_played_count then
                    max_played_count = deck_card.base.times_played
                    max_played_card = deck_card
                end
            end

			card.ability.extra.created_card = max_played_card
			card.ability.extra.times_played = max_played_count

		end


		if context.first_hand_drawn or context.card_added and context.card == card then

			get_most_played_card()
			
			if (card.ability.extra.created_card.ability and card.ability.extra.created_card.config.center.set == "Enhanced") then
				card.ability.extra.created_card = SMODS.create_card { set = "Base", enhancement = card.ability.extra.created_card.config.center.key, seal = "Red", edition = 'e_polychrome', rank = card.ability.extra.created_card.base.value, suit = card.ability.extra.created_card.base.suit,  area = G.discard }
			else
				card.ability.extra.created_card = SMODS.create_card { set = "Base", seal = "Red", edition = "e_polychrome",rank = card.ability.extra.created_card.base.value, suit = card.ability.extra.created_card.base.suit, area = G.discard }
			end

            G.playing_card = (G.playing_card and G.playing_card + 1) or 1
            card.ability.extra.created_card.playing_card = G.playing_card
            table.insert(G.playing_cards, card.ability.extra.created_card)

			return {
					message = 'Forged card!',
					func = function ()
						G.E_MANAGER:add_event(Event({
						func = function()
							G.hand:emplace(card.ability.extra.created_card)
							card.ability.extra.created_card:start_materialize()
							G.GAME.blind:debuff_card(card.ability.extra.created_card)
							G.hand:sort()
							if context.blueprint_card then
								context.blueprint_card:juice_up()
							else
								card:juice_up()
							end
							SMODS.calculate_context({ playing_card_added = true, cards = { card.ability.extra.created_card } })
							save_run()
							return true
						end
						}))
					end
			}
        end

		if context.end_of_round and context.cardarea == G.jokers and card.ability.extra.created_card then

			SMODS.destroy_cards(card.ability.extra.created_card,false,true)

			get_most_played_card()
			save_run()

			return {
				message = 'Card destroyed!',
			}

		end

	end
}

SMODS.Joker {
	key = 'thassa_deep',
	loc_txt = {
		name = 'Thassa, Deep-Dwelling',
		text = {
			"{C:attention}Destroy{} the first played hand",
			"and create it again {C:attention}after{} draw",
		}
	},
	config = { extra = { hand = {}, regenerate = false } },
	rarity = 3,
	blueprint_compat = true,
	atlas = 'TherosBD',
	pos = { x = 0, y = 1 },
	cost = 8,
	calculate = function(self, card, context)
		if not context.blueprint and context.destroy_card and context.cardarea == G.play and G.GAME.current_round.hands_played == 0 then

			card.ability.extra.hand[#card.ability.extra.hand+1] = context.destroying_card:save()

			if not card.ability.extra.regenerate then
				card.ability.extra.regenerate = true
			end

			return {
				remove = true
			}
		end

		if context.hand_drawn and card.ability.extra.regenerate then
			
			local blueprint = context.blueprint

			return {
				message = "Regenerated!",
				func = function()
					G.E_MANAGER:add_event(Event({
						func = function()
							local _first_dissolve = nil
							local _card = nil
							for _, create_card_table in ipairs(card.ability.extra.hand) do
								_card = Card(0, 0, G.CARD_W, G.CARD_H, G.P_CENTERS.j_joker, G.P_CENTERS.c_base)
								_card:load(create_card_table,nil)
								_card:hard_set_T()
								-- _card = copy_card(_create_card, nil, nil, G.playing_card)
								-- G.playing_card = (G.playing_card and G.playing_card + 1) or 1
								if (_card) then
									_card:add_to_deck()
									G.deck.config.card_limit = G.deck.config.card_limit + 1
									table.insert(G.playing_cards, _card)
									G.hand:emplace(_card)
									SMODS.recalc_debuff(_card)
									_card:start_materialize(nil, _first_dissolve)
									_first_dissolve = true
								end
							end
							SMODS.calculate_context({ playing_card_added = true, cards = card.ability.extra.hand })
							if (not blueprint) then
								card.ability.extra.hand = {}
								card.ability.extra.regenerate = false
							end
							save_run()
							return true
						end
					}))
				end
			}


		end

	end
}

SMODS.Joker {
	key = 'erebos_black',
	loc_txt = {
		name = 'Erebos, Black-Hearted',
		text = {
			"Create a {C:edition}negative{} {V:1}Erebos\' Favour{}",
			"when blind is selected"
		}
	},
	rarity = 3,
	blueprint_compat = true,
	atlas = 'TherosBD',
	pos = { x = 1, y = 1 },
	cost = 8,
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
		info_queue[#info_queue + 1] = G.P_CENTERS.c_mtgg_erebos_favour
		return { 
			vars = { 
				colours = {
					HEX('404040')
				}
			} 
		}
	end,
	calculate = function(self, card, context)
		if context.setting_blind then
				SMODS.add_card({area = G.consumeables, key = "c_mtgg_erebos_favour", edition = "e_negative"})
				return {
					message = "Favour Created!"
				}
		end
	end
}

SMODS.Joker {
	key = 'heliod_sun',
	loc_txt = {
		name = 'Heliod, Sun-Crowned',
		text = {
			"{X:mult,C:white}X#1#{} Mult per {C:attention}Gold{} card played.",
			"if no {C:attention}Gold{} cards were played",
			"{C:green}#2#{} in #3# chance of transforming",
			"each played card into a {C:attention}Gold{} card"
		}
	},
	rarity = 3,
	blueprint_compat = true,
	atlas = 'TherosBD',
	pos = { x = 2, y = 1 },
	cost = 8,
	config = { extra = { xmult = 0.50, gold_count = 0, odds = 2 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS.m_gold
		local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'j_mtgg_heliod_sun')
		return { vars = { card.ability.extra.xmult, numerator, denominator } }
	end,
	calculate = function(self, card, context)

		if context.before and not context.blueprint then
			
			card.ability.extra.gold_count = 0
			for _, played_card in pairs(context.full_hand) do
				if SMODS.has_enhancement(played_card, 'm_gold') then
					card.ability.extra.gold_count = card.ability.extra.gold_count + 1
				end
			end

			if card.ability.extra.gold_count == 0 then
				
				for _, scored_card in ipairs(context.full_hand) do
					if (SMODS.pseudorandom_probability(card, 'j_mtgg_heliod_sun', 1, card.ability.extra.odds)) then
						scored_card:set_ability('m_gold', nil, true)
						card.ability.extra.gold_count = card.ability.extra.gold_count + 1
						G.E_MANAGER:add_event(Event({
							func = function()
								scored_card:juice_up()
								return true
							end
						}))
					end
            	end

				if card.ability.extra.gold_count > 0 then
					return {
						message = "Blessed!",
                    	colour = G.C.MONEY
					}
				end

			end

		end

		if context.joker_main then
			return {
				xmult = 1 + card.ability.extra.xmult * card.ability.extra.gold_count
			}
		end

	end
}


function Get_hand_planet(hand)
	for _, v in ipairs(G.P_CENTER_POOLS.Planet) do
				if v.config and v.config.hand_type == hand then
					return v
				end
			end
	print("No planet found for hand " .. hand)
end