% Syntax folding of Vim scripts
% Ingo Karkat on vim.wikia.com
% 2006

Abstract
========

Many syntax files provide fold information. Unfortunately, the
officially distributed vimscript syntax file did not until [version
7.1-76](http://vim.wikia.com/wiki/Syntax_folding_of_Vim_scripts?useskin=monobook#New_built-in_folding), and even now only provides
limited support. You will need to define your own syntax folding, or
resign yourself to inserting fold markers all over the place (which,
incidentally, the vim.vim syntax file does). Here is a good set of
syntax folding definitions that you can at least use as a starting
point.

## Usage

The code at the end of this tip allows folding of various Vim script
constructs via `foldmethod=syntax`. Put it in `after/syntax/vim.vim`,
located either in your system-wide or home Vim directory (see [:help
after-directory](http://vimdoc.sourceforge.net/cgi-bin/help?tag=after-directory)).

To [use these
folds](http://vim.wikia.com/wiki/Syntax_folding_of_Vim_scripts?useskin=monobook#New_built-in_folding), put
`setlocal foldmethod=syntax` in `after/ftplugin/vim.vim`. While you're
at it, it also makes sense to avoid folding in the command window
(`q:`). You can use the following fragment for that:

    " Folding via syntax is used for this filetype.
    setlocal foldmethod=syntax

    " Vim's command window ('q:') and the :options window also set filetype=vim. We
    " do not want folding in these enabled by default, though, because some
    " malformed :if, :function, ... commands would fold away everything from the
    " malformed command until the last command.
    if bufname('') =~# '^\%(' . (v:version < 702 ? 'command-line' : '\[Command Line\]') . '\|option-window\)$'
      " With this, folding can still be enabled easily via any zm, zc, zi, ...
      " command.
      setlocal nofoldenable
    else
      " Fold settings for ordinary windows.
      setlocal foldcolumn=4
    endif

Alternatively, you can use an autocommand or a mapping to enable
folding. If using an autocommand, the FileType and Syntax events are
probably the best ones to use. Calling `zR` as well when you do this
will [start with all the folds open when loading the
file](http://vim.wikia.com/wiki/All_folds_open_when_opening_a_file).

## How it works

These syntax groups set up regions between start and end patterns as
long as they don't start within certain syntax groups such as comments,
strings, or the lhs of a mapping, and attempt to skip over commented-out
end patterns with the skip pattern.

A syntax cluster ([:help
:syn-cluster](http://vimdoc.sourceforge.net/cgi-bin/help?tag=%3Asyn-cluster))
called vimNoFold is defined to easily exclude certain syntax items from
containing a fold. The `containedin` option is set to @vimNoFold to make
sure the fold definitions do not match in areas such as comments, syntax
definitions, embedded scripts, and the like. The syntax items contained
in @vimNoFold were determined through (a) finding an error and (b)
looking at vim.vim to determine which ones are triggering the syntax
folding that shouldn't be. It is useful to [display the highlight group
under the
cursor](http://vim.wikia.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor)
while debugging in this way.

Most of the syntax rules have "begin" and "end" keywords that set up a
simple syntax region, using `keepend` to allow syntax highlighting of
end markers and `extend` to allow nesting.

The "if...else...endif" construct is a little different and works as
follows:

1.  vimFoldIfContainer is a simple transparent region with no folding
    that matches the entire if...endif region
2.  vimFoldIf is only contained in vimFoldIfContainer, and matches
    if...else or if...elseif, then backs up the endmarker match to allow
    another match on the else(if). This folds the first part of
    if...else...endif constructs.
3.  vimFoldElseIf is also only contained in the container, and will
    match any number of elseif...else(if) groups. This also backs up the
    endmarker match to allow another match on it to start the next
    region.
4.  vimFoldElse is also only contained in the container, and will match
    the final possible group: else...endif.
5.  Note that the contained groups do not have the "extend" argument,
    meaning that even if the "else" does not match to end the group, the
    group will not extend beyond the confines of the vimFoldIfContainer
    (which ends at "endif") because vimFoldIfContainer uses keepend.

"try...catch" constructs work similarly to "if...else...endif"
constructs (with try...catch...finally...endtry instead of
if...elseif...else...endif).

## Problems

These syntax folds are not perfect, and suffer from at least the
following:

-   The syntax definitions are fairly complex. Sometimes, especially
    when deleting or commenting out an "else", "catch", or "finally",
    you will need to type `:syn sync fromstart` to update the fold
    information. You may want to map this command to a key if you need
    to do it often.
-   The "skip" group could probably be improved. Currently, it will
    attempt to skip single and double-quoted strings, and comments.
-   Some keywords (such as "else" and "catch") must be preceded by
    nothing but whitespace to properly trigger fold behavior; this may
    or may not be an issue depending on your coding style.
-   If you use reserved words like "while" or "if" for purposes other
    than Vim language constructs, these fold definitions *may*
    incorrectly match them to start a fold. The definitions have an
    extensive vimNoFold group in an attempt to prevent this, but it can
    still be fooled. Try to avoid such keywords if you can, especially
    for variable names. Note: because of the "extend" part of the fold
    definitions, an incorrect match may cause incorrect syntax
    highlighting as well as incorrect folding.
-   While the start-of-region keywords (if, while, etc.) will not start
    within a group in the vimNoFold cluster, end-of-region keywords
    (endif, endwhile, etc.) are not similarly protected. Only the skip
    group protects these.

New built-in folding
====================

Version 7.1-76 of the default vim.vim syntax file (released January 24,
2008) includes folding for the following as a [configurable
option](http://vim.wikia.com/wiki/Check_your_syntax_files_for_configurable_options):

-   augroups
-   functions
-   embedded scripts in scheme, perl, python, ruby, and tcl

See [`:help
g:vimsyn_folding`](http://vimdoc.sourceforge.net/cgi-bin/help?tag=g%3Avimsyn_folding) for details.

Get the latest distribution of Vim from [whichever source you
prefer](Where to download Vim "wikilink") and put the following in
either your vimrc or in vim.vim in your ftplugin directory:

    let g:vimsyn_folding='af'

Syntax definitions
==================

As mentioned above, place the following in your after/syntax Vim file:

~~~~ {.vim}
" The default Vim syntax file has limited 'fold' definitions, so define more.

" define groups that cannot contain the start of a fold
syn cluster vimNoFold contains=vimComment,vimLineComment,
\   vimCommentString,vimString,vimSynKeyRegion,vimSynRegPat,
\   vimPatRegion,vimMapLhs,vimOperParen,@EmbeddedScript
syn cluster vimEmbeddedScript contains=vimMzSchemeRegion,
\   vimTclRegion,vimPythonRegion,vimRubyRegion,vimPerlRegion

" fold while loops
syn region vimFoldWhile
      \ start="\<wh\%[ile]\>"
      \ end="\<endw\%[hile]\>"
      \ transparent fold
      \ keepend extend
      \ containedin=ALLBUT,@vimNoFold
      \ skip=+"\%(\\"\|[^"]\)\{-}\%("\|$\)\|'[^']\{-}'+
      \     "comment to fix highlight on wiki'

" fold for loops
syn region vimFoldFor
      \ start="\v<for>%(\s*\n\s*\\)?\s*\k+%(\s*\n\s*\\\s*)?\s*<in>"
      \ end="\<endfo\%[r]\>"
      \ transparent fold
      \ keepend extend
      \ containedin=ALLBUT,@vimNoFold
      \ skip=+"\%(\\"\|[^"]\)\{-}\%("\|$\)\|'[^']\{-}'+
      \     "comment to fix highlight on wiki'

" fold if...else...endif constructs
"
" note that 'endif' has a shorthand which can also match many other end patterns
" if we did not include the word boundary \> pattern, and also it may match
" syntax end=/pattern/ elements, so we must explicitly exclude these
syn region vimFoldIfContainer
      \ start="\<if\>"
      \ end="\<en\%[dif]\>=\@!"
      \ transparent
      \ keepend extend
      \ containedin=ALLBUT,@vimNoFold
      \ contains=NONE
      \ skip=+"\%(\\"\|[^"]\)\{-}\%("\|$\)\|'[^']\{-}'+
      \     "comment to fix highlight on wiki'
syn region vimFoldIf
      \ start="\<if\>"
      \ end="^\s*\\\?\s*else\%[if]\>"ms=s-1,me=s-1
      \ fold transparent
      \ keepend
      \ contained containedin=vimFoldIfContainer
      \ nextgroup=vimFoldElseIf,vimFoldElse
      \ contains=TOP
      \ skip=+"\%(\\"\|[^"]\)\{-}\%("\|$\)\|'[^']\{-}'+
      \     "comment to fix highlight on wiki'
syn region vimFoldElseIf
      \ start="\<else\%[if]\>"
      \ end="^\s*\\\?\s*else\%[if]\>"ms=s-1,me=s-1
      \ fold transparent
      \ keepend
      \ contained containedin=vimFoldIfContainer
      \ nextgroup=vimFoldElseIf,vimFoldElse
      \ contains=TOP
      \ skip=+"\%(\\"\|[^"]\)\{-}\%("\|$\)\|'[^']\{-}'+
      \     "comment to fix highlight on wiki'
syn region vimFoldElse
      \ start="\<el\%[se]\>"
      \ end="\<en\%[dif]\>=\@!"
      \ fold transparent
      \ keepend
      \ contained containedin=vimFoldIfContainer
      \ contains=TOP
      \ skip=+"\%(\\"\|[^"]\)\{-}\%("\|$\)\|'[^']\{-}'+
      \     "comment to fix highlight on wiki'

" fold try...catch...finally...endtry constructs
syn region vimFoldTryContainer
      \ start="\<try\>"
      \ end="\<endt\%[ry]\>"
      \ transparent
      \ keepend extend
      \ containedin=ALLBUT,@vimNoFold
      \ contains=NONE
      \ skip=+"\%(\\"\|[^"]\)\{-}\%("\|$\)\|'[^']\{-}'+
      \     "comment to fix highlight on wiki'
syn region vimFoldTry
      \ start="\<try\>"
      \ end="^\s*\\\?\s*\(fina\%[lly]\|cat\%[ch]\)\>"ms=s-1,me=s-1
      \ fold transparent
      \ keepend
      \ contained containedin=vimFoldTryContainer
      \ nextgroup=vimFoldCatch,vimFoldFinally
      \ contains=TOP
      \ skip=+"\%(\\"\|[^"]\)\{-}\%("\|$\)\|'[^']\{-}'+
      \     "comment to fix highlight on wiki'
syn region vimFoldCatch
      \ start="\<cat\%[ch]\>"
      \ end="^\s*\\\?\s*\(cat\%[ch]\|fina\%[lly]\)\>"ms=s-1,me=s-1
      \ fold transparent
      \ keepend
      \ contained containedin=vimFoldTryContainer
      \ nextgroup=vimFoldCatch,vimFoldFinally
      \ contains=TOP
      \ skip=+"\%(\\"\|[^"]\)\{-}\%("\|$\)\|'[^']\{-}'+
      \     "comment to fix highlight on wiki'
