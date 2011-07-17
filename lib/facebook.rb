%w{yaml mechanize pp}.each{|l| require l}

class Facebook
  VERSION = "1.6"
  MOBILE_URL = "http://m.facebook.com/"
<<<<<<< HEAD
  SLEEP_TIME = 2 # Conservative?
  USER_AGENT = "iPhone" # Why the hell not?
  # For future (?) localisation 
  STRINGS = {:profile => /Profile/,
             :activity => "Activity",
             :status => "status",
             :photo => "photo",
             :remove_profile => "Remove",
             :wall => "Wall",
             :wall_to_wall => "Wall-to-Wall",
             :unlike => "Unlike",
             :delete_comment => "delete",
             :inbox => "Inbox",
             :delete_msg => "Delete",
             :remove_tag => "remove",
             :notes => /Notes/,
             :delete_note => "Delete",
             :photo_albums => /Photo albums/,
             :photo_delete => "Delete this photo.",
             :events => "Events",
             :past_events => "Past events",
             :remove_event => "Remove Event?"}
  
  class << self
    attr_reader :email, :password
    
    def setup(email, password)
      @email = email
      @password = password
      @a = Mechanize.new { |agent| agent.user_agent_alias = USER_AGENT }
      @profile = nil
      get_home
    end # setup
    
    def delete_wall_items
      puts "Proceeding with deletion of profile items"
      remove_count = nil
      while remove_count != 0 # As long as there are things to remove. Inelegant.
        profile = get_profile
        remove_count = 0 # For the exit condition
        # Is there a more compact way?
        patterns = [STRINGS[:activity],STRINGS[:status],STRINGS[:photo]]
        profile.links.find_all { |l| patterns.include?(l.text) }.each do |link|
          puts "Following link (#{link.text})"
          unlike_and_delete(link)
        end
        # We do an independent loop for the removing, so as to make sure 
        # everything is unliked and deleted first
        profile.links_with(:text => STRINGS[:remove_profile]).each do |link|
          puts "Removing item"
          remove_count = remove_count + 1
          remove(link)
        end
        puts "Moving on to next page..." unless remove_count == 0
      end
      puts "Done with profile items"
    end # delete_profile_items
    
    def delete_inbox_items
      puts "Proceeding with deletion of inbox items"
      delete_count = nil
      while delete_count != 0 # As long as there are things to delete. Inelegant.
        inbox = get_inbox
        delete_count = 0 # For the exit condition
        inbox.links_with(:text => STRINGS[:delete_msg]).each do |link|
          puts "Deleting inbox item"
          delete_count = delete_count + 1
          remove(link)
        end
        puts "Moving on to next page..." unless delete_count == 0
      end
    end # delete_inbox_items
    
    def delete_notes
      puts "Proceeding with deletion of notes"
      delete_count = nil
      while delete_count != 0 # As long as there are things to delete. Inelegant.
        notes = get_notes
        delete_count = 0 # For the exit condition
        notes.links_with(:text => STRINGS[:delete_note]).each do |link|
          puts "Deleting note"
          delete_count = delete_count + 1
          remove(link)
        end
        puts "Moving on to next page..." unless delete_count == 0
      end
    end # delete_notes
    
    def delete_albums_photos
      puts "Proceeding with deletion of photos from albums"
      delete_count = nil
      while delete_count != 0 # As long as there are things to delete. Inelegant.
        delete_count = 0 # For the exit condition
        my_albums = get_my_albums
        my_albums.links_with(:href=>/album.php/).each do |link|
          sleep(SLEEP_TIME)
          album = @a.click(link)
          album.links_with(:href=>/photo.php/).each do |l|
            sleep(SLEEP_TIME)
            photo = @a.click(l)
            unlike_and_delete(nil, photo)
            puts "Deleting photo"
            delete_count = delete_count + 1
            remove(photo.link_with(:text => STRINGS[:photo_delete]))
          end
        end
        puts "Moving on to next page..." unless delete_count == 0
      end
    end # delete_albums_photos
    
    def delete_past_events
      puts "Proceeding with removal of past events"
      remove_count = nil
      while remove_count != 0
        remove_count = 0
        past_events = get_past_events
        past_events.links_with(:href=>/\/event.php/).each do |link|
          sleep(SLEEP_TIME)
          event = @a.click(link)
          puts "Removing event"
          remove_count = remove_count + 1
          remove(event.link_with(:text => STRINGS[:remove_event]))
        end
        puts "Moving on to next page..." unless remove_count == 0
      end
    end # delete_past_events
    
    private
    
    def get_home
      @a.get(MOBILE_URL) do |page|
        sleep(SLEEP_TIME)
        @home = page.form_with(:action => "https://login.facebook.com/login.php?m=m") do |f|
          f.email = @email
          f.pass = @password
        end.submit
