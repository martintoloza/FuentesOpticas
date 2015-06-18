// Programa.: RIPCONSU.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Creacion y Manto. de Datos Consulta.
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

FUNCTION BrowseCon()
   LOCAL oTB, oCon
 oTB := oApl:Abrir( "ridconsu","fecha",.t.,,90 )
oCon := TRipcon() ; oCon:New( oTB )
oCon:Activate()
oCon:Cerrar()

RETURN NIL

//------------------------------------//
CLASS TRipcon FROM TNits

 DATA aFin, aExt, aDgp
 DATA aHelp  INIT { ,,,, }

METHOD New( oTabla ) Constructor
METHOD Editar( xRec,lNuevo,lView,cCod )
METHOD Mostrar( lAyuda,nOrd )
METHOD Listado()  INLINE  Diskette( 1,::aHelp[2] )
METHOD Cerrar()

ENDCLASS

//------------------------------------//
METHOD New( oTabla ) CLASS TRipcon
If oTabla # NIL
   Super:New( oTabla )
   ::aOrden := { {"<None> ",1,.f.},{"EPS"    ,4,.f.},;
                 {"Fecha"  ,6,.f.} }
   ::aFin   := ArrayCombo( "FINCONS   " )
   ::aExt   := ArrayCombo( "CAUSAEXT  " )
   ::aDgp   := ArrayCombo( "TIPODGN   " )
   ::aHelp[1] := TPer() ; ::aHelp[1]:NEW()
   ::aHelp[2] := TRip() ; ::aHelp[2]:New( 2,.f. )
   ::aHelp[3] := TRip() ; ::aHelp[3]:New( 3,.f. )
   ::aHelp[4] := TRip() ; ::aHelp[4]:New( 5,.f. )
   ::aHelp[5] := TRip() ; ::aHelp[5]:New( 6,.f. )
Else
   ::oDb:xBlank()
   ::oDb:Read()
   ::oDb:CODESPEC  := "500"
   ::oDb:CODCONS   := "890207"
   ::oDb:FINCONS   := "08"
   ::oDb:CAUSAEXTR := "15"
   ::oDb:CODDIAG   := "H521"
   ::oDb:TIPODIAG  := "1"
EndIf
RETURN NIL

//------------------------------------//
METHOD Mostrar( lAyuda,nOrd ) CLASS TRipcon
   LOCAL oDlg, oM := Self
   LOCAL bHacer, lReturn := NIL
   DEFAULT lAyuda := .t. , nOrd := 3
If lAyuda
   bHacer  := {||lReturn := ::lBuscar := .t., oDlg:End()}
   lReturn := .f.
Else
   bHacer  := ::bEditar
EndIf
   nOrd    := ::Ordenar( nOrd )

