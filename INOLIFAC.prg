// Programa.: INOLIFAC.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Lista Facturacion de Opticas
#include "FiveWin.ch"
#include "btnget.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE InoLiFac( nOpc )
   LOCAL oDlg, oLF, oGet := ARRAY(9)
   LOCAL cTit := "Listar Facturación"
   DEFAULT nOpc := 1
oLF := TFBodega()
oLF:lPrev := If( TRIM( oApl:cUser ) == "Martin", .t., .f. )
If nOpc == 2
   cTit := "Facturación de Administración"
   oLF:aLS[02] := 12000
ElseIf nOpc == 3
   oLF:Publicid()
   RETURN
EndIf

DEFINE DIALOG oDlg TITLE cTit FROM 0, 0 TO 11,46
   @ 02, 00 SAY "DIGITE FECHA  [DD.MM.AA]" OF oDlg RIGHT  PIXEL SIZE 76,10
   @ 02, 78 GET oGet[1] VAR oLF:aLS[1] OF oDlg  SIZE 40,10 PIXEL
   @ 16, 00 SAY        "VALOR  DEL  DOLAR" OF oDlg RIGHT  PIXEL SIZE 76,10
   @ 16, 78 GET oGet[2] VAR oLF:aLS[2] OF oDlg PICTURE "99,999" SIZE 30,10 PIXEL;
      WHEN nOpc == 1
   @ 30, 00 SAY "1_Monturas  2_L.Contacto" OF oDlg RIGHT  PIXEL SIZE 76,10
   @ 30, 78 GET oGet[3] VAR oLF:aLS[3] OF oDlg PICTURE "9"      SIZE 12,10 PIXEL;
      VALID Rango( oLF:aLS[3],1,2 ) ;
      WHEN nOpc == 1
   @ 30,110 CHECKBOX oGet[4] VAR oLF:aLS[6] PROMPT "Grabar Fact." OF oDlg ;
      SIZE 60,10 PIXEL WHEN oLF:lPrev
   @ 44, 00 SAY "No. FACTURA ANTERIOR"     OF oDlg RIGHT  PIXEL SIZE 76,10
   @ 44, 78 GET oGet[5] VAR oLF:aLS[9] OF oDlg PICTURE "9999999999" SIZE 40,10 PIXEL;
      WHEN nOpc == 1
   @ 56, 00 SAY "Tamaño LOGO X,Y"          OF oDlg RIGHT PIXEL SIZE 76,10
   @ 56, 78 GET oGet[6] VAR oApl:nX OF oDlg PICTURE "99.9" SIZE 20,10 PIXEL;
      WHEN oLF:lPrev
   @ 56,110 GET oGet[7] VAR oApl:nY OF oDlg PICTURE "99.9" SIZE 20,10 PIXEL;
      WHEN oLF:lPrev
   @ 70, 70 BUTTON oGet[8] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[8]:Disable(), oLF:Dialog( nOpc ), oDlg:End() ) PIXEL
   @ 70,120 BUTTON oGet[9] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 74, 02 SAY "[INOLIFAC]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
CLASS TFBodega FROM TIMPRIME

 DATA aLS  AS ARRAY INIT { DATE(),oApl:nUS,1,0,16,.t.,0,1,0,.t.,DATE()+30 }
 DATA aF, aPR, lPrev, nFac, sPie
 DATA lTit    INIT .T.

 METHOD NEW( cTit ) Constructor
 METHOD Dialog( nOpc )
 METHOD ListoAdm()
 METHOD Publicid()
 METHOD Cabecera( lSep,nSpace,nSuma )
 METHOD PieFactu( lFin,nSubt,nIVA,aDet )
ENDCLASS

//------------------------------------//
METHOD NEW( cTit ) CLASS TFBodega
If cTit # NIL
   If cTit == "PIE"
      ::nFac := If( ::aLS[9] > 0, ::aLS[9], SgteNumero( "numfacu",0,.t. ) )
      ::sPie := Buscar( "SELECT piefactu FROM cademprf " +;
                        "WHERE optica = 0"               +;
                        " AND ("  + LTRIM(STR(::nFac))   +;
                        " BETWEEN desde AND hasta)","CM",,8 )
      If EMPTY( ::sPie )
         ::sPie := oApl:oEmp:PIEFACTU
      EndIf
      ::sPie := ALLTRIM( ::sPie )
   Else
      oApl:oEmp:Seek( { "optica",0 } )
      nEmpresa( .t. )
      //oApl:nEmpresa := 0
      ::aLS[4] := oApl:oEmp:NUMFACU
      ::aLS[5] := oApl:oEmp:PIVA/100
      ::aLS[6] := If( ::aLS[9] > 0, .f., ::aLS[6] )
      ::aPR    := PIva( ::aLS[1] )
      ::Init( cTit, .t. ,, !::lPrev ,,, ::lPrev, 5 )
      ASIZE( ::aFnt,9 )

      DEFINE FONT ::aFnt[7] NAME ::cFont SIZE 0,-20 BOLD OF ::oPrn
      DEFINE FONT ::aFnt[8] NAME ::cFont SIZE 0,-7       OF ::oPrn
      DEFINE FONT ::aFnt[9] NAME ::cFont SIZE 0,-6       OF ::oPrn
       PAGE
   EndIf
