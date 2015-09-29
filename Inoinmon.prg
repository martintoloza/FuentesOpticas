// Programa.: INOINMON.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Ingresa archivo de monturas.
#include "FiveWin.ch"
#include "TSBrowse.ch"
#include "btnget.ch"

MEMVAR oApl

#define CLR_PINK  nRGB( 128, 150, 150)
#define CLR_NBLUE nRGB( 255, 255, 235)

PROCEDURE InoinMon()
   LOCAL oLbd, oLbx, oNi, oGet := ARRAY(12), lSalir := .f.
   LOCAL aBarra, aMone, oM := TMontura()
oM:New()
aBarra := { {|| oM:Editar( oLbx,.t. ) }, {|| oM:Editar( oLbx,.f. ) },;
            {|| oM:ArmarInf() }        , {|| oM:Borrar( oLbx ) }    ,;
            {|| oM:Ajustes(),  oM:aCab[1] := 0, oGet[1]:SetFocus() },;
            {|| If( oM:aCab[12], oM:ArmarInf(), ), lSalir := .t., oM:oDlg:End() } }
aMone  := oM:aCab[7]:aMone
oNi    := oM:aCab[7]:oNi
oNi:oDb:xBlank()

DEFINE DIALOG oM:oDlg FROM 0, 0 TO 370, 580 PIXEL;
   TITLE "Ingreso de Monturas"
   @ 16, 00 SAY "Nro. de Ingreso" OF oM:oDlg RIGHT PIXEL SIZE 50,10
   @ 16, 52 GET oGet[1] VAR oM:aCab[1] OF oM:oDlg PICTURE "999999";
      VALID oM:Buscar( oLbx,oGet,oLbd )                           ;
      SIZE 30,10 PIXEL UPDATE
   @ 16,100 SAY "Sgte. Ingreso" + STR( oM:aCab[4],6 ) OF oM:oDlg PIXEL SIZE 70,10;
      UPDATE COLOR nRGB( 255,0,0 )
   @ 28, 00 SAY "Optica" OF oM:oDlg RIGHT PIXEL SIZE 50,10
   @ 28, 52 GET oGet[2] VAR oM:aCab[2] OF oM:oDlg PICTURE "@!"     ;
      VALID Eval( {|| If( oApl:oEmp:Seek( {"localiz",oM:aCab[2]} ),;
                        ( oApl:nEmpresa := oApl:oEmp:OPTICA       ,;
                          oM:CambiaOptica(), .t. )                ,;
                        (MsgStop("Esta Optica NO EXISTE"), .f.) ) } );
      WHEN oM:aPrv[2] SIZE 24,10 PIXEL UPDATE
   @ 28,114 SAY oM:aLS[5] OF oM:oDlg PIXEL SIZE 30,10;
      UPDATE COLOR nRGB( 0,128,192 )
   @ 40, 00 SAY "Nit Proveedor" OF oM:oDlg RIGHT PIXEL SIZE 50,10
   @ 40, 52 BTNGET oGet[3] VAR oM:aCab[3] OF oM:oDlg PICTURE "9999999999";
      ACTION EVAL({|| If(oNi:Mostrar( ,,oM:aCab[3] ), ( oM:aCab[3] := ;
                         oNi:oDb:CODIGO,  oGet[3]:Refresh() ),) })    ;
      VALID EVAL( {|| If( oNi:Buscar( oM:aCab[3],"codigo",.t. )      ,;
            ( oM:aCab[10] := oNi:oDb:CODIGO_NIT, oM:oDlg:Update()    ,;
             If( oM:oMtc:lOK .AND. oM:oMtc:CODIGO_NIT # oM:aCab[10]  ,;
               ( oM:oMtc:CODIGO_NIT := oM:aCab[10]                   ,;
                 oM:oMtc:Update( .f.,1 ), oM:aCab[12] := .t.         ,;
                 oM:oMtd:dbEval( {|o| oM:Cambios( .f. ) } )          ,;
                 MsgInfo("HECHO"), oGet[3]:oJump := oLbx), ),.t. )   ,;
            ( MsgStop( "Este Proveedor no Existe .." ), .f. )) } )    ;
      SIZE 44,10 PIXEL UPDATE  RESOURCE "BUSCAR"
   @ 40,104 SAY oGet[4] VAR oNi:oDb:NOMBRE OF oM:oDlg PIXEL SIZE 100,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 16,172 SAY "Fecha [DD.MM.AA]" OF oM:oDlg RIGHT PIXEL SIZE 60,10
   @ 16,236 GET oGet[5] VAR oM:oMtc:FECINGRE OF oM:oDlg ;
      WHEN oM:aCab[1] == 0 SIZE 40,10 PIXEL UPDATE
   @ 28,172 SAY     "Nro. Factura" OF oM:oDlg RIGHT PIXEL SIZE 60,10
   @ 28,236 GET oGet[6] VAR oM:oMtc:FACTURA  OF oM:oDlg      ;
      VALID Facturas( oM:oMtc:lOK,oM:oMtc:FACTURA,oM:aCab[11],oM:oMtc );
      SIZE 40,10 PIXEL UPDATE
   @ 40,172 SAY           "Moneda" OF oM:oDlg RIGHT PIXEL SIZE 60,10
   @ 40,236 COMBOBOX oGet[7] VAR oM:aCab[9] ITEMS ArrayCol( aMone,1 ) SIZE 50,99 ;
      OF oM:oDlg PIXEL UPDATE WHEN oM:aCab[1] == 0
    oGet[7]:bLostFocus := { || oM:oMtc:MONEDA := aMone[oM:aCab[9],2] }
   @ 52,172 SAY "Total Factura" OF oM:oDlg RIGHT PIXEL SIZE 60,08
   @ 52,236 GET oGet[8] VAR oM:oMtc:TOTALFAC OF oM:oDlg PICTURE "999,999,999";
      VALID( If(oM:oMtc:lOK .AND. oM:oMtc:TOTALFAC # oM:oMtc:XColumn( 9 )   ,;
               (oM:oMtc:Update( .f.,1 ) ), ), .t. ) ;
      SIZE 42,10 PIXEL UPDATE
   @ 52,110 SAY "Factor CIF"      OF oM:oDlg RIGHT PIXEL SIZE 50,08
   @ 52,162 GET oGet[09] VAR oM:oMtc:CIF     OF oM:oDlg PICTURE "99,999.99";
      SIZE 30,10 PIXEL UPDATE
   @ 64,110 SAY "Factor de Venta" OF oM:oDlg RIGHT PIXEL SIZE 50,08
   @ 64,162 GET oGet[10] VAR oM:oMtc:FFV     OF oM:oDlg PICTURE "99,999.99";
      SIZE 30,10 PIXEL UPDATE
   @ 64,194 SAY "SubTotal"    OF oM:oDlg RIGHT PIXEL SIZE 40,10
   @ 64,236 SAY oM:nSub OF oM:oDlg PICTURE "999,999,999.99" PIXEL SIZE 42,10;
      UPDATE COLOR nRGB( 255,0,128 )
   @ 76,110 SAY "TC EURO"         OF oM:oDlg RIGHT PIXEL SIZE 50,08
   @ 76,162 GET oGet[11] VAR oM:oMtc:EUR     OF oM:oDlg PICTURE "999.9999";
      SIZE 30,10 PIXEL UPDATE
   @ 27,146 BUTTON oGet[12] PROMPT "Dscto Condicionado" SIZE 52,12 OF oM:oDlg;
      ACTION ( oGet[12]:Disable(), oM:Dsctos( oLbx,oM:oMtc:ROW_ID ),;
               oGet[12]:Enable() , oGet[12]:oJump := oLbx );
      WHEN oApl:oEmp:NIIF PIXEL
   @ 76,210 SAY "Total Monturas " + TRANSFORM( oM:oMtc:CONTROL,"999,999" );
      OF oM:oDlg PIXEL SIZE 76,10 UPDATE COLOR nRGB( 255,0,0 )
   @ 52.0,06 BROWSE oLbd SIZE 110,40 PIXEL OF oM:oDlg CELLED;
      COLORS CLR_BLACK, CLR_NBLUE

   oLbd:SetArray( oM:aIng )
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
       POSTEDIT { |uVar| If( oM:oMtc:lOK .AND. oLbd:lChanged, (oM:aIng :=;
                             Detalles( oM:aIng,oM:aCab[1],.t. )), ) }
   oLbd:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbd:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color
   @ 96,06 LISTBOX oLbx FIELDS oM:oMtd:REFER               ,;
                    TRANSFORM( oM:oMtd:CANTIDAD,"99,999" ) ,;
                               oM:oMtd:MATERIAL            ,;
                               oM:oMtd:SEXO                ,;
                    TRANSFORM( oM:oMtd:PCOSTO,"99,999,999.99"),;
                    TRANSFORM( oM:oMtd:PVENTA,"99,999,999"),;
                               oM:oMtd:TAMANO              ,;
                               oM:oMtd:CONSEC              ,;
                               oM:oMtd:INDICA               ;
      HEADERS "Referencia", "Cantidad", "Material", "Sexo" ,;
              "Precio"+CRLF+"Costo", "Precio"+CRLF+"Venta" ,;
              "Tamaño", "Código", "Ind";
      SIZES 400, 450 SIZE 280,86  ;
      OF oM:oDlg UPDATE PIXEL     ;
      ON DBLCLICK EVAL( aBarra[2] )
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:nHeaderHeight := 28
    oLbx:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:cToolTip   := "[F8] Copiar este Ingreso a otra Optica"
    oLbx:aColSizes  := {130,60,42,30,86,86,42,38,10}
    oLbx:aHjustify  := {2,2,2,2,2,2,2,2,2}
    oLbx:aJustify   := {0,1,2,2,1,1,0,0,2}
    oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE, ( oM:aCab[1] := 0, oGet[1]:SetFocus() ),;
                             If(nKey == VK_F8    , oM:CopiaIngr( oLbx ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=82, CambiaIndica( oM:oMtd ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(aBarra[1]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, EVAL(aBarra[2]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE,          EVAL(aBarra[4]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=80 .OR. nKey=VK_F3, EVAL(aBarra[5]),) )))))) }
    oLbx:lCellStyle  := .f.
    oLbx:ladjlastcol := .t.
    oLbx:ladjbrowse  := .f.
   MySetBrowse( oLbx,oM:oMtd )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oM:oDlg ON INIT ;
  (oM:oDlg:Move(80,1), DefineBar( oM:oDlg,oLbx,aBarra ));
   VALID lSalir
