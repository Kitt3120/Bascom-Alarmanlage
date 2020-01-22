'MCT Alarmanlage                                                    Datum:  20.12.2019
'Name: Torben Schweren, Fabian Ufer, Niko Illijoski Klasse: I13-F1
'
'Aufgabe:
'Es werden drei Türen überwacht die jeweils mit einem Kontaktgeber verbunden sind.
'Wird eine Tür geöffnet so wird auch der entsprechende Schaltkontakt geöffnet.
'
'Der Zustand der Tür wird durch eine LED angezeigt. Ist die Tür geöffnet ist die LED an
'ist die Tür zu ist die LED aus.
'
'Wenn die Alarmanlage eingeschaltet ist und eine Tür geöffnet wird, löst das einen immer
'schneller werdenden Piepton aus. Man hat dann 30 Sekunden Zeit einen geheimen Taster zu betätigen.
'
'Gleichzeitig wird eine Meldung mit einem von 30 herunter zählendem Countdown auf
'einem Display, einer 7-Segment Anzeige oder auf dem Terminal ausgegeben und alle
'angeschlossenen LEDs blinken.
'
'Wird der Taster innerhalb der 30 Sekunden betätigt, kehrt die Alarmanlage wieder in ihren Normalmodus zurück. Die bereits geöffnete Tür wird so lange ignoriert, bis sie wieder
'geschlossen wird.
'
'Wird der Taster nicht innerhalb von dreissig Sekunden betätigt, beginnt die Sirene mit
'dem Alarmton. Abschalten kann man die Anlage dann nur noch in dem man den RESET
'Knopf drückt.
'
'Die Alarmanlage soll am Terminal in drei verschiedene Zustände geschaltet werden können.
' Der erste Zustand ist einfach - die Alarmanlage ist ausgeschaltet und reagiert nicht.
' Im zweiten Zustand ist die Alarmanlage eingeschaltet und im Normalmodus. Sie reagiert wie oben beschrieben.
' Im dritten Zustand ist die Alarmlage im Testmodus. Hier kann man die Türen öffnen
' und sehen ob die LEDs und die Schalter richtig funktionieren, Es wird jedoch kein Alarmton ausgegeben. Stattdessen wird für jeden Alarmzustand ein einsprechender Text auf
' dem Terminal Ausgegeben.
'
'----------------------------------Deklaration----------------------------------
'Mikrocontroller Einstellungen
$regfile = "m168def.dat"                                    'ATmega168-Deklaration
$crystal = 20000000                                         'Taktfrequennz: 20,000 MhZ
$hwstack = 100
$swstack = 100
$framesize = 100
$baud = 19200

'-------------------------------------Main--------------------------------------
Do

Loop
End

'------------------------------------Labels-------------------------------------

'-------------------------------------Subs--------------------------------------