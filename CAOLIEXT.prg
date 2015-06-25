// Programa.: CAOLIEXT.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Extracto de un Cliente
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE CaoLiExt()
   LOCAL oDlg, oGet := ARRAY(7), aOpc := { 0,CTOD(""),DATE(),.f.,"" }
   LOCAL oNi := TNits()
oNi:New()
DEFINE DIALOG oDlg TITLE "Listo Extracto de un Cliente" FROM 0, 0 TO 10,50
   @ 02,00 SAY "Nit o C.C. del Cliente" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02,92 BTNGET oGet[1] VAR aOpc[1] OF oDlg PICTURE "999999999999";
      VALID EVAL( {|| If( oNi:oDb:Seek( {"codigo",aOpc[1]} )        ,;
                        ( oGet[7]:Settext( oNi:oDb:NOMBRE ), .t. )  ,;
                    (MsgStop("Este Nit ó C.C. no Existe.."),.f.)) }) ;
      RESOURCE "BUSCAR"                            SIZE 58,12 PIXEL  ;
      ACTION EVAL({|| If(oNi:Mostrar(), (aOpc[1] := oNi:oDb:CODIGO  ,;
                         oGet[1]:Refresh() ), ) })
   @ 16, 40 SAY oGet[7] VAR aOpc[5] OF oDlg PIXEL SIZE 130,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 30,00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 30,92 GET oGet[2] VAR aOpc[2] OF oDlg  SIZE 40,12 PIXEL
   @ 44,00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 44,92 GET oGet[3] VAR aOpc[3] OF oDlg ;
      VALID aOpc[3] >= aOpc[2] SIZE 40,12 PIXEL
   @ 44,150 CHECKBOX oGet[4] VAR aOpc[4] PROMPT "Vista &Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 60, 50 BUTTON oGet[5] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[5]:Disable(), ListoExt( aOpc ), oDlg:End() ) PIXEL
   @ 60,110 BUTTON oGet[6] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 66, 02 SAY "[CAOLIEXT]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT Empresa()
RETURN

//------------------------------------//
STATIC PROCEDURE ListoExt( aLS )
   LOCAL aVence := ARRAY(10), oRpt, oExt
   LOCAL cQry, aRes, hRes, nL
   LOCAL aPago := { "Efectivo ","Cheque   ","T.Debito ","T.Credito","Bono","","",;
                    "N.Credito","N.Debito ","Anulada  " }
oExt := oApl:Abrir( "extracto","fechoy",,.t. )
oApl:Tipo := "U"
AFILL( aVence,0 )
cQry := "SELECT numfac, fechoy, cliente, totalfac FROM cadfactu "+;
        "WHERE optica = "     + LTRIM(STR(oApl:nEmpresa))        +;
         " AND codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT)) +;
         " AND fechoy <= " + xValToChar( aLS[3] )                +;
         " AND tipo   = "  + xValToChar(oApl:Tipo)               +;
         " AND indicador <> 'A'"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aRes[2] < aLS[2] .AND. DAY( aLS[2] ) == 1
      oApl:cPer := NtChr( aLS[2]-1,"1" )
      aVence[8] += SaldoFac( aRes[1],oApl:Tipo )
   EndIf
   oApl:cPer    := NtChr( aLS[3],"1" )
   oApl:nSaldo  := SaldoFac( aRes[1],1 )
   Vence( aLS[3] - aRes[2],@aVence )
   oExt:xBlank()
   oExt:NUMFAC  := aRes[1] ; oExt:TIPO    := oApl:Tipo
   oExt:FECHOY  := aRes[2] ; oExt:CLIENTE := aRes[3]
   oExt:VALOR   := aRes[4] ; oExt:DEBITOS := aRes[4]
   oExt:CREDITOS:= 0       ; oExt:Insert()
   oApl:oPag:Seek( {"optica",oApl:nEmpresa,"numfac",aRes[1],;
                    "tipo",oApl:Tipo,"indicador <> ","A"} )
   While !oApl:oPag:Eof()
      oExt:xBlank()               ; oExt:NUMFAC := oApl:oPag:NUMFAC
      oExt:TIPO := oApl:oPag:TIPO ; oExt:FECHOY := oApl:oPag:FECPAG
      If oApl:oPag:FORMAPAGO >= 7
         oExt:CLIENTE  := aPago[oApl:oPag:FORMAPAGO+1] + oApl:oPag:NUMCHEQUE
         oExt:VALOR    := oApl:oPag:PAGADO * If( oApl:oPag:FORMAPAGO == 8, 1, -1 )
         oExt:DEBITOS  := If( oExt:VALOR > 0, oApl:oPag:PAGADO, 0 )
         oExt:CREDITOS := If( oExt:VALOR < 0, oApl:oPag:PAGADO, 0 )
      Else
         oExt:CLIENTE  := aPago[oApl:oPag:FORMAPAGO+1] + oApl:oPag:CODBANCO
         oExt:CREDITOS := oApl:oPag:PAGADO    - oApl:oPag:P_DE_MAS
       //oExt:CREDITOS := oApl:oPag:ABONO     + oApl:oPag:RETENCION + ;
       //                 oApl:oPag:DEDUCCION + oApl:oPag:DESCUENTO
         oExt:VALOR    := -oExt:CREDITOS
      EndIf
         oExt:Insert()
      oApl:oPag:Skip(1):Read()
      oApl:oPag:xLoad()
   EndDo
   nL --
