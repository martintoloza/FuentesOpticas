// Programa.: INOINART.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Ingresa inventario de Liq., Acces. y L.Contacto
#include "FiveWin.ch"
#include "TSBrowse.ch"
#include "btnget.ch"

MEMVAR oApl

#define CLR_PINK  nRGB( 128, 150, 150)
#define CLR_NBLUE nRGB( 255, 255, 235)

FUNCTION InoinArt()
   LOCAL aBarra, oLbd, oLbx, oGet := ARRAY(8)
   LOCAL lSalir := .f., oNi, oC := TCompra()
oC:New()
aBarra := { {|| oC:Editar( oLbx,.t. ) }, {|| oC:Editar( oLbx,.f. ) },;
            {|| oC:ArmarInf() }        , {|| oC:Borrar( oLbx ) }    ,;
            {|| oC:Ajustes(),  oC:aCab[1] := 0, oGet[1]:SetFocus() },;
            {|| If( oC:aCab[15], oC:ArmarInf(), ), lSalir := .t., oC:oDlg:End() } }
oNi := oC:oCA:oNi
oNi:oDb:xBlank()

DEFINE DIALOG oC:oDlg FROM 0, 0 TO 370, 580 PIXEL;
   TITLE "Ingresos de Liquidos, Accesorios y L.Contacto"
   @ 16, 00 SAY "Nro. de Ingreso" OF oC:oDlg RIGHT PIXEL SIZE 60,10
   @ 16, 62 GET oGet[1] VAR oC:aCab[1] OF oC:oDlg PICTURE "999999";
      VALID oC:Buscar( oLbx,oGet,oLbd )                           ;
      SIZE 30,10 PIXEL UPDATE
   @ 16,100 SAY "Sgte. Ingreso" + STR( oC:aCab[4],6 ) OF oC:oDlg PIXEL SIZE 70,10;
      UPDATE COLOR nRGB( 255,0,0 )
   @ 28, 00 SAY "Optica" OF oC:oDlg RIGHT PIXEL SIZE 60,10
   @ 28, 62 GET oGet[2] VAR oC:aCab[2] OF oC:oDlg PICTURE "@!"     ;
      VALID EVAL( {|| If( oApl:oEmp:Seek( {"localiz",oC:aCab[2]} ),;
                        ( oApl:nEmpresa := oApl:oEmp:OPTICA       ,;
                          oC:CambiaOptica() , .t. )               ,;
                        (MsgStop("Esta Optica NO EXISTE"), .f.) ) } );
      WHEN oC:aPrv[2] SIZE 24,10 PIXEL UPDATE
   @ 28,114 SAY oC:aLS[5] OF oC:oDlg PIXEL SIZE 30,10;
      UPDATE COLOR nRGB( 0,128,192 )
   @ 40, 00 SAY "Nit Proveedor" OF oC:oDlg RIGHT PIXEL SIZE 60,10
   @ 40, 62 BTNGET oGet[3] VAR oC:aCab[3] OF oC:oDlg PICTURE "9999999999";
      ACTION EVAL({|| If(oNi:Mostrar( ,,oC:aCab[3] ), ( oC:aCab[3] := ;
                         oNi:oDb:CODIGO,  oGet[3]:Refresh() ),) })    ;
      VALID EVAL( {|| If( oNi:Buscar( oC:aCab[3],"codigo",.t. )      ,;
            ( oC:aCab[11] := oNi:oDb:CODIGO_NIT, oC:oDlg:Update()    ,;
             If( oC:oArc:lOK .AND. oC:oArc:CODIGO_NIT # oC:aCab[11]  ,;
               ( oC:oArc:CODIGO_NIT := oC:aCab[11]                   ,;
                 oC:oArc:Update( .f.,1 ), MsgInfo("HECHO EL CAMBIO") ,;
                 oC:aCab[15] := .t., oGet[3]:oJump := oLbx), ) ,.t. ),;
            ( MsgStop( "Este Proveedor no Existe .." ), .f. )) })     ;
      SIZE 48,10 PIXEL UPDATE  RESOURCE "BUSCAR"
   @ 40,114 SAY oGet[4] VAR oNi:oDb:NOMBRE OF oC:oDlg PIXEL SIZE 130,12;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 16,172 SAY "Fecha [DD.MM.AA]" OF oC:oDlg RIGHT PIXEL SIZE 60,10
   @ 16,236 GET oGet[5] VAR oC:oArc:FECINGRE OF oC:oDlg ;
      VALID oC:CambiaFec() ;
      WHEN oC:aPrv[2] SIZE 40,10 PIXEL UPDATE
   @ 28,172 SAY     "Nro. Factura" OF oC:oDlg RIGHT PIXEL SIZE 60,10
   @ 28,236 GET oGet[6] VAR oC:oArc:FACTURA  OF oC:oDlg ;
      VALID Facturas( oC:oArc:lOK,oC:oArc:FACTURA,oC:aCab[12],oC:oArc );
      SIZE 40,10 PIXEL UPDATE
   @ 52,172 SAY "Total Factura"    OF oC:oDlg RIGHT PIXEL SIZE 60,10
   @ 52,236 GET oGet[7] VAR oC:oArc:TOTALFAC OF oC:oDlg PICTURE "999,999,999";
      VALID( If(oC:oArc:lOK .AND. oC:oArc:TOTALFAC # oC:oArc:XColumn( 9 )   ,;
               (oC:oArc:Update( .f.,1 ) ), ), .t. ) ;
      SIZE 42,10 PIXEL UPDATE
   @ 64,122 BUTTON oGet[8] PROMPT "Dscto Condicionado" SIZE 52,12 OF oC:oDlg;
      ACTION ( oGet[8]:Disable(), oC:Dsctos( oLbd,oC:oArc:ROW_ID ),;
               oGet[8]:Enable() , oGet[8]:oJump := oLbd );
      WHEN oApl:oEmp:NIIF PIXEL
   @ 64,194 SAY "SubTotal"    OF oC:oDlg RIGHT PIXEL SIZE 40,10
   @ 64,236 SAY oC:nSub OF oC:oDlg PICTURE "999,999,999.99" PIXEL SIZE 42,10;
      UPDATE COLOR nRGB( 255,0,128 )
                     //SIZE Ancho, Alto
   @ 52.0,06 BROWSE oLbd SIZE 110,40 PIXEL OF oC:oDlg CELLED;
      COLORS CLR_BLACK, CLR_NBLUE
   oLbd:SetArray( oC:aIng )
   oLbd:nFreeze     := 1
   oLbd:nRowPos     := oLbd:nAt   := 2
   oLbd:nColPos     := oLbd:nCell := 2
   oLbd:nHeightCell += 4
   oLbd:nHeightHead += 4
   oLbd:bKeyDown := {|nKey| If( nKey== VK_TAB, oLbd:oJump := oLbx, ) }
   oLbd:SetAppendMode( .f. )

   ADD COLUMN TO BROWSE oLbd DATA ARRAY ELEMENT 2;
       TITLE "Cuenta"                            ;
       SIZE  100;
       3DLOOK TRUE, TRUE, TRUE;    // Celda, Titulo, Footers
       MOVE DT_MOVE_NEXT;          // Cursor pasa a la Sig.Columna editable
       ALIGN DT_RIGHT, DT_CENTER   // Celda, Titulo, Footer
   ADD COLUMN TO BROWSE oLbd DATA ARRAY ELEMENT 6;
       TITLE "Valor"       PICTURE "999,999,999" ;
       SIZE  94 EDITABLE;          // Esta columna es editable
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER;
       POSTEDIT { |uVar| If( oC:oArc:lOK .AND. oLbd:lChanged, (oC:aIng :=;
                             Detalles( oC:aIng,oC:aCab[1],.t. )), ) }
   oLbd:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbd:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color

   @ 96,06 LISTBOX oLbx FIELDS oC:oArd:CODIGO             ,;
                    LeerCodig( oC:oArd:CODIGO )           ,;
                    TRANSFORM( oC:oArd:CANTIDAD,"99,999" ),;
                    TRANSFORM( oC:oArd:PCOSTO  ,"99,999,999.99" ),;
                    TRANSFORM( oC:oArd:PVENTA  ,"99,999,999.99" ),;
                               oC:oArd:INDICA              ;
      HEADERS "Código"+CRLF+"Artículo", "Descripción", "Cantidad",;
              "Precio"+CRLF+"Costo", "Precio"+CRLF+"Venta", "Ind" ;
      SIZES 400, 450 SIZE 280,86  ;
      OF oC:oDlg UPDATE PIXEL     ;
      ON DBLCLICK EVAL( aBarra[2] )
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:nHeaderHeight := 28
    oLbx:GoTop()
    oLbx:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:aColSizes   := {84,200,60,86,86,10}
    oLbx:aHjustify   := {2,2,2,2,2,2}
    oLbx:aJustify    := {0,0,1,1,1,2}
    oLbx:ladjbrowse  := oLbx:lCellStyle  := .f.
    oLbx:ladjlastcol := .t.
    oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE, ( oC:aCab[1] := 0, oGet[1]:SetFocus() )    ,;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=82, CambiaIndica( oC:oArd ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(aBarra[1]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, EVAL(aBarra[2]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE             , EVAL(aBarra[4]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=80 .OR. nKey=VK_F3    , EVAL(aBarra[5]),) ))))) }
   MySetBrowse( oLbx, oC:oArd )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oC:oDlg ON INIT ;
  (oC:oDlg:Move(80,1), DefineBar( oC:oDlg,oLbx,aBarra ) );
   VALID lSalir
