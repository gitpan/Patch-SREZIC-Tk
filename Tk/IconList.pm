# -*- perl -*-

#
# $Id: IconList.pm,v 1.3 2001/11/18 10:07:47 eserte Exp $
# Author: Slaven Rezic
#
# This is a patch against the original Tk/IconList.pm. Please consult
# the Perl/Tk documentation and/or sources for copyrights.
#
# Mail: slaven.rezic@berlin.de
# WWW:  http://www.rezic.de/eserte/
#

package Patch::SREZIC::Tk::IconList;

$VERSION = sprintf("%d.%03d", q$Revision: 1.3 $ =~ /(\d+)\.(\d+)/);

use Tk::IconList;
package
    Tk::IconList;

use Tk;

sub Populate {
    my($w, $args) = @_;
    $w->SUPER::Populate($args);

    my $sbar = $w->Component('Scrollbar' => 'sbar',
			     -orient => 'horizontal',
			     -highlightthickness => 0,
			     -takefocus => 0,
			    );
    # make sure that the size does not exceed handhelds' dimensions
    my($sw,$sh) = ($w->screenwidth, $w->screenheight);
    my $canvas = $w->Component('Canvas' => 'canvas',
			       -bd => 2,
			       -relief => 'sunken',
			       -width  => ($sw > 420 ? 400 : $sw-20),
			       -height => ($sh > 160 ? 120 : $sh-40),
			       -takefocus => 1,
			      );
    $sbar->pack(-side => 'bottom', -fill => 'x', -padx => 2);
    $canvas->pack(-expand => 'yes', -fill => 'both');
    $sbar->configure(-command => ['xview', $canvas]);
    $canvas->configure(-xscrollcommand => ['set', $sbar]);

    # Initializes the max icon/text width and height and other variables
    $w->{'maxIW'} = 1;
    $w->{'maxIH'} = 1;
    $w->{'maxTW'} = 1;
    $w->{'maxTH'} = 1;
    $w->{'numItems'} = 0;
    delete $w->{'curItem'};
    $w->{'noScroll'} = 1;

    # Creates the event bindings.
    $canvas->Tk::bind('<Configure>', sub { $w->Arrange } );
    $canvas->Tk::bind('<1>', [$w,'Btn1',Ev('x'),Ev('y')]);
    $canvas->Tk::bind('<B1-Motion>', [$w,'Motion1',Ev('x'),Ev('y')]);
    $canvas->Tk::bind('<Double-ButtonRelease-1>', [$w,'Double1',Ev('x'),Ev('y')]);
    $canvas->Tk::bind('<ButtonRelease-1>', [$w,'CancelRepeat']);
    $canvas->Tk::bind('<B1-Leave>', [$w,'Leave1',Ev('x'),Ev('y')]);
    $canvas->Tk::bind('<B1-Enter>', [$w,'CancelRepeat']);
    $canvas->Tk::bind('<Up>',       [$w,'UpDown',   -1]);
    $canvas->Tk::bind('<Down>',     [$w,'UpDown',    1]);
    $canvas->Tk::bind('<Left>',     [$w,'LeftRight',-1]);
    $canvas->Tk::bind('<Right>',    [$w,'LeftRight', 1]);
    $canvas->Tk::bind('<Return>',   [$w,'ReturnKey']);
    $canvas->Tk::bind('<KeyPress>', [$w,'KeyPress',Ev('A')]);
    $canvas->Tk::bind('<Control-KeyPress>', 'NoOp');
    $canvas->Tk::bind('<Alt-KeyPress>', 'NoOp');
    $canvas->Tk::bind('<FocusIn>', sub { $w->FocusIn });

    $canvas->Tk::bind('<2>',['scan','mark',Ev('x'),Ev('y')]);
    $canvas->Tk::bind('<B2-Motion>',['scan','dragto',Ev('x'),Ev('y')]);
    # Remove the standard Canvas bindings
    $canvas->bindtags([$canvas]);
    # ... and define some again
    $canvas->Tk::bind('<Home>', ['xview','moveto',0]);
    $canvas->Tk::bind('<End>',  ['xview','moveto',1]);

    $w->ConfigSpecs(-browsecmd =>
		    ['CALLBACK', 'browseCommand', 'BrowseCommand', undef],
		    -command =>
		    ['CALLBACK', 'command', 'Command', undef],
		    -font =>
		    ['PASSIVE', 'font', 'Font', undef],
		    -foreground =>
		    ['PASSIVE', 'foreground', 'Foreground', undef],
		    -fg => '-foreground',
		    -selectmode =>
		    ['PASSIVE', 'selectMode', 'SelectMode', 'browse'],
		   );

    $w;
}

