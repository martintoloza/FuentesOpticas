// Programa.: CAOLIDEV.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listado de Articulos Devueltos
#include "FiveWin.ch"
#include "Btnget.ch"

MEMVAR oApl

PROCEDURE CaoLiDev()
   LOCAL oDlg, oGet := ARRAY(4), aVta := { NtChr( oApl:oEmp:FEC_HOY,"1" ),0,.f. }
DEFINE DIALOG oDlg TITLE "Listo Articulos Devueltos" FROM 0, 0 TO 08,46
   @ 02, 00 SAY "DIGITE EL PERIODO" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02, 92 GET oGet[1] VAR aVta[1] OF oDlg PICTURE "999999";
      VALID NtChr( aVta[1],"P" ) SIZE 38,12 PIXEL
   @ 16, 92 CHECKBOX oGet[2] VAR aVta[3] PROMPT "Vista &Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 32, 50 BUTTON oGet[3] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[3]:Disable(), ListoDev( aVta ), oDlg:End() ) PIXEL
   @ 32,100 BUTTON oGet[4] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 38, 02 SAY "[CAOLIDEV]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED

RETURN

//------------------------------------//
STATIC PROCEDURE ListoDev( aLS )
   LOCAL aGT, aRes, cQry, hRes, nK, nL := 0
   LOCAL oRpt := TDosPrint()
aLS[1] := NtChr( aLS[1],"F" )
aLS[2] := CTOD( NtChr( aLS[1],"4" ) )
oRpt:New( oApl:cPuerto,oApl:cImpres,{"LISTADO DE ARTICULOS DEVUELTOS",;
         "EN " + NtChr(aLS[2],"3" ),"--FACTURA- FEC.FACTUR FEC.DEVOL  --CODIGO--"+;
         " D E S C R I P C I O N----------------      CANT  PR.VENDIDO  ---COSTO--"},;
         aLS[3],1,2 )
aGT := { { 0,0 },0,{ 0,0 },{ 0,0 },{ 0,0 },{ 0,0 },0,0,0 }
If aLS[1] <= CTOD("09.04.2007")
   cQry := "SELECT numfac, fecfac, fecdev, codart, descri, cantidad, "+;
           "precioven + montoiva, pcosto, indicador  FROM cadventa "  +;
           "WHERE optica  = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND fecdev >= " + xValToChar( aLS[1] )     +;
            " AND fecdev <= " + xValToChar( aLS[2] )     +;
            " AND tipo    = " + xValToChar( oApl:Tipo )  +;
            " AND LEFT(codart,2) NOT IN('02','05')"      +;
            " AND indicador IN ('A','D') ORDER BY fecdev, numfac"
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
EndIf
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   nK     := VAL( Grupos( aRes[4] ) )
   aGT[9] := aRes[6] * aRes[8]
   oRpt:Titulo( 119 )
   oRpt:Say( oRpt:nL, 00,STR(aRes[1]) )
   oRpt:Say( oRpt:nL, 11,aRes[2] )
   oRpt:Say( oRpt:nL, 22,aRes[3] )
   oRpt:Say( oRpt:nL, 33,aRes[4] )
   oRpt:Say( oRpt:nL, 45,aRes[5] )
   oRpt:Say( oRpt:nL, 86,TRANSFORM(aRes[6],"9,999") )
   oRpt:Say( oRpt:nL, 94,TRANSFORM(aRes[7],"9,999,999") )
   oRpt:Say( oRpt:nL,106,TRANSFORM( aGT[9],"9,999,999") )
   oRpt:Say( oRpt:nL,118,aRes[9] )
   oRpt:nL++
   aGT[2] ++
   aGT[7] += aRes[7]
   aGT[8] +=  aGT[9]
   aGT[nK,1] += If( aRes[2] >= aLS[1] .AND. aRes[2] <= aLS[2], 0, aRes[6] )
   aGT[nK,2] += aGT[9]
   nL --
