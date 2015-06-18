// Programa.: CAOANTIC.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Modulo para la Elaboracion de los Anticipos
#include "Fivewin.ch"
#include "TSBrowse.ch"
#include "Btnget.ch"

MEMVAR oApl

#define CLR_PINK  nRGB( 128, 150, 150) //255, 128, 128
#define CLR_NBLUE nRGB( 128, 128, 192)

FUNCTION Anticipos()
   LOCAL oDlg, oLbx, aColor[ 2 ], lNoBlink := .f.
   LOCAL bAyuda, cTit, nA, oBtn := ARRAY(9)
   LOCAL oAr, oDp, oF
//If oApl:aWHija[2] == NIL
   oAr := TInv()      ; oAr:New(,.f.)
   oDp := TPer()      ; oDp:NEW()
   oF  := TAnticipo() ; oF:New()
   If (aColor[ 1 ] := GetSysColor( COLOR_INACTIVECAPTION ) ) != ;
      GetSysColor( COLOR_ACTIVECAPTION )
      aColor[ 2 ] := GetSysColor( COLOR_INACTCAPTEXT )
      lNoBlink := .t.
      SBNoBlink()
   Endif
   cTit  := "Anticipos - Ventas || "
   oApl:Tipo := oF:cTipo := "U"
   oF:Iniciar()
   oF:AdicArray()
   SETKEY( VK_F4,{|| If( Empresa(), ( oDlg:SetText(cTit + oApl:cEmpresa),;
                      oF:Iniciar(), oDlg:Update() ), ), oF:oG[1]:SetFocus() } )
bAyuda:= {|| oDp:xVar := oF:aM[4], If( oDp:Mostrar( ,3 )    ,;
            (oF:aM[4] := oDp:oDb:NROIDEN, oF:oG[4]:Refresh(),;
             oF:oG[4]:lValid(.f.)), .f. ) }
DEFINE DIALOG oDlg RESOURCE "ANTICIPOS" TITLE cTit + oApl:cEmpresa OF oApl:oWnd
   REDEFINE SAY           VAR oF:nSigFac  ID  1 OF oDlg UPDATE COLOR "B+/W"
   REDEFINE BTNGET oF:oG[01] VAR oF:aM[2] ID  3 OF oDlg               ;
      RESOURCE "BUSCAR"                                               ;
      ACTION EVAL({|| If(oF:Mostrar(), (oF:aM[2] := oF:oDb:NUMERO    ,;
                        oApl:nEmpresa := oF:oDb:OPTICA               ,;
                        oF:oG[1]:Refresh(), oF:oG[1]:lValid(.f.)),)}) ;
      VALID( If( !oF:oDb:Seek( { "optica",oApl:nEmpresa,"numero"     ,;
                                  oF:aM[2] } ) .AND. oF:aM[2] # 0    ,;
               ( MsgStop("Anticipo NO EXISTE"), .f. )                ,;
               (oF:AdicArray(),  oLbx:aArray := oF:aV,  oF:Division(),;
                oDlg:Update(), oF:Dscto( 0,oLbx ) ,;
                If( oF:oDb:lOK, (oF:oG[1]:oJump := oLbx), ), .t. )))
   REDEFINE GET oF:oG[02] VAR oF:oDb:FECHA   ID  5 OF oDlg UPDATE ;
      WHEN !oApl:lEnLinea ;
      VALID(     oF:dFec := oF:oDb:FECHA                         ,;
             If( oF:oDb:lOK .AND. oF:dFec # oF:oDb:XColumn(3)    ,;
                 oF:CambiaFec(), ), .t. )
   REDEFINE BTNGET oF:oG[03] VAR oF:aM[3]   ID  7 OF oDlg               ;
      RESOURCE "BUSCAR"                                                 ;
      ACTION EVAL({|| If( oAr:oNi:Mostrar( ,,oF:aM[3] ), ( oF:aM[3] :=  ;
                          oAr:oNi:oDb:CODIGO, oF:oG[03]:Refresh() ),) });
      VALID EVAL( {|| If( oAr:oNi:Buscar( oF:aM[3],,.t. )              ,;
                ( oF:Division()                                        ,;
                  oF:oDb:CODIGO_NIT := oAr:oNi:oDb:CODIGO_NIT          ,;
                  oF:aM[5] := oAr:oNi:oDb:NOMBRE, oDlg:Update(), .t. ) ,;
                (If( MsgYesNo("Desea ingresarlo","Este Nit no Existe") ,;
                  oAr:oNi:Editar( ,.t.,,oF:aM[3] ), ),.f.) ) } ) UPDATE
   REDEFINE SAY           VAR oF:aM[5]      ID  8 OF oDlg UPDATE
   REDEFINE BTNGET oF:oG[04] VAR oF:aM[4]   ID 10 OF oDlg               ;
      RESOURCE "BUSCAR"                                                 ;
      ACTION EVAL( bAyuda )                                             ;
      VALID EVAL( {|| If( !oDp:Buscar( oF:aM[4],"nroiden",.t. ) .AND.   ;
                  !EMPTY(oF:aM[4]), (EVAL( bAyuda )), ( If( oDp:oDb:lOK,;
                  (oF:NEW( oDlg ), oDp:xVar := oF:aM[4]), ), .t. ) ) } ) UPDATE
//    WHEN oApl:lEnlinea
    oF:oG[4]:bRClicked = {|| oDp:Listado() }
   REDEFINE GET oF:oG[05] VAR oF:oDb:CLIENTE  ID 11 OF oDlg UPDATE PICTURE "@!"
   REDEFINE GET oF:oG[06] VAR oF:oDb:FECHAENT ID 13 OF oDlg UPDATE
   REDEFINE GET oF:oG[07] VAR oF:oDb:VENDEDOR ID 15 OF oDlg UPDATE PICTURE "@!"
   REDEFINE GET oF:oG[08] VAR oF:oDb:GAVETA   ID 17 OF oDlg UPDATE PICTURE "999"
   REDEFINE GET oF:oG[09] VAR oF:oDb:ORDEN    ID 19 OF oDlg UPDATE
   REDEFINE GET oF:oG[10] VAR oF:oDb:DIRECC   ID 21 OF oDlg UPDATE PICTURE "@!"
   REDEFINE GET oF:oG[11] VAR oF:oDb:TELEFONO ID 23 OF oDlg UPDATE
   REDEFINE COMBOBOX oF:oG[12] VAR oF:cTipoF ITEMS ArrayCol( oF:aEps,1 );
      ID 25 OF oDlg UPDATE;
      VALID ( oF:oDb:TIPOFAC:= oF:aEps[oF:oG[12]:nAt,2],;
              oDlg:GoNextCtrl( oF:oG[12]:hWnd ), .t. )
   REDEFINE GET oF:oG[13] VAR oF:oDb:VALOREPS ID 26 OF oDlg UPDATE ;
      WHEN oApl:oNit:EPS
   REDEFINE GET oF:oG[14] VAR oF:oDb:VALOROT  ID 28 OF oDlg PICTURE "9,999,999,999";
      UPDATE WHEN oApl:oNit:TIPOFAC == "FAN       ";
      VALID ( If( oF:oDb:lOK, oF:oDb:Update( .f.,1 ), ), .t. )
   REDEFINE GET oF:oG[15] VAR oF:oDb:FACTEXCE ID 30 OF oDlg UPDATE;
      VALID oF:BuscaFac( oF:oDb:FACTEXCE,oF:oDb:FECHA )
   REDEFINE SAY VAR oF:aM[6]        ID 32 OF oDlg PICTURE "999,999,999" UPDATE
   REDEFINE SAY VAR oF:oDb:SALDOFAC ID 34 OF oDlg PICTURE "999,999,999" UPDATE
   REDEFINE GET oF:oG[16] VAR oF:oDb:AUTORIZA ID 36 OF oDlg UPDATE
