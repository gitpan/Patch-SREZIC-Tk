#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: pane.t,v 1.2 2002/02/19 22:02:52 eserte Exp $
# Author: Slaven Rezic
#

use strict;

BEGIN { $Patch::SREZIC::Tk::VERBOSE = 0 }
use Patch::SREZIC::Tk;
use Tk;
use Tk::Pane;

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

my $mw = tkinit;
my $p = $mw->Pane;
$p->gridRowconfigure(1, -weight => 1);
ok(1);

__END__
