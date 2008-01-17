#!/usr/bin/env ruby

def tidy(line)
	line.chomp!
	line.gsub!("/", "\\/")
	line.gsub!("?", "\\?")
	line.gsub!("+", "\\+")
	line.gsub!("\\", "\\\\")
	line.gsub!("*", "(.*)")

	if line =~ /^@@/
		line.gsub!("@@", "")
		return "- /#{line}/"
	else
		return "+ /#{line}/"
	end
end

def genlist(text)
	return text.split("\n").collect { |s| tidy(s) }.select { |s| s.length>0 }.join("\n")
end

def main
	s=gets
	while s
		puts tidy(s)

		s=gets
	end
end

if __FILE__==$0
	begin
		main
	rescue Interrupt => e
		nil
	end
end