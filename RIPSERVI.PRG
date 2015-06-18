// Programa.: RIPSERVI.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Creacion y Manto. de Otros Servicios
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

FUNCTION BrowseSrv()
   LOCAL oTB, oSer
 oTB := oApl:Abrir( "ridservi","fecha",.t.,,150 )
oSer := TRipser() ; oSer:New( oTB )
oSer:Activate()
oSer:Cerrar()

RETURN NIL

//------------------------------------//
CLASS TRipser FROM TNits

 DATA aTip
 DATA aHelp  INIT { ,, }

METHOD New( oTabla ) Constructor
METHOD Editar( xRec,lNuevo,lView,cCod )
METHOD Mostrar( lAyuda,nOrd )
METHOD Listado()  INLINE  Diskette( 2,::aHelp[2] )
METHOD Cerrar()

ENDCLASS

//------------------------------------//
METHOD New( oTabla ) CLASS TRipser
If oTabla # NIL
   Super:New( oTabla )
   ::aOrden := { {"<None> ",1,.f.},{"EPS"    ,4,.f.},;
                 {"Fecha"  ,8,.f.} }
   ::aTip   := ArrayCombo( "TIPOSRV   " )
   ::aHelp[1] := TPer() ; ::aHelp[1]:NEW()
   ::aHelp[2] := TRip() ; ::aHelp[2]:New( 2,.f. )
   ::aHelp[3] := TRip() ; ::aHelp[3]:New( 5,.f. )
Else
   ::oDb:xBlank()
   ::oDb:Read()
   ::oDb:TIPOSERV := "1"
   ::oDb:CODSERVI := "S21505"
EndIf
RETURN NIL

//------------------------------------//
METHOD Mostrar( lAyuda,nOrd ) CLASS TRipser
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

