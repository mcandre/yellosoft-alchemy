# From http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/142072

require "zlib"
require "stringio"

@name="Unzipper"

def apply(req, res)
	if res.header["content-encoding"]=="gzip"
		res.body=Zlib::GzipReader.new(StringIO.new(res.body)).read

		res.header["content-encoding"]="text/html"
	end
end