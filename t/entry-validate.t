#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: entry.t,v 1.2 2002/02/19 22:02:28 eserte Exp $
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

BEGIN { plan tests => 1 }

my $top = new MainWindow;
my $e = $top->Entry;
$e->validate;

ok(1);

__END__
