    Local $ProjectFile = "project.txt"
	Local $ListFile = "lists.tsv"
	Local $KeyValueFile = "keyvalue.tsv"
	Local $cmd = "C:\WINDOWS\system32\cmd.exe"

	If WinExists("[TITLE:" & $ProjectFile & "; CLASS:TfPSPad;]") Then ;
        WinActivate ( $ProjectFile )
		WinWaitActive ( $ProjectFile )
		Send ( "^s")
    EndIf
	If WinExists("[TITLE:" & $ListFile & "; CLASS:Notepad++;]") Then ;
        WinActivate ( $ListFile )
		WinWaitActive ( $ListFile )
		Send ( "^s")
	EndIf

	If WinExists("[TITLE:" & $KeyValueFile & "; CLASS:Notepad++;]") Then ;
        WinActivate ( $KeyValueFile )
		WinWaitActive ( $KeyValueFile )
		Send ( "^s")
	EndIf

	WinActivate ( $cmd )
	WinWaitActive ( $cmd )