syn region vimFoldFinally
      \ start="\<fina\%[lly]\>"
      \ end="\<endt\%[ry]\>"
      \ fold transparent
      \ keepend
      \ contained containedin=vimFoldTryContainer
      \ contains=TOP
      \ skip=+"\%(\\"\|[^"]\)\{-}\%("\|$\)\|'[^']\{-}'+
      \     "comment to fix highlight on wiki'

" Folding of functions and augroups is built-in since VIM 7.2 (it was introduced
" with vim.vim version 7.1-76) if g:vimsyn_folding contains 'a' and 'f', so set
" this variable if you want it. (Also in older VIM versions.)
if v:version <= 701 && exists('g:vimsyn_folding')
  " Starting with VIM 7.2, this is built-in. Retrofit for older versions unless
  " VIM 7.1 already has it patched in.
  let s:vimsyn_folding = g:vimsyn_folding
  if v:version == 701
    " Special check for VIM 7.1: Since we cannot check for that particular
    " version of the runtime file, check one of the associated group names
    " itself for the 'fold' keyword.
    redir => s:synoutput
    silent! syn list vimFuncBody
    redir END
    if s:synoutput =~ 'fold'
      " No need to retrofit, this vim.vim version already supports folding.
      let s:vimsyn_folding = ''
    endif
    unlet s:synoutput
  endif

  if s:vimsyn_folding =~# 'f'
    " fold functions
    syn region vimFoldFunction
      \ start="\<fu\%[nction]!\=\s\+\%(<[sS][iI][dD]>\|
      \[sSgGbBwWtTlL]:\)\?\%(\i\|[#.]\|{.\{-1,}}\)*\ze\s*("
      \ end="\<endfu\%[nction]\>"
      \ transparent fold
      \ keepend extend
      \ containedin=ALLBUT,@vimNoFold
      \ skip=+"\%(\\"\|[^"]\)\{-}\%("\|$\)\|'[^']\{-}'+
      \     "comment to fix highlight on wiki'
  endif

" fold augroups
  if s:vimsyn_folding =~# 'a'
    syn region vimFoldAugroup
      \ start="\<aug\%[roup]\ze\s\+\(END\>\)\@!"
      \ end="\<aug\%[roup]\s\+END\>"
      \ transparent fold
      \ keepend extend
      \ containedin=ALLBUT,@vimNoFold
      \ skip=+"\%(\\"\|[^"]\)\{-}\%("\|$\)\|'[^']\{-}'+
      \     "comment to fix highlight on wiki'
  endif
  unlet s:vimsyn_folding
endif
~~~~

See also
========

- [Folding](http://vim.wikia.com/wiki/Folding) presents an overview of
  how to use folding

References
==========

- [`:help
  mysyntaxfile-add`](http://vimdoc.sourceforge.net/cgi-bin/help?tag=mysyntaxfile-add)
  tells how to add to a syntax file as done in this tip
- [`:help
  :syn-region`](http://vimdoc.sourceforge.net/cgi-bin/help?tag=%3Asyn-region)
- [`:help
  :syn-fold`](http://vimdoc.sourceforge.net/cgi-bin/help?tag=%3Asyn-fold)
- [`:help
  /\@!`](http://vimdoc.sourceforge.net/cgi-bin/help?tag=%2F%5C%40%21)
  used to match only when a string doesn't match
- [`:help
  /\%`](http://vimdoc.sourceforge.net/cgi-bin/help?tag=%2F%5C%25%5B%5D)
  used to match parts of a string
- [`:help
  :syn-pattern-offset`](http://vimdoc.sourceforge.net/cgi-bin/help?tag=%3Asyn-pattern-offset)
  used to "back up" on an if-else to allow else-endif to match.
  
* * * *
