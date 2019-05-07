# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class MlbItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    draft_year = scrapy.Field()
    draft_round = scrapy.Field()
    draft_pick = scrapy.Field()
    draft_round_pick = scrapy.Field()
    team = scrapy.Field()
    team_id = scrapy.Field()
    player = scrapy.Field()
    player_id = scrapy.Field()
    position = scrapy.Field()
    war = scrapy.Field()
    games_batting = scrapy.Field()
    games_pitching = scrapy.Field()
    at_bats = scrapy.Field()
    ops = scrapy.Field()
    pitch_wins = scrapy.Field()
    pitch_losses = scrapy.Field()
    pitch_saves = scrapy.Field()
    whip = scrapy.Field()
    prospect_type = scrapy.Field()
    last_school = scrapy.Field()