Else
    ENDPAGE
   IMPRIME END .F.
   If ::aLS[10]
      MSQuery( oApl:oMySql:hConnect,"UPDATE cadempre SET numfacu = "+;
            LTRIM( STR(::aLS[4]) ) + " WHERE optica = 0" )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Dialog( nOpc ) CLASS TFBodega
   LOCAL aDet, aFac, aRes, cQry, hRes, nL, nV
If nOpc == 2
   ::ListoAdm()
   RETURN NIL
EndIf
aRes := Privileg( { "facturo NOT LIKE ","%"+STR(::aLS[3],1)+"%" },.t.,.f. )
cQry := "SELECT c.optica, c.numrep, c.items, d.codigo, d.cantidad, d.pcosto, "+;
           "i.descrip, i.indiva, i.moneda, c.row_id, i.identif, i.codigo_nit "+;
        "FROM cadinven i, cadrepod d, cadrepoc c "   +;
        "WHERE d.codigo = i.codigo"                  +;
         " AND d.indica <> 'B'"                      +;
         " AND c.numrep = d.numrep"                  +;
         " AND c.optica "     + aRes[1]              +;
         " AND c.fecharep = " + xValToChar(::aLS[1] )+;
         " AND c.numfac   = " +  LTRIM(STR(::aLS[9]))+;
         " ORDER BY c.numrep"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY NADA PARA FACTURAR" )
   MSFreeResult( hRes ) ; RETURN NIL
EndIf
aRes := MyReadRow( hRes )
AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
cQry := "SELECT e.nombre, e.nit, e.direccion, e.telefonos, m.nombre, e.codigo_nit "+;
        "FROM ciudades m, cadempre e " +;
        "WHERE e.reshabit = m.codigo AND e.optica = [EMP]"
aFac := { 0,0,0,0,0,0 }
aDet := { {"0101","MONTURAS"  ,0,0,0,0,0,0,0},;
          {"0301","LIQUIDOS"  ,0,0,0,0,0,0,0},;
          {"0302","LIQUIDOS"  ,0,0,0,0,0,0,0},;
          {"0401","ACCESORIOS",0,0,0,0,0,0,0},;
          {"0402","ACCESORIOS",0,0,0,0,0,0,0} }
