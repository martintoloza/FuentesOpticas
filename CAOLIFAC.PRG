// Programa.: CAOLIFAC.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Imprime facturas
#include "FiveWin.ch"
#INCLUDE "Utilprn.CH"

MEMVAR oApl

PROCEDURE CaoLiFac( nFac,aDT,aM )
   LOCAL oLF
If EMPTY( nFac )
   MsgInfo("No hay Documento para imprimir")
   RETURN
EndIf
oLF := TListFac()
If LEN( aM ) == 3
   oLF:NEW( nFac,aDT,aM )
ElseIf oLF:Dialog()
   oLF:NEW( nFac,aDT,aM )
EndIf
RETURN

//------------------------------------//
CLASS TListFac FROM TIMPRIME

 DATA aF, nTL
 DATA lPrev   INIT .f.
 DATA lTit    INIT .t.

 METHOD NEW( nFac,aDT,aM ) Constructor
 METHOD Dialog()
 METHOD DFonts()
 METHOD LaserFac( aDT )
 METHOD Cabecera( lSep,nSpace,nSuma,nMD )
 METHOD PieFactu( nCol,nLine,nSeparator,lFin )
 METHOD LenteOft( cCod,cDsc,nIva,sCod,oRpt )
 METHOD ResumenV( aDT,oRpt )
 METHOD ListoCot( oRpt,aDT )
 METHOD LaserCot( aDT )
 METHOD LaserNCR( aD,aP,aCP,nE,oDb )
ENDCLASS

//------------------------------------//
METHOD NEW( nFac,aDT,aM ) CLASS TListFac
   LOCAL nL, oRpt
   aM    := { aM[1],aM[2],"ANTICIPO","","" }
 ::aF    := { nFac,0,1,0,1,"99,999,999",,"","logo"+LOWER(oApl:oEmp:LOCALIZ)+".jpg" }
 ::nTL   := nL := LEN( aDT )
If oApl:oNit:CODIGO > 0
   aM[3] := "REMISION"
   aM[4] := oApl:oNit:NOMBRE
   aM[5] := FormatoNit( oApl:oNit:CODIGO,oApl:oNit:DIGITO )
EndIf
AEVAL( aDT, { | e | nL += If( ALLTRIM( e[1] ) == "0201", 1, 0 ) } )

If oApl:Tipo == "Z"
   ::aEnc := { aM[3], "", oApl:oAtc:CLIENTE, oApl:oAtc:GAVETA, oApl:oAtc:ORDEN ,;
               NtChr( oApl:oAtc:FECHA,"2" ), aM[1],;
               If( EMPTY( aM[2] ), oApl:oAtc:DIRECC, aM[2] ),oApl:oAtc:TELEFONO,;
               TRANSFORM( oApl:oAtc:AUTORIZA ,"@Z 9999999999" ),;
               oApl:oAtc:VENDEDOR, aM[4], aM[5]                ,;
               NtChr( oApl:oAtc:FECHA+15,"2" )                 ,;
               NtChr( oApl:oAtc:FECHAENT,"2" )                 ,;
               If( oApl:oAtc:TOTALDES > 0, "DESCUENTO",SPACE(9) ), 0 }
   If oApl:nTFor == 2
      ::aEnc[17] := INT( nL/14 ) + If( nL % 14 > 0, 1, 0 )
      ::aF[3]    := 0.5
      ::LaserCot( aDT )
   Else
      ::aEnc[17] := INT( nL/17 ) + If( nL % 17 > 0, 1, 0 )
      ::ListoCot( oRpt,aDT )
   EndIf
   nL := Buscar( {"optica",oApl:nEmpresa,"numero",::aF[1]},"cadantip","rcaja",8 )
   If !EMPTY( nL )
      ReciCaja( {oApl:oAtc:FECHA,oApl:oAtc:FECHA,nL,oApl:nTFor,.f.,::aEnc[7],.f.} )
   EndIf
   RETURN NIL
EndIf
   ::aEnc := { "FACTURA DE VENTA","", oApl:oFac:CLIENTE, oApl:oFac:GAVETA,;
               oApl:oFac:ORDEN, NtChr( oApl:oFac:FECHOY,"2" ), aM[1]     ,;
               oApl:oFac:DIRECC, oApl:oFac:TELEFONO  ,;
               If( oApl:oFac:AUTORIZA == "GRUPO     ", "LIBRANZA"   ,;
                   oApl:oFac:AUTORIZA ),   oApl:oFac:VENDEDOR, aM[4],;
               aM[5], NtChr( oApl:oFac:FECHOY+30,"2" ),;
                      NtChr( oApl:oFac:FECHAENT,"2" ) ,;
               If( oApl:oFac:TOTALDES > 0, "DESCUENTO","" ),  0 }
   ::aEnc[17] := INT( nL/8 ) + If( nL % 8 > 0, 1, 0 )

If oApl:oEmp:PORPC
   ::LaserFac( aDT )
   RETURN NIL
EndIf
 ::aEnc[06] := NtChr( oApl:oFac:FECHOY,"7" )
 ::aEnc[14] := NtChr( oApl:oFac:FECHOY+30,"7" )
 ::aEnc[15] := PADR( ::aEnc[12],48 ) + PADR( ::aEnc[13],20 ) + oApl:cUser + SPACE(39) +;
            STRTRAN( NtChr( oApl:oFac:FECHAENT,"7" )," ","  " )
//cPort := If( oApl:Tipo $ "UZ" .AND. oApl:nEmpresa > 2, oApl:cPuerto, "LPT3:" )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,,::lPrev,,,33,33 )
oRpt:SetFont( oRpt:CPINormal,82,2 )
oRpt:nL := oApl:nLF ; oRpt:nPage := 1
nL := oApl:nLF -7   //:= 5
//oRpt:Say(nL-2,48,"ICA TARIFA 5.4 X 1000" )
oRpt:Say(  nL,01,::aEnc[03] )
oRpt:Say(  nL,44,STR(::aEnc[04],03) )
oRpt:Say(  nL,48,STR(::aEnc[05],10) )
oRpt:Say(  nL,60,::aEnc[06],10 )
oRpt:Say(  nL,71,oRpt:CPICompress+STRTRAN( ::aEnc[14]," ","  " ) )
oRpt:Say(++nL,01,::aEnc[07] )
oRpt:Say(++nL,01,::aEnc[08],30 )
oRpt:Say(  nL,48,::aEnc[09],08,1 )
oRpt:Say(  nL,60,::aEnc[10] )
oRpt:Say(  nL,72,::aEnc[11],05,2 )
oRpt:SetFont( oRpt:CPICompress,144,1 )
nL += 2
oRpt:Say(  nL,01,::aEnc[15] )
oRpt:Say(oRpt:nL-1,84,::aEnc[16] )
If oApl:oFac:NUMFAC == oApl:oFac:REMPLAZA .AND. ::nTL > oApl:nItems
   ::aF[5] := ::ResumenV( aDT,oRpt )
EndIf
nFac := MIN( ::nTL,oApl:nItems )
 ::lPrev := If( nFac <= 7, .t., .f. )
