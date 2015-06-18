LOCAL nP := 5, nT, nM, nF, nC, nI
LOCAL aM := ARRAY(nP,nP)
AEVAL( am, {|x| AFILL( x,0 ) } )

nT := nP * nP               //Total de Elementos
nM := nP / 2 + .5           //Hallar la Mitad
nF := 1
nC := nM

FOR nI := 1 TO nT
   aM[nF,nC] := nI
   nF --
   nC ++
   If nF == 0
      If nC > nP
         nF += 2
         nC --
      Else
         nF := nP
      EndIf
   Else
      If nC > nP
         nC := 1
      EndIf
   EndIf
   If aM[nF,nC] > 0
      nF += 2
      nC --
   EndIf
NEXT nI

nI := (nP * nM) + nT * (nM - 1)  //Total de Cada Fila

