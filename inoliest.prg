// Programa.: INOLIEST.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Estadisticas de Monturas por Optica por Proveedor.
#include "FiveWin.ch"
#include "Btnget.ch"

MEMVAR oApl

PROCEDURE InoLiEst( lResu )
   LOCAL oGet := ARRAY(11), aOpc := { 0,1,CTOD(""),DATE(),4,oApl:nUS,.f.,"",.f. }
   LOCAL oDlg, oNi := TNits(), aMone, aEsta, aRep
   DEFAULT lResu := .f.
If lResu
   aRep := { {|| ListoESI( aOpc ) },"Estadistica Ingresos Monturas",;
                 "A PRECIO [C/P]","CUAL" }
   aEsta := { "Costo","Público" }
   aMone := { {"Ingresos","I"},{"Reposiciones","R"},{"Todas","T"} }
Else
   aRep := { {|| ListoEST( aOpc ) },"Estadistica Monturas por Prov.",;
                 "Situación [E/V]","MONEDA" }
   aEsta := { "Existente","Vendida" }
   aMone := ArrayCombo( "MONEDA" )
   AADD( aMone, {"Todas","T"} )
EndIf
aOpc[5] := LEN( aMone )
oNi:New()
DEFINE DIALOG oDlg TITLE aRep[2] FROM 0, 0 TO 15,60
   @ 02, 00 SAY "Proveedor por Default Todos" OF oDlg RIGHT PIXEL SIZE 90,08
   @ 02, 92 BTNGET oGet[1] VAR aOpc[1] OF oDlg PICTURE "9999999999";
      VALID EVAL( {|| If( EMPTY( aOpc[1] ), .t.                   ,;
              (If( oNi:oDb:Seek( {"codigo",aOpc[1]} )             ,;
              ( oGet[2]:Settext( oNi:oDb:NOMBRE ) , .t. )         ,;
              ( MsgStop("Este NIT no Existe ...."), .f. ) ))) } )  ;
      SIZE 54,12 PIXEL      RESOURCE "BUSCAR"                      ;
      ACTION EVAL({|| If(oNi:Mostrar(), (aOpc[1] := oNi:oDb:CODIGO,;
                         oGet[1]:Refresh() ),) })
   @ 02,150 SAY oGet[2] VAR aOpc[8] OF oDlg PIXEL SIZE 100,20 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 16, 00 SAY      aRep[3]        OF oDlg RIGHT PIXEL SIZE 90,10
   @ 16, 92 COMBOBOX oGet[3] VAR aOpc[2] ITEMS aEsta SIZE 50,99 OF oDlg PIXEL
   @ 30, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 30, 92 GET oGet[4] VAR aOpc[3] OF oDlg  SIZE 40,12 PIXEL
   @ 44, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 44, 92 GET oGet[5] VAR aOpc[4] OF oDlg ;
      VALID aOpc[4] >= aOpc[3] SIZE 40,12 PIXEL
   @ 44,140 CHECKBOX oGet[6] VAR aOpc[9] PROMPT "A Costo" OF oDlg ;
      WHEN !lResu  SIZE 60,12 PIXEL
   @ 58, 00 SAY      aRep[4]        OF oDlg RIGHT PIXEL SIZE 90,10
   @ 58, 92 COMBOBOX oGet[7] VAR aOpc[5] ITEMS ArrayCol( aMone,1 ) SIZE 50,99 ;
      OF oDlg PIXEL
   @ 72, 00 SAY "VALOR  DEL  DOLAR" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 72, 92 GET oGet[8] VAR aOpc[6] OF oDlg PICTURE "9,999" SIZE 30,12 PIXEL
   @ 72,140 CHECKBOX oGet[9] VAR aOpc[7] PROMPT "Vista &Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 88, 50 BUTTON oGet[10] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[10]:Disable(), aOpc[5] := aMone[aOpc[5],2],;
        EVAL( aRep[1] ), oDlg:End() ) PIXEL
   @ 88,100 BUTTON oGet[11] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 94, 02 SAY "[INOLIEST]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT (Empresa() )
RETURN

//------------------------------------//
PROCEDURE InoLiEsm()
   LOCAL oGet := ARRAY(8), aOpc := { 0,1,NtChr( DATE(),"1" ),oApl:nUS,.f.,"" }
   LOCAL oDlg, oNi := TNits()