//    WHEN oApl:oNit:EPS
   REDEFINE SAY VAR oF:oDb:NUMFAC   ID 38 OF oDlg UPDATE
   REDEFINE SAY VAR oF:aM[7]        ID 39 OF oDlg UPDATE COLOR nRGB( 255,0,0 )
   ACTIVAGET(oF:oG)

   REDEFINE BTNBMP oBtn[1] ID 40 OF oDlg RESOURCE "IMPRIMIR" ;
      ACTION oF:Listado( oDlg,oLbx )     MESSAGE "Imprime Factura (F3)"
   REDEFINE BTNBMP oBtn[2] ID 41 OF oDlg RESOURCE "REINDEZAR";
      ACTION oLbx:KeyDown( VK_DELETE,0 ) MESSAGE "Devolver Código (Supr)"
   REDEFINE BTNBMP oBtn[3] ID 42 OF oDlg RESOURCE "DELREC"   ;
      ACTION oF:DelFactu( oDlg,oLbx )    MESSAGE "Anular Factura (F6)"
   REDEFINE BTNBMP oBtn[4] ID 43 OF oDlg RESOURCE "NEW"      ;
      ACTION oF:Iniciar( oDlg,oLbx )     MESSAGE "Nueva Factura (F7)"
   REDEFINE BTNBMP oBtn[5] ID 44 OF oDlg RESOURCE "DEDISCO"  ;
      ACTION oF:Guardar( oDlg,oLbx )     MESSAGE "Grabar Factura (F11)"
   REDEFINE BTNBMP oBtn[6] ID 45 OF oDlg RESOURCE "MIRAR"    ;
      ACTION (oF:Abonos(), oF:Iniciar( oDlg,oLbx ));
      MESSAGE "Ver los Pagos (F8)"
   REDEFINE BTNBMP oBtn[7] ID 46 OF oDlg RESOURCE "OK"       ;
      ACTION oF:Facturar( oDlg,oLbx )    MESSAGE "Pasar Anticipo a Factura"
   REDEFINE BTNBMP oBtn[8] ID 47 OF oDlg RESOURCE "CALC"     ;
      ACTION WinExec("Calc")             MESSAGE "Calculadora"
   REDEFINE BTNBMP oBtn[9] ID 48 OF oDlg RESOURCE "SALIR"    ;
      ACTION oDlg:End()                  MESSAGE "Regresar al Menu"
   REDEFINE BROWSE oLbx ID 49 OF oDlg CELLED ;      // CELLED es requerida
      COLORS CLR_BLACK, CLR_NBLUE                   // para editar Celdas
   oLbx:SetArray( oF:aV )     // Esto es necesario para trabajar con arrays
//   oLbx:nFreeze     := 2
   oLbx:nHeightCell += 4
   oLbx:nHeightHead += 4
   oLbx:bKeyDown := {|nKey| If(nKey=VK_TAB, oLbx:oJump := oF:oG[3],;
                            If(nKey=VK_F3 , oBtn[1]:Click()       ,;
                            If(nKey=VK_F5 , oBtn[2]:Click()       ,;
                            If(nKey=VK_F6 , oBtn[3]:Click()       ,;
                            If(nKey=VK_F7 , oBtn[4]:Click()       ,;
                            If(nKey=VK_F8 , oBtn[6]:Click()       ,;
                            If(nKey=VK_F11, oBtn[5]:Click(), ))))))) }
   oLbx:SetAppendMode( oF:lNuevo )            // Activando Auto Append Mode
   oLbx:SetDeleteMode( .t.,.f.,{ |nAt,oLbx| oF:DelArray(oLbx) },;
                  {|oLbx| oF:Dscto( 0,oLbx ) } ) // lOnOff, lConfirm, bDelete

   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 1;
       TITLE "Código"+CRLF+"Artículo"            ;
       SIZE  90 EDITABLE;          // Esta columna es editable
       3DLOOK TRUE, TRUE, TRUE;    // Celda, Titulo, Footers
       MOVE DT_MOVE_NEXT;          // Cursor pasa a la Sig.Columna editable
       VALID { | uVar| oF:Buscar( uVar,oLbx,"" ) }; // don't want empty rows
       ALIGN DT_LEFT, DT_CENTER  ; // Celda, Titulo, Footer
       PREEDIT {|uVar| oF:aM[11] := uVar, nA := oLbx:nAt ,;
                       oF:aM[15] := If( nA > LEN(oF:aV), 0, oF:aV[nA,10] ) };
       FOOTER { || STR( oLbx:nLen,4 ) + " Items" };
       WHEN oF:EditArray( oLbx,oF:lCambia )
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
         oApl:oNit:Seek( {"codigo_nit",oF:oDb:CODIGO_NIT} ) }, 16 )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 2;
       TITLE "Descripción" ;
       SIZE 180 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER, DT_RIGHT;
       WHEN oF:EditArray( oLbx,oF:lCambia ) ;
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
       WHEN oF:EditArray( oLbx,oF:lCambia ) ;
       VALID { |uVar| oF:BuscaFac( oLbx:nAt,uVar,4 ) }
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 7;
       TITLE "Precio"+CRLF+"Neto"   PICTURE "99,999,999" ;
       SIZE  76 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       FOOTER { || TRANSFORM( oF:aM[09], "99,999,999" ) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oF:Dscto( 7,oLbx,uVar ), ) };
       WHEN oF:EditArray( oLbx,oF:lCambia )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 5;
       TITLE "%"+CRLF+"Dscto."   PICTURE "999.99" ;
       SIZE  48 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER ;
       VALID { |uVar| If( Rango( uVar,0,100 ), .t., ;
              (MsgStop( "El Porcentaje debe ser entre 0 y 100",">>OJO<<" ), .f.)) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oF:Dscto( 5,oLbx,uVar ), ) };
       WHEN oF:EditArray( oLbx,oF:lCambia )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 6;
       TITLE "Descuento"     PICTURE "99,999,999" ;
       SIZE  74 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| oF:BuscaFac( oLbx:nAt,uVar,6 ) }   ;
       FOOTER { || TRANSFORM( oF:aM[08], "99,999,999" ) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oF:Dscto( 6,oLbx,uVar ), ) };
       WHEN oF:EditArray( oLbx,oF:lCambia )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 8;
       TITLE "Monto"+CRLF+"I.V.A"   PICTURE "99,999,999" ;
       SIZE  74 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       FOOTER { || TRANSFORM( oF:aM[10], "99,999,999" ) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oF:Dscto( 0,oLbx,uVar ), ) };
       WHEN oF:EditArray( oLbx,oF:lCambia )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 13;
       TITLE "Precio"+CRLF+"Costo"  PICTURE "99,999,999.99" ;
       SIZE  74 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       WHEN oF:lPcosto
   // Asignando Valores por defaults para nueva Fila creada con Auto Append.
   oLbx:aDefault := { SPACE(12), SPACE(40), 0, 1, 0, 0, 0, 0, " ", 0, 0, 1, 0, "", 0 }
   oLbx:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbx:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color
