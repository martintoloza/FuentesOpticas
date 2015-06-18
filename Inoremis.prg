// Programa.: INOREMIS.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Mantenimiento a Remisiones.
#include "FiveWin.ch"
#Include "btnget.ch"

MEMVAR oApl

PROCEDURE InoRemis()
   LOCAL oDlg, oLbx, oGet := ARRAY(6), lSalir := .f.
   LOCAL aBarra, oR := TRemis()
oR:New()
aBarra := { {|| oR:Editar( oLbx,.t. ) }, {|| oR:Editar( oLbx,.f. ) },;
            {|| .t. }                   ,{|| oR:Borrar( oLbx ) }    ,;
            {|| oR:ListoRem(), oR:aCab[1] := 0, oGet[1]:SetFocus() },;
            {|| lSalir := .t., oDlg:End() } }
DEFINE DIALOG oDlg FROM 0, 0 TO 330, 580 PIXEL;
   TITLE "Remisiones a Opticas"
   @ 02, 00 SAY "Nro. de Remisión" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 02, 72 GET oGet[1] VAR oR:aCab[1] OF oDlg PICTURE "999999";
      VALID oR:Buscar( oLbx,oGet )                             ;
      SIZE 30,12 PIXEL UPDATE
   @ 02,172 SAY "Optica" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 02,236 GET oGet[2] VAR oR:aCab[2] OF oDlg PICTURE "@!"        ;
      VALID EVAL( {|| If( oApl:oEmp:Seek( {"localiz",oR:aCab[2]} ),;
                        (oR:aCab[7] := (oApl:oEmp:PRINCIPAL != 4) ,;
                         oApl:nEmpresa := oApl:oEmp:OPTICA, .t. ) ,;
                      (MsgStop("Esta Optica NO EXISTE"), .f.) ) } );
      SIZE 26,12 PIXEL UPDATE
   @ 16, 00 SAY "Fecha [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 16, 72 GET oGet[3] VAR oR:oRmc:FECHA    OF oDlg SIZE 40,12 PIXEL UPDATE
   @ 16,172 SAY "Nro. Factura"     OF oDlg RIGHT PIXEL SIZE 60,10
   @ 16,236 GET oGet[4] VAR oR:oRmc:FACTURA  OF oDlg SIZE 40,12 PIXEL UPDATE
   @ 30, 00 SAY "Paciente"         OF oDlg RIGHT PIXEL SIZE 60,10
   @ 30, 72 GET oGet[5] VAR oR:oRmc:PACIENTE OF oDlg SIZE 98,12 PIXEL UPDATE
   @ 30,236 SAY oGet[6] VAR oR:oRmc:TOTALREM OF oDlg SIZE 40,12 PIXEL UPDATE
   @ 62,06 LISTBOX oLbx FIELDS oR:oRmd:CODIGO             ,;
                    LeerCodig( oR:oRmd:CODIGO )           ,;
                    TRANSFORM( oR:oRmd:CANTIDAD,"99,999" ),;
                    TRANSFORM( oR:oRmd:PCOSTO  ,"99,999,999" ) ;
      HEADERS "Código"+CRLF+"Artículo", "Descripción", "Cantidad",;
              "Precio"+CRLF+"Costo";
      SIZES 400, 450 SIZE 280,100 ;
      OF oDlg UPDATE PIXEL        ;
      ON DBLCLICK EVAL( aBarra[2] )
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:nHeaderHeight := 28
    oLbx:GoTop()
    oLbx:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:aColSizes   := {90,220,80,100}
    oLbx:aHjustify   := {2,2,2,2}
    oLbx:aJustify    := {0,0,1,1}
    oLbx:ladjbrowse  := oLbx:lCellStyle  := .f.
    oLbx:ladjlastcol := .t.
    oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE, ( oR:aCab[1] := 0, oGet[1]:SetFocus() ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(aBarra[1]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, EVAL(aBarra[2]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, EVAL(aBarra[4]),) ))) }
   MySetBrowse( oLbx, oR:oRmd )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT         ;
  (oDlg:Move(80,1), DefineBar( oDlg,oLbx,aBarra,90,18 ),;
   oR:aCab[6] := oDlg);
   VALID lSalir
