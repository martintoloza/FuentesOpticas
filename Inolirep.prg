// Programa.: CAOLIVED.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Lista Reposiciones.
#include "FiveWin.ch"

MEMVAR oApl

PROCEDURE InoLiRep( lResu )
   LOCAL oDlg, oGet := ARRAY(8), aOpc := { "   ","C",DATE(),DATE(),0,.f.,"N" }
   LOCAL aRep := { {|| ListoRep( aOpc ) },"Listar Reposiciones" }
   DEFAULT lResu := .f.
If lResu
   aRep := { {|| ListoRes( aOpc ) },"Resumen Reposiciones" }
EndIf
DEFINE DIALOG oDlg TITLE aRep[2] FROM 0, 0 TO 13,56
   @ 02, 00 SAY "Optica" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 02,102 GET oGet[1] VAR aOpc[1] OF oDlg PICTURE "@!" ;
      VALID EVAL( {|| If( EMPTY( aOpc[1] ), .t.         ,;
                     (If( oApl:oEmp:Seek( {"localiz",aOpc[1]} ),;
                      (nEmpresa( .t. ), .t. )           ,;
                      (MsgStop("Esta Optica NO EXISTE"), .f.) ))) } );
      SIZE 24,12 PIXEL WHEN !lResu
   @ 16, 00 SAY "A PRECIO COSTO O PUBLICO" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 16,102 GET oGet[2] VAR aOpc[2] OF oDlg PICTURE "!"            ;
      VALID If( aOpc[2] $ "CP", .t., .f. )   SIZE 08,12 PIXEL
   @ 30, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 30,102 GET oGet[3] VAR aOpc[3] OF oDlg  SIZE 44,12 PIXEL
   @ 44, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 44,102 GET oGet[4] VAR aOpc[4] OF oDlg ;
      VALID aOpc[4] >= aOpc[3] SIZE 44,12 PIXEL
   @ 58, 00 SAY  "NUMERO DE LA REPOSICION" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 58,102 GET oGet[5] VAR aOpc[5] OF oDlg PICTURE "999999" SIZE 44,12 PIXEL;
      WHEN !lResu
   @ 58,160 CHECKBOX oGet[6] VAR aOpc[6] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 74, 50 BUTTON oGet[7] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION      ;
      (oGet[7]:Disable(), aOpc[2] := If( aOpc[2] == "C", "costo", "publi"),;
       EVAL( aRep[1] )  , aOpc[2] := "C", oGet[7]:Enable()                  ,;
       oGet[7]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 74,100 BUTTON oGet[8] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 80, 02 SAY "[INOLIREP]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
PROCEDURE ListoRep( aLS )
   LOCAL aRep := { 0,0,0,0,0,0,"999,999,999","","",0 }, aRes, hRes, cQry, nL, nK
   LOCAL oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"","","C O D I G O- DESCRIPCION O REFEREN"+;
          "CIA            TAMANO   CANTIDAD  PRECI."+UPPER(aLS[2]) },aLS[6] )
If !EMPTY( aLS[1] )
   aRep[8] := "c.optica = " + LTRIM(STR(oApl:nEmpresa)) + " AND "
EndIf
cQry := "SELECT c.optica, c.numrep, c.fecharep, d.codigo, d.cantidad, d.p"+aLS[2] +;
              ", d.grupo, c.despub, i.descrip, i.tamano, i.indiva "   +;
        "FROM cadrepoc c, cadrepod d, cadinven i "    +;
        "WHERE " + aRep[8]                            +;
              "c.fecharep >= " + xValToChar( aLS[3] ) +;
         " AND c.fecharep <= " + xValToChar( aLS[4] ) + If( aLS[5] > 0,;
         " AND c.numrep = " + LTRIM(STR(aLS[5])), "" )+;
         " AND d.numrep = c.numrep"                   +;
         " AND d.indica <> 'B' AND i.codigo = d.codigo ORDER BY c.numrep"
