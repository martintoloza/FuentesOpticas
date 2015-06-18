// Programa.: INOLIRSM.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Lista Inventario mensual por grupo
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE InoLiRsm( lResu )
   LOCAL oDlg, oGet := ARRAY(17), aGrup, aMone, aRep
   LOCAL aOpc := { 0,DATE(),1,"S",1,"N",DATE()-730,"N",1,0,0,.f.,.f.,SPACE(15) }
   LOCAL oNi  := TNits()
   DEFAULT lResu := .f.
If lResu
   aRep := { {|| ListoRsm( aOpc,aGrup ) },"Resumen del Inventario",;
                 "RESUMEN [S/N]" }
Else
   aRep := { {|| ListoInv( aOpc,aGrup ) },"Listo Inventario Mensual",;
                 "MONTURAS VIEJAS [S/N]" }
EndIf
oNi:New()
aGrup := ArrayCombo( "GRUPO" )
aMone := ArrayCombo( "MONEDA" )
DEFINE DIALOG oDlg TITLE aRep[2] FROM 0, 0 TO 24,70
   @ 02, 00 SAY "NIT Proveedor" OF oDlg RIGHT PIXEL SIZE 110,10
   @ 02,112 BTNGET oGet[1] VAR aOpc[1] OF oDlg PICTURE "9999999999";
      ACTION EVAL({|| If(oNi:Mostrar(), (aOpc[1] := oNi:oDb:CODIGO,;
                        oGet[1]:Refresh() ),) })                   ;
      VALID EVAL( {|| If( oNi:Buscar( aOpc[1],"codigo",.t. )      ,;
                        ( oDlg:Update(), .t. )                    ,;
                   (MsgStop("Este Proveedor no Existe"), .f.) ) } );
      WHEN !lResu  SIZE 44,12 PIXEL RESOURCE "BUSCAR"
   @ 02,158 SAY oGet[17] VAR oNi:oDb:NOMBRE OF oDlg PIXEL SIZE 96,10;
      UPDATE COLOR nRGB( 128,0,255 )
   @  16, 00 SAY "FECHA DESEADA [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 110,10
   @  16,112 GET oGet[2] VAR aOpc[2] OF oDlg SIZE 44,12 PIXEL
   @  30, 00 SAY "RECUPERA PAGINA DESDE LA" OF oDlg RIGHT PIXEL SIZE 110,10
   @  30,112 GET oGet[3] VAR aOpc[3] OF oDlg PICTURE "###";
      VALID Rango( aOpc[3],1,999 )          SIZE 20,12 PIXEL
   @  44, 00 SAY   "CON PRECIO COSTO [S/N]" OF oDlg RIGHT PIXEL SIZE 110,10
   @  44,112 GET oGet[4] VAR aOpc[4] OF oDlg PICTURE "!";
      VALID If( aOpc[4] $ "NS", .t., .f. )  SIZE 08,12 PIXEL
   @  44,130 SAY                   "MONEDA" OF oDlg RIGHT PIXEL SIZE  48,10
   @  44,180 COMBOBOX oGet[5] VAR aOpc[5] ITEMS ArrayCol( aMone,1 ) SIZE 50,99 ;
      OF oDlg PIXEL
   @  58, 00 SAY    "ESCOJA &GRUPO DESEADO" OF oDlg RIGHT PIXEL SIZE 110,10
   @  58,112 COMBOBOX oGet[6] VAR aOpc[9] ITEMS ArrayCol( aGrup,1 ) SIZE 50,99 ;
      OF oDlg PIXEL
   @  72, 00 SAY       "MARCA DEL PRODUCTO" OF oDlg RIGHT PIXEL SIZE 110,10
   @  72,112 GET oGet[7] VAR aOpc[14] OF oDlg PICTURE "@!" SIZE 70,12 PIXEL
   @  86, 00 SAY     aRep[3]                OF oDlg RIGHT PIXEL SIZE 110,10
   @  86,112 GET oGet[8] VAR aOpc[6] OF oDlg PICTURE "!";
      VALID If( aOpc[6] $ "NS", .t., .f. )  SIZE 08,12 PIXEL
   @ 100, 00 SAY "FECHA MONTURAS VIEJAS [-2 AÑOS]" OF oDlg RIGHT PIXEL SIZE 110,08
   @ 100,112 GET oGet[9] VAR aOpc[7] OF oDlg SIZE 44,12 PIXEL;
      WHEN aOpc[6] == "S" .AND. !lResu
   @ 114, 00 SAY "LISTO LA FECHA DE INGRESO [S/N]" OF oDlg RIGHT PIXEL SIZE 110,10
   @ 114,112 GET oGet[10] VAR aOpc[8] OF oDlg PICTURE "!";
      VALID If( aOpc[8] $ "NS", .t., .f. )              ;
      WHEN oApl:nEmpresa > 0 .AND. !lResu  SIZE 08,12 PIXEL
   @ 128, 00 SAY   "PRECIO DE COSTO MENOR IGUAL A" OF oDlg RIGHT PIXEL SIZE 110,10
   @ 128,112 GET oGet[11] VAR aOpc[11] OF oDlg PICTURE "999,999,999";
      VALID aOpc[11] >= 0 SIZE 44,12 PIXEL ;
      WHEN aOpc[9] == 1 .AND. !lResu
   @ 142, 00 SAY   "PRECIO DE COSTO MAYOR IGUAL A" OF oDlg RIGHT PIXEL SIZE 110,10
   @ 142,112 GET oGet[12] VAR aOpc[10] OF oDlg PICTURE "999,999,999";
      VALID aOpc[10] >= 0 SIZE 44,12 PIXEL ;
      WHEN aOpc[9] == 1 .AND. !lResu
   @ 128,180 CHECKBOX oGet[13] VAR aOpc[13] PROMPT "Etiquetas" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 142,180 CHECKBOX oGet[14] VAR aOpc[12] PROMPT "Vista &Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 160, 70 BUTTON oGet[15] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( aOpc[05] := aMone[aOpc[5],2], aOpc[14] := If( EMPTY( aOpc[14] ) ,;
              "", " AND i.descrip LIKE '" + ALLTRIM( aOpc[14] ) + "%'" ),;
        oGet[15]:Disable(),  EVAL( aRep[1] ), oDlg:End() ) PIXEL
   @ 160,120 BUTTON oGet[16] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 166, 02 SAY "[INOLIRSM]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