ACTIVATE DIALOG oDlg CENTERED ON INIT oF:Division();
    VALID !GetKeyState( VK_ESCAPE )
//ACTIVATE DIALOG oDlg CENTERED NOWAIT ON INIT oF:Division();
//  VALID ( oApl:aWHija[2] := NIL, .t. )
//Else
//   oApl:aWHija[2]:SetFocus()
//EndIf
If( lNoBlink, SBNoBlink( aColor[1], aColor[2] ), Nil )
oF:oVen:Destroy()
oF:oPag:Destroy()
oDp:NEW( "FIN" )
RELEASE oF
If oApl:oEmp:LOCALIZ # oApl:cLocal .AND. oApl:oEmp:TITULAR # "COC"
   oApl:oEmp:Seek( {"localiz",oApl:cLocal} )
   nEmpresa( .t. )
EndIf
SETKEY( VK_F4,{||Empresa()} )
RETURN NIL

//------------------------------------//
CLASS TAnticipo FROM TFactura

 DATA lCambia       INIT .f.
 DATA lPcosto       INIT .f.
 DATA oVen, oPag

 METHOD NEW( oDlg ) Constructor
 METHOD Iniciar( oDlg,oLbx )
 METHOD AdicArray()
 METHOD DelArray( oLbx )
 METHOD DelFactu( oDlg,oLbx )
 METHOD Guardar( oDlg,oLbx )
 METHOD GrabaV( nCantidad,cCambio )
 METHOD CambiaFec()
 METHOD Listado( oDlg,oLbx )
 METHOD Mostrar( lAyuda,nOrd )
 METHOD Abonos()
 METHOD Borrar( oLbx,lBorrar )
 METHOD Facturar( oDlg,oLbx )

ENDCLASS

//------------------------------------//
METHOD NEW( oDlg ) CLASS TAnticipo
If oDlg == NIL
   Super:NEW( 1 )
   ::aM[1] := oApl:oEmp:FECVENTA
   ::oVen := oApl:Abrir( "cadantid","optica, numero",,,20 )
   ::oPag := oApl:Abrir( "cadantip","optica, numero",,,10 )
   ::lPcosto := If( TRIM( oApl:cUser ) == "Martin", .t., .f. )
  //ASIZE( ::oG,16 )
Else
/* If ::aM[2] == 0 .AND. oApl:oNit:TIPOFAC == "FAN       "
      ::aM[2] := If( EMPTY(oApl:oHis:FEC_NACIMI), oApl:oHis:EDAD, NtChr( oApl:oHis:FEC_NACIMI,"A" ) )
      ::oG[12]:nAt  := If( ::aM[2] <= 12, 1, 2 )
      ::cTipoF      := ::aEps[::oG[12]:nAt,1]
      ::oDb:TIPOFAC := ::aEps[::oG[12]:nAt,2]
      ::aM[2] := 0
      ::oG[12]:Refresh()
   EndIf*/
   ::oDb:CLIENTE  := XTrim( LEFT( oApl:oHis:NOMBRES,oApl:oHis:PNOMB+1 ) +;
                                  oApl:oHis:APELLIDOS,30 )
   ::oDb:DIRECC   := LEFT( oApl:oHis:DIRECCION,30 )
   ::oDb:TELEFONO := oApl:oHis:TEL_RESIDE
   ::oDb:CODIGO_CLI := oApl:oHis:CODIGO_NIT
   oDlg:Update()
EndIf
RETURN NIL

//------------------------------------//
METHOD Iniciar( oDlg,oLbx ) CLASS TAnticipo
   LOCAL cQry, hRes
If oDlg == NIL
   ::nIva    := ROUND( oApl:oEmp:PIVA/100,2 )
   ::nOptica := oApl:nEmpresa
   ::nSigFac := 1
   cQry := "SELECT MAX(numero) FROM cadantic WHERE optica = " +LTRIM(STR(::nOptica))
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   If MSNumRows( hRes ) > 0
      cQry := MyReadRow( hRes )
      AEVAL( cQry, { | xV,nP | cQry[nP] := MyClReadCol( hRes,nP ) } )
      ::nSigFac += cQry[1]
   EndIf
   MSFreeResult( hRes )
Else
   AEVAL( ::aM, {|xV,nI| ::aM[nI] := {"",CTOD(""),.f.,0}[AT(VALTYPE(xV),"CDLN")] },2 )
   ::AdicArray() ; oLbx:aArray := ::aV
   ::Division()  ; ::oDb:xBlank()
   oDlg:Update() ; oLbx:Refresh()
   oLbx:nCell := oLbx:nColPos := 1
   oLbx:HiliteCell( 1 )
   ::oG[01]:SetFocus()
EndIf
RETURN NIL

//------------------------------------//
METHOD AdicArray() CLASS TAnticipo
   LOCAL nVal
If ::aM[2] == 0
   ::aM[7] := ""
   ::lNuevo:= .t.
   oApl:oNit:Seek( {"codigo",0} )
   oApl:nEmpresa   := ::nOptica
   ::oDb:lOK       := .f.
   ::oDb:FECHA     := oApl:dFec
   ::oDb:FECHAENT  := oApl:dFec + If( DOW( oApl:dFec ) <= 3, 3, 5 )
   ::oDb:CODIGO_NIT:= oApl:oNit:CODIGO_NIT
   ::oDb:INDICADOR := "P"
   ::oDb:VENDEDOR  := If( oApl:cLocal == "COC", "     ", LEFT( oApl:cUser,5 ) )
Else
   oApl:oNit:Seek( {"codigo_nit",::oDb:CODIGO_NIT} )
   oApl:oHis:Seek( {"codigo_nit",::oDb:CODIGO_CLI} )
   If ::nOptica == ::oDb:OPTICA
      nVal := AT( ::oDb:INDICADOR,"APCN" ) +1
      If ::oDb:NUMFAC # 0 .AND. nVal # 5
         ::aM[7] := "FACTURADO"
      Else
         ::aM[7] := {"","ANULADO","PENDIENTE","CANCELADO","N.Credito"}[nVal]
      EndIf
   Else
      ::aM[7] := ArrayValor( oApl:aOptic,STR(::oDb:OPTICA,2) )
   EndIf
   nVal    := ::oDb:FECHA + If( oApl:nEmpresa == 4, 1, 0 )
   ::aM[21]:= If( nVal > oApl:oEmp:FECVENTA, .t., .f. )
   ::lNuevo:= !oApl:lEnLinea
   //MsgInfo( DTOC(nVal),If( ::aM[21], "SI", "NO" ) )
