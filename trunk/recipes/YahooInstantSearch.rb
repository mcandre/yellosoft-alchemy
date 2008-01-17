require "open-uri"

require "rubygems"
require "hpricot"

@name="YahooInstantSearch"

@search_uri=URI.parse("http://search.yahoo.com/xml/i?p=")

def apply(req, res)
	begin
		Socket.getaddrinfo(@search_uri.host, @search_uri.port)

		data=open(@search_uri.to_s+req.request_uri.host).read

		data=data.gsub("<![CDATA[", "")
		data=data.gsub("]]>", "")

		h=Hpricot(data)
		link=h.at("a")

		# Warning: if very often the case!
		raise "No results" if link.nil?

		url=link[:href]

		res.set_redirect(
			WEBrick::HTTPStatus::TemporaryRedirect.new,
			url
		)
	rescue RuntimeError => e
		res.header["content-type"]="text/html"
		res.header.delete("content-encoding")
		res.body = <<END
<html>
<head><title>Error</title></head>
<body><h1>Error</h1>
<p>Yahoo! Instant Search cannot be reached or has no results for <strong>#{req.request_uri.host}</strong>.</p>
</body>
</html>
END
	end
end