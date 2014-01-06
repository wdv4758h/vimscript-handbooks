% Creating your own syntax files
% Clearmoments on vim.wikia.com
% 2008

This is a tutorial showing how to create your own syntax files in Vim.
This provides syntax highlighting to show the different elements of
files that you use. In this tutorial, all file names matching a
particular extension will use the highlighting rules defined with the
syntax commands shown below.

Example: Celestia star catalogs
-------------------------------

This tutorial creates a syntax file for Celestia star catalogs.
[Celestia](http://www.shatters.net/celestia/) is a great program for
anyone who likes astronomy and space. All we need to know for this
tutorial is that a star catalog lists a star name with its positional
information, distance and attributes (color, radius, mass, brightness).
Here is an example entry in a star catalog file (`.stc`):

    600000 "My Star"
    {
      RA 24.406489
      Dec -9.404052
      SpectralType "Q"
      Mass 1.09
      AbsMag 1.29
      Distance 124.729260
    }

The entry consists of a number, a string, and a `{...}` block, with some
keywords within that block ("RA", "Dec", etc). Comments are prefixed
with "\#" like in shell scripts or conf files. There can be multiple
entries like this with a number (the HIP number), the string, and the
block containing the attributes. Celestia gets more complicated than
this because you can have multiple stars going around a barycenter, but
we will only cover stars.

Syntax files
------------

### Build a syntax file

First, create a new file named `cel.vim` with the following contents:

    " Vim syntax file
    " Language: Celestia Star Catalogs
    " Maintainer: Kevin Lauder
    " Latest Revision: 26 April 2008

    if exists("b:current_syntax")
      finish
    endif

Vim comments start with a quote. Following the convention of the
built-in syntax files, we start with a comment flower box. The test
`if&nbsp;exists("b:current_syntax") ...` checks whether an earlier file
has defined a syntax already. If so, the script exits with `finish`.

### Keyword, match and region elements

There are three major syntax elements, and commands to describe those
elements. In order to syntax highlight, we must be able to describe what
to highlight. Here is an example of what they look like:

    " Keywords
    syn keyword syntaxElementKeyword keyword1 keyword2
    \   nextgroup=syntaxElement2

    " Matches
    syn match syntaxElementMatch 'regexp' contains=syntaxElement1
    \   nextgroup=syntaxElement2 skipwhite

    " Regions
    syn region syntaxElementRegion start='x' end='y'

#### Keywords

Keywords are simple. Take for example the programming language BASIC. In
BASIC there are several keywords like PRINT, OPEN and IF. To have Vim
recognize them, you can use a definition:

    syn keyword basicLanguageKeywords PRINT OPEN IF

For now we are not going to worry about `nextgroup=`.

Vim will now recognize the keywords PRINT, OPEN and IF as syntax
elements of type `basicLanguageKeywords`. You can add more on the same
line, or add another line with the same type (`basicLanguageKeywords`).
For example, to add the keywords DO, WHILE and WEND, you could add to
the previous line like this:

    syn keyword basicLanguageKeywords PRINT OPEN IF DO WHILE WEND

or, add another line, like this:

    syn keyword basicLanguageKeywords PRINT OPEN IF
    syn keyword basicLanguageKeywords DO WHILE WEND

We will apply this procedure to our star catalog entry from above:

    600000 "My Star"
    {
      RA 24.406489
      Dec -9.404052
      SpectralType "Q"
      Mass 1.09
      AbsMag 1.29
      Distance 124.729260
    }

We can group the following keywords as part of a syntax element called
`celBlockCmd` by adding the following to our syntax file.

    syn keyword celBlockCmd RA Dec SpectralType Mass Distance AbsMag

Vim will now recognize these keywords which may be sufficient for your
purpose. However, what if we want to match the text following the
keywords, like those numbers and string values?

#### Matches (and addendum to keywords)

All this keyword stuff logically leads to matches. Take the above
example once again. After the keywords ("RA", "Dec", "AbsMag" etc) there
are numbers. We want Vim to know that following a certain keyword there
is going to be some set of characters, perhaps defined as a regular
expression.

This is where matches come in; along with an additional caveat to using
keywords, the `nextgroup` and `skipwhite` arguments as seen above.

    syn match celNumber '\d\+'
    syn keyword celBlockCmd RA Dec Mass Distance AbsMag
    \   nextgroup=celNumber skipwhite

Now as you can see the match was given a regular expression `\d\+`
meaning to match one or more (`\+`) digits 0-9 (`\d`). The keyword
syntax element `celBlockCmd` has been modified slightly because
following the `SpectralType` keyword is not a number but a string. Hence
it has been excluded from the list of keywords for now. Later we will
address that problem by creating another regular expression to match
strings and apply it to that keyword.

Notice the `nextgroup` argument. We are telling the editor to expect a
`celNumber` after the keyword. So that is the first pattern the editor
will attempt to match after finding one of those keywords.

The `skipwhite` argument simply tells the editor to expect some
whitespace (spaces or tabs) between the keyword and the number.

One problem is that the above pattern (`\d\+`) will only match numbers
like 1234, 93, and 0. It will not match numbers like 3.1416 or -1. To
fix that, we need a more advanced regular expression borrowed from one
of the existing Vim syntax files and slightly modified for our needs.

    " Integer with - + or nothing in front
    syn match celNumber '\d\+'
    syn match celNumber '[-+]\d\+'

    " Floating point number with decimal no E or e (+,-)
    syn match celNumber '\d\+\.\d*'
    syn match celNumber '[-+]\d\+\.\d*'

    " Floating point like number with E and no decimal point (+,-)
    syn match celNumber '[-+]\=\d[[:digit:]]*[eE][\-+]\=\d\+'
    syn match celNumber '\d[[:digit:]]*[eE][\-+]\=\d\+'

    " Floating point like number with E and decimal point (+,-)
    syn match celNumber '[-+]\=\d[[:digit:]]*\.\d*[eE][\-+]\=\d\+'
    syn match celNumber '\d[[:digit:]]*\.\d*[eE][\-+]\=\d\+'

We can keep creating more lines like `syn match celNumber ''pattern''`
to match all those patterns as one syntax element type (in this case
`celNumber`).

#### Regions

Looking at the star catalog entry again shows another challenge:

    600000 "My Star"
    {
      RA 24.406489
      Dec -9.404052
      SpectralType "Q"
      Mass 1.09
      AbsMag 1.29
      Distance 124.729260
    }

The first number is outside the brackets, and it's not really a number,
it's an [HIP catalog
entry](http://www.rssd.esa.int/index.php?project=HIPPARCOS) (more like a
star's ID number rather than a value with physical meaning like mass or
distance). The real numbers are the arguments to the keywords (like "RA"
and "Dec"). It would be nice if we could have the editor match those
differently than regular numbers. But, since `celNumber`s and HIPs
consist of the digits 0-9 they conflict with one another. How can we fix
that discrepancy?

