#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: text.t,v 1.2 2002/02/19 22:02:58 eserte Exp $
# Author: Slaven Rezic
#

use strict;

BEGIN { $Patch::SREZIC::Tk::VERBOSE = 0 }
use Patch::SREZIC::Tk;
use Tk;
use Tk::Text;

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
my $t = $mw->Text->pack;
if ($ENV{BATCH}) {
    $mw->after(1000, sub { $mw->destroy });
}
MainLoop;
ok(1);
__END__
