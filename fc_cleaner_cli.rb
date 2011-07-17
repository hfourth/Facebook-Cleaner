#
# Facebook Cleaner
#
# Usage: 
#   ruby fb_cleaner.rb [email [password]]
#
# Requires: mechanize, highline
# Install these by doing: 
#   sudo gem install mechanize highline
#
# Use at you own risk. See LICENSE before any use.
# Check README.md for a few more details.
#

%w{rubygems yaml highline/import lib/facebook}.each{|l| require l}
HighLine.track_eof = false # Bug with Mechanize

abort "#{$0} [email [password]]" if ARGV.size > 2

say("\nFacebook Cleaner v#{Facebook::VERSION} - Use at your own risk\n\n")

if File.exists?("config.yaml")
  # Note: putting your email in a config file is fine, but putting your 
  # password isn't really... Use at you own risk
  CONFIG = Yaml.load_file("config.yaml") 
else
  # Note: change_language switches the language to EN (US)
  CONFIG = {:email => "", :password => "", :change_language => true}
end

case ARGV.size
  when 0
    CONFIG['email'] = ask("Enter your email:  ") if CONFIG['email'] == ""
    CONFIG['password'] = ask("Enter your password:  ") { |q| q.echo = "*" } if CONFIG['password'] == ""
  when 1
    CONFIG['email'] = ARGV[0]
    CONFIG['password'] = ask("Enter your password:  ") { |q| q.echo = "*" } if CONFIG['password'] == ""
  else
    CONFIG['email'] = ARGV[0]
    CONFIG['password'] = ARGV[1]
end

f = Facebook.new(CONFIG)

loop do
  choose do |menu|
    menu.choice :"Delete all wall items\n   (unlike and uncomment when possible)" do
      f.delete_wall_items
      say("Done!")
    end
    menu.choice :"Delete all inbox posts" do
      f.delete_inbox_items
      say("Done!")
    end
    menu.choice :"Delete all notes" do
      f.delete_notes
      say("Done!")
    end
    menu.choice :"Delete all photos from albums\n   (except Profile pictures)" do
      f.delete_albums_photos
      say("Done!")
    end
    menu.choice :"Remove invitations to past events" do
      f.delete_past_events
      say("Done!")
    end
    menu.choice :"Quit" do
      say("Nice doing business with you.")
      exit
    end
  end
end
