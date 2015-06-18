// Programa.: INOLIMOP.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo monturas por Proveedor a Precio de Costo con Codigo
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE InoLiMop( lCosto )
   LOCAL oDlg, oNi, oGet := ARRAY(11)
   LOCAL aOpc := { 0,DATE(),SPACE(15),"N","    ","N",DATE()-730,.f.,oApl:cEmpresa }
   LOCAL aRep := { {|| Inolimo1( aOpc ) },"Listo Monturas por Prov. con Código",;
                       "FECHA MONTURAS VIEJAS" }
   DEFAULT lCosto := .f.
If lCosto
   aRep := { {|| InoLimo2( aOpc ) },"Resumen Ingreso de Monturas","FECHA INICIAL [DD.MM.AA]" }
   aOpc[4] := "S"
EndIf
oApl:cEmpresa := ""
oNi := TNits() ; oNi:New()
DEFINE DIALOG oDlg TITLE aRep[2] FROM 0, 0 TO 12,60
   @ 02, 00 SAY "NIT Proveedor" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02, 92 BTNGET oGet[1] VAR aOpc[1] OF oDlg PICTURE "9999999999";
      ACTION EVAL({|| If(oNi:Mostrar(), (aOpc[1] := oNi:oDb:CODIGO,;
                        oGet[1]:Refresh() ),) })                   ;
      VALID EVAL( {|| If( oNi:Buscar( aOpc[1],"codigo",.t. )      ,;
                        ( oDlg:Update(), .t. )                    ,;
                   (MsgStop("Este Proveedor no Existe"), .f.) ) } );
      SIZE 44,10 PIXEL RESOURCE "BUSCAR"
   @ 02,148 SAY oGet[11] VAR oNi:oDb:NOMBRE OF oDlg PIXEL SIZE 98,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 14, 00 SAY "FECHA DESEADA [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 14, 92 GET oGet[2] VAR aOpc[2] OF oDlg  SIZE 34,10 PIXEL
   @ 26, 00 SAY       "MARCA DEL PRODUCTO" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 26, 92 GET oGet[3] VAR aOpc[3] OF oDlg PICTURE "@!" SIZE 70,10 PIXEL
   @ 38, 00 SAY     "CON EXISTENCIA [S/N]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 38, 92 GET oGet[4] VAR aOpc[4] OF oDlg PICTURE "!";
      VALID aOpc[4] $ "NS"         SIZE 08,10 PIXEL
   @ 38,110 SAY "Optica" OF oDlg RIGHT PIXEL SIZE 30,10
   @ 38,142 GET oGet[5] VAR aOpc[5] OF oDlg PICTURE "@!" ;
      VALID EVAL( {|| If( EMPTY( aOpc[5] ), .t.         ,;
                     (If( oApl:oEmp:Seek( {"localiz",aOpc[5]} ),;
                      (nEmpresa( .t. ), .t. )           ,;
                      (MsgStop("Esta Optica NO EXISTE"), .f.) ))) } );
      SIZE 22,10 PIXEL  WHEN !lCosto
   @ 50, 00 SAY "MONTURAS VIEJAS [S/N]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 50, 92 GET oGet[6] VAR aOpc[6] OF oDlg PICTURE "!";
      VALID If( aOpc[6] $ "NS", .t., .f. )  SIZE 08,10 PIXEL;
      WHEN !lCosto
   @ 62, 00 SAY aRep[3]             OF oDlg RIGHT PIXEL SIZE 90,10
   @ 62, 92 GET oGet[7] VAR aOpc[7] OF oDlg  SIZE 34,10 PIXEL;
      WHEN lCosto .OR. aOpc[6] == "S"
   @ 62,142 CHECKBOX oGet[8] VAR aOpc[8] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,10 PIXEL
   @ 76, 60 BUTTON oGet[09] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( aOpc[3] := If( EMPTY( aOpc[3] ), "", " AND descrip LIKE '"+;
                     ALLTRIM( aOpc[3] ) + "%'" )                  ,;
        oGet[9]:Disable(), EVAL( aRep[1] ), oDlg:End() ) PIXEL
   @ 76,110 BUTTON oGet[10] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 80, 02 SAY "[INOLIMOP]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
oApl:cEmpresa := aOpc[9]
RETURN

//------------------------------------//
STATIC PROCEDURE Inolimo1( aLS )
   LOCAL oRpt, aGT := {}, aTC := { 0,0,1,1,0 }, aRes, hRes, cQry, nL, nK
If !EMPTY( aLS[5] )
   aLS[3] += " AND optica = " + LTRIM(STR(oApl:nEmpresa))
   aLS[4] := "S"
