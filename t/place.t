#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: place.t,v 1.2 2002/03/10 11:38:56 eserte Exp $
# Author: Slaven Rezic
#

use strict;

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

BEGIN { plan tests => 9, todo => [2,4] }

# test tkPlace.c.diff patch

my $mw = new MainWindow;
$mw->geometry("200x200");
my $l = $mw->Label(-text => "foo")->place(qw(-x 0 -y 0 -relwidth 0.5 -relheight 0.5));
my %i = $l->placeInfo;
ok($i{'-anchor'},'nw');
ok($i{'-relwidth'},0.5);
ok($i{'-relx'},0);
ok($i{'-relheight'},0.5);
ok($i{'-rely'},0);
ok($i{'-width'},'');
ok($i{'-x'},0);
ok($i{'-height'},'');
ok($i{'-y'},0);

__END__