FOR nL := ::aF[5] TO nFac
   If !EMPTY( aDT[nL,1] ) .AND.;
      !(TRIM(aDT[nL,1]) == "0505" .AND. aDT[nL,7] == 0)
      ::aF[4]:= ::LenteOft( aDT[nL,1],aDT[nL,2],aDT[nL,8],aDT[nL,14],oRpt )
      If TRIM(aDT[nL,1]) # "0203" .AND.;
         TRIM(aDT[nL,1]) # "059999"
         If aDT[nL,4] == 0
            ::aF[4] := aDT[nL,6] + aDT[nL,7]   //oVen:DESMON + oVen:PRECIOVEN
         ElseIf aDT[nL,2] # "FACTURACION  CORRESPONDIENTE AL  SUMINIS"
            ::aF[4] := ROUND((aDT[nL,6]+aDT[nL,7]) / aDT[nL,4],0)
         EndIf
         oRpt:Say( oRpt:nL, 62,TRANSFORM(aDT[nL,4],"999") )
         oRpt:Say( oRpt:nL, 70,TRANSFORM( ::aF[4],"99,999,999") )
         ::aF[4] := aDT[nL,7] + aDT[nL,8]   //oVen:PRECIOVEN + oVen:MONTOIVA
         oRpt:Say( oRpt:nL, 85,TRANSFORM(aDT[nL,6],"@Z 9,999,999") )
         oRpt:Say( oRpt:nL,100,TRANSFORM(aDT[nL,7],"99,999,999") )
         oRpt:Say( oRpt:nL,114,TRANSFORM(aDT[nL,8], "9,999,999") )
         oRpt:Say( oRpt:nL,127,TRANSFORM( ::aF[4] ,"99,999,999") )
      EndIf
      oRpt:nL += ::aF[3]
      ::aF[3] := 1
   EndIf
NEXT nL
 ::aF[4] := oApl:oFac:TOTALFAC - oApl:oFac:TOTALIVA
nL    := oApl:nLF + oApl:nItems + If( oApl:nItems == 9, 1, 0 )
/*
If oApl:nEmpresa == 49
   If oRpt:nL < nL
      oRpt:Say( nL-1, 70,"TOTALES =>" )
      oRpt:Say( nL-1, 85,TRANSFORM(oApl:oFac:TOTALDES,"@Z 9,999,999") )
      oRpt:Say( nL-1,100,TRANSFORM( ::aF[4]          ,  "99,999,999") )
      oRpt:Say( nL-1,114,TRANSFORM(oApl:oFac:TOTALIVA,   "9,999,999") )
   EndIf
   oRpt:Say( nL,15,oApl:oEmp:OBSERVA )
   oRpt:SetFont( oRpt:CPINormal,82,1 )
   If oApl:oFac:VALOREPS > 0
      oRpt:Say( nL+1,10,aM[2]+TRANSFORM( oApl:oFac:VALOREPS," $ 999,999" ) )
   EndIf
   oRpt:Say( nL+1,49,STR(oApl:oFac:NUMFAC) )
   oRpt:Say( nL+1,70,TRANSFORM( oApl:oFac:TOTALFAC,"99,999,999" ) )
   oRpt:SetFont( oRpt:CPICompress,82,1 )
Else
*/
/*
   If oApl:oFac:RETFTE > 0
      nFac := oApl:oFac:TOTALFAC + oApl:oFac:RETFTE
      oRpt:Say( nL-1, 70,"SUBTOTAL " )
      oRpt:Say( nL-1, 85,TRANSFORM(oApl:oFac:TOTALDES,"@Z 9,999,999") )
      oRpt:Say( nL-1,100,TRANSFORM( ::aF[4]          ,  "99,999,999") )
      oRpt:Say( nL-1,114,TRANSFORM(oApl:oFac:TOTALIVA,   "9,999,999") )
      oRpt:Say( nL-1,127,TRANSFORM( nFac             ,  "99,999,999") )
      oRpt:Say( nL  ,114,"RETENCION" )
      oRpt:Say( nL  ,127,TRANSFORM(oApl:oFac:RETFTE  , "-99,999,999") )
      oRpt:Say( nL+1,127,TRANSFORM(oApl:oFac:TOTALFAC,  "99,999,999") )
   EndIf
*/
   If oApl:oNit:CODIGO > 0 .AND.;
     (oRpt:nL < nL  .OR. EMPTY(oApl:oEmp:OBSERVA))
      aDT := Letras( oApl:oFac:TOTALFAC,52 )
      oRpt:Say( nL-1, 14,oApl:oEmp:OBSERVA )
      oRpt:Say( nL  , 02,aDT[1] )
      oRpt:Say( nL+1, 02,aDT[2] )
   Else
      oRpt:Say( nL  , 04,  LEFT(oApl:oEmp:OBSERVA,48) )
      oRpt:Say( nL+1, 04,SUBSTR(oApl:oEmp:OBSERVA,49) )
   EndIf
   oRpt:Say( nL  , 54,STR(::aF[1]) )
   oRpt:Say( nL  , 85,TRANSFORM(oApl:oFac:TOTALDES,"@Z 9,999,999") )
   oRpt:Say( nL  ,100,TRANSFORM( ::aF[4]          ,  "99,999,999") )
   oRpt:Say( nL  ,114,TRANSFORM(oApl:oFac:TOTALIVA,   "9,999,999") )
   oRpt:Say( nL  ,127,TRANSFORM(oApl:oFac:TOTALFAC,  "99,999,999") )
//EndIf
nFac := 1
nL   += 3
If oApl:oFac:LLEGO
   oRpt:Say( nL-1,11,"PROMOCION" )
EndIf
oRpt:Say( nL,00,STRTRAN( ::aEnc[6]," ","   " ) )
oApl:oPag:Seek( {"optica",oApl:nEmpresa,"numfac",::aF[1],"tipo",oApl:Tipo} )
While nFac <= 3     .AND. ;
      oApl:oPag:lOK .AND. !oApl:oPag:Eof()
   If oApl:oPag:PORDONDE == "F"
      ::aF[4] := oApl:oPag:ABONO     - oApl:oPag:P_DE_MAS
      ::aF[5] := oApl:oPag:DEDUCCION + oApl:oPag:DESCUENTO + oApl:oPag:RETENCION +;
                 oApl:oPag:RETIVA    + oApl:oPag:RETICA    + oApl:oPag:RETCRE
      If oApl:oPag:FORMAPAGO == 0
         oRpt:Say( nL,17,"X" )
      ElseIf oApl:oPag:FORMAPAGO == 1
         oRpt:Say( nL,21,oApl:oPag:CODBANCO )
         oRpt:Say( nL,25,oApl:oPag:NUMCHEQUE )
      Else
         ::aF[4] += ::aF[5]
         oApl:oBco:Seek( {"codigo",oApl:oPag:CODBANCO} )
         oRpt:Say( nL,44,oApl:oBco:NOMBRE,20 )
         oRpt:Say( nL,62,oApl:oPag:NUMCHEQUE )
      EndIf
      oRpt:Say( nL, 87,TRANSFORM( ::aF[5],"9,999,999.99" ) )
      oRpt:Say( nL,103,TRANSFORM( ::aF[4],"9,999,999.99" ) )
      If nFac == 2
         oRpt:Say( nL,121,TRANSFORM( oApl:nSaldo,"@Z 99,999,999.99" ) )
         oApl:nSaldo := 0
      EndIf
      nFac ++
      nL++
   EndIf
   oApl:oPag:Skip(1):Read()
   oApl:oPag:xLoad()
