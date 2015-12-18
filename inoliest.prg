// Programa.: INOLIEST.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Estadisticas de Monturas por Optica por Proveedor.
#include "FiveWin.ch"
#include "Btnget.ch"

MEMVAR oApl

PROCEDURE InoLiEst( lResu )
   LOCAL oGet := ARRAY(11)
   LOCAL aMone, aEsta, aRep, oC, oDlg, oNi
   DEFAULT lResu := .f.
oC  := TEstadis();  oC:NEW()
oNi := TNits()   ;  oNi:New()
If lResu
   aRep := { {|| oC:ListoESI() },"Estadistica Ingresos Monturas",;
                 "A PRECIO [C/P]","CUAL" }
   aEsta := { "Costo","Público" }
   aMone := { {"Ingresos","I"},{"Reposiciones","R"},{"Todas","T"} }
Else
   aRep := { {|| oC:ListoEST() },"Estadistica Monturas por Prov.",;
                 "Situación [E/V]","MONEDA" }
   aEsta := { "Existente","Vendida" }
   aMone := ArrayCombo( "MONEDA" )
   AADD( aMone, {"Todas","T"} )
EndIf
oC:aLS[5] := LEN( aMone )
DEFINE DIALOG oDlg TITLE aRep[2] FROM 0, 0 TO 15,60
   @ 02, 00 SAY "Proveedor por Default Todos" OF oDlg RIGHT PIXEL SIZE 90,08
   @ 02, 92 BTNGET oGet[1] VAR oC:aLS[1] OF oDlg PICTURE "9999999999";
      VALID EVAL( {|| If( EMPTY( oC:aLS[1] ), .t.                   ,;
              (If( oNi:oDb:Seek( {"codigo",oC:aLS[1]} )             ,;
              ( oGet[2]:Settext( oNi:oDb:NOMBRE ) , .t. )         ,;
              ( MsgStop("Este NIT no Existe ...."), .f. ) ))) } )  ;
      SIZE 54,12 PIXEL      RESOURCE "BUSCAR"                      ;
      ACTION EVAL({|| If(oNi:Mostrar(), (oC:aLS[1] := oNi:oDb:CODIGO,;
                         oGet[1]:Refresh() ),) })
   @ 02,150 SAY oGet[2] VAR oC:aLS[8] OF oDlg PIXEL SIZE 100,20 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 16, 00 SAY      aRep[3]        OF oDlg RIGHT PIXEL SIZE 90,10
   @ 16, 92 COMBOBOX oGet[3] VAR oC:aLS[2] ITEMS aEsta SIZE 50,99 OF oDlg PIXEL
   @ 30, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 30, 92 GET oGet[4] VAR oC:aLS[3] OF oDlg  SIZE 40,12 PIXEL
   @ 44, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 44, 92 GET oGet[5] VAR oC:aLS[4] OF oDlg ;
      VALID oC:aLS[4] >= oC:aLS[3] SIZE 40,12 PIXEL
   @ 44,140 CHECKBOX oGet[6] VAR oC:aLS[9] PROMPT "A Costo" OF oDlg ;
      WHEN !lResu  SIZE 60,12 PIXEL
   @ 58, 00 SAY      aRep[4]        OF oDlg RIGHT PIXEL SIZE 90,10
   @ 58, 92 COMBOBOX oGet[7] VAR oC:aLS[5] ITEMS ArrayCol( aMone,1 ) SIZE 50,99 ;
      OF oDlg PIXEL
   @ 72, 00 SAY "VALOR  DEL  DOLAR" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 72, 92 GET oGet[8] VAR oC:aLS[6] OF oDlg PICTURE "9,999" SIZE 30,12 PIXEL
   @ 72,140 CHECKBOX oGet[9] VAR oC:aLS[7] PROMPT "Vista &Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 88, 50 BUTTON oGet[10] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[10]:Disable(), oC:aLS[5] := aMone[oC:aLS[5],2],;
        EVAL( aRep[1] ), oDlg:End() ) PIXEL
   @ 88,100 BUTTON oGet[11] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 94, 02 SAY "[INOLIEST]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT (Empresa() )
RETURN

//------------------------------------//
PROCEDURE InoLiEsm()
   LOCAL oC, oDlg, oNi, oGet := ARRAY(9)
