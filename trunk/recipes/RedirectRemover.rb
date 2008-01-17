# Based on https://addons.mozilla.org/en-US/firefox/addon/537

require "rubygems"
require "hpricot"

@name="RedirectRemover"

- "abp://"
- "file://"
- "javascript:"
- "web.archive.org"
- "babelfish.altavista.com"
- "google"
- "http://*.*.*.*/translate_c?"
- "jigsaw.w3.org"
- "validator.w3.org"
- "contentquality.com"
- "http://*.php.net/manual/add-note.php?"
- "rd.yahoo"
- "4players.de"
- "xiti.com"
- "pagead2.googlesyndication.com"
- "72.14.209.104"
- "ask.com"
- "img.bettersearch.zottmann.org"
- "v04.browsershots.org"
- "www.deutschepost.de"
- "payments.ebay.de"

+ "*"

@rot13a="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
@rot13b="nopqrstuvwxyzabcdefghijklmNOPQRSTUVWXYZABCDEFGHIJKLM"

def de_rot13(line)
	risp=""

	0.upto(line.length) { |i|
		t=line[i, 1]
		x=@rot13a.index(t)

		if x>-1
			risp+=@rot13b[x, 1]
		else
			risp+=t
		end
	}

	return risp
end

def match(href)
	# Decrypt ROT13
	if href =~ /(?:uggcf?|sgc)(?::\/\/|%3a%2f%2f|%253a%252f%252f)/i
		href=de_rot13(href)
	end

	x=/.+((?:https?|ftp)(?:(?::[^?]+[?][^=&]+=.+)|(?:(?:%3a|%253a|:)[^&]+)))/i
	if href !~ x
		# Try Base64
		y=/((?:[aS][FH]R[0U][cU][HF]?(?:DovL|M6Ly|CUz[QY]SUy[RZ]iUy[RZ]|MlM[02]ElM[mk]YlM[km])|[RZ][ln]R[Qw](?:Oi8v|JTN[Bh]JTJ[Gm]JTJ[Gm]))[a-zA-Z0-9+\/]+)/
		if href =~ y
			matches=href.scan(y)
			puts "Matches:"
			pp matches

			#return unescape(atob(RegExp.$1))
		else
			return false
		end
	end
end

def remove_redirect(href)
	begin
		puts "Href:"
		pp href

		if match(href)
			# ...
		end
	rescue
		return href
	end
end

def apply(req, res)
	h=Hpricot(res.body)

	(h/"a[@href]").each { |link|
		link["href"]=remove_redirect(link["href"])
	}

	res.body=h.to_html
end