EndIf
cQry := "SELECT descrip, marca, tamano, material, sexo, situacion, "+;
         "fecrecep, pcosto, codigo, optica, fecventa FROM cadinven "+;
        "WHERE codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT))    +;
         " AND grupo = '1'"   + aLS[3]
If aLS[4] == "S"
   cQry += " AND (situacion = 'E' OR (situacion <> 'E'" +;
           " AND fecventa > " + xValToChar( aLS[2] ) + "))"
EndIf
If aLS[6] == "S"
   cQry += " AND fecrecep <= " + xValToChar( aLS[7] )
EndIf
cQry += " ORDER BY descrip, material, sexo, tamano"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN
EndIf
AEVAL( oApl:aOptic, { | x | AADD( aGT, { x[1],0 } ) } )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"MONTURAS POR PROVEEDOR CON CODIGO" ,;
        NtChr( aLS[2],"3" ),"        PROVEEDOR : " + oApl:oNit:NOMBRE    ,;
        "        -----MARCA-----  -----REFERENCIA-----  TAMANO  MAT  SEX"+;
        "  TOTAL   CANTIDAD  -FECHA--  CANTIDAD  --PRECIO--", SPACE(64)  +;
        "MONTURAS ULT.ENTR  ULT.ENTR  EXIS/LOC  -DE COSTO-  CODIGO" },aLS[8],,2 )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aTC[5] := If( aRes[6] == "E"  .OR.;
                 (aLS[4] == "S" .AND. aRes[11] > aLS[2]), 1, 0 )
   If (nK := ASCAN( oApl:aOptic, {|x| x[2] == STR(aRes[10],2) } )) > 0
      aGT[nK,2] += aTC[5]
   EndIf
   If !EMPTY( aLS[5] )
      aRes[8] := 0
   EndIf
   oRpt:Titulo( 126 )
   oRpt:Say( oRpt:nL, 08,  LEFT(aRes[1],aRes[2]) )
   oRpt:Say( oRpt:nL, 25,SUBSTR(aRes[1],aRes[2]+2) )
   oRpt:Say( oRpt:nL, 47,aRes[3] )
   oRpt:Say( oRpt:nL, 56,aRes[4] )
   oRpt:Say( oRpt:nL, 61,aRes[5] )
   oRpt:Say( oRpt:nL, 65,TRANSFORM(aTC[3],"9999") )
   oRpt:Say( oRpt:nL, 75,TRANSFORM(aTC[4],"9999") )
   oRpt:Say( oRpt:nL, 83,aRes[7] )
   oRpt:Say( oRpt:nL, 93,TRANSFORM(aTC[5],"9999") )
   oRpt:Say( oRpt:nL, 98,aGT[nK,1] )
   oRpt:Say( oRpt:nL,102,TRANSFORM(aRes[8],"@Z 999,999,999") )
   oRpt:Say( oRpt:nL,115,RIGHT( aRes[9],8 ) )
   oRpt:nL++
   aTC[1] += aTC[5]
   aTC[2] += aRes[8]
   nL --
EndDo
MSFreeResult( hRes )
   oRpt:Say(  oRpt:nL, 00,REPLICATE("_",126),,,1 )
   oRpt:Say(++oRpt:nL, 92,TRANSFORM(aTC[1],"9,999"),,,1 )
   oRpt:Say(  oRpt:nL,102,TRANSFORM(aTC[2],"999,999,999" ) )
   Resumen( oRpt,aGT )
   oRpt:NewPage()
   oRpt:End()
RETURN

//------------------------------------//
STATIC PROCEDURE Inolimo2( aLS )
   LOCAL oRpt, aGT := {}, aTC, aRes, hRes, cQry, nL, nM, nK
cQry := "SELECT descrip, marca, material, sexo, tamano, situacion, "+;
               "fecrecep, pcosto, optica, fecventa FROM cadinven "  +;
        "WHERE codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT))    +;
         " AND grupo = '1'"
If aLS[4] == "N"
   cQry += " AND fecrecep >= " + xValToChar( aLS[7] ) +;
           " AND fecrecep <= " + xValToChar( aLS[2] )
EndIf
cQry += aLS[3] + " ORDER BY descrip, material, sexo, tamano"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"MONTURAS POR PROVEEDOR A PRECIO DE COSTO" ,;
         NtChr( aLS[2],"3" ), "        PROVEEDOR : " + oApl:oNit:NOMBRE         ,;
        "        -----MARCA-----  -----REFERENCIA-----  TAMANO  MAT  SEX  TOTAL"+;
        "   CANTIDAD  -FECHA--  CANTIDAD   --PRECIO--", SPACE(64) + ;
        "MONTURAS ULT.ENTR  ULT.ENTR  EXIS/LOC   -DE COSTO-" },aLS[8],,2 )
