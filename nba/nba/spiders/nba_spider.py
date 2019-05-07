from scrapy import Spider, Request
from nba.items import NbaItem
import re

class NbaSpider(Spider):
	years = range(1979, 2019)
	name = 'nba_spider'
	allowed_urls = ['https://www.basketball-reference.com/']
	start_urls = ['https://www.basketball-reference.com/draft/NBA_{}.html'.format(year) for year in years]

	def parse(self, response):
		draft_year = response.xpath('//*[@id="meta"]/div[2]/h1/span[1]/text()').extract_first()
		picks = response.xpath('//*[@id="stats"]/tbody/tr[not(contains(@class, "thead"))]')

		entry = 1

		for pick in picks:
			draft_pick = pick.xpath('.//td[@data-stat="pick_overall"]//text()').extract_first()
			player = pick.xpath('.//td[@data-stat="player"]//text()').extract_first()
			team = pick.xpath('./td[@data-stat="team_id"]//@title').extract_first()
			team_id =  picks.xpath('.//td[@data-stat="team_id"]//@href').extract_first()
			team_id = re.findall('\/[A-Z]+', team_id)[0][1:]
			try:
				player_id = pick.xpath('.//td[@data-stat="player"]//@href').extract_first()
				player_id = re.findall('[a-zA-Z]+[\d]+', player_id)[0]
			except:
				player_id = ''
			college = pick.xpath('.//td[@data-stat="college_name"]//text()').extract_first()
			seasons = pick.xpath('.//td[@data-stat="seasons"]//text()').extract_first()
			games = pick.xpath('.//td[@data-stat="g"]//text()').extract_first()
			minutes = pick.xpath('.//td[@data-stat="mp"]//text()').extract_first()
			win_shares = pick.xpath('.//td[@data-stat="ws"]//text()').extract_first()
			win_shares_per48 = pick.xpath('.//td[@data-stat="ws_per_48"]//text()').extract_first()
			bpm = pick.xpath('.//td[@data-stat="bpm"]//text()').extract_first()
			vorp = pick.xpath('.//td[@data-stat="vorp"]//text()').extract_first()

			print('*' * 10)
			print(player)
			print('*' * 10)

			item = NbaItem()
			item['entry'] = entry
			item['draft_pick'] = draft_pick
			item['draft_year'] = draft_year
			item['player'] = player
			item['team'] = team
			item['team_id'] = team_id
			item['player_id'] = player_id
			item['college'] = college
			item['seasons'] = seasons
			item['games'] = games
			item['minutes'] = minutes
			item['win_shares'] = win_shares
			item['win_shares_per48'] = win_shares_per48
			item['bpm'] = bpm
			item['vorp'] = vorp

			entry += 1

			yield item
