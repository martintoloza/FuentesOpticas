// Programa.: CAODEVOL.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Devoluciones a Bodega o Traslados
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE CaoDevol()
   LOCAL oDlg, oLbx, oGet := ARRAY(10), lSalir := .f.
   LOCAL aBarra, aDev := { "" }, bEmp
   LOCAL oNi, oD := TDevol()
oD:New()
oNi := oD:oCA:oNi
oNi:oDb:xBlank()
aBarra := { {|| oD:Editar( oLbx,.t. ) }, {|| oD:Editar( oLbx,.f. ) },;
            {|| .t. }                  , {|| oD:Borrar( oLbx ) }    ,;
            {|| InoLiDev( 1,{ "1",oD:oDvc:FECHAD,oD:oDvc:FECHAD,"C" ,;
                      oApl:nUS,oD:aCab[2],"N",.f.,oApl:nTFor,.f. } ),;
                oD:aCab[2] := 0, oGet[1]:SetFocus() }    ,;
            {|| lSalir := .t., oDlg:End() } }
bEmp := {|| If( oApl:oEmp:Seek( {"localiz",oD:aCab[1]} ),;
              ( nEmpresa( .t. ),  oD:aCab[2] := 0       ,;
                oD:Grupos(), oD:oDvc:xBlank()           ,;
                oDlg:Update(), .t. )                    ,;
              (MsgStop("Esta Optica NO EXISTE"), .f.) ) }
AEVAL( oD:aCau, {|aVal| AADD( aDev, aVal[1] ) } )