oNi:New()
DEFINE DIALOG oDlg TITLE "Estadisticas del Inventario" FROM 0, 0 TO 10,60
   @ 02, 00 SAY "Proveedor por Default Todos" OF oDlg RIGHT PIXEL SIZE 90,08
   @ 02, 92 BTNGET oGet[1] VAR aOpc[1] OF oDlg PICTURE "9999999999";
      VALID EVAL( {|| If( EMPTY( aOpc[1] ), .t.                   ,;
              (If( oNi:oDb:Seek( {"codigo",aOpc[1]} )             ,;
              ( oGet[2]:Settext( oNi:oDb:NOMBRE ) , .t. )         ,;
              ( MsgStop("Este NIT no Existe ...."), .f. ) ))) } )  ;
      SIZE 54,12 PIXEL      RESOURCE "BUSCAR"                      ;
      ACTION EVAL({|| If(oNi:Mostrar(), (aOpc[1] := oNi:oDb:CODIGO,;
                         oGet[1]:Refresh() ),) })
   @ 02,150 SAY oGet[2] VAR aOpc[6] OF oDlg PIXEL SIZE 100,20 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 16, 00 SAY           "A PRECIO [C/P]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 16, 92 COMBOBOX oGet[3] VAR aOpc[2] ITEMS { "Costo","Público" };
      SIZE 50,99 OF oDlg PIXEL
   @ 30, 00 SAY  "DIGITE AÑO Y MES [AAMM]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 30, 92 GET oGet[4] VAR aOpc[3] OF oDlg  SIZE 30,12 PIXEL
   @ 44, 00 SAY "VALOR  DEL  DOLAR" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 44, 92 GET oGet[5] VAR aOpc[4] OF oDlg PICTURE "9,999" SIZE 30,12 PIXEL
   @ 44,140 CHECKBOX oGet[6] VAR aOpc[5] PROMPT "Vista &Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 60, 50 BUTTON oGet[7] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[7]:Disable(), ListoESM( aOpc ), oDlg:End() ) PIXEL
   @ 60,100 BUTTON oGet[8] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 66, 02 SAY "[INOLIEST]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT (Empresa() )
RETURN

//------------------------------------//
STATIC PROCEDURE ListoEST( aLS )
   LOCAL oRpt, nPos, nF, nTotal := 0
   LOCAL aRes, hRes, cQry, nL
   LOCAL aEst := PrecioEst()
aLS[8]:= If( aLS[9], "pcosto", If( aLS[2] == 1, "ppubli", "pvendida" ))
aRes := " AND moneda " + If( aLS[5] == "T", "IN(' ','U','C')", "= '"+aLS[5]+"'" )
cQry := "SELECT material, sexo, moneda, " + aLS[8]  +;
        " FROM cadinven WHERE LEFT(Codigo,2) = '01'"+;
        " AND optica = " + LTRIM(STR(oApl:nEmpresa))+;
        " AND situacion = "
do Case
Case aLS[2] == 1
   cQry += "'E'" + aRes
Case aLS[2] == 2 .AND. aLS[1] == 0
   cQry += "'V' AND fecventa >= " + xValToChar( aLS[3] ) +;
              " AND fecventa <= " + xValToChar( aLS[4] ) + aRes
OtherWise
   cQry += "'V' AND fecventa >= " + xValToChar( aLS[3] ) +;
              " AND fecventa <= " + xValToChar( aLS[4] ) +;
              " AND codigo_nit= " + LTRIM(STR(oApl:oNit:CODIGO_NIT)) + aRes
EndCase
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
aLS[6] := If( aLS[2] == 1, aLS[6], 1 )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[4] := Dolar_Peso( aLS[6],aRes[4],aRes[3] )
   nTotal  += aRes[4]
   nPos := If( aRes[1] == "P", 2, 5 ) + AT( aRes[2],"MFU" )
   FOR nF := 1 TO LEN( aEst )
      If Rango( aRes[4],aEst[nF,1],aEst[nF,2] )
         aEst[nF,nPos]++
         Exit
      EndIf
   NEXT
   nL --
EndDo
MSFreeResult( hRes )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"ESTADISTICA DE MONTURAS - ","","",""},aLS[7] )
oRpt:aEnc[1] += {" ","CARTIER","CONSIGNACION","TODAS"}[AT(aLS[5]," UCT")]
oRpt:aEnc[2] := {"EN EXISTENCIAS ","VENDIDAS DESDE "}[aLS[2]] + ;
          NtChr( aLS[3],"2" ) + " HASTA " + NtChr( aLS[4],"2" )
oRpt:aEnc[3] := PADC( UPPER(aLS[8]),20 )
LisEstadis( oRpt,aEst,aLS[1],nTotal )
RETURN

//------------------------------------//
STATIC PROCEDURE ListoESI( aLS )
   LOCAL oRpt, aEst, nPos, nF, nTotal := 0
   LOCAL aRes, hRes, cQry, nL
   LOCAL cCam := If( aLS[2] == 1, "C", NIL )