STATIC PROCEDURE ListoInv( aLS,aG )
   LOCAL oRpt, aGT, aRes, hRes, cQry, nL, nK
cQry  := UPPER(TRIM(aG[aLS[9],1])) + ;
         { ""," CARTIER"," EN CONSIGNACION" }[AT( aLS[5]," UC" )] + ;
         If( aLS[6] == "S", " VIEJAS", "" )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"INVENTARIO DE " + cQry,NtChr( aLS[2],"3" ),;
         SPACE(72)+"---PRECIO--- ---PRECIO---       ---PRECIO--- NUMERO --FECHA-",;
         "C O D I G O- PROVEEDOR--- ---MARCA---- REFERENCIA------- TAMANO MAT SE"+;
         "X ---COSTO---- ---VENTA---- CANT. ---PUBLICO-- DOCUME --RECIBO" },;
         aLS[12],aLS[3],2 )
If aLS[13]
   aGT := { { "VITRINA","C", 3,0 },{ "CODIGO","C",12,0 },{ "VALOR","C",11,0 } }
   BorraFile( "CODIGOS",{"DBF","N0","PXX","IXX"} )
   dbCREATE( oApl:cRuta2+"CODIGOS",aGT )
   If !AbreDbf( "Tem","CODIGOS",,,.f. )
      MsgInfo( "NO SE PUEDEN CREAR CODIGOS" ) ; RETURN
   EndIf
EndIf
aGT  := { 0,0,0,0,0,"","","s.codigo"  }
If oApl:nEmpresa == 0 .OR. aLS[8] == "S"
   aLS[8] := {|| aRes[12]+ " " +DTOC(aRes[13]) }
   aGT[8] := "n.nombre, s.codigo"
   cQry   := "i.factupro, i.fecrecep "