=======
  STRINGS = YAML.load_file('lib/links.en_us.yaml') # For future (?) localisation
  SLEEP_TIME_INTERVAL = [1.55, 2.45] # Conservative?
  USER_AGENT = "Opera/9.50 (J2ME/MIDP; Opera Mini/4.0.10031/298; U; en)"
  DEBUG = true
  attr_accessor :email, :password, :config
  
  def initialize(config)
    @config = config
    @email = config[:email]
    @password = config[:password]
    @a = Mechanize.new { |agent| agent.user_agent = USER_AGENT }
    @profile = nil
    get_home
  end
  
  # private
  
  ## Navigation
  
  def get_home
    @a.get(MOBILE_URL) do |page|
      sleep
      @home = page.form_with(:id => "login_form") do |f|
        f.email = @email
        f.pass = @password
      end.submit
    end
    if @config[:change_language]
      change_language
      sleep
      @home = @a.get(MOBILE_URL)
    end
    save_to_html_page("_home.html", @home) if DEBUG
    @home
  end # get_home
  
  def get_profile
    sleep
    @profile = @a.click(@home.link_with(:text => STRINGS[:profile]))
    save_to_html_page("_profile.html", @profile) if DEBUG
    @profile
  end # get_profile
  
  def get_wall # No referrer...
    sleep
    @wall = @a.get(MOBILE_URL + "wall.php?refid=17")
    save_to_html_page("_wall.html", @wall) if DEBUG
    @wall
  end # get_wall
  
  def get_bookmarks # No referrer...
    sleep
    @bookmarks = @a.get(MOBILE_URL + "bookmarks.php?refid=7")
    save_to_html_page("_bookmarks.html", @bookmarks) if DEBUG
    @bookmarks
  end # get_bookmarks
  
  def change_language(lang = STRINGS[:en_us_language])
    sleep
    language = @a.get(MOBILE_URL + "language.php?refid=31")
    save_to_html_page("_language.html", language) if DEBUG
    @a.click(language.link_with(:text => lang))
  end # change_language
  
  def get_inbox
    sleep
    inbox = @a.click(@home.link_with(:text => STRINGS[:inbox]))
    save_to_html_page("_inbox.html", inbox) if DEBUG
    inbox
  end # get_inbox
  
  def get_notes
    @bookmarks = get_bookmarks if @bookmarks == nil # No update needed if we already have it
    sleep
    notes = @a.click(@bookmarks.link_with(:text => STRINGS[:notes]))
    my_notes = @a.click(notes.link_with(:text => STRINGS[:my_notes]))
    save_to_html_page("_my_notes.html", my_notes) if DEBUG
    my_notes
  end # get_notes
  
  def get_my_albums
    @profile = get_profile if @profile == nil # No update needed if we already have it
    sleep
    my_albums = @a.click(@profile.link_with(:text => STRINGS[:photo_albums]))
    save_to_html_page("_my_albums.html", my_albums) if DEBUG
    my_albums
  end # get_my_albums
  
  def get_past_events
    sleep if @events == nil
    @events = @a.click(@home.link_with(:text => STRINGS[:events])) if @events == nil
    sleep
    past_events = @a.click(@events.link_with(:text => STRINGS[:past_events]))
    past_events
  end # get_past_events
  
  def unlike_and_delete(link, page = nil)
    sleep unless page != nil
    page = @a.click(link) unless page != nil
    page.links.each do |l|
      t = l.text.strip
      next unless t.length > 0
      if t==STRINGS[:unlike]
        puts "Unliking"
        sleep
        @a.click(l)
      elsif t==STRINGS[:delete_comment]
        puts "Deleting comment"
        remove(l)
>>>>>>> Not working yet - pre 1.6
      end
    end 
  end # unlike_and_delete
  
  def remove(link)
    sleep
    remove_confirm = @a.click(link)
    sleep
    remove_confirm.forms.first.click_button
  end # remove
  
  ## Utilities
  
  def sleep # Sleeps at least a minimum, then a random time within the interval
    Kernel.sleep(SLEEP_TIME_INTERVAL[0]+rand(SLEEP_TIME_INTERVAL[1]-SLEEP_TIME_INTERVAL[0]))
  end
  
  def save_to_html_page(filename, object)
    f = File.new(filename, "w")
    f.puts(object.parser.inner_html)
    f.close
  end
  
end
