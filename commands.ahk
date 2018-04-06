;; This script provides: command skeletons

#Include commands_util.ahk

kmacro_tt := alloc_tt()

kill_ring_size = 100

;; ---------
;; utilities
;; ---------

safe_cut()
{
    ClipBoard =
    send("^x")
    ClipWait, 0.5              ; confirm that the ClipBoard is updated
}

;; ---------
;; kill_ring
;; ---------

kill_ring_pointer = 0

kill_ring_push()
{ Global
    kill_ring_pointer := mod(kill_ring_pointer + 1, kill_ring_size)
    kill_ring%kill_ring_pointer% := ClipBoard
}

kill_ring_pop()
{ Global
    kill_ring_pointer := mod(kill_ring_pointer + kill_ring_size - 1, kill_ring_size)
    ClipBoard := kill_ring%kill_ring_pointer%
}

kill_ring_restore()
{ Global
    ClipBoard := kill_ring%kill_ring_pointer%
}

;; --------------
;; alttab command
;; --------------

;; Usage:
;;
;; #If, alt_pressed
;; alt up:: alttab_end()
;; #If,
;; !tab:: alttab_next()

alt_pressed = 0

alttab_next()
{ Global
    alt_pressed = 1
    command_simple("{alt down}{tab}", 0, 1)
}

alttab_end()
{ Global
    alt_pressed = 0
    command_simple("{alt up}", 0, 0)
}

;; -----------
;; send itself
;; -----------

;; send itself ARG times (for ASCII keys)
self_insert_command()
{
    command_simple(A_ThisHotKey, 1, 1)
}

;; send itself ARG times (for non-ASCII keys)
self_send_command()
{
    tmp = {%A_ThisHotKey%}
    command_simple(tmp, 0, 1)
}

;; send mouse event itself
mouse_event_command()
{
    MouseGetPos, x, y

    RegExMatch(A_ThisHotKey, "(\W*)(\w*)( up)?", res)

    If res2 = LButton
        key = L
    Else If res2 = RButton
        key = R
    Else If res2 = MButton
        key = M
    Else If res2 = XButton1
        key = X1
    Else If res2 = XButton2
        key = X2
    Else
        Return

    If res3 =
        updn = D
    Else
        updn = U

    key = %res1%{Click, %key%, %x%, %y%, 1, %updn%}
    command_simple(key, 0, 1)
}

;; digit argument
digit_argument()
{ Global
    Local tmp
    run_hooks("pre_command_hook")
    StringTrimLeft, tmp, A_ThisHotKey, 1
    set_digit_argument(arg * 10 + tmp)
    run_hooks("post_command_hook")
}

;; ------
;; system
;; ------

;; do nothing
ignore()
{
    run_hooks("pre_command_hook")
    run_hooks("post_command_hook")
}

set_mark_command()
{
    command_simple("set_mark", 0, 0)
}

set_cx_command()
{ Global
    run_hooks("pre_command_hook")
    set_digit_argument(arg)
    set_cx()
    run_hooks("post_command_hook")
}

;; send ESC and reset variables
keyboard_quit()
{ Global
    run_hooks("pre_command_hook")
    If mark
        reset_mark()
    Else
        send("{escape}")
    run_hooks("post_command_hook")
}

;; repeat last command again ARG times
repeat()
{ Global
    command_simple(last_command, 0, 1)
}

;; ------
;; kmacro
;; ------

;; functions

kmacro_recoding = 0
kmacro_count = 0

kmacro_start()
{ Global
    kmacro_recoding = 1
    kmacro_count = 0
    ToolTip, REC, , , %kmacro_tt%
}

kmacro_after_send_function()
{ Global
    If kmacro_recoding
    {
        kmacro_count++
        kmacro%kmacro_count% := last_command
        ToolTip, %last_command%, , , %kmacro_tt%
    }
}

kmacro_end()
{ Global
    kmacro_recoding = 0
    ToolTip, , , , %kmacro_tt%
}

kmacro_call()
{ Global
    Local varname, x, y
    MouseGetPos, x, y
    Loop, %kmacro_count%
    {
        varname := kmacro%A_Index%
        Send, %varname%
    }
    Send, {Click, , %x%, %y%, 0}
}

add_hook("after_send_hook", "kmacro_after_send_function")

;; commands

kmacro_end_macro()
{
    command_simple("kmacro_end", 0, 0)
}

kmacro_start_macro()
{
    command_simple("kmacro_start", 0, 0)
}

kmacro_call_macro()
{
    command_simple("kmacro_call", 0, 1)
}