AEVAL( oApl:aOptic, { | x | AADD( aGT, { x[1],0 } ) } )
aRes := MyReadRow( hRes )
AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
cQry := aRes[1] + aRes[3] + aRes[4] + aRes[5]
nM   := aRes[2]
aTC  := { 0,0,0,0,CTOD(""),0,0,cQry,0,0,"",nL }
While nL > 0
   If aTC[8] == cQry
      aTC[9] := If( aRes[6] == "E" .OR.;
                   (aRes[6]  # "E" .AND. aRes[10] > aLS[2]), 1, 0 )
      aTC[1] ++
      aTC[4] ++
      aTC[3] += aTC[9]
      If aRes[7] >= aTC[5]
         aTC[2] := If( aRes[7] > aTC[5], 0, aTC[2] )
         aTC[2] ++
         aTC[5] := aRes[7]
      EndIf
      nK := ASCAN( oApl:aOptic, {|x| x[2] == STR(aRes[9],2) } )
      aTC[10]   := aRes[8]
      aGT[nK,2] += aTC[9]
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      cQry := aRes[1] + aRes[3] + aRes[4] + aRes[5]
   EndIf
   If nL == 0 .OR. aTC[8] # cQry
      If aTC[4] > 0
         aTC[11] := aLS[4] + If( aTC[3] == 0, "N", "S" )
         If aTC[11] # "SN"
            oRpt:Titulo( 120 )
            oRpt:Say( oRpt:nL  , 08,SUBSTR( aTC[8],01,nM ) )
            oRpt:Say( oRpt:nL  , 25,SUBSTR( aTC[8],nM+2,34-nM ) )
            oRpt:Say( oRpt:nL  , 47,SUBSTR( aTC[8],38,06 ) )
            oRpt:Say( oRpt:nL  , 56,SUBSTR( aTC[8],36,01 ) )
            oRpt:Say( oRpt:nL  , 61,SUBSTR( aTC[8],37,01 ) )
            oRpt:Say( oRpt:nL  , 65,TRANSFORM(aTC[01],"9999") )
            oRpt:Say( oRpt:nL  , 75,TRANSFORM(aTC[02],"9999") )
            oRpt:Say( oRpt:nL  , 83,aTC[5] )
            oRpt:Say( oRpt:nL  , 95,TRANSFORM(aTC[03],"9999") )
            oRpt:Say( oRpt:nL++,103,TRANSFORM(aTC[10],"999,999,999") )
            aTC[6] +=  aTC[3]
            aTC[7] += (aTC[3] * aTC[10])
         EndIf
      EndIf
      AFILL( aTC,0,1,4 )
      aTC[5] := CTOD("")
      aTC[8] := cQry
      nM     := aRes[2]
   EndIf
EndDo
MSFreeResult( hRes )
   oRpt:Say(  oRpt:nL, 00,REPLICATE("_",120),,,1 )
   oRpt:Say(++oRpt:nL, 64,TRANSFORM(aTC[12],"9,999"),,,1 )
   oRpt:Say(  oRpt:nL, 94,TRANSFORM(aTC[06],"9,999") )
   oRpt:Say(  oRpt:nL,103,TRANSFORM(aTC[07],"999,999,999" ) )
   Resumen( oRpt,aGT )
   oRpt:NewPage()
   oRpt:End()
RETURN

//------------------------------------//
STATIC PROCEDURE Resumen( oRpt,aGT )
   LOCAL nK := 1
AEVAL( aGT, {|x| If( x[2] > 0, nK++, ) } )
If oRpt:nL + nK > oRpt:nLength
   ASIZE( oRpt:aEnc,4 )
   oRpt:nL := oRpt:nLength
   oRpt:aEnc[4] := "        RESUMEN DISTRIBUCION CANTIDADES EN EXISTENCIA POR LOCALIZACION"
   oRpt:Titulo( 126 )
Else
   oRpt:Say(++oRpt:nL,08,"RESUMEN DISTRIBUCION CANTIDADES EN EXISTENCIA POR LOCALIZACION" )
   oRpt:nL++
EndIf
oRpt:cFont := oRpt:CPINormal
FOR nK := 1 TO LEN( aGT )
   If aGT[nK,2] > 0
      oRpt:Say( oRpt:nL  ,12,aGT[nK,1] )
      oRpt:Say( oRpt:nL++,20,TRANSFORM(aGT[nK,2],"9,999" ) )
   EndIf
NEXT
RETURN