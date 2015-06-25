// Programa.: CAOLIHOY.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Facturas con Ordenes Para HOY
#include "FiveWin.ch"
#include "Btnget.ch"

MEMVAR oApl

PROCEDURE Diferido()
   LOCAL oDlg, oDp, oGet := ARRAY(6), aLS := { SPACE(15),"",DATE(),.t.,0,"" }
 oDp := TPer() ; oDp:NEW()
DEFINE DIALOG oDlg TITLE "Consultar los Diferidos" FROM 0,0 TO 08,46
   @ 02,00 SAY "Doc. Identidad" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 02,82 BTNGET oGet[1] VAR aLS[1] OF oDlg       ;
      ACTION EVAL({|| If( oDp:Mostrar( ,3,aLS[1] ),;
                        ( aLS[1] := oDp:oDb:NROIDEN, oGet[1]:Refresh() ),) })  ;
      VALID EVAL( {|| If( oDp:Buscar( aLS[1],"nroiden",.t. )        ,;
                        ( aLS[2] := XTRIM(oDp:oDb:NOMBRES) + oDp:oDb:APELLIDOS,;
                          aLS[5] := oDp:oDb:CODIGO_NIT              ,;
                          oGet[2]:Settext( aLS[2] ), .t. )          ,;
                ( MsgStop("Este Doc.Identidad no Existe"), .f.) ) } );
      SIZE 50,10 PIXEL RESOURCE "BUSCAR"
   @ 14,10 SAY oGet[2] VAR aLS[2] OF oDlg PIXEL SIZE 130,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 26,00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 26,82 GET oGet[3] VAR aLS[3] OF oDlg  SIZE 40,12 PIXEL
   @ 26,130 CHECKBOX oGet[4] VAR aLS[4] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 40, 50 BUTTON oGet[5] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[5]:Disable(), ListoDif( aLS ), oGet[5]:Enable(),;
        oGet[5]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 40,100 BUTTON oGet[6] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 44, 02 SAY "[CAOLIHOY]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
oDp:NEW( "FIN" )
RETURN

//------------------------------------//
PROCEDURE ListoDif( aLS )
   LOCAL aPG, aRC, aRes, cQry, hRes, nL, nP, oRpt
If oApl:oEmp:PRINCIPAL == 18
   aLS[6] := "IN(18,21)"
   oApl:nEmpresa := 18
Else
   aLS[6] := "= " + LTRIM(STR(oApl:nEmpresa))
EndIf
/*
SELECT c.numero, c.numfac, p.rcaja, p.fecha, p.pagado, p.formapago, p.numcheque
FROM cadantip p, cadantic c , historia h
WHERE c.optica = p.optica
  AND c.numero = p.numero
  AND c.optica = 21
  AND c.codigo_cli = h.codigo_nit
  AND h.nroiden    = '810114'
ORDER BY c.numero, c.numfac
*/
cQry := "SELECT c.numero, c.numfac, p.rcaja, p.fecha, p.pagado - IFNULL(p.p_de_mas,0)"+;
             ", p.formapago, p.numcheque "          +;
        "FROM cadantip p, cadantic c , historia h " +;
        "WHERE c.optica = p.optica"                 +;
         " AND c.numero = p.numero"                 +;
         " AND c.optica " + aLS[6]                  +;
         " AND c.codigo_cli = h.codigo_nit"         +;
         " AND h.nroiden    = " + xValToChar(aLS[1])+;
         " ORDER BY c.numero, c.numfac"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRC  := { aRes[1],aRes[2],0,0,1,"" }
Else
   aRC  := { 0,0,0,0,1,"" }
EndIf
cQry := "SELECT rcaja, fecpag, pagado - IFNULL(p_de_mas,0), formapago, numcheque "+;
        "FROM cadpagos "                             +;
        "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND numfac = [FAC]"                       +;
         " AND pordonde = 'A'"
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"LISTADO DE DIFERIDOS",aLS[2],;
          "  R.CAJA     ANT./FACT.   F E C H A      D E B I T O   C R E D I T O"},aLS[4] )
