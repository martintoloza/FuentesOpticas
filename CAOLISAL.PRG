// Programa.: CAOLISAL.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Saldos de Cartera y Facturas Canceladas.
#include "FiveWin.ch"
#include "Btnget.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE CaoLiSal( nOpc )
   LOCAL aOpc, oC, oNi, oDlg, oGet := ARRAY(10)
   DEFAULT nOpc := 1
oC  := TCartera() ;  oC:NEW()
oNi := TNits()    ; oNi:New()
aOpc := { { {|| oC:NEW( 1 ) }  ,"Listo Saldos de Cartera" }  ,;
          { {|| oC:ListoCan() },"Listo Facturas Canceladas" } }
DEFINE DIALOG oDlg TITLE aOpc[nOpc,2] FROM 0, 0 TO 12,46
   @ 02, 00 SAY "Nit por Default Todos" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02, 92 BTNGET oGet[1] VAR oC:aLS[4] OF oDlg PICTURE "999999999999";
      VALID EVAL( {|| If( EMPTY( oC:aLS[4] ), .t.                     ,;
                     (If( oNi:Buscar( oC:aLS[4],,.t. )                ,;
                        ( oGet[10]:Settext( oNi:oDb:NOMBRE), .t. )    ,;
                        ( MsgStop("Este Nit no Existe"),.f. ) ))) } )  ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"                              ;
      ACTION EVAL({|| If(oNi:Mostrar( ,,oC:aLS[4] ), ( oC:aLS[4] :=    ;
                         oNi:oDb:CODIGO, oGet[1]:Refresh(), ), )} )
   @ 14, 10 SAY oGet[10] VAR oC:aLS[5] OF oDlg PIXEL SIZE 130,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 26, 00 SAY "FECHA DE CORTE [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 26, 92 GET oGet[2] VAR oC:aLS[1] OF oDlg  SIZE 40,10 PIXEL
   @ 38, 00 SAY "PAGINA INICIAL"            OF oDlg RIGHT PIXEL SIZE 90,10
   @ 38, 92 GET oGet[3] VAR oC:aLS[2] OF oDlg PICTURE "999";
      VALID Rango( oC:aLS[2],1,999 )  SIZE 24,10 PIXEL
    oGet[3]:cTooltip := "Digite 999 para Clientes Varios con sus Cedulas"
   @ 38,122 CHECKBOX oGet[4] VAR oC:aLS[6] PROMPT "Agrupar Opticas" OF oDlg;
       SIZE 60,10 PIXEL
   @ 50, 00 SAY "DESEA  UN  RESUMEN [S/N]"  OF oDlg RIGHT PIXEL SIZE 90,10
   @ 50, 92 GET oGet[5] VAR oC:aLS[7] OF oDlg PICTURE "!";
      VALID oC:aLS[7] $ "NS"  SIZE 08,10 PIXEL
   @ 50,122 CHECKBOX oGet[6] VAR oC:aLS[3] PROMPT "Vista Previa" OF oDlg;
       SIZE 60,10 PIXEL
   @ 62, 00 SAY "CLASE DE LISTADO"   OF oDlg RIGHT PIXEL SIZE 90,10
   @ 62, 92 COMBOBOX oGet[7] VAR oC:aLS[8] ITEMS { "Matriz","Laser","Excel","S.Salud" };
      SIZE 48,90 OF oDlg PIXEL
   @ 76, 50 BUTTON oGet[8] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[8]:Disable(), EVAL( aOpc[nOpc,1] ), oGet[8]:Enable(),;
        oGet[8]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 76,100 BUTTON oGet[9] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 80, 02 SAY "[CAOLISAL]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED NOMODAL
RETURN

//------------------------------------//
CLASS TCartera FROM TIMPRIME

 DATA aLS, aGT, aVG, aRS, hRes, nL

 METHOD NEW() Constructor
 METHOD Listo_Car()
 METHOD Laser_Car()
 METHOD Excel_Car()
 METHOD Listo_Var()
 METHOD Laser_Var()
 METHOD Excel_Var()
 METHOD SuperSalud()
 METHOD ListoCan()
ENDCLASS

//------------------------------------//
METHOD NEW( nLis ) CLASS TCartera
   LOCAL cQry, cSal
If nLis == NIL
   Empresa()
   ::aLS := { DATE(),1,.f.,0,"",.f.,"N",1 }
Else
   ::aVG := { "","999,999,999.99",.f. }
   If ::aLS[6]
      If ::aLS[2] == 999
         ::aLS[2] := 1
         ::aLS[7] := "N"
      Else
         ::aLS[7] := "S"
      EndIf
      ::aRS := Privileg( {"principal",oApl:oEmp:PRINCIPAL,"optica <> ",1},.t.,.f. )
      cQry     := ::aRS[1]
      ::aVG[1] := ::aRS[2]
   Else
      cQry := " = " + LTRIM(STR(oApl:nEmpresa))
   EndIf
      cSal := " AND s.optica = f.optica"                              +;
              " AND s.numfac = f.numfac AND s.tipo = s.tipo"          +;
              " AND s.anomes = (SELECT MAX(m.anomes) FROM cadfactm m "+;
                               "WHERE m.optica = f.optica"            +;
                                " AND m.numfac = f.numfac"            +;
                                " AND m.tipo   = f.tipo"              +;
                                " AND m.anomes <= '" + NtChr( ::aLS[1],"1" )+;
            "') AND s.saldo <> 0"
   If (nLis := ::aLS[8]) <= 3
      If ::aLS[2] == 999
