// Programa.: CAOLIVEN.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo ventas de las opticas
#include "FiveWin.ch"
#include "Btnget.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE CaoLiVen( nOpc )
   LOCAL aMon, aRep, oDlg, oNi, oV
   LOCAL oGet := ARRAY(14), nMone := 1
   DEFAULT nOpc := 1
oV := TLVentas() ; oV:NEW( nOpc )
aMon := ArrayCombo( "MONEDA" )
aRep := { { {|| oV:ListoVen() },"Listo Ventas con Código" }       ,;
          { {|| oV:ListoRes() },"Resumen de Ventas Discriminadas"},;
          { {|| oV:ListaRes() },"Resumen de Ventas Consolidadas" },;
          { {|| oV:ListoBim() },"Ventas Discriminadas por Bimestre" } }
oNi := TNits() ; oNi:New()
DEFINE DIALOG oDlg TITLE aRep[nOpc,2] FROM 0, 0 TO 19,46 OF oApl:oWnd
   @  02, 00 SAY "CODIGO DE PROVEEDOR" OF oDlg RIGHT PIXEL SIZE 90,10
   @  02, 92 BTNGET oGet[1] VAR oV:aLS[8] OF oDlg PICTURE "9999999999";
      ACTION EVAL({|| If(oNi:Mostrar(), (oV:aLS[8] := oNi:oDb:CODIGO ,;
                         oGet[1]:Refresh() ),) })                     ;
      VALID EVAL( {|| If( EMPTY( oV:aLS[8] ), .t.                    ,;
                    ( If( oNi:Buscar( oV:aLS[8],"codigo",.t. )       ,;
                        ( oGet[14]:Settext( oNi:oDb:NOMBRE), .t. )   ,;
                (MsgStop("Este Proveedor no Existe"), .f.) ) )) } )   ;
      WHEN nOpc == 1           SIZE 44,10 PIXEL RESOURCE "BUSCAR"
   @  14, 10 SAY oGet[14] VAR oV:aLS[4] OF oDlg PIXEL SIZE 130,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @  26, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @  26, 92 GET oGet[2] VAR oV:aLS[1] OF oDlg  SIZE 40,10 PIXEL
   @  38, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @  38, 92 GET oGet[3] VAR oV:aLS[2] OF oDlg ;
      VALID oV:aLS[2] >= oV:aLS[1] SIZE 40,10 PIXEL
   @  50, 00 SAY "MONEDA" OF oDlg RIGHT PIXEL SIZE 90,10
   @  50, 92 COMBOBOX oGet[4] VAR nMone ITEMS ArrayCol( aMon,1 ) SIZE 50,99;
      OF oDlg PIXEL  WHEN nOpc == 1
   @  62, 00 SAY "MARCA DEL PRODUCTO" OF oDlg RIGHT PIXEL SIZE 90,10
   @  62, 92 GET oGet[5] VAR oV:aLS[13] OF oDlg PICTURE "@!";
      WHEN oV:aLS[8] > 0  SIZE 70,10 PIXEL
   @  74, 00 SAY "PAGINA INICIAL"           OF oDlg RIGHT PIXEL SIZE 90,10
   @  74, 92 GET oGet[6] VAR oV:aLS[5] OF oDlg PICTURE "999";
      VALID Rango( oV:aLS[5],1,999 )                        ;
      WHEN nOpc  # 3           SIZE 24,10 PIXEL             ;
      MESSAGE "Digite 2 Para excluir las Opticas del Grupo ó las de Afuera"
   @  86, 00 SAY "VALOR DE DOLAR"          OF oDlg RIGHT PIXEL SIZE 90,10
   @  86, 92 GET oGet[7] VAR oV:aLS[6] OF oDlg PICTURE "9,999";
      WHEN nOpc == 1           SIZE 24,10 PIXEL
   @  86,120 CHECKBOX oGet[8] VAR oV:aLS[9] PROMPT oV:aLS[10] OF oDlg;
      WHEN Rango( nOpc,{1,4} ) SIZE 60,12 PIXEL
   @  98, 00 SAY "Precio Costo o Público"  OF oDlg RIGHT PIXEL SIZE 90,10
   @  98, 92 GET oGet[9] VAR oV:aLS[7] OF oDlg PICTURE "!";
      VALID oV:aLS[7] $ "CPV"                  ;
      WHEN nOpc  # 2           SIZE 08,10 PIXEL;
      MESSAGE "C_Costo, P_Público, V_Promedio"
   @  98,120 CHECKBOX oGet[10] VAR oV:aLS[3] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 110, 00 SAY "TIPO DE IMPRESORA"   OF oDlg RIGHT PIXEL SIZE 90,10
   @ 110, 92 COMBOBOX oGet[11] VAR oV:aLS[11] ITEMS { "MS-DOS","Laser","Excel" };
      SIZE 48,90 OF oDlg PIXEL

   @ 124, 50 BUTTON oGet[12] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oV:aLS[4]:= aMon[nMone,2], oGet[12]:Disable(),;
        EVAL( aRep[nOpc,1] )     , oGet[12]:Enable() ,;
        oGet[12]:oJump := oGet[2], oGet[02]:SetFocus() ) PIXEL
   @ 124,100 BUTTON oGet[13] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 130, 02 SAY "[CAOLIVEN]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
CLASS TLVentas FROM TIMPRIME
 DATA aGT, aLS, aLV, nC, nF, oRpt
 DATA cQry, hRes, nL

 METHOD NEW( nOpc,nOK ) Constructor
 METHOD ArmarINF( aRes,cQry )
 METHOD ListoVen()
 METHOD LaserVen( aRes,aVT,nK )
 METHOD ListoAnt( aVT )
 METHOD LaserAnt( aRes,aVT )
 METHOD ListoBim()
 METHOD ListoRes()
 METHOD ListaRes()
 METHOD Armo( aVT,nF,nC )
 METHOD LaserRes( aGT,aVT )
 METHOD Saltar( nC,nL,nMax )
 METHOD DatosRes( aVT )
 METHOD ArmoExcel( aVT,nF,nC )
ENDCLASS

//------------------------------------//
METHOD NEW( nOpc,nOK ) CLASS TLVentas
If nOK == NIL
   If nOpc # 3
      Empresa()
   EndIf
   ::aLS :=  { DATE(),DATE(),.f.," ",1,oApl:nUS,"P",0,.f.,;
               If( nOpc == 1, "ANTICIPOS", "Agrupar Opticas" ),oApl:nTFor,1,SPACE(15) }
Else
   ::aLV := { "MONTURAS OFTALMICAS ","GAFAS DE SOL....... ","LENTES OFTALMICOS.. ",;
              "LENTES DE CONTACTO. ","LIQUIDOS........... ","ACCESORIOS......... ",;
              "CONSULTAS.......... ","VARIOS............. ","TOTAL VENTA "        ,;
              "DESCUENTOS......... ","DSCTO Y DEVOLUCIONES","VENTAS NETAS....... ",;
              "I.V.A.............. ","G R A N  T O T A L. ","CLIENTE PARTICULAR. ",;
              "OPTICAS DEL GRUPO.. ","EMPRESAS........... " }
   If ::aLS[07] == "C"
      ::aLS[12] := 9
      ::aLV[09] += "AL COSTO"
   Else
      ::aLS[12] := 17
      ::aLV[09] += "BRUTA.. "
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD ArmarINF( aRes,cQry ) CLASS TLVentas
If aRes == "Ventas"
   cQry := "SELECT v.fecfac, v.numfac, v.codart, v.descri, v.cantidad, " +;
            "v.precioven, v.montoiva, v.pcosto, v.indicador, v.fecdev, " +;
            "v.desmon, i.moneda, i.tipomontu, i.ppubli, i.situacion, i.optica "+;
           "FROM cadventa v LEFT JOIN cadinven i ON v.codart = i.codigo "+;
           "WHERE v.optica  = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND v.fecfac >= " + xValToChar( ::aLS[1] )   +;
            " AND v.fecfac <= " + xValToChar( ::aLS[2] )   +;
            " AND v.tipo    = " + xValToChar(oApl:Tipo)    +;
                           cQry + If( ::aLS[8] == 0,     "",;
            " AND i.codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT)))+;
                If( ::aLS[4] == " ", "", " AND i.moneda = '" + ::aLS[4] + "'" )+;
                If( EMPTY( ::aLS[13] ), "",;
            " AND i.descrip LIKE '" + ALLTRIM(::aLS[13]) + "%'" )+;
            " ORDER BY v.fecfac, v.numfac"
/*
SELECT n.nombre, v.codart, v.precioven, v.fecfac
FROM cadclien n, cadinven i, cadventa v
WHERE n.codigo_nit = i.codigo_nit
  AND v.codart     = i.codigo
  AND v.optica     = 54
  AND v.fecfac    >= '2014-01-01'
  AND v.fecfac    <= '2014-09-30'
  AND LEFT(v.codart,2) = '01'
ORDER BY n.nombre, v.precioven
*/
ElseIf aRes == "VentaSC"
   cQry := "SELECT d.documen, d.codigo, d.pcosto, i.descrip "+;
           "FROM caddevod d, cadinven i "                    +;
           "WHERE d.optica  = " + LTRIM(STR(oApl:nEmpresa))  +;
            " AND d.fechad >= " + xValToChar( ::aLS[1] )     +;
            " AND d.fechad <= " + xValToChar( ::aLS[2] )     +;
            " AND d.causadev = 5 AND LEFT(d.codigo,2) = '01'"+;
            " AND i.codigo = d.codigo"                       +;
            " AND i.codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT))+;
            " AND i.moneda = 'C' ORDER BY d.documen"
ElseIf aRes == "Antici"
   cQry := "SELECT c.fecha, c.numero, d.codart, d.descri, d.cantidad,"+;
            " d.precioven + d.montoiva, c.numfac, d.pcosto, d.ppubli "+;
           "FROM cadantid d, cadantic c "                 +;
           "WHERE LEFT(d.codart,2) NOT IN('02','05')"     +;
            " AND c.optica = d.optica"                    +;
            " AND c.numero = d.numero"                    +;
            " AND c.optica = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND c.fecha >= " + xValToChar( ::aLS[1] )   +;
            " AND c.fecha <= " + xValToChar( ::aLS[2] )   +;
            " AND c.indicador <> 'A'"                     +;
            " ORDER BY c.fecha, c.numero"
EndIf
::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) > 0
   aRes := MyReadRow( ::hRes )
   AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( ::hRes,nP ) } )