oR:oRmc:Destroy()
oR:oRmd:Destroy()
oApl:oEmp:Seek( {"optica",oR:aCab[4]} )
nEmpresa( .f. )

RETURN

//------------------------------------//
CLASS TRemis

 DATA aCab, oRmc, oRmd

 METHOD NEW() Constructor
 METHOD Buscar( oLbx,oGet )
 METHOD Borrar( oLbx )
 METHOD Editar( oLbx,lNew )
 METHOD Grabar( oLbx,lNew )
 METHOD ListoRem()

ENDCLASS

//------------------------------------//
METHOD New() CLASS TRemis

 oApl:oEmp:Seek( {"optica",0} )
 ::aCab := { 0,"COC",0,oApl:nEmpresa,TInv(),"",.f.,0,0 }
 ::oRmc := oApl:Abrir( "cadremic","remision"  ,.t.,,10 )
 ::oRmd := oApl:Abrir( "cadremid","remision",.t.,,100 )
 ::oRmd:Seek( { "remision",0 } )
 ::aCab[5]:New( ,.f. )

RETURN NIL

//------------------------------------//
METHOD Buscar( oLbx,oGet ) CLASS TRemis
   LOCAL lSi := .f.
 If !::oRmc:Seek( { "remision",::aCab[1] } ) .AND. ::aCab[1] > 0
    MsgStop( "Esta Remisión NO EXISTE !!" )
 Else
    If ::oRmc:lOK
       oApl:oEmp:Seek( {"optica",::oRmc:OPTICA} )
       ::aCab[2] := oApl:oEmp:LOCALIZ
       oApl:nEmpresa := ::oRmc:OPTICA
       oGet[1]:oJump := oLbx
    Else
       ::aCab[2] := "FPV"
       ::oRmc:FECHA := DATE()
    EndIf
    ::oRmd:Seek( { "remision",::aCab[1] } )
    ::aCab[6]:Update()
    oLbx:Refresh()
    lSi := .t.
 EndIf
RETURN lSi

//------------------------------------//
METHOD Borrar( oLbx ) CLASS TRemis
   LOCAL nCosto
If ::oRmc:TOTALREM > 0
   If MsgNoYes( "Este Código "+::oRmd:CODIGO,"Elimina" )
      nCosto := ::oRmd:CANTIDAD * ::oRmd:PCOSTO
      If ::oRmd:Delete( .t.,1 )
         ::oRmc:TOTALREM -= nCosto ; ::oRmc:Update( .f.,1 )
         oLbx:GoBottom()
      EndIf
      oLbx:SetFocus() ; oLbx:Refresh()
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Editar( oLbx,lNew ) CLASS TRemis
   LOCAL oDlg, oAr, cText := "Modificando Código"
   LOCAL oGet := ARRAY(5), oE := Self
   LOCAL bGrabar := {|| ::Grabar( oLbx,lNew ), oLbx:Refresh(), oDlg:End() }
lNew := If( ::oRmc:TOTALREM > 0, lNew, .t. )
If lNew
   cText := "Nuevo Código"
   bGrabar := {|| ::Grabar( oLbx,lNew )         ,;
                  ::oRmd:xBlank()               ,;
                  oDlg:Update(), oDlg:SetFocus() }
   oLbx:GoBottom() ; ::oRmd:xBlank()
EndIf
::aCab[8] := ::oRmd:CANTIDAD
::aCab[9] := ::oRmd:PCOSTO
oAr := ::aCab[5]
oApl:oInv:Seek( {"codigo",oE:oRmd:CODIGO} )

