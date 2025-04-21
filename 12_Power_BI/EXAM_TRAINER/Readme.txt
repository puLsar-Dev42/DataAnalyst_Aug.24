Install:

- download latest nodejs: https://nodejs.org/en/download
- datei installieren. (Chocolatey ist NICHT notwendig)
- Pc neustarten


Start:
1. release-ordner öffnen, Rechtsklick in den Ordner -> In Terminal öffnen.
2. dort eingeben:
	npx serve dist
3. Fertig, Localhost-Link im Browser öffnen.
   (Bei der ersten Ausführung läuft zuerst eine Installation durch, die mit y bestätigen.)



FAQ
- Policy Rechte:
Die Datei "C:\Program Files\nodejs\npx.ps1" kann nicht geladen werden, da die Ausführung von Skripts auf diesem
System deaktiviert ist. Weitere Informationen finden Sie unter "about_Execution_Policies"

Lösung:
- Terminal in Admin-Mode öffnen und dort: Set-ExecutionPolicy Unrestricted
  reinkopieren und bestätigen.


