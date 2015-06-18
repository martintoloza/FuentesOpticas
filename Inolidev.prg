// Programa.: CAOLIVED.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Devoluciones a Bodega.
#include "FiveWin.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE InoLiDev( nOpc,aLS )
   LOCAL aDB, oDlg, oLF, oGet := ARRAY(12)
   DEFAULT nOpc := 1
If VALTYPE( nOpc ) == "L"
   nOpc:= If( nOpc, 2, 1 )
EndIf
oLF := TLDevol()
aDB := { { {|| oLF:ListoDev() },"Listar Devoluciones a Bodega" },;
         { {|| oLF:ListoTra() },"Listar Traslados a Opticas" } }
If aLS # NIL
   oLF:aLS := ACLONE( aLS )
   EVAL( aDB[nOpc,1] )
   RETURN
EndIf
oLF:aLS := { "   ",NtChr( LEFT( DTOS(DATE()),6 ),"F" ),DATE(),"C",oApl:nUS,0,;
             "N",.f.,oApl:nTFor,.f. }
DEFINE DIALOG oDlg TITLE aDB[nOpc,2] FROM 0, 0 TO 16,50
   @ 02, 00 SAY "Optica" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02, 92 GET oGet[1] VAR oLF:aLS[1] OF oDlg PICTURE "@!" ;
      VALID EVAL( {|| If( EMPTY( oLF:aLS[1] ), .t.         ,;
                     (If( oApl:oEmp:Seek( {"localiz",oLF:aLS[1]} ),;
                      (nEmpresa( .t. ), .t. )           ,;
                      (MsgStop("Esta Optica NO EXISTE"), .f.) ))) } );
      SIZE 24,10 PIXEL
   @ 14, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 14, 92 GET oGet[2] VAR oLF:aLS[2] OF oDlg  SIZE 44,10 PIXEL
   @ 26, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 26, 92 GET oGet[3] VAR oLF:aLS[3] OF oDlg ;
      VALID oLF:aLS[3] >= oLF:aLS[2] SIZE 44,10 PIXEL
   @ 38, 00 SAY "A PRECIO COSTO O PUBLICO" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 38, 92 GET oGet[4] VAR oLF:aLS[4] OF oDlg PICTURE "!" ;
      VALID If( oLF:aLS[4] $ "CP", .t., .f. )   SIZE 08,10 PIXEL
   @ 50, 00 SAY          "VALOR DEL DOLAR" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 50, 92 GET oGet[5] VAR oLF:aLS[5] OF oDlg PICTURE "9,999" SIZE 44,10 PIXEL
   @ 62, 00 SAY  "DOCUMENTO Default Todos" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 62, 92 GET oGet[6] VAR oLF:aLS[6] OF oDlg PICTURE "999999" SIZE 44,10 PIXEL;
      WHEN nOpc == 1 .AND. !EMPTY( oLF:aLS[1] )
   @ 74, 00 SAY   "DEVOLUCIONES SEPARADAS" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 74, 92 GET oGet[7] VAR oLF:aLS[7] OF oDlg PICTURE "!" ;
      VALID If( oLF:aLS[7] $ "SN", .t., .f. )   SIZE 08,10 PIXEL
   @ 74,140 CHECKBOX oGet[8] VAR oLF:aLS[8] PROMPT "Nota Credito" OF oDlg;
      SIZE 60,10 PIXEL
   @ 86, 00 SAY "TIPO DE IMPRESORA"    OF oDlg RIGHT PIXEL SIZE 86,10
   @ 86, 92 COMBOBOX oGet[09] VAR oLF:aLS[9] ITEMS { "Matriz","Laser" };
      SIZE 40,90 OF oDlg PIXEL
   @ 86,140 CHECKBOX oGet[10] VAR oLF:aLS[10] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 104, 50 BUTTON oGet[11] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[11]:Disable(), EVAL( aDB[nOpc,1] ), oGet[11]:Enable(),;
        oGet[11]:oJump := oGet[2], oGet[2]:SetFocus() ) PIXEL
   @ 104,100 BUTTON oGet[12] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 110, 02 SAY "[INOLIDEV]" OF oDlg PIXEL SIZE 30,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
