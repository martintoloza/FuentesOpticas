// Programa.: CAOCODIG.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Creacion y Manto. de Codigos
#include "Objects.ch"
#include "Fivewin.ch"
#include "btnget.ch"

MEMVAR oApl

FUNCTION Articulos( lConsu )
   LOCAL aEst, oInv, oDlg, oLbs, oMes, oGet := ARRAY(2)
   DEFAULT lConsu := .f.
oInv := TInv()
oInv:New(,.f.)
If !lConsu
   oInv:Activate()
   RETURN NIL
EndIf
aEst := { "","","999,999","999,999,999.99" }
oMes := oApl:Abrir( "cadinvme","optica, codigo, anomes",,,30 )
oMes:Seek( { "optica",oApl:nEmpresa,"codigo",oInv:xVar,"anomes >= ","199401" },"anomes DESC" )
oApl:oInv:xBlank()
oApl:oNit:Seek( { "codigo_nit",oApl:oInv:CODIGO_NIT } )

DEFINE DIALOG oDlg RESOURCE "CODIGOS"
   REDEFINE BTNGET oGet[1] VAR oInv:xVar ID  1 OF oDlg RESOURCE "BUSCAR"     ;
      ACTION EVAL({|| If(oInv:Mostrar(), (oInv:xVar := oInv:oDb:CODIGO      ,;
                      oGet[1]:Refresh(), oGet[1]:lValid(.f.)),) })           ;
      VALID( If( BuscaCod( oInv,oMes,@aEst ), (oLbs:Refresh(), oDlg:Update(),;
                 oLbs:GoTop(), oGet[1]:oJump := oLbs, .t. ), .f. ))
//               oLbs:GoBottom(), oGet[1]:oJump := oLbs, .t. ), .f. ))
   REDEFINE SAY VAR oApl:oInv:DESCRIP   ID  2 OF oDlg UPDATE
   REDEFINE SAY VAR aEst[1]             ID  4 OF oDlg UPDATE
   REDEFINE SAY VAR oApl:oNit:CODIGO    ID  6 OF oDlg PICTURE "9999999999" UPDATE
   REDEFINE SAY VAR aEst[2]             ID  7 OF oDlg UPDATE
   REDEFINE SAY VAR oApl:oInv:SITUACION ID  9 OF oDlg UPDATE
   REDEFINE SAY VAR oApl:oInv:PCOSTO    ID 11 OF oDlg PICTURE aEst[4] UPDATE
   REDEFINE SAY VAR oApl:oInv:PVENTA    ID 13 OF oDlg PICTURE aEst[4] UPDATE
   REDEFINE SAY VAR oApl:oInv:PPUBLI    ID 15 OF oDlg PICTURE aEst[4] UPDATE
   REDEFINE SAY VAR oApl:oInv:NUMREPOS  ID 17 OF oDlg UPDATE
   REDEFINE SAY VAR oApl:oInv:FECREPOS  ID 19 OF oDlg UPDATE
   REDEFINE SAY VAR oApl:oInv:FACTUVEN  ID 21 OF oDlg UPDATE
   REDEFINE SAY VAR oApl:oInv:FECVENTA  ID 23 OF oDlg UPDATE
   REDEFINE SAY VAR oApl:oInv:PVENDIDA  ID 25 OF oDlg PICTURE aEst[4] UPDATE

   REDEFINE LISTBOX oLbs FIELDS           ;
                 oMes:ANOMES             ,;
      TRANSFORM( oMes:EXISTENCIA,aEst[3]),;
      TRANSFORM( oMes:ENTRADAS  ,aEst[3]),;
      TRANSFORM( oMes:SALIDAS   ,aEst[3]),;
      TRANSFORM( oMes:AJUSTES_E ,aEst[3]),;
      TRANSFORM( oMes:AJUSTES_S ,aEst[3]),;
      TRANSFORM( oMes:DEVOL_E   ,aEst[3]),;
      TRANSFORM( oMes:DEVOL_S   ,aEst[3]),;
      TRANSFORM( oMes:DEVOLCLI  ,aEst[3]),;
      TRANSFORM( oMes:PCOSTO    ,aEst[4]) ;
      ID 26 OF oDlg UPDATE                ;
      HEADERS "AñoMes", "Existencia", "Entradas", "Salidas"     ,;
              "Ajustes"+CRLF+"Entradas","Ajustes"+CRLF+"Salidas",;
              "Devoluc"+CRLF+"Entradas","Devoluc"+CRLF+"Salidas",;
              "Devoluc"+CRLF+"Cliente" ,"Precio" +CRLF+"Costo"
    oLbs:nClrBackHead  := oApl:nClrBackHead
    oLbs:nClrForeHead  := oApl:nClrForeHead
    oLbs:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbs:nClrBackFocus := oApl:nClrBackFocus
    oLbs:nClrForeFocus := oApl:nClrForeFocus
    oLbs:GoTop()
    oLbs:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbs:nHeaderHeight := 28
    oLbs:aColSizes   := {50,60,60,60,60,60,54,54,54,80}
    oLbs:aHjustify   := {2,2,2,2,2,2,2,2,2,2}
    oLbs:aJustify    := {0,1,1,1,1,1,1,1,1,1}
    oLbs:ladjbrowse  := oLbs:lCellStyle  := .f.
    oLbs:ladjlastcol := .t.
    oLbs:bKeyDown := {|nKey| If(nKey == VK_F3, oInv:Extrac( oMes ),;
                             If(nKey == VK_F5, ActuSaldo( {NtChr( oMes:ANOMES,"F" ),,0,0,oMes:CODIGO,;
                                                                  oMes:PCOSTO,} ),;
                             If(nKey == VK_F7 .OR. nKey == VK_ESCAPE, (oLbs:oJump := oGet[1], oGet[1]:SetFocus()),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, Insertar(oMes,oLbs,.f.),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, Insertar(oMes,oLbs,.t.),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, DelRecord(oMes,oLbs), )))))) }
   MySetBrowse( oLbs, oMes )
   REDEFINE BUTTON oGet[02] ID 27 OF oDlg ACTION oDlg:End() CANCEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT ( oDlg:Move(80,1) );
   VALID !GetKeyState(VK_ESCAPE)
