% Learn Vimscript the hard way
% Steve Losh (<steve@stevelosh.com>)
% April 4, 2013

Preface
=======

Programmers shape ideas into text.

That text gets turned into numbers and those numbers bump into other numbers
and *make things happen*.

As programmers, we use text editors to get our ideas out of our heads and create
the chunks of text we call "programs".  Full-time programmers will spend tens of
thousands of hours of their lives interacting with their text editor, during
which they'll be doing many things:

* Getting raw text from their brains into their computers.
* Correcting mistakes in that text.
* Restructuring the text to formulate a problem in a different way.
* Documenting how and why something was done a particular way.
* Communicating with other programmers about all of these things.

Vim is incredibly powerful out of the box, but it doesn't truly shine until you
take some time to customize it for your particular work, habits, and fingers.
This book will introduce you to Vimscript, the main programming language used to
customize Vim.  You'll be able to mold Vim into an editor suited to your own
personal text editing needs and make the rest of your time in Vim more
efficient.

Along the way I'll also mention things that aren't strictly about Vimscript, but
are more about learning and being more efficient in general.  Vimscript isn't
going to help you much if you wind up fiddling with your editor all day instead
of working, so it's important to strike a balance.

The style of this book is a bit different from most other books about
programming languages.  Instead of simply presenting you with facts about how
Vimscript works, it guides you through typing in commands to see what they do.

Sometimes the book will lead you into dead ends before explaining the "right
way" to solve a problem.  Most other books don't do this, or only mention the
sticky issues *after* showing you the solution.  This isn't how things typically
happen in the real world, though.  Often you'll be writing a quick piece of
Vimscript and run into a quirk of the language that you'll need to figure out.
By stepping through this process in the book instead of glossing over it I hope
to get you used to dealing with Vimscript's peculiarities so you're ready when
you find edge cases of your own.  Practice makes perfect.

Each chapter of the book focuses on a single topic.  They're short but packed
with information, so don't just skim them.  If you really want to get the most
out of this book you need to actually type in all of the commands.  You may
already be an experienced programmer who's used to reading code and
understanding it straight away.  If so: it doesn't matter.  Learning Vim and
Vimscript is a different experience from learning a normal programming language.

You need to **type in *all* the commands.**

You need to **do *all* the exercises.**

There are two reasons this is so important.  First, Vimscript is old and has
a lot of dusty corners and twisty hallways.  One configuration option can change
how the entire language works.  By typing *every* command in *every* lesson and
doing *every* exercise you'll discover problems with your Vim build or
configuration on the simpler commands, where they'll be easier to diagnose and
fix.

Second, Vimscript *is* Vim.  To save a file in Vim, you type `:write` (or `:w`
for short) and press return.  To save a file in a Vimscript, you use `write`.
Many of the Vimscript commands you'll learn can be used in your day-to-day
editing as well, but they're only helpful if they're in your muscle memory,
which simply doesn't happen from just reading.

I hope you'll find this book useful.  It's *not* meant to be a comprehensive
guide to Vimscript.  It's meant to get you comfortable enough with the language
to mold Vim to your taste, write some simple plugins for other users, read other
people's code (with regular side-trips to `:help`), and recognize some of the
common pitfalls.

Good luck!

Prerequisites
=============

To use this book you should have the latest version of Vim installed, which is
version 7.3 at the time of this writing.  New versions of Vim are almost always
backwards-compatible, so everything in this book should work fine with anything
after 7.3 too.

Nothing in this book is specific to console Vim or GUI Vims like gVim or MacVim.
You can use whichever you prefer.

You should be comfortable editing files in Vim.  You should know basic Vim
terminology like "buffer", "window", "normal mode", "insert mode" and "text
object".

If you're not at that point yet you should go through the `vimtutor` program,
use Vim exclusively for a month or two, and come back when you've got Vim burned
into your fingers.

You'll also need to have some programming experience.  If you've never
programmed before check out [Learn Python the Hard
Way](http://learnpythonthehardway.org/) first and come back to this book when
you're done.

Creating a Vimrc File
---------------------

If you already know what a `~/.vimrc` file is and have one, go on to the next
chapter.

A `~/.vimrc` file is a file you create that contains some Vimscript code.  Vim
will automatically run the code inside this file every time you open Vim.

On Linux and Mac OS X this file is located in your home directory and named
`.vimrc`.

On Windows this file is located in your home folder and named `_vimrc`.

To easily find the location and name of the file on *any* operating system, run
`:echo $MYVIMRC` in Vim.  The path will be displayed at the bottom of the
screen.

Create this file if it doesn't already exist.

Echoing Messages
================

The first pieces of Vimscript we'll look at are the `echo` and `echom` commands.

You can read their full documentation by running `:help echo` and `:help echom`
in Vim.  As you go through this book you should try to read the `:help` for
every new command you encounter to learn more about them.

Try out `echo` by running the following command:

    :echo "Hello, world!"

You should see `Hello, world!` appear at the bottom of the window.

Persistent Echoing
------------------

Now try out `echom` by running the following command.

    :echom "Hello again, world!"

You should see `Hello again, world!` appear at the bottom of the window.

To see the difference between these two commands, run the following:

    :messages

You should see a list of messages.  `Hello, world!` will *not* be in this list,
but `Hello again, world!` *will* be in it.

When you're writing more complicated Vimscript later in this book you may find
yourself wanting to "print some output" to help you debug problems.  Plain old
`:echo` will print output, but it will often disappear by the time your script
is done.  Using `:echom` will save the output and let you run `:messages` to
view it later.

Comments
--------

Before moving on, let's look at how to add comments.  When you write Vimscript
code (in your `~/.vimrc` file or any other one) you can add comments with the
`"` character, like this:

    " Make space more useful
    nnoremap <space> za

This doesn't *always* work (that's one of those ugly corners of Vimscript), but
in most cases it does.  Later we'll talk about when it won't (and why that
happens).