oC:oArc:Destroy()
oC:oArd:Destroy()
oC:oArf:Destroy()
oApl:oEmp:Seek( {"optica",oC:aCab[6]} )
nEmpresa( .f. )
ConectaOff()
RETURN NIL

//------------------------------------//
CLASS TCompra FROM TContabil

 DATA aCab, aIng, aPrv, oArc, oArd, oCA, oDlg
 DATA nSub          INIT 0
 METHOD NEW() Constructor
 METHOD Buscar( oLbx,oGet,oLbd )
 METHOD Borrar( oLbx )
 METHOD Editar( oLbx,lNew )
 METHOD Grabar( oLbx,lNew )
 METHOD CambiaFec()
 METHOD CambiaOptica()
 METHOD Ajustes()
 METHOD ArmarInf()
ENDCLASS

//------------------------------------//
METHOD New() CLASS TCompra

 oApl:oEmp:Seek( {"optica",0} )
 ::aCab := { 0,"COC",0,oApl:oEmp:NUMINGRESO +1,oApl:oEmp:PIVA / 100 +1,;
             oApl:nEmpresa,0,0,0,0,0,"",DATE(),0,.f. }
 ::aPrv := Privileg( "COMPRAS" )
 ::oArc := oApl:Abrir( "comprasc","ingreso",.t.,,10 )
 ::oArf := oApl:Abrir( "comprasf","fecha",.t.,,10 )
 ::oArd := oApl:Abrir( "cadartid","ingreso",,,100 )
 ::oArd:Seek( { "ingreso",0 } )
 ::oCA  := TInv() ; ::oCA:New( ,.f. )
 ::aLS[1] := 0
 ::aIng := { { 0,"Retención",1,0,0,0,0 },;
             { 0,"I.V.A."   ,2,0,0,0,0 },;
             { 0,"Seguro"   ,3,0,0,0,0 },;
             { 0,"Fletes"   ,4,0,0,0,0 },;
             { 0,"Ret.ICA." ,5,0,0,0,0 } }