EndIf
RETURN aRes

//1-----------------------------------//
METHOD ListoVen() CLASS TLVentas
   LOCAL oRpt, nG, nL, nK := 14
   LOCAL aRes, aVT, cQry
aVT := { { "MONTURAS  ",0,0,0,0,0 },{ "CON.VARIOS",0,0,0,0,0 },;
         { "LIQUIDOS  ",0,0,0,0,0 },{ "ACCESORIOS",0,0,0,0,0 },;
         { "L.OFTALMIC",0,0,0,0,0 },{ "L.CONTACTO",0,0,0,0,0 },;
         0,0,0,0,0,"999,999,999","PUBLI",0,0 }
If ::aLS[9]
   ::ListoAnt( aVT )
   RETURN NIL
EndIf
If ::aLS[7] $ "CV"
   ::aLS[7] := "C"
    aVT[13] := "COSTO"  //"PROME"
   nK   := 8
   aRes := " AND v.codart NOT IN('0203')"
//   aRes := " AND v.codart NOT IN('0203','0204','0501','0501000001','0506','0509','0510','0598',"+;
//                                "'0599','0599000001','0599000003','0599000004')"
Else
   aRes := " AND LEFT(v.codart,2) NOT IN('02','05')"
EndIf
 aRes   := ::ArmarINF( "Ventas",aRes )
If ::nL == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes )
   RETURN NIL
ElseIf ::aLS[11] == 2
   ::LaserVen( aRes,aVT,nK )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"LISTADO DE VENTAS",;
         "DESDE "+ NtChr( ::aLS[1],"2" )+ " HASTA "+ NtChr( ::aLS[2],"2" ),;
         "FACTURA CODIGO------ D E S C R I P C I O N-------------------  CANT."+;
         "  VALOR FACTU       I.V.A.    DESCUENTO    PRE." + aVT[13] },::aLS[3],::aLS[5],2 )
oRpt:aEnc[1] += If( ::aLS[8] > 0, " - "+TRIM(oApl:oNit:NOMBRE), "" )
oRpt:aEnc[2] += { " CONSIGNACION"," CARTIER", "" }[AT(::aLS[4],"CU ")]
   aVT[07] := aRes[1]
