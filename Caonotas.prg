// Programa.: CAONOTAS.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Captura las notas DB Y CR a facturas
#include "FiveWin.ch"

MEMVAR oApl

PROCEDURE CaoNotas()
   LOCAL oDlg, oLbx, oGet := ARRAY(1), lSalir := .f.
   LOCAL aBarra, aN := { oApl:dFec,0,1,0,0,0 }, bSum
   LOCAL aDev := { "","","","","","","","CREDITO","DEBITO","ANULADA" }
aBarra := { {|| NotasEdita( oLbx,@aN,.t. ) } ,;
            {|| NotasEdita( oLbx,@aN,.f. ) } ,;
            {|| .t. }                        ,;
            {|| NotasBorra( oLbx,aN ) }      ,;
            {|| ListNota( {aN[1],0,1,.f.} ) },;
            {|| lSalir := .t., oDlg:End() } }
bSum := {|| oApl:oPag:Seek( { "optica",oApl:nEmpresa,"fecpag",aN[1],;
                              "formapago >=",7,"formapago <=",9 } ),;
            aN[2] := oApl:oPag:RecCount(), oApl:cPer := NtChr( aN[1],"1" ) }
EVAL( bSum )
DEFINE DIALOG oDlg FROM 0, 0 TO 320, 580 PIXEL;
   TITLE "Notas Debitos y Creditos"
   @ 02,00 SAY "Fecha [DD.MM.AAAA]" OF oDlg RIGHT PIXEL SIZE 76,10
   @ 02,80 GET oGet[1] VAR aN[1]    OF oDlg SIZE 40,12 PIXEL ;
      VALID ( EVAL( bSum ), oLbx:GoTop(), oDlg:Update(), .t. )
   @ 50,06 LISTBOX oLbx FIELDS                   ;
             STR(oApl:oPag:NUMFAC)              ,;
         Buscar( oApl:oPag:NUMFAC )             ,;
           aDev[ oApl:oPag:FORMAPAGO+1]         ,;
                 oApl:oPag:NUMCHEQUE            ,;
      TRANSFORM( oApl:oPag:PAGADO ,"99,999,999" );
      HEADERS "Número"+CRLF+"Factura", "Cliente", "Tipo",;
              "Nro.Documento", "Valor Nota";
      SIZES 400, 450 SIZE 280,100 ;
      OF oDlg UPDATE PIXEL        ;
      ON DBLCLICK EVAL( aBarra[2] )
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:GoTop()
    oLbx:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:nHeaderHeight := 28
    oLbx:aColSizes  := {90,200,90,90,100}
    oLbx:aHjustify  := {2,2,2,2,2}
    oLbx:aJustify   := {0,0,0,0,1}
    oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE, ( oGet[1]:SetFocus() ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(aBarra[1]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, EVAL(aBarra[2]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, EVAL(aBarra[4]),) ))) }
    oLbx:ladjbrowse  := oLbx:lCellStyle  := .f.
    oLbx:ladjlastcol := .t.
   MySetBrowse( oLbx, oApl:oPag )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT     ;
  (oDlg:Move(80,1), DefineBar( oDlg,oLbx,aBarra,66,18 ));
   VALID lSalir
RETURN

//------------------------------------//
STATIC PROCEDURE NotasBorra( oLbx,aNot )
   LOCAL nRecNo := oApl:oPag:RecNo()
If aNot[2] > 0
   If MsgNoYes( "Está Nota"+STR(oApl:oPag:NUMFAC),"Elimina" )
      oApl:lFam := SaldoFac( oApl:oPag:NUMFAC )
      GrabaV( oApl:oPag:NUMFAC,oApl:oPag:FORMAPAGO,-oApl:oPag:PAGADO,.t. )
      If oApl:oPag:Delete( .t.,1 )
         oApl:oPag:GoTo( nRecNo ):Read()
      EndIf
      oLbx:SetFocus() ; oLbx:Refresh()
   EndIf
EndIf
RETURN

//------------------------------------//
STATIC FUNCTION NotasEdita( oLbx,aEst,lNew )
   LOCAL oDlg, aTip := { "CREDITO","DEBITO","ANULADA" }
   LOCAL bGrabar, oGet := ARRAY(8)
   LOCAL aEd := { oApl:oPag:Recno(),"Modificando Nota" }
