Vim More Editing
================

Introduction
------------

Let’s build upon what we learned in the last chapter to explore more
editing tricks in Vim.

Viewing files and reading commands
----------------------------------

We’ve already seen how to edit and write files, but Vim seems to think
there are more things that you can do.

What if you wanted to open a file to read it and not edit it? This can
also be done by running `vim -R` which starts Vim in read-only mode. Or
if you have the file already open in Vim, then you can run `:set ro` to
make the buffer read-only. The advantage of using this option is that
viewing large files will be faster because Vim doesn’t have to worry
about making changes to it.

What if you wanted to insert the contents of another file into the
current file? Just run `:r another_file.txt` and the contents of that
file will be “read” and inserted into the current buffer. This is useful
in many circumstances such as combining two different files or even
making a copy of the file and making minor modifications, and so on.

A cool side-effect about the `:r` command is that you can use it to read
the output of commands and not just files.

For example, install the _GCal_ program and run:

    :r !gcal -s1 -K

This inserts the calendar for the current month (`!gcal`) with the week
starting from Monday (`s1`) and also displays the week number (`K`). The
text will look something like this:

             April 2007
        Mo Tu We Th Fr Sa Su CW
                           1 13
         2  3  4< 5> 6  7  8 14
         9 10 11 12 13 14 15 15
        16 17 18 19 20 21 22 16
        23 24 25 26 27 28 29 17
        30                   18

Imagine the possibilities of how you can use external commands to add
relevant information to your own text…

Register all these memories
---------------------------

Let’s take our usual sample text:

> _I have coined a phrase for myself – ‘CUT to the G’:_
>
> 1. _Concentrate_
> 2. _Understand_
> 3. _Think_
> 4. _Get Things Done_
>
> _Step 4 is eventually what gets you moving, but Steps 2 and 3 are
> equally important. As Abraham Lincoln once said “If I had eight hours
> to chop down a tree, I’d spend six hours sharpening my axe.” And to
> get to this stage, you need to do Step 1 which boils down to one thing
> – It’s all in the mind. That’s why it’s so hard._

Now, let’s say you want to copy the 4 bullet points to another place,
perhaps in the summary. You also want to cut the second sentence to put
it somewhere else. Wouldn’t this be easy if you can store these two
separate pieces of text in two different places for now, continue our
work, and then paste them later? This is achieved using registers, which
are (again) parts of your computer’s memory, using which you can quickly
store and retrieve text.

For example, you can place the cursor on the line containing the text
`1\. Concentrate`, press `"a4yy`:

* `"a` → use the register named ‘a’ for
* `4` → 4 times the operation of
* `yy` → yank a line

This translates to “copy the next 4 lines into the register named ‘a’”.

For the next step, we can visually select the second sentence in the
last paragraph, and press `"bd` to ‘d’elete the text into the register
named ‘b’.

Now, that we have copied the appropriate text into the buffers, we can
paste the text wherever required – just press `"ap` which means ‘p’aste
the text from the register named ‘a’ and similarly `"bp` pastes the text
from the register named ‘b’ and so on.

To see the contents of all the registers, run:

    :registers

Notice how Vim takes even the simple concept of clipboard and makes it
so powerful!

See `:help registers` for the different types of registers in Vim.

Text formatting
---------------

Do you want to center some text? Let’s say like this text:

       THIS IS THE HEADING

Just run:

    :set textwidth=70
    :center

You will get the following result:

                                THIS IS THE HEADING

Setting `:set textwidth=70` will cause all paragraphs to have a maximum
width of 70, and if you write lines longer than 70 characters, Vim
automatically moves the word exceeding the length to the next line.

For example, take the text:


   Step 4 is eventually what gets you moving, but Steps 2 and 3 are equally
   important. As Abraham Lincoln once said "If I had eight hours to chop down a
   tree, I'd spend six hours sharpening my axe." And to get to this stage, you need
   to do Step 1 which boils down to one thing - It's all in the mind. That's why
   it's so hard.

They’ve been written with a `textwidth` of 80. We want to reformat the
paragraph now to fit into a maximum of 70 columns. So, just run

    :set textwidth=70
    gwap

The second command can be understood as:

* `gw` means ‘g’o format this text and also go back ‘w’here I was
* `ap` means ‘a’ ‘p’aragraph

Voila! The text becomes:


    Step 4 is eventually what gets you moving, but Steps 2 and 3 are
    equally important. As Abraham Lincoln once said "If I had eight hours
    to chop down a tree, I'd spend six hours sharpening my axe." And to
    get to this stage, you need to do Step 1 which boils down to one thing
    - It's all in the mind. That's why it's so hard.


See `:help formatting` and `:help formatoptions` for more details.

Also, similar to `:center`, there are `:left` and `:right` commands to
left-align and right-align the text respectively.

Search and replace
------------------

We have seen how to search for text. What if we wanted to ‘search and
replace’? Then, use the `:s` command.

For example, say you have the text:

    Setp 4 is eventually what gets you moving, but Setps 2 and 3 are equally
    important. As Abraham Lincoln once said "If I had eight hours to chop down a
    tree, I'd spend six hours sharpening my axe." And to get to this stage, you need
    to do Setp 1 which boils down to one thing - It's all in the mind. That's why
    it's so hard.

We want to replace all the spelling mistakes of `setp` to `step`. So,
just run:

    :s/setp/step/g

This command should be read as follows:

    :s/pattern/replacement text/options

