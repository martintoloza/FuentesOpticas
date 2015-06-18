// Programa.: INOLIART.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Ingresos de Liq., Acces. y L.Contacto
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE InoLiArt( nOpc )
   LOCAL oDlg, oGet := ARRAY(12), oNi := TNits()
   LOCAL aRep, aOpc := { DATE(),DATE(),0,0,"C","N",.t.,0,"        " }
   DEFAULT nOpc := 1
If nOpc == 1
   aRep := { {|| ListoArt( aOpc ) },"Listado de Compras" }
ElseIf nOpc == 2
   aRep := { {|| ListoRes( aOpc ) },"Resumen de Compras" }
Else
   aRep := { {|| InoEstAr( aOpc ) },"Resumen de Compras por Proveedor" }
EndIf
oNi:New()
DEFINE DIALOG oDlg TITLE aRep[2] FROM 0, 0 TO 15,60
   @ 02, 00 SAY "CODIGO DEL PROVEEDOR" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 02, 72 BTNGET oGet[1] VAR aOpc[8] OF oDlg PICTURE "9999999999";
      VALID EVAL( {|| If(!oNi:oDb:Seek( {"codigo",aOpc[8]} )      ,;
                    ( MsgStop("Este Proveedor no Existe..."),.f. ),;
                    ( oDlg:Update(), .t. )) } )  SIZE 44,10 PIXEL  ;
      WHEN nOpc == 3  RESOURCE "BUSCAR"                            ;
      ACTION EVAL({|| If(oNi:Mostrar(), (aOpc[8] := oNi:oDb:CODIGO,;
                         oGet[1]:Refresh() ), )})
   @ 02,120 SAY oGet[10] VAR oNi:oDb:NOMBRE OF oDlg PIXEL SIZE 88,10;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 14, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 14, 72 GET oGet[2] VAR aOpc[1] OF oDlg  SIZE 40,10 PIXEL
   @ 26, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 26, 72 GET oGet[3] VAR aOpc[2] OF oDlg ;
      VALID aOpc[2] >= aOpc[1] SIZE 40,10 PIXEL
   @ 38, 00 SAY "Nro. INGRESO INICIAL"     OF oDlg RIGHT PIXEL SIZE 70,10
   @ 38, 72 GET oGet[4] VAR aOpc[3] OF oDlg PICTURE "999999" SIZE 40,10 PIXEL;
      WHEN nOpc == 1
   @ 50, 00 SAY "Nro. INGRESO   FINAL"     OF oDlg RIGHT PIXEL SIZE 70,10
   @ 50, 72 GET oGet[5] VAR aOpc[4] OF oDlg PICTURE "999999" ;
      VALID aOpc[4] >= aOpc[3] SIZE 40,10 PIXEL ;
      WHEN nOpc == 1
   @ 62, 00 SAY "A PRECIO COSTO O PUBLICO" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 62, 82 GET oGet[6] VAR aOpc[5] OF oDlg PICTURE "!";
      VALID If( aOpc[5] $ "CP", .t., .f. )             ;
      WHEN nOpc == 2  SIZE 08,10 PIXEL
   @ 62,100 SAY "Nro. FACTURA"             OF oDlg RIGHT PIXEL SIZE 50,10
   @ 62,152 GET oGet[7] VAR aOpc[9] OF oDlg  SIZE 40,10 PIXEL
   @ 74, 00 SAY       "HAGO LAS ETIQUETAS" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 74, 82 GET oGet[8] VAR aOpc[6] OF oDlg PICTURE "!";
      VALID If( aOpc[6] $ "NS", .t., .f. )             ;
      WHEN nOpc == 1  SIZE 08,10 PIXEL
   @ 74,130 CHECKBOX oGet[9] VAR aOpc[7] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,10 PIXEL
   @ 88, 50 BUTTON oGet[11] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[11]:Disable(), EVAL( aRep[1] ), oGet[11]:Enable(),;
        oGet[11]:oJump := oGet[7], oGet[7]:SetFocus() ) PIXEL
   @ 88,100 BUTTON oGet[12] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 94, 02 SAY "[INOLIART]" OF oDlg PIXEL SIZE 30,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT (If( nOpc == 3, Empresa(), ))

RETURN

//------------------------------------//
PROCEDURE ListoArt( aLS )
   LOCAL oRpt, aMon := ARRAY(2)
   LOCAL aRes, cQry, hRes, nL, nK
aRes := ""
If !EMPTY(aLS[9])
   aRes := " AND c.factura  = " + xValToChar(aLS[9])
ElseIf aLS[3] > 0
   aRes := " AND c.ingreso >= " + LTRIM(STR(aLS[3])) +;
           " AND c.ingreso <= " + LTRIM(STR(aLS[4]))
