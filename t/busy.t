#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: busy.t,v 1.3 2002/02/28 00:36:06 eserte Exp $
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
$top->update;
$top->Busy
    (-cursor => "watch",
     -recurse => 1,
     sub {
         for (1..3) {
             #warn $_;
             tk_sleep($top, 1);
         }
     });

ok(1);

sub tk_sleep {
    my($top, $s) = @_;
    my $sleep_dummy = 0;
    $top->after($s*1000,
                sub { $sleep_dummy++ });
    $top->waitVariable(\$sleep_dummy)
        unless $sleep_dummy;
}

__END__
