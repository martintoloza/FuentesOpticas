// Programa.: CAOLICAR.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Cuentas de Cobro.
#include "FiveWin.ch"
#include "Btnget.ch"

MEMVAR oApl

PROCEDURE CaoLiCar()
   LOCAL oGet := ARRAY(10), aOpc := { "   ",0,CTOD(""),CTOD(""),"N","N",.f.,"",0 }
   LOCAL oDlg, oNi := TNits()
oNi:New()
oNi:oDb:xBlank()
DEFINE DIALOG oDlg TITLE "Cuenta de Cobro" FROM 0, 0 TO 15,64
   @ 02, 00 SAY "Optica" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02, 92 GET oGet[1] VAR aOpc[1] OF oDlg PICTURE "@!"        ;
      VALID Eval( {|| If( oApl:oEmp:Seek( {"localiz",aOpc[1]} ),;
                        ( nEmpresa( .t. ), .t. )               ,;
                      (MsgStop("Esta Optica NO EXISTE"), .f.) ) } );
      SIZE 24,12 PIXEL
   @ 16, 00 SAY    "Nit por Default Todos" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 16, 92 BTNGET oGet[2] VAR aOpc[2] OF oDlg PICTURE "9999999999";
      VALID EVAL( {|| If( EMPTY( aOpc[2] ), .t.                   ,;
              (If( oNi:Buscar( aOpc[2],"codigo",.t. )             ,;
              ( oGet[3]:Settext( oNi:oDb:NOMBRE ) , .t. )         ,;
              ( MsgStop("Este NIT no Existe ...."), .f. ) ))) } )  ;
      SIZE 54,12 PIXEL      RESOURCE "BUSCAR"                      ;
      ACTION EVAL({|| If(oNi:Mostrar( ,,aOpc[2] ), ( aOpc[2] :=    ;
                         oNi:oDb:CODIGO, oGet[2]:Refresh() ),) })
   @ 16,150 SAY oGet[3] VAR aOpc[8] OF oDlg PIXEL SIZE 100,20 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 30, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 30, 92 GET oGet[4] VAR aOpc[3] OF oDlg  SIZE 40,12 PIXEL
   @ 44, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 44, 92 GET oGet[5] VAR aOpc[4] OF oDlg ;
      VALID aOpc[4] >= aOpc[3] SIZE 40,12 PIXEL
   @ 58, 00 SAY "LISTA LA RELACION DE EPS" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 58, 92 GET oGet[6] VAR aOpc[5] OF oDlg PICTURE "!";
      VALID If( aOpc[5] $ "NS", .t., .f. )             ;
      WHEN oNi:oDb:EPS  SIZE 08,12 PIXEL
   @ 72, 00 SAY "LISTAR DE OTRAS CIUDADES" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 72, 92 GET oGet[7] VAR aOpc[6] OF oDlg PICTURE "!";
      VALID If( aOpc[6] $ "NS", .t., .f. )             ;
      WHEN oNi:oDb:EPS  SIZE 08,12 PIXEL
   @ 72,140 CHECKBOX oGet[8] VAR aOpc[7] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 88, 50 BUTTON oGet[09] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[9]:Disable(), ListoCar( aOpc ), oGet[9]:Enable(),;
        oGet[9]:oJump := oGet[2], oGet[2]:SetFocus() ) PIXEL
   @ 88,100 BUTTON oGet[10] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 94, 02 SAY "[CAOLICAR]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
STATIC PROCEDURE ListoCar( aLS )
   LOCAL aE, aRes, hRes, cQry, nL, nTF
   LOCAL oRpt := TDosPrint()
If aLS[5] == "S"
   Eps( aLS,oRpt )
   RETURN
EndIf
If oApl:oEmp:PRINCIPAL == 4
   aRes := Privileg( {"principal",4,"optica <> ",1,"activa","1"},.t.,.f. )
   oApl:oEmp:Seek( { "optica",oApl:nEmpresa } )
Else
   aRes := { " = " + LTRIM(STR(oApl:nEmpresa)),1 }
EndIf
cQry := "SELECT n.nombre, n.codigo, n.digito, c.nombre, "+;
             "f.cliente, f.fechoy, f.numfac, f.totalfac "+;
        "FROM ciudades c, cadclien n, cadfactu f "       +;
        "WHERE c.codigo     = n.codigo_ciu"              +;
         " AND f.codigo_nit = n.codigo_nit"              +;
         " AND f.optica "    + aRes[1]                   +;
         " AND f.fechoy >= " + xValToChar( aLS[3] )      +;
         " AND f.fechoy <= " + xValToChar( aLS[4] )      +;
         " AND f.tipo    = " + xValToChar( oApl:Tipo )   +;
         " AND f.indicador = 'P'" +      If( aLS[2] > 0  ,;
         " AND f.codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT)), "" ) +;
         " ORDER BY n.nombre, f.fechoy, f.numfac"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes ) ; RETURN
EndIf
   aE   := ArrayCol( ,0 )
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )

oRpt:New( oApl:cPuerto,oApl:cImpres,,aLS[7] )
oRpt:aEnc := { PADC(   LEFT( oApl:oEmp:NOMBRE,aE[1] )      ,25 ),;
               PADC( SUBSTR( oApl:oEmp:NOMBRE,aE[2],aE[3] ),41 ) }
oRpt:SetFont( oRpt:cFontI,82,2 )
oRpt:nL := 14 ; oRpt:nPage := 1
 aLS[2] := aRes[2]
 nTF := 0
While nL > 0
   If oRpt:nL == 14
      If oRpt:nPage == 1
         aLS[9] := SgteNumero( "numfacz",oApl:oEmp:PRINCIPAL,.t. )
      EndIf
      oRpt:Say( 01,00,oRpt:CPILarge + oRpt:aEnc[1] )
      oRpt:Say( 02,00,oRpt:aEnc[2] )
      oRpt:Say( 02,40,oApl:oEmp:DIRECCION )
      oRpt:Say( 03,10,"NIT: " + oApl:oEmp:Nit )
      oRpt:Say( 03,40,"TELEFONOS: " + oApl:oEmp:TELEFONOS )
      oRpt:Say( 04,40,TRIM(oApl:cCiu) + " - COLOMBIA" )
      oRpt:Say( 05,48,oRpt:CPIBold + "RELACION DE FACTURAS PARA COBRO" )
      oRpt:Say( 06,12,"FECHA " + NtChr( aLS[4],"2" ) )
      oRpt:Say( 06,50,oRpt:CPILarge + "No." + STR(aLS[9],10) )
      oRpt:Say( 08,02,"SE\OR(ES) " + aRes[1] )
      oRpt:Say( 09,02,"    NIT : " + FormatoNit( aRes[2],aRes[3] ) )
      oRpt:Say( 10,12,aRes[4] )
      oRpt:Say( 11,12,oRpt:CPICompress + "A CONTINUACION ESTAMOS RELACIONANDO LAS FACTURAS CORRESPONDIENTES A LOS SERVICIOS PRESTADOS" )
      oRpt:Say( 12,05,"BENEFICIARIO DEL SERVICIO        F E C H A   No.FACTURA     V A L O R" )
      oRpt:Say( 13,05,REPLICATE( "_",72 ) )
   EndIf
   oRpt:Say( oRpt:nL,05,aRes[5] )
   oRpt:Say( oRpt:nL,37,NtChr( aRes[6],"2" ) )
   oRpt:Say( oRpt:nL,50,aRes[7] )
   oRpt:Say( oRpt:nL,63,TRANSFORM(aRes[8],"999,999,999.99") )
   oRpt:nL ++
   nTF += aRes[8]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. oRpt:nL == 50
      oRpt:Say( 50,05,REPLICATE( "_",72 ) )
      oRpt:Say( 54,40,"RECIBIDO" )
      oRpt:Say( 56,01,"SARA ORTEGA MONTES" )
      oRpt:Say( 57,01,"______________________________         ______________________________" )
      oRpt:Say( 58,01,"        DPTO. DE CARTERA                       FIRMA Y SELLO" )
      oRpt:Say( 59,68,"Pagina" + STR(oRpt:nPage,4) )
      oRpt:SetFont( oRpt:CPICompress,82,1 )
      oRpt:Say( 60,01,"1. FAVOR CANCELAR CON CHEQUE CRUZADO NO NEGOCIABLE A FAVOR DE:" )
      oRpt:Say( 60,65,oRpt:CPIBold + SUBSTR( oApl:oEmp:NOMBRE,1,aE[4] ) )
      oRpt:Say( 61,01,"2. ESTA RELACION, CUYAS FACTURAS SE ANEXAN, DEBEN SER CANCELADA DENTRO DE LOS 30 DIAS SIGUIENTES A SU RECIBO." )
      oRpt:SetFont( oRpt:cFontI,82,2 )
   EndIf
   If aLS[2] == aRes[2] .AND. oRpt:nL == 50
      oRpt:Say( 51,63,"Pasan........" )
      oRpt:NewPage()
      oRpt:nL := 14 ; oRpt:nPage ++
   EndIf
   If nL == 0 .OR. aLS[2] # aRes[2]
      cQry := Letras( nTF,80 )
      oRpt:Say( 51,52,oRpt:CPIBold + "TOTAL ==> $" + TRANSFORM(nTF,"999,999,999.99") )
      oRpt:Say( 52,01,oRpt:CPICompress + "SON " + cQry[1] )
      oRpt:Say( 53,05,oRpt:CPICompress + cQry[2] )
      oRpt:NewPage()
      oRpt:nL := 14 ; oRpt:nPage := 1
      aLS[2] := aRes[2]
      nTF    := 0
   EndIf
