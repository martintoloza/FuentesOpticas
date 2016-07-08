// Programa.: INOLICRE.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Lista Notas Creditos de Opticas
/*
CLASE := 1.Anulación          ANULAP := 1.Bono
         2.Devolución                   2.Devolucion del Dinero
         3.Saldo                        3.Ninguna de las Anteriores
         4.Cruce Cuenta
         5.Anticipos
BONOS := ANULAP == 1.Bono
DEVOL := ANULAP == 2.Devolucion del Dinero Y 3.Ninguna de las Anteriores
*/

#include "FiveWin.ch"
#include "TSBrowse.ch"
#include "Btnget.ch"

MEMVAR oApl

#define CLR_PINK  nRGB( 128, 150, 150 )
#define CLR_NBLUE nRGB( 128, 128, 192 )

PROCEDURE NCredito( nA )
   LOCAL oDlg, oLbx, oLbp, aColor[ 2 ], lPer, lNoBlink := .f.
   LOCAL oGet := ARRAY(9), oN, cTipo := "Factura Nro."
If (aColor[ 1 ] := GetSysColor( COLOR_INACTIVECAPTION ) ) != ;
   GetSysColor( COLOR_ACTIVECAPTION )
   aColor[ 2 ] := GetSysColor( COLOR_INACTCAPTEXT )
   lNoBlink := .t.
   SBNoBlink()
EndIf
 oN := TNotasc() ; oN:New( nA )
oN:AdicArray()
lPer := oN:lBod
DEFINE DIALOG oDlg FROM 0, 0 TO 400,560 PIXEL;
   TITLE "Nota Credito por " + If( oN:lBod, "Devolución", "Anulación" )
   @ 16, 00 SAY "Fecha Final"  OF oDlg RIGHT PIXEL SIZE 42,10
   @ 16, 44 GET oGet[1] VAR oN:aM[1] OF oDlg SIZE 40,10 PIXEL ;
      WHEN lPer                                               ;
      VALID ( lPer := .f., oN:Iniciar( oDlg,oGet ), .t. )
   @ 16, 90 SAY "Nota Credito" OF oDlg RIGHT PIXEL SIZE 42,10
   @ 16,134 BTNGET oGet[2] VAR oN:aM[2] OF oDlg PICTURE "99999999"    ;
      ACTION EVAL({|| If(oN:Mostrar(), (oN:aM[2] := oN:oDb:NUMERO    ,;
                         oApl:nEmpresa := oN:oDb:OPTICA              ,;
                         oGet[2]:Refresh() ),) })                     ;
      VALID( If( !oN:oDb:Seek( { "optica",oApl:nEmpresa,"numero"     ,;
                                 oN:aM[2] } ) .AND. oN:aM[2] # 0     ,;
               ( MsgStop("Nota Credito NO EXISTE"), .f. )            ,;
               (oN:AdicArray(),  oLbx:aArray := oN:aD, oLbx:Refresh(),;
                oLbp:aArray := oN:aP, oLbp:Refresh(),  oDlg:Update() ,;
                If( oN:oDb:lOK, (oGet[2]:oJump := oLbx), ), .t. )) )  ;
      SIZE 44,10 PIXEL UPDATE  RESOURCE "BUSCAR"
   @ 16,180 SAY "N.Credito POR" OF oDlg RIGHT PIXEL SIZE 42,10
   @ 16,224 COMBOBOX oGet[3] VAR oN:oDb:CLASE      ;
      ITEMS {"Anulación","Devolución","Saldo","Cruce Cuenta","Anticipos"};
      SIZE 50,99 OF oDlg PIXEL UPDATE;
      ON CHANGE( cTipo := If( oN:oDb:CLASE == 5, "Anticipo", "Factura") +;
                              " Nro.", oDlg:Update() );
      WHEN !oN:oDb:lOK .AND. !oN:lBod