lNew := If( aEst[2] == 0, .t., lNew )
If lNew
   oApl:oPag:xBlank()
   bGrabar := {|| Nuevo( aEst,lNew )             ,;
                  oLbx:Refresh(), oLbx:GoBottom(),;
                  oApl:oPag:xBlanK()             ,;
                  oDlg:Update() , oDlg:SetFocus(),;
                  aEst[2] ++ }
//                  oApl:oPag:Refresh()            ,;
   aEd[2]  := "Nueva Nota"
   aEst[3] := 1
Else
   bGrabar := {|| Nuevo( aEst,lNew )             ,;
                  oApl:oPag:Go( aEd[1] ):Read()  ,;
                  oLbx:Refresh(), oDlg:End() }
   aEst[3] := oApl:oPag:FORMAPAGO - 6
   aEst[4] := oApl:oPag:NUMFAC
   aEst[5] := oApl:oPag:FORMAPAGO
   aEst[6] := oApl:oPag:PAGADO
EndIf
oApl:nSaldo := 0

DEFINE DIALOG oDlg TITLE aEd[2] FROM 0, 0 TO 14,50
   @ 02,00 SAY "Nro.Factura" OF oDlg RIGHT PIXEL SIZE 66,10
   @ 02,70 GET oGet[1] VAR oApl:oPag:NUMFAC OF oDlg PICTURE "9999999999";
      VALID If( Buscar( oApl:oPag:NUMFAC,lNew ), ;
                ( oDlg:Update(), .t. ), .f. )    ;
      SIZE 56,12 PIXEL
   @ 16,50 SAY oGet[2] VAR oApl:oFac:CLIENTE OF oDlg PIXEL SIZE 90,12 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 30,00 SAY "Saldo Fact."  OF oDlg RIGHT PIXEL SIZE 66,8
   @ 30,70 SAY oGet[3] VAR oApl:nSaldo  OF oDlg PICTURE "99,999,999.99";
      SIZE 50,12 PIXEL UPDATE COLOR nRGB( 128,0,255 )
   @ 44,00 SAY "Tipo de Nota" OF oDlg RIGHT PIXEL SIZE 66,8
   @ 44,70 COMBOBOX oGet[4] VAR aEst[3] ITEMS aTip SIZE 68,99;
      OF oDlg PIXEL UPDATE
   @ 58,00 SAY "Nro. Docum."  OF oDlg RIGHT PIXEL SIZE 66,8
   @ 58,70 GET oGet[5] VAR oApl:oPag:NUMCHEQUE OF oDlg PICTURE "999999";
      SIZE 50,12 PIXEL UPDATE
   @ 72,00 SAY "Valor  Nota"  OF oDlg RIGHT PIXEL SIZE 66,8
   @ 72,70 GET oGet[6] VAR oApl:oPag:PAGADO OF oDlg PICTURE "99,999,999.99";
      VALID {|| If( aEst[3] == 2,                               ;
          (If( oApl:oPag:PAGADO > oApl:oFac:TOTALFAC, (MsgStop( ;
           "Monto de la nota DEBITO > Total Factura" ),.f.),.t.)),;
          (If( oApl:oPag:PAGADO > oApl:nSaldo  , (MsgStop( ;
           "Monto de la nota CREDITO > Saldo" ),.f.),.t.)) ) } ;
      SIZE 50,12 PIXEL UPDATE
   @ 88, 70 BUTTON oGet[7] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ACTION;
      (If( EMPTY(oApl:oPag:NUMFAC) .OR. oApl:oPag:PAGADO <= 0         ,;
         ( MsgStop("Imposible grabar está NOTA"), oGet[1]:SetFocus() ),;
          EVAL(bGrabar) )) PIXEL
   @ 88,120 BUTTON oGet[8] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
RETURN NIL

//------------------------------------//
STATIC FUNCTION Buscar( nFac,lNew )
   LOCAL lBuscar
lBuscar := oApl:oFac:Seek( { "optica",oApl:nEmpresa,"numfac",nFac,"tipo",oApl:Tipo } )
If lNew == nil
   lBuscar := oApl:oFac:CLIENTE
