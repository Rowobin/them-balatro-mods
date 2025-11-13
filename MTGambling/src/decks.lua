--My personal atlas
SMODS.Atlas {
	-- Key for code to find it with
	key = "MTGDecks",
	-- The name of the file, for the code to pull the atlas from
	path = "MTG_Decks.png",
	-- Width of each sprite in 1x size
	px = 71,
	-- Height of each sprite in 1x size
	py = 95
}

SMODS.Back {
    key = 'commander',
    atlas = 'MTGDecks',
    pos = { x = 0, y = 0 },
    loc_txt = {
		name = 'Commander Deck',
		text = {
			"Start run with a random",
            "{C:edition}Negative{}, {C:attention}Eternal{} MTGG Joker"
		}
	},
    apply = function(self, back)
        local jokers_table = {}
        for key, value in pairs(G.P_CENTERS) do
            if string.find(key, "j_mtgg_") and value.rarity < 4 then
                jokers_table[#jokers_table+1] = key
            end
        end

        local random_joker = pseudorandom_element(jokers_table)

        if (random_joker) then
            delay(0.4)
            G.E_MANAGER:add_event(Event({
                func = function()
                    SMODS.add_card({set = 'Joker', area=G.jokers, key = random_joker, stickers={"eternal"}, edition="e_negative"})
                    return true
                end
            }))
            
        end

    end
}