#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: menu.t,v 1.2 2002/03/10 22:05:33 eserte Exp $
# Author: Slaven Rezic
#

use strict;

BEGIN { $Patch::SREZIC::Tk::VERBOSE = 0 }
use Patch::SREZIC::Tk;
use Tk::Menu;

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

BEGIN { plan tests => 4 }

my $mw = MainWindow->new;

{
    my $m = $mw->Menu(-foreground => "red");
    ok($m->cget('-foreground'), "red");
    ok(Tk::cget($m, '-foreground'), "red");
}

{
    my $m = $mw->Menu(-fg => "red");
    ok($m->cget('-fg'), "red");
    ok(Tk::cget($m, '-fg'), "red");
}

__END__
