    Local $ProjectFile = "project.txt"
	Local $ListFile = "lists.tsv"
	Local $KeyValueFile = "keyvalue.tsv"

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
