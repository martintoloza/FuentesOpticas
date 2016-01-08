// Programa.: CAOPAGOS.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Despliega cuadro para los Pagos Facturas y Anticipos
#include "Fivewin.ch"

MEMVAR oApl

//------------------------------------//
FUNCTION CaoPagos( lPago,lNuevo,aPag )
   LOCAL aP, aTC, oDlg, oGet := ARRAY(17)
   LOCAL bGrabar, bSumar, bValid, nFPag, nFactu, nPago := 0
DEFAULT lPago := .f., lNuevo := .t. ,;
        aPag  := ArrayCombo( "FPAGO" )
aP := { oApl:dFec,"","","999,999,999",.f.,0,.f.,0,0,0,0,0,0,0,0 }
If lPago
   bGrabar := {|| GrabaPago( lNuevo,aP[6] )       ,;
                  aP[2] := oApl:oPag:NUMCHEQUE    ,;
                  aP[3] := oApl:oPag:CODBANCO     ,;
                  nPago := 0                      ,;
                  If( lNuevo, ( oApl:oPag:xBlanK(),;
                      oApl:oPag:FECPAG    := aP[1],;
                      oApl:oPag:NUMCHEQUE := aP[2],;
                      oApl:oPag:CODBANCO  := aP[3],;
                      AFILL( aP,0,8 )             ,;
                   oDlg:Update(), oGet[13]:oJump :=;
                   oGet[2], oGet[2]:SetFocus() )  ,;
                 (aP[5] := .t., oDlg:End()) ) }
   oApl:nSaldo := 0
   oApl:Tipo   := "U"
Else
   bGrabar := {|| aP[5] := .t., oDlg:End() }
EndIf
If lNuevo
   oApl:oPag:xBlank()
   oApl:oPag:FECPAG := aP[1]
   oApl:cPer := NtChr( aP[1],"1" )
Else
   If oApl:oEmp:FECVENTA > oApl:oPag:FECPAG .OR. oApl:oPag:PORDONDE == "A"
         aTC := { .f.,.f. }
      If Login( "Quiere Modificar este Pago" )
         aTC := Privileg( "PAGOS" )
      EndIf
      If !aTC[2]
         MsgStop("Usted no esta Autorizado para Modificar",oApl:cUser)
         RETURN .f.
      EndIf
   EndIf
   If oApl:oPag:NUMFAC > 0
      oApl:cPer := NtChr( oApl:oPag:FECPAG,"1" )
      oApl:lFam := SaldoFac( oApl:oPag:NUMFAC )
   EndIf
   aP[06]      := oApl:oPag:PAGADO - oApl:oPag:P_DE_MAS
   aP[08]      := oApl:oPag:ABONO
   aP[09]      := oApl:oPag:DEDUCCION
   aP[10]      := oApl:oPag:RETENCION
   aP[11]      := oApl:oPag:DESCUENTO
   aP[12]      := oApl:oPag:P_DE_MAS
   aP[13]      := oApl:oPag:RETICA
   aP[14]      := oApl:oPag:RETIVA
   aP[15]      := oApl:oPag:RETCRE
   oApl:nSaldo += aP[6]
   If (aP[7] := Rango( oApl:oPag:FORMAPAGO,2,3 ))
      aP[08]   += aP[09]
      aP[09]   := 0
   EndIf
EndIf
aTC    := PIva( oApl:oPag:FECPAG )
aTC[5] := " FROM bancosd WHERE (optica = " + LTRIM(STR(oApl:nEmpresa))      +;
                           " OR optica = " + LTRIM(STR(oApl:oEmp:PRINCIPAL))+;
                         ") AND codigo = 'bco'"
If aP[7] .AND. aTC[4] == 1
   aP[08] += aP[10] + aP[14] + aP[13]
   aP[14] := aP[14] * aTC[1] * 100
   aP[10] := aP[13] := aP[09] := 0
