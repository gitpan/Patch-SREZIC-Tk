# -*- perl -*-

#
# $Id: FileSelect.pm,v 1.2 2002/03/11 21:43:35 eserte Exp $
# Author: Slaven Rezic
#
# This is a patch against the original Tk/FileSelect.pm. Please consult
# the Perl/Tk documentation and/or sources for copyrights.
#
# Mail: slaven.rezic@berlin.de
# WWW:  http://www.rezic.de/eserte/
#

package Patch::SREZIC::Tk::FileSelect;

$VERSION = sprintf("%d.%03d", q$Revision: 1.2 $ =~ /(\d+)\.(\d+)/);

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

sub directory
{
 my ($cw,$dir) = @_;
 my $var = \$cw->{Configure}{'-directory'};
 if (@_ > 1 && defined $dir)
  {
   if (substr($dir,0,1) eq '~')
    {
     if (substr($dir,1,1) eq '/')
      {
       $dir = $ENV{'HOME'} . substr($dir,1);
      }
     else
      {my ($uid,$rest) = ($dir =~ m#^~([^/]+)(/.*$)#);
       $dir = (getpwnam($uid))[7] . $rest;
      }
    }
   my $revert_dir = sub
    {
     my $message = shift;
     $$var = $cw->{OldDirectory};
     $cw->messageBox(-message => $message, -icon => 'error');
     if (!defined $$var)
      {
       # OldDirectory was never set, so force reread...
       $$var = $cw->{OldDirectory} = Cwd::getcwd(); # XXX maybe use check like code below...
       unless ($cw->{'reread'}++)
        {
         $cw->Busy;
         $cw->afterIdle(['reread',$cw])
        }
      }
     $$var;
    };
   $dir =~ s#([^/\\])[\\/]+$#$1#;
   if (-d $dir)
    {
     unless (Tk::tainting())
      {
       my $pwd = Cwd::getcwd();
       if (chdir( (defined($dir) ? $dir : '') ) )
        {
         my $new = Cwd::getcwd();
         if ($new)
          {
           $dir = $new;
          }
         else
          {
	   return $revert_dir->("Cannot getcwd in '$dir'");
          }
         if (!chdir($pwd))
          {
	   return $revert_dir->("Cannot change directory to $pwd:\n$!");
          }
	 $$var = $dir;
        }
       else
        {
	 return $revert_dir->("Cannot change directory to $dir:\n$!");
        }
       $$var = $cw->{OldDirectory} = $dir;
      }
     unless ($cw->{'reread'}++)
      {
       $cw->Busy;
       $cw->afterIdle(['reread',$cw])
      }
    }
  }
 return $$var;
}

1;

__END__
