// Programa.: INOLIRID.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo resumen de Reposiciones, Devoluciones, Traslados
#include "FiveWin.ch"

MEMVAR oApl

PROCEDURE InoLiRid()
   LOCAL oDlg, oGet := ARRAY(7), aOpc := { CTOD(""),CTOD(""),1,oApl:nUS,.f. }
   LOCAL aItem := { "Reposiciones","Inventarios","Devoluciones",;
                    "Traslados","Compras","Ajustes" }
DEFINE DIALOG oDlg TITLE "Resumen de Varios" FROM 0, 0 TO 10,50
   @ 02,00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02,92 GET oGet[1] VAR aOpc[1] OF oDlg  SIZE 40,12 PIXEL
   @ 16,00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 16,92 GET oGet[2] VAR aOpc[2] OF oDlg ;
      VALID aOpc[2] >= aOpc[1] SIZE 40,12 PIXEL
   @ 30,00 SAY     "ESCOJA GRUPO DESEADO" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 30,92 COMBOBOX oGet[3] VAR aOpc[3] ITEMS aItem SIZE 54,99 ;
      OF oDlg PIXEL
   @ 44,00 SAY "VALOR  DEL  DOLAR" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 44,92 GET oGet[4] VAR aOpc[4] OF oDlg PICTURE "9,999" SIZE 30,12 PIXEL
   @ 44,150 CHECKBOX oGet[5] VAR aOpc[5] PROMPT "Vista &Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 60, 50 BUTTON oGet[6] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ;
      ACTION ( oGet[6]:Disable(), ListoRes( aOpc,oDlg ), oDlg:End() ) PIXEL
   @ 60,100 BUTTON oGet[7] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 66, 02 SAY "[INOLIRID]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
STATIC PROCEDURE ListoRes( aLS,oDlg )
   LOCAL oRpt, aGT := ARRAY(2,7), cQry, cQr1, cQr2
   LOCAL aDat := { "CARTIER","MONTURAS","LIQUIDOS","ACCESORIOS",;
                   "CONSIGNACION","L.CONTACTO" }, aEnt, nJ
cQry  := { "DATOS SUMINISTROS A OPTICAS","DATOS INVENTARIOS EN OPTICAS",;
           "DEVOLUCIONES","TRASLADOS","COMPRAS","AJUSTES"}[aLS[3]]     +;
         " EN EL PERIODO DE"
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{cQry,NtChr( aLS[2],"6" )},aLS[5] )
If MONTH( aLS[1] ) # MONTH( aLS[2] )
   oRpt:aEnc[2] := "DESDE " + NtChr(aLS[1],"2") + " HASTA " + NtChr(aLS[2],"2")
EndIf
do Case
Case aLS[3] == 1
   cQr1 := "SELECT d.codigo, d.cantidad, d.pcosto, i.moneda "+;
           "FROM cadrepoc c, cadrepod d, cadinven i "        +;
           "WHERE c.optica = <nOptica>"                      +;
            " AND c.fecharep >= " + xValToChar( aLS[1] )     +;
            " AND c.fecharep <= " + xValToChar( aLS[2] )     +;
            " AND d.numrep = c.numrep"                       +;
            " AND d.indica <> 'B' AND i.codigo = d.codigo"
Case aLS[3] == 2
   cQr1 := "SELECT s.codigo, s.existencia, s.pcosto, i.moneda "   +;
           "FROM cadinvme s, cadinven i "                         +;
           "WHERE s.optica = <nOptica>"                           +;
            " AND s.anomes = (SELECT MAX(anomes) FROM cadinvme m "+;
                             "WHERE m.optica = s.optica"          +;
                              " AND m.codigo = s.codigo"          +;
                              " AND m.anomes <= '" + NtChr( aLS[2],"1" )+;
          "') AND s.existencia <> 0 AND i.codigo = s.codigo"