kmacro_end_or_call_macro()
{ Global
    If kmacro_recoding
        kmacro_end_macro()
    Else
        kmacro_call_macro()
}

kmacro_end_and_call_macro()
{ Global
    run_hooks("pre_command_hook")
    If kmacro_recoding
        kmacro_end()
    Loop, % arg ? arg : 1
        kmacro_call()
    run_hooks("post_command_hook")
}

;; -----
;; files
;; -----

;; save (C-s)
save_buffer()
{
    command_simple("^s", 0, 0)
}

;; files(_F) > save as(_A)
write_file()
{
    command_simple("{alt down}fa{alt up}", 0, 0)
}

;; open file (C-o)
find_file()
{
    command_simple("^o", 0, 0)
}

;; launch explorer (Win-e)
dired()
{
    command_simple("#e", 0, 0)
}

;; ---------------
;; windows, frames
;; ---------------

;; close window (M-F4)
kill_frame()
{
    command_simple("!{F4}", 0, 0)
}

;; delete ARG tabs (C-F4)
delete_window()
{
    command_simple("^{f4}", 0, 1)
}

;; new ARG tabs (C-t)
split_window()
{
    command_simple("^t", 0, 1)
}

;; forward ARG tabs (C-TAB)
next_window()
{
    command_simple("^{tab}", 0, 1)
}

;;  backward ARG tabs (C-S-TAB)
previous_window()
{
    command_simple("^+{tab}", 0, 1)
}

;; minimize frame (Win-Down)
suspend_frame()
{
    command_simple("#{down}", 0, 0)
}

;; --------
;; motion
;; --------

;; forward ARG chars
forward_char()
{
    command_motion("{right}", 1)
}

;; backward ARG chars
backward_char()
{
    command_motion("{left}", 1)
}

;; forward ARG words (C-right)
forward_word()
{
    command_motion("^{right}", 1)
}

;; backward ARG words (C-left)
backward_word()
{
    command_motion("^{left}", 1)
}

;; down ARG lines
next_line()
{
    command_motion("{down}", 1)
}

;; up ARG lines
previous_line()
{
    command_motion("{up}", 1)
}

;; --------------
;; jumping around
;; --------------

;; PgDn ARG times
scroll_down()
{
    command_motion("{pgdn}", 1)
}

;; PgUp ARG times
scroll_up()
{
    command_motion("{pgup}", 1)
}

;; scroll left ARG times (Alt+PgUp)
scroll_left()
{
    command_motion("!{pgup}", 1)
}

;; scroll right ARG times (Alt+PgDn)
scroll_right()
{
    command_motion("!{pgdn}", 1)
}

;; Home
move_beginning_of_line()
{
    command_motion("{home}", 0)
}

;; End
move_end_of_line()
{
    command_motion("{end}", 0)
}

;; bob (C-Home)
beginning_of_buffer()
{
    command_motion("^{home}", 9)
}

;; eob (C-End)
end_of_buffer()
{
    command_motion("^{end}", 0)
}

;; move to the bob and forward N-1 lines
goto_line()
{
    run_hooks("pre_command_hook")
    InputBox, line, Goto:, , , 130, 105
    If line is number
    {
        line--
        reset_mark()
        send("^{home}")
        Loop, %line%
            send("{down}")
    }
    run_hooks("post_command_hook")
}

;; ------
;; region
;; ------

;; mark this word
mark_word()
{
    command_mark("^{right}{shift down}^{left}{shift up}")
}

;; mark this line
mark_whole_line()
{
    command_mark("{home}{shift down}{end}{shift up}")
}

;; mark this buffer
mark_whole_buffer()
{
    command_mark("^a")
}

;; copy (C-c)
kill_ring_save()
{
    run_hooks("pre_command_hook")
    send("^c")
    reset_mark()
    kill_ring_push()
    run_hooks("post_command_hook")
}

;; cut (C-x)
kill_region()
{
    command_simple("^x", 1, 0)
    kill_ring_push()
}

;; paste ARG times (C-v)
yank()
{
    command_simple("^v", 1, 1)
}

;; pop kill_ring ARG times (M-v)
yank_pop()
{
    run_hooks("pre_command_hook")
    send("^z")
    Loop, % arg ? arg : 1
        kill_ring_pop()
    send("^v")
    run_hooks("after_change_hook")
    run_hooks("post_command_hook")
}

;; delete ARG chars forward (Del)
delete_char()
{
    command_simple("{del}", 1, 1)
}

;; delete ARG chars backward (Bs)
delete_backward_char()
{
    command_simple("{bs}", 1, 1)
}