//,120,18
oM:oMtc:Destroy()
oM:oMtd:Destroy()
oM:oArf:Destroy()
oApl:oEmp:Seek( {"optica",oM:aCab[6]} )
nEmpresa( .f. )
ConectaOff()
RETURN

//------------------------------------//
CLASS TMontura FROM TContabil

 DATA aCab, aIng, aPrv, nSec, oMtc, oMtd, oDlg
 DATA aCam AS ARRAY INIT { SPACE(15),1,SPACE(20),"","","","      ","N",0,0,0 }
 DATA nSub          INIT 0
 METHOD NEW() Constructor
 METHOD Buscar( oLbx,oGet,oLbd )
 METHOD Borrar( oLbx )
 METHOD Editar( oLbx,lNew )
 METHOD Grabar( lNew )
 METHOD GrabaCab()
 METHOD Cambios( lCos )
 METHOD CambiaOptica()
 METHOD CopiaIngr( oLbx )
 METHOD PasaRef( lGrupo,oDie )
 METHOD Ajustes()
 METHOD ArmarInf()
ENDCLASS

//------------------------------------//
METHOD NEW() CLASS TMontura

 oApl:oEmp:Seek( {"optica",0} )
 ::aCab := { 0,"BOD",0,oApl:oEmp:NUMINGRESO + 1,oApl:oEmp:PIVA / 100 + 1,;
             oApl:nEmpresa,TInv(),0, 1, 0, "", .f.,;
             {|nCt| ::oMtc:CONTROL += nCt , ::aCab[12]:= .t. ,;
                    ::oMtc:Update( .f.,1 ), ::oDlg:Update() } }
 ::aPrv := Privileg( "COMPRAS" )
 ::oMtc := oApl:Abrir( "comprasc","ingreso",.t.,,10 )
 ::oArf := oApl:Abrir( "comprasf","fecha",.t.,,10 )
 ::oMtd := oApl:Abrir( "cadmontd","ingreso",.t.,,100 )
 ::oMtd:Seek( {"ingreso",::aCab[1]} )
 ::aCab[7]:New( ,.f. )
 ::aLS[1] := 0
 ::aIng := { { 0,"Retención"       ,1,0,0,0,0 },;
             { 0,"Retención de Iva",2,0,0,0,0 },;
             { 0,"Seguro"          ,3,0,0,0,0 },;
             { 0,"Fletes"          ,4,0,0,0,0 },;
             { 0,"Nacionalización" ,5,0,0,0,0 },;
             { 0,"Arancel e Iva"   ,6,0,0,0,0 },;
             { 0,"Otros Gastos 1"  ,7,0,0,0,0 },;
             { 0,"Otros Gastos 2"  ,8,0,0,0,0 } }
