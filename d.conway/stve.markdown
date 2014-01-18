% Scripting the Vim Editor
% Dr. Damian Conway (<damian@conway.org>)
% 6 May 2009 -- 3 March 2010

# Variables, values, and expressions #

## Start with the basic elements of Vimscript ##

Vimscript is a mechanism for reshaping and extending the Vim editor.
Scripting allows you to create new tools, simplify common tasks, and
even redesign and replace existing editor features. This article (the
first in a series) introduces the fundamental components of the
Vimscript programming language: values, variables, expressions,
statements, functions, and commands. These features are demonstrated and
explained through a series of simple examples.


## A great text editor ##

There's an old joke that Emacs would be a great operating system if only
it had a decent text editor, whereas vi would be a great text editor if
only it had a decent operating system. This gag reflects the single
greatest strategic advantage that Emacs has always had over vi: an
embedded extension programming language. Indeed, the fact that Emacs
users are happy to put up with RSI-inducing control chords and are
willing to write their extensions in Lisp shows just how great an
advantage a built-in extension language must be.

But vi programmers no longer need cast envious glances towards Emacs'
parenthetical scripting language. Our favorite editor can be scripted
too—and much more humanely than Emacs.

In this series of articles, we'll look at the most popular modern
variant of vi, the Vim editor, and at the simple yet extremely powerful
scripting language that Vim provides. This first article explores the
basic building blocks of Vim scripting: variables, values, expressions,
simple flow control, and a few of Vim's numerous utility functions.

I'll assume that you already have access to Vim and are familiar with
its interactive features. If that's not the case, some good starting
points are Vim's own Web site and various online resources and hardcopy
books, or you can simply type `:help` inside Vim itself. See the
Resources section for links.

Unless otherwise indicated, all the examples in this series of articles
assume you're using Vim version 7.2 or higher. You can check which
version of Vim you're using by invoking the editor like so:

    vim --version

or by typing `:version` within Vim itself. If you're using an older
incarnation of Vim, upgrading to the latest release is strongly
recommended, as previous versions do not support many of the features of
Vimscript that we'll be exploring. The Resources section has a link to
download and upgrade Vim.


## Vimscript ##

Vim's scripting language, known as Vimscript, is a typical dynamic
imperative language and offers most of the usual language features:
variables, expressions, control structures, built-in functions,
user-defined functions, first-class strings, high-level data structures
(lists and dictionaries), terminal and file I/O, regex pattern matching,
exceptions, and an integrated debugger.

You can read Vim's own documentation of Vimscript via the built-in help
system, by typing:

    :help vim-script-intro

inside any Vim session. Or just read on.


### Running Vim scripts ###

There are numerous ways to execute Vim scripting commands. The simplest
approach is to put them in a file (typically with a .vim extension) and
then execute the file by :source-ing it from within a Vim session:

    :source /full/path/to/the/scriptfile.vim

Alternatively, you can type scripting commands directly on the Vim
command line, after the colon. For example:

    :source /full/path/to/the/scriptfile.vim
    
Alternatively, you can type scripting commands directly on the Vim
command line, after the colon. For example:

    :call MyBackupFunc(expand('%'), { 'all':1, 'save':'recent'})
    
But very few people do that. After all, the whole point of scripting is
to reduce the amount of typing you have to do. So the most common way to
invoke Vim scripts is by creating new keyboard mappings, like so:

    :nmap ;s :source /full/path/to/the/scriptfile.vim<CR>
    :nmap \b :call MyBackupFunc(expand('%'), { 'all': 1 })<CR>
    
Commands like these are usually placed in the .vimrc initialization file
in your home directory. Thereafter, when you're in Normal mode (in other
words, not inserting text), the key sequence `;s` will execute the
specified script file, and a `\b` sequence will call the
`MyBackupFunc()` function (which you presumably defined somewhere in
your .vimrc as well).

All of the Vimscript examples in this article use key mappings of
various types as triggers. In later articles, we'll explore two other
common invocation techniques: running scripts as colon commands from
Vim's command line, and using editor events to trigger scripts
automatically.


## A syntactic example ##

Vim has very sophisticated syntax highlighting facilities, which you can
turn on with the built-in `:syntax enable command`, and off again with
:syntax off.

It's annoying to have to type ten or more characters every time you want
to toggle syntax highlighting, though. Instead, you could place the
following lines of Vimscript in your .vimrc file:

    Listing 1. Toggling syntax highlighting
    
    function! ToggleSyntax()
        if exists("g:syntax_on")
            syntax off
        else
            syntax enable
        endif
    endfunction

    nmap <silent> ;s :call ToggleSyntax()<CR>

This causes the `;s` sequence to flip syntax highlighting on or off each
time it's typed when you're in Normal mode. Let's look at each component
of that script.

The first block of code is obviously a function declaration, defining a
function named `ToggleSyntax()`, which takes no arguments. That
user-defined function first calls a built-in Vim function named
`exists()`, passing it a string. The `exists()` function determines
whether a variable with the name specified by the string (in this case,
the global variable `g:syntax_on`) has been defined.

If so, the `if` statement executes a `syntax off`; otherwise it executes
a `syntax enable`. Because `syntax enable`ndefines the
`g:syntax_on`nvariable, and ` syntax off` undefines it, calling the
`ToggleSyntax()`nfunction repeatedly alternates between enabling and
disabling syntax highlighting.

All that remains is to set up a key sequence (`;s` in this example) to
call the `ToggleSyntax()` function:

    nmap <silent> ;s :call ToggleSyntax()<CR>

`nmap` stands for "*n*ormal-mode key *m*apping." The `<silent>` option
after the `nmap`  causes the mapping not to echo any command it's
executing, ensuring that the new `;s` command will do its work
unobtrusively. That work is to execute the command:

    :call ToggleSyntax()<CR>

which is how you call a function in Vimscript when you intend to ignore
the return value.

Note that the `<CR>` at the end is the literal sequence of characters
`<,C,R,>`. Vimscript recognizes this as being equivalent to a literal
carriage return. In fact, Vimscript understands many other similar
representations of unprintable characters. For example, you could create
a keyboard mapping to make your space bar act like the page-down key (as
it does in most Web browsers), like so:

    :nmap <Space> <PageDown>

You can see the complete list of these special symbols in the [last
part](#keycodes) of the manual or by typing `:help keycodes` within Vim.

Note too that `ToggleSyntax()` was able to call the built-in `syntax`
command directly. That's because every built-in colon command in Vim is
automatically also a statement in Vimscript. For example, to make it
easier to create centered titles for documents written in Vim, you could
create a function that capitalizes each word on the current line,
centers the entire line, and then jumps to the next line, like so:

    Listing 2. Creating centered titles
    
    function! CapitalizeCenterAndMoveDown()
    s/\<./\u&/g    "Built-in substitution capitalizes each word
    center         "Built-in center command centers entire line
    +1             "Built-in relative motion (+1 line down)
    endfunction

    nmap <silent>  \C  :call CapitalizeCenterAndMoveDown()<CR>


### Vimscript statements ###

As the previous examples illustrate, all statements in Vimscript are
terminated by a newline (as in shell scripts or Python). If you need to
run a statement across multiple lines, the continuation marker is a
single backslash. Unusually, the backslash doesn't go at the end of the
line to be continued, but rather at the start of the continuation line:

    Listing 3. Continuing lines using backslash

    call SetName(
    \           first_name,
    \           middle_initial,
    \           family_name
    \           )

You can also put two or more statements on a single line by separating
them with a vertical bar:

    echo "Starting..." | call Phase(1) | call Phase(2) | echo "Done"

That is, the vertical bar in Vimscript is equivalent to a semicolon in
most other programming languages. Unfortunately, Vim couldn't use the
semicolon, as that character already means something else at the start
of a command (specifically, it means "from the current line to..." as
part of the command's line range).


### comments ###

One important use of the vertical bar as a statement separator is in
commenting. vimscript comments start with a double-quote and continue to
the end of the line, like so:

    listing 4. commenting in vimscript
    
    if exists("g:syntax_on")
        syntax off      "not 'syntax clear' (which does something else)
    else
        syntax enable   "not 'syntax on' (which overrides colorscheme)
    endif

Unfortunately, vimscript strings can also start with a double-quote and
always take precedence over comments. this means you can't put a comment
anywhere that a string might be expected, because it will always be
interpreted as a string:

    echo "> " "print generic prompt
    
the echo command expects one or more strings, so this line produces an
error complaining about the missing closing quote on (what Vim assumes
to be) the second string.

Comments can, however, always appear at the very start of a statement,
so you canfix the above problem by using a vertical bar to explicitly
begin a new statement before starting the comment, like so: 

    echo "> " |"Print generic prompt


### values and variables ###

Variable assignment in Vimscript requires a special keyword, `let:`

    Listing 5. Using the let keyword
    
    let name = "Damian"
    let height = 165
    let interests = [ 'Cinema', 'Literature', 'World Domination', 101 ]
    let phone = { 'cell':5551017346, 'home':5558038728, 'work':'?' }

Note that strings can be specified with either double-quotes or
single-quotes as delimiters. Double-quoted strings honor special "escape
sequences" such as "`\n`" (for newline), "`\t`" (for tab), "`\u263A`"
(for Unicode smiley face), or "`\<ESC>`" (for the escape character). In
contrast, single-quoted strings treat everything inside their delimiters
as literal characters -- except two consecutive single-quotes, which are
treated as a literal single-quote.

Values in Vimscript are typically one of the following three types:

* scalar: a single value, such as a string or a number. For example:
  "`Damian`" or `165`
* list: an ordered sequence of values delimited by square brackets, with
  implicit integer indices starting at zero. For example: `['Cinema',
  'Literature', 'World Domination', 101]`
* dictionary: an unordered set of values delimited by braces, with
  explicit string keys. For example: `{'cell':5551017346,
  'home':5558038728, 'work':'?'}`

Note that the values in a list or dictionary don't have to be all of the
same type; you can mix strings, numbers, and even nested lists and
dictionaries if you wish.

Unlike values, variables have no inherent type. Instead, they take on
the type of the first value assigned to them. So, in the preceding
example, the `name` and `height` variables are now scalars (that is,
they can henceforth store only strings or numbers), `interests` is now a
list variable (that is, it can store only lists), and `phone` is now a
dictionary variable (and can store only dictionaries). Variable types,
once assigned, are permanent and strictly enforced at runtime:

    let interests = 'unknown' " Error: variable type mismatch
    
By default, a variable is scoped to the function in which it is first
assigned to, or is global if its first assignment occurs outside any
function. However, variables may also be explicitly declared as
belonging to other scopes, using a variety of prefixes, as summarized in
Table 1.

Table: **Variable scoping**

**Prefix** | **Meaning**
:--- | :---
**g**: varname    | The variable is global
**s**: varname    | The variable is local to the current script file
**w**: varname    | The variable is local to the current editor window
**t**: varname    | The variable is local to the current editor tab
**b**: varname    | The variable is local to the current editor buffer
**l**: varname    | The variable is local to the current function
**a**: varname    | The variable is a parameter of the current function
**v**: varname    | The variable is one that Vim predefines

There are also _pseudovariables_ that scripts can use to access the
other types of value containers that Vim provides. These are summarized
in Table 2.

Table: **Pseudovariables**

**Prefix** | **Meaning**
:--- | :---
**&** varname     | A Vim option (local option if defined, otherwise global)
**&l**: varname   | A local Vim option
**&g**: varname   | A global Vim option
**@** varname     | A Vim register
**$** varname     | An environment variable

The "option" pseudovariables can be particularly useful. For example,
you could set up two key-maps to increase or decrease the current
tabspacing like so:

    nmap <silent> ]] :let &tabstop += 1<CR>
    nmap <silent> [[ :let &tabstop -= &tabstop > 1 ? 1 : 0<CR>


### Expressions ###

Note that the `[[` key-mapping in the previous example uses an
expression containing a C-like "ternary expression":

    &tabstop > 1 ? 1 : 0
    
This prevents the key map from decrementing the current tab spacing
below the sane minimum of 1. As this example suggests, expressions in
Vimscript are composed of the same basic operators that are used in most
other modern scripting languages, and with generally the same syntax.
The available operators(grouped by increasing precedence) are summarized
in Table 3.

Table: **Operator precedence table**

**Operation** | **Operator syntax**
:--- | :---
Assignment                          | _**let** var = expr_
Numeric-add-and-assign              | _**let** var += expr_
Numeric-subtract-and-assign         | _**let** var -= expr_
String-concatenate-and-assign       | _let var .= expr_
Ternary operator                    | _bool **?** expr-if-true : expr-if-false_
Logical OR                          | _bool **`||`** bool_
Logical AND                         | _bool **`&&`** bool_
Numeric or string equality          | _expr == expr_
Numeric or string inequality        | _expr != expr_
Numeric or string greater-then      | _expr > expr_
Numeric or string greater-or-equal  | _expr >= expr_
Numeric or string less than         | _expr < expr_
Numeric or string less-or-equal     | _expr <= expr_
Numeric addition                    | _num + num_
Numeric subtraction                 | _num - num_
String concatenation                | _str . str_
Numeric multiplication              | _num * num_
Numeric division                    | _num / num_
Numeric modulus                     | _num % num_
Convert to number                   | _+ num_
Numeric negation                    | _- num_
Logical NOT                         | _! bool_
Parenthetical precedence            | _( expr )_


### Logical caveats ###

In Vimscript, as in C, only the numeric value zero is false in a boolean
context; any non-zero numeric value—whether positive or negative—is
considered true. However, all the logical and comparison operators
consistently return the value 1 for _true_.

When a string is used as a boolean, it is first converted to an integer,
and then evaluated for truth (_non-zero_) or falsehood (_zero_). This
implies that the vast majority of strings—including most non-empty
strings—will evaluate as being false. A typical mistake is to test for
an empty string like so:

    Listing 6. Flawed test for empty string
    
    let result_string = GetResult();
    
    if !result_string
        echo "No result"
    endif
    
The problem is that, although this does work correctly when
`result_string` is assigned an empty string, it also indicates "`No
result`" if `result_string` contains a string like "`I am NOT an empty
string` ", because that string is first converted to a number (_zero_)
and then to a boolean (_false_).

The correct solution is to explicitly test strings for emptiness using
the appropriate built-in function:

    Listing 7. Correct test for empty string
    
    if empty(result_string)
        echo "No result"
    endif


### Comparator caveats ###

In Vimscript, comparators always perform numeric comparison, unless both
operands are strings. In particular, if one operand is a string and the
other a number, the string will be converted to a number and the two
operands then compared numerically. This can lead to subtle errors:

    let ident = 'Vim' if ident == 0 "Always true (string 'Vim' converted
    to number 0)

A more robust solution in such cases is:

    if ident == '0' "Uses string equality if ident contains string
                    "but numeric equality if ident contains number

String comparisons normally honor the local setting of Vim's
`ignorecase` option, but any string comparator can also be explicitly
marked as case-sensitive (by appending a `#`) or case-insensitive (by
appending a `?`):

    Listing 8. Casing string comparators
    
    if name ==? 'Batman'            |"Equality always case insensitive
        echo "I'm Batman"
    elseif name <# 'ee cummings'    |"Less-than always case sensitive
        echo "the sky was can dy lu minous"
    endif

Using the "explicitly cased" operators for all string comparisons is
strongly recommended, because they ensure that scripts behave reliably
regardless of variations in the user's option settings.


### Arithmetic caveats ###

When using arithmetic expressions, it's also important to remember that,
until version 7.2, Vim supported only integer arithmetic. A common
mistake under earlier versions was writing something like:

    Listing 9. Problem with integer arithmetic
    
    "Step through each file...
    for filenum in range(filecount)
        " Show progress...
        echo (filenum / filecount * 100) . '% done'
        
        " Make progress...
        call process_file(filenum)
    endfor

Because `filenum` will always be less than `filecount`, the integer
division `filenum/filecount` will always produce zero, so each iteration
of the loop will echo:

    Now 0% done
    
Even under version 7.2, Vim does only floating-point arithmetic if one
of the operands is explicitly floating-point:

    let filecount = 234
    
    echo filecount/100      |" echoes 2
    echo filecount/100.0    |" echoes 2.34


## Another toggling example ##

It's easy to adapt the syntax-toggling script shown earlier to create
other useful tools. For example, if there is a set of words that you
frequently misspell or misapply, you could add a script to your .vimrc
to activate Vim's match mechanism and highlight problematic words when
you're proofreading text.

For example, you could create a key-mapping (say: `;p`) that causes text
like the previous paragraph to be displayed within Vim like so:

```text
_It's_ easy _to_ adapt the syntax-toggling script shown earlier _to_
create other useful tools. For example, if _there_ is a set of
words that you frequently misspell or misapply, you could add
a script _to your_ .vimrc _to_ activate Vim's match mechanism and
highlight problematic words when _you're_ proofreading text.
```

That script might look like this:

    Listing 10. Highlighting frequently misused words

    "Create a text highlighting style that always stands out...
    highlight STANDOUT term=bold cterm=bold gui=bold
    
    "List of troublesome words...
    let s:words = [
                \ "it's", "its",
                \ "your", "you're",
                \ "were", "we're", "where",
                \ "their", "they're", "there",
                \ "to", "too",  "two"
                \ ]
                
    "Build a Vim command to match troublesome words...
    let s:words_matcher
    \ = 'match STANDOUT /\c\<\(' . join(s:words, '\|') . '\)\>/'
    
    "Toggle word checking on or off...
    function! WordCheck ()
        "Toggle the flag (or set it if it doesn't yet exist)...
        let w:check_words = exists('w:check_words') ? !w:check_words : 1
        
        "Turn match mechanism on/off, according to new state of flag...
        if w:check_words
            exec s:words_matcher
        else
            match none
        endif
    endfunction
    
    "Use ;p to toggle checking...
    
    nmap <silent>   ;p  :call WordCheck()<CR>
    
The variable `w:check_words` is used as a boolean flag to toggle word
checking on or off. The first line of the `WordCheck()` function checks
to see if the flag already exists, in which case the assignment simply
toggles the variable's boolean value:

    let w:check_words = exists('w:check_words') ? !w:check_words : 1

If `w:check_words` does not yet exist, it is created by assigning the
value `1` to it:

    let w:check_words = exists('w:check_words') ? !w:check_words : 1
    
Note the use of the `w:` prefix, which means that the flag variable is
always local to the current window. This allows word checking to be
toggled independently for each editor window (which is consistent with
the behavior of the `match` command, whose effects are always local to
the current window as well).

Word checking is enabled by setting Vim's `match` command. A `match`
expects a text-highlighting specification (`STANDOUT` in this example),
followed by a regular expression that specifies which text to highlight.
In this case, that regex is constructed by `OR`'ing together all of the
words specified in the script's `s:words` list variable (that is:
`join(s:words, '\|'`)). That set of alternatives is then bracketed by
case-insensitive word boundaries (`\c\<\(...\)\>`) to ensure that only
entire words are matched, regardless of capitalization.

The `WordCheck()` function then converts the resulting string as a Vim
command and executes it (`exec s:words_matcher`) to turn on the matching
facility. When `w:check_words` is toggled off, the function performs a
`match` none command instead, to deactivate the special matching.


## Scripting in Insert mode ##

Vimscripting is by no means restricted to Normal mode. You can also use
the `imap` or `iabbrev` commands to set up key-mappings or abbreviations
that can be used while inserting text. For example:

    imap <silent> <C-D><C-D> <C-R>=strftime("%e %b %Y")<CR>
    imap <silent> <C-T><C-T> <C-R>=strftime("%l:%M %p")<CR>
    
With these mappings in your .vimrc, typing CTRL-D twice while in Insert
mode causes Vim to call its built-in `strftime()` function and insert
the resulting date, while double-tapping CTRL-T likewise inserts the
current time.