EndDo
oRpt:Say( nL,121,TRANSFORM( oApl:nSaldo,"@Z 99,999,999.99" ) )
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD Dialog() CLASS TListFac
   LOCAL aOK, hDC := GetDC( 0 )
   aOK   := { .f.,If( TRIM( oApl:cUser ) == "Martin", .t., .f. ) }
 ::aFont := GetFontNames( hDC )
 ::nAncho:= oApl:oEmp:ANCHO    //2400 215.9
 ::nAlto := oApl:oEmp:ALTURA   //1490 139.7
DEFINE DIALOG ::oDlg TITLE "Impresión"
   @ 02,62 CHECKBOX ::lPrev PROMPT "Vista Previa" OF ::oDlg ;
      SIZE 60,10 PIXEL
   @ 14,00 SAY "Número de Copias" OF ::oDlg RIGHT PIXEL SIZE 60,10
   @ 14,62 GET ::nCopia OF ::oDlg PICTURE "99" SIZE 12,10 PIXEL;
      VALID Rango( ::nCopia,1,10 ) ;
      WHEN oApl:oEmp:PORPC
   @ 26,00 SAY "Escoja la Fuente" OF ::oDlg RIGHT PIXEL SIZE 60,10
   @ 26,62 COMBOBOX ::cFont ITEMS ::aFont SIZE 80,99 OF ::oDlg PIXEL;
      WHEN oApl:oEmp:PORPC
   @ 38, 00 SAY "Altura en mm"    OF ::oDlg RIGHT PIXEL SIZE 60,10
   @ 38, 62 GET ::nAlto           OF ::oDlg PICTURE "99,999.99" SIZE 42,10 PIXEL;
      WHEN aOK[2]
   @ 50, 00 SAY "Ancho  en mm"    OF ::oDlg RIGHT PIXEL SIZE 60,10
   @ 50, 62 GET ::nAncho          OF ::oDlg PICTURE "99,999.99" SIZE 42,10 PIXEL;
      WHEN aOK[2]
   @ 38,106 GET oApl:nX           OF ::oDlg PICTURE "99.9"      SIZE 20,10 PIXEL;
      WHEN aOK[2]
   @ 50,106 GET oApl:nY           OF ::oDlg PICTURE "99.9"      SIZE 20,10 PIXEL;
      WHEN aOK[2]

   @ 63,70 BUTTON hDC PROMPT "Imprimir" SIZE 44,12 OF ::oDlg;
      ACTION ( aOK[1] := .t., ::oDlg:End() ) PIXEL
ACTIVATE DIALOG ::oDlg CENTER
RETURN aOK[1]

//------------------------------------//
METHOD DFonts() CLASS TListFac
 ASIZE( ::aFnt,9 )
 DEFINE FONT ::aFnt[7] NAME ::cFont SIZE 0,-20 BOLD OF ::oPrn
 DEFINE FONT ::aFnt[8] NAME ::cFont SIZE 0,-6       OF ::oPrn
 DEFINE FONT ::aFnt[9] NAME ::cFont SIZE 0,-7       OF ::oPrn
RETURN NIL

//------------------------------------//
METHOD LaserFac( aDT ) CLASS TListFac
   LOCAL aPF, nL
aPF := Buscar( "SELECT prefijo, piefactu FROM cademprf "    +;
               "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND ("          + LTRIM(STR(::aF[1]))      +;
               " BETWEEN desde AND hasta)","CM",,8 )
