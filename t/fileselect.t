#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: fileselect.t,v 1.1 2002/03/11 21:42:55 eserte Exp $
# Author: Slaven Rezic
#

use strict;

BEGIN { $Patch::SREZIC::Tk::VERBOSE = 0 }
use Patch::SREZIC::Tk;
use Tk;
use Tk::FileSelect;

BEGIN {
    if (!eval q{
	use Test;
	die "Only for me" if $ENV{USER} ne "eserte";
	1;
    }) {
	print "# tests only work for the author (eserte)\n";
	print "1..1\n";
	print "ok 1\n";
	exit;
    }
}

BEGIN { plan tests => 2 }

my $dir = "/tmp/fileselect-test.$$";
mkdir $dir, 0600;

my $ok = 0;

if (-d $dir) {
    my $mw = new MainWindow;
    my $fs = $mw->FileSelect;
    $mw->after
	(200, sub {
	     $fs->Walk
		 (sub {
		      if ($_[0]->isa("Tk::Dialog") && $_[0]->viewable) {
			  $_[0]->Walk(sub { eval { $_[0]->invoke; $ok = 1 } });
		      }
		  });
	     ok($ok);

	     $ok = 0;
	     $mw->after
		 (200, sub {
		      $fs->Walk
			  (sub {
			       eval {
				   my $text = $_[0]->cget(-text);
				   if (defined $text && $text eq 'Cancel') {
				       $_[0]->invoke;
				       $ok = 1;
				   }
			       }
			   });
		  });
	 });
    $fs->configure(-initialdir => $dir);
    $fs->Show;
    rmdir $dir;
}
ok($ok);

__END__
