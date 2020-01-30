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
'Wird der Taster innerhalb der 30 Sekunden betätigt, kehrt die Alarmanlage wieder in ihren Normalmodus zurück.
'Die bereits geöffnete Tür wird so lange ignoriert, bis sie wieder geschlossen wird.
'
'Wird der Taster nicht innerhalb von dreissig Sekunden betätigt, beginnt die Sirene mit dem Alarmton.
'Abschalten kann man die Anlage dann nur noch in dem man den RESET-Knopf drückt.
'
'Die Alarmanlage soll am Terminal in drei verschiedene Zustände geschaltet werden können.
' Der erste Zustand ist einfach - die Alarmanlage ist ausgeschaltet und reagiert nicht.
' Im zweiten Zustand ist die Alarmanlage eingeschaltet und im Normalmodus. Sie reagiert wie oben beschrieben.
' Im dritten Zustand ist die Alarmlage im Testmodus. Hier kann man die Türen öffnen
' und sehen ob die LEDs und die Schalter richtig funktionieren, Es wird jedoch kein Alarmton ausgegeben.
' Stattdessen wird für jeden Alarmzustand ein einsprechender Text auf dem Terminal Ausgegeben.
'
'Hardware:
'7-Segment-Anzeige an PortB.0-3 und PortD.4-6
'Taster an PortD.2
'Türen:
' Tür 1 an PortC.3
' Tür 2 an PortC.4
' Tür 3 an PortC.5
'LEDs:
' Tür 1 (Grün) an PortC.0
' Tür 2 (Gelb) an PortC.1
' Tür 3 (Rot)  an PortC.2
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
Ddrd = &B11110000                                           'PortD.4-7 als Ausgänge, Rest Eingänge
Ddrb = &B00001111                                           'PortB.0-3 als Ausgänge, Rest Eingänge
Ddrc = &B00000111                                           'PortC.0-3 Ausgänge, Rest Eingänge
Portd.2 = 1                                                 'Pull-Up für Taster an PortD.2 einschalten
Portc.3 = 1                                                 'Pull-Up für Taster an PortC.3 einschalten
Portc.4 = 1                                                 'Pull-Up für Taster an PortC.4 einschalten
Portc.5 = 1                                                 'Pull-Up für Taster an PortC.5 einschalten

'Sirene + Interrupt
Config Timer0 = Timer , Prescale = 64
On Timer0 On_timer0
Enable Interrupts
Dim Timer0_value As Byte

'Interrupt für Taster
Enable Int0                                                 'Interrupt 0 einschalten
On Int0 Tasterdruck                                         'Beim Interrupt Tasterdruck ausführen
Config Int0 = Falling                                       'H/L-Flanke für INT0

'Variablen
Dim Displaystates(16) As Byte                               'Array, welches die verschiedenen Zustände der 7-Segment-Anzeige enthält

Dim Count As Integer                                        'Benutzt für Loops
Count = 0

Dim Amode As Byte                                           'Durch Terminal ausgewählter Modus (0=Aus, 1=Ein oder 2=Test) (AMode, da Mode ein Keyword für den Compiler ist)

Dim Lastline As String * 25                                 'Letzte gelesene Eingabe durch ReadLine

Dim Check_ok As Bit                                         'Gibt an, ob der letzte Check ok war
Check_ok = 1

Dim Bypass As Bit                                           'Bypass für den Alarm, wenn geheimer Taster gedrückt wurde
Bypass = 0

Dim Countdown_next_buzzer As Integer                        'Zeitpunkt im Countdown, wann der nächste Beep-Ton einsetzen soll
Countdown_next_buzzer = 0

Dim Countdown_next_buzzer_delay As Integer                  'Für die nächste Verschiebung des Beep-Tons im Countdown
Countdown_next_buzzer_delay = 1000

Dim Countdown_display_number As Integer
Countdown_display_number = 0

Dim Buzzer_frequency As Byte                                'Für die Tonlage des Buzzers
Buzzer_frequency = 80

Dim Buzzer_delay As Integer                                 'Für die länge des Beep-Ton
Buzzer_delay = 500

Dim Ignoreddoors As Byte                                    'Byte, um die zu ignorierenden Türen nach rechtzeitigem Abschalten des Countdowns zu speichern
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
    Gosub Check                                             'Einen Check ausführen und eventuell Alarmanlage auslösen

    If Check_ok = 0 Then
      Gosub Countdown
    End If
  End If
Loop
End
'------------------------------------Labels-------------------------------------
Setupdisplaystates:                                         'Initialisiert die verschiedenen Zustände der 7-Segment-Anzeige
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

Selectmode:                                                 'Lässt den Nutzer einen Modus auswählen
  Print "In welchem Modus soll gestartet werden?"
  Print "Aus"
  Print "Normal"
  Print "Test"
  Call Readline()                                           'Ließt ganze Zeile ein und speichert sie in Variable LastLine

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

Check:                                                      'Führt einen Check aus und löst eventuell die Alarmanlage aus
  Check_ok = 1                                              'Standardmäßig erfolgreich

  If Tuer1 = 1 And Ignoreddoors.1 = 0 Then                  'Wenn eine Tür offen ist und nicht ignoriert werden soll, schlägt der Check fehö
    Check_ok = 0
  End If
  If Tuer2 = 1 And Ignoreddoors.2 = 0 Then
    Check_ok = 0
  End If
  If Tuer3 = 1 And Ignoreddoors.3 = 0 Then
    Check_ok = 0
  End If

  If Tuer1 = 0 And Ignoreddoors.1 = 1 Then                  'Wenn eine Tür geschlossen ist und ignoriert werden soll, wird sie nicht mehr ignoriert
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
  While Count > 100 And Bypass = 0                          'While anstatt for, um Count in der Schleife modifizieren zu können
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
    If Tuer1 = 1 Then                                       'Türen, welche nach Bypass offen sind, bis zum Schließen ignorieren
      Ignoreddoors.1 = 1
    End If
    If Tuer2 = 1 Then
      Ignoreddoors.2 = 1
    End If
    If Tuer3 = 1 Then
      Ignoreddoors.3 = 1
    End If
    Bypass = 0                                              'Bypass zurücksetzen
  Else                                                      'Wenn Countdown abgelaufen und kein Bypass
    Gosub Sirene
  End If
Return

Beep:                                                       'Lässt den Buzzer piepen
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
Sub Readline()                                              'Ließt eine ganze Zeile vom Nutzer ein
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
On_timer0:                                                  'Schaltet den Buzzer in unterschiedlichen Abständen ein und aus, um Töne zu erzeugen
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