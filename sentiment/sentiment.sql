
-- Twitter Sentiment API call
-- https://sites.google.com/site/twittersentimenthelp/api

CREATE OR REPLACE FUNCTION cgrant_sentiment(t text) RETURNS char AS
$$
import json
import urllib
import urllib2
from urllib2 import urlopen

url = 'http://partners-v1.twittersentiment.appspot.com/api/bulkClassifyJson'
values = json.dumps({'data':[{'text': unicode(t, errors='ignore') }]}, encoding="utf-8")

req = urllib2.Request(url, values)
r = urllib2.urlopen(req).read()

j = json.loads(unicode(r, errors='ignore')) # We ignore unicode chars
val = int(j['data'][0]['polarity'])
if val == 0:
	return '-' # Negative
elif val == 4:
	return '+' # Positive 
else:
	return 'o' # Neutral 
$$ LANGUAGE plpythonu IMMUTABLE;
