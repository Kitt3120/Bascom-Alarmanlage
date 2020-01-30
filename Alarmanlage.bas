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
' Stattdessen wird f�r jeden Alarmzustand ein einsprechender Text auf dem Terminal Ausgegeben.
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
Ddrd = &B11110000                                           'PortD.4-7 als Ausg�nge, Rest Eing�nge
Ddrb = &B00001111                                           'PortB.0-3 als Ausg�nge, Rest Eing�nge
Ddrc = &B00000111                                           'PortC.0-3 Ausg�nge, Rest Eing�nge
Portd.2 = 1                                                 'Pull-Up f�r Taster an PortD.2 einschalten
Portc.3 = 1                                                 'Pull-Up f�r Taster an PortC.3 einschalten
Portc.4 = 1                                                 'Pull-Up f�r Taster an PortC.4 einschalten
Portc.5 = 1                                                 'Pull-Up f�r Taster an PortC.5 einschalten

'Sirene + Interrupt
Config Timer0 = Timer , Prescale = 64
On Timer0 On_timer0
Enable Interrupts
Dim Timer0_value As Byte

'Interrupt f�r Taster
Enable Int0                                                 'Interrupt 0 einschalten
On Int0 Tasterdruck                                         'Beim Interrupt Tasterdruck ausf�hren
Config Int0 = Falling                                       'H/L-Flanke f�r INT0

'Variablen
Dim Displaystates(16) As Byte                               'Array, welches die verschiedenen Zust�nde der 7-Segment-Anzeige enth�lt

Dim Count As Integer                                        'Benutzt f�r Loops
Count = 0

Dim Amode As Byte                                           'Durch Terminal ausgew�hlter Modus (0=Aus, 1=Ein oder 2=Test) (AMode, da Mode ein Keyword f�r den Compiler ist)

Dim Lastline As String * 25                                 'Letzte gelesene Eingabe durch ReadLine

Dim Check_ok As Bit                                         'Gibt an, ob der letzte Check ok war
Check_ok = 1

Dim Bypass As Bit                                           'Bypass f�r den Alarm, wenn geheimer Taster gedr�ckt wurde
Bypass = 0

Dim Countdown_next_buzzer As Integer                        'Zeitpunkt im Countdown, wann der n�chste Beep-Ton einsetzen soll
Countdown_next_buzzer = 0

Dim Countdown_next_buzzer_delay As Integer                  'F�r die n�chste Verschiebung des Beep-Tons im Countdown
Countdown_next_buzzer_delay = 1000

Dim Countdown_display_number As Integer
Countdown_display_number = 0

Dim Buzzer_frequency As Byte                                'F�r die Tonlage des Buzzers
Buzzer_frequency = 80

Dim Buzzer_delay As Integer                                 'F�r die l�nge des Beep-Ton
Buzzer_delay = 500

Dim Ignoreddoors As Byte                                    'Byte, um die zu ignorierenden T�ren nach rechtzeitigem Abschalten des Countdowns zu speichern
Ignoreddoors = &B00000000

'Aliase
Tuer1 Alias Pinc.3
Tuer2 Alias Pinc.4
Tuer3 Alias Pinc.5

Led1 Alias Portc.0
Led2 Alias Portc.1
Led3 Alias Portc.2

Buzzer Alias Portd.7

'Subs Deklarieren
Declare Sub Readline()
Declare Sub Displaynumber(byval Number As Integer)
'-------------------------------------Init-------------------------------------'
Gosub Setupdisplaystates
Gosub Selectmode
Print "Starte im Modus: " ; Amode
'-------------------------------------Main--------------------------------------
Do
  If Amode = 0 Then
    !NOP
  Else
    Gosub Refreshleds                                       'Alle LEDs aktualisieren
    Gosub Check                                             'Einen Check ausf�hren und eventuell Alarmanlage ausl�sen

    If Check_ok = 0 Then
      Gosub Countdown
    End If
  End If
Loop
End
'------------------------------------Labels-------------------------------------
Setupdisplaystates:                                         'Initialisiert die verschiedenen Zust�nde der 7-Segment-Anzeige
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

Selectmode:                                                 'L�sst den Nutzer einen Modus ausw�hlen
  Print "In welchem Modus soll gestartet werden?"
  Print "Aus"
  Print "Normal"
  Print "Test"
  Call Readline()                                           'Lie�t ganze Zeile ein und speichert sie in Variable LastLine

  If Lastline = "Aus" Then
    Amode = 0
  Elseif Lastline = "Normal" Then
    Amode = 1
  Elseif Lastline = "Test" Then
    Amode = 2
  Else
    Print "Unbekannter Modus!"
    Gosub Selectmode
  End If
Return

Refreshleds:                                                'LEDs aktualisieren
  Led1 = Not Tuer1                                          'Not, da der Wert einmal umgekehrt werden muss
  Led2 = Not Tuer2
  Led3 = Not Tuer3
Return