oMes:Destroy()

RETURN NIL

//------------------------------------//
STATIC FUNCTION BuscaCod( oInv,oMes,aEst )
   LOCAL lSi := oApl:oInv:Seek( {"codigo",oInv:xVar} )
If !lSi .AND. LEFT( oInv:xVar,2 ) == "01"
   oInv:xVar := STUFF( oInv:xVar,4,1,If( SUBSTR(oInv:xVar,4,1) == "1", "2", "1" ) )
   lSi := oApl:oInv:Seek( {"codigo",oInv:xVar} )
EndIf
If lSi
   oApl:oNit:Seek( { "codigo_nit",oApl:oInv:CODIGO_NIT } )
   oMes:Seek( { "optica",oApl:nEmpresa,"codigo",oInv:xVar,"anomes >= ","199401" },"anomes DESC" )
   aEst[1] := ArrayValor( oApl:aOptic,STR(oApl:oInv:Optica,2) )
   aEst[2] := oApl:oNit:NOMBRE
Else
   MsgStop( "Este Código NO EXISTE !!!" )
EndIf
RETURN lSi

//------------------------------------//
STATIC PROCEDURE Insertar( oMes,oLbx,lNew )
   LOCAL oDlg, oGet := ARRAY(14)
   LOCAL aED := { .f.,"Modificando Saldo ","###,###","999,999,999" }
If !oApl:lEnLinea .AND. oLbx # NIL
   If lNew
      aED[2] := "Nuevo Saldo "
      oMes:xBlank()
      oMes:Read()
      oMes:OPTICA := oApl:nEmpresa ; oMes:CODIGO := oApl:oInv:CODIGO
      oMes:ANOMES := oApl:cPer     ; oMes:PCOSTO := oApl:oInv:PCOSTO
   Else
      oMes:xLoad()
   EndIf