CLASS TLDevol FROM TIMPRIME

 DATA aLS

 METHOD ListoDev()
 METHOD LaserDev( hRes,nL )
 METHOD ListoTra()
 METHOD LaserTra( aGT,hRes,nL )
 METHOD Grupo()
ENDCLASS

//------------------------------------//
METHOD ListoDev() CLASS TLDevol
   LOCAL oRpt, aDV, aTD, lOK, nG, nL
   LOCAL cOpt, cQry, aRes, hRes
cQry := "SELECT c.optica, c.documen, c.consedev, c.fechad, "      +;
               "c.nombre, d.codigo, d.cantidad, d.causadev, "     +;
               "d.pcosto, d.numrep, d.destino, i.moneda, "        +;
               "i.compra_d, i.descrip, i.ppubli, c.codigo_nit "   +;
        "FROM cadinven i, caddevod d, caddevoc c "                +;
        "WHERE i.codigo  = d.codigo"                              +;
         " AND c.optica  = d.optica"                              +;
         " AND c.documen = d.documen"  +        If( ::aLS[8]      ,;
         " AND d.causadev = 2", "" )                              +;
         " AND d.indica <> 'B'"        + If( EMPTY( ::aLS[1] ), "",;
         " AND c.optica  = " + LTRIM(STR(oApl:nEmpresa)) )        +;
         " AND c.fechad >= " + xValToChar( ::aLS[2] )             +;
         " AND c.fechad <= " + xValToChar( ::aLS[3] ) + If( ::aLS[6] > 0,;
         " AND c.documen = " + LTRIM(STR(::aLS[6])), "" )         +;
         " ORDER BY c.consedev"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
 ::aLS[6] := 0
 ::aLS[7] := If( EMPTY( ::aLS[1] ), "S", ::aLS[7] )