While ::nL > 0
   aVT[13] := Grupos( aRes[03] )
   If aRes[06]  > 0 .OR.;
     (aRes[06] == 0 .AND. aVT[13] # "2")
      aVT[08] := If( aRes[09] $ "AD" .AND. aRes[10] <= ::aLS[2], 0, aRes[05] )
      aVT[09] := Dolar_Peso( ::aLS[6],aRes[nK],aRes[12] )
      aVT[14] := aRes[06] + aRes[07]
      nG      := VAL(aVT[13])
         oRpt:Titulo( 122 )
      If oRpt:nPage >= oRpt:nPagI
         If aVT[13] + aRes[13] == "1S"
            aRes[4] := LEFT( aRes[4],34 ) + "[SOL]"
         EndIf
          aVT[15] := aRes[05] * aRes[nK]
         oRpt:Say( oRpt:nL, 00,STR( aRes[02],7 ) )
         oRpt:Say( oRpt:nL, 08,aRes[03] )
         oRpt:Say( oRpt:nL, 21,aRes[04] )
         oRpt:Say( oRpt:nL, 63,TRANSFORM(aRes[05],"9,999"))
         oRpt:Say( oRpt:nL, 70,TRANSFORM( aVT[14],aVT[12] ))
         oRpt:Say( oRpt:nL, 83,TRANSFORM(aRes[07],aVT[12] ))
         oRpt:Say( oRpt:nL, 96,TRANSFORM(aRes[11],aVT[12] ))
         oRpt:Say( oRpt:nL,109,TRANSFORM( aVT[15],aVT[12] ))
         oRpt:Say( oRpt:nL,122,If( aVT[08] == 0, aRes[09], " " ))
      EndIf
         oRpt:nL++
      aVT[nG,2] += aVT[08]
      aVT[nG,4] += aRes[07]
      aVT[nG,5] += aRes[11]
      aVT[nG,6] += aVT[08] * aVT[09]
      If aVT[08] # 0
         aVT[nG,3] += aRes[06]
         aVT[10]   +=  aVT[14]
      EndIf
      If LEFT(aRes[3],2) == "01" .AND. aRes[09] == " "           .AND.;
                aRes[15] == "E"  .AND. aRes[16] == oApl:nEmpresa .AND.;
             oApl:cLocal == "LOC"
         If SaldoInv( aRes[3],NtChr( aRes[1],"1" ),1 ) == 0
            cQry := "UPDATE cadinven SET situacion = 'V', "+;
                       "pvendida = " +  LTRIM(STR(aRes[6]))+;
                     ", factuven = " +  LTRIM(STR(aRes[2]))+;
                     ", fecventa = " + xValToChar(aRes[1] )+;
                  " WHERE codigo = " + xValToChar(aRes[3] )
            MSQuery( oApl:oMySql:hConnect,cQry )
         EndIf
      EndIf
   EndIf
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If (::nL == 0 .OR. aVT[07] # aRes[1]) .AND.;
      ::aLS[8] == 0 .AND. aVT[10] > 0
      oRpt:Say(  oRpt:nL,00,REPLICATE("_",122),,,1 )
      oRpt:Say(++oRpt:nL,21,"TOTAL DEL DIA " +LEFT( NtChr(aVT[07],"2"),6 ),,,1)
      oRpt:Say(  oRpt:nL,70,TRANSFORM( aVT[10],aVT[12] ))
      oRpt:nL+= 2
      aVT[07] := aRes[1]
      aVT[11] += aVT[10]
      aVT[10] := 0
   EndIf
EndDo
MSFreeResult( ::hRes )

If ::aLS[8] > 0
   aRes := ::ArmarINF( "VentaSC" )
   If ::nL > 0
      oRpt:Say(++oRpt:nL,20,"====SALIDAS SIN COSTO====",,,1 )
      oRpt:nL += 2
   EndIf
   While ::nL > 0
      oRpt:Titulo( 80 )
      If oRpt:nPage >= oRpt:nPagI
         oRpt:Say( oRpt:nL,00,STR( aRes[1],7 ) )
         oRpt:Say( oRpt:nL,08,aRes[2] )
         oRpt:Say( oRpt:nL,21,aRes[4] )
         oRpt:Say( oRpt:nL,67,"1" )
         oRpt:Say( oRpt:nL,70,TRANSFORM(aRes[3],aVT[12] ))
      EndIf
      oRpt:nL++
      aVT[1,2] += 1
      aVT[1,3] += aRes[3]
      If (::nL --) > 1
         aRes := MyReadRow( ::hRes )
         AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
      EndIf
   EndDo
   MSFreeResult( ::hRes )
EndIf
 oRpt:Say( oRpt:nL,21,"TOTAL VENTA................." + NtChr(aVT[11],aVT[12]),,,1)
 oRpt:Separator( 3,10 )
 oRpt:Say( oRpt:nL++,19,"CANTIDAD  VALOR VENTA  VALOR I.V.A    DESCUENTO  VALOR COSTO" )
 AFILL( aVT, 0,7,5 )
 FOR nG := 1 TO 6
    cQry := ""
    If aVT[nG,2] > 0
       aVT[07] += aVT[nG,2]
       aVT[08] += aVT[nG,3]
       aVT[09] += aVT[nG,4]
       aVT[10] += aVT[nG,5]
       aVT[11] += aVT[nG,6]
       If nK == 8
          nL := ((aVT[nG,3] - aVT[nG,6]) / aVT[nG,3]) * 100
          cQry := TRANSFORM( nL,"999999999.99%" )
       EndIf
       oRpt:Say( oRpt:nL++,06,aVT[nG,1]        +;
                 TRANSFORM( aVT[nG,2],aVT[12] )+ "  " +;
                 TRANSFORM( aVT[nG,3],aVT[12] )+ "  " +;
                 TRANSFORM( aVT[nG,4],aVT[12] )+ "  " +;
                 TRANSFORM( aVT[nG,5],aVT[12] )+ "  " +;
                 TRANSFORM( aVT[nG,6],aVT[12] )+ cQry )
    EndIf
 NEXT nG
 oRpt:Say( oRpt:nL++,06,REPLICATE("_",86) )
 oRpt:Say( oRpt:nL++,06,"GRAN TOTAL"   +;
           TRANSFORM( aVT[07],aVT[12] )+ "  " +;
           TRANSFORM( aVT[08],aVT[12] )+ "  " +;
           TRANSFORM( aVT[09],aVT[12] )+ "  " +;
           TRANSFORM( aVT[10],aVT[12] )+ "  " +;
           TRANSFORM( aVT[11],aVT[12] ) )
oRpt:NewPage()
oRpt:End()
RETURN NIL

//1-----------------------------------//
METHOD LaserVen( aRes,aVT,nK ) CLASS TLVentas
   LOCAL cQry, nG, nFac := 0
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit                 ,;
             "LISTADO DE VENTAS" + If( ::aLS[8] > 0, " - "+TRIM(oApl:oNit:NOMBRE), "" ),;
             "DESDE "+NtChr( ::aLS[1],"2" ) + " HASTA " + NtChr( ::aLS[2],"2" ) +;
             { " CONSIGNACION"," CARTIER", "" }[AT(::aLS[4],"CU ")],;
             { .F., 0.5,"FACTURA" }    , { .F., 2.2,"CODIGO" } ,;
             { .F., 4.1,"DESCRIPCION" }, { .T.,10.8,"CANT." }  ,;
             { .T.,13.3,"VALOR FACTU" }, { .T.,15.6,"I.V.A." } ,;
             { .T.,18.1,"DESCUENTO" }  , { .T.,20.6,"PRE." + aVT[13] } }
   aVT[7] := aRes[1]
 ::Init( ::aEnc[4], .f. ,, !::aLS[3] ,,,, 5 )
 ::nMD := 20.9
   PAGE
While ::nL > 0
   aVT[13] := Grupos( aRes[03] )
   If aRes[06]  > 0 .OR.;
     (aRes[06] == 0 .AND. aVT[13] # "2")
      aVT[08] := If( aRes[09] $ "AD" .AND. aRes[10] <= ::aLS[2], 0, aRes[05] )
      aVT[09] := Dolar_Peso( ::aLS[6],aRes[nK],aRes[12] )
      aVT[14] := aRes[06] + aRes[07]
      aVT[15] := aRes[05] * aRes[nK]
      nG      := VAL(aVT[13])
      If aVT[13] + aRes[13] == "1S"
         aRes[4] := LEFT( aRes[4],34 ) + "[SOL]"
      EndIf
      ::Cabecera( .t.,0.45 )
      If nFac  # aRes[2]
         nFac := aRes[2]
         UTILPRN ::oUtil Self:nLinea,02.0 SAY STR(nFac,8)                  RIGHT
      EndIf
         UTILPRN ::oUtil Self:nLinea,02.2 SAY aRes[03]
         UTILPRN ::oUtil Self:nLinea,04.1 SAY aRes[04]
         UTILPRN ::oUtil Self:nLinea,10.8 SAY TRANSFORM(aRes[05],"9,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,13.3 SAY TRANSFORM( aVT[14],aVT[12] ) RIGHT
         UTILPRN ::oUtil Self:nLinea,15.6 SAY TRANSFORM(aRes[07],aVT[12] ) RIGHT
         UTILPRN ::oUtil Self:nLinea,18.1 SAY TRANSFORM(aRes[11],aVT[12] ) RIGHT
         UTILPRN ::oUtil Self:nLinea,20.6 SAY TRANSFORM( aVT[15],aVT[12] ) RIGHT
         UTILPRN ::oUtil Self:nLinea,20.8 SAY If( aVT[08] == 0, aRes[09], "" )
      aVT[nG,2] += aVT[08]
      aVT[nG,4] += aRes[07]
      aVT[nG,5] += aRes[11]
      aVT[nG,6] += aVT[08] * aVT[09]
      If aVT[08] # 0
         aVT[nG,3] += aRes[06]
         aVT[10]   +=  aVT[14]
      EndIf
      If LEFT(aRes[3],2) == "01" .AND. aRes[09] == " "           .AND.;
                aRes[15] == "E"  .AND. aRes[16] == oApl:nEmpresa .AND.;
             oApl:cLocal == "LOC"
         If SaldoInv( aRes[3],NtChr( aRes[1],"1" ),1 ) == 0
            cQry := "UPDATE cadinven SET situacion = 'V', "+;
                       "pvendida = " +  LTRIM(STR(aRes[6]))+;
                     ", factuven = " +  LTRIM(STR(aRes[2]))+;
                     ", fecventa = " + xValToChar(aRes[1] )+;
                  " WHERE codigo = " + xValToChar(aRes[3] )
            MSQuery( oApl:oMySql:hConnect,cQry )
         EndIf
      EndIf
   EndIf
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If (::nL == 0 .OR. aVT[07] # aRes[1]) .AND.;
      ::aLS[8] == 0 .AND. aVT[10] > 0
      ::Cabecera( .t.,0.4,1.3,21 )
      UTILPRN ::oUtil Self:nLinea,04.1 SAY "TOTAL DEL DIA " + LEFT( NtChr(aVT[7],"2"),6 )
      UTILPRN ::oUtil Self:nLinea,13.3 SAY TRANSFORM( aVT[10],aVT[12] ) RIGHT
      ::nLinea += 0.45
      aVT[07] := aRes[1]
      aVT[11] += aVT[10]
      aVT[10] := 0
   EndIf
EndDo
MSFreeResult( ::hRes )
If ::aLS[8] > 0
   aRes := ::ArmarINF( "VentaSC" )
   If ::nL > 0
      UTILPRN ::oUtil Self:nLinea,05.0 SAY "====SALIDAS SIN COSTO===="
      ::nLinea += 0.45
      nFac := 0
   EndIf
   While ::nL > 0
      ::Cabecera( .t.,0.45 )
      If nFac  # aRes[1]
         nFac := aRes[1]
         UTILPRN ::oUtil Self:nLinea,02.0 SAY STR(nFac,8)                 RIGHT
      EndIf
         UTILPRN ::oUtil Self:nLinea,02.2 SAY aRes[2]
         UTILPRN ::oUtil Self:nLinea,04.1 SAY aRes[4]
         UTILPRN ::oUtil Self:nLinea,10.8 SAY "1"                         RIGHT
         UTILPRN ::oUtil Self:nLinea,13.3 SAY TRANSFORM(aRes[3],aVT[12] ) RIGHT
      aVT[1,2] += 1
      aVT[1,3] += aRes[3]
      If (::nL --) > 1
         aRes := MyReadRow( ::hRes )
         AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
      EndIf
   EndDo
   MSFreeResult( ::hRes )
EndIf
      ::Cabecera( .t.,0.1,2.40 )
      UTILPRN ::oUtil Self:nLinea,04.1 SAY "TOTAL VENTA................."
      UTILPRN ::oUtil Self:nLinea,13.3 SAY TRANSFORM( aVT[11],aVT[12] ) RIGHT
      ::nLinea += 0.60
      UTILPRN ::oUtil Self:nLinea,05.3 SAY "Cantidad"    RIGHT
      UTILPRN ::oUtil Self:nLinea,07.3 SAY "Valor Venta" RIGHT
      UTILPRN ::oUtil Self:nLinea,09.3 SAY "Valor I.V.A" RIGHT
      UTILPRN ::oUtil Self:nLinea,11.3 SAY "Descuento"   RIGHT
      UTILPRN ::oUtil Self:nLinea,13.3 SAY "Valor Costo" RIGHT
 AFILL( aVT, 0,7,5 )
 FOR nG := 1 TO 6
    cQry := ""
    If aVT[nG,2] > 0
       aVT[07] += aVT[nG,2]
       aVT[08] += aVT[nG,3]
       aVT[09] += aVT[nG,4]
       aVT[10] += aVT[nG,5]
       aVT[11] += aVT[nG,6]
       If nK == 8
          ::nL := ((aVT[nG,3] - aVT[nG,6]) / aVT[nG,3]) * 100
          cQry := TRANSFORM( ::nL,"999999999.99%" )
       EndIf
       ::nLinea += 0.45
       UTILPRN ::oUtil Self:nLinea,02.2 SAY aVT[nG,1]
       UTILPRN ::oUtil Self:nLinea,05.3 SAY TRANSFORM( aVT[nG,2],aVT[12] ) RIGHT
       UTILPRN ::oUtil Self:nLinea,07.3 SAY TRANSFORM( aVT[nG,3],aVT[12] ) RIGHT
       UTILPRN ::oUtil Self:nLinea,09.3 SAY TRANSFORM( aVT[nG,4],aVT[12] ) RIGHT
       UTILPRN ::oUtil Self:nLinea,11.3 SAY TRANSFORM( aVT[nG,5],aVT[12] ) RIGHT
       UTILPRN ::oUtil Self:nLinea,13.3 SAY TRANSFORM( aVT[nG,6],aVT[12] ) RIGHT
       UTILPRN ::oUtil Self:nLinea,15.3 SAY cQry                           RIGHT
    EndIf
 NEXT nG
       ::nLinea += 0.35
       UTILPRN ::oUtil LINEA Self:nLinea,2.2 TO Self:nLinea,15.0 PEN ::oPen
       ::nLinea += 0.45
       UTILPRN ::oUtil Self:nLinea,02.2 SAY "GRAN TOTAL"
       UTILPRN ::oUtil Self:nLinea,05.3 SAY TRANSFORM( aVT[07],aVT[12] ) RIGHT
       UTILPRN ::oUtil Self:nLinea,07.3 SAY TRANSFORM( aVT[08],aVT[12] ) RIGHT
       UTILPRN ::oUtil Self:nLinea,09.3 SAY TRANSFORM( aVT[09],aVT[12] ) RIGHT
       UTILPRN ::oUtil Self:nLinea,11.3 SAY TRANSFORM( aVT[10],aVT[12] ) RIGHT
       UTILPRN ::oUtil Self:nLinea,13.3 SAY TRANSFORM( aVT[11],aVT[12] ) RIGHT
   ENDPAGE
IMPRIME END .F.
RETURN NIL

//------------------------------------//
METHOD ListoAnt( aVT ) CLASS TLVentas
   LOCAL aRes, nG, oRpt
 aRes   := ::ArmarINF( "Antici" )
If ::nL == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes )
   RETURN NIL
ElseIf ::aLS[11] == 2
   ::LaserAnt( aRes,aVT )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"LISTADO DE ANTICIPOS"           ,;
         "DESDE "+ NtChr( ::aLS[1],"2" )+ " HASTA "+ NtChr( ::aLS[2],"2" ),;
         "ANTICIPO  FACTURA C O D I G O  D E S C R I P C I O N----     CANT PRE.VENDIDO"},::aLS[3] )
   aVT[7] := aRes[1]
While ::nL > 0
      oRpt:Titulo( 79 )
   If aVT[8]  # aRes[2]
      aVT[8] := aRes[2]
      oRpt:Say( oRpt:nL,00,STR( aRes[2],8 ) )
      oRpt:Say( oRpt:nL,09,TRANSFORM(aRes[7],"@Z 99999999" ))
   EndIf
      oRpt:Say( oRpt:nL,18,aRes[3] )
      oRpt:Say( oRpt:nL,31,aRes[4] )
      oRpt:Say( oRpt:nL,61,TRANSFORM(aRes[5],"9999" ))
      oRpt:Say( oRpt:nL,66,TRANSFORM(aRes[6],aVT[12]))
      oRpt:nL++
   nG := VAL(Grupos( aRes[3] ))
   aVT[nG,2] += aRes[5]
   aVT[nG,3] += aRes[6]
   aVT[9]    += aRes[6]
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. aVT[7] # aRes[1]
      oRpt:Say(  oRpt:nL,00,Replicate("_",79),,,1 )
      oRpt:Say(++oRpt:nL,10,"TOTAL DEL DIA " +LEFT( NtChr(aVT[7],"2"),6 ),,,1)
      oRpt:Say(  oRpt:nL,66,TRANSFORM( aVT[9],aVT[12] ))
      oRpt:nL+= 2
      aVT[07] := aRes[1]
      aVT[10] += aVT[9]
      aVT[09] := 0
   EndIf
EndDo
MSFreeResult( ::hRes )
If aVT[10] > 0
   oRpt:Say( oRpt:nL,10,"TOTAL ANTICIPOS............." + TRANSFORM(aVT[10],aVT[12]),,,1)
   oRpt:Separator( 3,5 )
   oRpt:Say( oRpt:nL++,23,"CANTIDAD  VALOR VENTA" )
   FOR nG := 1 TO 6
      If aVT[nG,2] > 0
         oRpt:Say( oRpt:nL++,10,aVT[nG,1]         +;
                   TRANSFORM( aVT[nG,2],aVT[12] ) + "  " +;
                   TRANSFORM( aVT[nG,3],aVT[12] ) )
      EndIf
   NEXT nG
EndIf
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserAnt( aRes,aVT ) CLASS TLVentas
   LOCAL nG
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit                    ,;
             "LISTADO DE ANTICIPOS","DESDE "+NtChr( ::aLS[1],"2" )+;
             " HASTA " + NtChr( ::aLS[2],"2" ),;
             { .F., 0.5,"ANTICIPO" }  , { .F., 2.4,"FACTURA" }    ,;
             { .F., 4.3,"CODIGO" }    , { .F., 6.6,"DESCRIPCION" },;
             { .T.,18.0,"CANT" }      , { .T.,20.8,"PRE.VENDIDO" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[3] ,,,, 2 )
 ::nMD := 20.8
   PAGE
   aVT[7] := aRes[1]
While ::nL > 0
      ::Cabecera( .t.,0.45 )
   If aVT[8]  # aRes[2]
      aVT[8] := aRes[2]
      UTILPRN ::oUtil Self:nLinea,02.2 SAY STR(aRes[2],8)                    RIGHT
      UTILPRN ::oUtil Self:nLinea,03.9 SAY TRANSFORM(aRes[7],"@Z 99999999" ) RIGHT
   EndIf
      UTILPRN ::oUtil Self:nLinea,04.3 SAY aRes[3]
      UTILPRN ::oUtil Self:nLinea,06.6 SAY aRes[4]
      UTILPRN ::oUtil Self:nLinea,18.0 SAY TRANSFORM(aRes[5],"9999" )  RIGHT
      UTILPRN ::oUtil Self:nLinea,20.8 SAY TRANSFORM(aRes[6],aVT[12] ) RIGHT
   nG := VAL(Grupos( aRes[3] ))
   aVT[nG,2] += aRes[5]
   aVT[nG,3] += aRes[6]
   aVT[9]    += aRes[6]
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. aVT[7] # aRes[1]
      ::Cabecera( .t.,0.4,1.3,21 )
      UTILPRN ::oUtil Self:nLinea,03.0 SAY "TOTAL DEL DIA " + LEFT( NtChr(aVT[7],"2"),6 )
      UTILPRN ::oUtil Self:nLinea,20.8 SAY TRANSFORM( aVT[9],aVT[12] ) RIGHT
      ::nLinea += 0.45
      aVT[07] := aRes[1]
      aVT[10] += aVT[9]
      aVT[09] := 0
   EndIf
EndDo
MSFreeResult( ::hRes )
   If aVT[10] > 0
      ::Cabecera( .t.,0.1,2.40 )
      UTILPRN ::oUtil Self:nLinea,03.0 SAY "TOTAL ANTICIPOS............."
      UTILPRN ::oUtil Self:nLinea,12.0 SAY TRANSFORM( aVT[10],aVT[12] ) RIGHT
      ::nLinea += 0.60
      UTILPRN ::oUtil Self:nLinea,07.6 SAY "CANTIDAD  VALOR VENTA"
   FOR nG := 1 TO 6
      If aVT[nG,2] > 0
         ::nLinea += 0.45
         UTILPRN ::oUtil Self:nLinea,03.0 SAY aVT[nG,1]
         UTILPRN ::oUtil Self:nLinea,09.5 SAY TRANSFORM( aVT[nG,2],aVT[12] ) RIGHT
         UTILPRN ::oUtil Self:nLinea,12.0 SAY TRANSFORM( aVT[nG,3],aVT[12] ) RIGHT
      EndIf
   NEXT nG
EndIf
   ENDPAGE
IMPRIME END .F.
RETURN NIL

//4-----------------------------------//
METHOD ListoBim() CLASS TLVentas
   LOCAL aVT, aRes, cQry, hRes, nG, nK, nL, oRpt
   LOCAL aV := { 0,0,0,0,"","" }, aOG := {}
cQry := "SELECT codigo_nit FROM opticasg WHERE codigo <> " +;
        STRTRAN( LEFT( oApl:oEmp:NIT,AT("-",oApl:oEmp:NIT)-1 ),".","" )
 aOG := Buscar( cQry,"CM",,9 )
If ::aLS[9]
   cQry := "principal = " + LTRIM(STR(oApl:oEmp:PRINCIPAL))+;
      " AND optica <> 1"
   If ::aLS[5] == 2
      cQry += " AND reshabit = '08001'"
   EndIf
   aRes  := Privileg( cQry,.T.,(oApl:oEmp:PRINCIPAL == 4) )
   aV[5] := aRes[1]
   aV[6] := aRes[2]
Else
   aV[5] := " = " + LTRIM(STR(oApl:nEmpresa))
   aV[6] := "AÑO " + STR(YEAR(::aLS[2]))
EndIf
cQry := "SELECT v.numfac, v.codart, v.precioven, v.indicador, v."+;
        "fecdev, v.fecfac, c.codigo_nit, i.moneda, i.tipomontu " +;
        "FROM cadfactu c, cadventa v LEFT JOIN cadinven i"       +;
          " ON v.codart  = i.codigo "               +;
        "WHERE v.optica  = c.optica"                +;
         " AND v.numfac  = c.numfac"                +;
         " AND v.tipo    = c.tipo"                  +;
         " AND v.optica "    + aV[5]                +;
         " AND v.fecfac >= " + xValToChar( ::aLS[1])+;
         " AND v.fecfac <= " + xValToChar( ::aLS[2])+;
         " AND v.tipo    = " + xValToChar(oApl:Tipo)+;
         " ORDER BY v.optica, v.numfac"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aV[1] := aRes[1]
 //aV[3] := If( Rango( aRes[7],{358,578,626,655,826} ), 1, 0 )
   aV[3] := If( Rango( aRes[7],aOG ), 1, 0 )
   nK    := { 1,1,2,2,3,3,4,4,5,5,6,6 }[MONTH( aRes[6] )]
EndIf
aVT := { {0,0,0,0,0,0, 1,"Monturas de Sol c/U.V."   },{0,0,0,0,0,0, 2,"Monturas Recetadas"     },;
         {0,0,0,0,0,0, 8,"Monturas a FPV, PAN, OG"  },{0,0,0,0,0,0, 3,"L.Contacto a Pacientes" },;
         {0,0,0,0,0,0, 9,"L.Contacto a FPV, PAN, OG"},{0,0,0,0,0,0,11,"Liq. y Acc a Pacientes" },;
         {0,0,0,0,0,0,10,"Liq. y Acc a FPV, PAN, OG"},{0,0,0,0,0,0, 4,"Lentes Oftalmicos"      },;
         {0,0,0,0,0,0, 5,"Consultas"                },{0,0,0,0,0,0,12,"Otros"                  },;
         {0,0,0,0,0,0, 6,"Devoluciones x NC"        },{0,0,0,0,0,0,13,"Devoluciones x NC"      },;
         {0,0,0,0,0,0, 7," TOTAL NO GRAVADAS"       },{0,0,0,0,0,0,14," TOTAL    GRAVADAS"     },;
         {0,0,0,0,0,0,15,"GRAN TOTAL ==>"} }
While nL > 0
   nG := GrupoIca( aRes[2],aRes[9],aV[3] )
   aV[2] := If( aRes[4] $ "AD" .AND. aRes[5] <= ::aLS[2], 0, 1 )
   aVT[nG,nK] += aV[2] * aRes[3]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aV[1] # aRes[1]
      aV[1] := aRes[1]
      aV[3] := If( Rango( aRes[7],aOG ), 1, 0 )
      nK    := { 1,1,2,2,3,3,4,4,5,5,6,6 }[MONTH( aRes[6] )]
   EndIf
EndDo
MSFreeResult( hRes )
cQry := "SELECT c.numero, c.fecha, d.codigo, d.precioven, c.codigo_nit, i.tipomontu "+;
        "FROM cadnotac c, cadnotad d LEFT JOIN cadinven i"+;
        " USING( codigo ) "                               +;
        "WHERE c.optica = d.optica"                       +;
         " AND c.numero = d.numero"                       +;
         " AND c.optica "   + aV[5]                       +;
         " AND c.fecha >= " + xValToChar( ::aLS[1] )      +;
         " AND c.fecha <= " + xValToChar( ::aLS[2] )      +;
         " AND c.clase <= 2 ORDER BY c.numero"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aV[1] := aRes[1]
   aV[3] := If( Rango( aRes[5],aOG ), 1, 0 )
   nK    := { 1,1,2,2,3,3,4,4,5,5,6,6 }[MONTH( aRes[2] )]
EndIf
While nL > 0
   nG := GrupoIca( aRes[3],aRes[6],aV[3] )
   aRes[4] *= -1
   If Rango( nG,{3,5,6,7,10 } )
      aVT[12,nK] += aRes[4]
   Else
      aVT[11,nK] += aRes[4]
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aV[1] # aRes[1]
      aV[1] := aRes[1]
      aV[3] := If( Rango( aRes[5],aOG ), 1, 0 )
      nK    := { 1,1,2,2,3,3,4,4,5,5,6,6 }[MONTH( aRes[2] )]
   EndIf
EndDo
MSFreeResult( hRes )
ASORT( aVT,,, { |x,y| x[7] < y[7] } )
If ::aLS[11] == 1
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,{"RESUMEN DE VENTAS BIMESTRAL","DESDE "+;
            NtChr( ::aLS[1],"2" )+ " HASTA "+ NtChr( ::aLS[2],"2" ),aV[6]},::aLS[3],,2 )
   oRpt:Titulo( 132 )
   oRpt:Say( 09,34,"BIM.   I       BIM.  II       BIM. III       BIM.  IV       BIM.   V       BIM.  VI  T O T A L E S" )
   cQry:= "9,999,999,999"
   nL  := 10
   FOR nG := 1 TO 15
      If nG <= 13 .AND. nG # 7
         FOR nK := 1 TO 6
            If nG <= 6
               aVT[07,nK] += aVT[nG,nK]
            Else
               aVT[14,nK] += aVT[nG,nK]
            EndIf
               aVT[15,nK] += aVT[nG,nK]
         NEXT nK
      EndIf
      nK := aVT[nG,1] + aVT[nG,2] + aVT[nG,3] + aVT[nG,4] + aVT[nG,5] + aVT[nG,6]
      oRpt:Say( nL, 00,aVT[nG,8] )
      oRpt:Say( nL, 29,TRANSFORM(aVT[nG,1],cQry ))
      oRpt:Say( nL, 44,TRANSFORM(aVT[nG,2],cQry ))
      oRpt:Say( nL, 59,TRANSFORM(aVT[nG,3],cQry ))
      oRpt:Say( nL, 74,TRANSFORM(aVT[nG,4],cQry ))
      oRpt:Say( nL, 89,TRANSFORM(aVT[nG,5],cQry ))
      oRpt:Say( nL,104,TRANSFORM(aVT[nG,6],cQry ))
      oRpt:Say( nL,119,TRANSFORM( nK      ,cQry ))
      nL += 2
   NEXT nG
   oRpt:Say( 21,00,REPLICATE("_",132) )
   oRpt:Say( 35,00,REPLICATE("_",132) )
   oRpt:Say( 37,00,REPLICATE("=",132) )
   oRpt:NewPage()
   oRpt:End()
