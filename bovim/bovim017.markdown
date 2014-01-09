
[Source](http://swaroopch.com/notes/Vim_en-More/ "Permalink to Vim en:More")

# Vim en:More

##  Introduction

We’ve explored so many features of Vim, but we still haven’t covered them all, so let’s take a quick wild ride through various topics that are useful and fun.

##  Modeline

What if you wanted to specify that a certain file should always use pure tabs and no spaces while editing. Can we enforce that within the file itself?

Yes, just put `vim: noexpandtab` within the first two lines or last two lines of your file.

An example:


    # Sample Makefile
    .cpp:
        $(CXX) $(CXXFLAGS) $&lt; -o $@

    # vim: noexpandtab

This line that we are adding is called a “modeline.”

##  Portable Vim

If you keep switching between different computers, isn’t it a pain to maintain your Vim setup exactly the same on each machine? Wouldn’t it be useful if you could just carry Vim around in your own USB disk? This is exactly what [Portable GVim][1] is.

Just unzip into a directory on the portable disk, then run `GVimPortable.exe`. You can even store your own `vimrc` and other related files on the disk and use it anywhere you have a Microsoft Windows computer.

##  Upgrade plugins

Any sufficiently advanced Vim user would be using a bunch of plugins and scripts added to their `~/.vim` or `~/vimfiles` directory. What if we wanted to update them all to the latest versions? You could visit the script page for each of them, download and install them, but there’s a better way – just run `:GLVS` (which stands for ‘G’et ‘L’atest ‘V’im ‘S’cripts).

See `:help getscript` for details.

There are scripts to even [twitter from Vim][2]!

##  Dr. Chip’s plugins

“Dr. Chip” has written some amazing [Vim plugins][3] over many years. My favorite ones are the `drawit.vim` which help you to draw actual text-based drawings such as all those fancy ASCII diagrams that you have seen before.

Another favorite is [Align.vim][4] which helps you to align consecutive lines together. For example, say you have the following piece of program code:


    a = 1
    bbbbb = 2
    cccccccccc = 3

Just visually select these three lines and press `t=`, and voila, it becomes like this:


    a          = 1
    bbbbb      = 2
    cccccccccc = 3

This is much easier to read than before and makes your code look more professional.

Explore Dr. Chip’s page to find out about many more interesting plugins.

##  Blog from Vim

Using the [Vimpress plugin][5], you can blog to your WordPress blog right within Vim.

##  Make Firefox work like Vim

Use the [Vimperator add-on][6] to make Firefox behave like Vim, complete with modal behavior, keyboard shortcuts to visit links, status line, tab completion and even marks support!

##  Bram’s talk on the seven habits

Bram Moolenaar, the creator of Vim, had written an article long ago titled [“Seven habits of effective text editing”][7] that explained how you should use a good editor (such as Vim).

Bram recently gave a talk titled [“Seven habits for effective text editing, 2.0″][8] where he goes on to describe the newer features of Vim as well as how to effectively use Vim. This talk is a good listen for any regular Vim user.

##  Contribute to Vim

You can contribute to Vim in various ways such as [working on development of Vim itself][9], [writing plugins and color schemes][10], contributing [tips][11] and helping with the [documentation][12].

If you want to help in the development of Vim itself, see `:help development`.

##  Community

Many Vim users hang out at the [vim@vim.org mailing list][13] where questions and doubts are asked and answered. The best way to learn more about Vim and to help other beginners learn Vim is to frequently read (and reply) to emails in this mailing list.

You can also ask questions at [Stack Overflow by tagging the question as ‘vim’][14] and you’ll find useful discussions there, such as the one on [“What are your favorite vim tricks?”][15]

You can also find articles and discussions at [delicious][16] and [reddit][17].

##  Summary

We’ve seen some wide range of Vim-related stuff and how it can be beneficial to us. Feel free to explore these and many more [Vim scripts][10] to help you ease your editing and make it even more convenient.

* * *

   [1]: http://portablegvim.sourceforge.net
   [2]: http://www.vim.org/scripts/script.php?script_id=1853
   [3]: http://mysite.verizon.net/astronaut/vim/
   [4]: http://www.vim.org/scripts/script.php?script_id=294
   [5]: http://www.vim.org/scripts/script.php?script_id=1953
   [6]: http://vimperator.mozdev.org/
   [7]: http://www.moolenaar.net/habits.html
   [8]: http://video.google.com/videoplay?docid=2538831956647446078&amp;q=%22Google%2BengEDU%22
   [9]: http://groups.google.com/group/vim_dev
   [10]: http://www.vim.org/scripts/
   [11]: http://vim.wikia.com
   [12]: http://vimdoc.sourceforge.net
   [13]: http://www.vim.org/maillist.php#vim
   [14]: http://stackoverflow.com/questions/tagged/vim
   [15]: http://stackoverflow.com/questions/95072/what-are-your-favorite-vim-tricks
   [16]: http://delicious.com/popular/vim
   [17]: http://www.reddit.com/r/vim/
  