EndIf
oApl:oBco:Seek( {"codigo",oApl:oPag:CODBANCO} )
bValid := {|| If( !oApl:oFac:Seek( { "optica",oApl:nEmpresa,"numfac"    ,;
                                     nFactu,"tipo",oApl:Tipo} )         ,;
                ( MsgStop("Factura NO EXISTE"), .f.),;
                (If( (nPago := AT( oApl:oFac:INDICADOR,"ACN" )) > 0     ,;
                (MsgStop({"ANULADA","CANCELADA","N.Credito"}[nPago],"Factura"), .f.),;
                (oApl:lFam := SaldoFac( nFactu ), nPago := 0            ,;
                 aP[08] := oApl:nSaldo, oDlg:Update(), .t.) ))) }
bSumar := {|nVal| If( nVal < 0, (MsgStop( "El Valor debe ser Mayor de 0",;
                     "<< OJO >>" ), .f.), ;
            (nPago := aP[08] + aP[09] + aP[10] +;
                      aP[11] + aP[13] + aP[15] +;
                      If( nFPag >= 3, 0, aP[14] ),;
             oGet[15]:Refresh(), .t.) ) }
nFactu := oApl:oPag:NUMFAC
nFPag  := ArrayValor( aPag,STR(oApl:oPag:FORMAPAGO,1),,.t. )
DEFINE DIALOG oDlg TITLE "Pagos a Facturas de " + ArrayValor( oApl:aOptic,STR(oApl:nEmpresa,2) );
   FROM 0, 0 TO 370, 340 PIXEL
   @  02, 00 SAY "Fecha"         OF oDlg RIGHT PIXEL SIZE 50,10
   @  02, 52 GET oGet[01] VAR oApl:oPag:FECPAG OF oDlg ;
      VALID (aP[1] := oApl:oPag:FECPAG, oApl:cPer := NtChr( aP[1],"1" ), .t.);
      WHEN lNuevo .AND. !oApl:lEnLinea SIZE 40,10 PIXEL
   @  14, 00 SAY "Nro.Factura"   OF oDlg RIGHT PIXEL SIZE 50,10
   @  14, 52 GET oGet[02] VAR nFactu OF oDlg;
      VALID EVAL( bValid )                  ;
      WHEN lPago .AND. lNuevo          SIZE 40,10 PIXEL
   @  27, 06 SAY oApl:oFac:CLIENTE OF oDlg PIXEL SIZE 130,10;
      UPDATE COLOR nRGB( 128,0,255 )
   @  38, 00 SAY "Saldo Factura" OF oDlg RIGHT PIXEL SIZE 50,10
   @  38, 52 SAY oApl:nSaldo OF oDlg PICTURE aP[4] SIZE 40,10 PIXEL UPDATE
   @  50, 00 SAY "Forma Pago"    OF oDlg RIGHT PIXEL SIZE 50,10
   @  50, 52 COMBOBOX oGet[03] VAR nFPag ITEMS ArrayCol( aPag,1 ) ;
      SIZE 52,99 OF oDlg PIXEL ;
      VALID (aP[7] := Rango( nFPag,2,4 ), .t.)
   @  62, 00 SAY "Monto Pago"    OF oDlg RIGHT PIXEL SIZE 50,10
   @  62, 52 GET oGet[04] VAR aP[08]     OF oDlg PICTURE aP[4];
      VALID EVAL( bSumar,aP[08] )     ;
      SIZE 40,10 PIXEL UPDATE
   @  74, 00 SAY "Deducción"     OF oDlg RIGHT PIXEL SIZE 50,10
   @  74, 52 GET oGet[05] VAR aP[09] OF oDlg PICTURE aP[4];
      VALID EVAL( bSumar,aP[09] ) ;
      WHEN nFPag  # 5 SIZE 40,10 PIXEL UPDATE
   @  86, 00 SAY "Retención"     OF oDlg RIGHT PIXEL SIZE 50,10
   @  86, 52 GET oGet[06] VAR aP[10] OF oDlg PICTURE aP[4];
      VALID EVAL( bSumar,aP[10] ) ;
      WHEN nFPag <= 2 SIZE 40,10 PIXEL UPDATE
   @  98, 00 SAY "Descuento"     OF oDlg RIGHT PIXEL SIZE 50,10
   @  98, 52 GET oGet[07] VAR aP[11] OF oDlg PICTURE aP[4];
      VALID EVAL( bSumar,aP[11] ) ;
      WHEN nFPag  # 5 SIZE 40,10 PIXEL UPDATE
   @  98, 94 SAY "Pagado de +"   OF oDlg RIGHT PIXEL SIZE 36,10
   @  98,132 GET oGet[17] VAR aP[12] OF oDlg PICTURE aP[4];
      VALID EVAL( bSumar,aP[12] ) ;
      WHEN nFPag  # 5 SIZE 34,10 PIXEL UPDATE
   @ 110, 00 SAY "Ret.ICA"       OF oDlg RIGHT PIXEL SIZE 50,10
   @ 110, 52 GET oGet[08] VAR aP[13]    OF oDlg PICTURE aP[4];
      VALID EVAL( bSumar,aP[13] ) ;
      WHEN nFPag <= 2 SIZE 40,10 PIXEL UPDATE
   @ 110, 94 SAY "Total Pago"    OF oDlg RIGHT PIXEL SIZE 36,10
   @ 110,132 SAY oGet[15] VAR nPago OF oDlg PICTURE aP[4] SIZE 40,10 PIXEL;
      UPDATE COLOR nRGB( 255,0,128 )
   @ 122, 00 SAY "Código Banco"  OF oDlg RIGHT PIXEL SIZE 50,10
   @ 122, 52 GET oGet[09] VAR oApl:oPag:CODBANCO OF oDlg PICTURE "!!"      ;
      VALID EVAL( {|| If( oApl:oBco:Seek( {"codigo",oApl:oPag:CODBANCO} ) ,;
             (oApl:oPag:INDRED := Rango( nFPag,3,4 ), oDlg:Update(), .t. ),;
             (MsgStop("Este Banco no Existe .."),.f.) ) } )                ;
      WHEN aP[7] SIZE 16,10 PIXEL UPDATE
   @ 122, 70 SAY oApl:oBco:NOMBRE OF oDlg PIXEL SIZE 100,10 UPDATE
   @ 134, 00 SAY "Nro.Documento" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 134, 52 GET oGet[10] VAR oApl:oPag:NUMCHEQUE OF oDlg PICTURE "@!";
      WHEN nFPag >= 2 SIZE 58,10 PIXEL UPDATE
