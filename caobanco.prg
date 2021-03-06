// Programa.: CAOBANCO.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Creacion y Manto. de Bancos al Sistema
#include "Fivewin.ch"
#include "Objects.ch"

MEMVAR oApl

FUNCTION Bancos()
   LOCAL oBan := TBan()
oBan:New()
oBan:Activate()
RETURN NIL

//------------------------------------//
CLASS TBan FROM TNits

METHOD NEW( oTabla ) Constructor
METHOD Editar( xRec,lNuevo,lView )
METHOD Mostrar( lAyuda,nOrd )
METHOD Listado()

ENDCLASS

//------------------------------------//
METHOD NEW( oTabla ) CLASS TBan
   DEFAULT oTabla := oApl:oBco
Super:New(oTabla)
::aOrden := { {"<None> ",1,.f.},{"C�digo" ,2,.f.},;
              {"Nombre" ,3,.f.} }
::xVar   := "  "
RETURN NIL

//------------------------------------//
METHOD Mostrar( lAyuda,nOrd ) CLASS TBan
   LOCAL oDlg, oM := Self
   LOCAL cTit := "Ayuda de Bancos", bHacer, lReturn := NIL
DEFAULT lAyuda := .t. , nOrd := 2
If lAyuda
   bHacer  := {||lReturn :=.t., oDlg:End()}
   lReturn := .f.
ELSE
   bHacer  := ::bEditar
   cTit    := "C�digo de Bancos"
ENDIF
nOrd := ::Ordenar( nOrd )

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE cTit
   @ 1.5, 0 LISTBOX ::oLbx FIELDS ;
                    ::oDb:CODIGO ,;
         OEMTOANSI( ::oDb:NOMBRE );
      HEADERS "C�digo", "Nombre"  ;
      SIZES 400, 450 SIZE 200,107 ;
      OF oDlg UPDATE              ;
      ON DBLCLICK EVAL(bHacer)
    ::oLbx:nClrBackHead  := oApl:nClrBackHead
    ::oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    ::oLbx:nClrBackFocus := oApl:nClrBackFocus
    ::oLbx:GoTop()
    ::oLbx:nHeaderHeight := 28
    ::oLbx:oFont       := ::oFont
    ::oLbx:aColSizes   := {50,460}
    ::oLbx:aHjustify   := {2,2}
    ::oLbx:aJustify    := {.f.,.f.}
    ::oLbx:ladjbrowse  := ::oLbx:lCellStyle := .f.
    ::oLbx:ladjlastcol := .t.
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN, (Eval(bHacer)),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, Eval(::BNew),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=69, Eval(::bEditar)		 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=86, Eval(::bVer) 		         ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, Eval(::bBuscar),) )))) }
   MySetBrowse( ::oLbx, ::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT ( oM:Barra(lAyuda,oDlg) )
::oDb:Setorder(nOrd)

RETURN lReturn

//------------------------------------//
METHOD Editar(xRec,lNuevo,lView) CLASS TBan
   LOCAL oDlg, oGet := ARRAY(7)
   LOCAL aEd := { ::oDb:Recno(),"Nuevo C�digo",.f. }
DEFAULT lNuevo := .t. ,;
        lView  := .f. ,;
        xRec   :=  0
If lNuevo
   ::oDb:xBlank()
   ::oDb:Read()
Else
   aEd[2] := If( lView, "Viendo", "Modificando" ) + " C�digo"
EndIf

DEFINE DIALOG oDlg TITLE aEd[2] FROM 0, 0 TO 12,50
// COLOR RGB(0,0,0),RGB(120,180,200)
   @ 02,10 SAY "&C�digo"   OF oDlg RIGHT PIXEL SIZE 56,10
   @ 02,70 GET oGet[1] VAR ::oDb:CODIGO OF oDlg PICTURE "!!"         ;
      VALID EVAL( {|| If( EMPTY( ::oDb:CODIGO ),                     ;
                   (MsgStop("El C�digo no puede quedar vac�o"),.f.) ,;
                   (If( ::Buscar( ::oDb:CODIGO ) .AND. lNuevo       ,;
                   (MsgStop("Este C�digo ya existe"),.f.),.t.) )) } );
      SIZE 18,12 PIXEL  // WHEN lNuevo
   @ 16,10 SAY "&Nombre"   OF oDlg RIGHT PIXEL SIZE 56,10
   @ 16,70 GET oGet[2] VAR ::oDb:NOMBRE  OF oDlg PICTURE "@!";
      VALID !EMPTY(::oDb:NOMBRE)  SIZE 100,12 PIXEL
   @ 30,10 SAY "%  Debito" OF oDlg RIGHT PIXEL SIZE 56,10
   @ 30,70 GET oGet[3] VAR ::oDb:DEBITO  OF oDlg PICTURE "99.99" SIZE 24,12 PIXEL
   @ 44,10 SAY "% Credito" OF oDlg RIGHT PIXEL SIZE 56,10
   @ 44,70 GET oGet[4] VAR ::oDb:CREDITO OF oDlg PICTURE "99.99" SIZE 24,12 PIXEL
   @ 58,70 CHECKBOX oGet[5] VAR ::oDb:EN_ESPERA PROMPT "&Esperar Cheque" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 74, 60 BUTTON oGet[6] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ACTION;
      (If( EMPTY(::oDb:CODIGO) .OR. EMPTY(::oDb:NOMBRE),;
         (MsgStop("No se puede grabar este BANCO, debe completar datos"),;
          oGet[1]:SetFocus()), (aEd[3] := .t.,oDlg:End()) )) PIXEL
   @ 74,110 BUTTON oGet[7] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION (aEd[3] := .f.,oDlg:End()) PIXEL
   ACTIVAGET(oGet)
   IF lView                     // Solo Consulta
      DesactivaALLGET(oGet)
      oGet[6]:Disable()
      oGet[7]:Enable()
      oGet[7]:SetFocus()
   ENDIF
ACTIVATE DIALOG oDlg CENTER

If aEd[3]
   ::Guardar(lNuevo)
   aEd[1] := ::oDb:Recno()
Endif
::oDb:Go( aEd[1] ):Read()

RETURN NIL

//------------------------------------//
METHOD Listado() CLASS TBan
   LOCAL oRpt, nConta := 0, nReg := ::oDb:Recno()
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"LISTADO DE BANCOS","",;
          "CODIGO   NOMBRE   DEL   BANCO/TARJETA   % DEBITO  %CREDITO"},.t. )
::oDb:GoTop():Read()
::oDb:xLoad()
While !::oDb:Eof()
   oRpt:Titulo( 72 )
   oRpt:Say( oRpt:nL,02,::oDb:CODIGO )
   oRpt:Say( oRpt:nL,09,::oDb:NOMBRE )
   oRpt:Say( oRpt:nL,42,TRANSFORM( ::oDb:DEBITO ,"99.99" ))
   oRpt:Say( oRpt:nL,52,TRANSFORM( ::oDb:CREDITO,"99.99" ))
   oRpt:Say( oRpt:nL,60,If( ::oDb:EN_ESPERA, "Si", "No" ) )
   oRpt:nL ++
   nConta   ++
   ::oDb:Skip(1):Read()
   ::oDb:xLoad()
EndDo
If nConta > 0
   oRpt:Say( oRpt:nL++,10,REPLICATE("_",62) )
   oRpt:Say( oRpt:nL  ,10,"TOTAL BANCOS ESTE LISTADO...." + STR( nConta,4 ) )
EndIf
oRpt:NewPage()
oRpt:End()
::oDb:Go(nReg):Read()
::oLbx:GoTop()
::oLbx:Refresh()
RETURN NIL