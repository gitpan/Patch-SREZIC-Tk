#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: wm-popup.t,v 1.3 2002/02/19 22:03:04 eserte Exp $
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

$mw->destroy;

ok(1);

# REPO BEGIN
# REPO NAME tk_sleep /home/e/eserte/src/repository 
# REPO MD5 8ede6fb7c5021ac927456dff1f24aa7a

=head2 tk_sleep

=for category Tk

    $top->tk_sleep($s);

Sleep $s seconds (fractions are allowed). Use this method in Tk
programs rather than the blocking sleep function.

=cut

sub Tk::Widget::tk_sleep {
    my($top, $s) = @_;
    my $sleep_dummy = 0;
    $top->after($s*1000,
                sub { warn 1;$sleep_dummy++ });
    $top->waitVariable(\$sleep_dummy)
	unless $sleep_dummy;
}
# REPO END

__END__