EndIf
cQry := "SELECT c.optica, c.ingreso, c.codigo_nit, c.fecingre, c.factura, "+;
           "d.codigo, d.cantidad, d.pcosto, d.pventa, d.ppubli, i.descrip "+;
        "FROM cadinven i, cadartid d, comprasc c "   +;
        "WHERE i.codigo  = d.codigo"                 +;
         " AND d.indica <> 'B'"                      +;
         " AND c.ingreso = d.ingreso"                +;
         " AND c.fecingre >= " + xValToChar( aLS[1] )+;
         " AND c.fecingre <= " + xValToChar( aLS[2] )+;
         " AND c.moneda  = 'X'"+ aRes                +;
         " ORDER BY c.ingreso, d.secuencia"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN
EndIf
If aLS[6] == "S"
   BorraFile( "CODIGOS",{"DBF","N0","PXX","IXX"} )
   aRes := { { "VITRINA","C", 3,0 },{ "CODIGO","C",12,0 },{ "VALOR","C",11,0 } }
   dbCREATE( oApl:cRuta2+"CODIGOS",aRes )
   If !AbreDbf( "Tem","CODIGOS",,,.f. )
      MsgInfo( "NO SE PUEDEN CREAR CODIGOS" )
      MSFreeResult( hRes )
      RETURN
   EndIf
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"","","",;
         "  C O D I G O-  D E S C R I P C I O N--------------     FACT" + ;
         "URA  CANTIDAD    PRECIO  COSTO  PRECIO VENTA  PREC.PUBLICO" },aLS[7],,2 )
 aRes := MyReadRow( hRes )
 AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
 aLS[3] := 0
While nL > 0
   If aLS[3]  # aRes[2]
      aLS[3] := aRes[2]
      AFILL( aMon,0 )
      oApl:oEmp:Seek( {"optica",aRes[1]} )
      oApl:oNit:Seek( {"codigo_nit",aRes[3]} )
      oApl:cEmpresa := ALLTRIM( oApl:oEmp:NOMBRE )
      oRpt:aEnc[1] := "INGRESO DE ARTICULO" + STR(aRes[2],6)
      oRpt:aEnc[2] := NtChr( aRes[4],"3" )
      oRpt:aEnc[3] := "PROVEEDOR : " + STR(oApl:oNit:CODIGO) + "  " + oApl:oNit:NOMBRE
      oRpt:nL    := 67
      oRpt:nPage := 0
   EndIf
   If aLS[6] == "S"
      FOR nK := 1 TO aRes[07]
         Tem->(dbAppend())
         Tem->CODIGO := aRes[06]
      NEXT
   Else
      oRpt:Titulo( 119 )
      oRpt:Say( oRpt:nL, 02,aRes[06] )
      oRpt:Say( oRpt:nL, 16,aRes[11] )
      oRpt:Say( oRpt:nL, 57,aRes[05] )
      oRpt:Say( oRpt:nL, 66,TRANSFORM(aRes[07],"99,999") )
      oRpt:Say( oRpt:nL, 76,TRANSFORM(aRes[08],"999,999,999.99") )
      oRpt:Say( oRpt:nL, 93,TRANSFORM(aRes[09],"999,999,999") )
      oRpt:Say( oRpt:nL,107,TRANSFORM(aRes[10],"999,999,999") )
      oRpt:nL++
      aMon[1] +=  aRes[07]
      aMon[2] += (aRes[07] * aRes[08])
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aLS[3] # aRes[2]
      If aMon[1] > 0
       //aMon[2] := ROUND( aMon[2],0 )
         oRpt:Say(  oRpt:nL,00,REPLICATE("_",119) )
         oRpt:Say(++oRpt:nL,65,TRANSFORM(aMon[1],"999,999") )
         oRpt:Say(  oRpt:nL,76,TRANSFORM(aMon[2],"999,999,999.99" ) )
         oRpt:NewPage()
      EndIf
   EndIf
EndDo
MSFreeResult( hRes )
oRpt:End()
oApl:oEmp:Seek( {"optica",oApl:nEmpresa} )
oApl:cEmpresa := ALLTRIM( oApl:oEmp:NOMBRE )
If aLS[6] == "S"
   Tem->(dbCloseArea())
EndIf
RETURN

//------------------------------------//
STATIC PROCEDURE ListoRes( aLS )
   LOCAL aArc, aRes, cQry, hRes, nL
   LOCAL aGT := { 0,0,0,0,0, }, oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"RESUMEN DE COMPRAS","DESDE " +;
           NtChr( aLS[1],"2" ) + " HASTA " + NtChr( aLS[2],"2" )    ,;
           "No.Ingre. Optica Nro.Factura Valor Ingreso Liquidos Acc"+;
           "esorio L.Contacto   Cpbte" },aLS[7] )
cQry := "SELECT c.optica, c.ingreso, c.factura, d.codigo, d.cantidad, "+;
        If( aLS[5] == "C", "d.pcosto ", "d.ppubli " )+;
        ", c.cgeconse FROM cadartid d, comprasc c "  +;
        "WHERE d.indica <> 'B'"                      +;
         " AND c.ingreso = d.ingreso"                +;
         " AND c.fecingre >= " + xValToChar( aLS[1] )+;
         " AND c.fecingre <= " + xValToChar( aLS[2] )+;
         " AND c.moneda  = 'X' ORDER BY c.ingreso"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aArc := { aRes[1],aRes[2],aRes[3],aRes[7] }