//           { 0,"Descuento",5,0,0,0,0 } }
RETURN NIL

//------------------------------------//
METHOD Buscar( oLbx,oGet,oLbd ) CLASS TCompra
   LOCAL lSi := .f.
If VALTYPE( oGet ) == "L"
   If (lSi := oApl:oInv:Seek( {"codigo",::oArd:CODIGO} ))
      If LEFT( ::oArd:CODIGO,2 ) == "01"
         MsgStop( "Monturas no es por AQUI" )
         lSi := .f.
      ElseIf oGet
         ::oArd:CANTIDAD := oApl:oInv:PAQUETE
         ::oArd:PCOSTO   := oApl:oInv:PCOSTO
         ::oArd:PVENTA   := oApl:oInv:PVENTA
         ::oArd:INDIVA   := oApl:oInv:INDIVA
      EndIf
      oLbx:Update()
   Else
      MsgStop( "Este Código NO EXISTE !!!" )
   EndIf
ElseIf Rango( ::aCab[1],0,::aCab[4] )
   If ::aCab[15]
      ::ArmarInf()
   EndIf
   If !::oArc:Seek( { "ingreso",::aCab[1],"moneda","X" } ) .AND. ::aCab[1] > 0
      MsgStop( "Este Ingreso NO EXISTE !!" )
   Else
      If ::oArc:lOK
         oApl:oNit:Seek( {"codigo_nit",::oArc:CODIGO_NIT} )
         oApl:oEmp:Seek( {"optica",::oArc:OPTICA} )
         ::aCab[02] := ArrayValor( oApl:aOptic,STR(::oArc:OPTICA,2) )
         ::aCab[03] := oApl:oNit:CODIGO
         ::aCab[11] := ::oArc:CODIGO_NIT
         oApl:nEmpresa := ::oArc:OPTICA
         oGet[1]:oJump := oLbx
         ::nSub := Buscar( {"ingreso",::aCab[1]},"cadartid","SUM(cantidad * pcosto)" )
      Else
         ::nSub := 0
         ::oArc:FECINGRE := DATE()
      EndIf
      ::oArd:Seek( { "ingreso",::aCab[1] } )
        ::aLS[5] := ::oArc:CGECONSE
      ::aCab[07] := oApl:oEmp:PRINCIPAL
      ::aCab[12] := ::oArc:FACTURA
      ::aCab[13] := ::oArc:FECINGRE
      ::aCab[15] := !(::aLS[5] != 0)
      ::aIng     := Detalles( ::aIng,::aCab[1],.f. )
      ::oDlg:Update()
      oLbd:Refresh() ; oLbx:Refresh()
      lSi := .t.
   EndIf
EndIf
RETURN lSi

//------------------------------------//
METHOD Borrar( oLbx ) CLASS TCompra
   LOCAL aBor
If VALTYPE( oLbx ) == "D"
   If ::aLS[5] # 0 .AND. !oApl:lEnLinea
      aBor := "WHERE CODIGO_EMP  = " + LTRIM(STR(::aCab[7]))+;
               " AND ANO_MES     = " + LEFT( DTOS(oLbx),6 ) +;
               " AND CONSECUTIVO = " + LTRIM(STR(::aLS[5]))
      ConectaOn()
      oApl:oOdbc:Execute( "DELETE FROM movto_d " + aBor )
      oApl:oOdbc:Execute( "DELETE FROM movto_c " + aBor )
      ::aCab[15] := .t.
       ::aLS[5]  := 0
      ::ArmarInf()
      ::oArc:CGECONSE := ::aLS[5]
   EndIf
