# GUIDeFATE
GUI Design From A Text Editor

Designing a graphical User interface requires knowledge of things like toolkit libraries, platform context etc.  At least I think it does.  I am a relatively new programmer in that I have near zero experience in GUI programming outside a web page.  So when I explore how to design an application which works outside a command line or a browser window, I feel tremendously out of my depth.  When I see the programming interfaces to these interfaces (QT, GTK, TK, ncurses, HTML) my bewilderment reaches even greater heights.

Sure there are clever things like wxGlade, and QT Designer etc.  These are tools that also require more skill than I possess; I am old and I can just about use a text editor as an IDE. So what is needed? I need a GUI designer that: -
1) Is simple, abstracting away from the underlying Toolkit/platform
2) Requires the simplest designer possible, with a visual representation of the interface
3) Allows the use use of multiple different GUI engines
4) Makes it easy recognise the interface elements by simply looking at the code

# So how might this work?

The user uses a text editor to design the window. Not new of course...text editors have had to be used to describe windows when other graphical representation methods were not possible.  As this is already a two dimensional data, it should be possible to convert this into an actual graphical interface through an interpreter.  The developer simply has to draw the interface in text and then program the interaction that is required.  From version 0.06 multiple backends are supported, version 0.11 has 7 backends.  For more details and working examples see the [wiki](https://github.com/saiftynet/GUIDeFATE/wiki)

# So how do I use it?

GUIDeFATE requires an available working backend with their relevant connecting Perl modules.  Different users will find different backends can be installed on their system.  For instance Wx may not install easily in Perl versions before 5.16 without a lot of effeort.  Tk installs relatively easily gnerally and Gtk, and Win32 (for windows machines) may be more easily installed.  Currently I dont feel it is robust enough for installation through CPAN...primarily because an attempt is made to install the backends which inariably fail because (e.g. Win32 is not available on Linux machines).  So what I would suggest is that you unzip the ["experimental environment"](https://github.com/saiftynet/GUIDeFATE/blob/master/TestEnvironment/GUIDeFATE-0.13%20Test%20Environment.zip) in your working folder and use 'use lib <path_to_lib>;" in your code.  The [example code](https://github.com/saiftynet/GUIDeFATE/wiki/Example-Programs) that comes with the folder will probably be the best way to see how it works.

# Textual Representation of a Graphical Interface

A simple ![hello world](https://github.com/saiftynet/dummyrepo/blob/main/GUIDeFATE/helloworld.png)
```
+------------------+
|T Message         |
+------------------+
|                  |
|  Hello World! !  |
|                  |
+------------------+
```
A Calculator
```
+------------------------+
|T  Calculator           |
+------------------------+
|  [__________________]  |
|  { V }{ % }{ C }{AC }  |
|  { 1 }{ 2 }{ 3 }{ + }  |
|  { 4 }{ 5 }{ 6 }{ - }  |
|  { 7 }{ 8 }{ 9 }{ * }  |
|  { . }{ 0 }{ = }{ / }  |
|  made with GUIdeFATE   |
+------------------------+
```

# Example PERL script

```perl
#!/usr/bin/perl -w
use strict;
use GUIDeFATE;
use GUIDeFATE qw<$frame>;
package Main;

my $window=<<END;
+------------------------+
|T  Calculator           |
+------------------------+
|  [                  ]  |
|  { V }{ % }{ C }{AC }  |
|  { 1 }{ 2 }{ 3 }{ + }  |
|  { 4 }{ 5 }{ 6 }{ - }  |
|  { 7 }{ 8 }{ 9 }{ * }  |
|  { . }{ 0 }{ = }{ / }  |
|  made with GUIdeFATE   |
+------------------------+

END

my $gui=GUIDeFATE->new($window [$backend],[$assist]); # API changed at version 0.06
# $backend is one of Wx(Default), Tk or Gtk
# $assist is one or  "q" (quiet, default), "v" (verbose) or "a" for Autogenerate
$gui->MainLoop;
```
This produces something like ![Calculator Screenshot](https://github.com/saiftynet/dummyrepo/blob/main/GUIDeFATE/calculator%20screenshot.png)

From Version 0.10 seven backends are supported. Wx, Tk, Gtk, Qt, Win32, HTML, Websocket.  These have different prerequisites.

* Perl5.8.8, Exporter, Wx, Wx::Perl::Imagick (for Wx interface)
* Perl5.8.8, Exporter, Tk, Image::Magick, Tk::JPEG, MIME::Base64 (for Tk interface)
* Perl5.8.8, Exporter, Glib, Gtk3 (for Gtk3 interface)
* Perl5.8.8, Exporter, Glib, Gtk2 (for Gtk2 interface)
* Perl5.8.8, Exporter, QtCore4, QtGui4 (for Qt interface)
* Perl5.8.8, Exporter, Win32, Imager (for Win32 interface)
* Perl5.8.8, Exporter (for HTML interface)
* Perl5.8.8, Exporter, Net::WebSocket::Server (for [WebSocket interface](https://github.com/saiftynet/GUIDeFATE/wiki/WebSocket-Applications) )

## Widgets

Supported Widgets: -

* Buttons
* Single text entry
* Multi-line Text entry
* ComboBoxes
* Menu (partial)
* Image panel
* [Timers](https://github.com/saiftynet/GUIDeFATE/wiki/Timers) also supported

More will be made as time goes along

NOTE:  Amajor change happens from version 0.13 onwards.  The Back-end modules (e.g. GFTk, GFWx, etc) will now reside in a folder called GUIDeFATE...this is reduce root namespace pollution making it easier to maintain.  This will be commited to CPAN in a few months.