Note that numbers with values exist only within brackets. Outside of the
brackets it is an ID number rather than a value. We have to add another
argument to the keyword and match definition blocks, and introduce
another type of syntax element: a region.

First, we let the editor know that the keywords only exist within
brackets. Second, we specify that `celNumber` syntax elements only exist
within brackets. This is the concept of a region.

    syn region celDescBlock start="{" end="}" fold transparent

The `fold` argument means that Vim can increase the fold count inside
brackets so you can press Ctrl-F9 to expand and contract the code. The
`transparent` is the important keyword here. It tells the editor to
continue to apply matches and keywords to what is inside the region.
Otherwise the region would not be colorized properly.

We must add another additional argument to finish off everything.

    syn region celDescBlock start="{" end="}" fold transparent
    \   contains=celNumber,celBlockCmd

The `contains` argument tells the editor which syntax elements this
region will contain. In this case keywords and numbers. But we have
strings too, right? So let's implement the required syntax elements
since we know all about keywords, matches and regions now. In addition
we pickup another argument along the way, `contained`.

Let's define comments as a syntax element and see how `contained` works.

    syn keyword celTodo contained TODO FIXME XXX NOTE
    syn match celComment "#.*$" contains=celTodo

Comments start with a "\#" and run until the end of line. So that's a
simple regular expression `'#.*$'`. Starts with a "\#" and match all
characters until the end of a line.

`contained` tells the editor that the keyword is only valid when
contained by another syntax element, in this case a `celTodo` is only
treated as a separate syntax element when contained by `celComment`.

#### Bringing it together

    syn keyword celTodo contained TODO FIXME XXX NOTE
    syn match celComment "#.*$" contains=celTodo

    "----------------------------------------------------------------
    " Celestia Star Catalog Numbers
    "----------------------------------------------------------------

    " Regular int like number with - + or nothing in front
    syn match celNumber '\d\+' contained display
    syn match celNumber '[-+]\d\+' contained display

    " Floating point number with decimal no E or e (+,-)
    syn match celNumber '\d\+\.\d*' contained display
    syn match celNumber '[-+]\d\+\.\d*' contained display

    " Floating point like number with E and no decimal point (+,-)
    syn match celNumber '[-+]\=\d[[:digit:]]*[eE][\-+]\=\d\+' contained display
    syn match celNumber '\d[[:digit:]]*[eE][\-+]\=\d\+' contained display

    " Floating point like number with E and decimal point (+,-)
    syn match celNumber '[-+]\=\d[[:digit:]]*\.\d*[eE][\-+]\=\d\+'
    \   contained display
    syn match celNumber '\d[[:digit:]]*\.\d*[eE][\-+]\=\d\+' contained display

    syn region celString start='"' end='"' contained
    syn region celDesc start='"' end='"'

    syn match celHip '\d\{1,6}' nextgroup=celString
    syn region celDescBlock start="{" end="}" fold transparent
    \   contains=ALLBUT,celHip,celDesc

    syn keyword celBlockCmd RA Dec Distance AbsMag nextgroup=celNumber
    syn keyword celBlockCmd SpectralType nextgroup=celString