EndIf
 ::aV := {}
 ::cDesc := ""
 ::oVen:Seek( {"optica",oApl:nEmpresa,"numero",::aM[2]},"row_id" )
While !::oVen:Eof()
   If ::oVen:CODART   == "0203        "
      ::cDesc := ALLTRIM( ::oVen:DESCRI )
   EndIf
   If ::aM[21] .AND. Rango( LEFT(::oVen:CODART,4),{"0201","0503","0505"} )
      ::aM[05] := " *"
      //MsgInfo( ::aM[05],"SI" )
   Else
      ::aM[05] := ::oVen:INDICADOR+"-"+DTOC(::oVen:FECDEV)
      //MsgInfo( ::aM[05],"NO" )
   EndIf
   ::aM[17] := If( ::oVen:MONTOIVA == 0, 0, ::nIva ) + 1
   nVal := ROUND( (::oVen:PRECIOVEN + ::oVen:DESMON)/::oVen:CANTIDAD,2 )
   AADD( ::aV,{ ::oVen:CODART   , ::oVen:DESCRI  , ::oVen:PPUBLI,;
                ::oVen:CANTIDAD , ::oVen:DESPOR  , ::oVen:DESMON,;
                ::oVen:PRECIOVEN, ::oVen:MONTOIVA, ::aM[05]     ,;
                ::oVen:ROW_ID   , nVal, ::aM[17] ,;
                ::oVen:PCOSTO   , ::oVen:ORDENEMP, ::oVen:PCOSTO } )
   ::oVen:Skip(1):Read()
   ::oVen:xLoad()
EndDo
If LEN( ::aV ) == 0
   AADD( ::aV,{ SPACE(12), SPACE(40), 0, 1, 0, 0, 0, 0, " ", 0, 0, 1, 0, "", 0 } )
EndIf
 ::aM[3] := oApl:oNit:CODIGO ; ::aM[5] := oApl:oNit:NOMBRE
 ::aM[4] := If( ::oDb:CODIGO_CLI > 0, oApl:oHis:NROIDEN, SPACE(15) )
 ::aM[6] := ::oDb:TOTALFAC
 ::dFec  := ::oDb:FECHA
 ::lCambia := (::oDb:NUMFAC != 0)
oApl:Tipo := ::cTipo
oApl:cPer := NtChr( ::dFec,"1" )
SysRefresh()
RETURN NIL

//------------------------------------//
METHOD DelArray( oLbx ) CLASS TAnticipo
   LOCAL lSi := .f., nA := oLbx:nAt
do Case
Case ::aV[nA,10] == 0
   lSi := .t.
Case ::oDb:NUMFAC == 0
   If MsgNoYes( "Elimina este Código",::aV[nA,01] )
      ::oVen:Seek( {"row_id",::aV[nA,10]} )
      ::GrabaV( ::aV[nA,04],"S" )
      ::oVen:Delete(.f.,1)
      If ::oDb:FECHA < ::aM[1]
         MsgStop( "Comunicarse con Sistemas para que"+CRLF+;
                  "Te hagan el favor de modificarlo","<<< OJO >>>" )
      EndIf
      lSi := .t.
   EndIf
EndCase
RETURN lSi

//------------------------------------//
METHOD DelFactu( oDlg,oLbx ) CLASS TAnticipo
   LOCAL cQry, nR
If ::oDb:lOK .AND. ::oDb:INDICADOR # "A" .AND.;
   ::oDb:NUMFAC == 0
   ::oPag:Seek( {"optica",oApl:nEmpresa,"numero",::oDb:NUMERO} )
   If ::oPag:nRowCount > 0 .AND. ::oDb:FECHA < oApl:dFec
      MsgStop( "Este Anticipo se Anula con un Diario","<<< OJO >>>" )
   ElseIf Login( "Desea Anular está Venta" )
      ::oDb:FECHAENT  := FechaDev( "Fecha Anulación",::oDb:FECHA )
      ::oDb:INDICADOR := "A"
      Guardar( ::oDb,.f.,.f. )
      cQry := "DELETE FROM cadantip " +;
              "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND numero = " + LTRIM(STR(::aM[2]))
      MSQuery( oApl:oMySql:hConnect,cQry )
      cQry := "DELETE FROM cadrcaja " +;
              "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND rcaja  = " + LTRIM(STR(::oPag:RCAJA))
      MSQuery( oApl:oMySql:hConnect,cQry )
      FOR nR := 1 TO LEN( ::aV )
         If ::aV[nR,10] > 0
            ::oVen:Seek( {"row_id",::aV[nR,10]} )
            ::GrabaV( 1,"S" )
            If ::oDb:FECHA == oApl:dFec
               ::oVen:Delete(.f.,1)
            EndIf
         EndIf
      NEXT
      If ::oDb:FECHA < ::aM[1]
         MsgStop( "Comunicarse con Sistemas para que"+CRLF+;
                  "Te hagan el favor de Anularlo","<<< OJO >>>" )
      EndIf
      ::Iniciar( oDlg,oLbx )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Guardar( oDlg,oLbx ) CLASS TAnticipo
   LOCAL aPago := {}, lCambio, nAbono, nValor, nR
/*
If oApl:oEmp:DTOCOMER > 0
   ::Servicios( "Descuento COSTO de Lentes o Servicios" )
   oLbx:Refresh()
   RETURN NIL
EndIf
*/
If EMPTY( ::aV[1,1] ) .AND. ::oDb:INDICADOR # "A"
   MsgInfo( "Anticipo no Tiene ningun Items" )
   RETURN NIL
ElseIf EMPTY( ::aM[4] ) .AND. ::oDb:FECHA >= CTOD("01.12.2011")
   MsgInfo( "Doc. Identidad es Obligatorio",">>> OJO <<<" )
   ::oG[4]:SetFocus()
   RETURN NIL
