#!/usr/bin/env ruby
#  ___ ___         __ __         _______         ___ __
# |   |   |.-----.|  |  |.-----.|     __|.-----.'  _|  |_       .--.--.-----.
#  \     / |  -__||  |  ||  _  ||__     ||  _  |   _|   _|  __  |  |  |__ --|
#   |___|  |_____||__|__||_____||_______||_____|__| |____| |__| |_____|_____|
#
# == Summary ==
#
# Alchemy - A Greasemonkey proxy with Ruby user scripts
#
# == License ==
#
# GPLv3
#
# == Credits ==
#
# The big idea, and page modding techniques
#
#    Why the Lucky Stiff
#    http://code.whytheluckystiff.net/mouseHole/wiki/
#
# WEBrick adblocking proxy server
#
#    Paul Battley
#    http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/142072
#
# ASCII art
#
#    Ed Zahurak
#    http://www.chris.com/ascii/art/html/monsters.html
#
# == Requirements ==
#
# Ruby >= 1.8.6
# RubyGems >= 0.9.4
# Hpricot >= 0.6

V="0.0.1"
HOME_PAGE="http://code.google.com/p/yellosoft-alchemy/"

USAGE = <<END
Alchemy #{V} ( #{HOME_PAGE} )
Usage: alchemy [OPTIONS]

--help, -h:
    show usage information
--debug, -d:
    enable debug mode
--config, -c <file>:
    load specified configuration file
    default is "./default.yaml"
--address, -a <ip address>[:<port>]:
    run on specified ip address (and optional port)
--port, -p <port>:
    run on specified port (1023 < port < 65536)
--recipedir, -r <directory>:
    load scripts from directory
    default is "./recipes"
END

def usage
	puts USAGE
	exit
end

require "pp"

require "getoptlong"
require "rdoc/usage"

require "webrick/httpproxy"
require "webrick/httpservlet"

class TestServlet < WEBrick::HTTPServlet::AbstractServlet
end

class WEBrick::HTTPResponse
	attr_reader :header
end

class Recipe
	attr_accessor :name, :content_types, :whitelist, :blacklist

	# Items in whitelist and blacklist will be converted from Strings to regular expressions.

	def initialize
		@name="Name"
		@content_types=[Regexp.new("text/html")]
		@whitelist=[]
		@blacklist=[]
	end

	def tidy(line)
		line.gsub!("/", "\\/")
		line.gsub!("?", "\\?")
		line.gsub!("+", "\\+")
		line.gsub!("-", "\\-")
		line.gsub!("\\", "\\\\")
		line.gsub!(".", "\\.")
		line.gsub!("*", "(.*)")

		return line
	end

	def white(item)
		if item.class==Regexp
			@whitelist << item
		elsif item.class==String
			@whitelist << Regexp.new(tidy(item))
		end
	end

	def black(item)
		if item.class==Regexp
			@blacklist << item
		elsif item.class==String
			@blacklist << Regexp.new(tidy(item))
		end
	end

	def in_content_types?(content_type)
		if $debug
			temp=@content_types.select { |regex| content_type =~ regex }
			if temp.length>0
				puts "#{@name} Matching content: #{content_type}"
				pp temp
			end
		end

		return @content_types.any? { |regex| content_type=~ regex }
	end

	def in_whitelist?(url)
		if $debug
			temp=@whitelist.select { |regex| url =~ regex }
			if temp.length>0
				puts "#{@name} Matching whitelist: #{url}"
				pp temp
			end
		end

		return @whitelist.any? { |regex| url =~ regex }
	end

	def in_blacklist?(url)
		if $debug
			temp=@blacklist.select { |regex| url =~ regex }
			if temp.length>0
				puts "#{@name} Matching blacklist: #{url}"
				pp temp
			end
		end

		return @blacklist.any? { |regex| url =~ regex }
	end

	def applies?(req, res)
		if in_content_types?(res.header["content-type"])
			url=res.request_uri.to_s

			return !in_blacklist?(url) && in_whitelist?(url)
		else
			return false
		end
	end

	def apply(req, res)
	end

	def run(req, res)
		begin
			apply(req, res)
		end

		if !res.nil? && !res.body.nil?
			res.header["content-length"]=res.body.length
		end
	end

	def self.load(stream)
		recipe=new
		code=stream.read
		stream.close

		code=code.split("\n").collect { |line|
			line.gsub(/\A\+/, "white").gsub(/\A\-/, "black")
		}.join("\n")

		recipe.instance_eval code

		# Convert all strings into regexes
		recipe.content_types=recipe.content_types.collect { |e| Regexp.new(e) }

		return recipe
	end
end

