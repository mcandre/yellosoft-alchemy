# Works just like GoogleCache

require "rubygems"
require "hpricot"

@name="WaybackMachine"

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

def getcache(href)
	begin
		uri=URI.parse(href)
		url=uri.to_s

		raise if in_blacklist?(url) || in_whitelist?(url)

		return "http://web.archive.org/web/*/#{url}"
	rescue
		return href
	end
end

def apply(req, res)
	begin
		h=Hpricot(res.body)

		(h/"a[@href]").each { |link| 
			link["href"]=getcache(link["href"])
		}

		res.body=h.to_html
	end
end