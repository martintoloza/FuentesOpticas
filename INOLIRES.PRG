// Programa.: INOLIRES.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo ventas de las opticas
#include "FiveWin.ch"

MEMVAR oApl

PROCEDURE InoLiRes()
   LOCAL oDlg, oGet := ARRAY(7), aOpc := { NtChr( DATE(),"1" ),oApl:nUS,.f.,1,.t. }
DEFINE DIALOG oDlg TITLE "Resumen de Ventas" FROM 0, 0 TO 08,50
   @ 02, 00 SAY "DIGITE EL PERIODO" OF oDlg RIGHT PIXEL SIZE 88,10
   @ 02, 90 GET oGet[1] VAR aOpc[1] OF oDlg PICTURE "999999";
      VALID NtChr( aOpc[1],"P" )   SIZE 30,12 PIXEL
   @ 16, 00 SAY "VALOR  DEL  DOLAR" OF oDlg RIGHT PIXEL SIZE 88,10
   @ 16, 90 GET oGet[2] VAR aOpc[2] OF oDlg PICTURE "9,999" SIZE 30,12 PIXEL
   @ 16,140 CHECKBOX oGet[3] VAR aOpc[3] PROMPT ANSITOOEM("Todo el AÑO") OF oDlg ;
      SIZE 60,12 PIXEL
   @ 30, 00 SAY "CLASE DE LISTADO"   OF oDlg RIGHT PIXEL SIZE 88,10
   @ 30, 90 COMBOBOX oGet[4] VAR aOpc[4] ITEMS { "MS-DOS","Excel","OpenOffice" };
      SIZE 48,90 OF oDlg PIXEL
   @ 30,140 CHECKBOX oGet[5] VAR aOpc[5] PROMPT "Vista &Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 46, 50 BUTTON oGet[6] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ;
      ACTION ( oGet[6]:Disable(), ListoRsm( aOpc ), oDlg:End() ) PIXEL
   @ 46,100 BUTTON oGet[7] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 52, 02 SAY "[INOLIRES]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT ( Empresa( .t. ) )
RETURN

//------------------------------------//
STATIC PROCEDURE ListoRsm( aLS )
   LOCAL aRes, cQry, hRes, nC, nL, nF, nS, oRpt
   LOCAL aRS := ARRAY(10,12), aGT := { NtChr( aLS[1],"F" ),0,0,"",aLS[1] }
AEVAL( aRS, { |x| AFILL( x,0 ) } )
If aLS[3]
   aGT[1] := CTOD( "01.01."+LEFT(aLS[1],4) )
   aGT[2] := CTOD( "31.12."+LEFT(aLS[1],4) )
   aGT[5] := LEFT(aLS[1],4) + "12"
   aLS[1] := LEFT(aLS[1],4) + "01"
Else
   aGT[2] := CTOD( NtChr( aGT[1],"4" ) )
EndIf
   aGT[3] := NtChr( aGT[1]-1,"1" )
// Saldos de Inventario
cQry := "SELECT s.codigo, s.existencia, s.pcosto, s.anomes, i.moneda, "+;
        "s.entradas, s.devol_e, s.devolcli, s.salidas, s.devol_s, s.ajustes_e, s.ajustes_s "+;
        "FROM cadinvme s, cadinven i "                           +;
        "WHERE s.optica = " + LTRIM(STR(oApl:nEmpresa))          +;
         " AND s.anomes = (SELECT MAX(m.anomes) FROM cadinvme m "+;
                          "WHERE m.optica  = s.optica"           +;
	                         " AND m.codigo  = s.codigo"           +;
			                     " AND m.anomes <= '" + aLS[1] + "')"  +;
         " AND (s.existencia <> 0 OR s.anomes = '"+ aLS[1] + "')"+;
         " AND i.codigo = s.codigo AND i.moneda <> 'C'"
