#!/usr/bin/env ruby

require "open-uri"

def clean(line)
	return "" if line =~ /^\[/
	return "" if line =~ /^!/

	line.gsub!(/\$(.*)/, "")
	line.gsub!("|", "")

	return line
end

def getlist
	begin
		data=open("http://easylist.adblockplus.org/adblock_rick752.txt").read
		data=data.split("\n").collect { |s| clean(s) }.select { |s| s.length>0 }.join("\n")

		return data
	rescue
		raise "Error: Could not connect"
	end
end

def main
	puts getlist
end

if __FILE__==$0
	begin
		main
	rescue RuntimeError => e
		puts e
	end
end