class WorkShop
	attr_accessor :directory, :recipes, :search, :unzip

	def initialize(settings)
		reload(settings)
	end

	def reload(settings)
		@directory=settings["recipedir"] || ""
		@recipes=[]

		raise "#{@directory} does not exist!" unless FileTest.exists?(@directory)

		settings["recipes"].each { |filename|
			f=open(@directory+filename, "r")
			begin
				@recipes << Recipe::load(f)
				puts "loaded #{filename}"
			rescue LoadError, SyntaxError => e
				puts "Could not load #{filename}"
				raise e if $debug
			end
		}

		r=nil
		begin
			r=Recipe::load(open(@directory+"/"+settings["search"]))
			@search=r
		rescue
			@search=Recipe.new
		end

		r=nil
		begin
			r=Recipe::load(open(@directory+"/"+settings["unzip"]))
			@unzip=r
		rescue
			@unzip=Recipe.new
		end

		puts "reloaded recipes"
		pp @recipes if $debug
	end
end

class RedirectingProxyServer < WEBrick::HTTPProxyServer
	attr_accessor :workshop

	def initialize(config)
		@workshop=WorkShop.new(config[:settings])
		config.delete(:settings)
		super
	end

	def service(req, res)
		begin
			super(req, res)
		rescue WEBrick::HTTPStatus::Status => e
			puts "redirecting to search"

			@workshop.search.run(req, res)
		end
	end
end

class AlchemyServer
	def initialize(settings)
		begin
			@server=RedirectingProxyServer.new(
				:settings => settings,
				:BindAddress => settings["host"],
				:Port => settings["port"],
				:ProxyVia => false,
				:ProxyContentHandler => method(:handler),
				:AccessLog => [] # suppresses log messages
			)

			# testing out servlets
			@server.mount("/", TestServlet)

		rescue Errno::EADDRNOTAVAIL => e
			raise "Error: Cannot assign address"
		end
	end

	def handler(req, res)
		@server.workshop.unzip.run(req, res)

		url=req.request_uri.to_s

		@server.workshop.recipes.each { |recipe|
			if recipe.applies?(req, res)
				puts "running #{recipe.name}"
				recipe.run(req, res)
			end
		}
	end

	def start
		@server.start
	end

	def shutdown
		@server.shutdown
	end
end

$debug=false

DEFAULTS={
	"host" => "localhost",
	"port" => 8080,
	"unzip" => "Unzipper.rb",
	"search" => "GoogleSearch.rb",
	"config" => File.dirname($0)+"/default.yaml",
	"recipedir" => File.dirname($0)+"/recipes/",
	"recipes" => []
}

def load_settings(stream, settings)
	require "yaml"

	YAML::load(stream).each { |name, string|
		settings[name]=string
	}
end

class GetoptLong
	alias :old_to_a :to_a

	# Detour around Getoptlong#each's destructive nature.
	def export
		options={}
		self.each { |k, v|
			options[k]=v
		}

		return options
	end
end

def main
	settings=DEFAULTS.dup

	begin
		opts=GetoptLong.new(
			["--help", "-h", GetoptLong::NO_ARGUMENT],
			["--debug", "-d", GetoptLong::NO_ARGUMENT],
			["--config", "-c", GetoptLong::REQUIRED_ARGUMENT],
			["--address", "-a", GetoptLong::REQUIRED_ARGUMENT],
			["--port", "-p", GetoptLong::REQUIRED_ARGUMENT],
			["--recipedir", "-r", GetoptLong::REQUIRED_ARGUMENT]
		)

		opts=opts.export

		if opts["--config"]
			settings["config"]=opts["--config"]
		end

		begin
			open(settings["config"]) { |f|
				load_settings(f, settings)
			}

			puts "loaded config" if $debug
		rescue Errno::ENOENT => e
			puts "Could not load config"
		end

		# Command line options override settings loaded from config file.

		opts.each { |option, value|
			case option
				when "--help"
					raise
				when "--debug"
					$debug=true
				when "--address"
					host=value

					if host.include?(":")
						host, port=host.split(":")
						port=port.to_i
						raise if port<1024 or port>65535
						settings["port"]=port
					end
					settings["host"]=host
				when "--port"
					port=value.to_i
					raise if port<1024 or port>65535
					settings["port"]=port
				when "--recipedir"
					settings["recipedir"]=value
			end
		}
	rescue
		usage
	end

	puts "Settings:" if $debug
	pp settings if $debug

	puts "starting on #{settings["host"]}:#{settings["port"]}"

	server=AlchemyServer.new(settings)
	%w[INT HUP].each { |signal| trap(signal) { server.shutdown } }
	server.start
end

if __FILE__==$0
	begin
		main
	rescue Interrupt => e
		nil
	rescue RuntimeError => e
		puts e.message
	end
end