DEFINE DIALOG oDlg FROM 0, 0 TO 320, 600 PIXEL;
   TITLE "Devolución a Bodega o Traslados"
   @ 16, 06 SAY "Optica"         OF oDlg RIGHT PIXEL SIZE 50,10
   @ 16, 58 GET oGet[1] VAR oD:aCab[1] OF oDlg PICTURE "@!";
      VALID EVAL( bEmp ) ;
      SIZE 21,10 PIXEL
   @ 28, 06 SAY "Nro.Devolución" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 28, 58 GET oGet[2] VAR oD:aCab[2] OF oDlg PICTURE "9999999999";
      VALID oD:Buscar( oLbx,oGet )                                 ;
      SIZE 40,10 PIXEL UPDATE
   @ 40, 06 SAY "Fecha"          OF oDlg RIGHT PIXEL SIZE 50,10
   @ 40, 58 GET oGet[3] VAR oD:oDvc:FECHAD OF oDlg ;
      VALID oD:NEW( .t. ) ;
      WHEN !oD:oDvc:lOK   ;
      SIZE 40,10 PIXEL UPDATE
   @ 16,118 GET oGet[4] VAR oD:oDvc:NOMBRE OF oDlg ;
      WHEN !oD:oDvc:lOK  ;
      SIZE 140,10 PIXEL UPDATE
   @ 28,110 SAY "% Dscto. Publico" OF oDlg RIGHT PIXEL SIZE 40,10
   @ 28,152 GET oGet[5] VAR oD:oDvc:DESPUB   OF oDlg PICTURE "999.99";
      VALID (If( Rango( oD:oDvc:DESPUB,0,100 ), .t., ;
               (MsgStop( "El Porcentaje debe ser entre 0 y 100",">>OJO<<" ), .f.)) );
      WHEN oApl:cLocal == "COC" SIZE 26,10 PIXEL UPDATE
   @ 52, 06 SAY "Nit del Proveedor" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 52, 58 BTNGET oGet[6] VAR oD:aCab[6] OF oDlg PICTURE "9999999999";
      ACTION EVAL({|| If(oNi:Mostrar(), (oD:aCab[6] := oNi:oDb:CODIGO,;
                         oGet[6]:Refresh() ),) })                     ;
      VALID EVAL( {|| If( oNi:Buscar( oD:aCab[6],"codigo",.t. )      ,;
            ( oD:aCab[14] := oNi:oDb:CODIGO_NIT, oDlg:Update()       ,;
             If( oD:oDvc:lOK .AND. oD:oDvc:CODIGO_NIT # oD:aCab[14]  ,;
               ( oD:oDvc:CODIGO_NIT := oD:aCab[14]                   ,;
                 oD:oDvc:Update( .f.,1 ), MsgInfo("HECHO EL CAMBIO") ,;
                 oGet[6]:oJump := oLbx), ) ,.t. )                    ,;
            ( MsgStop( "Este Proveedor no Existe .." ), .f. )) })     ;
      SIZE 48,10 PIXEL UPDATE  RESOURCE "BUSCAR"
   @ 52,114 SAY oGet[7] VAR oNi:oDb:NOMBRE OF oDlg PIXEL SIZE 130,10;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 28,214 SAY "Sgte. Devolución"   OF oDlg RIGHT PIXEL SIZE 46,10
   @ 28,263 SAY oGet[8] VAR oD:aCab[3] OF oDlg PIXEL SIZE  44,10 ;
      UPDATE COLOR nRGB( 255,0,0 )
   @ 40,110 SAY "Consecutivo Devolución" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 40,173 SAY oGet[9] VAR oD:oDvc:CONSEDEV OF oDlg PIXEL SIZE  44,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 40,214 SAY "Sgte. Consecutivo"  OF oDlg RIGHT PIXEL SIZE 46,10
   @ 40,263 SAY oGet[10] VAR oD:aCab[4] OF oDlg PIXEL SIZE  44,10 ;
      UPDATE COLOR nRGB( 255,0,0 )

   @ 64, 06 LISTBOX oLbx FIELDS oD:oDvd:CODIGO            ,;
                     LeerCodig( oD:oDvd:CODIGO )          ,;
                     TRANSFORM( oD:oDvd:CANTIDAD,"9,999" ),;
                          aDev[ oD:oDvd:CAUSADEV+1 ]      ,;
        ArrayValor( oApl:aOptic,STR(oD:oDvd:DESTINO,2) )  ,;
                                oD:oDvd:INDICA             ;
      HEADERS "Código"+CRLF+"Artículo", "Descripción", "Cantidad",;
              "Causa", "Traslado A", "Ind" ;
      SIZES 400, 450 SIZE 290,90 ;
      OF oDlg UPDATE PIXEL       ;
      ON DBLCLICK EVAL( aBarra[2] )
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:GoTop()
    oLbx:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:nHeaderHeight := 28
    oLbx:aColSizes   := {90,200,90,80,80,10}
    oLbx:aHjustify   := {2,2,2,2,2,2}       // .F. ó 0 => Derecha
    oLbx:aJustify    := {0,0,1,0,2,2}       // .T. ó 1 => Izquierda, 2 => Centro
    oLbx:ladjbrowse  := oLbx:lCellStyle  := .f.
    oLbx:ladjlastcol := .t.
    oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE, ( oGet[1]:SetFocus() ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=65, oD:Actual()            ,;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=82, CambiaIndica( oD:oDvd ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(aBarra[1]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, EVAL(aBarra[2]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, EVAL(aBarra[4]),) ))))) }
   MySetBrowse( oLbx,oD:oDvd )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT ;
  (oDlg:Move(80,1), DefineBar( oDlg,oLbx,aBarra ),;
   oD:aCab[5] := oDlg)       ;
   VALID lSalir
oD:oDvc:Destroy()
oD:oDvd:Destroy()
RETURN

//------------------------------------//
CLASS TDevol

 DATA aCab, aCau, nSec, oCA, oDvc, oDvd
 DATA aGrp AS ARRAY INIT { "BOD",0 }

 METHOD NEW( lOK ) Constructor
 METHOD Buscar( oLbx,oGet )
 METHOD Borrar( oLbx )
 METHOD Editar( oLbx,lNew )
 METHOD Articulo( lOk,aEd )
 METHOD SiNo( lOk,cBus )
 METHOD Grabar( oLbx,lNew )
 METHOD Devol( cCodi,nOpt,nCanti,nCDev,lSi )
 METHOD Actual( nGrup )
 METHOD Grupos()

ENDCLASS