Else
   aLS[8] := {|| STR(aRes[12],6)+ " " +DTOC(aRes[13]) }
   cQry   := "i.numrepos, " + If( aLS[9] == 1, "i.fecrepos ", "s.fec_ulte " )
EndIf
If aLS[9] == 1
   If aLS[11]  < aLS[10]
      nK      := aLS[11]
      aLS[11] := aLS[10] ; aLS[10] := nK
   EndIf
   If aLS[10] + aLS[11] > 0
      aGT[6] := " AND s.pcosto >= " + LTRIM(STR(aLS[10])) + ;
                " AND s.pcosto <= " + LTRIM(STR(aLS[11]))
   EndIf
   aGT[7] := " AND i.moneda = '" + aLS[5] + "'" + If( aLS[6] == "S",;
             " AND i.fecrecep <= " + xValToChar( aLS[7] ), "" )
EndIf
cQry := "SELECT s.codigo, n.nombre, i.descrip, i.marca, i.tamano, i.material"+;
             ", i.sexo, s.pcosto, i.pventa, s.existencia, i.ppubli, " + cQry +;
        "FROM cadinvme s, cadinven i, cadclien n "                           +;
        "WHERE s.optica = " + LTRIM(STR(oApl:nEmpresa))  +    If( aLS[9] == 5,;
    " AND LEFT(s.codigo,2) >= '60' AND LEFT(s.codigo,2) <= '99'"             ,;
    " AND LEFT(s.codigo,2) = '" + { "01","03","04","05" }[aLS[9]] + "'" )    +;
         " AND s.anomes = (SELECT MAX(m.anomes) FROM cadinvme m "            +;
                          "WHERE m.optica = s.optica"                        +;
                           " AND m.codigo = s.codigo"                        +;
                           " AND m.anomes <= '" + NtChr( aLS[2],"1" ) + "')" +;
         " AND s.existencia <> 0"   + aGT[6]                                 +;
         " AND i.codigo = s.codigo" + aGT[7] + aLS[14]   + If( aLS[1]  > 0   ,;
         " AND i.codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT)), "" )     +;
         " AND n.codigo_nit = i.codigo_nit  ORDER BY " + aGT[8]
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      oRpt:Titulo( 134 )
   If oRpt:nPage >= oRpt:nPagI
      If aLS[9] == 1
         //nK   := If( aRes[4] == 0, 1, aRes[4]+2 )
         aRes[3] := PADR( LEFT(aRes[03],aRes[04]),12 )+;
                  " " + SUBSTR(aRes[03],aRes[4]+2)
         oRpt:Say( oRpt:nL, 04,RIGHT(aRes[01],8) )
      Else
         oRpt:Say( oRpt:nL, 00,aRes[01] )
      EndIf
      oRpt:Say( oRpt:nL, 13,aRes[02],12 )
      oRpt:Say( oRpt:nL, 26,aRes[03],30 )
      oRpt:Say( oRpt:nL, 57,aRes[05] )
      oRpt:Say( oRpt:nL, 65,aRes[06] )
      oRpt:Say( oRpt:nL, 69,aRes[07] )
      If aLS[4] == "S"
         oRpt:Say( oRpt:nL, 71,TRANSFORM(aRes[08],"99,999,999.99") )
         aGT[2] += (aRes[08] * aRes[10])
      EndIf
      oRpt:Say( oRpt:nL, 84,TRANSFORM(aRes[09],"99,999,999.99") )
      oRpt:Say( oRpt:nL, 98,TRANSFORM(aRes[10],"9,999") )
      oRpt:Say( oRpt:nL,105,TRANSFORM(aRes[11],"999,999,999") )
      oRpt:Say( oRpt:nL,117,EVAL( aLS[8] ) )
      oRpt:nL++
   EndIf
   aGT[1] ++
   aGT[3] += (aRes[09] * aRes[10])
   aGT[4] +=  aRes[10]
   aGT[5] += (aRes[11] * aRes[10])
   If aLS[13]
      Tem->(dbAppend())
      Tem->CODIGO := aRes[01]
      Tem->VALOR  := TRANSFORM(aRes[11],"999,999,999")
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
If aLS[13]
   Tem->(dbCloseArea())
EndIf
If aGt[1] > 0
   oRpt:Say( oRpt:nL++, 00,REPLICATE("_",134) )
   oRpt:Say( oRpt:nL  , 01,TRANSFORM(aGT[1],"9,999") )
   oRpt:Say( oRpt:nL  , 69,TRANSFORM(aGT[2],"999,999,999.99" ) )
   oRpt:Say( oRpt:nL  , 83,TRANSFORM(aGT[3],"999,999,999.99" ) )
   oRpt:Say( oRpt:nL  , 98,TRANSFORM(aGT[4],"99999" ) )
   oRpt:Say( oRpt:nL++,105,TRANSFORM(aGT[5],"999,999,999" ) )
   oRpt:Say( oRpt:nL  , 00,REPLICATE("_",134) )
EndIf
oRpt:NewPage()
oRpt:End()
RETURN

//------------------------------------//
STATIC PROCEDURE ListoRsm( aLS,aG )
   LOCAL oRpt, oLC, aGT, cPer, nC, nK := DAY(aLS[2])
   LOCAL aRes, hRes, nL, cQry, aTI := ARRAY(2,9)
If aLS[6] == "S"  //Resumen
   oLC := oApl:Abrir( "contacto","grupo, codigo" )
   oLC:dbEval( {|o| o:CANTIDAD := o:VALOR := 0, o:Update( .f.,1 ) } )
EndIf
AEVAL( aTI, { |x| AFILL( x,0 ) } )
cPer  := UPPER(TRIM(aG[aLS[9],1])) + ;
         { ""," CARTIER"," EN CONSIGNACION" }[AT( aLS[5]," UC" )]
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"INVENTARIO MENSUAL DE " + cPer,;
         NtChr( aLS[2],"3" ),SPACE(36) +;
         "EXISTENCIA     TOTAL        TOTAL   DEVOLUCION  DEVOLUCION     AJUSTE      AJUSTE  DEVOLUCION     SALDO ",;
         "C O D I G O- -----DESCRIPCION-----  MES ANTER.    ENTRADAS      VENTAS"+;
         "   ENTRADAS     SALIDAS     ENTRADAS     SALIDAS   CLIENTE      ACTUAL"},;
         aLS[12],aLS[3],2 )