EndIf
//PICTURE aED[3];
DEFINE DIALOG oDlg TITLE aED[2]+oMes:CODIGO FROM 00,02 TO 16,50
   @ 02, 00 SAY "Año y Mes"    OF oDlg RIGHT PIXEL SIZE 46,10
   @ 02, 50 GET oGet[01] VAR oMes:ANOMES OF oDlg PICTURE "999999";
      SIZE 30,10 PIXEL
   @ 14, 00 SAY "Existencia"   OF oDlg RIGHT PIXEL SIZE 46,10
   @ 14, 50 GET oGet[02] VAR oMes:EXISTENCIA OF oDlg ;
      SIZE 30,10 PIXEL
   @ 28, 00 SAY "Entradas"     OF oDlg RIGHT PIXEL SIZE 46,10
   @ 28, 50 GET oGet[03] VAR oMes:ENTRADAS   OF oDlg ;
      SIZE 30,10 PIXEL
   @ 28, 84 SAY "Salidas"      OF oDlg RIGHT PIXEL SIZE 46,10
   @ 28,134 GET oGet[04] VAR oMes:SALIDAS    OF oDlg ;
      SIZE 30,10 PIXEL
   @ 40, 00 SAY "Sobrantes"    OF oDlg RIGHT PIXEL SIZE 46,10
   @ 40, 50 GET oGet[05] VAR oMes:AJUSTES_E  OF oDlg ;
      SIZE 30,10 PIXEL
   @ 40, 84 SAY "Faltantes"    OF oDlg RIGHT PIXEL SIZE 46,10
   @ 40,134 GET oGet[06] VAR oMes:AJUSTES_S  OF oDlg ;
      SIZE 30,10 PIXEL
   @ 52, 00 SAY "Devol_Ent"    OF oDlg RIGHT PIXEL SIZE 46,10
   @ 52, 50 GET oGet[07] VAR oMes:DEVOL_E    OF oDlg ;
      SIZE 30,10 PIXEL
   @ 52, 84 SAY "Devol_Sal"    OF oDlg RIGHT PIXEL SIZE 46,10
   @ 52,134 GET oGet[08] VAR oMes:DEVOL_S    OF oDlg ;
      SIZE 30,10 PIXEL
   @ 64, 00 SAY "Devol_Cli"    OF oDlg RIGHT PIXEL SIZE 46,10
   @ 64, 50 GET oGet[09] VAR oMes:DEVOLCLI   OF oDlg ;
      SIZE 30,10 PIXEL
   @ 64, 84 SAY "Precio Costo" OF oDlg RIGHT PIXEL SIZE 46,10
   @ 64,134 GET oGet[10] VAR oMes:PCOSTO     OF oDlg ;
      SIZE 32,10 PIXEL
   @ 76, 00 SAY "FULT_Entrada" OF oDlg RIGHT PIXEL SIZE 46,10
   @ 76, 50 GET oGet[11] VAR oMes:FEC_ULTE   OF oDlg SIZE 32,12 PIXEL
   @ 76, 84 SAY "FULT_Salida"  OF oDlg RIGHT PIXEL SIZE 46,10
   @ 76,134 GET oGet[12] VAR oMes:FEC_ULTS   OF oDlg SIZE 32,12 PIXEL

   @ 94, 60 BUTTON oGet[13] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ACTION ;
      (If( EMPTY(oMes:ANOMES) .OR. oMes:PCOSTO <= 0           ,;
         ( MsgStop("Imposible grabar este Código"), oGet[1]:SetFocus() ),;
         ( aEd[1] := .t., oDlg:End() ))) PIXEL
   @ 94,110 BUTTON oGet[14] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL ;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER;
   WHEN !oApl:lEnLinea
If aEd[1]
   If lNew
      oMes:Append(.t.)
      oLbx:Refresh()
   Else
      oMes:Update(.t.,1)
   EndIf
EndIf

RETURN

//------------------------------------//
CLASS TInv FROM TNits

DATA aGrup, aTipo, aMone, aIden, aSexo, aMate, oNi

METHOD NEW( oTabla,lDel ) Constructor
METHOD Editar( xRec,lNuevo,lView,cCod )
METHOD Extrac( oMes )
METHOD Mostrar( lAyuda,nOrd )
METHOD Listado() INLINE CaoLiPre()

