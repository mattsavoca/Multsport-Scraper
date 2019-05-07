from scrapy import Spider, Request
from mlb.items import MlbItem
import re

class MlbSpider(Spider):
	years = [year for year in range(1979, 2019)]
	positions = ['INF', '2B', 'C', 'OF', '3B', 'SS', '1B', 'P']

	name = 'mlb_spider'
	allowed_urls = ['https://www.baseball-reference.com/']
	start_urls = ['https://www.baseball-reference.com/draft/?pos={}&year_ID={}&query_type=pos_year&from_type_jc=0&from_type_hs=0&from_type_4y=0&from_type_unk=0'.format(x, y) for x in positions for y in range(1979, 2019)]
	
	def parse(self, response):
		draft_year = response.xpath('//*[@id="draft_stats"]/tbody/tr[1]/th[@data-stat="year_ID"]//text()').extract_first()
		pos = response.xpath('//*[@id="content"]/h2[2]/text()').extract_first().strip()
		pos = re.findall('of .+',pos)[0][3:] 
		picks = response.xpath('//*[@id="draft_stats"]/tbody/tr[not(contains(@class, "thead"))]')

		entry = 1

		for pick in picks:
			draft_round = pick.xpath('.//td[@data-stat="draft_round"]//text()').extract_first()
			draft_pick = pick.xpath('.//td[@data-stat="overall_pick"]//text()').extract_first()
			draft_round_pick = pick.xpath('.//td[@data-stat="round_pick"]//text()').extract_first()
			team = pick.xpath('.//td[@data-stat="team_ID"]//text()').extract_first()
			team_id = pick.xpath('.//td[@data-stat="team_ID"]//@href').extract_first()
			team_id = re.findall('ID=[a-zA-Z]+', team_id)[0][3:]
			try:
				player = pick.xpath('.//td[@data-stat="player"]/a/text()').extract()
				player = [x for x in player if x not in 'minors'][0]
			except:
				player = pick.xpath('.//td[@data-stat="player"]//text()').extract_first()
				
			
			player_id = pick.xpath('.//td[@data-stat="player"]//@href').extract_first()
			try:
				player_id = re.findall('id=[a-zA-Z\d]+[-]*[a-zA-Z\d]*[-]*', player_id)[0][3:]
			except:
				try:
					player_id = re.findall('[a-zA-Z.]+[\d]+', player_id)[0]
				except:
					player_id = ''

			draft_age = pick.xpath('.//td[@data-stat="draft_age"]//text()').extract_first()
			war = pick.xpath('.//td[@data-stat="WAR"]//text()').extract_first()
			games_batting = pick.xpath('.//td[@data-stat="G_bat"]//text()').extract_first()
			games_pitching = pick.xpath('.//td[@data-stat="G_pitch"]//text()').extract_first()
			at_bats = pick.xpath('.//td[@data-stat="AB"]//text()').extract_first()
			ops = pick.xpath('.//td[@data-stat="onbase_plus_slugging"]//text()').extract_first()
			pitch_wins = pick.xpath('.//td[@data-stat="W"]//text()').extract_first()
			pitch_losses = pick.xpath('.//td[@data-stat="L"]//text()').extract_first()
			pitch_saves = pick.xpath('.//td[@data-stat="SV"]//text()').extract_first()
			whip = pick.xpath('.//td[@data-stat="whip"]//text()').extract_first()
			prospect_type = pick.xpath('.//td[@data-stat="from_type"]//text()').extract_first()
			last_school = pick.xpath('.//td[@data-stat="came_from"]//text()').extract_first()

			item = MlbItem()
			item['draft_year'] = draft_year
			item['draft_round'] = draft_round
			item['draft_pick'] = draft_pick
			item['draft_round_pick'] =  draft_round_pick
			item['player'] = player
			item['player_id'] = player_id
			item['team'] = team
			item['team_id'] = team_id
			item['position'] = pos
			item['war'] = war
			item['games_batting'] = games_batting
			item['games_pitching'] = games_pitching
			item['at_bats'] = at_bats
			item['ops'] = ops
			item['pitch_wins'] =  pitch_wins
			item['pitch_losses'] =  pitch_losses
			item['pitch_saves'] = pitch_saves
			item['whip'] = whip
			item['prospect_type'] = prospect_type
			item['last_school'] = last_school

			print('*' * 50)
			print(player)
			print('*' * 50)

			entry += 1

			yield item