Else
      nL  := 7
     cQry := cFilePath( GetModuleFileName( GetInstance() )) + "Test1.xls"
   ::oRpt := TExcelScript():New()
   ::oRpt:Create( cQry )
   ::oRpt:Font("Arial")
   ::oRpt:Size(10)
   ::oRpt:ColumnWidth( 1 , 25.00 )
   ::oRpt:Align(1)
   ::oRpt:Visualizar(.F.)
   ::oRpt:Say(  1, 1, oApl:cEmpresa )
   ::oRpt:Say(  2, 2, "RESUMEN DE VENTAS BIMESTRAL" )
   ::oRpt:Say(  3, 2, "DESDE "+ NtChr(::aLS[1],"2")+ " HASTA "+ NtChr(::aLS[2],"2") )
   ::oRpt:Say(  4, 1, aV[6] )
   ::oRpt:Say(  6, 2, "BIM.   I" )
   ::oRpt:Say(  6, 3, "BIM.  II" )
   ::oRpt:Say(  6, 4, "BIM. III" )
   ::oRpt:Say(  6, 5, "BIM.  IV" )
   ::oRpt:Say(  6, 6, "BIM.   V" )
   ::oRpt:Say(  6, 7, "BIM.  VI" )
   ::oRpt:Say(  6, 8, "T O T A L E S" )
   FOR nG := 1 TO 15
      If nG <= 13 .AND. nG # 7
         FOR nK := 1 TO 6
            If nG <= 6
               aVT[07,nK] += aVT[nG,nK]
            Else
               aVT[14,nK] += aVT[nG,nK]
            EndIf
               aVT[15,nK] += aVT[nG,nK]
         NEXT nK
      EndIf
      nK := aVT[nG,1] + aVT[nG,2] + aVT[nG,3] + aVT[nG,4] + aVT[nG,5] + aVT[nG,6]
      ::oRpt:Say( nL, 1, aVT[nG,8] )
      ::oRpt:Say( nL, 2, aVT[nG,1] )
      ::oRpt:Say( nL, 3, aVT[nG,2] )
      ::oRpt:Say( nL, 4, aVT[nG,3] )
      ::oRpt:Say( nL, 5, aVT[nG,4] )
      ::oRpt:Say( nL, 6, aVT[nG,5] )
      ::oRpt:Say( nL, 7, aVT[nG,6] )
      ::oRpt:Say( nL, 8, nK        )
      nL += 2
   NEXT nG
   ::oRpt:Visualizar(.T.)
   ::oRpt:End(.F.) ; ::oRpt := NIL