nF := 10                 //SaldoAct
//FOR nS := 1 TO 2
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   While nL > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      nC      := LeerGrupo( aRes[1] )
      aRes[3] := Dolar_Peso( aLS[2],aRes[3],aRes[5] )  //PCosto
      aRS[nF][nC]   +=  aRes[2]
      aRS[nF][nC+4] += (aRes[2] * aRes[3])
      If aRes[4] == aLS[1]
         aRS[3][nC+8] += (aRes[3] * aRes[06])
         aRS[4][nC+8] += (aRes[3] * aRes[07])
         aRS[5][nC+8] += (aRes[3] * aRes[08])
         aRS[6][nC+8] += (aRes[3] * aRes[09])
         aRS[7][nC+8] += (aRes[3] * aRes[10])
         aRS[8][nC+8] += (aRes[3] * aRes[11])
         aRS[9][nC+8] += (aRes[3] * aRes[12])
         aRes[2] := SaldoInv( aRes[1],aGT[3],1 )
         aRes[3] := Dolar_Peso( aLS[2],oApl:aInvme[2],aRes[5] )
      EndIf
      aRS[01][nC]   +=  aRes[2]
      aRS[01][nC+4] += (aRes[2] * aRes[3])
      nL --
   EndDo
   MSFreeResult( hRes )
//   cQry := STRTRAN( cQry,aLS[1],aGT[3] )
//   nF := 1               //SaldoAnt
//NEXT nS
// 2_Reposiciones
   cQry := "= " + LTRIM(STR(oApl:nEmpresa))
If oApl:nEmpresa == 0
   aRes := Privileg( {"Principal",4,"Optica <> ",1},.t.,.f. )
   cQry := aRes[1]
EndIf
cQry := "SELECT d.codigo, d.cantidad, d.pcosto, i.moneda "+;
        "FROM cadrepoc c, cadrepod d, cadinven i "        +;
        "WHERE c.optica "      + cQry                     +;
         " AND c.fecharep >= " + xValToChar( aGT[1] )     +;
         " AND c.fecharep <= " + xValToChar( aGT[2] )     +;
         " AND d.numrep = c.numrep"                       +;
         " AND d.indica <> 'B' AND i.codigo = d.codigo"
Detalle( @aRS,cQry,aLS[2],2 )
// 3_Compras de Monturas
cQry := "SELECT c.moneda, d.cantidad, d.pcosto "        +;
        "FROM cadmontd d, comprasc c "                  +;
        "WHERE d.indica <> 'B' AND d.consec <> ''"      +;
         " AND c.ingreso = d.ingreso"                   +;
         " AND c.optica  = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fecingre >= " + xValToChar( aGT[1] )   +;
         " AND c.fecingre <= " + xValToChar( aGT[2] )   +;
         " AND c.moneda NOT IN('C','X')"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
nC   := 1
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[3] := Dolar_Peso( aLS[2],aRes[3],aRes[1] )  //PCosto
   aRS[3][nC]   +=  aRes[2]
   aRS[3][nC+4] += (aRes[2] * aRes[3])
   nL --
EndDo
MSFreeResult( hRes )
// 3_Compras de Articulos
cQry := "SELECT d.codigo, d.cantidad, d.pcosto, 'X' "   +;
        "FROM cadartid d, comprasc c "                  +;
        "WHERE d.indica <> 'B'"                         +;
         " AND c.ingreso = d.ingreso"                   +;
         " AND c.optica  = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fecingre >= " + xValToChar( aGT[1] )   +;
         " AND c.fecingre <= " + xValToChar( aGT[2] )   +;
         " AND c.moneda  = 'X'"