Case aLS[3] == 3
   cQr1 := "SELECT d.codigo, d.cantidad, d.pcosto, i.moneda "+;
           "FROM caddevod d, cadinven i "                    +;
           "WHERE d.optica = <nOptica>"                      +;
            " AND d.fechad >= " + xValToChar( aLS[1] )       +;
            " AND d.fechad <= " + xValToChar( aLS[2] )       +;
            " AND d.causadev = 2"                            +;
            " AND d.indica <> 'B' AND i.codigo = d.codigo"
Case aLS[3] == 4
   cQr1 := "SELECT d.codigo, d.cantidad, d.pcosto, i.moneda "+;
           "FROM caddevod d, cadinven i "                    +;
           "WHERE d.destino = <nOptica>"                     +;
            " AND d.fechad >= " + xValToChar( aLS[1] )       +;
            " AND d.fechad <= " + xValToChar( aLS[2] )       +;
            " AND d.causadev = 4"                            +;
            " AND d.indica <> 'B' AND i.codigo = d.codigo"
Case aLS[3] == 5
   cQr1 := "SELECT '01', d.cantidad, d.pcosto, c.moneda "+;
           "FROM comprasc c, cadmontd d "                +;
           "WHERE c.optica = <nOptica>"                  +;
            " AND c.fecingre >= " + xValToChar( aLS[1] ) +;
            " AND c.fecingre <= " + xValToChar( aLS[2] ) +;
            " AND c.moneda <> 'X'"                       +;
            " AND d.ingreso = c.ingreso AND d.indica <> 'B'"
   cQr2 := "SELECT d.codigo, d.cantidad, d.pcosto, i.moneda "+;
           "FROM comprasc c, cadartid d, cadinven i "    +;
           "WHERE c.optica = <nOptica>"                  +;
            " AND c.fecingre >= " + xValToChar( aLS[1] ) +;
            " AND c.fecingre <= " + xValToChar( aLS[2] ) +;
            " AND c.moneda  = 'X'"                       +;
            " AND d.ingreso = c.ingreso"                 +;
            " AND d.indica <> 'B' AND i.codigo = d.codigo"
Case aLS[3] == 6
   cQr1 := "SELECT a.codigo, a.cantidad, a.pcosto, i.moneda "+;
           "FROM cadajust a, cadcausa u, cadinven i "    +;
           "WHERE a.optica  = <nOptica>"                 +;
            " AND a.fecha  >= " + xValToChar( aLS[1] )   +;
            " AND a.fecha  <= " + xValToChar( aLS[2] )   +;
            " AND a.indica <> 'B'"                       +;
            " AND u.clase = 'Ajustes' AND u.tipo = a.tipo"+;
            " AND u.movto = 5 AND i.codigo = a.codigo"
