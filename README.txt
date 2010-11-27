LuaAnnotate - C code comments externally stored but displayed inline.

LuaAnnotate is a tool for displaying C source file comments inline to
the source but stored in a separate file.  The comments are maintained
in a text file (annotate.txt) in the same directory as the C sources.
Displaying the comments inline to the C code can be done in many ways:

  - weaving the comments into the source code as C comments and saving
    the result to a temporary file for viewing in any text editor.
  - displaying comments as annotations in the SciTE text editor when viewing
	  the original source files (without altering those source files).
  - other possibilities (not implemented) include rendering as HTML
	   or creating plugins for other text editors.		

The original motivation for this project is to allow Lua users to better
document the Lua source code [2].  The Lua source code is dense
but sparsely commented.  It's uncertain whether the original Lua authors
will incorporate generous use of comments in the original upstream
sources, so we need to maintain the comments separately.
This becomes challenging when the upstream sources change
and users themselves may maintain their own set of patches.
The problem with using unified patches here is that the contextual
information contained is more detailed than necessary and its conflict
checking is more strict than necesessary.  All the comment data really
needs to say is that a certain identifier corresponds with a certain piece of
documentation, almost in the manner of ctags.  Furthermore, if such an
identifier cannot be matched in the source, we don't care that much
--it's just documentation.

== Project Page ==

For further details, see http://lua-users.org/wiki/LuaAnnotate .

== Status ==

WARNING: This code is very new and might not be stable yet.
It is usable but you may need to sometimes fix things yourself.
Many additional features could be added too.

== Example ===

See the "lua\annotations.txt" for an example of an annotations file
for the Lua 5.2.0-alpha sources.  To use, copy annotations.txt into
the Lua "src" directory.

Note: This annotations.txt example currently only documents a few items
in the Lua sources.  It should be extended to the extire Lua sources.
Patches are welcome.

== Command-line Usage (C++ output) ==

Example:

  $ cp lua/annotations.txt ../lua-5.2.0-alpha/src/
  $ lua luaannotate.lua ../lua-5.2.0-alpha/src/luac.c > luac-annotated.c

== Installation in SciTE ==

First install SciTE <http://www.scintilla.org/SciTE.html>.
Version 2.12 and 2.20 work (older versions might not work).

Install SciTE ExtMan: http://lua-users.org/wiki/SciteExtMan .

Copy luaannotate.lua into your ExtMan "scite_lua" scripts folder.

Now when you restart SciTE and load a C file that has an annotations.txt
file in the same directory, SciTE will render the annotations inline to the
source file.

== LICENSE ==

See COPYRIGHT file.

== Credits ==

David Manura, original author.
Steve Donovan originally suggested this.

== Bugs ==

Please report bugs via github <http://github.com/davidm/lua-annotate/issues>
or just "dee em dot el you ae at em ae tee ayche two dot ow ar gee", or
if you prefer neither then append to the wiki page
<http://lua-users.org/wiki/LuaAnnotate>.

== References ==

[1] http://www.scintilla.org/SciTE.html
[2] lua-users.org/wiki/LuaSource