EndDo
MSFreeResult( hRes )
cQry := "SELECT c.numfac, f.fechoy, c.fecha, d.codigo, c.numero, "+;
        "d.cantidad, d.precioven + d.montoiva, d.pcosto, c.clase "+;
        "FROM cadnotad d, cadnotac c, cadfactu f "     +;
        "WHERE LEFT(d.codigo,2) NOT IN('02','05')"     +;
         " AND c.optica = d.optica"                    +;
         " AND c.numero = d.numero"                    +;
         " AND c.tipo   = d.tipo"                      +;
         " AND c.optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fecha >= " + xValToChar( aLS[1] )     +;
         " AND c.fecha <= " + xValToChar( aLS[2] )     +;
         " AND f.optica = c.optica"                    +;
         " AND f.numfac = c.numfac"                    +;
         " ORDER BY c.numero"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   nK     := VAL( Grupos( aRes[4] ) )
   aGT[9] := aRes[6] * aRes[8]
   oRpt:Titulo( 119 )
   oRpt:Say( oRpt:nL, 00,STR(aRes[1]) )
   oRpt:Say( oRpt:nL, 11,aRes[2] )
   oRpt:Say( oRpt:nL, 22,aRes[3] )
   oRpt:Say( oRpt:nL, 33,aRes[4] )
   oRpt:Say( oRpt:nL, 45,"N.C."+STR(aRes[5]) )
   oRpt:Say( oRpt:nL, 86,TRANSFORM(aRes[6],"9,999") )
   oRpt:Say( oRpt:nL, 94,TRANSFORM(aRes[7],"9,999,999") )
   oRpt:Say( oRpt:nL,106,TRANSFORM( aGT[9],"9,999,999") )
   oRpt:Say( oRpt:nL,118,If( aRes[9] == 1, "A", "D" ) )
   oRpt:nL++
   aGT[2] ++
   aGT[7] += aRes[7]
   aGT[8] +=  aGT[9]
   aGT[nK,1] += aRes[6]
   aGT[nK,2] +=  aGT[9]
   nL --
EndDo
MSFreeResult( hRes )
If aGT[2] > 0
   oRpt:Say(  oRpt:nL, 00,REPLICATE("_",119),,,1 )
   oRpt:Say(++oRpt:nL, 18,STR( aGT[2],3 ) + " DEVOLUCIONES",,,1 )
   oRpt:Say(  oRpt:nL, 93,TRANSFORM(aGT[7],"99,999,999") )
   oRpt:Say(  oRpt:nL,105,TRANSFORM(aGT[8],"99,999,999") )
   oRpt:Say(++oRpt:nL, 00,REPLICATE("_",119),,,1 )
   oRpt:Say(++oRpt:nL, 10,"Cantidad Monturas  " + NtChr( aGT[1,1],"9,999" ),,,1)
   oRpt:Say(  oRpt:nL, 36,TRANSFORM(aGT[1,2],"99,999,999") )
   oRpt:Say(++oRpt:nL, 10,"Cantidad Liquidos  " + NtChr( aGT[3,1],"9,999" ),,,1)
   oRpt:Say(  oRpt:nL, 36,TRANSFORM(aGT[3,2],"99,999,999") )
   oRpt:Say(++oRpt:nL, 10,"Cantidad Accesorio " + NtChr( aGT[4,1],"9,999" ),,,1)
   oRpt:Say(  oRpt:nL, 36,TRANSFORM(aGT[4,2],"99,999,999") )
   oRpt:Say(++oRpt:nL, 10,"Cantidad L.Contacto" + NtChr( aGT[6,1],"9,999" ),,,1)
   oRpt:Say(  oRpt:nL, 36,TRANSFORM(aGT[6,2],"99,999,999") )
EndIf
   oRpt:NewPage()
   oRpt:End()
RETURN

//-----Total de venta por Cliente-----//
PROCEDURE CaoLiVet()
   LOCAL oDlg, oGet := ARRAY(10), aVta := { 0,DATE(),DATE(),1,"S",0,.f.,"" }
   LOCAL oNi := TNits()