Detalle( @aRS,cQry,aLS[2],3 )
// 6_Ventas
   cQry := "SELECT v.codart, v.cantidad, v.pcosto, v.fecdev, i.moneda "+;
           "FROM cadfactu c, cadventa v LEFT JOIN cadinven i"+;
             " ON v.codart  = i.codigo "                     +;
           "WHERE LEFT(v.codart,2) NOT IN('02','05')"        +;
            " AND c.optica  = v.optica"                      +;
            " AND c.numfac  = v.numfac"                      +;
            " AND c.tipo    = v.tipo"                        +;
            " AND c.optica  = [OPT]"                         +;
            " AND c.fechoy >= " + xValToChar( aGT[1] )       +;
            " AND c.fechoy <= " + xValToChar( aGT[2] )       +;
            " AND c.tipo   <> 'Z'"
If oApl:nEmpresa == 18
   cQry := STRTRAN( cQry,"[OPT]","18" ) +;
            " AND c.autoriza <> 'FOCA'"
/*
   cQry := "SELECT v.codart, v.cantidad, v.pcosto, v.fecdev, i.moneda "+;
           "FROM cadfactu c, cadventa v LEFT JOIN cadinven i"+;
             " ON v.codart  = i.codigo "                     +;
           "WHERE c.optica  = 18"                            +;
            " AND c.fechoy >= " + xValToChar( aGT[1] )       +;
            " AND c.fechoy <= " + xValToChar( aGT[2] )       +;
            " AND c.autoriza "  +     If( oApl:nEmpresa == 18,;
                    "<>", "=" ) + " 'FOCA'"                  +;
            " AND v.optica  = c.optica"                      +;
            " AND v.numfac  = c.numfac"                      +;
            " AND v.tipo    = c.tipo"                        +;
            " AND LEFT(v.codart,2) NOT IN('02','05')"
*/
ElseIf oApl:nEmpresa == 21
   If aGT[1] >= CTOD("01.09.2015")
      cQry := STRTRAN( cQry,"[OPT]","21" )
   Else
      cQry := STRTRAN( cQry,"[OPT]","18" ) +;
               " AND c.autoriza = 'FOCA'"
   EndIf
Else
   cQry := STRTRAN( cQry,"[OPT]",LTRIM(STR(oApl:nEmpresa)) )
EndIf
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If NtChr( aRes[4],"1" ) # aLS[1] .AND. aRes[5] # "C"
      nC      := LeerGrupo( aRes[1] )
      aRes[3] := Dolar_Peso( aLS[2],aRes[3],aRes[5] )
      aRS[6][nC]   +=  If( oApl:nEmpresa == 0 .OR. LEN( ALLTRIM( aRes[1] ) ) >= 10, aRes[2], 0 )
      aRS[6][nC+4] += (aRes[3] * If( oApl:nEmpresa == 0, 1, aRes[2] ))
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
// 5_Devolucion de Clientes
If oApl:nEmpresa # 0
   If aGT[1] <= CTOD("09.04.2007")
      aGT[4]:= "SELECT v.codart, v.cantidad, v.pcosto FROM cadventa v, cadinven i "+;
               "WHERE v.optica  = " + LTRIM(STR(oApl:nEmpresa))+;
                " AND v.fecdev >= " + xValToChar( aGT[1] )     +;
                " AND v.fecdev <= " + xValToChar( aGT[2] )     +;
                " AND v.tipo   <> 'Z'"                         +;
                " AND LEFT(v.codart,2) NOT IN('02','05')"      +;
                " AND v.indicador IN('A','D')"                 +;
                " AND EXTRACT(YEAR_MONTH FROM v.fecfac) <> " + xValToChar( aLS[1] )+;
                " AND i.codigo = v.codart AND i.moneda <> 'C'" +;
                " UNION ALL "
   //           " AND NOT(indicador = 'A' AND fecfac = fecdev)"
   EndIf
   cQry := aGT[4] +;
        "SELECT d.codigo, d.cantidad, d.pcosto "   +;
        "FROM cadinven i, cadnotad d, cadnotac c " +;
        "WHERE i.moneda <> 'C'"                    +;
         " AND d.codigo = i.codigo"                +;
         " AND LEFT(d.codigo,2) NOT IN('02','05')" +;
         " AND c.optica = d.optica"                +;
         " AND c.numero = d.numero"                +;
         " AND c.optica = [OPT]"                   +;
         " AND c.fecha >= " + xValToChar( aGT[1] ) +;
         " AND c.fecha <= " + xValToChar( aGT[2] ) +;
         " AND c.clase <= 2"
   CambiarNC( @cQry,aGT[1] )
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   While nL > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      nC     := LeerGrupo( aRes[1] )
      aRS[5][nC]   +=  aRes[2]
      aRS[5][nC+4] += (aRes[2] * aRes[3])
      nL --
   EndDo
   MSFreeResult( hRes )
