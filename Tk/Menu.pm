# -*- perl -*-

#
# $Id: Menu.pm,v 1.2 2002/03/10 21:52:35 eserte Exp $
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

# Hack to use SELF config spec for -foreground
sub InitObject
{
 my ($menu,$args) = @_;
 my $menuitems = delete $args->{-menuitems};
 $menu->SUPER::InitObject($args);
 $menu->ConfigSpecs(-foreground => ['SELF']);
 if (defined $menuitems)
  {
   # If any other args do configure now
   if (%$args)
    {
     $menu->configure(%$args);
     %$args = ();
    }
   $menu->AddItems(@$menuitems)
  }
}

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
