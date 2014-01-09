
[Source](http://swaroopch.com/notes/Vim_en-Modes/ "Permalink to Vim en:Modes")

# Vim en:Modes

##  Introduction

We had our first encounter with modes in the [previous chapter][1]. Now, let us explore the concept of modes and what we can do in each mode.

##  Types of modes

There are three basic modes in Vim – normal, insert and visual.

  * Normal mode is where you can run commands. This is the default mode in which Vim starts up.
  * Insert mode is where you insert, i.e., write the text.
  * Visual mode is where you visually select a bunch of text so that you can run a command/operation only on that part of the text.

##  Normal mode

By default, you’re in normal mode. Let’s see what we can do in this mode.

Type `:echo "hello world"` and press enter. You should see the famous words `hello world` echoed back to you. What you just did was run a Vim command called `:echo` and you supplied some text to it which was promptly printed back.

Type `/hello` and press the enter key. Vim will search for that phrase and will jump to the first occurrence.

This was just two simple examples of the kind of commands available in the normal mode. We will see many more such commands in later chapters.

###  How to use the help

Almost as important as knowing the normal mode, is knowing how to use the `:help` command. This is where you learn more about the commands available in Vim.

Remember that you do not need to know every command available in Vim; it’s better to simply know where to find them when you need them. For example, see `:help usr_toc` takes us to the table of contents of the reference manual. You can see `:help index` to search for the particular topic you are interested in, for example, run `/insert mode` to see the relevant information regarding insert mode.

If you can’t remember these two help topics at first, just press `F1` or simply run `:help`.

##  Insert mode

When Vim starts up in normal mode, we have seen how to use `i` to get into insert mode. There are other ways of switching from normal mode to insert mode as well:

  * Run `:e dapping.txt`
  * Press `i`
  * Type the following paragraph (including all the typos and mistakes, we’ll correct them later):

&gt; means being determined about being determined and being passionate about being passionate

  * Press `` key to switch back to normal mode.
  * Run `:w`

Oops, we seem to have missed a word at the beginning of the line, and our cursor is at the end of the line, what do we do now?

What would be the most efficient way of going to the start of the line and insert the missing word? Should we use the mouse to move the cursor to the start of the line? Should we use arrow keys to travel all the way to the start of the line. Should we press home key and then press `i` to switch back to insert mode again?

It turns out that the most efficient way would be to press `I` (upper case i):

  * Press `I`
  * Type `Dappin`
  * Press `` key to switch back to the normal mode.

Notice that we used a different key to switch to insert mode. Its specialty is that it moves the cursor to the start of the line and then switches to the insert mode.

Also notice how important it is to _switch back to the normal mode as soon as you’re done typing the text_. Making this a habit will be beneficial because most of your work (after the initial writing phase) will be in the normal mode – that’s where the all-important rewriting/editing/polishing happens.

Now, let’s take a different variation of the `i` command. Notice that pressing `i` will place your cursor before the current position and then switch to insert mode. To place the cursor ‘a’fter the current position, press `a`.

  * Press `a`
  * Type `g` (to complete the word as “Dapping”)
  * Press `` to switch back to normal mode

Similar to the relationship between `i` and `I` keys, there is a relationship between the `a` and `A` keys – if you want to append text at the end of the line, press the `A` key.

  * Press `A`
  * Type `.` (put a dot to complete the sentence properly)
  * Press `` to switch back to the normal mode

To summarize the four keys we have learnt so far:

Command  Action

i
insert text just before the cursor

I
insert text at the start of the line

a
append text just after the cursor

A
append text at the end of the line

Notice how the upper case commands are ‘bigger’ versions of the lower case commands.

Now that we are proficient in quickly moving in the current line, let’s see how to move to new lines. If you want to ‘o’pen a new line to start writing, press the `o` key.

  * Press `o`
  * Type `I'm a rapper.`
  * Press `` to switch back to the normal mode.

Hmmm, it would be more appealing if that new sentence we wrote was in a paragraph by itself.

  * Press `O` (upper case ‘O’)
  * Press `` to switch back to the normal mode.

To summarize the two new keys we just learnt:

Command  Action

o
open a new line below

O
open a new line above

Notice how the upper and lower case ‘o’ commands are opposite in the direction in which they open the line.

Was there something wrong in the text that we just wrote? Aah, it should be ‘dapper’, not ‘rapper’! It’s a single character that we have to change, what’s the most efficient way to make this change?

We _could_ press `i` to switch to insert mode, press `` key to delete the `r`, type `d` and then press `` to switch back to normal mode. But that is four steps for such a simple change! Is there something better? You can use the `s` key – s for ‘s’ubstitute.

  * Move the cursor to the character `r` (or simply press `b` to move ‘b’ack to the start of the word)
  * Press `s`
  * Type `d`
  * Press `` to switch back to the normal mode

Well, okay, it may not have saved us much right now, but imagine repeating such a process over and over again throughout the day! Making such a mundane operation as fast as possible is beneficial because it helps us focus our energies to more creative and interesting aspects. As Linus Torvalds says, _“it’s not just doing things faster, but because it is so fast, the way you work dramatically changes.”_

Again, there is a bigger version of the `s` key, `S` which substitutes the whole line instead of the current character.

  * Press `S`
  * Type `Be a sinner.`
  * Press `` to switch back to normal mode.

Command  Action

s
substitute the current character

S
substitute the current line

Let’s go back to our last action… Can’t we make it more efficient since we want to ‘r’eplace just a single character? Yes, we can use the `r` key.

  * Move the cursor to the first character of the word `sinner`.
  * Press `r`
  * Type `d`

Notice we’re already back in the normal mode and didn’t need to press ``.

There’s a bigger version of `r` called `R` which will replace continuous characters.

  * Move the cursor to the ‘i’ in `dinner`.
  * Press `R`
  * Type `app` (the word now becomes ‘dapper’)
  * Press `` to switch back to normal mode.

Command  Action

r
replace the current character

R
replace continuous characters

The text should now look like this:

&gt; Dapping means being determined about being determined and being passionate about being passionate.
&gt;
&gt; Be a dapper.

Phew. We have covered a lot in this chapter, but I guarantee that this is the only step that is the hardest. Once you understand this, you’ve pretty much understood the heart and soul of how Vim works, and all other functionality in Vim, is just icing on the cake.

To repeat, understanding how modes work and how switching between modes works is the key to becoming a Vimmer, so if you haven’t digested the above examples yet, please feel free to read them again. Take all the time you need.

If you want to read more specific details about these commands, see `:help inserting` and `:help replacing`.

##  Visual mode

Suppose that you want to select a bunch of words and replace them completely with some new text that you want to write. What do you do?

One way would be to use the mouse to click at the start of the text that you are interested in, hold down the left mouse button, drag the mouse till the end of the relevant text and then release the left mouse button. This seems like an awful lot of distraction.

We could use the `` or `` keys to delete all the characters, but this seems even worse in efficiency.

The most efficient way would be to position the cursor at the start of the text, press `v` to start the visual mode, use arrow keys or any text movement commands to move to the end of the relevant text (for example, press `5e` to move to the end of the 5th word counted from the current cursor position) and then press `c` to ‘c’hange the text. Notice the improvement in efficiency.

In this particular operation (the `c` command), you’ll be put into insert mode after it is over, so press `` to return to normal mode.

The `v` command works on a character basis. If you want to operate in terms of lines, use the upper case `V`.

##  Summary

Here is a drawing of the relationship between the different modes:



                   %2B---------%2B  i,I,a,A,o,O,r,R,s,S  %2B----------%2B
                   | Normal  %2B----------&gt;------------%2B Insert   |
                   | mode    |                       | mode     |
                   |         %2B----------  