//    oGet[3]:bLostFocus := {|| cTipo := If( oN:oDb:CLASE == 5, "Anticipo", "Factura")+;
//                              " Nro.", oDlg:Update() }
   If oN:lBod
      @ 30, 50 BUTTON oGet[4] PROMPT "Siguiente" SIZE 40,12 OF oDlg ACTION;
        ( oN:GeneraNC( oGet ), oLbx:aArray := oN:aD, oLbx:Refresh(), ;
          oDlg:Update(), oLbx:SetFocus() ) PIXEL
   Else
      @ 30, 00 SAY cTipo OF oDlg RIGHT PIXEL SIZE 42,10 UPDATE
      @ 30, 44 GET oGet[4] VAR oN:oDb:NUMFAC OF oDlg PICTURE "999999999" ;
         WHEN !oN:oDb:lOK                                                ;
         VALID( If( !oN:Buscar( (oN:oDb:CLASE # 4),oN:oDb:NUMFAC ),.f.  ,;
                  ( oN:Detalle(), oLbx:aArray := oN:aD, oLbx:Refresh()  ,;
                    oLbp:aArray := oN:aP, oLbp:Refresh(), oDlg:Update() ,;
                    oGet[4]:oJump := oLbx, .t. ) ) )                     ;
         SIZE 40,10 PIXEL UPDATE
   EndIf
   @ 30,100 SAY "Optica"       OF oDlg RIGHT PIXEL SIZE 32,10
   @ 30,134 SAY oGet[5] VAR oN:aM[3] OF oDlg PIXEL SIZE 20,10 ;
      UPDATE COLOR nRGB( 128,128,255 )
   @ 30,180 SAY "Fecha N.C."   OF oDlg RIGHT PIXEL SIZE 42,10
   @ 30,224 SAY oGet[6] VAR oN:oDb:FECHA OF oDlg PIXEL SIZE 40,10 UPDATE
   @ 44, 00 SAY "Valor Bono"   OF oDlg RIGHT PIXEL SIZE 42,10
   @ 44, 44 GET oGet[7] VAR oN:oDb:BONOS OF oDlg PICTURE "999,999,999";
      VALID oN:BuscarP( 2,oN:oDb:BONOS ) ;
      WHEN  oN:oDb:ANULAP == 1 SIZE 40,10 PIXEL UPDATE
   @ 44, 90 SAY "Devolución $" OF oDlg RIGHT PIXEL SIZE 42,10
   @ 44,134 GET oGet[8] VAR oN:oDb:DEVOL OF oDlg PICTURE "999,999,999";
      VALID oN:BuscarP( 3,oN:oDb:DEVOL ) ;
      WHEN  oN:oDb:ANULAP <= 2 SIZE 40,10 PIXEL UPDATE
   @ 44,180 SAY "Valor Pagos"  OF oDlg RIGHT PIXEL SIZE 42,10
   @ 44,224 SAY oN:aM[12]  OF oDlg PICTURE "999,999,999.99" PIXEL SIZE 42,10;
     UPDATE COLOR nRGB( 255,0,128 )
   @ 58, 00 SAY "Concepto"     OF oDlg RIGHT PIXEL SIZE 42,10
   @ 58, 44 SAY oGet[9] VAR oN:oDb:CONCEPTO OF oDlg PIXEL SIZE 130,10;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 58,180 SAY "D.I." + oN:oDb:NROIDEN OF oDlg PIXEL SIZE  50,10;
      UPDATE COLOR nRGB( 0,127,170 )
   @ 58,240 SAY oN:nSigNot OF oDlg PIXEL SIZE  40,10;
      UPDATE COLOR nRGB( 255,0,0 )
   ACTIVAGET(oGet)

   @ 72,06 BROWSE oLbx SIZE 262, 60 PIXEL OF oDlg CELLED; // CELLED  es requerida
      COLORS CLR_BLACK, CLR_NBLUE                         // para editar Celdas
   oLbx:SetArray( oN:aD )     // Esto es necesario para trabajar con arrays
   oLbx:nHeightCell += 4
   oLbx:nHeightHead += 4
   oLbx:bKeyDown := {|nKey| If(nKey=VK_F3 , oN:Listado( oDlg,oLbx ) ,;
                            If(nKey=VK_F5 , oLbx:KeyDown( VK_DELETE,0 ),;
                            If(nKey=VK_F11, oN:Guardar( oDlg,oLbx ) , ))) }
   oLbx:SetAppendMode( .f. )                         // Activando Auto Append Mode
   oLbx:SetDeleteMode( .t.,.f.,{ |nAt,oLbx| oN:DelArray(oLbx,.f.) },;
                               { |oLbx| oN:Dscto( oLbx ) } ) // lOnOff, lConfirm, bDelete
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 1;
       TITLE "Código"+CRLF+"Artículo"            ;
       SIZE  80 ;                  // Esta columna es editable
       3DLOOK TRUE, TRUE, TRUE;    // Celda, Titulo, Footers
       MOVE DT_MOVE_NEXT;          // Cursor pasa a la Sig.Columna editable
       ALIGN DT_LEFT, DT_CENTER  ; // Celda, Titulo, Footer
       FOOTER { || STR( oLbx:nLen,4 ) + " Items" }
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 2;
       TITLE "Descripción";
       SIZE 220           ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER, DT_RIGHT;
       FOOTER "SUBTOTAL ->"
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 3;
       TITLE "Cantidad"       PICTURE "999,999.9";
       SIZE  74 EDITABLE ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       PREEDIT {|uVar| nA := oLbx:nAt          ,;
                       oN:aM[7] := oN:aD[nA,3] ,;
                       oN:aM[8] := oN:aD[nA,4] };
       POSTEDIT { |uVar| If( oLbx:lChanged, oN:Dscto( oLbx,uVar ), ) } ;
       WHEN !oN:lBod .AND. oN:oDb:CLASE == 2;
       VALID { |uVar| If( uVar <= 0, ;
          (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>" ), .f.),;
          (If( LEFT( oN:aD[oLbx:nAt,01],2 ) == "01" .AND. uVar > 1,;
          (MsgStop( "En Montura la Cantidad debe ser 1","<< OJO >>" ), .f.), .t. ))) }
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT oN:nEle;
       TITLE "Valor"         PICTURE "99,999,999" ;
       SIZE 76 ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       FOOTER { || TRANSFORM( oN:aM[6], "99,999,999" ) }
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 6      ;
       TITLE "Monto"+CRLF+"I.V.A" PICTURE "99,999,999" ;
       SIZE 74 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       FOOTER { || TRANSFORM( oN:oDb:TOTALIVA, "99,999,999" ) }
   // Asignando Valores por defaults para nueva Fila creada con Auto Append.
   oLbx:aDefault := { SPACE(12), SPACE(30), 0, 0, 0, 0, 0, 0 }
   oLbx:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbx:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color

   @ 134,06 BROWSE oLbp SIZE 200, 60 PIXEL OF oDlg CELLED;
      COLORS CLR_BLACK, CLR_NBLUE
   oLbp:SetArray( oN:aP )
   oLbp:nHeightCell += 4
   oLbp:nHeightHead += 4
   oLbp:bKeyDown := {|nKey| If(nKey=VK_F3 , oN:Listado( oDlg,oLbp ) ,;
                            If(nKey=VK_F5 , oLbp:KeyDown( VK_DELETE,0 ),;
                            If(nKey=VK_F11, oN:Guardar( oDlg,oLbp ) , ))) }

   oLbp:SetAppendMode( .t. )                         // Activando Auto Append Mode
   oLbp:SetDeleteMode( .t.,.f.,{ |nAt,oLbp| oN:DelArray(oLbp,.t.) },;
                               { |oLbp| oN:Dscto( oLbp ) } ) // lOnOff, lConfirm, bDelete
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 1;
       TITLE "Numero"+CRLF+"Factura"             ;
       PICTURE "9999999999" ;
       SIZE  80 EDITABLE ;         // Esta columna es editable
       3DLOOK TRUE, TRUE, TRUE;    // Celda, Titulo, Footers
       MOVE DT_MOVE_NEXT;          // Cursor pasa a la Sig.Columna editable
       VALID { | uVar| oN:Buscar( .t.,uVar,oLbp ) }; // don't want empty rows
       ALIGN DT_RIGHT, DT_CENTER  ; // Celda, Titulo, Footer
       PREEDIT {|uVar| oN:aM[09] := uVar, nA := oLbp:nAt ,;
                       oN:aM[10] := If( nA > LEN(oN:aP), 0, oN:aP[nA,3] ) };
       FOOTER { || STR( oLbp:nLen,4 ) + " Items" };
       WHEN Rango( oN:oDb:CLASE,3,4 ) .OR. !oApl:lEnLinea
    oLbp:aColumns[01]:bPostEdit := { |uVar| ;
       oN:aP[nA,1] := oN:aM[09], oN:aP[nA,2] := oN:aM[10],;
       oN:aP[nA,3] := oN:aM[11], oN:aP[nA,5] := oN:aRes  , oN:Dscto( oLbp ) }
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 5;
       TITLE "Cliente"    ;
       SIZE 220           ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER, DT_RIGHT;
       FOOTER "TOTAL PAGOS ->"
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 2;
       TITLE "Valor" +CRLF +"Pago NC"            ;
       PICTURE "999,999,999" ;
       SIZE 90 EDITABLE ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       POSTEDIT { |uVar| If( oLbp:lChanged, oN:Dscto( oLbp ), ) } ;
       VALID { |uVar| If( uVar <= 0, ;
          (MsgStop( "El Pago debe ser Mayor de 0","<< OJO >>" ), .f.),;
          (If( uVar > oN:aP[oLbx:nAt,3],;
          (MsgStop( "Pago Mayor que el Saldo","<< OJO >>" ), .f.), .t. ))) };
       FOOTER { || TRANSFORM( oN:oDb:PAGADO,"999,999,999" ) }
   oLbp:aDefault := { 0, 0, 0, 0,SPACE(30) }
   oLbp:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbp:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color

ACTIVATE DIALOG oDlg CENTER ON INIT (oN:DefBar( oDlg,oLbx ))

If( lNoBlink, SBNoBlink( aColor[1], aColor[2] ), Nil )
oN:Iniciar()
RETURN

//------------------------------------//
CLASS TNotasc FROM TNits
 DATA aM, aD, aP, aRes, nL, hRes
 DATA nOptica, nSigNot, oNvd
 DATA lBod          INIT .f.
 DATA lCar          INIT .f.
 DATA nEle          INIT 5

 METHOD NEW( nBod ) Constructor
 METHOD Iniciar( oDlg,oGet )
 METHOD AdicArray( xBus )
 METHOD Buscar( lBus,xBus,oLbp )
 METHOD BuscarP( nMTL,nVal )
 METHOD DelArray( oLbx,lPago )
 METHOD DelDeta( nA,nRow )
 METHOD Borrar( oDlg,oLbx )
 METHOD Dscto( oLbx,mGetVar )
 METHOD Detalle()
 METHOD GeneraNC( oGet )
 METHOD Guardar( oDlg,oLbx )
 METHOD Listado( oDlg,oLbx )
 METHOD Mostrar( nOrd )
 METHOD SaldoNC()
 METHOD DefBar( oDlg,oLbx )
ENDCLASS

//------------------------------------//
METHOD New( nBod ) CLASS TNotasc
   LOCAL oNvc
 If nBod == NIL .OR. nBod == 0
    oApl:nEmpresa := 0
    oApl:oEmp:Seek( {"optica",0} )
    ::lBod := .t.
 Else
    ::nEle := 4
    Empresa()
 EndIf
 ::aM   := { oApl:oEmp:FEC_HOY,0,"",0,oApl:oEmp:PIVA,0,0,0,0,0,0,0,"U",0,;
             ALLTRIM(   LEFT( oApl:oEmp:NOMBRE,oApl:oEmp:DIVIDENOMB ) ),;
             ALLTRIM( SUBSTR( oApl:oEmp:NOMBRE,oApl:oEmp:DIVIDENOMB ) ) }
 ::nOptica := oApl:nEmpresa
 ::nSigNot := oApl:oEmp:NOTASC + 1
   oNvc := oApl:Abrir( "cadnotac","optica, numero, tipo",,,100 )
 ::oNvd := oApl:Abrir( "cadnotad","optica, numero, tipo",,,50 )
Super:New( oNvc )
 ::aOrden := { {"Nombre" ,6,.f.},{"Cedula" ,12,.f.},{"Fecha"  ,5,.f.} }
 ::bNew := ::bEditar := ::bVer := {||.t. }
 ::oDb:xBlank()
RETURN NIL

//------------------------------------//
METHOD Iniciar( oDlg,oGet ) CLASS TNotasc
   LOCAL cQry
If oDlg == NIL
   ::oDb:Destroy()
   ::oNvd:Destroy()
ElseIf ::lBod
   cQry := CTOD( "01" + RIGHT( DTOC( ::aM[1] ),8 ) )
   cQry := "SELECT e.localiz, c.documen, d.codigo, d.cantidad, "  +;
           "d.pcosto, i.pcosto, d.row_id, i.indiva, e.codigo_nit "+;
           "FROM cadempre e, caddevoc c, caddevod d, cadinven i " +;
           "WHERE e.principal <> 4"                  +;
            " AND e.optica <> 0"                     +;
            " AND c.optica  = e.optica"              +;
            " AND c.fechad >= " + xValToChar( cQry ) +;
            " AND c.fechad <= " + xValToChar(::aM[1])+;
            " AND d.optica  = c.optica"              +;
            " AND d.documen = c.documen"             +;
            " AND d.causadev = 2"                    +;
            " AND LEFT( d.codigo,2 ) >= '01'"        +;
            " AND LEFT( d.codigo,2 ) <= '04'"        + If( oApl:cLocal # "LOC",;
            " AND d.facturado = '0'", "" )           +;
            " AND i.codigo = d.codigo AND i.compra_d = '0' ORDER BY e.localiz, c.documen"
   ::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
                 MSStoreResult( oApl:oMySql:hConnect ), 0 )
   If (::nL := MSNumRows( ::hRes )) == 0
      MSFreeResult( ::hRes )
      oGet[4]:Disable()
   Else
      oGet[2]:Disable()
      ::aRes := MyReadRow( ::hRes )
      AEVAL( ::aRes, { | xV,nP | ::aRes[nP] := MyClReadCol( ::hRes,nP ) } )
      ::aM[1] := MsgDate( oApl:oEmp:FEC_HOY,"Fecha de la N.Credito" )
   EndIf
EndIf
 oApl:cPer:= NtChr( ::aM[1],"1" )
RETURN .t.

//------------------------------------//
METHOD AdicArray( xBus ) CLASS TNotasc
   LOCAL aRes, hRes, nL
If ::aM[2] == 0
   oApl:nEmpresa := ::nOptica
   ::oDb:lOK  := .f.
   ::oDb:CLASE:= If( ::lBod, 2, 1 )
   ::aM[13] := ::oDb:TIPO := oApl:Tipo
Else
   ::aM[3]  := Buscar( {"codigo_nit",::oDb:CODIGO_NIT},"cadempre","localiz",8 )
   ::aM[6]  := ::oDb:TOTALFAC - ::oDb:TOTALIVA
   ::aM[13] := ::oDb:TIPO
   ::aM[14] := If( ::oDb:CLASE == 5 .AND. ::oDb:ANULAP == 3, ::oDb:BONOS, 0 )
EndIf
If xBus == NIL
   ::aD := {}
   ::aP := {}
   aRes := "SELECT d.codigo, i.descrip, d.cantidad, "     +;
           "d.precioven, d.pcosto, d.montoiva, d.row_id " +;
           "FROM cadinven i, cadnotad d "                 +;
           "WHERE d.codigo = i.codigo"                    +;
            " AND d.optica = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND d.numero = " + LTRIM(STR( ::aM[2] ))
   hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   While nL > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      xBus := If( aRes[6] > 0, 1, 0 )
      AADD( ::aD,{ aRes[1], aRes[2], aRes[3], aRes[4],;
                   aRes[5], aRes[6], aRes[7], xBus } )
      nL --
   EndDo
   MSFreeResult( hRes )
   If LEN( ::aD ) == 0
      AADD( ::aD,{ SPACE(12), SPACE(30), 0, 0, 0, 0, 0, 0 } )
   EndIf
   ::lCar := .f.
   If !::lBod
      aRes := "SELECT numfac, pagado, row_id FROM cadpagos "+;
              "WHERE optica = " + LTRIM(STR(oApl:nEmpresa)) +;
               " AND fecpag = " + xValToChar(::oDb:FECHA)   +;
               " AND tipo   = " + xValToChar( oApl:Tipo )   +;
               " AND numcheque = '" + LTRIM(STR( ::aM[2] )) +;
              "' AND formapago = 7 AND pordonde = 'N'"
      hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      nL   := MSNumRows( hRes )
      ::lCar := If( nL > 0, .t., .f. )
      While nL > 0
         aRes := MyReadRow( hRes )
         AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
         oApl:oFac:Seek( {"optica",oApl:nEmpresa,"numfac",aRes[1],;
                          "tipo"  ,oApl:Tipo} )
         AADD( ::aP,{ aRes[1], aRes[2], 0, aRes[3],oApl:oFac:CLIENTE} )
         nL --
      EndDo
      MSFreeResult( hRes )
      ::BuscarP( 0 )
   EndIf
   If LEN( ::aP ) == 0
      AADD( ::aP,{ 0, 0, 0, 0, SPACE(30) } )
   EndIf
   SysRefresh()
Else
   ::aD := { {"0101","MONTURAS"  ,0,0,0,0,0,1},;
             {"0301","LIQUIDOS"  ,0,0,0,0,0,1},;
             {"0302","LIQUIDOS"  ,0,0,0,0,0,0},;
             {"0401","ACCESORIOS",0,0,0,0,0,1},;
             {"0402","ACCESORIOS",0,0,0,0,0,0} }
   ::aP := { {0,0,0,0,SPACE(30)} }
EndIf
RETURN NIL

//------------------------------------//
METHOD Buscar( lBus,xBus,oLbp ) CLASS TNotasc
   LOCAL xA, lOK := .t.
If lBus
   If ::oDb:CLASE == 5
      lOK := oApl:oAtc:Seek( {"optica",oApl:nEmpresa,"numero",xBus} )
      xA  := { "Anticipo",oApl:oAtc:INDICADOR, oApl:oAtc:CODIGO_NIT, oApl:oAtc:CLIENTE }
      oApl:nSaldo := oApl:oAtc:SALDOFAC
   Else
      lOK := oApl:oFac:Seek( {"optica",oApl:nEmpresa,"numfac",xBus,;
                              "tipo",oApl:Tipo} )
      xA  := { "Factura", oApl:oFac:INDICADOR, oApl:oFac:CODIGO_NIT, oApl:oFac:CLIENTE }
      oApl:lFam   := SaldoFac( xBus )
      If oLbp == NIL .AND. oApl:nEmpresa == 18 .AND. oApl:oFac:AUTORIZA == "FOCA      "
         ::aM[13] := "F"
      Else
         ::aM[13] := ::oDb:TIPO
      EndIf
   EndIf
   If !lOK
      MsgStop( xA[1]+" NO EXISTE",">>> OJO <<<" )
   ElseIf ::oDb:CLASE == 1 .AND. oApl:oFac:FECHOY == ::aM[1]
      MsgStop( "Se anula como siempre",">>> Factura de HOY <<<" )
      lOK := .f.
   ElseIf ::oDb:CLASE == 5 .AND. ;
      (oApl:oAtc:NUMFAC # 0 .OR. !(oApl:oAtc:TOTALFAC # oApl:oAtc:SALDOFAC))
      If oApl:oAtc:NUMFAC # 0
         MsgStop( "Ya esta Facturado",">>> Anticipo <<<" )
      Else
         MsgStop( "No Tiene Pagos",">>> Anticipo <<<" )
      EndIf
      lOK := .f.
   ElseIf xA[2] $ "AN"
      MsgStop( "Anulada o con N.Credito",">>> "+xA[1]+"  <<<" )
      lOK := .f.
   Else
      If ::oDb:CODIGO_NIT == 0
         ::oDb:CODIGO_NIT := xA[3]
      EndIf
      ::aRes := xA[4]
      If oLbp # NIL
         xA := oLbp:nAt
         ::aM[09] := xBus
         If ::aM[10] == 0
            ::aM[10] := ::aM[11] := oApl:nSaldo
         Else
            ::aM[10] := ::aP[xA,2]
            ::aM[11] := ::aP[xA,2] + oApl:nSaldo
         EndIf
      EndIf
   EndIf
Else
   ::aRes   := SPACE(30)
   oApl:nSaldo := 0
EndIf
RETURN lOK

//------------------------------------//
METHOD BuscarP( nMTL,nVal ) CLASS TNotasc
   LOCAL xPG, hRes, nL, oDlg, oGet
If nMTL <= 1
   If ::oDb:CLASE <= 2
      xPG := "SELECT pagado - IFNULL(p_de_mas,0), deduccion, descuento, formapago "+;
             "FROM cadpagos "                                 +;
             "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))    +;
              " AND numfac = " + LTRIM(STR(::oDb:NUMFAC))     +;
              " AND tipo   = " + xValToChar( oApl:Tipo )      +;
              " AND formapago <= 4"
   ElseIf ::oDb:CLASE == 5
      xPG := "SELECT pagado - IFNULL(p_de_mas,0), deduccion, descuento, formapago "+;
             "FROM cadantip "                                 +;
             "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))    +;
              " AND numero = " + LTRIM(STR(::oDb:NUMFAC))     +;
              " AND formapago <= 4"
   EndIf
      ::aM[12] := ::aM[14] := 0
   If xPG # NIL
      hRes := If( MSQuery( oApl:oMySql:hConnect,xPG )  ,;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      nL   := MSNumRows( hRes )
      While nL > 0
         oGet := MyReadRow( hRes )
         AEVAL( oGet, { | xV,nP | oGet[nP] := MyClReadCol( hRes,nP ) } )
         ::aM[12] +=  oGet[1]
         If Rango( oGet[4],{0,1,4} )
            ::aM[14] += (oGet[2] + oGet[3])
         Else
            ::aM[14] +=  oGet[3]
         EndIf
         nL --
      EndDo
      MSFreeResult( hRes )
      ::aM[12] -= ::aM[14]
   EndIf
   If nMTL == 1
      nL   := If( ::oDb:CLASE == 5, 2, 1 )
      oGet := { ,,If( ::aM[12] > 0, .t., .f. ),.f. }
      DEFINE DIALOG oDlg TITLE "QUIERE UTILIZAR " + TRANSFORM( ::aM[12],"$99,999,999" );
        FROM 8, 2 TO 18,43
         @ 0.5, 1 SAY "Los Pagos de esta Factura como BONO"      OF oDlg
         @ 1.0, 1 SAY "para la elaboracion de una nueva Factura" OF oDlg
         @   2,1.5 RADIO oGet[1] VAR nL PROMPT "&Bono" ,;
             "&Devolucion del Dinero", "&Ninguna de las Anteriores" OF oDlg
         @ 2, 22 BUTTON oGet[2] PROMPT "&OK"       SIZE 24, 12 OF oDlg ;
            ACTION ( oGet[4] := .t., oDlg:End() )
      ACTIVATE DIALOG oDlg CENTERED ;
         WHEN oGet[3]
      If !oGet[4]
         nL := If( ::oDb:CLASE == 5, 2, 3 )
      EndIf
      If (::oDb:ANULAP := nL) == 1
         ::oDb:BONOS := ::aM[12]
      Else
         ::oDb:DEVOL := ::aM[12]
      EndIf
   EndIf
Else
   nL  := ::oDb:BONOS + ::oDb:DEVOL
   xPG := .t.
   If nVal < 0
      MsgStop( "El Valor debe ser Mayor de 0","<< OJO >>" )
      xPG := .f.
   EndIf
   If nL > ::aM[12] .OR.;
     (::oDb:CLASE == 2 .AND. nL > ::oDb:TOTALFAC)
      MsgStop( "La Suma de BONOS + DEVOL es Mayor que el Pago","<< OJO >>" )
      xPG := .f.
   EndIf
EndIf
RETURN xPG

//------------------------------------//
METHOD DelArray( oLbx,lPago ) CLASS TNotasc
   LOCAL lSi := .t., nA := oLbx:nAt
If lPago
   If ::aP[nA,4] > 0
      If (lSi := MsgNoYes( "Elimina este Pago",::aP[nA,1] ))
         NotaCre( ::aP[nA,1],::aM[1],::aM[2],-::aP[nA,2],::oDb:CLASE )
         MSQuery( oApl:oMySql:hConnect,;
                  "DELETE FROM cadpagos WHERE row_id ="+;
                  LTRIM(STR(::aP[nA,4])) )
      EndIf
   EndIf
Else
   lSi := !(::oDb:CLASE != 2)
   If ::aD[nA,7] > 0
      If (lSi := MsgNoYes( "Elimina este Código",::aD[nA,1] ))
         ::DelDeta( nA,2 )
      EndIf
   EndIf
EndIf
RETURN lSi

//------------------------------------//
METHOD DelDeta( nA,nRow ) CLASS TNotasc
   LOCAL cQry
If !::lBod .AND. !oApl:oEmp:TACTUINV
   If ::oDb:CLASE == 5
      cQry := "UPDATE cadinven i, cadantid d SET i.pvendida = d.precioven, "   +;
              "i.factuven = d.numero, i.fecventa = d.fecha, i.situacion = 'A' "+;
              "WHERE d.optica = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND d.numero = " + LTRIM(STR(::oDb:NUMFAC)) +;
               " AND d.codart = " + xValToChar( ::aD[nA,1] ) +;
               " AND LEFT(d.codart,2) = '01'"                +;
               " AND d.indicador = 'N'"                      +;
               " AND i.codigo = d.codart"                    +;
               " AND i.optica = d.optica"                    +;
               " AND i.factuven = 0"
      MSQuery( oApl:oMySql:hConnect,cQry )
      cQry := "UPDATE cadantid SET indicador = '' "        +;
              "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND numero = " + LTRIM(STR(::oDb:NUMFAC)) +;
               " AND codart = " + xValToChar( ::aD[nA,1] )
      MSQuery( oApl:oMySql:hConnect,cQry )
   Else
      oApl:nEmpresa := If( ::oDb:TIPO == "F", 21, oApl:nEmpresa )
      Actualiz( ::aD[nA,1],-::aD[nA,3],::oDb:FECHA,7,::aD[nA,5] )
      oApl:nEmpresa := ::oDb:OPTICA
      cQry := "UPDATE cadinven i, cadventa d SET i.pvendida = d.precioven, "    +;
              "i.factuven = d.numfac, i.fecventa = d.fecfac, i.situacion = 'V' "+;
              "WHERE d.optica = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND d.numfac = " + LTRIM(STR(::oDb:NUMFAC)) +;
               " AND d.tipo   = " + xValToChar( oApl:Tipo )  +;
               " AND d.codart = " + xValToChar( ::aD[nA,1] ) +;
               " AND LEFT(d.codart,2) = '01'"                +;
               " AND d.indicador = 'N'"                      +;
               " AND i.codigo = d.codart"                    +;
               " AND i.optica = d.optica"                    +;
               " AND i.factuven = 0"
      MSQuery( oApl:oMySql:hConnect,cQry )
      cQry := "UPDATE cadventa SET indicador = '' "        +;
              "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND numfac = " + LTRIM(STR(::oDb:NUMFAC)) +;
               " AND tipo   = " + xValToChar( oApl:Tipo )  +;
               " AND codart = " + xValToChar( ::aD[nA,1] )
      MSQuery( oApl:oMySql:hConnect,cQry )
   EndIf
EndIf
If nRow # 1
   MSQuery( oApl:oMySql:hConnect,"DELETE FROM cadnotad WHERE row_id ="+;
            LTRIM(STR(::aD[nA,7])) )
EndIf
RETURN NIL

//------------------------------------//
METHOD Borrar( oDlg,oLbx ) CLASS TNotasc
   LOCAL nR
//ElseIf !CierreInv( ::oDb:FECHA,"N.CREDITO" )
If !Login( "Desea Anular esta Nota Credito" )
   RETURN NIL
EndIf
FOR nR := 1 TO LEN( ::aD )
   If ::aD[nR,7] > 0
      ::DelDeta( nR,nR )
      If nR == 1
         ::oNvd:Seek( {"row_id",::aD[nR,7]} )
         ::oNvd:CODIGO    := "0599000004"
         ::oNvd:CANTIDAD  := 1
         ::oNvd:PRECIOVEN := ::oNvd:PCOSTO := ::oNvd:MONTOIVA := 0
         Guardar( ::oNvd,.f.,.f. )
      EndIf
      ::aD[nR,7] := 0
   EndIf
NEXT nR
//Pagos
FOR nR := 1 TO LEN( ::aP )
   If ::aP[nR,4] > 0
      NotaCre( ::aP[nR,1],::aM[1],::aM[2],-::aP[nR,2],::oDb:CLASE )
      MSQuery( oApl:oMySql:hConnect,"DELETE FROM cadpagos WHERE row_id ="+;
               LTRIM(STR(::aP[nR,4])) )
   EndIf
NEXT nR
If ::oDb:lOK
   If ::oDb:CLASE == 5
      NotaCre( ::oDb:NUMFAC,::aM[1],::aM[2],-1,::oDb:CLASE )
   EndIf
   ::oDb:TOTALFAC := ::oDb:TOTALIVA := 0
   ::oDb:PAGADO   := ::oDb:BONOS    := ::oDb:DEVOL := 0
   ::oDb:ANULAP   := 3
   Guardar( ::oDb,.f.,.f. )
EndIf
::aM[2] := ::oDb:NUMFAC := 0
::AdicArray()
oLbx:aArray := ::aD ; oLbx:Refresh()
oDlg:Update()
SetFocus( oDlg:aControls[ 4 ]:hWnd )
RETURN NIL

//------------------------------------//
METHOD Dscto( oLbx,mGetVar ) CLASS TNotasc
   LOCAL nPrecio, nA := oLbx:nAt
If ::oDb:CLASE <= 2
   If mGetVar # NIL
      nPrecio    := ::aM[8] / ::aM[7]
      ::aD[nA,4] := ROUND( nPrecio*mGetVar,0 )
      If ::aD[nA,8] == 1
         ::aD[nA,6] := ROUND( ::aD[nA,4]*::aM[5]/100,0 )
      EndIf
   EndIf
   ::aM[6] := ::aM[7] := 0
   AEVAL( ::aD, { | e | ::aM[6] += e[ 4 ], ::aM[7] += e[ 6 ] } )
   ::aM[8] := ::aM[6] + ::aM[7]
   If ::oDb:TOTALIVA  # ::aM[7] .OR. ;
      ::oDb:TOTALFAC  # ::aM[8] .OR. oLbx:lChanged
      ::oDb:TOTALIVA := ::aM[7]
      ::oDb:TOTALFAC := ::aM[8]
      If ::oDb:CLASE == 2
         nPrecio := If( ::aM[12] > ::aM[8], ::aM[8], ::aM[12] )
         If ::oDb:ANULAP == 1
            ::oDb:BONOS := nPrecio
            ::oDb:DEVOL := 0
         Else
            ::oDb:BONOS := 0
            ::oDb:DEVOL := nPrecio
         EndIf
      EndIf
      If ::oDb:lOK
         ::oDb:Update( .f.,1 )
      EndIf
   EndIf
EndIf
 ::oDb:PAGADO := 0
 AEVAL( ::aP, { | e | ::oDb:PAGADO += e[ 2 ] } )
oLbx:Refresh() ; oLbx:DrawFooters()
RETURN NIL

//------------------------------------//
METHOD Detalle() CLASS TNotasc
   LOCAL aF, aRes, hRes, nIva
 ::aM[6] := ::aM[12] := ::oDb:TOTALIVA := 0
If Rango( ::oDb:CLASE,{1,2,5} )
   If ::oDb:CLASE == 5
      aF   := { oApl:oAtc:CODIGO_CLI,oApl:oAtc:CLIENTE }
      aRes := "SELECT d.codart, i.descrip, d.cantidad, "     +;
                     "d.precioven, d.pcosto, d.montoiva "    +;
              "FROM cadantid d, cadinven i "                 +;
              "WHERE d.optica = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND d.numero = " + LTRIM(STR(::oDb:NUMFAC)) +;
               " AND d.indicador = ' '"                      +;
               " AND i.codigo = d.codart"
   Else
      aF   := { oApl:oFac:CODIGO_CLI,oApl:oFac:CLIENTE }
      aRes := "SELECT d.codart, i.descrip, d.cantidad, "     +;
                     "d.precioven, d.pcosto, d.montoiva "    +;
              "FROM cadventa d, cadinven i "                 +;
              "WHERE d.optica = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND d.numfac = " + LTRIM(STR(::oDb:NUMFAC)) +;
               " AND d.tipo   = " + xValToChar( oApl:Tipo )  +;
               " AND d.indicador = ' '"                      +;
               " AND i.codigo = d.codart"
   EndIf
   hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   ::aD := {}
   ::nL := MSNumRows( hRes )
   While ::nL > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      If aRes[4] > 0 .OR. Rango( Grupos( aRes[1] ),{"1","3","4","6"} )
         nIva := If( aRes[6] > 0, 1, 0 )
         AADD( ::aD,{ aRes[1], aRes[2], aRes[3], aRes[4],;
                      aRes[5], aRes[6],     0  , nIva } )
         ::aM[6] += aRes[4]
         ::oDb:TOTALIVA += aRes[6]
      EndIf
      ::nL --
   EndDo
   MSFreeResult( hRes )
   If LEN( ::aD ) == 0
      AADD( ::aD,{ SPACE(12), SPACE(30), 0, 0, 0, 0, 0, 0 } )
   EndIf
   ::oDb:CONCEPTO := aF[2]
   ::oDb:TOTALFAC := ::aM[6] + ::oDb:TOTALIVA
   If aF[1] > 0
      ::oDb:NROIDEN := Buscar( "SELECT nroiden FROM historia WHERE codigo_nit = "+;
                               LTRIM(STR(aF[1])),"CM",,8 )
   Else
      ::oDb:NROIDEN := ""
   EndIf
   ::BuscarP( 1 )
   ::lCar := If( ::aM[12] == 0, .t., .f. )
Else
   ::oDb:CONCEPTO := {"CANCELACION DE LAS SIG.FACTURAS",;
                      "CANCELACION POR CRUCE DE CUENTA" }[::oDb:CLASE-2]
EndIf
    ::aP := {{ 0, 0, 0, 0, SPACE(30) }}
 If oApl:nSaldo > 0 .AND.;
   (::oDb:CLASE # 2 .AND. ::oDb:CLASE # 5)
    ::aP := {{ ::oDb:NUMFAC,oApl:nSaldo,oApl:nSaldo,0,::aRes }}
    ::oDb:PAGADO := oApl:nSaldo
 EndIf
 SysRefresh()
RETURN NIL

//------------------------------------//
METHOD GeneraNC( oGet ) CLASS TNotasc
   LOCAL aNC := { "Doc.",0,0,0 }, nV
::aM[2] := ::aM[6] := 0
::aM[3] := ::aRes[1]         //Localiz
::aM[4] := ::aRes[9]         //Codigo_nit
::oDb:Seek( { "optica",oApl:nEmpresa,"numero",::aM[2] } )
::AdicArray( 1 )
While ::nL > 0
   aNC[3] := Grupos( ::aRes[3] )
   If aNC[3] == "6"
      aNC[4] := LEFT( ::aRes[3],4 )
      If (nV := ASCAN( ::aD, {|aVal| aVal[1] == aNC[4]} )) == 0
         If !oApl:oInv:Seek( {"codigo",aNC[4]} )
             oApl:oInv:Seek( {"codigo",::aRes[3]} )
         EndIf
         AADD( ::aD, { aNC[4],oApl:oInv:DESCRIP,0,0,0,0,0,oApl:oInv:INDIVA } )
         nV := LEN( ::aD )
      EndIf
   Else
      nV := { 1,1,2,4 }[VAL( aNC[3] )] + If( ::aRes[8] == 1, 0, 1 )
   EndIf
   ::aD[nV,3] += ::aRes[4]
   ::aD[nV,5] += ::aRes[4] * If( aNC[3] == "1" .AND.;
                 ::aRes[5] > ::aRes[6], ::aRes[5], ::aRes[6] )
   MSQuery( oApl:oMySql:hConnect,"UPDATE caddevod SET facturado = '1' "+;
            "WHERE row_id = " + LTRIM(STR(::aRes[7])) )
   If aNC[2]  # ::aRes[2]
      aNC[1] += "-" + LTRIM( STR(::aRes[2]) )
      aNC[2] := ::aRes[2]
   EndIf
   If (::nL --) > 1
      ::aRes := MyReadRow( ::hRes )
      AEVAL( ::aRes, {| xV,nP | ::aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aM[3] # ::aRes[1]
      FOR nV := 1 TO LEN( ::aD )
         If ::aD[nV,8] == 1
            ::aD[nV,6] := ROUND( ::aD[nV,5] * ::aM[5]/100,0 )
            ::oDb:TOTALIVA += ::aD[nV,6]
         EndIf
         ::aM[6] += ::aD[nV,5]
      NEXT nV
      ::oDb:CODIGO_NIT := ::aM[4]
      ::oDb:CONCEPTO   := aNC[1]
      ::oDb:TOTALFAC   := ::aM[6] + ::oDb:TOTALIVA
      aNC := {}
      AEVAL( ::aD, { |e| If( e[3] # 0, AADD( aNC,{ e[1],e[2],e[3],e[4],;
                                                   e[5],e[6],e[7],e[8] } ), ) } )
      ::aD := aNC
      EXIT
   EndIf
EndDo
 If ::nL == 0
    MSFreeResult( ::hRes )
    oGet[2]:Disable()
 EndIf
If LEN( ::aD ) == 0
   AADD( ::aD,{ SPACE(12), SPACE(30), 0, 0, 0, 0, 0, 0 } )
EndIf
SysRefresh()
RETURN NIL

//------------------------------------//
METHOD Guardar( oDlg,oLbx ) CLASS TNotasc
   LOCAL nPago, nR
If EMPTY( ::aD[1,1] ) .AND. EMPTY( ::aP[1,1] )
   MsgInfo( "Nota Credito no Tiene ningun Items" )
   RETURN NIL
EndIf
If ::oDb:CLASE == 5
   If ::oDb:ANULAP == 3
      ::oDb:BONOS    := ::aM[14]
      ::oDb:TOTALFAC := ::oDb:DEVOL + ::aM[14]
   Else
      ::oDb:TOTALFAC := ::oDb:DEVOL
   EndIf
ElseIf ::oDb:CLASE >= 3
   ::oDb:TOTALFAC := ::oDb:PAGADO
// ::oDb:TOTALFAC := If( ::oDb:CLASE == 5, ::oDb:DEVOL, ::oDb:PAGADO )
ElseIf ::oDb:CLASE == 2 .AND. ::oDb:ANULAP == 3
   If ::lCar .AND. !::lBod
      ::aP[1,1] := ::oDb:NUMFAC
      ::aP[1,2] := ::oDb:PAGADO := ::oDb:TOTALFAC
   EndIf
EndIf
If !::oDb:lOK
   nR := SgteNumero( "notasc",oApl:nEmpresa,.f. )
   If !MsgYesNo("Nota Credito #"+STR(nR),"Graba esta")
      RETURN NIL
   EndIf
   ::aM[2] := SgteNumero( "notasc",oApl:nEmpresa )
   ::nSigNot    := ::aM[2] + 1
   ::oDb:OPTICA := oApl:nEmpresa
   ::oDb:NUMERO := ::aM[2]
   ::oDb:TIPO   := ::aM[13]
   ::oDb:FECHA  := ::aM[1]
   ::oDb:Append( .t. )
   oDlg:Update()
Else
   ::oDb:Update( .f.,1 )
EndIf
   oApl:nEmpresa := If( ::oDb:TIPO == "F", 21, oApl:nEmpresa )
FOR nR := 1 TO LEN( ::aD )
   If ::aD[nR,3] > 0
      nPago := 0
      If ::oNvd:Seek( {"row_id",::aD[nR,7]} )
         nPago := -::oNvd:CANTIDAD
      Else
         ::oNvd:OPTICA  := ::oDb:OPTICA
         ::oNvd:NUMERO  := ::aM[2]    ; ::oNvd:TIPO      := ::aM[13]
         ::oNvd:CODIGO  := ::aD[nR,1]
      EndIf
         ::oNvd:CANTIDAD:= ::aD[nR,3] ; ::oNvd:PRECIOVEN := ::aD[nR,4]
         ::oNvd:PCOSTO  := ::aD[nR,5] ; ::oNvd:MONTOIVA  := ::aD[nR,6]
         Guardar( ::oNvd,!::oNvd:lOK,.t. )
      If ::aD[nR,7] == 0
         ::aD[nR,7] := ::oNvd:ROW_ID
      EndIf
      If !::lBod .AND. ::oDb:CLASE # 5
         nPago += ::aD[nR,3]
         Actualiz( ::aD[nR,1],nPago,::oDb:FECHA,7,::aD[nR,5] )
      EndIf
   EndIf
NEXT nR
   oApl:nEmpresa := ::oDb:OPTICA
If !::lBod
   NotaCre( ::oDb:NUMFAC,::aM[1],::aM[2],,::oDb:CLASE )  //( nFac,dFec,nDoc,nPago,nClase )
   If ::oDb:CLASE == 5
      NotaCre( ::oDb:NUMFAC,::aM[1],::aM[2],1,::oDb:CLASE )
   EndIf
   FOR nR := 1 TO LEN( ::aP )
      If ::aP[nR,2] > 0
         nPago := 0
         If oApl:oPag:Seek( {"row_id",::aP[nR,4]} )
            nPago := -oApl:oPag:PAGADO
            If oApl:oPag:NUMFAC # ::aP[nR,1]
               NotaCre( oApl:oPag:NUMFAC,::aM[1],::aM[2],nPago,::oDb:CLASE )
               nPago := 0
            EndIf
         Else
            oApl:oPag:TIPO     := oApl:Tipo ; oApl:oPag:OPTICA    := oApl:nEmpresa
            oApl:oPag:FECPAG   := ::aM[1]   ; oApl:oPag:FORMAPAGO := 7
            oApl:oPag:PORDONDE := "N"       ; oApl:oPag:NUMCHEQUE := LTRIM(STR(::aM[2]))
         EndIf
            oApl:oPag:NUMFAC   := ::aP[nR,1]; oApl:oPag:PAGADO    := ::aP[nR,2]
         nPago += ::aP[nR,2]
         Guardar( oApl:oPag,!oApl:oPag:lOK,.t. )
         NotaCre( ::aP[nR,1],::aM[1],::aM[2],nPago,::oDb:CLASE )
         If ::aP[nR,4] == 0
            ::aP[nR,4] := oApl:oPag:ROW_ID
         EndIf
      EndIf
   NEXT nR
EndIf
RETURN NIL

//------------------------------------//
METHOD Listado( oDlg,oLbx ) CLASS TNotasc
   LOCAL aCP, aNC, nL, oRpt
If ::aM[2] == 0
   MsgStop( "Grabar la Nota Credito","Primero tienes que" )
   RETURN NIL
EndIf
 If ::lBod .OR. oApl:nEmpresa == 0
    aCP := {}
    aNC := Buscar( "SELECT e.nit, e.nombre, e.direccion, m.nombre, '', '' " +;
                   "FROM ciudades m, cadempre e WHERE e.reshabit = m.codigo"+;
                   " AND e.codigo_nit = "+ LTRIM(STR(::oDb:CODIGO_NIT)),"CM",,8 )
    aNC[6] := ::oDb:CONCEPTO
    ::nEle := 5
 Else
    aNC := Buscar( "SELECT e.codigo, e.nombre, e.direccion, m.nombre, e.digito, ''"+;
                  " FROM ciudades m, cadclien e WHERE e.codigo_ciu = m.codigo"     +;
                   " AND e.codigo_nit = "+ LTRIM(STR(::oDb:CODIGO_NIT)),"CM",,8 )
    aNC[1] := FormatoNit( aNC[1],aNC[5] )
    aNC[3] := ::oDb:CONCEPTO
    If !EMPTY( ::oDb:NROIDEN )
       aNC[4] := "CC." + LEFT(::oDb:NROIDEN,11) + " " +LEFT(aNC[4],12)
    EndIf
    If ::oDb:CLASE == 5
       aNC[6] := "Anticipo No." + LTRIM(STR(::oDb:NUMFAC))
    Else
       aNC[6] := "Factura No." + If( ::oDb:CLASE <= 2, LTRIM(STR(::oDb:NUMFAC)), "" )
    EndIf
    //Armar las Cuentas
    If ::oDb:CLASE <= 2
       aCP := { {"41750102",::aM[6],0},;
                {"24080101",::oDb:TOTALIVA,0},;
                {"13050502",0,::oDb:PAGADO},;
                {"28050501",0,::oDb:BONOS },;
                {"28050502",0,0},{"42950501",0,0},{"53053501",0,0} }
       If ::oDb:ANULAP <= 2
          aCP[5,3] := ::oDb:DEVOL
       Else
          aCP[6,3] := ::oDb:DEVOL
       EndIf
       nL := 0
       AEVAL( aCP, { | e | nL += (e[2] - e[3]) } )
       If nL > 0
          aCP[7,3] :=     nL
       Else
          aCP[7,2] := ABS(nL)
       EndIf
    ElseIf ::oDb:CLASE == 3
       aCP := { {"53053501",::oDb:PAGADO,0},;
                {"13050502",0,::oDb:PAGADO} }
    ElseIf ::oDb:CLASE == 5
       aCP := { {"28050501",::oDb:BONOS+::oDb:DEVOL,0},;
                {"28050501",0,0},{"28050502",0,0},{"42950501",0,0} }
       If ::oDb:ANULAP <= 2
          aCP[2,3] := ::oDb:BONOS
          aCP[3,3] := ::oDb:DEVOL
       Else
          aCP[2,1] := "53053501"
          aCP[2,3] := ::oDb:BONOS
          aCP[4,3] := ::oDb:DEVOL
       EndIf
    Else
       nL := Buscar( {"optica",oApl:nEmpresa,"numero",::aM[2],;
                      "tipo"  ,::aM[13]},"cadnotap","SUM(pagado)",8 )
       aCP := { {"22050501",nL             ,0},;
                {"13551501",::oDb:PAGADO-nL,0},;
                {"13050502",0,::oDb:PAGADO} }
    EndIf
 EndIf
 aNC[5] := {"ANULACION ","DEVOLUCION","Cancelacion Saldo","Cruce Cuenta","ANULACION "}[::oDb:CLASE]
If oApl:nTFor == 2
   oRpt := TListFac()
   If oRpt:Dialog()
      aNC[5] += If( Rango( ::oDb:CLASE,{1,2,5} ), " de Mercancias", "" )
      oRpt:aEnc := { "Nota Crédito","", aNC[3], 0, 0 ,;
                     NtChr( ::oDb:FECHA,"2" ), aNC[4],;
                     "", "", "", "", aNC[2], aNC[1]  ,;
                     aNC[5], aNC[6], "", 1 }
      oRpt:LaserNCR( ::aD,::aP,aCP,::nEle,::oDb )
   EndIf
   RETURN NIL
EndIf
 oRpt := TDosPrint()
 oRpt:New( oApl:cPuerto,oApl:cImpres,,.f.,,,33,33 )
 oRpt:SetFont( oRpt:CPINormal,80,2 )
 oRpt:nPage := 1
 oRpt:nL := 12
 oRpt:Say( 01,00,oRpt:CPILarge+PADC( ::aM[15],30 ) )
 oRpt:Say( 02,00,              PADC( ::aM[16],60 ) )
 oRpt:Say( 03,20,"Nit. "+oApl:oEmp:NIT )
 oRpt:Say( 03,67,oRpt:CPILarge+STR(::aM[2],5) )
 oRpt:Say( 06,07,aNC[2] )
 oRpt:Say( 06,47,aNC[1] )
 oRpt:Say( 06,65,STRTRAN( DTOC( ::oDb:FECHA ),".","  " ) )
 oRpt:Say( 08,07,aNC[3] )
 oRpt:Say( 08,48,aNC[4] )
 oRpt:Say( 10,07,oRpt:CPIBold + aNC[5] )
 oRpt:Say( 11,07,aNC[6] )
 If Rango( ::oDb:CLASE,{1,2,5} )
    oRpt:Say( 10,19,oRpt:CPIBold+" de Mercancias segun Relacion Adjunta     I.V.A." )
    FOR nL := 1 TO LEN( ::aD )
       oRpt:Say( oRpt:nL,08,::aD[nL,1] )
       oRpt:Say( oRpt:nL,20,::aD[nL,2] )
       oRpt:Say( oRpt:nL,50,TRANSFORM(::aD[nL,3], "99,999") )
       oRpt:Say( oRpt:nL,58,TRANSFORM(::aD[nL,6], "@Z 999,999") )
       oRpt:Say( oRpt:nL,66,TRANSFORM(::aD[nL,::nEle],"999,999,999") )
       oRpt:nL ++
    NEXT nL
    If ::oDb:ANULAP <= 2 .AND. ::oDb:BONOS > 0
       oRpt:Say( 20,12,"B O N O  P O R  $" + TRANSFORM(::oDb:BONOS,"999,999,999") )
    EndIf
    oRpt:Say( 20,55,"SUBTOTAL-> " + TRANSFORM(::aM[6],"999,999,999") )
    If ::oDb:ANULAP <= 2 .AND. ::oDb:DEVOL > 0
       oRpt:Say( 21,07,"DEVOLUCION DE DINERO $" + TRANSFORM(::oDb:DEVOL,"999,999,999") )
    EndIf
    oRpt:Say( 21,52,"I.V.A."+TRANSFORM( ::aM[5],"999.99%" ) )
    oRpt:Say( 21,66,TRANSFORM(::oDb:TOTALIVA,"999,999,999") )
 Else
    FOR nL := 1 TO LEN( ::aP )
       oRpt:Say( oRpt:nL,08,::aP[nL,1] )
       oRpt:Say( oRpt:nL,20,::aP[nL,5] )
       oRpt:Say( oRpt:nL,66,TRANSFORM(::aP[nL,2],"999,999,999") )
       oRpt:nL ++
    NEXT nL
 EndIf
 aNC := Letras( ::oDb:TOTALFAC,75 )
 oRpt:Say( 23,15,oRpt:CPICompress + PADR( aNC[1],87 ) +;
                 oRpt:CPINormal   + TRANSFORM(::oDb:TOTALFAC,"999,999,999") )
 oRpt:Say( 24,10,oRpt:CPICompress +aNC[2] +oRpt:CPINormal )
 oRpt:nL := 26
 FOR nL := 1 TO LEN( aCP )
    If aCP[nL,2] # 0 .OR. aCP[nL,3] # 0
       oRpt:Say( oRpt:nL,07,aCP[nL,1] )
       oRpt:Say( oRpt:nL,16,TRANSFORM(aCP[nL,2],"@Z 999,999,999") )
       oRpt:Say( oRpt:nL,28,TRANSFORM(aCP[nL,3],"@Z 999,999,999") )
       oRpt:nL ++
    EndIf
 NEXT nL
 oRpt:Say( 26,40,oApl:cUser )
 oRpt:NewPage()
 oRpt:End()
RETURN NIL

//------------------------------------//
METHOD Mostrar( nOrd ) CLASS TNotasc
   LOCAL oDlg, oM := Self, lReturn := .f.
   LOCAL bHacer := {|| lReturn := .t., oDlg:End() }
   DEFAULT nOrd := 1
nOrd := ::Ordenar( nOrd )

DEFINE DIALOG oDlg FROM 3, 2 TO 22, 65 TITLE "Ayuda de Notas Credito"
   @ 1.5, 0 LISTBOX ::oLbx FIELDS  ;
               STR( ::oDb:NUMERO ),;
              DTOC( ::oDb:FECHA ) ,;
                    ::oDb:CONCEPTO,;
                    ::oDb:NROIDEN ,;
        ArrayValor( oApl:aOptic,STR(::oDb:Optica,2) );
      HEADERS "Número"+CRLF+"N.Credito","Fecha","Cliente","Cedula","Optica" ;
      SIZES 400, 450 SIZE 250,107  ;
      ON DBLCLICK EVAL(bHacer)
    ::oLbx:nClrBackHead  := oApl:nClrBackHead
    ::oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    ::oLbx:nClrBackFocus := oApl:nClrBackFocus
    ::oLbx:nClrForeFocus := oApl:nClrForeFocus
    ::oLbx:nHeaderHeight := 28
    ::oLbx:GoTop()
    ::oLbx:oFont       := ::oFont
    ::oLbx:aColSizes   := {70,70,200,70,30}
    ::oLbx:aHjustify   := {2,2,2,2,2}
    ::oLbx:aJustify    := {1,0,0,0,2}
    ::oLbx:lCellStyle  := ::oLbx:ladjbrowse  := .f.
    ::oLbx:ladjlastcol := .t.
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN, (EVAL(bHacer)),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) ) }
   MySetBrowse( ::oLbx,::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT ( oM:Barra(.t.,oDlg) )
::oDb:Setorder(nOrd)
RETURN lReturn

//------------------------------------//
METHOD SaldoNC() CLASS TNotasc
   LOCAL aPG, hRes, nL, nPago, oRpt
If ::oDb:BONOS == 0
   MsgStop( "Esta Nota Credito no tiene BONO" )
   RETURN NIL
EndIf
aPG :=  " AND p.formapago = 4 AND p.indred = '1'"       +;
        " AND p.numcheque LIKE '%" + LTRIM(STR(::aM[2]))+ "%'"
aPG := "SELECT p.numfac, 'F', f.cliente, p.fecpag FECHA, p.pagado, f.remplaza "+;
       "FROM cadfactu f, cadpagos p "                   +;
       "WHERE p.optica  = f.optica "                    +;
        " AND p.numfac  = f.numfac "                    +;
        " AND p.optica  = " + LTRIM(STR(oApl:nEmpresa)) +;
        " AND p.fecpag >= " + xValToChar( ::oDb:FECHA ) +;
        aPG +  " UNION ALL "                            +;
       "SELECT p.numero, 'A', f.cliente, p.fecha FECHA, p.pagado, f.numfac "+;
       "FROM cadantic f, cadantip p "                   +;
       "WHERE p.optica  = f.optica "                    +;
        " AND p.numero  = f.numero "                    +;
        " AND p.optica  = " + LTRIM(STR(oApl:nEmpresa)) +;
        " AND p.fecha  >= " + xValToChar( ::oDb:FECHA ) +;
        aPG + " ORDER BY FECHA"
hRes := If( MSQuery( oApl:oMySql:hConnect,aPG )  ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
EndIf
nPago:= 0
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"SALDO DE NOTAS CREDITOS","BONOS USADOS",;
         "   FACTURA  NOMBRE CLIENTE                   F E C H A    VALOR PAGO" },.t.,1 )
While nL > 0
   aPG := MyReadRow( hRes )
   AEVAL( aPG, { | xV,nP | aPG[nP] := MyClReadCol( hRes,nP ) } )
   oRpt:Titulo( 78 )
   If aPG[2] == "F" .AND. aPG[6] > 0
      aPG[5] := 0
      oRpt:Say( oRpt:nL,70,"A."+STR(aPG[6],6) )
   EndIf
   oRpt:Say( oRpt:nL,00,STR(aPG[1],9)+aPG[2] )
   oRpt:Say( oRpt:nL,12,aPG[3] )
   oRpt:Say( oRpt:nL,44,NtChr( aPG[4],"2" ) )
   oRpt:Say( oRpt:nL,57,TRANSFORM(aPG[5],"999,999,999") )
   oRpt:nL ++
   nPago += aPG[5]
   nL --
EndDo
MSFreeResult( hRes )
   nL := ::oDb:BONOS - nPago
   oRpt:Say(  oRpt:nL,00,REPLICATE("_",78) )
   oRpt:Say(++oRpt:nL,00,"N.C." + STR(::aM[2],9) )
   oRpt:Say(  oRpt:nL,16,NtChr( ::oDb:FECHA,"2" ) )
   oRpt:Say(  oRpt:nL,45,"TOTAL BONOS " + TRANSFORM( nPago     ,"999,999,999") )
   oRpt:Say(++oRpt:nL,00,"F/A." + STR(::oDb:NUMFAC,9) )
   oRpt:Say(  oRpt:nL,45,"VALOR BONO  " + TRANSFORM(::oDb:BONOS,"999,999,999") )
   oRpt:Say(++oRpt:nL,45,"SALDO N.C.  " + TRANSFORM( nL        ,"999,999,999") )
   oRpt:NewPage()
   oRpt:End()
RETURN NIL

//------------------------------------//
METHOD DefBar( oDlg,oLbx ) CLASS TNotasc
   LOCAL oBar, oBot := ARRAY(7)
DEFINE BUTTONBAR oBar OF oDlg 3DLOOK SIZE 28,28

DEFINE BUTTON RESOURCE "DEDISCO" OF oBar NOBORDER TOOLTIP "Grabar (F11)";
   ACTION ::Guardar( oDlg,oLbx,.t. )
DEFINE BUTTON RESOURCE "DELREC"  OF oBar NOBORDER TOOLTIP "Anular Nota (F6)";
   ACTION ::Borrar( oDlg,oLbx ) GROUP
DEFINE BUTTON oBot[4] RESOURCE "ELIMINAR" OF oBar NOBORDER ;
   TOOLTIP "Eliminar (Ctrl+DEL)" ;
   ACTION oLbx:KeyDown( VK_DELETE, 0 )
DEFINE BUTTON oBot[6] RESOURCE "PRINT"    OF oBar NOBORDER ;
   TOOLTIP "Imprimir" ;
   ACTION ::Listado( oDlg,oLbx )
DEFINE BUTTON oBot[5] RESOURCE "MIRAR"    OF oBar NOBORDER ;
   TOOLTIP "Ver los Bonos" ;
   ACTION ::SaldoNC()
DEFINE BUTTON oBot[7] RESOURCE "QUIT"     OF oBar NOBORDER ;
   TOOLTIP "Salir"    ;
   ACTION ( ::Iniciar(), oDlg:End() )    GROUP
 oBar:bRClicked := {|| NIL }
 oBar:bLClicked := {|| NIL }
RETURN oBar

//------------------------------------//
PROCEDURE NotaCre( nFac,dFec,nDoc,nPago,nClase )
   LOCAL cQry
If nPago == NIL
   If !oApl:oEmp:TACTUINV
      If nClase == 5
         cQry := "UPDATE cadantid v, cadnotad d SET indicador = 'N' "+;
                 "WHERE d.optica = " + LTRIM(STR(oApl:nEmpresa))+;
                  " AND d.numero = " + LTRIM(STR( nDoc ))       +;
                  " AND v.optica = d.optica"                    +;
                  " AND v.numero = " + LTRIM(STR( nFac ))       +;
                  " AND v.codart = d.codigo"
         MSQuery( oApl:oMySql:hConnect,cQry )
         cQry := "UPDATE cadinven i, cadantid d SET i.pvendida = 0, "   +;
                 "i.factuven = 0, i.fecventa = NULL, i.situacion = 'E' "+;
                 "WHERE d.optica = " + LTRIM(STR(oApl:nEmpresa))+;
                  " AND d.numero = " + LTRIM(STR( nFac ))       +;
                  " AND LEFT(d.codart,2) = '01'"                +;
                  " AND d.indicador = 'N'"                      +;
                  " AND i.codigo = d.codart"                    +;
                  " AND i.optica = d.optica"                    +;
                  " AND i.factuven = d.numero"
         MSQuery( oApl:oMySql:hConnect,cQry )
      Else
         cQry := "UPDATE cadventa v, cadnotad d SET indicador = 'N' "+;
                 "WHERE d.optica = " + LTRIM(STR(oApl:nEmpresa))+;
                  " AND d.numero = " + LTRIM(STR( nDoc ))       +;
                  " AND v.optica = d.optica"                    +;
                  " AND v.numfac = " + LTRIM(STR( nFac ))       +;
                  " AND v.tipo   = " + xValToChar( oApl:Tipo )  +;
                  " AND v.codart = d.codigo"
         MSQuery( oApl:oMySql:hConnect,cQry )
         cQry := "UPDATE cadinven i, cadventa d SET i.pvendida = 0, "   +;
                 "i.factuven = 0, i.fecventa = NULL, i.situacion = 'E' "+;
                 "WHERE d.optica = " + LTRIM(STR(oApl:nEmpresa))+;
                  " AND d.numfac = " + LTRIM(STR( nFac ))       +;
                  " AND d.tipo   = " + xValToChar( oApl:Tipo )  +;
                  " AND LEFT(d.codart,2) = '01'"                +;
                  " AND d.indicador = 'N'"                      +;
                  " AND i.codigo = d.codart"                    +;
                  " AND i.optica = d.optica"                    +;
                  " AND i.factuven = d.numfac"
         MSQuery( oApl:oMySql:hConnect,cQry )
      EndIf
   EndIf
ElseIf nPago # 0
      cQry := { "P",CTOD(""),0 }
   If nClase == 5
      If nPago > 0
         cQry := { "N",dFec,nDoc }
      EndIf
      cQry := "UPDATE cadantic SET indicador = '" + cQry[1]+;
               "', fechacan = "  + xValToChar( cQry[2] )   +;
                ", numfac   = "  + LTRIM(STR( cQry[3] ))   +;
             " WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND numero = " + LTRIM(STR( nFac ))
   Else
      oApl:lFam := SaldoFac( nFac )
      GrabaSal( nFac,1,nPago )
      If (oApl:nSaldo - nPago) == 0
         cQry := {If( nClase == 1, "N", "C" ),dFec}
      EndIf
      cQry := "UPDATE cadfactu SET indicador = '" + cQry[1]+;
               "', fechacan = " + xValToChar( cQry[2] )    +;
             " WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND numfac = " + LTRIM(STR( nFac ))       +;
               " AND tipo   = " + xValToChar( oApl:Tipo )
   EndIf
   MSQuery( oApl:oMySql:hConnect,cQry )
EndIf
RETURN