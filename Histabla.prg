// Programa.: HISTABLA.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Creacion y Manto. de Codigos Varios
#include "Fivewin.ch"
//#include "Report.ch"

MEMVAR oApl

FUNCTION BrowseVarios( nX )
   LOCAL oRip := TVar()
 oRip:New( nX )
 oRip:Activate()
 oRip:oDb:Destroy()
RETURN NIL

//------------------------------------//
CLASS TVar FROM TNits

 DATA aTip  INIT { "Antecedentes","Motivos Consulta","Examen Externo",;
                   "Otros Examenes","Doctores" }
 DATA nTip

 METHOD NEW( nRip,lDel ) Constructor
 METHOD Editar()
 METHOD Mostrar()
 METHOD Listado()
ENDCLASS

//------------------------------------//
METHOD NEW( nRip,lDel ) CLASS TVar
// LOCAL oTabla //:= oApl:oMot
   LOCAL oTabla
   DEFAULT nRip := 1
   oTabla := oApl:Abrir( "hisvaria","tipo",,,50 )
oTabla:cWhere := "tipo = " + STRZERO(nRip,2)
Super:New( oTabla,lDel )

::aOrden := { {"<None> ",1,.f.},{"Nombre" ,"descripcio",.f.} }
::nTip   := nRip

RETURN NIL

//------------------------------------//
METHOD Mostrar( lAyuda,nOrd ) CLASS TVar
   LOCAL oDlg, oM := Self
   LOCAL cTit := ::aTip[::nTip], bHacer, lReturn := NIL
   DEFAULT lAyuda := .t. , nOrd := 2
If lAyuda
   bHacer  := {||lReturn :=.t., oDlg:End()}
   cTit    := "Ayuda de " + ::aTip[::nTip]
   lReturn := .f.
Else
   bHacer  := ::bEditar
EndIf
nOrd := ::Ordenar( nOrd )

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE cTit
   @ 1.5, 0 LISTBOX ::oLbx FIELDS ;
         OEMTOANSI( ::oDb:DESCRIPCIO );
      HEADERS "Descripción"  ;
      SIZES 400, 450 SIZE 200,107 ;
      OF oDlg UPDATE              ;
      ON DBLCLICK EVAL(bHacer)
    ::oLbx:nClrBackHead  := oApl:nClrBackHead
    ::oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    ::oLbx:nClrBackFocus := oApl:nClrBackFocus
    ::oLbx:GoTop()
    ::oLbx:oFont      := ::oFont
    ::oLbx:nHeaderHeight := 28
    ::oLbx:aColSizes  := {460}
    ::oLbx:aHjustify  := {2}
    ::oLbx:aJustify   := {0}
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN,                        EVAL(bHacer),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(::BNew),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=69, EVAL(::bEditar)		 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=86, EVAL(::bVer) 		         ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) )))) }
    ::oLbx:lCellStyle  := ::oLbx:ladjbrowse  := .f.
    ::oLbx:ladjlastcol := .t.
   MySetBrowse( ::oLbx, ::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT ( oM:Barra(lAyuda,oDlg) )
::oDb:Setorder( nOrd )
RETURN lReturn

//------------------------------------//
METHOD Editar(xRec,lNuevo,lView) CLASS TVar
   LOCAL oDlg, oGet := ARRAY(3)
   LOCAL aEd := { ::oDb:Recno(),"Nuevo Código",.f.,0 }
   DEFAULT lNuevo := .t. , lView  := .f.
If lNuevo
   ::oDb:xBlank()
   ::oDb:Read()
Else
   aEd[2] := If( lView, "Viendo", "Modificando" ) + " Código"
EndIf
DEFINE DIALOG oDlg TITLE aEd[2] + " // " + ::aTip[::nTip] FROM 0, 0 TO 06, 52
   @ 02,00 SAY "Descripción"  OF oDlg RIGHT PIXEL SIZE 40,10
   @ 02,42 GET oGet[1] VAR ::oDb:DESCRIPCIO OF oDlg ;
      VALID If( !EMPTY( ::oDb:DESCRIPCIO ), .t.,                ;
              (MsgStop("El Código no puede quedar vacío"),.f.) );
      SIZE 154,10 PIXEL
   @ 20,40 BUTTON oGet[2] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ;
      ACTION If( !EMPTY(::oDb:DESCRIPCIO), (aEd[3] := .t., oDlg:End()),;
               (MsgStop("Imposible grabar este registro"), oGet[1]:SetFocus()) ) PIXEL
   @ 20,90 BUTTON oGet[3] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
   If lView                     // Solo Consulta
      DesactivaALLGET(oGet)
      oGet[2]:Disable()
      oGet[3]:Enable()
      oGet[3]:SetFocus()
   EndIf
ACTIVATE DIALOG oDlg CENTERED

If aEd[3]
   ::oDb:TIPO := STRZERO(::nTip,2)
   ::Guardar( lNuevo )
   aEd[1] := ::oDb:Recno()
EndIf
::oDb:Go( aEd[1] ):Read()

RETURN NIL

//------------------------------------//
METHOD Listado() CLASS TVar
   LOCAL oRpt, aLis := { 0,::oDb:Recno() }
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"LISTADO DE "+::aTip[::nTip],;
          "","D E S C R I P C I O N"},.t.,,2 )
::oDb:GoTop():Read()
::oDb:xLoad()
While !::oDb:Eof()
   oRpt:Titulo( 72 )
   oRpt:Say( oRpt:nL,01,::oDb:DESCRIPCIO )
   oRpt:nL ++
   aLis[1] ++
   ::oDb:Skip(1):Read()
   ::oDb:xLoad()
EndDo
If aLis[1] > 0
   oRpt:Say( oRpt:nL++, 0,REPLICATE ("_",72) )
   oRpt:Say( oRpt:nL  ,10,"TOTAL ESTE LISTADO...." + STR( aLis[1],4 ) )
EndIf
oRpt:NewPage()
oRpt:End()
/*
   LOCAL oRpt, oFont1, oFont2
DEFINE FONT oFont1 NAME "Courier New" SIZE 0,-10
DEFINE FONT oFont2 NAME "Courier New" SIZE 0,-10 BOLD
REPORT oRpt ;
   TITLE ::cTitu,"",oApl:cEmpresa,"" ;
   FONT oFont1, oFont2 ;
   HEADER "Fecha: "+DTOC(DATE()),"Hora:  "+TIME() ;
   FOOTER OemtoAnsi("Página: ")+STR(oRpt:nPage,3) ;
   PREVIEW   // TO PRINTER

   COLUMN TITLE "DESCRIPCIÓN" ;
      DATA ::oDb:DESCRIPCIO
END REPORT

ACTIVATE REPORT oRpt
*/
::oDb:Go(aLis[2]):Read()
::oLbx:GoTop()
::oLbx:Refresh()
RETURN NIL
