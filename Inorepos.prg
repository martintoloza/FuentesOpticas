// Programa.: INOREPOS.PRG     >>> Martin A. Toloza Lozano <<<
// Notas....: Pasa y Actualiza las Reposiciones e Ingresos
#include "FiveWin.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE InoRepos()
   LOCAL oDlg, oGet := ARRAY(4)
   LOCAL oA := TActurep()
DEFINE DIALOG oDlg TITLE "Pasa Reposiciones a Diskette" FROM 1, 2 TO 10,44
   @ 02,00 SAY "Fecha Inicial [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 02,82 GET oGet[1] VAR oA:aLS[1] OF oDlg SIZE 40,12 PIXEL
   @ 16,00 SAY "Fecha   Final [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 16,82 GET oGet[2] VAR oA:aLS[2] OF oDlg ;
      VALID oA:aLS[2] >= oA:aLS[1] SIZE 40,12 PIXEL
   @ 32,40 BUTTON oGet[3] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ;
      ACTION ( MsgRun( "Copiando CODIGOS","Por favor Espere",;
               { |oDlg| oA:CopioRep( oDlg ) } ), oDlg:End() ) PIXEL
   @ 32,90 BUTTON oGet[4] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 38,02 SAY "[INOREPOS]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//--Actualiza Reposiciones e Ingresos-//
PROCEDURE InoRepOp()
   LOCAL oA, oDlg, oGet := ARRAY(3)
oA := TActurep()
oA:aLS := { 0,CTOD(""),"",4,"FECREPOS",oA:NEW() }
If LEFT( oA:aLS[6],2 ) == "A:"
   MsgInfo( "Inserte el Diskette con las Reposiciones","POR FAVOR" )
EndIf
If !AbreDbf( "Tem","INVTEM",,oA:aLS[6] )
   RETURN
EndIf
MsgMeter( { | oMeter, oText, oDlg, lEnd | ;
            Revisar( oMeter,oText,oDlg,@lEnd,oA:aLS ) },;
            "A:INVTEM","Revisando" )
oA:aLS[4] := Tem->(LastRec())
Tem->(dbCloseArea())
DEFINE DIALOG oDlg TITLE "Actualiza Reposiciones" FROM 0, 0 TO 06,50
   @ 02,10 SAY oA:aLS[4] OF oDlg PIXEL SIZE 100,10
   @ 06, 50 BUTTON oGet[1] PROMPT "Actualizo" SIZE 44,12 OF oDlg ACTION;
      ( oGet[1]:Disable(), oA:ActuRepos( oDlg ), oDlg:End() ) PIXEL
   @ 06,100 BUTTON oGet[2] PROMPT "Cancelar"  SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 12,02 SAY "[INOREPOS]" OF oDlg PIXEL SIZE 32,10
   @ 30,10 SAY oGet[3] VAR oA:aLS[3] OF oDlg PIXEL SIZE 120,12 ;
      UPDATE COLOR nRGB( 128,0,255 )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
CLASS TActurep FROM TIMPRIME
 DATA aLS  AS ARRAY INIT { NtChr( LEFT( DTOS( DATE() ),6 ),"F" ),DATE() }
 DATA aRep AS ARRAY INIT {}

 METHOD NEW( cCodigo,nP,cO,nItem ) Constructor
 METHOD CopioRep( oDlg )
 METHOD GrabaTem( cCodigo,nMov,nCon,nOptica,cFactu,aR )
 METHOD ActuRepos( oDlg )
 METHOD CambiaMon( cCodi,nCanti,nMov,lCambio,nPC )
 METHOD CompraArt( oTB,cIndica )
 METHOD CompraMon( oTB,aRep )
 METHOD Devolucion( oTB,cIndica )
 METHOD DevolM( oTB,cCodi,nOpt,nCanti )
 METHOD Reposicion( oTB,cIndica )
 METHOD Ajustes( oTB,cIndica,nMov )
ENDCLASS

//------------------------------------//
METHOD NEW( cCodigo,nP,cO,nItem ) CLASS TActurep
   LOCAL xRut
If nP  # NIL
   cCodigo += STR(Tem->NUMREPOS,7)
   If (nP := ASCAN( ::aRep, {|aX| aX[1] == cCodigo } )) == 0
       AADD( ::aRep, { cCodigo,cO,0,0 } )
       nP := LEN( ::aRep )
   EndIf
   ::aRep[nP,4] += Tem->CANTIDAD