EndIf
// 4_Traslados
aGT[3] := "SELECT d.codigo, d.cantidad, d.pcosto, i.moneda, "+;
          "d.causadev, d.destino FROM caddevod d, cadinven i "+;
          "WHERE d.destino = " + LTRIM(STR(oApl:nEmpresa))   +;
           " AND d.fechad >= " + xValToChar( aGT[1] )        +;
           " AND d.fechad <= " + xValToChar( aGT[2] )
aGT[4] :=  " AND d.indica <> 'B'"                            +;
           " AND i.codigo = d.codigo AND i.moneda <> 'C'"
If oApl:nEmpresa == 0
   cQry := aGT[3] +;
         " AND d.optica <> d.destino"                  +;
         " AND d.causadev IN (2,3) AND d.indica <> 'B'"+;
         " AND i.codigo = d.codigo AND i.moneda <> 'C'"+;
         " AND i.grupo <> '6' AND i.compra_d = '0'"
Else
   cQry := aGT[3] + aGT[4]
EndIf
Detalle( @aRS,cQry,aLS[2],4 )
// 7_Devoluciones y Traslados
cQry := STRTRAN( aGT[3],"destino","optica",2 ) + aGT[4]
Detalle( @aRS,cQry,aLS[2],7 )
If oApl:nEmpresa == 21
   cQry := "SELECT d.codigo, d.cantidad, d.pcosto, i.moneda, "+;
                "d.causadev, 21 FROM caddevod d, cadinven i " +;
           "WHERE d.optica  = 18"                             +;
            " AND d.destino = 21"                             +;
            " AND d.fechad >= " + xValToChar( aGT[1] )        +;
            " AND d.fechad <= " + xValToChar( aGT[2] )        +;
            " AND d.causadev = 6 AND d.indica <> 'B'"         +;
            " AND i.codigo  = d.codigo AND i.moneda <> 'C'"
   Detalle( @aRS,cQry,aLS[2],7 )
EndIf
// 8_Ajustes
cQry := "SELECT a.codigo, a.cantidad, a.pcosto, u.movto "+;
        "FROM cadajust a, cadcausa u, cadinven i  "      +;
        "WHERE a.optica  = " + LTRIM(STR(oApl:nEmpresa)) +;
         " AND a.fecha  >= " + xValToChar( aGT[1] )      +;
         " AND a.fecha  <= " + xValToChar( aGT[2] )      +;
         " AND a.indica <> 'B'"                          +;
         " AND u.clase  = 'Ajustes' AND u.tipo = a.tipo" +;
         " AND i.codigo = a.codigo AND i.moneda <> 'C'"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If (nC := LeerGrupo( aRes[1] )) > 0
      nS  := If( aRes[4] == 5, 8, 9 )
      aRS[nS][nC]   +=  aRes[2]
      aRS[nS][nC+4] += (aRes[2] * aRes[3])
   EndIf
   nL --
EndDo
MSFreeResult( hRes )

aRes := {6,7,9}
If oApl:nEmpresa == 0
   AADD( aRes,2 )
EndIf
FOR nL := 1 TO LEN( aRes )
  nF := aRes[nL]
  AEVAL( aRS[nF], { |xV,nP| aRS[nF,nP] := xV *-1 } )