::NEW( "Facturas BOD" )
While nL > 0
   If aFac[6]  # aRes[10]
      aFac[6] := aRes[10]
      aFac[3] := aFac[4] := 0
      ::aF := Buscar( STRTRAN( cQry,"[EMP]",LTRIM(STR(aRes[1])) ),"CM" )
      ::aLS[7]:= 0
      ::NEW( "PIE" )
      ::nPage := INT( aRes[3]/30 ) + If( aRes[3] % 30 > 0, 1, 0 )
      oApl:oFac:xBlank()
      oApl:oFac:CLIENTE := "Reposicion No." + STR( aRes[2],7 )
      oApl:oNit:Seek( {"codigo_nit",::aF[6]} )
   EndIf
   aRes[6] := Dolar_Peso( ::aLS[2],aRes[6],aRes[9] )
   aFac[1] := aRes[6] * aRes[5]
   aFac[2] := 0
   If aRes[8] == 1
      aFac[2] := ROUND( aFac[1] * ::aLS[5],0 )
   EndIf
   aFac[3] += aFac[1]
   aFac[4] += aFac[2]
   aFac[5] := aFac[1] + aFac[2]
   ::Cabecera( .t. )
   UTILPRN ::oUtil Self:nLinea, 0.5 SAY aRes[4]
   UTILPRN ::oUtil Self:nLinea, 2.5 SAY aRes[7]
   UTILPRN ::oUtil Self:nLinea,12.5 SAY TRANSFORM( aRes[5], "99,999" )     RIGHT
   UTILPRN ::oUtil Self:nLinea,14.5 SAY TRANSFORM( aRes[6],"999,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,16.5 SAY TRANSFORM( aFac[1],"999,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM( aFac[2],  "9,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aFac[5],"999,999,999" ) RIGHT

   aRes[4] := Grupos( aRes[4] )
   nV := { 1,1,2,4 }[VAL( aRes[4] )] + If( aRes[8] == 1, 0, 1 )
   aDet[nV,3] += aRes[5]
   aDet[nV,4] += aFac[1]
   If aRes[4] == "1"
      aFac[1] := ROUND( aFac[1] / Ptaje( aRes[11],.t.,aRes[12] ),0 )
   EndIf
   aDet[nV,7] += aFac[2]
   aDet[nV,9] += aFac[1]
   ::aLS[8] ++

   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aFac[6] # aRes[10]
      oApl:oFac:GAVETA := ::nPage
      ::PieFactu( .t.,aFac[3],aFac[4],aDet )
      If ::aLS[6]
         MSQuery( oApl:oMySql:hConnect,"UPDATE cadrepoc SET numfac = " +;
                  LTRIM(STR(::nFac)) + " WHERE row_id = "+ LTRIM(STR(aFac[6])) )
      EndIf
      AEVAL( aDet, { |x| AFILL( x,0,3 ) } )
   ElseIf ::aLS[8] >= 30 .AND. ::aLS[7] < ::nPage
      ::PieFactu( .f. )
   EndIf
EndDo
MSFreeResult( hRes )
::NEW()
RETURN NIL

//-Lista Facturacion de Administración-//
METHOD ListoAdm() CLASS TFBodega
   LOCAL aDet, aRes, hRes, nL
aDet := "SELECT e.nombre, e.nit, e.direccion, e.telefonos, m.nombre, e.codigo_nit, e.val_admon "+;
        "FROM ciudades m, cadempre e " +;
        "WHERE e.reshabit = m.codigo " +;
         " AND e.activa   = '1' AND e.val_admon > 0"
hRes := If( MSQuery( oApl:oMySql:hConnect,aDet ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY NADA PARA FACTURAR" )
   MSFreeResult( hRes ) ; RETURN NIL
EndIf
aDet := { {"0599000002","LENTES OFTALMICOS",0,0,0,0,0,0,0} }
::NEW( "Facturas ADMON" )
::aLS[1] := CTOD( NtChr( ::aLS[1],"4" ) )
While nL > 0
   ::aF := MyReadRow( hRes )
   AEVAL( ::aF, { | xV,nP | ::aF[nP] := MyClReadCol( hRes,nP ) } )
   oApl:oFac:xBlank()
   oApl:oFac:CLIENTE := "ADMON. EN " + NtChr( ::aLS[1],"6" )
   oApl:oNit:Seek( {"codigo_nit",::aF[6]} )
   ::NEW( "PIE" )
   ::aLS[7]  := 0
   aDet[1,4] := ::aF[7]
   aDet[1,3] := ::aF[7] / ::aLS[2]

   ::Cabecera( .t. )
   UTILPRN ::oUtil  7.0, 2.5 SAY "LENTES OFTALMICOS PARA STOCK"
   UTILPRN ::oUtil  7.5, 2.5 SAY "EN EL MES DE " + NtChr( ::aLS[1],"6" )
   UTILPRN ::oUtil  7.5,12.5 SAY TRANSFORM( aDet[1,3], "99,999" )     RIGHT
   UTILPRN ::oUtil  7.5,14.5 SAY TRANSFORM(  ::aLS[2],"999,999,999" ) RIGHT
   UTILPRN ::oUtil  7.5,16.5 SAY TRANSFORM( aDet[1,4],"999,999,999" ) RIGHT
   UTILPRN ::oUtil  7.5,18.5 SAY TRANSFORM( 0        ,  "9,999,999" ) RIGHT
   UTILPRN ::oUtil  7.5,20.5 SAY TRANSFORM( aDet[1,4],"999,999,999" ) RIGHT
   ::PieFactu( .t.,::aF[7],0,aDet )
   nL --
EndDo
   MSFreeResult( hRes )
::NEW()
RETURN NIL

//------------------------------------//
METHOD Publicid() CLASS TFBodega
   LOCAL cLinea, oDlg, oNi, oGet := ARRAY(14)
   LOCAL aFac := { 0,.f.,1,1,0,"",1,0,0,0,"","" }
   LOCAL aV   := { {"0598","PUBLICIDAD",1,0,0,0,0,0,0} }
 oNi := TNits() ; oNi:New( ,.f. )
::aF := { SPACE(33),"",SPACE(33),SPACE(33),SPACE(20),0 }
 oApl:oFac:xBlank()
 oApl:oFac:CLIENTE := "PUBLICIDAD" + SPACE( 20 )
DEFINE DIALOG oDlg TITLE "Facturación de Publicidad" FROM 0, 0 TO 25,60
   @ 02, 00 SAY "Nit ó C.C."    OF oDlg RIGHT PIXEL SIZE 70,10
   @ 02, 72 BTNGET oGet[1] VAR aFac[01] OF oDlg PICTURE "99999999999";
      ACTION EVAL({|| If(oNi:Mostrar(), (aFac[01] := oNi:oDb:CODIGO ,;
                         oGet[1]:Refresh() ),) })                    ;
      VALID EVAL( {|| If( oNi:Buscar( aFac[01],"codigo",.t. )       ,;
                        ( ::aF[01] := oNi:oDb:NOMBRE + " "          ,;
                          ::aF[03] := oNi:oDb:DIRECCION             ,;
                          ::aF[04] := oNi:oDb:TELEFONO + SPACE(17)  ,;
                          oDlg:Update(), .t. )                      ,;
                  (MsgStop("Este Nit ó C.C. no Existe .."), .f. )) });
      SIZE 48,10 PIXEL UPDATE  RESOURCE "BUSCAR"
   @  02,172 GET oGet[14] VAR ::aLS[11] OF oDlg SIZE 34,10 PIXEL
   @  14,00 SAY "NOMBRE"       OF oDlg RIGHT PIXEL SIZE 70,10
   @  14,72 GET oGet[02] VAR ::aF[01] OF oDlg PICTURE "@!" SIZE 130,10 PIXEL UPDATE
   @  28,00 SAY "DIRECCION 1"  OF oDlg RIGHT PIXEL SIZE 70,10
   @  28,72 GET oGet[03] VAR ::aF[03] OF oDlg SIZE 130,10 PIXEL UPDATE
   @  40,00 SAY "DIRECCION 2"  OF oDlg RIGHT PIXEL SIZE 70,10
   @  40,72 GET oGet[04] VAR ::aF[04] OF oDlg SIZE 130,10 PIXEL UPDATE
   @  52,00 SAY "CIUDAD"       OF oDlg RIGHT PIXEL SIZE 70,10
   @  52,72 GET oGet[05] VAR ::aF[05] OF oDlg SIZE 70,10 PIXEL
   @  64,00 SAY "CLIENTE"      OF oDlg RIGHT PIXEL SIZE 70,10
   @  64,72 GET oGet[06] VAR oApl:oFac:CLIENTE OF oDlg PICTURE "@!" SIZE 130,10 PIXEL
   @  76,00 SAY "TIPO TEXTO"   OF oDlg RIGHT PIXEL SIZE 70,10
   @  76,72 GET oGet[07] VAR aFac[03] OF oDlg PICTURE   "99"         ;
      VALID EVAL( {|| aFac[6] := Buscar( {"tipo",aFac[3]},"publicid",;
                            "detalle",8 ),  oDlg:Update(), .t. } )   ;
       SIZE 20,10 PIXEL
   @  76,100 SAY "No.DE MESES"  OF oDlg RIGHT PIXEL SIZE 70,10
   @  76,172 GET oGet[08] VAR aFac[04] OF oDlg PICTURE  "999" SIZE 20,10 PIXEL
   @  88, 00 SAY "  VALOR MES"  OF oDlg RIGHT PIXEL SIZE 70,10
   @  88, 72 GET oGet[09] VAR aFac[05] OF oDlg PICTURE "9,999,999" SIZE 32,10 PIXEL
   @  88,110 CHECKBOX oGet[10] VAR ::aLS[6] PROMPT "Grabar Fact." OF oDlg ;
      SIZE 60,10 PIXEL
   @ 100, 16 GET oGet[11] VAR aFac[06] OF oDlg MEMO ;
      SIZE 200,60 PIXEL UPDATE HSCROLL
//    VALID ::Cambios( 3,oApl:oCtl:MOTIVO_CON,::aCtl[6] )

   @ 166, 50 BUTTON oGet[12] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ;
      ACTION ( aFac[2] := .t., oDlg:End() ) PIXEL
   @ 166,100 BUTTON oGet[13] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
If aFac[2]
   ::aLS[5] := oApl:oEmp:PIVA/100
   ::aF[02] := STRTRAN( FormatoNit( aFac[1],oNi:oDb:DIGITO ),",","." )
   ::aF[06] := oNi:oDb:CODIGO_NIT
    aV[1,4] := aFac[04] * aFac[05]
    aV[1,7] := ROUND( aV[1,4] * ::aLS[5],0 )
   aFac[08] := aV[1,4] + aV[1,7]

   ::NEW( "Facturas PUBLICIDAD" )
   ::aPR[6] := 0.04
   ::NEW( "PIE" )
   ::Cabecera( .t. )
   UTILPRN ::oUtil  8.0,12.5 SAY TRANSFORM( aFac[04], "99,999" )     RIGHT
   UTILPRN ::oUtil  8.0,14.5 SAY TRANSFORM( aFac[05],"999,999,999" ) RIGHT
   UTILPRN ::oUtil  8.0,16.5 SAY TRANSFORM(  aV[1,4],"999,999,999" ) RIGHT
   UTILPRN ::oUtil  8.0,18.5 SAY TRANSFORM(  aV[1,7],"999,999,999" ) RIGHT
   UTILPRN ::oUtil  8.0,20.5 SAY TRANSFORM( aFac[08],"999,999,999" ) RIGHT
   ::nLinea := 8.0

   ::MEMO( 2.0,ALLTRIM( aFac[06] ),140,.40,::aFnt[2] )
/*
   UTILPRN ::oUtil  8.0, 2.5 SAY "Apoyo promocional y Publicitario Año 2010"
   UTILPRN ::oUtil  8.5, 2.5 SAY "1. Apoyo boletin prensa de educación en salud visual,"
   UTILPRN ::oUtil  8.5,12.5 SAY TRANSFORM(       1, "99,999" )     RIGHT
   UTILPRN ::oUtil  8.5,14.5 SAY TRANSFORM( 3898500,"999,999,999" ) RIGHT
   UTILPRN ::oUtil  8.5,16.5 SAY TRANSFORM( 3898500,"999,999,999" ) RIGHT
   UTILPRN ::oUtil  8.5,18.5 SAY TRANSFORM(  623760,"999,999,999" ) RIGHT
   UTILPRN ::oUtil  8.5,20.5 SAY TRANSFORM( 4522260,"999,999,999" ) RIGHT
   UTILPRN ::oUtil  9.0, 2.5 SAY "    promoción y posicionamiento de producto"

   UTILPRN ::oUtil 10.0, 2.5 SAY "2. Gigantografía, portafolio hidrogel de silicona"
   UTILPRN ::oUtil 10.0,12.5 SAY TRANSFORM(       1, "99,999" )     RIGHT
   UTILPRN ::oUtil 10.0,14.5 SAY TRANSFORM( 3860000,"999,999,999" ) RIGHT
   UTILPRN ::oUtil 10.0,16.5 SAY TRANSFORM( 3860000,"999,999,999" ) RIGHT
   UTILPRN ::oUtil 10.0,18.5 SAY TRANSFORM(  617600,"999,999,999" ) RIGHT
   UTILPRN ::oUtil 10.0,20.5 SAY TRANSFORM( 4477600,"999,999,999" ) RIGHT
   UTILPRN ::oUtil 10.5, 2.5 SAY "   sede principal"
*/
/*
   While !Tmp->(EOF())
    //cLinea := STRTRAN(Tmp->LINEA,"*1",oDPrn:CPIBold )
    //cLinea := STRTRAN( cLinea,"*2",oDPrn:CPIBoldN )
      cLinea := Tmp->LINEA
      cLinea := STRTRAN( cLinea,"*3",aFac[11] )
      cLinea := STRTRAN( cLinea,"*4",NtChr( aFac[03],"3" ) )
      cLinea := STRTRAN( cLinea,"*5",TRANSFORM(aFac[05],"99,999") )
      cLinea := STRTRAN( cLinea,"*6",aFac[12] )
      cLinea := STRTRAN( cLinea,"*7",TRIM( TRANSFORM(aFac[08],"99,999") ))
      cLinea := STRTRAN( cLinea,"*8",TRANSFORM(aFac[06],"99,999.99") )
      ::Cabecera( .t. )
      UTILPRN ::oUtil Self:nLinea, 2.5 SAY cLinea
      If ::nLinea == 6.7
         aFac[08] := aV[1,4] + aV[1,7]
         UTILPRN ::oUtil  7.5,12.5 SAY TRANSFORM( aFac[07], "99,999" )     RIGHT
         UTILPRN ::oUtil  7.5,14.5 SAY TRANSFORM( aFac[10],"999,999,999" ) RIGHT
         UTILPRN ::oUtil  7.5,16.5 SAY TRANSFORM( aV[1,4] ,"999,999,999" ) RIGHT
         UTILPRN ::oUtil  7.5,18.5 SAY TRANSFORM( aV[1,7] ,"999,999,999" ) RIGHT
         UTILPRN ::oUtil  7.5,20.5 SAY TRANSFORM( aFac[08],"999,999,999" ) RIGHT
      EndIf
      Tmp->(dbSkip())
   EndDo
*/
   ::PieFactu( .t.,aV[1,4],aV[1,7],aV )
   ::NEW()
EndIf
RETURN NIL

//------------------------------------//
METHOD Cabecera( lSep,nSpace,nSuma ) CLASS TFBodega

If lSep .AND. !::lTit
   ::lTit := ::Separator( nSpace )
EndIf
If ::lTit
   ::lTit   := .F.
   ::aLS[7] ++
   ::aLS[8] := 0
   UTILPRN ::oUtil SELECT ::aFnt[2]
   If oApl:cLocal == "LOC"
      UTILPRN ::oUtil 1.3,15.6 SAY "FACTURA DE VENTA No."             FONT ::aFnt[4]
      UTILPRN ::oUtil 2.0,16.2 SAY "BOD -" + STR(::nFac,10)           FONT ::aFnt[4]
      UTILPRN ::oUtil 3.2, 1.5 SAY "CENTRO OPTICO DE LA COSTA S.A.S."
      UTILPRN ::oUtil 3.6, 2.5 SAY TRIM(oApl:oEmp:REGIMEN)            FONT ::aFnt[5]
      UTILPRN ::oUtil 3.6,13.0 SAY TRIM(oApl:oEmp:ICA)                FONT ::aFnt[5]

      UTILPRN ::oUtil BOX  3.9 , 0.4 TO  6.4 ,15.2 ROUND 25,25
      UTILPRN ::oUtil BOX  3.9 ,15.3 TO  6.4 ,20.6 ROUND 25,25
      UTILPRN ::oUtil LINEA 5.4,15.3 TO  5.4 ,20.6

      UTILPRN ::oUtil SELECT ::aFnt[5]
      UTILPRN ::oUtil 4.0, 0.8 SAY "SEÑORES"                          FONT ::aFnt[8]
      UTILPRN ::oUtil 4.0, 2.1 SAY ::aF[1]
      UTILPRN ::oUtil 4.5, 2.1 SAY "NIT: " + ::aF[2]
      UTILPRN ::oUtil 5.0, 2.1 SAY ::aF[3]
      UTILPRN ::oUtil 5.5, 2.1 SAY ::aF[4]
      UTILPRN ::oUtil 6.0, 2.1 SAY ::aF[5]

      UTILPRN ::oUtil 4.2,16.1 SAY "FECHA FACTURA"
      UTILPRN ::oUtil 4.2,18.7 SAY NtChr( ::aLS[1],"2" )
      UTILPRN ::oUtil 4.8,15.5 SAY "FECHA VENCIMIENTO"
      UTILPRN ::oUtil 4.8,18.7 SAY NtChr( ::aLS[11],"2" )

      UTILPRN ::oUtil 5.7,16.8 SAY "Pagina" + STR(::aLS[7],3) + " DE" + STR(::nPage,3)

      UTILPRN ::oUtil 6.5, 2.0 SAY oApl:oFac:CLIENTE
      UTILPRN ::oUtil BOX  7.0 , 0.4 TO  7.5 ,20.6 ROUND 25,25
      UTILPRN ::oUtil 7.1, 4.6 SAY "D E S C R I P C I O N"            FONT ::aFnt[5]
      UTILPRN ::oUtil 7.1,12.0 SAY "CANT"                             FONT ::aFnt[5]
      UTILPRN ::oUtil 7.1,13.5 SAY "PRECIO"                           FONT ::aFnt[5]
      UTILPRN ::oUtil 7.1,15.5 SAY "VENTA"                            FONT ::aFnt[5]
      UTILPRN ::oUtil 7.1,17.7 SAY "I.V.A."                           FONT ::aFnt[5]
      UTILPRN ::oUtil 7.1,19.4 SAY "TOTAL"                            FONT ::aFnt[5]
   Else
      If FILE( oApl:cIco+"logo.jpg" )
         UTILPRN ::oUtil 0.2,1 IMAGE oApl:cIco+"logo.jpg" SIZE oApl:nX,oApl:nY JPG
      Else
         If oApl:oEmp:DIVIDENOMB > 0
            nSuma := LEN( ALLTRIM( oApl:oEmp:NOMBRE ) ) -;
                     RAT( "-",oApl:oEmp:NOMBRE ) + oApl:oEmp:DIVIDENOMB
         Else
            nSuma := 0
         EndIf
         UTILPRN ::oUtil 0.8, 0.5 SAY   LEFT( oApl:oEmp:NOMBRE,oApl:oEmp:DIVIDENOMB )       FONT ::aFnt[7]
         UTILPRN ::oUtil 1.5, 0.6 SAY SUBSTR( oApl:oEmp:NOMBRE,oApl:oEmp:DIVIDENOMB,nSuma ) FONT ::aFnt[4]
      EndIf

      UTILPRN ::oUtil 1.3, 6.5 SAY oApl:oEmp:DIRECCION
      UTILPRN ::oUtil 1.3,15.6 SAY "FACTURA DE VENTA No."             FONT ::aFnt[4]
      UTILPRN ::oUtil 1.8, 6.5 SAY "Teléfonos: " + oApl:oEmp:TELEFONOS
      UTILPRN ::oUtil 2.0,16.2 SAY "BOD -" + STR(::nFac,10)           FONT ::aFnt[4]
      UTILPRN ::oUtil 2.3, 1.5 SAY "NIT: " + oApl:oEmp:NIT
      UTILPRN ::oUtil 2.3, 6.5 SAY TRIM(oApl:cCiu) + " - COLOMBIA"
      UTILPRN ::oUtil 2.8, 2.5 SAY TRIM(oApl:oEmp:REGIMEN)            FONT ::aFnt[5]
      UTILPRN ::oUtil 2.8,13.0 SAY TRIM(oApl:oEmp:ICA)                FONT ::aFnt[5]

      UTILPRN ::oUtil BOX  3.1 , 0.4 TO  5.6 ,15.2 ROUND 25,25
      UTILPRN ::oUtil BOX  3.1 ,15.3 TO  5.6 ,20.6 ROUND 25,25
      UTILPRN ::oUtil LINEA 4.6,15.3 TO  4.6 ,20.6

      UTILPRN ::oUtil SELECT ::aFnt[5]
      UTILPRN ::oUtil 3.2, 0.8 SAY "SEÑORES"                          FONT ::aFnt[8]
      UTILPRN ::oUtil 3.2, 2.1 SAY ::aF[1]
      UTILPRN ::oUtil 3.7, 2.1 SAY "NIT: " + ::aF[2]
      UTILPRN ::oUtil 4.2, 2.1 SAY ::aF[3]
      UTILPRN ::oUtil 4.7, 2.1 SAY ::aF[4]
      UTILPRN ::oUtil 5.2, 2.1 SAY ::aF[5]

      UTILPRN ::oUtil 3.4,16.1 SAY "FECHA FACTURA"
      UTILPRN ::oUtil 3.4,18.7 SAY NtChr( ::aLS[1],"2" )
      UTILPRN ::oUtil 4.0,15.5 SAY "FECHA VENCIMIENTO"
      UTILPRN ::oUtil 4.0,18.7 SAY NtChr( ::aLS[11],"2" )

      UTILPRN ::oUtil 4.9,16.8 SAY "Pagina" + STR(::aLS[7],3) + " DE" + STR(::nPage,3)

      UTILPRN ::oUtil 5.7, 2.0 SAY oApl:oFac:CLIENTE
      UTILPRN ::oUtil BOX  6.2 , 0.4 TO  6.7 ,20.6 ROUND 25,25
      UTILPRN ::oUtil 6.3, 4.6 SAY "D E S C R I P C I O N"            FONT ::aFnt[5]
      UTILPRN ::oUtil 6.3,12.0 SAY "CANT"                             FONT ::aFnt[5]
      UTILPRN ::oUtil 6.3,13.5 SAY "PRECIO"                           FONT ::aFnt[5]
      UTILPRN ::oUtil 6.3,15.5 SAY "VENTA"                            FONT ::aFnt[5]
      UTILPRN ::oUtil 6.3,17.7 SAY "I.V.A."                           FONT ::aFnt[5]
      UTILPRN ::oUtil 6.3,19.4 SAY "TOTAL"                            FONT ::aFnt[5]
   EndIf
   ::nLinea := 6.7
EndIf
RETURN NIL

//------------------------------------//
METHOD PieFactu( lFin,nSubt,nIVA,aDet ) CLASS TFBodega
   LOCAL aTL, nRET, nICA, nCRE

 UTILPRN ::oUtil BOX  21.7 , 0.4 TO 24.2 ,12.5 ROUND 25,25
 UTILPRN ::oUtil BOX  21.7 ,12.5 TO 24.2 ,20.6 ROUND 25,25
 UTILPRN ::oUtil LINEA 22.2,14.5 TO 22.2 ,20.6
 UTILPRN ::oUtil LINEA 22.7,14.5 TO 22.7 ,20.6
 UTILPRN ::oUtil LINEA 23.2,14.5 TO 23.2 ,20.6
 UTILPRN ::oUtil LINEA 23.7,14.5 TO 23.7 ,20.6

 UTILPRN ::oUtil 22.2, 0.8 SAY "SON"                               FONT ::aFnt[8]
// UTILPRN ::oUtil 23.3, 0.6 SAY   LEFT(oApl:oEmp:OBSERVA,48)
 UTILPRN ::oUtil 22.8,12.7 SAY "T O T A L E S"
// UTILPRN ::oUtil 23.8, 0.6 SAY SUBSTR(oApl:oEmp:OBSERVA,49)

If lFin
   //If !Buscar( {"codigo_nit",::aF[6]},"cadclien","autoreten",8,,3 )
   aTL  := Retenciones( ::aLS[1],nSubt,::aF[6],::aPR )
   nRet := aTL[1]
   nICA := aTL[2]
   nCRE := aTL[3]
   ::aLS[8]    := nSubt + nIVA
   oApl:nSaldo := ::aLS[8] - nRET - nICA - nCRE
   aTL  := Letras( oApl:nSaldo,64 )

   UTILPRN ::oUtil 22.2, 1.5 SAY aTL[1]                       FONT ::aFnt[5]
   UTILPRN ::oUtil 22.6, 1.5 SAY aTL[2]                       FONT ::aFnt[5]

   UTILPRN ::oUtil 21.8,16.5 SAY TRANSFORM( nSubt     ,"999,999,999" ) RIGHT
   UTILPRN ::oUtil 21.8,18.5 SAY TRANSFORM( nIVA      , "99,999,999" ) RIGHT
   UTILPRN ::oUtil 21.8,20.5 SAY TRANSFORM( ::aLS[8]  ,"999,999,999" ) RIGHT
   UTILPRN ::oUtil 22.3,17.3 SAY "Ret.Fuente"    FONT ::aFnt[5] RIGHT
   UTILPRN ::oUtil 22.3,20.5 SAY TRANSFORM( nRet      ,"999,999,999" ) RIGHT
   UTILPRN ::oUtil 22.8,17.3 SAY "Ret.   ICA"    FONT ::aFnt[5] RIGHT
   UTILPRN ::oUtil 22.8,20.5 SAY TRANSFORM( nICA      ,"999,999,999" ) RIGHT
   UTILPRN ::oUtil 23.3,17.3 SAY "Ret.  CREE"    FONT ::aFnt[5] RIGHT
   UTILPRN ::oUtil 23.3,20.5 SAY TRANSFORM( nCRE      ,"999,999,999" ) RIGHT
   UTILPRN ::oUtil 23.8,20.5 SAY TRANSFORM(oApl:nSaldo,"999,999,999" ) RIGHT

   If aDet # NIL
      If ::aLS[6]
         If oApl:oFac:NUMFAC == 0
            oApl:oFac:NUMFAC := ::nFac
         EndIf
         oApl:cPer   := NtChr( ::aLS[1],"1" )
         oApl:lFam   := .f.
         oApl:oFac:TIPO       := oApl:Tipo
         oApl:oFac:FECHOY     := oApl:oFac:FECHAENT := ::aLS[1]
         oApl:oFac:TOTALIVA   := nIVA ; oApl:oFac:TOTALFAC := ::aLS[8]
         oApl:oFac:INDICADOR  := "P"  ; oApl:oFac:TIPOFAC  := "L"
         oApl:oFac:CODIGO_NIT := ::aF[6]
         oApl:oFac:Insert( .f. )
         GrabaSal( ::nFac,1,0 )
         GrabaVen( aDet,1 )
         ::aLS[10] := .f.
      EndIf
   EndIf
EndIf
  ::nLinea := 24.3
  ::MEMO( 1.0,::sPie,140,.26,::aFnt[8] )
  ::nLinea := ::nEndLine + 3
RETURN NIL

//------------------------------------//
FUNCTION Retenciones( dFecha,nValor,nNit,aPR,lPtj )

If aPR == NIL
   aPR := PIva( dFecha )
   lPtj:= .t.
Else
   lPtj:= .f.
EndIf
// 1_RETFTE, 2_RETICA, 3_RETCREE, 4_RSIM, 5_BASE
/*
   If nValor >= oApl:oEmp:TOPERET
      oApl:oFac:RETFTE := ROUND( nValor * oApl:oEmp:PRET,0 )
   EndIf*/
AFILL( aPR,0,1,4 )
aPR[5] := nValor
If !oApl:oNit:AUTORETEN
   aPR[1] := ROUND( nValor * aPR[6] ,0 )
   If dFecha >= CTOD("01.05.2013") .AND.;
      dFecha <= CTOD("31.08.2013")
      aPR[3] := ROUND( nValor * .003,0 )
   EndIf
EndIf
If !oApl:oNit:GRANCONTR .AND. nNit # 655
   aPR[7] := If( oApl:oNit:PICA > 0, oApl:oNit:PICA/1000,;
             If( dFecha    <= CTOD("31.07.2009"), 0.0054, aPR[7] ) )
   aPR[2] := ROUND( nValor * aPR[7],0 )
EndIf
If oApl:oNit:REGSIMPLI
   aPR[4] := ROUND( nValor * aPR[8],0 )
 //aPR[4] := ROUND( nValor * .16 * .15,0 )
EndIf
If lPtj
   AEVAL( aPR, { | xV,nP | aPR[nP] := ROUND( xV * 100,2 ) },6 )
EndIf
RETURN aPR