/*
         cQry := "SELECT f.codigo_cli, f.cliente, f.fechoy, s.saldo "+;
                 "FROM cadfactm s, cadfactu f "                  +;
                 "WHERE f.optica "    + cQry                     +;
                  " AND f.fechoy <= " + xValToChar( ::aLS[1] )   +;
                  " AND f.tipo    = " + xValToChar( oApl:Tipo )  +;
                  " AND f.codigo_nit = 123" + cSal               +;
                 " ORDER BY f.codigo_cli"
*/
         cQry := "SELECT h.nroiden, CONCAT(h.nombres, ' ', h.apellidos), "+;
                        "f.cliente, f.codigo_cli, f.fechoy, s.saldo "+;
                 "FROM cadfactm s, cadfactu f LEFT JOIN historia h " +;
                   "ON f.codigo_cli = h.codigo_nit "                 +;
                 "WHERE f.optica "    + cQry                         +;
                  " AND f.fechoy <= " + xValToChar( ::aLS[1] )       +;
                  " AND f.tipo    = " + xValToChar( oApl:Tipo )      +;
                  " AND f.codigo_nit = 123" + cSal                   +;
                 " ORDER BY f.cliente, f.codigo_cli"
         nLis += 3
      Else
         ::aLS[7] := If( ::aLS[2] == 99, "S", ::aLS[7] )

         cQry := "SELECT n.nombre, n.codigo, n.digito, n.grupo, "     +;
                 "f.numfac, f.fechoy, f.cliente, f.totalfac, s.saldo "+;
                 "FROM cadfactm s, cadfactu f, cadclien n "      +;
                 "WHERE f.codigo_nit = n.codigo_nit"             +;
                  " AND f.optica "    + cQry                     +;
                  " AND f.fechoy <= " + xValToChar( ::aLS[1] )   +;
                  " AND f.tipo    = " + xValToChar( oApl:Tipo )  +If( ::aLS[4] > 0,;
                  " AND f.codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT)), "" ) +;
                  cSal + " ORDER BY n.nombre, f.fechoy, f.numfac"
      EndIf
   Else
         cQry := "SELECT n.nroiden NIT, -1, CONCAT(n.apellidos, ' ', n.nombres), f.fechoy, s.saldo, 0 DV "+;
                 "FROM cadfactm s, cadfactu f, historia n "      +;
                 "WHERE f.codigo_cli = n.codigo_nit"             +;
                  " AND f.optica "    + cQry                     +;
                  " AND f.fechoy <= " + xValToChar( ::aLS[1] )   +;
                  " AND f.tipo    = " + xValToChar( oApl:Tipo )  +;
                  " AND f.codigo_nit = 123"  + cSal              +;
                  " UNION ALL "                                  +;
                 "SELECT n.codigo NIT, n.digito, n.nombre, f.fechoy, s.saldo, 1 DV "  +;
                 "FROM cadfactm s, cadfactu f, cadclien n "      +;
                 "WHERE f.codigo_nit = n.codigo_nit"             +;
                  " AND f.optica "    + cQry                     +;
                  " AND f.fechoy <= " + xValToChar( ::aLS[1] )   +;
                  " AND f.tipo    = " + xValToChar( oApl:Tipo )  +;
                  " AND f.codigo_nit <> 123" + cSal              +;
                 " ORDER BY DV, NIT"
         nLis := 7
   EndIf
   ::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
                 MSStoreResult( oApl:oMySql:hConnect ), 0 )
   If (::nL := MSNumRows( ::hRes )) == 0
      MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
      MSFreeResult( ::hRes )
      RETURN NIL
   EndIf
   ::aGT := { {0,0,0,0,0,0,0},{0,0,0,0,0,0,0} }
   ::aRS := MyReadRow( ::hRes )
   AEVAL( ::aRS, { | xV,nP | ::aRS[nP] := MyClReadCol( ::hRes,nP ) } )
   cQry := { {|| ::Listo_Car() },{|| ::Laser_Car() },{|| ::Excel_Car() },;
             {|| ::Listo_Var() },{|| ::Laser_Var() },{|| ::Excel_Var() },;
             {|| ::SuperSalud() } }
   EVAL( cQry[nLis] )
   MSFreeResult( ::hRes )
   ::aLS[4] := 0
EndIf
RETURN NIL

//------------------------------------//
METHOD Listo_Car() CLASS TCartera
   LOCAL oRpt, aVence := { 0,0,0,0,0,0,0 }, nL
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"REPORTE DE CUENTAS POR COBRAR",;
         NtChr( ::aLS[1],"3" ),SPACE(50) + "--FACTURA-   ---FECHA---   -NOMBRE"+;
         " DEL CLIENTE-    TOTAL FACTURA   SALDO FACTURA"},::aLS[3],::aLS[2],2 )
If ::aLS[6]
   oRpt:aEnc[3] := STUFF( oRpt:aEnc[3],1,LEN( ::aVG[1] ),::aVG[1] )
EndIf
 ::aLS[5] := ::aRS[1]
 ::aVG[1] := PADR(::aRS[1],36) + TRANSFORM( ::aRS[2],"999,999,999-" ) + STR(::aRS[3],1)
 ::aVG[3] := ::aRS[4]