//------------------------------------//
METHOD NEW( lOK ) CLASS TDevol
If lOK == NIL
   oApl:oEmp:Seek( {"optica",0} )
   ::aCab := { If( oApl:cLocal == "LOC", "COC", oApl:cLocal ),0,0,;
               oApl:oEmp:CONSEDEV + 1,0,0,.t.,.f.,"",0,0,0,"",0 }
   ::aCau := Buscar( { "clase","Devolucion" },"cadcausa","nombre, movto",2,"tipo" )
   ::oDvc := oApl:Abrir( "caddevoc","optica, documen",.t.,,10 )
   ::oDvd := oApl:Abrir( "caddevod","optica, documen",.t.,,100 )
   ::oDvd:Seek( {"optica",0,"documen",0} )
   ::oCA  := TInv() ; ::oCA:New( ,.f. )
Else
   If EMPTY( ::oDvc:FECHAD )
      MsgStop( "No puede ir en Blanco","FECHA" )
      lOK := .f.
   Else
      ::aCab[13] := NtChr( ::oDvc:FECHAD,"1" )
   EndIf
EndIf
RETURN lOK

//------------------------------------//
METHOD Buscar( oLbx,oGet ) CLASS TDevol
   LOCAL lSi := .f.
If Rango( ::aCab[2],0,::aCab[3] )
   If !::oDvc:Seek( {"optica",oApl:nEmpresa,"documen",::aCab[2]} ) .AND. ::aCab[2] > 0
      MsgStop( "Está Devolución NO EXISTE !!" )
   Else
      If ::oDvc:lOK .AND. ::oDvc:DOCUMEN == 0
         Guardar( "DELETE FROM caddevoc WHERE documen = 0","caddevoc" )
         ::oDvc:xBlank()
         ::oDvc:lOK := .f.
      EndIf
      If ::oDvc:lOK
         oGet[2]:oJump := oLbx
      Else
         ::oDvc:FECHAD := DATE()
         ::oDvc:CODIGO_NIT := 123
      EndIf
      oApl:oNit:Seek( {"codigo_nit",::oDvc:CODIGO_NIT} )
      ::oDvd:Seek( {"optica",oApl:nEmpresa,"documen",::aCab[2]},"secuencia",.t. )
      ::nSec := MAX( ::oDvd:SECUENCIA,::oDvd:nRowCount )
      ::aCab[06] := oApl:oNit:CODIGO
      ::aCab[13] := NtChr( ::oDvc:FECHAD,"1" )
      ::aCab[14] := ::oDvc:CODIGO_NIT
      ::aCab[05]:Update()
      oLbx:Refresh()
      lSi := .t.
   EndIf
EndIf
RETURN lSi

//------------------------------------//
METHOD Borrar( oLbx ) CLASS TDevol

If ::oDvc:lOK .AND. !CierreInv( ::oDvc:FECHAD,"DEVOLUCIONES" )
   If ::oDvd:INDICA == "B"
      MsgInfo( "Ya esta Borrado",::oDvd:CODIGO )
   ElseIf MsgNoYes( "Este Código "+::oDvd:CODIGO,"Elimina" )
      oApl:oInv:Seek( {"codigo",::oDvd:CODIGO} )
      If oApl:oInv:MONEDA == "C" .OR. !::oDvd:FACTURADO
         ::Devol( ::oDvd:CODIGO,::oDvd:DESTINO,-::oDvd:CANTIDAD,::oDvd:CAUSADEV,.t. )
         If ::oDvd:INDICA == "E"
            ::oDvd:INDICA := "B" ; ::oDvd:Update( .f.,1 )
         ElseIf ::oDvd:Delete( .t.,1 )
            oLbx:GoBottom()
         EndIf
         oLbx:SetFocus() ; oLbx:Refresh()
      EndIf
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Editar( oLbx,lNew ) CLASS TDevol
   LOCAL oDlg, aEd := { "Modificando Devolución","","",1,.f. }
   LOCAL bGrabar, oGet := ARRAY(10), oE := Self
   LOCAL nGrup := 1
// LOCAL aDev := { "CAMBIO","DEVOLUCION","DAÑO","TRASLADO","SIN COSTO","DEV.CLIENTE" }
If EMPTY( ::oDvc:FECHAD )
   MsgStop( "Devolución sin FECHA",">>> OJO <<<" )
   RETURN NIL