If (nL := MSNumRows( hRes )) == 0
   MsgStop( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[9] == 2
   ::LaserDev( hRes,nL )
   RETURN NIL
EndIf
   cQry := If( ::aLS[4] == "C", "COSTO", "PUBLI" )
If MONTH(::aLS[2]) == MONTH(::aLS[3])
   cOpt := "EN " + NtChr( ::aLS[2],"6" )
Else
   cOpt := "DESDE "+ NtChr( ::aLS[2],"2" )+ " HASTA "+ NtChr( ::aLS[3],"2" )
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"DEVOLUCIONES A "       +;
         If( oApl:nEmpresa == 0, "PROVEEDOR", "BODEGA" ),cOpt,;
         " DOCUMEN CONSEC.   FECHA   C O D I G O-  D E S C R I P C I O N---"+;
         "------------  CANT.  PREC."+cQry + "   C A U S A" },::aLS[10],,2 )
   aDV  := ::Grupo()
   aTD  := Buscar( {"clase","Devolucion"},"cadcausa","LEFT(nombre,11)",2,"tipo" )
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
While nL > 0
   cQry := Grupos( aRes[06] )
   lOK  := If( ::aLS[8] .AND. (aRes[13] .OR. cQry $ "26"), .f., .t. )
   If lOK
      cOpt := If( aRes[8] >= 6, "Fac."+STR(aRes[10]),;
              If( aRes[8]  # 4 .AND. (aRes[12] == "C" .OR. aRes[13] .OR. aRes[16] # 123), "PRV",;
              If( aRes[8]  # 5, ArrayValor( oApl:aOptic,STR(aRes[11],2) ), "" )))
      If ::aLS[6]  # aRes[3]
         ::aLS[6] := aRes[3]
         oApl:oEmp:Seek( {"optica",aRes[1]} )
         oApl:cEmpresa := ALLTRIM( oApl:oEmp:NOMBRE )
         If ::aLS[1] == "1" .AND. !EMPTY(aRes[5])
            oRpt:aEnc[2] := "PRUEBA A: " + aRes[5]
         EndIf
         oRpt:Titulo( 113 )
         oRpt:Say( oRpt:nL,00,STR(aRes[2],7) + "-" + STRZERO(aRes[3],7) )
         oRpt:Say( oRpt:nL,16,aRes[4] )
      Else
         oRpt:Titulo( 113 )
      EndIf
      aRes[9] := Dolar_Peso( ::aLS[5],If( ::aLS[4] == "C", aRes[9],aRes[15] ),aRes[12] )
      oRpt:Say( oRpt:nL,27,aRes[06] )
      oRpt:Say( oRpt:nL,41,aRes[14] )
      oRpt:Say( oRpt:nL,77,TRANSFORM(aRes[7], "99,999") )
      oRpt:Say( oRpt:nL,85,TRANSFORM(aRes[9],"999,999,999") )
      oRpt:Say( oRpt:nL,98,aTD[ aRes[8] ] + " " + cOpt )
      oRpt:nL++
      nG := { 1,1,2,3,4,5,5,6 }[ aRes[8] ] +;
             If( cQry == "1" .AND. aRes[12] == "C", 6,;
             If( cQry == "1" .AND. aRes[13], 12, 0 ))
      cOpt := cQry+STR(nG,2)
      If (nG := ASCAN( aDV, {|aVal| aVal[1] == cOpt } )) > 0
         aDV[nG,3] +=  aRes[7]
         aDV[nG,4] += (aRes[7] * aRes[9])
      EndIf
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. (::aLS[6] # aRes[3] .AND. ::aLS[7] == "S")
      nG := 0
      AEVAL( aDV, { | e | nG += If( e[3] > 0, 1, 0 ) } )
      oRpt:Separator( 0,nG,113 )
      FOR nG := 1 TO LEN( aDV )
         If aDV[nG,3] > 0
            oRpt:Say(++oRpt:nL,46,aDV[nG,2] + TRANSFORM( aDV[nG,3],"999,999" ) )
            oRpt:Say(  oRpt:nL,85,TRANSFORM( aDV[nG,4],"999,999,999" ) )
         EndIf
         aDV[nG,3] := aDV[nG,4] := 0
      NEXT nG
      oRpt:NewPage()
      oRpt:nPage := 0
      oRpt:nL    := oRpt:nLength + 1
   EndIf
EndDo
MSFreeResult( hRes )
oRpt:End()
::aLS[6] := 0
oApl:oEmp:Seek( {"optica",oApl:nEmpresa} )
oApl:cEmpresa := ALLTRIM( oApl:oEmp:NOMBRE )
RETURN NIL

//------------------------------------//
METHOD LaserDev( hRes,nL ) CLASS TLDevol
   LOCAL aDV, aTD, aRes, cOpt, cQry, lOK, nG
aDV  := ::Grupo()
aTD  := Buscar( {"clase","Devolucion"},"cadcausa","LEFT(nombre,11)",2,"tipo" )
aRes := MyReadRow( hRes )
AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:NIT ,"DEVOLUCIONES A "+;
             If( oApl:nEmpresa == 0, "PROVEEDOR", "BODEGA" ),""  ,;
             { .T., 1.8,"NUMERO" }   , { .T., 3.2,"CONSEC" }     ,;
             { .F., 3.5,"F E C H A" }, { .F., 5.2,"C O D I G O" },;
             { .F., 7.0,"NOMBRE DEL ARTICULO" },;
             { .T.,14.8,"CANTIDAD" } , { .T.,16.8,"Precio " },;
             { .F.,17.0,"C A U S A" } }
If MONTH(::aLS[2]) == MONTH(::aLS[3])
   ::aEnc[5] := "EN " + NtChr( ::aLS[2],"6" )
Else
   ::aEnc[5] := "DESDE "+ NtChr( ::aLS[2],"2" )+ " HASTA "+ NtChr( ::aLS[3],"2" )
EndIf
::aEnc[12,3]+= If( ::aLS[4] == "C", "Costo", "Público" )
 ::Init( ::aEnc[4], .f. ,, !::aLS[10] ,,, ::aLS[10], 5 )
 ::nMD := 20.5
  PAGE
While nL > 0
   cQry := Grupos( aRes[06] )
   lOK  := If( ::aLS[8] .AND. (aRes[13] .OR. cQry $ "26"), .f., .t. )
   If lOK
      cOpt := If( aRes[8] >= 6, "Fac."+STR(aRes[10]),;
              If( aRes[8]  # 4 .AND. (aRes[12] == "C" .OR. aRes[13] .OR. aRes[16] # 123), "PRV",;
              If( aRes[8]  # 5, ArrayValor( oApl:aOptic,STR(aRes[11],2) ), "" )))
      aRes[9] := Dolar_Peso( ::aLS[5],If( ::aLS[4] == "C", aRes[9],aRes[15] ),aRes[12] )
      If ::aLS[6]  # aRes[3]
         ::aLS[6] := aRes[3]
         oApl:oEmp:Seek( {"optica",aRes[1]} )
            ::aEnc[2] := ALLTRIM( oApl:oEmp:NOMBRE )
            ::aEnc[3] :=          oApl:oEmp:NIT
         If ::aLS[1] == "1" .AND. !EMPTY(aRes[5])
            ::aEnc[5] := "PRUEBA A: " + aRes[5]
         EndIf
         ::Cabecera( .t.,0.42,0 )
         UTILPRN ::oUtil Self:nLinea,1.8 SAY     STR(aRes[2],7) RIGHT
         UTILPRN ::oUtil Self:nLinea,3.1 SAY STRZERO(aRes[3],7) RIGHT
         UTILPRN ::oUtil Self:nLinea,3.3 SAY NtChr( aRes[4],"2" )
      Else
         ::Cabecera( .t.,0.42,0 )
      EndIf
      UTILPRN ::oUtil Self:nLinea, 5.2 SAY aRes[06]
      UTILPRN ::oUtil Self:nLinea, 7.0 SAY aRes[14]
      UTILPRN ::oUtil Self:nLinea,14.8 SAY TRANSFORM( aRes[7],     "99,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,16.8 SAY TRANSFORM( aRes[9],"999,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,17.0 SAY aTD[ aRes[8] ] + " " + cOpt
      nG := { 1,1,2,3,4,5,5,6 }[ aRes[8] ] +;
             If( cQry == "1" .AND. aRes[12] == "C", 6,;
             If( cQry == "1" .AND. aRes[13], 12, 0 ))
      cOpt := cQry+STR(nG,2)
      If (nG := ASCAN( aDV, {|aVal| aVal[1] == cOpt } )) > 0
         aDV[nG,3] +=  aRes[7]
         aDV[nG,4] += (aRes[7] * aRes[9])
      EndIf
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. (::aLS[6] # aRes[3] .AND. ::aLS[7] == "S")
      nG := 0.40
      AEVAL( aDV, { | e | nG += If( e[3] > 0, 0.42, 0 ) } )
      ::Cabecera( .t.,0.40,nG,20.5 )
      FOR nG := 1 TO LEN( aDV )
         If aDV[nG,3] > 0
            UTILPRN ::oUtil Self:nLinea, 8.0 SAY aDV[nG,2]
            UTILPRN ::oUtil Self:nLinea,14.8 SAY TRANSFORM(aDV[nG,3],    "999,999" ) RIGHT
            UTILPRN ::oUtil Self:nLinea,16.8 SAY TRANSFORM(aDV[nG,4],"999,999,999" ) RIGHT
            ::nLinea += 0.42
         EndIf
         aDV[nG,3] := aDV[nG,4] := 0
      NEXT nG
      ::nLinea := ::nEndLine
   EndIf
EndDo
MSFreeResult( hRes )
  ENDPAGE
 ::EndInit( .F. )
 ::aLS[6] := 0
RETURN NIL

//------------------------------------//
METHOD ListoTra() CLASS TLDevol
   LOCAL cQry, hRes, nG, nL, oRpt
   LOCAL aGT := ARRAY( 2,5 ), aRes := If( ::aLS[4] == "C", "d.PCOSTO", "i.PPUBLI" )
AEVAL( aGT, {|x| AFILL( x,0 ) } )
::aLS[6]:= 0
cQry := "SELECT d.documen, d.fechad, d.optica, c.despub, d.codigo, i.descrip,"+;
              " d.cantidad, " + aRes + ", i.grupo, i.moneda " +;
        "FROM caddevod d, caddevoc c, cadinven i "     +;
        "WHERE d.destino = "+ LTRIM(STR(oApl:nEmpresa))+;
         " AND d.fechad >= " + xValToChar( ::aLS[2] )  +;
         " AND d.fechad <= " + xValToChar( ::aLS[3] )  +;
         " AND d.causadev = 4 AND d.indica <> 'B'"     +;
         " AND c.optica  = d.optica"                   +;
         " AND c.documen = d.documen"                  +;
         " AND i.codigo  = d.codigo ORDER BY d.fechad, d.documen"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgStop( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[9] == 2
   ::LaserTra( aGT,hRes,nL )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"T R A S L A D O S","EN "+ NtChr( ::aLS[2],"6" ),;
         "DOCUMEN  F E C H A VIENE DE   %     C O D I G O- D E S C R I P "+;
         "C I O N--------------  CANT.   PREC." + RIGHT(aRes,5) },::aLS[10],,2 )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[8]:= Dolar_Peso( ::aLS[5],aRes[8],aRes[10] )
   nG     := { 0,1,3,4,5 }[AT( aRes[9],"1346")+1]
   oRpt:Titulo( 104 )
   If ::aLS[6]  # aRes[1]
      ::aLS[6] := aRes[1]
      oRpt:Say( oRpt:nL,00,STR(aRes[1],7) )
      oRpt:Say( oRpt:nL,08,aRes[2] )
      oRpt:Say( oRpt:nL,21,ArrayValor( oApl:aOptic,STR(aRes[3],2) ) )
      oRpt:Say( oRpt:nL,27,TRANSFORM(aRes[4],"@Z 999.99") )
   EndIf
   oRpt:Say( oRpt:nL,36,aRes[5] )
   oRpt:Say( oRpt:nL,49,aRes[6] )
   oRpt:Say( oRpt:nL,86,TRANSFORM(aRes[7],"9,999") )
   oRpt:Say( oRpt:nL,93,TRANSFORM(aRes[8],"999,999,999") )
   oRpt:nL++
   If nG > 0
      aGT[1,nG] +=  aRes[7]
      aGT[2,nG] += (aRes[7] * aRes[8])
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
   oRpt:Separator( 0,4,104 )
   oRpt:Say(++oRpt:nL,65,"TOTAL MONTURAS" )
   oRpt:Say(  oRpt:nL,85,TRANSFORM(aGT[1,1],     "99,999") )
   oRpt:Say(  oRpt:nL,93,TRANSFORM(aGT[2,1],"999,999,999") )
   oRpt:Say(++oRpt:nL,65,"TOTAL LIQUIDOS" )
   oRpt:Say(  oRpt:nL,85,TRANSFORM(aGT[1,3],     "99,999") )
   oRpt:Say(  oRpt:nL,93,TRANSFORM(aGT[2,3],"999,999,999") )
   oRpt:Say(++oRpt:nL,65,"TOTAL ACCESORIOS" )
   oRpt:Say(  oRpt:nL,85,TRANSFORM(aGT[1,4],     "99,999") )
   oRpt:Say(  oRpt:nL,93,TRANSFORM(aGT[2,4],"999,999,999") )
   oRpt:Say(++oRpt:nL,65,"TOTAL L.CONTACTO" )
   oRpt:Say(  oRpt:nL,85,TRANSFORM(aGT[1,5],     "99,999") )
   oRpt:Say(  oRpt:nL,93,TRANSFORM(aGT[2,5],"999,999,999") )
   oRpt:NewPage()
   oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserTra( aGT,hRes,nL ) CLASS TLDevol
   LOCAL aRes, nG
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:NIT ,"T R A S L A D O S"  ,;
             "EN "+ NtChr( ::aLS[2],"6" ),;
             { .T., 1.8,"NUMERO" }       , { .F., 2.2,"F E C H A" }  ,;
             { .F., 3.9,"VIENE DE    %" }, { .F., 6.2,"C O D I G O" },;
             { .F., 8.0,"NOMBRE DEL ARTICULO" },;
             { .T.,16.0,"CANTIDAD" }     , { .T.,18.0,"Precio " } }
::aEnc[12,3]+= If( ::aLS[4] == "C", "Costo", "Público" )
 ::Init( ::aEnc[4], .f. ,, !::aLS[10] ,,, ::aLS[10], 5 )
 ::nMD := 18.0
  PAGE
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[8] := Dolar_Peso( ::aLS[5],aRes[8],aRes[10] )
   nG      := { 0,1,3,4,5 }[AT( aRes[9],"1346")+1]
      ::Cabecera( .t.,0.42,0 )
   If ::aLS[6]  # aRes[1]
      ::aLS[6] := aRes[1]
      UTILPRN ::oUtil Self:nLinea, 1.8 SAY    STR(aRes[1],7) RIGHT
      UTILPRN ::oUtil Self:nLinea, 2.0 SAY NtChr( aRes[2],"2" )
      UTILPRN ::oUtil Self:nLinea, 4.0 SAY ArrayValor( oApl:aOptic,STR(aRes[3],2) )
      UTILPRN ::oUtil Self:nLinea, 6.0 SAY TRANSFORM(aRes[4],"@Z 999.99") RIGHT
   EndIf
      UTILPRN ::oUtil Self:nLinea, 6.2 SAY aRes[5]
      UTILPRN ::oUtil Self:nLinea, 8.0 SAY aRes[6]
      UTILPRN ::oUtil Self:nLinea,16.0 SAY TRANSFORM( aRes[7],     "99,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,18.0 SAY TRANSFORM( aRes[8],"999,999,999" ) RIGHT
   If nG > 0
      aGT[1,nG] +=  aRes[7]
      aGT[2,nG] += (aRes[7] * aRes[8])
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
      ::Cabecera( .t.,0.40,1.68,18.0 )
      UTILPRN ::oUtil Self:nLinea,11.5 SAY "TOTAL MONTURAS"
      UTILPRN ::oUtil Self:nLinea,16.0 SAY TRANSFORM( aGT[1,1],     "99,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,18.0 SAY TRANSFORM( aGT[2,1],"999,999,999" ) RIGHT
      ::nLinea += 0.42
      UTILPRN ::oUtil Self:nLinea,11.5 SAY "TOTAL LIQUIDOS"
      UTILPRN ::oUtil Self:nLinea,16.0 SAY TRANSFORM( aGT[1,3],     "99,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,18.0 SAY TRANSFORM( aGT[2,3],"999,999,999" ) RIGHT
      ::nLinea += 0.42
      UTILPRN ::oUtil Self:nLinea,11.5 SAY "TOTAL ACCESORIOS"
      UTILPRN ::oUtil Self:nLinea,16.0 SAY TRANSFORM( aGT[1,4],     "99,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,18.0 SAY TRANSFORM( aGT[2,4],"999,999,999" ) RIGHT
      ::nLinea += 0.42
      UTILPRN ::oUtil Self:nLinea,11.5 SAY "TOTAL L.CONTACTO"
      UTILPRN ::oUtil Self:nLinea,16.0 SAY TRANSFORM( aGT[1,5],     "99,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,18.0 SAY TRANSFORM( aGT[2,5],"999,999,999" ) RIGHT
  ENDPAGE
 ::EndInit( .F. )
 ::aLS[6] := 0
RETURN NIL

//------------------------------------//
METHOD Grupo() CLASS TLDevol
   LOCAL aGru := {}, aRes, hRes, cQry, nL
cQry := "SELECT grupo, tipo, nombre FROM caddevol ORDER BY grupo, tipo"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
WHILE nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   AADD( aGru, { aRes[1]+STR(aRes[2],2),aRes[3],0,0 } )
   nL --
ENDDO
MSFreeResult( hRes )
RETURN aGru