EndIf
nAbono := nValor := 0
If !::oDb:lOK
   oApl:nSaldo := ::oDb:TOTALFAC
   oApl:oFac:CLIENTE := ::oDb:CLIENTE
   While oApl:nSaldo > 0 .AND. ::aM[3] == 0
      If CaoPagos(,,::aPag) .AND. !EMPTY( oApl:oPag:ABONO )
         nAbono += oApl:oPag:PAGADO
         nR     := oApl:oPag:ABONO     + oApl:oPag:DEDUCCION +;
                   oApl:oPag:RETENCION + oApl:oPag:DESCUENTO +;
                   oApl:oPag:RETIVA    + oApl:oPag:RETICA    + oApl:oPag:RETCRE
         nValor += nR
         oApl:nSaldo -= nR
         AADD( aPago, {oApl:oPag:ABONO    , oApl:oPag:RETENCION,;
                       oApl:oPag:DEDUCCION, oApl:oPag:DESCUENTO,;
                       oApl:oPag:NUMCHEQUE, oApl:oPag:CODBANCO ,;
                       oApl:oPag:FORMAPAGO, oApl:oPag:INDRED   ,;
                       oApl:oPag:PAGADO   , oApl:oPag:RETIVA   ,;
                       oApl:oPag:RETICA   , oApl:oPag:RETCRE  })
      Else
         Exit
      EndIf
   EndDo
   If !MsgYesNo("Anticipo #"+STR(::nSigFac),"Graba este")
      RETURN NIL
   EndIf
   If !oApl:lEnLinea
      oApl:dFec := ::oDb:FECHA
   ElseIf ::oDb:FECHA < oApl:oEmp:FEC_HOY
      ::oDb:FECHA    := oApl:oEmp:FEC_HOY
      ::oDb:FECHAENT := ::oDb:FECHA + If( DOW( ::oDb:FECHA ) <= 3, 3, 5 )
   EndIf
   ::oDb:OPTICA  := oApl:nEmpresa
   Guardar( ::oDb,.t.,.t. )
   oApl:nSaldo := ::oDb:TOTALFAC
   ::nSigFac   := ::oDb:NUMERO + 1
   lCambio := .t.
   ::Servicios( ,0 )