//345678  1234567890  01-NOV-2012  999,999,999.00  999,999,999.00
While nL > 0
   aRC[4] += aRes[5]
   oRpt:Titulo( 80 )
   oRpt:Say( oRpt:nL,00,STR(aRes[3],8) )
   oRpt:Say( oRpt:nL,10,STR(aRC[5],2) +"."+STR(aRes[1]) )
   oRpt:Say( oRpt:nL,25,NtChr( aRes[4],"2" ) )
   oRpt:Say( oRpt:nL,54,TRANSFORM(aRes[5],"999,999,999.99") )
   oRpt:nL ++
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aRC[1] # aRes[1]
      If aRC[2] > 0
         aPG := Buscar( STRTRAN( cQry,"[FAC]",LTRIM(STR(aRC[2])) ),"CM",,9 )
         FOR nP := 1 TO LEN(aPG)
            aRC[3] += aPG[nP,3]
            oRpt:Titulo( 80 )
            oRpt:Say( oRpt:nL,00,STR(aPG[nP,1],8) )
            oRpt:Say( oRpt:nL,10,STR(aRC[5],2) +"."+STR(aRC[2]) )
            oRpt:Say( oRpt:nL,25,NtChr( aPG[nP,2],"2" ) )
            oRpt:Say( oRpt:nL,38,TRANSFORM(aPG[nP,3],"999,999,999.99") )
            oRpt:nL ++
         NEXT nP
      EndIf
      aRC[1] := aRes[1]
      aRC[2] := aRes[2]
      aRC[5] ++
   EndIf
EndDo
MSFreeResult( hRes )

cQry := "SELECT numero, numfac, fecha, bonos "       +;
        "FROM cadnotac "                             +;
        "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND bonos  > 0"                           +;
         " AND nroiden = " + xValToChar( aLS[1] )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRC[1] := aRes[1]
EndIf
cQry := "SELECT rcaja, numfac, fecpag, pagado, formapago, numcheque "+;
        "FROM cadpagos "                             +;
        "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND fecpag >= [FEC]"                      +;
         " AND numcheque LIKE '%[NC]%'"              +;
         " AND formapago = 4 AND indred = '1'"
While nL > 0
   aRC[4] += aRes[4]
   oRpt:Titulo( 80 )
   oRpt:Say( oRpt:nL,00,"NC"+STR(aRes[1],6) )
   oRpt:Say( oRpt:nL,10,STR(aRC[5],2) +"."+STR(aRes[2]) )
   oRpt:Say( oRpt:nL,25,NtChr( aRes[3],"2" ) )
   oRpt:Say( oRpt:nL,54,TRANSFORM(aRes[4],"999,999,999.99") )
   oRpt:nL ++
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aRC[1] # aRes[1]
      aRC[6] := STRTRAN( cQry,"[FEC]",xValToChar( aRC[3] ) )
      aPG := Buscar( STRTRAN( aRC[6],"[NC]",LTRIM(STR(aRC[1])) ),"CM",,9 )
      FOR nP := 1 TO LEN(aPG)
         aRC[3] += aPG[nP,4]
         oRpt:Titulo( 80 )
         oRpt:Say( oRpt:nL,00,STR(aPG[nP,1],8) )
         oRpt:Say( oRpt:nL,10,STR(aRC[5],2) +"."+STR(aPG[nP,2]) )
         oRpt:Say( oRpt:nL,25,NtChr( aPG[nP,3],"2" ) )
         oRpt:Say( oRpt:nL,38,TRANSFORM(aPG[nP,4],"999,999,999.99") )
         oRpt:nL ++
      NEXT nP
      aRC[1] := aRes[1]
      aRC[5] ++
   EndIf
EndDo
MSFreeResult( hRes )
   oRpt:Say( oRpt:nL,10,"TOTALES ==>" )
   oRpt:Say( oRpt:nL,38,TRANSFORM(aRC[3],"999,999,999.99") )
   oRpt:Say( oRpt:nL,54,TRANSFORM(aRC[4],"999,999,999.99") )
   oRpt:NewPage()
   oRpt:End()
RETURN

//------------------------------------//
PROCEDURE CaoLiHoy()
   LOCAL oDlg, oGet := ARRAY(5), aVta := { DATE(), 1, .f. }
   LOCAL oRpt, lSi := .f.
DEFINE DIALOG oDlg TITLE "Facturas con Ordenes Para HOY" FROM 0,0 TO 08,46
   @ 02, 00 SAY "FECHA DESEADA [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02, 92 GET oGet[1] VAR aVta[1] OF oDlg  SIZE 40,12 PIXEL
   @ 16, 00 SAY "PAGINA INICIAL"           OF oDlg RIGHT PIXEL SIZE 90,10
   @ 16, 92 GET oGet[2] VAR aVta[2] OF oDlg PICTURE "999";
      VALID Rango( aVta[2],1,999 )  SIZE 24,12 PIXEL
   @ 16,120 CHECKBOX oGet[3] VAR aVta[3] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 38, 50 BUTTON oGet[4] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( lSi := .t., oDlg:End() ) PIXEL
   @ 38,100 BUTTON oGet[5] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 44, 02 SAY "[CAOLIHOY]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED

