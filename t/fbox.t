#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: fbox.t,v 1.5 2002/03/02 22:00:27 eserte Exp $
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

# multiple mainwindows are ok:
my $mw1 = new MainWindow;
$mw1->geometry("+0+0");
my $mw2 = new MainWindow;
$mw2->geometry("+0+300");
if ($ENV{BATCH}) {
    $mw1->after(500, sub {
		    $mw1->destroy;
		});
    $mw2->after(1000, sub {
		    $mw2->destroy;
		});
}
$mw1->getOpenFile;
$mw2->getOpenFile;

ok(1);

# strange grab problems

my $mw3 = new MainWindow;
my $e = $mw3->Entry->pack;
$e->update;
$e->grabGlobal;
$mw3->after(100, sub { $e->packForget; $mw3->getOpenFile });

if ($ENV{BATCH}) {
    $mw3->after(500, sub {
		    $mw3->destroy;
		});
}

ok(1);

#MainLoop;

__END__