Else
   If (lCambio := ::oDb:TOTALFAC # ::aM[6])
      If !MsgNoYes( TRANSFORM( ::oDb:TOTALFAC,"NUEVO 999,999,999" ) +;
         TRANSFORM( ::aM[6]," - VIEJO 999,999,999" ),"EL TOTAL ES DIFERENTE" )
         RETURN NIL
      EndIf
   EndIf
   nAbono := Buscar( "SELECT SUM(pagado) FROM cadantip "          +;
                     "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
                      " AND numero = " + LTRIM(STR(::aM[2])),"CM",,8 )
   If EMPTY( nAbono )
      nAbono := 0
   EndIf
   //nAbono      := ::oDb:SALDOFAC - ::aM[6]
   oApl:nSaldo := ::oDb:TOTALFAC
   ::Servicios( ,1 )
EndIf
If lCambio .AND. ::oDb:INDICADOR # "A"
   ::oDb:SALDOFAC := oApl:nSaldo - nAbono
   If ::oDb:SALDOFAC == 0
      ::oDb:INDICADOR := "C" ; ::oDb:FECHACAN := ::oDb:FECHA
   Else
      ::oDb:INDICADOR := "P" ; ::oDb:FECHACAN := CTOD("")
   EndIf
EndIf
Guardar( ::oDb,.f.,.f. )
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
      If (lCambio := (::aV[nR,10] == 0))
         ::oVen:xBlank()                 ; ::oVen:OPTICA  := oApl:nEmpresa
         ::oVen:NUMERO   := ::oDb:NUMERO ; ::oVen:FECHA   := ::oDb:FECHA
      Else
         ::oVen:Seek( {"row_id",::aV[nR,10]} )
         nAbono    := ::oVen:CANTIDAD * -1
         If ::oVen:CODART # ::aV[nR,1]
            ::GrabaV( nAbono,"S" )
            nAbono := 0
         EndIf
      EndIf
         ::oVen:CODART   := ::aV[nR,1] ; ::oVen:DESCRI    := ::aV[nR,2]
         ::oVen:CANTIDAD := ::aV[nR,4] ; ::oVen:PRECIOVEN := ::aV[nR,7]
         ::oVen:DESPOR   := ::aV[nR,5] ; ::oVen:DESMON    := ::aV[nR,6]
         ::oVen:MONTOIVA := ::aV[nR,8] ; ::oVen:PPUBLI    := ::aV[nR,3]
         ::oVen:PCOSTO   := ::aV[nR,13]; ::oVen:ORDENEMP  := ::aV[nR,14]
        Guardar( ::oVen,lCambio,.f. )
      ::GrabaV( nAbono+::aV[nR,4],"N" )
   EndIf
NEXT nR
If ::oDb:NUMERO # ::aM[2]
   If LEN( aPago ) > 0
      ::oPag:Seek( {"optica",oApl:nEmpresa,"numero",::oDb:NUMERO} )
      ::oPag:OPTICA := oApl:nEmpresa ; ::oPag:NUMERO   := ::oDb:NUMERO
      ::oPag:FECHA  := ::oDb:FECHA   ; ::oPag:PORDONDE := "F"
      ::oPag:RCAJA  := RCaja( .t.,::oDb:CODIGO_NIT,::oDb:FECHA,"A",ALLTRIM(::aM[4]) )
   EndIf
   FOR nR := 1 TO LEN( aPago )
      ::oPag:ABONO     := aPago[nR,01]; ::oPag:RETENCION := aPago[nR,02]
      ::oPag:DEDUCCION := aPago[nR,03]; ::oPag:DESCUENTO := aPago[nR,04]
      ::oPag:NUMCHEQUE := aPago[nR,05]; ::oPag:CODBANCO  := aPago[nR,06]
      ::oPag:FORMAPAGO := aPago[nR,07]; ::oPag:INDRED    := aPago[nR,08]
      ::oPag:PAGADO    := aPago[nR,09]; ::oPag:RETIVA    := aPago[nR,10]
      ::oPag:RETICA    := aPago[nR,11]; ::oPag:RETCRE    := aPago[nR,12]
      Guardar( ::oPag,.t.,.f. )
   NEXT
   oApl:nSaldo := ::oDb:TOTALFAC - nValor
   ::Listado( oDlg,oLbx )
Else
   ::Iniciar( oDlg,oLbx )
EndIf
RETURN NIL

//--Marca las Monturas-------------------------//
METHOD GrabaV( nCantidad,cCambio ) CLASS TAnticipo
   LOCAL cGru
If LEFT(::oVen:CODART,2) # "01" .OR. nCantidad == 0
   RETURN NIL
EndIf
If oApl:oInv:Seek( {"codigo",::oVen:CODART} )
   If oApl:oInv:OPTICA == ::oVen:OPTICA .AND.;
     (oApl:oInv:FACTUVEN == 0 .OR. oApl:oInv:FACTUVEN == ::oVen:NUMERO)
      cGru := If( cCambio == "S", { 0,0,CTOD(""),"E" },;
                { ::oVen:PRECIOVEN,::oVen:NUMERO,::oVen:FECHA,"A" } )
      oApl:oInv:PVENDIDA := cGru[1] ; oApl:oInv:FACTUVEN  := cGru[2]
      oApl:oInv:FECVENTA := cGru[3] ; oApl:oInv:SITUACION := cGru[4]
      Guardar( oApl:oInv,.f.,.f. )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD CambiaFec() CLASS TAnticipo
   LOCAL nR, dFec := ::oDb:XColumn( 3 ) //Fac->FECHA
FOR nR := 1 TO LEN( ::aV )
   If ::aV[nR,10] > 0
      ::oVen:Seek( {"row_id",::aV[nR,10]} )
      If ::oVen:FECHA == dFec
         ::oVen:FECHA := ::oDb:FECHA ; Guardar( ::oVen,.f.,.f. )
         ::GrabaV( 1,"N" )
      EndIf
   EndIf
NEXT
::oPag:Seek( {"optica",oApl:nEmpresa,"numero",::aM[2]} )
While !::oPag:Eof()
   If ::oPag:FECHA == dFec
      ::oPag:FECHA := ::oDb:FECHA ; Guardar( ::oPag,.f.,.f. )
   EndIf
   ::oPag:Skip(1):Read()
   ::oPag:xLoad()
EndDo
Guardar( ::oDb,.f.,.f. )
MsgInfo( "El cambio de Fecha","HECHO" )
RETURN NIL

//------------------------------------//
METHOD Listado( oDlg,oLbx ) CLASS TAnticipo
If ::oDb:lOK //.AND. oApl:lEnLinea
   If MsgNoYes( "Quite las FACTURAS y coloque papel Blanco","IMPRIME ESTA FACTURA" )
      oApl:Tipo := "Z"
      CaoLiFac( ::oDb:NUMERO,::aV,{::aM[4],::cTipoF} )
   EndIf
   ::Iniciar( oDlg,oLbx )
EndIf
RETURN NIL

//------------------------------------//
METHOD Mostrar( lAyuda,nOrd ) CLASS TAnticipo
   LOCAL oDlg, oM := Self, lReturn := .f.
   LOCAL bHacer := {|| lReturn := .t., oDlg:End() }
   DEFAULT lAyuda := .t., nOrd := 2
nOrd := ::Ordenar( nOrd )

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE "Ayuda de Anticipos"
   @ 1.5, 0 LISTBOX ::oLbx FIELDS  ;
               STR( ::oDb:NUMERO ),;
              DTOC( ::oDb:FECHA ) ,;
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
    ::oLbx:oFont      := ::oFont
    ::oLbx:aColSizes  := {70,70,200,60}
    ::oLbx:aHjustify  := {2,2,2,2}
    ::oLbx:aJustify   := {1,0,0,2}
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN, (EVAL(bHacer)),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) ) }
    ::oLbx:lCellStyle  := ::oLbx:ladjbrowse  := .f.
    ::oLbx:ladjlastcol := .t.
   MySetBrowse( ::oLbx,::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT ( oM:Barra(lAyuda,oDlg) )
::oDb:Setorder(nOrd)
RETURN lReturn

//------------------------------------//
METHOD Abonos() CLASS TAnticipo
   LOCAL oDlg, oGet, oLbp, cPict := "999,999,999.99"
oApl:oFac:CLIENTE := ::oDb:CLIENTE
::oPag:Seek( {"optica",oApl:nEmpresa,"numero",::aM[2]},"fecha" )
DEFINE DIALOG oDlg FROM 0, 3 TO 14,90 TITLE "Abonos de Anticipos"
   @ 0.5, 1 SAY ::oDb:CLIENTE OF oDlg UPDATE COLOR CLR_BLACK, NIL;
      SIZE 100,18 FONT ::oFont
   @ 1.5,.5 LISTBOX oLbp FIELDS             DTOC( ::oPag:FECHA )         ,;
        ::aPag[::oPag:FORMAPAGO+1,1]  ,           ::oPag:CODBANCO        ,;
     TRANSFORM(::oPag:PAGADO   ,cPict), TRANSFORM(::oPag:ABONO    ,cPict),;
     TRANSFORM(::oPag:DEDUCCION,cPict), TRANSFORM(::oPag:RETENCION,cPict),;
     TRANSFORM(::oPag:DESCUENTO,cPict),           ::oPag:NUMCHEQUE       ,;
           STR(::oPag:RCAJA ) ;
      HEADERS "Fecha", "FormaPago", "Banco", "Total Pago", "Monto Pago"  ,;
              "DEDUCCION", "RETENCION", "DESCUENTO", "DOCUMENTO", "RCAJA" ;
      SIZES 400,450 SIZE 338,70
    oLbp:nClrBackHead  := oApl:nClrBackHead
    oLbp:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbp:nClrBackFocus := oApl:nClrBackFocus
    oLbp:nClrForeFocus := oApl:nClrForeFocus
    oLbp:nHeaderHeight := 28
    oLbp:GoTop()
    oLbp:oFont     := ::oFont
    oLbp:aColSizes := {60,64,40,82,82,82,82,82,90,60}
    oLbp:aHjustify := {2,2,2,2,2,2,2,2,2,2}
    oLbp:aJustify  := {1,0,2,1,1,1,1,1,0,1}
    oLbp:bKeyDown  := {|nKey| If(nKey = VK_RETURN, ::Borrar( oLbp )  ,;
                              If(nKey = VK_INSERT, ::Borrar(oLbp,.t.),;
                              If(nKey = VK_F3                        ,;
                                 ReciCaja( {::oPag:FECHA,::oPag:FECHA,::oPag:RCAJA,oApl:nTFor,.t.,"",.t.} ),;
                              If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, ::Borrar(oLbp,.f.), )))) }
    oLbp:ladjbrowse  := oLbp:lCellStyle := .f.
    oLbp:ladjlastcol := .t.
   MySetBrowse( oLbp,::oPag )
   @  02, 90 SAY "Saldo" OF oDlg RIGHT PIXEL SIZE 40,10
   @  02,132 GET oGet VAR ::oDb:SALDOFAC OF oDlg PICTURE "99,999,999";
      WHEN ::oDb:INDICADOR # "A"                                    ;
      VALID EVAL({|| If( ::oDb:SALDOFAC # ::oDb:XColumn(17)        ,;
                       (If( ::oDb:SALDOFAC == 0                    ,;
                          ( ::oDb:INDICADOR := "C"                 ,;
                            ::oDb:FECHACAN  := ::oDb:FECHA )       ,;
                          ( ::oDb:INDICADOR := "P"                 ,;
                            ::oDb:FECHACAN  := CTOD("") ) )        ,;
                            ::oDb:Update(.f.,1) ), )               ,;
                     oGet:oJump := oLbp, .t. } )                    ;
      SIZE 40,10 PIXEL
   @  94, 04 SAY "[Enter] Para Modificar, [Insert] Para un nuevo pago" OF oDlg RIGHT PIXEL SIZE 120,10
ACTIVATE DIALOG oDlg CENTER
RETURN NIL

//------------------------------------//
METHOD Borrar( oLbx,lBorrar ) CLASS TAnticipo
   LOCAL nPago