You can use the same general pattern to cause an insertion map or an
abbreviation to perform _any_ scriptable action. Just put the
appropriate Vimscript expression or function call between an initial
`<C-R>=` (which tells Vim to insert the result of evaluating what
follows) and a final `<CR>` (which tells Vim to actually evaluate the
preceding expression). Remember, though, that `<C-R>` (Vim's
abbreviation for CTRL-R) is not the same as `<CR>` (Vim's abbreviation
for a carriage return).

For example, you could use Vim's built-in `getcwd()` function to create
an abbreviation for the current working directory, like so:

    iabbrev <silent> CWD <C-R>=getcwd()<CR>

Or you could embed a simple calculator that can be called by typing
CTRL-C during text insertions:

    imap <silent> <C-C> <C-R>=string(eval(input("Calculate: ")))<CR>
    
Here, the expression:

    string( eval( input("Calculate: ") ) )
    
first calls the built-in `input()` function to request the user to type
in their calculation, which `input()` then returns as a string. That
input string is then passed to the built-in `eval()`, which evaluates it
as a Vimscript expression and returns the result. Next, the built-in
`string()` function converts the numeric result back to a string, which
the key-mapping's `<C-R>=` sequence is then able to insert.


### A more complex Insert-mode script ###

Insertion mappings can involve scripts considerably more sophisticated
than the previous examples. In such cases, it's usually a good idea to
refactor the code out into a user-defined function, which the
key-mapping can then call.

For example, you could change the behavior of CTRL-Y during insertions.
Normally a CTRL-Y in Insert mode does a "vertical copy." That is, it
copies the character in the same column from the line immediately above
the cursor. For example, a CTRL-Y in the following situation would
insert an "m" at the cursor:

    Glib jocks quiz nymph to vex dwarf
    Glib jocks quiz ny_

However, you might prefer your vertical copies to ignore any intervening
empty lines and instead copy the character from the same column of the
first _non-blank_ line anywhere above the insertion point. That would
mean, for instance, that a CTRL-Y in the following situation would also
insert an "m", even though the immediately preceding line is empty:

    Glib jocks quiz nymph to vex dwarf
    Glib jocks quiz ny_
    
You could achieve this enhanced behavior by placing the following in
your .vimrc file:

    Listing 11. Improving vertical copies to ignore blank lines
    
    "Locate and return character "above" current cursor position...
    function! LookUpwards()
        "Locate current column and preceding line from which to copy...
        let column_num      = virtcol('.')
        let target_pattern  = '\%' . column_num . 'v.'
        let target_line_num = search(target_pattern . '*\S', 'bnW')
        
        "If target line found, return vertically copied character...

        if !target_line_num
            return ""
        else
            return matchstr(getline(target_line_num), target_pattern)
        endif
    endfunction
    
    "Reimplement CTRL-Y within insert mode...
    imap <silent>   <C-Y>   <C-R><C-R>=LookUpwards()<CR>
    
The `LookUpwards()` function first determines which on-screen column (or
"virtual column") the insertion point is currently in, using the
built-in `virtcol()` function. The '.' argument specifies that you want
the column number of the current cursor position:

    let column_num = virtcol('.')
    
`LookUpwards()` then uses the built-in `search()` function to look
backwards through the file from the cursor position:

    let target_pattern = '\%' . column_num . 'v.'
    let target_line_num = search(target_pattern . '*\S', 'bnW')

The search uses a special target pattern (namely: `\%column_numv.*\S`)
to locate the closest preceding line that has a non-whitespace character
(`\S`) at or after (`.*`) the cursor column (`\%column_numv`). The
second argument to `search()` is the configuration string `bnW`, which
tells the function to search backwards but not to move the cursor nor to
wrap the search. If the search is successful, `search()` returns the
line number of the appropriate preceding line; if the search fails, it
returns zero.

The `if` statement then works out which character --if any-- is to be
copied back down to the insertion point. If a suitable preceding line
was not found, `target_line_num` will have been assigned zero, so the
first return statement is executed and returns an empty string
(indicating "insert nothing").

If, however, a suitable preceding line was identified, the second return
statement is executed instead. It first gets a copy of that preceding
line from the current editor buffer:

    return matchstr(getline(target_line_num), target_pattern)
    
It then finds and returns the one-character string that the previous
call to `search()`  successfully matched:

    return matchstr(getline(target_line_num), target_pattern)

Having implemented this new vertical copy behavior inside
`LookUpwards()`, all that remains is to override the standard CTRL-Y
command in Insert mode, using an imap:

    imap <silent> <C-Y> <C-R><C-R>=LookUpwards()<CR>
    
Note that, whereas earlier imap examples all used `<C-R>=`nto invoke a
Vimscript function call, this example uses `<C-R><C-R>=` instead. The
single-CTRL-R form inserts the result of the subsequent expression as if
it had been directly typed, which means that any special characters
within the result retain their special meanings and behavior. The
double-CTRL-R form, on the other hand, inserts the result as verbatim
text without any further processing.

Verbatim insertion is more appropriate in this example, since the aim is
to exactly copy the text above the cursor. If the key-mapping used
`<C-R>=`, copying a literal escape character from the previous line
would be equivalent to typing it, and would cause the editor to
instantly drop out of Insert mode.


### Learning Vim's built-in functions ###

As you can see from each of the preceding examples, much of Vimscript's
power comes from its extensive set of over 200 built-in functions. You
can start learning about them by typing:

    :help functions
    
