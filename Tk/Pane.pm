# -*- perl -*-

#
# $Id: Pane.pm,v 1.2 2001/11/18 10:07:48 eserte Exp $
# Author: Slaven Rezic
#
# This is a patch against the original Tk/Pane.pm. Please consult
# the Perl/Tk documentation and/or sources for copyrights.
#
# Mail: slaven.rezic@berlin.de
# WWW:  http://www.rezic.de/eserte/
#

package Patch::SREZIC::Tk::Pane;

use Tk::Pane;
package
    Tk::Pane;

# by Rob Seegel (robseegel@aol.com)

use Tk::Submethods(
  grid => [qw/bbox columnconfigure location propagate rowconfigure size slaves/],
  pack => [qw/propagate slaves/]
);

1;

__END__
