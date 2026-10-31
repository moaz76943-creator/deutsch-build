import json, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tool'))
from content_quality_gate import review_batch, filter_queue


def _write(p,d): p.write_text(json.dumps(d,ensure_ascii=False),encoding='utf-8')
def _item():
 return {'id':'w1','german':'lernen','arabic':'يتعلم','sentence':'Ich lerne.','sentenceAr':'أنا أتعلم.','topic':'تعلم','skill':'recall','article':'','plural':'','accepted':['lernen']}
def _batch(): return {'version':1,'languageCode':'de','contentItems':[_item()], 'verbConjugations':[], 'audio':[]}

def test_review_report_exposes_structured_queue_items(tmp_path):
 p=tmp_path/'b.json'; _write(p,_batch())
 report=review_batch(p)
 assert report['queue']['summary']['warning']==1
 item=report['queue']['items'][0]
 assert item['severity']=='warning'
 assert item['category']=='audio'
 assert item['contentId']=='w1'
 assert item['field']=='audio'
 assert item['code']=='missing_audio'

def test_review_report_orders_errors_before_warnings(tmp_path):
 p=tmp_path/'b.json'; d=_batch(); d['contentItems'][0]['arabic']=''; _write(p,d)
 report=review_batch(p)
 assert report['queue']['items'][0]['severity']=='error'
 assert report['queue']['items'][0]['category']=='content'
 assert report['queue']['items'][0]['field']=='arabic'
 assert report['queue']['items'][0]['code']=='required'

def test_review_queue_can_filter_by_severity_and_category(tmp_path):
 p=tmp_path/'b.json'; d=_batch(); d['contentItems'][0]['arabic']=''; _write(p,d)
 report=review_batch(p)
 filtered=filter_queue(report['queue'], severity='error', category='content')
 assert len(filtered)==1
 assert filtered[0]['contentId'] is None or filtered[0]['contentId']=='w1'
