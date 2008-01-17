@name="GoogleTimmy"

require "rubygems"
require "hpricot"

+ "www.google"
+ "images.google"
+ "video.google"

def apply(req, res)
	h=Hpricot(res.body)

	(h/"input[@name]").each { |e|
		if e["name"]=="btnG"
			e["value"]="Timmah"
		elsif e["name"]=="btnI"
			e["value"]="Livin a Lie Livin a Lie"
		end
	}

	(h/"img").each { |e|
		puts "Source:" if $debug
		pp e["src"] if $debug && !e["src"].nil?

		if !e["src"].nil? && (e["src"] =~ /intl\/(.*)\/images\/(.*)\.gif/)
			e["src"]="http://i241.photobucket.com/albums/ff300/nilsmilo/timmah2.gif"
			e["width"]="342"
			e["height"]="110"
		end
	}

	out=h.to_html
	out.gsub!("/intl/en_com/images/logo_plain.png", "http://i241.photobucket.com/albums/ff300/nilsmilo/timmahintl.gif")
	out.gsub!("/images/nav_logo3.png", "http://i241.photobucket.com/albums/ff300/nilsmilo/timmahsmall2.gif")
	out.gsub!("/common/logo_video.jpg", "http://i241.photobucket.com/albums/ff300/nilsmilo/timmahvid2.gif")

	res.body=out
end