DEFINE DIALOG oDlg TITLE cText FROM 0, 0 TO 08,40
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 60,10
   @ 02,62 BTNGET oGet[1] VAR oE:oRmd:CODIGO OF oDlg PICTURE "999999999!!!";
      VALID EVAL( {|| If( oApl:oInv:Seek( {"codigo",oE:oRmd:CODIGO} ),;
                          ( oDlg:Update(), .t. )                     ,;
                 (MsgStop( "Este Código NO EXISTE !!!" ), .f. )) } )  ;
      SIZE 56,12 PIXEL  RESOURCE "BUSCAR"                             ;
      ACTION EVAL({|| If(oAr:Mostrar(), (oE:oRmd:CODIGO := oAr:oDb:CODIGO,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 16,30 SAY oGet[2] VAR oApl:oInv:DESCRIP OF oDlg PIXEL SIZE 100,12;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 30,00 SAY "Cantidad" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 30,62 GET oGet[3] VAR ::oRmd:CANTIDAD OF oDlg PICTURE "9,999";
      VALID {|| If( ::oRmd:CANTIDAD >  0, .t.                       ,;
        (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>" ), .f.)) };
      WHEN LEFT( ::oRmd:CODIGO,2 ) # "01" SIZE 40,12 PIXEL UPDATE
   @ 46, 50 BUTTON oGet[4] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION ;
      (If( EMPTY(::oRmd:CODIGO) .OR. ::oRmd:CANTIDAD <= 0       ,;
         (MsgStop("Imposible grabar este Código"), oGet[1]:SetFocus()),;
          EVAL(bGrabar) )) PIXEL
   @ 46,100 BUTTON oGet[5] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(260,230)
RETURN NIL

//------------------------------------//
METHOD Grabar( oLbx,lNew ) CLASS TRemis
   LOCAL nCosto := 0
If ::aCab[1] == 0
   ::oRmc:OPTICA := oApl:nEmpresa
   ::oRmc:Append( .t. )
   ::aCab[1] := ::oRmc:REMISION
EndIf
::oRmd:PCOSTO := oApl:oInv:PCOSTO
If lNew
   ::oRmd:REMISION := ::aCab[1]
   ::oRmd:Append( .t. )
   PListbox( oLbx,::oRmd )
Else
   nCosto := ::aCab[8] * ::aCab[9]
   ::oRmd:Update( .t.,1 )
EndIf
::oRmc:TOTALREM += (::oRmd:CANTIDAD * ::oRmd:PCOSTO - nCosto)
::oRmc:Update( .f.,1 )
::aCab[6]:Update()
RETURN NIL

//------------------------------------//
METHOD ListoRem() CLASS TRemis
   LOCAL oRpt, nValor, cPict := "99,999,999"
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,,.f.,,,33,33 )
oRpt:nL := 12
oRpt:nPage := 1
oRpt:Say( 01,06,"CENTRO OPTICO DE" )
oRpt:Say( 02,06," LA COSTA LTDA." )
oRpt:Say( 02,50,"REMISION No. " + STRZERO(::oRmc:REMISION) )
oRpt:Say( 04,06,"OPTICA : " + oApl:oEmp:NOMBRE )
oRpt:Say( 05,06," FECHA : " + NtChr( ::oRmc:FECHA,"2" ) )
oRpt:Say( 06,04,"PACIENTE : " + ::oRmc:PACIENTE )
oRpt:Say( 07,02,"FACTURA No.: " + STR( ::oRmc:FACTURA ) )
oRpt:Say( 09,00,REPLICATE( "-",68 ) )
oRpt:Say( 10,00,"C O D I G O   P R O D U C T O                      CANT   T O T A L" )
oRpt:Say( 11,00,REPLICATE( "-",68 ) )
::oRmd:GoTop():Read()
::oRmd:xLoad()
While !::oRmd:Eof()
   nValor := ::oRmd:PCOSTO * ::oRmd:CANTIDAD
   oApl:oInv:Seek( {"codigo",::oRmd:CODIGO} )
   oRpt:Say( oRpt:nL,01,::oRmd:CODIGO )
   oRpt:Say( oRpt:nL,15,oApl:oInv:DESCRIP )
   oRpt:Say( oRpt:nL,52,TRANSFORM(::oRmd:CANTIDAD,"9999" ) )
   oRpt:Say( oRpt:nL,58,TRANSFORM( nValor,cPict ) )
   oRpt:nL++
   ::oRmd:Skip(1):Read()
   ::oRmd:xLoad()
EndDo
oRpt:Say( 23,01,REPLICATE( "=",68 ) )
oRpt:Say( 24,40,"TOTAL REMISION ==>"+ TRANSFORM( ::oRmc:TOTALREM,cPict ) )
oRpt:Say( 25,01,REPLICATE( "=",68 ) )
oRpt:NewPage()
oRpt:End()
RETURN NIL