ElseIf cCodigo == NIL
   xRut := AbrirFile( 4,,"INVTEM.DBF" )
   If (cCodigo := RAT( "\", xRut )) > 0
      xRut := LEFT( xRut,cCodigo )
   Else
      xRut := "A:"
   EndIf
ElseIf !oApl:oInv:Seek( {"codigo",cCodigo} )
   xRut := { "",0,CTOD(""),0 }
   If Tem->GRUPO == "1"
      If Tem->OPTICA > 0
         xRut := { "",0,Tem->FECREPOS,Tem->NUMREPOS }
      EndIf
      xRut[1] := ALLTRIM( Tem->MARCA ) + " "
      xRut[2] := LEN( xRut[1] ) - 1
   EndIf
      xRut[1] += Tem->DESCRIP
   oApl:oInv:OPTICA    := Tem->OPTICA    ; oApl:oInv:CODIGO    := ALLTRIM(cCodigo)
   oApl:oInv:GRUPO     := Tem->GRUPO     ; oApl:oInv:DESCRIP   := xRut[1]
   oApl:oInv:CODIGO_NIT:= Tem->CODIGO_NIT; oApl:oInv:MARCA     := xRut[2]
   oApl:oInv:TAMANO    := Tem->TAMANO    ; oApl:oInv:MATERIAL  := Tem->MATERIAL
   oApl:oInv:SEXO      := Tem->SEXO      ; oApl:oInv:TIPOMONTU := Tem->TIPOMONTU
   oApl:oInv:FECRECEP  := Tem->FECRECEP  ; oApl:oInv:FECREPOS  := xRut[3]
   oApl:oInv:NUMREPOS  := xRut[4]        ; oApl:oInv:INGRESO   := Tem->INGRESO
   oApl:oInv:PCOSTO    := Tem->PCOSTO    ; oApl:oInv:PVENTA    := Tem->PVENTA
   oApl:oInv:PPUBLI    := Tem->PPUBLI    ; oApl:oInv:FACTUPRO  := Tem->FACTUPRO
   oApl:oInv:SITUACION := "E"            ; oApl:oInv:IDENTIF   := Tem->IDENTIF
   oApl:oInv:LOC_ANTES := Tem->LOC_ANTES ; oApl:oInv:INDIVA    := Tem->INDIVA
   oApl:oInv:DESPOR    := Tem->IMPUESTO  ; oApl:oInv:MONEDA    := Tem->MONEDA
   oApl:oInv:COMPRA_D  := Tem->COMPRA_D  ; oApl:oInv:PAQUETE   := Tem->PAQUETE
   oApl:oInv:Append(.f.)
   xRut := ""
EndIf
RETURN xRut

//------------------------------------//
METHOD CopioRep( oDlg ) CLASS TActurep
   LOCAL aRes, hRes, cCod, cFile, cQry, nL
Diccionario( "INVTEM",1 )
If !AbreDbf( "Tem","INVTEM",,,.f. )
   MsgInfo( "NO SE PUEDEN CREAR CODIGOS" )
   RETURN NIL
EndIf
oDlg:cMsg := "4_Monturas Nuevas"
oDlg:Refresh() ; SysRefresh()
cQry := "SELECT c.optica, c.fecingre, c.ingreso, c.codigo_nit, d.pcosto, "+;
               "d.cantidad, d.secuencia, d.material, d.consec, d.row_id " +;
        "FROM cadmontd d, comprasc c "                 +;
        "WHERE d.indica    = 'A'"                      +;
         " AND c.ingreso   = d.ingreso"                +;
         " AND c.fecingre >= " + xValToChar( ::aLS[1] )+;
         " AND c.fecingre <= " + xValToChar( ::aLS[2] )+;
         " AND c.cgeconse  > 0"                        +;
         " AND c.moneda   <> 'X' ORDER BY c.ingreso"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   cCod := "010" + If( aRes[8] == "P", "1", "2" ) + aRes[9]
   cQry := "UPDATE cadmontd SET indica = 'E' WHERE row_id = " + LTRIM(STR(aRes[10]))
   ::GrabaTem( cCod,4,VAL(aRes[9]),aRes[1],"",;
           { aRes[2],aRes[3],aRes[5],aRes[6],aRes[7],"",aRes[4],0,0,0,cQry } )
   nL --
EndDo
MSFreeResult( hRes )

oDlg:cMsg := "1_Reposiciones"
oDlg:Refresh() ; SysRefresh()
cQry := "SELECT c.optica, c.fecharep, c.numrep, c.numfac, d.codigo, d.pcosto" +;
          ", d.cantidad, d.secuencia, d.indica, d.row_id, c.despor, c.despub "+;
        "FROM cadrepod d, cadrepoc c "                 +;
        "WHERE d.indica   <> 'E'"                      +;
         " AND c.numrep    = d.numrep"                 +;
         " AND c.fecharep >= " + xValToChar( ::aLS[1] )+;
         " AND c.fecharep <= " + xValToChar( ::aLS[2] )+;
         " ORDER BY c.numrep"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   cQry := If( aRes[9] == "B", "DELETE FROM cadrepod",;
               "UPDATE cadrepod SET indica = 'E'" ) +;
           " WHERE row_id = " + LTRIM(STR(aRes[10]))
   ::GrabaTem( aRes[5],1,0,aRes[1],"",;
           { aRes[2],aRes[3],aRes[6],aRes[7],aRes[8],aRes[9],aRes[4],0,aRes[11],aRes[12],cQry } )
   nL --
EndDo
MSFreeResult( hRes )

oDlg:cMsg := "2_Ingresos LC.Liq.Acces"
oDlg:Refresh() ; SysRefresh()
cQry := "SELECT c.optica, c.fecingre, c.ingreso, c.codigo_nit, c.factura, "+;
         "d.codigo, d.pcosto, d.cantidad, d.secuencia, d.indica, d.row_id "+;
        "FROM cadartid d, comprasc c "                 +;
        "WHERE d.indica   <> 'E'"                      +;
         " AND c.ingreso   = d.ingreso"                +;
         " AND c.fecingre >= " + xValToChar( ::aLS[1] )+;
         " AND c.fecingre <= " + xValToChar( ::aLS[2] )+;
         " AND c.cgeconse  > 0"                        +;
         " AND c.moneda    = 'X' ORDER BY c.ingreso"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   cQry := If( aRes[10] == "B", "DELETE FROM cadartid",;
               "UPDATE cadartid SET indica = 'E'" ) +;
           " WHERE row_id = " + LTRIM(STR(aRes[11]))
   ::GrabaTem( aRes[6],2,0,aRes[1],aRes[5],;
           { aRes[2],aRes[3],aRes[7],aRes[8],aRes[9],aRes[10],aRes[4],0,0,0,cQry } )
   nL --
EndDo
MSFreeResult( hRes )

oDlg:cMsg := "3_Devoluciones y Traslados"
oDlg:Refresh() ; SysRefresh()
cQry := "SELECT d.destino, d.fechad, d.documen, c.consedev, d.codigo, d.pcosto, d.cantidad, "+;
                 "d.secuencia, d.indica, d.numrep, d.optica, d.causadev, c.despub, d.row_id "+;
        "FROM caddevod d, caddevoc c "               +;
        "WHERE d.indica <> 'E'"                      +;
         " AND c.optica  = d.optica"                 +;
         " AND c.documen = d.documen"                +;
         " AND c.fechad >= " + xValToChar( ::aLS[1] )+;
         " AND c.fechad <= " + xValToChar( ::aLS[2] )+;
        " ORDER BY c.consedev, d.secuencia"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   cQry := If( aRes[9] == "B", "DELETE FROM caddevod",;
               "UPDATE caddevod SET indica = 'E'" )  +;
           " WHERE row_id = " + LTRIM(STR(aRes[14]))
   ::GrabaTem( aRes[5],3,aRes[4],aRes[1],"",;
           { aRes[2],aRes[3],aRes[6],aRes[7],aRes[8],aRes[9],aRes[10],aRes[11],aRes[12],aRes[13],cQry } )
   nL --
EndDo
MSFreeResult( hRes )

oDlg:cMsg := "5_Ajustes"
oDlg:Refresh() ; SysRefresh()
cQry := "SELECT optica, fecha, numero, codigo, pcosto, "+;
            "cantidad, secuencia, indica, tipo, row_id "+;
        "FROM cadajust "                           +;
        "WHERE indica <> 'E'"                      +;
         " AND fecha  >= " + xValToChar( ::aLS[1] )+;
         " AND fecha  <= " + xValToChar( ::aLS[2] )+;
         " ORDER BY optica, numero, secuencia"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   cQry := If( aRes[8] == "B", "DELETE FROM cadajust",;
               "UPDATE cadajust SET indica = 'E'" )  +;
           " WHERE row_id = " + LTRIM(STR(aRes[10]))
   ::GrabaTem( aRes[4],5,0,aRes[1],"",;
           { aRes[2],aRes[3],aRes[5],aRes[6],aRes[7],aRes[8],0,0,aRes[9],0,cQry } )
   nL --
EndDo
MSFreeResult( hRes )

hRes := Tem->(LastRec())
Tem->(dbCloseArea())
If hRes > 0
   aRes := ""
   AEVAL( ::aRep, { | xV,nP | aRes += ArrayValor( oApl:aOptic,STR(xV,2) ) + ", " } )
   cQry := oApl:cRuta2 + "INVTEM.DBF"
   cCod := 1
   MsgGet( aRes,"Cantidad de COPIAS",@cCod )
   cFile:= ::NEW() + "INVTEM.DBF"
   FOR nL := 1 TO cCod
      If MsgYesNo( "Inserte en la Unidad DISKETTE #"+STR(nL,2),">>> Por Favor <<<" )
         COPY FILE &(cQry) TO &(cFile)
      EndIf
   NEXT nL
EndIf
RETURN NIL

//-1_FecRepos,2_NumRepos,3_Pcosto,4_Cantidad,5_Secuencia,6_Indica,8_LocAntes
METHOD GrabaTem( cCodigo,nMov,nCon,nOptica,cFactu,aR ) CLASS TActurep
   LOCAL nMarca
oApl:oInv:Seek( {"codigo",cCodigo} )
nMarca := If( oApl:oInv:GRUPO == "1", oApl:oInv:MARCA+2, 1 )

Tem->(dbAppend())
Tem->OPTICA    := nOptica            ; Tem->CODIGO    := cCodigo
Tem->GRUPO     := oApl:oInv:GRUPO    ; Tem->CODIGO_NIT:= oApl:oInv:CODIGO_NIT
Tem->DESCRIP   := SUBSTR( oApl:oInv:DESCRIP,nMarca )
Tem->MARCA     :=   LEFT( oApl:oInv:DESCRIP,oApl:oInv:MARCA )
Tem->TAMANO    := oApl:oInv:TAMANO   ; Tem->MATERIAL  := oApl:oInv:MATERIAL
Tem->SEXO      := oApl:oInv:SEXO     ; Tem->TIPOMONTU := oApl:oInv:TIPOMONTU
Tem->FECRECEP  := oApl:oInv:FECRECEP ; Tem->FECREPOS  := aR[1]
Tem->NUMREPOS  := aR[2]              ; Tem->INGRESO   := oApl:oInv:INGRESO
Tem->PCOSTO    := aR[3]              ; Tem->PVENTA    := oApl:oInv:PVENTA
Tem->PPUBLI    := oApl:oInv:PPUBLI   ; Tem->IDENTIF   := oApl:oInv:IDENTIF
Tem->FACTUPRO  := If( nMov == 2, cFactu, oApl:oInv:FACTUPRO )
Tem->LOC_ANTES := If( nMov == 4, oApl:oInv:LOC_ANTES, aR[8] )
Tem->INDIVA    := oApl:oInv:INDIVA   ; Tem->IMPUESTO  := oApl:oInv:DESPOR
Tem->MONEDA    := oApl:oInv:MONEDA   ; Tem->COMPRA_D  := oApl:oInv:COMPRA_D
Tem->PAQUETE   := oApl:oInv:PAQUETE  ; Tem->CANTIDAD  := aR[4]
Tem->SECUENCIA := aR[5]              ; Tem->INDICA    := aR[6]
Tem->NUMFAC    := aR[7]              ; Tem->MOV       := nMov
Tem->CONSEDEV  := nCon               ; Tem->DESPUB    := aR[10]
//nMov = 1_Reposicion, 2_Ingresos, 3_Traslados, 4_Compras Monturas, 5_Ajustes
If nMov == 1
   Tem->DESPOR   := aR[9]
Else
   Tem->CAUSADEV := aR[9]
EndIf
MSQuery( oApl:oMySql:hConnect,aR[11] )
If nOptica # 0 .AND. nOptica # 4
   If ASCAN( ::aRep, nOptica ) == 0
       AADD( ::aRep, nOptica )
   EndIf
EndIf

RETURN NIL

//------------------------------------//
METHOD ActuRepos( oDlg ) CLASS TActurep
   LOCAL aRep, nL, oTB := ARRAY(9), cTemp := oApl:cRuta2 + "INVTEM.DBF"
   LOCAL cOri := ::aLS[6] + "INVTEM.DBF"
COPY FILE &(cOri) TO &(cTemp)
If !AbreDbf( "Tem","INVTEM" )
   RETURN NIL
EndIf
oTB[1] := oApl:Abrir( "cadrepoc","numrep",.t.,,5 )
oTB[2] := oApl:Abrir( "cadrepod","numrep",.t.,,5 )
oTB[3] := oApl:Abrir( "comprasc","ingreso",.t.,,5 )
oTB[4] := oApl:Abrir( "cadartid","ingreso",.t.,,5 )
oTB[5] := oApl:Abrir( "caddevoc","optica, documen",.t.,,5 )
oTB[6] := oApl:Abrir( "caddevod","optica, documen",.t.,,5 )
oTB[7] := oApl:Abrir( "cadmontd","ingreso",.t.,,5 )
oTB[8] := oApl:Abrir( "cadajust","optica, numero",.t.,,5 )
oTB[9] := Buscar( {"clase","Devolucion"},"cadcausa","movto",2,"tipo" )

oApl:oEmp:Seek( {"optica",0} )
cTemp:= oApl:oEmp:TITULAR
aRep := { oApl:oEmp:NUMREP,oApl:oEmp:NUMINGRESO,0,0,oApl:nEmpresa,;
          If( cTemp == "COC", .t., .f. ),oApl:oEmp:CONSEDEV,0, }
oApl:oEmp:Seek( {"localiz",cTemp} )
aRep[8] := oApl:oEmp:AJUSTES

oDlg:SetText( "<< ESPERE >> ACTUALIZANDO REPOSICIONES " + cTemp )
Tem->(dbGoTop())
While !Tem->(EOF())
   aRep[3] += Tem->CANTIDAD
   aRep[4] ++
   aRep[9] := If( Tem->OPTICA == oApl:oEmp:OPTICA .OR. aRep[6], .t., .f. )
   ::aLS[3] := Tem->CODIGO + STR(aRep[4])
   oDlg:Update()
   oApl:nEmpresa := Tem->OPTICA
   ::NEW( Tem->CODIGO )
   do Case
   Case Tem->MOV == 1 .AND. aRep[9]
      aRep[1] := MAX( Tem->NUMREPOS,aRep[1] )
      ::Reposicion( oTB,Tem->INDICA )
   Case Tem->MOV == 2 .AND. aRep[9]
      aRep[2] := MAX( Tem->NUMREPOS,aRep[2] )
      ::CompraArt( oTB,Tem->INDICA )
   Case Tem->MOV == 3 .AND. aRep[9]
      aRep[7] := MAX( Tem->CONSEDEV,aRep[7] )
      ::Devolucion( oTB,Tem->INDICA )
   Case Tem->MOV == 4 .AND. oApl:oEmp:ENLINEA
      aRep[2] := MAX( Tem->NUMREPOS,aRep[2] )
      ::CompraMon( oTB,aRep )
   Case Tem->MOV == 5 .AND. aRep[9]
      aRep[8] := MAX( Tem->NUMREPOS,aRep[8] )
      ::Ajustes( oTB,Tem->INDICA )
   EndCase
   Tem->(dbSkip())
EndDo
AEVAL( oTB, { |o| o:Destroy() },1,8 )
Tem->(dbCloseArea())
cTemp := STRTRAN( cOri,".DBF",".ULT" )
ERASE  &(cTemp)
RENAME &(cOri) TO &(cTemp)
aRep[7] := MAX( SgteNumero( "CONSEDEV",0,.f. ),aRep[7] )
cTemp := "UPDATE cadempre SET consedev = " + LTRIM(STR(aRep[7])) +;
                             ", numrep = " + LTRIM(STR(aRep[1])) +;
                         ", numingreso = " + LTRIM(STR(aRep[2])) +;
         " WHERE optica = 0"
MSQuery( oApl:oMySql:hConnect,cTemp )

cTemp := "UPDATE cadempre SET ajustes = " + LTRIM(STR(aRep[8])) +;
         " WHERE optica = " + LTRIM(STR(oApl:oEmp:OPTICA))
MSQuery( oApl:oMySql:hConnect,cTemp )
oApl:oEmp:Seek( {"optica",aRep[5]} )
oApl:nEmpresa := aRep[5]
If LEN( ::aRep ) > 0
   If oApl:nTFor == 1
      oTB := TDosPrint()
      oTB:New( oApl:cPuerto,oApl:cImpres,{"Actualizaciones HECHAS",NtChr( oApl:dFec,"2" ),;
               "   DOCUMENTO   OPTICA   ITEMS   CANTIDAD" },.T. )
      FOR nL := 1 TO LEN( ::aRep )
         oTB:Titulo( 40 )
         oTB:Say( oTB:nL,01,::aRep[nL,1] )
         oTB:Say( oTB:nL,17,::aRep[nL,2] )
         oTB:Say( oTB:nL,24,TRANSFORM(::aRep[nL,3],"9,999") )
         oTB:Say( oTB:nL,31,TRANSFORM(::aRep[nL,4],"9,999,999") )
         oTB:nL++
      NEXT nL
      oTB:NewPage()
      oTB:End()
   Else
      ::aEnc:= { .t., oApl:cEmpresa, oApl:oEmp:Nit,;
                 "Actualizaciones HECHAS",NtChr( oApl:dFec,"2" ),;
                 { .T., 3.5,"DOCUMENTO" }, { .F., 4.4,"OPTICA" },;
                 { .T., 8.0,"ITEMS" }    , { .T.,11.0,"CANTIDAD" } }
      ::Init( "Actualizaciones", .f. ,, .f. ,,, .f., 2 )
      PAGE
      FOR nL := 1 TO LEN( ::aRep )
         ::Cabecera( .t.,0.42 )
         UTILPRN ::oUtil Self:nLinea, 3.5 SAY ::aRep[nL,1]                        RIGHT
         UTILPRN ::oUtil Self:nLinea, 4.6 SAY ::aRep[nL,2]
         UTILPRN ::oUtil Self:nLinea, 8.0 SAY TRANSFORM(::aRep[nL,3],    "9,999") RIGHT
         UTILPRN ::oUtil Self:nLinea,11.0 SAY TRANSFORM(::aRep[nL,4],"9,999,999") RIGHT
      NEXT nL
      ENDPAGE
    ::EndInit( .F. )
   EndIf
Else
   MsgInfo( STR(aRep[4])+" Registros con"+STR(aRep[3])+" Unidades","HECHA la Actualización" )
EndIf
RETURN NIL

//------------------------------------//
METHOD CambiaMon( cCodi,nCanti,nMov,lCambio,nPC ) CLASS TActurep
   DEFAULT nPC := Tem->PCOSTO
oApl:oInv:Seek( {"codigo",cCodi} )
If LEFT( cCodi,2 ) == "01"
   If nMov >= 5 .AND. oApl:oInv:OPTICA == oApl:nEmpresa
      If nMov == 6 .AND. nCanti > 0
         oApl:oInv:PVENDIDA := Tem->PCOSTO   ; oApl:oInv:FACTUVEN  := Tem->NUMREPOS
         oApl:oInv:FECVENTA := Tem->FECREPOS ; oApl:oInv:SITUACION := "V"
      Else
         oApl:oInv:PVENDIDA := 0             ; oApl:oInv:FACTUVEN  := 0
         oApl:oInv:FECVENTA := CTOD("")      ; oApl:oInv:SITUACION := "E"
      EndIf
      oApl:oInv:Update( .f.,1 )
   ElseIf lCambio
      oApl:oInv:OPTICA    := Tem->OPTICA  ; oApl:oInv:FECREPOS  := Tem->FECREPOS
      oApl:oInv:NUMREPOS  := Tem->NUMREPOS; oApl:oInv:LOC_ANTES := Tem->LOC_ANTES
      oApl:oInv:SITUACION := "E"          ; oApl:oInv:DESPOR    := Tem->IMPUESTO
      oApl:oInv:Update( .f.,1 )
   ElseIf oApl:oInv:NUMREPOS == Tem->NUMREPOS
      oApl:oInv:OPTICA    := 0            ; oApl:oInv:FECREPOS  := CTOD("")
      oApl:oInv:NUMREPOS  := 0            ; oApl:oInv:LOC_ANTES := 0
      oApl:oInv:Update( .f.,1 )
   EndIf
EndIf
/*
If lCambio
   oApl:oInv:PCOSTO := Tem->PCOSTO ; oApl:oInv:PVENTA := Tem->PVENTA
   oApl:oInv:PPUBLI := Tem->PPUBLI ; oApl:oInv:Replace()
EndIf
*/
Actualiz( cCodi,nCanti,Tem->FECREPOS,nMov,nPC )
If Tem->MOV == 1 .AND. oApl:cLocal == "LOC"
   oApl:nEmpresa := 0
   Actualiz( cCodi,nCanti,Tem->FECREPOS,2 )
   oApl:nEmpresa := Tem->OPTICA
EndIf
RETURN NIL

//-----------------2------------------//
METHOD CompraArt( oTB,cIndica ) CLASS TActurep
   LOCAL cInd := If( oApl:cLocal == "COC", "", "E" )
If oTB[3]:INGRESO # Tem->NUMREPOS
   If !oTB[3]:Seek( { "ingreso",Tem->NUMREPOS,"moneda","X" } )
      oTB[3]:OPTICA    := Tem->OPTICA  ; oTB[3]:INGRESO  := Tem->NUMREPOS
      oTB[3]:CODIGO_NIT:= Tem->NUMFAC  ; oTB[3]:FECINGRE := Tem->FECREPOS
      oTB[3]:FACTURA   := Tem->FACTUPRO; oTB[3]:MONEDA   := "X"
      oTB[3]:Append(.t.)
   EndIf
EndIf
If oTB[4]:Seek( { "ingreso",Tem->NUMREPOS,"secuencia",Tem->SECUENCIA } )
   If cIndica $ "BC"
      oApl:oInv:Seek( {"codigo",oTB[4]:CODIGO} )
      Actualiz( oTB[4]:CODIGO,-oTB[4]:CANTIDAD,Tem->FECREPOS,1,oTB[4]:PCOSTO )
      If cIndica == "B"
         If cInd == "E"
            oTB[4]:Delete( .f.,1 )
         Else
            oTB[4]:INDICA := "B" ; oTB[4]:Update( .f.,1 )
         EndIf
      EndIf
   Else
      cIndica := "B"
   EndIf
EndIf
If cIndica # "B"
   oTB[4]:CODIGO    := Tem->CODIGO   ; oTB[4]:CANTIDAD := Tem->CANTIDAD
   oTB[4]:PCOSTO    := Tem->PCOSTO   ; oTB[4]:PVENTA   := Tem->PVENTA
   oTB[4]:PPUBLI    := Tem->PPUBLI   ; oTB[4]:INDIVA   := Tem->INDIVA
   If oTB[4]:lOk
      oTB[4]:INDICA := Tem->INDICA   ; oTB[4]:Update( .f.,1 )
   Else
      oTB[3]:CONTROL := MAX( Tem->SECUENCIA,oTB[3]:CONTROL )
      oTB[3]:Update( .f.,1 )
      oTB[4]:INGRESO := Tem->NUMREPOS; oTB[4]:SECUENCIA := Tem->SECUENCIA
      oTB[4]:INDICA  := cInd         ; oTB[4]:Append(.f.)
   EndIf
   oApl:oInv:Seek( {"codigo",Tem->CODIGO} )
   Actualiz( Tem->CODIGO,Tem->CANTIDAD,Tem->FECREPOS,1,Tem->PCOSTO )
   ::NEW( "Ing.",0,"",1 )
EndIf
RETURN NIL

//-----------------4------------------//
METHOD CompraMon( oTB,aRep ) CLASS TActurep
   LOCAL aMon := { "",.f.,"" }, nCan, nCon := Tem->CONSEDEV
If Tem->OPTICA == oApl:oEmp:OPTICA .OR. aRep[6]
   If !oTB[3]:Seek( {"ingreso",Tem->NUMREPOS,"moneda <> ","X"} )
      oTB[3]:OPTICA    := Tem->OPTICA  ; oTB[3]:INGRESO  := Tem->NUMREPOS
      oTB[3]:CODIGO_NIT:= Tem->NUMFAC  ; oTB[3]:FECINGRE := Tem->FECREPOS
      oTB[3]:FACTURA   := Tem->FACTUPRO; oTB[3]:MONEDA   := Tem->MONEDA
      oTB[3]:Append(.t.)
   EndIf
   If !oTB[7]:Seek( {"ingreso",Tem->NUMREPOS,"secuencia",Tem->SECUENCIA} )
      oTB[3]:CONTROL   += Tem->CANTIDAD ; oTB[3]:Update( .f.,1 )
      oTB[7]:INGRESO   := Tem->NUMREPOS ; oTB[7]:MARCA  := Tem->MARCA
      oTB[7]:CANTIDAD  := Tem->CANTIDAD ; oTB[7]:REFER  := Tem->DESCRIP
      oTB[7]:MATERIAL  := Tem->MATERIAL ; oTB[7]:SEXO   := Tem->SEXO
      oTB[7]:TIPOMONTU := Tem->TIPOMONTU; oTB[7]:TAMANO := Tem->TAMANO
      oTB[7]:IDENTIF   := Tem->IDENTIF  ; oTB[7]:PCOSTO := Tem->PCOSTO
      oTB[7]:PVENTA    := Tem->PVENTA   ; oTB[7]:PPUBLI := Tem->PPUBLI
      oTB[7]:CONSEC    :=StrZero(nCon,6); oTB[7]:SECUENCIA := Tem->SECUENCIA
      oTB[7]:INDICA    := "A"           ; oTB[7]:Append(.f.)
      aMon[2] := .t.
   EndIf
EndIf
aMon[1] := "010" + If( oTB[7]:MATERIAL == "P", "1", "2" )
FOR nCan := 1 TO Tem->CANTIDAD
   aMon[3] := aMon[1] + StrZero(nCon,6)
   ::NEW( aMon[3] )
   If aMon[2]
      ::CambiaMon( aMon[3],1,1,.t. )
   EndIf
   nCon ++
NEXT nCan
   If aMon[2]
      ::NEW( "Ing.",0,"",Tem->CANTIDAD )
   EndIf
RETURN NIL

//-----------------3------------------//
METHOD Devolucion( oTB,cIndica ) CLASS TActurep
   LOCAL cQry
oApl:nEmpresa := Tem->LOC_ANTES
If oTB[5]:OPTICA # oApl:nEmpresa .OR. oTB[5]:DOCUMEN # Tem->NUMREPOS
   If !oTB[5]:Seek( { "optica",oApl:nEmpresa,"documen",Tem->NUMREPOS } )
      oTB[5]:OPTICA := oApl:nEmpresa ; oTB[5]:DOCUMEN  := Tem->NUMREPOS
      oTB[5]:FECHAD := Tem->FECREPOS ; oTB[5]:CONSEDEV := Tem->CONSEDEV
      oTB[5]:DESPUB := Tem->DESPUB   ; oTB[5]:Append(.t.)
      cQry := "UPDATE cadempre SET numdevol = " + LTRIM(STR(Tem->NUMREPOS)) +;
              " WHERE optica = " + LTRIM(STR(oApl:nEmpresa))
      MSQuery( oApl:oMySql:hConnect,cQry )
   EndIf
EndIf
If oTB[6]:Seek( { "optica",oApl:nEmpresa,"documen",Tem->NUMREPOS,;
                  "secuencia",Tem->SECUENCIA } )
   If cIndica $ "BC"
      ::DevolM( oTB,oTB[6]:CODIGO,oTB[6]:DESTINO,-oTB[6]:CANTIDAD )
      If cIndica == "B"
         oTB[6]:Delete( .f.,1 )
      EndIf
   Else
      cIndica := "B"
   EndIf
EndIf
If cIndica # "B"
   oTB[6]:OPTICA    := oApl:nEmpresa ; oTB[6]:DOCUMEN := Tem->NUMREPOS
   oTB[6]:FECHAD    := Tem->FECREPOS ; oTB[6]:CODIGO  := Tem->CODIGO
   oTB[6]:CANTIDAD  := Tem->CANTIDAD ; oTB[6]:PCOSTO  := Tem->PCOSTO
   oTB[6]:CAUSADEV  := Tem->CAUSADEV ; oTB[6]:DESTINO := Tem->OPTICA
   oTB[6]:NUMREP    := Tem->NUMFAC   //oTB[6]:FECHAREP:= dFechaRep
   oTB[6]:FACTURADO := .t.           ; oTB[6]:SECUENCIA := Tem->SECUENCIA
   oTB[6]:INDICA    := "E"
   If Tem->PCOSTO == 0 .AND. LEFT( Tem->CODIGO,2 ) # "05"
      oApl:oInv:Seek( {"codigo",Tem->CODIGO} )
      If oApl:oInv:PCOSTO > 0
         oTB[6]:PCOSTO := oApl:oInv:PCOSTO
      Else
         SaldoInv( Tem->CODIGO,NtChr( Tem->FECREPOS,"1" ) )
         oTB[6]:PCOSTO := oApl:aInvme[2]
      EndIf
   EndIf
   If oTB[6]:lOk
      oTB[6]:Update( .t.,1 )
   Else
      oTB[6]:Append(.t.)
   EndIf
   ::DevolM( oTB,oTB[6]:CODIGO,oApl:nEmpresa,oTB[6]:CANTIDAD )
   If Tem->CAUSADEV == 4
      cQry := ArrayValor( oApl:aOptic,STR(Tem->LOC_ANTES,2) )
      ::NEW( "Tra.",0,cQry,1 )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD DevolM( oTB,cCodi,nOpt,nCanti ) CLASS TActurep
   LOCAL aDV, nCDev
If nCanti # 0 .AND. LEFT( cCodi,2 ) # "05"
   nCDev := oTB[6]:CAUSADEV
   aDV   := { Grupos( cCodi ),Rango( nCDev,{1,5} ),.f.,"E",0,CTOD(""),0 }
   oApl:oInv:Seek( {"codigo",cCodi} )
   If aDV[1] == "1"
      aDV[3] := If( nCDev # 4 .AND. (oApl:oInv:COMPRA_D .OR. nCDev == 3 .OR.;
                                     oApl:oInv:MONEDA == "C"), .t., .f. )
      If nCanti > 0
         aDV[4] := If( nCDev == 4, "E", If( aDV[2], "V", "D" ) )
         aDV[5] := oTB[5]:DOCUMEN
         aDV[6] := oTB[5]:FECHAD
         aDV[7] := oTB[5]:DESPUB
      EndIf
      If Rango( nCDev,6,7 )
         FVenta( oTB[6]:NUMREP,cCodi,nCanti,oTB[5]:FECHAD,nCDev )
      ElseIf oApl:nEmpresa == 0 .OR. aDV[2] .OR. aDV[3]
         oApl:oInv:SITUACION := aDV[4] ; oApl:oInv:FACTUVEN  := aDV[5]
         oApl:oInv:FECVENTA  := aDV[6] ; oApl:oInv:Update( .f.,1 )
      ElseIf oApl:oInv:OPTICA == nOpt .OR. oApl:oEmp:ENLINEA
         If nCanti > 0
            oApl:oInv:OPTICA   := oTB[6]:DESTINO
            oApl:oInv:NUMREPOS := aDV[5]       ; oApl:oInv:FECREPOS := aDV[6]
         Else
            oApl:oInv:OPTICA   := oApl:nEmpresa
            oApl:oInv:NUMREPOS := oTB[6]:NUMREP; oApl:oInv:FECREPOS := oTB[6]:FECHAREP
         EndIf
         oApl:oInv:LOC_ANTES   := oApl:nEmpresa; oApl:oInv:DESPOR   := aDV[7]
         oApl:oInv:Update( .f.,1 )
      EndIf
   EndIf
   nOpt := oTB[9][nCDev]
// nOpt := { 4,4,4,4,2,7,7,2 }[nCDev]    //2=SALIDAS, 4=DEVOL_S, 7=DEVOLCLI
   If oApl:cLocal == "LOC"
      Actualiz( cCodi,nCanti,oTB[5]:FECHAD,nOpt,oTB[6]:PCOSTO )
   EndIf
   If oApl:nEmpresa > 0 .AND. nOpt == 4
      If nCDev # 4 .AND. (aDV[2] .OR. aDV[3] .OR. aDV[1] == "6")
         RETURN NIL
      EndIf
      oApl:nEmpresa := oTB[6]:DESTINO
      Actualiz( cCodi,nCanti,oTB[5]:FECHAD,3,If( oApl:nEmpresa # 0, oTB[6]:PCOSTO, ) )
   EndIf
      oApl:nEmpresa := oTB[6]:OPTICA
EndIf
RETURN NIL

//-----------------1------------------//
METHOD Reposicion( oTB,cIndica ) CLASS TActurep

If oTB[1]:NUMREP # Tem->NUMREPOS
   If !oTB[1]:Seek( { "numrep",Tem->NUMREPOS } )
      oTB[1]:OPTICA   := Tem->OPTICA  ; oTB[1]:NUMREP := Tem->NUMREPOS
      oTB[1]:FECHAREP := Tem->FECREPOS; oTB[1]:NUMFAC := Tem->NUMFAC
      oTB[1]:DESPOR   := Tem->DESPOR  ; oTB[1]:DESPUB := Tem->DESPUB
      oTB[1]:Append(.t.)
   EndIf
EndIf
If oTB[2]:Seek( { "numrep",Tem->NUMREPOS,"secuencia",Tem->SECUENCIA } )
   If cIndica $ "BC"
      ::CambiaMon( oTB[2]:CODIGO,-oTB[2]:CANTIDAD,1,.f.,oTB[2]:PCOSTO )
      If cIndica == "B"
         oTB[2]:Delete( .f.,1 )
      EndIf
   Else
      cIndica := "B"
   EndIf
EndIf
If cIndica # "B"
   oTB[2]:GRUPO    := Tem->GRUPO     ; oTB[2]:CODIGO := Tem->Codigo
   oTB[2]:CANTIDAD := Tem->CANTIDAD  ; oTB[2]:PCOSTO := Tem->Pcosto
   oTB[2]:PPUBLI   := Tem->PPUBLI    ; oTB[2]:INDICA := "E"
   If oTB[2]:lOk
      oTB[2]:Update( .f.,1 )
   Else
      oTB[1]:CONTROL := MAX( Tem->SECUENCIA,oTB[1]:CONTROL )
      oTB[1]:ITEMS   ++              ; oTB[1]:Update( .f.,1 )
      oTB[2]:NUMREP  := Tem->NumRepos; oTB[2]:SECUENCIA := Tem->Secuencia
      oTB[2]:Append(.f.)
   EndIf
   ::CambiaMon( Tem->CODIGO,Tem->CANTIDAD,1,.t. )
   ::NEW( "Rep.",0,"",1 )
EndIf
RETURN NIL

//-----------------5------------------//
METHOD Ajustes( oTB,cIndica,nMov ) CLASS TActurep

If oTB[8]:Seek( { "optica",oApl:nEmpresa,"numero",Tem->NUMREPOS,;
                  "secuencia",Tem->SECUENCIA } )
   If cIndica $ "BC"
      nMov := { 5,6,6 }[oTB[8]:TIPO]
      ::CambiaMon( oTB[8]:CODIGO,-oTB[8]:CANTIDAD,nMov,.f.,oTB[8]:PCOSTO )
      If cIndica == "B"
         oTB[8]:Delete( .f.,1 )
      EndIf
   Else
      cIndica := "B"
   EndIf
EndIf
If cIndica # "B"
   nMov := { 5,6,6 }[Tem->CAUSADEV]       //5_Sobrante, 6_Faltante y Robo
   oTB[8]:CODIGO   := Tem->CODIGO
   oTB[8]:CANTIDAD := Tem->CANTIDAD ; oTB[8]:TIPO    := Tem->CAUSADEV
   oTB[8]:PCOSTO   := Tem->PCOSTO   ; oTB[8]:PVENTA  := Tem->PVENTA
   oTB[8]:INDICA   := "E"
   If oTB[8]:lOk
      oTB[8]:Update( .f.,1 )
   Else
      oTB[8]:OPTICA := oApl:nEmpresa ; oTB[8]:NUMERO    := Tem->NUMREPOS
      oTB[8]:FECHA  := Tem->FECREPOS ; oTB[8]:SECUENCIA := Tem->SECUENCIA
      oTB[8]:Append(.f.)
   EndIf
   ::CambiaMon( Tem->CODIGO,Tem->CANTIDAD,nMov,.f.,Tem->PCOSTO )
   ::NEW( "Aju.",0,"",1 )
EndIf
RETURN NIL