RETURN NIL

//------------------------------------//
METHOD Buscar( oLbx,oGet,oLbd ) CLASS TMontura
   LOCAL lSi := .f.
If Rango( ::aCab[1],0,::aCab[4] )
   If !::oMtc:Seek( {"ingreso",::aCab[1],"moneda <>","X"} ) .AND. ::aCab[1] > 0
      MsgStop( "Este Ingreso NO EXISTE !!" )
   Else
      If ::oMtc:lOK
         oApl:nEmpresa := ::oMtc:OPTICA
         oApl:oNit:Seek( {"codigo_nit",::oMtc:CODIGO_NIT} )
         oApl:oEmp:Seek( {"optica",::oMtc:OPTICA} )
         ::aCab[02] := ArrayValor( oApl:aOptic,STR(::oMtc:OPTICA,2) )
         ::aCab[09] := ArrayValor( ::aCab[7]:aMone,::oMtc:MONEDA,,.t.)
         ::aCab[03] := oApl:oNit:CODIGO
         ::aCab[10] := ::oMtc:CODIGO_NIT
         oGet[1]:oJump := oLbx
         ::nSub := Buscar( {"ingreso",::aCab[1]},"cadmontd","SUM(cantidad * pcosto)" )
      Else
         ::nSub := 0
         ::aCab[2] := "BOD"
         ::aCab[9] := 1
         ::oMtc:FECINGRE := DATE()
      EndIf
      ::oMtd:Seek( { "ingreso",::aCab[1] },"secuencia",.t. )
      ::nSec := MAX( ::oMtd:SECUENCIA,::oMtd:nRowCount )
        ::aLS[5] := ::oMtc:CGECONSE
      ::aCab[08] := oApl:oEmp:PRINCIPAL
      ::aCab[11] := ::oMtc:FACTURA
      ::aCab[12] := !(::aLS[5] != 0)
      ::aIng     := Detalles( ::aIng,::aCab[1],.f. )
      ::oDlg:Update()
      oLbd:Refresh() ; oLbx:Refresh()
      lSi := .t.
   EndIf
EndIf
RETURN lSi

//------------------------------------//
METHOD Borrar( oLbx ) CLASS TMontura
   LOCAL aBor
If VALTYPE( oLbx ) == "D"
   If ::aLS[5] # 0 .AND. !oApl:lEnLinea
      aBor := "WHERE CODIGO_EMP  = " + LTRIM(STR(::aCab[8]))+;
               " AND ANO_MES     = " + LEFT( DTOS(oLbx),6 ) +;
               " AND CONSECUTIVO = " + LTRIM(STR(::aLS[5]))
      ConectaOn()
      oApl:oOdbc:Execute( "DELETE FROM movto_d " + aBor )
      oApl:oOdbc:Execute( "DELETE FROM movto_c " + aBor )
      ::aCab[12] := .t.
       ::aLS[5]  := 0
      ::ArmarInf()
      If ::aLS[5] == 0
         ::oMtc:CGECONSE := ::aLS[5]
         ::oMtc:Update( .f.,1 )
      EndIf
   EndIf
Else
   If ::aPrv[3] .AND. EMPTY( ::oMtd:INDICA )
      If MsgNoYes( "Este Código "+::oMtd:REFER,"Elimina" )
         aBor := { -::oMtd:CANTIDAD,::oMtd:PCOSTO }
         If ::oMtd:Delete( .t.,1 )
            PListbox( oLbx,::oMtd )
            ::nSub += (aBor[1] * aBor[2])
            EVAL( ::aCab[13],aBor[1] )
         EndIf
      EndIf
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Editar( oLbx,lNew ) CLASS TMontura
   LOCAL oDie, aEd := { "Modificando Ingreso",SPACE(12) }
   LOCAL oAr, oGet := ARRAY(14)
   LOCAL bGrabar, nMate, nSexo, nIden, nTipo
lNew := If( ::oMtc:CONTROL == 0, .t., lNew )
If lNew
   bGrabar := {|| ::Grabar( lNew )          ,;
                  PListbox( oLbx,::oMtd )   ,;
                  ::PasaRef(), oDie:Update(),;
                  oDie:SetFocus() }
   aEd[1] := "Nuevo Ingreso"
   ::PasaRef()
Else
   bGrabar := {|| ::Grabar( lNew ), oLbx:Refresh(), oDie:End() }
   ::aCam := { ::oMtd:MARCA   ,::oMtd:CANTIDAD ,::oMtd:REFER  ,::oMtd:MATERIAL,;
               ::oMtd:SEXO    ,::oMtd:TIPOMONTU,::oMtd:TAMANO ,::oMtd:IDENTIF ,;
               ::oMtd:PCOSTO  ,::oMtd:PVENTA   ,::oMtd:USD }
   If oApl:oNit:GRUPO
      aEd[2] := "010" + If( ::oMtd:MATERIAL == "P", "1", "2" )+::oMtd:CONSEC
   EndIf
EndIf
oAr   := ::aCab[7]
nMate := ArrayValor( oAr:aMate,::aCam[4],,.t. )
nSexo := ArrayValor( oAr:aSexo,::aCam[5],,.t. )
nTipo := ArrayValor( oAr:aTipo,::aCam[6],,.t. )
nIden := ArrayValor( oAr:aIden,::aCam[8],,.t. )