//  oGet[10]:cToolTip := "Para Bonos NC ##, SODEXO, BIG PASS"
   @ 134,114 CHECKBOX oGet[11] VAR oApl:oPag:INDRED PROMPT "Por Datafono" OF oDlg;
      WHEN nFPag >= 4 SIZE 50,12 PIXEL UPDATE
   @ 146, 00 SAY "Ret.IVA."      OF oDlg RIGHT PIXEL SIZE 50,10
   @ 146, 52 GET oGet[12] VAR aP[14]    OF oDlg PICTURE aP[4];
      VALID EVAL( bSumar,aP[14] ) ;
      WHEN nFPag <= 4 SIZE 40,10 PIXEL UPDATE
   @ 158, 00 SAY "Ret.CREE"      OF oDlg RIGHT PIXEL SIZE 50,10
   @ 158, 52 GET oGet[16] VAR aP[15]    OF oDlg PICTURE aP[4];
      VALID EVAL( bSumar,aP[15] ) ;
      WHEN nFPag <= 2 SIZE 40,10 PIXEL UPDATE

   @ 172, 70 BUTTON oGet[13] PROMPT "Aceptar" SIZE 40,12 OF oDlg CANCEL;
      ACTION ( If( TotalPagado( nFPag,@aP,oGet ), (oApl:oPag:NUMCHEQUE := aP[2],;
                   oGet[13]:oJump := oGet[10], oGet[10]:SetFocus() ),;
              (If( aP[7] .AND. EMPTY(oApl:oPag:CODBANCO)    ,;
                 ( MsgStop("Falta el Código del Banco"), oGet[9]:SetFocus()),;
                 ( EVAL( bSumar,0 )                               ,;
                   oApl:oPag:FORMAPAGO := VAL(aPag[nFPag,2])      ,;
                   If( TotalPagado( nPago,aTC ), (EVAL( bGrabar )),;
                     ( oGet[13]:oJump := oGet[4], oGet[4]:SetFocus()) ))) )) ) PIXEL
   @ 172,114 BUTTON oGet[14] PROMPT "Cancelar" SIZE 40,12 OF oDlg CANCEL;
      ACTION (aP[5] := .f., oDlg:End()) PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER
RETURN aP[5]

//------------------------------------//
FUNCTION TotalPagado( nPago,aTC,nPorT )
   LOCAL lOk := .f., nAbono
If nPorT # NIL
   If nPago == 5
      aTC[2] := oApl:oPag:NUMCHEQUE
      If LEFT( aTC[2],3 ) == "BIG" .OR. LEFT( aTC[2],4 ) == "SODE"
         oApl:oPag:INDRED := .f.
         nPorT[11]:Refresh()
      ElseIf !oApl:oPag:INDRED
         lOk := MsgYesNo( "Debes que Chulear Por Datafono","Si este BONO es por N.Credito" )
      EndIf
      If EMPTY( aTC[2] ) .AND. (lOk .OR. oApl:oPag:INDRED)
         aTC[2] := "NC.             "
         lOk := .t.
         MsgStop( "Nro.Documento = NC. + el # de la N.C",">> OJO <<" )
      EndIf
   EndIf
   oApl:oPag:ABONO     := aTC[08]
   oApl:oPag:DEDUCCION := aTC[09]
   oApl:oPag:RETENCION := aTC[10]
   oApl:oPag:DESCUENTO := aTC[11]
   oApl:oPag:P_DE_MAS  := aTC[12]
   oApl:oPag:RETICA    := aTC[13]
   oApl:oPag:RETIVA    := aTC[14]
   oApl:oPag:RETCRE    := aTC[15]
ElseIf nPago > 0
   If (lOk := MsgYesNo( "Graba este Pago" ))
      nAbono := nPago - oApl:oPag:P_DE_MAS
      If nAbono > oApl:nSaldo
         lOk := MsgNoYes( "Desea Continuar","Pago Mayor que el Saldo" )
      EndIf
   EndIf
EndIf
If lOk
   If Rango( oApl:oPag:FORMAPAGO,2,3 )
      nAbono:= oApl:oPag:ABONO - oApl:oPag:RETIVA
      nPorT := Buscar( "SELECT " + {"debito","credito"}[oApl:oPag:FORMAPAGO-1] +;
                       STRTRAN( aTC[5],"bco",TRIM(oApl:oPag:CODBANCO) ),"CM",,8,,4 )
      If nPorT == 0
         nPorT := If( oApl:oPag:FORMAPAGO == 2, oApl:oBco:DEBITO, oApl:oBco:CREDITO )
      EndIf
      If aTC[4] == 1
         oApl:oPag:RETIVA    := ROUND( oApl:oPag:RETIVA* aTC[1],0 )
         oApl:oPag:RETENCION := ROUND( nAbono * aTC[3],0 )
         oApl:oPag:RETICA    := ROUND( nAbono * aTC[2],0 )
      Else
         nAbono += oApl:oPag:RETIVA
         oApl:oPag:RETIVA    := 0
      EndIf
      oApl:oPag:DESCUENTO += oApl:oPag:DEDUCCION
      oApl:oPag:DEDUCCION := ROUND( nAbono * nPorT / 100,2 )
      If oApl:oPag:FORMAPAGO == 3 .AND. oApl:oPag:CODBANCO # "CB" .AND. ;
        (oApl:oBco:EN_ESPERA .OR. !oApl:oPag:INDRED)
         oApl:oPag:DEDUCCION := 0
         nPago := oApl:oPag:DESCUENTO
      EndIf
      oApl:oPag:ABONO -= (oApl:oPag:DEDUCCION + oApl:oPag:RETENCION +;
                          oApl:oPag:RETIVA    + oApl:oPag:RETICA)
   Else
      If oApl:oPag:FORMAPAGO == 0
         oApl:oPag:CODBANCO  := oApl:oPag:NUMCHEQUE := ""
      ElseIf oApl:oPag:FORMAPAGO == 4
         oApl:oPag:CODBANCO  := ""
         oApl:oPag:RETENCION := oApl:oPag:RETIVA    := 0
         oApl:oPag:RETICA    := oApl:oPag:RETCRE    := 0
      EndIf
   EndIf
   oApl:oPag:PAGADO := nPago
