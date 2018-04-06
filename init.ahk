

;; load libraries
;; --------------

;; #Include lib_evil.ahk
;; #Include lib_autopair.ahk

;; customize variables
;; -------------------

;; evil_auto_mode = 1

;; //////////// auto execution section ends here ////////////

;; keybinds for lib_autopair
;; -------------------------

;; #If !ignored_frame() && !cx
;; ,:: smart_colon()
;; [:: smart_bracket()
;; +9:: insert_parentheses()
;; +[:: smart_brace()
;; +':: smart_dquot()

;; keybinds for lib_evil
;; ---------------------

;; #If !ignored_frame() && !evil
;; escape:: evil_mode()

;; #If !dummy && !ignored_frame() && evil
;; bs:: self_send_command()
;; enter:: self_send_command()
;; space:: self_send_command()

;; #Include lib_evil_keys.ahk

ToggleWinMinimize(TheWindowTitle)
{
SetTitleMatchMode,2
DetectHiddenWindows, Off
IfWinActive, %TheWindowTitle%
{
WinActivate, %TheWindowTitle%
keyboard_quit()
}
Else
{
IfWinExist, %TheWindowTitle%
{
WinActivate, %TheWindowTitle%
keyboard_quit()
}
}
Return
}

Win__Fling(FlingDirection = 1, WinID = "A")
{
	; Figure out which window to move based on the "WinID" function parameter:
	;	1) The letter "A" means to use the Active window
	;	2) The letter "M" means to use the window under the Mouse
	; Otherwise, the parameter value is assumed to be the AHK window ID of the window to use.

	if (WinID = "A")
	{
		; If the user supplied an "A" as the window ID, we use the Active window
		WinID := WinExist("A")
	}
	else if (WinID = "M")
	{
		; If the user supplied an "M" as the window ID, we use the window currently under the Mouse
		MouseGetPos, MouseX, MouseY, WinID		; MouseX & MouseY are retrieved but, for now, not used
	}

	; Check to make sure we are working with a valid window
	IfWinNotExist, ahk_id %WinID%
	{
		; Make a short noise so the user knows to stop expecting something fun to happen.
		SoundPlay, *64
		
		; Debug Support
		;MsgBox, 16, Window Fling: Error, Specified window does not exist.`nWindow ID = %WinID%

		return 0
	}
}

!t::^t 