;; delete ARG words "forward"
kill_word()
{
    command_abc("", "{shift down}^{right}{shift up}", "^x", 1)
    kill_ring_push()
}

;; delete ARG words "backward"
backward_kill_word()
{
    command_abc("", "{shift down}^{left}{shift up}", "^x", 1)
    kill_ring_push()
}

;; delete this line "forward"
kill_line()
{
    command_simple("{shift down}{end}{shift up}^x", 1, 0)
    kill_ring_push()
}

;; delete whole line
kill_whole_line()
{
    command_simple("{home}{shift down}{end}{right}{shift up}^x", 1, 0)
    kill_ring_push()
}

;; ------------------
;; newline and indent
;; ------------------

;; new ARG lines (Ret)
newline()
{
    command_simple("{enter}", 1, 1)
}

;; open ARG lines below (Ret, Left)
open_line()
{
    command_simple("{enter}{left}", 1, 1)
}

;; indent ARG times (Tab)
indent_for_tab_command()
{
    command_simple("{tab}", 1, 1)
}

;; join ARG lines backward
delete_indentation()
{
    command_simple("{home}{bs}", 1, 1)
}

;; -------------
;; edit commands
;; -------------

;; undo ARG times (C-z)
undo_only()
{
    command_simple("^z", 1, 1)
}

;; redo ARG times (C-y)
redo()
{
    command_simple("^y", 1, 1)
}

;; transpose ARG chars
transpose_chars()
{
    command_abc("{left}{shift down}{right}{shift up}^x", "{right}", "^v", 1)
    kill_ring_restore()
}

;; transpose ARG words
transpose_words()
{
    command_abc("{left}^{right}{shift down}^{left}{shift up}^x", "^{right}", "^v", 1)
    kill_ring_restore()
}

;; transpose ARG lines
transpose_lines()
{
    command_abc("{up}{home}{shift down}{down}{shift up}^x", "{down}", "^v", 1)
    kill_ring_restore()
}

;; replace (C-h)
query_replace()
{
    command_simple("^h", 0, 0)
}

;; search (C-f)
search_forward()
{
    command_simple("^f", 0, 0)
}

;; insert mode (ins)
overwrite_mode()
{
    command_simple("{insert}", 0, 0)
}

;; ---------------
;; case conversion
;; ---------------

upcase_region()
{
    run_hooks("pre_command_hook")
    safe_cut()
    StringUpper, Clipboard, Clipboard
    send("^v")
    run_hooks("after_change_hook")
    run_hooks("post_command_hook")
}

downcase_region()
{
    run_hooks("pre_command_hook")
    safe_cut()
    StringLower, Clipboard, Clipboard
    send("^v")
    run_hooks("after_change_hook")
    run_hooks("post_command_hook")
}

upcase_word()
{
    run_hooks("pre_command_hook")
    send("^{right}{shift down}^{left}{shift up}")
    safe_cut()
    StringUpper, Clipboard, Clipboard
    send("^v")
    run_hooks("after_change_hook")
    run_hooks("post_command_hook")
}

downcase_word()
{
    run_hooks("pre_command_hook")
    send("^{right}{shift down}^{left}{shift up}")
    safe_cut()
    StringLower, Clipboard, Clipboard
    send("^v")
    run_hooks("after_change_hook")
    run_hooks("post_command_hook")
}

capitalize_word()
{
    run_hooks("pre_command_hook")
    send("{shift down}^{right}{shift up}")
    safe_cut()
    StringUpper, Clipboard, Clipboard, T
    send("^v")
    run_hooks("after_change_hook")
    run_hooks("post_command_hook")
}

;; ---------------
;; inserting pairs
;; ---------------

;; insert ARG parentheses
insert_parentheses()
{
    command_pair("(){left}")
}

;; insert comment (/* `!!' */)
insert_comment()
{
    command_pair("/*  */{left}{left}{left}")
}

;; continue multiline comment ARG lines (\n * `!!')
indent_new_comment_line()
{
    command_simple("{enter} *{space}", 1, 1)
}

;; ------
;; others
;; ------

;; launch cmd.exe
shell()
{
    run_hooks("pre_command_hook")
    Run, cmd.exe
    run_hooks("after_display_transition_hook")
    run_hooks("post_command_hook")
}

;; execute shell command (Win-r)
shell_command()
{
    command_simple("#r", 0, 0)
}

;; add text properties (basically for MSWord)
facemenu()
{
    command_simple("^d", 0, 0)
}

;; help
help()
{
    command_simple("{f1}", 0, 0)
}