DEFINE DIALOG oDlg FROM 0, 0 TO 20, 60 TITLE "Mantenimiento Datos de Consulta"
   @ 1.5,.5 LISTBOX ::oLbx FIELDS     ;
             NtChr( ::oDb:FECHA,"2" ),;
                    ::oDb:CODADMIN   ,;
          Paciente( ::oDb:CODIGO_NIT),;
               STR( ::oDb:ORDEN )     ;
      HEADERS "Fecha", "Código ARS", "Paciente", "Orden";
      SIZES 400, 450 SIZE 228,107 ;
      OF oDlg UPDATE              ;
      ON DBLCLICK EVAL(bHacer)
    ::oLbx:nClrBackHead  := oApl:nClrBackHead
    ::oLbx:nClrForeHead  := oApl:nClrForeHead
    ::oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    ::oLbx:nClrBackFocus := oApl:nClrBackFocus
    ::oLbx:nClrForeFocus := oApl:nClrForeFocus
    ::oLbx:GoTop()
    ::oLbx:nHeaderHeight := 28
    ::oLbx:oFont       := ::oFont
    ::oLbx:aColSizes   := {70,70,240,70}
    ::oLbx:aHjustify   := {2,2,2,2}
    ::oLbx:aJustify    := {0,0,0,1}
    ::oLbx:ladjbrowse  := ::oLbx:lCellStyle  := .f.
    ::oLbx:ladjlastcol := .t.
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN, (EVAL(bHacer)),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(::BNew),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=69, EVAL(::bEditar)		   ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=86, EVAL(::bVer) 		     ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, EVAL(::bBorrar),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) ))))) }
   MySetBrowse( ::oLbx,::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT (oM:Barra(lAyuda,oDlg))

::oDb:Setorder(nOrd)

RETURN lReturn

//------------------------------------//
METHOD Editar( xRec,lNuevo,lView,cCod ) CLASS TRipcon
   LOCAL oDlgC, oDp, oAd, oEs, oPc, oDg, oE := Self
   LOCAL bGrabar, aH := ARRAY(14), oGet := ARRAY(20)
oDp := ::aHelp[1] // His
oAd := ::aHelp[2] // Ars
oEs := ::aHelp[3] // Espec
oPc := ::aHelp[4] // ClPro
oDg := ::aHelp[5] // Diagn
If lNuevo
   ::New()
   oDp:xVar:= SPACE(15)
   bGrabar := {|| cCod         := ::oDb:CODADMIN,;
                  ::oDb:OPTICA :=  oApl:nEmpresa,;
                  Guardar( ::oDb,lNuevo,.f. )   ,;
                  ::New()                       ,;
                  ::oDb:CODADMIN := cCod        ,;
                  oDlgC:Update()                ,;
                  oDlgC:SetFocus() }
Else
   bGrabar := {|| Guardar( ::oDb,lNuevo,.f. ), oDlgC:End() }
   aH[6] := Paciente( ::oDb:CODIGO_NIT )
   cCod  := ::oDb:CODADMIN
   oDp:xVar:= oApl:oHis:NROIDEN
EndIf
aH[2] := ArrayValor( ::aFin,::oDb:FINCONS  , {|xV|::oDb:FINCONS   := xV},.t. )
aH[3] := ArrayValor( ::aExt,::oDb:CAUSAEXTR, {|xV|::oDb:CAUSAEXTR := xV},.t. )
aH[4] := ArrayValor( ::aDgp,::oDb:TIPODIAG , {|xV|::oDb:TIPODIAG  := xV},.t. )
aH[1] := {|| If( oDp:Mostrar( ,3 ), (oDp:xVar := oDp:oDb:NROIDEN,;
                 oGet[4]:Refresh(), oGet[4]:lValid(.f.)), .f. ) }

DEFINE DIALOG oDlgC FROM 0, 0 TO 370, 580 PIXEL;
   TITLE "Datos de Consulta"
   @ 02, 00 SAY "Orden de Servicios" OF oDlgC RIGHT PIXEL SIZE 62,10
   @ 02, 64    GET oGet[01] VAR ::oDb:ORDEN    OF oDlgC ;
      SIZE 40,10 PIXEL
   @ 02,130 SAY "Nro. Autorizacón"   OF oDlgC RIGHT PIXEL SIZE 68,10
   @ 02,200    GET oGet[02] VAR ::oDb:AUTORIZA OF oDlgC ;
      SIZE 40,10 PIXEL
   @ 14, 00 SAY "Administradora"     OF oDlgC RIGHT PIXEL SIZE 62,10
   @ 14, 64 BTNGET oGet[03] VAR oE:oDb:CODADMIN OF oDlgC PICTURE "@!";
      ACTION EVAL({|| If(oAd:Mostrar(), (oE:oDb:CODADMIN := oAd:oDb:CODIGO,;
                         oGet[03]:Refresh() ), ) })                        ;
      VALID EVAL( {|| If( oAd:oDb:Seek( {"codigo",oE:oDb:CODADMIN} )      ,;
                        ( aH[5] := oAd:oDb:NOMBRE, oDlgC:Update(), .t. )  ,;
                  (MsgStop("Esta Administradora no Existe .."),.f.) ) } )  ;
      SIZE 36,10 PIXEL  RESOURCE "BUSCAR"
    oGet[03]:cToolTip := "Ayuda de Administradoras [F2]"
   @ 14,105 SAY aH[5] OF oDlgC PIXEL SIZE 150,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 26, 00 SAY "Documento ID"       OF oDlgC RIGHT PIXEL SIZE 62,10
   @ 26, 64 BTNGET oGet[04] VAR oDp:xVar OF oDlgC               ;
      ACTION EVAL( aH[1] )                                      ;
      VALID EVAL( {|| If( oDp:oDb:Seek( {"nroiden",oDp:xVar} ) ,;
                ( ::oDb:CODIGO_NIT := oDp:oDb:CODIGO_NIT       ,;
                  ::oDb:HRIACLIN   := oDp:oDb:NRO_HISTOR       ,;
              aH[6] := XTRIM(oDp:oDb:APELLIDOS)+oDp:oDb:NOMBRES,;
              oDlgC:Update(), .t.), (EVAL( aH[1] )) ) } )       ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"
    oGet[04]:cToolTip := "Ayuda de Afiliados [F2]"
   @ 26,125 SAY aH[6] OF oDlgC PIXEL SIZE 130,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 38, 00 SAY "Fecha Atención"     OF oDlgC RIGHT PIXEL SIZE 62,10
   @ 38, 64    GET oGet[05] VAR ::oDb:FECHA OF oDlgC ;
      SIZE 40,10 PIXEL
   // ACTION (::oDb:FECHA := MsgDate(), oGet[5]:Refresh(), oGet[5]:SetFocus() )
   // SIZE 40,10 PIXEL  RESOURCE "Calendar"
   @ 38,130 SAY "Historia Clinica"   OF oDlgC RIGHT PIXEL SIZE 68,10
   @ 38,200 SAY ::oDb:HRIACLIN       OF oDlgC PIXEL SIZE 40,10 UPDATE
   @ 50, 00 SAY "Factura Nro."       OF oDlgC RIGHT PIXEL SIZE 62,10
   @ 50, 64    GET oGet[06] VAR ::oDb:FACTURA OF oDlgC ;
      SIZE 40,10 PIXEL
   @ 62, 00 SAY "Especialidad"       OF oDlgC RIGHT PIXEL SIZE 62,10
   @ 62, 64 BTNGET oGet[07] VAR oE:oDb:CODESPEC OF oDlgC                   ;
      ACTION EVAL({|| If(oEs:Mostrar(), (oE:oDb:CODESPEC := oEs:oDb:CODIGO,;
                         oGet[07]:Refresh() ), ) })                        ;
      VALID EVAL( {|| If( oEs:oDb:Seek( {"codigo",oE:oDb:CODESPEC} )      ,;
                        ( aH[7] := oEs:oDb:NOMBRE, oDlgC:Update(), .t. )  ,;
                    (MsgStop("Está Especialidad no Existe .."),.f.) ) } )  ;
      SIZE 36,10 PIXEL  RESOURCE "BUSCAR"
    oGet[07]:cToolTip := "Ayuda de Especialidades [F2]"
   @ 62,105 SAY aH[7]                OF oDlgC PIXEL SIZE 150,10 UPDATE
   @ 74, 00 SAY "Código Consulta"    OF oDlgC RIGHT PIXEL SIZE 62,10
   @ 74, 64 BTNGET oGet[08] VAR oE:oDb:CODCONS OF oDlgC                    ;
      ACTION EVAL({|| If(oPc:Mostrar(), (oE:oDb:CODCONS := oPc:oDb:CODIGO ,;
                         oGet[08]:Refresh() ), ) })                        ;
      VALID EVAL( {|| If( oPc:oDb:Seek( {"codigo",oE:oDb:CODCONS} )       ,;
                   (::oDb:VALOR := If(lNuevo, ::oDb:VALOR, oPc:oDb:VALOR) ,;
                          aH[8] := oPc:oDb:NOMBRE, oDlgC:Update(), .t. )  ,;
                        (MsgStop("Está Consulta no Existe .."),.f.) ) } )  ;
      SIZE 36,10 PIXEL  RESOURCE "BUSCAR"
    oGet[08]:cToolTip := "Ayuda de Consultas [F2]"
   @ 74,105 SAY aH[8]                OF oDlgC PIXEL SIZE 150,10 UPDATE
   @ 86, 00 SAY "Finalidad Consulta" OF oDlgC RIGHT PIXEL SIZE 62,10
   @ 86, 64 COMBOBOX oGet[09] VAR aH[2] ITEMS ArrayCol( ::aFin,1 ) SIZE 68,99 ;
      OF oDlgC PIXEL UPDATE
    oGet[09]:bLostFocus := {|| ::oDb:FINCONS := ::aFin[aH[2],2] }
   @ 86,140 SAY "Causa Externa"      OF oDlgC RIGHT PIXEL SIZE 58,10
   @ 86,200 COMBOBOX oGet[10] VAR aH[3] ITEMS ArrayCol( ::aExt,1 ) SIZE 68,99 ;
      OF oDlgC PIXEL UPDATE
    oGet[10]:bLostFocus := {|| ::oDb:CAUSAEXTR := ::aExt[aH[3],2] }
   @ 98, 00 SAY "Cód.Diag.Principal" OF oDlgC RIGHT PIXEL SIZE 62,10
   @ 98, 64 BTNGET oGet[11] VAR oE:oDb:CODDIAG OF oDlgC                    ;
      ACTION EVAL({|| If(oDg:Mostrar(), (oE:oDb:CODDIAG  := oDg:oDb:CODIGO,;
                         oGet[11]:Refresh() ), ) })                        ;
      VALID EVAL( {|| If( oDg:oDb:Seek( {"codigo",oE:oDb:CODDIAG} )       ,;
                        ( aH[9] := oDg:oDb:NOMBRE, oDlgC:Update(), .t. )  ,;
                     (MsgStop("Este Diagnóstico no Existe .."),.f.) ) } )  ;
      SIZE 36,10 PIXEL  RESOURCE "BUSCAR"
    oGet[11]:cToolTip := "Ayuda de Diagnósticos [F2]"
   @  98,105 SAY aH[9]               OF oDlgC PIXEL SIZE 150,10 UPDATE
   @ 110, 00 SAY "Cód.Diag.Relac.1"  OF oDlgC RIGHT PIXEL SIZE 62,10
   @ 110, 64 BTNGET oGet[12] VAR oE:oDb:CODDIAG1 OF oDlgC                  ;
      ACTION EVAL({|| If(oDg:Mostrar(), (oE:oDb:CODDIAG1 := oDg:oDb:CODIGO,;
                         oGet[12]:Refresh() ), ) })                        ;
      VALID EVAL( {|| If( EMPTY(::oDb:CODDIAG1), .t.                      ,;
                    ( If( oDg:oDb:Seek( {"codigo",::oDb:CODDIAG1} )       ,;
                        ( aH[11] := oDg:oDb:NOMBRE, oDlgC:Update(), .t. ) ,;
                    (MsgStop("Este Diagnóstico no Existe .."),.f.)))) } )  ;
      SIZE 36,10 PIXEL  RESOURCE "BUSCAR"
   @ 110,105 SAY aH[11]              OF oDlgC PIXEL SIZE 150,10 UPDATE
   @ 122, 00 SAY "Cód.Diag.Relac.2"  OF oDlgC RIGHT PIXEL SIZE 62,10
   @ 122, 64 BTNGET oGet[13] VAR oE:oDb:CODDIAG2 OF oDlgC                  ;
      ACTION EVAL({|| If(oDg:Mostrar(), (oE:oDb:CODDIAG2 := oDg:oDb:CODIGO,;
                         oGet[13]:Refresh() ), ) })                        ;
      VALID EVAL( {|| If( EMPTY(::oDb:CODDIAG2), .t.                      ,;
                    ( If( oDg:oDb:Seek( {"codigo",oE:oDb:CODDIAG2} )      ,;
                        ( aH[12] := oDg:oDb:NOMBRE, oDlgC:Update(), .t. ) ,;
                    (MsgStop("Este Diagnóstico no Existe .."),.f.)))) } )  ;
      SIZE 36,10 PIXEL  RESOURCE "BUSCAR"
   @ 122,105 SAY aH[12]              OF oDlgC PIXEL SIZE 150,10 UPDATE
   @ 134, 00 SAY "Cód.Diag.Relac.3"  OF oDlgC RIGHT PIXEL SIZE 62,10
   @ 134, 64 BTNGET oGet[14] VAR oE:oDb:CODDIAG3 OF oDlgC                  ;
      ACTION EVAL({|| If(oDg:Mostrar(), (oE:oDb:CODDIAG3 := oDg:oDb:CODIGO,;
                         oGet[14]:Refresh() ), ) })                        ;
      VALID EVAL( {|| If( EMPTY(::oDb:CODDIAG3), .t.                      ,;
                    ( If( oDg:oDb:Seek( {"codigo",oE:oDb:CODDIAG3} )      ,;
                        ( aH[13] := oDg:oDb:NOMBRE, oDlgC:Update(), .t. ) ,;
                    (MsgStop("Este Diagnóstico no Existe .."),.f.)))) } )  ;
      SIZE 36,10 PIXEL  RESOURCE "BUSCAR"
   @ 134,105 SAY aH[13]                OF oDlgC PIXEL SIZE 150,10 UPDATE
   @ 146, 00 SAY "Tipo Diag.Principal" OF oDlgC RIGHT PIXEL SIZE 62,10
   @ 146, 64 COMBOBOX oGet[15] VAR aH[4] ITEMS ArrayCol( ::aDgp,1 ) SIZE 68,99 ;
      OF oDlgC PIXEL UPDATE
    oGet[15]:bLostFocus := {|| ::oDb:TIPODIAG := ::aDgp[aH[4],2] }
   @ 146,140 SAY "Valor Consulta"   OF oDlgC RIGHT PIXEL SIZE 58,10
   @ 146,200    GET oGet[16] VAR ::oDb:VALOR OF oDlgC      ;
      VALID (aH[14] := ::oDb:VALOR - ::oDb:VALORMOD       ,;
             ::oDb:VALORNET := If( aH[14] < 0, 0, aH[14] ),;
             oGet[18]:Refresh(), .t. )  SIZE 40,10 PIXEL UPDATE
   @ 158, 00 SAY "Vr.Cta.Moderadora"  OF oDlgC RIGHT PIXEL SIZE 62,10
   @ 158, 64    GET oGet[17] VAR ::oDb:VALORMOD OF oDlgC   ;
      VALID (aH[14] := ::oDb:VALOR - ::oDb:VALORMOD       ,;
             ::oDb:VALORNET := If( aH[14] < 0, 0, aH[14] ),;
             oGet[18]:Refresh(), .t. )  SIZE 40,10 PIXEL UPDATE
   @ 158,130 SAY "Valor Neto a Pagar" OF oDlgC RIGHT PIXEL SIZE 68,10
   @ 158,200    GET oGet[18] VAR ::oDb:VALORNET OF oDlgC ;
      VALID (If( oGet[19]:lActive, (oGet[18]:oJump := oGet[19],;
                 oGet[19]:SetFocus(),.t.),.f.)) ;
      SIZE 40,10 PIXEL UPDATE
   @ 172, 70 BUTTON oGet[19] PROMPT "&Grabar"   SIZE 44,12 OF oDlgC ACTION;
      (If( EMPTY(::oDb:CODADMIN) .OR. ::oDb:CODIGO_NIT == 0,;
         ( MsgStop("Imposible grabar esta Consulta"), oGet[3]:SetFocus()),;
         ( oGet[19]:Disable(), EVAL( bGrabar ), oGet[19]:Enable() ))) PIXEL
   @ 172,120 BUTTON oGet[20] PROMPT "&Cancelar" SIZE 44,12 OF oDlgC CANCEL;
      ACTION ( oDlgC:End() ) PIXEL
   ACTIVAGET(oGet)

ACTIVATE DIALOG oDlgC CENTER //ON INIT ( If(lNuevo, oGet[19]:Disable(),) )
::oDb:Seek( {"codadmin",cCod} )
RETURN NIL

//------------------------------------//
METHOD Cerrar() CLASS TRipcon
   LOCAL nT
::oDb:Destroy()
::aHelp[1]:NEW( "FIN" )
FOR nT := 1 TO 5
   ::aHelp[nT]:oDb:Destroy()
NEXT nT
RETURN NIL
/*
FUNCTION CtrlSearch(oDlg,nG,nCtl,nPos)
   LOCAL nAt := AScan( oDlg:aControls, { |oCtrl| oCtrl:lFocused } )
   DEFAULT nCtl := 0
If nCtl == 0
   MsgInfo( "nAt" + Str(nAt),"nG"+ Str(nG) )
ElseIf nAt == nCtl
   nG := nPos
EndIf
RETURN .t.
*/
//------------------------------------//
FUNCTION Paciente( nCodigo )
 oApl:oHis:Seek( {"codigo_nit",nCodigo} )
RETURN ( XTRIM(oApl:oHis:APELLIDOS) + oApl:oHis:NOMBRES )