Else
   If lBuscar .AND. oApl:oFac:INDICADOR # "A"
      oApl:lFam := SaldoFac( nFac )
      oApl:oPag:PAGADO := If( lNew, oApl:nSaldo, oApl:oPag:PAGADO )
   Else
      MsgStop( If( oApl:oFac:INDICADOR == "A", "está Anulada", ;
               "NO EXISTE !!" ),"Factura" )
      lBuscar := .f.
   EndIf
EndIf
RETURN lBuscar

//------------------------------------//
STATIC FUNCTION Nuevo( aEst,lNew )
   LOCAL nPago := 0
oApl:oPag:FORMAPAGO := aEst[3]+6
If lNew
   oApl:oPag:OPTICA := oApl:nEmpresa
   oApl:oPag:TIPO   := oApl:Tipo
   oApl:oPag:FECPAG := aEst[1]
   oApl:oPag:Append( .t. )
Else
   nPago := -aEst[6] //PAGADO
   If aEst[4] # oApl:oPag:NUMFAC .OR.;
      aEst[5] # oApl:oPag:FORMAPAGO
      If aEst[4] # oApl:oPag:NUMFAC
         oApl:lFam := SaldoFac( aEst[4] )
         GrabaV( aEst[4],aEst[5],nPago,.t. )
      Else
         GrabaSal( oApl:oPag:NUMFAC,If( aEst[5] == 8, 2, 1 ),nPago )
      EndIf
      oApl:lFam := SaldoFac( oApl:oPag:NUMFAC )
      nPago     := 0
   EndIf
   oApl:oPag:Update( .t.,1 )
EndIf
nPago += oApl:oPag:PAGADO
GrabaV( oApl:oPag:NUMFAC,oApl:oPag:FORMAPAGO,nPago,.f. )
RETURN NIL

//------------------------------------//
STATIC PROCEDURE GrabaV( nNumfac,nMov,nPago,lCambia )
   LOCAL aCan := { "P",CTOD("") }, cNota := " ", nSald
   LOCAL aD := { 0,0,CTOD(""),"E","D",oApl:oPag:FECPAG }
nMov := If( nMov == 8, 2, 1 )
If lCambia
   cNota := "D"
   nSald := oApl:nSaldo + If( nMov == 2, -nPago, nPago )
Else
   nSald := oApl:nSaldo + If( nMov == 2, nPago, -nPago )
EndIf
If nSald == 0
   aCan := { "C",oApl:oPag:FECPAG }
EndIf
oApl:oFac:Seek( { "optica",oApl:nEmpresa,"numfac",nNumfac,"tipo",oApl:Tipo } )
oApl:oFac:INDICADOR := aCan[1] ; oApl:oFac:FECHACAN := aCan[2]
oApl:oFac:Update( .f.,1 )
If nPago # 0
   GrabaSal( nNumfac,nMov,nPago )
EndIf
oApl:oVen:Seek( { "optica",oApl:nEmpresa,"numfac",nNumfac,;
                  "tipo",oApl:Tipo,"indicador",cNota } )
While oApl:oPag:FORMAPAGO == 9 .AND. !oApl:oVen:EOF()
   oApl:oInv:Seek( {"codigo",oApl:oVen:CODART} )
   If oApl:oInv:MONEDA == "C" .AND. oApl:cPer # LEFT( DTOS( oApl:oPag:FECPAG ),6 )
      MsgStop( "Llamar a [EUNICE] para que le haga nuevo Código" )
      oApl:oVen:Skip(1):Read()
      oApl:oVen:xLoad()
      LOOP
   EndIf
   nSald := oApl:oVen:CANTIDAD * If( lCambia, -1, 1 )
   If lCambia
      aD := { oApl:oVen:PRECIOVEN,nNumfac,oApl:oVen:FECFAC,"V"," ",CTOD("") }
   EndIf
   oApl:oVen:INDICADOR := aD[5] ; oApl:oVen:FECDEV := aD[6]
   oApl:oVen:Update( .f.,1 )
   If oApl:oInv:GRUPO == "1"
      oApl:oInv:PVENDIDA := aD[1]; oApl:oInv:FACTUVEN  := aD[2]
      oApl:oInv:FECVENTA := aD[3]; oApl:oInv:SITUACION := aD[4]
      oApl:oInv:Update( .f.,1 )
   EndIf
   Actualiz( oApl:oVen:CODART,nSald,oApl:oPag:FECPAG,7 )
   oApl:oVen:Skip(1):Read()
   oApl:oVen:xLoad()