NEXT nL
aRes := { "Saldo Anterior           ","Reposiciones del Mes     ",;
          "C o m p r as del Mes     ","Traslados de Otras Optic ",;
          "Devolucion de Clientes   ","Ventas del Mes           ",;
          "Devoluciones y Traslados ","Ajustes de Entradas      ",;
          "Ajustes de Salidas       ","Saldo  Actual            " }
If aLS[3]
   aRS[10,1] := aRS[10,2] := aRS[10,3] := aRS[10,4] := 0
   aRS[10,5] := aRS[10,6] := aRS[10,7] := aRS[10,8] := 0
   FOR nF := 1 TO 9
      FOR nC := 1 TO 8
         aRS[10,nC] += aRS[nF,nC]
      NEXT nC
   NEXT nF
   aGT[4] := "PERIODO " + TRANSFORM( YEAR(aGT[2]),"9,999" )
Else
   aGT[4] := NtChr( aGT[2],"3" )
EndIf
If aLS[4] == 1
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,{"MOVIMIENTO A",aGT[4]},aLS[5] )
   oRpt:Titulo( 70 )
   oRpt:Say( 08,03,TRANSFORM( aLS[2],"US 99,999" ) )
   oRpt:Say( 08,31,"Monturas      Liquidos    Accesorios    L.Contacto" )
   oRpt:nL := 10
   aGT  := { {0,0,0,0},{0,0,0,0} }
   FOR nF := 1 TO 9
      oRpt:Say( oRpt:nL  ,01,aRes[nF] + LeerGrupo( aRS,nF,0 ) )
      oRpt:Say( oRpt:nL+1,23,   "$  " + LeerGrupo( aRS,nF,4 ) )
      oRpt:nL += 3
       aGT[1,1]  += aRS[nF,05] ; aGT[1,2]   += aRS[nF,06]
       aGT[1,3]  += aRS[nF,07] ; aGT[1,4]   += aRS[nF,08]
      aRS[10,09] += aRS[nF,09] ; aRS[10,10] += aRS[nF,10]
      aRS[10,11] += aRS[nF,11] ; aRS[10,12] += aRS[nF,12]
   NEXT nF
       aGT[2,1]  := aRS[10,05]-aGT[1,1] ; aGT[2,2] += aRS[10,06]-aGT[1,2]
       aGT[2,3]  := aRS[10,07]-aGT[1,3] ; aGT[2,4] += aRS[10,08]-aGT[1,4]
   oRpt:Say( 36,26,"===========   ===========   ===========   ===========" )
   oRpt:Say( 37,01,aRes[10] + LeerGrupo( aRS,10,0 ) )
   oRpt:Say( 38,23,   "$  " + LeerGrupo( aRS,10,4 ) )
   oRpt:Say( 39,20,"SUMAS " + LeerGrupo( aGT,01,0 ) )
   oRpt:Say( 40,20,"DIFER " + LeerGrupo( aGT,02,0 ) )
   If !aLS[3]
      oRpt:Say( 44,31,"TOTALES A COSTO PROMEDIO" )
      oRpt:nL := 45
      aRS[10,09] += aRS[01,05] ; aRS[10,10] += aRS[01,06]
      aRS[10,11] += aRS[01,07] ; aRS[10,12] += aRS[01,08]
      aRS[10,05] -= aRS[10,09] ; aRS[10,06] -= aRS[10,10]
      aRS[10,07] -= aRS[10,11] ; aRS[10,08] -= aRS[10,12]
      FOR nF := 3 TO 10
         oRpt:Say( oRpt:nL  ,01,aRes[nF] + LeerGrupo( aRS,nF,8 ) )
         oRpt:nL += 2
      NEXT nF
      oRpt:Say( oRpt:nL,14,"DIFERENCIA  "+ LeerGrupo( aRS,10,4 ) )
   EndIf
   oRpt:NewPage()
   oRpt:End()
