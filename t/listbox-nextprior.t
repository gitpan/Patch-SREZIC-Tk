#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: listbox.t,v 1.2 2002/02/19 22:02:40 eserte Exp $
# Author: Slaven Rezic
#

use strict;

BEGIN { $Patch::SREZIC::Tk::VERBOSE = 0 }
use Patch::SREZIC::Tk;
use Tk;

BEGIN {
    if (!eval q{
	use Test;
	1;
    }) {
	print "# tests only work with installed Test module\n";
	print "1..1\n";
	print "ok 1\n";
	exit;
    }
}

BEGIN { plan tests => 2 }

my $mw = tkinit;
my $lb = $mw->Scrolled("Listbox", -scrollbars => "e")->pack;
$lb->insert("end", 0..100);
$lb->activate(0);
$lb->focus;
$lb->after(300, sub {
	       $lb->update;
	       ok($lb->index("active"), 0);
	       $lb->Subwidget("scrolled")->eventGenerate("<Next>");
	       $lb->update;
	       ok($lb->index("active"), 8);
	       $mw->destroy;
	   });
$mw->Popup(-popover => "cursor");
MainLoop;

__END__