EndDo
RETURN

//------------------------------------//
PROCEDURE CaoLiNot()
   LOCAL oDlg, oGet := ARRAY(6), aNot := { DATE(),0,1,.f. }
DEFINE DIALOG oDlg FROM 0, 0 TO 110,370 PIXEL TITLE "Listo Notas Creditos y Debitos"
   @ 02,00 SAY "Fecha [DD.MM.AAAA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02,92 GET oGet[1] VAR aNot[1] OF oDlg SIZE 40,10 PIXEL
   @ 14,00 SAY "Documento  0 Todos" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 14,92 GET oGet[2] VAR aNot[2] OF oDlg PICTURE "9,999" SIZE 30,10 PIXEL
   @ 26,00 SAY "Pagina Inicial" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 26,92 GET oGet[3] VAR aNot[3] OF oDlg PICTURE "999"   SIZE 12,10 PIXEL;
      VALID Rango( aNot[3],1,999 )
   @ 26,110 CHECKBOX oGet[4] VAR aNot[4] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 40, 70 BUTTON oGet[5] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[5]:Disable(), ListNota( aNot ), oDlg:End() ) PIXEL
   @ 40,120 BUTTON oGet[6] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 46, 02 SAY "[CAONOTAS]" OF oDlg PIXEL SIZE 34,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
STATIC PROCEDURE ListNota( aLS )
   LOCAL aDC := { 0,0,0,"" }, aRes, hRes, cQry, nL, nK, nC
   LOCAL oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"LISTADO DE COMPROBANTES DE DIARIO",;
         "EN " + NtChr( aLS[1],"6" ),"--FACTURA- DOCUM.  F E C H A  C L I " +;
         "E N T E           D E B I T O  C R E D I T O"},aLS[4],aLS[3] )
aDC[4]:= NtChr( LEFT( DTOS(aLS[1]),6 ),"F" )
cQry := "SELECT p.numfac, p.numcheque, p.fecpag, f.cliente, p.pagado, "+;
              "p.formapago FROM cadpagos p, cadfactu f "   +;
        "WHERE p.optica = "  + LTRIM(STR(oApl:nEmpresa))   +;
         " AND p.fecpag >= " + xValToChar( aDC[4] )        +;
         " AND p.fecpag <= " + xValToChar( aLS[1] )        +;
         " AND p.tipo   = "  + xValToChar(oApl:Tipo)       +;
         " AND p.formapago >= 7"           + If( aLS[2] > 0,;
         " AND p.numcheque = " + LTRIM(STR(aLS[2])), "" )  +;
         " AND f.optica = p.optica AND f.numfac = p.numfac"+;
         " AND f.tipo = p.tipo ORDER BY p.numcheque, p.numfac"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   nK := If( aRes[6] == 8, 1, 2 )
   oRpt:Titulo( 80 )
   If oRpt:nPage >= aLS[3]
      nC := If( nK == 1, 52, 67 )
      oRpt:Say( oRpt:nL,00,STR(aRes[1]) )
      oRpt:Say( oRpt:nL,13,aRes[2] )
      oRpt:Say( oRpt:nL,18,NtChr( aRes[3],"2" ) )
      oRpt:Say( oRpt:nL,30,aRes[4],20 )
      oRpt:Say( oRpt:nL,nC,TRANSFORM(aRes[5],"99,999,999.99" ))
   EndIf
   aDC[nK] += aRes[5]
   aDC[03] ++
   oRpt:nL ++
   nL --
EndDo
MSFreeResult( hRes )
If oRpt:nPage > 0
// nK := aDC[1] - aDC[2]
   oRpt:Say( oRpt:nL++,00,REPLICATE("_",80) )
   oRpt:Say( oRpt:nL  ,13,STR(aDC[3],4) + "  TOTALES" )
   oRpt:Say( oRpt:nL  ,52,TRANSFORM(aDC[1],"99,999,999.99" ))
   oRpt:Say( oRpt:nL++,67,TRANSFORM(aDC[2],"99,999,999.99" ))
EndIf
oRpt:NewPage()
oRpt:End()
RETURN