We have already seen how patterns can be as complex as we need it. The
replacement patterns can also have special syntax to make use of the
original search pattern. For example, if we want to swap two words, we
can use:

    :s/(bachchan) (amitabh)/2 1/g

This converts the text from `bachchan amitabh` to `amitabh bachchan`.

The options can specify how the replacement should work. By default, the
search and replace works only on the first occurrence of the search
pattern in a line. To make it work on all occurrences, we give the `g`
option which means ‘g’lobal. If we want a confirmation of each change,
then specify the `c` option which means `c`onfirm every substitution.

Abbreviations
-------------

Sometimes you tend to write the same text over and over again. So why
not use shortcuts? They’re called abbreviations in Vim.

For example, if you repeatedly write the text `Highly Amazing
Corporation Pvt. Ltd.`, then you can run:

    :iab hac Highly Amazing Corporation Pvt. Ltd.

Now, when you are writing the text and enter `h`, `a`, `c`, `<space>`,
it will be automatically expanded to the above text!

Run `:verbose abbreviate` to see the list of abbreviations currently
set.

See `:help:ab` and `:help:unab` for details.

Spell checking
--------------

An important feature added in the latest version 7 of Vim is spell
checking. This lets Vim look for spelling mistakes in your text and help
you correct them.

More accurately, Vim looks for words that are present in a “good words
list”, i.e., a spell file and then flags the remaining words as possible
mistakes.

Let’s start with the following text:

    Setp 4 is eventually what gets you moving, but Setps 2 and 3 are equally
    important. As Abraham Lincoln once said "If I had eight hours to chop down a
    tree, I'd spend six hours sharpening my axe." And to get to this stage, you need
    to do Setp 1 which boils down to one thing - It's all in the mind. That's why
    it's so hard.

To enable spell checking, run:

    :setlocal spell spelllang=en_us

Here ‘en’ stands for ‘English’ and ‘us’ stands for USA. You can choose
the language and locale of your choice depending on the text. However,
the corresponding spell files must be installed in the
`$VIMRUNTIME/spell/` directory. If not, Vim will prompt you on whether
it should automatically download the spell file from the Vim website.

Vim should now display a red squiggly line below the “Setp” and similar
mistakes. The exact color depends on your `colorscheme` setting.

Press `]s` to move to the next ‘bad word’, i.e., incorrect spelling.

Now press `z=` to ask Vim for suggestions on good words. It’ll display a
list of choices. You can type the number for the choice that you think
is correct and press enter to replace the word with the selected choice,
or simply press enter to cancel.

If you want to see a score for each word on how ‘good’ a replacement
choice the word is, run `:set verbose=1` and then run `z=`.

In our case, we can replace “Setp” with “Step”, but we have the same
word again. It would be better if we can make this substitution
everywhere in the text. For that, we can run `:spellrepall`.

Consider the text:

    Swaroop is a name.

In this case, Vim flags that ‘Swaroop’ is a “bad word”. We know that it
is a name and for our purposes, we want to add it to the good word list
so that Vim doesn’t mark this word everytime. For this, we can run `zg`
to add to the ‘g’ood words list.

To know more information about which spell file is being used, you can
run `:spellinfo`.

I find spell-checking to be useful when I can toggle it on and off so
that it doesn’t hamper my normal editing. So, I’ve added the following
lines to my _vimrc file_ so that I can use F4 to do the toggling:

    " Spell check
    function! ToggleSpell()
        if !exists("b:spell")
            setlocal spell spelllang=en_us
            let b:spell = 1
        else
            setlocal nospell
            unlet b:spell
        endif
    endfunction

    nmap <F4> :call ToggleSpell()<CR>
    imap <F4> <Esc>:call ToggleSpell()<CR>a

Spell-checking is a huge topic on its own, so if you’re interested in
how spell checking is implemented in Vim, and also about how you can add
spellings or word lists for your language of choice, please see `:help
spell`.

Rectangular selection
---------------------

When we are editing tabular data, sometimes we would want to copy only a
few columns from the text as opposed to a few lines. For this, we can
use the rectangular block selection mode in Vim by pressing `ctrl-v`.

Consider the following sample text:

    1. Concentrate
    2. Understand
    3. Think
    4. Get Things Done

1. Place the cursor on the capital ‘C’ in the first line.
2. Press `ctrl-v`.
3. Press `3j` to travel down 3 lines.
4. Press `$` to move right towards the end of the line.
5. Press `y` to yank the text to the default register.
6. Run `:new` and press `p` to paste the rectangular selection.

The new file should have the following contents:

    Concentrate
    Understand
    Think
    Get Things Done

See `:help ctrl-v` for details.

Remote file editing
-------------------

You can directly edit a file in a remote ftp site using Vim. Just run
`vim ftp://ftp.foo.com/bar` command or run `:Nread
ftp://ftp.foo.com/bar` in Vim.

This makes use of the built-in “netrw” plugin in Vim using which you can
also edit remote files via scp, http, webdav and other protocols. See
`:help netrw-urls` for details.

You can even provide the username and password in your `~/.netrc` file
so that Vim can automatically login for you.

See `:help netrw-start` for more details.

Summary
-------

We have dived a little deeper into the range of editing features that
Vim provides. This should give you an idea of the wide range of things
that you can do. Again, the important thing is not to know every feature
but to learn what is important to you right now and make it a habit, and
then learn the other features/options/plugins as and when required.

It might be a good idea to browse through the “Editing Effectively”
section of `:help user-manual` and read any topics that you find
interesting.

* * * *
