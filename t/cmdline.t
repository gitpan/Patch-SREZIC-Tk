#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: cmdline.t,v 1.1 2002/03/04 20:02:36 eserte Exp $
# Author: Slaven Rezic
#

use strict;

BEGIN { $Patch::SREZIC::Tk::VERBOSE = 0 }
use Patch::SREZIC::Tk;
use Tk;
use Tk::CmdLine;

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

BEGIN { plan tests => 1 }

@ARGV = (-geometry => "500x200+2+2");
my $mw = new MainWindow;
$mw->update;
ok($mw->geometry, "500x200+2+2");
$mw->destroy;

__END__
