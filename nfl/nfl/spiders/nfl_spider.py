from scrapy import Spider, Request
from nfl.items import NflItem
import re


class NflSpider(Spider):
	years = range(1979, 2019)
	name = 'nfl_spider'
	allowed_urls = ['https://www.pro-football-reference.com/']
	start_urls = ['https://www.pro-football-reference.com/years/{}/draft.htm'.format(year) for year in years]

	def parse(self, response):
		draft_year = response.xpath('//*[@id="meta"]/div[2]/h1/span[1]/text()').extract_first()
		picks = response.xpath('//*[@id="drafts"]/tbody/tr[not(@class="thead")]')

		entry = 1
		for pick in picks:

			draft_round = pick.xpath('.//th[@data-stat="draft_round"]//text()').extract_first()
			draft_pick = pick.xpath('.//td[@data-stat="draft_pick"]//text()').extract_first()
			player = pick.xpath('.//td[@data-stat="player"]//text()').extract_first()
			team = pick.xpath('.//td[@data-stat="team"]//@title').extract_first()
			team_id = pick.xpath('.//td[@data-stat="team"]//@href').extract_first()
			team_id = re.findall('teams\/[a-z]+', team_id)[0][6:]
			position = pick.xpath('.//td[@data-stat="pos"]//text()').extract_first()
			age_drafted = pick.xpath('.//td[@data-stat="age"]//text()').extract_first()
			played_until = pick.xpath('.//td[@data-stat="year_max"]//text()').extract_first()
			allpros = pick.xpath('.//td[@data-stat="all_pros_first_team"]//text()').extract_first()
			probowls = pick.xpath('.//td[@data-stat="pro_bowls"]//text()').extract_first()
			starter_seasons = pick.xpath('.//td[@data-stat="years_as_primary_starter"]//text()').extract_first()
			career_avg_value = pick.xpath('.//td[@data-stat="career_av"]//text()').extract_first()
			drafteam_avg_value = pick.xpath('.//td[@data-stat="draft_av"]//text()').extract_first()
			games = pick.xpath('.//td[@data-stat="g"]//text()').extract_first()
			try:
				player_id = pick.xpath('.//td[@data-stat="player"]//@href').extract_first()
				player_id = re.findall('[a-zA-Z]+[\d]+', player_id)[0]
			except:
				player_id = ''

			print('*' * 10)
			print(player)
			print('*' * 10)

			item = NflItem()
			item['entry'] = entry
			item['draft_year'] = draft_year
			item['draft_round'] = draft_round
			item['draft_pick'] = draft_pick
			item['player'] = player
			item['player_id'] = player_id
			item['team'] = team
			item['team_id'] = team_id
			item['position'] = position
			item['age_drafted'] = age_drafted
			item['played_until'] = played_until
			item['allpros'] = allpros
			item['probowls'] = probowls
			item['starter_seasons'] = starter_seasons
			item['career_avg_value'] = career_avg_value
			item['drafteam_avg_value'] = drafteam_avg_value
			item['games'] = games

			yield item

			entry += 1

			