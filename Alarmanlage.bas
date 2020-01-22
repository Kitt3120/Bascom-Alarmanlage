'MCT Alarmanlage                                                    Datum:  20.12.2019
'Name: Torben Schweren, Fabian Ufer, Niko Illijoski Klasse: I13-F1
'
'Aufgabe:
'Es werden drei T�ren �berwacht die jeweils mit einem Kontaktgeber verbunden sind.
'Wird eine T�r ge�ffnet so wird auch der entsprechende Schaltkontakt ge�ffnet.
'
'Der Zustand der T�r wird durch eine LED angezeigt. Ist die T�r ge�ffnet ist die LED an
'ist die T�r zu ist die LED aus.
'
'Wenn die Alarmanlage eingeschaltet ist und eine T�r ge�ffnet wird, l�st das einen immer
'schneller werdenden Piepton aus. Man hat dann 30 Sekunden Zeit einen geheimen Taster zu bet�tigen.
'
'Gleichzeitig wird eine Meldung mit einem von 30 herunter z�hlendem Countdown auf
'einem Display, einer 7-Segment Anzeige oder auf dem Terminal ausgegeben und alle
'angeschlossenen LEDs blinken.
'
'Wird der Taster innerhalb der 30 Sekunden bet�tigt, kehrt die Alarmanlage wieder in ihren Normalmodus zur�ck.
'Die bereits ge�ffnete T�r wird so lange ignoriert, bis sie wieder geschlossen wird.
'
'Wird der Taster nicht innerhalb von dreissig Sekunden bet�tigt, beginnt die Sirene mit dem Alarmton.
'Abschalten kann man die Anlage dann nur noch in dem man den RESET-Knopf dr�ckt.
'
'Die Alarmanlage soll am Terminal in drei verschiedene Zust�nde geschaltet werden k�nnen.
' Der erste Zustand ist einfach - die Alarmanlage ist ausgeschaltet und reagiert nicht.
' Im zweiten Zustand ist die Alarmanlage eingeschaltet und im Normalmodus. Sie reagiert wie oben beschrieben.
' Im dritten Zustand ist die Alarmlage im Testmodus. Hier kann man die T�ren �ffnen
' und sehen ob die LEDs und die Schalter richtig funktionieren, Es wird jedoch kein Alarmton ausgegeben.
' Stattdessen wird f�r jeden Alarmzustand ein einsprechender Text aufdem Terminal Ausgegeben.
'
'Hardware:
'7-Segment-Anzeige an PortB.0-3 und PortD.4-6
'Taster an PortD.2
'T�ren:
' T�r 1 an PortC.3
' T�r 2 an PortC.4
' T�r 3 an PortC.5
'LEDs:
' T�r 1 (Gr�n) an PortC.0
' T�r 2 (Gelb) an PortC.1
' T�r 3 (Rot)  an PortC.2
'
'----------------------------------Deklaration----------------------------------
'Mikrocontroller-Einstellungen
$regfile = "m168def.dat"                                    'ATmega168-Deklaration
$crystal = 20000000                                         'Taktfrequennz: 20,000 MhZ
$hwstack = 100
$swstack = 100
$framesize = 100
$baud = 19200

'Ports
Ddrd = &B01110000                                           'PortD.4-6 als Ausg�nge, Rest Eing�nge
Ddrb = &B00001111                                           'PortB.0-3 als Ausg�nge, Rest Eing�nge
Portd.2 = 1                                                 'Pull-Up f�r Taster an PortD.2 einschalten

'Variablen
Dim Displaystates(16) As Byte
Dim Count As Integer
Count = 0

Dim Amode As Byte                                           'Durch Terminal ausgew�hlter Modus (0=Aus, 1=Ein oder 2=Test) (AMode, da Mode ein Keyword f�r den Compiler ist)

Dim Doorstatus As Byte                                      'Byte, um den Zustand der T�ren zu speichern
Doorstatus = &B00000000
Dim Ignoreddoors As Byte                                    'Byte, um die zu ignorierenden T�ren nach rechtzeitigem Abschalten des Countdowns zu speichern
Ignoreddoors = &B00000000

'Aliase
Tuer.1 Alias Portc.3
Tuer.2 Alias Portc.4
Tuer.3 Alias Portc.5

Led.1 Alias Portc.0
Led.2 Alias Portc.1
Led.3 Alias Portc.2

'Subs Deklarieren
Declare Sub Displaynumber(number As Integer)
'-------------------------------------Main--------------------------------------
Gosub Setupdisplaystates

Do

Loop
End

'------------------------------------Labels-------------------------------------
Setupdisplaystates:
   Displaystates(1) = &B00111111
   Displaystates(2) = &B00000110
   Displaystates(3) = &B01011011
   Displaystates(4) = &B01001111
   Displaystates(5) = &B01100110
   Displaystates(6) = &B01101101
   Displaystates(7) = &B01111101
   Displaystates(8) = &B00100111
   Displaystates(9) = &B01111111
   Displaystates(10) = &B01101111
   Displaystates(11) = &B01110111
   Displaystates(12) = &B01111100
   Displaystates(13) = &B00111001
   Displaystates(14) = &B01011110
   Displaystates(15) = &B01111001
   Displaystates(16) = &B01110001
Return

'-------------------------------------Subs--------------------------------------
Sub Displaynumber(number As Integer)
   Portd = Displaystates(number + 1) And &B11110000
   Portd.2 = 1                                              'Pull-Up Widerstand an PortD.2 wieder aktivieren
   Portb = Displaystates(number + 1) And &B00001111
End Sub