From the help system
--------------------

### help echo

`:ec[ho] {expr1} ..`

:   Echoes each `{expr1}`, with a space in between.  The first `{expr1}`
    starts on a new line.  Also see `:comment`.  Use `"\n"` to start a
    new line.  Use `"\r"` to move the cursor to the first column.  Uses
    the highlighting set by the `:echohl` command.  Cannot be followed
    by a comment.  Example:

        :echo "the value of 'shell' is" &shell

### help echom

`:echom[sg] {expr1} ..`

:   Echo the expression(s) as a true message, saving the message in the
    `message-history`.  Spaces are placed between the arguments as with
    the `:echo` command.  But unprintable characters are displayed, not
    interpreted.  The parsing works slightly different from `:echo`,
    more like `:execute`.  All the expressions are first evaluated and
    concatenated before echoing anything.  The expressions must evaluate
    to a Number or String, a Dictionary or List causes an error.  Uses
    the highlighting set by the `:echohl` command.  Example:

		:echomsg "It's a Zizzer Zazzer Zuzz, as you can plainly see."

    See `:echo-redraw` to avoid the message disappearing when the screen
    is redrawn.

### help messages

This is an (incomplete) overview of various messages that Vim gives:

    Press ENTER or type command to continue

This message is given when there is something on the screen for you to
read, and the screen is about to be redrawn:

- After executing an external command (e.g., `":!ls"` and `"="`).
- Something is displayed on the status line that is longer than the
  width of the window, or runs into the 'showcmd' or 'ruler' output.

  * Press `<Enter>` or `<Space>` to redraw the screen and continue,
    without that key being used otherwise.
  * Press ':' or any other Normal mode command character to start that
    command.
  * Press 'k', `<Up>`, 'u', 'b' or 'g' to scroll back in the messages.
    This works the same way as at the |more-prompt|.  Only works when
    'compatible' is off and 'more' is on.
  * Pressing 'j', 'f', 'd' or `<Down>` is ignored when messages scrolled
    off the top of the screen, 'compatible' is off and 'more' is on, to
    avoid that typing one 'j' or 'f' too many causes the messages to
    disappear.
  * Press `<C-Y>` to copy (yank) a modeless selection to the clipboard
    register.
  * Use a menu.  The characters defined for Cmdline-mode are used.
  * When 'mouse' contains the 'r' flag, clicking the left mouse button
    works like pressing `<Space>`.  This makes it impossible to select
    text though.
  * For the GUI clicking the left mouse button in the last line works
    like pressing `<Space>`.

{Vi: only ":" commands are interpreted}

If you accidentally hit `<Enter>` or `<Space>` and you want to see the
displayed text then use `g<`.  This only works when 'more' is set.

To reduce the number of hit-enter prompts:
- Set 'cmdheight' to 2 or higher.
- Add flags to 'shortmess'.
- Reset 'showcmd' and/or 'ruler'.

If your script causes the hit-enter prompt and you don't know why, you
may find the `v:scrollstart` variable useful.

Also see 'mouse'.  The hit-enter message is highlighted with the
`hl-Question` group.

    -- More --
    -- More -- SPACE/d/j: screen/page/line down, b/u/k: up, q: quit

This message is given when the screen is filled with messages.  It is only
given when the 'more' option is on.  It is highlighted with the `hl-MoreMsg`
group.

------------------------------------------------------------
Type                                effect
---------------------------------   ------------------------
`<CR>` or `<NL>` or j or `<Down>`	one more line

d					                down a page (half a screen)

`<Space>` or f or `<PageDown>`		down a screen

G					                down all the way, until
                                    the hit-enter prompt

`<BS>` or k or `<Up>`			    one line back `(*)`

u					                up a page (half a screen) `(*)`

b or `<PageUp>`			            back a screen `(*)`

g					                back to the start `(*)`

q, `<Esc>` or CTRL-C			    stop the listing

:					                stop the listing and enter
                                    a command-line
                                    
`<C-Y>`				                yank (copy) a modeless selection
                                    to the clipboard (`"*` and
                                    `"+` registers)

{menu-entry}			            what the menu is defined to in Cmdline-mode.

`<LeftMouse>` `(**)`                next page
-------------------------------------------------------------

Any other key causes the meaning of the keys to be displayed.

`(*)`

:   backwards scrolling is {not in Vi}.  Only scrolls back to where
    messages started to scroll.
    
`(**)`

:   Clicking the left mouse button only works:
        
        - For the GUI: in the last line of the screen.
        - When 'r' is included in 'mouse' (but then selecting text won't
          work).

> Note:
>
> The typed key is directly obtained from the terminal, it is not mapped
> and typeahead is ignored.

The `g<` command can be used to see the last page of previous command output.
This is especially useful if you accidentally typed `<Space>` at the hit-enter
prompt.

Exercises
---------

Add a line to your `~/.vimrc` file that displays a friendly ASCII-art cat
(`>^.^<`) whenever you open Vim.