oC  := TEstadis();  oC:NEW( 0 )
oNi := TNits()      ; oNi:New()
DEFINE DIALOG oDlg TITLE "Estadisticas del Inventario" FROM 0, 0 TO 11,60
   @ 02, 00 SAY "Proveedor por Default Todos" OF oDlg RIGHT PIXEL SIZE 90,08
   @ 02, 92 BTNGET oGet[1] VAR oC:aLS[1] OF oDlg PICTURE "9999999999";
      VALID EVAL( {|| If( EMPTY( oC:aLS[1] ), .t.                   ,;
                     (If( oNi:oDb:Seek( {"codigo",oC:aLS[1]} )      ,;
                        ( oGet[2]:Settext( oNi:oDb:NOMBRE ) , .t. ) ,;
                  ( MsgStop("Este NIT no Existe ...."), .f. ) ))) } );
      SIZE 54,10 PIXEL      RESOURCE "BUSCAR"                        ;
      ACTION EVAL({|| If(oNi:Mostrar(), (oC:aLS[1] := oNi:oDb:CODIGO,;
                         oGet[1]:Refresh() ),) })
   @ 02,150 SAY oGet[2] VAR oC:aLS[7] OF oDlg PIXEL SIZE 100,20 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 14, 00 SAY           "A PRECIO [C/P]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 14, 92 COMBOBOX oGet[3] VAR oC:aLS[2] ITEMS { "Costo","Público" };
      SIZE 50,99 OF oDlg PIXEL
   @ 26, 00 SAY  "DIGITE AÑO Y MES [AAMM]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 26, 92 GET oGet[4] VAR oC:aLS[3] OF oDlg  SIZE 30,10 PIXEL
   @ 38, 00 SAY             "TIPO DESEADO" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 38, 92 COMBOBOX oGet[5] VAR oC:aLS[4] ITEMS { "Inventario","Ventas" };
      SIZE 50,99 OF oDlg PIXEL
   @ 50, 00 SAY "VALOR  DEL  DOLAR" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 50, 92 GET oGet[6] VAR oC:aLS[5] OF oDlg PICTURE "9,999" SIZE 30,10 PIXEL
   @ 50,140 CHECKBOX oGet[7] VAR oC:aLS[6] PROMPT "Vista &Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 64, 50 BUTTON oGet[8] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[8]:Disable(), oC:ListoESM(), oDlg:End() ) PIXEL
   @ 64,100 BUTTON oGet[9] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 70, 02 SAY "[INOLIEST]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT (Empresa() )
RETURN

//------------------------------------//
//CLASS TEstadis FROM TIMPRIME
CLASS TEstadis

 DATA aLS, aGT, hRes, nL

 METHOD NEW( nLis,cQry ) Constructor
 METHOD ListoESI()
 //METHOD LaserESI()
 METHOD ListoESM()
 METHOD ListoEST()
 METHOD PrecioEst( cPrecio )
ENDCLASS

//------------------------------------//
METHOD NEW( nLis,cQry ) CLASS TEstadis
If nLis == NIL
   ::aLS := { 0,1,CTOD(""),DATE(),4,oApl:nUS,.f.,"",.f. }
ElseIf nLis == 0
   ::aLS := { 0,1,NtChr( DATE(),"1" ),1,oApl:nUS,.f.,"",, }
ElseIf nLis == 1
   cQry := "SELECT i.moneda, i.material, i.sexo, s.existencia, " +;
                  If( ::aLS[2] == 1, "s.pcosto ", "i.ppubli " )  +;
           "FROM cadinvme s, cadinven i "                        +;
           "WHERE s.optica = " + LTRIM(STR(oApl:nEmpresa))       +;
           " AND LEFT(s.codigo,2) = '01'"                        +;
           " AND s.anomes = (SELECT MAX(anomes) FROM cadinvme m "+;
                            "WHERE m.optica = s.optica"          +;
                             " AND m.codigo = s.codigo"          +;
                             " AND m.anomes <= '" +::aLS[3]+ "')"+;
           " AND s.existencia <> 0"                              +;
           " AND i.codigo = s.codigo" + ::aLS[7]
   ::aLS[7] := " INVENTARIO "
ElseIf nLis == 2
   ::aLS[9] := CTOD( NtChr( ::aLS[8],"4" ) )
   cQry := "SELECT i.moneda, i.material, i.sexo, d.cantidad, "   +;
      If( ::aLS[2] == 1, "d.pcosto", "d.precioven + d.montoiva" )+;
          " FROM cadinven i, cadventa d, cadfactu c "            +;
           "WHERE d.codart  = i.codigo" + ::aLS[7]               +;
            " AND LEFT(d.codart,2) = '01'"                       +;
            " AND c.optica  = d.optica"                          +;
            " AND c.numfac  = d.numfac"                          +;
            " AND c.tipo    = d.tipo"                            +;
            " AND c.optica  = " + LTRIM(STR(oApl:nEmpresa))      +;
            " AND c.fechoy >= " + xValToChar( ::aLS[8] )         +;
            " AND c.fechoy <= " + xValToChar( ::aLS[9] )         +;
            " AND c.tipo    = " + xValToChar(oApl:Tipo)          +;
            " AND c.indicador <> 'A'"
   ::aLS[7] := " VENTAS "