ElseIf aLS[4] == 2
   cQry := cFilePath( GetModuleFileName( GetInstance() )) + "Test1.xls"
   oRpt := TExcelScript():New()
   oRpt:Create( cQry )
   oRpt:Font("Verdana")
   oRpt:Size(10)
 //oRpt:ColumnWidth( 1 , 25.00 )
   oRpt:Align(1)
   oRpt:Visualizar(.F.)
   oRpt:Say(  1 , 1 , oApl:cEmpresa )
   oRpt:Say(  2 , 2 , "MOVIMIENTO A " + aGT[4] )
   oRpt:Say(  3 , 2 , "Monturas" )
   oRpt:Say(  3 , 3 , "Liquidos" )
   oRpt:Say(  3 , 4 , "Accesorios" )
   oRpt:Say(  3 , 5 , "L.Contacto" )
   oRpt:Say(  3 , 6 , "T O T A L" )
   aGT := "=SUMA(B*:E*)"
   FOR nF := 1 TO 10
      oRpt:Say( nF+3 , 1 , aRes[nF] )
      oRpt:Say( nF+3 , 2 , aRS[nF,5] )
      oRpt:Say( nF+3 , 3 , aRS[nF,6] )
      oRpt:Say( nF+3 , 4 , aRS[nF,7] )
      oRpt:Say( nF+3 , 5 , aRS[nF,8] )
      oRpt:Say( nF+3 , 6 , STRTRAN( aGT,"*",LTRIM(STR(nF+3)) ) )
   NEXT nF
   oRpt:Say( nF+3 , 2 , "=SUMA(B4:B12)" )
   oRpt:Say( nF+3 , 3 , "=SUMA(C4:C12)" )
   oRpt:Say( nF+3 , 4 , "=SUMA(D4:D12)" )
   oRpt:Say( nF+3 , 5 , "=SUMA(E4:E12)" )

   oRpt:Say( nF+5 , 2 , "DIFERENCIAS" )
   oRpt:Say( nF+5 , 2 , "=SUMA(B13-B14)" )
   oRpt:Say( nF+5 , 3 , "=SUMA(C13-C14)" )
   oRpt:Say( nF+5 , 4 , "=SUMA(D13-D14)" )
   oRpt:Say( nF+5 , 5 , "=SUMA(E13-E14)" )
   oRpt:Visualizar(.T.)
   oRpt:End(.F.) ; oRpt := NIL
