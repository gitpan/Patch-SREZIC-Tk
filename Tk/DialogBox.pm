# -*- perl -*-

#
# $Id: DialogBox.pm,v 1.3 2001/11/18 10:07:45 eserte Exp $
# Author: Slaven Rezic
#
# This is a patch against the original Tk/DialogBox.pm. Please consult
# the Perl/Tk documentation and/or sources for copyrights.
#
# Mail: slaven.rezic@berlin.de
# WWW:  http://www.rezic.de/eserte/
#

package Patch::SREZIC::Tk::DialogBox;

use Tk::DialogBox;
package
    Tk::DialogBox;

sub Populate {
    my ($cw, $args) = @_;

    $cw->SUPER::Populate($args);
    my $buttons = delete $args->{'-buttons'};
    $buttons = ['OK'] unless defined $buttons;
    my $default_button = delete $args->{'-default_button'};
    $default_button = $buttons->[0] unless defined $default_button;

    $cw->{'selected_button'} = '';
    $cw->transient($cw->Parent->toplevel);
    $cw->withdraw;
    if (@$buttons == 1) {
	$cw->protocol('WM_DELETE_WINDOW' => sub { $cw->{'default_button'}->invoke });
    } else {
	$cw->protocol('WM_DELETE_WINDOW' => sub {});
    }

    # create the two frames
    my $top = $cw->Component('Frame', 'top');
    $top->configure(-relief => 'raised', -bd => 1) unless $Tk::platform eq 'MSWin32';
    my $bot = $cw->Component('Frame', 'bottom');
    $bot->configure(-relief => 'raised', -bd => 1) unless $Tk::platform eq 'MSWin32';
    $bot->pack(qw/-side bottom -fill both -ipady 3 -ipadx 3/);
    $top->pack(qw/-side top -fill both -ipady 3 -ipadx 3 -expand 1/);

    # create a row of buttons in the bottom.
    my $bl;  # foreach my $var: perl > 5.003_08
    foreach $bl (@$buttons)
     {
	my $b = $bot->Button(-text => $bl, -command => sub { $cw->{'selected_button'} = "$bl" } );
	$b->bind('<Return>' => [ $b, 'Invoke']);
	$cw->Advertise("B_$bl" => $b);
        if ($Tk::platform eq 'MSWin32')
         {
          $b->configure(-width => 10, -pady => 0);
         }
	if ($bl eq $default_button) {
            if ($Tk::platform eq 'MSWin32') {
                $b->pack(-side => 'left', -expand => 1,  -padx => 1, -pady => 1);
            } else {
	        my $db = $bot->Frame(-relief => 'sunken', -bd => 1);
	        $b->raise($db);
	        $b->pack(-in => $db, -padx => '2', -pady => '2');
	        $db->pack(-side => 'left', -expand => 1, -padx => 1, -pady => 1);
            }
	    $cw->{'default_button'} = $b;
	} else {
	    $b->pack(-side => 'left', -expand => 1,  -padx => 1, -pady => 1);
	}
    }
    $cw->ConfigSpecs(-command    => ['CALLBACK', undef, undef, undef ],
                     -foreground => ['DESCENDANTS', 'foreground','Foreground', 'black'],
                     -background => ['DESCENDANTS', 'background','Background',  undef],
                    );
    $cw->Delegates('Construct',$top);
}

1;

__END__
