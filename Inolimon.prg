// Programa.: INOLIMON.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Ingresos de Monturas
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE InoLimon( lResu )
   LOCAL oDlg, oGet := ARRAY(11), aOpc := { 0,DATE(),DATE(),0,0,oApl:nUS,1,.f.," " }
   LOCAL aRep := { {|| ListoMon( aOpc ) },"Listar Ingresos de Monturas" }
   LOCAL oNi  := TNits(), aMone := ArrayCombo( "MONEDA" )
   DEFAULT lResu := .f.
If lResu
   aRep := { {|| ListoRes( aOpc ) },"Resumen Ingreso de Monturas" }
   AADD( aMone, {"Todas-Consig","T"} )
   aOpc[7] := 4
EndIf
oNi:New()
DEFINE DIALOG oDlg TITLE aRep[2] FROM 0, 0 TO 15,60
   @ 02, 00 SAY "Proveedor" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02, 92 BTNGET oGet[1] VAR aOpc[1] OF oDlg PICTURE "9999999999";
      ACTION EVAL({|| If(oNi:Mostrar(), (aOpc[1] := oNi:oDb:CODIGO,;
                         oGet[1]:Refresh() ),) })                  ;
      VALID EVAL( {|| If( EMPTY( aOpc[1] ), .t.                   ,;
                    ( If( oNi:Buscar( aOpc[1],"codigo",.t. )      ,;
                        ( oGet[11]:Settext( oNi:oDb:NOMBRE), .t. ),;
                (MsgStop("Este Proveedor no Existe"), .f.) ) )) } );
      WHEN !lResu                                                  ;
      SIZE 50,10 PIXEL RESOURCE "BUSCAR"
   @ 02,138 SAY oGet[11] VAR aOpc[9] OF oDlg PIXEL SIZE 96,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 14, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 14, 92 GET oGet[2] VAR aOpc[2] OF oDlg  SIZE 40,10 PIXEL
   @ 26, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 26, 92 GET oGet[3] VAR aOpc[3] OF oDlg ;
      VALID aOpc[3] >= aOpc[2] SIZE 40,10 PIXEL
   @ 38, 00 SAY "Nro. INGRESO INICIAL"     OF oDlg RIGHT PIXEL SIZE 90,10
   @ 38, 92 GET oGet[4] VAR aOpc[4] OF oDlg PICTURE "999999" SIZE 40,10 PIXEL;
      WHEN !lResu
   @ 50, 00 SAY "Nro. INGRESO   FINAL"     OF oDlg RIGHT PIXEL SIZE 90,10
   @ 50, 92 GET oGet[5] VAR aOpc[5] OF oDlg PICTURE "999999" ;
      VALID aOpc[5] >= aOpc[4] SIZE 40,10 PIXEL ;
      WHEN !lResu
   @ 62, 00 SAY        "VALOR  DEL  DOLAR" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 62, 92 GET oGet[6] VAR aOpc[6] OF oDlg PICTURE "9,999" SIZE 44,10 PIXEL;
      WHEN lResu
   @ 74, 00 SAY                   "MONEDA" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 74, 92 COMBOBOX oGet[7] VAR aOpc[7] ITEMS ArrayCol( aMone,1 ) SIZE 50,99 ;
      OF oDlg PIXEL
   @ 74,160 CHECKBOX oGet[8] VAR aOpc[8] PROMPT "Vista Previa" OF oDlg SIZE 60,10 PIXEL

   @ 88, 50 BUTTON oGet[09] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[09]:Disable(), aOpc[7] := aMone[aOpc[7],2],;
        EVAL( aRep[1] ), oDlg:End() ) PIXEL
   @ 88,100 BUTTON oGet[10] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 94, 02 SAY "[INOLIMON]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
PROCEDURE ListoMon( aLS )
   LOCAL aMon := ARRAY(3), aRes, cQry, hRes, nL
   LOCAL oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"","","",;
         " CODIGO   M A R C A------  R E F E R E N C I A-    MAT SEX TAMANO   "+;
         "CANT.      USD/EURO    PRECIO COSTO  PREC.VENTA  PREC.PUBLI ID" },aLS[8],,2 )
