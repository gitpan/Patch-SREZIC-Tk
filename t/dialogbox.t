#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: dialogbox.t,v 1.4 2002/03/02 21:27:16 eserte Exp $
# Author: Slaven Rezic
#

use strict;

BEGIN { $Patch::SREZIC::Tk::VERBOSE = 0 }
use Patch::SREZIC::Tk;
use Tk;
use Tk::DialogBox;

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

my $top = new MainWindow;
if ($ENV{BATCH}) {
    $top->after(100, sub { $top->Walk(sub { eval { $_[0]->invoke } }) });
}
$top->messageBox(-title => "yes/no",
		 -message => "can't cancel with close button",
		 -type => "error",
		 -type => "YesNoCancel");
ok(1);

if ($ENV{BATCH}) {
    $top->after(100, sub { $top->Walk(sub { eval { $_[0]->invoke } }) });
}
$top->messageBox(-title => "yes/no",
		 -message => "can cancel with close button",
		 -type => "error",
		 -type => "Yes");
ok(1);

__END__
