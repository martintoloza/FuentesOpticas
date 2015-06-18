// Programa.: CAOVENTA.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Modulo para la Elaboracion de las Facturas
#include "Fivewin.ch"
#include "TSBrowse.ch"
#include "Btnget.ch"

MEMVAR oApl

#define CLR_PINK  nRGB( 128, 150, 150) //255, 128, 128
#define CLR_NBLUE nRGB( 128, 128, 192)

FUNCTION CaoVenta( lCoti )
   LOCAL oDlg, oLbx, aColor[ 2 ], lNoBlink := .f.
   LOCAL bAyuda, cTit, nA, oAr, oF, oDp
If (aColor[ 1 ] := GetSysColor( COLOR_INACTIVECAPTION ) ) != ;
   GetSysColor( COLOR_ACTIVECAPTION )
   aColor[ 2 ] := GetSysColor( COLOR_INACTCAPTEXT )
   lNoBlink := .t.
   SBNoBlink()
EndIf
  oAr := TInv()     ; oAr:New(,.f.)
  oDp := TPer()     ; oDp:NEW()
  oF  := TFactura() ; oF:New()
cTit  := If( lCoti, "Cotizaciones", "Ventas - Facturas" ) + " || "
oApl:Tipo := oF:cTipo := If( lCoti, "Z", "U" )
oF:Iniciar()
oF:AdicArray()
SETKEY( VK_F4,{|| If( Empresa(), ( oDlg:SetText(cTit + oApl:cEmpresa),;
                      oF:Iniciar(), oDlg:Update() ), ), oF:oG[1]:SetFocus() } )
bAyuda:= {|| oDp:xVar := oF:aM[4], If( oDp:Mostrar( ,3 )    ,;
            (oF:aM[4] := oDp:oDb:NROIDEN, oF:oG[4]:Refresh(),;
             oF:oG[4]:lValid(.f.)), .f. ) }
DEFINE DIALOG oDlg RESOURCE "FACTURAS" TITLE cTit + oApl:cEmpresa OF oApl:oWnd
   REDEFINE SAY           VAR oF:nSigFac  ID  1 OF oDlg UPDATE COLOR "B+/W"
   REDEFINE BTNGET oF:oG[01] VAR oF:aM[2] ID  3 OF oDlg               ;
      RESOURCE "BUSCAR"                                               ;
      ACTION EVAL({|| If(oF:Mostrar(), (oF:aM[2] := oF:oDb:NUMFAC    ,;
                        oApl:nEmpresa := oF:oDb:OPTICA               ,;
                        oApl:Tipo     := oF:oDb:TIPO                 ,;
                        oF:oG[1]:Refresh(), oF:oG[1]:lValid(.f.)),)}) ;
      VALID( If( !oApl:oFac:Seek( { "optica",oApl:nEmpresa,"numfac"  ,;
                      oF:aM[2],"tipo",oApl:Tipo} ) .AND. oF:aM[2] # 0,;
               ( MsgStop("Factura NO EXISTE"), .f. )                 ,;
               (oF:AdicArray(),  oLbx:aArray := oF:aV,  oF:Division(),;
                oDlg:Update(), oF:Dscto( 0,oLbx ) ,;
                If( oApl:oFac:lOK, (oF:oG[1]:oJump := oLbx), ), .t. )))
   REDEFINE GET oF:oG[02] VAR oApl:oFac:FECHOY   ID  5 OF oDlg UPDATE ;
      WHEN !oApl:lEnLinea ;
      VALID(     oF:dFec := oApl:oFac:FECHOY                         ,;
             If( oApl:oFac:lOK .AND. oF:dFec # oApl:oFac:XColumn(5)  ,;
                 oF:CambiaFec(), ), .t. )
   REDEFINE BTNGET oF:oG[03] VAR oF:aM[3]   ID  7 OF oDlg               ;
      RESOURCE "BUSCAR"                                                 ;
      ACTION EVAL({|| If( oAr:oNi:Mostrar( ,,oF:aM[3] ), ( oF:aM[3] :=  ;
                          oAr:oNi:oDb:CODIGO, oF:oG[03]:Refresh() ),) });
      VALID EVAL( {|| If( oAr:oNi:Buscar( oF:aM[3],,.t. )              ,;
                ( oF:Division()                                        ,;
                  oApl:oFac:CODIGO_NIT := oAr:oNi:oDb:CODIGO_NIT       ,;
                  oF:aM[20] := !oAr:oNi:oDb:CONVENIO                   ,;
                  oF:aM[5]  := oAr:oNi:oDb:NOMBRE, oDlg:Update(), .t. ),;
              (If( MsgYesNo("Desea ingresarlo","Este Nit no Existe")   ,;
                  oAr:oNi:Editar( ,.t.,,oF:aM[3] ), ),.f.) ) } ) UPDATE
   REDEFINE SAY           VAR oF:aM[5]      ID  8 OF oDlg UPDATE
   REDEFINE BTNGET oF:oG[04] VAR oF:aM[4]   ID 10 OF oDlg                ;
      RESOURCE "BUSCAR"                                                  ;
      ACTION EVAL( bAyuda )                                              ;
      VALID EVAL( {|| If( EMPTY(oF:aM[4]) .AND. oApl:oFac:CODIGO_NIT # 123,;
                     (oF:oG[05]:Settext( LEFT(oApl:oNit:NOMBRE,30) ), .t.),;
                     (If( !oDp:Buscar( oF:aM[4],"nroiden",.t. ) .AND.    ;
                  !EMPTY(oF:aM[4]), (EVAL( bAyuda )), ( If( oDp:oDb:lOK ,;
             (oApl:oFac:CLIENTE := LEFT(oDp:oDb:NOMBRES,oDp:oDb:PNOMB+1)+;
                oDp:oDb:APELLIDOS  ,  oDp:xVar := oF:aM[4]              ,;
              oApl:oFac:CLIENTE    := XTrim(oApl:oFac:CLIENTE,30)       ,;
              oApl:oFac:DIRECC     := LEFT(oDp:oDb:DIRECCION ,30)       ,;
              oApl:oFac:TELEFONO   :=      oDp:oDb:TEL_RESIDE           ,;
              oApl:oFac:CODIGO_CLI := oDp:oDb:CODIGO_NIT,                ;
              oDlg:Update() ), ), .t. ) ) ) ) } ) UPDATE
    oF:oG[4]:bRClicked = {|| oDp:Listado() }
   REDEFINE GET oF:oG[05] VAR oApl:oFac:CLIENTE  ID 11 OF oDlg UPDATE PICTURE "@!"
   REDEFINE GET oF:oG[06] VAR oApl:oFac:FECHAENT ID 13 OF oDlg UPDATE ;
      WHEN oApl:lEnLinea
   REDEFINE GET oF:oG[07] VAR oApl:oFac:VENDEDOR ID 15 OF oDlg UPDATE PICTURE "@!"
   REDEFINE GET oF:oG[08] VAR oApl:oFac:GAVETA   ID 17 OF oDlg UPDATE PICTURE "999";
      WHEN oApl:lEnLinea
   REDEFINE GET oF:oG[09] VAR oApl:oFac:ORDEN    ID 19 OF oDlg UPDATE
   REDEFINE GET oF:oG[10] VAR oApl:oFac:DIRECC   ID 21 OF oDlg UPDATE PICTURE "@!"
   REDEFINE GET oF:oG[11] VAR oApl:oFac:TELEFONO ID 23 OF oDlg UPDATE
   REDEFINE COMBOBOX oF:oG[12] VAR oF:cTipoF ITEMS ArrayCol( oF:aEps,1 );
      ID 25 OF oDlg UPDATE;
      VALID ( oApl:oFac:TIPOFAC := oF:aEps[oF:oG[12]:nAt,2],;
              oDlg:GoNextCtrl( oF:oG[12]:hWnd ), .t. )
   REDEFINE GET oF:oG[13] VAR oApl:oFac:VALOREPS ID 26 OF oDlg UPDATE ;
      WHEN oApl:oNit:EPS
   REDEFINE GET oF:oG[14] VAR oApl:oFac:FACTEXCE ID 28 OF oDlg UPDATE;
      VALID oF:BuscaFac( oApl:oFac:FACTEXCE,oApl:oFac:FECHOY )
   REDEFINE CHECKBOX oF:oG[15] VAR oApl:oFac:LLEGO ID 29 OF oDlg UPDATE;
      VALID ( oDlg:GoNextCtrl( oF:oG[15]:hWnd ), .t. )
   REDEFINE CHECKBOX oF:oG[16] VAR oF:aM[20] ID 30 OF oDlg UPDATE;
      VALID ( oF:Borrar( "CREDITO" ), oDlg:GoNextCtrl( oF:oG[16]:hWnd ), .t. );
      WHEN oF:aM[3] > 0
   REDEFINE SAY VAR oF:aM[6]    ID 32 OF oDlg PICTURE "999,999,999" UPDATE
   REDEFINE SAY VAR oApl:nSaldo ID 34 OF oDlg PICTURE "999,999,999" UPDATE
   REDEFINE SAY VAR oF:aM[7]    ID 35 OF oDlg UPDATE COLOR nRGB( 255,0,0 )
   ACTIVAGET(oF:oG)

   REDEFINE BROWSE oLbx ID 36 OF oDlg CELLED ;      // CELLED es requerida
      COLORS CLR_BLACK, CLR_NBLUE                   // para editar Celdas
   oLbx:SetArray( oF:aV )     // Esto es necesario para trabajar con arrays
// oLbx:nFreeze     := 2
   oLbx:nHeightCell += 4
   oLbx:nHeightHead += 4
   oLbx:bKeyDown := {|nKey| If(nKey=VK_TAB, oLbx:oJump := oF:oG[3],;
                            If(nKey=VK_F3 , oF:Listado( oDlg,oLbx,.t. ),;
                            If(nKey=VK_F5 , (oF:aM[1] := .t.        ,;
                                 oLbx:KeyDown( VK_DELETE,0 ))       ,;
                            If(nKey=VK_F6 , oF:DelFactu( oDlg,oLbx ),;
                            If(nKey=VK_F7 , oF:Iniciar( oDlg,oLbx)  ,;
                            If(nKey=VK_F11, oF:Guardar( oDlg,oLbx ) ,;
                            If(nKey=VK_F8 , (oF:Abonos(), oF:Iniciar( oDlg,oLbx ))  ,;
                            If(GetKeyState(VK_CONTROL) .AND. nKey=82, oF:Division(oLbx:nAt), )))))))) }
   oLbx:SetAppendMode( oF:lNuevo )            // Activando Auto Append Mode
   oLbx:SetDeleteMode( .t.,.f.,{ |nAt,oLbx| oF:DelArray(oLbx) },;
                  {|oLbx| oF:Dscto( 0,oLbx ) } ) // lOnOff, lConfirm, bDelete

   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 1;
       TITLE "Código"+CRLF+"Artículo"            ;
       SIZE  90 EDITABLE;          // Esta columna es editable
       3DLOOK TRUE, TRUE, TRUE;    // Celda, Titulo, Footers
       MOVE DT_MOVE_NEXT;          // Cursor pasa a la Sig.Columna editable
       VALID { | uVar| oF:Buscar( uVar,oLbx,"S" ) }; // don't want empty rows
       ALIGN DT_LEFT, DT_CENTER  ; // Celda, Titulo, Footer
       PREEDIT {|uVar| oF:aM[11] := uVar, nA := oLbx:nAt ,;
                       oF:aM[15] := If( nA > LEN(oF:aV), 0, oF:aV[nA,10] ) };
       FOOTER { || STR( oLbx:nLen,4 ) + " Items" };
       WHEN oF:EditArray( oLbx )
    oLbx:aColumns[01]:bPostEdit := { |uVar| ;
       oF:aV[nA,01] := oF:aM[11], oF:aV[nA,02] := oF:aM[12],;
       oF:aV[nA,03] := oF:aM[13], oF:aV[nA,05] := oF:aM[15],;
       oF:aV[nA,07] := oF:aM[14], oF:aV[nA,08] := oF:aM[16],;
       oF:aV[nA,11] := oF:aM[14], oF:aV[nA,12] := oF:aM[17],;
       oF:aV[nA,13] := oF:aM[18], oF:aV[nA,14] := oF:aM[19], oF:Dscto( 1,oLbx ) }
     // activando BtnGet para la columna 1 y habilitando una Ayuda
    oLbx:SetBtnGet( 1, "Buscar", { | oGet,cVar | If( oAr:Mostrar() ,;
        (cVar := oAr:oDb:CODIGO, oGet:cText( cVar ), oGet:Refresh(),;
         oGet:KeyDown( VK_RETURN, 0 )), ),;
         oApl:oNit:Seek( {"codigo_nit",oApl:oFac:CODIGO_NIT} ) }, 16 )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 2;
       TITLE "Descripción" ;
       SIZE 180 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER, DT_RIGHT ;
       WHEN oF:EditArray( oLbx );
       FOOTER "Totales->"
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 3;
       TITLE "Precio"+CRLF+"Unitario" PICTURE "99,999,999";
       SIZE  74 ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 4;
       TITLE "Cantidad"      PICTURE "9,999" ;
       SIZE  58 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER ;
       POSTEDIT { |uVar| If( oLbx:lChanged, oF:Dscto( 4,oLbx,uVar ), ) } ;
       WHEN oF:EditArray( oLbx ) ;
       VALID { |uVar| oF:BuscaFac( oLbx:nAt,uVar,4 ) }
