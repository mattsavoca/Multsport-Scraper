from scrapy import Spider, Request
from nbapos.items import NbaposItem
import re

class NbaSpider(Spider):
	positions = ['g', 'gf', 'f', 'fg', 'fc', 'c', 'cf'] 
	years = range(1979, 2019)
	name = 'nbapos_spider'
	allowed_urls = ['https://www.basketball-reference.com/']
	start_urls = ['https://www.basketball-reference.com/play-index/draft_finder.cgi?request=1&year_min={}&year_max={}&college_id=0&pos_is_{}=Y&order_by=ws'.format(x, x, y) for x in range(1979,2019) for y in ['g', 'gf', 'f', 'fg', 'fc', 'c', 'cf']]     

	def parse(self, response):
		picks = response.xpath('//*[@id="stats"]/tbody/tr')

		for pick in picks:
			try:
				player_id = pick.xpath('.//td[@data-stat="player"]//@href').extract_first()
				player_id = re.findall('[a-zA-Z]+[\d]+', player_id)[0]
			except:
				player_id = ''
			
			try:
				position = pick.xpath('.//td[@data-stat="pos"]//text()').extract_first()
			except:
				position = ''

			print('*' * 10)
			print(player_id)
			print('*' * 10)

			item = NbaposItem()
			item['player_id'] = player_id
			item['position'] = position

			yield item