If !lSi
   RETURN
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"LISTADO DE ORDENES PARA HOY"      ,;
           NtChr( aVta[1],"3" )," FACTURA  NRO.ORDEN  NOMBRE DEL CLIENTE"+;
           "    GAV  F.ENTREGA"},aVta[3],aVta[2] )
aVta[2]:= 0
oApl:oFac:Seek( {"optica",oApl:nEmpresa,"fechaent",aVta[1],"orden <> ",0,;
                 "indicador <> ","A"} )
While !oApl:oFac:Eof()
   oRpt:Titulo( 80 )
   oRpt:Say( oRpt:nL,01,STR(oApl:oFac:NUMFAC,7) )
   oRpt:Say( oRpt:nL,09,STR(oApl:oFac:ORDEN) )
   oRpt:Say( oRpt:nL,21,oApl:oFac:CLIENTE )
   oRpt:Say( oRpt:nL,43,STR(oApl:oFac:GAVETA,3) )
   oRpt:Say( oRpt:nL,48,oApl:oFac:FECHAENT )
   oRpt:nL++
   aVta[2]++
   oApl:oFac:Skip(1):Read()
   oApl:oFac:xLoad()
EndDo
If aVta[2] > 0
   oRpt:Say( oRpt:nL  ,00,REPLICATE("_",80) )
   oRpt:Say( oRpt:nL+1,01,STR( aVta[2],3 ) + " FACTURAS" )
EndIf
   oRpt:NewPage()
   oRpt:End()
RETURN

//----Listado de precios al publico---//
PROCEDURE CaoLiPre()
   LOCAL oDlg, oGet := ARRAY(4), aVta := { "", 2, .f.,"","" }
   LOCAL aGrupo := { "M O N T U R A S"   , "L I Q U I D O S", ;
                     "A C C E S O R I O S", "LENTES DE CONTACTO" }
   LOCAL aRes, hRes, nL, cQry, oRpt, lSi := .f.
DEFINE DIALOG oDlg TITLE "Listo Precios al Público" FROM 0, 0 TO 08,40
   @ 02,00 SAY "Grupo a Listar"  OF oDlg RIGHT PIXEL SIZE 60,10
   @ 02,62 COMBOBOX oGet[1] VAR aVta[2] ITEMS aGrupo SIZE 70,36 OF oDlg PIXEL
   @ 18,62 CHECKBOX oGet[2] VAR aVta[3] PROMPT "Vista &Previa"  OF oDlg ;
      SIZE 60,12 PIXEL
   @ 38,40 BUTTON oGet[3] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( lSi := .t., oDlg:End() ) PIXEL
   @ 38,90 BUTTON oGet[4] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 44, 02 SAY "[CAOLIHOY]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED

If !lSi
   RETURN
EndIf
aVta[4] := { '01','03','04','60' }[aVta[2]]
aVta[5] := If( aVta[2] == 4, '90', aVta[4] ) + "99999999"
//aVta[1] := STRTRAN( aVta[4],"0","" )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"PRECIOS AL PUBLICO DE "+aGrupo[aVta[2]],;
          "EN " + NtChr( DATE(),"3" ),"         C O D I G O-"+;
          "  D E S C R I P C I O N----------------- PRECIO PUBLICO"},aVta[3] )
cQry := "SELECT codigo, descrip, ppubli, indiva FROM cadinven "+;
        "WHERE codigo >= '" + aVta[4] +;
        "' AND codigo <= '" + aVta[5] + "'" + If( aVta[2] == 1,;
         " AND situacion = 'E' AND optica = " + LTRIM(STR(oApl:nEmpresa)), "" ) +;
        " ORDER BY codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aRes[3] > 0
      oRpt:Titulo( 76 )
      oRpt:Say( oRpt:nL,09,aRes[1] )
      oRpt:Say( oRpt:nL,23,aRes[2] )
      oRpt:Say( oRpt:nL,65,TRANSFORM(aRes[3],"999,999,999") )
      oRpt:Say( oRpt:nL,77,If( aRes[4] == 1, "*", " " ) )
      oRpt:nL ++
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
   oRpt:NewPage()
   oRpt:End()
RETURN