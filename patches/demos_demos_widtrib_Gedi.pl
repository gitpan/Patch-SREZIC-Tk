--- Tk800.023/demos/demos/widtrib/Gedi.pl	Sat Jan 15 13:26:40 2000
+++ new.Tk800.023/demos/demos/widtrib/Gedi.pl	Tue May 29 10:09:00 2001
@@ -93,7 +93,7 @@
         -iconname         => 'GEDI',
     );
 
-
+$TOP->withdraw;
 
 $text_frame = $TOP->Frame->pack
 	(-anchor=>'nw', expand=>'yes', -fill => 'both'); # autosizing
@@ -106,7 +106,7 @@
 	# once window shrinks below height
 	# and the line counters go off the screen.
 	# seems to be a problem with the Tk::pack command;
-	height => 40, 	 
+#	height => 40, 	 
 	-background => 'white',
 	-wrap=> 'none', 
 	-setgrid => 'true', # use this for autosizing
@@ -159,6 +159,15 @@
 $textwindow->ResetUndo;
 
 $textwindow->CallNextGUICallback;
+
+# adjust height
+$TOP->update;
+my $menuheight = ($TOP->wrapper)[1];
+my $TOPheight = 30 + $TOP->reqheight + $menuheight;
+if ($TOP->screenheight < $TOPheight) {
+    $textwindow->GeometryRequest($textwindow->reqwidth, $textwindow->reqheight - ($TOPheight - $TOP->screenheight));
+}
+$TOP->deiconify;
 
 }
 