DEFINE DIALOG oDlg FROM 0, 0 TO 20, 60 TITLE "Mantenimiento Datos Otros Servicios"
   @ 1.5,.5 LISTBOX ::oLbx FIELDS     ;
             NtChr( ::oDb:FECHA,"2" ),;
                    ::oDb:CODADMIN   ,;
          Paciente( ::oDb:CODIGO_NIT),;
                    ::oDb:FACTURA     ;
      HEADERS "Fecha", "Código ARS", "Paciente", "Nro.Factura";
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
                               If(GetKeyState(VK_CONTROL) .AND. nKey=69, EVAL(::bEditar)	  	 ,;
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
METHOD Editar( xRec,lNuevo,lView,cCod ) CLASS TRipser
   LOCAL oDlgC, oDp, oAd, oPc, oE := Self
   LOCAL bGrabar, aH := ARRAY(5), oGet := ARRAY(13)
oDp := ::aHelp[1] // His
oAd := ::aHelp[2] // Ars
oPc := ::aHelp[3] // ClPro
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
   aH[3] := Paciente( ::oDb:CODIGO_NIT )
   cCod  := ::oDb:CODADMIN
   oDp:xVar:= oApl:oHis:NROIDEN
EndIf
aH[1] := ArrayValor( ::aTip,::oDb:TIPOSERV ,{|xV|::oDb:TIPOSERV := xV},.t. )
aH[5] := {|| If( oDp:Mostrar( ,3 ), (oDp:xVar := oDp:oDb:NROIDEN,;
                 oGet[2]:Refresh() ), .f. ) }

DEFINE DIALOG oDlgC FROM 0, 0 TO 230, 580 PIXEL;
   TITLE "Datos de Otros Servicios"
   @ 02, 00 SAY "Administradora - EPS" OF oDlgC RIGHT PIXEL SIZE 62,10
   @ 02, 64 BTNGET oGet[01] VAR oE:oDb:CODADMIN OF oDlgC PICTURE "@!";
      ACTION EVAL({|| If(oAd:Mostrar(), (oE:oDb:CODADMIN := oAd:oDb:CODIGO,;
                         oGet[01]:Refresh() ), ) })                        ;
      VALID EVAL( {|| If( oAd:oDb:Seek( {"codigo",oE:oDb:CODADMIN} )      ,;
                        ( aH[2] := oAd:oDb:NOMBRE, oDlgC:Update(), .t. )  ,;
                  (MsgStop("Esta Administradora no Existe .."),.f.) ) } )  ;
      SIZE 36,10 PIXEL  RESOURCE "BUSCAR"
    oGet[01]:cToolTip := "Ayuda de Administradoras [F2]"
   @ 02,105 SAY aH[2] OF oDlgC PIXEL SIZE 150,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 14, 00 SAY "Documento ID"       OF oDlgC RIGHT PIXEL SIZE 62,10
   @ 14, 64 BTNGET oGet[02] VAR oDp:xVar OF oDlgC               ;
      ACTION EVAL( aH[5] )                                      ;
      VALID EVAL( {|| If( oDp:oDb:Seek( {"nroiden",oDp:xVar} ) ,;
                ( ::oDb:CODIGO_NIT := oDp:oDb:CODIGO_NIT       ,;
              aH[3] := XTRIM(oDp:oDb:APELLIDOS)+oDp:oDb:NOMBRES,;
              oDlgC:Update(), .t.), (EVAL( aH[1] )) ) } )       ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"
    oGet[02]:cToolTip := "Ayuda de Afiliados [F2]"
   @ 14,125 SAY aH[3] OF oDlgC PIXEL SIZE 130,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 26, 00 SAY "Tipo de servicio" OF oDlgC RIGHT PIXEL SIZE 62,10
   @ 26, 64 COMBOBOX oGet[03] VAR aH[1] ITEMS ArrayCol( ::aTip,1 ) SIZE 68,99 ;
      OF oDlgC PIXEL
    oGet[03]:bLostFocus := {|| ::oDb:TIPOSERV := ::aTip[aH[1],2] }
   @ 38, 00 SAY "Código de Servicio" OF oDlgC RIGHT PIXEL SIZE 62,10
   @ 38, 64 BTNGET oGet[04] VAR oE:oDb:CODSERVI OF oDlgC                   ;
      ACTION EVAL({|| If(oPc:Mostrar(), (oE:oDb:CODSERVI := oPc:oDb:CODIGO,;
                         oGet[04]:Refresh() ), ) })                        ;
      VALID EVAL( {|| If( EMPTY(::oDb:CODSERVI), .t.                      ,;
                    ( If( oPc:oDb:Seek( {"codigo",oE:oDb:CODSERVI} )      ,;
                        ( oE:oDb:NOMBRE := oPc:oDb:NOMBRE                 ,;
                          oDlgC:Update(), .t. )                           ,;
                    ( MsgStop("Este Servicio no Existe .."),.f. )))) } )   ;
      SIZE 36,10 PIXEL  RESOURCE "BUSCAR"
    oGet[04]:cToolTip := "Ayuda de Servicios [F2]"
   @ 38,105    GET oGet[05] VAR ::oDb:NOMBRE   OF oDlgC PICTURE "@!";
      WHEN EMPTY(::oDb:CODSERVI) SIZE 150,10 PIXEL UPDATE
   @ 50, 00 SAY "Fecha  de Servicio" OF oDlgC RIGHT PIXEL SIZE 62,10
   @ 50, 64    GET oGet[06] VAR ::oDb:FECHA OF oDlgC ;
      SIZE 40,10 PIXEL
   @ 50,130 SAY "Factura Nro."       OF oDlgC RIGHT PIXEL SIZE 68,10
   @ 50,200    GET oGet[07] VAR ::oDb:FACTURA  OF oDlgC ;
      SIZE 40,10 PIXEL
   @ 62, 00 SAY "Cantidad de Servicios" OF oDlgC RIGHT PIXEL SIZE 62,10
   @ 62, 64    GET oGet[08] VAR ::oDb:CANTIDAD OF oDlgC PICTURE  "99,999";
      SIZE 40,10 PIXEL
   @ 74, 00 SAY "Vr.Neto Mat.e Insumo"  OF oDlgC RIGHT PIXEL SIZE 62,10
   @ 74, 64    GET oGet[09] VAR ::oDb:VALOR    OF oDlgC PICTURE "999,999,999.99";
      SIZE 40,10 PIXEL
   @ 62,130 SAY "Nro. Autorizacón"   OF oDlgC RIGHT PIXEL SIZE 68,10
   @ 62,200    GET oGet[10] VAR ::oDb:AUTORIZA OF oDlgC ;
      SIZE 40,10 PIXEL
   @ 74,130 SAY "Vr.Cta.Moderadora"  OF oDlgC RIGHT PIXEL SIZE 62,10
   @ 74,200    GET oGet[11] VAR ::oDb:VALORMOD OF oDlgC PICTURE "999,999,999.99";
      SIZE 40,10 PIXEL

   @ 88, 70 BUTTON oGet[12] PROMPT "&Grabar"   SIZE 44,12 OF oDlgC ACTION;
      (If( EMPTY(::oDb:CODADMIN) .OR. ::oDb:CODIGO_NIT == 0,;
         ( MsgStop("Imposible GRABAR este Servicio"), oGet[1]:SetFocus()),;
         ( oGet[12]:Disable(), EVAL( bGrabar ), oGet[12]:Enable() ))) PIXEL
   @ 88,120 BUTTON oGet[13] PROMPT "&Cancelar" SIZE 44,12 OF oDlgC CANCEL;
      ACTION ( oDlgC:End() ) PIXEL
   ACTIVAGET(oGet)

ACTIVATE DIALOG oDlgC CENTER
::oDb:Seek( {"codadmin",cCod} )
RETURN NIL

//------------------------------------//
METHOD Cerrar() CLASS TRipser
   LOCAL nT
::oDb:Destroy()
::aHelp[1]:NEW( "FIN" )
FOR nT := 1 TO 3
   ::aHelp[nT]:oDb:Destroy()
NEXT nT
RETURN NIL