aEst := PrecioEst( cCam )
cCam := If( aLS[2] == 1, "pcosto", "ppubli" )
If aLS[5] $ "IT"
   cQry := "SELECT c.moneda, d.material, d.sexo, d.cantidad, d."+cCam+;
           " FROM comprasc c, cadmontd d "                 +;
           "WHERE c.optica = " + LTRIM(STR(oApl:nEmpresa)) +;
            " AND c.fecingre >= " + xValToChar( aLS[3] )   +;
            " AND c.fecingre <= " + xValToChar( aLS[4] )   + If( aLS[1] > 0,;
            " AND c.codigo_nit= " + LTRIM(STR(oApl:oNit:CODIGO_NIT)), "" ) +;
            " AND c.moneda <> 'X'"                         +;
            " AND d.ingreso = c.ingreso"                   +;
            " AND d.indica <> 'B'"
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   While nL > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      aRes[5] := Dolar_Peso( aLS[6],aRes[5],aRes[1] )
      nTotal  += (aRes[5] * aRes[4])
      nPos := If( aRes[2] == "P", 2, 5 ) + AT( aRes[3],"MFU" )
      FOR nF := 1 TO LEN( aEst )
         If Rango( aRes[5],aEst[nF,1],aEst[nF,2] )
            aEst[nF,nPos]+= aRes[4]
            EXIT
         EndIf
      NEXT
      nL --
   EndDo
   MSFreeResult( hRes )
EndIf
If aLS[5] $ "RT"
   cQry := "SELECT i.moneda, i.material, i.sexo, d.cantidad, d."+cCam+;
           " FROM cadrepoc c, cadrepod d, cadinven i "     +;
           "WHERE c.optica = " + LTRIM(STR(oApl:nEmpresa)) +;
            " AND c.fecharep >= " + xValToChar( aLS[3] )   +;
            " AND c.fecharep <= " + xValToChar( aLS[4] )   +;
            " AND d.numrep = c.numrep"                     +;
            " AND d.indica <> 'B'"                         +;
            " AND d.grupo  = '1'"                          +;
            " AND i.codigo = d.codigo"                     + If( aLS[1] > 0,;
            " AND i.codigo_nit= " + LTRIM(STR(oApl:oNit:CODIGO_NIT)), "" )
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   While nL > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      aRes[5] := Dolar_Peso( aLS[6],aRes[5],aRes[1] )
      nTotal  += (aRes[5] * aRes[4])
      nPos := If( aRes[2] == "P", 2, 5 ) + AT( aRes[3],"MFU" )
      FOR nF := 1 TO LEN( aEst )
         If Rango( aRes[5],aEst[nF,1],aEst[nF,2] )
            aEst[nF,nPos]+= aRes[4]
            EXIT
         EndIf
      NEXT
      nL --
   EndDo
   MSFreeResult( hRes )
EndIf
cCam  := { "SOLAMENTE INGRESOS","SOLAMENTE REPOSICIONES",;
           "INGRESOS MAS REPOSICIONES" }[AT(aLS[5],"IRT")]
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"ESTADISTICA INGRESOS DE MONTURAS"   ,;
           "DESDE " + NtChr( aLS[3],"2" ) + " HASTA " + NtChr( aLS[4],"2" ),;
           cCam,"",""},aLS[7] )
LisEstadis( oRpt,aEst,aLS[1],nTotal )
RETURN

//------------------------------------//
STATIC PROCEDURE ListoESM( aLS )
   LOCAL oRpt, aEst, nPos, nF, nTotal := 0
   LOCAL aRes, hRes, cQry, nL
aEst := PrecioEst( If( aLS[2] == 1, "C", NIL ) )
cQry := "SELECT i.moneda, i.material, i.sexo, s.existencia, "+;
                 If( aLS[2] == 1, "s.pcosto ", "i.ppubli " ) +;
        "FROM cadinvme s, cadinven i "                  +;
        "WHERE s.optica = " + LTRIM(STR(oApl:nEmpresa)) +;
        " AND LEFT(s.codigo,2) = '01'"                  +;
        " AND s.anomes = (SELECT MAX(anomes) FROM cadinvme m " +;
                         "WHERE m.optica = s.optica"           +;
                          " AND m.codigo = s.codigo"           +;
                          " AND m.anomes <= '" + aLS[3] + "')" +;
        " AND s.existencia <> 0"                               +;
        " AND i.codigo = s.codigo"             + If( aLS[1] > 0,;
        " AND i.codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT)), "" )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[5] := Dolar_Peso( aLS[4],aRes[5],aRes[1] )
   nTotal  += aRes[5]
   nPos := If( aRes[2] == "P", 2, 5 ) + AT( aRes[3],"MFU" )
   FOR nF := 1 TO LEN( aEst )
      If Rango( aRes[5],aEst[nF,1],aEst[nF,2] )
         aEst[nF,nPos]+= aRes[4]
         EXIT
      EndIf
   NEXT
   nL --
EndDo
MSFreeResult( hRes )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"ESTADISTICA INVENTARIO DE MONTURAS",;
           "EN ","",""},aLS[5] )