DEFINE DIALOG oDie TITLE aEd[1] FROM 0, 0 TO 22,50
   @ 02,00 SAY "Cantidad" OF oDie RIGHT PIXEL SIZE 56,8
   @ 02,60 GET oGet[01] VAR ::oMtd:CANTIDAD OF oDie PICTURE "9,999";
      VALID {|| If( ::oMtd:CANTIDAD >  0, .t.                     ,;
          (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>"), .f.)) };
      SIZE 40,12 PIXEL UPDATE
   @ 02,130 GET oGet[2] VAR aEd[2] OF oDie                             ;
      VALID EVAL( {|| If( oApl:oInv:Seek( {"codigo",aEd[2]} )         ,;
                (::PasaRef( .t. )                                     ,;
                 nMate := ArrayValor( oAr:aMate,::oMtd:MATERIAL ,,.t.),;
                 nSexo := ArrayValor( oAr:aSexo,::oMtd:SEXO     ,,.t.),;
                 nIden := ArrayValor( oAr:aIden,::oMtd:IDENTIF  ,,.t.),;
                 nTipo := ArrayValor( oAr:aTipo,::oMtd:TIPOMONTU,,.t.),;
                 oDie:Update(), .t. )                                 ,;
                ( MsgStop( "Este Código NO EXISTE !!!" ), .f. )) } )   ;
      WHEN oApl:oNit:GRUPO   SIZE 56,12 PIXEL
   @  16,00 SAY      "Marca" OF oDie RIGHT PIXEL SIZE 56,8
   @  16,60 GET oGet[03] VAR ::oMtd:MARCA OF oDie PICTURE "@!";
      SIZE 70,12 PIXEL UPDATE
   @  30,00 SAY "Referencia" OF oDie RIGHT PIXEL SIZE 56,8
   @  30,60 GET oGet[04] VAR ::oMtd:REFER OF oDie PICTURE "@!";
      SIZE 78,12 PIXEL UPDATE
   @  44,00 SAY   "Material" OF oDie RIGHT PIXEL SIZE 56,8
   @  44,60 COMBOBOX oGet[05] VAR nMate ITEMS ArrayCol( oAr:aMate,1 ) SIZE 60,99;
      OF oDie PIXEL UPDATE
   @  58,00 SAY       "Sexo" OF oDie RIGHT PIXEL SIZE 56,8
   @  58,60 COMBOBOX oGet[06] VAR nSexo ITEMS ArrayCol( oAr:aSexo,1 ) SIZE 60,99;
      OF oDie PIXEL UPDATE
   @  72,00 SAY "Tipo Montura" OF oDie RIGHT PIXEL SIZE 56,8
   @  72,60 COMBOBOX oGet[07] VAR nTipo ITEMS ArrayCol( oAr:aTipo,1 ) SIZE 60,99;
      OF oDie PIXEL UPDATE
   @  72,120 SAY "Costo USD" OF oDie RIGHT PIXEL SIZE 36,8
   @  72,162 GET oGet[14] VAR ::oMtd:USD    OF oDie PICTURE "99,999.9999";
      VALID (::oMtd:TIPOMONTU := oAr:aTipo[nTipo,2]             ,;
             ::PasaRef( .f. ,oDie )                             ,;
             oGet[8]:Refresh(), oGet[14]:oJump := oGet[10], .t. );
      WHEN ::oMtc:CIF > 0  SIZE 30,10 PIXEL UPDATE
   @  86,00 SAY "Precio Costo" OF oDie RIGHT PIXEL SIZE 56,8
   @  86,60 GET oGet[08] VAR ::oMtd:PCOSTO  OF oDie PICTURE "999,999,999.99";
      VALID (::oMtd:TIPOMONTU := oAr:aTipo[nTipo,2]   ,;
             PrecioVenta( ::oMtd,oDie,oApl:oNit:GRUPO ,;
                      If( ::oMtc:CODIGO_NIT == 1569, ::aCam[10], 0 ) )) ;
      SIZE 40,12 PIXEL UPDATE
   @ 100,00 SAY "Precio Venta" OF oDie RIGHT PIXEL SIZE 56,8
   @ 100,60 GET oGet[09] VAR ::oMtd:PVENTA  OF oDie PICTURE "999,999,999";
      SIZE 40,12 PIXEL UPDATE
   @ 114,00 SAY       "Tamaño" OF oDie RIGHT PIXEL SIZE 56,8
   @ 114,60 GET oGet[10] VAR ::oMtd:TAMANO  OF oDie PICTURE "@K!";
      SIZE 40,12 PIXEL UPDATE
   @ 128,00 SAY "Identificaci" OF oDie RIGHT PIXEL SIZE 56,8
   @ 128,60 COMBOBOX oGet[11] VAR nIden ITEMS ArrayCol( oAr:aIden,1 ) SIZE 60,99;
      OF oDie PIXEL UPDATE
   @ 144, 70 BUTTON oGet[12] PROMPT "Grabar"   SIZE 44,12 OF oDie ACTION;
      (If( EMPTY(::oMtd:REFER) .OR. ::oMtd:CANTIDAD <= 0          ,;
         (MsgStop("Imposible grabar este registro"), oGet[1]:SetFocus()),;
         (::oMtd:MATERIAL := oAr:aMate[nMate,2] ,;
          ::oMtd:SEXO     := oAr:aSexo[nSexo,2] ,;
          ::oMtd:TIPOMONTU:= oAr:aTipo[nTipo,2] ,;
          ::oMtd:IDENTIF  := oAr:aIden[nIden,2] , EVAL(bGrabar) ))) PIXEL
   @ 144,120 BUTTON oGet[13] PROMPT "Cancelar" SIZE 44,12 OF oDie CANCEL;
      ACTION oDie:End() PIXEL
   ACTIVAGET(oGet)
   If !::aPrv[1]
      oGet[12]:Disable()
   EndIf
ACTIVATE DIALOG oDie ON INIT oDie:Move(220,200)
RETURN NIL

//------------------------------------//
METHOD Grabar( lNew ) CLASS TMontura
   LOCAL nCant := ::oMtd:CANTIDAD
If oApl:oNit:GRUPO
   ::oMtd:PPUBLI := oApl:oInv:PPUBLI
ElseIf ::oMtc:CODIGO_NIT == 1569 .AND.;
   RIGHT( STR( ::oMtd:PVENTA,10 ),3 ) == "000"
   // OptiCalia
   ::oMtd:PPUBLI := ::aCam[10] := ::oMtd:PVENTA
   ::oMtd:PVENTA -= ROUND( ::aCam[10]*::aCab[5],0 )
Else
   ::aCam[10]    := ::oMtd:PVENTA
   ::oMtd:PPUBLI := ROUND( ::aCam[10]*::aCab[5],0 )
EndIf
If lNew
   ::GrabaCab()
   ::nSub += (::oMtd:CANTIDAD * ::oMtd:PCOSTO)
   ::oMtd:INGRESO   := ::aCab[1]
   ::oMtd:SECUENCIA := ++::nSec
   ::oMtd:Append( .t. )
   ::aCam := { ::oMtd:MARCA ,::oMtd:CANTIDAD ,::oMtd:REFER  ,::oMtd:MATERIAL,;
               ::oMtd:SEXO  ,::oMtd:TIPOMONTU,::oMtd:TAMANO ,::oMtd:IDENTIF ,;
               ::oMtd:PCOSTO,::aCam[10]      ,::oMtd:USD }
Else
   If ::oMtd:INDICA # " "      .AND. (::oMtd:MARCA  # ::aCam[01] .OR.;
      ::oMtd:REFER  # ::aCam[03] .OR. ::oMtd:TAMANO # ::aCam[07] .OR.;
      ::oMtd:PCOSTO # ::aCam[09] .OR. ::oMtd:PVENTA # ::aCam[10])
      ::Cambios( .t. )
      ::oMtd:INDICA := If( ::oMtd:INDICA == "E", "C", "A" )
   EndIf
   nCant  -= ::aCam[2]
   ::nSub += (::oMtd:CANTIDAD * ::oMtd:PCOSTO - ::aCam[2] * ::aCam[9])
   ::oMtd:Update( .t.,1 )
EndIf
EVAL( ::aCab[13],nCant )
RETURN NIL

//------------------------------------//
METHOD GrabaCab() CLASS TMontura
If ::aCab[1] == 0
   ::aCab[1] := SgteNumero( "numingreso",0,.t. )
   ::oMtc:OPTICA    := oApl:nEmpresa
   ::oMtc:INGRESO   := ::aCab[01]
   ::oMtc:CODIGO_NIT:= ::aCab[10]
   ::oMtc:Append( .t. )
   ::aCab[4] := ::aCab[1] + 1
   ::aIng    := Detalles( ::aIng,::aCab[1],.t. )
   ::oDlg:Update()
EndIf
RETURN NIL

//------------------------------------//
METHOD Cambios( lCos ) CLASS TMontura
   LOCAL cCod := "010" + If( ::oMtd:MATERIAL == "P", "1", "2" )
   LOCAL cCodi, nCan, nCon := VAL( ::oMtd:CONSEC )
If nCon > 0
   FOR nCan := 1 TO ::oMtd:CANTIDAD
      cCodi := cCod + StrZero( nCon,6 )
      If oApl:oInv:Seek( {"codigo",cCodi} )
         If !oApl:oNit:GRUPO
            oApl:oInv:CODIGO_NIT := ::oMtc:CODIGO_NIT
         EndIf
         oApl:oInv:DESCRIP:= XTRIM(::oMtd:MARCA) + ::oMtd:REFER
         oApl:oInv:MARCA  := LEN(ALLTRIM(::oMtd:MARCA))
         oApl:oInv:TAMANO := ::oMtd:TAMANO ; oApl:oInv:PCOSTO := ::oMtd:PCOSTO
         oApl:oInv:PVENTA := ::oMtd:PVENTA ; oApl:oInv:PPUBLI := ::oMtd:PPUBLI
         oApl:oInv:Update( .f.,1 )
         If lCos .AND. ::oMtd:PCOSTO # ::aCam[9]
            SaldoInv( cCodi,NtChr( ::oMtc:FECINGRE,"1" ) )
            oApl:oMes:PCOSTO := ::oMtd:PCOSTO ; oApl:oMes:Update( .f.,1 )
         EndIf
      EndIf
      nCon ++
   NEXT
EndIf
RETURN NIL

//------------------------------------//
METHOD CambiaOptica() CLASS TMontura
   LOCAL aO, lSi := .f.
   oApl:nEmpresa := oApl:oEmp:OPTICA
If ::oMtc:lOK .AND. ;
   ::oMtc:OPTICA  # oApl:nEmpresa
   lSi := MsgYesNo( "Desea Cambiarle de Optica" )
EndIf
If lSi
   aO := { ::oMtc:OPTICA,::oMtd:RecNo(),0,0,"","",;
           "UPDATE cadinvme SET optica = " + LTRIM(STR(oApl:nEmpresa))+;
          " WHERE optica = "  + LTRIM(STR(::oMtc:OPTICA) )+;
            " AND anomes = '" + NtChr(::oMtc:FECINGRE,"1")+;
           "' AND codigo = '[COD]'"                       +;
            " AND existencia = 0 AND entradas  = 0"       +;
            " AND salidas    = 0 AND ajustes_e = 0"       +;
            " AND ajustes_s  = 0 AND devol_e   = 0"       +;
            " AND devol_s    = 0 AND devolcli  = 0" }
   ::oMtc:OPTICA := oApl:nEmpresa
   ::oMtc:Update( .f.,1 )
   ::oMtd:GoTop():Read()
   ::oMtd:xLoad()
   While !::oMtd:Eof()
      If (aO[3] := VAL(::oMtd:CONSEC)) > 0
          aO[5] := "010" + If( ::oMtd:MATERIAL == "P", "1", "2" )
         FOR aO[4] := 1 TO ::oMtd:CANTIDAD
             aO[6] := aO[5] + StrZero( aO[3],6 )
            If oApl:oInv:Seek( {"codigo",aO[6]} )
               oApl:oInv:OPTICA := ::oMtc:OPTICA
               If ::oMtc:OPTICA == 0
                  oApl:oInv:COMPRA_D := .f.
               ElseIf !oApl:oNit:GRUPO
                  oApl:oInv:COMPRA_D := .t.
               EndIf
               oApl:oInv:Update( .f.,1 )
            EndIf
            oApl:nEmpresa := aO[1]
            Actualiz( aO[6],-1,::oMtc:FECINGRE,1,::oMtd:PCOSTO )
            Guardar( STRTRAN( aO[7],"[COD]",aO[6] ),"cadinvme" )
            oApl:nEmpresa := ::oMtc:OPTICA
            Actualiz( aO[6], 1,::oMtc:FECINGRE,1,::oMtd:PCOSTO )
            aO[3] ++
         NEXT
      EndIf
      ::oMtd:Skip(1):Read()
      ::oMtd:xLoad()
   EndDo
   ::oMtd:Go( aO[2] ):Read()
   ::oMtd:xLoad()
   If ::aCab[8]  # oApl:oEmp:PRINCIPAL .AND.;
     (::aCab[8]  # 0 .AND. ::aCab[8] # 4)
      ::Borrar( ::oMtc:FECINGRE )
      ::aCab[8] := oApl:oEmp:PRINCIPAL
   EndIf
   MsgInfo( "El cambio de Optica","HECHO" )
EndIf

RETURN .t.

//------------------------------------//
METHOD CopiaIngr( oLbx ) CLASS TMontura
   LOCAL nOptica := ::oMtc:OPTICA, cQry
If !Empresa()
   RETURN NIL
EndIf
If nOptica # oApl:nEmpresa
   ::aCab[1] := 0
   ::aCab[2] := oApl:oEmp:LOCALIZ
   ::oMtc:FECINGRE := MsgDate( ::oMtc:FECINGRE,"Fecha Ingreso" )
   ::GrabaCab()
   ::oMtd:dbEval( {|o,cQry| cQry := "INSERT INTO cadmontd VALUES ( null, "+;
              LTRIM(STR(::oMtc:INGRESO))+ ", '" +  TRIM(o:MARCA)  + "', " +;
              LTRIM(STR(o:CANTIDAD)) + ", '"  +  TRIM(o:REFER)    + "', '"+;
               TRIM(    o:MATERIAL ) + "', '" +  TRIM(o:SEXO)     + "', '"+;
               TRIM(    o:TIPOMONTU) + "', '" +  TRIM(o:TAMANO)   + "', '"+;
               TRIM(    o:IDENTIF)   + "', "  + LTRIM(STR(o:PCOSTO))+ ", "+;
              LTRIM(STR(o:PVENTA))   + ", "   + LTRIM(STR(o:PPUBLI))      +;
              ", '', " + LTRIM(STR(o:SECUENCIA)) + ", '', "               +;
              LTRIM(STR(o:USD)) + " )"                                    ,;
              MSQuery( oApl:oMySql:hConnect,cQry ) } )
   ::oMtc:Seek( { "ingreso",::aCab[1],"moneda <>","X" } )
   ::oMtd:Seek( { "ingreso",::aCab[1] } )
   oLbx:Refresh()
EndIf
 ::aCab[6] := oApl:nEmpresa
RETURN NIL

//------------------------------------//
METHOD PasaRef( lGrupo,oDie ) CLASS TMontura
If lGrupo == NIL
   ::oMtd:xBlank()
   ::oMtd:MARCA  := ::aCam[1]
   ::oMtd:REFER  := ::aCam[3]
   ::oMtd:TAMANO := ::aCam[7]
   ::oMtd:PCOSTO := ::aCam[9]
ElseIf lGrupo
   If oApl:oInv:GRUPO == "1"
      ::oMtd:MARCA    := PADR(  LEFT( oApl:oInv:DESCRIP,oApl:oInv:MARCA ),15 )
      ::oMtd:REFER    := PADR(SUBSTR( oApl:oInv:DESCRIP,oApl:oInv:MARCA+2 ),20 )
      ::oMtd:MATERIAL := oApl:oInv:MATERIAL
      ::oMtd:SEXO     := oApl:oInv:SEXO
      ::oMtd:PCOSTO   := oApl:oInv:PCOSTO
      ::oMtd:PVENTA   := oApl:oInv:PVENTA
      ::oMtd:TAMANO   := oApl:oInv:TAMANO
      ::oMtd:IDENTIF  := oApl:oInv:IDENTIF
      ::oMtd:TIPOMONTU:= oApl:oInv:TIPOMONTU
      ::oMtd:CONSEC   := SUBSTR(oApl:oInv:CODIGO,5,6)
   EndIf
Else
      ::aCam[11] := ::oMtd:USD
   If ::oMtc:EUR > 0
      ::aCam[11] := ROUND( ::oMtc:EUR * ::oMtd:USD,4 )
   EndIf
      ::oMtd:PCOSTO := ROUND( ::oMtc:FFV * ::aCam[11],0 )
      PrecioVenta( ::oMtd,oDie,oApl:oNit:GRUPO )
      ::oMtd:PCOSTO := ROUND( ::oMtc:CIF * ::aCam[11],2 )
EndIf
RETURN NIL

//------------------------------------//
METHOD Ajustes() CLASS TMontura
   LOCAL aGT, cCod, nCan, nCon
If !oApl:lEnLinea
   aGT  := {::oMtc:TOTALFAC - (::nSub + ::aIng[2,6] - ::aIng[1,6]),;
            ::aIng[4,6],0,::oMtd:nRowCount,"" }
   If aGT[1] >= aGT[2] .AND. aGT[2] > 0
      If !MsgYesNo( TRANSFORM( aGT[2],"9,999,999" ) + CRLF + "Entre " +;
                    STR(::oMtc:CONTROL) + " Monturas","Desea Repartir el Flete" )
         RETURN NIL
      EndIf
      aGT[3] := ROUND( aGT[2]/::oMtc:CONTROL,2 )
      ::oMtd:GoTop():Read()
      ::oMtd:xLoad()
      While !::oMtd:Eof()
         If (nCon := VAL(::oMtd:CONSEC)) > 0
            cCod := "010" + If( ::oMtd:MATERIAL == "P", "1", "2" )
            FOR nCan := 1 TO ::oMtd:CANTIDAD
               aGT[5] := cCod + StrZero( nCon,6 )
               If oApl:oInv:Seek( {"codigo",aGT[5]} )
                  oApl:oInv:PCOSTO := ::oMtd:PCOSTO + aGT[3]
                  oApl:oInv:Update( .f.,1 )
               EndIf
               Actualiz( aGT[5],-1,::oMtc:FECINGRE,1,::oMtd:PCOSTO )
               Actualiz( aGT[5], 1,::oMtc:FECINGRE,1,::oMtd:PCOSTO+aGT[3] )
               nCon ++
            NEXT nCan
         EndIf
         ::nSub += (::oMtd:CANTIDAD * aGT[3])
         aGT[2] -= (::oMtd:CANTIDAD * aGT[3])
         ::oMtd:PCOSTO += aGT[3] ; ::oMtd:Update( .f.,1 )
         ::oMtd:Skip(1):Read()
         ::oMtd:xLoad()
         If (aGT[4] --) == 2
             aGT[3] := ROUND( aGT[2]/::oMtd:CANTIDAD,2 )
         EndIf
      EndDo
   EndIf
EndIf
ListoMon( {0,::oMtc:FECINGRE,::oMtc:FECINGRE,::aCab[1],::aCab[1],0,::oMtc:MONEDA,.f.} )
If ::aCab[12]
   ::ArmarInf()
EndIf
RETURN NIL

//------------------------------------//
METHOD ArmarInf() CLASS TMontura
   LOCAL aGT, aDT, aRes, cQry, nD, nL, nRT, hRes
   LOCAL oDlg, oBrw, bFac := {|nCtl| ::oDlg:Update(), ::aCab[12]:= .f. }
If ::aCab[1] == 0 .OR. ::nSub == 0 .OR. oApl:lEnLinea .OR.;
   ::aCab[3] == 890112740    //LOC
   RETURN NIL
EndIf
/*
If ::aCab[3] >= 444444001 .AND.;
   ::aCab[3] <= 444444030
   nRT  := ::aIng[1,6] + ::aIng[3,6] + ::aIng[4,6] + ::aIng[5,6] + ::aIng[6,6]
   aDT  := ::BuscaCta( ::oMtc:FECINGRE,aRes[3],"4" )
//1_Fecha,2_Factura,3_Row_id,4_,5_Anomes,6_Descrip,7_Empresa,8_Nit,9_CodigoNit
   ::aMV:= { { NtChr( aDT[1,1],"2" ),aDT[1,2],aDT[1,3],aDT[1,4],;
           LEFT( DTOS(aDT[1,1]),6 ) ,aDT[1,6],aDT[1,7],aDT[1,8],aDT[1,9] } }

   aGT  := { { aDT[1,1],"","","","",0,aDT[1,7],0,0,aDT[1,10] },;
             { aDT[3,1],"","","","",0,aDT[1,7],0,0,aDT[1,10] } }
Else*/
   cQry := "SELECT CAST(SUM(d.cantidad) AS UNSIGNED INTEGER), SUM(d.cantidad * d.pcosto), c.optica "+;
           "FROM comprasc c, cadmontd d "
   nRT  := ::oMtc:TOTALFAC - (::nSub + ::aIng[2,6] - ::aIng[1,6])
   If nRT > 1000
      bFac := {|nCtl| cQry := "UPDATE comprasc SET cgeconse = "+ LTRIM(STR(nCtl))+;
                              " WHERE factura = " + xValToChar( ::oMtc:FACTURA ) ,;
                      MSQuery( oApl:oMySql:hConnect,cQry ),;
                      ::oDlg:Update(), ::aCab[12]:= .f. }
      cQry += "WHERE c.factura = " + xValToChar( ::oMtc:FACTURA )   +;
               " AND c.codigo_nit = "+ LTRIM(STR(::oMtc:CODIGO_NIT))+;
               " AND d.ingreso = c.ingreso"                         +;
               " AND d.indica <> 'B' GROUP BY c.optica"
   Else
      cQry += "WHERE c.ingreso = " + LTRIM(STR(::aCab[1]))+;
               " AND d.ingreso = c.ingreso"               +;
               " AND d.indica <> 'B' GROUP BY c.optica"
   EndIf
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   If (nL := MSNumRows( hRes )) == 0
      MSFreeResult( hRes )
      RETURN .f.
   EndIf
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aDT  := ::BuscaCta( ::oMtc:FECINGRE,::aCab[8],"4",aRes[3] )
   aGT  := { { aDT[1,1],"","","","",0,aDT[1,7],0,0,aDT[1,10] } }
   nRT  := aRes[3]
   While nL > 0
      aGT[01,6] += aRes[1]
      aGT[01,8] += ROUND(aRes[2],0)
      aDT[03,7] += ROUND(aRes[2],0)
      If (nL --) > 1
         aRes := MyReadRow( hRes )
         AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      EndIf
      If nL == 0 .OR. aRes[3] # nRT
         FOR nD := 2 TO 5
            AADD( aGT,{ aDT[nD,1],"","","","",aDT[nD,6],aDT[nD,7],0,0,aDT[1,10] } )
         NEXT nD
         If nRT  # aRes[3]
            nRT := aRes[3]
            aDT := ::BuscaCta( ::oMtc:FECINGRE,::aCab[8],"4",nRT )
         EndIf
      EndIf
   EndDo
   MSFreeResult( hRes )
   nRT := aGT[1,8] + ::aIng[2,6] - ::aIng[1,6] - ::aIng[6,6] - ::oMtc:TOTALFAC
   If nRT > 1000
      If !MsgNoYes( "Con esta Diferencia "+STR(nRT),"Lo Contabilizo" )
         RETURN .f.
      EndIf
   EndIf
   FOR nD := 6 TO 11
      AADD( aGT,{ aDT[nD,1],"","","","",aDT[nD,6],0,0 } )
   NEXT nD
//EndIf
 aGT[1,8] := ::aCab[3]
 If ::BuscaNit( @aGT,1 )
    RETURN .f.
 EndIf
 cQry := "SELECT marca FROM cadmontd WHERE ingreso = " + LTRIM(STR(::aCab[1]))
 nL   := LEN( aGT )
    aGT[1,2] := ::oMtc:FACTURA
    aGT[1,3] := LTRIM( STR(::oMtc:ROW_ID) )
    aGT[1,6] := LTRIM(STR(aGT[1,6])) + " MONTURAS " + Buscar( cQry,"CM" )
 If aGT[1,8] == 800146073 .AND. LEN( ALLTRIM( ::oMtc:FACTURA ) ) < 8
    cQry := STRZERO( 0,8-LEN( ALLTRIM( ::oMtc:FACTURA ) ) )
    aGT[1,2] := STUFF( ::oMtc:FACTURA,3,0,cQry )
 EndIf
 If nRT > 0
    aGT[nL  ,8] := nRT
 Else
    aGT[nL  ,7] := ABS(nRT)
 EndIf
 //Base Retencion  TOTALFAC + Retencion - Iva
::aLS[12] := ::oMtc:TOTALFAC + ::aIng[1,6] - ::aIng[2,6]
aRes := Retenciones( ::oMtc:FECINGRE,::aLS[12],If( ::aCab[8] == 16, 655, ::oMtc:CODIGO_NIT ) )
    aGT[nL-5,7] := ::aIng[2,6]             //24080102
    aGT[nL-4,8] := ::oMtc:TOTALFAC         //22050101
 If ::aIng[1,6] > 0
    aGT[nL-3,5] := ROUND( (::aIng[1,6] / aRes[5]) * 100,2 )
    aGT[nL-3,8] := ::aIng[1,6]             //23654001
 Else
    aGT[nL-3,5] := aRes[6]
    aGT[nL-3,8] := aRes[1]
    aGT[nL-4,8] -= aRes[1]
 EndIf
 If ::aIng[6,6] > 0
    aGT[nL-1,5] := ROUND( (::aIng[6,6] / aRes[5]) * 100,2 )
    aGT[nL-1,8] := ::aIng[6,6]             //23680101
 Else
    aGT[nL-1,5] := aRes[7]
    aGT[nL-1,8] := aRes[2]
    aGT[nL-4,8] -= aRes[2]
 EndIf
    aGT[nL-2,8] := aRes[3]                 //23657003  .30%
    aGT[nL-4,8] -= aRes[3]
 If aRes[4] > 0
    AADD( aGT, {"24080104","","","","",0,aRes[4],0 } )
    AADD( aGT, {"23670101","","","",aRes[9],0,0,aRes[4] } )
 EndIf
 ::aDC := Buscar( {"comprasc_id",::oMtc:ROW_ID},"comprasf",;
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
PROCEDURE InoAcMon()
   LOCAL oDlg, oFont, oGet := ARRAY(5), aOpc := { CTOD(""),0,"" }
DEFINE FONT oFont NAME "Times New Roman" SIZE 0,-18
DEFINE DIALOG oDlg TITLE "Generar Códigos de Montura" FROM 0, 0 TO 08,50
   @ 02, 00 SAY "FECHA DE ACTUALIZACION [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 110,10
   @ 02,112 GET oGet[1] VAR aOpc[1] OF oDlg ;
      VALID !EMPTY( Buscar( { "fecingre",aOpc[1] },"comprasc","ingreso" ) );
      SIZE 44,12 PIXEL
   @ 16, 00 SAY       "NUMERO DEL INGRESO" OF oDlg RIGHT PIXEL SIZE 110,10
   @ 16,112 GET oGet[2] VAR aOpc[2] OF oDlg PICTURE "99999" SIZE 44,12 PIXEL
   @ 32, 50 BUTTON oGet[3] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[3]:Disable(), Generar( aOpc,oDlg ), oGet[3]:Enable()    ,;
        oGet[3]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 32,100 BUTTON oGet[4] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 47, 30 SAY oGet[5] VAR aOpc[3] OF oDlg PIXEL SIZE 90,18 ;
      UPDATE COLOR nRGB( 160,19,132 ) FONT oFont
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
oFont:End()
RETURN

//------------------------------------//
STATIC PROCEDURE Generar( aFec,oDlg )
   LOCAL aDat, cCon, lSi, mCodigo, nCan, nCod, nOpt := oApl:nEmpresa
   LOCAL aMtc, oMtd, nC
oDlg:SetText( "<< ESPERE >> GENERANDO CODIGOS" )
oApl:oEmp:Seek( {"optica",0} )
nCod := oApl:oEmp:CODMONTURA
aMtc := { "fecingre",aFec[1] }
oMtd := oApl:Abrir( "cadmontd","ingreso",.t.,,120 )
If aFec[2] > 0
   AEVAL( { "ingreso",aFec[2] }, {|cVal| AADD( aMtc,cVal ) } )
EndIf
aMtc := Buscar( aMtc,"comprasc","optica, ingreso, codigo_nit, fecingre, factura, moneda",2 )
FOR nC := 1 TO LEN( aMtc )
   If (oApl:nEmpresa := aMtc[nC,1]) == 0
      aDat := { CTOD(""), .f., 0,"",0,"" }
   Else
      aDat := { aMtc[nC,4], .t., aMtc[nC,2],"",0,"" }
   EndIf
   oMtd:Seek( { "ingreso",aMtc[nC,2],"indica"," " } )
   While !oMtd:EOF()
      lSi  := EMPTY( oMtd:CONSEC )
      aDat[4] := XTRIM( oMtd:MARCA ) + oMtd:REFER
      aDat[5] := LEN(ALLTRIM(oMtd:MARCA))
      aDat[6] := "010" + If( oMtd:MATERIAL == "P", "1", "2" )
      FOR nCan := 1 TO oMtd:CANTIDAD
         If lSi
            cCon := STRZERO( ++nCod,6 )
         Else
            cCon := oMtd:CONSEC
         EndIf
         mCodigo := aDat[6] + cCon
         If oApl:oInv:Seek( {"codigo",mCodigo} ) .AND. lSi
            nCan -= 1 ; LOOP
         EndIf
         aFec[3] := "Código = " + mCodigo
         oDlg:Update()
         If lSi
            oApl:oInv:CODIGO    := mCodigo       ; oApl:oInv:GRUPO     := "1"
            oApl:oInv:DESCRIP   := aDat[4]       ; oApl:oInv:CODIGO_NIT:= aMtc[nC,3]
            oApl:oInv:MARCA     := aDat[5]       ; oApl:oInv:TAMANO    := oMtd:TAMANO
            oApl:oInv:MATERIAL  := oMtd:MATERIAL ; oApl:oInv:SEXO      := oMtd:SEXO
            oApl:oInv:TIPOMONTU := oMtd:TIPOMONTU; oApl:oInv:FECRECEP  := aFec[1]
            oApl:oInv:INGRESO   := oMtd:INGRESO  ; oApl:oInv:PCOSTO    := oMtd:PCOSTO
            oApl:oInv:FACTUPRO  := aMtc[nC,5]    ; oApl:oInv:IDENTIF   := oMtd:IDENTIF
            oApl:oInv:LOC_ANTES := aMtc[nC,1]    ; oApl:oInv:INDIVA    := 1
            oApl:oInv:DESPOR    := 0             ; oApl:oInv:MONEDA    := aMtc[nC,6]
            oApl:oInv:COMPRA_D  := aDat[2]
            oApl:oInv:Append( .t. )
         EndIf
            oApl:oInv:OPTICA    := aMtc[nC,1]    ; oApl:oInv:FECREPOS  := aDat[1]
            oApl:oInv:NUMREPOS  := aDat[3]       ; oApl:oInv:PVENDIDA  := 0
            oApl:oInv:PVENTA    := oMtd:PVENTA   ; oApl:oInv:PPUBLI    := oMtd:PPUBLI
            oApl:oInv:FACTUVEN  := 0             ; oApl:oInv:FECVENTA  := CTOD("")
            oApl:oInv:SITUACION := "E"
            oApl:oInv:Update( .f.,1 )
         Actualiz( mCodigo,1,aFec[1],1,oMtd:PCOSTO )
         If oMtd:INDICA == " "
            oMtd:CONSEC := cCon ; oMtd:INDICA := "A"
            oMtd:Update( .f.,1 )
         EndIf
      NEXT nCan
      oMtd:Skip(1):Read()
      oMtd:xLoad()
   EndDo
   oApl:oEmp:CODMONTURA := nCod ; oApl:oEmp:Update( .f.,1 )
NEXT nC
oMtd:Destroy()
oApl:oEmp:Seek( {"optica",nOpt} )
oApl:nEmpresa := nOpt
RETURN