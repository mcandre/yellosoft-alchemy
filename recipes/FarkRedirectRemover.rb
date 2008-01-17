# Copied from http://userscripts.org/scripts/review/7487

require "rubygems"
require "hpricot"

@name="FarkRedirectRemover"

+ "fark.com"

def clean(href)
	return href.gsub(/http:\/\/go.fark.com\/cgi\/fark\/go\.pl\?i=([0-9]+)&l=/, "")
end

def apply(req, res)
	begin
		h=Hpricot(res.body)

		(h/"a[@href]").each { |link| 
			link["href"]=clean(link["href"])
		}

		res.body=h.to_html
	end
end