EndCase
aLS[5] := If( aLS[3] == 4 .OR. aLS[3] == 6, .t., .f. )
oApl:oEmp:Seek( {"orden_dato >= ",1},"orden_dato" )
While !oApl:oEmp:Eof()
   oDlg:SetText( oApl:oEmp:NOMBRE )
   AEVAL( aGT, { |x| AFILL( x,0 ) } )
   cQry := STRTRAN( cQr1,"<nOptica>",LTRIM(STR(oApl:oEmp:OPTICA)) )
   Sumatoria( @aGT,cQry,aLS[4] )
   If aLS[5]
      aEnt := ACLONE( aGT )
      AEVAL( aGT, { |x| AFILL( x,0 ) } )
      cQry := STRTRAN( cQry,"destino","optica" )
      cQry := STRTRAN( cQry,"to = 5","to = 6" )
      Sumatoria( @aGT,cQry,aLS[4] )
      aGT[1,7] += aEnt[1,7]
   ElseIf aLS[3] == 5
      cQry := STRTRAN( cQr2,"<nOptica>",LTRIM(STR(oApl:oEmp:OPTICA)) )
      Sumatoria( @aGT,cQry,aLS[4] )
   EndIf
   If aGT[1,7] > 0
      FOR nJ := 1 TO 6
         oRpt:Titulo( 78 )
         If aLS[5] .AND. oRpt:nL == 6
            oRpt:Say( 07,24,"E N T R A D A S               S A L I D A S" )
            oRpt:nL := 9
         EndIf
         If nJ == 1
            oRpt:Separator( 0,9 )
            oRpt:Say( oRpt:nL,01,oApl:oEmp:NOMBRE )
            oRpt:nL += 2
         EndIf
         If aLS[5]
            If aEnt[1,nJ] > 0 .OR. aGT[1,nJ] > 0
               oRpt:Say( oRpt:nL,05,aDat[nJ] )
               oRpt:Say( oRpt:nL,20,TRANSFORM(aEnt[1,nJ],"@Z 999,999") )
               oRpt:Say( oRpt:nL,30,If( nJ == 1, "US$", "" ) )
               oRpt:Say( oRpt:nL,33,TRANSFORM(aEnt[2,nJ],"@Z 999,999,999.99") )
               oRpt:Say( oRpt:nL,50,TRANSFORM( aGT[1,nJ],"@Z 999,999") )
               oRpt:Say( oRpt:nL,61,If( nJ == 1, "US$", "" ) )
               oRpt:Say( oRpt:nL,64,TRANSFORM( aGT[2,nJ],"@Z 999,999,999.99") )
               oRpt:nL ++
            EndIf
         Else
            If aGT[1,nJ] > 0
               oRpt:Say( oRpt:nL,07,aDat[nJ] )
               oRpt:Say( oRpt:nL,50,TRANSFORM( aGT[1,nJ],"999,999") )
               oRpt:Say( oRpt:nL,61,If( nJ == 1, "US$", "" ) )
               oRpt:Say( oRpt:nL,64,TRANSFORM( aGT[2,nJ],"999,999,999.99") )
               oRpt:nL ++
            EndIf
         EndIf
      NEXT
      If aLS[5]
         aGT[1,7] -= aEnt[1,7]
         oRpt:Say(  oRpt:nL,20,Replicate("=",58),,,1 )
         oRpt:Say(++oRpt:nL,07,"GRAN TOTAL" )
         oRpt:Say(  oRpt:nL,20,TRANSFORM( aEnt[1,7],"999,999") )
         oRpt:Say(  oRpt:nL,33,TRANSFORM( aEnt[2,7],"999,999,999.99") )
      Else
         oRpt:Say(  oRpt:nL,50,REPLICATE("=",28),,,1 )
         oRpt:Say(++oRpt:nL,07,"GRAN TOTAL" )
      EndIf
      oRpt:Say( oRpt:nL,50,TRANSFORM( aGT[1,7],"999,999") )
      oRpt:Say( oRpt:nL,64,TRANSFORM( aGT[2,7],"999,999,999.99") )
      oRpt:nL ++
   EndIf
   oApl:oEmp:Skip(1):Read()
   oApl:oEmp:xLoad()
   oRpt:nL += If( oApl:oEmp:ORDEN_DATO == 7, 60, If( aGT[1,7] > 0, 2, 0 ) )
EndDo
oRpt:NewPage()
oRpt:End()
oApl:oEmp:Seek( { "optica",oApl:nEmpresa } )
RETURN

//------------------------------------//
STATIC PROCEDURE Sumatoria( aGT,cQry,nUS )
   LOCAL aRes, hRes, nL, nA
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEval( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[1] := Grupos( aRes[1] )
   aRes[3] := Dolar_Peso( nUS,aRes[3],aRes[4] )  //PCosto
   If (nA := AT( aRes[1],"1 34 6" )) > 0
      nA := If( nA == 1, AT( aRes[4],"U   C" ), nA )
      aGT[1,nA] +=  aRes[2]
      aGT[2,nA] += (aRes[2] * aRes[3] )
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
aGT[1,7] := aGT[1,1]+ aGT[1,2]+ aGT[1,3]+ aGT[1,4]+ aGT[1,5]+ aGT[1,6]
aGT[2,7] := aGT[2,1]+ aGT[2,2]+ aGT[2,3]+ aGT[2,4]+ aGT[2,6]
RETURN