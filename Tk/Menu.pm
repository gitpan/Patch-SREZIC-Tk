# -*- perl -*-

#
# $Id: Menu.pm,v 1.1 2001/11/27 00:26:55 eserte Exp $
# Author: Slaven Rezic
#
# This is a patch against the original Tk/Menu.pm. Please consult
# the Perl/Tk documentation and/or sources for copyrights.
#
# Mail: slaven.rezic@berlin.de
# WWW:  http://www.rezic.de/eserte/
#

package Patch::SREZIC::Tk::Menu;

use Tk::Menu;
package
    Tk::Menu;

sub NextEntry
{
 my $menu = shift;
 my $count = shift;
 if ($menu->index('last') eq 'none')
  {
   return;
  }
 my $length = $menu->index('last')+1;
 my $quitAfter = $length;
 my $active = $menu->index('active');
 my $i = ($active eq 'none') ? 0 : $active+$count;
 while (1)
  {
   return if ($quitAfter <= 0);
   while ($i < 0)
    {
     $i += $length
    }
   while ($i >= $length)
    {
     $i += -$length
    }
   my $state = eval {local $SIG{__DIE__};  $menu->entrycget($i,'-state') };
   last if (defined($state) && $state ne 'disabled');
   return if ($i == $active);
   $i += $count;
   $quitAfter -= 1;
  }
 $menu->activate($i);
 $menu->GenerateMenuSelect;
 if ($menu->cget('-type') eq 'menubar' && $menu->type($i) eq 'cascade')
  {
   my $cascade = $menu->entrycget($i, '-menu');
   $menu->postcascade($i);
   $cascade->FirstEntry if (defined $cascade);
  }
}

1;

__END__