ElseIf nLis == 3
   cQry := "SELECT c.moneda, d.material, d.sexo, d.cantidad, d."+cQry+;
           " FROM comprasc c, cadmontd d "                 +;
           "WHERE c.optica = " + LTRIM(STR(oApl:nEmpresa)) +;
            " AND c.fecingre >= " + xValToChar( ::aLS[3] ) +;
            " AND c.fecingre <= " + xValToChar( ::aLS[4] ) + ::aLS[8] +;
            " AND c.moneda <> 'X'"                         +;
            " AND d.ingreso = c.ingreso"                   +;
            " AND d.indica <> 'B'"
ElseIf nLis == 4
   cQry := "SELECT i.moneda, i.material, i.sexo, d.cantidad, d."+cQry+;
           " FROM cadrepoc c, cadrepod d, cadinven i "      +;
           "WHERE c.optica = " + LTRIM(STR(oApl:nEmpresa))  +;
            " AND c.fecharep >= " + xValToChar( ::aLS[3] )  +;
            " AND c.fecharep <= " + xValToChar( ::aLS[4] )  +;
            " AND d.numrep = c.numrep"                      +;
            " AND d.indica <> 'B'"                          +;
            " AND d.grupo  = '1'"                           +;
            " AND i.codigo = d.codigo" + ::aLS[8]
ElseIf nLis == 5
   cQry := "SELECT material, sexo, moneda, " + ::aLS[8]   +;
           " FROM cadinven WHERE LEFT(codigo,2) = '01'"   +;
           " AND optica    = " + LTRIM(STR(oApl:nEmpresa))+;
           " AND situacion = " + cQry
EndIf
If cQry # NIL
   ///MsgInfo( cQry )
   ::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
                 MSStoreResult( oApl:oMySql:hConnect ), 0 )
   If (::nL := MSNumRows( ::hRes )) == 0
      MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
      MSFreeResult( ::hRes )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD ListoESI() CLASS TEstadis
   LOCAL aEst, aRes, cCam, oRpt
   LOCAL nPos, nF, nTotal := 0
aEst := ::PrecioEst( If( ::aLS[2] == 1, "C", NIL ) )
cCam := If( ::aLS[2] == 1, "pcosto", "ppubli" )
::aLS[8] := If( ::aLS[1] > 0, " AND c.codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT)), "" )
If ::aLS[5] $ "IT"
   ::NEW( 3,cCam )
   While ::nL > 0
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
      aRes[5] := Dolar_Peso( ::aLS[6],aRes[5],aRes[1] )
      nTotal  += (aRes[5] * aRes[4])
      nPos := If( aRes[2] == "P", 2, 5 ) + AT( aRes[3],"MFU" )
      FOR nF := 1 TO LEN( aEst )
         If Rango( aRes[5],aEst[nF,1],aEst[nF,2] )
            aEst[nF,nPos]+= aRes[4]
            EXIT
         EndIf
      NEXT
      ::nL --
   EndDo
   MSFreeResult( ::hRes )
EndIf
If ::aLS[5] $ "RT"
   ::aLS[8] := STRTRAN( ::aLS[8],"c.","i." )
   ::NEW( 4,cCam )
   While ::nL > 0
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
      aRes[5] := Dolar_Peso( ::aLS[6],aRes[5],aRes[1] )
      nTotal  += (aRes[5] * aRes[4])
      nPos := If( aRes[2] == "P", 2, 5 ) + AT( aRes[3],"MFU" )
      FOR nF := 1 TO LEN( aEst )
         If Rango( aRes[5],aEst[nF,1],aEst[nF,2] )
            aEst[nF,nPos]+= aRes[4]
            EXIT
         EndIf
      NEXT
      ::nL --
   EndDo
   MSFreeResult( ::hRes )
EndIf
cCam := { "SOLAMENTE INGRESOS","SOLAMENTE REPOSICIONES",;
          "INGRESOS MAS REPOSICIONES" }[AT(::aLS[5],"IRT")]
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"ESTADISTICA INGRESOS DE MONTURAS"   ,;
          "DESDE " + NtChr( ::aLS[3],"2" ) + " HASTA " + NtChr( ::aLS[4],"2" ),;
          cCam,"",""},::aLS[7] )