EndIf
RETURN NIL

//2-----------------------------------//
METHOD ListoRes() CLASS TLVentas
   LOCAL oRpt, oLC, aRes, cQry, hRes, nL, nC
   LOCAL aVD := { 0,0,0,0,0,"1","",0,.t. }, cPict := "99,999,999,999"
oLC := oApl:Abrir( "contacto","grupo, codigo" )
oLC:dbEval( {|o| o:CANTIDAD := o:VALOR := 0, o:Update( .f.,1 ) } )
cQry := "SELECT d.codart, d.descri, d.fecfac, d.fecdev, d.indicador, "+;
             "d.cantidad, d.precioven, d.desmon, d.montoiva, n.grupo "+;
        "FROM cadventa d, cadfactu c, cadclien n "      +;
        "WHERE LEFT(d.codart,4) <> '0203'"              +;
         " AND c.optica  = d.optica"                    +;
         " AND c.numfac  = d.numfac AND c.tipo = d.tipo"+;
         " AND c.optica  = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fechoy >= " + xValToChar( ::aLS[1] )   +;
         " AND c.fechoy <= " + xValToChar( ::aLS[2] )   +;
         " AND c.tipo    = " + xValToChar(oApl:Tipo)    +;
         " AND c.indicador <> 'A'"                      +;
         " AND n.codigo_nit = c.codigo_nit"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aRes[10] .AND. ::aLS[5] == 2
      nL --
      LOOP
   EndIf
   aVD[6] := Grupos( aRes[1] )
   aVD[7] := LEFT( aRes[1],2 )
   aVD[9] := .f.
   If (aVD[6] + aVD[7]) == "502"
      If SUBSTR( aRes[2],38,1 ) $ "123"
         aVD[7] := STUFF( RIGHT( aRes[2],4 ),2,1,"" ) + " "
         aVD[7] := If( NtChr( aVD[7] ) <= 2, "002", ;
                   If( aVD[7] == "050", "150", aVD[7] ))
                // If( SUBSTR( aRes[2],3,2 ) == "T.", "T", " " )
         aVD[9] := .t.
      Else
         aVD[7] := "9998"
      EndIf
   ElseIf LEFT( aRes[1],5 ) == "05990"
      nC   := VAL( SUBSTR( aRes[1],10,1 ) )
      aVD[6] := { "2","5","6" }[nC]
      aVD[7] := { "02","9999","9999" }[nC]
   Else
      aVD[7] += If( aVD[6] $ "134", "", SUBSTR( aRes[1],3,2 ) )
   EndIf
   nC := If( LEFT(DTOS(aRes[3]),6) <= LEFT(DTOS(aRes[4]),6) .AND.;
             aRes[5] == "D", 0, aRes[6] )
   If !oLC:Seek( { "grupo",aVD[6],"codigo",aVD[7] } )
       If aVD[9]
          oLC:NOMBRE := Buscar( {"clase_mate",LEFT(aVD[7],1),"tipo_mater",SUBSTR(aVD[7],2,2)},;
                                "cadtlist","nombre",8 )
       Else
          If !oApl:oInv:Seek( {"codigo",aRes[1]} )
              oApl:oInv:Seek( {"codigo",LEFT(aRes[1],4)} )
          EndIf
          oLC:NOMBRE := oApl:oInv:DESCRIP
      EndIf
      oLC:GRUPO  := aVD[6] ; oLC:CODIGO := aVD[7]
      oLC:Append( .t. )
      oLC:VALOR  := oLC:CANTIDAD := 0
   EndIf
   oLC:VALOR    += aRes[7] + aRes[8]
   oLC:CANTIDAD += nC   ; oLC:Update( .f.,1 )
   aVD[1] += aRes[8]
   aVD[2] += aRes[9]
   If aVD[6] == "6" .AND. aVD[7] # "9999"
      aVD[8] += nC
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"RESUMEN DE VENTAS POR PRODUCTOS"  ,;
         "DESDE " + NtChr( ::aLS[1],"2" ) + " HASTA " + NtChr( ::aLS[2],"2" ),;
         "CLASE MATERIAL  -------D E S C R I P C I O N-------  CANTIDAD" +;
         "     VALOR VENTA" },::aLS[3] )
