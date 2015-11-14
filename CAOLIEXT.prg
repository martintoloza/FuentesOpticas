// Programa.: CAOLIEXT.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Extracto de un Cliente
#include "FiveWin.ch"
#include "btnget.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE CaoLiExt()
   LOCAL oC, oNi, oDlg, oGet := ARRAY(8)
oC  := TExtracto() ; oC:NEW()
oNi := TNits()     ; oNi:New()
DEFINE DIALOG oDlg TITLE "Listo Extracto de un Cliente" FROM 0, 0 TO 12,50
   @ 02,00 SAY "Nit o C.C. del Cliente" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02,92 BTNGET oGet[1] VAR oC:aLS[1] OF oDlg PICTURE "999999999999";
      VALID EVAL( {|| If( oNi:oDb:Seek( {"codigo",oC:aLS[1]} )        ,;
                        ( oGet[6]:Settext( oNi:oDb:NOMBRE ), .t. )  ,;
                    (MsgStop("Este Nit ó C.C. no Existe.."),.f.)) }) ;
      RESOURCE "BUSCAR"                            SIZE 58,10 PIXEL  ;
      ACTION EVAL({|| If(oNi:Mostrar(), (oC:aLS[1] := oNi:oDb:CODIGO  ,;
                         oGet[1]:Refresh() ), ) })
   @ 14, 40 SAY oGet[6] VAR oC:aLS[6] OF oDlg PIXEL SIZE 130,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 26,00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 26,92 GET oGet[2] VAR oC:aLS[2] OF oDlg  SIZE 40,12 PIXEL
   @ 38,00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 38,92 GET oGet[3] VAR oC:aLS[3] OF oDlg ;
      VALID oC:aLS[3] >= oC:aLS[2] SIZE 40,12 PIXEL
   @ 50,00 SAY "CLASE DE LISTADO"   OF oDlg RIGHT PIXEL SIZE 90,10
   @ 50,92 COMBOBOX oGet[4] VAR oC:aLS[4] ITEMS { "Matriz","Laser" };
      SIZE 48,90 OF oDlg PIXEL
   @ 50,150 CHECKBOX oGet[5] VAR oC:aLS[5] PROMPT "Vista &Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 64, 50 BUTTON oGet[7] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[7]:Disable(), oC:ListoExt(), oDlg:End() ) PIXEL
   @ 64,110 BUTTON oGet[8] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 70, 02 SAY "[CAOLIEXT]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
CLASS TExtracto FROM TIMPRIME

 DATA aLS, oExt

 METHOD NEW() Constructor
 METHOD ListoExt()
 METHOD LaserExt( aVence )
ENDCLASS

//------------------------------------//
METHOD NEW( nL,aVence ) CLASS TExtracto
   LOCAL aRes, hRes
If nL == NIL
   Empresa()
   ::aLS := { 0,CTOD(""),DATE(),1,.f.,"",0 }