//                   " AND desde >= " + LTRIM(STR(::aF[1]))       +;
//                   " AND hasta <= " + LTRIM(STR(::aF[1])),"CM",,8 )
If LEN( aPF ) == 0
   ::aEnc[2]:= If( oApl:oEmp:SUCURSAL # "001", oApl:oEmp:LOCALIZ + "-", "    " )
   ::aF[08] := ALLTRIM( oApl:oEmp:PIEFACTU )
Else
   ::aEnc[2]:=          aPF[1] + "-"
   ::aF[08] := ALLTRIM( aPF[2] )
EndIf
 ::Init( "Factura"+STR(::aF[1]), .t. ,, !::lPrev ,,, ::lPrev, 5 )
 ::DFonts()
 ::lPrev := If( ::nTL <= 6, .t., .f. )
 PAGE
    If oApl:oFac:NUMFAC == oApl:oFac:REMPLAZA .AND. ::nTL > oApl:nItems
       ::aF[5] := ::ResumenV( aDT )
       ::nPage := 1
    EndIf
    FOR nL := ::aF[5] TO ::nTL
       If !EMPTY( aDT[nL,1] ) .AND.;
          !(TRIM(aDT[nL,1]) == "0505" .AND. aDT[nL,7] == 0)
          ::Cabecera( .t.,::aF[3] )
          ::aF[3] := .5
          ::aF[4] := ::LenteOft( aDT[nL,1],aDT[nL,2],aDT[nL,8],aDT[nL,14] )
          If TRIM(aDT[nL,1]) # "0203" .AND.;
             TRIM(aDT[nL,1]) # "059999"
             If aDT[nL,4] == 0
                ::aF[4] := aDT[nL,6] + aDT[nL,7]   //oVen:DESMON + oVen:PRECIOVEN
             ElseIf aDT[nL,2] # "FACTURACION  CORRESPONDIENTE AL  SUMINIS"
                ::aF[4] := ROUND((aDT[nL,6]+aDT[nL,7]) / aDT[nL,4],0)
             EndIf
             UTILPRN ::oUtil Self:nLinea,10.2 SAY TRANSFORM( aDT[nL,4],  "999" )        RIGHT
             UTILPRN ::oUtil Self:nLinea,12.5 SAY TRANSFORM(   ::aF[4],  "99,999,999" ) RIGHT
             ::aF[4] := aDT[nL,7] + aDT[nL,8]   //oVen:PRECIOVEN + oVen:MONTOIVA
             UTILPRN ::oUtil Self:nLinea,14.5 SAY TRANSFORM( aDT[nL,6],"@Z 9,999,999" ) RIGHT
             UTILPRN ::oUtil Self:nLinea,16.5 SAY TRANSFORM( aDT[nL,7],  "99,999,999" ) RIGHT
             UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM( aDT[nL,8],   "9,999,999" ) RIGHT
             UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM(   ::aF[4],  "99,999,999" ) RIGHT
          EndIf
             ::aF[2] ++
          If ::aF[2] == 8 .AND. nL < ::nTL
             ::PieFactu( 0.4,180,.26,.f. )
           //::Cabecera( .t.,3.0 )
             ::nLinea += 3.0
          EndIf
       ElseIf nL == 1
          ::Cabecera( .t. )
          UTILPRN ::oUtil 7.5, 4.0 SAY "ANULADA" FONT ::aFnt[4]
       EndIf
    NEXT nL
    ::PieFactu( 0.4,180,.26,.t. )
 ENDPAGE
IMPRIME END .F.

RETURN NIL

//------------------------------------//
METHOD Cabecera( lSep,nSpace,nSuma,nMD ) CLASS TListFac

If lSep .AND. !::lTit
   ::lTit := ::Separator( nSpace,nSuma,nMD )
EndIf
If ::lTit
// Para imprimir una imagen en el formato actual de papel ,
//simplemente le decimos la imagen que es y la clausula PAGE y yasta!
//   UTILPRN ::oUtil 0.5,1 IMAGE oApl:cIco+"logotipo.jpg" JPG PAGE
// Podemos usar tambien la clausula JPG para poner Bitmaps
   If FILE( oApl:cIco+::aF[9] )
      UTILPRN ::oUtil 0.2,1 IMAGE oApl:cIco+::aF[9] SIZE oApl:nX,oApl:nY JPG
   Else
   //CENTRO OPTICO DE LA COSTA S.A.S. - VSM
   //12345678901234567890123456789012345678
      If oApl:oEmp:DIVIDENOMB > 0
         If (nSuma := RAT( "-",oApl:oEmp:NOMBRE )) > 0
             nSuma -= oApl:oEmp:DIVIDENOMB
         Else
            nSuma := LEN( ALLTRIM( oApl:oEmp:NOMBRE ) ) - oApl:oEmp:DIVIDENOMB
         EndIf
         //Msginfo( STR(nSuma),STR(RAT( "-",oApl:oEmp:NOMBRE )) )
      Else
         nSuma := 0
      EndIf
      UTILPRN ::oUtil 0.8, 0.5 SAY   LEFT( oApl:oEmp:NOMBRE,oApl:oEmp:DIVIDENOMB )       FONT ::aFnt[7]
      UTILPRN ::oUtil 1.5, 0.6 SAY SUBSTR( oApl:oEmp:NOMBRE,oApl:oEmp:DIVIDENOMB,nSuma ) FONT ::aFnt[4]
   EndIf
   UTILPRN ::oUtil SELECT ::aFnt[2]

   UTILPRN ::oUtil 1.3, 6.5 SAY oApl:oEmp:DIRECCION
   UTILPRN ::oUtil 1.3,15.7 SAY ::aEnc[01] + " No."                FONT ::aFnt[4]
   UTILPRN ::oUtil 1.8, 6.5 SAY "Teléfonos: " + oApl:oEmp:TELEFONOS
   UTILPRN ::oUtil 2.0,16.2 SAY ::aEnc[02] + STR(::aF[1],10)       FONT ::aFnt[4]
   UTILPRN ::oUtil 2.3, 1.5 SAY "NIT: " + oApl:oEmp:NIT
   UTILPRN ::oUtil 2.3, 6.5 SAY TRIM(oApl:cCiu) + " - COLOMBIA"
   If LEFT(::aEnc[1],7) == "FACTURA"
      UTILPRN ::oUtil 2.8, 2.5 SAY TRIM(oApl:oEmp:REGIMEN)         FONT ::aFnt[5]
      UTILPRN ::oUtil 2.8,13.0 SAY TRIM(oApl:oEmp:ICA)             FONT ::aFnt[5]
   Else
      UTILPRN ::oUtil 2.8,13.0 SAY "Pagina" + STR(::nPage,3) + " DE" + STR(::aEnc[17],3) FONT ::aFnt[5]
   EndIf
   UTILPRN ::oUtil BOX  3.1 , 0.4 TO  4.6 ,10.4 ROUND 25,25
   UTILPRN ::oUtil BOX  3.1 ,10.5 TO  5.5 ,20.6 ROUND 25,25
   UTILPRN ::oUtil LINEA 3.9,10.5 TO  3.9 ,20.6
   UTILPRN ::oUtil LINEA 4.7,10.5 TO  4.7 ,20.6
   UTILPRN ::oUtil BOX  4.7 , 0.4 TO  5.5 ,10.4 ROUND 25,25

   UTILPRN ::oUtil SELECT ::aFnt[5]
   If LEFT( ::aEnc[1],4 ) == "Nota"
      UTILPRN ::oUtil 3.1, 1.0 SAY ::aEnc[03]
      UTILPRN ::oUtil 3.1,15.7 SAY "FECHA Nota Crédito"               FONT ::aFnt[8]
      UTILPRN ::oUtil 3.4,15.8 SAY ::aEnc[06]

      UTILPRN ::oUtil 3.6, 1.0 SAY ::aEnc[07]
      UTILPRN ::oUtil 4.2, 1.0 SAY ::aEnc[08]
      UTILPRN ::oUtil 3.9,12.0 SAY "Le(s) rogamos tomar nota de los sigientes"
      UTILPRN ::oUtil 4.2,12.0 SAY "abonos hechos a su apreciable cuenta"

      UTILPRN ::oUtil 4.7, 0.8 SAY "EMPRESA"                          FONT ::aFnt[8]
      UTILPRN ::oUtil 5.0, 1.0 SAY ::aEnc[12]
      UTILPRN ::oUtil 4.7, 7.4 SAY "NIT"                              FONT ::aFnt[8]
      UTILPRN ::oUtil 5.0, 7.5 SAY ::aEnc[13]
      UTILPRN ::oUtil 4.7,10.7 SAY ::aEnc[14]
      UTILPRN ::oUtil 5.0,10.9 SAY ::aEnc[15]
   Else
      UTILPRN ::oUtil 3.1, 1.0 SAY ::aEnc[03]
      UTILPRN ::oUtil 3.1,10.7 SAY "GAVETA No."                       FONT ::aFnt[8]
      UTILPRN ::oUtil 3.4,12.2 SAY TRANSFORM( ::aEnc[04],"@Z 999" )        RIGHT
      UTILPRN ::oUtil 3.1,13.0 SAY "ORDEN No."                        FONT ::aFnt[8]
      UTILPRN ::oUtil 3.4,15.0 SAY TRANSFORM( ::aEnc[05],"@Z 9999999999" ) RIGHT
      UTILPRN ::oUtil 3.1,15.7 SAY "FECHA " + LEFT(::aEnc[01],8)      FONT ::aFnt[8]
      UTILPRN ::oUtil 3.4,15.8 SAY ::aEnc[06]
      UTILPRN ::oUtil 3.1,18.0 SAY "FECHA VENCIMIENTO"                FONT ::aFnt[8]
      UTILPRN ::oUtil 3.4,18.2 SAY ::aEnc[14]

      UTILPRN ::oUtil 3.6, 1.0 SAY ::aEnc[07]
      UTILPRN ::oUtil 4.2, 1.0 SAY ::aEnc[08]
      UTILPRN ::oUtil 3.9,10.7 SAY "TELEFONOS"                        FONT ::aFnt[8]
      UTILPRN ::oUtil 4.2,10.9 SAY ::aEnc[09]
      UTILPRN ::oUtil 3.9,15.2 SAY "AUTORIZACION"                     FONT ::aFnt[8]
      UTILPRN ::oUtil 4.2,15.3 SAY ::aEnc[10]
      UTILPRN ::oUtil 3.9,18.1 SAY "VENDEDOR"                         FONT ::aFnt[8]
      UTILPRN ::oUtil 4.2,18.2 SAY ::aEnc[11]

      UTILPRN ::oUtil 4.7, 0.8 SAY "EMPRESA"                          FONT ::aFnt[8]
      UTILPRN ::oUtil 5.0, 1.0 SAY ::aEnc[12]
      UTILPRN ::oUtil 4.7, 7.4 SAY "NIT"                              FONT ::aFnt[8]
      UTILPRN ::oUtil 5.0, 7.5 SAY ::aEnc[13]
      UTILPRN ::oUtil 4.7,10.7 SAY "CAJERO"                           FONT ::aFnt[8]
      UTILPRN ::oUtil 5.0,10.9 SAY oApl:cUser
      UTILPRN ::oUtil 5.0,18.2 SAY ::aEnc[15]
   EndIf
   UTILPRN ::oUtil BOX  5.5 , 0.4 TO  6.0 ,20.6 ROUND 25,25
   UTILPRN ::oUtil 5.6, 0.8 SAY "CODIGO"                           FONT ::aFnt[5]
   UTILPRN ::oUtil 5.6, 4.6 SAY "P R O D U C T O"                  FONT ::aFnt[5]
   UTILPRN ::oUtil 5.6, 9.8 SAY "CANT"                             FONT ::aFnt[5]
   UTILPRN ::oUtil 5.6,11.2 SAY "PRECIO"                           FONT ::aFnt[5]
   UTILPRN ::oUtil 5.6,13.0 SAY ::aEnc[16]                         FONT ::aFnt[5]
   UTILPRN ::oUtil 5.6,15.5 SAY "VENTA"                            FONT ::aFnt[5]
   UTILPRN ::oUtil 5.6,17.7 SAY "I.V.A."                           FONT ::aFnt[5]
   UTILPRN ::oUtil 5.6,19.4 SAY "TOTAL"                            FONT ::aFnt[5]
// ::aF[09] ++
   ::aF[2]  := 0
   ::lTit   := .F.
   ::nLinea := 6.0
EndIf
RETURN NIL

//------------------------------------//
METHOD PieFactu( nCol,nLine,nSeparator,lFin ) CLASS TListFac
   LOCAL aP, aRes, nL, hRes
   DEFAULT nLine := 180,;
            nCol := 0.4
 UTILPRN ::oUtil BOX   9.8 , 0.4 TO 11.1 ,10.4 ROUND 25,25
 UTILPRN ::oUtil BOX   9.8 ,10.4 TO 11.1 ,20.6 ROUND 25,25
 UTILPRN ::oUtil LINEA 10.2,12.8 TO 10.2 ,20.6
 UTILPRN ::oUtil LINEA 10.6,12.8 TO 10.6 ,20.6
 UTILPRN ::oUtil BOX  11.2 , 0.4 TO 12.5 ,20.6 ROUND 25,25
 UTILPRN ::oUtil LINEA 11.6, 0.4 TO 11.6 ,20.6

 UTILPRN ::oUtil  9.8, 0.8 SAY "OBSERVACIONES"                     FONT ::aFnt[8]
 UTILPRN ::oUtil 10.3, 0.6 SAY   LEFT(oApl:oEmp:OBSERVA,48)
 UTILPRN ::oUtil 10.3,10.5 SAY "T O T A L E S"
 UTILPRN ::oUtil 10.8, 0.6 SAY SUBSTR(oApl:oEmp:OBSERVA,49)

 UTILPRN ::oUtil SELECT ::aFnt[8]
 UTILPRN ::oUtil 11.3, 1.3 SAY "FECHA"
 UTILPRN ::oUtil 11.3, 2.7 SAY "EFEC"
 UTILPRN ::oUtil 11.3, 3.4 SAY "BANCO / TARJETA"
 UTILPRN ::oUtil 11.3, 7.3 SAY "No. CHEQUE / VOUCHER"
 UTILPRN ::oUtil 11.3,12.5 SAY "DEDUCCION"            RIGHT
 UTILPRN ::oUtil 11.3,15.0 SAY "A B O N O"            RIGHT
 UTILPRN ::oUtil 11.3,17.5 SAY "S A L D O"            RIGHT
 UTILPRN ::oUtil SELECT ::aFnt[5]

::nLinea := 12.6
If lFin
   If oApl:oFac:LLEGO
      UTILPRN ::oUtil  9.3, 2.1 SAY "PROMOCION"
   EndIf
   If oApl:oNit:CODIGO > 0 .AND. EMPTY(oApl:oEmp:OBSERVA)
      aRes := Letras( oApl:oFac:TOTALFAC,60 )
      UTILPRN ::oUtil 10.3, 1.5 SAY aRes[1]                       FONT ::aFnt[9]
      UTILPRN ::oUtil 10.8, 1.5 SAY aRes[2]                       FONT ::aFnt[9]
   EndIf

   ::aF[4] := oApl:oFac:TOTALFAC - oApl:oFac:TOTALIVA
   UTILPRN ::oUtil  9.9,14.5 SAY TRANSFORM( oApl:oFac:TOTALDES,"@Z 9,999,999" ) RIGHT
   UTILPRN ::oUtil  9.9,16.5 SAY TRANSFORM(            ::aF[4],  "99,999,999" ) RIGHT
   UTILPRN ::oUtil  9.9,18.5 SAY TRANSFORM( oApl:oFac:TOTALIVA,   "9,999,999" ) RIGHT
   UTILPRN ::oUtil  9.9,20.5 SAY TRANSFORM( oApl:oFac:TOTALFAC,  "99,999,999" ) RIGHT

   aP   := "SELECT p.formapago, p.pagado - IFNULL(p.p_de_mas,0), p.descuento, p.deduccion + "    +;
                  "p.retencion + IFNULL(p.retiva,0) + IFNULL(p.retica,0), p.numcheque, b.nombre "+;
           "FROM cadpagos p LEFT JOIN cadbanco b"         +;
             " ON p.codbanco = b.codigo "                 +;
           "WHERE p.optica = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND p.numfac = " + LTRIM(STR(::aF[1]))      +;
            " AND p.tipo   = " + xValToChar(oApl:Tipo)    +;
            " AND p.pordonde = 'F'"
   hRes := If( MSQuery( oApl:oMySql:hConnect,aP )   ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   aP   := { 1,11.7 }
   If (nL := MSNumRows( hRes )) > 0
      UTILPRN ::oUtil aP[2], 0.5 SAY ::aEnc[6]
   EndIf
   While aP[1] <= 3 .AND. nL > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      If aRes[1] == 0
         UTILPRN ::oUtil aP[2], 2.8 SAY "X"
      Else
         If aRes[1] >= 2 .AND. aRes[1] <= 3
            aRes[2] -= aRes[3]
         EndIf
         UTILPRN ::oUtil aP[2], 3.4 SAY aRes[6]
         UTILPRN ::oUtil aP[2], 7.3 SAY aRes[5]
      EndIf
         UTILPRN ::oUtil aP[2],12.5 SAY TRANSFORM( aRes[3]+aRes[4],"9,999,999.99" ) RIGHT
         UTILPRN ::oUtil aP[2],15.0 SAY TRANSFORM( aRes[2]        ,"9,999,999.99" ) RIGHT
      If aP[1] == 2
         UTILPRN ::oUtil aP[2],17.5 SAY TRANSFORM( oApl:nSaldo,"@Z 99,999,999.99" ) RIGHT
         oApl:nSaldo := 0
      EndIf
      aP[1] ++
      aP[2] += .4
      nL    --
   EndDo
   MSFreeResult( hRes )
         UTILPRN ::oUtil aP[2],20.5 SAY TRANSFORM( oApl:nSaldo,"@Z 99,999,999.99" ) RIGHT
EndIf
   If ::nPage > 1
      UTILPRN ::oUtil 12.1,18.0 SAY "Pagina" + STR(::nPage,3) + " DE" + STR(::aEnc[17],3)
   EndIf
   ::MEMO( nCol,::aF[8],nLine,nSeparator,::aFnt[8] )
   ::nLinea := ::nEndLine
RETURN NIL

//------------------------------------//
METHOD LenteOft( cCod,cDsc,nIva,sCod,oRpt ) CLASS TListFac
   LOCAL aNom, cOft, nP, nLen := If( oApl:nEmpresa == 44, 45, 50 )
   cOft   := ""
If TRIM( cCod ) == "0201" .AND. SUBSTR( cDsc,38,1 ) $ "123"
   nP   := AT( ".",SUBSTR( cDsc,12 ) ) + 11
   cCod := "0201- " + SUBSTR(cDsc,37,4)
   If EMPTY(sCod)
      aNom := { "clase_mate",SUBSTR(cCod,7,1),"tipo_mater",SUBSTR(cCod,9,2),;
                "tipol", If( SUBSTR(cDsc,nP-2,2) == "NG", "N", " " )       ,;
                "nomcorto" , SUBSTR(cDsc,nP-5,5) }
   Else
      aNom := { "clase_mate",LEFT(sCod,1),"tipo_mater",SUBSTR(sCod,3,2),"tipol",RIGHT(sCod,1) }
   EndIf
   aNom := Buscar( aNom,"cadtlist","nombre, nombre_cla" )
   cOft := TRIM( SUBSTR( cDsc,nP,37-nP ) )
   If ::lPrev
      ::aF[3] *= 2
      cOft := LEFT( cDsc,2 ) + If( SUBSTR( cDsc,3,2 ) == "T.", "TERMINADO ", "" ) + cOft
      cDsc := aNom[2] + " " +;
              If( SUBSTR( cDsc,3,2 ) == "N.", "MONOFOCAL LENTICULAR NEGATIVO ", aNom[1] )
   Else
      sCod := If( SUBSTR( cDsc,3,2 ) == "T.", STRTOKEN(aNom[1],1," ")+" TERMINADO",;
              If( SUBSTR( cDsc,3,2 ) == "N.", "MONOFOCAL LENTICULAR NEGATIVO", TRIM(aNom[1]) ) )
      nP   := nLen - 2 - LEN( cOft )
      cDsc := LEFT( cDsc,2 ) + LEFT( sCod,nP ) + cOft
      If (nP  := nLen - LEN( cDsc )) >= 7
         sCod := STRTRAN( aNom[2],"-" )
         sCod := LEFT( STRTRAN( sCod," " ),nP-1 ) + "/"
         cDsc := STUFF( cDsc,3,0,sCod )
      EndIf
      cOft := ""
   EndIf
EndIf
cDsc := PADR( cDsc,nLen ) +;
        If( oApl:nEmpresa == 44,;
        If( nIva > 0, "/5012", "/5022" ), "" )
If oRpt # NIL
   oRpt:Say( oRpt:nL  ,00,cCod )
   oRpt:Say( oRpt:nL  ,12,PADR( cDsc,nLen ) )
   oRpt:Say( oRpt:nL+1,14,cOft )
Else
   UTILPRN ::oUtil Self:nLinea   , 0.5 SAY cCod
   UTILPRN ::oUtil Self:nLinea   , 2.4 SAY cDsc FONT ::aFnt[9]
   UTILPRN ::oUtil Self:nLinea+.5, 2.6 SAY cOft FONT ::aFnt[9]
EndIf
RETURN 0

//------------------------------------//
METHOD ResumenV( aDT,oRpt ) CLASS TListFac
   LOCAL aDet, cCod, nK, nL, nPUnitario
If ASCAN( aDT, { |x| x[1] == "059999      " } ) > 0
   RETURN 1
EndIf
aDet := { {"0599000001  ","MONTURAS"         ,0,0,0,0},;
          {"0599000002  ","LENTES OFTALMICOS",0,0,0,0},;
          {"0599000003  ","LENTES CONTACTOS" ,0,0,0,0},;
          {"0501        ","CONSULTAS"        ,0,0,0,0},;
          {"0502        ","AJUSTES MONTURAS" ,0,0,0,0},;
          {"0503        ","COLOR_TRATAMIENTO",0,0,0,0},;
          {"0301        ","LIQUIDOS"         ,0,0,0,0} }
FOR nL := 1 TO ::nTL
   do Case
   Case LEFT( aDT[nL,1],2 ) == "01"
      cCod := "0599000001  "
   Case LEFT( aDT[nL,1],2 ) == "03"
      cCod := "0301        "
   Case LEFT( aDT[nL,1],2 ) >= "60"
      cCod := "0599000003  "
   OtherWise
      cCod := aDT[nL,1]
   EndCase
      nK := ASCAN( aDet, {|aVal| aVal[1] == cCod} )
   If nK > 0
      aDet[nK,3] += aDT[nL,4] ; aDet[nK,4] += aDT[nL,7]
      aDet[nK,5] += aDT[nL,6] ; aDet[nK,6] += aDT[nL,8]
   EndIf
NEXT nL
FOR nK := 1 TO LEN( aDet )
   If aDet[nK,3] > 0
      aDet[nK,2] += If( oApl:oFac:OPTICA == 44, ;
                    If( aDet[nK,6] > 0, "/5012","/5022"),"" )
      nPUnitario := ROUND( (aDet[nK,4]+aDet[nK,5])/aDet[nK,3],0 )
      ::aF[4]    := aDet[nK,4] + aDet[nK,6]
      If oRpt # NIL
         oRpt:Say( oRpt:nL, 00,aDet[nK,1] )
         oRpt:Say( oRpt:nL, 11,aDet[nK,2] )
         oRpt:Say( oRpt:nL, 62,TRANSFORM( aDet[nK,3],"999" ) )
         oRpt:Say( oRpt:nL, 70,TRANSFORM( nPUnitario,  "99,999,999" ) )
         oRpt:Say( oRpt:nL, 85,TRANSFORM( aDet[nK,5],"@Z 9,999,999" ) )
         oRpt:Say( oRpt:nL,100,TRANSFORM( aDet[nK,4],  "99,999,999" ) )
         oRpt:Say( oRpt:nL,114,TRANSFORM( aDet[nK,6],   "9,999,999" ) )
         oRpt:Say( oRpt:nL,127,TRANSFORM(    ::aF[4],  "99,999,999" ) )
         oRpt:nL ++
      Else
         ::Cabecera( .t. )
         UTILPRN ::oUtil Self:nLinea, 0.5 SAY aDet[nK,1]
         UTILPRN ::oUtil Self:nLinea, 2.3 SAY aDet[nK,2]
         UTILPRN ::oUtil Self:nLinea,10.3 SAY TRANSFORM( aDet[nK,3],  "999" )        RIGHT
         UTILPRN ::oUtil Self:nLinea,12.5 SAY TRANSFORM( nPUnitario,  "99,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,14.5 SAY TRANSFORM( aDet[nK,5],"@Z 9,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,16.5 SAY TRANSFORM( aDet[nK,4],  "99,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM( aDet[nK,6],   "9,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM(    ::aF[4],  "99,999,999" ) RIGHT
      EndIf
   EndIf
NEXT nK
RETURN nL

//------------------------------------//
METHOD ListoCot( oRpt,aDT ) CLASS TListFac
   LOCAL aEC, nL
 aEC := { PADC(   LEFT( oApl:oEmp:NOMBRE,oApl:oEmp:DIVIDENOMB ),25 ),;
          PADC( SUBSTR( oApl:oEmp:NOMBRE,oApl:oEmp:DIVIDENOMB ),25 ) }
 ::aEnc[12] := PADR( ::aEnc[12],35 )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,,::lPrev,,,33,33 )
oRpt:SetFont( oRpt:CPINormal,82,2 )
oRpt:nL := oRpt:nPage := 0
::lPrev := .t.
FOR nL := 1 TO ::nTL
   If !EMPTY( aDT[nL,1] ) .AND.;
      !(TRIM(aDT[nL,1]) == "0505" .AND. aDT[nL,7] == 0)
      If oRpt:nL ==  0
         oRpt:nL := 12
         oRpt:nPage ++
         oRpt:Say( 01,06,aEC[1] + "    DIRECCION: " + oApl:oEmp:DIRECCION )
         oRpt:Say( 02,06,aEC[2] + "    TELEFONOS: " + oApl:oEmp:TELEFONOS )
         oRpt:Say( 03,06,"Nit: " + oApl:oEmp:NIT + SPACE(21)+ oApl:cCiu )
         oRpt:SetFont( oRpt:CPICompress,82,1 )
         oRpt:Say( 04,01,"Se\or(es) : " + ::aEnc[12] + "  Nit. " + PADL(::aEnc[13],13) )
         oRpt:Say( 04,,oRpt:CPINormal + SPACE(13) + NtChr( ::aEnc[1],"A" ) )
         oRpt:Say( 05,01,"Paciente  : " + ::aEnc[3] )
         oRpt:Say( 05,50,"C.C. "+::aEnc[7],40 )
         oRpt:Say( 05,,oRpt:CPINormal+"  No. " + STRZERO( ::aF[1],8 ))
         oRpt:Say( 06,13,::aEnc[8] )
         oRpt:Say( 06,50,"Tel. "+::aEnc[9] )
         oRpt:SetFont( oRpt:CPINormal,82,1 )
         oRpt:Say( 07,01,"Gaveta No.: " + STR( ::aEnc[4] ) )
         oRpt:Say( 07,48,"FECHA " +::aEnc[1]+" "+ ::aEnc[6] )
         oRpt:Say( 08,01,"Orden  No.: " + STR( ::aEnc[5] ) + SPACE(12) + ::aEnc[11] )
         oRpt:Say( 08,60,"Pagina" + STR( oRpt:nPage,3 ) + " DE" + STR( ::aEnc[17],3 ) )
         oRpt:SetFont( oRpt:CPICompress,82,1 )
         oRpt:Say( 09,00,REPLICATE( "-",137 ) )
         oRpt:Say( 10,00,"  CODIGO                   P R O D U C T O                   CANT       PRECIO" )
         oRpt:Say( 10,85,::aEnc[16] + "      V E N T A       I.V.A.      T O T A L" )
         oRpt:Say( 11,00,REPLICATE( "-",137 ) )
      EndIf
      ::aF[4] := ::LenteOft( aDT[nL,1],aDT[nL,2],aDT[nL,8],aDT[nL,14],oRpt )
      If TRIM(aDT[nL,1]) # "0203" .AND.;
         TRIM(aDT[nL,1]) # "059999"
         ::aF[4] := ROUND((aDT[nL,6] + aDT[nL,7]) / aDT[nL,4],0)
         If aDT[nL,4] == 0
            ::aF[4] := aDT[nL,6] + aDT[nL,7]
         EndIf
         ::aF[5] := aDT[nL,7] + aDT[nL,8]
         oRpt:Say( oRpt:nL, 62,TRANSFORM(aDT[nL,4],"999" ) )
         oRpt:Say( oRpt:nL, 70,TRANSFORM(  ::aF[4],::aF[6] ) )
         oRpt:Say( oRpt:nL, 85,TRANSFORM(aDT[nL,6],"@Z 9,999,999") )
         oRpt:Say( oRpt:nL,100,TRANSFORM(aDT[nL,7],::aF[6]   ) )
         oRpt:Say( oRpt:nL,114,TRANSFORM(aDT[nL,8],"9,999,999") )
         oRpt:Say( oRpt:nL,127,TRANSFORM(  ::aF[5],::aF[6]   ) )
      EndIf
      oRpt:nL += ::aF[3]
      ::aF[3] := 1
      If oRpt:nL == 30 .AND. oRpt:nPage < ::aEnc[17]
         oRpt:NewPage()
         oRpt:nL :=  0
      EndIf
   EndIf
NEXT nL
 ::aF[5] := oApl:oAtc:TOTALFAC - oApl:oAtc:TOTALIVA
oRpt:nL ++
oRpt:Say(  oRpt:nL, 00,REPLICATE( "=",137 ) )
oRpt:Say(++oRpt:nL, 70,"TOTALES =>" )
oRpt:Say(  oRpt:nL, 85,TRANSFORM(oApl:oAtc:TOTALDES,"@Z 9,999,999") )
oRpt:Say(  oRpt:nL,100,TRANSFORM( ::aF[5]          ,  "99,999,999") )
oRpt:Say(  oRpt:nL,114,TRANSFORM(oApl:oAtc:TOTALIVA,   "9,999,999") )
oRpt:Say(  oRpt:nL,127,TRANSFORM(oApl:oAtc:TOTALFAC,::aF[6] ) )
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserCot( aDT ) CLASS TListFac
   LOCAL nL
 ::Init( "Factura"+STR(::aF[1]), .t. ,, !::lPrev ,,, ::lPrev, 5 )
 ::DFonts()
 PAGE
FOR nL := 1 TO ::nTL
   If !EMPTY( aDT[nL,1] ) .AND.;
      !(TRIM(aDT[nL,1]) == "0505" .AND. aDT[nL,7] == 0)
      ::Cabecera( .t.,::aF[3] )
      ::aF[3] := .5
      ::aF[5] := ::LenteOft( aDT[nL,1],aDT[nL,2],aDT[nL,8],aDT[nL,14] )
      If TRIM(aDT[nL,1]) # "0203" .AND.;
         TRIM(aDT[nL,1]) # "059999"
         ::aF[5] := ROUND((aDT[nL,6] + aDT[nL,7]) / aDT[nL,4],0)
         If aDT[nL,4] == 0
            ::aF[5] := aDT[nL,6] + aDT[nL,7]
         EndIf
         UTILPRN ::oUtil Self:nLinea,10.2 SAY TRANSFORM( aDT[nL,4],  "999" )        RIGHT
         UTILPRN ::oUtil Self:nLinea,12.5 SAY TRANSFORM(   ::aF[5], ::aF[6] )       RIGHT
         ::aF[5] := aDT[nL,7] + aDT[nL,8]
         UTILPRN ::oUtil Self:nLinea,14.5 SAY TRANSFORM( aDT[nL,6],"@Z 9,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,16.5 SAY TRANSFORM( aDT[nL,7], ::aF[6] )       RIGHT
         UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM( aDT[nL,8],   "9,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM(   ::aF[5], ::aF[6] )       RIGHT
      EndIf
         ::aF[2] ++
      If ::aF[2] == 14 .AND. nL < ::nTL
         ::nLinea := ::nEndLine
      EndIf
   ElseIf nL == 1
      ::Cabecera( .t. )
      UTILPRN ::oUtil 7.5, 4.0 SAY "ANULADA" FONT ::aFnt[4]
   EndIf
NEXT nL
 ::aF[5] := oApl:oAtc:TOTALFAC - oApl:oAtc:TOTALIVA
   ::Cabecera( .t.,0.50,0.92,20.6 )
   UTILPRN ::oUtil Self:nLinea,10.5 SAY "TOTALES =>"
   UTILPRN ::oUtil Self:nLinea,14.5 SAY TRANSFORM(oApl:oAtc:TOTALDES,"@Z 9,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,16.5 SAY TRANSFORM( ::aF[5]          ,  "99,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM(oApl:oAtc:TOTALIVA,   "9,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM(oApl:oAtc:TOTALFAC, ::aF[6] )       RIGHT
 ENDPAGE
IMPRIME END .F.
RETURN NIL

//------------------------------------//
METHOD LaserNCR( aD,aP,aCP,nE,oDb ) CLASS TListFac
   LOCAL aNC, nL

 ::aF := { oDb:NUMERO,0,1,0,1,"99,999,999",,"","logo"+LOWER(oApl:oEmp:LOCALIZ)+".jpg" }

::Init( "N.Credito"+STR(::aF[1]), .t. ,, !::lPrev ,,, ::lPrev )
::DFonts()
 PAGE
 If Rango( oDb:CLASE,{1,2,5} )
    FOR nL := 1 TO LEN( aD )
       ::aF[4] := aD[nL,nE] + aD[nL,6]
       ::Cabecera( .t. )
       UTILPRN ::oUtil Self:nLinea, 0.5 SAY aD[nL,1]
       UTILPRN ::oUtil Self:nLinea, 2.5 SAY aD[nL,2] FONT ::aFnt[9]
       UTILPRN ::oUtil Self:nLinea,10.2 SAY TRANSFORM( aD[nL, 3],    "999" )      RIGHT
       UTILPRN ::oUtil Self:nLinea,16.5 SAY TRANSFORM( aD[nL,nE], "99,999,999" ) RIGHT
       UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM( aD[nL, 6],  "9,999,999" ) RIGHT
       UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM(   ::aF[4],"999,999,999" ) RIGHT
    NEXT nL
    aP := { oDb:TOTALFAC-oDb:TOTALIVA, oDb:TOTALIVA,.t. }
 Else
    FOR nL := 1 TO LEN( aP )
       ::Cabecera( .t. )
       UTILPRN ::oUtil Self:nLinea, 3.8 SAY TRANSFORM( aP[nL,1],  "9999999999" ) RIGHT
       UTILPRN ::oUtil Self:nLinea, 4.1 SAY LEFT( aP[nL,5],41 )
       UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aP[nL,2], "999,999,999" ) RIGHT
    NEXT nL
    aP := { 0,0,.f. }
 EndIf

 aD := Letras( oDb:TOTALFAC,76 )
       ::nLinea += 0.5
       UTILPRN ::oUtil BOX Self:nLinea, 0.4 TO Self:nLinea+1,20.6 ROUND 25,25
       ::nLinea += 0.1
       UTILPRN ::oUtil Self:nLinea, 0.5 SAY "SON"           FONT ::aFnt[5]
       UTILPRN ::oUtil Self:nLinea, 1.3 SAY aD[1]           FONT ::aFnt[5]
       UTILPRN ::oUtil Self:nLinea,16.5 SAY TRANSFORM( aP[1]      ,"999,999,999" ) RIGHT
       UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM( aP[2]      ,"999,999,999" ) RIGHT
       UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM(oDb:TOTALFAC,"999,999,999" ) RIGHT
       ::nLinea += 0.5
       UTILPRN ::oUtil Self:nLinea, 1.3 SAY aD[2]           FONT ::aFnt[5]
 nE := ::nLinea + 1.0
 If aP[3]
    If oDb:ANULAP <= 2 .AND. oDb:BONOS > 0
       ::Cabecera( .t. )
       UTILPRN ::oUtil Self:nLinea, 4.8 SAY "B O N O  P O R  $"
       UTILPRN ::oUtil Self:nLinea,10.2 SAY TRANSFORM( oDb:BONOS,"999,999,999" ) RIGHT
    EndIf
    If oDb:ANULAP <= 2 .AND. oDb:DEVOL > 0
       ::Cabecera( .t. )
       UTILPRN ::oUtil Self:nLinea, 4.8 SAY "DEVOLUCION DE DINERO $"
       UTILPRN ::oUtil Self:nLinea,10.2 SAY TRANSFORM( oDb:DEVOL,"999,999,999" ) RIGHT
    EndIf
 EndIf
 ::nLinea := nE
 FOR nL := 1 TO LEN( aCP )
    If aCP[nL,2] # 0 .OR. aCP[nL,3] # 0
       UTILPRN ::oUtil Self:nLinea,14.5 SAY aCP[nL,1]
       UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM( aCP[nL,2],"@Z 999,999,999.99" ) RIGHT
       UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aCP[nL,3],"@Z 999,999,999.99" ) RIGHT
      ::nLinea += 0.4
    EndIf
 NEXT nL
 ENDPAGE
IMPRIME END .F.
RETURN NIL
/*
//------------------------------------//5574203 = 56
FUNCTION DigitoDavivien( nFac )
   LOCAL aP := { 0,0,0,0,1,LTRIM(STR( nFac )),"" }, nR
FOR nR := LEN( aP[6] ) TO 1 STEP -1
   nFac := VAL(SUBSTR( aP[6],nR,1 ))
   If (aP[5] % 2) == 0
      aP[3] := nFac
      aP[4] := nFac * 3
   Else
      aP[3] := nFac * 2
      aP[4] := nFac
   EndIf
   If aP[3] > 9
      aP[7] := STR(aP[3],2)
      aP[3] := VAL(LEFT(aP[7],1)) + VAL(RIGHT(aP[7],1))
   EndIf
   If aP[4] > 9
      aP[7] := STR(aP[4],2)
      aP[4] := VAL(LEFT(aP[7],1)) + VAL(RIGHT(aP[7],1))
   EndIf
   aP[1] += aP[3]
   aP[2] += aP[4]
   aP[5] ++
NEXT nR
aP[6] := RIGHT(STR(aP[1],2),1) + RIGHT(STR(aP[2],2),1)
RETURN aP[6] */