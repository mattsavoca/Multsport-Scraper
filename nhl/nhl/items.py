# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class NhlItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    entry = scrapy.Field()
    draft_year = scrapy.Field()
    draft_pick = scrapy.Field()
    player = scrapy.Field()
    position = scrapy.Field()
    player_id = scrapy.Field()
    team = scrapy.Field()
    team_id = scrapy.Field()
    draft_age = scrapy.Field()
    played_until = scrapy.Field()
    games = scrapy.Field()
    points = scrapy.Field()
    plus_minus = scrapy.Field()
    point_share = scrapy.Field()