EndIf
lNew := If( ::oDvd:nRowCount == 0, .t., lNew )
If CierreInv( ::oDvc:FECHAD,"DEVOLUCIONES" )
   RETURN NIL
ElseIf lNew
   aEd[1]  := "Nueva Devolución"
   bGrabar := {|| aEd[4] := ::oDvd:CAUSADEV     ,;
                  ::Grabar( oLbx,lNew )         ,;
                  ::oDvd:xBlanK()               ,;
                  ::oDvd:CAUSADEV := aEd[4]     ,;
                  oDlg:Update(), oDlg:SetFocus() }
   oLbx:GoBottom() ; ::oDvd:xBlank()
ElseIf ::oDvd:INDICA == "B"
   MsgInfo( "Ya esta Borrado",::oDvd:CODIGO )
   RETURN NIL
Else
   aEd[5] := Rango( ::oDvd:CAUSADEV,6,7 )
   ::aCab[09]:= ::oDvd:CODIGO
   ::aCab[10]:= ::oDvd:DESTINO
   ::aCab[11]:= ::oDvd:CANTIDAD
   ::aCab[12]:= ::oDvd:CAUSADEV
   bGrabar := {|| ::Grabar( oLbx,lNew ), oLbx:Refresh(), oDlg:End() }
   nGrup := ASCAN( ::aGrp, {|x| x[2] == ::oDvd:DESTINO } )
EndIf
oApl:oInv:Seek( {"codigo",oE:oDvd:CODIGO} )

