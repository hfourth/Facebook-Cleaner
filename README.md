Facebook Cleaner
================

This script is supposed to basically clean up your Facebook profile.
It's not perfect, and it's inelegant at best.

**USE AT YOUR OWN RISK** - see license before using it!

This is a take-over of [Netcrawler's unmaintained Facebook Cleaner][netcrawler].
Not all issues are fixed yet! There's been many change on Facebook since the last 
update.

What's the point?
-----------------

You want to “delete” your Facebook data (or at least flick a “do not show” switch),
while not entirely deleting your profile.

This script is an attempt to do just that. So far, you can take care of **wall items**, 
**inbox messages**, **notes**, **photos from albums**, and **past events**.
It will probably not work entirely; it will definitely break when Facebook changes
layout elements, as the method used is unfortunately not very robust (see How does it work?).

**Importantly**, using this script is possibly not compatible with the Terms and Conditions 
you have agreed to. While it is doing nothing more than crawling the mobile site at a rather 
slow pace, this script is to be used completely at your own risk. Possible consequences
include the destruction of all your data (that would be great actually) or getting 
kicked out altogether (less great).

How do I use it?
----------------
This script is tested using Ruby 1.8.7. It is very possible that it will fail
on any other version. 
You need to have the [mechanize][mechanize] and [highline][highline] gems 
installed.

    gem install mechanize highline

(You might need to use sudo.)

Get the project from GitHub (or download the tarball from above): 

    git clone http://github.com/hfourth/Facebook-Cleaner.git

Change directory, then you can do one of these:

    ruby fb_cleaner.rb my.email@example.com myS3CR3Tpassw0rd
    ruby fb_cleaner.rb my.email@example.com
    ruby fb_cleaner.rb
    
If you do not use the first method, you will be prompted for missing details.
Then, you can choose from a menu what you want to do next.

How does it work?
-----------------

The script crawls Facebook mobile using [Mechanize][mechanize].

For now, it looks for five things:

- **Wall items**: crawls your wall, finds activity, status, and photo links 
and when possible unlikes them and delete comments. Then it removes all items
from the feed and load the page again until there is nothing left to remove.
- **Inbox messages**: crawls your inbox, delete all messages from the page,
then load the page again until there is nothing left to delete.
- **Notes**: crawls your notes, delete all, etc.
- **Photos from Albums**: cannot delete albums themselves so far...
- **Past events**

Notice 
------

This is by no means a fully effective way to truly delete your data
from the platform. (Is this even possible?) In particular, it will not
delete wall posts from external applications (which do not show up in
the mobile version). With the current method, it is not possible to
tackle likes on other walls either.

From experience, some supposedly deleted data sometimes mysteriously 
reappears. Can anyone believe that your data is not immediately deleted
the instant you ask for it? No, of course. Diligent It must be a database 
redundancy bug. Anyone to [send a bug report](http://xkcd.com/258/) to 
our overlords?

Anyway, this is just a quickly hacked together way of getting rid of most 
of your data from _some_ prying eyes. All improvements are welcome! 
Fork, fork, fork.

Todo and bugs
-------------

- **MAJOR REFACTORING:** for 2.0, we want to create a graphical user interface
using [Shoes 3](http://shoesrb.com). We also want to be able to save a local copy
of the elements we delete.

- **TODO:** deleting tags in others' photos
- **TODO:** refactor photo deletion, as it is rather inefficient
- **BUG:** sometimes the script seems to stop and throw a 404. Launching the script 
again seems a good enough BUGFIX for now.

Changelog
---------

- **Version 1.6**: Refactored Netcrawler's code to get it working again.

- Version 1.5: Delete past events participation. A few bug corrected.
- Version 1.4: Delete photos from albums. Some refactoring using links_with.
- Version 1.3: Notes deletion.
- Version 1.2: Added a HighLine CLI.
- Version 1.1: Refactored and added inbox messages deletion.
- Version 1.0: Basic ugly, functional hack. 

[mechanize]:http://mechanize.rubyforge.org/mechanize/
[highline]:http://highline.rubyforge.org/
[netcrawler]:https://github.com/netcrawler/Facebook-Cleaner/