ENDCLASS

//------------------------------------//
METHOD NEW( oTabla,lDel ) CLASS TInv
   DEFAULT oTabla := oApl:oInv
Super:New( oTabla,lDel )
::aOrden := { {"<None> "  ,1,.f.},{"Código"   ,3,.f.},;
              {"Nombre"   ,5,.f.},{"CódigoPro",6,.f.} }
::aGrup := ArrayCombo( "GRUPO" )
::aTipo := ArrayCombo( "TIPOM" )
::aMone := ArrayCombo( "MONEDA" )
::aIden := ArrayCombo( "IDENTIF" )
::aMate := ArrayCombo( "MATERIAL" )
::aSexo := ArrayCombo( "SEXO" )
::oNi   := TNits()
::xVar  := SPACE(12)
::oNi:New()
RETURN NIL

//------------------------------------//
METHOD Mostrar(lAyuda,nOrd) CLASS TInv
   LOCAL oDlg, oM := Self
   LOCAL cTit := "Ayuda de Artículos", bHacer, lReturn := NIL
   DEFAULT lAyuda := .t. , nOrd := 3
If lAyuda
   bHacer  := {||lReturn :=.t., oDlg:End()}
   lReturn := .f.
ELSE
   bHacer  := ::bEditar
   cTit    := "Código de Artículos"