//     VALID { |uVar| If( uVar <= 0, ;
//        (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>" ), .f.),;
//        (If( LEFT( oF:aV[oLbx:nAt,01],2 ) == "01" .AND. uVar > 1,;
//        (MsgStop( "En Montura la Cantidad debe ser 1","<< OJO >>" ), .f.), .t. ))) }
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 7;
       TITLE "Precio"+CRLF+"Neto"   PICTURE "99,999,999" ;
       SIZE  76 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       FOOTER { || TRANSFORM( oF:aM[09], "99,999,999" ) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oF:Dscto( 7,oLbx,uVar ), ) };
       WHEN oF:EditArray( oLbx )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 5;
       TITLE "%"+CRLF+"Dscto."   PICTURE "999.99" ;
       SIZE  48 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER ;
       VALID { |uVar| If( Rango( uVar,0,100 ), .t., ;
              (MsgStop( "El Porcentaje debe ser entre 0 y 100",">>OJO<<" ), .f.)) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oF:Dscto( 5,oLbx,uVar ), ) };
       WHEN oF:EditArray( oLbx )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 6;
       TITLE "Descuento"     PICTURE "99,999,999" ;
       SIZE  74 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| oF:BuscaFac( oLbx:nAt,uVar,6 ) } ;
       FOOTER { || TRANSFORM( oF:aM[08], "99,999,999" ) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oF:Dscto( 6,oLbx,uVar ), ) };
       WHEN oF:EditArray( oLbx )
//     VALID { |uVar| If( uVar >= 0, .t., ;
//            (MsgStop("Descuento tiene que ser Positivo","<<OJO>>"), .f.)) };
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 8;
       TITLE "Monto"+CRLF+"I.V.A"   PICTURE "99,999,999" ;
       SIZE  74 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       FOOTER { || TRANSFORM( oF:aM[10], "99,999,999" ) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oF:Dscto( 0,oLbx,uVar ), ) };
       WHEN oF:EditArray( oLbx )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 9;
       TITLE "Indicador" ;
       SIZE  80 ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER
   // Asignando Valores por defaults para nueva Fila creada con Auto Append.
   oLbx:aDefault := { SPACE(12), SPACE(40), 0, 1, 0, 0, 0, 0, " ", 0, 0, 1, 0, "", 0 }
   oLbx:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbx:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color
ACTIVATE DIALOG oDlg CENTERED ON INIT ;
   (oF:DefBar( oDlg,oLbx ), oF:Division() );
    VALID !GetKeyState( VK_ESCAPE )
If( lNoBlink, SBNoBlink( aColor[1], aColor[2] ), Nil )
oApl:oFac:nLimit := 50
oApl:oEmp:Seek( {"optica",oF:nOptica} )
oDp:NEW( "FIN" )
RELEASE oF
SETKEY( VK_F4,{||Empresa()} )
nEmpresa( .f. )
RETURN NIL

//------------------------------------//
CLASS TFactura FROM TNits

 DATA aEps AS ARRAY INIT { {" "," "} }
 DATA aCla AS ARRAY INIT {}
 DATA aSrv AS ARRAY INIT {}
 DATA aBit AS ARRAY INIT {}
 DATA aM   AS ARRAY INIT { .f.,0,0,0,"",0,"",0,0,0,"","",0,0,0,0,0,0,"",.f.,.f. }
 DATA aPag AS ARRAY INIT ArrayCombo( "FPAGO" )
 DATA cTipoF        INIT " "
 DATA lNuevo        INIT .t.
 DATA oG            INIT ARRAY(16)
 DATA aPrv, aV, cDesc, cTipo, dFec, nIva, nSigFac, nOptica

 METHOD NEW( xAnti ) Constructor
 METHOD Iniciar( oDlg,oLbx )
 METHOD AdicArray()
 METHOD Division( nL )
 METHOD EditArray( oLbx,lCambia )
 METHOD Buscar( xBuscar,oLbx,cM )
 METHOD BuscaFac( nFac,dFec,nCol )
 METHOD Dscto( nPos,oLbx,mGetVar )
 METHOD DelArray( oLbx )
 METHOD DelFactu( oDlg,oLbx )
 METHOD CambiaFec()
 METHOD Guardar( oDlg,oLbx )
 METHOD Listado( oDlg,oLbx,lMul )
 METHOD Abonos()
 METHOD Borrar( oLbx )
 METHOD Editar( lNuevo,oLbx )
 METHOD Mostrar( lAyuda,nOrd )
 METHOD DefBar( oDlg,oLbx )
 METHOD Lentes( lOft,nA )
 METHOD Servicios( aL,nAt )
 METHOD SinServic( aL,cSer,nAt,aTEmp,nMate,nTerm,nTipo )
// METHOD AbreCaja( cPort )

ENDCLASS

//------------------------------------//
METHOD NEW( xAnti ) CLASS TFactura
   LOCAL aRes, hRes, nL, cQry, cClase := " "
If xAnti == NIL
   Super:New( oApl:oFac )
   ::aOrden := { {"<None> ",1,.f.},{"Factura",3,.f.},;
                 {"Nombre" ,9,.f.},{"Fecha"  ,5,.f.} }
Else
   Super:New( oApl:oAtc )
   ::aOrden := { {"<None> ",1,.f.},{"Nombre" ,7,.f.},;
                 {"Fecha"  ,3,.f.} }
EndIf
 ::bNew := ::bEditar := ::bVer := ::bBorrar := {||.t. }
cQry := "SELECT clase_mate, tipo_mater, nombre, nombre_cla,"+;
                  " nomcorto, por_dscto, valunidad, pcosto "+;
        "FROM cadtlist WHERE activo = '0' "                 +;
        "ORDER BY clase_mate, tipo_mater, tipol"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aRes[1] # cClase .AND. aRes[1] # "U"
      AADD( ::aCla, { aRes[1] + " " + aRes[4],aRes[1] } )
      cClase := aRes[1]
   EndIf
   If aRes[1] == "S"
      AADD( ::aSrv, { 2,aRes[3],aRes[2],aRes[5],aRes[6],aRes[7],aRes[8] } )
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
If oApl:oEmp:LOCALIZ # oApl:cLocal .AND. oApl:oEmp:TITULAR # "COC"
   oApl:oEmp:Seek( {"localiz",oApl:cLocal} )
   nEmpresa( .t. )
EndIf
 ::oDb:xBlank()
 ::oDb:nLimit := 200
 ::aPrv := Privileg( "FACTURAS" )
 ::aBit := { LoadBitmap( GetResources(), "OK" ),;
             LoadBitmap( GetResources(), "THIS" ) }
RETURN NIL

//------------------------------------//
METHOD Iniciar( oDlg,oLbx ) CLASS TFactura
If oDlg == NIL
   ::nIva    := ROUND( oApl:oEmp:PIVA/100,2 )
   ::nOptica := oApl:nEmpresa
   ::nSigFac := SgteNumero( "numfac"+oApl:Tipo,::nOptica,.f. )
Else
   AEVAL( ::aM, {|xV,nI| ::aM[nI] := {"",CTOD(""),.f.,0}[AT(VALTYPE(xV),"CDLN")] } )
   ::AdicArray() ; oLbx:aArray := ::aV
   ::Division()  ; oApl:oFac:xBlank()
   oDlg:Update() ; oLbx:Refresh()
   ::oG[01]:SetFocus()
EndIf
RETURN NIL

//------------------------------------//
METHOD AdicArray() CLASS TFactura
   LOCAL aRes, hRes, nL, nVal
If ::aM[2] == 0
   ::aM[7] := ""
   ::lNuevo:= .t.
   oApl:oNit:Seek( {"codigo",0} )
   oApl:nEmpresa := ::nOptica ; oApl:Tipo := ::cTipo
   oApl:oFac:lOK       := .f.
   oApl:oFac:FECHOY    := oApl:dFec
   oApl:oFac:FECHAENT  := oApl:dFec + If( DOW( oApl:dFec ) <= 3, 3, 5 )
   oApl:oFac:CODIGO_NIT:= oApl:oNit:CODIGO_NIT
   oApl:oFac:INDICADOR := "C"
   oApl:oFac:VENDEDOR  := If( oApl:cLocal == "COC", "     ", LEFT( oApl:cUser,5 ) )
Else
   oApl:oNit:Seek( {"codigo_nit",oApl:oFac:CODIGO_NIT} )
   oApl:oHis:Seek( {"codigo_nit",oApl:oFac:CODIGO_CLI} )
   If ::nOptica == oApl:oFac:OPTICA
      nVal := AT( oApl:oFac:INDICADOR,"APCN" ) +1
      ::aM[7] := {"","ANULADA","PENDIENTE","CANCELADA","N.Credito"}[nVal]
   Else
      ::aM[7] := ArrayValor( oApl:aOptic,STR(oApl:oFac:OPTICA,2) )
   EndIf
   nVal    := oApl:oFac:FECHOY + If( oApl:nEmpresa == 4, 1, 0 )
   ::aM[21]:= If( nVal > oApl:oEmp:FECVENTA, .t., .f. )
   ::lNuevo:= !oApl:lEnLinea
EndIf
 ::aV := {}
 ::cDesc := ""
aRes := "SELECT v.codart, v.descri, v.ppubli, v.cantidad, v.despor, v.desmon, v.precioven"+;
             ", v.montoiva, v.indicador, v.row_id, v.pcosto, v.ordenemp, c.numero "       +;
        "FROM cadventa v LEFT JOIN cadnotac c USING(optica, numfac)"                      +;
                       " LEFT JOIN cadnotad d"         +;
          " ON c.optica = d.optica"                    +;
         " AND c.numero = d.numero "                   +;
         " AND v.codart = d.codigo "                   +;
        "WHERE v.optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND v.numfac = " + LTRIM(STR(::aM[2]))      +;
         " AND v.tipo   = " + xValToChar( oApl:Tipo )  +;
         " GROUP BY v.row_id"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aRes[09] == "N"
      aRes[09] += "C." + LTRIM(STR(aRes[13]))
   ElseIf ::aM[21] .AND. Rango( LEFT(aRes[01],4),{"0201","0503","0505"} )
      aRes[09] := " *"
   EndIf
   If aRes[01]   == "0203        "
      ::cDesc := ALLTRIM( aRes[02] )
   EndIf
   ::aM[17] := If( aRes[08] == 0, 0, ::nIva ) + 1
   nVal := ROUND( (aRes[07] + aRes[06]) / aRes[04],2 )
   AADD( ::aV,{ aRes[01], aRes[02], aRes[03], aRes[04],;
                aRes[05], aRes[06], aRes[07], aRes[08],;
                aRes[09], aRes[10], nVal    , ::aM[17],;
                aRes[11], aRes[12], aRes[11] } )
   nL --
EndDo
MSFreeResult( hRes )
/*
SELECT v.codart, v.descri, v.ppubli, v.cantidad, v.despor, v.desmon, v.precioven
     , v.montoiva, v.indicador, v.row_id, v.pcosto, v.ordenemp, c.numero
FROM cadventa v LEFT JOIN cadnotac c USING(optica, numfac)
                LEFT JOIN cadnotad d
   ON c.optica = d.optica
  AND c.numero = d.numero
  AND v.codart = d.codigo
WHERE v.optica = 4
  AND v.numfac = 181923
  AND v.tipo   = 'U'
GROUP BY v.row_id

oApl:oVen:Seek( {"optica",oApl:nEmpresa,"numfac",::aM[2],"tipo",oApl:Tipo} )
While !oApl:oVen:Eof()
   ::aM[17] := If( oApl:oVen:MONTOIVA == 0, 0, ::nIva ) + 1
   ::cDesc  := If( oApl:oVen:CODART   == "0203        ", oApl:oVen:DESCRI, ::cDesc )
   nVal := ROUND( (oApl:oVen:PRECIOVEN + oApl:oVen:DESMON)/oApl:oVen:CANTIDAD,2 )
   AADD( ::aV,{ oApl:oVen:CODART    , oApl:oVen:DESCRI        ,;
                oApl:oVen:PPUBLI    , oApl:oVen:CANTIDAD      ,;
                oApl:oVen:DESPOR    , oApl:oVen:DESMON        ,;
                oApl:oVen:PRECIOVEN , oApl:oVen:MONTOIVA      ,;
                oApl:oVen:INDICADOR+"-"+DTOC(oApl:oVen:FECDEV),;
                oApl:oVen:ROW_ID    , nVal,  ::aM[17]         ,;
                oApl:oVen:PCOSTO    , oApl:oVen:ORDENEMP } )
   oApl:oVen:Skip(1):Read()
   oApl:oVen:xLoad()
EndDo
*/
If LEN( ::aV ) == 0
   AADD( ::aV,{ SPACE(12), SPACE(40), 0, 1, 0, 0, 0, 0, " ", 0, 0, 1, 0, "", 0 } )
EndIf
 ::aM[3] := oApl:oNit:CODIGO ; ::aM[5] := oApl:oNit:NOMBRE
 ::aM[4] := If( oApl:oFac:CODIGO_CLI > 0, oApl:oHis:NROIDEN, SPACE(15) )
 ::aM[6] := oApl:oFac:TOTALFAC
 ::aM[20]:= If( oApl:oFac:AUTORIZA == "GRUPO     ", .t., .f. )
 ::dFec  := oApl:oFac:FECHOY
oApl:cPer:= NtChr( ::dFec,"1" )
oApl:lFam:= SaldoFac( ::aM[2] )
SysRefresh()
RETURN NIL

// Limpia el combobox, y lo prepara para llenarlo con
// los items de acuerdo a la nueva opción escogida
METHOD Division( nL ) CLASS TFactura
   LOCAL aPC, cTP, hRes