DEFINE DIALOG oDlg TITLE aEd[1] FROM 8,02 TO 22,50
   @ 02,00 SAY "Causa Devolución" OF oDlg RIGHT PIXEL SIZE 66,8
   @ 02,70 COMBOBOX oGet[1] VAR ::oDvd:CAUSADEV ITEMS ArrayCol( ::aCau,1 );
      VALID ( aEd[5] := Rango( ::oDvd:CAUSADEV,6,7 ), .t. );
      SIZE 68,99 OF oDlg PIXEL UPDATE
   @ 16,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 66,10
   @ 16,70 BTNGET oGet[2] VAR oE:oDvd:CODIGO OF oDlg PICTURE "999999999!!!";
      VALID If( ::Articulo( lNew,@aEd ),            ;
              ( oDlg:Update(), .t.), .f. )          ;
      SIZE 56,12 PIXEL  RESOURCE "BUSCAR"           ;
      ACTION EVAL({|| If(oE:oCA:Mostrar(), (oE:oDvd:CODIGO := oE:oCA:oDb:CODIGO,;
                        oGet[2]:Refresh(), oGet[2]:lValid(.f.)),) })
   @ 16,130 SAY oGet[3] VAR aEd[2] OF oDlg PIXEL SIZE  52,12 ;
      UPDATE COLOR nRGB( 160,19,132 )
   @ 30, 50 SAY oGet[4] VAR oApl:oInv:DESCRIP OF oDlg PIXEL SIZE 130,12 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 44, 00 SAY "Cantidad" OF oDlg RIGHT PIXEL SIZE 66,8
   @ 44, 70 GET oGet[5] VAR ::oDvd:CANTIDAD OF oDlg PICTURE "9,999";
      VALID {|| If( ::oDvd:CANTIDAD <= 0, ;
          (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>" ), .f.),;
          (If( oApl:oInv:GRUPO == "1" .AND. ::oDvd:CANTIDAD > 1,;
          (MsgStop( "En Montura la Cantidad debe ser 1","<< OJO >>" ), .f.), .t. ))) };
      SIZE 40,12 PIXEL UPDATE
   @ 58,00 SAY "Traslado A" OF oDlg RIGHT PIXEL SIZE 66,8
   @ 58,70 COMBOBOX oGet[6] VAR nGrup ITEMS ArrayCol( ::aGrp,1 );
      SIZE 44,99 OF oDlg  PIXEL UPDATE ;
      WHEN ::oDvd:CAUSADEV == 4
   @ 72,00 SAY "Nro. Factura" OF oDlg RIGHT PIXEL SIZE 66,8
   @ 72,70 GET oGet[7] VAR ::oDvd:NUMREP   OF oDlg                  ;
      VALID EVAL( {|| If( !::aCab[7], .t.                          ,;
                ( If( FVenta( ::oDvd:NUMREP,::oDvd:CODIGO,,@aEd,    ;
                            ::oDvd:CAUSADEV ), (oDlg:Update(), .t.),;
                    ( MsgStop( "Factura NO EXISTE" ), .f. ) ) )) } );
      WHEN aEd[5]  SIZE 40,12 PIXEL
   @ 70,120 SAY oGet[8] VAR aEd[3] OF oDlg PIXEL SIZE 60,16 ;
      UPDATE COLOR nRGB( 160,19,132 )
   @ 88, 70 BUTTON oGet[09] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION  ;
      (If( EMPTY(::oDvd:CODIGO) .OR. ::oDvd:CANTIDAD <= 0               ,;
         ( MsgStop("Imposible grabar este Código"), oGet[1]:SetFocus() ),;
         ( ::Actual( nGrup ), EVAL(bGrabar) ) )) PIXEL
   @ 88,120 BUTTON oGet[10] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL  ;
      ACTION ( oDlg:End() ) PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
 oLbx:SetFocus()
RETURN NIL

//------------------------------------//
METHOD Articulo( lOk,aEd ) CLASS TDevol
   LOCAL cMens, lExiste := oApl:oInv:Seek( {"codigo",::oDvd:CODIGO} )
If lExiste
   aEd[2] := If( oApl:oInv:MONEDA == "C", "CONSIGNACION",;
             If( oApl:oInv:COMPRA_D, "C.DIRECTA", "" ))
   If oApl:oInv:GRUPO == "1"
      If aEd[5] .AND. lOk
         ::oDvd:NUMREP  := oApl:oInv:FACTUVEN
      EndIf
      If !aEd[5] .AND. (lOk .OR. ::aCab[9] # ::oDvd:CODIGO)
         If Buscar( {"optica",oApl:nEmpresa,"documen",::aCab[2],"codigo",::oDvd:CODIGO,;
                     "causadev",::oDvd:CAUSADEV},"caddevod","1",8,,4 ) == 1
            MsgStop( "Está Devolución ya tiene este Código",::oDvd:CODIGO )
            RETURN .f.
         EndIf
         SaldoInv( ::oDvd:CODIGO,::aCab[13] )
      Else
         oApl:aInvme[1] := 1
      EndIf
      If oApl:aInvme[1] <= 0
         MsgStop( "hacer Devolución sin Existencia",">> NO PUEDO <<" )
         lExiste := .f.
      ElseIf ::SiNo( lOk )
         cMens := {"Activa","Vendida","Devuelta"}[AT(oApl:oInv:SITUACION,"EVD")] +;
                   " en " + ArrayValor( oApl:aOptic,STR(oApl:oInv:OPTICA,2) )
//       If oApl:lEnLinea .AND. !(::oDvd:CAUSADEV == 6 .AND. oApl:oInv:SITUACION == "V" .AND. lOk)
         If oApl:lEnLinea .AND. !(::aCau[::oDvd:CAUSADEV,2] == 7 .AND. oApl:oInv:SITUACION == "V" .AND. lOk)
            MsgStop( cMens,"Montura esta" )
            lExiste := .f.
         Else
            lExiste := MsgNoYes( cMens,"Montura esta" )
         EndIf
      EndIf
   EndIf
Else
   MsgStop( "Este Código NO EXISTE !!!",::oDvd:CODIGO )
EndIf
RETURN lExiste

//------------------------------------//
METHOD SiNo( lOk,cBus ) CLASS TDevol
   LOCAL lSi := .f.
If cBus # NIL
   oApl:oInv:Seek( {"codigo",cBus} )
EndIf
lOk := If( !lOk .AND. ::oDvd:DESTINO == oApl:oInv:OPTICA, .f., .t. )
If oApl:oInv:GRUPO    == "1" .AND. ;
  (oApl:oInv:SITUACION $ "DV" .OR. oApl:oInv:OPTICA # oApl:nEmpresa) .AND. lOk
   lSi := .t.
EndIf
RETURN lSi

//------------------------------------//
METHOD Grabar( oLbx,lNew ) CLASS TDevol
   LOCAL lSi, nDest := ::oDvd:DESTINO
If ::aCab[2] == 0
   ::oDvc:DOCUMEN := SgteNumero( "numdevol",oApl:nEmpresa,.t. )
   ::oDvc:CONSEDEV:= SgteNumero( "consedev",0,.t. )
   ::oDvc:OPTICA  := oApl:nEmpresa
   ::oDvc:CODIGO_NIT := ::aCab[14]
   ::oDvc:Append( .t. )
   ::aCab[2] := ::oDvc:DOCUMEN
   ::aCab[3] := ::aCab[2] + 1 ; ::aCab[4] := ::oDvc:CONSEDEV + 1
   ::aCab[5]:Update()
EndIf
   SaldoInv( ::oDvd:CODIGO,::aCab[13] )
If oApl:oInv:GRUPO == "6" .OR.;
  (oApl:oInv:GRUPO == "1" .AND. oApl:oInv:IDENTIF == "I" .AND. ::aCab[8])
   ::oDvd:PCOSTO := oApl:aInvme[2]
Else
   ::oDvd:PCOSTO := oApl:oInv:PCOSTO
EndIf
lSi := !::SiNo( lNew )
If lNew
   ::oDvd:OPTICA  := oApl:nEmpresa
   ::oDvd:DOCUMEN := ::aCab[2]
   ::oDvd:FECHAD  := ::oDvc:FECHAD
   ::oDvd:FECHAREP:= oApl:oInv:FECREPOS
   ::oDvd:NUMREP  := If( Rango( ::oDvd:CAUSADEV,6,7 ), ::oDvd:NUMREP, oApl:oInv:NUMREPOS )
   ::oDvd:INDICA  := If( oApl:lEnLinea, "", "E" )
   ::oDvd:SECUENCIA := ++::nSec
   ::oDvd:Append( .t. )
   ::Devol( ::oDvd:CODIGO,oApl:nEmpresa,::oDvd:CANTIDAD,::oDvd:CAUSADEV,lSi )
   PListbox( oLbx,::oDvd )
Else
   If ::oDvd:CODIGO   # ::aCab[09] .OR. ::oDvd:DESTINO  # ::aCab[10] .OR.;
      ::oDvd:CANTIDAD # ::aCab[11] .OR. ::oDvd:CAUSADEV # ::aCab[12]
      ::oDvd:DESTINO := ::aCab[10]
      lSi := !::SiNo( lNew,::aCab[09] )
      ::Devol( ::aCab[09],::aCab[10],-::aCab[11],::aCab[12],lSi )
      ::oDvd:DESTINO := nDest
      lSi := !::SiNo( lNew,::oDvd:CODIGO )
      If ::oDvd:CODIGO # ::aCab[09]
         ::oDvd:FECHAREP:= oApl:oInv:FECREPOS
         ::oDvd:NUMREP  := If( ::oDvd:CAUSADEV # 6, oApl:oInv:NUMREPOS, ::oDvd:NUMREP )
      EndIf
      If ::oDvd:INDICA == "E"
         ::oDvd:INDICA := "C"
      EndIf
      ::aCab[11] := 0
   EndIf
   ::oDvd:Update( .t.,1 )
   ::Devol( ::oDvd:CODIGO,oApl:nEmpresa,::oDvd:CANTIDAD-::aCab[11],::oDvd:CAUSADEV,lSi )
EndIf
RETURN NIL

//------------------------------------//
METHOD Devol( cCodi,nOpt,nCanti,nCDev,lSi ) CLASS TDevol
   LOCAL aDV
If nCanti # 0 .AND. LEFT( cCodi,2 ) # "05"
   aDV := { Grupos( cCodi ),Rango( nCDev,{1,5} ),.f.,"E",0,CTOD(""),0 }
   If aDV[1] == "1"
      oApl:oInv:Seek( {"codigo",cCodi} )
      aDV[3] := If( nCDev # 4 .AND. (oApl:oInv:COMPRA_D .OR. nCDev == 3 .OR.;
                                     oApl:oInv:MONEDA == "C"), .t., .f. )
      If nCanti > 0
         aDV[4] := If( nCDev == 4, "E", If( aDV[2], "V", "D" ) )
         aDV[5] := ::oDvc:DOCUMEN
         aDV[6] := ::oDvc:FECHAD
         aDV[7] := ::oDvc:DESPUB
      EndIf
      If Rango( nCDev,6,7 )
         FVenta( ::oDvd:NUMREP,cCodi,nCanti,::oDvc:FECHAD,nCDev )
      ElseIf oApl:nEmpresa == 0 .OR. aDV[2] .OR. aDV[3]
         oApl:oInv:SITUACION := aDV[4] ; oApl:oInv:FACTUVEN  := aDV[5]
         oApl:oInv:FECVENTA  := aDV[6] ; oApl:oInv:Update( .f.,1 )
      ElseIf oApl:oInv:OPTICA == nOpt .AND. lSi
         If nCanti > 0
            oApl:oInv:OPTICA   := ::oDvd:DESTINO
            oApl:oInv:NUMREPOS := aDV[5]       ; oApl:oInv:FECREPOS := aDV[6]
         Else
            oApl:oInv:OPTICA   := oApl:nEmpresa
            oApl:oInv:NUMREPOS := ::oDvd:NUMREP; oApl:oInv:FECREPOS := ::oDvd:FECHAREP
         EndIf
         oApl:oInv:LOC_ANTES := oApl:nEmpresa  ; oApl:oInv:DESPOR   := aDV[7]
         oApl:oInv:Update( .f.,1 )
      EndIf
   EndIf
   nOpt := ::aCau[nCDev,2]            // 2=SALIDAS, 4=DEVOL_S, 7=DEVOLCLI
   Actualiz( cCodi,nCanti,::oDvc:FECHAD,nOpt,::oDvd:PCOSTO )
   If oApl:nEmpresa > 0 .AND. nOpt == 4 .AND. ::aCab[14] == 123
      If nCDev # 4 .AND. (aDV[2] .OR. aDV[3] .OR. aDV[1] == "6")
         RETURN NIL
      EndIf
      oApl:nEmpresa := ::oDvd:DESTINO
      Actualiz( cCodi,nCanti,::oDvc:FECHAD,3,If( oApl:nEmpresa # 0, ::oDvd:PCOSTO, ) )
   EndIf
      oApl:nEmpresa := ::oDvd:OPTICA
EndIf
RETURN NIL

//------------------------------------//
METHOD Actual( nGrup ) CLASS TDevol
   LOCAL cQry
If nGrup == NIL
   cQry := "UPDATE cadinven i, caddevoc c, caddevod d "       +;
           "SET i.optica = d.destino, i.fecrepos = d.fechad, "+;
               "i.numrepos = d.documen, "                     +;
               "i.loc_antes = d.optica, i.despor = c.despub " +;
           "WHERE c.optica  = " + LTRIM( STR(oApl:nEmpresa) ) +;
            " AND c.documen = " + LTRIM( STR(::aCab[2]) )     +;
            " AND d.optica  = c.optica"                       +;
            " AND d.documen = c.documen"                      +;
            " AND d.causadev = 4"          +;
            " AND LEFT(d.codigo,2) = '01'" +;
            " AND i.codigo = d.codigo"     +;
            " AND i.optica = d.optica"
   RunSql1( cQry )
Else
   If ::oDvd:CAUSADEV == 6
      If (::oDvd:DESTINO := oApl:nEmpresa) == 18
         If Buscar( {"optica",18,"numfac",::oDvd:NUMREP},"cadfactu",;
                   "autoriza",8 ) == "FOCA      "
            ::oDvd:DESTINO := 21
         EndIf
      EndIf
   Else
      ::oDvd:DESTINO := If( ::oDvd:CAUSADEV # 4, 0, ::aGrp[nGrup,2] )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Grupos() CLASS TDevol
   LOCAL aRes, hRes, cQry, nL
::aGrp := {}
cQry := "SELECT localiz, optica FROM cadempre WHERE principal = " +;
        LTRIM(STR(oApl:oEmp:PRINCIPAL))
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
WHILE nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aRes[2] # oApl:nEmpresa
      AADD( ::aGrp, { aRes[1], aRes[2] } )
   EndIf
   nL --
ENDDO
MSFreeResult( hRes )
If LEN( ::aGrp ) == 0
   AADD( ::aGrp, { "BOD",0 } )
EndIf
::aCab[3] := oApl:oEmp:NUMDEVOL + 1
::aCab[7] := If( oApl:lEnLinea .AND. oApl:cLocal == ::aCab[1], .t. , .f. )
//::aCab[8] := EMPTY( LEFT(oApl:oEmp:FACTURO,1) )
::aCab[8] := If( AT( "1",oApl:oEmp:FACTURO ) == 0, .t., .f. )
RETURN NIL

//------------------------------------//
FUNCTION FVenta( nFac,cCod,nCan,aEd,nCDev )
   LOCAL aRes, cQry, hRes, nL
If nCDev == 6
   cQry := "SELECT d.precioven, d.fecfac, c.cliente FROM cadventa d, cadfactu c "+;
           "WHERE d.codart = " + xValToChar( cCod )       +;
            " AND c.optica = d.optica"                    +;
            " AND c.numfac = d.numfac"                    +;
            " AND c.optica = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND c.numfac = " + LTRIM(STR(nFac))
Else
   cQry := "SELECT d.pcosto, c.fechad, c.nombre FROM caddevod d, caddevoc c "+;
           "WHERE d.codigo  = " + xValToChar( cCod )      +;
            " AND c.optica  = d.optica"                   +;
            " AND c.documen = d.documen"                  +;
            " AND c.optica  = "+ LTRIM(STR(oApl:nEmpresa))+;
            " AND c.documen = "+ LTRIM(STR(nFac))
EndIf
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aEd # NIL .AND. VALTYPE( aEd ) == "A"
      aEd[3] := aRes[3]
   EndIf
   If nCan # NIL
      cQry := "NULL"
      If oApl:oInv:MONEDA == "C" .AND. NtChr( aRes[2],"1" ) < NtChr( aEd,"1" )
         cQry := NtChr( aEd,"1" )
      EndIf
      If nCDev == 6 .AND. oApl:nEmpresa == 18
         If Buscar( {"optica",18,"numfac",nFac},"cadfactu",;
                   "autoriza",8 ) == "FOCA      "
            oApl:nEmpresa := 21
         EndIf
      EndIf
      aRes := If( nCan >= 1, { 0,0,CTOD(""),"E",nFac,cQry },;
                      { aRes[1],nFac,aRes[2],"V",0,"NULL" } )
      cQry := "UPDATE cadinven SET "                    +;
              "pvendida = " +  LTRIM(STR(aRes[1]))      +;
            ", factuven = " +  LTRIM(STR(aRes[2]))      +;
            ", fecventa = " + xValToChar(aRes[3])       +;
            ", situacion = "+ xValToChar(aRes[4])       +;
           " WHERE codigo = "+xValToChar(cCod)          +;
             " AND optica = "+ LTRIM(STR(oApl:nEmpresa))+;
             " AND factuven = " + LTRIM(STR(aRes[5]))
      MSQuery( oApl:oMySql:hConnect,cQry )
   EndIf
EndIf
MSFreeResult( hRes )
RETURN (nL != 0)

//------------------------------------//
FUNCTION LeerCodig( cCod )
   oApl:oInv:Seek( {"codigo",cCod} )
RETURN oApl:oInv:DESCRIP

//------------------------------------//
PROCEDURE CambiaIndica( oTB )
   LOCAL nWhe, cQry, cInd := "''"
If UPPER(oTB:cName) == "CADMONTD"
   cInd := "'A'"
EndIf
nWhe := AT( "WHERE",oTB:cStatement )
cQry := "UPDATE " + oTB:cName + " SET indica = " + cInd + ;
        SUBSTR( oTB:cStatement,nWhe-1 ) + " AND indica = 'E'"
//MsgInfo( cQry,oTB:cStatement )
RunSql1( cQry,"YA ESTA DESMARCADA" )
RETURN