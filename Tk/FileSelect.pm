# -*- perl -*-

#
# $Id: FileSelect.pm,v 1.1 2002/01/31 19:28:46 eserte Exp $
# Author: Slaven Rezic
#
# This is a patch against the original Tk/FileSelect.pm. Please consult
# the Perl/Tk documentation and/or sources for copyrights.
#
# Mail: slaven.rezic@berlin.de
# WWW:  http://www.rezic.de/eserte/
#

package Patch::SREZIC::Tk::FileSelect;

$VERSION = sprintf("%d.%03d", q$Revision: 1.1 $ =~ /(\d+)\.(\d+)/);

use Tk::FileSelect;
package
    Tk::FileSelect;

sub reread
{
 my ($w) = @_;
 my $dir = $w->cget('-directory');
 if (defined $dir)
  {
   if (!defined $w->cget('-filter') or $w->cget('-filter') eq '')
    {
     $w->configure('-filter', '*');
    }
   my $dl = $w->Subwidget('dir_list');
   $dl->delete(0, 'end');
   my $fl = $w->Subwidget('file_list');
   $fl->delete(0, 'end');
   local *DIR;
   if (opendir(DIR, $dir))
    {
     my $file = $w->cget('-initialfile');
     my $seen = 0;
     my $accept = $w->cget('-accept');
     foreach my $f (sort(readdir(DIR)))
      {
       next if ($f eq '.');
       my $path = "$dir/$f";
       if (-d $path)
        {
         $dl->insert('end', $f);
        }
       else
        {
         if (&{$w->{match}}($f))
          {
           if (!defined($accept) || $accept->Call($path))
            {
             $seen = $fl->index('end') if ($file && $f eq $file);
             $fl->insert('end', $f)
            }
          }
        }
      }
     closedir(DIR);
     if ($seen)
      {
       $fl->selectionSet($seen);
       $fl->see($seen);
      }
     else
      {
       $w->configure(-initialfile => undef) unless $w->cget('-create');
      }
    }
   $w->{DirectoryString} = $dir . '/' . $w->cget('-filter');
  }
 $w->{'reread'} = 0;
 $w->Unbusy if $w->{'Busy'};
}

1;

__END__
