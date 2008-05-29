@name="GoogleMySearchFundsRedirector"

+ "www.google.co.uk"

def apply(req, res)
	parts=req.request_uri.to_s.split("http://www.google.co.uk/search?hl=en&q=")
	if parts.length>1
		query=parts[1]

		new_google="http://www.google.com/search?q="+query

		res.set_redirect(
			WEBrick::HTTPStatus::TemporaryRedirect.new,
			new_google
		)
	end
end