EndDo
MSFreeResult( hRes )
oRpt:End()
/*
oRpt:New( oApl:cPuerto,oApl:cImpres,,aLS[7],1,1,44,44 )
oRpt:SetFont( oRpt:cFontI,82,2 )
oRpt:nL := 13 ; oRpt:nPage := 1
While nL > 0
   If oRpt:nL == 13
      oRpt:Say( 04,51,RIGHT(DTOC(aLS[4]),4 )   + "  " + ;
                     SUBSTR(DTOC(aLS[4]),4,2 ) + "  " + LEFT(DTOC(aLS[4]),2 ))
      oRpt:Say( 06,02,aRes[1] )
      oRpt:Say( 06,46,TRANSFORM(aRes[2],"999,999,999-") + STR(aRes[3],1) )
      oRpt:Say( 09,46,aRes[4] )
      oRpt:Say( 10,01,CHR(27)+CHR(51)+CHR(58)+" " )  // n/216 ESC 3n
      oRpt:Say( 11,01,CHR(27)+CHR(50)+" " )          // 1/6   ESC 2 Normal
   EndIf
   oRpt:Say( oRpt:nL,01,aRes[5] )
   oRpt:Say( oRpt:nL,30,RIGHT(DTOC(aRes[6]),4 )   + " " + ;
                       SUBSTR(DTOC(aRes[6]),4,2 ) + " " + LEFT(DTOC(aRes[6]),2 ))
   oRpt:Say( oRpt:nL,42,aRes[7] )
   oRpt:Say( oRpt:nL,51,TRANSFORM(aRes[8],"99,999,999.99") )
   oRpt:nL ++
   nTF += aRes[8]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If aRes[2] == aLS[2] .AND. oRpt:nL > 29
      oRpt:Say( 32,51,"Pasan........" )
      oRpt:Say( 34,01,"SARA ORTEGA MONTES",24 )
//      oRpt:Say( 35,01,Usu->NOMBRE,24 )
      oRpt:NewPage()
      oRpt:nL := 13
   EndIf
   If nL == 0 .OR. aRes[2] # aLS[2]
      oRpt:Say( 32,51,TRANSFORM(nTF,"99,999,999.99") )
      oRpt:Say( 34,01,"SARA ORTEGA MONTES",24 )
      oRpt:NewPage()
      oRpt:nL := 13 ; oRpt:nPage := 1
      aLS[2] := aRes[2]
      nTF    := 0
   EndIf
EndDo
*/
RETURN

//------------------------------------//
STATIC PROCEDURE Eps( aLS,oRpt )
   LOCAL aGT := { 0,0,0,0,"tipofac = 'O'" }, aRes, hRes, cQry, nL
oRpt:New( oApl:cPuerto,oApl:cImpres,{"RELACION DE USUARIOS DE "+;
         TRIM(oApl:oNit:NOMBRE),"QUE SE LE SUMINISTRARON LENTES OFTALMICOS DURANTE",;
         "               EL MES DE "+NtChr( aLS[3],"6")+" SEGUN ORDENES ADJUNTAS",;
         "--FACTURA-  -NOMBRE DEL CLIENTE-   ---COPAGO--  " },aLS[7] )
If aLS[6] == "S"
   oRpt:aEnc[4] += "OTRA CIUDAD-   VALOR TOTAL"
Else
   aGT[5] := "tipofac IN ('P','M')"
   oRpt:aEnc[4] += "C.MODERADORA   VALOR TOTAL"
EndIf
cQry := "SELECT numfac, cliente, valoreps, totalfac, " +;
        "tipofac  FROM cadfactu "                      +;
        "WHERE optica  = " + LTRIM(STR(oApl:nEmpresa)) +;
         " AND fechoy >= " + xValToChar( aLS[3] )      +;
         " AND fechoy <= " + xValToChar( aLS[4] )      +;
         " AND tipo    = " + xValToChar( oApl:Tipo )   +;
         " AND codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT))+;
         " AND indicador <> 'A' AND "  + aGT[5]        +;
         " AND totalfac > 0  ORDER BY numfac"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   oRpt:Titulo( 78 )
   oRpt:Say( oRpt:nL,01,aRes[1] )
   oRpt:Say( oRpt:nL,13,aRes[2] )
   If aRes[5] == "P"
      oRpt:Say( oRpt:nL,36,TRANSFORM(aRes[3],"999,999,999") )
      aGT[1] += aRes[3]
   Else
      oRpt:Say( oRpt:nL,50,TRANSFORM(aRes[3],"999,999,999") )
      aGT[2] += aRes[3]
   EndIf
   oRpt:Say( oRpt:nL,64,TRANSFORM(aRes[4],"999,999,999") )
   oRpt:nL ++
   aGT[3] += aRes[4]
   aGT[4] ++
   nL --
EndDo
MSFreeResult( hRes )
If aGT[4] > 0
   oRpt:Say( oRpt:nL++,01,REPLICATE("_",78) )
   oRpt:Say( oRpt:nL  ,01,TRANSFORM(aGT[4], "99,999,999") )
   oRpt:Say( oRpt:nL  ,36,TRANSFORM(aGT[1],"999,999,999") )
   oRpt:Say( oRpt:nL  ,50,TRANSFORM(aGT[2],"999,999,999") )
   oRpt:Say( oRpt:nL  ,64,TRANSFORM(aGT[3],"999,999,999") )
EndIf
oRpt:NewPage()
oRpt:End()
RETURN