ElseIf nL == 1
   ::oExt := oApl:Abrir( "extracto","fechoy",,.t. )
   aRes := "SELECT u.numfac, u.fechoy, u.cliente, u.totalfac, p.fecpag, "      +;
                  "p.formapago, p.codbanco, p.numcheque, p.pagado, p.p_de_mas "+;
           "FROM cadfactu u LEFT JOIN cadpagos p "+;
              "ON u.optica = p.optica "           +;
             "AND u.numfac = p.numfac "           +;
             "AND u.tipo   = p.tipo "             +;
             "AND p.indicador <> 'A' "            +;
           "WHERE u.optica     = " + LTRIM(STR(oApl:nEmpresa))       +;
            " AND u.codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT))+;
            " AND u.fechoy    <= " + xValToChar( ::aLS[3] )          +;
            " AND u.tipo       = " + xValToChar(oApl:Tipo)           +;
            " AND u.indicador <> 'A' ORDER BY u.numfac"
   hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   While nL > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      If aRes[2] < ::aLS[2] .AND. DAY( ::aLS[2] ) == 1
         oApl:cPer := NtChr( ::aLS[2]-1,"1" )
         aVence[8] += SaldoFac( aRes[1],oApl:Tipo )
      EndIf
      oApl:cPer    := NtChr( ::aLS[3],"1" )
      oApl:nSaldo  := SaldoFac( aRes[1],1 )
      Vence( ::aLS[3] - aRes[2],@aVence )
      If ::aLS[7]  # aRes[1]
         ::aLS[7] := aRes[1]
         ::oExt:xBlank()
         ::oExt:NUMFAC  := aRes[1] ; ::oExt:TIPO    := oApl:Tipo
         ::oExt:FECHOY  := aRes[2] ; ::oExt:CLIENTE := aRes[3]
         ::oExt:VALOR   := aRes[4] ; ::oExt:DEBITOS := aRes[4]
         ::oExt:CREDITOS:= 0       ; ::oExt:Insert()
      EndIf
      If aRes[9] > 0
         ::oExt:xBlank()
         ::oExt:NUMFAC  := aRes[1] ; ::oExt:TIPO    := oApl:Tipo
         ::oExt:FECHOY  := aRes[5]
         ::oExt:CLIENTE := { "Efectivo ","Cheque   ","T.Debito ","T.Credito","Bono",;
                             "","","N.Credito ","N.Debito ","Anulada " }[ aRes[6]+1 ]
         If aRes[6] >= 7
            ::oExt:CLIENTE  += aRes[8]
            ::oExt:VALOR    := aRes[9] * If( aRes[6] == 8, 1, -1 )
            If ::oExt:VALOR > 0
               ::oExt:DEBITOS  := aRes[9]
               ::oExt:CREDITOS := 0
            Else
               ::oExt:DEBITOS  := 0
               ::oExt:CREDITOS := aRes[9]
            EndIf
         Else
            ::oExt:CLIENTE  += aRes[7]
            ::oExt:CREDITOS := aRes[9] - aRes[10]
            ::oExt:VALOR    := -::oExt:CREDITOS
         EndIf
            ::oExt:Insert()
      EndIf
      nL --
   EndDo
   MSFreeResult( hRes )
Else
   ::oExt:Destroy()
   MSQuery( oApl:oMySql:hConnect,"DROP TABLE extracto" )
   oApl:oDb:GetTables()
EndIf
RETURN NIL

//------------------------------------//
METHOD ListoExt() CLASS TExtracto
   LOCAL aVence := ARRAY(10), oRpt
oApl:Tipo := "U"
AFILL( aVence,0 )
 ::NEW( 1,@aVence )
oApl:nSaldo := aVence[8]
If !::oExt:Seek( { "fechoy >=",::aLS[2],"fechoy <=",::aLS[3] } )
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   ::NEW( 0 )
ElseIf ::aLS[4] == 2
   ::LaserExt( aVence )
   ::NEW( 0 )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ "EXTRACTO DE CUENTAS POR COBRAR"   ,;
         ALLTRIM( oApl:oNit:NOMBRE ) + "  DESDE " + NtChr( ::aLS[2],"2" )+;
         " HASTA " + NtChr( ::aLS[3],"2" ),"-F E C H A- DOCUMENTO ----"  +;
         "DESCRIPCION-----     DEBITOS    CREDITOS  -S A L D O-"},::aLS[5] )
While !::oExt:EOF()
   oApl:nSaldo += ::oExt:VALOR
   oRpt:Titulo( 79 )
   oRpt:Say( oRpt:nL,00,NtChr( ::oExt:FECHOY,"2" ) )
   oRpt:Say( oRpt:nL,12,STR(::oExt:NUMFAC,8) )
   oRpt:Say( oRpt:nL,22,::oExt:CLIENTE )
   oRpt:Say( oRpt:nL,43,TRANSFORM(::oExt:DEBITOS ,"@Z 999,999,999") )
   oRpt:Say( oRpt:nL,55,TRANSFORM(::oExt:CREDITOS,"@Z 999,999,999") )
   oRpt:Say( oRpt:nL,68,TRANSFORM( oApl:nSaldo ,   "999,999,999") )
   oRpt:nL ++
   aVence[09] += ::oExt:DEBITOS
   aVence[10] += ::oExt:CREDITOS
   ::oExt:Skip(1):Read()
   ::oExt:xLoad()
EndDo
   oRpt:Separator( 0,8 )
   oRpt:Say( oRpt:nL++,29,REPLICATE("=",50) )
   oRpt:Say( oRpt:nL++,29,"SALDO ANTER   TOT.DEBITOS TOT.CREDITO  NUEVO SALDO" )
   oRpt:Say( oRpt:nL  ,29,TRANSFORM( aVence[08],"999,999,999") )
   oRpt:Say( oRpt:nL  ,43,TRANSFORM( aVence[09],"999,999,999") )
   oRpt:Say( oRpt:nL  ,55,TRANSFORM( aVence[10],"999,999,999") )
   oRpt:Say( oRpt:nL++,68,TRANSFORM(oApl:nSaldo,"999,999,999") )
   oRpt:nL ++
   oRpt:Say( oRpt:nL++,25,"* * *  V E N C I M I E N T O S  * * *" )
   Vence( 0,aVence,01,oRpt )