ElseIf !CierreInv( ::oArc:FECINGRE,"COMPRAS" )
   If ::aPrv[3] .AND. ::oArc:CONTROL > 0
      If ::oArd:INDICA == "B"
         MsgInfo( "Ya esta Borrado",::oArd:CODIGO )
      ElseIf MsgNoYes( "Este Código "+::oArd:CODIGO,"Elimina" )
         aBor := { ::oArd:CODIGO,-::oArd:CANTIDAD,::oArd:PCOSTO,.f. }
         If ::oArd:INDICA == "E"
            ::oArd:INDICA := "B"
            aBor[4] := ::oArd:Update( .f.,1 )
            oLbx:SetFocus() ; oLbx:Refresh()
         ElseIf (aBor[4] := ::oArd:Delete( .t.,1 ))
            PListbox( oLbx,::oArd )
         EndIf
         If aBor[4]
            oApl:oInv:Seek( {"codigo",aBor[1]} )
            Actualiz( aBor[1],aBor[2],::oArc:FECINGRE,1,aBor[3] )
            ::nSub += (aBor[2] * aBor[3])
         EndIf
      EndIf
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Editar( oLbx,lNew ) CLASS TCompra
   LOCAL oDlg, cTit := "Modificando Ingreso"
   LOCAL bGrabar, oGet := ARRAY(9), oE := Self
lNew := If( ::oArc:CONTROL == 0, .t., lNew )
If CierreInv( ::oArc:FECINGRE,"COMPRAS" )
   RETURN NIL
ElseIf lNew
   cTit    := "Nuevo Ingreso"
   bGrabar := {|| ::Grabar( oLbx,lNew )         ,;
                  ::oArd:xBlanK()               ,;
                  oDlg:Update(), oDlg:SetFocus() }
   oLbx:GoBottom() ; ::oArd:xBlank()
Else
   If !::aPrv[2]
      MsgStop( "Este Registro no se Puede Modificar","Lo Siento" )
      RETURN NIL
   EndIf
   bGrabar := {|| ::Grabar( oLbx,lNew ), oLbx:Refresh(), oDlg:End() }
   ::aCab[08]:= ::oArd:CODIGO
   ::aCab[09]:= ::oArd:CANTIDAD
   ::aCab[14]:= ::oArd:PCOSTO
EndIf
oApl:oInv:Seek( {"codigo",oE:oArd:CODIGO} )

