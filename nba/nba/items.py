# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class NbaItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    entry = scrapy.Field()
    draft_pick = scrapy.Field()
    draft_year = scrapy.Field()
    player = scrapy.Field()
    player_id = scrapy.Field()
    team = scrapy.Field()
    team_id = scrapy.Field()
    college = scrapy.Field()
    seasons = scrapy.Field()
    games = scrapy.Field()
    minutes = scrapy.Field()
    win_shares = scrapy.Field()
    win_shares_per48 = scrapy.Field()
    bpm = scrapy.Field()
    vorp = scrapy.Field()