aRes := ""
If aLS[4] > 0
   aRes := " AND c.ingreso >= " + LTRIM(STR(aLS[4])) +;
           " AND c.ingreso <= " + LTRIM(STR(aLS[5]))
EndIf
If aLS[1] > 0
   aRes += " AND c.codigo_nit= " + LTRIM(STR(oApl:oNit:CODIGO_NIT))
EndIf
cQry := "SELECT c.optica, c.ingreso, c.codigo_nit, c.fecingre, c.factura, "    +;
           "c.moneda, d.consec, d.marca, d.refer, d.material, d.sexo, d.tamano"+;
           ", d.cantidad, d.usd, d.pcosto, d.pventa, d.ppubli, d.identif, c.cif, c.eur "+;
        "FROM cadmontd d, comprasc c "                   +;
        "WHERE d.indica <> 'B'"                          +;
         " AND c.ingreso = d.ingreso"                    +;
         " AND c.fecingre >= " + xValToChar( aLS[2] )    +;
         " AND c.fecingre <= " + xValToChar( aLS[3] )    + aRes +;
         " AND c.moneda " +   If( EMPTY(aLS[7]), "<> 'X'",;
                          "= " + xValToChar( aLS[7] ) )  +;
         " ORDER BY c.ingreso, d.row_id"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aLS[4] := 0
EndIf
While nL > 0
   If aLS[4]  # aRes[2]
      aLS[4] := aRes[2]
      AFILL( aMon,0 )
      oApl:oEmp:Seek( {"optica",aRes[1]} )
      oApl:oNit:Seek( {"codigo_nit",aRes[3]} )
      oApl:cEmpresa := ALLTRIM( oApl:oEmp:NOMBRE )
      oRpt:aEnc[1] := "INGRESO DE MONTURAS" + ;
           If( aRes[6] == "C", " EN CONSIGNACION", "" ) + STR(aRes[2],6)
      oRpt:aEnc[2] := NtChr( aRes[4],"3" )
      oRpt:aEnc[3] := "PROVEEDOR : " + STR(oApl:oNit:CODIGO) + "  " + oApl:oNit:NOMBRE +;
                      "    FACTURA No. " + aRes[5] +;
                      If( aRes[19] > 0, "  CIF="+TRANSFORM(aRes[19],"99,999.99"), "" ) +;
                      If( aRes[20] > 0, "  TC EUR="+TRANSFORM(aRes[20],"999.9999"), "" )
      oRpt:nL    := 67
      oRpt:nPage := 0
   EndIf
   oRpt:Titulo( 129 )
   oRpt:Say( oRpt:nL, 01,aRes[07] )
   oRpt:Say( oRpt:nL, 10,aRes[08] )
   oRpt:Say( oRpt:nL, 27,aRes[09] )
   oRpt:Say( oRpt:nL, 52,aRes[10] )
   oRpt:Say( oRpt:nL, 56,aRes[11] )
   oRpt:Say( oRpt:nL, 59,aRes[12] )
   oRpt:Say( oRpt:nL, 68,TRANSFORM(aRes[13],"9,999") )
   oRpt:Say( oRpt:nL, 76,TRANSFORM(aRes[14],  "@Z 99,999.9999") )
   oRpt:Say( oRpt:nL, 89,TRANSFORM(aRes[15],"999,999,999.99") )
   oRpt:Say( oRpt:nL,104,TRANSFORM(aRes[16],"999,999,999") )
   oRpt:Say( oRpt:nL,116,TRANSFORM(aRes[17],"999,999,999") )
   oRpt:Say( oRpt:nL,129,aRes[18] )
   oRpt:nL++
   aMon[1] +=  aRes[13]
   aMon[2] += (aRes[13] * aRes[14])
   aMon[3] += (aRes[13] * aRes[15])
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aLS[4] # aRes[2]
      If aMon[1] > 0
         oRpt:Say(  oRpt:nL,00,REPLICATE("_",129) )
         oRpt:Say(++oRpt:nL,67,TRANSFORM(aMon[1],"99,999"),,,1 )
         oRpt:Say(  oRpt:nL,75,TRANSFORM(aMon[2],    "999,999.9999" ) )
         oRpt:Say(  oRpt:nL,89,TRANSFORM(aMon[3],"999,999,999.99" ) )
         oRpt:NewPage()
      EndIf
   EndIf