oRpt:aEnc[1] += If( ::aLS[5] == 2, " - SIN O.GRUPO", "" )
oLC:Seek( { "grupo >=","1" },"grupo, codigo" ) //,"Cantidad >",0
aVD[7] := oLC:GRUPO
While !oLC:EOF()
   If oLC:CANTIDAD > 0
      oRpt:Titulo( 78 )
      oRpt:Say( oRpt:nL  ,01,oLC:NOMBRE_CLA )
      oRpt:Say( oRpt:nL  ,17,oLC:NOMBRE )
      If oLC:GRUPO == "6" .AND. oLC:CODIGO # "9999"
         nC := ROUND( oLC:CANTIDAD/aVD[8]*100,2 )
         oRpt:Say( oRpt:nL,46,TRANSFORM(nC,"9999.99%") )
      EndIf
      oRpt:Say( oRpt:nL  ,55,TRANSFORM(oLC:CANTIDAD,"99,999") )
      oRpt:Say( oRpt:nL++,64,TRANSFORM(oLC:VALOR   ,cPict ) )
      aVD[3]+= oLC:VALOR
      If oLC:GRUPO >= "5"
         aVD[4]+= If( oLC:CODIGO == "9999", 0, oLC:CANTIDAD )
         aVD[5]+= oLC:VALOR
      EndIf
   EndIf
   oLC:Skip(1):Read()
   oLC:xLoad()
   If (oLC:GRUPO # aVD[7] .OR. oLC:lEof) .AND. aVD[4] > 0
      oRpt:Say( oRpt:nL++,17,Replicate("=",62) )
      oRpt:Say( oRpt:nL  ,17,"TOTALES..............." )
      oRpt:Say( oRpt:nL  ,55,TRANSFORM(aVD[4],"99,999") )
      oRpt:Say( oRpt:nL++,64,TRANSFORM(aVD[5], cPict ) )
      oRpt:Say( oRpt:nL++,17,Replicate("=",62) )
      aVD[4] := aVD[5] := 0
   ElseIf oLC:CODIGO == "010 "
      oRpt:Say( oRpt:nL++,17,Replicate("=",62) )
   EndIf
   aVD[7] := oLC:GRUPO
EndDo
If (aVD[2]+aVD[3]) > 0
   aVD[4] := aVD[3] - aVD[1] + aVD[2]
   oRpt:Separator( 0,5 ) //5
   oRpt:Say( oRpt:nL++,38,"TOTAL VENTA..............."+NtChr(aVD[3],cPict) )
   oRpt:Say( oRpt:nL++,38,"TOTAL DESCUENTOS (-)......"+NtChr(aVD[1],cPict) )
   oRpt:Say( oRpt:nL++,38,"TOTAL I.V.A.     (+)......"+NtChr(aVD[2],cPict) )
   oRpt:Say( oRpt:nL++,64,Replicate("=",14) )
   oRpt:Say( oRpt:nL++,38,"TOTAL FACTURACION........."+NtChr(aVD[4],cPict) )
EndIf
oLC:Destroy()
oRpt:NewPage()
oRpt:End()
RETURN NIL

//3-----------------------------------//
METHOD ListaRes() CLASS TLVentas
   LOCAL oRpt, cCod, nC, nF, nK, nM, nT, cFntC, cFntN
   LOCAL aGT := ARRAY(19,11), aVT := ARRAY(17,03)
cCod  := If( ::aLS[7] == "C", "v.pcosto", "v.precioven + v.desmon" )
::aGT := ARRAY(17,12)
::cQry := "SELECT u.numfac, u.totaldes, u.totaliva, u.totalfac, n.grupo, "   +;
          "n.codigo, v.codart, v.fecfac, v.fecdev, v.indicador, v.cantidad, "+;
           cCod + ", u.autoriza "                      +;
          "FROM cadventa v, cadfactu u, cadclien n "   +;
          "WHERE u.optica  = v.optica"                 +;
           " AND u.numfac  = v.numfac"                 +;
           " AND u.tipo    = v.tipo"                   +;
           " AND u.optica  = [Optica]"                 +;
           " AND u.fechoy >= " + xValToChar( ::aLS[1] )+;
           " AND u.fechoy <= " + xValToChar( ::aLS[2] )+;
           " AND u.tipo    = " + xValToChar(oApl:Tipo) +;
           " AND u.indicador <> 'A'"                   +;
           " AND n.codigo_nit = u.codigo_nit ORDER BY u.numfac"
AEVAL(::aGT, { |x| AFILL( x,0 ) } )
AEVAL(  aGT, { |x| AFILL( x,"",1,3 ) } )
AEVAL(  aGT, { |x| AFILL( x, 0,4,8 ) } )
 ::NEW( 3,1 )
oApl:oEmp:Seek( {"orden_dato >= ",1},"orden_dato" )
If ::aLS[11] == 2
   ::LaserRes( aGT,aVT )
   RETURN NIL
ElseIf ::aLS[11] == 3
   ::ArmoExcel()
EndIf
While !oApl:oEmp:Eof()
   ::DatosRes( @aVT )
   If aVT[12,2] > 0
      nC := If( oApl:oEmp:ORDEN_DATO < 12, 1, 2 )
      If (nT := oApl:oEmp:RSV) == 0
         nT := LEN( aGT[1] ) + 1
         AEVAL( aGT, { |x| AADD( x,0 ), AADD( x,0 ) } )
         aGT[18,nT] := ::Armo()
      ElseIf ::aLS[11] == 1 .AND. ::aLS[9]
         aGT[18,nC] += ::Armo() + "  "
         aGT[19,nC] += REPLICATE("=",30) + "  "
      EndIf
      FOR nF := 1 TO 17
         If oApl:oEmp:RSV > 0 .AND. ::aLS[11] == 1 .AND. ::aLS[9]
            aGT[nF,nC] += ::Armo( aVT,nF )
         EndIf
         aGT[nF,04]   += aVT[nF,1]
         aGT[nF,05]   += aVT[nF,2]
         aGT[nF,nT]   += aVT[nF,1]
         aGT[nF,nT+1] += aVT[nF,2]
      NEXT nF
      If ::aLS[11] == 3
         If ::nF == 4 .AND. nC == 2
            ::nF += (::aLS[12] + 6)
            ::nC := 2
            ::ArmoExcel()
         EndIf
         If oApl:oEmp:RSV > 0
            ::ArmoExcel( aVT )
         EndIf
      EndIf
   EndIf
   oApl:oEmp:Skip(1):Read()
   oApl:oEmp:xLoad()
EndDo
oApl:nEmpresa := oApl:oEmp:OPTICA
aGT[18,04] := "----------TOTAL GENERAL-------"
aGT[18,06] := "----------TOTAL C.O.C.--------"  //RSV =  6
aGT[18,08] := "----------TOTAL GERDTS--------"  //RSV =  8
aGT[18,10] := "----------TOTAL PANORAMA------"  //RSV = 10
If ::aLS[11] == 1
   FOR nF := 1 TO ::aLS[12]
      nT := LEN( aGT[nF] )
      If nF >= 15
         aGT[nF,4] := ROUND( aGT[nF,5]/aGT[12,5]*100,2 )
         aGT[nF,6] := ROUND( aGT[nF,7]/aGT[12,7]*100,2 )
         aGT[nF,8] := ROUND( aGT[nF,9]/aGT[12,9]*100,2 )
      EndIf
      FOR nC := 4 TO nT STEP 2
         aGT[nF,03] += ::Armo( aGT,nF,nC )
         If nF == 17
            aGT[18,03] += aGT[18,nC] + "  "
            aGT[19,03] += REPLICATE("=",30) + "  "
         EndIf
      NEXT nC
   NEXT nF
   cFntC := CHR(27)+CHR(51)+CHR(33)        // n/216 ESC 3n
   cFntN := CHR(27)+CHR(50)                // 1/6   ESC 2 Normal
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,,::aLS[3],,2,73 )
   oRpt:nL := 3 ; oRpt:nPage := 1
   oRpt:SetFont( oRpt:CPINormal,82,2 )
   oRpt:Say( 1,00,oRpt:CPILarge + oRpt:CPIBold +;
              PADC( "RESUMEN DE VENTAS OPTICAS DEL GRUPO",43 ) )
   oRpt:Say( 2,00,"FEC.PROC:" + DTOC( DATE() ) )
   oRpt:Say( 2,24,"DESDE "+ NtChr(::aLS[1],"2")+ " HASTA "+ NtChr(::aLS[2],"2") )
   oRpt:Say( 2,62,"HORA: " + AmPm( TIME() ) )
   oRpt:SetFont( oRpt:cFontI+cFntC )
   ::aLV[12] := oRpt:CPIBold + ::aLV[12] + oRpt:CPIBoldN
   FOR nC := 1 TO 3
      oRpt:Say( oRpt:nL++,21,oRpt:CPIBold+aGT[18,nC]+oRpt:CPIBoldN )
      FOR nF := 1 TO ::aLS[12]
         If !EMPTY( aGT[nF,nC] )
            oRpt:Say( oRpt:nL++,01,::aLV[nF] + aGT[nF,nC] )
            If nF == 8 .OR. nF == 11 .OR. nF == 13
               oRpt:Say( oRpt:nL++,21,aGT[19,nC] )
            ElseIf nF == 14
               oRpt:nL ++
            EndIf
         EndIf
      NEXT nF
      oRpt:nL ++
   NEXT nC
   oRpt:NewPage()
   oRpt:End()