oRpt:NewPage()
oRpt:End()
 ::NEW( 0 )
RETURN NIL

//------------------------------------//
METHOD LaserExt( aVence ) CLASS TExtracto
   LOCAL aRS, nL
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit,;
             "EXTRACTO DE CUENTAS POR COBRAR" , ALLTRIM( oApl:oNit:NOMBRE )    +;
             "  DESDE " + NtChr(::aLS[2],"2") + " HASTA " + NtChr(::aLS[3],"2"),;
             { .F., 0.8,"F E C H A" }  , { .T., 5.4,"DOCUMENTO" },;
             { .F., 5.7,"DESCRIPCION" }, { .T.,14.9,"DEBITOS" }  ,;
             { .T.,17.7,"CREDITOS" }   , { .T.,20.5,"S A L D O" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[5] ,,, ::aLS[5], 2 )
 ::nMD := 20.5
 PAGE
While !::oExt:EOF()
   oApl:nSaldo += ::oExt:VALOR
   ::Cabecera( .t.,0.42 )
   UTILPRN ::oUtil Self:nLinea, 0.5 SAY NtChr( ::oExt:FECHOY,"2" )
   UTILPRN ::oUtil Self:nLinea, 5.4 SAY   STR( ::oExt:NUMFAC,8 )     RIGHT
   UTILPRN ::oUtil Self:nLinea, 5.7 SAY  LEFT( ::oExt:CLIENTE,30 )
   UTILPRN ::oUtil Self:nLinea,14.9 SAY TRANSFORM(::oExt:DEBITOS ,"@Z 999,999,999") RIGHT
   UTILPRN ::oUtil Self:nLinea,17.7 SAY TRANSFORM(::oExt:CREDITOS,"@Z 999,999,999") RIGHT
   UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( oApl:nSaldo   ,   "999,999,999") RIGHT

   aVence[09] += ::oExt:DEBITOS
   aVence[10] += ::oExt:CREDITOS
   ::oExt:Skip(1):Read()
   ::oExt:xLoad()
EndDo
   ::Cabecera( .t.,0.42,3.36,20.5 )
   UTILPRN ::oUtil Self:nLinea,12.2 SAY "SALDO ANTER"  RIGHT
   UTILPRN ::oUtil Self:nLinea,14.9 SAY "TOT.DEBITOS"  RIGHT
   UTILPRN ::oUtil Self:nLinea,17.7 SAY "TOT.CREDITO"  RIGHT
   UTILPRN ::oUtil Self:nLinea,20.5 SAY "NUEVO SALDO"  RIGHT
   ::nLinea += 0.42
   UTILPRN ::oUtil Self:nLinea,12.2 SAY TRANSFORM( aVence[08],"999,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,14.9 SAY TRANSFORM( aVence[09],"999,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,17.7 SAY TRANSFORM( aVence[10],"999,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM(oApl:nSaldo,"999,999,999" ) RIGHT
   ::nLinea += 0.84
   UTILPRN ::oUtil Self:nLinea,08.5 SAY "* * *  V E N C I M I E N T O S  * * *"
   aRS := { "A 30 Dias","A 60 Dias","A 90 Dias","A 180 Dias","A 360 Dias","Sobre 360Dias",;
            ::nLinea+0.42, 6.6 }
   ::nLinea += 0.84
   FOR nL := 1 TO 6
      UTILPRN ::oUtil aRS[7]     , aRS[8] SAY aRS[nL]                             RIGHT
      UTILPRN ::oUtil Self:nLinea, aRS[8] SAY TRANSFORM(aVence[nL],"999,999,999") RIGHT
      If aVence[7]  > 0
         aVence[nL] := ROUND( aVence[nL]/aVence[7]*100,2 )
         UTILPRN ::oUtil aRS[7]+0.84,aRS[8] SAY TRANSFORM(aVence[nL],"999.99%") RIGHT
      EndIf
      aRS[8] += 2.8
   NEXT nL
   ENDPAGE
IMPRIME END .F.
RETURN NIL