If lBorrar == NIL .OR. lBorrar
   If lBorrar == NIL
      lBorrar := .f.                         ; oApl:oPag:xBlank()
      oApl:oPag:FECPAG    := ::oPag:FECHA    ; oApl:oPag:ABONO     := ::oPag:ABONO
      oApl:oPag:RETENCION := ::oPag:RETENCION; oApl:oPag:DEDUCCION := ::oPag:DEDUCCION
      oApl:oPag:DESCUENTO := ::oPag:DESCUENTO; oApl:oPag:NUMCHEQUE := ::oPag:NUMCHEQUE
      oApl:oPag:CODBANCO  := ::oPag:CODBANCO ; oApl:oPag:FORMAPAGO := ::oPag:FORMAPAGO
      oApl:oPag:INDRED    := ::oPag:INDRED   ; oApl:oPag:PAGADO    := ::oPag:PAGADO
      oApl:oPag:RETIVA    := ::oPag:RETIVA   ; oApl:oPag:RETICA    := ::oPag:RETICA
      oApl:oPag:RETCRE    := ::oPag:RETCRE
   ElseIf ::oDb:NUMFAC # 0
      MsgStop( "Anticipo ya esta FACTURADO",">>> OJO <<<" )
      RETURN NIL
   EndIf
      oApl:nSaldo      := ::oDb:SALDOFAC
   If CaoPagos(.f.,lBorrar,::aPag)
      If lBorrar
         ::oPag:xBlank()
         ::oPag:OPTICA := oApl:nEmpresa ; ::oPag:NUMERO   := ::oDb:NUMERO
         ::oPag:FECHA  := oApl:dFec     ; ::oPag:PORDONDE := "P"
         ::oPag:RCAJA  := RCaja( .t.,::oDb:CODIGO_NIT,oApl:dFec,"A",ALLTRIM(::aM[4]) )
      EndIf
      nPago            := ::oPag:PAGADO      ; ::oPag:ABONO     := oApl:oPag:ABONO
      ::oPag:RETENCION := oApl:oPag:RETENCION; ::oPag:DEDUCCION := oApl:oPag:DEDUCCION
      ::oPag:DESCUENTO := oApl:oPag:DESCUENTO; ::oPag:NUMCHEQUE := oApl:oPag:NUMCHEQUE
      ::oPag:CODBANCO  := oApl:oPag:CODBANCO ; ::oPag:FORMAPAGO := oApl:oPag:FORMAPAGO
      ::oPag:INDRED    := oApl:oPag:INDRED   ; ::oPag:PAGADO    := oApl:oPag:PAGADO
      ::oPag:RETIVA    := oApl:oPag:RETIVA   ; ::oPag:RETICA    := oApl:oPag:RETICA
      ::oPag:RETCRE    := oApl:oPag:RETCRE
      Guardar( ::oPag,lBorrar,.f. )
      ::oDb:SALDOFAC   += (nPago - ::oPag:PAGADO)
      If ::oDb:SALDOFAC == 0
         ::oDb:INDICADOR := "C" ; ::oDb:FECHACAN := ::oDb:FECHA
      Else
         ::oDb:INDICADOR := "P" ; ::oDb:FECHACAN := CTOD("")
      EndIf
      Guardar( ::oDb,.f.,.f. )
   EndIf
Else
   If Login( "Quiere Borrar este Pago" )
      If ::oPag:PAGADO # 0 .AND. ::oDb:INDICADOR # "A"
         ::oDb:SALDOFAC  += ::oPag:PAGADO
         ::oDb:INDICADOR := "P" ; ::oDb:FECHACAN := CTOD("")
         Guardar( ::oDb,.f.,.f. )
      EndIf
      ::oPag:Delete(.f.,1)
   EndIf
EndIf
oLbx:Refresh()
RETURN NIL

//------------------------------------//
METHOD Facturar( oDlg,oLbx ) CLASS TAnticipo
   LOCAL aPago := {}, nPago, nAbono := 0, nValor := 0, nR
If ::oDb:TOTALFAC == 0 .OR. ::oDb:NUMFAC > 0 .OR. ::oDb:INDICADOR == "A"
   RETURN NIL
EndIf
   nR := ASCAN( ::aV, { |x| TRIM(x[1]) == "0599000001" } )
If nR > 0
   If !MsgNoYes( ::aV[nR,2],">>> Código de EXCEDENTE <<<" )
      RETURN NIL
   EndIf
EndIf
::oPag:dbEval( {|o| AADD( aPago,{o:ABONO    , o:RETENCION, o:DEDUCCION,;
                                 o:DESCUENTO, o:NUMCHEQUE, o:CODBANCO ,;
                                 o:FORMAPAGO, o:INDRED   , o:PAGADO   ,;
                                 "A"        , o:RETIVA   , o:RETICA   , o:RETCRE}),;
                    nValor += (o:ABONO + o:DEDUCCION  + o:RETENCION +  ;
                               o:DESCUENTO + o:RETIVA + o:RETICA    + o:RETCRE)   ,;
                    nAbono += o:PAGADO }                              ,;
               {"optica",oApl:nEmpresa,"numero",::oDb:NUMERO} )
oApl:nSaldo := ::oDb:TOTALFAC - nValor
oApl:oFac:Seek( {"optica",oApl:nEmpresa,"numfac",0,"tipo",oApl:Tipo} )
While oApl:nSaldo > 0
   If CaoPagos(,,::aPag) .AND. !EMPTY( oApl:oPag:ABONO )
      nAbono += oApl:oPag:PAGADO
      nPago  := oApl:oPag:ABONO     + oApl:oPag:DEDUCCION +;
                oApl:oPag:RETENCION + oApl:oPag:DESCUENTO +;
                oApl:oPag:RETIVA    + oApl:oPag:RETICA    + oApl:oPag:RETCRE
      nValor += nPago
      oApl:nSaldo -= nPago
      AADD( aPago, {oApl:oPag:ABONO    , oApl:oPag:RETENCION,;
                    oApl:oPag:DEDUCCION, oApl:oPag:DESCUENTO,;
                    oApl:oPag:NUMCHEQUE, oApl:oPag:CODBANCO ,;
                    oApl:oPag:FORMAPAGO, oApl:oPag:INDRED   ,;
                    oApl:oPag:PAGADO   , "F"                ,;
                    oApl:oPag:RETIVA   , oApl:oPag:RETICA   , oApl:oPag:RETCRE})
   Else
      Exit
   EndIf
EndDo
If (nPago := oApl:nEmpresa) == 21
   If oApl:nSaldo > 0
      MsgStop( "NO SE PUEDE SUBIR CON SALDO","ANTICIPO DE FOCA" )
      RETURN NIL
   EndIf
   oApl:nEmpresa := 18
   ::aM[4] := Buscar( "SELECT r.nroiden FROM cadrcaja r, cadantip p "  +;
                      "WHERE r.optica = p.optica AND r.rcaja = p.rcaja"+;
                       " AND p.optica = " + LTRIM(STR(nPago))          +;
                       " AND p.numero = " + LTRIM(STR(::oDb:NUMERO)),"CM",,8 )
EndIf
nR := SgteNumero( "numfacu",oApl:nEmpresa,.f. )
If !MsgYesNo("Factura #"+STR(nR),"Graba esta")
   oApl:nEmpresa := nPago
   RETURN NIL