Telling Vim how to highlight + final touches
--------------------------------------------

We can now take the syntax elements and use the `hi def link` command to
tell Vim how to highlight them.

Set the `b:current_syntax` variable to a name, for example, "cel". That
name can be used to modify the Un/Commentify (F6/Shift-F6) script in
Cream, for example to block comment-out lines with the new file type.

    let b:current_syntax = "cel"

    hi def link celTodo        Todo
    hi def link celComment     Comment
    hi def link celBlockCmd    Statement
    hi def link celHip         Type
    hi def link celString      Constant
    hi def link celDesc        PreProc
    hi def link celNumber      Constant

The `hi def link` command has different types of highlighting options
that we need not consider. The ones used here are:

-   `Todo`: used for the todo comments (ones that have "TODO: something"
    in them)
-   `Comment`: indicates a code comment
-   `Statement`: a code statement like a for loop
-   `Type`: a user defined type generally
-   `PreProc`: a pre-processor statement like `#include <stdio.h>` in C
-   `Constant`: like a string or number in code

These of course are guidelines. In this example, there are no statements
or pre-processor commands, however `celBlockCmd` has been set to use
`Statement` highlighting, and `celHip` will use `Type` highlighting.

You can view more options in Vim with

### Install the syntax file

Save the file, then install it by copying the file to
`~/.vim/syntax/cel.vim` on Unix-based systems, or to
`$HOME/vimfiles/syntax/cel.vim` on Windows systems.

You may need to create the `.vim` (or `vimfiles`) directory, and you may
need to create the `syntax` subdirectory. In Vim, your home directory is
specified with `~` on Unix systems, and `$HOME` on Windows systems. You
can see what directories to use by entering commands like the following
in Vim:

    :echo expand('~')
    :echo expand('~/.vim/syntax/cel.vim')
    :echo $HOME
    :echo expand('$HOME/vimfiles/syntax/cel.vim')

Using the directory specified above means the syntax file will be
available to you, but not to other users. If you want the syntax file to
be available to all users, do not save the file under your home
directory; instead, copy the file under your Vim system directory. The
default for both Unix and Windows is that system-wide syntax files are
placed in the `$VIM/vimfiles/syntax` directory (which you may need to
create). You can see the full path name of the required file by entering
the following in Vim:

    :echo expand('$VIM/vimfiles/syntax/cel.vim')

Another procedure to show the base directories which can be used is to
enter either of the following commands in Vim (the first displays the
value of the `'runtimepath'` option, and the second inserts that value
into the current buffer):

    :set runtimepath?
    :put =&runtimepath

By default, the first item in `runtimepath` is the base directory for
your personal Vim files, and the second item is the base directory for
system-wide Vim files. Place the `syntax` subdirectory under either of
these directories; doing that means your syntax file will not be
overwritten when you next upgrade Vim. Do not use a directory containing
the files distributed with Vim because that will be overwritten during
an upgrade (in particular, do not use the `$VIMRUNTIME` directory).

### Make Vim recognize the filetype

Now we have to make sure Vim knows how to interpret your file. There are
a few methods to add filetype detection for files of this new type. See
for full details, but the basics are here.

#### Add a file in the ftdetect directory

This is probably the simplest method.

Simply create a file in `~/.vim/ftdetect` with the same name as your
syntax file, in this case `~/.vim/ftdetect/cel.vim`. In this file place
a single line to set the filetype on buffer read or creation:

`au BufRead,BufNewFile *.stc set filetype=cel`

Note that this will override any previously detected filetype with the
new filetype.

#### Add to <filetype.vim>

Add filetype detection to <filetype.vim>: in this case the Vim script is
named `cel.vim` so we use the filetype "cel".

    au BufRead,BufNewFile *.stc setfiletype cel

Note the use of instead of `set filetype=`. This is so that Vim does not
override any previously detected filetypes while running this script.
Details .

#### Add to scripts.vim

This method does not apply in our example case, but some filetypes can
only be detected by examining buffer contents. For example, maybe you
have a config file that is actually in XML format but does not have a
normal file extension reflecting that, like \*.xml. Details at .
Basically you just add tests using , , etc. and use them to determine
whether to set the filetype with .

See also
--------

-   [Syntax folding of Vim
    scripts](Syntax folding of Vim scripts "wikilink") for an example of
    adding to an existing syntax instead of creating your own as this
    tip demonstrates.
-   [celstarcat.vim](User:Clearmoments/celstarcat "wikilink") an actual
    stc syntax file
-   [celssc.vim](User:Clearmoments/celssc "wikilink") an actual ssc
    syntax file

