#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: hlist.t,v 1.2 2002/02/19 22:20:29 eserte Exp $
#

use strict;
BEGIN { $Patch::SREZIC::Tk::VERBOSE = 0 }
use Patch::SREZIC::Tk;
use Tk;
use Tk::LabFrame;
use Tk::Balloon;
use Tk::HList;

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

my $mw = MainWindow->new;
my $frame = $mw->Frame->pack(-fill => 'both', -expand => 1);

my $mode = "single";

my $listLabel = $frame->Label(
  -text => 'Listbox'
)->grid(-row => 0, -column => 0, -sticky => 'w');

my $listbox = $frame->Listbox(
  -height => 8,
   -takefocus => 1,
  -selectmode => $mode,
  -width => 10
)->grid(-row => 1, -column => 0, -sticky => 'n');

my $hlistLabel = $frame->Label(
  -text => 'HList'
)->grid(-row => 0, -column => 2, -sticky => 'w');

my $hlist = $frame->HList(
  -column => 1,
  -takefocus => 1,
  -selectmode => $mode,
  -height => 8,
  -pady => 0,
  -browsecmd => \&browseThis,
  -highlightthickness => 1,
  -width => 10,
)->grid(-row => 1, -column => 2, -sticky => 'n');

$b = $mw->Balloon(-state => 'balloon');
$b->attach($hlist, -state => 'balloon',
  -msg => ["First item",
           "second item",
           "third item"
          ]
);




my $middleF = $frame->Frame->
  grid(-row => 1, -column => 1, -padx => 20,);


my $anchorF = $middleF->LabFrame(
  -labelside => 'acrosstop',
  -label => "Tix anchor"
)->pack(-side => 'top', -fill => 'x');

my $anchor = 1;
my %anchorState = ('on        ' => 1, 'off       ' => 0);
for (sort {$b cmp $a} keys %anchorState) {
  $anchorF->Radiobutton(
    -text => $_,
    -variable => \$anchor,
    -value => $anchorState{$_},
    -highlightthickness => 0,
    -command => [\&setAnchor, $hlist, $anchorState{$_}]
  )->pack(-side => 'top');
}


my $modeFrame = $middleF->LabFrame(
  -labelside => 'acrosstop',
  -label => 'Select Modes'
)->pack(-side => 'top');
my $intFrame = $modeFrame->Frame->pack(-padx => 15);

foreach my $m (qw/single browse multiple extended/) {
  $intFrame->Radiobutton(
    -text => $m,
    -value => $m,
    -variable => \$mode,
    -highlightthickness => 0,
    -command => [\&setMode, $m, $listbox, $hlist]
  )->pack(-side => 'top', -anchor => 'nw');
}

populateLists($hlist, $listbox);

if ($ENV{BATCH}) {
    $mw->after(1000, sub { $mw->destroy });
}

MainLoop;

ok(1);


sub browseThis {
  my $ent = shift;
  return unless $ent;
  print "browsecmd called on $ent\n";
}

sub setMode {
  my ($mode, $list, $hlist) = @_;
  foreach ($list, $hlist) {
    $_->configure(-selectmode => $mode);
  }
}

sub setAnchor {
  my ($hlist, $anchor) = @_;
  $hlist->configure(-showactive => $anchor);
}


sub populateLists {
  my ($hlist, $list) = @_;

  my $font = $hlist->cget("-font");
  
  foreach my $i (qw/one two three four five six seven
                    eight nine ten eleven twelve/) {
    $list->insert('end', $i);
    my $path = $hlist->add($i, -text => $i);
  }
}

__END__