or, to access a (more useful) categorized listing, go to the [last
part](#function-list) of the book or type:

    :help function-list


## Looking ahead ##

Vimscript is a mechanism for reshaping and extending the Vim editor.
Scripting lets you create new tools (such as a problem-word highlighter)
and simplify common tasks (like changing tabspacing, or inserting time
and date information, or toggling syntax highlighting), and even
completely redesign existing editor features (for example, enhancing
CTRL-Y's "copy-the-previous-line" behavior).

For many people, the easiest way to learn any new language is by
example. To that end, you can find an endless supply of sample
Vimscripts—most of which are also useful tools in their own right—on the
Vim Tips wiki. Or, for more extensive examples of Vim scripting, you can
trawl the 2000+ larger projects housed in the Vim script archive.

If you're already familiar with Perl or Python or Ruby or PHP or Lua or
Awk or Tcl or any shell language, then Vimscript will be both hauntingly
familiar (in its general approach and concepts) and frustratingly
different (in its particular syntactic idiosyncrasies). To overcome that
cognitive dissonance and master Vimscript, you're going to have to spend
some time experimenting, exploring, and playing with the language. To
that end, why not take your biggest personal gripe about the way Vim
currently works and see if you can script a better solution for
yourself?

This article has described only Vimscript's basic variables, values,
expressions, and functions. The range of "better solutions" you're
likely to be able to construct with just those few components is, of
course, extremely limited. So, in future installments, we'll look at
more advanced Vimscript tools and techniques: data structures, flow
control, user-defined commands, event-driven scripting, building Vim
modules, and extending Vim using other scripting languages. In
particular, the next article in this series will focus on the features
of Vimscript's user-defined functions and on the many ways they can make
your Vim experience better.


# User-defined functions #

## Create the fundamental building blocks of automation ##

User-defined functions are an essential tool for decomposing an
application into correct and maintainable components, in order to manage
the complexity of real-world programming tasks.  This article explains
how to create and deploy new functions in the Vimscript language, giving
several practical examples of why you might want to.


## User-defined functions ##

Ask Haskell or Scheme programmers, and they'll tell you that functions
are the most important feature of any serious programming language. Ask
C or Perl programmers, and they'll tell you exactly the same thing.
Functions provide two essential benefits to the serious programmer:

1. They enable complex computational tasks to be subdivided into pieces
   small enough to fit comfortably into a single human brain.
2. They allow those subdivided pieces to be given logical and
   comprehensible names, so they can be competently manipulated by a
   single human brain.
   
Vimscript is a serious programming language, so it naturally supports
the creation of user-defined functions. Indeed, it arguably has better
support for user-defined functions than Scheme, C, or Perl. This article
explores the various features of Vimscript functions, and show how you
can use those features to enhance and extend Vim's built-in
functionality in a maintainable way.


### Declaring functions ###

Functions in Vimscript are defined using the `function` keyword, followed
by the name of the function, then the list of parameters (which is
mandatory, even if the function takes no arguments).  The body of the
function then starts on the next line, and continues until a matching
endfunction keyword is encountered. For example:

    Listing 1. A correctly structured function
    
    function ExpurgateText (text)
        let expurgated_text = a:text
        
        for expletive in [ 'cagal', 'frak', 'gorram', 'mebs', 'zarking']
        let expurgated_text
        \   = substitute(expurgated_text, expletive, '[DELETED]', 'g')
        endfor
        
        return expurgated_text
    endfunction

The return value of the function is specified with a return statement.
You can specify as many separate return statements as you need. You can
include none at all if the function is being used as a procedure and has
no useful return value. However, Vimscript functions _always_ return a
value, so if no return is specified, the function automatically returns
zero.

Function names in Vimscript must start with an uppercase letter:

    Listing 2. Function names start with an uppercase letter

    function SaveBackup ()
        let b:backup_count = exists('b:backup_count') ? b:backup_count+1 : 1
        return writefile(getline(1,'$'), bufname('%') . '_' . b:backup_count)
    endfunction
    
    nmap <silent>   <C-B>   :call SaveBackup()<CR>

This example defines a function that increments the value of the current
buffer's `b:backup_count` variable (or initializes it to 1, if it
doesn't yet exist). The function then grabs every line in the current
file (`getline(1,'$')`) and calls the built-in `writefile()` function to
write them to disk. The second argument to `writefile()` is the name of
the new file to be written; in this case, the name of the current file
(`bufname('%')`) with the counter's new value appended. The value
returned is the success/failure value of the call to `writefile()`.
Finally, the nmap sets up CTRL-B to call the function to create a
numbered backup of the current file.

Instead of using a leading capital letter, Vimscript functions can also
be declared with an explicit scope prefix (like variables can be, as
described in Part 1). The most common choice is `s:`, which makes the
function local to the current script file. If a function is scoped in
this way, its name need not start with a capital; it can be any valid
identifier. However, explicitly scoped functions must always be called
with their scoping prefixes. For example:

    Listing 3. Calling a function with its scoping prefix
    
    " Function scoped to current script file...
    function s:save_backup ()
        let b:backup_count = exists('b:backup_count') ? b:backup_count+1 : 1
        return writefile(getline(1,'$'), bufname('%') . '_' . b:backup_count)
    endfunction
    
    nmap <silent>   <C-B>   :call s:save_backup()<CR>


### Redeclarable functions ###

Function declarations in Vimscript are runtime statements, so if a
script is loaded twice, any function declarations in that script will be
executed twice, re-creating the corresponding functions.

Redeclaring a function is treated as a fatal error (to prevent
collisions where two separate scripts accidentally declare functions of
the same name). This makes it difficult to create functions in scripts
that are designed to be loaded repeatedly, such as custom
syntax-highlighting scripts.

So Vimscript provides a keyword modifier (`function!`) that allows you
to indicate that a function declaration may be safely reloaded as often
as required:

    Listing 4. Indicating that a function declaration may be safely reloaded
    
    function! s:save_backup ()
        let b:backup_count = exists('b:backup_count') ? b:backup_count+1 : 1
        return writefile(getline(1,'$'), bufname('%') . '_' . b:backup_count)
    endfunction

No redeclaration checks are performed on functions defined with this
modified keyword, so it is best used with explicitly scoped functions
(in which case the scoping already ensures that the function won't
collide with one from another script).


### Calling functions ###

To call a function and use its return value as part of a larger
expression, simply name it and append a parenthesized argument list:

    Listing 5. Using a function's return value
    
    "Clean up the current line...
    let success = setline('.', ExpurgateText(getline('.')) )

Note, however, that, unlike C or Perl, Vimscript does not allow you to
throw away the return value of a function without using it. So, if you
intend to use the function as a procedure or subroutine and ignore its
return value, you must prefix the invocation with the `call` command:

    Listing 6. Using a function without using its return value

    "Checkpoint the text...
    call SaveBackup()

Otherwise, Vimscript will assume that the function call is actually a
built-in Vim command and will most likely complain that no such command
exists. We'll look at the difference between functions and commands in a
future article in this series.


### Parameter lists ###

Vimscript allows you to define both _explicit parameters_ and _variadic
parameter lists_, and even combinations of the two.

You can specify up to 20 explicitly named parameters immediately after
the declaration of the subroutine's name. Once specified, the
corresponding argument values for the current call can be accessed
within the function by prefixing an a: to the parameter name:

    Listing 7. Accessing argument values within the function

    function PrintDetails(name, title, email)
        echo 'Name:     ' a:title a:name
        echo 'Contact:  ' a:email
    endfunction

If you don't know how many arguments a function may be given, you can
specify a variadic parameter list, using an ellipsis ( ... ) instead of
named parameters.  In this case, the function may be called with as many
arguments as you wish, and those values are collected into a single
variable: an array named a:000 . Individual arguments are also given
positional parameter names: `a:1 , a:2 , a:3`, etc. The number of
arguments is available as a:0 . For example:

    Listing 8. Specifying and using a variadic parameter list
    
    function Average(...)
        let sum = 0.0
        
        for nextval in a:000  "a:000 is the list of arguments
            let sum += nextval
        endfor
        
        return sum / a:0      "a:0 is the number of arguments
    endfunction

Note that, in this example, `sum` must be initialized to an explicit
floating-point value; otherwise, all the subsequent computations will be
done using integer arithmetic.


### Combining named and variadic parameters ###

Named and variadic parameters can be used in the same function, simply
by placing the variadic ellipsis after the list of named parameters.

For example, suppose you wanted to create a CommentBlock() function that
was passed a string and formatted it into an appropriate comment block
for various programming languages. Such a function would always require
the caller to supply the string to be formatted, so that parameter
should be explicitly named. But you might prefer that the comment
introducer, the "boxing" character, and the width of the comment all be
optional (with sensible defaults when omitted).  Then you could call:

    Listing 9. A simple CommentBlock function call

    call CommentBlock("This is a comment")

and it would return a multi-line string containing:

    Listing 10. The CommentBlock return
    
    //*******************
    // This is a comment
    //*******************

Whereas, if you provided extra arguments, they would specify non-default
values for the comment introducer, the "boxing" character, and the
comment width. So this call:

    Listing 11. A more involved CommentBlock function call
    
    call CommentBlock("This is a comment", '#', '=', 40)

would return the string:

    Listing 12. The CommentBlock return

    #========================================
    # This is a comment
    #========================================
    
Such a function might be implemented like so:

    Listing 13. The CommentBlock implementation
    
    function CommentBlock(comment, ...)
        "If 1 or more optional args, first optional arg is introducer...
        let introducer = a:0 >= 1   ?   a:1     :   "//"
        
        "If 2 or more optional args, second optional arg is boxing character...
        let box_char    = a:0 >= 2  ?   a:2     :   "*"
        
        "If 3 or more optional args, third optional arg is comment width...
        let width       = a:0 >= 3  ?   a:3     :   strlen(a:comment) + 2
        
        " Build the comment box and put the comment inside it...
        return introducer . repeat(box_char,width)  . "\<CR>"
        \   . introducer . " " . a:comment          . "\<CR>"
        \   . introducer . repeat(box_char,width)   . "\<CR>"
    endfunction

If there is at least one optional argument (`a:0 >= 1`), the introducer
parameter is assigned that first option (that is, `a:1`); otherwise, it
is assigned a default value of `"//"`. Likewise, if there are two or
more optional arguments (`a:0 >= 2`), the `box_char` variable is
assigned the second option (`a:2`), or else a default value of `"*"`. If
three or more optional arguments are supplied, the third option is
assigned to the width variable. If no width argument is given, the
appropriate width is autocomputed from the comment argument itself
(`strlen(a:comment)+2`).

Finally, having resolved all the parameter values, the top and bottom
lines of the comment box are constructed using the leading comment
introducer, followed by the appropriate number of repetitions of the
boxing character (`repeat(box_char,width)`), with the comment text
itself sandwiched between them.

Of course, to use this function, you'd need to invoke it somehow. An
insertion map is probably the ideal way to do that:

    Listing 14. Invoking the function using an insertion map

    "C++/Java/PHP comment...
    imap <silent> /// <C-R>=CommentBlock(input("Enter comment: "))<CR>

    "Ada/Applescript/Eiffel comment...
    imap <silent> --- <C-R>=CommentBlock(input("Enter comment: "),'--')<CR>

    "Perl/Python/Shell comment...
    imap <silent> ### <C-R>=CommentBlock(input("Enter comment: "),'#','#')<CR>

In each of these maps, the built-in `input()` function is first called
to request that the user type in the text of the comment. The
`CommentBlock()` function is then called to convert that text into a
comment block. Finally, the leading `<C-R>=` inserts the resulting
string.

Note that the first mapping passes only a single argument, so it
defaults to using `//` as its comment marker. The second and third
mappings pass a second argument to specify `#` or `--` as their
respective comment introducers. The final mapping also passes a third
argument, to make the "boxing" character match its comment introducer.


## Functions and line ranges ##

You can invoke any standard Vim command --including call-- with a
preliminary line range, which causes the command to be repeated once for
every line in the range:

    "Delete every line from the current line (.) to the end-of-file ($)...
    :.,$delete
    
    "Replace "foo" with "bar" everywhere in lines 1 to 10
    :1,10s/foo/bar/
    
    "Center every line from five above the current line to five below it...
    :-5,+5center

You can type `:help cmdline-ranges` in any Vim session to learn more about
this facility or go to the [last part](#command-line-ranges) of the book.

In the case of the `call` command, specifying a range causes the
requested function to be called repeatedly: once for each line in the
range. To see why that's useful, let's consider how to write a function
that converts any "raw" ampersands in the current line to proper XML
&amp; entities, but that is also smart enough to ignore any ampersand
that is already part of some other entity. That function could be
implemented like so:

    Listing 15. Function to convert ampersands

    function DeAmperfy()
        "Get current line...
        let curr_line   = getline('.')
        
        "Replace raw ampersands...
        let replacement = substitute(curr_line,'&\(\w\+;\)\@!','&amp;','g')
        
        "Update current line...
        call setline('.', replacement)
    endfunction

The first line of `DeAmperfy()` grabs the current line from the editor
buffer (`getline('.')`). The second line looks for any `&` in that line
that isn't followed by an identifier and a colon, using the negative
lookahead pattern `'&\(\w\+;\)\@!'` (see `:help \@!` for details).  The
`substitute()` call then replaces all such "raw" ampersands with the XML
entity `&amp;`.  Finally, the third line of `DeAmperfy()` updates the
current line with the modified text.

If you called this function from the command line:

    :call DeAmperfy()
    
it would perform the replacement on the current line only. But if you
specified a range before the `call`:

    :1,$call DeAmperfy()
    
then the function would be called once for each line in the range (in
this case, for every line in the file).


### Internalizing function line ranges ###

This `call-the-function-repeatedly-for-each-line` behavior is a
convenient default. However, sometimes you might prefer to specify a
range but then have the function called only once, and then handle the
range semantics within the function itself. That's also easy in
Vimscript. You simply append a special modifier (`range`) to the
function declaration:

    Listing 16. Range semantics within a function

    function DeAmperfyAll() range"Step through each line in the range...
        for linenum in range(a:firstline, a:lastline)
            "Replace loose ampersands (as in DeAmperfy())...
            let curr_line   = getline(linenum)
            let replacement =
            \   substitute(curr_line,'&\(\w\+;\)\@!','&amp;','g')
            call setline(linenum, replacement)
        endfor

        "Report what was done...
        if a:lastline > a:firstline
            echo "DeAmperfied" (a:lastline - a:firstline + 1) "lines"
        endif
    endfunction

With the range modifier specified after the parameter list, any time
`DeAmperfyAll()` is called with a range such as:

    :1,$call DeAmperfyAll()
    
then the function is invoked only once, and two special arguments,
`a:firstline` and `a:lastline`, are set to the first and last line
numbers in the range. If no range is specified, both `a:firstline` and
`a:lastline` are set to the current line number.

The function first builds a list of all the relevant line numbers
(`range(a:firstline, a:lastline)`).  Note that this call to the built-in
`range()` function is entirely unrelated to the use of the range
modifier as part of the function declaration. The `range()` function is
simply a list constructor, very similar to the `range()` function in
Python, or the `..` operator in Haskell or Perl.

Having determined the list of line numbers to be processed, the function
uses a for loop to step through each:

    for linenum in range(a:firstline, a:lastline)
    
and updates each line accordingly (just as the original `DeAmperfy()`
did).

Finally, if the range covers more than a single line (in other words, if
`a:lastline > a:firstline`), the function reports how many lines were
updated.


### Visual ranges ###

Once you have a function call that can operate on a range of lines, a
particularly useful technique is to call that function via Visual mode
(see `:help Visual-mode` for details).

For example, if your cursor is somewhere in a block of text, you could
encode all the ampersands anywhere in the surrounding paragraph with:

    Vip:call DeAmperfyAll()
    
Typing `V` in Normal mode swaps you into Visual mode. The ip then causes
Visual mode to highlight the entire paragraph you're inside. Then, the
`:` swaps you to Command mode and automatically sets the command's range
to the range of lines you just selected in Visual mode. At this point
you call `DeAmperfyAll()` to deamperfy all of them.

Note that, in this instance, you could get the same effect with just:

    Vip:call DeAmperfy()
    
The only difference is that the `DeAmperfy()` function would be called
repeatedly: once for each line the Vip highlighted in Visual mode.


## A function to help you code ##

Most user-defined functions in Vimscript require very few parameters,
and often none at all. That's because they usually get their data
directly from the current editor buffer and from contextual information
(such as the current cursor position, the current paragraph size, the
current window size, or the contents of the current line).

Moreover, functions are often far more useful and convenient when they
obtain their data through context, rather than through their argument
lists. For example, a common problem when maintaining source code is
that assignment operators fall out of alignment as they accumulate,
which reduces the readability of the code:

    Listing 17. Assignment operators out of alignment

    let applicants_name = 'Luke'
    let mothers_maiden_name = 'Amidala'
    let closest_relative = 'sister'
    let fathers_occupation = 'Sith'
    
Realigning them manually every time a new statement is added can be
tedious:

    Listing 18. Manually realigned assignment operators

    let  applicants_name = 'Luke'
    let  mothers_maiden_name = 'Amidala'
    let  closest_relative = 'sister'
    let  fathers_occupation = 'Sith'

To reduce the tedium of that everyday coding task, you could create a
key-mapping (such as `;=`) that selects the current block of code,
locates any lines with assignment operators, and automatically aligns
those operators. Like so:

    Listing 19. Function to align assignment operators

    function AlignAssignments ()
        "Patterns needed to locate assignment operators...
        let ASSIGN_OP   = '[-+*/%|&]\?=\@<!=[=~]\@!'
        let ASSIGN_LINE = '^\(.\{-}\)\s*\(' . ASSIGN_OP . '\)'
        
        "Locate block of code to be considered (same indentation, no blanks)
        let indent_pat = '^' . matchstr(getline('.'), '^\s*') . '\S'
        let firstline = search('^\%('. indent_pat . '\)\@!','bnW') + 1
        let lastline = search('^\%('. indent_pat . '\)\@!', 'nW') - 1
        if lastline < 0
            let lastline = line('$')
        endif
        
        "Find the column at which the operators should be aligned...
        let max_align_col = 0
        let max_op_width = 0
        for linetext in getline(firstline, lastline)
            "Does this line have an assignment in it?
            let left_width = match(linetext, '\s*' . ASSIGN_OP)
            
            "If so, track the maximal assignment column and operator width...
            if left_width >= 0
                let max_align_col = max([max_align_col, left_width])
                let op_width  = strlen(matchstr(linetext, ASSIGN_OP))
                let max_op_width = max([max_op_width, op_width+1])
            endif
        endfor
        
        "Code needed to reformat lines so as to align operators...
        let FORMATTER = '\=printf("%-*s%*s",    max_align_col, submatch(1),
        \                                       max_op_width, submatch(2))'

        " Reformat lines with operators aligned in the appropriate column...
        for linenum in range(firstline, lastline)
            let oldline = getline(linenum)
            let newline = substitute(oldline, ASSIGN_LINE, FORMATTER, "")
            call setline(linenum, newline)
        endfor
    endfunction

    nmap <silent>   ;=  :call AlignAssignments()<CR>

The `AlignAssignments()` function first sets up two regular expressions
(see `:help pattern` for the necessary details of Vim's regex syntax):

    let ASSIGN_OP   = '[-+*/%|&]\?=\@<!=[=~]\@!'
    let ASSIGN_LINE = '^\(.\{-}\)\s*\(' . ASSIGN_OP . '\)'
    
The pattern in `ASSIGN_OP` matches any of the standard assignment
operators: `= , += , -= , *=`, etc. but carefully avoids matching other
operators that contain `=`, such as `==` and `=~`. If your favorite
language has other assignment operators (such as `.=` or `||=` or `^=`),
you could extend the `ASSIGN_OP` regex to recognize those as well.
Alternatively, you could redefine `ASSIGN_OP` to recognize other types
of "alignables," such as comment introducers or column markers, and
align them instead.

The pattern in `ASSIGN_LINE` matches only at the start of a line (`^`),
matching a minimal number of characters (`.\{-}`), then any whitespace
(`\s*`), then an assignment operator.

Note that both the initial "minimal number of characters" subpattern and
the operator subpattern are specified within capturing parentheses: `\(
... \)`. The substrings captured by those two components of the regex
will later be extracted using calls to the built-in `submatch()`
function; specifically, by calling `submatch(1)` to extract everything
before the operator, and `submatch(2)` to extract the operator itself.

AlignAssignments() then locates the range of lines on which it will
operate:

    let indent_pat = '^' . matchstr(getline('.'), '^\s*') . '\S'
    let firstline = search('^\%('. indent_pat . '\)\@!','bnW') + 1
    let lastline = search('^\%('. indent_pat . '\)\@!', 'nW') - 1
    if lastline < 0
        let lastline = line('$')
    endif

In earlier examples, functions have relied on an explicit command range
or a Visual mode selection to determine which lines they operate on, but
this function computes its own range directly. Specifically, it first
calls the built-in `matchstr()` function to determine what leading
whitespace (`'^\s*'`) appears at the start of the current line
(`getline('.')`. It then builds a new regular expression in `indent_pat`
that matches exactly the same sequence of whitespace at the start of any
non-empty line (hence the trailing `'\S'`).

`AlignAssignments()` then calls the built-in `search()` function to
search upwards (using the flags `'bnW'`) and locate the first line above
the cursor that does not have precisely the same indentation.  Adding 1
to this line number gives the start of the range of interest, namely,
the first contiguous line with the same indentation as the current line.

A second call to `search()` then searches downwards (`'nW'`) to
determine `lastline`: the number of the final contiguous line with the
same indentation. In this second case, the search might hit the end of
the file without finding a differently indented line, in which case
`search()` would return `-1`.  To handle this case correctly, the
following `if` statement would explicitly set `lastline` to the line
number of the end of file (that is, to the line number returned by
`line('$')`).

The result of these two searches is that `AlignAssignments()` now knows
the full range of lines immediately above or below the current line that
all have precisely the same indentation as the current line. It uses
this information to ensure that it aligns only those assignment
statements at the same scoping level in the same block of code. Unless,
of course, the indentation of your code doesn't correctly reflect its
scope, in which case you fully deserve the formatting catastrophe about
to befall you.

The first `for` loop in `AlignAssignments()` determines the column in
which the assignment operators should be aligned. This is done by
walking through the list of lines in the selected range (the lines
retrieved by `getline(firstline, lastline)`) and checking whether each
line contains an assignment operator (possibly preceded by whitespace):

    let left_width = match(linetext, '\s*' . ASSIGN_OP)
    
If there is no operator in the line, the built-in `match()` function
will fail to find a match and will return `-1`. In that case, the loop
simply skips on to the next line. If there is an operator, `match()`
will return the (positive) index at which that operator appears. The
`if` statement then uses the built-in `max()` function to determine
whether this latest column position is further right than any previously
located operator, thereby tracking the maximum column position required
to align all the assignments in the range:

    let max_align_col = max([max_align_col, left_width])
    
The remaining two lines of the `if` use the built-in `matchstr()`
function to retrieve the actual operator, then the built-in `strlen()`
to determine its length (which will be 1 for a "`=`" but 2 for "`+=`",
'`-=`' , etc.) The `max_op_width` variable is then used to track the
maximum width required to align the various operators in the range:

    let op_width        = strlen(matchstr(linetext, ASSIGN_OP))
    let max_op_width    = max([max_op_width, op_width+1])

Once the location and width of the alignment zone have been determined,
all that remains is to iterate through the lines in the range and
reformat them accordingly. To do that reformatting, the function uses
the built-in `printf()` function. This function is very useful, but also
very badly named.  It is not the same as the `printf` function in C or
Perl or PHP. It is, in fact, the same as the `sprintf` function in those
languages. That is, in Vimscript, `printf` doesn't print a formatted
version of its list of data arguments; it returns a string containing a
formatted version of its list of data arguments.

Ideally, in order to reformat each line, `AlignAssignments()` would use
the built-in `substitute()` function, and replace everything up to the
operator with a `printf 'd` rearrangement of that text.  Unfortunately,
`substitute()` expects a fixed string as its replacement value, not a
function call.

So, in order to use a `printf()` to reformat each replacement text, you
need to use the special embedded replacement form: `"\=expr"`. The
leading `\=` in the replacement string tells `substitute()` to evaluate
the expression that follows and use the result as the replacement text.
Note that this is similar to the `<C-R>=` mechanism in Insert mode,
except this magic behavior only works for the replacement string of the
built-in `substitute()` function (or in the standard `:s/ ... / ... /`
Vim command).

In this example, the special replacement form will be the same `printf`
for every line, so it is pre-stored in the `FORMATTER` variable before
the second for loop begins:

    let FORMATTER = '\=printf("%-*s%*s",    max_align_col, submatch(1),
    \                                       max_op_width, submatch(2))'

When it is eventually called by `substitute()`, this embedded `printf()`
will left-justify (using a `%-*s` placeholder) everything to the left of
the operator (`submatch(1)`) and place the result in a field that's
`max_align_col` characters wide. It will then right-justify (using a
`%*s`) the operator itself (`submatch(2)`) into a second field that's
`max_op_width` characters wide.  See `:help printf()` for details on how
the - and * options modify the two %s format specifiers used here.

With this formatter now available, the second for loop can finally
iterate through the full range of line numbers, retrieving the
corresponding text buffer contents one line at a time:

    for linenum in range(firstline, lastline)
        let oldline = getline(linenum)
        
The loop then uses `substitute()` to transform those contents, by
matching everything up to and including any assignment operator (using
the pattern in `ASSIGN_LINE`) and replacing that text with the result of
the `printf()` call (as specified by `FORMATTER`):

        let newline = substitute(oldline, ASSIGN_LINE, FORMATTER, "")
        call setline(linenum, newline)
    endfor
    
Once the `for` loop has iterated all the lines, any assignment operators
within them will now be aligned correctly. All that remains is to create
a key-mapping to invoke `AlignAssignments()`, like so:

    nmap <silent>   ;=  :call AlignAssignments()<CR>


## Looking ahead ##

Functions are an essential tool for decomposing an application into
correct and maintainable components, in order to manage the complexity
of real-world Vim programming tasks.

Vimscript allows you to define functions with fixed or variadic
parameter lists, and to have them interact either automatically or in
user-controlled ways with ranges of lines in the editor's text buffer.
Functions can call back to Vim's built-in features (for example, to
`search()` or `substitute()` text), and they can also directly access
editor state information (such as determining the current line the
cursor is on via `line('.')`) or interact with any text buffer currently
being edited (via `getline()` and `setline()`).

This is undoubtedly a powerful facility, but our ability to
programmatically manipulate state and content is always limited by how
cleanly and accurately we can represent the data on which our code
operates. So far in this series of articles, we've been restricted to
the use of single scalar values (numbers, strings, and booleans). In the
next two articles, we'll explore the use of much more powerful and
convenient data structures: ordered lists and random-access
dictionaries.


# Built-in lists #

## Explore Vimscript's support for lists and arrays ##

Vimscript provides excellent support for operating on collections of
data, a cornerstone of programming. In this third part in the book,
learn how to use Vimscript's built-in lists to ease everyday operations
such as reformatting lists, filtering sequences of filenames, and
sorting sets of line numbers. You'll also walk through examples that
demonstrate the power of lists to extend and enhance two common uses of
Vim: creating a user-defined function to align assignment operators, and
improving the built-in text completions mechanism.

The heart of all programming is the creation and manipulation of data
structures. So far in this book, we’ve considered only Vimscript’s
scalar data types (strings, numbers, and booleans) and the scalar
variables that store them. But the true power of programming Vim becomes
apparent when its scripts can operate on entire collections of related
data at once: reformatting lists of text lines, accessing
multidimensional tables of configuration data, filtering sequences of
filenames, and sorting sets of line numbers.

In this chapter, we’ll explore Vimscript’s excellent support for lists
and the arrays that store them, as well as the language's many built-in
functions that make using lists so easy, efficient, and maintainable.


## Lists in Vimscript ##

In Vimscript, a list is a sequence of scalar values: strings, numbers,
references, or any mixture thereof.

Vimscript lists are arguably misnamed. In most languages, a "list" is a
value (rather than a container), an immutable ordered sequence of
simpler values. In contrast, lists in Vimscript are mutable and in many
ways far more like (references to) anonymous-array data structures. A
Vimscript variable that is storing a list is, for most purposes, an
array.

You create a list by placing a comma-separated sequence of scalar values
inside a pair of square brackets. List elements are indexed from zero,
and are accessed and modified via the usual notation: postfix square
brackets with the index inside them:

    Listing 1. Creating a list

    let data = [1,2,3,4,5,6,"seven"]
    echo data[0]                |" echoes: 1
    let data[1] = 42            |" [1,42,3,4,5,6,"seven"]
    let data[2] += 99           |" [1,42,102,4,5,6,"seven"]
    let data[6] .= ' samurai'   |" [1,42,102,4,5,6,"seven samurai"]

You can also use indices less than zero, which then count backward from
the end of the list. So the final statement of the previous example
could also be written like so:

    let data[-1] .= ' samurai'

As in most other dynamic languages, Vimscript lists require no explicit
memory management: they automatically grow or shrink to accommodate the
elements they’re asked to store, and they’re automatically
garbage-collected when the program no longer requires them.


### Nested lists ###

In addition to storing strings or numbers, a list can also store other
lists. As in C, C++, or Perl, if a list contains other lists, it acts
like a multidimensional array. For example:

    Listing 2. Creating a nested list

    let pow = [
    \   [ 1, 0, 0, 0 ],
    \   [ 1, 1, 1, 1 ],
    \   [ 1, 2, 4, 8 ],
    \   [ 1, 3, 9, 27 ].
    \]
    " and later...
    echo pow[x][y]

Here, the first indexing operation ( pow[x] ) returns one of the
elements of the list in pow . That element is itself a list, so the
second indexing ( [y] ) returns one of the nested list’s elements.


### List assignments and aliasing ###

When you assign any list to a variable, you’re really assigning a
pointer or reference to the list.  So, assigning from one list variable
to another causes them to both point at or refer to the same underlying
list. This usually leads to unpleasant action-at-a-distance surprises
like the one you see here:

    Listing 3. Assign with caution

    let old_suffixes = ['.c', '.h', '.py']
    let new_suffixes = old_suffixes
    let new_suffixes[2] = '.js'
    echo old_suffixes   |" echoes: ['.c', '.h', '.js']
    echo new_suffixes   |" echoes: ['.c', '.h', '.js']

To avoid this aliasing effect, you need to call the built-in copy()
function to duplicate the list, and then assign the copy instead:

    Listing 4. Copying a list
    
    let old_suffixes = ['.c', '.h', '.py']
    let new_suffixes = copy(old_suffixes)
    let new_suffixes[2] = '.js'
    echo old_suffixes   |" echoes: ['.c', '.h', '.py']
    echo new_suffixes   |" echoes: ['.c', '.h', '.js']

Note, however, that `copy()` only duplicates the top level of the list.
If any of those values is itself a nested list, it’s really a
pointer/reference to some separate external list. In that case, `copy()`
will duplicate that pointer/reference, and the nested list will still be
shared by both the original and the copy, as shown here:

    Listing 5. Shallow copy
    
    let pedantic_pow = copy(pow)
    let pedantic_pow[0][0] = 'indeterminate'
    " also changes pow[0][0] due to shared nested list

If that’s not what you want (and it’s almost always not what you want),
then you can use the built-in `deepcopy()` function instead, which
duplicates any nested data structure "all the way down":

    Listing 6. Deep copy
    
    let pedantic_pow = deepcopy(pow)
    let pedantic_pow[0][0] = 'indeterminate'
    " pow[0][0] now unaffected; no nested list is shared


## Basic list operations ##

Most of Vim’s list operations are provided via built-in functions. The
functions usually take a list and
return some property of it:

    Listing 7. Finding size, range, and indexes

    " Size of list...
    let list_length = len(a_list)
    let list_is_empty = empty(a_list) " same as: len(a_list) == 0
    
    " Numeric minima and maxima...
    let greatest_elem = max(list_of_numbers)
    let least_elem = min(list_of_numbers)

    " Index of first occurrence of value or pattern in list...
    let value_found_at = index(list, value)     " uses == comparison
    let pat_matched_at = match(list, pattern)   " uses =~ comparison

The `range()` function can be used to generate a list of integers. If
called with a single-integer
argument, it generates a list from zero to one less than that argument.
Called with two arguments,
it generates an inclusive list from the first to the second. With three
arguments, it again generates
an inclusive list, but increments each successive element by the third
argument:

    Listing 8. Generating a list using the range() function

    let sequence_of_ints = range(max)             " 0...max-1
    let sequence_of_ints = range(min, max)        " min...max
    let sequence_of_ints = range(min, max, step)  " min, min+step,...max

You can also generate a list by splitting a string into a sequence of
"words":

    Listing 9. Generating a list by splitting text

    let words = split(str)                  " split on whitespace
    let words = split(str, delimiter_pat)   " split where pattern matches

To reverse that, you can join the list back together:

    Listing 10. Joining the elements of a list

    let str = join(list)            " use a single space char to join
    let str = join(list, delimiter) " use delimiter string to join


## Other list-related procedures ##

You can explore the many other list-related functions by typing `:help
function-list` in any Vim session, then scrolling down to "`List
manipulation`"). Most of these functions are actually procedures,
however, because they modify their list argument in-place.

For example, to insert a single extra element into a list, you can use
`insert()` or `add()`:

    Listing 11. Adding a value to a list

    call insert(list, newval)       " insert new value at start of list
    call insert(list, newval, idx)  " insert new value before index idx
    call add(list, newval)          " append new value to end of list

You can insert a list of values with `extend()`:

    Listing 12. Adding a set of values to a list

    call extend(list, newvals)      " append new values to end of list
    call extend(list, newvals, idx) " insert new values before index idx

Or remove specified elements from a list:

    Listing 13. Removing elements

    call remove(list, idx)      " remove element at index idx
    call remove(list, from, to) " remove elements in range of indices

Or sort or reverse a list:

    Listing 14. Sorting or reversing a list

    call sort(list)     " re-order the elements of list alphabetically
    call reverse(list)  " reverse order of elements in list


### A common mistake with list procedures ###

Note that all list-related procedures also return the list they’ve just
modified, so you could write:

    let sorted_list = reverse(sort(unsorted_list))
    
Doing so would almost always be a serious mistake, however, because even
when their return values are used in this way, list-related functions
still modify their original argument. So, in the previous example, the
list in `unsorted_list` would also be sorted and reversed. Moreover,
`unsorted_list` and `sorted_list` would now be aliased to the same
sorted-and-reversed list (as described under "List assignments and
aliasing").

This is highly counterintuitive for most programmers, who typically
expect functions like `sort` and `reverse` to return modified copies of
the original data, without changing the original itself.

Vimscript lists simply don’t work that way, so it’s important to
cultivate good coding habits that will help you avoid nasty surprises.
One such habit is to only ever call `sort()`, `reverse()`, and the like,
as pure functions, and to always pass a copy of the data to be modified.
You can use the built-in `copy()` function for this purpose:

    let sorted_list = reverse(sort(copy(unsorted_list)))


### Filtering and transforming lists ###

Two particularly useful procedural list functions are `filter()` and
`map()` . The `filter()` function takes a list and removes those
elements that fail to meet some specified criterion:

    let filtered_list = filter(copy(list), criterion_as_str)
    
The call to `filter()` converts the string that is passed as its second
argument to a piece of code, which it then applies to each element of
the list that is passed as its first argument. In other words, it
repeatedly performs an `eval()` on its second argument. For each
evaluation, it passes the next element of its first argument to the
code, via the special variable `v:val`. If the result of the evaluated
code is zero (that is, false), the corresponding element is removed from
the list.

For example, to remove any negative numbers from a list, type:

    let positive_only = filter(copy(list_of_numbers), 'v:val >= 0')
    
To remove any names from a list that contain the pattern `/.*nix/`,
type:

    let non_starnix = filter(copy(list_of_systems), 'v:val !~ ".*nix"')


### The map() function ###

The `map()` function is similar to `filter()`, except that instead of
removing some elements, it replaces every element with a user-specified
transformation of its original value. The syntax is:

    let transformed_list = map(copy(list), transformation_as_str)
    
Like `filter()`, `map()` evaluates the string passed as its second
argument, passing each list element in turn, via `v:val`. But, unlike
`filter()`, a `map()` always keeps every element of a list, replacing
each value with the result of evaluating the code on that value.

For example, to increase every number in a list by 10, type:

    let increased_numbers = map(copy(list_of_numbers), 'v:val + 10')
    
Or to capitalize each word in a list: type:

    let LIST_OF_WORDS = map(copy(list_of_words), 'toupper(v:val)')
    
Once again, remember that `filter()` and `map()` modify their first
argument in-place. A very common error when using them is to write
something like:

    let squared_values = map(values, 'v:val * v:val')
    
instead of:

    let squared_values = map(copy(values), 'v:val * v:val')


### List concatenation ###

You can concatenate lists with the `+` and `+=` operators, like so:

    Listing 15. Concatenating lists

    let activities = ['sleep', 'eat'] + ['game', 'drink']
    let activities += ['code']

Remember that both sides must be lists. Don’t think of `+=` as
"`append`"; you can’t use it to add a single value directly to the end
of a list:

    Listing 16. Concatenation needs two lists

    let activities += 'code'
    " Error: Wrong variable type for +=


## Sublists ##

You can extract part of a list by specifying a colon-separated range in
the square brackets of an indexing operation. The limits of the range
can be constants, variables with numeric values, or any numeric
expression:

    Listing 17. Extracting parts of a list

    let week = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']
    let weekdays = week[1:5]
    let freedays = week[firstfree : lastfree-2]

If you omit the starting index, the sublist automatically starts at
zero; if you omit the ending index, the sublist finishes at the last
element. For example, to split a list into two (near-)equal halves,
type:

    Listing 18. Splitting a list into two sublists

    let middle = len(data)/2
    let first_half = data[: middle-1]   " same as: data[0 : middle-1]
    let second_half = data[middle :]    " same as: data[middle : len(data)-1]


## Example 1: Revisiting autoalignments ##

The full power and utility of lists is best illustrated by example.
Let's start by improving an existing tool.

In the second part we explored a user-defined function called
`AlignAssignments()`, which lined up assignment operators in elegant
columns. Listing 19 reproduces that function.

    Listing 19. The original AlignAssignments() function

    function AlignAssignments ()
        " Patterns needed to locate assignment operators...
        let ASSIGN_OP   = '[-+*/%|&]\?=\@<!=[=~]\@!'
        let ASSIGN_LINE = '^\(.\{-}\)\s*\(' . ASSIGN_OP . '\)'

        " Locate block of code to be considered (same indentation, no blanks)
        let indent_pat  = '^' . matchstr(getline('.'), '^\s*') . '\S'
        let firstline   = search('^\%('. indent_pat . '\)\@!','bnW') + 1
        let lastline    = search('^\%('. indent_pat . '\)\@!', 'nW') - 1
        if lastline < 0
            let lastline = line('$')
        endif
        
        " Find the column at which the operators should be aligned...
        let max_align_col = 0
        let max_op_width = 0
        for linetext in getline(firstline, lastline)
            " Does this line have an assignment in it?
            let left_width = match(linetext, '\s*' . ASSIGN_OP)
            
            " If so, track the maximal assignment column and operator width...
            if left_width >= 0
                let max_align_col = max([max_align_col, left_width])
                let op_width        = strlen(matchstr(linetext, ASSIGN_OP))
                let max_op_width    = max([max_op_width, op_width+1])
            endif
        endfor
        
        " Code needed to reformat lines so as to align operators...
        let FORMATTER = '\=printf("%-*s%*s",    max_align_col, submatch(1),
        \                                       max_op_width, submatch(2))'

        " Reformat lines with operators aligned in the appropriate column...
        for linenum in range(firstline, lastline)
            let oldline = getline(linenum)
            let newline = substitute(oldline, ASSIGN_LINE, FORMATTER, "")
            call setline(linenum, newline)
        endfor
    endfunction

One deficiency of this function is that it has to grab each line being
processed twice: once (in the first `for loop`) to gather information on
the paragraph’s existing structure, and a second time (in the final `for
loop`) to adjust each line to fit the new structure.

This duplicated effort is clearly suboptimal. It would be better to
store the lines in some internal data structure and reuse them directly.
Knowing what you do about lists, it is indeed possible to rewrite
`AlignAssignments()` more efficiently and more cleanly. Listing 20 shows
a new version of the function that takes advantage of several list data
structures and the various list-manipulation functions described
earlier.

    Listing 20. An updated AlignAssignments() function

    function! AlignAssignments ()
        " Patterns needed to locate assignment operators...
        let ASSIGN_OP   = '[-+*/%|&]\?=\@<!=[=~]\@!'
        let ASSIGN_LINE = '^\(.\{-}\)\s*\(' . ASSIGN_OP . '\)\(.*\)$'

        " Locate block of code to be considered (same indentation, no blanks)
        let indent_pat  = '^' . matchstr(getline('.'), '^\s*') . '\S'
        let firstline   = search('^\%('. indent_pat . '\)\@!','bnW') + 1
        let lastline    = search('^\%('. indent_pat . '\)\@!', 'nW') - 1
        if lastline < 0
            let lastline = line('$')
        endif
        
        " Decompose lines at assignment operators...
        let lines = []
        for linetext in getline(firstline, lastline)
            let fields = matchlist(linetext, ASSIGN_LINE)
            call add(lines, fields[1:3])
        endfor
        
        " Determine maximal lengths of lvalue and operator...
        let op_lines    = filter(copy(lines),'!empty(v:val)')
        let max_lval    = max( map(copy(op_lines), 'strlen(v:val[0])') ) + 1
        let max_op      = max( map(copy(op_lines), 'strlen(v:val[1])' ) )
        
        " Recompose lines with operators at the maximum length...
        let linenum = firstline
        for line in lines
            if !empty(line)
                let newline
                \   = printf("%-*s%*s%s", max_lval, line[0],
                \           max_op, line[1], line[2])
                call setline(linenum, newline)
            endif
            let linenum += 1
        endfor
    endfunction

Note that the first two code blocks within the new function are almost
identical to those in the original. As before, they locate the range of
lines whose assignments are to be aligned, based on the current
indentation of the text.

The changes begin in the third code block, which uses the two-argument
form of the built-in `getline()` function to return a list of all the
lines in the range to be realigned.

The `for` loop then iterates through each line, matching it against the
regular expression in `ASSIGN_LINE` using the built-in `matchlist()`
function:

    let fields = matchlist(linetext, ASSIGN_LINE)

The call to `matchlist()` returns a list of all the fields captured by
the regex (that is, anything matched by those parts of the pattern
inside `\(...\)` delimiters). In this example, if the match succeeds,
the resulting fields are a decomposition that separates out the
`lvalue`, operator, and `rvalue` of any assignment line.  Specifically,
a successful call to `matchlist()` will return a list with the following
elements:

* The full line (because matchlist() always returns the entire match as
  its first element)
* Everything to the left of the assignment operator
* The assignment operator itself
* Everything to the right of the assignment operator

In that case, the call to `add()` adds a sublist of the final three
fields to the lines list. If the match failed (that is, the line didn’t
contain an assignment), then `matchlist()` will return an empty list, so
the sublist that `add()` appends (`fields[1:3]` below) will also be
empty.  This will be used to indicate a line of no further interest to
the reformatter:

    call add(lines, fields[1:3])
    
The fourth code block deploys the `filter()` and `map()` functions to
analyze the structure of each line containing an assignment. It first
uses a `filter()` to winnow the list of lines, keeping only those that
were successfully decomposed into multiple components by the previous
code block:

    let op_lines = filter(copy(lines), '!empty(v:val)')
    
Next the function determines the length of each assignment’s `lvalue`,
by mapping the `strlen()` function over a copy of the filtered lines:

    map(copy(op_lines), 'strlen(v:val[0])')
    
The resulting list of `lvalue` lengths is then passed to the built-in
`max()` function to determine the longest `lvalue` in any assignment.
The maximal length determines the column at which all the assignment
operators will need to be aligned (that is, one column beyond the widest
`lvalue`):

    let max_lval = max( map(copy(op_lines),'strlen(v:val[0])') ) + 1

In the same way, the final line of the fourth code block determines the
maximal number of columns required to accommodate the various assignment
operators that were found, by mapping and then maximizing their
individual string lengths:

    let max_op = max( map(copy(op_lines),'strlen(v:val[1])' ) )

The final code block then reformats the assignment lines, by iterating
through the original buffer line numbers (`linenum`) and through each
line in the lines list, in parallel:

    let linenum = firstline
    for line in lines
    
Each iteration of the loop checks whether a particular line needs to be
reformatted (that is, whether it was decomposed successfully around an
assignment operation). If so, the function creates a new version of the
line, using a `printf()` to reformat the line’s components:

    if !empty(line)
        let newline = printf("%-*s%*s%s",
        \                    max_lval, line[0], max_op, line[1],
        \                    line[2])
        
That new line is then written back to the editor buffer by calling
`setline()`, and the line tracking is updated for the next iteration:

        call setline(linenum, newline)
    endif
    let linenum += 1

Once all the lines have been processed, the buffer will have been
completely updated and all the relevant assignment operators aligned to
a suitable column. Because it can take advantage of Vimscript's
excellent support for lists and list operations, the code for this
second version of `AlignAssignments()` is about 15 percent shorter than
that of the previous version. Far more importantly, however, the
function does only one-third as many buffer accesses, and the code is
much clearer and more maintainable.


## Example 2: Enhancing Vim’s completion facilities ##

Vim has a sophisticated built-in text-completion mechanism, which you
can learn about by typing :help ins-completion in any Vim session.

One of the most commonly used completion modes is keyword completion.
You can use it any time you’re inserting text, by pressing *CTRL-N*. When
you do, it searches various locations (as specified by the "`complete`"
option), looking for words that start with whatever sequence of
characters immediately precedes the cursor. By default, it looks in the
current buffer you’re editing, any other buffers you’ve edited in the
same session, any tag files you’ve loaded, and any files that are
included from your text (via the `include` option).

For example, if you had the preceding two paragraphs in a buffer, and
then --in insertion mode-- you typed:

    My use of Vim is increasingly so<CTRL-N>
    
Vim would search the text and determine that the only word beginning
with `"so..."` was `sophisticated`, and would complete that word
immediately:

    My use of Vim is increasingly sophisticated_
    
On the other hand, if you typed:

    My repertoire of editing skills is bu<CTRL-N>
    
Vim would detect three possible completions: `built`, `buffer`, and
`buffers`.  By default, it would show a menu of alternatives:

    Listing 21. Text completion with alternatives

    My repertoire of editing skills is  bu_
                                        built
                                        buffer
                                        buffers

and you could then use a sequence of *CTRL-N* and *CTRL-P* (or the up-
and down-arrows) to step through the menu and select the word you
wanted.

To cancel a completion at any time, you can type *CTRL-E*; to accept and
insert the currently selected alternative, you can type *CTRL-Y*. Typing
anything else (typically, a space or newline) also accepts and inserts
the currently selected word, as well as whatever extra character you
typed.


### Designing smarter completions ###

There’s no doubt that Vim's built-in completion mechanism is extremely
useful, but it’s not very clever. By default, it matches only sequences
of "keyword" characters (alphanumerics and underscore), and it has no
deep sense of context beyond matching what’s immediately to the left of
the cursor.

The completion mechanism is also not very ergonomic. *CTRL-N* isn’t the
easiest sequence to type, nor is it the one a programmer’s fingers are
particularly used to typing. Most command-line users are more accustomed
to using *TAB* or *ESC* as their completion key.

Happily, with Vimscript, we can easily remedy those deficiencies. Let’s
redefine the *TAB* key in insertion mode so that it can be taught to
recognize patterns in the text on either side of the cursor and select
an appropriate completion for that context. We’ll also arrange it so
that, if the new mechanism doesn’t recognize the current insertion
context, it will fall back to Vim’s built-in *CTRL-N* completion
mechanism. Oh, and while we’re at it, we should probably make sure we
can still use the *TAB* key to type tab characters, where that’s
appropriate.


### Specifying smarter completions ###

To build this smarter completion mechanism, we’ll need to store a series
of "contextual responses" to a completion request. So we’ll need a list.
Or rather, a list of lists, given each contextual response will itself
consist of four elements. Listing 22 shows how to set up that data
structure.

    Listing 22. Setting up a look-up table in Vimscript

    " Table of completion specifications (a list of lists)...
    let s:completions = []
    " Function to add user-defined completions...
    function! AddCompletion (left, right, completion, restore)
        call insert(s:completions, [a:left, a:right, a:completion, a:restore])
    endfunction
    let s:NONE = ""
    " Table of completions...
    "                   Left    Right   Complete with           Restore
    "                   =====   =====   =============           =======
    call AddCompletion( '{',    s:NONE, "}",                        1   )
    call AddCompletion( '{',    '}',    "\<CR>\<C-D>\<ESC>O",       0   )
    call AddCompletion( '\[',   s:NONE, "]",                        1   )
    call AddCompletion( '\[',   '\]',   "\<CR>\<ESC>O\<TAB>",       0   )
    call AddCompletion( '(',    s:NONE, ")",                        1   )
    call AddCompletion( '(',    ')',    "\<CR>\<ESC>O\<TAB>",       0   )
    call AddCompletion( '<',    s:NONE, ">",                        1   )
    call AddCompletion( '<',    '>',    "\<CR>\<ESC>O\<TAB>",       0   )
    call AddCompletion( '"',    s:NONE, '"',                        1   )
    call AddCompletion( '"',    '"',    "\\n",                      1   )
    call AddCompletion( "'",    s:NONE, "'",                        1   )
    call AddCompletion( "'",    "'",    s:NONE,                     0   )

The list-of-lists we create will act as a table of contextual response
specifications, and will be stored in the list variable `s:completions`.
Each entry in the list will itself be a list, with four values:

* A string specifying a regular expression to match what’s to the left
  of the cursor
* A string specifying a regular expression to match what’s to the right
  of the cursor
* A string to be inserted when both contexts are detected
* A flag indicating whether to automatically restore the cursor to its
  pre-completion position, after the completion text has been inserted

To populate the table, we create a small function: `AddCompletion()`.
This function expects four arguments: the left and right contexts, and
the replacement text, and the "`restore cursor`" flag.  The series of
arguments are simply collected into a single list:

    [a:left, a:right, a:completion, a:restore]
    
and that list is then prepended as a single element at the start of the
`s:completions` variable using the built-in `insert()` function:

    call insert(s:completions, [a:left, a:right, a:completion, a:restore])

Repeated calls to `AddCompletion()` therefore build up a list of lists,
each of which specifies one completion. The code in Listing 22 does the
work.

The first call to `AddCompletion()`:

    "                   Left    Right       Complete with...        Restore
    "                   =====   =======     ====================    =======
    call AddCompletion( '{',    s:NONE,     '}',                       1    )

specifies that, when the new mechanism encounters a curly brace to the
left of the cursor and nothing to the right, it should insert a closing
curly brace and then restore the cursor to its pre-completion position.
That is, when completing:

    while (1) {_
    
(where the `_` represents the cursor), the mechanism will now produce:

    while (1) {_}

leaving the cursor conveniently in the middle of the newly closed block.

The second call to `AddCompletion()`:

    "                       Left    Right       Complete with...      Restore
    "                       =====   =======     ====================  =======
    call AddCompletion(     '{',    '}',        "\<CR>\<C-D>\<ESC>O",   0    )

then proceeds to make the completion mechanism smarter still. It
specifies that, when the mechanism encounters an opening curly brace to
the left of the cursor and a closing brace to the right of the cursor,
it should insert a newline, outdent the closing curly (via a *CTRL-D*),
then escape from insertion mode (*ESC*) and open a new line above the
closing curly (`O`).

Assuming the "`smartindent`" option is enabled, the net effect of the
sequence is that, when you press *TAB* in the following context

    while (1) {_}

the mechanism will produce:

    while (1) {
        _
    }

In other words, because of the first two additions to the completion
table, *TAB*-completion after an opening brace closes it on the same
line, and then immediately doing a second *TAB*-completion "stretches"
the block across several lines (with correct indenting).

The remaining calls to `AddCompletion()` replicate this arrangement for
the three other kinds of brackets (square, round, and angle) and also
provide special completion semantics for single-and double-quotes.
Completing after a double-quote appends the matching double-quote, while
completing between two double quotes appends a `\n` (newline)
metacharacter. Completing after a single quote appends the matching
single quote, and then a second completion attempt does nothing.


### Implementing smarter completions ###

Once the list of completion-specifications has been set up, all that
remains is to implement a function to select the appropriate completion
from the table, and then bind that function to the *TAB* key. Listing 23
shows that code.

    Listing 23. A smarter completion function

    " Implement smart completion magic...
    function! SmartComplete ()
        " Remember where we parked...
        let cursorpos = getpos('.')
        let cursorcol = cursorpos[2]
        let curr_line = getline('.')

        " Special subpattern to match only at cursor position...
        let curr_pos_pat = '\%' . cursorcol . 'c'
        
        " Tab as usual at the left margin...
        if curr_line =~ '^\s*' . curr_pos_pat
            return "\<TAB>"
        endif
        
        " How to restore the cursor position...
        let cursor_back = "\<C-O>:call setpos('.'," . string(cursorpos) . ")\<CR>"
        
        " If a matching smart completion has been specified, use that...
        for [left, right, completion, restore] in s:completions
            let pattern = left . curr_pos_pat . right
            if curr_line =~ pattern
                " Code around bug in setpos() when used at EOL...
                if cursorcol == strlen(curr_line)+1 && strlen(completion)==1
                    let cursor_back = "\<LEFT>"
                endif

                " Return the completion...
                return completion . (restore ? cursor_back : "")
            endif
        endfor

        " If no contextual match and after an identifier, do keyword completion...
        if curr_line =~ '\k' . curr_pos_pat
            return "\<C-N>"

            " Otherwise, just be a <TAB>...
        else
            return "\<TAB>"
        endif
    endfunction

    " Remap <TAB> for smart completion on various characters...
    inoremap <silent> <TAB> <C-R>=SmartComplete()<CR>

The `SmartComplete()` function first locates the cursor, using the
built-in `getpos()` function with a '.' argument (that is, "get position
of cursor"). That call returns a list of four elements: the buffer
number (usually zero), the row and column numbers (both indexed from 1),
and a special "virtual offset" (which is also usually zero, and not
relevant here). We’re primarily interested in the middle two values, as
they indicate the location of the cursor. In particular,
`SmartComplete()` needs the column number, which is extracted by
indexing into the list that `getpos()` returned, like so:

    let cursorcol = cursorpos[2]
    
The function also needs to know the text on the current line, which can
be retrieved using `getline()`, and is stored in `curr_line`.

`SmartComplete()` is going to convert each entry in the `s:completions`
table into a pattern to be matched against the current line. In order to
correctly match left and right contexts around the cursor, it needs to
ensure the pattern matches only at the cursor’s column. Vim has a
special subpattern for that: `\%Nc` (where N is the column number
required). So, the function creates that subpattern by interpolating the
cursor’s column position found earlier:

    let curr_pos_pat = '\%' . cursorcol . 'c'

Because we’re eventually going to bind this function to the *TAB* key,
we’d like the function to still insert a TAB whenever possible, and
especially at the start of a line.  So `SmartComplete()` first checks if
there is only whitespace to the left of the cursor position, in which
case it returns a simple tabspace:

    if curr_line =~ '^\s*' . curr_pos_pat
        return "\<TAB>"
    endif

If the cursor isn’t at the start of a line, then `SmartComplete()` needs
to check all the entries in the completion table and determine which, if
any, apply. Some of those entries will specify that the cursor should be
returned to its previous position after completion, which will require
executing a custom command from within insertion mode. That command is
simply a call to the built-in `setpos()` function, passing the value the
original information from the earlier call to `getpos()`.  To execute
that function call from within insertion mode requires a *CTRL-O* escape
(see `:help i_CTRL-O` in any Vim session). So `SmartComplete()`
prebuilds the necessary *CTRL-O* command as a string and stores in
`cursor_back`:

    let cursor_back = "\<C-O>:call setpos('.'," . string(cursorpos) . ")\<CR>"


### A more-sophisticated for loop ###

To walk through the completions table, the function uses a special
version of the for statement.  The standard `for` loop in Vimscript
walks through a one-dimensional list, one element at a time:

    Listing 24. A standard for loop

    for name in list
        echo name
    endfor

However, if the list is two-dimensional (that is, each element is itself
a list), then you often want to "unpack" the contents of each nested
list as it is iterated. You could do that like so:

    Listing 25. Iterating over nested lists

    for nested_list in list_of_lists
        let name    = nested_list[0]
        let rank    = nested_list[1]
        let serial = nested_list[2]
        
        echo rank . ' ' . name . '(' . serial . ')'
    endfor

but Vimscript has a much cleaner shorthand for it:

    Listing 26. A cleaner shorthand for iterating over nested lists

    for [name, rank, serial] in list_of_lists
        echo rank . ' ' . name . '(' . serial . ')'
    endfor

On each iteration, the loop takes the next nested list from
`list_of_lists` and assigns the first element of that nested list to
`name`, the second nested element to `rank`, and the third to `serial`.

Using this special form of `for` loop makes it easy for
`SmartComplete()` to walk through the table of completions and give a
logical name to each component of each completion:

    for [left, right, completion, restore] in s:completions


### Recognizing a completion context ###

Within the loop, `SmartComplete()` constructs a regular expression by
placing the left and right context patterns around the special
subpattern that matches the cursor position:

    let pattern = left . curr_pos_pat . right
    
If the current line matches the resulting regex, then the function has
found the correct completion (the text of which is already in
completion) and can return it immediately. Of course, it also needs to
append the cursor restoration command it built earlier, if the selected
completion has requested it (that is, if restore is true).

Unfortunately, that `setpos()`-based cursor restoration command has a
problem. In Vim versions 7.2 or earlier, there’s an obscure idiosyncrasy
in `setpos()`: it doesn’t correctly reposition the cursor in insertion
mode if the cursor was previously at the end of a line and the
completion text to be inserted is only one character long. In that
special case, the restoration command has to be changed to a single
left-arrow, which moves the cursor back over the one newly inserted
character.

So, before the selected completion is returned, the following code makes
that change:

    Listing 27. Restoring the cursor after a one-character insertion at end-of-line

    if cursorcol == strlen(curr_line)+1 && strlen(completion)==1
        let cursor_back = "\<LEFT>"
    endif

All that remains is to return the selected completion, appending the
`cursor_back` command if cursor restoration was requested:

    return completion . (restore ? cursor_back : "")
    
If none of the entries from the completion table match the current
context, `SmartComplete()` will eventually fall out of the for loop and
will then try two final alternatives. If the character immediately
before the cursor was a "keyword" character, it invokes a normal
keyword-completion by returning a *CTRL-N*:

    Listing 28. Falling back to CTRL-N behavior

    " If no contextual match and after an identifier, do keyword completion...
    if curr_line =~ '\k' . curr_pos_pat
        return "\<C-N>"
    
Otherwise, no completion was possible, so it falls back to acting like a
normal *TAB* key, by returning a literal tab character:

    Listing 29. Falling back to normal TAB key behavior

    " Otherwise, just be a <TAB>...
    else
        return "\<TAB>"
    endif


### Deploying the new mechanism ###

Now we just have to make the *TAB* key call `SmartComplete()` in order
to work out what it should insert. That’s done with an `inoremap`, like
so:

    inoremap <silent> <TAB> <C-R>=SmartComplete()<CR>
    
The key-mapping converts any insert-mode *TAB* to a *CTRL-R=*, calling
`SmartComplete()` and inserting the completion string it returns (see
`:help i_CTRL-R` or the first part of this book for details of this
mechanism).

The `inoremap` form of `imap` is used here because some of the
completion strings that `SmartComplete()` returns also contain a *TAB*
character. If a regular `imap` were used, inserting that returned *TAB*
would immediately cause this same key-mapping to be re-invoked, calling
`SmartComplete()` again, which might return another *TAB*, and so on.

With the `inoremap` in place, we now have a *TAB* key that can:

* Recognize special user-defined insertion contexts and complete them
  appropriately
* Fall back to regular CTRL-N completion after an identifier
* Still act like a TAB everywhere else

In addition, with the code from Listings 22 and 23 placed in your .vimrc
file, you will be able to add new contextual completions simply by
extending the completion table with extra calls to `AddCompletion()`.
For example, you could make it easier to start new Vimscript functions
with:

    call AddCompletion( 'function!\?',  "", "\<CR>endfunction", 1 )
    
so that tabbing immediately after a function keyword appends the
corresponding endfunction keyword on the next line.

Or, you could autocomplete C/C++ comments intelligently (assuming the
cindent option is also set) with:

    call AddCompletion( '/\*', "",  '*/',                           1 )
    call AddCompletion( '/\*', '\*/', "\<CR>* \<CR>\<ESC>\<UP>A",   0 )

So that:

    /*_<TAB>
    
appends a closing comment delimiter after the cursor:

    /*_*/

and a second *TAB* at that point inserts an elegant multiline comment
and positions the cursor in the middle of it:

    /*
    * _
    */


## Looking ahead ##

The ability to store and manipulate lists of data greatly increases the
range of tasks that Vimscript can easily accomplish, but lists are not
always the ideal solution for aggregating and storing collections of
information. For example, the re-implemented version of
`AlignAssignments()` shown in Listing 20 contains a `printf()` call that
looks like this:

    printf("%-*s%*s%s", max_lval, line[0], max_op, line[1], line[2])
    
Using `line[0]`, `line[1]`, and `line[2]` for the various components of
a code line is certainly not very readable, and hence both error-prone
during initial implementation, and unnecessarily hard to maintain
thereafter.

This is a common situation: related data needs to be collected together,
but has no inherent or meaningful order. In such cases, each datum is
often better identified by some logical name, rather than by a numeric
index. Of course, we could always create a set of variables to "name"
the respective numeric constants:

    let LVAL    = 0
    let OP      = 1
    let RVAL    = 2
    
    " and later...
    printf("%-*s%*s%s", max_lval, line[LVAL], max_op, line[OP], line[RVAL])

But that’s a clunky and brittle solution, prone to hard-to-find errors
if the order of components were to change within the line list, but the
variables weren’t updated appropriately.

Because collections of named data are such a common requirement in
programming, in most dynamic languages there’s a common construct that
provides them: the `associative array`, or `hash table`, or
`dictionary`. As it turns out, Vim has dictionaries too. In the next
part, we’ll look at Vimscript’s implementation of that very useful data
structure.


# Dictionaries #

## Learn when to use dictionaries for cleaner, faster code ##

A dictionary is a container data structure that offers different
optimizations and trade-offs from a list. In particular, in a dictionary
the order of the elements stored is irrelevant and the identity of each
element is explicit. In this fourth chapter we introduce to dictionaries,
including an overview of their basic syntax and many functions.  We'll
conclude with several examples that illustrate the use of dictionaries
for more efficient data processing and cleaner code.

A dictionary in Vimscript is essentially the same as an AWK associative
array, a Perl hash, or a Python dictionary. That is, it's an unordered
container, indexed by strings rather than integers.

This fourth part introduces this important data structure and explains
its various functions for copying, filtering, extending, and pruning.
The examples focus on the differences between lists and dictionaries,
and on those cases where the use of a dictionary is a better alternative
to the list-based solutions developed in Part 3 on built-in lists.


## Dictionaries in Vimscript ##

You create a dictionary in Vimscript by using curly braces around a list
of key/value pairs. In each pair, the key and value are separated by a
colon. For example:

    Listing 1. Creating a dictionary

    let seen = {}   " Haven't seen anything yet

    let daytonum = { 'Sun':0, 'Mon':1, 'Tue':2, 'Wed':3, 'Thu':4, 'Fri':5, 'Sat':6 }
    let diagnosis = {
    \       'Perl'      : 'Tourettes',
    \       'Python'    : 'OCD',
    \       'Lisp'      : 'Megalomania',
    \       'PHP'       : 'Idiot-Savant',
    \       'C++'       : 'Savant-Idiot',
    \       'C#'        : 'Sociopathy',
    \       'Java'      : 'Delusional',
    \}

Once you have created a dictionary, you can access its values using the
standard square-bracket indexing notation, but using a string as the
index instead of a number:

    let lang = input("Patient's name? ")
    let Dx = diagnosis[lang]
    
If the key doesn't exist in the dictionary, an exception is thrown:

    let Dx = diagnosis['Ruby']
    **E716: Key not present in Dictionary: Ruby**

However, you can access potentially non-existent entries safely, using
the `get()` function. `get()` takes two arguments: the dictionary
itself, and a key to look up in it.  If the key exists in the
dictionary, the corresponding value is returned; if the key doesn't
exist, `get()` returns zero.  Alternately, you can specify a third
argument, in which case `get()` returns that value if the key isn't
found:

    let Dx = get(diagnosis, 'Ruby')
    " Returns: 0

    let Dx = get(diagnosis, 'Ruby', 'Schizophrenia')
    " Returns: 'Schizophrenia'

There's a third way to access a particular dictionary entry. If the
entry's key consists only of identifier characters (alphanumerics and
underscores), you can access the corresponding value using the "dot
notation," like so:

    let Dx = diagnosis.Lisp " Same as: diagnosis['Lisp']
    diagnosis.Perl = 'Multiple Personality' " Same as: diagnosis['Perl']

This special limited notation makes dictionaries very easy to use as
records or structs:

    let user = {}
    let user.name   = 'Bram'
    let user.acct   = 123007
    let user.pin_num = '1337'


## Batch-processing of dictionaries ##

Vimscript provides functions that allow you to get a list of all the
keys in a dictionary, a list of all its values, or a list of all its
key/value pairs:

    let keylist = keys(dict)
    let valuelist = values(dict)
    let pairlist = items(dict)

This `items()` function actually returns a list of lists, where each
"inner" list has exactly two elements: one key and the corresponding
value. Hence `items()` is especially handy for iterating through the
entries of a dictionary:

    for [next_key, next_val] in items(dict)
        let result = process(next_val)
        echo "Result for " next_key " is " result
    endfor


## Assignments and identities ##

Assignments in dictionaries work exactly as they do for Vimscript lists.
Dictionaries are represented by references (that is, pointers), so
assigning a dictionary to another variable aliases the two variables to
the same underlying data structure. You can get around this by first
copying or deep-copying the original:

    let dict2 = dict1 " dict2 just another name for dict1
    let dict3 = copy(dict1) " dict3 has a copy of dict1's top-level elements
    let dict4 = deepcopy(dict1) " dict4 has a copy of dict1 (all the way down)

Just as for lists, you can compare identity with the `is` operator, and
value with the `==` operator:

    if dictA is dictB
        " They alias the same container, so must have the same keys and values
    elseif dictA == dictB
        " Same keys and values, but maybe in different containers
    else
        " Different keys and/or values, so must be different containers
    endif


## Adding and removing entries ##

To add an entry to a dictionary, just assign a value to a new key:

    let diagnosis['COBOL'] = 'Dementia'

To merge in multiple entries from another dictionary, use the `extend()`
function. Both the first argument (which is being extended) and the
second argument (which contains the extra entries) must be dictionaries:

    call extend(diagnosis, new_diagnoses)

`extend()` is also convenient when you want to add multiple entries
explicitly:

    call extend(diagnosis, {'COBOL':'Dementia', 'Forth':'Dyslexia'})
    
There are two ways to remove a single entry from a dictionary: the
built-in `remove()` function, or the `unlet` command:

    let removed_value = remove(dict, "key")
    unlet dict["key"]

When removing multiple entries from a dictionary, it is cleaner and more
efficient to use `filter()`.  The `filter()` function works much the
same way as for lists, except that in addition to testing each entry's
value using `v:val`, you can also test its key using `v:key`. For
example:

    Listing 2. Testing values and keys

    " Remove any entry whose key starts with C...
    call filter(diagnosis, 'v:key[0] != "C"')

    " Remove any entry whose value doesn't contain 'Savant'...
    call filter(diagnosis, 'v:val =~ "Savant"')

    " Remove any entry whose value is the same as its key...
    call filter(diagnosis, 'v:key != v:val')


## Other dictionary-related functions ##

In addition to `filter()`, dictionaries can use several other of the
same built-in functions and procedures as lists. In almost every case
(the notable exception being `string()`), a list function applied to a
dictionary behaves as if the function had been passed a list of the
values of the dictionary. Listing 3 shows the most commonly used
functions.

    Listing 3. Other list functions that also work on dictionaries

    let is_empty = empty(dict) " True if no entries at all
    let entry_count = len(dict) " How many entries?
    let occurrences = count(dict, str) " How many values are equal to str?
    let greatest = max(dict) " Find smallest value of any entry
    let least = min(dict) " Find largest value of any entry
    call map(dict, value_transform_str) " Transform values by eval'ing string
    echo string(dict) " Print dictionary as key/value pairs

The `filter()` built-in is particularly handy for normalizing the data
in a dictionary. For example, given a dictionary containing the
preferred names of users (perhaps indexed by userids), you could ensure
that each name was correctly capitalized, like so:

    call map( names, 'toupper(v:val[0]) . tolower(v:val[1:])' )

The call to `map()` walks through each value, aliases it to `v:val`,
evaluates the expression in the string, and replaces the value with the
result of that expression. In this example, it converts the first
character of the name to uppercase, and the remaining characters to
lowercase, and then uses that modified string as the new name value.


## Deploying dictionaries for cleaner code ##

The third part explained Vimscript's _variadic_ function arguments with
a small example that generated comment boxes around a specified text.
Optional arguments could be added after the text string to specify the
comment introducer, the character used as the "box," and the width of
the comment. Listing 4 reproduces the original function.

    Listing 4. Passing optional arguments as variadic parameters
    
    function! CommentBlock(comment, ...)
        " If 1 or more optional args, first optional arg is introducer...
        let introducer = a:0 >= 1 ? a:1 : "//"
        
        " If 2 or more optional args, second optional arg is boxing character...
        let box_char = a:0 >= 2 ? a:2 : "*"
        
        " If 3 or more optional args, third optional arg is comment width...
        let width = a:0 >= 3 ? a:3 : strlen(a:comment) + 2

        " Build the comment box and put the comment inside it...
        return introducer . repeat(box_char,width)  . "\<CR>"
        \    . introducer . " " . a:comment         . "\<CR>"
        \    . introducer . repeat(box_char,width)  . "\<CR>"
    endfunction

Variadic arguments are convenient for specifying function options but
suffer from two major drawbacks: they impose an explicit ordering on the
function's parameters, and they leave that ordering implicit in function
calls.


### Revisiting autocomments ###

As Listing 4 illustrates, when any arguments are optional, it is usually
necessary to decide in advance the order in which they must be
specified. This necessity presents a design problem, however: in order
to specify a later option, the user will have to explicitly specify all
the options before it as well. Ideally, the first option would be the
most commonly used one, the second would be the second-most commonly
used, etc. In reality, deciding on this order before the function is
widely deployed can be difficult: how are you supposed to know which
option will be most important to most people?

The `CommentBlock()` function in Listing 4, for example, assumes that
the comment introducer is the optional argument that is most likely to
be needed, and so places it first in the parameter list. But what if a
user of the function only ever programs in C and C++, and so never
alters the default introducer? Worse, what if it turns out that the
width of comment blocks varies for every new project? This will prove
very annoying, because developers will now have to specify all three
optional arguments every time, even though the first two are always
given their default values:

    " Comment of required width, with standard delimiter and box character...
    let new_comment = CommentBlock(comment_text, '//', '*', comment_width)
    
This leads directly to the second issue, namely that when any options do
need to be specified explicitly, it is likely that several of them will
have to be specified.  However, because options default to the most
commonly needed values, the user may be unfamiliar with specifying
options, and hence unfamiliar with the necessary order. This can lead to
implementation errors like the following:

    " Box comment using ==== to standard line width...
    let new_comment = CommentBlock(comment_text, '=', 72)

...which, rather disconcertingly, produces a (non-)comment that looks
like this:

    =727272727272727272727272727272 = A bad comment =727272727272727272727272727272

The problem is that the optional arguments have nothing explicit to
indicate which option they are supposed to set. Their meaning is
determined implicitly by their position in the argument list, and so any
mistake in their ordering silently changes their meaning.

This is a classic case of using the wrong tool for the job. Lists are
perfect when order is significant and identity is best implied by
position. But, in this example, the order of the optional arguments is
more a nuisance than a benefit and their positions are easily confused,
which can lead to subtle errors of misidentification.

What's wanted is, in a sense, the exact opposite of a list: a data
structure where order is irrelevant, and identity is explicit. In other
words, a dictionary. Listing 5 shows the same function, but with its
options specified via a dictionary, rather than with variadic
parameters.

    Listing 5. Passing optional arguments in a dictionary

    function! CommentBlock(comment, opt)
        " Unpack optional arguments...
        let introducer  = get(a:opt,    'intro',    '//'    )
        let box_char    = get(a:opt,    'box',      '*'     )
        let width       = get(a:opt,    'width',    strlen(a:comment) + 2)
        " Build the comment box and put the comment inside it...
        return introducer . repeat(box_char,width)  . "\<CR>"
        \    . introducer . " " . a:comment         . "\<CR>"
        \    . introducer . repeat(box_char,width) . "\<CR>"
    endfunction

In this version of the function, only two arguments are passed: the
essential comment text, followed by a dictionary of options. The
built-in `get()` function is then used to retrieve each option, or its
default value, if the option was not specified. Calls to the function
then use the named option/ value pairs to configure its behavior. The
implementation of the parameter parsing within the function becomes a
little cleaner, and calls to the function becomes much more readable,
and less error-prone. For example:

    " Comment of required width, with standard delimiter and box character...
    let new_comment = CommentBlock(comment_text, {'width':comment_width})

    " Box comment using ==== to standard line width...
    let new_comment = CommentBlock(comment_text, {'box':'=', 'width':72})


## Refactoring autoalignments ##

In the third part we updated an earlier example function called
`AlignAssignments()`, converting it to use lists to store the text lines
it was modifying. Listing 6 reproduces that updated version of the
function.

    Listing 6. The updated AlignAssignments() function

    function! AlignAssignments ()
        " Patterns needed to locate assignment operators...
        let ASSIGN_OP       = '[-+*/%|&]\?=\@<!=[=~]\@!'
        let ASSIGN_LINE     = '^\(.\{-}\)\s*\(' . ASSIGN_OP . '\)\(.*\)$'

        " Locate block of code to be considered (same indentation, no blanks)...
        let indent_pat = '^' . matchstr(getline('.'), '^\s*') . '\S'
        let firstline = search('^\%('. indent_pat . '\)\@!','bnW') + 1
        let lastline = search('^\%('. indent_pat . '\)\@!', 'nW') - 1
        if lastline < 0
            let lastline = line('$')
        endif
        
        " Decompose lines at assignment operators...
        let lines = []
        for linetext in getline(firstline, lastline)
            let fields = matchlist(linetext, ASSIGN_LINE)
            call add(lines, fields[1:3])
        endfor
        
        " Determine maximal lengths of lvalue and operator...
        let op_lines = filter(copy(lines),'!empty(v:val)')
        let max_lval = max( map(copy(op_lines), 'strlen(v:val[0])') ) + 1
        let max_op = max( map(copy(op_lines), 'strlen(v:val[1])' ) )

        " Recompose lines with operators at the maximum length...
        let linenum = firstline
        for line in lines
            if !empty(line)
                let newline
                \ = printf("%-*s%*s%s", max_lval, line[0], max_op, line[1], line[2])
                call setline(linenum, newline)
            endif
            let linenum += 1
        endfor
    endfunction

This version greatly improved the efficiency of the function, by caching
data rather than reloading it, but it did so at the expense of
maintainability.  Specifically, because it stored the various components
of each line in small three-element arrays, the code is littered with
"magic indexes" (such as `v:val[0]` and `line[1]`) whose names give no
clue as to their purpose.  Dictionaries are tailor-made for solving this
problem, because, like lists, they aggregate data into a single
structure, but, unlike lists, they label each datum with a string,
rather than with a number.  If those strings are selected carefully,
they can make the resulting code much clearer. Instead of magic indexes,
we get meaningful names (such as `v:val.lval` for each line's `lvalue`
and `line.op` for each line's operator).  Rewriting the function using
dictionaries is trivially easy, as Listing 7 demonstrates.

    Listing 7. A further-improved AlignAssignments() function

    function! AlignAssignments ()
        " Patterns needed to locate assignment operators...
        let ASSIGN_OP = '[-+*/%|&]\?=\@<!=[=~]\@!'
        let ASSIGN_LINE = '^\(.\{-}\)\s*\(' . ASSIGN_OP . '\)\(.*\)$'
        
        " Locate block of code to be considered (same indentation, no blanks)...
        let indent_pat = '^' . matchstr(getline('.'), '^\s*') . '\S'
        let firstline = search('^\%('. indent_pat . '\)\@!','bnW') + 1
        let lastline = search('^\%('. indent_pat . '\)\@!', 'nW') - 1
        if lastline < 0
            let lastline = line('$')
        endif
        
        " Decompose lines at assignment operators...
        let lines = []
        for linetext in getline(firstline, lastline)
            let fields = matchlist(linetext, ASSIGN_LINE)
            if len(fields)
                call add(lines, {'lval':fields[1], 'op':fields[2], 'rval':fields[3]})
            else
                call add(lines, {'text':linetext, 'op':''})

            endif
        endfor

        " Determine maximal lengths of lvalue and operator...
        let op_lines = filter(copy(lines),'!empty(v:val.op)')
        let max_lval = max( map(copy(op_lines), 'strlen(v:val.lval)') ) + 1
        let max_op = max( map(copy(op_lines), 'strlen(v:val.op)' ) )
        
        " Recompose lines with operators at the maximum length...
        let linenum = firstline
        for line in lines
            let newline = empty(line.op)
            \ ? line.text
            \ : printf("%-*s%*s%s", max_lval, line.lval, max_op, line.op, line.rval)
            call setline(linenum, newline)
            let linenum += 1
        endfor
    endfunction

The differences in this new version are marked in bold. There are only
two: the record for each line is now a dictionary rather than a hash,
and the subsequent accesses to elements of each record use named lookups
instead of numeric indexing. The overall result is that the code is more
readable and less prone to the kinds of off-by-one errors common to
array indexing.


## Dictionaries as data structures ##

Vim provides a built-in command that allows you to remove duplicate
lines from a file:

    :%sort u

The `u` option causes the built-in `sort` command to remove duplicate
lines (once they've been sorted), and the leading `%` applies that
special sort to the entire file.  That's handy, but only if you don't
care about preserving the original order of the unique lines in the
file. This might be a problem if the lines are a list of prize winners,
a sign-up sheet for a finite resource, a to-do list, or any other
sequence in which first-in should remain best-dressed.


### Sort-free uniqueness ###

The keys of a dictionary are inherently unique, so it's possible to use
a dictionary to remove duplicate lines from a file, and to do so in a
way that preserves the original ordering of those lines.  Listing 8
illustrates a simple function that achieves this goal.

    Listing 8. A function for order-preserving uniqueness

    function! Uniq () range
        " Nothing unique seen yet...
        let have_already_seen = {}
        let unique_lines = []
        
        " Walk through the lines, remembering only the hitherto-unseen ones...
        for original_line in getline(a:firstline, a:lastline)
            let normalized_line = '>' . original_line
            if !has_key(have_already_seen, normalized_line)
                call add(unique_lines, original_line)
                let have_already_seen[normalized_line] = 1
            endif
        endfor
        
        " Replace the range of original lines with just the unique lines...
        exec a:firstline . ',' . a:lastline . 'delete'
        call append(a:firstline-1, unique_lines)
    endfunction

The `Uniq()` function is declared to take a range, so it will only be
called once, even when invoked on a range of lines in the buffer.

When called, it first sets up an empty dictionary (`have_already_seen`)
that will be used to track which lines have already been encountered
within the specified range.  Lines that haven't been seen before will
then be added to the list stored in `unique_lines`.

The function then provides a loop that does precisely that. It grabs the
specified range of lines from the buffer with a `getline()` and iterates
through each. It first adds a leading '`>`'to each line to ensure it is
not empty. Vimscript dictionaries cannot store an entry whose key is an
empty string, so empty lines from the buffer would not be correctly
added to `have_already_seen`.

Once the line is normalized, the function then checks whether that line
has already been used as a key in the `have_already_seen` dictionary. If
so, an identical line must already have been seen and added to
`unique_lines`, so the copy can be ignored. Otherwise, the line is being
encountered for the first time, so the original (un-normalized) line
must be added to `unique_lines`, and the normalized version must be
added as a key in `have_already_seen`.

When all the lines have been filtered in this way, `unique_lines` will
contain only the unique subset of them, in the order in which they were
first encountered. All that remains is to delete the original set of
lines and replace it (via an `append()`) with these accumulated unique
lines.  With such a function available, you could set up a Normal-mode
keymap to invoke the command on entire files, like so:

    nmap ;u :%call Uniq()<CR>
    
Or you could apply it to a specific set of lines (for example, a range
that had been selected in Visual mode), like so:

    vmap u :call Uniq()<CR>


## Looking ahead ##

The basic features of Vimscript covered so far (statements and
functions, arrays, and hashes) are sufficient to create almost any kind
of addition to Vim's core feature set. But all the extensions we have
seen have required the user to explicitly request behavior, by issuing a
Normal-mode command or typing a particular sequence in Insert mode.  In
the next part we'll investigate Vim's built-in event model and explore
how to set up user-defined functions that trigger automatically as the
user edits.


# Event-driven scripting and automation #

## Automate your workflow with Vim’s autocommands ##

Why repeat yourself? You can configure Vim’s comprehensive event model
to execute time-saving scripts whenever particular editing events—such
as loading a file or switching between editor modes—occur. This part
describes how events work in Vim, explores a selection of useful event
types, and then gets you started with attaching specific scripts to
particular events. The end result is a more automated workflow
configured precisely to your needs.

## Vim’s event model ##

Vim’s editing functions behave as if they are event-driven. For
performance reasons, the actual implementation is more complex than
that, with much of the event handling optimized away or handled several
layers below the event loop itself, but you can still think of the
editor as a simple while loop responding to a series of editing events.

Whenever you start a Vim session, open a file, edit a buffer, change
your editing mode, switch windows, or interact with the surrounding
filesystem, you are effectively queuing an event that Vim immediately
receives and handles.

For example, if you start Vim, edit a file named demo.txt, swap into
Insert mode, type in some text, save the file, and then exit, your Vim
session receives a series of events like what is shown in Listing 1.

    Listing 1. Event sequence in a simple Vim editing session

    > vim
        BufWinEnter         (create a default window)
        ufEnter             (create a default buffer)
        VimEnter            (start the Vim session):edit example.txt
        BufNew              (create a new buffer to contain demo.txt)
        BufAdd              (add that new buffer to the session’s buffer list)
        BufLeave            (exit the default buffer)
        BufWinLeave         (exit the default window)
        BufUnload           (remove the default buffer from the buffer list)
        BufDelete           (deallocate the default buffer)
        BufReadCmd          (read the contexts of demo.txt into the new buffer)
        BufEnter            (activate the new buffer)
        BufWinEnter         (activate the new buffer's window)i
        InsertEnter         (swap into Insert mode)
    Hello                   
        CursorMovedI        (insert a character)
        CursorMovedI        (insert a character)
        CursorMovedI        (insert a character)
        CursorMovedI        (insert a character)
        CursorMovedI        (insert a character)<ESC>
        InsertLeave         (swap back to Normal mode):wq
        BufWriteCmd         (save the buffer contents back to disk)
        BufWinLeave         (exit the buffer's window)
        BufUnload           (remove the buffer from the buffer list)
        VimLeavePre         (get ready to quit Vim)
        VimLeave            (quit Vim)                                          

More interestingly, Vim provides "hooks" that allow you to intercept any
of these editing events.  So you can cause a particular Vimscript
command or function to be executed every time a specific event occurs:
every time Vim starts, every time a file is loaded, every time you leave
Insert mode ... or even every time you move the cursor. This makes it
possible to add automatic behaviors almost anywhere throughout the
editor.

Vim provides notifications for 78 distinct editing events, which fall
into eight broad categories: session start-up and clean-up events,
file-reading events, file-writing events, buffer-change events,
option-setting events, window-related events, user-interaction events,
and asynchronous notifications.

To see the complete list of these events, type `:help autocmd-events` on
the Vim command line.  For detailed descriptions of each event, see
:help autocmd-events-abc .

This part explains how events work in Vim and then introduces a series
of scripts for automating editing events and behaviours.


## Event handling with autocommands ##

The mechanism Vim provides for intercepting events is known as the
autocommand. Each autocommand specifies the type of event to be
intercepted, the name of the edited file in which such events are to be
intercepted, and the command-line mode action to be taken when the event
is detected. The keyword for all this is autocmd (which is often
abbreviated to just `au`). The usual syntax is:

    autocmd EventName   filename_pattern    :command

The event name is one of the 78 valid Vim event names (as listed under
`:help autocmd-events`).  The filename pattern syntax is similar -- but
not identical -- to a normal shell pattern (see `:help autocmd-patterns`
for details). The command is any valid Vim command, including calls to
Vimscript functions. The colon at the start of the command is optional,
but it’s a good idea to include it; doing so makes the command easier to
locate in the (usually complex) argument list of an `autocmd`.

For example, you could surrender all remaining dignity and specify an
event handler for the FocusGained event by adding the following to your
.vimrc file:

    autocmd FocusGained *.txt   :echo 'Welcome back, ' . $USER . '! You look great!'

`FocusGained` events are queued whenever a Vim window becomes the window
system’s input focus, so now whenever you swap back to your Vim session,
if you’re editing any file whose name matches the filename pattern
`*.txt`, then Vim will automatically execute the specified echo command.

You can set up as many handlers for the same event as you wish, and all
of them will be executed in the sequence in which they were originally
specified. For example, a far more useful automation for `FocusGained`
events might be to have Vim briefly emphasize the cursor line whenever
you swap back to your editing session, as shown in Listing 2.

    Listing 2. A useful automation for FocusGained events

    autocmd  FocusGained  *.txt  :set cursorline
    autocmd  FocusGained  *.txt  :redraw
    autocmd  FocusGained  *.txt  :sleep 1
    autocmd  FocusGained  *.txt  :set nocursorline

These four autocommands cause Vim to automatically highlight the line
containing the cursor (`set cursorline`), reveal that highlighting
(`redraw`), wait one second (`sleep 1`), and then switch the
highlighting back off (`set nocursorline`).

You can use any series of commands in this way; you can even break up a
single control structure across multiple autocommands. For example, you
could set up a global variable (`g:autosave_on_focus_change`) to control
an "autosave" mechanism that automatically writes any modified .txt file
whenever the user swaps away from Vim to some other window (causing a
`FocusLost` event to be queued):

    Listing 3. Autocommand to autosave when leaving an editor window

    autocmd FocusLost   *.txt   :   if &modified && g:autosave_on_focus_change
    autocmd FocusLost   *.txt   :   write
    autocmd FocusLost   *.txt   :   echo "Autosaved file while you were absent"
    autocmd FocusLost   *.txt   :   endif

Multi-line autocommands like this require that you repeat the essential
event-selector specification (i.e., `FocusLost *.txt`) multiple times.
Hence they are generally unpleasant to maintain, and more error-prone.
It’s much cleaner and safer to factor out any control structure, or
other command sequences, into a separate function and then have a single
autocommand call that function. For example:

    Listing 4. A cleaner way to handle multi-line autocommands

    function! Highlight_cursor ()
        set cursorline
        redraw
        sleep 1
        set nocursorline
    endfunction
    function! Autosave ()
        if &modified && g:autosave_on_focus_change
            write
            echo "Autosaved file while you were absent"
        endif
    endfunction

    autocmd FocusGained *.txt   :call Highlight_cursor() 
    autocmd FocusLost   *.txt   :call Autosave()

## Universal and single-file autocommands ##

So far, all the examples shown have restricted event handling to files
that matched the pattern `*.txt`. Obviously, that implies that you can
use any file-globbing pattern to specify the files to which a particular
autocommand applies. For example, you could make the previous
cursor-highlighting `FocusGained` autocommand apply to any file simply
by using the universal file-matching pattern `*` as the filename filter:

    " Cursor-highlight any file when context-switching ...
    autocmd FocusGained *   :call Highlight_cursor()

Alternatively, you can restrict commands to a single file:

    " Only cursor-highlight for my .vimrc ...
    autocmd FocusGained ~/.vimrc    :call Highlight_cursor()

Note that this also implies that you can specify different behaviors for
the same event, depending on which file is being edited. For example,
when the user turns their attention elsewhere, you might choose to have
text files autosaved, or have Perl or Python scripts check-pointed,
while a documentation file might be instructed to reformat the current
paragraph, as shown in Listing 5.

    Listing 5. What to do when the user’s attention is elsewhere

    autocmd FocusLost   *.txt   :call Autosave()
    autocmd FocusLost   *.p[ly] :call Checkpoint_sourcecode()
    autocmd FocusLost   *.doc   :call Reformat_current_para()

## Autocommand groups ##

Autocommands have an associated namespace mechanism that allows them to
be gathered into autocommand groups, whence they can be manipulated
collectively.

To specify an autocommand group, you can use the `augroup` command. The
general syntax for the command is:

    augroup GROUPNAME
        " autocommand specifications here ...
    augroup END

The group’s name can be any series of non-whitespace characters, except
"`end`"or "`END`”, which are reserved for specifying the end of a group.

Within an autocommand group, you can place any number of autocommands.
Typically, you would group commands by the event they all respond to, as
shown in Listing 6.

    Listing 6. Defining a group for autocommands responding to FocusLost events

    augroup Defocus
        autocmd FocusLost   *.txt   :call Autosave()
        autocmd FocusLost   *.p[ly] :call Checkpoint_sourcecode()
        autocmd FocusLost   *.doc   :call Reformat_current_para()
    augroup END

Or you might group a series of autocommands relating to a single
filetype, such as:

    Listing 7. Defining a group of autocommands for handling text files

    augroup TextEvents
        autocmd FocusGained
        autocmd FocusLost
    augroup END


## Deactivating autocommands ##

You can remove specific event handlers using the `autocmd!` command
(that is, with an exclamation mark). The general syntax for this command
is:

    autocmd!    [group] [EventName [filename_pattern]]

To remove a single event handler, specify all three arguments. For
example, to remove the handler for `FocusLost` events on `.txt` files
from the Unfocussed group, use:

    autocmd!    Unfocussed  FocusLost   *.txt

Instead of a specific event name, you can use an asterisk to indicate
that every kind of event should be removed for the particular group and
filename pattern. If you wanted to remove all events for `.txt` files
within the Unfocussed group, you would use:

    autocmd!    Unfocussed  *   *.txt

If you leave off the filename pattern, then every handler for the
specified event type is removed.  You could remove all the `FocusLost`
handlers in the `Unfocussed` group like so:

    autocmd!    Unfocussed  FocusLost

If you also leave out the event name, then every event handler in the
specified group is removed.  So, to turn off all event handling
specified in the Unfocussed group:

    autocmd!    Unfocussed

Finally, if you omit the group name, the autocommand removal applies to
the currently active group. The typical use of this option is to "clear
the decks" within a group before setting up a series of autocommands.
For example, the `Unfocussed` group is better specified like so:

    Listing 8. Making sure a group is empty before adding new autocommands

    augroup Unfocussed
        autocmd!

        autocmd FocusLost   *.txt   :call Autosave()
        autocmd FocusLost   *.p[ly] :call Checkpoint_sourcecode()
        autocmd FocusLost   *.doc   :call Reformat_current_para()
    augroup END

Adding an `autocmd!` to the start of every group is important because
autocommands do not statically declare event handlers; they dynamically
create them. If you execute the same `autocmd` twice, you get two event
handlers, both of which will be separately invoked by the same
combination of event and filename from that point onward. By starting
each autocommand group with an `autocmd!`, you wipe out any existing
handlers within the group so that subsequent `autocmd` statements
replace any existing handlers, rather than augmenting them.  This, in
turn, means that your script can be executed as many times as necessary
(or your .vimrc can be source ’d repeatedly) without multiplying
event-handling entities unnecessarily.


## Some practical examples ##

The appropriate use of autocommands can make your editing life vastly
easier. Let’s look at a few ways you can use autocommands to streamline
your editing process and remove existing frustrations.


###  Managing simultaneous edits ##

One of the most useful features of Vim is that it automatically detects
when you attempt to edit a file that is currently being edited by some
other instance of Vim.  That often happens in multi-window environments,
where you’re already editing a file in another terminal; or in
multi-user setups, where someone else is already working on a shared
file. When Vim detects a second attempt to edit a particular file, you
get the following request:

    Swap file ".filename.swp" already exists!  [O]pen Read-Only, (E)dit
    anyway, (R)ecover, (Q)uit, (A)bort: _

Depending on the environment in which you’re working, your fingers
probably automatically hit one of those options every time, without much
conscious thought on your part. For example, if you rarely work on
shared files, you probably just hit *q* to terminate the session, and
then go hunting for the terminal window where you’re already editing the
file. On the other hand, if you typically edit shared resources, perhaps
your fingers are trained to immediately hit *<ENTER>*, in order to
select the default option and open the file read-only.

With autocommands, however, you can completely eliminate the need to
see, recognize, and respond to that message, simply by automating the
response to the `SwapExists` event that triggers it. For example, if you
never want to edit files that are already being edited elsewhere, you
could add the following to your .vimrc:

    Listing 9. Automatically quitting on simultaneous edits

    augroup NoSimultaneousEdits
        autocmd!
        autocmd SwapExists * :let v:swapchoice = 'q'
    augroup END

This sets up an autocommand group, and removes any previous handlers
(via the `autocmd!` command). It then installs a handler for the
`SwapExists` event on any file (using the universal file pattern: `*`).
That handler simply assigns the response `'q'` to the special
`v:swapchoice` variable.  Vim consults this variable prior to displaying
the `"swapfile exists"` message. If the variable has been set, it uses
the value as the automatic response and doesn’t bother showing the
message.  So now you’ll never see the `swapfile` message; your Vim
session will just automatically quit if you try to edit a file that’s
being edited elsewhere.

Alternately, if you’d prefer always to open already edited files in
read-only mode, you can simply change the `NoSimultaneousEdits` group
to:

    Listing 10. Automating read-only access to existing files

    augroup NoSimultaneousEdits
        autocmd!
        autocmd SwapExists * :let v:swapchoice = 'o'
    augroup END

More interestingly, you could arrange to select between these two (or
any other) alternatives, based on the location of the file being
considered. For example, you might prefer to auto-quit files in your own
subdirectories, but open shared files under `/dev/shared/` as read-only.
You could do that with the following:

    Listing 11. Automating a context-sensitive response

    augroup NoSimultaneousEdits
        autocmd!
        autocmd SwapExists ~/*              :let v:swapchoice = 'q'
        autocmd SwapExists /dev/shared/*    :let v:swapchoice = 'o'
    augroup END

That is: if the full filename begins with the home directory, followed
by anything at all (`~/*`), then preselect the "quit" behaviour; but if
the full filename starts with the shared directory (`/dev/shared/*`),
then preselect the "read-only" behaviour instead.


### Autoformatting code consistently ###

Vim has good support for automatic edit-time code layout (see `:help
indent.txt` and `:help filter`). For example, you can turn on the
`'autoindent'` and `'smartindent'` options and have Vim re-indent your
code blocks automatically as you type. Or you can hook your own
language-specific code reformatter to the standard `=` command by
setting the `'equalprg'` option.

Unfortunately, Vim doesn’t have an option or a command to deal with one
of the commonest code-formatting situations: being forced to read
someone else’s abysmally malformatted code.  Specifically, there’s no
built-in option to tell Vim to automatically sanitize the formatting of
any code file you open.

That's okay because it’s trivially easy to set up an autocommand to do
that instead.

For example, you could add the following autocommand group to your
`.vimrc`, so that C, Python, Perl, and XML files are automatically run
through the appropriate code formatter whenever you open a file of the
corresponding type, as shown in Listing 12.

    Listing 12. Beautiful code, on autocommand

    augroup CodeFormatters
        autocmd!

        autocmd BufReadPost,FileReadPost    *.py    :silent %!PythonTidy.py
        autocmd BufReadPost,FileReadPost    *.p[lm] :silent %!perltidy -q
        autocmd BufReadPost,FileReadPost    *.xml   :silent %!xmlpp –t –c –n
        autocmd BufReadPost,FileReadPost    *.[ch]  :silent %!indent
    augroup END

All of the autocommands in the group are identical in structure,
differing only in the filename extensions to which they apply and the
corresponding pretty-printer they invoke.

Note that the autocommands do not name a single event to be handled.
Instead, each one specifies a list of events. Any autocmd can be
specified with a comma-separated list of event types, in which case the
handler will be invoked for any of the events listed.  In this case, the
events listed for each handler are `BufReadPost` (which is queued
whenever an existing file is loaded into a new buffer) and
`FileReadPost` (which is queued immediately after any `:read` command is
executed). These two events are often specified together because between
them they cover the most common ways of loading the contents of an
existing file into a buffer.

After the event list, each autocommand specifies the file suffix(es) to
which it applies: Python’s `.py`, Perl’s `.pl` and `.pm`, XML’s `.xml`,
or the `.c` and `.h` files of C.  Note that, as with events, these
filename patterns could also have been specified as a comma-separated
list, rather than a single pattern. For example, the Perl handler could
have been written:

    autocmd BufReadPost,FileReadPost    *.pl,*.pm   :silent %!perltidy -q

or the C handler could be extended to handle common C++ variants (`.C`,
`.cc`, `.cxx`, etc.) as well, like so:

    autocmd BufReadPost,FileReadPost *.[chCH],*.cc,*.hh,*.[ch]xx :silent %!indent

As usual, the final component of each autocommand is the command to be
executed. In each case, it is a global filter command
(`%!filter_program`), which takes the entire contents of the file (`%`)
and pipes it out (`!`) to the specified external program (one of:
`PythonTidy.py`, `perltidy`, `xmlpp`, or `indent`). The output of each
program is then pasted back into the buffer, replacing the original
contents.

Normally, when filter commands like these are used, Vim automatically
displays a notification after the command completes, like so:

    42 lines filtered
    Press ENTER or type command to continue_

To prevent this annoyance, each of the autocommands prefixes its action
with a `:silent`, which neutralizes any ordinary information messages,
but still allows error messages to be displayed.


### Opportunistic code autoformatting ###

Vim has excellent support for automatically formatting C code as you
type it, but it offers less support for other languages. That’s not
entirely Vim’s fault; some languages -- yes, Perl, I’m looking at you --
can be extremely hard to format correctly on the fly.

If Vim doesn't give you adequate support for autoformatting source code
in your preferred language, you can easily have your editor invoke an
external utility to do that for you.

The simplest approach is to make use of the `'InsertLeave` event. This
event is queued whenever you exit from `Insert` mode (most commonly,
immediately after you hit `<ESC>`). You can easily set up a handler that
reformats your code every time you finish adding to it, like so:

    Listing 13. Invoking PerlTidy after every edit

    function! TidyAndResetCursor ()
        let cursor_pos = getpos('.')
        %!perltidy -q
        call setpos('.', cursor_pos)
    endfunction

    augroup PerlTidy
        autocmd!
        autocmd InsertLeave *.p[lm] :call TidyAndResetCursor()
    augroup END

The `TidyAndResetCursor()` function first makes a record of the current
cursor position, by storing the cursor information returned by the
built-in `getpos()` in the variable `cursor_pos`. It then runs the
external `perltidy` utility over the entire file (`%!perltidy -q`), and
finally restores the cursor to its original position, by passing the
saved cursor information to the built-in `setpos()` function.

Inside the `PerlTidy` group, you then just set up a single autocommand
that calls `TidyAndResetCursor()` every time the user leaves `Insert`
mode within any Perl file.  This same code pattern could be adapted to
perform any appropriate action each time you insert text. For example,
if you were working on a very unreliable system and wished to maximize
your ability to recover files (see `:help usr_11.txt`) if something went
wrong, you could arrange for Vim to update its swap-file every time you
left `Insert` mode, like so:

    augroup UpdateSwap
        autocmd!
        autocmd InsertLeave
    augroup END


### Timestamping files ###

Another useful set of events are `BufWritePre`, `FileWritePre`, and
`FileAppendPre`. These "`Pre`" events are queued just before your Vim
session writes a buffer back to disk (as a result of a command such as
`:write`, `:update`, or `:saveas`). A `BufWritePre` event occurs just
before the entire buffer is written, a `FileWritePre` occurs just before
part of a buffer is written (that is, when you specify a range of lines
to be written: `:1,10write`). A `FileAppendPre` occurs just before a
`:write` command is used to append rather than replace; for example:

    :write >> logfile.log).
    
For all three types of events, Vim sets the special line-number aliases
`'[` and `']` to the range of lines being written. These aliases can
then be used in the range specifier of any subsequent command, to ensure
that autocommand actions are applied only to the relevant lines.

Typically, you would set up a single handler that covered all three
types of pre-writing event. For example, you could have Vim
automatically update an internal timestamp whenever a file was written
(or appended) to disk, as shown in Listing 14.

    Listing 14. Automatically updating an internal timestamp whenever
                a file is saved

    function! UpdateTimestamp ()
        '[,']s/^This file last updated: \zs.*/\= strftime("%c") /
    endfunction

    augroup TimeStamping
        autocmd!
        autocmd BufWritePre,FileWritePre,FileAppendPre * :call UpdateTimestamp()
    augroup END

The `UpdateTimestamp()` function performs a substitution (`s/.../.../`)
on every line being written, by specifically limiting the range of the
substitution to between `'[` and `']` like so: `'[,']s/.../.../`. The
substitution looks for lines starting with `"This file last updated:”`,
followed by anything (`.*`). The `\zs` before the `.*` causes the
substitution to pretend that the match only started after the colon, so
only the actual timestamp is replaced.

To update the timestamp, the substitution uses the special `\=` escape
sequence in the replacement text. This escape sequence tells Vim to
treat the replacement text as a Vimscript expression, evaluating it to
get the actual replacement string. In this case, that expression is a
call to the built-in `strftime()` function, which returns a standard
timestamp string of the form: `"Fri Oct 23 14:51:01 2009"`. This string
is then written back into the timestamp line by the `substitution`
command.

All that remains is to set up an event handler (`autocmd`) for all three
event types (`BufWritePre`, `FileWritePre`, `FileAppendPre`) in any file
(`*`) and have it invoke the appropriate timestamping function (`:call
UpdateTimestamp()`). Now, any time a file is written, any timestamp in
the lines being saved will be updated to the current time.

Note that Vim provides two other sets of events that you can use to
modify the behavior of write operations. To automate some action that
should happen after a write, you can use `BufWritePost`,
`FileWritePost`, and `FileAppendPost`. To completely replace the
standard write behavior with your own script, you can use `BufWriteCmd`,
`FileWriteCmd`, and `FileAppendCmd` (but consult `:help Cmd-event` first
for some important caveats).


#### Table-driven timestamps ####

Of course, you could also create much more elaborate mechanisms to
handle files with different timestamping conventions. For example, you
might prefer to specify the various timestamp signatures and their
replacements in a Vim dictionary (see the previous part) and then loop
through each pair to determine how the timestamp should be updated. This
approach is shown in Listing 15.

    Listing 15. Table-driven automatic timestamps

    let s:timestamps = {
    \ 'This file last updated: \zs.*'               :   'strftime("%c")',
    \ 'Last modification: \zs.*'                    :   'strftime("%Y%m%d.%H%M%S")',
    \ 'Copyright (c) .\{-}, \d\d\d\d-\zs\d\d\d\d'   :   'strftime("%Y")',
    \}

    function! UpdateTimestamp ()
        for [signature, replacement] in items(s:timestamps)
            silent! execute "'[,']s/" . signature . '/\= ' . replacement . '/'
        endfor
    endfunction

Here, the for loop iterates through each timestamp’s
signature/replacement pair in the `s:timestamps` dictionary, like so:

    for [signature, replacement] in items(s:timestamps)

It then generates a string containing the corresponding substitution
command. The following substitution command is identical in structure to
the one in the previous example, but is here constructed by
interpolating the signature/replacement pair into a string:

    "'[,']s/" . signature . '/\= ' . replacement . '/'

Finally, it executes the generated command silently:

    silent! execute "'[,']s/" . signature . '/\= ' . replacement . '/'

The use of `silent!` is important because it ensures that any
substitutions that don’t match will not result in the annoying `Pattern
not found` error message.

Note that the last entry in `s:timestamps` is a particularly useful
example: it automatically updates the year-range of any embedded
copyright notices, whenever a file containing them is written.


#### Filename-driven timestamps ####

Instead of listing all possible timestamp formats in a single table, you
might prefer to parameterize the `UpdateTimestamp()` function and then
create a series of distinct autocmds for different filetypes, as shown
in Listing 16.

    Listing 16. Context-sensitive timestaming for different filetypes

    function! UpdateTimestamp (signature, replacement)
        silent! execute "'[,']s/" . a:signature . '/\= ' . a:replacement . '/'
    endfunction

    augroup Timestamping
        autocmd!

        " C header files use one timestamp format ...
        autocmd BufWritePre,FileWritePre,FileAppendPre *.h
        \ :call UpdateTimestamp('This file last updated: \zs.*', 'strftime("%c")')
        " C code files use another ...
        autocmd BufWritePre,FileWritePre,FileAppendPre *.c
        \ :call UpdateTimestamp('Last update: \zs.*', 'strftime("%Y%m%d.%H%M%S")')
    augroup END

In this version, the signature and replacement components are passed
explicitly to `UpdateTimestamp()`, which then generates a string
containing the single corresponding substitution command and executes
it. Within the `Timestamping` group, you then set up individual
autocommands for each required file type, passing the appropriate
timestamp signature and replacement text for each.


### Conjuring directories ###

Autocommands can be useful even before you begin editing. For example,
when you start editing a new file, you will occasionally see a message
like this one:

    "dir/subdir/filename" [New DIRECTORY]

This means that the file you specified (in this case `filename`) does
not exist and that the directory it’s supposed to be in (in this case
`dir/subdir`) doesn’t exist either.

Vim will happily allow you to ignore this warning (many users don’t even
recognize that it is a warning) and continue to edit the file. But when
you try to save it you’ll be confronted with the following unhelpful
error message:

    "dir/subdir/filename" E212: Can't open file for writing.

Now, in order to save your work, you have to explicitly create the
missing directory before writing the file into it. You can do that from
within Vim like so:

    :write
    "dir/subdir/filename" E212: Can't open file for writing.
    :call mkdir(expand("%:h"),"p")
    :write

Here, the call to the built-in `expand()` function is applied to
`"%:h"`, where the `%` means the current filepath (in this case
`dir/subdir/filename`), and the `:h` takes just the "head" of that path,
removing the filename to leave the path of the intended directory
(`dir/subdir`).  The call to Vim’s built-in `mkdir()` then takes this
directory path and creates all the interim directories along it (as
requested by the second argument, `"p"`).

Realistically, though, most Vim users would be more likely to simply
escape to the shell to build the necessary directories. For example:

    :write
    "dir/subdir/filename" E212: Can't open file for writing.
    :! mkdir -p dir/subdir/
    :write

Either way, it’s a hassle. If you’re eventually going to have to create
the missing directory anyway, why not have Vim notice up-front that it
doesn’t exist, and simply create it for you before you even start? That
way, you’ll never encounter the obscure [`New DIRECTORY`] hint; nor will
your workflow be later interrupted by an equally mysterious `E212`
error.

To have Vim take care of prebuilding non-existent directories, you could
hook a handler into the `BufNewFile` event, which is queued whenever you
start to edit a file that does not yet exist. Listing 17 shows the code
you would add to your `.vimrc` file to make this work.

    Listing 17. Unconditionally autocreating non-existent directories

    augroup AutoMkdir
        autocmd!
        autocmd BufNewFile * :call EnsureDirExists()
    augroup END

    function! EnsureDirExists ()
        let required_dir = expand("%:h")
        if !isdirectory(required_dir)
            call mkdir(required_dir, 'p')
        endif
    endfunction

The `AutoMkdir` group sets up a single autocommand for `BufNewFile`
events on any kind of file, calling the `EnsureDirExists()` function
whenever a new file is edited. `EnsureDirExists()` first determines the
directory being requested by expanding the "head" of the current
filepath: `expand("%:h")`. It then uses the built-in `isdirectory()`
function to check whether the requested directory exists. If not, it
attempts to create the directory using Vim’s built-in `mkdir()`.

Note that, if the `mkdir()` call can’t create the requested directory
for any reason, it will produce a slightly more precise and informative
error message:

    E739: Cannot create directory: dir/subdir


### Conjuring directories more carefully ###

The only problem with this solution is that, occasionally, autocreating
non-existent subdirectories is exactly the wrong thing to do. For
example, suppose you requested the following:

    > vim /share/sites/corporate/root/.htaccess

You had intended to create a new access control file in the already
existing subdirectory `/share/corporate/website/root/`. Except, of
course, because you got the path wrong, what you actually did was create
a new access control file in the formerly non-existent subdirectory
`/share/website/corporate/root/`. And because that happened
automatically, with no warnings of any kind, you might not even realize
the mistake. At least, not until the misapplied access control
precipitates some online disaster.

To guard against errors like this, you might prefer that Vim be a little
less helpful in autocreating missing directories. Listing 18 shows a
more elaborate version of `EnsureDirExists()`, which still detects
missing directories but now asks the user what to do about them. Note
that the autocommand set-up is exactly the same as in Listing 17; only
the `EnsureDirExists()` function has changed.

    Listing 18. Conditionally autocreating non-existent directories

    augroup AutoMkdir
        autocmd!
        autocmd BufNewFile * :call EnsureDirExists()
    augroup END

    function! EnsureDirExists ()
        let required_dir = expand("%:h")
        if !isdirectory(required_dir)
            call AskQuit("Directory '" . required_dir .
            \   "' doesn't exist.", "&Create it?")

            try
                call mkdir( required_dir, 'p' )
            catch
                call AskQuit("Can't create '" . required_dir .
                \   "'", "&Continue anyway?")
            endtry
        endif
    endfunction

    function! AskQuit (msg, proposed_action)
        if confirm(a:msg, "&Quit?\n" . a:proposed_action) == 1
            exit
        endif
    endfunction

In this version of the function, `EnsureDirExists()` locates the
required directory and detects whether it exists, exactly as before.
However, if the directory is missing, `EnsureDirExists()` now calls a
helper function:` AskQuit()`. This function uses the built-in
`confirm()` function to inquire whether you want to exit the session or
autocreate the directory.  `"Quit?"` is presented as the first option,
which also makes it the default if you just hit `<ENTER>`.

If you do select the `"Quit?"` option, the helper function immediately
terminates the Vim session.  Otherwise, the helper function simply
returns. In that case, `EnsureDirExists()` continues to execute, and
attempts to call `mkdir()`.

Note, however, that the call to `mkdir()` is now inside a `try...endtry`
construct. This is -- as you might expect -- an exception handler, which
will now catch the `E739` error that is thrown if `mkdir()` is unable to
create the requested directory.

When that error is thrown, the catch block will intercept it and will
call `AskQuit()` again, informing you that the directory could not be
created, and asking whether you still want to continue. For more details
on Vim’s extensive exception handling mechanisms see: `:help
exception-handling`.

The overall effect of this second version of `EnsureDirExists()` is to
highlight the non-existent directory but require you to explicitly
request that it be created (by typing a single *c* when prompted to). If
the directory cannot be created, you are again warned and given the
option of continuing with the session anyway (again, by typing a single
*c* when asked). This also makes it trivially easy to escape from a
mistaken edit (simply by hitting `<ENTER>` to select the default
`"Quit?"` option at either prompt).

Of course, you might prefer that continuing was the default, in which
case, you would just change the first line of `AskQuit()` to:

    if confirm(a:msg, a:proposed_action . "\n&Quit?") == 2

In this case the proposed action would be the first alternative, and
hence the default behaviour.  Note that `"Quit?"` is now the second
alternative, so the response now has to be compared against the value 2.


## Looking ahead ##

Autocommands can save you a great deal of effort and error by automating
repetitive actions that you would otherwise have to perform yourself. A
productive way to get started is to take a mental step back as you edit
and watch for repetitive patterns of usage that might be suitably
automated using Vim’s event-handling mechanisms. Scripting those
patterns into autocommands may require some extra work up front, but the
automated actions will repay your investment every day. By automating
everyday actions you’ll save time and effort, avoid errors, smooth your
workflow, eliminate trivial stressors, and thereby improve your
productivity.

Though your autocommands will probably start out as simple single-line
automations, you may soon find yourself redesigning and elaborating
them, as you think of better ways to have Vim do more of your grunt
work. In this fashion, your event handlers can grow progressively
smarter, safer, and more perfectly adapted to the way you want to work.

As Vim scripts like these become more complex, however, you also will
need better tools to manage them. Adding 10 or 20 lines to your `.vimrc`
every time you devise a clever new keymapping or autocommand will
eventually produce a configuration file that is several thousand lines
long ... and utterly unmaintainable.

So, in the next part we’ll explore Vim’s simple plug-in architecture,
which allows you to factor out parts of your .vimrc and isolate them in
separate modules. We’ll look at how that plug-in system works by
developing a standalone module that ameliorates some of the horrors of
working with XML.


Addictional contents
====================

Keycodes
--------

These names for keys are used in the documentation.  They can also be used
with the ":map" command (insert the key name by pressing CTRL-K and then the
key you want the name for).

-------------------------------------------------------------------------------
notation	        meaning		            equivalent	decimal value(s)	
-----------         -----------------       ----------- -----------------------
`<Nul>`		        zero			        CTRL-@	    0 (stored as 10) 

`<BS>`		        backspace		        CTRL-H	    8	

`<Tab>`		        tab			            CTRL-I	    9	

`<NL>`		        linefeed		        CTRL-J	    10 (used for `<Nul>`)

`<FF>`		        formfeed		        CTRL-L	    12

`<CR>`		        carriage return	        CTRL-M	    13	

`<Return>`	        same as `<CR>`	        			

`<Enter>`		    same as `<CR>`	        			

`<Esc>`		        escape			        CTRL-[	    27	

`<Space>`		    space			        	        32

`<lt>`		        less-than		        <	        60	

`<Bslash>`	        backslash		        \	        92	

`<Bar>`		        vertical bar	        	|	    124	

`<Del>`		        delete			        	        127

`<CSI>`		        command                 ALT-Esc     155	
                    sequence intro

`<xCSI>`		    CSI when typed
                    in the GUI

`<EOL>`		        end-of-line
                    (can be `<CR>`,
                    `<LF>` or
                    `<CR>``<LF>`,
                    depends on
                    system and
                    'fileformat')

`<Up>`		        cursor-up

`<Down>`		    cursor-down			

`<Left>`		    cursor-left		

`<Right>`		    cursor-right

`<S-Up>`		    shift-cursor-up

`<S-Down>`	        shift-cursor-down

`<S-Left>`	        shift-cursor-left

`<S-Right>`	        shift-cursor-right

`<C-Left>`	        control-cursor-left

`<C-Right>`	        control-cursor-right

`<F1>`-`<F12>`	    function keys 1
                    to 12

`<S-F1>-<S-F12>`    shift-function keys
                    1 to 12	

`<Help>`		    help key

`<Undo>`		    undo key

`<Insert>`	        insert key

`<Home>`		    home				       

`<End>`		        end				           

`<PageUp>`	        page-up				       

`<PageDown>`	    page-down			       

`<kHome>`		    keypad home
                    (upper left)   

`<kEnd>`		    keypad end
                    (lower left)	   

`<kPageUp>`	        keypad page-up
                    (upper right)	

`<kPageDown>`	    keypad page-down
                    (lower right)	

`<kPlus>`		    keypad +			

`<kMinus>`	        keypad -			

`<kMultiply>`	    keypad *			

`<kDivide>`	        keypad /			

`<kEnter>`	        keypad Enter		

`<kPoint>`	        keypad Decimal point

`<k0>` - `<k9>`	    keypad 0 to 9		

`<S-...>`		    shift-key			

`<C-...>`		    control-key			

`<M-...>`		    alt-key or meta-key	

`<A-...>`		    same as `<M-...>`		

`<D-...>`		    command-key
                    (Macintosh only)
`<t_xx>`		    key with "xx"
                    entry in termcap
-------------------------------------------------------------------------------

> Note:
>
> The shifted cursor keys, the help key, and the undo key are only
> available on a few terminals.  On the Amiga, shifted function key 10
> produces a code (CSI) that is also used by key sequences.  It will be
> recognized only after typing another key.

> Note:
>
> There are two codes for the delete key.  127 is the decimal ASCII
> value for the delete key, which is always recognized.  Some delete
> keys send another value, in which case this value is obtained from the
> termcap entry "kD".  Both values have the same effect.  Also see
> |:fixdel|.

> Note:
>
> The keypad keys are used in the same way as the corresponding "normal"
> keys.  For example, `<kHome>` has the same effect as `<Home>`.  If a
> keypad key sends the same raw key code as its non-keypad equivalent,
> it will be recognized as the non-keypad code.  For example, when
> `<kHome>` sends the same code as `<Home>`, when pressing `<kHome>` Vim
> will think `<Home>` was pressed.  Mapping `<kHome>` will not work
> then.


Function-list
-------------

There are many functions.  We will mention them here, grouped by what they are
used for. 

String manipulation:

----------------    ----------------------------------------------------
nr2char()		    get a character by its ASCII value
char2nr()		    get ASCII value of a character
str2nr()		    convert a string to a Number
str2float()		    convert a string to a Float
printf()		    format a string according to % items
escape()		    escape characters in a string with a '\'
shellescape()	    escape a string for use with a shell command
fnameescape()	    escape a file name for use with a Vim command
tr()			    translate characters from one set to another
strtrans()		    translate a string to make it printable
tolower()		    turn a string to lowercase
toupper()		    turn a string to uppercase
match()			    position where a pattern matches in a string
matchend()		    position where a pattern match ends in a string
matchstr()		    match of a pattern in a string
matchlist()		    like matchstr() and also return submatches
stridx()		    first index of a short string in a long string
strridx()		    last index of a short string in a long string
strlen()		    length of a string
substitute()	    substitute a pattern match with a string
submatch()		    get a specific match in ":s" and substitute()
strpart()		    get part of a string
expand()		    expand special keywords
iconv()			    convert text from one encoding to another
byteidx()		    byte index of a character in a string
repeat()		    repeat a string multiple times
eval()			    evaluate a string expression
------------------------------------------------------------------------

List manipulation:

-----------     --------------------------------------------------------
get()			get an item without error for wrong index
len()			number of items in a List
empty()			check if List is empty
insert()		insert an item somewhere in a List
add()			append an item to a List
extend()		append a List to a List
remove()		remove one or more items from a List
copy()			make a shallow copy of a List
deepcopy()		make a full copy of a List
filter()		remove selected items from a List
map()			change each List item
sort()			sort a List
reverse()		reverse the order of a List
split()			split a String into a List
join()			join List items into a String
range()			return a List with a sequence of numbers
string()		String representation of a List
call()			call a function with List as arguments
index()			index of a value in a List
max()			maximum value in a List
min()			minimum value in a List
count()			count number of times a value appears in a List
repeat()		repeat a List multiple times
-----------------------------------------------------------------------

Dictionary manipulation:

------------    -------------------------------------------------------
get()			get an entry without an error for a wrong key
len()			number of entries in a Dictionary
has_key()		check whether a key appears in a Dictionary
empty()			check if Dictionary is empty
remove()		remove an entry from a Dictionary
extend()		add entries from one Dictionary to another
filter()		remove selected entries from a Dictionary
map()			change each Dictionary entry
keys()			get List of Dictionary keys
values()		get List of Dictionary values
items()			get List of Dictionary key-value pairs
copy()			make a shallow copy of a Dictionary
deepcopy()		make a full copy of a Dictionary
string()		String representation of a Dictionary
max()			maximum value in a Dictionary
min()			minimum value in a Dictionary
count()			count number of times a value appears
-----------------------------------------------------------------------

Floating point computation:

------------    -------------------------------------------------------
float2nr()		convert Float to Number
abs()			absolute value (also works for Number)
round()			round off
ceil()			round up
floor()			round down
trunc()			remove value after decimal point
log10()			logarithm to base 10
pow()			value of x to the exponent y
sqrt()			square root
sin()			sine
cos()			cosine
tan()			tangent
asin()			arc sine
acos()			arc cosine
atan()			arc tangent
atan2()			arc tangent
sinh()			hyperbolic sine
cosh()			hyperbolic cosine
tanh()			hyperbolic tangent
-----------------------------------------------------------------------

Other computation:

----------      -------------------------------------------------------
and()			bitwise AND
invert()		bitwise invert
or()			bitwise OR
xor()			bitwise XOR
-----------------------------------------------------------------------

Variables:

-------------       ---------------------------------------------------
type()			    type of a variable
islocked()		    check if a variable is locked
function()		    get a Funcref for a function name
getbufvar()		    get a variable value from a specific buffer
setbufvar()		    set a variable in a specific buffer
getwinvar()		    get a variable from specific window
gettabvar()		    get a variable from specific tab page
gettabwinvar()	    get a variable from specific window & tab page
setwinvar()		    set a variable in a specific window
settabvar()		    set a variable in a specific tab page
settabwinvar()	    set a variable in a specific window & tab page
garbagecollect()    possibly free memory
-----------------------------------------------------------------------

Cursor and mark position:

--------------  -------------------------------------------------------
col()			column number of the cursor or a mark
virtcol()		screen column of the cursor or a mark
line()			line number of the cursor or mark
wincol()		window column number of the cursor
winline()		window line number of the cursor
cursor()		position the cursor at a line/column
getpos()		get position of cursor, mark, etc.
setpos()		set position of cursor, mark, etc.
byte2line()		get line number at a specific byte count
line2byte()		byte count at a specific line
diff_filler()	get the number of filler lines above a line
-----------------------------------------------------------------------

Working with text in the current buffer:

----------------    ---------------------------------------------------
getline()		    get a line or list of lines from the buffer
setline()		    replace a line in the buffer
append()		    append line or list of lines in the buffer
indent()		    indent of a specific line
cindent()		    indent according to C indenting
lispindent()	    indent according to Lisp indenting
nextnonblank()	    find next non-blank line
prevnonblank()	    find previous non-blank line
search()		    find a match for a pattern
searchpos()		    find a match for a pattern
searchpair()	    find the other end of a start/skip/end
searchpairpos()	    find the other end of a start/skip/end
searchdecl()	    search for the declaration of a name
-----------------------------------------------------------------------

System functions and manipulation of files:

-----------------   ---------------------------------------------------
glob()			    expand wildcards
globpath()		    expand wildcards in a number of directories
findfile()		    find a file in a list of directories
finddir()		    find a directory in a list of directories
resolve()		    find out where a shortcut points to
fnamemodify()	    modify a file name
pathshorten()	    shorten directory names in a path
simplify()		    simplify a path without changing its meaning
executable()	    check if an executable program exists
filereadable()	    check if a file can be read
filewritable()	    check if a file can be written to
getfperm()		    get the permissions of a file
getftype()		    get the kind of a file
isdirectory()	    check if a directory exists
getfsize()		    get the size of a file
getcwd()		    get the current working directory
haslocaldir()	    check if current window used |:lcd|
tempname()		    get the name of a temporary file
mkdir()			    create a new directory
delete()		    delete a file
rename()		    rename a file
system()		    get the result of a shell command
hostname()		    name of the system
readfile()		    read a file into a List of lines
writefile()		    write a List of lines into a file
-----------------------------------------------------------------------

Date and Time:

--------------  -------------------------------------------------------
getftime()		get last modification time of a file
localtime()		get current time in seconds
strftime()		convert time to a string
reltime()		get the current or elapsed time accurately
reltimestr()	convert reltime() result to a string
-----------------------------------------------------------------------

Buffers, windows and the argument list:

-----------------   ---------------------------------------------------
argc()			    number of entries in the argument list
argidx()		    current position in the argument list
argv()			    get one entry from the argument list
bufexists()		    check if a buffer exists
buflisted()		    check if a buffer exists and is listed
bufloaded()		    check if a buffer exists and is loaded
bufname()		    get the name of a specific buffer
bufnr()			    get the buffer number of a specific buffer
tabpagebuflist()    return List of buffers in a tab page
tabpagenr()		    get the number of a tab page
tabpagewinnr()	    like winnr() for a specified tab page
winnr()			    get the window number for the current window
bufwinnr()		    get the window number of a specific buffer
winbufnr()		    get the buffer number of a specific window
getbufline()	    get a list of lines from the specified buffer
-----------------------------------------------------------------------

Command line:

--------------  -------------------------------------------------------
getcmdline()	get the current command line
getcmdpos()		get position of the cursor in the command line
setcmdpos()		set position of the cursor in the command line
getcmdtype()	return the current command-line type
-----------------------------------------------------------------------

Quickfix and location lists:

-------------   -------------------------------------------------------
getqflist()		list of quickfix errors
setqflist()		modify a quickfix list
getloclist()	list of location list items
setloclist()	modify a location list
-----------------------------------------------------------------------

Insert mode completion:

-----------------   ---------------------------------------------------
complete()		    set found matches
complete_add()		add to found matches
complete_check()	check if completion should be aborted
pumvisible()		check if the popup menu is displayed
-----------------------------------------------------------------------

Folding:

------------------  ---------------------------------------------------
foldclosed()		check for a closed fold at a specific line
foldclosedend()		like foldclosed() but return the last line
foldlevel()		    check for the fold level at a specific line
foldtext()		    generate the line displayed for a closed fold
foldtextresult()	get the text displayed for a closed fold
-----------------------------------------------------------------------

Syntax and highlighting:

------------------  ---------------------------------------------------
clearmatches()		clear all matches defined by matchadd() and
			        the :match commands

getmatches()		get all matches defined by matchadd() and
			        the :match commands
                    
hlexists()		    check if a highlight group exists

hlID()			    get ID of a highlight group

synID()			    get syntax ID at a specific position

synIDattr()		    get a specific attribute of a syntax ID

synIDtrans()	    get translated syntax ID

synstack()		    get list of syntax IDs at a specific position

synconcealed()	    get info about concealing

diff_hlID()		    get highlight ID for diff mode at a position

matchadd()		    define a pattern to highlight (a "match")

matcharg()		    get info about :match arguments

matchdelete()	    delete a match defined by matchadd() or a
			        :match command

setmatches()		restore a list of matches saved by
			        getmatches()
-----------------------------------------------------------------------

Spelling:

--------------  -------------------------------------------------------
spellbadword()	locate badly spelled word at or after cursor
spellsuggest()	return suggested spelling corrections
soundfold()		return the sound-a-like equivalent of a word
-----------------------------------------------------------------------

History:

------------    -------------------------------------------------------
histadd()		add an item to a history
histdel()		delete an item from a history
histget()		get an item from a history
histnr()		get highest index of a history list
-----------------------------------------------------------------------

Interactive:

--------------  -------------------------------------------------------
browse()		put up a file requester
browsedir()		put up a directory requester
confirm()		let the user make a choice
getchar()		get a character from the user
getcharmod()	get modifiers for the last typed character
feedkeys()		put characters in the typeahead queue
input()			get a line from the user
inputlist()		let the user pick an entry from a list
inputsecret()	get a line from the user without showing it
inputdialog()	get a line from the user in a dialog
inputsave()		save and clear typeahead
inputrestore()	restore typeahead
-----------------------------------------------------------------------

GUI:

------------------  ---------------------------------------------------
getfontname()		get name of current font being used
getwinposx()		X position of the GUI Vim window
getwinposy()		Y position of the GUI Vim window
-----------------------------------------------------------------------

Vim server:

------------------- ---------------------------------------------------
serverlist()		return the list of server names
remote_send()		send command characters to a Vim server
remote_expr()		evaluate an expression in a Vim server
server2client()		send a reply to a client of a Vim server
remote_peek()		check if there is a reply from a Vim server
remote_read()		read a reply from a Vim server
foreground()		move the Vim window to the foreground
remote_foreground()	move the Vim server window to the foreground
-----------------------------------------------------------------------

Window size and position:

--------------  -------------------------------------------------------
winheight()		get height of a specific window
winwidth()		get width of a specific window
winrestcmd()	return command to restore window sizes
winsaveview()	get view of current window
winrestview()	restore saved view of current window
-----------------------------------------------------------------------

Mappings:

--------------  -------------------------------------------------------
hasmapto()		check if a mapping exists
mapcheck()		check if a matching mapping exists
maparg()		get rhs of a mapping
wildmenumode()	check if the wildmode is active
-----------------------------------------------------------------------

Various:

------------------- ---------------------------------------------------
mode()			    get current editing mode
visualmode()	    last visual mode used
exists()		    check if a variable, function, etc. exists
has()			    check if a feature is supported in Vim
changenr()		    return number of most recent change
cscope_connection()	check if a cscope connection exists
did_filetype()		check if a FileType autocommand was used
eventhandler()		check if invoked by an event handler
getpid()		    get process ID of Vim
libcall()		    call a function in an external library
libcallnr()		    idem, returning a number
getreg()		    get contents of a register
getregtype()	    get type of a register
setreg()		    set contents and type of a register
taglist()		    get list of matching tags
tagfiles()		    get a list of tags files
mzeval()		    evaluate MzScheme expression
-----------------------------------------------------------------------


Command-line ranges
-------------------

Some Ex commands accept a line range in front of them.  This is noted as
`[range]`.  It consists of one or more line specifiers, separated with
`','` or `';'`.

The basics are explained in section `10.3` of the user manual.

When separated with `';'` the cursor position will be set to that line
before interpreting the next line specifier.  This doesn't happen for
`','`.

Examples:

    4,/this line/
    " from line 4 till match with "this line" after the cursor line.
    
    5;/that line/
    " from line 5 till match with "that line" after line 5.

The default line specifier for most commands is the cursor position, but
the commands `":write"` and `":global"` have the whole file (`1,$`) as
default.

If more line specifiers are given than required for the command, the
first one(s) will be ignored.

Line numbers may be specified with:

--------------  -------------------------------------------------------
`{number}`      an absolute line number

`.`		        the current line

`$`		        the last line in the file

`%`		        equal to 1,$ (the entire file)

`'t`		    position of mark t (lowercase)

`'T`	        position of mark T (uppercase); when the mark is in
		        another file it cannot be used in a range

`/{pattern}[/]` the next line where {pattern} matches

`?{pattern}[?]` the previous line where {pattern} matches

`\/`		    the next line where the previously used search
		        pattern matches

`\?`	        the previous line where the previously used search
		        pattern matches

`\&`	        the next line where the previously used substitute
		        pattern matches
----------------------------------------------------------------------

Each may be followed (several times) by `'+'` or `'-'` and an optional
number.  This number is added or subtracted from the preceding line
number.  If the number is omitted, 1 is used.

The `"/"` and `"?"` after {pattern} are required to separate the pattern
from anything that follows.

The `"/"` and `"?"` may be preceded with another address.  The search
starts from there.  The difference from using `';'` is that the cursor
isn't moved.

Examples:

	/pat1//pat2/    " Find line containing "pat2" after line containing
                    " pat1", without moving the cursor.
	7;/pat2/	    " Find line containing "pat2", after line 7, leaving
			        " the cursor in line 7.

The `{number}` must be between 0 and the number of lines in the file.
When using a 0 (zero) this is interpreted as a 1 by most commands.
Commands that use it as a count do use it as a zero (`:tag`, `:pop`,
etc).  Some commands interpret the zero as "before the first line"
(`:read`, search pattern, etc).

Examples:

	.+3         " three lines below the cursor
	/that/+1	" the line below the next line containing "that"
	.,$		    " from current line until end of file
	0;/that		" the first line containing "that", also matches in the
			    " first line.
	1;/that		" the first line after line 1 containing "that"

Some commands allow for a count after the command.  This count is used
as the number of lines to be used, starting with the line given in the
last line specifier (the default is the cursor line).  The commands that
accept a count are the ones that use a range but do not have a file name
argument (because a file name can also be a number).

Examples:

	:s/x/X/g 5  " substitute 'x' by 'X' in the current line and four
			    " following lines
	:23d 4		" delete lines 23, 24, 25 and 26


### Folds and Range

When folds are active the line numbers are rounded off to include the
whole closed fold.  See `fold-behavior`.


### Reverse Range

A range should have the lower line number first.  If this is not the
case, Vim will ask you if it should swap the line numbers.

    Backwards range given, OK to swap ~

This is not done within the global command `":g"`.

You can use `":silent"` before a command to avoid the question, the
range will always be swapped then.


### Count and Range

When giving a count before entering `":"`, this is translated into:

        :.,.+(count - 1)

In words: The `'count'` lines at and after the cursor.

Example: To delete three lines:

        3:d<CR>		is translated into: .,.+2d<CR>


### Visual Mode and Range

`{Visual}`: Starts a command-line with the Visual selected lines as a
range.  The code `:'<,'>` is used for this range, which makes it
possible to select a similar line from the command-line history for
repeating a command on different Visually selected lines.

When Visual mode was already ended, a short way to use the Visual area
for a range is `:*`.  This requires that `"*"` does not appear in
`'cpo'`, see `cpo-star`. Otherwise you will have to type `:'<,'>`
