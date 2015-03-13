[Sample scripts](http://yellosoft-alchemy.googlecode.com/svn/trunk/recipes/)

# What is Alchemy? #

  * an HTTP proxy
  * an Ad blocker
  * a web customizer

![http://i241.photobucket.com/albums/ff300/nilsmilo/alchemyscreen.png](http://i241.photobucket.com/albums/ff300/nilsmilo/alchemyscreen.png)

Like [Adblock Plus](http://adblockplus.org/en/), [Greasemonkey](http://www.greasespot.net/), [Stylish](http://userstyles.org/stylish/), and exactly like [MouseHole](http://code.whytheluckystiff.net/mouseHole/), Alchemy downloads web pages for you. Before you see them, your custom scripts chop the web code just the way you like it. Block ads, redesign pages, insert your own code. Alchemy is intended to be a [GreaseProxy](http://www.mnot.net/blog/2005/05/09/greasemonkey).

Don't want to type out a long URL? Use

![http://yubnub.org/images/yubnub.png](http://yubnub.org/images/yubnub.png)

or

![http://www.google.com/tour/services/lucky.gif](http://www.google.com/tour/services/lucky.gif)

to finish your URLs for you!

AdBlock and NoScript too slow?

Roll your own web-fu like this:

```
@name="Adblocker"

# these sites are blocked

+ "adserver.example.com"
+ "about.com"
+ "ad-flow"
+ "ad4cash"
+ "adfusion"

# these are not blocked

- "forbes.com"
- "nbc.com"

def apply(req, res)
    res.body=""
end
```

  1. Save it as something.rb in `recipes/`.
  1. Add the filename to the list of recipes in `default.yaml`.
  1. Start Alchemy by running `ruby alchemy.rb`.

The file does not have to have the same name as the `@name` inside the script. This way, Alchemy can manage scripts using their @name attribute as an identifier. Whether the scripts are loaded from flat files, string buffers, a database, what have you, they can be manipulated the same.

The filtering list can specify Strings or Regexps. They will be converted into Regexps either way.

Alchemy uses whitelists and blacklists in scripts to control which URLs scripts can be applied to. Here, the whitelist (+'s) contains URLs or URL parts that a script DOES apply to. A blacklist (-'s) contains URLs or URL parts that the script will NOT apply to.

# Dependencies #

Alchemy:
  * Ruby >= 1.8.6
  * Gems >= 0.9.4

Some of the recipes use:
  * Hpricot >= 0.6

Note: Thinking about replacing Hpricot with REXML, which is now included with Ruby.

# Troubleshooting #

While testing the ad blocker with Safari, ads never seemed to disappear. Finally, after emptying the cache and using [Cocoa Cookies](http://ditchnet.org/cocoacookies/) to delete all cookies, the ads stopped displaying. The ad blocker was working fine; the problem was that Safari had already stored the ads and was replaying them despite the fact that Alchemy had removed their content.

# Future #

The goal is to provide a public proxy that works with all web browsers, replacing Greasemonkey.

Eventually, we want Alchemy to have

  * web caching
  * full Greasemonkey, Userstyles support
  * web UI control panel
  * a multiuser account system
  * a dedicated proxy host, besides the personal or business self-run proxy (WordPress powerered versus WordPress.com).

Edit: Is caching useful for a multiuser server that constantly edits webpages according to each user's scripts?
Edit: Is caching useful for a personal proxy server when many browsers already cache webpages?