EndDo
MSFreeResult( hRes )
oRpt:End()
oApl:oEmp:Seek( {"optica",oApl:nEmpresa} )
oApl:cEmpresa := ALLTRIM( oApl:oEmp:NOMBRE )
RETURN

//------------------------------------//
STATIC PROCEDURE ListoRes( aLS )
   LOCAL aGT, aMon, cQry, hRes, nK, nL, oRpt
cQry := "SELECT c.ingreso, c.factura, c.cgeconse, c.moneda, d.identif, "+;
        "CAST(SUM(d.cantidad) AS UNSIGNED INTEGER), SUM(d.cantidad * d.pcosto) "+;
        "FROM cadmontd d, comprasc c "                 +;
        "WHERE d.indica <> 'B'"                        +;
         " AND c.ingreso = d.ingreso"                  +;
         " AND c.optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fecingre >= " + xValToChar( aLS[2] )  +;
         " AND c.fecingre <= " + xValToChar( aLS[3] )  +;
         " AND c.moneda "      +      If( aLS[7] == "T",;
          "IN (' ','U')", "= " + xValToChar(aLS[7]) )  +;
        " GROUP BY c.ingreso, c.moneda, d.identif ORDER BY c.ingreso"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN
EndIf
aMon := { "Pesos","US $","Consignacion","Pesos y US $" }[AT( aLS[7]," UCT" )]
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"INGRESO DE MONTURAS",;
         "DESDE " + NtChr( aLS[2],"2" ) + " HASTA " + NtChr( aLS[3],"2" ),;
         "          MONEDA : " + aMon + TRANSFORM(aLS[6]," $ 9,999")     ,;
         "No.Ingreso   Nro.Factura   Nro. Cpbte    Valor Ingreso" },aLS[8] )
 aMon := MyReadRow( hRes )
 AEVAL( aMon, { | xV,nP | aMon[nP] := MyClReadCol( hRes,nP ) } )
  aGT := { 0,0,0,0,5,aMon[1],aMon[2],aMon[3],0,0," 9,999,999,999","$9,999,999,999" }
While nL > 0
   nK := AT( aMon[5],"NI" )
   aGT[05]   := Dolar_Peso( aLS[6],aMon[7],aMon[4] )
   aGT[nK]   += aMon[6]
   aGT[nK+2] +=  aGT[5]
   aGT[09]   +=  aGT[5]
   If (nL --) > 1
      aMon := MyReadRow( hRes )
      AEVAL( aMon, {| xV,nP | aMon[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aGT[6] # aMon[1]
      oRpt:Titulo( 60 )
      oRpt:Say( oRpt:nL,00,STR(aGT[6]) )
      oRpt:Say( oRpt:nL,13,    aGT[7] )
      oRpt:Say( oRpt:nL,26,STR(aGT[8]) )
      oRpt:Say( oRpt:nL,40,TRANSFORM(aGT[9],aGT[11]) )
      oRpt:nL ++
      aGT[6]  := aMon[1]
      aGT[7]  := aMon[2]
      aGT[8]  := aMon[3]
      aGT[10] += aGT[9]
      aGT[9]  := 0
   EndIf
EndDo
   MSFreeResult( hRes )
 oRpt:Separator( 0,10,60 )
 oRpt:Say(  oRpt:nL,00,REPLICATE("_",60) )
 oRpt:Say(++oRpt:nL,14,"GRAN TOTAL ==>" )
 oRpt:Say(  oRpt:nL,40,TRANSFORM(aGT[10],aGT[11] ) )
 oRpt:Say( oRpt:nL+2,11,"Cantidad Compras Nacionales.." + TRANSFORM(aGT[1],aGT[11]) )
 oRpt:Say( oRpt:nL+4,11,"Valor    Compras Nacionales.." + TRANSFORM(aGT[3],aGT[12]) )
 oRpt:Say( oRpt:nL+6,11,"Cantidad Compras Importadas.." + TRANSFORM(aGT[2],aGT[11]) )
 oRpt:Say( oRpt:nL+8,11,"Valor    Compras Importadas.." + TRANSFORM(aGT[4],aGT[12]) )
 oRpt:NewPage()
 oRpt:End()
RETURN