Else
   ::nF += (::aLS[12] + 6)
   ::nC := 2
   ::ArmoExcel()
   FOR nF := 1 TO ::aLS[12]
      nT := LEN( aGT[nF] )
      If nF >= 14
         aGT[nF,4] := ROUND( aGT[nF,5]/aGT[11,5]*100,2 )
         aGT[nF,6] := ROUND( aGT[nF,7]/aGT[11,7]*100,2 )
         aGT[nF,8] := ROUND( aGT[nF,9]/aGT[11,9]*100,2 )
      EndIf
      FOR nC := 4 TO nT STEP 2
         If nF == 1
            ::oRpt:Say( ::nF-1, ::nC, aGT[18,nC],,,,,, 7 )
            ::oRpt:Combinar( CHR( ::nC+64 ) + LTRIM(STR(::nF-1)) + ":" +;
                             CHR( ::nC+65 ) + LTRIM(STR(::nF-1)) )
         EndIf
         ::oRpt:Say( ::nF, ::nC  , aGT[nF,nC] )
         ::oRpt:Say( ::nF, ::nC+1, aGT[nF,nC+1] )
         If nF >= 14
            ::oRpt:CellFormat( ::nF, ::nC,,,"####.##" )
         EndIf
         ::nC += 2
      NEXT nC
      ::nF += If( Rango( nF,{7, 10, 12, 13} ), 2, 1 )
      ::nC := 2
   NEXT nF
   ::oRpt:Visualizar(.T.)
   ::oRpt:End(.F.) ; ::oRpt := NIL
EndIf
RETURN NIL

//------------------------------------//
METHOD Armo( aVT,nF,nC ) CLASS TLVentas
   LOCAL cVal := "", cPict
   DEFAULT nC := 1
If aVT == NIL
   cVal := TRIM(oApl:oEmp:LOCALIZ)
   If !IsAlpha( RIGHT( cVal,1 ) )
      nF := RAT( "-",oApl:oEmp:NOMBRE )
      cVal := ALLTRIM(SUBSTR( oApl:oEmp:NOMBRE,nF+1 ))
   EndIf
   If ::aLS[11] == 1
      cVal := PADC( cVal,30,"_" )
   EndIf
Else
   If nF <= 7
      cVal := ROUND( aVT[nF,nC+1]/aVT[9,nC+1]*100,2 )
      cPict:= TRANSFORM( aVT[nF,nC],"@Z 999,999" ) +;
              TRANSFORM( cVal      ,"@Z 999.99%" )
   ElseIf nF >= 15
      cPict:= SPACE(7) + TRANSFORM( aVT[nF,nC],"@Z 999.99%" )
   Else
      cPict:= SPACE(14)
   EndIf
   cVal := cPict + TRANSFORM( aVT[nF,nC+1]," 999,999,999,999" ) + "  "
/*
   cPict:= If( nF < 14, "@Z 999,999", "999.99%" )
   cVal += TRANSFORM( aVT[nF,nC]  ,cPict ) + " " +;
           TRANSFORM( aVT[nF,nC+1],"999,999,999,999" ) + "  "
*/
EndIf
RETURN cVal

//------------------------------------//
METHOD LaserRes( aGT,aVT ) CLASS TLVentas
   LOCAL nF, nL := 1, nC := 6
 ::aEnc := { .t.,"RESUMEN DE VENTAS OPTICAS DEL GRUPO",;
             "DESDE "+NtChr( ::aLS[1],"2" )+ " HASTA " + NtChr( ::aLS[2],"2" ),;
             3.0,11.0 }
 ::Init( ::aEnc[2], .f. ,, !::aLS[3] ,,,, 5 )
 ::SetLandscape()
   PAGE
While !oApl:oEmp:Eof()
   ::DatosRes( @aVT )
   If aVT[12,3] > 0
      ::Saltar( @nC,@nL,25 )
      FOR nF := 1 TO ::aLS[12]
         If ::nLinea == ::aEnc[ nL+3 ]
            UTILPRN ::oUtil Self:nLinea,nC+4.0 SAY PADC( ::aLS[13],29,"_" ) FONT ::aFnt[6] RIGHT
            ::nLinea += 0.32
         EndIf
         If nC == 6
            UTILPRN ::oUtil Self:nLinea,01.2   SAY ::aLV[nF]
         EndIf
            UTILPRN ::oUtil Self:nLinea,nC     SAY TRANSFORM(aVT[nF,1], "@Z 999,999" )     RIGHT
            UTILPRN ::oUtil Self:nLinea,nC+1.4 SAY TRANSFORM(aVT[nF,2], "@Z 999.99%" )     RIGHT
            UTILPRN ::oUtil Self:nLinea,nC+4.0 SAY TRANSFORM(aVT[nF,3],"999,999,999,999" ) RIGHT
         If nF == 8 .OR. nF == 11 .OR. nF == 13
            ::nLinea += 0.32
            UTILPRN ::oUtil Self:nLinea,nC+4.0 SAY REPLICATE("=",29) RIGHT
         ElseIf nF == 14
            ::nLinea += 0.32
         EndIf
            ::nLinea += 0.32
      NEXT nF
      nC += 5.5
   EndIf
   oApl:oEmp:Skip(1):Read()
   oApl:oEmp:xLoad()
EndDo
   If nC > 6
      ::nLinea := { 3.0,11.0,3.0 }[ nL+1 ]
   EndIf
   ::Saltar( @nC,@nL,7 )
   UTILPRN ::oUtil Self:nLinea,10.0 SAY PADC( "TOTAL GENERAL" ,29,"-" ) FONT ::aFnt[6] RIGHT
   UTILPRN ::oUtil Self:nLinea,15.5 SAY PADC( "TOTAL C.O.C."  ,29,"-" ) FONT ::aFnt[6] RIGHT
   UTILPRN ::oUtil Self:nLinea,21.0 SAY PADC( "TOTAL GERDTS"  ,29,"-" ) FONT ::aFnt[6] RIGHT
   UTILPRN ::oUtil Self:nLinea,26.5 SAY PADC( "TOTAL PANORAMA",29,"-" ) FONT ::aFnt[6] RIGHT
           ::nLinea += 0.32
