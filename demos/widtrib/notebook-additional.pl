#!/usr/bin/perl
# -*- perl -*-

#
# $Id: notebook-additional.pl,v 1.2 2002/03/04 20:09:25 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 2002 Slaven Rezic. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: slaven.rezic@berlin.de
# WWW:  http://www.rezic.de/eserte/
#

# non-documented notebook configuration options and methods ...
# document them!

use Tk;
use Tk::NoteBook;

$top = new MainWindow;
$nb = $top->NoteBook(-background => "green",
		     -backpagecolor => "blue",
		     -bd => 3,
		     -cursor => "hand2",
		     -disabledforeground => "red",
		     -fg => "brown",
		     -focuscolor => "yellow",
		     -font => "Times 24",
		     -inactivebackground => "cyan",
		     -tabpadx => 24,
		     -tabpady => 5,
		    )->pack;
for (1..5) {
    my $f = $nb->add("add$_", -label => "tab $_");
    $f->configure(-bg => "green3");
    $f->Label(-text => "1234 - $_",-bg => "green3")->pack;
}

warn "dimensions of tab area: " . join(",", $nb->geometryinfo) . "\n"; 
warn "identify over first tab: " . $nb->identify(10,10) . "\n";
warn "identify over non-tab area: " . $nb->identify(10,200) . "\n";
warn "all pages: " . join(",",$nb->info('pages')) . "\n";
$nb->after(100,sub { warn "active tab: " . join(",",$nb->info('active')) . "\n"});
$nb->after(100,sub { warn "tab focus: " . join(",",$nb->info('focus')) . "\n"});
$nb->after(100,sub { warn "next tab focus: " . join(",",$nb->info('focusnext')) . "\n"});
$nb->after(100,sub { warn "prev tab focus: " . join(",",$nb->info('focusprev')) . "\n"});
$nb->move; # NYI
#$top->after(1000,sub { $nb->activate("add3") }); # internal
#$top->after(1000,sub { $nb->focus("add3") }); # internal

#$nb->configure(-relief => "ridge"); # sieht schlecht aus


MainLoop;

__END__