aRep[8] := If( aLS[7] == "N", "1", "6" )
aRep[9] := If( aLS[7] == "N", "4", "6" )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aLS[5] := 0
EndIf
While nL > 0
   If aLS[5]  # aRes[2]
      aLS[5]   := aRes[2]
      aRep[10] := aRes[8]
      AFILL( aRep,0,2,4 )
      oApl:oEmp:Seek( {"optica",aRes[1]} )
      oApl:cEmpresa := ALLTRIM( oApl:oEmp:NOMBRE )
      oRpt:aEnc[1] := "REPOSICION No." + STR(aRes[2],6)
      oRpt:aEnc[2] := NtChr( aRes[3],"3" )
      oRpt:nL    := 67
      oRpt:nPage := 0
   EndIf
   If aRes[7] >= aRep[8] .AND. aRes[7] <= aRep[9]
      oRpt:Titulo( 79 )
      oRpt:Say( oRpt:nL,00,aRes[04] )
      oRpt:Say( oRpt:nL,13,aRes[09],33 )
      oRpt:Say( oRpt:nL,49,aRes[10] + {""," *"}[aRes[11]+1] )
      oRpt:Say( oRpt:nL,59,TRANSFORM( aRes[05],"99,999") )
      oRpt:Say( oRpt:nL,68,TRANSFORM( aRes[06],aRep[7] ) )
      nK      :=  aRes[11] + 4
      aRep[2] +=  aRes[05]
      aRep[3] += (aRes[05] * aRes[06])
      aRep[nK]+= (aRes[05] * aRes[06])
      oRpt:nL++
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aLS[5] # aRes[2]
      If aRep[2] > 0
         oRpt:Say(  oRpt:nL,00,REPLICATE("_",79) )
         oRpt:Say(++oRpt:nL,40,"TOTAL REPOSICION ==>" )
         oRpt:Say(  oRpt:nL,60,TRANSFORM(aRep[02],"99,999") )
         oRpt:Say(  oRpt:nL,68,TRANSFORM(aRep[03],aRep[7] ) )
         oRpt:Say(++oRpt:nL,13,TRANSFORM(aRep[10],"999.99")+;
                     "% de Descuento" )
         oRpt:Say(  oRpt:nL,46,"SUMINISTRO    GRAVADO "+TRANSFORM(aRep[5],aRep[7]) )
         oRpt:Say(++oRpt:nL,46,"SUMINISTRO NO GRAVADO "+TRANSFORM(aRep[4],aRep[7]) )
         oRpt:NewPage()
      EndIf
   EndIf
EndDo
oRpt:End()
oApl:oEmp:Seek( {"optica",oApl:nEmpresa} )
oApl:cEmpresa := ALLTRIM( oApl:oEmp:NOMBRE )
RETURN

//------------------------------------//
STATIC PROCEDURE ListoRes( aLS )
   LOCAL aRes, hRes, cQry, nL, nK, aRpd := { 0,0,0,0,0,0 }
   LOCAL oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"RESUMEN DE REPOSICIONES",;
         "DESDE " + NtChr( aLS[3],"2" ) + " HASTA " + NtChr( aLS[4],"2" ),;
         "No.Repos. Optica  Valor Repos. Cant.Montu. Cant.Liqui. Cant.Acce"+;
         "s. Cant.Conta." },aLS[6] )
cQry := "SELECT c.optica, c.numrep, d.grupo, CAST(SUM(d.cantidad) AS UNSIGNED INTEGER), SUM(d.cantidad*d.p"+;
        aLS[2] + ") FROM cadrepoc c, cadrepod d "    +;
        "WHERE c.fecharep >= " + xValToChar( aLS[3] )+;
         " AND c.fecharep <= " + xValToChar( aLS[4] )+;
         " AND d.numrep = c.numrep"                  +;
         " AND d.indica <> 'B' GROUP BY c.numrep, d.grupo ORDER BY c.numrep"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aLS[1] := ArrayValor( oApl:aOptic,STR(aRes[1],2) )
   aLS[5] := aRes[2]
EndIf
While nL > 0
   If (nK := AT(aRes[3],"134")) > 0
      nK := { 1,2,3 }[nK]
   Else
      nK := 4
   EndIf
   aRpd[nK] += aRes[4]
   aRpd[05] += aRes[5]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aLS[5] # aRes[2]
      oRpt:Titulo( 78 )
      oRpt:Say( oRpt:nL,02,STR(aLS[5],7) )
      oRpt:Say( oRpt:nL,13,aLS[1] )
      oRpt:Say( oRpt:nL,19,TRANSFORM(aRpd[5],"999,999,999") )
      oRpt:Say( oRpt:nL,34,TRANSFORM(aRpd[1],"@Z 999,999") )
      oRpt:Say( oRpt:nL,46,TRANSFORM(aRpd[2],"@Z 999,999") )
      oRpt:Say( oRpt:nL,58,TRANSFORM(aRpd[3],"@Z 999,999") )
      oRpt:Say( oRpt:nL,70,TRANSFORM(aRpd[4],"@Z 999,999") )
      oRpt:nL ++
      aLS[1]  := ArrayValor( oApl:aOptic,STR(aRes[1],2) )
      aLS[5]  := aRes[2]
      aRpd[6] += aRpd[5]
      AFILL( aRpd,0,1,5 )
   EndIf
EndDo
If aRpd[6] > 0
   oRpt:Say(  oRpt:nL,01,REPLICATE("_",78) )
   oRpt:Say(++oRpt:nL,04,"GRAN TOTAL ==>" )
   oRpt:Say(  oRpt:nL,19,TRANSFORM(aRpd[6],"999,999,999") +;
              "    " + UPPER(aLS[2]) )
EndIf
oRpt:NewPage()
oRpt:End()
RETURN