#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: mousewheel.t,v 1.2 2002/02/19 22:02:46 eserte Exp $
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

my $txt = $top->Scrolled("Text")->pack;
my $lb  = $top->Scrolled("Listbox")->pack;

$txt->BindMouseWheel;
$lb->BindMouseWheel;

open(F, $0);
local $/;
my $buf = scalar <F>;
close F;

$txt->insert("end", $buf x 10);
$lb->insert("end", split /\n/, $buf x 10);

if ($ENV{BATCH}) {
    $top->after(1000, sub { $top->destroy });
}

MainLoop;

ok(1);

__END__
