#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: wm-popup.t,v 1.4 2002/03/08 21:37:06 eserte Exp $
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

BEGIN { plan tests => 3 }

my $mw = new MainWindow;
$mw->geometry("+0+0");
$mw->update;

my $t = $mw->Toplevel;
$t->geometry("300x300");
$t->Popup(-popover => $mw, -overanchor => "nw");

$mw->tk_sleep(2);

$mw->geometry("-0-0");
$mw->update;
$t->Popup(-popover => $mw, -overanchor => "se");

$mw->tk_sleep(2);

my $geom;
$mw->after(1000, sub {
	       $mw->Walk(sub {
			     if ($_[0]->isa("Tk::DialogBox")) {
				 my $msgbox = $_[0];
				 $geom = $_[0]->geometry;
				 $msgbox->Walk(sub { eval { $_[0]->invoke } });
			     }
			 })
	   });
$mw->messageBox(-message => "\n"x500);

$mw->tk_sleep(3);

{
    my($w,$h,$x,$y) = parse_geometry_string($geom);
    ok($x >= 0);
    ok($y >= 0);
}

$mw->destroy;

ok(1);

# REPO BEGIN
# REPO NAME tk_sleep /home/e/eserte/src/repository 
# REPO MD5 8ede6fb7c5021ac927456dff1f24aa7a
sub Tk::Widget::tk_sleep {
    my($top, $s) = @_;
    my $sleep_dummy = 0;
    $top->after($s*1000,
                sub { $sleep_dummy++ });
    $top->waitVariable(\$sleep_dummy)
	unless $sleep_dummy;
}
# REPO END

sub parse_geometry_string {
    my $geometry = shift;
    my @extends = (0, 0, 0, 0);
    if ($geometry =~ /([-+]?\d+)x([-+]?\d+)/) {
	$extends[0] = $1;
	$extends[1] = $2;
    }
    if ($geometry =~ /[-+]([-+]?\d+)[-+]([-+]?\d+)/) {
	$extends[2] = $1;
	$extends[3] = $2;
    }
    @extends;
}

__END__