EndDo
MSFreeResult( hRes )
oApl:nSaldo := aVence[8]
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"EXTRACTO DE CUENTAS POR COBRAR" ,;
         ALLTRIM( oApl:oNit:NOMBRE ) + "  DESDE " + NtChr( aLS[2],"2" )+;
         " HASTA " + NtChr( aLS[3],"2" ),"-F E C H A- DOCUMENTO ----"  +;
         "DESCRIPCION-----     DEBITOS    CREDITOS  -S A L D O-"},aLS[4] )
oExt:Seek( { "fechoy >=",aLS[2],"fechoy <=",aLS[3] } )
While !oExt:EOF()
   oApl:nSaldo += oExt:VALOR
   oRpt:Titulo( 79 )
   oRpt:Say( oRpt:nL,00,NtChr( oExt:FECHOY,"2" ) )
   oRpt:Say( oRpt:nL,12,STR(oExt:NUMFAC,8) )
   oRpt:Say( oRpt:nL,22,oExt:CLIENTE )
   oRpt:Say( oRpt:nL,43,TRANSFORM(oExt:DEBITOS ,"@Z 999,999,999") )
   oRpt:Say( oRpt:nL,55,TRANSFORM(oExt:CREDITOS,"@Z 999,999,999") )
   oRpt:Say( oRpt:nL,68,TRANSFORM( oApl:nSaldo ,   "999,999,999") )
   oRpt:nL ++
   aVence[09] += oExt:DEBITOS
   aVence[10] += oExt:CREDITOS
   oExt:Skip(1):Read()
   oExt:xLoad()
EndDo
If oRpt:nPage > 0
   oRpt:Separator( 0,8 )
   oRpt:Say( oRpt:nL++,29,REPLICATE("=",50) )
   oRpt:Say( oRpt:nL++,29,"SALDO ANTER   TOT.DEBITOS TOT.CREDITO  NUEVO SALDO" )
   oRpt:Say( oRpt:nL  ,29,TRANSFORM( aVence[08],"999,999,999") )
   oRpt:Say( oRpt:nL  ,43,TRANSFORM( aVence[09],"999,999,999") )
   oRpt:Say( oRpt:nL  ,55,TRANSFORM( aVence[10],"999,999,999") )
   oRpt:Say( oRpt:nL++,68,TRANSFORM(oApl:nSaldo,"999,999,999") )
   oRpt:nL ++
   oRpt:Say( oRpt:nL++,25,"* * *  V E N C I M I E N T O S  * * *" )
   Vence( 0,aVence,10,oRpt )
EndIf
oRpt:NewPage()
oRpt:End()
oExt:Destroy()
MSQuery( oApl:oMySql:hConnect,"DROP TABLE extracto" )
oApl:oDb:GetTables()
RETURN