While ::nL > 0
   oApl:nSaldo := ::aRS[9]
   Vence( ::aLS[1] - ::aRS[6],@aVence )
   oRpt:Titulo( 130 )
   If oRpt:nPage >= oRpt:nPagI .AND. ::aLS[7] == "N"
      If ::aGT[1,5] == 0
         oRpt:Say( oRpt:nL,01,::aVG[1] )
      EndIf
      oRpt:Say( oRpt:nL, 50,STR(::aRS[5]) )
      oRpt:Say( oRpt:nL, 63,NtChr( ::aRS[6],"2" ) )
      oRpt:Say( oRpt:nL, 77,::aRS[7],20 )
      oRpt:Say( oRpt:nL,100,TRANSFORM(::aRS[8],::aVG[2]) )
      oRpt:Say( oRpt:nL,116,TRANSFORM(::aRS[9],::aVG[2]) )
      oRpt:nL ++
   EndIf
   ::aGT[1,5] += ::aRS[9]
   If (::nL --) > 1
      ::aRS := MyReadRow( ::hRes )
      AEVAL( ::aRS, {| xV,nP | ::aRS[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aRS[1] # ::aLS[5]
      If oRpt:nPage >= oRpt:nPagI
         AEVAL( aVence, {|nVal,nP| ::aGT[2,nP] += nVal } )
         If ::aLS[7] == "N"
            oRpt:Say(++oRpt:nL, 97,"TOTAL CLIENTE --> $"+oRpt:CPIBold,,,1 )
            oRpt:Say(  oRpt:nL,116,TRANSFORM( ::aGT[1,5],::aVG[2] )+oRpt:CPIBoldN )
         Else
            oRpt:Say(  oRpt:nL,01,::aVG[1],,,1 )
            oRpt:Say(  oRpt:nL,116,TRANSFORM( ::aGT[1,5],::aVG[2] ) )
            oRpt:nL ++
            Vence( 0,aVence,50,oRpt )
         EndIf
      EndIf
      oRpt:nL += 2
      If ::aVG[3]
         ::aGT[1,3] += ::aGT[1,5]
      ElseIf ::aLS[4] > 0
         ::aGT[1,2] += ::aGT[1,5]
      EndIf
      AFILL( aVence,0 )
      ::aGT[1,4] ++
      ::aGT[1,5] := 0
      ::aLS[5] := ::aRS[1]
      ::aLS[4] := ::aRS[2]
      ::aVG[1] := PADR(::aRS[1],36) + TRANSFORM( ::aRS[2],"999,999,999-" ) + STR(::aRS[3],1)
      ::aVG[3] := ::aRS[4]
   EndIf
EndDo
If ::aGT[1,4] > 0
   FOR nL := 1 TO 7
      aVence[nL] := ::aGT[2,nL]
   NEXT nL
   oRpt:Say(  oRpt:nL, 01,REPLICATE("_",129),,,1 )
   oRpt:Say(++oRpt:nL, 01,STR( ::aGT[1,4],3 ) + "  SALDOS",,,1 )
   oRpt:Say(  oRpt:nL,116,TRANSFORM(::aGT[2,7],::aVG[2]) )
   oRpt:Say(++oRpt:nL, 01,REPLICATE("_",129),,,1 )
   oRpt:nL += If( oRpt:nL+12 > oRpt:nLength, oRpt:nLength-oRpt:nL, 2 )
   oRpt:Titulo( 130 )
   oRpt:Say( oRpt:nL  ,10,"TOTAL OPTICAS GRUPO -------> $" + TRANSFORM( ::aGT[1,3],::aVG[2] ) )
   oRpt:Say( oRpt:nL+2,10,"TOTAL EMPRESAS ------------> $" + TRANSFORM( ::aGT[1,2],::aVG[2] ) )
   oRpt:Say( oRpt:nL+4,10,"TOTAL CUENTAS POR COBRAR --> $" + TRANSFORM( ::aGT[2,7],::aVG[2] ) )
   oRpt:nL += 6
   Vence( 0,aVence,10,oRpt )
EndIf
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD Laser_Car() CLASS TCartera
   LOCAL aRS, aVence := { 0,0,0,0,0,0,0 }, nL
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit      ,;
             "REPORTE DE CUENTAS POR COBRAR"  , NtChr( ::aLS[1],"3" )  ,;
             { .T., 9.4,"FACTURA" }           , { .F., 9.8,"F E C H A" }    ,;
             { .F.,11.7,"Nombre del Cliente" }, { .T.,18.0,"Total Factura" },;
             { .T.,20.5,"Saldo Factura" } }
//If ::aLS[6]
//   oRpt:aEnc[3] := STUFF( oRpt:aEnc[3],1,LEN( ::aVG[1] ),::aVG[1] )
//EndIf
 ::aLS[5] := ::aRS[1]
 ::aVG[1] := TRANSFORM( ::aRS[2],"999,999,999-" ) + STR(::aRS[3],1)
 ::aVG[3] := ::aRS[4]
 ::Init( ::aEnc[4], .f. ,, !::aLS[3] ,,, ::aLS[3], 5 )
 ::nMD := 20.5
 PAGE
While ::nL > 0
   oApl:nSaldo := ::aRS[9]
   Vence( ::aLS[1] - ::aRS[6],@aVence )
   If ::aLS[7] == "N"
      ::Cabecera( .t.,0.42 )
      If ::aGT[1,5] == 0
         UTILPRN ::oUtil Self:nLinea, 0.5 SAY LEFT(::aLS[5],34)
         UTILPRN ::oUtil Self:nLinea, 5.9 SAY ::aVG[1]
      EndIf
      UTILPRN ::oUtil Self:nLinea, 9.4 SAY   STR( ::aRS[5] )            RIGHT
      UTILPRN ::oUtil Self:nLinea, 9.6 SAY NtChr( ::aRS[6],"2" )
      UTILPRN ::oUtil Self:nLinea,11.7 SAY  LEFT( ::aRS[7],20 )
      UTILPRN ::oUtil Self:nLinea,18.0 SAY TRANSFORM(::aRS[8],::aVG[2]) RIGHT
      UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM(::aRS[9],::aVG[2]) RIGHT
   EndIf
   ::aGT[1,5] += ::aRS[9]
   If (::nL --) > 1
      ::aRS := MyReadRow( ::hRes )
      AEVAL( ::aRS, {| xV,nP | ::aRS[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aRS[1] # ::aLS[5]
      AEVAL( aVence, {|nVal,nP| ::aGT[2,nP] += nVal } )
      If ::aLS[7] == "N"
         ::Cabecera( .t.,0.84 )
         UTILPRN ::oUtil SELECT ::aFnt[6]
         UTILPRN ::oUtil Self:nLinea,15.0 SAY "TOTAL CLIENTE --> $"
         UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( ::aGT[1,5],::aVG[2] ) RIGHT
         UTILPRN ::oUtil SELECT ::aFnt[5]
      Else
         ::Cabecera( .t.,0.42 )
         UTILPRN ::oUtil Self:nLinea, 0.5 SAY LEFT(::aLS[5],34)
         UTILPRN ::oUtil Self:nLinea, 5.9 SAY ::aVG[1]
         UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( ::aGT[1,5],::aVG[2] ) RIGHT
         //   Vence( 0,aVence,50,oRpt )
      EndIF
      ::nLinea += 0.42
      If ::aVG[3]
         ::aGT[1,3] += ::aGT[1,5]
      ElseIf ::aLS[4] > 0
         ::aGT[1,2] += ::aGT[1,5]
      EndIf
      AFILL( aVence,0 )
      ::aGT[1,4] ++
      ::aGT[1,5] := 0
      ::aLS[5] := ::aRS[1]
      ::aLS[4] := ::aRS[2]
      ::aVG[1] := TRANSFORM( ::aRS[2],"999,999,999-" ) + STR(::aRS[3],1)
      ::aVG[3] := ::aRS[4]
   EndIf
EndDo
MSFreeResult( ::hRes )
If ::aGT[1,4] > 0
   FOR nL := 1 TO 7
      aVence[nL] := ::aGT[2,nL]
   NEXT nL
   ::Cabecera( .t.,0.1,4.20,20.5 )
   UTILPRN ::oUtil Self:nLinea, 0.6 SAY STR( ::aGT[1,4],3 ) + "  SALDOS"
   UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( ::aGT[2,7],::aVG[2] ) RIGHT
   ::nLinea += 0.84
   UTILPRN ::oUtil Self:nLinea, 2.0 SAY "TOTAL OPTICAS GRUPO -------> $"
   UTILPRN ::oUtil Self:nLinea, 9.3 SAY TRANSFORM( ::aGT[1,3],::aVG[2] ) RIGHT
   ::nLinea += 0.84
   UTILPRN ::oUtil Self:nLinea, 2.0 SAY "TOTAL EMPRESAS ------------> $"
   UTILPRN ::oUtil Self:nLinea, 9.3 SAY TRANSFORM( ::aGT[1,2],::aVG[2] ) RIGHT
   ::nLinea += 0.84
   UTILPRN ::oUtil Self:nLinea, 2.0 SAY "TOTAL CUENTAS POR COBRAR --> $"
   UTILPRN ::oUtil Self:nLinea, 9.3 SAY TRANSFORM( ::aGT[2,7],::aVG[2] ) RIGHT

   aRS := { "A 30 Dias","A 60 Dias","A 90 Dias","A 180 Dias","A 360 Dias","Sobre 360 Dias",;
            ::nLinea+0.84, 3.5 }
   ::nLinea += 1.26
   FOR nL := 1 TO 6
      UTILPRN ::oUtil aRS[7]     , aRS[8] SAY aRS[nL]                             RIGHT
      UTILPRN ::oUtil Self:nLinea, aRS[8] SAY TRANSFORM(aVence[nL],"999,999,999") RIGHT
      If aVence[7]  > 0
         aVence[nL] := ROUND( aVence[nL]/aVence[7]*100,2 )
         UTILPRN ::oUtil aRS[7]+0.84,aRS[8] SAY TRANSFORM(aVence[nL],"999.99%") RIGHT
      EndIf
      aRS[8] += 2.4
   NEXT nL
EndIf
   ENDPAGE
IMPRIME END .F.
RETURN NIL

//------------------------------------//
METHOD Excel_Car() CLASS TCartera
   LOCAL aVence, nF := 6, nL := 1, oRpt
aVence := cFilePath( GetModuleFileName( GetInstance() )) + "Test1.xls"
oRpt := TExcelScript():New()
oRpt:Create( aVence )
oRpt:Font("Arial")
oRpt:Size(10)
oRpt:Align(1)
oRpt:Visualizar(.F.)
oRpt:Say(  1, 2, oApl:cEmpresa )
oRpt:Say(  2, 2, "REPORTE DE CUENTAS POR COBRAR" )
oRpt:Say(  3, 2, NtChr(::aLS[1],"3") )
If ::aLS[7] == "S"
   If ::aLS[2] == 99
      nL := NIL
      oRpt:Say( 5, 4, "A  30 Dias" )
      oRpt:Say( 5, 5, "A  60 Dias" )
      oRpt:Say( 5, 6, "A  90 Dias" )
      oRpt:Say( 5, 7, "A 180 Dias" )
      oRpt:Say( 5, 8, "A 360 Dias" )
      oRpt:Say( 5, 9, "Sobre 360 Dias" )
   Else
      oRpt:Say( 4, 1,::aVG[1] )
      oRpt:Say( 5, 2, "A  90 Dias" )
      oRpt:Say( 5, 3, "A 180 Dias" )
      oRpt:Say( 5, 4, "A 360 Dias" )
      oRpt:Say( 5, 5, "Sobre 360 Dias" )
      oRpt:Say( 5, 6, "SALDO FACTURA" )
   EndIf
Else
   oRpt:Say(  5, 3, "FACTURA" )
   oRpt:Say(  5, 4, "FECHA" )
   oRpt:Say(  5, 5, "NOMBRE DEL CLIENTE" )
   oRpt:Say(  5, 6, "TOTAL FACTURA" )
   oRpt:Say(  5, 7, "SALDO FACTURA" )
EndIf
   aVence := { 0,0,0,0,0,0,0 }
 ::aLS[5] := ::aRS[1]
 ::aVG[1] := PADR(::aRS[1],36) + TRANSFORM( ::aRS[2],"999,999,999-" ) + STR(::aRS[3],1)
 ::aVG[2] := "#,###.##"
 ::aVG[3] := ::aRS[4]
While ::nL > 0
   oApl:nSaldo := ::aRS[9]
   Vence( ::aLS[1] - ::aRS[6],@aVence,,,nL )
   If ::aLS[7] == "N"
      If ::aGT[1,5] == 0
         oRpt:Say( nF, 1,::aVG[1] )
      EndIf
      oRpt:Say( nF, 3,::aRS[5] )
      oRpt:Say( nF, 4,NtChr( ::aRS[6],"2" ) )
      oRpt:Say( nF, 5,::aRS[7] )
      oRpt:Say( nF, 6,::aRS[8],,,,,,,,,,,::aVG[2] )
      oRpt:Say( nF, 7,::aRS[9],,,,,,,,,,,::aVG[2] )
      nF ++
   EndIf
   ::aGT[1,5] += ::aRS[9]
   If (::nL --) > 1
      ::aRS := MyReadRow( ::hRes )
      AEVAL( ::aRS, {| xV,nP | ::aRS[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aRS[1] # ::aLS[5]
      AEVAL( aVence, {|nVal,nP| ::aGT[2,nP] += nVal } )
      If ::aLS[7] == "N"
         oRpt:Say(++nF, 5,"TOTAL CLIENTE --> $" )
         oRpt:Say(  nF, 7,::aGT[1,5],,,,,,,,,,,::aVG[2] )
      ElseIf ::aLS[2] == 99
         oRpt:Say(  nF, 1,NtChr( SUBSTR(::aVG[1],37,12),"N" ) )
         oRpt:Say(  nF, 2,RIGHT(::aVG[1],1 ) )
         oRpt:Say(  nF, 3, LEFT(::aVG[1],36) )
         oRpt:Say(  nF, 4, aVence[1] )
         oRpt:Say(  nF, 5, aVence[2] )
         oRpt:Say(  nF, 6, aVence[3] )
         oRpt:Say(  nF, 7, aVence[4] )
         oRpt:Say(  nF, 8, aVence[5] )
         oRpt:Say(  nF, 9, aVence[6] )
         nF --
      Else
         oRpt:Say(  nF, 1,::aVG[1] )
         oRpt:Say(  nF, 2, aVence[1],,,,,,,,,,,::aVG[2] )
         oRpt:Say(  nF, 3, aVence[2],,,,,,,,,,,::aVG[2] )
         oRpt:Say(  nF, 4, aVence[3],,,,,,,,,,,::aVG[2] )
         oRpt:Say(  nF, 5, aVence[4],,,,,,,,,,,::aVG[2] )
         oRpt:Say(  nF, 6,::aGT[1,7],,,,,,,,,,,::aVG[2] )
         nF ++
      EndIf
      nF += 2
      If ::aVG[3]
         ::aGT[1,3] += ::aGT[1,5]
      ElseIf ::aLS[4] > 0
         ::aGT[1,2] += ::aGT[1,5]
      EndIf
      AFILL( aVence,0 )
      ::aGT[1,4] ++
      ::aGT[1,5] := 0
      ::aLS[5] := ::aRS[1]
      ::aLS[4] := ::aRS[2]
      ::aVG[1] := PADR(::aRS[1],36) + TRANSFORM( ::aRS[2],"999,999,999-" ) + STR(::aRS[3],1)
      ::aVG[3] := ::aRS[4]
   EndIf
EndDo
If ::aGT[1,4] > 0 .AND. ::aLS[2] # 99
   If ::aLS[7] == "N"
      oRpt:Say(++nF, 2, "A  90 Dias" )
      oRpt:Say(  nF, 3, "A 180 Dias" )
      oRpt:Say(  nF, 4, "A 360 Dias" )
      oRpt:Say(  nF, 5, "Sobre 360 Dias" )
   EndIf
   oRpt:Say(++nF, 1,STR( ::aGT[1,4],3 ) + "  SALDOS" )
   FOR nL := 1 TO 5
      oRpt:Say( nF  , nL+1,::aGT[2,nL],,,,,,,,,,,::aVG[2] )
      If nL <= 4
         oRpt:Say( nF+1, nL+1,ROUND( ::aGT[2,nL]/::aGT[2,7],2 ) )
         oRpt:CellFormat( nF+1, nL+1,,,"###.##%" )
      EndIf
   NEXT nL
   nF += 3
   oRpt:Say(  nF, 5,"TOTAL OPTICAS GRUPO -------> $" )
   oRpt:Say(  nF, 7,::aGT[1,3],,,,,,,,,,,::aVG[2] )
   oRpt:Say(++nF, 5,"TOTAL EMPRESAS ------------> $" )
   oRpt:Say(  nF, 7,::aGT[1,2],,,,,,,,,,,::aVG[2] )
   oRpt:Say(++nF, 5,"TOTAL CUENTAS POR COBRAR --> $" )
   oRpt:Say(  nF, 7,::aGT[2,7],,,,,,,,,,,::aVG[2] )
EndIf
   oRpt:Visualizar(.T.)
   oRpt:End(.F.) ; oRpt := NIL
RETURN NIL

//------------------------------------//
METHOD Listo_Var() CLASS TCartera
   LOCAL aHis, aVence := { 0,0,0,0,0,0,0 }, oRpt
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"REPORTE DE CUENTAS POR COBRAR",NtChr( ::aLS[1],"3" ),;
          " Doc. Identidad N O M B R E                       A 30 Dias    "+;
          "A 60 Dias    A 90 Dias   A 180 Dias   A 360 Dias Sobre 360 Dias"},::aLS[3],1,2 )
//3456789012345 123456789012345678901234567890  999,999,999  999,999,999  999,999,999  999,999,999  999,999,999
 ::aLS[4] := ::aRS[4]
 ::aLS[5] := ::aRS[1]
 ::aLS[7] := If( EMPTY( ::aRS[2] ), ::aRS[3], ::aRS[2] )
While ::nL > 0
   oApl:nSaldo := ::aRS[6]
   Vence( ::aLS[1] - ::aRS[5],@aVence )
   If (::nL --) > 1
      ::aRS := MyReadRow( ::hRes )
      AEVAL( ::aRS, {| xV,nP | ::aRS[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aRS[4] # ::aLS[4]
/*
      aHis := Buscar( "SELECT nroiden, CONCAT(apellidos, ' ', nombres) FROM historia "+;
                      "WHERE codigo_nit = " + LTRIM(STR(::aLS[4])),"CM",,8 )
      If LEN( aHis ) == 0
         aHis := { "",::aLS[5] }
      EndIf
      oRpt:Say( oRpt:nL, 00,aHis[1] )
      oRpt:Say( oRpt:nL, 16,aHis[2] )
*/
      oRpt:Titulo( 130 )
      oRpt:Say( oRpt:nL, 00,::aLS[5] )
      oRpt:Say( oRpt:nL, 16,::aLS[7] )
      oRpt:Say( oRpt:nL, 48,TRANSFORM(aVence[1],"999,999,999") )
      oRpt:Say( oRpt:nL, 61,TRANSFORM(aVence[2],"999,999,999") )
      oRpt:Say( oRpt:nL, 74,TRANSFORM(aVence[3],"999,999,999") )
      oRpt:Say( oRpt:nL, 87,TRANSFORM(aVence[4],"999,999,999") )
      oRpt:Say( oRpt:nL,100,TRANSFORM(aVence[5],"999,999,999") )
      oRpt:Say( oRpt:nL,113,TRANSFORM(aVence[6],"999,999,999") )
      oRpt:nL ++
      AFILL( aVence,0 )
      ::aLS[4] := ::aRS[4]
      ::aLS[5] := ::aRS[1]
      ::aLS[7] := If( EMPTY( ::aRS[2] ), ::aRS[3], ::aRS[2] )
   EndIf
EndDo
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD Laser_Var() CLASS TCartera
   LOCAL aHis, aVence := { 0,0,0,0,0,0,0 }, nL
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit      ,;
             "REPORTE DE CUENTAS POR COBRAR" , NtChr( ::aLS[1],"3" ) ,;
             { .F., 0.5,"Doc.Identidad" }, { .F., 3.0,"N O M B R E" },;
             { .T., 8.6,"A 30 Dias" }    , { .T.,11.0,"A 60 Dias" }  ,;
             { .T.,13.4,"A 90 Dias" }    , { .T.,15.8,"A 180 Dias" } ,;
             { .T.,18.2,"A 360 Dias" }   , { .T.,20.6,"Sobre 360 Dias" } }
 ::aLS[4] := ::aRS[4]
 ::aLS[5] := ::aRS[1]
 ::aLS[7] := If( EMPTY( ::aRS[2] ), ::aRS[3], ::aRS[2] )
 ::Init( ::aEnc[4], .f. ,, !::aLS[3] ,,, ::aLS[3], 5 )
 ::nMD := 20.6
 PAGE
While ::nL > 0
   oApl:nSaldo := ::aRS[6]
   Vence( ::aLS[1] - ::aRS[5],@aVence )
   If (::nL --) > 1
      ::aRS := MyReadRow( ::hRes )
      AEVAL( ::aRS, {| xV,nP | ::aRS[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aRS[4] # ::aLS[4]
      ::Cabecera( .t.,0.42 )
      UTILPRN ::oUtil Self:nLinea, 2.8 SAY ALLTRIM( ::aLS[5] )  RIGHT
      UTILPRN ::oUtil Self:nLinea, 3.0 SAY LEFT( ::aLS[7],22 )
      UTILPRN ::oUtil Self:nLinea,08.6 SAY TRANSFORM(aVence[1],"@Z 999,999,999") RIGHT
      UTILPRN ::oUtil Self:nLinea,11.0 SAY TRANSFORM(aVence[2],"@Z 999,999,999") RIGHT
      UTILPRN ::oUtil Self:nLinea,13.4 SAY TRANSFORM(aVence[3],"@Z 999,999,999") RIGHT
      UTILPRN ::oUtil Self:nLinea,15.8 SAY TRANSFORM(aVence[4],"@Z 999,999,999") RIGHT
      UTILPRN ::oUtil Self:nLinea,18.2 SAY TRANSFORM(aVence[5],"@Z 999,999,999") RIGHT
      UTILPRN ::oUtil Self:nLinea,20.6 SAY TRANSFORM(aVence[6],"@Z 999,999,999") RIGHT
      AEVAL( aVence, {|nVal,nP| ::aGT[1,nP] += nVal } )
      AFILL( aVence,0 )
      ::aGT[2,1] ++
      ::aLS[4] := ::aRS[4]
      ::aLS[5] := ::aRS[1]
      ::aLS[7] := If( EMPTY( ::aRS[2] ), ::aRS[3], ::aRS[2] )
   EndIf
EndDo
   ::Cabecera( .t.,0.42,1.26,20.6 )
   UTILPRN ::oUtil Self:nLinea, 1.6 SAY STR( ::aGT[2,1],3 ) + "  SALDOS"
   aHis := { 8.6 }
   FOR nL := 1 TO 6
      UTILPRN ::oUtil Self:nLinea, aHis[1] SAY TRANSFORM(::aGT[1,nL],"999,999,999") RIGHT
      aHis[1] += 2.4
   NEXT nL
   ::nLinea += 0.84
   UTILPRN ::oUtil Self:nLinea, 1.8 SAY "TOTAL CLIENTES VARIOS -----> $"
   UTILPRN ::oUtil Self:nLinea, 8.6 SAY TRANSFORM( ::aGT[1,7],"999,999,999" ) RIGHT
   ENDPAGE
IMPRIME END .F.
RETURN NIL

//------------------------------------//
METHOD Excel_Var() CLASS TCartera
   LOCAL aHis, aVence := { 0,0,0,0,0,0,0 }, nC, nF := 5, oRpt
aHis := cFilePath( GetModuleFileName( GetInstance() )) + "Test1.xls"
oRpt := TExcelScript():New()
oRpt:Create( aHis )
oRpt:Font("Arial")
oRpt:Size(10)
//oRpt:ColumnWidth( 2, 25.00 )
oRpt:Align(1)
oRpt:Visualizar(.F.)
oRpt:Say(  1, 2, oApl:cEmpresa )
oRpt:Say(  2, 2, "REPORTE DE CUENTAS POR COBRAR" )
oRpt:Say(  3, 2, NtChr(::aLS[1],"3") )
oRpt:Say(  5, 1,"Doc. Identidad" )
oRpt:Say(  5, 2,"N O M B R E" )
oRpt:Say(  5, 3, "A  30 Dias" )
oRpt:Say(  5, 4, "A  60 Dias" )
oRpt:Say(  5, 5, "A  90 Dias" )
oRpt:Say(  5, 6, "A 180 Dias" )
oRpt:Say(  5, 7, "A 360 Dias" )
oRpt:Say(  5, 8, "Sobre 360 Dias" )
 ::aLS[4] := ::aRS[4]
 ::aLS[5] := ::aRS[1]
 ::aLS[7] := If( EMPTY( ::aRS[2] ), ::aRS[3], ::aRS[2] )
 ::aVG[2] := "#,###.##"
While ::nL > 0
   oApl:nSaldo := ::aRS[6]
   Vence( ::aLS[1] - ::aRS[5],@aVence )
   If (::nL --) > 1
      ::aRS := MyReadRow( ::hRes )
      AEVAL( ::aRS, {| xV,nP | ::aRS[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aRS[4] # ::aLS[4]
      oRpt:Say(++nF, 1, ::aLS[5] )
      oRpt:Say(  nF, 2, ::aLS[7] )
      FOR nC := 1 TO 6
         oRpt:Say( nF, nC+2, aVence[nC] )
      NEXT nC
      AFILL( aVence,0 )
      ::aLS[4] := ::aRS[4]
      ::aLS[5] := ::aRS[1]
      ::aLS[7] := If( EMPTY( ::aRS[2] ), ::aRS[3], ::aRS[2] )
   EndIf
EndDo
   oRpt:Visualizar(.T.)
   oRpt:End(.F.) ; oRpt := NIL
RETURN NIL

//------------------------------------//
METHOD SuperSalud() CLASS TCartera
   LOCAL aVence := { 0,0,0,0,0,0,0 }, cQry, hRes, nEnMora
 cQry := ALLTRIM(oApl:oEmp:NIT)
::aVG := { NtChr( SUBSTR( cQry,1,LEN(cQry)-1 ),"N" ) + "," +;
           RIGHT( cQry,1 )                           + "," +;
           If( MONTH( ::aLS[1] ) <= 6, "41", "43" )  + "," +;
           STR( YEAR( ::aLS[1] ),4 )             + ",059," ,;
           ::aRS[1], ::aRS[2], ::aRS[3], }
 cQry := STRTRAN( ::aVG[1],",", "" ) + ".TXT"
FERASE( cQry )
hRes := FCREATE( cQry,0 )
While ::nL > 0
 //oApl:nSaldo := ::aRS[5]
 //Vence( ::aLS[1] - ::aRS[4],@aVence )
   aVence[7] += ::aRS[5]
   If (::nL --) > 1
      ::aRS := MyReadRow( ::hRes )
      AEVAL( ::aRS, {| xV,nP | ::aRS[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aRS[1] # ::aVG[2]
      AEVAL( aVence, {| xV,nP | xV := ROUND( xV / 1000,0 ),;
                                aVence[nP] := If( ABS(xV) > 0,xV, 0 ) },7 )
      If ABS( aVence[7] ) > 0
         If ::aVG[3] == -1
            ::aVG[2] := NtChr(::aVG[2],"N")
            ::aVG[3] := DigitoVerifica( INT(VAL(::aVG[2])) )
            ::aVG[5] := "130525,0,0,0,0,0"
         Else
            ::aVG[5] := "130530,0,0,0,0,0"
         EndIf
       //aVence[7] := aVence[1] + aVence[2] + aVence[3]
         nEnMora   := 0  //aVence[4] + aVence[5] + aVence[6]
         cQry :=           ::aVG[1]              +;
                   ALLTRIM(::aVG[2])       + "," +;
                 LTRIM(STR(::aVG[3],15,0)) + "," +;
                   ALLTRIM(::aVG[4])       + "," +;
                           ::aVG[5]        + "," +;
                 LTRIM(STR(aVence[7],15,0))+ "," +;
                 LTRIM(STR(nEnMora  ,15,0))+ "," +;
                 LTRIM(STR(aVence[1],15,0))+ "," +;
                 LTRIM(STR(aVence[2],15,0))+ "," +;
                 LTRIM(STR(aVence[3],15,0))+ "," +;
                 LTRIM(STR(aVence[4],15,0))+ "," +;
                 LTRIM(STR(aVence[5],15,0))+ "," +;
                 LTRIM(STR(aVence[6],15,0))+ ",0,0"
         FWRITE( hRes, cQry + CRLF )
      EndIf
      AFILL( aVence,0 )
      ::aVG[2] := ::aRS[1]
      ::aVG[3] := ::aRS[2]
      ::aVG[4] := ::aRS[3]
   EndIf
EndDo
FCLOSE( hRes )
 cQry := "\" + CURDIR() + "\" + STRTRAN( ::aVG[1],",", "" ) + ".TXT"
MsgInfo( cQry,"SE GENERO EL ARCHIVO" )
RETURN NIL

//------------------------------------//
METHOD ListoCan() CLASS TCartera
   LOCAL cQry, nK, oRpt 
   LOCAL aGT := { 0,0,0,0,0,0,0,0,0,0,NtChr( LEFT( DTOS( ::aLS[1] ),6 ),"F" ),;
                  " = " + LTRIM(STR(oApl:nEmpresa)) }
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"REPORTE DE FACTURAS CANCELADAS" ,;
         "EN " + NtChr( ::aLS[1],"6" ),SPACE(10) + "--FACTURA-   FECHA " +;
         "CANCELACION      VALOR FACTURA   LENTE CONTACTO"},::aLS[3],::aLS[2],1 )
If ::aLS[6]
   ::aLS[7] := "S"
   ::aRS    := Privileg( {"principal",oApl:oEmp:PRINCIPAL,"optica <> ",1},.t.,.f. )
    aGT[12] := ::aRS[1]
   oRpt:aEnc[3] := STUFF( oRpt:aEnc[3],1,LEN( ::aRS[2] ),::aRS[2] )
EndIf
cQry := "SELECT f.numfac, f.fechacan, f.totalfac, n.grupo"+;
             ", n.codigo, n.nombre, f.optica, f.autoriza "+;
        "FROM cadclien n, cadfactu f "                   +;
        "WHERE f.codigo_nit = n.codigo_nit"              +;
         " AND f.optica "      + aGT[12]                 +;
         " AND f.fechacan >= " + xValToChar( aGT[11] )   +;
         " AND f.fechacan <= " + xValToChar( ::aLS[1] )  +;
         " AND f.tipo      = " + xValToChar( oApl:Tipo ) +;
         " AND f.indicador = 'C'"      + If( ::aLS[4] > 0,;
         " AND f.codigo_nit = "+ LTRIM(STR(oApl:oNit:CODIGO_NIT)), "" )+;
         " ORDER BY n.nombre, f.numfac"
::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) > 0
   ::aRS := MyReadRow( ::hRes )
   AEVAL( ::aRS, { | xV,nP | ::aRS[nP] := MyClReadCol( ::hRes,nP ) } )
   aGT[1] := ::nL
   ::aLS[5]:= ::aRS[6]
EndIf
While ::nL > 0
   cQry := "SELECT SUM(precioven + montoiva) FROM cadventa "+;
           "WHERE optica = " + LTRIM( STR(::aRS[7]) )  +;
            " AND numfac = " + LTRIM( STR(::aRS[1]) )  +;
            " AND tipo   = " + xValToChar( oApl:Tipo ) +;
            " AND indicador NOT IN('A','D')"           +;
            " AND LEFT(codart,2) >= '60'"
   aGT[4] := Buscar( cQry,"CM",,8 )
      oRpt:Titulo( 76 )
   If oRpt:nPage >= oRpt:nPagI .AND. ::aLS[7] == "N"
      If aGT[9] == 0
         oRpt:Say( oRpt:nL++,01,::aLS[5] )
      EndIf
      oRpt:Say( oRpt:nL,10,STR(::aRS[1]) )
      oRpt:Say( oRpt:nL,27,NtChr( ::aRS[2],"2" ) )
      oRpt:Say( oRpt:nL,45,TRANSFORM(::aRS[3],   "999,999,999.99") )
      oRpt:Say( oRpt:nL,62,TRANSFORM(aGT[4],"@Z 999,999,999.99") )
      oRpt:nL++
   EndIf
   nK := If( ::aRS[4] .OR. ::aRS[8] == "GRUPO     ", 5, If( ::aRS[5] > 0, 8, 7 ) )
   aGT[02] += ::aRS[3]
   aGT[03] += aGT[4]
   aGT[06] += If( ::aRS[4], aGT[4], 0 )
   aGT[09] += ::aRS[3]
   aGT[nK] += ::aRS[3]
   If ::aRS[8] == "FOCA      "
      aGT[10] += ::aRS[3]
   EndIf
   If (::nL --) > 1
      ::aRS := MyReadRow( ::hRes )
      AEVAL( ::aRS, {| xV,nP | ::aRS[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aRS[6] # ::aLS[5]
      If oRpt:nPage >= oRpt:nPagI
         If ::aLS[7] == "N"
            oRpt:Say(++oRpt:nL,27,"TOTAL CLIENTE --> $"+oRpt:CPIBold,,,1 )
            oRpt:Say(  oRpt:nL,45,TRANSFORM( aGT[9],"999,999,999.99" )+oRpt:CPIBoldN )
         Else
            oRpt:Say(  oRpt:nL,01,::aLS[5],,,1 )
            oRpt:Say(  oRpt:nL,45,TRANSFORM( aGT[9],"999,999,999.99" ) )
            oRpt:nL ++
         EndIf
      EndIf
      oRpt:nL += 2
      ::aLS[5] := ::aRS[6]
      aGT[9]:= 0
   EndIf
EndDo
MSFreeResult( ::hRes )
  ::aVG := { "TOTAL OPTICAS DEL GRUPO ---> $","TOTAL CLIENTES VARIOS -----> $",;
             "TOTAL EMPRESAS ------------> $","PAGOS POR NOTA CREDITO ----> $",;
             "TOTAL PUNTO EN FOCA -------> $","9,999,999,999.99" }
If aGT[1] > 0
   cQry := "SELECT SUM(pagado) FROM cadfactu u, cadpagos p "+;
           "WHERE u.indicador <> 'N'"                   +;
            " AND p.optica = u.optica"                  +;
            " AND p.numfac = u.numfac"                  +;
            " AND p.tipo   = u.tipo"                    +;
            " AND p.optica  "   + aGT[12]               +;
            " AND p.fecpag >= " + xValToChar( aGT[11] ) +;
            " AND p.fecpag <= " + xValToChar( ::aLS[1] )+;
            " AND p.formapago IN(7,9)"
   aGT[9] := Buscar( cQry,"CM",,8 )
   oRpt:Say(  oRpt:nL,01,Replicate("_",75),,,1 )
   oRpt:Separator( 0,19 )
   oRpt:Say(++oRpt:nL,02,STR(aGT[1])+" TOTAL FACTURAS CANCELADAS :" )
   oRpt:Say(  oRpt:nL,43,TRANSFORM(aGT[2],::aVG[6]) )
   oRpt:Say(  oRpt:nL,60,TRANSFORM(aGT[3],::aVG[6]) )
   oRpt:Say(++oRpt:nL,13,::aVG[1] + TRANSFORM( aGT[5],::aVG[6] ) )
   oRpt:Say(  oRpt:nL,60,TRANSFORM( aGT[6],::aVG[6] ) )
   If aGT[09] > 0
      aGT[02] -= aGT[09]
      oRpt:Say(++oRpt:nL,13,::aVG[4] + TRANSFORM( aGT[09],::aVG[6] ) )
   EndIf
   If aGT[10] > 0
      aGT[02] -= aGT[10]
      oRpt:Say(++oRpt:nL,13,::aVG[5] + TRANSFORM( aGT[10],::aVG[6] ) )
   EndIf
   oRpt:Say(++oRpt:nL,45,"==============  ===============" )
   oRpt:Say(++oRpt:nL,43,TRANSFORM(aGT[2]-aGT[5],::aVG[6]) )
   oRpt:Say(  oRpt:nL,60,TRANSFORM(aGT[3]-aGT[6],::aVG[6]) )
   oRpt:Say(  oRpt:nL+2,13,::aVG[2] + TRANSFORM( aGT[7],::aVG[6] ) )
   oRpt:Say(  oRpt:nL+3,13,::aVG[3] + TRANSFORM( aGT[8],::aVG[6] ) )
   oRpt:nL += 6
EndIf

cQry := "SELECT n.grupo, n.codigo, f.totalfac, f.totaliva, f.autoriza "+;
        "FROM cadclien n, cadfactu f "                  +;
        "WHERE f.codigo_nit = n.codigo_nit"             +;
         " AND f.optica "      + aGT[12]                +;
         " AND f.fechoy   >= " + xValToChar( aGT[11] )  +;
         " AND f.fechoy   <= " + xValToChar( ::aLS[1] ) +;
         " AND f.tipo      = " + xValToChar( oApl:Tipo )+;
         " AND f.indicador <> 'A'" 
::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
::nL   := MSNumRows( ::hRes )
  cQry := DsctoDevol( {aGT[12],aGT[11],::aLS[1]} )
AFILL( aGT,0 )
While ::nL > 0
   ::aRS := MyReadRow( ::hRes )
   AEVAL( ::aRS, { | xV,nP | ::aRS[nP] := MyClReadCol( ::hRes,nP ) } )
   ::aRS[3] -= ::aRS[4] 
   nK := If( ::aRS[1],     1,;
         If( ::aRS[5] == "GRUPO     ", 4,;
         If( ::aRS[2] > 0, 3, 2 ) ) )
   If ::aRS[5] == "FOCA      "
      nK := 5
   EndIf
      aGT[nK]   += ::aRS[3]
      aGT[nK+5] += ::aRS[4] 
   ::nL --
EndDo
MSFreeResult( ::hRes )
 aGT[1] -= cQry[2]
 aGT[2] -= cQry[1]
 aGT[3] -= cQry[3]
 aGT[5] -= cQry[4]
 aGT[11] := aGT[2] + aGT[3] + aGT[4]
 oRpt:Say(  oRpt:nL,27,"R E S U M E N  D E  V E N T A S  S I N   I.V.A." )
 oRpt:Say(++oRpt:nL,27,"DSCTO. POR N.C." )
 oRpt:Say(++oRpt:nL,00,SUBSTR(::aVG[1],7) )
 oRpt:Say(  oRpt:nL,26,TRANSFORM(cQry[2],::aVG[6] ) )
 oRpt:Say(  oRpt:nL,43,TRANSFORM( aGT[1],::aVG[6] ) )
 oRpt:Say(  oRpt:nL,60,TRANSFORM( aGT[6],::aVG[6]) )
 oRpt:Say(++oRpt:nL,00,"EMPRESAS GRUPO.P ----> $" )
 oRpt:Say(  oRpt:nL,43,TRANSFORM(aGT[4],::aVG[6]) )
 oRpt:Say(  oRpt:nL,60,TRANSFORM(aGT[9],::aVG[6]) )
 oRpt:Say(++oRpt:nL,00,SUBSTR(::aVG[2],7) )
 oRpt:Say(  oRpt:nL,26,TRANSFORM(cQry[1],::aVG[6] ) )
 oRpt:Say(  oRpt:nL,43,TRANSFORM( aGT[2],::aVG[6] ) )
 oRpt:Say(  oRpt:nL,60,TRANSFORM( aGT[7],::aVG[6]) )
 oRpt:Say(++oRpt:nL,00,SUBSTR(::aVG[3],7) )
 oRpt:Say(  oRpt:nL,26,TRANSFORM(cQry[3],::aVG[6] ) )
 oRpt:Say(  oRpt:nL,43,TRANSFORM( aGT[3],::aVG[6] ) )
 oRpt:Say(  oRpt:nL,60,TRANSFORM( aGT[8],::aVG[6]) )
 If aGT[5] # 0
    oRpt:Say(++oRpt:nL,00,SUBSTR(::aVG[5],7) )
    oRpt:Say(  oRpt:nL,26,TRANSFORM(cQry[4],::aVG[6] ) )
    oRpt:Say(  oRpt:nL,43,TRANSFORM( aGT[5],::aVG[6] ) )
    oRpt:Say(  oRpt:nL,60,TRANSFORM(aGT[10],::aVG[6]) )
 EndIf
 oRpt:Say(++oRpt:nL,45,"==============" )
 oRpt:Say(++oRpt:nL,13,"TOTAL VENTAS NETAS :" )
 oRpt:Say(  oRpt:nL,43,TRANSFORM(aGT[11],::aVG[6]) )
 oRpt:NewPage()
 oRpt:End()
RETURN NIL

//------------------------------------//
PROCEDURE Vence( nDias,aVence,nC,oRpt,nRes )
If nC == NIL
   If nRes == NIL
      do Case
      Case nDias <= 30
         aVence[1] += oApl:nSaldo
      Case nDias >=  31 .AND. nDias <= 60
         aVence[2] += oApl:nSaldo
      Case nDias >=  61 .AND. nDias <= 90
         aVence[3] += oApl:nSaldo
      Case nDias >=  91 .AND. nDias <= 180
         aVence[4] += oApl:nSaldo
      Case nDias >= 181 .AND. nDias <= 360
         aVence[5] += oApl:nSaldo
      OtherWise
         aVence[6] += oApl:nSaldo
      EndCase
         aVence[7] += oApl:nSaldo
   Else
      do Case
      Case nDias <=  90
         aVence[1] += oApl:nSaldo
      Case nDias >=  91 .AND. nDias <= 180
         aVence[2] += oApl:nSaldo
      Case nDias >= 181 .AND. nDias <= 360
         aVence[3] += oApl:nSaldo
      OtherWise
         aVence[4] += oApl:nSaldo
      EndCase
         aVence[7] += oApl:nSaldo
   EndIf
Else
// oRpt:Say( oRpt:nL,nC,"  A 30 Dias     A 60 Dias     A 90 Dias    A 180 Dias  Sobre 180 Dias",,,1 )
   oRpt:Say( oRpt:nL,nC,"  A 30 Dias     A 60 Dias     A 90 Dias    A 180 Dias    A 360 Dias Sobre 360 Dias",,,1 )
//                      999,999,999...999,999,999...999,999,999...999,999,999...999,999,999...999,999,999
//                   123456789012341234567890123412345678901234123456789012341234567890123412345678901234
   oRpt:nL ++
   oRpt:Say( oRpt:nL,nC   ,TRANSFORM(aVence[1],"999,999,999"),,,1 )
   oRpt:Say( oRpt:nL,nC+14,TRANSFORM(aVence[2],"999,999,999") )
   oRpt:Say( oRpt:nL,nC+28,TRANSFORM(aVence[3],"999,999,999") )
   oRpt:Say( oRpt:nL,nC+42,TRANSFORM(aVence[4],"999,999,999") )
   oRpt:Say( oRpt:nL,nC+56,TRANSFORM(aVence[5],"999,999,999") )
   oRpt:Say( oRpt:nL,nC+70,TRANSFORM(aVence[6],"999,999,999") )
   If aVence[7] > 0
      oRpt:nL ++
      oRpt:Say( oRpt:nL,nC+04,TRANSFORM( ROUND( aVence[1]/aVence[7]*100,2 ),"999.99%" ),,,1)
      oRpt:Say( oRpt:nL,nC+18,TRANSFORM( ROUND( aVence[2]/aVence[7]*100,2 ),"999.99%" ))
      oRpt:Say( oRpt:nL,nC+32,TRANSFORM( ROUND( aVence[3]/aVence[7]*100,2 ),"999.99%" ))
      oRpt:Say( oRpt:nL,nC+46,TRANSFORM( ROUND( aVence[4]/aVence[7]*100,2 ),"999.99%" ))
      oRpt:Say( oRpt:nL,nC+60,TRANSFORM( ROUND( aVence[5]/aVence[7]*100,2 ),"999.99%" ))
      oRpt:Say( oRpt:nL,nC+74,TRANSFORM( ROUND( aVence[6]/aVence[7]*100,2 ),"999.99%" ))
   EndIf
   oRpt:nL += 2
EndIf
RETURN

//------------------------------------//
FUNCTION DsctoDevol( aNC )
   LOCAL aRes, hRes, nC, nL
aRes := "SELECT n.grupo, n.codigo, c.totalfac, c.totaliva, c.tipo "+;
        "FROM cadclien n, cadnotac c "             +;
        "WHERE c.codigo_nit = n.codigo_nit"        +;
         " AND c.optica "   +             aNC[1]   +;
         " AND c.fecha >= " + xValToChar( aNC[2] ) +;
         " AND c.fecha <= " + xValToChar( aNC[3] ) +;
         " AND c.clase <= 2"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
aNC  := { 0,0,0,0 }
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   nC := If( aRes[1],     2,;
         If( aRes[5] == "F", 4,;
         If( aRes[2] > 0, 3, 1 ) ) )
   aNC[nC] += (aRes[3] - aRes[4]) 
   nL --
EndDo
MSFreeResult( hRes )
RETURN aNC