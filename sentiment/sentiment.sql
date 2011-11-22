
-- Twitter Sentiment API call
-- https://sites.google.com/site/twittersentimenthelp/api

CREATE OR REPLACE FUNCTION cgrant_sentiment(t text) RETURNS integer AS
$$
import json
import urllib
import urllib2
from urllib2 import urlopen

url = 'http://partners-v1.twittersentiment.appspot.com/api/bulkClassifyJson'
values = json.dumps({'data':[{'text': t }]})

req = urllib2.Request(url, values)
r = urllib2.urlopen(req).read()

j = json.loads(r)
return int(j['data'][0]['polarity'])
$$ LANGUAGE plpythonu;