EndIf
oApl:nSaldo := ::oDb:TOTALFAC
oApl:oFac:OPTICA    := oApl:nEmpresa
oApl:oFac:NUMFAC    := SgteNumero( "numfacu",oApl:nEmpresa )
oApl:oFac:TIPO      := oApl:Tipo        ; oApl:oFac:FECHOY    := oApl:oEmp:FEC_HOY
oApl:oFac:VENDEDOR  := ::oDb:VENDEDOR //; oApl:oFac:ORDEN     := ::oDb:ORDEN
oApl:oFac:GAVETA    := ::oDb:GAVETA     ; oApl:oFac:CLIENTE   := ::oDb:CLIENTE
oApl:oFac:DIRECC    := ::oDb:DIRECC     ; oApl:oFac:TELEFONO  := ::oDb:TELEFONO
oApl:oFac:CODIGO_NIT:= ::oDb:CODIGO_NIT ; oApl:oFac:CODIGO_CLI:= ::oDb:CODIGO_CLI
oApl:oFac:AUTORIZA  := If( nPago == 21, "FOCA"    ,;
                       If( ::aM[3] > 0, "LIBRANZA",;
                       If( nAbono == 0, "CREDITO", "CONTADO")))
oApl:oFac:FECHAENT  := ::oDb:FECHAENT   ; oApl:oFac:TOTALDES  := ::oDb:TOTALDES
oApl:oFac:TOTALIVA  := ::oDb:TOTALIVA   ; oApl:oFac:TOTALFAC  := ::oDb:TOTALFAC
oApl:oFac:INDICADOR := ::oDb:INDICADOR  ; oApl:oFac:VALOREPS  := ::oDb:VALOREPS
oApl:oFac:TIPOFAC   := ::oDb:TIPOFAC    ; oApl:oFac:REMPLAZA  := ::oDb:NUMERO
If ::aM[3] > 0 .AND. !oApl:oNit:CONVENIO
   If MsgYesNo( ::aM[5],"Sin Convenio" )
      oApl:oFac:AUTORIZA := "GRUPO"
   EndIf
EndIf
If (oApl:nSaldo - nAbono) == 0
   oApl:oFac:INDICADOR := "C" ; oApl:oFac:FECHACAN := oApl:oFac:FECHOY
Else
   oApl:oFac:INDICADOR := "P"
EndIf
BuscaDup( oApl:oFac:NUMFAC,oApl:Tipo,.t. )
Guardar( oApl:oFac,.t.,.t. )
oApl:cPer := NtChr( oApl:oFac:FECHOY,"1" )
oApl:lFam := .f.
GrabaSal( oApl:oFac:NUMFAC,1,nAbono )
::oDb:NUMFAC := oApl:oFac:NUMFAC ; Guardar( ::oDb,.f.,.f. )
//oApl:oVen:Seek( {"optica",oApl:nEmpresa,"numfac",oApl:oFac:NUMFAC,"tipo",oApl:Tipo} )
FOR nR := 1 TO LEN( ::aV )
   If !EMPTY( ::aV[nR,01] ) .AND. LEFT( ::aV[nR,09],1 ) == " "
      oApl:oVen:Seek( {"row_id",0} )
      oApl:oVen:OPTICA   := oApl:nEmpresa
      oApl:oVen:NUMFAC   := oApl:oFac:NUMFAC
      oApl:oVen:TIPO     := oApl:Tipo  ; oApl:oVen:FECFAC    := oApl:oFac:FECHOY
      oApl:oVen:CODART   := ::aV[nR,1] ; oApl:oVen:DESCRI    := ::aV[nR,2]
      oApl:oVen:CANTIDAD := ::aV[nR,4] ; oApl:oVen:PRECIOVEN := ::aV[nR,7]
      oApl:oVen:DESPOR   := ::aV[nR,5] ; oApl:oVen:DESMON    := ::aV[nR,6]
      oApl:oVen:MONTOIVA := ::aV[nR,8] ; oApl:oVen:PPUBLI    := ::aV[nR,3]
      oApl:oVen:PCOSTO   := ::aV[nR,13]; oApl:oVen:ORDENEMP  := ::aV[nR,14]
      oApl:nEmpresa := nPago
      Guardar( oApl:oVen,.t.,.t. )
      GrabaV( ::aV[nR,4],"N",2,oApl:oFac:FECHOY,::oDb:NUMERO,1 )
      oApl:nEmpresa := oApl:oFac:OPTICA
   EndIf
NEXT nR
If LEN( aPago ) > 0
   oApl:oPag:Seek( {"optica",oApl:nEmpresa,"numfac",oApl:oFac:NUMFAC,"tipo",oApl:Tipo} )
   oApl:oPag:OPTICA := oApl:nEmpresa ; oApl:oPag:NUMFAC := oApl:oFac:NUMFAC
   oApl:oPag:TIPO   := oApl:Tipo     ; oApl:oPag:FECPAG := oApl:oFac:FECHOY
   oApl:oPag:RCAJA  := RCaja( .t.,::oDb:CODIGO_NIT,oApl:oFac:FECHOY,"T",ALLTRIM(::aM[4]) )
EndIf
 FOR nR := 1 TO LEN( aPago )
    oApl:oPag:ABONO     := aPago[nR,01]; oApl:oPag:RETENCION := aPago[nR,2]
    oApl:oPag:DEDUCCION := aPago[nR,03]; oApl:oPag:DESCUENTO := aPago[nR,4]
    oApl:oPag:NUMCHEQUE := aPago[nR,05]; oApl:oPag:CODBANCO  := aPago[nR,6]
    oApl:oPag:FORMAPAGO := aPago[nR,07]; oApl:oPag:INDRED    := aPago[nR,8]
    oApl:oPag:PAGADO    := aPago[nR,09]; oApl:oPag:PORDONDE  := aPago[nR,10]
    oApl:oPag:RETIVA    := aPago[nR,11]; oApl:oPag:RETICA    := aPago[nR,12]
    oApl:oPag:RETCRE    := aPago[nR,13]
    Guardar( oApl:oPag,.t.,.f. )
 NEXT
 oApl:nSaldo := oApl:oFac:TOTALFAC - nValor
 CaoLiFac( oApl:oFac:NUMFAC,::aV,{::aM[4],::cTipoF} )
 oApl:nEmpresa := nPago
 ::Iniciar( oDlg,oLbx )
RETURN NIL

//------------------------------------//
PROCEDURE BuscaDup( nNumfac,cTipo,lOK )
   LOCAL aRes, hRes, cQry
If cTipo # "Z"
   cQry := "SELECT fechoy FROM cadfactu "               +;
           "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND numfac = " + LTRIM(STR(nNumfac))      +;
            " AND tipo  = '" + cTipo + "'"
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   If MSNumRows( hRes ) > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      If aRes[1] == oApl:dFec .AND. lOK
         Guardar( STRTRAN(cQry,"SELECT fechoy","DELETE"),"cadfactu" )
      Else
         Renumera( { aRes[1],aRes[1],0,nNumfac,nNumfac,0 } )
      EndIf
   EndIf
   MSFreeResult( hRes )
EndIf
RETURN