LisEstadis( oRpt,aEst,::aLS[1],nTotal )
RETURN NIL

//------------------------------------//
METHOD ListoESM() CLASS TEstadis
   LOCAL oRpt, aEst, aRes, nPos, nF, nTotal := 0
::aLS[7] := If( ::aLS[1] > 0, " AND i.codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT)), "" )
::aLS[8] := NtChr( ::aLS[3],"F" )
::NEW( ::aLS[4] )
If ::nL == 0
   RETURN NIL
EndIf
//aEst := PrecioEst( If( ::aLS[2] == 1, "C", NIL ) )
aEst := ::PrecioEst( "B" )
While ::nL > 0
   aRes := MyReadRow( ::hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   aRes[5] := Dolar_Peso( ::aLS[5],aRes[5],aRes[1] )
   nTotal  += aRes[5]
   nPos := If( aRes[2] == "P", 2, 5 ) + AT( aRes[3],"MFU" )
   FOR nF := 1 TO LEN( aEst )
      If Rango( aRes[5],aEst[nF,1],aEst[nF,2] )
         aEst[nF,nPos]+= aRes[4]
         EXIT
      EndIf
   NEXT
   ::nL --
EndDo
MSFreeResult( ::hRes )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"ESTADISTICA" + ::aLS[7] + "DE MONTURAS",;
          "EN " + NtChr( ::aLS[8],"6" ),"",""},::aLS[6] )
oRpt:aEnc[2] += " A PRECIO " + If( ::aLS[2] == 1, "COSTO", "PUBLICO" )
LisEstadis( oRpt,aEst,::aLS[1],nTotal )
RETURN NIL

//------------------------------------//
METHOD ListoEST() CLASS TEstadis
   LOCAL oRpt, nPos, nF, nTotal := 0
   LOCAL aEst, aRes
::aLS[8]:= If( ::aLS[9], "pcosto", If( ::aLS[2] == 1, "ppubli", "pvendida" ))
aRes := " AND moneda " + If( ::aLS[5] == "T", "IN(' ','U','C')", "= '"+::aLS[5]+"'" )
do Case
Case ::aLS[2] == 1
   aEst := "'E'" + aRes
Case ::aLS[2] == 2 .AND. ::aLS[1] == 0
   aEst := "'V' AND fecventa >= " + xValToChar( ::aLS[3] ) +;
              " AND fecventa <= " + xValToChar( ::aLS[4] ) + aRes
OtherWise
   aEst := "'V' AND fecventa >= " + xValToChar( ::aLS[3] ) +;
              " AND fecventa <= " + xValToChar( ::aLS[4] ) +;
              " AND codigo_nit= " + LTRIM(STR(oApl:oNit:CODIGO_NIT)) + aRes
EndCase
::NEW( 5,aEst )
If ::nL == 0
   RETURN NIL
EndIf
aEst := ::PrecioEst()
::aLS[6] := If( ::aLS[2] == 1, ::aLS[6], 1 )
While ::nL > 0
   aRes := MyReadRow( ::hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   aRes[4] := Dolar_Peso( ::aLS[6],aRes[4],aRes[3] )
   nTotal  += aRes[4]
   nPos := If( aRes[1] == "P", 2, 5 ) + AT( aRes[2],"MFU" )
   FOR nF := 1 TO LEN( aEst )
      If Rango( aRes[4],aEst[nF,1],aEst[nF,2] )
         aEst[nF,nPos]++
         Exit
      EndIf
   NEXT
   ::nL --
EndDo
MSFreeResult( ::hRes )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"ESTADISTICA DE MONTURAS - ","","",""},::aLS[7] )
oRpt:aEnc[1] += {" ","CARTIER","CONSIGNACION","TODAS"}[AT(::aLS[5]," UCT")]
oRpt:aEnc[2] := {"EN EXISTENCIAS ","VENDIDAS DESDE "}[::aLS[2]] + ;
          NtChr( ::aLS[3],"2" ) + " HASTA " + NtChr( ::aLS[4],"2" )
oRpt:aEnc[3] := PADC( UPPER(::aLS[8]),20 )
LisEstadis( oRpt,aEst,::aLS[1],nTotal )
RETURN NIL

//------------------------------------//
METHOD PrecioEst( cPrecio ) CLASS TEstadis
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