# -*- perl -*-

#
# $Id: DragDrop.pm,v 1.1 2002/02/22 21:45:39 eserte Exp $
# Author: Slaven Rezic
#
# This is a patch against the original Tk/DragDrop.pm. Please consult
# the Perl/Tk documentation and/or sources for copyrights.
#
# Mail: slaven.rezic@berlin.de
# WWW:  http://www.rezic.de/eserte/
#

package Patch::SREZIC::Tk::DragDrop;

use Tk::DragDrop;
package
    Tk::DragDrop;

sub Drop
{
 my $ewin  = shift;
 my $e     = $ewin->XEvent;
 my $token = $ewin->toplevel;
 my $site  = $token->FindSite($e->X,$e->Y,$e);
 Tk::catch { $token->grabRelease };
 if (defined $site)
  {
   my $seln = $token->cget('-selection');
   unless ($token->Callback(-predropcommand => $seln, $site))
    {
     warn "schedule done";
# XXX This is ugly, if the user again starts a drag within the 2000 ms:
#     my $id = $token->after(2000,[$token,'Done']);
     my $w = $token->parent;
     $token->InstallHandlers;
     $site->Drop($token,$seln,$e);
     $token->Callback(-postdropcommand => $seln);
     $token->Done;
    }
  }
 else
  {
   $token->Done;
  }
 $token->Callback('-endcommand');
}


1;

__END__
