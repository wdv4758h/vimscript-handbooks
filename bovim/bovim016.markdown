
[Source](http://swaroopch.com/notes/Vim_en-Programmers_Editor/ "Permalink to Vim en:Programmers Editor")

# Vim en:Programmers Editor

##  Introduction

Vim tends to be heavily used by programmers. The features, ease of use and flexibility that Vim provides makes it a good choice for people who write a lot of code. This should not seem surprising since writing code involves a lot of editing.

Let me reiterate that typing skills are critical for a programmer. If our [earlier discussion][1] didn’t convince you, hope this [article by Jeff Atwood on ‘We Are Typists First, Programmers Second’][2] will convince you.

If you do not have programming experience, you can skip this chapter.

For those who love programming, let’s dive in and see Vim can help you in writing code.

##  Simple stuff

The simplest feature of Vim that you can utilize to help you in writing code is to use syntax highlighting. This allows you to visualize, i.e., “see” your code which helps you in reading and writing your code faster and also helps avoid making obvious mistakes.

###  Syntax highlighting

![Syntax highlighting.png][3]

![][4]

Suppose you are editing a vim syntax file, run `:set filetype=vim` and see how Vim adds color. Similarly, if you are editing a Python file, run `:set filetype=python`.

To see the list of language types available, check the `$VIMRUNTIME/syntax/` directory.

Tip
     If you want the power of syntax highlighting for any Unix shell output, just pipe it to Vim, for example `svn diff | vim -R -`. Notice the dash in the end which tells Vim that it should read text from its standard input.

###  Smart indentation

An experienced programmer’s code is usually indented properly which makes the code look “uniform” and the structure of the code is more visually apparent. Vim can help by doing the indentation for you so that you can concentrate on the actual code.

If you indent a particular line and want the lines following it to be also indented to the same level, then you can use the `:set autoindent` setting.

If you start a new block of statements and want the next line to be automatically indented to the next level, then you can use the `:set smartindent` setting. Note that the behavior of this setting is dependent on the particular programming language being used.

###  Bounce

If the programming language of your choice uses curly brackets to demarcate blocks of statements, place your cursor on one of the curly brackets, and press the `%` key to jump to the corresponding curly bracket. This bounce key allows you to jump between the start and end of a block quickly.

###  Shell commands

You can run a shell command from within Vim using the `:!` command.

For example, if the `date` command is available on your operating system, run `:!date` and you should see the current date and time printed out.

This is useful in situations where you want to check something with the file system, for example, quickly checking what files are in the current directory using `:!ls` or `:!dir` and so on.

If you want access to a full-fledged shell, run `:sh`.

We can use this facility to run external filters for the text being edited. For example, if you have a bunch of lines that you want to sort, then you can run `:%!sort`, this passes the current text to the `sort` command in the shell and then the output of that command replaces the current content of the file.

##  Jumping around

There are many ways of jumping around the code.

  * Position your cursor on a filename in the code and then press `gf` to open the file.
  * Position your cursor on a variable name and press `gd` to move to the local definition of the variable name. `gD` achieves the same for the global declaration by searching from the start of the file.
  * Use `]]` to move to the next `{` in the first column. There are many similar motions – see `:help object-motions` for details.
  * See `:help 29.3`, `:help 29.4`, and `:help 29.5` for more such commands. For example, `[I` will display all lines that contain the keyword that is under the cursor!

##  Browsing parts of the code

###  File system

Use `:Vex` or `:Sex` to browse the file system within Vim and subsequently open the required files.

###  ctags

We have now seen how to achieve simple movements within the same file, but what if we wanted to move between different files and have cross-references between files? Then, we can use tags to achieve this.

For simple browsing of the file, we can use the `taglist.vim` plugin.

![][5]

![][4]

Taglist in action

  1. Install the [Exuberant ctags][6] program.
  2. Install the [taglist.vim][7] plugin. Refer the "install details" on the script page.
  3. Run `:TlistToggle` to open the taglist window. Voila, now you can browse through parts of your program such as macros, typedefs, variables and functions.
  4. You can use `:tag foo` to jump to the definition of `foo`.
  5. Position your cursor on any symbol and press `ctrl-]` to jump to the definition of that symbol.
    * Press `ctrl-t` to return to the previous code you were reading.
  6. Use `ctrl-w ]` to jump to the definition of the symbol in a split window.
  7. Use `:tnext`, `:tprev`, `:tfirst`, `:tlast` to move between matching tags.

Note that exuberant Ctags supports 33 programming languages as of this writing, and it can easily be extended for other languages.

See `:help taglist-intro` for details.

###  cscope

To be able to jump to definitions across files, we need a program like cscope. However, as the name suggests, this particular program works only for the C programming language.

![][8]

![][4]

cscope in action

  1. Install cscope. Refer `:help cscope-info` and `:help cscope-win32` regarding installation.
  2. Copy [cscope_maps.vim][9] to your `~/.vim/plugin/` directory.
  3. Switch to your source code directory and run `cscope -R -b` to ‘b’uild the database ‘r’ecursively for all subdirectories.
  4. Restart Vim and open a source code file.
  5. Run `:cscope show` to confirm that there is a cscope connection created.
  6. Run `:cscope find symbol foo` to locate the symbol `foo`. You can shorten this command to `:cs f s foo`.

You can also:

  * Find this definition – `:cs f g`
  * Find functions called by this function – `:cs f d`
  * Find functions calling this function – `:cs f c`
  * Find this text string – `:cs f t`
  * Find this egrep pattern – `:cs f e`

See `:help cscope-suggestions` for suggested usage of cscope with Vim.

Also, the [Source Code Obedience][10] plugin is worth checking out as it provides easy shortcut keys on top of cscope/ctags.

While we are on the subject of C programming language, the [c.vim][11] plugin can be quite handy.

##  Compiling

We have already seen in the [previous chapter][12] regarding `:make` for the programs we are writing, so we won’t repeat it here.

##  Easy writing

###  Omnicompletion

One of the most-requested features which was added in Vim 7 is “omnicompletion” where the text can be auto-completed based on the current context. For example, if you are using a long variable name and you are using the name repeatedly, you can use a keyboard shortcut to ask Vim to auto-complete and it’ll figure out the rest.

Vim accomplishes this via ftplugins, specifically the ones by the name `ftplugin/complete.vim` such as `pythoncomplete.vim`.

Let’s start the example with a simple Python program:


    def hello():
        print 'hello world'

    def helpme():
        print 'help yourself'

![][13]

![][4]

Omni-completion in action

After typing this program, start a new line in the same file, type ‘he’ and press `ctrl-x ctrl-o` which will show you suggestions for the autocompletion.

If you get an error like `E764: Option 'omnifunc' is not set`, then run `:runtime! autoload/pythoncomplete.vim` to load the omnicompletion plugin.

To avoid doing this every time, you can add the following line to your `~/.vimrc`:


    autocmd FileType python runtime! autoload/pythoncomplete.vim

Vim automatically uses the first suggestion, you can change to the next or previous selection using `ctrl-n` and `ctrl-p` respectively.

In case you want to abort using the omnicompletion, simply press `esc`.

Refer `:help new-omni-completion` for details on what languages are supported (C, HTML, JavaScript, PHP, Python, Ruby, SQL, XML, …) as well as how to create your own omnicompletion scripts.

Note
     If you are more comfortable in using the arrow keys to select your choice from the omnicompletion list, see [Vim Tip 1228][14] on how to enable that.

I prefer to use a simple `ctrl-space` instead of the unwieldy `ctrl-x ctrl-o` key combination. To achieve this, put this in your `vimrc`:


    imap &lt;c-space&gt; &lt;c-x&gt;&lt;c-o&gt;

Relatedly, the [PySmell plugin][15] may be of help to Vim users who code in Python.

###  Using Snippets

Code snippets are small pieces of code that you repetitively tend to write. Like all good lazy programmers, you can use a plugin that helps you to do that. In our case, we use the amazing SnippetsEmu plugin.

  1. Download the [snippetsEmu][16] plugin.
  2. Create your `~/.vim/after/` directory if it doesn’t already exist.
  3. Start Vim by providing this plugin name on the command line. For example, start Vim as `gvim snippy_bundles.vba`
  4. Run `:source%`. The ‘vimball’ will now unpack and store the many files in the appropriate directories.
  5. Repeat the same process for `snippy_plugin.vba`

Now, let’s try using this plugin.

1\. Open a new file called, say, `test.py`.

2\. Press the keys `d`, `e`, `f` and then ``.

3\. Voila! See, how snippetsEmu has created a structure of your function already. You should now see this in your file:


    def &lt;{fname}&gt;(&lt;{args}&gt;):
        """
        &lt;{}&gt;
        &lt;{args}&gt;"""
        &lt;{pass}&gt;
        &lt;{}&gt;

Note
     In case you see `def` and nothing else happened, then perhaps the snippets plugin is not loaded. Run `:runtime! ftplugin/python_snippets.vim` and see if that helps.

4\. Your cursor is now positioned on the function name, i.e., `fname`.

5\. Type the function name, say, `test`.

6\. Press `` and the cursor is automatically moved to the arguments. Tab again to move to the next item to be filled.

7\. Now enter a comment: `Just say Hi`

8\. Tab again and type `print 'Hello World'`

9\. Press tab

10\. Your program is complete!

You should now see:


    def test():
        """
        Just say Hi
        """
        print 'Hello World'

The best part is that SnippetsEmu enables a standard convention to be followed and that nobody in the team ‘forgets’ it.

###  Creating Snippets

Let’s now see how to create our own snippets.

Let us consider the case where I tend to repeatedly write the following kind of code in ActionScript3:


    private var _foo:Object;

    public function get foo():Object
    {
        return _foo;
    }

    public function set foo(value:Object)
    {
        _foo = value;
    }

This is a simple getter/setter combination using a backing variable. The problem is that’s an awful lot of boilerplate code to write repeatedly. Let’s see how to automate this.

The SnippetsEmu language snippets plugins assume `st` as the start tag and `et` as the end tag – these are the same arrow-type symbols you see in-between which we enter our code.

Let’s start with a simple example.


    exec "Snippet pubfun public function ".st.et.":".st.et."&lt;CR&gt;{&lt;CR&gt;".st.et."&lt;CR&gt;}&lt;CR&gt;"

Add the above line to your `~/.vim/after/ftplugin/actionscript_snippets.vim`.

Now open a new file, say, `test.as` and then type `pubfun` and press `` and see it expanded to:


    public function &lt;{}&gt;:&lt;{}&gt;
    {

    }

The cursor will be positioned for the function name, tab to enter the return type of the function, tab again to type the body of the function.

Going back to our original problem, here’s what I came up with:


    exec "Snippet getset private var _".st."name".et.";&lt;CR&gt;&lt;CR&gt;public function get ".st."name".et."():".st."type".et."&lt;CR&gt;{&lt;CR&gt;&lt;tab&gt;return _".st."name".et.";&lt;CR&gt;}&lt;CR&gt;&lt;CR&gt;public function set ".st."name".et."(value:".st."type".et.")&lt;CR&gt;{&lt;CR&gt;&lt;tab&gt;_".st."name".et." = value;&lt;CR&gt;}&lt;CR&gt;"

Note
     All snippets for this plugin _must_ be entered on a _single line_. It is a technical limitation.

Follow the same procedure above to use this new snippet:

1\. Add this line to your `~/.vim/after/ftplugin/actionscript_snippets.vim`.

2\. Open a new file such as `test.as`.

3\. Type `getset` and press `` and you will see this:


    private var _&lt;{name}&gt;;

    public function get &lt;{name}&gt;():&lt;{type}&gt;
    {
            return _&lt;{name}&gt;;
    }

    public function set &lt;{name}&gt;(value:&lt;{type}&gt;)
    {
            _&lt;{name}&gt; = value;
    }

4\. Type `color` and press ``. Notice that the variable name `color` is replaced everywhere.

5\. Type `Number` and press ``. The code now looks like this:


    private var _color;

    public function get color():Number
    {
            return _color;
    }

    public function set color(value:Number)
    {
            _color = value;
    }

Notice how much of keystrokes we have reduced! We have replaced writing around 11 lines of repetitive code by a single Vim script line.

We can keep adding such snippets to make coding more lazier and will help us concentrate on the real work in the software.

See `:help snippets_emu.txt` for more details (this help file will be available only after you install the plugin).

##  IDE

Vim can be actually used as an IDE with the help of a few plugins.

###  Project plugin

The Project plugin is used to create a Project-manager kind of usage to Vim.

  1. Download the [project][17] plugin.
  2. Unarchive it to your `~/.vim/` directory.
  3. Run `:helptags ~/.vim/doc/`.
  4. Download Vim source code from 
  5. Run `:Project`. A sidebar will open up in the left which will act as your ‘project window’.
  6. Run `c` (backslash followed by ‘c’)
  7. Give answers for the following options
    * Name of entry, say ‘vim7_src’
    * Directory, say `C:repovim7src`
    * CD option, same as directory above
    * Filter option, say `*.h *.c`
  8. You will see the sidebar filled up with the list of files that match the filter in the specified directory.
  9. Use the arrow keys or `j`/`k` keys to move up and down the list of files, and press the enter key to open the file in the main window.

This gives you the familiar IDE-kind of interface, the good thing is that there are no fancy configuration files or crufty path setups in IDEs which usually have issues always. The Project plugin’s functionality is simple and straightforward.

You can use the standard fold commands to open and close the projects and their details.

You can also run scripts at the start and end of using a project, this helps you to setup the PATH or set compiler options and so on.

See `:help project.txt` for more details.

###  Running code from the text

You can run code directly from Vim using plugins such as [EvalSelection.vim][18] or simpler plugins like [inc-python.vim][19].

###  SCM integration

If you start editing a file, you can even make it automatically checked out from Perforce using the [perforce plugin][20]. Similarly, there is a [CVS/SVN/SVK/Git integration plugin][21].

###  More

To explore more plugins to implement IDE-like behavior in Vim, see:

There are more language-specific plugins that can help you do nifty things. For example, for Python, the following plugins can be helpful:

  * [SuperTab][22] allows you to call omni-completion by just pressing tab and then use arrow keys to choose the option.
  * [python_calltips][23] shows a window at the bottom which gives you the list of possibilities for completion. The cool thing about this compared to omni-completion is that you get to view the documentation for each of the possibilities.
  * [VimPdb][24] helps you to debug Python programs from within Vim.

###  Writing your own plugins

You can write your own plugins to extend Vim in any way that you want. For example, here’s a task that you can take on:

&gt; Write a Vim plugin that takes the current word and opens a browser with the documentation for that particular word (the word can be a function name or a class name, etc.).

If you really can’t think of how to approach this, take a look at [“Online documentation for word under cursor” tip at the Vim Tips wiki][25].

I have extended the same tip and made it more generic:


    " Add the following lines to your ~/.vimrc to enable online documentation
    " Inspiration: http://vim.wikia.com/wiki/Online_documentation_for_word_under_cursor

    function Browser()
        if has("win32") || has("win64")
            let s:browser = "C:Program FilesMozilla Firefoxfirefox.exe -new-tab"
        elseif has("win32unix") " Cygwin
            let s:browser = "'/cygdrive/c/Program Files/Mozilla Firefox/firefox.exe' -new-tab"
        elseif has("mac") || has("macunix") || has("unix")
            let s:browser = "firefox -new-tab"
        endif

        return s:browser
    endfunction

    function Run(command)
        if has("win32") || has("win64")
            let s:startCommand = "!start"
            let s:endCommand = ""
        elseif has("mac") || has("macunix") " TODO Untested on Mac
            let s:startCommand = "!open -a"
            let s:endCommand = ""
        elseif has("unix") || has("win32unix")
            let s:startCommand = "!"
            let s:endCommand = "&amp;"
        else
            echo "Don't know how to handle this OS!"
            finish
        endif

        let s:cmd = "silent " . s:startCommand . " " . a:command . " " . s:endCommand
        " echo s:cmd
        execute s:cmd
    endfunction

    function OnlineDoc()
        if &amp;filetype == "viki"
            " Dictionary
            let s:urlTemplate = "http://dictionary.reference.com/browse/&lt;name&gt;"
        elseif &amp;filetype == "perl"
            let s:urlTemplate = "http://perldoc.perl.org/functions/&lt;name&gt;.html"
        elseif &amp;filetype == "python"
            let s:urlTemplate = "http://www.google.com/search?q=&lt;name&gt;&amp;domains=docs.python.org&amp;sitesearch=docs.python.org"
        elseif &amp;filetype == "ruby"
            let s:urlTemplate = "http://www.ruby-doc.org/core/classes/&lt;name&gt;.html"
        elseif &amp;filetype == "vim"
            let s:urlTemplate = "http://vimdoc.sourceforge.net/search.php?search=&lt;name&gt;&amp;docs=help"
        endif

        let s:wordUnderCursor = expand("&lt;cword&gt;")
        let s:url = substitute(s:urlTemplate, '&lt;name&gt;', s:wordUnderCursor, 'g')

        call Run(Browser() . " " . s:url)
    endfunction

    noremap &lt;silent&gt; &lt;M-d&gt; :call OnlineDoc()&lt;CR&gt;
    inoremap &lt;silent&gt; &lt;M-d&gt; &lt;Esc&gt;:call OnlineDoc()&lt;CR&gt;a

##  Access Databases

You can even talk to some 10 different databases from Oracle to MySQL to PostgreSQL to Sybase to SQLite, all from Vim, using the [dbext.vim plugin][26]. The best part is that this plugin helps you to edit SQL written within PHP, Perl, Java, etc. and you can even directly execute the SQL even though it is embedded within another programming language and even asking you for values for variables.

##  Summary

We have learned how Vim can be used for programming with the help of various plugins and settings. If we need a feature, it can be solved by writing our own Vim plugins (as we have discussed in the [Scripting][27] chapter).

A good source of related discussions is at [Stack Overflow][28] and [Peteris Krumins’s blog][29].

* * *

   [1]: http://swaroopch.com/notes/Vim_en-Typing_Skills (Vim en:Typing Skills)
   [2]: http://www.codinghorror.com/blog/archives/001188.html
   [3]: http://swaroopch.com/mediawiki/images/thumb/2/28/Syntax_highlighting.png/180px-Syntax_highlighting.png
   [4]: http://swaroopch.com/mediawiki/skins/common/images/magnify-clip.png
   [5]: http://swaroopch.com/mediawiki/images/thumb/7/71/Taglist_screenshot.png/180px-Taglist_screenshot.png
   [6]: http://ctags.sourceforge.net
   [7]: http://www.vim.org/scripts/script.php?script_id=273
   [8]: http://swaroopch.com/mediawiki/images/thumb/b/b1/Cscope_screenshot.png/180px-Cscope_screenshot.png
   [9]: http://cscope.sourceforge.net/cscope_maps.vim
   [10]: http://www.vim.org/scripts/script.php?script_id=1638
   [11]: http://vim.sourceforge.net/scripts/script.php?script_id=213
   [12]: http://swaroopch.com/notes/Vim_en-Plugins#compiler_plugin (Vim en:Plugins)
   [13]: http://swaroopch.com/mediawiki/images/thumb/1/16/Omnicompletion_screenshot.png/180px-Omnicompletion_screenshot.png
   [14]: http://www.vim.org/tips/tip.php?tip_id=1228
   [15]: http://code.google.com/p/pysmell/
   [16]: http://www.vim.org/scripts/script.php?script_id=1318
   [17]: http://www.vim.org/scripts/script.php?script_id=69
   [18]: http://www.vim.org/scripts/script.php?script_id=889
   [19]: http://www.vim.org/scripts/script.php?script_id=1941
   [20]: http://www.vim.org/scripts/script.php?script_id=240
   [21]: http://www.vim.org/scripts/script.php?script_id=90
   [22]: http://www.vim.org/scripts/script.php?script_id=1643
   [23]: http://www.vim.org/scripts/script.php?script_id=1074
   [24]: http://www.vim.org/scripts/script.php?script_id=2043
   [25]: http://vim.wikia.com/wiki/Online_documentation_for_word_under_cursor
   [26]: http://www.vim.org/scripts/script.php?script_id=356
   [27]: http://swaroopch.com/notes/Vim_en-Scripting (Vim en:Scripting)
   [28]: http://stackoverflow.com/questions/tagged/vim
   [29]: http://www.catonmat.net/tag/vim
  