cPer := NtChr( aLS[2],"1" )
cQry := "SELECT s.codigo, i.descrip, s.entradas, s.salidas, s.devol_e, s.devol_s, "+;
        "s.ajustes_e, s.ajustes_s, s.devolcli, s.existencia, s.pcosto, s.anomes, i.grupo "+;
        "FROM cadinvme s, cadinven i "                                    +;
        "WHERE s.optica = " + LTRIM(STR(oApl:nEmpresa)) +  If( aLS[9] == 5,;
    " AND LEFT(s.codigo,2) >= '60' AND LEFT(s.codigo,2) <= '99'"          ,;
    " AND LEFT(s.codigo,2) = '" + { "01","03","04","05" }[aLS[9]] + "'" ) +;
         " AND s.anomes = (SELECT MAX(m.anomes) FROM cadinvme m "         +;
                          "WHERE m.optica = s.optica"                     +;
                           " AND m.codigo = s.codigo"                     +;
                           " AND m.anomes <= '" + cPer + "')"             +;
         " AND (s.existencia <> 0 OR s.anomes = '" + cPer + "')"          +;
         " AND i.codigo = s.codigo"                     +  If( aLS[9] == 1,;
         " AND i.moneda = '" + aLS[5] + "'", "" )                         +;
         " ORDER BY s.codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
