# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://doc.scrapy.org/en/latest/topics/item-pipeline.html
from scrapy.exporters import CsvItemExporter


class NhlPipeline(object):
    def __init__(self):
        self.filename = 'nhldrafts.csv'

    def open_spider(self, spider):
        self.csvfile = open(self.filename, 'wb')
        self.exporter = CsvItemExporter(self.csvfile)
        #self.exporter.fields_to_export = ['entry', 'draft_year', 'draft_round', 'draft_pick', 'player', 'team', 'position', 'age_drafted', 'played_until', 'allpros', 'probowls', 'starter_seasons', 'career_avg_value', 'drafteam_avg_value', 'games']
        self.exporter.start_exporting()

    def close_spider(self, spider):
        self.exporter.finish_exporting()
        self.csvfile.close()

    def process_item(self, item, spider):
        self.exporter.export_item(item)
        return item