oNi:New()
DEFINE DIALOG oDlg TITLE "Listo Total de venta por Cliente" FROM 0, 0 TO 17,54
   @ 02, 00 SAY    "Nit por Default Todos" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 02,102 BTNGET oGet[1] VAR aVta[1] OF oDlg PICTURE "999999999999";
      VALID EVAL( {|| If( EMPTY( aVta[1] ), .t.                    ,;
                ( If( oNi:Buscar( aVta[1],"codigo",.t. )           ,;
                    ( oGet[2]:Settext( oNi:oDb:NOMBRE ), .t. )     ,;
                    ( MsgStop("Este Nit no Existe"), .f. ) ) )) } ) ;
      SIZE 56,12 PIXEL  RESOURCE "BUSCAR"                           ;
      ACTION EVAL({|| If(oNi:Mostrar(), (aVta[1] := oNi:oDb:CODIGO ,;
                        oGet[1]:Refresh() ), ) })
   @ 16, 30 SAY oGet[2] VAR aVta[8] OF oDlg PIXEL SIZE 120,12
   @ 30, 00 SAY "Fecha Inicial [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 30,102 GET oGet[3] VAR aVta[2] OF oDlg SIZE 40,12 PIXEL
   @ 44, 00 SAY "Fecha   Final [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 44,102 GET oGet[4] VAR aVta[3] OF oDlg ;
      VALID aVta[3] >= aVta[2] SIZE 40,12 PIXEL
   @ 58, 00 SAY "Recupera desde la Página" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 58,102 GET oGet[5] VAR aVta[4] OF oDlg PICTURE "999" SIZE 12,12 PIXEL;
      VALID Rango( aVta[4],1,999 )
   @ 72, 00 SAY            "RESUMEN [S/N]" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 72,102 GET oGet[6] VAR aVta[5] OF oDlg PICTURE "!"   SIZE 08,12 PIXEL;
      VALID aVta[5] $ "SN"
   @ 86, 00 SAY "Base para total Ventas"   OF oDlg RIGHT PIXEL SIZE 100,10
   @ 86,102 GET oGet[7] VAR aVta[6] OF oDlg PICTURE "99,999,999" SIZE 48,12 PIXEL
   @ 86,158 CHECKBOX oGet[8] VAR aVta[7] PROMPT "Vista &Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 104, 50 BUTTON oGet[09] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[9]:Disable(), ListoVet( aVta ), oGet[9]:Enable(),;
        oGet[9]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 104,100 BUTTON oGet[10] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 110, 02 SAY "[CAOLIDEV]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
STATIC PROCEDURE ListoVet( aLS )
   LOCAL oRpt, cPict := "99,999,999,999.99"
   LOCAL aGT := { 0,0,0,0,0,0,.t.,.t.,aLS[1],.f.,"",.f. }
   LOCAL aRes, cQry, hRes, nK, nL
If aLS[4] == 2
   aLS[4] := 1
   aGT[12]:= .t.
   aRes := Privileg( {"principal",oApl:oEmp:PRINCIPAL,"optica <> ",1},.T.,(oApl:oEmp:PRINCIPAL == 4) )
Else
   aRes := { " = " + LTRIM(STR(oApl:nEmpresa)),"" }
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"REPORTE DE TOTAL DE VENTAS",;
         "DESDE " + NtChr( aLS[2],"2" ) + " HASTA " + NtChr( aLS[3],"2" )  ,;
         SPACE(50)+ "--FACTURA-   ---FECHA---   -NOMBRE DEL CLIENTE-     " +;
         "TOTAL  FACTURA     SALDO  FACTURA" },aLS[7],aLS[4],2 )
If aLS[6] > 0
   AGrupar( aLS,oRpt )
   RETURN
ElseIf aGT[12]
   aLS[5] := "N"
   oRpt:aEnc[3] := STRTRAN( oRpt:aEnc[3],"FACTURA     SALDO  FACTURA"," VENTAS     TOTAL  I.V.A." )