oRpt:aEnc[2] += NtChr( NtChr( aLS[3],"F" ),"6" ) + ;
          " A PRECIO " + If( aLS[2] == 1, "COSTO", "PUBLICO" )
LisEstadis( oRpt,aEst,aLS[1],nTotal )
RETURN

//------------------------------------//
PROCEDURE LisEstadis( oRpt,aEst,nProv,nTotal )
   LOCAL aCan := { 0, 0, 0, 0, 0, 0, 0, 0 }, nF := LEN(oRpt:aEnc)
If nProv # 0
   oRpt:aEnc[1]    += " POR PROVEEDOR"
   oRpt:aEnc[nF-1] += oApl:oNit:NOMBRE
EndIf
oRpt:aEnc[nF] := "--DESDE--  --HASTA--  P.HOMBRE  P.MUJER  P.UNISEX  M.HOMBRE  M.MUJER  M.UNISEX"
FOR nF := 1 TO LEN( aEst )
   oRpt:Titulo( 79 )
   oRpt:Say( oRpt:nL,01,TRANSFORM(aEst[nF,1], "9,999,999") )
   oRpt:Say( oRpt:nL,11,TRANSFORM(aEst[nF,2],"99,999,999") )
   oRpt:Say( oRpt:nL,26,TRANSFORM(aEst[nF,3],"9,999") )
   oRpt:Say( oRpt:nL,35,TRANSFORM(aEst[nF,4],"9,999") )
   oRpt:Say( oRpt:nL,45,TRANSFORM(aEst[nF,5],"9,999") )
   oRpt:Say( oRpt:nL,55,TRANSFORM(aEst[nF,6],"9,999") )
   oRpt:Say( oRpt:nL,64,TRANSFORM(aEst[nF,7],"9,999") )
   oRpt:Say( oRpt:nL,74,TRANSFORM(aEst[nF,8],"9,999") )
   oRpt:nL ++
   aCan[1] += aEst[nF,3]
   aCan[2] += aEst[nF,4]
   aCan[3] += aEst[nF,5]
   aCan[4] += aEst[nF,6]
   aCan[5] += aEst[nF,7]
   aCan[6] += aEst[nF,8]
NEXT
aCan[7] := aCan[1] + aCan[2] + aCan[3]
aCan[8] := aCan[4] + aCan[5] + aCan[6]
oRpt:Say( oRpt:nL++,01,REPLICATE("_",78) )
oRpt:Say( oRpt:nL  ,08,"TOTALES --->" )
oRpt:Say( oRpt:nL  ,25,TRANSFORM(aCan[1],"99,999") )
oRpt:Say( oRpt:nL  ,34,TRANSFORM(aCan[2],"99,999") )
oRpt:Say( oRpt:nL  ,44,TRANSFORM(aCan[3],"99,999") )
oRpt:Say( oRpt:nL  ,54,TRANSFORM(aCan[4],"99,999") )
oRpt:Say( oRpt:nL  ,63,TRANSFORM(aCan[5],"99,999") )
oRpt:Say( oRpt:nL++,73,TRANSFORM(aCan[6],"99,999") )
oRpt:Say( oRpt:nL++,01,REPLICATE("=",78) )
oRpt:Say( oRpt:nL++,08,"TOTAL PASTA     "+ TRANSFORM(aCan[7],"999,999") )
oRpt:Say( oRpt:nL++,08,"TOTAL METAL     "+ TRANSFORM(aCan[8],"999,999") )
oRpt:Say( oRpt:nL++,08,REPLICATE("=",23) )
oRpt:Say( oRpt:nL++,08,"GRAN  TOTAL     "+ TRANSFORM(aCan[7]+aCan[8],"999,999"))
oRpt:Say( oRpt:nL++,08,"TOTAL VALOR " + TRANSFORM(nTotal,"999,999,999") )
oRpt:NewPage()
oRpt:End()
RETURN

//------------------------------------//
STATIC FUNCTION PrecioEst( cPrecio )
   LOCAL aEst := {}, aRes, hRes, cQry, nL
   DEFAULT cPrecio := oApl:oEmp:PRECIO
cQry := "SELECT costodesde, costohasta FROM cadestmo WHERE precio = "+;
        xValToChar( cPrecio ) + " ORDER BY costodesde"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   AADD( aEst, { aRes[1], aRes[2], 0, 0, 0, 0, 0, 0 } )
   nL --
EndDo
MSFreeResult( hRes )
RETURN aEst