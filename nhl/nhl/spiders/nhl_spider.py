from scrapy import Spider, Request
from nhl.items import NhlItem
import re

class NhlSpider(Spider):
	years = range(1979, 2019)
	name = 'nhl_spider'
	allowed_urls = ['https://www.hockey-reference.com/']
	start_urls = ['https://www.hockey-reference.com/draft/NHL_{}_entry.html'.format(year) for year in years]

	def parse(self, response):
		draft_year = re.findall('\d+',response.xpath('//*[@id="content"]/h1/text()').extract_first())[0]
		picks = response.xpath('//*[@id="stats"]/tbody/tr[not(contains(@class, "thead"))]')

		entry = 1

		for pick in picks:
			draft_pick = pick.xpath('.//th[@data-stat="pick_overall"]//text()').extract_first()
			player = pick.xpath('.//td[@data-stat="player"]//text()').extract_first()
			team = pick.xpath('.//td[@data-stat="team_name"]//text()').extract_first()
			team_id =  picks.xpath('.//td[@data-stat="team_name"]//@href').extract_first()
			team_id = re.findall('\/[A-Z]+', team_id)[0][1:]
			try:
				player_id = pick.xpath('.//td[@data-stat="player"]//@href').extract_first()
				player_id = re.findall('[a-zA-Z]+[\d]+', player_id)[0]
			except:
				player_id = ''
			position = pick.xpath('.//td[@data-stat="pos"]//text()').extract_first()
			draft_age = pick.xpath('.//td[@data-stat="draft_age"]//text()').extract_first()
			played_until = pick.xpath('.//td[@data-stat="year_last"]//text()').extract_first() 
			games = pick.xpath('.//td[@data-stat="games_played"]//text()').extract_first() 
			points = pick.xpath('.//td[@data-stat="points"]//text()').extract_first() 
			plus_minus = pick.xpath('.//td[@data-stat="plus_minus"]//text()').extract_first()
			point_share = pick.xpath('.//td[@data-stat="ps"]//text()').extract_first()


			print('*' * 10)
			print(player)
			print('*' * 10)

			item = NhlItem()
			item['entry'] = entry
			item['draft_year'] = draft_year
			item['draft_pick'] = draft_pick
			item['player'] = player
			item['position'] = position
			item['player_id'] = player_id
			item['team'] = team
			item['team_id'] = team_id
			item['draft_age'] = draft_age
			item['played_until'] = played_until
			item['games'] = games
			item['points'] = points
			item['plus_minus'] = plus_minus
			item['point_share'] = point_share

			entry += 1

			yield item