cQry := NtChr( aLS[2] - nK,"1" )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aRes[12] == cPer
      aGT := { 0,aRes[03],aRes[04],aRes[05],aRes[06],aRes[07],aRes[08],;
                 aRes[09],aRes[10],aRes[11],0 }
      aGT[01] := SaldoInv( aRes[01],cQry,1 )
      aGT[11] := oApl:aInvme[2]  // Pcosto Anterior
      aRes[02]:= LEFT( aRes[2],22 ) +;
                 If( oApl:aInvme[5] == cQry .AND. aGT[10] # aGT[11], " *", "  " )
   Else
      aGT := { aRes[10],0,0,0,0,0,0,0,aRes[10],aRes[11],aRes[11] }
   EndIf
   nK := 0
   AEVAL( aGT, { | nV,nP | nC := If( nP # 1, aGT[10], aGT[11] ),;
                           If( nV # 0, nK ++, ),;
                           aTI[1][nP] +=  nV   ,;
                           aTI[2][nP] += (nV * nC) },1,9 )
   If nK > 0
      If aLS[6] == "S"
         aRes[1] := LEFT( aRes[1],4 )
         If !oLC:Seek( { "grupo",aRes[13],"codigo",aRes[1] } )
             oLC:GRUPO  := aRes[13] ; oLC:CODIGO := aRes[1]
             oLC:NOMBRE := aRes[02] ; oLC:Append( .t. )
         EndIf
         oLC:VALOR    += aGT[9] * aGT[10]
         oLC:CANTIDAD += aGT[9]     ; oLC:Update( .f.,1 )
      Else
            oRpt:Titulo( 141 )
         If oRpt:nPage >= oRpt:nPagI
            nC := aGT[1] + aGT[2] - aGT[3] + aGT[4] - aGT[5] + aGT[6] - aGT[7] + aGT[8]
            oRpt:Say( oRpt:nL, 00,aRes[1] )
            oRpt:Say( oRpt:nL, 13,aRes[2],24 )
            oRpt:Say( oRpt:nL, 38,TRANSFORM(aGT[1],   "999,999") )
            oRpt:Say( oRpt:nL, 50,TRANSFORM(aGT[2],"@Z 999,999") )
            oRpt:Say( oRpt:nL, 62,TRANSFORM(aGT[3],"@Z 999,999") )
            oRpt:Say( oRpt:nL, 74,TRANSFORM(aGT[4],"@Z 999,999") )
            oRpt:Say( oRpt:nL, 86,TRANSFORM(aGT[5],"@Z 999,999") )
            oRpt:Say( oRpt:nL, 98,TRANSFORM(aGT[6],"@Z 999,999") )
            oRpt:Say( oRpt:nL,110,TRANSFORM(aGT[7],"@Z 999,999") )
            oRpt:Say( oRpt:nL,122,TRANSFORM(aGT[8],"@Z 999,999") )
            oRpt:Say( oRpt:nL,134,TRANSFORM(aGT[9],"999,999") )
            oRpt:Say( oRpt:nL,142,If( nC  # aGT[9], "X", "" ) )
            If aLS[9] # 1
               aGT[1] *= aGT[11]
               AEVAL( aGT, { |nV,nP| aGT[nP] *= aGT[10] },2,8 )
               oRpt:nL ++
               oRpt:Say( oRpt:nL, 18,TRANSFORM(aGT[10],"99,999,999.99") )
               oRpt:Say( oRpt:nL, 34,TRANSFORM(aGT[1],   "999,999,999") )
               oRpt:Say( oRpt:nL, 46,TRANSFORM(aGT[2],"@Z 999,999,999") )
               oRpt:Say( oRpt:nL, 58,TRANSFORM(aGT[3],"@Z 999,999,999") )
               oRpt:Say( oRpt:nL, 70,TRANSFORM(aGT[4],"@Z 999,999,999") )
               oRpt:Say( oRpt:nL, 82,TRANSFORM(aGT[5],"@Z 999,999,999") )
               oRpt:Say( oRpt:nL, 94,TRANSFORM(aGT[6],"@Z 999,999,999") )
               oRpt:Say( oRpt:nL,106,TRANSFORM(aGT[7],"@Z 999,999,999") )
               oRpt:Say( oRpt:nL,118,TRANSFORM(aGT[8],"@Z 999,999,999") )
               oRpt:Say( oRpt:nL,130,TRANSFORM(aGT[9],   "999,999,999") )
            EndIf
         EndIf
         oRpt:nL ++
      EndIf
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
cPer := "999,999" ; cQry := "999,999,999"
If oRpt:nPage > 0
   oRpt:Say( oRpt:nL++, 00,REPLICATE("_",141) )
   oRpt:Separator( 0,3 )
   oRpt:Say( oRpt:nL  , 00,"TOTAL UNIDADES" )
   oRpt:Say( oRpt:nL  , 38,TRANSFORM(aTI[1][1],cPer) )
   oRpt:Say( oRpt:nL  , 50,TRANSFORM(aTI[1][2],cPer) )
   oRpt:Say( oRpt:nL  , 62,TRANSFORM(aTI[1][3],cPer) )
   oRpt:Say( oRpt:nL  , 74,TRANSFORM(aTI[1][4],cPer) )
   oRpt:Say( oRpt:nL  , 86,TRANSFORM(aTI[1][5],cPer) )
   oRpt:Say( oRpt:nL  , 98,TRANSFORM(aTI[1][6],cPer) )
   oRpt:Say( oRpt:nL  ,110,TRANSFORM(aTI[1][7],cPer) )
   oRpt:Say( oRpt:nL  ,122,TRANSFORM(aTI[1][8],cPer) )
   oRpt:Say( oRpt:nL++,134,TRANSFORM(aTI[1][9],cPer) )
   oRpt:Say( oRpt:nL  , 34,TRANSFORM(aTI[2][1],cQry) )
   oRpt:Say( oRpt:nL  , 46,TRANSFORM(aTI[2][2],cQry) )
   oRpt:Say( oRpt:nL  , 58,TRANSFORM(aTI[2][3],cQry) )
   oRpt:Say( oRpt:nL  , 70,TRANSFORM(aTI[2][4],cQry) )
   oRpt:Say( oRpt:nL  , 82,TRANSFORM(aTI[2][5],cQry) )
   oRpt:Say( oRpt:nL  , 94,TRANSFORM(aTI[2][6],cQry) )
   oRpt:Say( oRpt:nL  ,106,TRANSFORM(aTI[2][7],cQry) )
   oRpt:Say( oRpt:nL  ,118,TRANSFORM(aTI[2][8],cQry) )
   oRpt:Say( oRpt:nL++,130,TRANSFORM(aTI[2][9],cQry) )
   oRpt:Say( oRpt:nL++, 00,REPLICATE("_",141) )
EndIf
If aLS[6] == "S"
   nK := nC := 0
   oRpt:Say( oRpt:nL+3, 12,"RESUMEN DE INVENTARIO POR PRODUCTO" )
   oRpt:nL += 5
   oLC:Seek( { "cantidad <> ",0 } )
   While !oLC:EOF()
      oRpt:Titulo( 78 )
      oRpt:Say( oRpt:nL  ,10,oLC:CODIGO )
      oRpt:Say( oRpt:nL  ,17,oLC:NOMBRE )
      oRpt:Say( oRpt:nL  ,55,TRANSFORM(oLC:CANTIDAD,cPer) )
      oRpt:Say( oRpt:nL++,64,TRANSFORM(oLC:VALOR   ,cQry) )
      nK += oLC:CANTIDAD
      nC += oLC:VALOR
      oLC:Skip(1):Read()
      oLC:xLoad()
   EndDo
   oRpt:Say(++oRpt:nL,17,"TOTAL UNIDADES" )
   oRpt:Say(  oRpt:nL,55,TRANSFORM(nK,cPer) )
   oRpt:Say(  oRpt:nL,64,TRANSFORM(nC,cQry) )
   oLC:Destroy()
EndIf
oRpt:NewPage()
oRpt:End()
RETURN