If nL == NIL
   cTP := If( oApl:oNit:EPS, "EPS", oApl:oNit:TIPOFAC )
   AEVAL( ::aEps, { |x| ::oG[12]:Del(1) } )
   ::aEps := ArrayCombo( cTP )
   AEVAL( ::aEps, { |x| ::oG[12]:Add( x[1] ) } )
   ::cTipoF := ArrayValor( ::aEps,::oDb:TIPOFAC,{|xV| ::oDb:TIPOFAC := xV} )
ElseIf TRIM( oApl:cUser ) == "Martin"
   If oApl:oFac:CODIGO_NIT == 48
      aPC := { "'0201', '0202', '0503', '0505'"," GROUP BY c.numero" }
      cTP := "SELECT 1, SUM(d.cantidad * d.pcosto), c.numero "
   Else
      aPC := { "'0201', '0202'","" }
      cTP := "SELECT d.cantidad, d.pcosto "
   EndIf
   cTP += "FROM cadantid d, cadantic c "        +;
          "WHERE LEFT(d.codart,4) IN(" + aPC[1] +;
          ") AND c.optica = d.optica"           +;
           " AND c.numero = d.numero"           +;
           " AND c.optica = " + If( oApl:oFac:AUTORIZA == "FOCA      ", "21",;
                         LTRIM(STR(oApl:nEmpresa)) )+;
           " AND c.numfac = " + LTRIM(STR(::aM[2])) +;
           " AND c.indicador <> 'A'"   + aPC[2]
   hRes := If( MSQuery( oApl:oMySql:hConnect,cTP ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   aPC  := { 0,0,MSNumRows( hRes ) }
   While aPC[3] > 0
      cTP := MyReadRow( hRes )
      AEVAL( cTP, { | xV,nP | cTP[nP] := MyClReadCol( hRes,nP ) } )
      cTP[2] := (aPC[1] * aPC[2] + cTP[1] * cTP[2]) /;
                (aPC[1] + cTP[1])
      aPC[1] +=        cTP[1]
      aPC[2] := ROUND( cTP[2],2 )
      aPC[3] --
   EndDo
   MSFreeResult( hRes )
   cTP := "PC.A=" + TRANSFORM(::aV[nL,13],"999,999,999.99") + CRLF +;
          "PC.N=" + TRANSFORM(aPC[2],"999,999,999.99")      + CRLF +;
          "CANT=" + TRANSFORM(aPC[1],"999,999,999")
   If MsgNoYes( cTP,"Cambio el Promedio" )
      ::aV[nL,13] := aPC[2]
      aPC := "UPDATE cadventa SET pcosto = " + LTRIM(STR(aPC[2])) +;
                          " WHERE row_id = " + LTRIM(STR(::aV[nL,10]))
      MSQuery( oApl:oMySql:hConnect,aPC )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD EditArray( oLbx,lCambia ) CLASS TFactura
   LOCAL lEdit := .t., nA := oLbx:nAt, nF := 0
If nA > LEN(::aV)
   nF := If( nA > 2, 1, nA-1 )
   If EMPTY( ::aV[nF,1] ) .OR. oLbx:nCell # 1
      MsgStop( "Primero Digite Código del Artículo","Nuevo" )
      oLbx:nAt   := oLbx:nRowPos := oLbx:nLen
      lEdit := .f.
   ElseIf nA > oApl:nItems
      MsgStop( "Ya Van" + STR( oLbx:nLen,3 ) + " Lineas","ITEMS" )
      lEdit := .f.
   EndIf
   If !lEdit
      oLbx:nCell := 1
      oLbx:HiliteCell( 1 ) ; oLbx:Refresh(.t.)
      oLbx:DrawSelect()
   EndIf
Else
 //lCambia := If( ::aV[nA,9] == " *", .f.,;
   lCambia := If( ::aV[nA,9] == " *", !::aPrv[2],;
              If( lCambia == NIL, oApl:lEnLinea, lCambia ) )
   If EMPTY( ::aV[nA,1] ) .AND. oLbx:nCell # 1
      MsgStop( "Primero Digite Código del Artículo" )
      oLbx:nCell := 1 ; lEdit := .f.
      oLbx:HiliteCell( 1 ) ; oLbx:Refresh()
   ElseIf oLbx:nCell == 2 .AND. LEFT(::aV[nA,1],4) == "0201"
      oLbx:nCell := 4 ; lEdit := .f.
      oLbx:HiliteCell( 4 ) ; oLbx:Refresh( .F. )
   ElseIf ::oDb:lOK .AND. (lCambia .OR. LEFT( ::aV[nA,9],1 ) $ "ADN")
      MsgStop( "Este Registro no se Puede Modificar","Lo Siento" )
      lEdit := .f.
   EndIf
EndIf
RETURN lEdit

//------------------------------------//
METHOD Buscar( xBuscar,oLbx,cM ) CLASS TFactura
   LOCAL aMsg, sCod, lExiste, nA, oE := Self
sCod := ALLTRIM( xBuscar )
If LEFT( sCod,2 ) == "01"
   If (nA := ASCAN( ::aV, { |x| x[1] == xBuscar } )) > 0
      MsgStop( ::aV[nA,2],"Código no puede estar 2 VECES" )
      RETURN .f.
   EndIf
EndIf
   lExiste := oApl:oInv:Seek( {"codigo",sCod} )
/*
If !lExiste .AND. oApl:lEnLinea
   aMsg := Buscar( { "codbarra",xBuscar },"cadcodig","codigo" )
   If !EMPTY( aMsg )
      xBuscar := aMsg
      lExiste := oApl:oInv:Seek( {"codigo",xBuscar} )
   EndIf
EndIf
*/
If LEFT( sCod,1 ) >= "6" .AND. SUBSTR( sCod,5,1 ) == " "
   lExiste := .F.
EndIf
If lExiste
   nA := If( oLbx:nAt > LEN(::aV), 0, oLbx:nAt )
   ::aM[17] := If( oApl:oInv:INDIVA == 0, 0, ::nIva ) + 1
   If sCod == "0201" .OR. sCod == "0503" .OR. sCod == "0505" .OR.;
     (sCod == "0202" .AND. ::aM[2] == 0)
      ::aM[13] := 0
      AEVAL( ::aV, { | e | ::aM[13] += If( LEFT( e[1],4 ) == "0201", 1, 0 ) } )
      If sCod == "0201" .AND. nA == 0 .AND. ::aM[13] >= 2
         MsgStop( "En Lentes Oftlamicos solo va un Par de Lentes","Lo Siento" )
         lExiste := .f.
      ElseIf (lExiste := ::Lentes( (sCod == "0201"),nA ))
         xBuscar := If( ::aM[1] .AND. LEFT(sCod,2) == "02", "0503      ", xBuscar )
         ::aM[1] := .f.
      EndIf
   Else
      aMsg := { AT( oApl:oInv:SITUACION,"VDA" ),;
                If( oApl:cPer < NtChr( oApl:oInv:FECREPOS,"1" ), cM, "" ) }
      If ::aM[11] # xBuscar .AND. LEN( sCod ) >= 10 .AND. oApl:oInv:GRUPO == "1" .AND.;
         (aMsg[1] # 0 .OR. oApl:oInv:OPTICA # oApl:nEmpresa .OR. aMsg[2] == "S")
         If aMsg[1] # 0
            aMsg[2] := {"Vendida Fact. ","Devuelta Doc. ","Apartada Cot. "}[aMsg[1]]+;
                    NtChr( oApl:oInv:FACTUVEN,"0" ) + " del " + NtChr( oApl:oInv:FECVENTA,"2" )
         ElseIf aMsg[2] == "S"
            aMsg[2] := "en Reposicion de un mes Superior " + NtChr( oApl:oInv:FECREPOS,"2" )
         EndIf
            aMsg[2] += " en " + ArrayValor( oApl:aOptic,STR(oApl:oInv:OPTICA,2) )
         MsgStop( aMsg[2],"Esta montura esta" )
         RETURN .f.
      EndIf
      ::aM[12] := If( oApl:oInv:GRUPO == "1" .AND. oApl:oInv:MONEDA # "U", "MONTURA ", "" ) +;
                   oApl:oInv:DESCRIP
      ::aM[12] := XTrim( ::aM[12],40 )
      ::aM[19] := ""
      If ::aM[15] == 0
         ::aM[13] := If( oApl:oNit:GRUPO, oApl:oInv:PCOSTO,;
                     If( LEFT( sCod,4 ) == "0501" .AND. oApl:oNit:CONSULTA > 0,;
                         oApl:oNit:CONSULTA, oApl:oInv:PPUBLI ) )
         ::aM[14] := ROUND( ::aM[13] / ::aM[17],0 )
         ::aM[16] := ::aM[13] - ::aM[14]
         ::aM[18] := oApl:oInv:PCOSTO
      Else
         ::aM[13] := ::aV[nA,3]
         ::aM[14] := ROUND((::aV[nA,7] + ::aV[nA,8]) / ::aM[17],0 )
         ::aM[14] := ROUND((::aV[nA,6] + ::aM[14]) / ::aV[nA,4],0 )
         ::aM[16] := ::aV[nA,08]
         ::aM[18] := ::aV[nA,13]
      EndIf
   EndIf
   ::aM[11] := If( nA == 0, 0, ::aV[nA,5] )
   If LEFT( sCod,2 ) $ "0102"
      ::aM[15] := If( ::aM[15] > 0, ::aM[11],;
                  If( oApl:oInv:DESPOR > 0, oApl:oInv:DESPOR,;
                      oApl:oNit:POR_DSCTO ) )
   Else
      ::aM[15] := ::aM[11]                                 //DESPOR
   EndIf
   ::aM[11] := xBuscar
   If LEFT(xBuscar,4) == "0201"
      oLbx:nCell := 4 ; oLbx:HiliteCell( 4 )
      oLbx:Refresh( .F. )
   EndIf
ElseIf !EMPTY( xBuscar )
   MsgStop( "Este Código NO EXISTE !!!",xBuscar )
EndIf
RETURN If( EMPTY( xBuscar ), .f., lExiste )

//------------------------------------//
METHOD BuscaFac( nFac,dFec,nCol ) CLASS TFactura
   LOCAL aFac, cQry, lOK := .t.
If VALTYPE( dFec ) == "D"
   If nFac > 0
      cQry := "SELECT codigo_cli, codigo_nit FROM cadfactu "+;
              "WHERE optica = " + LTRIM(STR(oApl:nEmpresa)) +;
               " AND numfac = " + LTRIM(STR(nFac))          +;
               " AND fechoy >= "+ xValToChar( dFec-15 )
      aFac := Buscar( cQry,"CM",,8 )
      If LEN( aFac ) == 0
         cQry := STRTRAN( cQry,"factu","antic" )
         cQry := STRTRAN( cQry,"hoy"  ,"ha" )
         aFac := Buscar( STRTRAN( cQry,"fac","ero" ),"CM",,8 )
      EndIf
      If LEN( aFac ) == 0
         MsgStop( "Esta Factura o Anticipo no Existe",STR(nFac) )
         lOK := .f.
      ElseIf aFac[1] # ::oDb:CODIGO_CLI .AND.;
           !(aFac[1] == 0 .AND. aFac[2] # 123)
         MsgStop( "Esta Factura o Anticipo no es de este Paciente",STR(nFac) )
         lOK := .f.
      EndIf
   EndIf
ElseIf nCol == 4
   aFac := ::aV[nFac,01]
   If dFec <= 0
      MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>" )
      lOK := .f.
   ElseIf dFec > 1 .AND.;
         (LEFT( aFac,2 ) == "01" .OR. LEFT( aFac,4 ) == "0201")
      cQry := {"Montura","Lentes Oftalmicos"}[AT(SUBSTR( aFac,2,1 ),"12")]
      MsgStop( "La Cantidad debe ser 1","En "+cQry )
      lOK := .f.
   EndIf
ElseIf nCol == 6
   If dFec < 0
      MsgStop( "Descuento tiene que ser Positivo","<<OJO>>" )
      lOK := .f.
   ElseIf dFec > ::aV[nFac,07]
      cQry := "  Descuento" + TRANSFORM( dFec,"$999,999,999" ) + CRLF +;
              "Precio Neto" + TRANSFORM( ::aV[nFac,06]+::aV[nFac,07],"$999,999,999" )
      MsgStop( cQry,"Descuento MAYOR que el Precio Neto" )
      lOK := .f.
   EndIf
EndIf
RETURN lOK

//------------------------------------//
METHOD Dscto( nPos,oLbx,mGetVar ) CLASS TFactura
   LOCAL nSubTot, nA := oLbx:nAt
do Case
Case nPos == 5           // % Descuento
   ::aV[nA,06] := If( mGetVar == 0, 0, ::aV[nA,06] )
Case nPos == 7           // Precio Neto
   If ::aV[nA,04] > 1 .AND. mGetVar > 0
      If !MsgYesNo( "Este es el Precio Unitario","DIVIDIR" )
         mGetVar := ROUND( mGetVar / ::aV[nA,04],2 )
      EndIf
   EndIf
   If ::aV[nA,12] > 1 .AND. mGetVar > 0
      If MsgYesNo( "Precio con IVA incluido","I.V.A." )
         mGetVar := ROUND( mGetVar / ::aV[nA,12],0 )
      EndIf
   EndIf
   ::aV[nA,11] := mGetVar
EndCase
If Rango( nPos,1,7 )
   nSubTot    := ROUND( ::aV[nA,11] * ::aV[nA,04],0 )
   If oApl:oInv:GRUPO == "6" .AND. !oApl:oNit:GRUPO
      nSubTot := Redondear( nSubTot,5,10 )
   EndIf
   ::aV[nA,6] := If( nPos == 6, mGetVar, If( ::aV[nA,05] = 0, ::aV[nA,06],;
                     ROUND( nSubTot * ::aV[nA,5] / 100,0 ) ) )
   ::aV[nA,7] := nSubTot - ::aV[nA,06]
   ::aV[nA,8] := ROUND( ::aV[nA,07] * ::aV[nA,12],0 ) - ::aV[nA,7]
EndIf
::aM[08] := ::aM[09] := ::aM[10] := 0
AEVAL( ::aV, { | e | ::aM[08] += e[ 6 ], ::aM[09] += e[ 7 ], ;
                     ::aM[10] += e[ 8 ] } )
::aM[09] += ::aM[10]
If ::oDb:TOTALDES  # ::aM[08] .OR. ::oDb:TOTALIVA # ::aM[10] .OR.;
   ::oDb:TOTALFAC  # ::aM[09] .OR. oLbx:lChanged
   ::oDb:TOTALDES := ::aM[08] ; ::oDb:TOTALIVA := ::aM[10]
   ::oDb:TOTALFAC := ::aM[09]
  //oApl:oFac:TOTALFAC := ::aM[09]
EndIf
oLbx:Refresh() ; oLbx:DrawFooters()
RETURN NIL

//------------------------------------//
METHOD DelArray( oLbx ) CLASS TFactura
   LOCAL dFecdev, lSi := .f., nA := oLbx:nAt
do Case
Case ::aV[nA,10] == 0
   lSi := .t.
Case !::aM[1] .AND. !oApl:lEnLinea .AND.;
     !LEFT( ::aV[nA,09],1 ) $ "ADN"
   If MsgNoYes( "Devuelve este Código",::aV[nA,01] )
      dFecdev := FechaDev( "Fecha Devolución",oApl:oFac:FECHOY )
      oApl:oInv:Seek( {"codigo",::aV[nA,01]} )
      If oApl:cPer # LEFT( DTOS( dFecdev ),6 ) .AND. oApl:oInv:MONEDA == "C"
         MsgStop( "Llamar a [EUNICE] para que le haga nuevo Código" )
         RETURN lSi
      EndIf
      ::aV[nA,09]:= "D-" + DTOC( dFecdev )
      oApl:oVen:Seek( {"row_id",::aV[nA,10]} )
      GrabaV( ::aV[nA,04],"S",7,dFecdev,0 )
      oApl:oVen:INDICADOR := "D" ; oApl:oVen:FECDEV := dFecdev
      Guardar( oApl:oVen,.f.,.f. )
      oLbx:Refresh()
   EndIf
Case ::aM[1] .AND. oApl:oFac:lOK .AND. !oApl:lEnLinea
   If MsgNoYes( "Elimina este Código",::aV[nA,01] )
      oApl:oVen:Seek( {"row_id",::aV[nA,10]} )
      If LEFT( ::aV[nA,09],1 ) $ "AD"
         GrabaV( -::aV[nA,04],"S",7,oApl:oVen:FECDEV,0 )
      EndIf
      GrabaV( -::aV[nA,04],"S",2,oApl:oFac:FECHOY,0 )      // Reversa Inventarios
      oApl:oVen:Delete(.f.,1)
      lSi := .t.
   EndIf
EndCase
::aM[1] := .f.
RETURN lSi

//------------------------------------//
METHOD DelFactu( oDlg,oLbx ) CLASS TFactura
   LOCAL dFecdev, cPerF := oApl:cPer, mCant, nTipo, nR
If !oApl:oFac:lOK
   If EMPTY( ::aV[1,01] )
      oApl:oFac:INDICADOR := "A"
      ::Guardar( oDlg,oLbx )
   EndIf
ElseIf oApl:oFac:INDICADOR # "A"
   If oApl:lEnLinea .AND. oApl:oFac:FECHOY < oApl:dFec
      MsgStop( "Factura se Anula con una Nota Credito","<<< OJO >>>" )
   ElseIf Login( "Desea Anular esta Factura" )
      dFecdev   := FechaDev( "Fecha Anulación",oApl:oFac:FECHOY )
      oApl:cPer := NtChr( dFecdev,"1" )
      oApl:lFam := SaldoFac( ::aM[2] )
      nTipo     := If( oApl:cPer > cPerF, 7, 2 )
      If oApl:oFac:REMPLAZA > 0
         nR    := If( oApl:oFac:AUTORIZA == "FOCA      ", 21, oApl:nEmpresa )
         cPerF := "UPDATE cadantic SET numfac = 0 "  +;
                  "WHERE optica = " + LTRIM(STR(nR)) +;
                   " AND numfac = " + LTRIM(STR(::aM[2]))
         //        " AND numero = " + LTRIM(STR(oApl:oFac:REMPLAZA))
         MSQuery( oApl:oMySql:hConnect,cPerF )
         oApl:oFac:REMPLAZA := 0
      EndIf
      oApl:oFac:INDICADOR := "A" ; oApl:oFac:FECHAENT := dFecdev
      Guardar( oApl:oFac,.f.,.f. )
      GrabaSal( ::aM[2],1,oApl:nSaldo )
      cPerF := If( oApl:lEnLinea, "DELETE FROM cadpagos"    ,;
                    "UPDATE cadpagos SET indicador = 'A'" ) +;
              " WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
                " AND numfac = " + LTRIM(STR(::aM[2]))      +;
                " AND tipo  = '" + oApl:Tipo + "'"
      MSQuery( oApl:oMySql:hConnect,cPerF )
      FOR nR := 1 TO LEN( ::aV )
         If ::aV[nR,10] > 0 .AND. LEFT( ::aV[nR,09],1 ) == " "
            oApl:oVen:Seek( {"row_id",::aV[nR,10]} )
            mCant := ::aV[nR,04] * If( nTipo = 2, -1, 1 )
            GrabaV( mCant,"S",nTipo,dFecdev,0 )
            If oApl:lEnLinea .AND. nTipo == 2
               oApl:oVen:Delete(.f.,1)
            Else
               oApl:oVen:INDICADOR := If( nTipo == 2, "A", "D" )
               oApl:oVen:FECDEV    := dFecdev ; Guardar( oApl:oVen,.f.,.f. )
            EndIf
         EndIf
      NEXT
      ::Iniciar( oDlg,oLbx )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD CambiaFec() CLASS TFactura
   LOCAL nR, lPrecio := oApl:cPer # NtChr( oApl:oFac:FECHOY,"1" )
   LOCAL dFec := oApl:oFac:XColumn( 5 ) //Fac->FECHOY
FOR nR := 1 TO LEN( ::aV )
   If ::aV[nR,10] > 0
      oApl:oVen:Seek( {"row_id",::aV[nR,10]} )
      If oApl:oVen:FECFAC == dFec
         oApl:oVen:FECFAC := oApl:oFac:FECHOY ; Guardar( oApl:oVen,.f.,.f. )
         If lPrecio
            GrabaV( -::aV[nR,4],"N",2,dFec,0 )             // Reversa Inventarios
            GrabaV(  ::aV[nR,4],"N",2,oApl:oFac:FECHOY,0 )
         EndIf
      EndIf
   EndIf
NEXT
oApl:oPag:Seek( {"optica",oApl:nEmpresa,"numfac",::aM[2],"tipo",oApl:Tipo} )
While !oApl:oPag:Eof()
   If oApl:oPag:FECPAG == dFec
      oApl:oPag:FECPAG := oApl:oFac:FECHOY ; Guardar( oApl:oPag,.f.,.f. )
   EndIf
   oApl:oPag:Skip(1):Read()
   oApl:oPag:xLoad()
EndDo
Guardar( oApl:oFac,.f.,.f. )
If lPrecio
   If oApl:oFam:Seek( { "optica",oApl:nEmpresa,"numfac",::aM[2],;
                        "tipo",oApl:Tipo,"anomes",oApl:cPer } )
      oApl:cPer := NtChr( oApl:oFac:FECHOY,"1" )
      oApl:oFam:ANOMES := oApl:cPer
      Guardar( oApl:oFam,.f.,.f. )
   EndIf
EndIf
MsgInfo( "El cambio de Fecha","HECHO" )
RETURN NIL

//------------------------------------//
METHOD Guardar( oDlg,oLbx ) CLASS TFactura
   LOCAL aPago := {}, cFactu := "numfac"+oApl:Tipo, lCambio
   LOCAL nPago := 0, nAbono := 0, nValor := 0, nR := 0
If oApl:oFac:lOK .AND. CierreInv( oApl:oFac:FECHOY,"FACTURA" )
   RETURN NIL
ElseIf EMPTY( ::aV[1,1] ) .AND. oApl:oFac:INDICADOR # "A"
   MsgInfo( "Factura no Tiene ningun Items" )
   RETURN NIL
ElseIf EMPTY( ::aM[4] ) .AND. oApl:oFac:FECHOY >= CTOD("01.12.2011")
   MsgInfo( "Doc. Identidad es Obligatorio",">>> OJO <<<" )
   ::oG[4]:SetFocus()
   RETURN NIL
EndIf
oApl:cPer := NtChr( oApl:oFac:FECHOY,"1" )
If !oApl:oFac:lOK
   oApl:nSaldo := If( oApl:Tipo == "Z", 0, oApl:oFac:TOTALFAC ) // .OR. ::aM[3] > 0
   While oApl:lEnLinea .AND. oApl:nSaldo > 0
      If CaoPagos(,,::aPag) .AND. !EMPTY( oApl:oPag:ABONO )
         nAbono += oApl:oPag:PAGADO
         nPago  := oApl:oPag:ABONO     + oApl:oPag:DEDUCCION +;
                   oApl:oPag:RETENCION + oApl:oPag:DESCUENTO +;
                   oApl:oPag:RETIVA    + oApl:oPag:RETICA    + oApl:oPag:RETCRE
         nValor += nPago
         oApl:nSaldo -= nPago
         AADD( aPago, { oApl:oPag:ABONO    , oApl:oPag:RETENCION,;
                        oApl:oPag:DEDUCCION, oApl:oPag:DESCUENTO,;
                        oApl:oPag:NUMCHEQUE, oApl:oPag:CODBANCO ,;
                        oApl:oPag:FORMAPAGO, oApl:oPag:INDRED   ,;
                        oApl:oPag:PAGADO   , oApl:oPag:RETIVA   ,;
                        oApl:oPag:RETICA   , oApl:oPag:RETCRE })
      Else
         Exit
      EndIf
   EndDo
   nR := SgteNumero( cFactu,oApl:nEmpresa,.f. )
   If !MsgYesNo("Factura #"+STR(nR),"Graba esta")
      RETURN NIL
   EndIf
   If !oApl:lEnLinea
      oApl:dFec := oApl:oFac:FECHOY
   ElseIf oApl:oFac:FECHOY < oApl:oEmp:FEC_HOY
      oApl:oFac:FECHOY   := oApl:oEmp:FEC_HOY
      oApl:oFac:FECHAENT := oApl:oFac:FECHOY + If( DOW( oApl:oFac:FECHOY ) <= 3, 3, 5 )
      oApl:cPer:= NtChr( oApl:oFac:FECHOY,"1" )
   EndIf
   oApl:oFac:OPTICA  := oApl:nEmpresa
   oApl:oFac:TIPO    := oApl:Tipo
   oApl:oFac:NUMFAC  := SgteNumero( cFactu,oApl:nEmpresa )
   oApl:oFac:FECHAENT:= If( oApl:oFac:INDICADOR == "A", oApl:dFec, oApl:oFac:FECHAENT )
   ::Borrar( If( nAbono == 0, "CREDITO", "CONTADO" ) )
/*   If oApl:oFac:CODIGO_NIT # 123
      If (nPago := oApl:oFac:TOTALFAC - oApl:oFac:TOTALIVA) >= oApl:oEmp:TOPERET
         oApl:oFac:RETFTE := ROUND( nPago * oApl:oEmp:PRET,0 )
      EndIf
   EndIf*/
   BuscaDup( oApl:oFac:NUMFAC,oApl:Tipo,.t. )
   Guardar( oApl:oFac,.t.,.t. )
// oApl:oFac:Append( .t. )
   oApl:nSaldo := oApl:oFac:TOTALFAC // - oApl:oFac:RETFTE
   ::nSigFac   := oApl:oFac:NUMFAC + 1
   lCambio := .t. ; oApl:lFam := .f.
   nPago   := nAbono
   nR      := 1
   ::Servicios( ,0 )
Else
   If (lCambio := oApl:oFac:TOTALFAC # ::aM[6])
      If !MsgNoYes( TRANSFORM( oApl:oFac:TOTALFAC,"NUEVO 999,999,999" ) +;
         TRANSFORM( ::aM[6]," - VIEJO 999,999,999" ),"EL TOTAL ES DIFERENTE" )
         RETURN NIL
      EndIf
   EndIf
   If (oApl:lFam := SaldoFac( ::aM[2] ))
      nPago := oApl:oFac:TOTALFAC - ::aM[6]
      oApl:nSaldo += nPago
   Else
      oApl:nSaldo := oApl:oFac:TOTALFAC
   EndIf
   ::Servicios( ,1 )
EndIf
If lCambio .AND. oApl:Tipo # "Z"
   nAbono := oApl:nSaldo - nPago
   oApl:oFac:INDICADOR:= If( nAbono == 0, oApl:oFac:INDICADOR, "P" )
   oApl:oFac:FECHACAN := If( nAbono == 0, oApl:oFac:FECHOY, CTOD("") )
/* If (oApl:nSaldo - nPago) == 0
      oApl:oFac:FECHACAN := oApl:oFac:FECHOY
   Else
      oApl:oFac:FECHACAN := CTOD("") ; oApl:oFac:INDICADOR := "P"
   EndIf*/
   If oApl:nEmpresa == 0
           nAbono := oApl:oFac:TOTALFAC - oApl:oFac:TOTALIVA
      oApl:aInvme := Retenciones( oApl:oFac:FECHOY,nAbono,oApl:oFac:CODIGO_NIT )
      oApl:nSaldo -= (oApl:aInvme[1] + oApl:aInvme[2] + oApl:aInvme[3])
   EndIf
   GrabaSal( oApl:oFac:NUMFAC,nR,nPago )
EndIf
Guardar( oApl:oFac,.f.,.f. )
If oApl:oEmp:DTOCOMER > 0
   ::Servicios( "Descuento COSTO de Lentes o Servicios" )
EndIf

FOR nR := 1 TO LEN( ::aV )
   If !EMPTY( ::aV[nR,01] ) .AND. LEFT( ::aV[nR,09],1 ) == " "
      nAbono := 0
      ::aV[nR,1] := UPPER(LTRIM(::aV[nR,1]))
      ::aV[nR,2] := UPPER(::aV[nR,2])
      If ::aV[nR,5] == 0
         ::aV[nR,5] := ROUND( (::aV[nR,6] / (::aV[nR,6]+::aV[nR,7]))*100,2 )
      EndIf
         oApl:oVen:Seek( {"row_id",::aV[nR,10]} )
      If (lCambio := (::aV[nR,10] == 0))
         oApl:oVen:OPTICA   := oApl:nEmpresa
         oApl:oVen:NUMFAC   := oApl:oFac:NUMFAC
         oApl:oVen:TIPO     := oApl:Tipo  ; oApl:oVen:FECFAC    := oApl:oFac:FECHOY
      // Guardar( oApl:oVen,.t.,.t. )
      Else
         nAbono    := oApl:oVen:CANTIDAD * -1
         If oApl:oVen:CODART # ::aV[nR,01]
            GrabaV( nAbono,"S",2,oApl:oFac:FECHOY,0 )
            nAbono := 0
         EndIf
      EndIf
         oApl:oVen:CODART   := ::aV[nR,1] ; oApl:oVen:DESCRI    := ::aV[nR,2]
         oApl:oVen:CANTIDAD := ::aV[nR,4] ; oApl:oVen:PRECIOVEN := ::aV[nR,7]
         oApl:oVen:DESPOR   := ::aV[nR,5] ; oApl:oVen:DESMON    := ::aV[nR,6]
         oApl:oVen:MONTOIVA := ::aV[nR,8] ; oApl:oVen:PPUBLI    := ::aV[nR,3]
         oApl:oVen:PCOSTO   := ::aV[nR,13]; oApl:oVen:ORDENEMP  := ::aV[nR,14]
         Guardar( oApl:oVen,lCambio,lCambio )
      nAbono += ::aV[nR,4]
      GrabaV( nAbono,"N",2,oApl:oFac:FECHOY,0,1 )
   EndIf
NEXT nR
If oApl:lEnLinea .AND. oApl:oFac:NUMFAC # ::aM[2] .AND. oApl:Tipo # "Z"
   If LEN( aPago ) > 0
      oApl:oPag:xBlank()                   ; oApl:oPag:OPTICA   := oApl:nEmpresa
      oApl:oPag:NUMFAC := oApl:oFac:NUMFAC ; oApl:oPag:TIPO     := oApl:Tipo
      oApl:oPag:FECPAG := oApl:oFac:FECHOY ; oApl:oPag:PORDONDE := "F"
      oApl:oPag:RCAJA  := RCaja( .f.,123,oApl:oPag:FECPAG,"F" )
   EndIf
   FOR nR := 1 TO LEN( aPago )
      oApl:oPag:ABONO     := aPago[nR,01]; oApl:oPag:RETENCION := aPago[nR,02]
      oApl:oPag:DEDUCCION := aPago[nR,03]; oApl:oPag:DESCUENTO := aPago[nR,04]
      oApl:oPag:NUMCHEQUE := aPago[nR,05]; oApl:oPag:CODBANCO  := aPago[nR,06]
      oApl:oPag:FORMAPAGO := aPago[nR,07]; oApl:oPag:INDRED    := aPago[nR,08]
      oApl:oPag:PAGADO    := aPago[nR,09]; oApl:oPag:RETIVA    := aPago[nR,10]
      oApl:oPag:RETICA    := aPago[nR,11]; oApl:oPag:RETCRE    := aPago[nR,12]
      Guardar( oApl:oPag,.t.,.f. )
   NEXT
   oApl:nSaldo := oApl:oFac:TOTALFAC - nValor
   CaoLiFac( oApl:oFac:NUMFAC,::aV,{::aM[4],::cTipoF} )
// ::AbreCaja( "COM1:" )
EndIf
oLbx:nCell := oLbx:nColPos := 1
oLbx:HiliteCell( 1 )
::Iniciar( oDlg,oLbx )
RETURN NIL

//------------------------------------//
METHOD Listado( oDlg,oLbx,lMul ) CLASS TFactura
   LOCAL aLF
If oApl:oFac:lOK .AND.;
  (oApl:lEnLinea .OR. TRIM( oApl:cUser ) == "Martin")
   If MsgNoYes( "Imprime esta Factura" )
      CaoLiFac( oApl:oFac:NUMFAC,::aV,{::aM[4],::cTipoF} )
      If lMul
         aLF := ::aM[2]
         MsgGet( "Imprimir Varias Facturas","Factura Final",@aLF )
         aLF := { ,::aM[2]+1,aLF }
         FOR aLF[1] := aLF[2] TO aLF[3]
            ::aM[2] := aLF[1]
            If oApl:oFac:Seek( {"optica",oApl:nEmpresa,"numfac",::aM[2],"tipo",oApl:Tipo} )
               ::AdicArray()
               ::Division()
               CaoLiFac( ::aM[2],::aV,{::aM[4],::cTipoF} )
            EndIf
         NEXT aLF[1]
      EndIf
      ::Iniciar( oDlg,oLbx )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Abonos() CLASS TFactura
   LOCAL oDlg, oLbp, oLbf, oGet := ARRAY(3), aEst, aFac, nEst
If ::aM[2] == 0 .OR. !oApl:oFac:lOK .OR. oApl:oFac:TIPO == "Z"
   RETURN NIL
EndIf
aEst := { "","ANULADA","PENDIENTE","CANCELADA","N.Credito","999,999,999.99" }
aFac := ArrayCol( ::aPag,1 )
nEst := AT( oApl:oFac:INDICADOR,"APCN" )
AEVAL( { "","","N.Credito","N.Debito","Anulada" }, {|cVal| AADD( aFac,cVal ) } )
oApl:oFam:Seek( {"optica",oApl:nEmpresa,"numfac",::aM[2],"tipo",oApl:Tipo,;
                 "anomes >= ",NtChr( oApl:oFac:FECHOY,"1" )},"anomes",.f. )
oApl:cPer   := NtChr( DATE(),"1" )
oApl:nSaldo := oApl:oFam:SALDO
oApl:oPag:Seek( {"optica",oApl:nEmpresa,"numfac",::aM[2],"tipo",oApl:Tipo},;
                 "fecpag" )
DEFINE DIALOG oDlg RESOURCE "PAGOSFAC"
   REDEFINE SAY VAR oApl:oFac:NUMFAC   ID  1 OF oDlg
   REDEFINE SAY VAR oApl:oFac:CLIENTE  ID  2 OF oDlg
   REDEFINE SAY VAR oApl:oFac:FECHOY   ID  4 OF oDlg
   REDEFINE SAY VAR oApl:oFac:FECHAENT ID  6 OF oDlg
   REDEFINE SAY VAR oApl:oFac:REMPLAZA ID  8 OF oDlg
   REDEFINE SAY VAR aEst[nEst+1]       ID 10 OF oDlg UPDATE COLOR nRGB( 255,0,0 )
   REDEFINE GET oGet[1] VAR oApl:oFac:FECHACAN ID 11 OF oDlg        ;
      WHEN Rango( nEst,2,3 )                                        ;
      VALID EVAL({|| If( oApl:oFac:FECHACAN # oApl:oFac:XColumn(16),;
                       ( oApl:oFac:INDICADOR :=                     ;
                        If( EMPTY( oApl:oFac:FECHACAN ), "P", "C" ),;
                        nEst := AT( oApl:oFac:INDICADOR, "APCN" )  ,;
                        oApl:oFac:Update(.f.,1), oDlg:Update() ), ),;
                        oGet[1]:oJump := oLbp, .t. } )
   REDEFINE SAY VAR oApl:oFac:TOTALFAC ID 13 OF oDlg PICTURE aEst[6]
   REDEFINE SAY VAR oApl:nSaldo        ID 15 OF oDlg PICTURE aEst[6] UPDATE
   REDEFINE LISTBOX oLbp FIELDS       ;
         DTOC( oApl:oPag:FECPAG )    ,;
          aFac[oApl:oPag:FORMAPAGO+1],;
               oApl:oPag:CODBANCO    ,;
    TRANSFORM( oApl:oPag:PAGADO   ,aEst[6]),;
    TRANSFORM( oApl:oPag:ABONO    ,aEst[6]),;
    TRANSFORM( oApl:oPag:DEDUCCION,aEst[6]),;
    TRANSFORM( oApl:oPag:RETENCION,aEst[6]),;
    TRANSFORM( oApl:oPag:DESCUENTO,aEst[6]),;
               oApl:oPag:NUMCHEQUE   ,;
          STR( oApl:oPag:RCAJA )      ;
      HEADERS "Fecha", "FormaPago", "Banco", "Total Pago", "Monto Pago" ,;
              "DEDUCCION", "RETENCION", "DESCUENTO", "DOCUMENTO", "RCAJA";
      ID 20 OF oDlg UPDATE
    oLbp:nClrBackHead  := oApl:nClrBackHead
    oLbp:nClrForeHead  := oApl:nClrForeHead
    oLbp:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbp:nClrBackFocus := oApl:nClrBackFocus
    oLbp:nClrForeFocus := oApl:nClrForeFocus
    oLbp:nHeaderHeight := 28
    oLbp:GoTop()
    oLbp:oFont      := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbp:aColSizes  := {60,64,40,82,82,82,82,82,94,60}
    oLbp:aHjustify  := {2,2,2,2,2,2,2,2,2,2}
    oLbp:aJustify   := {1,0,2,1,1,1,1,1,0,1}
    oLbp:lCellStyle := oLbp:ladjbrowse := .f.
    oLbp:ladjlastcol:= .t.
    oLbp:cToolTip := "[Ctrl] + [Supr] Borrar Pago"
    oLbp:bKeyDown := {|nKey| If(nKey = VK_RETURN .AND. oApl:oPag:FORMAPAGO < 5, (CaoPagos(.t.,.f.,::aPag), oLbf:Refresh()),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, ::Borrar(oLbp), ) ) }
   MySetBrowse( oLbp, oApl:oPag )

   REDEFINE LISTBOX oLbf FIELDS ;
               oApl:oFam:ANOMES,;
    TRANSFORM( oApl:oFam:SALDO ,aEst[6]),;
    TRANSFORM( oApl:oFam:ABONOS,aEst[6]),;
    TRANSFORM( oApl:oFam:DEBITO,aEst[6]) ;
      HEADERS "AñoMes", "Saldo", "Abonos", "Debitos" ;
      ID 22 OF oDlg UPDATE
    oLbf:nClrBackHead  := oApl:nClrBackHead
    oLbf:nClrForeHead  := oApl:nClrForeHead
    oLbf:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbf:nClrBackFocus := oApl:nClrBackFocus
    oLbf:nClrForeFocus := oApl:nClrForeFocus
    oLbf:nHeaderHeight := 28
    oLbf:GoTop()
    oLbf:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbf:aColSizes  := {70,100,100,100}
    oLbf:aHjustify  := {2,2,2,2}
    oLbf:aJustify   := {0,1,1,1}  // O Derecha, 1 Izquierda, 2 Centro
    oLbf:lCellStyle := .f.
    oLbf:bKeyDown := {|nKey| If(nKey == VK_RETURN, ::Editar(.f.,oLbf),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, ::Editar(.t.,oLbf),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, DelRecord(oApl:oFam,oLbf), ))) }
   MySetBrowse( oLbf, oApl:oFam )
//   REDEFINE BUTTON oGet[02] ID 27 OF oDlg ACTION ::Listado()
   REDEFINE BUTTON oGet[02] ID 28 OF oDlg ACTION oDlg:End()
ACTIVATE DIALOG oDlg CENTER

RETURN NIL

//------------------------------------//
METHOD Borrar( oLbx ) CLASS TFactura
If VALTYPE( oLbx ) # "C"
   If oApl:oPag:FORMAPAGO <= 4
      If Login( "Quiere Borrar este Pago" )
         If oApl:oPag:PAGADO # 0 .AND. oApl:oFac:INDICADOR # "A"
            oApl:oFac:INDICADOR := "P" ; oApl:oFac:FECHACAN := CTOD("")
            Guardar( oApl:oFac,.f.,.f. )
            oApl:cPer := NtChr( oApl:oPag:FECPAG,"1" )
            oApl:lFam := SaldoFac( oApl:oPag:NUMFAC )
            GrabaSal( oApl:oPag:NUMFAC,1,-oApl:oPag:PAGADO )
            oApl:cPer := NtChr( oApl:dFec,"1" )
         EndIf
         oApl:oPag:Delete(.f.,1)
         oLbx:Refresh()
      EndIf
   EndIf
ElseIf ::aM[2] > 0
   oLbx := "SELECT 'CONTADO' FROM cadpagos "            +;
           "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND numfac = " + LTRIM(STR(::aM[2]))      +;
            " AND pordonde IN('A', 'F')"
   oLbx := Buscar( oLbx,"CM",,8 )
   oApl:oFac:AUTORIZA:= If( ::aM[20]   , "GRUPO"   ,;
                        If( ::aM[3] > 0, "LIBRANZA",;
                        If( EMPTY(oLbx), "CREDITO", "CONTADO" )))
   Guardar( oApl:oFac,.f.,.f. )
Else
   oApl:oFac:AUTORIZA:= If( ::aM[20]   , "GRUPO"   ,;
                        If( ::aM[3] > 0, "LIBRANZA", oLbx ) )
EndIf
RETURN NIL

//------------------------------------//
METHOD Editar( lNuevo,oLbx ) CLASS TFactura
   LOCAL oDlg, oGet := ARRAY(06)
   LOCAL aED := { .f.,"Modificando Saldo","999,999,999" }
If !oApl:lEnLinea
   If lNuevo
      If MsgYesNo("Adicionar un Registro","Quiere")
         aED[2] := "Nuevo Saldo"
         oApl:oFam:xBlank()
         oApl:oFam:OPTICA := oApl:nEmpresa ; oApl:oFam:NUMFAC := oApl:oFac:NUMFAC
         oApl:oFam:TIPO   := oApl:Tipo     ; oApl:oFam:ANOMES := oApl:cPer
      EndIf
   Else
      oApl:oFam:xLoad()
   EndIf
EndIf
DEFINE DIALOG oDlg TITLE aED[2] FROM 00,02 TO 10,40
   @ 02,00 SAY "Año y Mes"     OF oDlg RIGHT PIXEL SIZE 46,10
   @ 02,50 GET oGet[01] VAR oApl:oFam:ANOMES OF oDlg PICTURE "999999";
      SIZE 30,10 PIXEL
   @ 14,00 SAY "Saldo Factura" OF oDlg RIGHT PIXEL SIZE 46,10
   @ 14,50 GET oGet[02] VAR oApl:oFam:SALDO  OF oDlg PICTURE aED[3];
      SIZE 40,10 PIXEL
   @ 28,00 SAY "Total Abonos"  OF oDlg RIGHT PIXEL SIZE 46,10
   @ 28,50 GET oGet[03] VAR oApl:oFam:ABONOS OF oDlg PICTURE aED[3];
      SIZE 40,10 PIXEL
   @ 40,00 SAY "Total Debitos" OF oDlg RIGHT PIXEL SIZE 46,10
   @ 40,50 GET oGet[04] VAR oApl:oFam:DEBITO OF oDlg PICTURE aED[3];
      SIZE 40,10 PIXEL
   @ 58,30 BUTTON oGet[05] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ACTION ;
      (If( EMPTY(oApl:oFam:ANOMES) .OR. oApl:oFam:ABONOS < 0            ,;
         ( MsgStop("Imposible grabar este Saldo"), oGet[1]:SetFocus() ) ,;
         ( aEd[1] := .t., oDlg:End() ))) PIXEL
   @ 58,80 BUTTON oGet[06] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL ;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER;
   WHEN !oApl:lEnLinea
If aEd[1]
   If lNuevo
      oApl:oFam:Append(.t.)
   Else
      oApl:oFam:Update(.t.,1)
   EndIf
   oLbx:Refresh()
EndIf

RETURN NIL

//------------------------------------//
METHOD Mostrar( lAyuda,nOrd ) CLASS TFactura
   LOCAL oDlg, oM := Self, lReturn := .f.
   LOCAL bHacer := {|| lReturn := .t., oDlg:End() }
   DEFAULT lAyuda := .t. , nOrd := 3
nOrd := ::Ordenar( nOrd )

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE "Ayuda de Facturas"
   @ 1.5, 0 LISTBOX ::oLbx FIELDS  ;
               STR( ::oDb:NUMFAC ),;
              DTOC( ::oDb:FECHOY ),;
                    ::oDb:CLIENTE ,;
        ArrayValor( oApl:aOptic,STR(::oDb:Optica,2) );
      HEADERS "Número"+CRLF+"Factura","Fecha","Cliente", "Optica" ;
      SIZES 400, 450 SIZE 200,107  ;
      ON DBLCLICK EVAL(bHacer)
    ::oLbx:nClrBackHead  := oApl:nClrBackHead
    ::oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    ::oLbx:nClrBackFocus := oApl:nClrBackFocus
    ::oLbx:nClrForeFocus := oApl:nClrForeFocus
    ::oLbx:nHeaderHeight := 28
    ::oLbx:GoTop()
    ::oLbx:oFont       := ::oFont
    ::oLbx:aColSizes   := {70,70,200,60}
    ::oLbx:aHjustify   := {2,2,2,2}
    ::oLbx:aJustify    := {1,0,0,2}
    ::oLbx:lCellStyle  := ::oLbx:ladjbrowse  := .f.
    ::oLbx:ladjlastcol := .t.
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN, (EVAL(bHacer)),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) ) }
   MySetBrowse( ::oLbx, ::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT ( oM:Barra(lAyuda,oDlg) )
::oDb:Setorder(nOrd)

RETURN lReturn

//------------------------------------//
METHOD DefBar( oDlg,oLbx ) CLASS TFactura
   LOCAL oBar := TBar():NewAt( 130,20,300,32,28,28,oDlg, .t.,"TOP", )
DEFINE BUTTON RESOURCE "IMPRIMIR" OF oBar NOBORDER TOOLTIP "Imprime (F3)";
   ACTION ::Listado( oDlg,oLbx,.f. )
DEFINE BUTTON RESOURCE "REINDEZAR" OF oBar NOBORDER TOOLTIP "Devolver Código (Supr)";
   ACTION ( oLbx:KeyDown( VK_DELETE, 0 ) )
DEFINE BUTTON RESOURCE "DELREC"  OF oBar NOBORDER TOOLTIP "Anular Factura (F6)";
   ACTION ::DelFactu( oDlg,oLbx ) GROUP
DEFINE BUTTON RESOURCE "NEW"     OF oBar NOBORDER TOOLTIP "Nueva Factura (F7)";
   ACTION ::Iniciar( oDlg,oLbx )
DEFINE BUTTON RESOURCE "DEDISCO" OF oBar NOBORDER TOOLTIP "Grabar (F11)";
   ACTION ::Guardar( oDlg,oLbx )
DEFINE BUTTON RESOURCE "MIRAR"   OF oBar NOBORDER TOOLTIP "Ver los Pagos (F8)";
   ACTION (::Abonos(), ::Iniciar( oDlg,oLbx )) GROUP
DEFINE BUTTON RESOURCE "MONEY"   OF oBar NOBORDER TOOLTIP "Pagos a Cartera";
   ACTION (CaoPagos(.t.), ::Iniciar( oDlg,oLbx ))
DEFINE BUTTON RESOURCE "CALC"    OF oBar NOBORDER TOOLTIP "Calculadora";
   ACTION WinExec("Calc") GROUP
DEFINE BUTTON RESOURCE "SALIR"   OF oBar NOBORDER TOOLTIP "Salir";
   ACTION oDlg:End()
RETURN oBar

//-Despliega cuadro Lentes Oftalmicos-//
METHOD Lentes( lOft,nA ) CLASS TFactura
   LOCAL bMate, bServ, oDlg, oLbx, oGet := ARRAY(18), lOk := .f.
   LOCAL aL, aLado, aTerm, aTipo, aTEmp, nLado, nMate, nTerm, nTipo
   LOCAL oF := Self
aTipo := TipoMate( "0" )
aL    := { "M    ","  ",aTipo[1,5],0.0,0.0,0.0,"",0,0,0,0,0,0,.f.,1,1,"",0,1,.f.,;
           { .f.,"","",0,0,"" } }
FOR nLado := 1 TO LEN( ::aV )
   If TRIM( ::aV[nLado,1] ) == "0201"
      aLado := SUBSTR(::aV[nLado,2],39,2)
      nTipo := If( LEFT( ::aV[nLado,2],1 ) == "D", 1, 2 )
      aL[21,nTipo+3] := nLado
      If Buscar( {"tipomat",aLado},"servicios","1",8,,4 ) == 1
         aL[21,1] := .T.
         aL[21,6] := aL[21,nTipo+1] := aLado
      EndIf
   EndIf
NEXT nLado
aTEmp := ACLONE( aTipo )
aTerm := { {"Tallado"," "},{"Terminado","T"},{"Coquilla","C"} }
nLado := nMate := nTerm := nTipo := 1
AEVAL( ::aSrv, { | e | e[ 1 ] := 2 } )

If lOft .AND. (nLado := ASCAN( ::aV, { |x| TRIM(x[1]) == "0201" } )) > 0
   If nA == 0 .OR. TRIM(::aV[nA,1]) # "0201"
      nA := 0
   Else
      nLado := nA
   EndIf
   aTipo := ::SinServic( @aL,,nLado,@aTEmp,@nMate,@nTerm,@nTipo )
   nLado := If( nA > 0, AT( LEFT( ::aV[nLado,2],1 ),"DIA" ),;
            If(   LEFT( ::aV[nLado,2],1 )   == "D", 2, 1 ) )
   ::Servicios( aL,0 )
ElseIf !lOft
   aL[7] := ::cDesc
   ::cDesc := ""
EndIf
aLado := { {"Derecho","D"},{"Izquierdo","I"} }
nA    := aL[6]
bMate := {|| If( ::aCla[nMate,2] == "S", ( oGet[3]:oJump := oLbx )    ,;
            (aL[1] := PADR( aTipo[nTipo,4],5 ),    aL[6] := nA        ,;
             aL[7] := aTerm[nTerm,2]+ ::aCla[nMate,2] + aTipo[nTipo,2],;
             aL[3] := If( Rango( aL[7],{"T021 ","T511N"} ), 70, aTipo[nTipo,5] ),;
             aL[8] := aL[12] := aL[18] := 0, oDlg:Update() )) }
bServ := {|| ::Servicios( @aL,oLbx:nAt ), oDlg:Update(),;
             oLbx:Refresh(), oLbx:SetFocus() }
SETKEY( VK_F9,{|| oGet[15]:Click() } )

DEFINE DIALOG oDlg FROM 0, 0 TO 20, 80 TITLE "LENTES OFTALMICOS"
   @ 02,00 SAY "Lado del Lente" OF oDlg RIGHT PIXEL SIZE 50,8
   @ 02,52 COMBOBOX oGet[01] VAR nLado ITEMS ArrayCol( aLado,1 );
      SIZE  40,34 OF oDlg PIXEL WHEN lOft
   @ 16,00 SAY "Clase de Lente" OF oDlg RIGHT PIXEL SIZE 50,8
   @ 16,52 COMBOBOX oGet[02] VAR nTerm ITEMS ArrayCol( aTerm,1 );
      SIZE  40,34 OF oDlg PIXEL WHEN lOft
   @ 16,100 CHECKBOX oGet[18] VAR aL[20] PROMPT "Sin Biselar ?";
      OF oDlg SIZE 50,12 PIXEL WHEN oApl:oEmp:PRINCIPAL == 18
   @ 30,00 SAY "Clase de Material" OF oDlg RIGHT PIXEL SIZE 50,8
   @ 30,52 COMBOBOX oGet[03] VAR nMate ITEMS ArrayCol( oF:aCla,1 );
      SIZE  78,50 OF oDlg PIXEL;
      ON CHANGE( aTipo := TipoMate( oF:aCla[nMate,2],aTipo,oGet[04] ),;
                 nTipo := 1, EVAL(bMate) ) WHEN lOft
   @ 44,00 SAY "Tipo de Material" OF oDlg RIGHT PIXEL SIZE 50,8
   @ 44,52 COMBOBOX oGet[04] VAR nTipo ITEMS ArrayCol( aTipo,1 );
      SIZE 130,54 OF oDlg PIXEL UPDATE WHEN lOft
    oGet[04]:bLostFocus := {|| EVAL(bMate) }
   @ 56, 22 CHECKBOX oGet[05] VAR aL[14] PROMPT "Con Orden de una Empresa ?";
      OF oDlg SIZE 78,12 PIXEL WHEN lOft
   @ 58,106 SAY "C.Lente Emp." OF oDlg RIGHT PIXEL SIZE 34,8
   @ 58,142 COMBOBOX oGet[17] VAR aL[19] ITEMS ArrayCol( aTerm,1 );
      SIZE  40,34 OF oDlg PIXEL WHEN (lOft .AND. aL[14])
   @ 72,00 SAY "C.Material Empresa" OF oDlg RIGHT PIXEL SIZE 50,8
   @ 72,52 COMBOBOX oGet[06] VAR aL[15] ITEMS ArrayCol( oF:aCla,1 );
      SIZE  78,50 OF oDlg PIXEL;
      ON CHANGE( aTEmp := TipoMate( oF:aCla[aL[15],2],aTEmp,oGet[7] ),;
                 aL[16]:= 1,          aL[17] := PADR( aTEmp[1,4],5 ) +;
                 oF:aCla[aL[15],2] + aTEmp[1,2] + STR(aTEmp[1,5],3) ) ;
      WHEN (lOft .AND. aL[14])
   @ 86,00 SAY "T.Material Empresa" OF oDlg RIGHT PIXEL SIZE 50,8
   @ 86,52 COMBOBOX oGet[07] VAR aL[16] ITEMS ArrayCol( aTEmp,1 );
      SIZE 130,54 OF oDlg PIXEL UPDATE WHEN (lOft .AND. aL[14])
    oGet[07]:bLostFocus := {|| aL[17] := PADR( aTEmp[aL[16],4],5 ) + ::aCla[aL[15],2] +;
                                               aTEmp[aL[16],2] + STR(aTEmp[aL[16],5],3) }
   @ 102, 18 SAY "Caracteristica" OF oDlg PIXEL SIZE 40,8
   @ 110, 22 GET oGet[08] VAR aL[1] OF oDlg PICTURE "@!";
      WHEN (lOft .AND. Rango( aL[7],{" 011 "," 611 "} )) ;
      VALID (If( aL[1] == "M    " .OR. aL[1] == "LEN  ", .t.,;
            (MsgStop( "Caracteristica NO EXISTE" ),.f. )))   ;
      SIZE 24,12 PIXEL UPDATE
//    WHEN (lOft .AND. aL[7] == " 011 ") ;
    oGet[08]:cToolTip := "[LEN] PARA MONOFOCAL LENTICULAR NEGATIVO CON DISEÑO ESPECIAL"
/*
   @ 58, 98 SAY "Color" OF oDlg RIGHT PIXEL SIZE 20,8
   @ 58,120 GET oGet[06] VAR aL[2] OF oDlg PICTURE "@!";
      WHEN (lOft .AND. ::aCla[nMate,2] == "V")         ;
      VALID ( If( aL[2] $ "BL CL FG HB",          .t. ,;
                ( MsgStop( "Color NO EXISTE" ),.f. ))) ;
      SIZE 24,12 PIXEL
    oGet[06]:cToolTip := "BL, CL, FG, HB"
*/
   @ 102, 54 SAY "Diámetro" OF oDlg PIXEL SIZE 40,8
   @ 110, 52 GET oGet[09] VAR aL[3] OF oDlg ;
      SIZE 28,12 PIXEL UPDATE WHEN lOft
   @ 102, 86 SAY "Esfera" OF oDlg PIXEL SIZE 40,8
   @ 110, 84 GET oGet[10] VAR aL[4] OF oDlg PICTURE "999.99";
      VALID ( If( aL[4] % .25 == 0, .t.                   ,;
                ( MsgStop( "ESFERA Incorrecta" ), .f.) ) ) ;
      SIZE 28,12 PIXEL WHEN lOft
   @ 102,118 SAY "Cilindro" OF oDlg PIXEL SIZE 40,8
   @ 110,116 GET oGet[11] VAR aL[5] OF oDlg PICTURE "999.99"   ;
      VALID ( If( aL[5] % .25  > 0                     ,;
                ( MsgStop( "Cilindro Incorrecta"), .f.),;
             (If( ValLente( @aL,aTipo[nTipo,6]), oDlg:Update(),;
                 oGet[11]:oJump := oGet[10] ), .t. ) ) )       ;
      SIZE 28,12 PIXEL WHEN lOft
   @ 102,150 SAY "Adición" OF oDlg PIXEL SIZE 40,8
   @ 110,148 GET oGet[12] VAR aL[6] OF oDlg PICTURE "999.99"   ;
      WHEN (lOft .AND. aTipo[nTipo,3]) ;
      VALID ( If( aL[6] % .25  > 0                    ,;
                ( MsgStop( "Adición Incorrecta"), .f.),;
             (If( Rango( aL[6],aL[10],aL[11] )  , .t. ,;
                (MsgStop( "Adición NO EXISTE",">>> OJO <<<<" ), .f.) )) ));
      SIZE 28,12 PIXEL
   @ 128, 00 SAY "Valor del Lente" OF oDlg RIGHT PIXEL SIZE 50,8
   @ 128, 52 SAY oGet[13] VAR aL[8] OF oDlg PICTURE "9,999,999";
      SIZE 62,12 PIXEL UPDATE COLOR nRGB( 160,19,132 )

   @ 02,190 LISTBOX oLbx FIELDS "", "" ;
      HEADERS "", "SERVICIOS A LENTES" ;
      SIZE 120,115         ;
      FIELDSIZES 16, 170   ;
      OF oDlg PIXEL UPDATE ;
      ON CLICK ( EVAL(bServ) )
    oLbx:nClrBackHead := oApl:nClrBackHead
    oLbx:nLineStyle:= 2
    oLbx:nClrLine  := nRgb(184,196,224)
    oLbx:nAt       := 1
    oLbx:bLine     := {|| { ::aBit[ ::aSrv[oLbx:nAt,1] ],;
                            ::aSrv[oLbx:nAt][2] } }
    oLbx:bGoTop    := {|| oLbx:nAt := 1 }
    oLbx:bGoBottom := {|| oLbx:nAt := EVAL( oLbx:bLogicLen ) }
    oLbx:bSkip     := {|nWant,nOld| nOld := oLbx:nAt, oLbx:nAt += nWant,;
                        oLbx:nAt := MAX( 1, MIN( oLbx:nAt, EVAL( oLbx:bLogicLen ) ) ),;
                        oLbx:nAt - nOld }
    oLbx:bLogicLen := {|| LEN( ::aSrv ) }
    oLbx:bKeyDown  := {|nKey| If( nKey=VK_RETURN, EVAL(bServ), ) }
    oLbx:lHScroll  := .f.
   @ 128,190 SAY "Valor Servicios" OF oDlg RIGHT PIXEL SIZE 50,8
   @ 128,242 SAY oGet[14] VAR aL[9] OF oDlg PICTURE "9,999,999";
      SIZE 62,12 PIXEL UPDATE COLOR nRGB( 160,19,132 )

   @ 134,100 BUTTON oGet[15] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      (lOk := .t., oDlg:End()) PIXEL
   @ 134,150 BUTTON oGet[16] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER

SETKEY( VK_F9,{|| .t. } )
 ::aM[1]  := .f.
 ::aM[19] := ""
If lOk
      ::aM[13] := aL[8]                //PPUBLI
   If !lOft
   //If aL[8] == 0 .AND. aL[9] > 0
      If LEN(::cDesc) <= 6
         AEVAL( ::aSrv, { | e | If( e[1] == 1, (::aM[12] := e[2] + "     "), ) } )
      Else
         ::aM[12] := XTrim( "L.OFTALMICOS "+::cDesc,40 )
      EndIf
      ::aM[1]  := .t.
      ::aM[13] += aL[9]
      ::cDesc  := aL[7]
   ElseIf aL[8] > 0
      If Buscar( {"tipomat",SUBSTR(aL[7],3,2)},"servicios","1",8,,4 ) == 1
         aL[21,1] := .T.
         aL[21,6] := aL[21,nLado+1] := SUBSTR(aL[7],3,2)
         aL[9] := aL[13] := 0
         ::Servicios( aL,0 )
      EndIf
      If !aL[20] .AND. !aL[21,1]
         ::aM[19] := If( nTerm >= 2 .AND. nMate == 1, "56", "57" )
         nA    := ASCAN( ::aSRV, {|aVal| aVal[3] == ::aM[19]} )
         bServ := ::SinServic( aL,::aM[19],nA )
         aL[13]+= bServ[2]
         ::aM[19] := ""
      // aL[13] += Buscar( "SELECT pcosto FROM cadtlist WHERE clase_mate = 'S' AND tipo_trab = 'BM"+;
      //                  If( nTerm >= 2 .AND. nMate == 1, "N'", "S2'" ),"CM",,8,,4 )
      EndIf
      aL[07] := ::aCla[nMate,2] + If( aL[3] < 70, "1",;
                If( aL[3] >= 75, "3", "2" ) ) + aTipo[nTipo,2]
      ::aM[12] := aLado[nLado,2] + "_" + ;
                  If( aL[1] == "LEN  ", "N", aTerm[nTerm,2] ) + "."  +;
                  LEFT( STRTRAN( SUBSTR(::aCla[nMate,1],3),"-" ),4 ) +;
                   "." + aTipo[nTipo,7] + "." + STR( aL[3],2 )       +;
                                 TRANSFORM( aL[4],"E999.99" )        +;
                  If( aL[5] # 0, TRANSFORM( aL[5],"C999.99" ), "       " )+;
             If( aTipo[nTipo,3], TRANSFORM( aL[6],  "A9.99" ), "     " )
      ::aM[12] := XTrim( ::aM[12],40 )
      ::aM[12] := STUFF( ::aM[12],37,4,aL[7] )
   EndIf
   If aL[14]
      ::aM[13] := aL[18]
      ::aM[19] := ::aCla[aL[15],2] + LTRIM(STR(aL[19])) + aTEmp[aL[16],2]
   // ::aM[19] := ::aCla[aL[15],2] + SUBSTR(aL[07],2,1) + aTEmp[aL[16],2]
   EndIf
      ::aM[14] := aL[8]  + aL[9]
      ::aM[18] := aL[12] + aL[13]      //PCOSTO
   // Recalcular Precios si Uno de los Lentes es Progresivo o Digital
   If aL[21,1]
      FOR nA := 2 TO 3
         If EMPTY(aL[21,nA]) .AND. aL[21,nA+2] > 0
            nLado := aL[21,nA+2]
          //aL[8] := aL[9] + ::aV[nLado,3]
            aTipo := ::SinServic( @aL,,nLado,@aTEmp,@nMate,@nTerm,@nTipo )
            aL[8] += aL[9]
            aL[9] := 0
            If ::aV[nLado,5] > 0
               aL[9] := ROUND( aL[8] * ::aV[nLado,5] / 100,0 )
            EndIf
            ::aV[nLado,06] := aL[9]
            ::aV[nLado,07] := aL[8]  - aL[9]
            ::aV[nLado,11] := aL[8]
            ::aV[nLado,13] := aL[12] + aL[13]
         EndIf
      NEXT nA
   EndIf
EndIf
RETURN lOk
/*
   If cClase = "V"
aCL := { {"BL BLANCO   ","BL"},{"C1 PINK1    ","CL"},{"CA CALOBAR-A ","CL"},;
         {"CB CALOBAR-A","CL"},{"CL COLORES  ","CL"},{"EF EXT FOTGRY","FG"},;
         {"FG FOTO GRAY","FG"},{"FS FOTO SUN ","CL"},{"HB HI LITE   ","HB"} }
      ::aM[12] += LEFT( aCL[nK,1],2 ) + "."
      aL[2] := aCL[nK,2]
   EndIf
*/
//------------------------------------//
METHOD Servicios( aL,nAt ) CLASS TFactura
   LOCAL aPC, cSer, cTer, nCan := 1
If aL == NIL
   If !EMPTY( ::cDesc )
      If nAt == 1
         If (nAt := ASCAN( ::aV, { |x| x[1] == "0203        " } )) > 0
            ::aV[nAt,2] := XTrim( ::cDesc,40 )
         EndIf
      EndIf
      If nAt == 0
         AADD( ::aV, { "0203",XTrim( ::cDesc,40 ), 0, 1, 0, 0, 0, 0, " ", 0, 0, 1, 0, "" } )
      EndIf
   EndIf
ElseIf VALTYPE( aL ) == "C"
   ::aM[13] := ::aM[16] := ::aM[18] := 0
   FOR nAt := 1 TO LEN( ::aV )
      If ALLTRIM( ::aV[nAt,1] ) $ "0201,0503,0505" .AND.;
         ::aV[nAt,13]  # ::aV[nAt,15]
         ::aM[13] := nAt
         ::aM[14] := ::aV[nAt,04] * ::aV[nAt,13]
         ::aM[16] += ::aM[14]
         ::aM[14] := ROUND( ::aM[14] * oApl:oEmp:DTOCOMER / 100,0 )
         ::aM[18] += ::aM[14]
         ::aV[nAt,13] -= (::aM[14] / ::aV[nAt,04])
      EndIf
   NEXT nAt
   If (nAT := ::aM[13]) > 0
      ::aM[14] := ::aM[18] - ROUND( ::aM[16] * oApl:oEmp:DTOCOMER / 100,0 )
      ::aV[nAt,13] += (::aM[14] / ::aV[nAt,04])
      //MsgStop( TRANSFORM( ::aM[16],"999,999,999.99" ) + CRLF +;
      //         TRANSFORM( ::aM[18],"999,999,999.99" ) + CRLF +;
      //         TRANSFORM( ::aM[14],"999,999,999.99" ),aL )
   EndIf
/*
   If (::aM[13] - INT(::aM[13])) == 0.5
      //MsgStop( TRANSFORM( ::aM[13],"999,999,999.99" ),"PCOSTO" )
      FOR nAt := 1 TO LEN( ::aV )
         If ALLTRIM( ::aV[nAt,1] ) $ "0201,0503,0505"
            If (::aV[nAt,13] - INT(::aV[nAt,13])) == 0.5
                ::aV[nAt,13] -= 0.5
               //MsgStop( TRANSFORM( ::aV[nAt,13],"999,999,999.99" ),"PCOSTO"+STR(nAt) )
               EXIT
            EndIf
         EndIf
      NEXT nAt
   EndIf
*/
ElseIf nAt == 0
   cTer := ALLTRIM( ::cDesc )
   While !EMPTY( cTer )
      cSer := Saca( @cTer,"," )
      nCan := 1
      If ISDIGIT( cSer ) .AND. SUBSTR(cSer,2,5) == "PERFO"
         nAt  := If( ISDIGIT( SUBSTR(cSer,2,1) ), 2, 1 )
         nCan := VAL( LEFT(cSer,nAt) )
         cSer := STUFF( cSer,nAt,nAt,"" )
      EndIf
      cSer := PADR( cSer,5," " )
      If (nAt := ASCAN( ::aSRV, {|aVal| aVal[4] == cSer} )) > 0
         aPC  := ::SinServic( aL,::aSrv[nAt,3],nAt )
         aL[09] += (aPC[1] * nCan)
         aL[13] += PorDscto( aPC[2] * If( nCan > 3, 3, nCan ),;
                             ::aSrv[nAt,5]*100,.t. )
         ::aSrv[nAt,1] := 1
      EndIf
   EndDo
Else
   If ::aSrv[nAt,3] == "51"  //TIPO_MATER
      MsgGet( "Perforaciones","Cantidad",@nCan )
      cTer := STR( nCan,1 ) + TRIM( ::aSrv[nAt,4] ) + ","
   Else
      cTer := TRIM( ::aSrv[nAt,4] ) + ","
      nCan := 1
   EndIf
   aPC := ::SinServic( aL,::aSrv[nAt,3],nAt )
   If ::aSrv[nAt,1] == 2
      ::aSrv[nAt,1] := 1
      ::cDesc += If( AT( cTer,::cDesc ) = 0, cTer,"" )
      aL[09] += (aPC[1] * nCan)
      nCan   := If( nCan > 3, 3, nCan )
      aL[13] += PorDscto( aPC[2] * nCan,::aSrv[nAt,5]*100,.t. )
   Else
      ::aSrv[nAt,1] := 2
      ::cDesc := STRTRAN( ::cDesc,cTer,"" )
      aL[09] += (aPC[1] * -nCan)
      nCan   := If( nCan > 3,  3, nCan )
      aL[13] += PorDscto( aPC[2] * nCan,::aSrv[nAt,5]*100,.t. ) * -1
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD SinServic( aL,cSer,nAt,aTEmp,nMate,nTerm,nTipo ) CLASS TFactura
   LOCAL aPC, nL
If cSer # NIL
//      " AND clasemat = '" + SUBSTR(aL[7],2,1) +;
   aPC := If( EMPTY(aL[21,6]), SUBSTR(aL[7],3,2), aL[21,6] )
   cSer:= "SELECT valunidad, pcosto, 1 FROM servicios WHERE " +;
           xValToChar( ::dFec ) + " BETWEEN fechai AND fechaf"+;
           " AND tipomat = '" + aPC  +;
          "' AND tiposer = '" + cSer + "'"
   aPC := Buscar( cSer,"CM",,8 )
   If LEN( aPC ) == 0
      aPC := { ::aSrv[nAt,6],::aSrv[nAt,7],0 }
               //valunidad  ,  pcosto
   EndIf
Else
   If !EMPTY(::aV[nAt,14])
      cSer  := ::aV[nAt,14]
      aL[1] := LEFT(cSer,1)
      aTEmp := TipoMate( aL[1] )
      aL[14]:= .t.
      aL[15]:= ArrayValor( ::aCla,aL[1],,.t. )
      aL[16]:= ArrayValor(  aTEmp,RIGHT(cSer,3),,.t. )
      aL[17]:= PADR( aTEmp[aL[16],4],5 ) + ::aCla[aL[15],2] +;
                     aTEmp[aL[16],2] + STR(aTEmp[aL[16],5],3)
      aL[19]:= VAL( SUBSTR(cSer,2,1) )
   EndIf

   aL[1] := SUBSTR(::aV[nAt,2],37,1)
   aPC   := TipoMate( aL[1] )
   nMate := ArrayValor( ::aCla,aL[1],,.t. )
   nTerm := AT( ".",SUBSTR( ::aV[nAt,2],12 ) ) + 11
   aL[1] := SUBSTR( ::aV[nAt,2],39,2 ) +;
        If( SUBSTR( ::aV[nAt,2],nTerm-2,2 ) == "NG", "N", " " )
   //       If( SUBSTR(::aV[nAt,2],14,1 ) == "M", "M",;
   nTipo := ArrayValor( aPC,{ aL[1],SUBSTR(::aV[nAt,2],10,5) },,.t.,2 )
   aL[1] := SUBSTR( ::aV[nAt,2],nTerm,37-nTerm )
   aL[3] := VAL( SUBSTR(aL[1],2,2) )            //Diametro
   aL[4] := VAL( SUBSTR(aL[1],5,6) )            //Esfera
   aL[5] := If( SUBSTR(aL[1],11,1) == "C", VAL( SUBSTR(aL[1],12,6) ), 0 )
   nTerm := AT( "A",aL[1] ) + 1
   aL[6] := VAL( SUBSTR(aL[1],nTerm,4) )        //Adicion
   nTerm := If( SUBSTR( ::aV[nAt,2],3,2 ) == "T.", 2,;
            If( SUBSTR( ::aV[nAt,2],3,2 ) == "C.", 3, 1 ) )
   aL[1] := If( SUBSTR( ::aV[nAt,2],3,2 ) == "N.", "LEN  ", PADR( aPC[nTipo,4],5 ) )
   aL[7] := { " ","T","C" }[nTerm] + ::aCla[nMate,2] + aPC[nTipo,2]
// aL[7] := aTerm[nTerm,2] + ::aCla[nMate,2] + aPC[nTipo,2]
   ValLente( @aL,aPC[nTipo,6] )
EndIf
RETURN aPC
/*
//------------------------------------//
METHOD AbreCaja( cPort ) CLASS TFactura
   LOCAL oPuerto
   DEFAULT cPort := "COM2:"
 oPuerto := TDosPrint():New( cPort )
 oPuerto:Say( 1,01,CHR(130) )
 oPuerto:End()
RETURN NIL
*/
/*
SELECT m.valventa, m.esferacil, m.esferap, m.adicion_de, m.adicion_a, m.pcosto,
       e.rango, e.valventa, e.pcosto, e.codigo_dia
FROM cadtesfe e, cadtmate m
WHERE e.esfera_de <= 1
  AND e.esfera_a  >= 1
  AND m.consec    = e.consec
  AND m.terminado = e.terminado
  AND m.terminado = ''
  AND m.clasemat  = '0'
  AND m.tipomat   = '11'
  AND m.tipolista = 'M'
  AND m.colorv    = ''
  AND m.tipoesfe  = ''
  AND m.diametro  = 65
*/
//------------------------------------//
STATIC FUNCTION ValLente( aL,nPor )
   LOCAL aPC := "  ", cDiam := LEFT( aL[7],4 )
   LOCAL aVL, aVO, nEsf := ABS(aL[4])
If STUFF( cDiam,2,1 ) == "T11" .AND. aL[4] = 0 .AND. aL[5] # 0
   aPC := "PC"
EndIf
aL[8] := aL[12] := 0
aPC := Buscar( { "terminado",SUBSTR(aL[7],1,1),"clasemat",SUBSTR(aL[7],2,1),;
                 "tipomat"  ,SUBSTR(aL[7],3,2),"tipolista",aL[1]  ,;
                 "colorv",aL[2],"tipoesfe",aPC,"diametro" ,aL[3] },"cadtmate",;
                 "consec, valventa, esferacil, esferap, adicion_de, adicion_a, pcosto",8 )
If LEN( aPC ) == 0
   RETURN .f.
EndIf
If LEFT(aL[7],1) == "T"
   If SUBSTR(aL[7],3,2) == "21" .AND. aL[4] < 0
      MsgStop( "En Bifocal la Esfera debe ser Positiva" )
      RETURN .f.
   ElseIf SUBSTR(aL[7],3,2) == "21" .AND. aL[5] # 0
      MsgStop( "En Bifocal solo es Esferico" )
      RETURN .f.
   ElseIf aL[5] # 0 .AND. (aL[4] > aPC[4] .OR. nEsf > aPC[3])
      MsgStop( "Esfera NO EXISTE en Terminado Cilindrico" )
      RETURN .f.
   ElseIf aL[4] > 0 .AND. aL[4] > aPC[4]
      MsgStop( "Esfera NO EXISTE en Terminado" )
      RETURN .f.
   EndIf
ElseIf aPC[4] > 0 .AND. aL[4] > aPC[4]
      MsgStop( "Esfera NO EXISTE en Positivos" )
      RETURN .f.
EndIf
aL[10] := aPC[5]
aL[11] := aPC[6]
aVL    := { aPC[2],aPC[7] }
cDiam  := If( aL[3] < 70, "1", If( aL[3] >= 75, "3", "2" ) )
aPC := Buscar( { "consec",aPC[1],"terminado",LEFT(aL[7],1) ,;
                 "esfera_de <= ",nEsf,"esfera_a >= ",nEsf },;
                 "cadtesfe","rango, valventa, pcosto, codigo_dia",8 )
If LEN( aPC ) == 0 .OR. !cDiam $ aPC[4]
   MsgStop( "Esfera NO EXISTE",">>> OJO <<<<" )
   RETURN .f.
EndIf
aVL[1] += aPC[2]
aVL[2] += aPC[3]
If aL[5] # 0
   nEsf := ABS(aL[5])
   aPC := Buscar( { "rango",aPC[1],"cilin_de <= ",nEsf,"cilin_a >= ",nEsf },;
                    "cadtcili","valventa, pcosto",8 )
   If LEN( aPC ) == 0
      MsgStop( "Cilindro NO EXISTE",">>> OJO <<<<" )
      RETURN .f.
   EndIf
   aVL[1] += aPC[1]
   aVL[2] += aPC[2]
EndIf
aL[08] := PorDscto( aVL[1],nPor,.t. )
aL[12] := aVL[2]
If aL[14]
   aVO   := { aL[1],aL[3],aL[7],aL[10],aL[11],aL[12] }
   aL[1] := LEFT( aL[17],5 )
   aL[7] := { " ","T","C" }[aL[19]] + SUBSTR( aL[17],6,4 )
   aL[3] := If( Rango( aL[7],{"T021 ","T511N"} ), 70, INT( VAL(RIGHT( aL[17],3 )) ) )
   aL[14]:= .f.
   aL[18]:= aL[08]
   ValLente( aL,nPor )
   aL[01]:= aVO[1]
   aL[03]:= aVO[2]
   aL[07]:= aVO[3]
   aL[10]:= aVO[4]
   aL[11]:= aVO[5]
   aL[12]:= aVO[6]
   aL[14]:= .t.
EndIf
RETURN .t.

//------------------------------------//
STATIC FUNCTION PorDscto( nValor,nPor,lSi )
   LOCAL nDscto := 0
If lSi .AND. nPor > 0
   nDscto := ROUND( nValor * nPor / 100,2 )
   If (nPor := nDscto - INT(nDscto)) # 0.5
      nDscto := ROUND( nDscto,0 )
   EndIf
EndIf
RETURN (nValor - nDscto)

//------------------------------------//
STATIC FUNCTION TipoMate( cClase,aTipo,oGet )
   LOCAL aTip := {}, aRes, hRes, nL, cQry
cQry := "SELECT nombre, tipo_mater, tipol, bifocal, tipo_lista, " +;
                                 "diametro, por_dscto, nomcorto " +;
        "FROM cadtlist WHERE clase_mate = " + xValToChar( cClase )+;
         " AND activo = '0' ORDER BY clase_mate, tipo_mater, tipol"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
If nL > 0 .AND. cClase == "0"
   aRes := MyReadRow( hRes )
   nL --
EndIf
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[2] := PADR( aRes[2]+aRes[3],3 )
   AADD( aTip, { aRes[1],aRes[2],aRes[4],aRes[5],aRes[6],aRes[7],aRes[8] } )
   nL --
EndDo
MSFreeResult( hRes )
If oGet # NIL
   AEVAL( aTipo, {|x| oGet:Del(1) } )
   AEVAL( aTip , {|x| oGet:Add( x[1] ) } )
   oGet:Refresh()
EndIf
RETURN aTip

//------------------------------------//
FUNCTION FechaDev( cMsg,dFecha )
   LOCAL dFec := oApl:dFec
WHILE !oApl:lEnLinea
   dFec := MsgDate( dFec,cMsg )
   If dFec >= dFecha
      If MsgYesNo( DTOC(dFec)+" Es Correcta Fecha",cMsg )
         EXIT
      EndIf
   EndIf
EndDo
RETURN dFec

//--Actualiza archivos de Inventario CadInven--//
PROCEDURE GrabaV( nCantidad,cCambio,nHago,dFecH,nFV,nPC )
   LOCAL cGru := LEFT( oApl:oVen:CODART,2 )
   oApl:aInvme[2] := 0
If cGru $ "02  05" .OR. nCantidad == 0 .OR. oApl:Tipo == "Z"
   RETURN
EndIf
If oApl:oInv:Seek( {"codigo",oApl:oVen:CODART} )
   If oApl:oInv:GRUPO == "1" .AND. oApl:oInv:OPTICA == oApl:nEmpresa .AND.;
      Rango( oApl:oInv:FACTUVEN,{0,nFV,oApl:oVen:NUMFAC} )
      cGru := If( cCambio == "S", { 0,0,CTOD(""),"E" },;
                { oApl:oVen:PRECIOVEN,oApl:oVen:NUMFAC,oApl:oVen:FECFAC,"V" } )
      oApl:oInv:PVENDIDA := cGru[1] ; oApl:oInv:FACTUVEN  := cGru[2]
      oApl:oInv:FECVENTA := cGru[3] ; oApl:oInv:SITUACION := cGru[4]
      Guardar( oApl:oInv,.f.,.f. )
   EndIf
   Actualiz( oApl:oVen:CODART,nCantidad,dFecH,nHago )
ElseIf LEFT(oApl:oVen:CODART,1) >= "6"
   oApl:oInv:Seek( {"codigo",LEFT(oApl:oVen:CODART,4)} )
   Actualiz( oApl:oVen:CODART,nCantidad,dFecH,nHago )
EndIf
If nPC # NIL .AND. oApl:aInvme[2] # 0
   If oApl:oVen:PCOSTO  # oApl:aInvme[2]
      oApl:oVen:PCOSTO := oApl:aInvme[2] ; Guardar( oApl:oVen,.f.,.f. )
   EndIf
EndIf
RETURN

//------------------------------------//
FUNCTION CierreInv( dFec,xMsg )
If dFec <= oApl:oEmp:FECINV
   MsgStop( "Ya se hizo el cierre CONTABLE y no se puede Modificar",xMsg )
   xMsg := .t.
Else
   xMsg := .f.
EndIf
RETURN xMsg