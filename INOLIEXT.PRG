// Programa.: INOLIEXT.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Movimento de un Codigo por Mes
#include "FiveWin.ch"
#include "Btnget.ch"

MEMVAR oApl

PROCEDURE InoLiExt()
   LOCAL oDlg, oGet := ARRAY(7), oAr := TInv()
   LOCAL aVta := { SPACE(12),DATE(),DATE(),.t.,"" }
oAr:New()
DEFINE DIALOG oDlg TITLE "Extracto de un Código" FROM 0, 0 TO 11,52
   @ 02, 00 SAY "CODIGO DEL ARTICULO" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 02,102 BTNGET oGet[1] VAR aVta[1] OF oDlg PICTURE "999999999!!!";
      VALID EVAL( {|| If( oAr:oDb:Seek( {"codigo",aVta[1]} )      ,;
                ( oGet[2]:Settext( oAr:oDb:DESCRIP ), .t. )       ,;
                ( MsgStop("Este Código no Existe"),.f.)) } )       ;
      SIZE 58,12 PIXEL  RESOURCE "BUSCAR"                          ;
      ACTION EVAL({|| If(oAr:Mostrar(), (aVta[1] := oAr:oDb:CODIGO,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 16, 40 SAY oGet[2] VAR aVta[5] OF oDlg PIXEL SIZE 120,12;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 30, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 30,102 GET oGet[3] VAR aVta[2] OF oDlg  SIZE 40,12 PIXEL
   @ 44, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 44,102 GET oGet[4] VAR aVta[3] OF oDlg ;
      VALID aVta[3] >= aVta[2] SIZE 40,12 PIXEL
   @ 44,150 CHECKBOX oGet[5] VAR aVta[4] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 60, 50 BUTTON oGet[6] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[6]:Disable(), Extracto( aVta ), oGet[6]:Enable(),;
        oGet[6]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 60,100 BUTTON oGet[7] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 66, 02 SAY "[INOLIEXT]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
PROCEDURE Extracto( aLS )
   LOCAL cQry, hRes, nL, nK, oRpt
   LOCAL aExt := { 0,aLS[1],"",0,0,0,0,0,0 }
aLS[2]  := CTOD( "01" + RIGHT( DTOC( aLS[2] ),8 ) )
cQry    := NtChr( aLS[2] - 1,"1" )
aExt[1] := aExt[7] := SaldoInv( aLS[1],cQry,1 )
aLS[5]  := NtChr( aLS[3],"1" )
oRpt := TDosPrint()
oRpt:New(oApl:cPuerto,oApl:cImpres,{"MOVIMIENTO DEL CODIGO "+aLS[1],;
         oApl:oInv:DESCRIP + "  DESDE " +NtChr(aLS[2],"2") +" HASTA " +NtChr(aLS[3],"2"),;
         "  EXISTENCIA ANTERIOR " + TRANSFORM( aExt[1],"99,999" ) +;
         " PC = " + TRANSFORM( oApl:aInvme[2],"99,999,999.99" ) ,;
         "     -FECHA--   No.DOCUMEN   CANTIDAD     P.VENDIDO"},aLS[4] )
   cQry := "SELECT d.fecfac, d.numfac, d.cantidad, d.precioven, d.descri "+;
           "FROM cadventa d, cadfactu c "             +;
           "WHERE d.codart = "  + xValToChar( aLS[1] )+;
            " AND NOT(d.indicador = 'A' AND d.fecfac = d.fecdev)"+;
            " AND c.optica = d.optica"                +;
            " AND c.numfac = d.numfac"                +;
            " AND c.tipo   = d.tipo"                  +;
            " AND c.optica = [OPT]"                   +;
            " AND c.fechoy >= " + xValToChar( aLS[2] )+;
            " AND c.fechoy <= " + xValToChar( aLS[3] )+;
            " AND c.tipo   <> 'Z'"
If oApl:cLocal == "LOC"
   cQry := STRTRAN( cQry,"precioven","pcosto" )
EndIf
If oApl:nEmpresa == 18
   cQry := STRTRAN( cQry,"[OPT]","18" ) +;
            " AND c.autoriza <> 'FOCA'"
ElseIf oApl:nEmpresa == 21
   If aLS[1] == "0599000001  "
   cQry := "SELECT c.fecha, c.numero, d.cantidad, d.precioven, d.descri "+;
           "FROM cadantid d, cadantic c "             +;
           "WHERE d.codart = '0599000001'"            +;
            " AND c.optica = d.optica"                +;
            " AND c.numero = d.numero"                +;
            " AND c.optica = 21"                      +;
            " AND c.fecha >= " + xValToChar( aLS[2] ) +;
            " AND c.fecha <= " + xValToChar( aLS[3] )
   Else
   cQry := STRTRAN( cQry,"[OPT]","18" ) +;
            " AND c.autoriza = 'FOCA'"
   EndIf
Else
   cQry := STRTRAN( cQry,"[OPT]",LTRIM(STR(oApl:nEmpresa)) )
EndIf
Lineas( cQry,@aExt,oRpt,"VENTAS",1,-1 )

oRpt:aEnc[4] := STRTRAN( oRpt:aEnc[4],"VENDIDO","COSTO" )
If oApl:nEmpresa == 0
   cQry := "SELECT c.fecharep, c.numrep, d.cantidad, d.pcosto, e.localiz "+;
           "FROM cadrepod d, cadempre e, cadrepoc c "    +;
           "WHERE d.codigo = "    + xValToChar( aLS[1] ) +;
            " AND d.indica <> 'B'"                       +;
            " AND c.numrep = d.numrep"                   +;
            " AND c.optica = e.optica"                   +;
            " AND c.fecharep >= " + xValToChar( aLS[2] ) +;
            " AND c.fecharep <= " + xValToChar( aLS[3] )
   Lineas( cQry,@aExt,oRpt,"R E P O S I C I O N E S",2,-1 )
Else
   cQry := "SELECT c.fecharep, c.numrep, d.cantidad, d.pcosto "+;
           "FROM cadrepod d, cadrepoc c "                 +;
           "WHERE d.codigo = "    + xValToChar( aLS[1] )  +;
            " AND d.indica <> 'B'"                        +;
            " AND c.numrep = d.numrep"                    +;
            " AND c.optica = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND c.fecharep >= " + xValToChar( aLS[2] )  +;
            " AND c.fecharep <= " + xValToChar( aLS[3] )
   Lineas( cQry,@aExt,oRpt,"R E P O S I C I O N E S",2,1 )
EndIf

If LEFT( aLS[1],2 ) # "01"
   cQry := "SELECT c.fecingre, c.ingreso, d.cantidad, d.pcosto "+;
           "FROM cadartid d, comprasc c "                 +;
           "WHERE d.codigo  = "    + xValToChar( aLS[1] ) +;
            " AND d.indica <> 'B'"                        +;
            " AND c.ingreso = d.ingreso"                  +;
            " AND c.optica = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND c.fecingre >= " + xValToChar( aLS[2] )  +;
            " AND c.fecingre <= " + xValToChar( aLS[3] )  +;
            " AND c.moneda  = 'X'"
   Lineas( cQry,@aExt,oRpt,"C O M P R A S",3,1 )
ElseIf oApl:nEmpresa == 0 .OR. oApl:oInv:COMPRA_D
   cQry := "SELECT c.fecingre, c.ingreso, d.cantidad, d.pcosto, d.consec "+;
           "FROM cadmontd d, comprasc c "                 +;
           "WHERE d.indica <> 'B'"                        +;
            " AND c.ingreso = d.ingreso"                  +;
            " AND c.optica = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND c.fecingre >= " + xValToChar( aLS[2] )  +;
            " AND c.fecingre <= " + xValToChar( aLS[3] )  +;
            " AND c.moneda <> 'X'"
   Lineas( cQry,@aExt,oRpt,"C O M P R A S",3,1,SUBSTR( aLS[1],5,6 ) )
EndIf

cQry := "SELECT d.fechad, d.documen, d.cantidad, d.pcosto, e.localiz "+;
        "FROM cadempre e, caddevod d "                 +;
        "WHERE d.optica  = e.optica"                   +;
         " AND d.destino = "+ LTRIM(STR(oApl:nEmpresa))+;
         " AND d.codigo  = " + xValToChar( aLS[1] )    +;
         " AND d.fechad >= " + xValToChar( aLS[2] )    +;
         " AND d.fechad <= " + xValToChar( aLS[3] )    +;
         " AND d.optica <> d.destino"                  +;
         " AND d.indica <> 'B'"                        +;
         " AND d.causadev "                            +;
           If( oApl:nEmpresa == 0, "IN(2,3)", "= 4" )
Lineas( cQry,@aExt,oRpt,"T R A S L A D O S",4,1 )

cQry := "SELECT d.fechad, d.documen, d.cantidad, d.pcosto, d.causadev, e.localiz "+;
        "FROM cadempre e, caddevod d "                +;
        "WHERE d.destino = e.optica"                  +;
         " AND d.optica = "+ LTRIM(STR(oApl:nEmpresa))+;
         " AND d.codigo = "  + xValToChar( aLS[1] )   +;
         " AND d.fechad >= " + xValToChar( aLS[2] )   +;
         " AND d.fechad <= " + xValToChar( aLS[3] )   +;
         " AND d.causadev NOT IN(6, 7) AND d.indica <> 'B'"
//         " AND d.causadev <= 5 AND d.indica <> 'B'"
Lineas( cQry,@aExt,oRpt,"D E V O L U C I O N E S",5,-1 )
If oApl:nEmpresa > 0
   If aLS[2] <= CTOD("09.04.2007")
      cQry := "SELECT fecfac, numfac, cantidad, precioven, indicador, fecdev "+;
              "FROM cadventa "                             +;
              "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND codart = "  + xValToChar( aLS[1] )    +;
               " AND fecdev >= " + xValToChar( aLS[2] )    +;
               " AND fecdev <= " + xValToChar( aLS[3] )    +;
               " AND tipo <> 'Z'"                          +;
               " AND indicador IN ('A', 'D')"              +;
               " AND NOT(indicador = 'A' AND fecfac = fecdev)"
      If oApl:cLocal == "LOC"
         cQry := STRTRAN( cQry,"precioven","pcosto" )
      EndIf
      Lineas( cQry,@aExt,oRpt,"DEVOLUCION DE CLIENTES",6,0 )
   EndIf
   cQry := "SELECT fechad, CONCAT('DEV.',documen), "      +;
           "cantidad, pcosto, numrep FROM caddevod "      +;
           "WHERE optica = "  + LTRIM(STR(oApl:nEmpresa)) +;
            " AND codigo = "  + xValToChar( aLS[1] )      +;
            " AND fechad >= " + xValToChar( aLS[2] )      +;
            " AND fechad <= " + xValToChar( aLS[3] )      +;
            " AND causadev IN(6, 7) AND indica <> 'B'"    +;
           " UNION ALL "                                  +;
           "SELECT c.fecha, CONCAT('N.C.',c.numero), "    +;
                  "d.cantidad, d.pcosto, c.numfac "       +;
           "FROM cadnotad d, cadnotac c "                 +;
           "WHERE d.codigo = " + xValToChar( aLS[1] )     +;
            " AND c.optica = d.optica"                    +;
            " AND c.numero = d.numero"                    +;
            " AND c.optica = [OPT]"                       +;
            " AND c.fecha >= " + xValToChar( aLS[2] )     +;
            " AND c.fecha <= " + xValToChar( aLS[3] )     +;
            " AND c.clase <= 2"
   CambiarNC( @cQry )
   Lineas( cQry,@aExt,oRpt,"DEVOLUCION DE CLIENTES",6,1 )
EndIf

cQry := "SELECT fecha, numero, cantidad, pcosto, tipo FROM cadajust "+;
        "WHERE optica = " + LTRIM(STR(oApl:nEmpresa)) +;
         " AND fecha >= " + xValToChar( aLS[2] )      +;
         " AND fecha <= " + xValToChar( aLS[3] )      +;
         " AND codigo = " + xValToChar( aLS[1] )      +;
         " AND indica <> 'B'"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) > 0
   oRpt:Titulo( 73,10 )
   oRpt:Say( oRpt:nL+1,05,PADC( "A J U S T E S",68,"=" ) )
   oRpt:nL += 2
EndIf
While nL > 0
   cQry := MyReadRow( hRes )
   AEVAL( cQry, { | xV,nP | cQry[nP] := MyClReadCol( hRes,nP ) } )
    nK  := If( cQry[5] == 1, 4, 5 )
   cQry[5] := { "Sobrante(+)","Faltante(-)","Faltante(-)" }[cQry[5]]
   oRpt:Titulo( 73,10 )
   oRpt:Say( oRpt:nL,05,cQry[1] )
   oRpt:Say( oRpt:nL,16,cQry[2] )
   oRpt:Say( oRpt:nL,30,TRANSFORM(cQry[3],  "9,999") )
   oRpt:Say( oRpt:nL,38,TRANSFORM(cQry[4],"999,999,999.99") )
   oRpt:Say( oRpt:nL,54,cQry[5] )
   oRpt:nL++
   aExt[nK] += cQry[3]  //4_Sobrante, 5_Faltante
   nL --
EndDo
MSFreeResult( hRes )

aExt[7] += aExt[4] - aExt[5]
aExt[8] := SaldoInv( aLS[1],aLS[5],1 )
oRpt:Titulo( 73,10 )
oRpt:Say( oRpt:nL  ,05,REPLICATE("_",68),,,1 )
oRpt:Say( oRpt:nL+1,07,"AJUSTE POR SOBRANTES :" + TRANSFORM(aExt[4],"99,999"),,,1)
oRpt:Say( oRpt:nL+2,07,"AJUSTE POR FALTANTES :" + TRANSFORM(aExt[5],"99,999"),,,1)
oRpt:Say( oRpt:nL+4,07,"SALDO MATEMATICO     :" + TRANSFORM(aExt[7],"99,999"),,,1)
oRpt:Say( oRpt:nL+5,07,"EXISTENCIA ACTUAL    :" + TRANSFORM(aExt[8],"99,999"),,,1)
oRpt:NewPage()
oRpt:End()
RETURN

//------------------------------------//
STATIC FUNCTION Lineas( cQry,aExt,oRpt,cTit,nX,nV,cCon )
   LOCAL aRes, hRes, nL, bExt := {|| cQry := "" }, nSec
do Case
Case nX == 1
   bExt := {|| cQry := If( LEFT(aExt[2],4) == "0599", aRes[5], "" )}
Case nX == 2 .AND. nV < 1
   bExt := {|| aRes[2] := STR(aRes[2],6) + "-" + aRes[5], cQry := "" }
Case nX == 3 .AND. cCon # NIL
   bExt := {|| cQry := StrZero( VAL(aRes[5])+aRes[3]-1,6 ),;
               aRes[3] := If( aRes[5] <= cCon .AND. cCon <= cQry, 1, 0 ) }
Case nX == 4
   bExt := {|| aRes[2] := STR(aRes[2],6) + "-" + aRes[5], cQry := "" }
Case nX == 5
   bExt := {|| aRes[2] := STR(aRes[2],6) + "-" +;
               If( aRes[5] == 5, "S.C", aRes[6] ), cQry := "" }
Case nX == 6 .AND. nV == 0
   bExt := {|| cQry := aRes[5] + " " + DTOC(aRes[6]) }
Case nX == 6
   bExt := {|| cQry := "Fac."+STR(aRes[5],7) }
EndCase

//nSec := Seconds()
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EVAL( bExt )
   If aRes[3] # 0
      oRpt:Titulo( 73,10 )
      If aExt[8] == 0
         oRpt:Say( oRpt:nL+1,05,PADC( cTit,68,"=" ) )
         oRpt:nL += 2
      EndIf
      oRpt:Say( oRpt:nL,05,aRes[1] )
      oRpt:Say( oRpt:nL,16,aRes[2] )
      oRpt:Say( oRpt:nL,30,TRANSFORM(aRes[3],  "9,999") )
      oRpt:Say( oRpt:nL,38,TRANSFORM(aRes[4],"999,999,999.99") )
      oRpt:Say( oRpt:nL,53,cQry )
      oRpt:nL++
      aExt[8] += aRes[3]
      aExt[9] += aRes[4] * If( nX == 1, 1, aRes[3] )
   EndIf
   nL --
EndDo
//MsgInfo( "Ha tardado " + STR( Seconds() - nSec ),cTit )
MSFreeResult( hRes )
If aExt[8] > 0 .AND. nV # 0
   aRes := { "TOTAL VENTA           :","TOTAL REPOSICIONES    :",;
             "TOTAL INGRESOS(COMPRA):","ENTRADAS POR TRASLADO :",;
             "DEVOLUCIONES A BODEGA :","DEVOLUCION DE CLIENTES:" }
   oRpt:Say( oRpt:nL++,05,REPLICATE("_",68) )
   oRpt:Say( oRpt:nL  ,06,aRes[nX] + TRANSFORM( aExt[8],"99,999" ) )
   oRpt:Say( oRpt:nL++,38,TRANSFORM( aExt[9],"999,999,999.99" ) )
   aExt[7] += aExt[8] * nV
   aExt[8] := aExt[9] := 0
EndIf
RETURN NIL