EndIf
aGT[8]:= MONTH( aLS[2] ) < MONTH( aLS[3] )
oApl:cPer := NtChr( aLS[3],"1" )
cQry := "SELECT n.nombre, n.codigo, n.digito, n.grupo, f.numfac, f.fechoy"+;
           ", f.cliente, f.totalfac, f.fechaent, f.indicador, f.totaliva "+;
        "FROM cadclien n, cadfactu f "                 +;
        "WHERE f.codigo_nit = n.codigo_nit"            +;
         " AND f.optica "    + aRes[1]                 +;
         " AND f.fechoy >= " + xValToChar( aLS[2] )    +;
         " AND f.fechoy <= " + xValToChar( aLS[3] )    + If( aGT[12],;
         " AND f.indicador <> 'A'", "" )               +;
         " AND f.tipo    = " + xValToChar( oApl:Tipo ) + If( aLS[1] > 0 ,;
         " AND f.codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT)), "" ) +;
        " ORDER BY n.nombre, f.fechoy, f.numfac"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aLS[7]  := aRes[4]
   aLS[8]  := aRes[1]
   aGT[11] := TRANSFORM(aRes[2],"999,999,999-") + STR(aRes[3],1)
EndIf
While nL > 0
   aGT[10] := If( aRes[10] == "A", .t., .f. )
   oRpt:Titulo( 135 )
   If oRpt:nPage >= oRpt:nPagI .AND. aLS[5] == "N"
      If aGT[12]
         aRes[8]     -= aRes[11]
         oApl:nSaldo := aRes[11]
      Else
         oApl:nSaldo := SaldoFac( aRes[5],1 )
      EndIf
      If aGT[2] == 0
         oRpt:Say( oRpt:nL,01,PADR(aLS[8],36) + aGT[11] )
      EndIf
      oRpt:Say( oRpt:nL, 50,STR(aRes[5]) )
      oRpt:Say( oRpt:nL, 63,NtChr( aRes[6],"2" ) + ;
                    If( aGT[10], " *", "" ) )
      oRpt:Say( oRpt:nL, 77,aRes[7],20 )
      oRpt:Say( oRpt:nL, 99,TRANSFORM(aRes[8]    ,cPict) )
      oRpt:Say( oRpt:nL,118,TRANSFORM(oApl:nSaldo,cPict) )
   EndIf
   If (aGT[7] := MONTH( aRes[6] ) # MONTH( aRes[9] )) .AND. ;
       aGT[8] .AND. aGT[10]
       aGT[6] += aRes[8]
   EndIf
   aGT[2] += If( aGT[10] .AND. !aGT[7], 0, aRes[8] )
   oRpt:nL+= { 1,0 }[AT(aLS[5],"NS")]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aRes[1] # aLS[8]
      If aGT[2] # 0
         If oRpt:nPage >= oRpt:nPagI
            If aLS[5] == "N"
               oRpt:Say(++oRpt:nL,77,"TOTAL CLIENTE ---> $"+oRpt:CPIBold,,,1 )
               oRpt:Say(  oRpt:nL,99,TRANSFORM( aGT[2],cPict )+oRpt:CPIBoldN )
            Else
               oRpt:Say(  oRpt:nL,01,PADR(aLS[8],36) + aGT[11],,,1 )
               oRpt:Say(  oRpt:nL,99,TRANSFORM( aGT[2],cPict ) )
            EndIf
         EndIf
         oRpt:nL+= 2
         nK := If( aLS[7], 4, If( aGT[9] > 0, 5, 3 ) )
         aGT[01] ++
         aGT[nK] += aGT[2]
         aGT[02] := 0
      EndIf
      aLS[7] := aRes[4]
      aLS[8] := aRes[1]
      aGT[9] := aRes[2]
      aGT[11]:= TRANSFORM(aRes[2],"999,999,999-") + STR(aRes[3],1)
   EndIf
EndDo
MSFreeResult( hRes )
If aGT[1] > 0 .AND. !aGT[12]
   aGT[7] := aGT[3] + aGT[4] + aGT[5]
   oRpt:Say(  oRpt:nL,01,REPLICATE("_",134),,,1 )
   oRpt:Say(++oRpt:nL,01,TRANSFORM( aGT[1],"9,999" ) + " SALDOS",,,1 )
   oRpt:Say(  oRpt:nL,99,TRANSFORM( aGT[7],cPict ) )
   oRpt:Separator( 2,8 )
   oRpt:cFont := oRpt:CPINormal
   oRpt:Say( oRpt:nL  ,10,"TOTAL CLIENTES PARTICULARES  $"+NtChr( aGT[3],cPict ))
   oRpt:Say( oRpt:nL+2,10,"TOTAL OPTICAS DEL GRUPO ---> $"+NtChr( aGT[4],cPict ))
   oRpt:Say( oRpt:nL+4,10,"TOTAL EMPRESAS ------------> $"+NtChr( aGT[5],cPict ))
   oRpt:Say( oRpt:nL+6,10,"TOTAL DE LAS VENTAS--------> $"+NtChr( aGT[7],cPict ))
   oRpt:Say( oRpt:nL+8,10,"TOTAL FACT.ANULADAS--------> $"+NtChr( aGT[6],cPict ))
EndIf
oRpt:NewPage()
oRpt:End()
RETURN

//------------------------------------//
STATIC PROCEDURE AGrupar( aLS,oRpt )
   LOCAL aVT := { { 123,0,0 } }, aRes, hRes, nL, nK
   LOCAL aGT := { "",0,0,0,0,"","",,999 }
aRes := Privileg( {"principal",oApl:oEmp:PRINCIPAL,"optica <> ",1},.T.,(oApl:oEmp:PRINCIPAL == 4) )
aGT[1] := aRes[1]
aGT[8] := "SELECT optica, codigo_nit, SUM(totalfac), SUM(totaliva) FROM cadfactu "+;
          "WHERE optica "    + aGT[1]                  +;
           " AND fechoy >= " + xValToChar( aLS[2] )    +;
           " AND fechoy <= " + xValToChar( aLS[3] )    +;
           " AND tipo = "    + xValToChar( oApl:Tipo ) +;
           " AND NOT (indicador = 'A' AND MONTH(fechoy) = MONTH(fechaent))"+;
           " GROUP BY optica, codigo_nit"
//       AND (Indicador = 'A'
//       AND EXTRACT(YEAR_MONTH FROM Fechoy) = EXTRACT(YEAR_MONTH FROM Fechaent))
//aGT[9] := Seconds()
hRes := If( MSQuery( oApl:oMySql:hConnect,aGT[8] ),;
            MSStoreResult( oApl:oMySql:hConnect ) , 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aGT[9]  # aRes[1]
      aGT[9] := aRes[1]
      aGT[6] += ArrayValor( oApl:aOptic,STR(aGT[9],2) ) + " - "
   EndIf
   If (nK := ASCAN( aVT, {|aVal| aVal[1] == aRes[2]} )) == 0
      AADD( aVT, { aRes[2], 0, 0 } )
       nK := LEN( aVT )
   EndIf
   aVT[nK,2] += aRes[3]
   aVT[nK,3] += aRes[4]
   nL --
EndDo
MSFreeResult( hRes )
//aGT[9] := "Ha tardado " + STR( Seconds() - aGT[9] )
oRpt:aEnc[3] :=   STUFF( oRpt:aEnc[3],1,LEN( aGT[6] ),aGT[6] )
oRpt:aEnc[3] := STRTRAN( oRpt:aEnc[3],"SALDO  FACTURA","TOTAL  I.V.A." )
ASORT( aVT,,, { |x,y| x[2] > y[2] } )
FOR nK := 1 TO LEN( aVT )
   If aVT[nK,2] >= aLS[6]
      oApl:oNit:Seek( {"codigo_nit",aVT[nK,1]} )
     // If !oApl:oNit:lOK
     //    MsgInfo( aVT[nK,1],"NO EXISTE" )
     // EndIf
      oRpt:Titulo( 135 )
      oRpt:Say( oRpt:nL, 01,oApl:oNit:NOMBRE,,,1 )
      oRpt:Say( oRpt:nL, 40,TRANSFORM( oApl:oNit:CODIGO,"999,999,999-" ) +;
                STR(oApl:oNit:DIGITO,1) )
      oRpt:Say( oRpt:nL, 99,TRANSFORM( aVT[nK,2],"99,999,999,999.99" ) )
      oRpt:Say( oRpt:nL,118,TRANSFORM( aVT[nK,3],"99,999,999,999.99" ) )
      oRpt:nL+= 2
      aGT[2] += aVT[nK,2]
      aGT[3] += aVT[nK,3]
   EndIf
   aGT[4] += aVT[nK,2]
   aGT[5] += aVT[nK,3]
NEXT nK
oRpt:Say(  oRpt:nL, 01,REPLICATE("_",134),,,1 )
oRpt:Say(++oRpt:nL, 40,"BASE >"+TRANSFORM( aLS[6],"999,999,999" ),,,1 )
oRpt:Say(  oRpt:nL, 99,TRANSFORM( aGT[2],"99,999,999,999.99" ) )
oRpt:Say(  oRpt:nL,118,TRANSFORM( aGT[3],"99,999,999,999.99" ) )
oRpt:nL+= 2
oRpt:Say(  oRpt:nL, 40,"GRAN TOTAL DE VENTAS",,,1 )
oRpt:Say(  oRpt:nL, 99,TRANSFORM( aGT[4],"99,999,999,999.99" ) )
oRpt:Say(  oRpt:nL,118,TRANSFORM( aGT[5],"99,999,999,999.99" ) )

aGT[8] := "SELECT f.optica, f.codigo_nit, SUM(s.saldo) "  +;
          "FROM cadfactm s, cadfactu f "                  +;
          "WHERE f.optica "    + aGT[1]                   +;
           " AND f.fechoy <= " + xValToChar( aLS[3] )     +;
           " AND f.tipo    = " + xValToChar( oApl:Tipo )  +;
           " AND s.optica = f.optica"                     +;
           " AND s.numfac = f.numfac AND s.tipo = s.tipo" +;
           " AND s.anomes = (SELECT MAX(m.anomes) FROM cadfactm m "+;
                            "WHERE m.optica = f.optica"   +;
                             " AND m.numfac = f.numfac"   +;
                             " AND m.tipo   = f.tipo"     +;
			                       " AND m.anomes <= '" + NtChr( aLS[3],"1" ) +;
         "') AND s.saldo <> 0 GROUP BY f.optica, f.codigo_nit"
aVT    := { { 123,0 } }
aGT[9] := 999
hRes := If( MSQuery( oApl:oMySql:hConnect,aGT[8] ),;
            MSStoreResult( oApl:oMySql:hConnect ) , 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aGT[9]  # aRes[1]
      aGT[9] := aRes[1]
      aGT[7] += ArrayValor( oApl:aOptic,STR(aGT[9],2) ) + " - "
   EndIf
   If (nK := ASCAN( aVT, {|aVal| aVal[1] == aRes[2]} )) == 0
      AADD( aVT, { aRes[2], 0 } )
       nK := LEN( aVT )
    EndIf
    aVT[nK,2] += aRes[3]
    nL --
EndDo
MSFreeResult( hRes )
oRpt:aEnc[1] := "REPORTE DE CUENTAS POR COBRAR"
oRpt:aEnc[2] := NtChr( aLS[3],"3" )
oRpt:aEnc[3] :=   STUFF( oRpt:aEnc[3],1,LEN( aGT[6] ),aGT[7] )
oRpt:aEnc[3] := STRTRAN( oRpt:aEnc[3],"TOTAL  I.V.A.","SALDO  FACTURA" )
oRpt:nL := oRpt:nLength + 1
aGT[2] := 0
ASORT( aVT,,, { |x,y| x[2] > y[2] } )
FOR nK := 1 TO LEN( aVT )
   oApl:oNit:Seek( {"codigo_nit",aVT[nK,1]} )
   oRpt:Titulo( 135 )
   oRpt:Say( oRpt:nL, 01,oApl:oNit:NOMBRE,,,1 )
   oRpt:Say( oRpt:nL, 40,TRANSFORM( oApl:oNit:CODIGO,"999,999,999-" ) +;
             STR(oApl:oNit:DIGITO,1) )
   oRpt:Say( oRpt:nL, 63,oApl:oNit:DIRECCION )
   oRpt:Say( oRpt:nL,118,TRANSFORM( aVT[nK,2],"99,999,999,999.99" ) )
   oRpt:nL+= 2
   aGT[2] += aVT[nK,2]
NEXT nK
oRpt:Say(  oRpt:nL, 01,REPLICATE("_",134),,,1 )
oRpt:Say(++oRpt:nL, 63,"TOTAL CUENTAS POR COBRAR --> $" )
oRpt:Say(  oRpt:nL,118,TRANSFORM( aGT[2],"99,999,999,999.99" ) )

oRpt:NewPage()
oRpt:End()
RETURN