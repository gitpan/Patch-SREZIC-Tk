#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: iconlist.t,v 1.1 2002/02/19 23:10:02 eserte Exp $
# Author: Slaven Rezic
#

use strict;

BEGIN { $Patch::SREZIC::Tk::VERBOSE = 0 }
use Patch::SREZIC::Tk;
use Tk;
use Tk::IconList;

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

my $mw = new MainWindow;

my $il = $mw->IconList(-browsecmd => sub { warn "Browse @_\n" },
		       -command   => sub { warn "Command @_\n" })->pack;
my $folder = $mw->Photo(-file => Tk->findINC("folder.xpm"));
my $file   = $mw->Photo(-file => Tk->findINC("file.xpm"));
foreach my $i (1..10) {
    $il->Add($i%2==0 ? $file : $folder, "Text $i");
}
$il->Arrange;

if ($ENV{BATCH}) {
    $mw->after(1000, sub {
		   $il->DeleteAll;
		   $mw->after(1000, sub {
				  $mw->destroy;
			      });
	       });
}

MainLoop;

ok(1);

__END__