DEFINE DIALOG oDlg TITLE cTit FROM 0, 0 TO 16,50
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 66,10
   @ 02,70 BTNGET oGet[1] VAR oE:oArd:CODIGO OF oDlg PICTURE "999999999!!!";
      VALID oE:Buscar( oDlg,lNew )        ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR" ;
      ACTION EVAL({|| If(oE:oCA:Mostrar(), (oE:oArd:CODIGO := oE:oCA:oDb:CODIGO,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 14,50 SAY oGet[2] VAR oApl:oInv:DESCRIP OF oDlg PIXEL SIZE 120,10;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 26,00 SAY "Cantidad" OF oDlg RIGHT PIXEL SIZE 66,10
   @ 26,70 GET oGet[3] VAR ::oArd:CANTIDAD OF oDlg PICTURE "9,999";
      VALID {|| If( ::oArd:CANTIDAD >  0, .t.                       ,;
          (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>"), .f.)) };
      SIZE 40,10 PIXEL UPDATE
   @ 38,00 SAY "Precio Costo"  OF oDlg RIGHT PIXEL SIZE 66,10
   @ 38,70 GET oGet[4] VAR ::oArd:PCOSTO   OF oDlg PICTURE "999,999,999.99";
      SIZE 40,10 PIXEL UPDATE
   @ 50,00 SAY "Precio Venta"  OF oDlg RIGHT PIXEL SIZE 66,10
   @ 50,70 GET oGet[5] VAR ::oArd:PVENTA   OF oDlg PICTURE "999,999,999";
      SIZE 40,10 PIXEL UPDATE
   @ 62,00 SAY "Indicador IVA" OF oDlg RIGHT PIXEL SIZE 66,10
   @ 62,70 GET oGet[5] VAR ::oArd:INDIVA   OF oDlg PICTURE "9";
      VALID Rango( ::oArd:INDIVA,0,1 )     SIZE 10,10 PIXEL UPDATE
   @ 74,00 SAY "Nro. del Lote" OF oDlg RIGHT PIXEL SIZE 66,10
   @ 74,70 GET oGet[6] VAR ::oArd:LOTE     OF oDlg ;
      WHEN oApl:oInv:GRUPO == "6" SIZE 64,10 PIXEL UPDATE
   @ 86,00 SAY "F.Vencimiento" OF oDlg RIGHT PIXEL SIZE 66,10
   @ 86,70 GET oGet[7] VAR ::oArd:FECHAV   OF oDlg ;
      WHEN oApl:oInv:GRUPO == "6" SIZE 36,10 PIXEL UPDATE

   @ 100, 70 BUTTON oGet[8] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ACTION;
      (If( EMPTY(::oArd:CODIGO) .OR. ::oArd:CANTIDAD <= 0              ,;
         ( MsgStop("Imposible grabar este Código"), oGet[1]:SetFocus()),;
         ( oGet[8]:Disable(), EVAL( bGrabar ), oGet[8]:Enable() ))) PIXEL
   @ 100,120 BUTTON oGet[9] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION ( oDlg:End() ) PIXEL
   ACTIVAGET(oGet)
   If !::aPrv[1]
      oGet[8]:Disable()
   EndIf
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
 oLbx:SetFocus()
RETURN NIL

//------------------------------------//
METHOD Grabar( oLbx,lNew ) CLASS TCompra

If ::aCab[1] == 0
   ::aCab[1] := SgteNumero( "numingreso",0,.t. )
   ::oArc:OPTICA    := oApl:nEmpresa
   ::oArc:INGRESO   := ::aCab[01]
   ::oArc:CODIGO_NIT:= ::aCab[11]
   ::oArc:MONEDA    := "X"
   ::oArc:Append( .t. )
   ::aCab[4] := ::aCab[1] + 1
   ::aIng    := Detalles( ::aIng,::aCab[1],.t. )
EndIf
::oArd:CODIGO := UPPER(LTRIM(::oArd:CODIGO))
::oArd:PPUBLI := If( ::oArd:INDIVA == 0, ::oArd:PVENTA,;
                     ROUND( ::oArd:PVENTA*::aCab[5],0 ) )
If lNew
   ::nSub += (::oArd:CANTIDAD * ::oArd:PCOSTO)
   ::oArc:CONTROL ++
   ::oArd:INGRESO   := ::aCab[1]
   ::oArd:SECUENCIA := ::oArc:CONTROL
   ::oArd:Append( .t. )
   ::oArc:Update( .f.,1 )
   Actualiz( ::oArd:CODIGO,::oArd:CANTIDAD,::oArc:FECINGRE,1,::oArd:PCOSTO )
   PListbox( oLbx,::oArd )
Else
   ::nSub += (::oArd:CANTIDAD * ::oArd:PCOSTO - ::aCab[09] * ::aCab[14])
   If ::oArd:INDICA == "E" .AND. ;
     (::oArd:CODIGO # ::aCab[8] .OR. ::oArd:CANTIDAD # ::aCab[9])
      ::oArd:INDICA := "C"
   EndIf
   If ::oArd:CODIGO # ::aCab[08] .OR.;
      ::oArd:PCOSTO # ::aCab[14]
      Actualiz( ::aCab[8],-::aCab[9],::oArc:FECINGRE,1,::aCab[14] )
      ::aCab[9] := 0
   EndIf
   ::oArd:Update( .t.,1 )
   Actualiz( ::oArd:CODIGO,::oArd:CANTIDAD-::aCab[9],::oArc:FECINGRE,1,::oArd:PCOSTO )
EndIf
   ::oDlg:Update()
   ::aCab[15]:= .t.
RETURN NIL

//------------------------------------//
METHOD CambiaFec() CLASS TCompra
   LOCAL aFE, lSI := .t.
If EMPTY( ::oArc:FECINGRE )
   MsgStop( "No puede ir en Blanco","FECHA" )
   lSI := .f.
ElseIf CierreInv( ::oArc:FECINGRE,"COMPRAS" )
   lSI := .f.
ElseIf ::oArc:lOK
   aFE := { ::aCab[13],::oArc:FECINGRE }
   If (LEFT( DTOS(aFE[1]),6 ) != LEFT( DTOS(aFE[2]),6 ))
      ::oArd:dbEval( {|o| Actualiz( o:CODIGO,-o:CANTIDAD,aFE[1],1,o:PCOSTO ),;
                          Actualiz( o:CODIGO, o:CANTIDAD,aFE[2],1,o:PCOSTO ) } )
      ::Borrar( ::aCab[13] )
   EndIf
   ::oArc:Update(.f.,1)
   MsgInfo( "El cambio de Fecha","HECHO" )
EndIf
 ::aCab[13] := If( lSi, ::oArc:FECINGRE, ::aCab[13] )
RETURN lSI

//------------------------------------//
METHOD CambiaOptica() CLASS TCompra
   LOCAL nOptica := ::oArc:OPTICA, nReg := ::oArd:Recno()
If ::oArc:CONTROL > 0 .AND. nOptica # oApl:nEmpresa
   ::oArc:OPTICA := oApl:nEmpresa
   ::oArc:Update( .f.,1 )
   ::oArd:GoTop():Read()
   ::oArd:xLoad()
   While !::oArd:Eof()
      oApl:nEmpresa := nOptica
      Actualiz( ::oArd:CODIGO,-::oArd:CANTIDAD,::oArc:FECINGRE,1,::oArd:PCOSTO )
      oApl:nEmpresa := ::oArc:OPTICA
      Actualiz( ::oArd:CODIGO, ::oArd:CANTIDAD,::oArc:FECINGRE,1,::oArd:PCOSTO )
      ::oArd:Skip(1):Read()
      ::oArd:xLoad()
   EndDo
   ::oArd:Go( nReg ):Read()
   If ::aCab[7]  # oApl:oEmp:PRINCIPAL .AND.;
     (::aCab[7]  # 0 .AND. ::aCab[7] # 4)
      ::Borrar( ::oArc:FECINGRE )
      ::aCab[7] := oApl:oEmp:PRINCIPAL
      ::oArc:Update(.f.,1)
   EndIf
   MsgInfo( "El cambio de Optica","HECHO" )
Else
   ::aCab[7] := oApl:oEmp:PRINCIPAL
EndIf
RETURN NIL

//------------------------------------//
METHOD Ajustes() CLASS TCompra
   LOCAL aGT
If !oApl:lEnLinea
   aGT  := {::oArc:TOTALFAC - (::nSub + ::aIng[2,6] - ::aIng[1,6] - ::aIng[5,6]),;
            ::aIng[4,6],0,0 }
 //         ::aIng[4,6],0,0,::aIng[5,6] }
 //If (aGT[1]+aGT[5] >= aGT[2] .AND. aGT[2] > 0) .OR.;
 //   (aGT[1]+aGT[2] >= aGT[5] .AND. aGT[5] > 0)
   If ROUND( aGT[1],0 ) >= aGT[2] .AND. aGT[2] > 0
      ::oArd:dbEval( {|o| aGT[3] += o:CANTIDAD, aGT[4] ++ } )
      If !MsgYesNo( TRANSFORM( aGT[2],"9,999,999" ) + CRLF + "Entre " +;
                    STR( aGT[3] ) + " Articulos","Desea Repartir el Flete" )
         RETURN NIL
      EndIf
      aGT[3] := ROUND( aGT[2]/aGT[3],2 )
 //           - ROUND( aGT[5]/aGT[3],2 )
      ::oArd:GoTop():Read()
      ::oArd:xLoad()
      While !::oArd:Eof()
         Actualiz( ::oArd:CODIGO,-::oArd:CANTIDAD,::oArc:FECINGRE,1,::oArd:PCOSTO )
                   ::oArd:PCOSTO += aGT[3]  ; ::oArd:Update( .f.,1 )
         Actualiz( ::oArd:CODIGO, ::oArd:CANTIDAD,::oArc:FECINGRE,1,::oArd:PCOSTO )
         ::nSub += (::oArd:CANTIDAD * aGT[3])
         aGT[2] -= (::oArd:CANTIDAD * aGT[3])
 //      aGT[5] -= (::oArd:CANTIDAD * aGT[3])
         //MsgInfo( "INC"+TRANSFORM( aGT[3],"999,999.99" )+CRLF+;
         //         "RES"+TRANSFORM( aGT[2],"999,999.99" ),STR(aGT[4]) )
         ::oArd:Skip(1):Read()
         ::oArd:xLoad()
         If (aGT[4] --) == 2
             aGT[3] := ROUND( aGT[2]/::oArd:CANTIDAD,2 )
 //                  - ROUND( aGT[5]/::oArd:CANTIDAD,2 )
         EndIf
      EndDo
   EndIf
EndIf
ListoArt( {::oArc:FECINGRE,::oArc:FECINGRE,::aCab[1],::aCab[1],"C","N",.f.,0,""} )
If ::aCab[15]
   ::ArmarInf()
EndIf
RETURN NIL

//------------------------------------//
METHOD ArmarInf() CLASS TCompra
   LOCAL aGT, aDT, aRes, cQry, nD, nL, nRT, hRes
   LOCAL oDlg, oBrw, bFac := {|nCtl| ::oDlg:Update(), ::aCab[15]:= .f. }
If ::aCab[1] == 0 .OR. ::nSub == 0 .OR. oApl:lEnLinea .OR.;
   ::aCab[3] == 890112740    //LOC
   RETURN NIL
EndIf
cQry := "SELECT d.codigo, CAST(SUM(d.cantidad) AS UNSIGNED INTEGER), SUM(d.cantidad * d.pcosto)"+;
        ", c.optica FROM comprasc c, cadartid d "
nRT  := ::oArc:TOTALFAC - (::nSub + ::aIng[2,6])
If nRT > 1000
   bFac := {|nCtl| cQry := "UPDATE comprasc SET cgeconse = "+ LTRIM(STR(nCtl))+;
                           " WHERE factura = " + xValToChar( ::oArc:FACTURA ) ,;
                   MSQuery( oApl:oMySql:hConnect,cQry ),;
                   ::oDlg:Update(), ::aCab[15]:= .f. }
   cQry += "WHERE c.factura = " + xValToChar( ::oArc:FACTURA )+;
            " AND c.codigo_nit = " + LTRIM(STR(::oArc:CODIGO_NIT))+;
            " AND d.ingreso = c.ingreso"+;
            " AND d.indica <> 'B' "     +;
            "GROUP BY c.optica, LEFT(d.codigo,2) ORDER BY c.optica"
Else
   cQry += "WHERE c.ingreso = " + LTRIM(STR(::aCab[1]))+;
            " AND d.ingreso = c.ingreso"               +;
            " AND d.indica <> 'B' GROUP BY LEFT(d.codigo,2)"
EndIf
 hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
             MSStoreResult( oApl:oMySql:hConnect ), 0 )
 If (nL := MSNumRows( hRes )) == 0
    MSFreeResult( hRes )
    RETURN .f.
 EndIf
 aRes := MyReadRow( hRes )
 AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
// aDT  := ::BuscaCta( ::oArc:FECINGRE,aRes[4],"4" )
 aDT  := ::BuscaCta( ::oArc:FECINGRE,::aCab[7],"4",aRes[4] )
 aGT  := { { aDT[1,1],"","","","",0,aDT[1,7],0,0,aDT[1,10] } }
 nRT  := aRes[4]
 While nL > 0
    nD := { 3,0,4,5,1,2 }[VAL( Grupos( aRes[1] ) )]
    aGT[01,6] += aRes[2]
    aGT[01,8] += ROUND(aRes[3],0)
    aDT[nD,7] += ROUND(aRes[3],0)
    If (nL --) > 1
       aRes := MyReadRow( hRes )
       AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
    EndIf
    If nL == 0 .OR. aRes[4] # nRT
       FOR nD := 2 TO 5
          AADD( aGT,{ aDT[nD,1],"","","","",aDT[nD,6],aDT[nD,7],0,0,aDT[1,10] } )
       NEXT nD
       If nRT  # aRes[4]
          nRT := aRes[4]
          aDT := ::BuscaCta( ::oArc:FECINGRE,::aCab[7],"4",nRT )
       EndIf
    EndIf
 EndDo
 MSFreeResult( hRes )
 nRT := (aGT[1,8] + ::aIng[2,6]) - (::oArc:TOTALFAC + ::aIng[1,6] + ::aIng[5,6])
 If nRT > 1000
    If !MsgNoYes( "Con esta Diferencia "+STR(nRT),"Lo Contabilizo" )
       RETURN .f.
    EndIf
 EndIf
 FOR nD := 6 TO 11
    AADD( aGT,{ aDT[nD,1],"","","","",aDT[nD,6],0,0 } )
 NEXT nD
 aGT[1,8] := ::aCab[3]
 If ::BuscaNit( @aGT,1 )
    RETURN .f.
 EndIf
 cQry := "SELECT descrip FROM cadinven WHERE LEFT(codigo,4) = '" +;
          LEFT(aRes[1],4) + "'"
 nL   := LEN( aGT )
//1_Fecha,2_Factura,3_Row_id,4_,5_Anomes,6_Descrip,7_Empresa,8_Nit,9_CodigoNit
    aGT[1,2] := ::oArc:FACTURA
    aGT[1,3] := LTRIM( STR(::oArc:ROW_ID) )
    aGT[1,6] := LTRIM(STR(aGT[1,6])) + " " + Buscar( cQry,"CM" )
 If aGT[1,8] == 800146073 .AND. LEN( ALLTRIM( ::oArc:FACTURA ) ) < 8
    cQry := STRZERO( 0,8-LEN( ALLTRIM( ::oArc:FACTURA ) ) )
    aGT[1,2] := STUFF( ::oArc:FACTURA,3,0,cQry )
 EndIf
 If nRT > 0
    aGT[nL  ,8] := nRT
 Else
    aGT[nL  ,7] := ABS(nRT)
 EndIf
 //Base Retencion  TOTALFAC + RFte + RIca - Iva
::aLS[12] := ::oArc:TOTALFAC + ::aIng[1,6] - ::aIng[2,6] - ::aIng[5,6]
aRes := Retenciones( ::oArc:FECINGRE,::aLS[12],If( ::aCab[7] == 16, 655, ::oArc:CODIGO_NIT ) )
    aGT[nL-5,7] := ::aIng[2,6]          //24080102
    aGT[nL-4,8] := ::oArc:TOTALFAC      //22050101
 If ::aIng[1,6] > 0
    aGT[nL-3,5] := ROUND( (::aIng[1,6] / aRes[5]) * 100,2 )
    aGT[nL-3,8] := ::aIng[1,6]          //23654001 RFte
 Else
    aGT[nL-3,5] := aRes[6]
    aGT[nL-3,8] := aRes[1]
    aGT[nL-4,8] -= aRes[1]
  //MsgInfo( "RFte"+STR(aGT[nL-3,5]),STR(::aLS[12])+STR(aRes[6]) )
 EndIf
    aGT[nL-2,8] := aRes[3]              //23657003 0.30%
 If ::aIng[5,6] > 0
    aGT[nL-1,5] := ROUND( (::aIng[5,6] / aRes[5]) * 100,2 )
    aGT[nL-1,8] := ::aIng[5,6]          //23680101 RIca
 Else
    aGT[nL-1,5] := aRes[7]
    aGT[nL-1,8] := aRes[2]
    aGT[nL-4,8] -= aRes[2]
 EndIf
    aGT[nL-4,8] -= aRes[3]
 If aRes[4] > 0
    aGT[nL-4,1] := "23359501"
    aGT[nL-3,1] := "23654002"
    aGT[nL-3,5] := aRes[9]
    AADD( aGT, {"24080104","","","","",0,aRes[4],0 } )
    AADD( aGT, {"23670101","","","",aRes[9],0,0,aRes[4]} )
 EndIf
 ::aDC := Buscar( {"comprasc_id",::oArc:ROW_ID},"comprasf",;
                  "fecha, dscto_us, dscto, ptaje",9,"fecha" )
   nD  := ::BuscaNit( aGT )
DEFINE DIALOG oDLG TITLE "Contabilizar las Compras" FROM 4,10 TO 24,60

  @ 2.0,1 LISTBOX oBrw ;
      FIELDS "", "", "", "", "" ;
      HEADERS "Cuenta", "InfA", "InfB", "Debito", "Credito";
      FIELDSIZES 66, 66, 66, 60, 60;
      OF oDlg          SIZE 180, 76;
      ON DBLCLICK MsgInfo( "Array row: " + Str( oBrw:nAt ) + CRLF + ;
                           "Array col: " + Str( oBrw:nAtCol( nCol ) ) )

   oBrw:nAt       := 1
   oBrw:bLine     := { || { ::aMV[oBrw:nAt][1], ::aMV[oBrw:nAt][2], ::aMV[oBrw:nAt][3],;
                      TRANSFORM( ::aMV[oBrw:nAt][7],"999,999,999"),;
                      TRANSFORM( ::aMV[oBrw:nAt][8],"999,999,999") } }
   oBrw:bGoTop    := { || oBrw:nAt := 1 }
   oBrw:bGoBottom := { || oBrw:nAt := EVAL( oBrw:bLogicLen ) }
   oBrw:bSkip     := { | nWant, nOld | nOld := oBrw:nAt, oBrw:nAt += nWant,;
                        oBrw:nAt := MAX( 1, MIN( oBrw:nAt, EVAL( oBrw:bLogicLen ) ) ),;
                        oBrw:nAt - nOld }
   oBrw:bLogicLen := { || LEN( ::aMV ) }
   oBrw:cAlias    := "Array"

  @ 7.5,1  BUTTON "Contabilizar" ACTION ;
      ( If( ::aMV[1,8] > 0, (::Contable(), EVAL( bFac,::aLS[5] ), oDlg:End()),;
            MsgAlert( "NO HAY INFORMACION PARA GRABAR" ) ) )
  @ 7.5,14 BUTTON "Cancelar"  ACTION oDlg:End()

ACTIVATE DIALOG oDlg CENTERED

RETURN nD

//------------------------------------//
FUNCTION Detalles( aV,nIng,lNew )
   LOCAL cQry, hRes, nR
If oApl:lEnLinea
   RETURN aV
EndIf
If lNew
   FOR nR := 1 TO LEN( aV )
      If aV[nR,6] > 0 .OR. aV[nR,7] > 0
         If aV[nR,1] == 0
            cQry := "INSERT INTO comprasd VALUES ( null, "+ LTRIM(STR(nIng))+;
                    ", " +                   LTRIM(STR(aV[nR,3]))           +;
                    ", " + If( aV[nR,4] > 0, LTRIM(STR(aV[nR,4])), "null" ) +;
                    ", " + If( aV[nR,5] > 0, LTRIM(STR(aV[nR,5])), "null" ) +;
                    ", " + If( aV[nR,6] > 0, LTRIM(STR(aV[nR,6])), "null" ) +;
                    ", " + If( aV[nR,7] > 0, LTRIM(STR(aV[nR,7])), "null" ) + " )"
         Else
            cQry := "UPDATE comprasd SET " +;
                    "nit = " + If( aV[nR,4] > 0, LTRIM(STR(aV[nR,4])), "null" ) +;
                  ", doc = " + If( aV[nR,5] > 0, LTRIM(STR(aV[nR,5])), "null" ) +;
                  ", deb = " + If( aV[nR,6] > 0, LTRIM(STR(aV[nR,6])), "null" ) +;
                  ", cre = " + If( aV[nR,7] > 0, LTRIM(STR(aV[nR,7])), "null" ) +;
                 " WHERE row_id = " + LTRIM(STR(aV[nR,1]))
         EndIf
         MSQuery( oApl:oMySql:hConnect,cQry )
      ElseIf aV[nR,1] > 0
            cQry := "DELETE FROM comprasd WHERE row_id = " +;
                    LTRIM(STR(aV[nR,1]))
         MSQuery( oApl:oMySql:hConnect,cQry )
         aV[nR,1] := aV[nR,6] := aV[nR,7] := 0
      EndIf
   NEXT nR
EndIf
FOR nR := 1 TO LEN( aV )
   aV[nR,1] := aV[nR,4] := aV[nR,5] := aV[nR,6] := aV[nR,7] := 0
NEXT nR
cQry := "SELECT row_id, tipo, nit, doc, deb, cre " +;
        "FROM comprasd WHERE ingreso = " + LTRIM(STR(nIng))
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nR   := MSNumRows( hRes )
While nR > 0
   cQry := MyReadRow( hRes )
   AEVAL( cQry, { |xV,nP| cQry[nP] := MyClReadCol( hRes,nP ) } )
   aV[cQry[2],1] := cQry[1]
   aV[cQry[2],4] := cQry[3]
   aV[cQry[2],5] := cQry[4]
   aV[cQry[2],6] := cQry[5]
   aV[cQry[2],7] := cQry[6]
   nR --
EndDo
MSFreeResult( hRes )
RETURN aV

//------------------------------------//
FUNCTION Facturas( lNew,cFac,cFV,oArc )
   LOCAL cQry, hRes, nR, lOK := .t.
If lNew
   If cFac # cFV
      oArc:Update( .f.,1 )
   EndIf
Else
   cFV  := ""
   cQry := "SELECT c.ingreso, e.localiz FROM cadempre e, comprasc c "+;
           "WHERE c.optica  = e.optica"              +;
            " AND c.factura = " + xValToChar( cFac ) +;
            " AND c.codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT))
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nR   := MSNumRows( hRes )
   While nR > 0
      cQry := MyReadRow( hRes )
      cFV  += ("Ing." + cQry[1] + " EN " + cQry[2]) +;
              If( nR > 1, CRLF, "" )
      nR --
   EndDo
   MSFreeResult( hRes )
   If !EMPTY( cFV )
      lOK := MsgNoYes( cFV,"Factura "+cFac+" YA esta en" )
   EndIf
EndIf
RETURN lOK