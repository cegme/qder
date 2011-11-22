
-- Twitter Sentiment API call
-- https://sites.google.com/site/twittersentimenthelp/api

CREATE OR REPLACE FUNCTION cgrant_sentiment(t text) RETURNS integer AS
$$
import json
import urllib
import urllib2
from urllib2 import urlopen

url = 'http://partners-v1.twittersentiment.appspot.com/api/bulkClassifyJson'
values = {'data':{'text': t }}
plpy.notice(str(values))

data = urllib.urlencode(values)
req = urllib2.Request(url, data)

r = urllib2.urlopen(req)

#j = json.loads(r.read())
#return int(j['data'][0]['polarity'])
return 0
$$ LANGUAGE plpythonu;