ENDIF
nOrd := ::Ordenar( nOrd )

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 64 TITLE cTit
   @ 1.5, 0 LISTBOX ::oLbx FIELDS   ;
                    ::oDb:CODIGO    , ::oDb:DESCRIP ,;
                    ::oDb:SITUACION ,;
        ArrayValor( oApl:aOptic,STR(::oDb:Optica,2) );
      HEADERS "Código"+CRLF+"Artículo","Nombre","Estado", "Ubicación" ;
      SIZES 400, 450 SIZE 280,107  ;
      OF oDlg UPDATE               ;
      ON DBLCLICK EVAL(bHacer)
    ::oLbx:nClrBackHead  := oApl:nClrBackHead
    ::oLbx:nClrForeHead  := oApl:nClrForeHead
    ::oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    ::oLbx:nClrBackFocus := oApl:nClrBackFocus
    ::oLbx:nClrForeFocus := oApl:nClrForeFocus
    ::oLbx:GoTop()
    ::oLbx:nHeaderHeight := 28
    ::oLbx:oFont       := ::oFont
    ::oLbx:aColSizes   := {74,270,40,44}
    ::oLbx:aHjustify   := {2,2,2,2}
    ::oLbx:aJustify    := {0,0,2,2}
    ::oLbx:ladjbrowse  := ::oLbx:lCellStyle  := .f.
    ::oLbx:ladjlastcol := .t.
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey == VK_RETURN, (EVAL(bHacer)),;
                               If(nKey == VK_F5    , (::Editar( -1,.t. ),;
                                                      ::oLbx:SetFocus() , ::oLbx:Refresh() ),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, Eval(::BNew),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=69, EVAL(::bEditar)		 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=86, EVAL(::bVer) 		         ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) ))))) }
   MySetBrowse( ::oLbx, ::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT (oM:Barra(lAyuda,oDlg))
::oDb:Setorder(nOrd)

RETURN lReturn

//------------------------------------//
METHOD Editar( xRec,lNuevo,lView,cCod ) CLASS TInv
   LOCAL aEd := { "Nuevo Código",0,oApl:nEmpresa,0,0,0,.f.,"","999,999,999.99" }
   LOCAL bValid, oDlg, oGet := ARRAY(16)
   LOCAL nGrup, nTipo, nMone, nIden, nMate, nSexo
DEFAULT lNuevo := .t. ,;
        lView  := .f. ,;
        cCod   := ::xVar
If lNuevo
   If xRec == -1
      cCod := ACLONE( ::oDb:axBuffer )
      ::oDb:xBlank()
      AEval( cCod, { |x,p| ::oDb:axBuffer[p] := x },2 )
   Else
      ::oDb:xBlank()
      ::oDb:CODIGO  := cCod
   EndIf
ELSE
   aEd[8] := NtChr( oApl:dFec,"1" )
   oApl:nEmpresa := If( ::oDb:GRUPO == "1", ::oDb:OPTICA, aEd[3] )
   oApl:oMes:Seek( { "optica",oApl:nEmpresa,"codigo",::oDb:CODIGO,;
                     "anomes <= ",aEd[8] },,.f. )
   aEd[1] := If( lView, "Viendo", "Modificando" ) + " Código"
   aEd[4] := ::oDb:PCOSTO
   aEd[5] := ::oDb:PVENTA
   aEd[6] := oApl:oMes:EXISTENCIA
ENDIF
bValid := {|| If( ::Buscar( ::oDb:CODIGO )              ,;
              (MsgStop("Código ya existe .."),.f.)      ,;
              (If( LEFT( ::oDb:CODIGO,3 ) == "010", .f. ,;
              (::oDb:GRUPO := Grupos( ::oDb:CODIGO )    ,;
               nGrup := ArrayValor( ::aGrup,::oDb:GRUPO,,.t. ),;
               oDlg:Update(), .t.)))) }
::oNi:oDb:Seek( { "codigo_nit",::oDb:CODIGO_NIT } )
aEd[2]:= ::oNi:oDb:CODIGO
cCod  := ArrayValor( oApl:aOptic,STR(::oDb:OPTICA,2) )
nGrup := ArrayValor( ::aGrup,::oDb:GRUPO  ,{|xV|::oDb:GRUPO   := xV},.t. )
nIden := ArrayValor( ::aIden,::oDb:IDENTIF,{|xV|::oDb:IDENTIF := xV},.t. )
nTipo := ArrayValor( ::aTipo,::oDb:TIPOMONTU,,.t. )
nMone := ArrayValor( ::aMone,::oDb:MONEDA   ,,.t. )
nMate := ArrayValor( ::aMate,::oDb:MATERIAL ,,.t. )
nSexo := ArrayValor( ::aSexo,::oDb:SEXO     ,,.t. )
xRec  := ::oDb:INDIVA + 1

DEFINE DIALOG oDlg RESOURCE "ARTICULOS" TITLE aEd[1]
   REDEFINE GET oGet[01] VAR ::oDb:CODIGO       ID  1 OF oDlg ;
      VALID EVAL(bValid) ;
      WHEN lNuevo
   REDEFINE BTNGET oGet[02] VAR aEd[2] ID  3 OF oDlg RESOURCE "BUSCAR"  ;
      ACTION EVAL({|| If( ::oNi:Mostrar(), (aEd[2] := ::oNi:oDb:CODIGO ,;
                         oGet[02]:Refresh(), oGet[02]:lValid(.f.)), ) });
      VALID EVAL( {|| If( ::oNi:oDb:Seek( { "codigo",aEd[2] } )        ,;
                        ( oDlg:Update(), .t. )                         ,;
                        ( MsgStop("Este Proveedor no Existe .."), .f. ) ) } )
   REDEFINE SAY VAR ::oNi:oDb:NOMBRE ID  4 OF oDlg UPDATE
   REDEFINE COMBOBOX oGet[03] VAR nGrup ITEMS ArrayCol( ::aGrup,1 );
      ID  6 OF oDlg UPDATE;
      WHEN !lView .AND. nGrup > 1
    oGet[03]:bChange := {|| ::oDb:GRUPO := ::aGrup[nGrup,2] }
   REDEFINE COMBOBOX oGet[04] VAR nTipo ITEMS ArrayCol( ::aTipo,1 );
      ID  8 OF oDlg ;
      WHEN !lView .AND. nGrup == 1
    oGet[04]:bChange := {|| ::oDb:TIPOMONTU := ::aTipo[nTipo,2] }
   REDEFINE GET oGet[05] VAR ::oDb:DESCRIP ID 10 OF oDlg PICTURE "@!"
   REDEFINE RADIO oGet[6] VAR xRec         ID 12,13 OF oDlg    ;
      WHEN !lView
   REDEFINE GET oGet[07] VAR ::oDb:PAQUETE ID 15 OF oDlg PICTURE "99";
      VALID ::oDb:PAQUETE > 0
   REDEFINE GET oGet[08] VAR ::oDb:PCOSTO  ID 17 OF oDlg PICTURE aEd[9];
      VALID If( nGrup == 1 .AND. ::oDb:PCOSTO # aEd[4] ,;
                PrecioVenta(::oDb,oDlg,::oNi:oDb:GRUPO), .t. );
      WHEN nGrup > 1
   REDEFINE GET oGet[09] VAR ::oDb:PVENTA  ID 19 OF oDlg PICTURE aEd[9];
      VALID PrecioPubli( ::oDb,oDlg,lNuevo,xRec,aEd[5] ) UPDATE ;
      WHEN nGrup > 1
   REDEFINE SAY          VAR ::oDb:PPUBLI  ID 21 OF oDlg PICTURE aEd[9] UPDATE
   REDEFINE COMBOBOX oGet[10] VAR nMone ITEMS ArrayCol( ::aMone,1 );
      ID 23 OF oDlg ;
      WHEN !lView .AND. nGrup == 1
   REDEFINE COMBOBOX oGet[11] VAR nIden ITEMS ArrayCol( ::aIden,1 );
      ID 25 OF oDlg UPDATE
   REDEFINE GET oGet[12] VAR ::oDb:TAMANO  ID 27 OF oDlg ;
      WHEN !lView .AND. nGrup == 1
   REDEFINE COMBOBOX oGet[13] VAR nMate ITEMS ArrayCol( ::aMate,1 );
      ID 29 OF oDlg ;
      WHEN !lView .AND. nGrup == 1
   REDEFINE COMBOBOX oGet[14] VAR nSexo ITEMS ArrayCol( ::aSexo,1 );
      ID 31 OF oDlg ;
      WHEN !lView .AND. nGrup == 1
   REDEFINE SAY VAR ::oDb:FECRECEP  ID 33 OF oDlg
   REDEFINE SAY VAR ::oDb:INGRESO   ID 34 OF oDlg
   REDEFINE SAY VAR cCod            ID 36 OF oDlg
   REDEFINE SAY VAR ::oDb:NUMREPOS  ID 38 OF oDlg
   REDEFINE SAY VAR aEd[6]          ID 40 OF oDlg
   REDEFINE SAY VAR ::oDb:FECREPOS  ID 42 OF oDlg
   REDEFINE SAY VAR ::oDb:SITUACION ID 44 OF oDlg
   REDEFINE SAY VAR ::oDb:FACTUVEN  ID 46 OF oDlg
   REDEFINE SAY VAR ::oDb:FACTUPRO  ID 48 OF oDlg
   REDEFINE SAY VAR ::oDb:FECVENTA  ID 50 OF oDlg
   REDEFINE SAY VAR ::oDb:PVENDIDA  ID 52 OF oDlg PICTURE aEd[9]
   REDEFINE CHECKBOX ::oDb:COMPRA_D ID 53 OF oDlg

   REDEFINE BUTTON oGet[15] ID 54 OF oDlg ACTION ;
      (If( EMPTY(::oDb:CODIGO) .OR. EMPTY(::oDb:DESCRIP),;
         (MsgStop("No se puede grabar este CODIGO, debe completar datos"),;
          oGet[1]:SetFocus()), (aEd[7] := .t., oDlg:End()) ))
   REDEFINE BUTTON oGet[16] ID 55 OF oDlg CANCEL ;
      ACTION oDlg:End()
   ACTIVAGET(oGet)
   IF lView                     // Solo Consulta
      DesactivaALLGET(oGet)
      oGet[15]:Disable()
      oGet[16]:Enable()
      oGet[16]:SetFocus()
   ENDIF
ACTIVATE DIALOG oDlg CENTER
If aEd[7]
   ::oDb:CODIGO_NIT := ::oNi:oDb:CODIGO_NIT
   ::oDb:INDIVA  := xRec - 1
   ::oDb:IDENTIF := ::aIden[nIden,2]
   ::oDb:MONEDA  := ::aMone[nMone,2]
   ::oDb:MATERIAL:= ::aMate[nMate,2]
   ::oDb:SEXO    := ::aSexo[nSexo,2]
   ::Guardar(lNuevo)
   If lNuevo
      ::oDb:Seek( {"codigo",::oDb:CODIGO} )
   EndIf
/* Else
      If ::oDb:GRUPO == "1" .AND. ::oDb:PCOSTO # oApl:oMes:PCOSTO
         If aEd[8] == oApl:oMes:ANOMES
            oApl:oMes:PCOSTO := ::oDb:PCOSTO ; oApl:oMes:Update(.t.,1)
         Else
            Actualiz( ::oDb:CODIGO,1,DATE(),3,::oDb:PCOSTO )
            Actualiz( ::oDb:CODIGO,1,DATE(),4,::oDb:PCOSTO )
         EndIf
      EndIf
   EndIf*/
EndIf
oApl:nEmpresa := aEd[3]
RETURN NIL

//------------------------------------//
METHOD Extrac( oMes ) CLASS TInv
   LOCAL aEd := { oMes:CODIGO,1,2,.t.,"" }
aEd[2] := NtChr( oMes:ANOMES,"F" )
aEd[3] := CTOD( NtChr( aEd[2],"4" ) )
oApl:oWnd:SetMsg( "Extracto del Periodo "+oMes:ANOMES )
Extracto( aEd )
RETURN NIL

// 1_01 Monturas     4_04 Accesorios
// 2_05 Varios       5_02 L.Oftalmicos
// 3_03 Liquidos     6_60 L.Contacto
//------------------------------------//
FUNCTION Grupos( cCod )
    cCod := RTRIM( cCod )
 If cCod == "0502" .OR. cCod == "0503" .OR.;
    cCod == "0504" .OR. cCod == "0505" .OR. cCod == "0599000002"
    cCod := "2"
 Else
    cCod := If( LEFT( cCod,2 ) >= "50", "6", SUBSTR( cCod,2,1 ) )
 EndIf
RETURN If( cCod == "5", "2", If( cCod == "2", "5", cCod ) )

//------------------------------------//
FUNCTION PrecioVenta( oB,oDlg,lGrupo,nPV )
   LOCAL cQry, cTipo, hRes
   DEFAULT lGrupo := .f.
If !lGrupo
   If nPV == NIL .OR. nPV == 0
      cTipo := If( oB:TIPOMONTU == " ", "X", oB:TIPOMONTU )
      cQry  := "SELECT porcentaje, incremento FROM cadtabla"+;
               " WHERE tipo = '" + (cTipo)                  +;
          "' OR (costodesde <= " + LTRIM(STR(oB:PCOSTO))    +;
           " AND costohasta >= " + LTRIM(STR(oB:PCOSTO))    + ") LIMIT 1"
      hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      If MSNumRows( hRes ) > 0
         cTipo := MyReadRow( hRes )
         AEVAL( cTipo, { | xV,nP | cTipo[nP] := MyClReadCol( hRes,nP ) } )
         oB:PVENTA := ROUND( oB:PCOSTO * cTipo[1],0 ) + cTipo[2]
         oB:PVENTA := Redondear( oB:PVENTA,500,1000 )
      EndIf
      MSFreeResult( hRes )
   Else
         oB:PVENTA := nPV
   EndIf
   oDlg:Update()
EndIf
RETURN .t.

//------------------------------------//
FUNCTION PrecioPubli( oB,oDlg,lNue,nINDIVA,nPVenta )
   LOCAL nIva := 0
 If nINDIVA == 2
    If nPVenta > 0 .AND. nPVenta == oB:PVENTA
       If (nIva := oB:PPUBLI / nPVenta -1) == 0
           nIva := oApl:oEmp:PIVA / 100
       EndIf
    Else
       nIva := oApl:oEmp:PIVA / 100
    EndIf
 EndIf
 oB:PPUBLI := ROUND( oB:PVENTA * (1+nIva),0 )
 oDlg:Update()
RETURN .t.