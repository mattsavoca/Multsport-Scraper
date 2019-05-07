# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class NbaposItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    player_id = scrapy.Field()
    position = scrapy.Field()