EndIf
While nL > 0
   do case
      Case LEFT(aRes[4],2) == "03"
         aGT[1] += aRes[5]
      Case LEFT(aRes[4],2) == "04"
         aGT[2] += aRes[5]
      OtherWise
         aGT[3] += aRes[5]
   EndCase
   aGT[4] += (aRes[5] * aRes[6])
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aRes[2] # aArc[2]
      aGT[6] := ArrayValor( oApl:aOptic,STR(aArc[1],2) )
      oRpt:Titulo( 79 )
      oRpt:Say( oRpt:nL  ,03,aArc[2] )
      oRpt:Say( oRpt:nL  ,12,aGT[6] )
      oRpt:Say( oRpt:nL  ,18,aArc[3] )
      oRpt:Say( oRpt:nL  ,31,TRANSFORM(aGT[4],"999,999,999") )
      oRpt:Say( oRpt:nL  ,44,TRANSFORM(aGT[1], "@Z 999,999") )
      oRpt:Say( oRpt:nL  ,54,TRANSFORM(aGT[2], "@Z 999,999") )
      oRpt:Say( oRpt:nL  ,65,TRANSFORM(aGT[3], "@Z 999,999") )
      oRpt:Say( oRpt:nL++,73,TRANSFORM(aArc[4],"@Z 999,999") )
      aArc   := { aRes[1],aRes[2],aRes[3],aRes[7] }
      aGT[5] += aGT[4]
      AFILL( aGT,0,1,4 )
   EndIf
EndDo
If aGT[5] > 0
   oRpt:Say(  oRpt:nL,00,REPLICATE("_",79) )
   oRpt:Say(++oRpt:nL,14,"GRAN TOTAL ==>" )
   oRpt:Say(  oRpt:nL,32,TRANSFORM(aGT[5],"999,999,999" ) )
EndIf
oRpt:NewPage()
oRpt:End()
RETURN

//------------------------------------//
STATIC PROCEDURE InoEstAr( aLS )
   LOCAL oRpt, aGT := { 0,0,0,"" }
   LOCAL aRes, cQry, hRes, nL
aGT[4]:= If( aLS[5] == "C", "costo", "publi")
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"COMPRAS DISCRIMINADAS POR PRODUCTO" ,;
          "DESDE " + NtChr( aLS[1],"2" ) + " HASTA " + NtChr( aLS[2],"2" ),;
          "        PROVEEDOR : " + STR(aLS[8]) + "  " + oApl:oNit:NOMBRE  ,;
          "  C O D I G O-  D E S C R I P C I O N    CANTIDAD   PRECIO "   +;
          UPPER( aGT[4] ) },aLS[7] )
cQry := "SELECT d.codigo, CAST(SUM(d.cantidad) AS UNSIGNED INTEGER), SUM(d.cantidad*d.p" + aGT[4] +;
        ") FROM cadartid d, comprasc c "                         +;
        "WHERE c.ingreso = d.ingreso"                            +;
         " AND d.indica <> 'B'"                                  +;
         " AND c.optica    = " + LTRIM(STR(oApl:nEmpresa))       +;
         " AND c.fecingre >= " + xValToChar( aLS[1] )            +;
         " AND c.fecingre <= " + xValToChar( aLS[2] )            +;
         " AND c.codigo_nit = "+ LTRIM(STR(oApl:oNit:CODIGO_NIT))+;
         " AND c.moneda  = 'X'"                                  +;
         " GROUP BY d.codigo ORDER BY d.codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   oApl:oInv:Seek( {"codigo",aRes[1]} )
   oRpt:Titulo( 70 )
   oRpt:Say( oRpt:nL  ,02,aRes[1] )
   oRpt:Say( oRpt:nL  ,16,oApl:oInv:DESCRIP )
   oRpt:Say( oRpt:nL  ,40,TRANSFORM( aRes[2],  "9,999,999") )
   oRpt:Say( oRpt:nL++,53,TRANSFORM( aRes[3],"999,999,999") )
   aGT[1] += aRes[2]
   aGT[2] += aRes[3]
   aGT[3] ++
   nL --
EndDo
If aGT[3] > 0
   oRpt:Say(  oRpt:nL,00,REPLICATE("_",70) )
   oRpt:Say(++oRpt:nL,16,"GRAN TOTAL ==>" )
   oRpt:Say(  oRpt:nL,39,TRANSFORM(aGT[1],   "99,999,999" ) )
   oRpt:Say(  oRpt:nL,51,TRANSFORM(aGT[2],"9,999,999,999" ) )
EndIf
oRpt:NewPage()
oRpt:End()
RETURN