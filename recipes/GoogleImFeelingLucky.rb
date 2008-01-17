@name="GoogleImFeelingLucky"

@search_uri=URI.parse("http://wwwgoogle.com/search?btnI&q=")

def apply(req, res)
	begin
		Socket.getaddrinfo(@search_uri.host, @search_uri.port)

		res.set_redirect(
			WEBrick::HTTPStatus::TemporaryRedirect.new,
			@search_uri.to_s+req.request_uri.host
		)
	rescue SocketError => e
		res.header["content-type"]="text/html"
		res.header.delete("content-encoding")
		res.body = <<END
<html>
<head><title>Error</title></head>
<body><h1>Error</h1>
<p>Cannot reach Google I\'m Feeling Lucky to search for <strong>#{req.request_uri.host}</strong>.</p>
</body>
</html>
END
	end
end