FOR nF := 1 TO ::aLS[12]
      UTILPRN ::oUtil Self:nLinea,01.2   SAY ::aLV[nF]
   FOR nL := 1 TO 12 STEP 3
      If nF <= 7
         ::aGT[nF,nL+1] := ROUND(::aGT[nF,nL+2] /::aGT[09,nL+2]* 100,2 )
      ElseIf nF >= 15
         ::aGT[nF,nL+1] := ROUND(::aGT[nF,nL+2] /::aGT[12,nL+2]* 100,2 )
      EndIf
      UTILPRN ::oUtil Self:nLinea,nC     SAY TRANSFORM(::aGT[nF,nL]  , "@Z 999,999" )     RIGHT
      UTILPRN ::oUtil Self:nLinea,nC+1.4 SAY TRANSFORM(::aGT[nF,nL+1], "@Z 999.99%" )     RIGHT
      UTILPRN ::oUtil Self:nLinea,nC+4.0 SAY TRANSFORM(::aGT[nF,nL+2],"999,999,999,999" ) RIGHT
      nC += 5.5
   NEXT nL
   nC := 6
   If nF == 8 .OR. nF == 11 .OR. nF == 13
      ::nLinea += 0.32
      UTILPRN ::oUtil Self:nLinea,10.0 SAY REPLICATE("=",29) RIGHT
      UTILPRN ::oUtil Self:nLinea,15.5 SAY REPLICATE("=",29) RIGHT
      UTILPRN ::oUtil Self:nLinea,21.0 SAY REPLICATE("=",29) RIGHT
      UTILPRN ::oUtil Self:nLinea,26.5 SAY REPLICATE("=",29) RIGHT
   ElseIf nF == 14
      ::nLinea += 0.32
   EndIf
      ::nLinea += 0.32
NEXT nF
   ENDPAGE
IMPRIME END .F.
RETURN NIL

//------------------------------------//
METHOD Saltar( nC,nL,nMax ) CLASS TLVentas
If nC >= nMax
   If ::nLinea > 10
      ::nLinea += If( ::nLinea > 18, ::nEndLine, 0.32 )
      ::aEnc[1] := ::Separator( 0.32,1 )
      nC := 6
      nL := If( nL == 1, 2, 1 )
   EndIf
EndIf
   ::nLinea := ::aEnc[ nL+3 ]
If ::aEnc[1]
   ::aEnc[1] := .F.
   ::Centrar( ::aEnc[2],::aFnt[4],1.0 )
   ::Centrar( ::aEnc[3],::aFnt[2],1.5 )
   ::FechaHora( ,,20 )
   ::nLinea  := 3.00
   UTILPRN ::oUtil SELECT ::aFnt[5]
EndIf
RETURN NIL

//------------------------------------//
METHOD DatosRes( aVT ) CLASS TLVentas
   LOCAL aRes, cCod, nC, nF, nM, nK := 0
 aRes := STRTRAN( ::cQry,"[Optica]",LTRIM(STR(oApl:oEmp:OPTICA)) )
 ::hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
 ::nL   := MSNumRows( ::hRes )
 ::aLS[9] := !Rango( oApl:oEmp:RSV,{8,10} )
 AEVAL( aVT, { |x| AFILL( x,0 ) } )
While ::nL > 0
   aRes := MyReadRow( ::hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   cCod := TRIM( aRes[07] )
   nC   := If( LEFT(DTOS(aRes[08]),6) <= LEFT(DTOS(aRes[09]),6) .AND.;
               aRes[10] == "D", 0, aRes[11] )
   nF   := aRes[12] * If( ::aLS[7] == "C" .AND. oApl:oEmp:OPTICA # 0, nC, 1 )
   do Case
   Case cCod == "0599000001" .OR. LEFT(cCod,2) = "01" // Montura
      nM := 1
      If LEFT(cCod,2) == "01"
         nM := If( Buscar( "SELECT tipomontu FROM cadinven WHERE codigo = '"+;
                           cCod + "'","CM",,8,,1 ) == "S", 2, 1 )
      EndIf
      aVT[nM,1] += If( cCod == "0599000001", 0, nC )
      aVT[nM,3] += nF
   Case cCod == "0599000002" .OR. LEFT(cCod,2) = "02" // Oftalmicos
      aVT[03,1] += If( SUBSTR(cCod,4,1) $ "12", nC, 0 )
      aVT[03,3] += nF
   Case LEFT(cCod,2) >= "60" .OR. ;
             cCod = "0599000003" .OR. ;
             cCod = "0504"
      aVT[04,1] += If( LEFT(cCod,2) = "05", 0, nC )
      aVT[04,3] += nF
   Case LEFT(cCod,2) = "03"                  // Liquidos
      aVT[05,1] += aRes[11]
      aVT[05,3] += nF
   Case LEFT(cCod,2) = "04"                  // Accesorios
      aVT[06,1] += aRes[11]
      aVT[06,3] += nF
   Case LEFT(cCod,4) = "0501"                // Consultas
      aVT[07,1] += aRes[11]
      aVT[07,3] += nF
   OtherWise                                 // Varios
      aVT[08,3] += nF
   EndCase
      aVT[09,3] += nF
   ::nL --
   If nK  # aRes[01]
      nK := aRes[01]
      nC := If( aRes[05] .OR. aRes[13] == "GRUPO     ", 16,;
            If( aRes[06] > 0, 17, 15 ) )
      aVT[10,3] +=  aRes[02] //TOTALDES
      aVT[13,3] +=  aRes[03] //TOTALIVA
      aVT[12,3] +=  aRes[04] //TOTALFAC
      aVT[nC,3] += (aRes[04] - aRes[03])
   EndIf
EndDo
MSFreeResult( ::hRes )
If ::aLS[7] == "P"
   aRes := DsctoDevol( {" = " + LTRIM(STR(oApl:oEmp:OPTICA)),::aLS[1],::aLS[2]} )
   aVT[11,3] := aRes[1] + aRes[2] + aRes[3] + aRes[4]
   aVT[15,3] -= aRes[1]
   aVT[16,3] -= aRes[2]
   aVT[17,3] -= aRes[3] + aRes[4]
EndIf
   //TOTALFAC
If aVT[12,3] > 0
   aVT[12,3] := aVT[09,3] - aVT[10,3] - aVT[11,3]
   aVT[14,3] := aVT[12,3] + aVT[13,3]
   AEVAL( aVT,{|x| aVT[09,1] += x[1] },1,7 )
   nK := If( oApl:oEmp:RSV ==  8,  7,;
         If( oApl:oEmp:RSV == 10, 10, 4 ) )
   FOR nF := 1 TO ::aLS[12]
      ::aGT[nF, 1]   += aVT[nF,1]
      ::aGT[nF, 2]   += aVT[nF,2]
      ::aGT[nF, 3]   += aVT[nF,3]
      ::aGT[nF,nK]   += aVT[nF,1]
      ::aGT[nF,nK+1] += aVT[nF,2]
      ::aGT[nF,nK+2] += aVT[nF,3]
      If nF <= 7
         aVT[nF,2] := ROUND( aVT[nF,3] / aVT[9,3] * 100,2 )
      ElseIf nF >= 15
         aVT[nF,2] := ROUND( aVT[nF,3] / aVT[12,3]* 100,2 )
      EndIf
   NEXT nF
   ::aLS[13] := TRIM(oApl:oEmp:LOCALIZ)
   If !IsAlpha( RIGHT( ::aLS[13],1 ) )
      nF := RAT( "-",oApl:oEmp:NOMBRE )
      ::aLS[13] := ALLTRIM(SUBSTR( oApl:oEmp:NOMBRE,nF+1 ))
   EndIf
   If ::aLS[11] == 1
      ::aLS[13] := PADC( ::aLS[13],30,"_" )
   EndIf
   If oApl:oEmp:RSV ==  8
      aVT[12,3] := 0
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD ArmoExcel( aVT,nF,nC ) CLASS TLVentas

If aVT == NIL
   If ::oRpt == NIL
         aVT := cFilePath( GetModuleFileName( GetInstance() )) + "Test1.xls"
      ::oRpt := TExcelScript():New()
      ::oRpt:Create( aVT )
      ::oRpt:Font("Arial")
      ::oRpt:Size(10)
      ::oRpt:ColumnWidth( 1 , 25.00 )
      ::oRpt:Align(1)
      ::oRpt:Visualizar(.F.)
      ::oRpt:Say(  1, 1, "RESUMEN DE VENTAS OPTICAS DEL GRUPO" )
      ::oRpt:Say(  2, 2, "DESDE "+ NtChr(::aLS[1],"2")+ " HASTA "+ NtChr(::aLS[2],"2") )
      ::nF := 5
      ::nC := 2
   EndIf
   nF := ::nF
   FOR nC := 1 TO ::aLS[12]
      ::oRpt:Say( nF, 1, ::aLV[nC] )
      nF += If( Rango( nC,{7, 10, 12, 13} ), 2, 1 )
   NEXT nC
Else
   nF := ::nF
//Say( nRow, nCol, xValue, cFont, nSize, lBold, lItalic, lUnderLine, nAlign, nColor, nFondo, nOrien, nStyle, cFormat )
      ::oRpt:Say( nF-1, ::nC, ::Armo(),,,,,, 7 )
      ::oRpt:Combinar( CHR( ::nC+64 ) + LTRIM(STR(nF-1)) + ":" +;
                       CHR( ::nC+65 ) + LTRIM(STR(nF-1)) )
   FOR nC := 1 TO ::aLS[12]
      ::oRpt:Say( nF, ::nC  , aVT[nC,1] )
      ::oRpt:Say( nF, ::nC+1, aVT[nC,2] )
      If nC >= 14
         ::oRpt:CellFormat( nF, ::nC,,,"####.##" )
      EndIf
      nF += If( Rango( nC,{7, 10, 12, 13} ), 2, 1 )
   NEXT nC
   ::nC += 2
EndIf
RETURN NIL