EndIf
RETURN lOk

//------------------------------------//
PROCEDURE GrabaPago( lNuevo,nPagado )
   LOCAL aCan := { "P",CTOD("") }, nPago
   nPago := oApl:oPag:PAGADO - oApl:oPag:P_DE_MAS
If lNuevo
   oApl:oPag:OPTICA    := oApl:nEmpresa ; oApl:oPag:NUMFAC   := oApl:oFac:NUMFAC
   oApl:oPag:TIPO      := oApl:Tipo     ; oApl:oPag:PORDONDE := "P"
   oApl:oPag:INDICADOR := If( oApl:cLocal == "LOC", "*", "" )
   If oApl:lEnLinea
      oApl:oPag:RCAJA  := RCaja( .f.,123,oApl:oPag:FECPAG,"F" )
    //oApl:oPag:RCAJA  := RCaja( .f.,oApl:oFac:CODIGO_NIT,oApl:oPag:FECPAG,"P" )
   EndIf
   Guardar( oApl:oPag,.t.,.f. )
Else
   nPago       -= nPagado
   oApl:nSaldo -= nPagado
   Guardar( oApl:oPag,.f.,.f. )
Endif
If nPago # 0
   GrabaSal( oApl:oPag:NUMFAC,1,nPago )
EndIf
If (oApl:nSaldo - nPago) = 0
   aCan := { "C",oApl:oPag:FECPAG }
EndIf
oApl:oFac:INDICADOR := aCan[1] ; oApl:oFac:FECHACAN := aCan[2]
Guardar( oApl:oFac,.f.,.f. )
RETURN

//------------------------------------//
FUNCTION PIva( dFec )
   LOCAL aDF, hRes
aDF := "SELECT iva2, ica, ret, 1, iva1, ret2, ica2, rsim, cree " +;
       "FROM cadfijos WHERE " + xValToChar(dFec) +;
      " BETWEEN fechai AND fechaf AND optica = " + LTRIM(STR(oApl:nEmpresa))
hRes := If( MSQuery( oApl:oMySql:hConnect,aDF ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If MSNumRows( hRes ) > 0
   aDF := MyReadRow( hRes )
   AEVAL( aDF, { | xV,nP | aDF[nP] := MyClReadCol( hRes,nP ) } )
Else
   aDF := { 0,0,0,0,0.16,0.035,0.0096,0.024,0.003 }
EndIf
MSFreeResult( hRes )
RETURN aDF
/*
//  If(nKey=VK_RETURN, FwKeyBoard( oCmb,VK_TAB ), NIL) }
FUNCTION FwKeyBoard( oWnd,nKey )
 oWnd:SetFocus()
 oWnd:PostMsg( WM_KEYDOWN, nKey, 0 )
RETURN NIL*/