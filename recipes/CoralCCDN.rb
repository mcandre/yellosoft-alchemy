# All credits for this one go to:
# LWU http://code.whytheluckystiff.net/mouseHole/browser/trunk/samples/coral.rb

require "rubygems"
require "hpricot"

@name="CoralCCDN"

- "digg.com/tools"
- "nyud.net"
- "coralcdn.org"
- "google.com"
- "yahoo.com"
- "web.archive.org"
- "duggback.com"
- "duggtrends.com"
- "propeller.com"

+ "slashdot.org"
+ "digg.com"
+ "reddit.com"
+ "beta.netscape.com"
+ "doggdot.us"
+ "mixx.com"
+ "hugg.com"
+ "meneame.net"
+ "tailrank.com"
+ "shoutwire.com"

def coralize(href)
	begin
		uri=URI.parse(href)
		url=uri.to_s

		raise if uri.port!=80 || in_blacklist?(url) || in_whitelist?(url)

		return href.gsub(uri.host, uri.host+".nyud.net:8080")
	rescue
		return href
	end
end

def apply(req, res)
	h=Hpricot(res.body)

	(h/"a[@href]").each { |link| 
		link["href"]=coralize(link["href"])
	}

	res.body=h.to_html
end