Else
/*
   cQry := cFilePath( GetModuleFileName( GetInstance() )) + "Test1.xls"
   oRpt := TXls():New( cQry,.t. )
   oRpt:Write( 1, 1, oApl:cEmpresa )
   oRpt:Write( 2, 1, "MOVIMIENTO A " + aGT[4] )
   oRpt:Write( 3, 2 , "Monturas" )
   oRpt:Write( 3, 3 , "Liquidos" )
   oRpt:Write( 3, 4 , "Accesorios" )
   oRpt:Write( 3, 5 , "L.Contacto" )
   oRpt:Write( 3, 6 , "T O T A L" )

   aGT := "=SUMA(B*:E*)"
   FOR nF := 1 TO 10
      oRpt:Write( nF+3 , 1 , aRes[nF] )
      oRpt:Write( nF+3 , 2 , LTRIM(STRTRAN( STR(aRS[nF,5]),".","," )) )
      oRpt:Write( nF+3 , 3 , LTRIM(STRTRAN( STR(aRS[nF,6]),".","," )) )
      oRpt:Write( nF+3 , 4 , LTRIM(STRTRAN( STR(aRS[nF,7]),".","," )) )
      oRpt:Write( nF+3 , 5 , LTRIM(STRTRAN( STR(aRS[nF,8]),".","," )) )
   NEXT nF
   oRpt:Close()
   XLS( cQry )
   cQry := cFilePath( GetModuleFileName( GetInstance() )) + "Test1.txt"
*/
   cQry := cFilePath( GetModuleFileName( GetInstance() )) + "Test1.csv"
   FERASE(cQry)
   hRes := FCREATE(cQry,0) //, FC_NORMAL)
   If FERROR() != 0
      Msginfo(FERROR(),"No se pudo crear el archivo "+cQry )
      RETURN
   EndIf
   aGT[1] := "=SUMA(B*:E*)"
   aGT[2] := CHR(13) + CHR(10)  //CRLF

   FWRITE( hRes,'"'+oApl:cEmpresa+'"'+aGT[2] )
   FWRITE( hRes,'"MOVIMIENTO A ' + aGT[4] + '"' +aGT[2] )
   FWRITE( hRes,'"","Monturas","Liquidos","Accesorios","L.Contacto","T O T A L"'+aGT[2] )

   FOR nF := 1 TO 10
      aGT[3] := XTrim( aRes[nF] ,-9 ) + XTrim( aRS[nF,5],-9 ) +;
                XTrim( aRS[nF,6],-9 ) + XTrim( aRS[nF,7],-9 ) + XTrim( aRS[nF,8],-9 )
      FWRITE( hRes,aGT[3]  + '"' + STRTRAN( aGT[1],"*",LTRIM(STR(nF+3)) ) + '"' + aGT[2] )
   NEXT nF
   FWRITE( hRes,'"SUMATORIA","=SUMA(B4:B12)","=SUMA(C4:C12)",' +;
                            '"=SUMA(D4:D12)","=SUMA(E4:E12)"'  +  aGT[2] )
   FWRITE( hRes,'""' + aGT[2] )
   FWRITE( hRes,'"DIFERENCIA","=SUMA(B13-B14)","=SUMA(C13-C14)",'+;
                             '"=SUMA(D13-D14)","=SUMA(E13-E14)"' + aGT[2] )
   If !FCLOSE(hRes)
      Msginfo(FERROR(),"Error cerrando el archivo "+cQry)
   EndIf
   WAITRUN("OPENOFICE.BAT " + cQry, 0 )
EndIf
RETURN

//------------------------------------//
STATIC PROCEDURE Detalle( aRS,cQry,nDol,nF )
   LOCAL aRes, hRes, nL, nC, nDC := 0
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
//MsgInfo( cQry,STR(nL) )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If !LEFT(aRes[1],2) $ "02  05"
      nC    := LeerGrupo( aRes[1] )
      If nF == 4 .AND. aRes[5] # 10
         If (aRes[5] == 3 .AND. oApl:nEmpresa == 0 .AND. nC == 1) .OR.;
           !(aRes[5] == 4  .OR. oApl:nEmpresa == 0)
             aRes[2] := 0
         EndIf
      ElseIf nF == 7
         nDC := If( Rango( aRes[5],6,7 ), 2, 0 )
         If aRes[5] == 10 .OR.;
           (aRes[5] ==  6 .AND. oApl:nEmpresa  # aRes[6])
            aRes[2] := 0
         EndIf
      EndIf
      aRes[3] := Dolar_Peso( nDol,aRes[3],aRes[4] )
      aRS[nF-nDC][nC]   +=  aRes[2]
      aRS[nF-nDC][nC+4] += (aRes[2] * aRes[3])
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
RETURN

//------------------------------------//
FUNCTION LeerGrupo( cCod,nF,nP )
   LOCAL nC, nX
If VALTYPE( cCod ) == "A"
   nC := ""
   FOR nX := 1 TO 4
      nC += TRANSFORM( cCod[nF,nP+nX],"999,999,999" ) + "   "
   NEXT
Else
   // 1_01, 2_05, 3_03, 4_04, 5_02, 6_>=60
   cCod := If( LEFT( cCod,2 ) >= "60", "6", SUBSTR( cCod,2,1 ) )
   If (nC := AT( cCod,"1346" )) == 0
      nC := 4
   EndIf
EndIf
RETURN nC