# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class NflItem(scrapy.Item):
	entry = scrapy.Field()
	draft_year = scrapy.Field()
	draft_round = scrapy.Field()
	draft_pick = scrapy.Field()
	player = scrapy.Field()
	player_id = scrapy.Field()
	team = scrapy.Field()
	team_id = scrapy.Field()
	position = scrapy.Field()
	age_drafted = scrapy.Field()
	played_until = scrapy.Field()
	allpros = scrapy.Field()
	probowls = scrapy.Field()
	starter_seasons = scrapy.Field()
	career_avg_value = scrapy.Field()
	drafteam_avg_value = scrapy.Field()
	games = scrapy.Field()