sub Arrange {
    my $w = shift;
    my $canvas = $w->Subwidget('canvas');
    my $sbar   = $w->Subwidget('sbar');
    unless (exists $w->{'list'}) {
	if (defined $canvas && Tk::Exists($canvas)) {
	    $w->{'noScroll'} = 1;
	    $sbar->configure(-command => sub { });
	}
	return;
    }

    my $W = $canvas->width;
    my $H = $canvas->height;
    my $pad = $canvas->cget(-highlightthickness) + $canvas->cget(-bd);
    $pad = 2 if ($pad < 2);
    $W -= $pad*2;
    $H -= $pad*2;
    my $dx = $w->{'maxIW'} + $w->{'maxTW'} + 8;
    my $dy;
    if ($w->{'maxTH'} > $w->{'maxIH'}) {
	$dy = $w->{'maxTH'};
    } else {
	$dy = $w->{'maxIH'};
    }
    $dy += 2;
    my $shift = $w->{'maxIW'} + 4;
    my $x = $pad * 2;
    my $y = $pad;
    my $usedColumn = 0;
    foreach my $sublist (@{ $w->{'list'} }) {
	$usedColumn = 1;
	my($iTag, $tTag, $rTag, $iW, $iH, $tW, $tH) = @$sublist;
	my $i_dy = ($dy - $iH) / 2;
	my $t_dy = ($dy - $tH) / 2;
	$canvas->coords($iTag, $x, $y + $i_dy);
	$canvas->coords($tTag, $x + $shift, $y + $t_dy);
	$canvas->coords($tTag, $x + $shift, $y + $t_dy);
	$canvas->coords($rTag, $x, $y, $x + $dx, $y + $dy);
	$y += $dy;
	if ($y + $dy > $H) {
	    $y = $pad;
	    $x += $dx;
	    $usedColumn = 0;
	}
    }
    my $sW;
    if ($usedColumn) {
	$sW = $x + $dx;
    } else {
	$sW = $x;
    }
    if ($sW < $W) {
	$canvas->configure(-scrollregion => [$pad, $pad, $sW, $H]);
	$sbar->configure(-command => sub { });
	$canvas->xview(moveto => 0);
	$w->{'noScroll'} = 1;
    } else {
	$canvas->configure(-scrollregion => [$pad, $pad, $sW, $H]);
	$sbar->configure(-command => ['xview', $canvas]);
	$w->{'noScroll'} = 0;
    }
    $w->{'itemsPerColumn'} = int(($H - $pad) / $dy);
    $w->{'itemsPerColumn'} = 1 if ($w->{'itemsPerColumn'} < 1);
    $w->Select($w->{'list'}[$w->{'curItem'}][2], 0)
      if (exists $w->{'curItem'});
}

sub Btn1 {
    my($w, $x, $y) = @_;
    $w->Subwidget('canvas')->CanvasFocus;
    $w->SelectAtXY($x, $y);
}

sub LeftRight {
    my($w, $amount) = @_;
    my $rTag;
    return unless (exists $w->{'list'});
    unless (exists $w->{'curItem'}) {
	$rTag = $w->{'list'}[0][2];
    } else {
	my $oldRTag = $w->{'list'}[$w->{'curItem'}][2];
	my $newItem = $w->{'curItem'} + $amount * $w->{'itemsPerColumn'};
	return if $newItem < 0;
	$rTag = $w->{'list'}[$newItem][2];
	$rTag = $oldRTag unless (defined $rTag);
    }
    if (defined $rTag) {
	$w->Select($rTag);
	$w->See($rTag);
    }
}

1;

__END__

suggested -selectmode and IconList (see Listbox and HList)

[1]
extended: Shift-B1           adjust selection
extended: Shift-B1-Motion    adjust selection while moving
[2]
extended: Control-B1         toggle selection
extended: Control-B1-Motion  adjust selection (+/- according to anchor)
[3] OK
[4]
        : B2-Motion          scanning
[5]
extended
browse  : Up/Down/Left/Right move cursor (as yet), deselect all other
[6]
extended: Shift-Up/Down...   move cursor + adjust selection
[7] OK, Control-* not needed
[8] Not needed
[9] OK
[10] maybe
        : Control-Home       select and show first
[11] maybe
        : Control-End        select and show last
[12] maybe
extended: C-S-Home/End
[13]
multiple: C-S-Home/End