Check:                                                      'F�hrt einen Check aus und l�st eventuell die Alarmanlage aus
  Check_ok = 1                                              'Standardm��ig erfolgreich

  If Tuer1 = 1 And Ignoreddoors.1 = 0 Then                  'Wenn eine T�r offen ist und nicht ignoriert werden soll, schl�gt der Check feh�
    Check_ok = 0
  End If
  If Tuer2 = 1 And Ignoreddoors.2 = 0 Then
    Check_ok = 0
  End If
  If Tuer3 = 1 And Ignoreddoors.3 = 0 Then
    Check_ok = 0
  End If

  If Tuer1 = 0 And Ignoreddoors.1 = 1 Then                  'Wenn eine T�r geschlossen ist und ignoriert werden soll, wird sie nicht mehr ignoriert
    Ignoreddoors.1 = 0
  End If
  If Tuer2 = 0 And Ignoreddoors.2 = 1 Then
    Ignoreddoors.2 = 0
  End If
  If Tuer3 = 0 And Ignoreddoors.3 = 1 Then
    Ignoreddoors.3 = 0
  End If
Return

Countdown:
  Buzzer_frequency = 80
  Buzzer_delay = 1000
  Countdown_next_buzzer = 30000
  Countdown_next_buzzer_delay = 1000
  Countdown_display_number = 0

  Led1 = 1
  Led2 = 1
  Led3 = 1

  Count = 30000
  While Count > 100 And Bypass = 0                          'While anstatt for, um Count in der Schleife modifizieren zu k�nnen
    Toggle Led1
    Toggle Led2
    Toggle Led3

    If Count > 20000 Then
      Countdown_display_number = 3
    Elseif Count > 10000 Then
      Countdown_display_number = 2
    Else
      Countdown_display_number = Count / 1000
    End If

    Call Displaynumber(countdown_display_number)

    If Count <= Countdown_next_buzzer Then
      Gosub Beep
      Count = Count - Buzzer_delay                          'Verstrichene Zeit vom Buzzer abziehen

      Buzzer_delay = Buzzer_delay - 30
      If Buzzer_delay <= 100 Then
        Buzzer_delay = 100
      End If

      Countdown_next_buzzer = Count - Countdown_next_buzzer_delay
      Countdown_next_buzzer_delay = Countdown_next_buzzer_delay - 40
      If Countdown_next_buzzer <= 0 Then
        Countdown_next_buzzer = 0
      End If
    End If

    Waitms 1
    Count = Count - 1
  Wend

  Call Displaynumber( -1)

  If Bypass = 1 Then                                        'Wenn Countdown abgelaufen und Bypass
    If Tuer1 = 1 Then                                       'T�ren, welche nach Bypass offen sind, bis zum Schlie�en ignorieren
      Ignoreddoors.1 = 1
    End If
    If Tuer2 = 1 Then
      Ignoreddoors.2 = 1
    End If
    If Tuer3 = 1 Then
      Ignoreddoors.3 = 1
    End If
    Bypass = 0                                              'Bypass zur�cksetzen
  Else                                                      'Wenn Countdown abgelaufen und kein Bypass
    Gosub Sirene
  End If
Return

Beep:                                                       'L�sst den Buzzer piepen
  Buzzer_frequency = 80
  Enable Timer0
  Waitms Buzzer_delay
  Disable Timer0
Return

Sirene:
  Enable Timer0
  Do                                                        'In Endlosschleife laufen lassen
    For Buzzer_frequency = 80 To 150 Step 1
      Waitms 5
    Next Buzzer_frequency

    Waitms 1500

    For Buzzer_frequency = 150 To 80 Step -1
      Waitms 30
    Next Buzzer_frequency
  Loop
Return
'-------------------------------------Subs--------------------------------------
Sub Readline()                                              'Lie�t eine ganze Zeile vom Nutzer ein
  Local Inputstring As String * 25
  Local Current As Byte
  Local Reading As Byte
  Inputstring = ""
  Current = 0
  Reading = 1
  While Reading = 1
    Current = Waitkey()
    If Current = 13 Then
      Reading = 0
    Else
      Inputstring = Inputstring + Chr(current)
    End If
  Wend
  Print "Input: " ; Inputstring
  Lastline = Inputstring
End Sub

Sub Displaynumber(number As Integer)                        'Gibt die angegebene Zahl auf der 7-Segment-Anzeige aus
   If Number < 0 Then
     Portd = &B00000000 And &B11110000
     Portd.2 = 1                                            'Pull-Up Widerstand an PortD.2 wieder aktivieren
     Portb = &B00000000 And &B00001111
   Else
     Portd = Displaystates(number + 1) And &B11110000
     Portd.2 = 1                                            'Pull-Up Widerstand an PortD.2 wieder aktivieren
     Portb = Displaystates(number + 1) And &B00001111
   End If
End Sub
'----------------------------------Interrupts-----------------------------------
On_timer0:                                                  'Schaltet den Buzzer in unterschiedlichen Abst�nden ein und aus, um T�ne zu erzeugen
   Timer0_value = Timer0 + 9                                'Genauigkeit verbesser, der MC braucht etwa 9 Ticks, um die Werte neu zu setzen
   Timer0 = Buzzer_frequency + Timer0_value

   If Amode = 1 Then
     Toggle Buzzer
   Elseif Amode = 2 Then
     Print "Buzzer! (" ; Buzzer_frequency ; ")"
   End If
Return

Tasterdruck:
  If Amode = 1 Or Amode = 2 Then
    If Check_ok = 0 Then
      Bypass = 1
    Else
      Gosub Selectmode
    End If
  End If
Return