/* Modulo...................... CaoTipos.prg
*  Fecha de escritura.......... 07/09/2001
*  Fecha de Actualizacion......
*  Descripcion ................ Grupo de Funciones para el manejo
*                               de controles
*/
#include "Fivewin.ch"

MEMVAR oApl

//------------------------------------//
FUNCTION ActivaGET( aTable,oDlg,oFont )
//   DEFAULT oFont := oDlg:oFont
AEVAL( aTable,{|o|o:Enable(),If(o:ClassName=="TGET",ColorGet(o),),;
                   IF(o:ClassName<>"TRADMENU",o:Refresh(),) } )
//AEVAL( oDlg:aControls,{|a|a:SetFont(oFont)} )

RETURN NIL //aTable

//------------------------------------//
FUNCTION ColorGet(oGet)
   LOCAL nClrFocusText := RGB(0,0,0)
   LOCAL nClrNfocus    := RGB(255,255,255)
   LOCAL nGetFocus     := RGB(255,255,128)
oGet:bGotFocus  := {|| (oGet:SetPos(1),;
                        oGet:SetColor(nClrFocusText,nGetFocus))}
oGet:bLostFocus := {|| (oGet:SetPos(1),;
                        oGet:SetColor(nClrFocusText,nClrNfocus))}
RETURN .T.

//------------------------------------//
FUNCTION DesactivaGET(oGet)
 oGet:SetColor(RGB(0,0,0),RGB(192,192,192))
RETURN NIL

//------------------------------------//
FUNCTION DesactivaALLGET( aTable,nPos )
   DEFAULT nPos := LEN( aTable )
AEVAL( aTable,{|o|If(o:ClassName=="TGET",DesactivaGET(o),),;
                  IF(o:ClassName<>"TRADMENU",o:Disable(),) },1,nPos )
RETURN NIL

//------------------------------------//
FUNCTION AbreDbf(cAlias,cNomdbf,cIndice,cRuta,lModo,lReadOnly,nSecond)
 //<cNomdbf>   Nombre de la base de datos a abrir
 //<cIndice>   Nombre del archivo CDX
 //<cRuta>     Ruta   del archivo
 //<lModo>     Modo de apertura .T. = compartida , .F. Exclusiva
 //<lReadOnly> Modo de acceso   .T. = Lectura, .F. = Lectura/escritura
 //<nSecond>   segundos que tiene que esperar si no puede abrir la dbf
   DEFAULT cRuta := oApl:cRuta2, lModo   := .t. ,;
           lReadOnly := .f.    , nSecond := 1.5
cNomdbf := cRuta+cNomdbf
IF !FILE( cNomdbf+".DBF" )
   MsgStop("NO EXISTE EL ARCHIVO "+cNomdbf+CRLF+"Imposible continuar",;
            "Error en el sistema")
   RETURN .f.
ENDIF
IF NetTry(nSecond,{|| DbUseArea(.t.,,cNomdbf,cAlias,lModo,lReadOnly), ;
                      !NetErr() })
   If !Empty(cIndice)
      dbSetIndex( cRuta + cIndice )
   EndIf
   RETURN .t.
ELSE
   Msginfo("El archivo que intenta abrir, esta siendo utilizado"+CRLF+;
           "Por otro usuario, por favor intente mas tarde",           ;
           "Error en el sistema")
ENDIF
RETURN .f.

//------------------------------------//
PROCEDURE Actualiz( cCodigo,nCantid,dFecha,nMov,nPCos )
   LOCAL aCam, cQry, nCF := 4
If !oApl:oEmp:TACTUINV     .AND.;
   LEFT( cCodigo,2) # "05" .AND.;
  NtChr( cCodigo ) >= 10   .AND. nCantid # 0
   cQry := NtChr( dFecha,"1" )
   aCam := { "", "fec_ults = ", nCantid, cQry          ,;
             " WHERE optica = "  + STR(oApl:nEmpresa,2)+;
               " AND codigo = '" + TRIM(cCodigo)       +;
              "' AND anomes = '" + cQry + "'" }
   aCam[1] := {"entradas" ,"salidas"  ,"devol_e","devol_s",;
               "ajustes_e","ajustes_s","devolcli"}[nMov]
   If !SaldoInv( cCodigo,aCam[4] )
      cQry := "INSERT INTO cadinvme VALUES ( null, " +;
               LTRIM(STR(oApl:nEmpresa)) + ", '" + aCam[4] + "', "+;
               LTRIM(STR(oApl:aInvme[1]))+ ", '" + TRIM(cCodigo)  +;
               "', 0, 0, 0, 0, null, null, 0, 0, 0, 0 )"
      MSQuery( oApl:oMySql:hConnect,cQry )
   EndIf
   nPCos   := If( nPCos == NIL, oApl:aInvme[2], nPCos )
/* nCF = ROUND( decode(sign(EXISTENCIA + WCANTIDAD),0,COSTO_PROMEDIO,
                           (EXISTENCIA*nvl(COSTO_PROMEDIO,0) +
                        nvl(WCANTIDAD,0) * nvl(WVALOR_UNIDAD,0) ) ) /
                     decode(sign(EXISTENCIA + WCANTIDAD),0,1,
                                (EXISTENCIA + WCANTIDAD) ),4),
   -----------------
   (-2 * 13700) + (2 * 16250) / 0 = 13700
   (-3 * 13700) + (2 * 16250) /-1 =  8600
   ( 1 * 13700) + (2 * 16250) / 3 = 15400
*/
   //nMov    := nMov % 2
   //If nMov == 1
   If Rango( nMov,{1,3,5,7} )
      nCF := oApl:aInvme[1] + nCantid
      If ABS( nCF ) > 0
         nPCos := (oApl:aInvme[1] * oApl:aInvme[2] + nCantid * nPCos) / nCF
    //ElseIf oApl:aInvme[1] < 0
    //   nPCos := nPCos
      Else
         nPCos := oApl:aInvme[2]
      EndIf
      oApl:aInvme[2] := ABS( ROUND( nPCos,2 ) )
      aCam[2]:= "fec_ulte = "
      nCF    := 3
   Else
      aCam[3] *= -1
   EndIf
   //dFec := If( oApl:aInvme[nCF] < dFecha, dFecha, oApl:aInvme[nCF] )
   dFecha := MAX( dFecha,oApl:aInvme[nCF] )
   oApl:aInvme[2] := If( oApl:aInvme[2] == 0, nPCos, oApl:aInvme[2] )
   cQry := "UPDATE cadinvme SET " + aCam[1] + " = " + aCam[1] + " + "   +;
           LTRIM(STR(nCantid)) + ", " + aCam[2]     + xValToChar(dFecha)+;
           ", pcosto = " + LTRIM(STR(oApl:aInvme[2])) + aCam[5]
   MSQuery( oApl:oMySql:hConnect,cQry )
 //nCantid *= If( nMov == 1, 1, -1 )
   cQry := "UPDATE cadinvme SET existencia = existencia + "  +;
           LTRIM(STR(aCam[3])) + If( oApl:Tipo == "MTL", aCam[5],;
           STRTRAN( aCam[5],"mes ","mes >" ) )
   MSQuery( oApl:oMySql:hConnect,cQry )
EndIf
RETURN

//------------------------------------//
FUNCTION ArrayCol( aArray,nCol )
   LOCAL aColArray := {}, nLen, nPtr
If aArray == NIL
   nLen := LEN( ALLTRIM( oApl:oEmp:NOMBRE ) )
   If (nPtr := RAT( "-",oApl:oEmp:NOMBRE )) == 0
       nPtr := nLen
   Else
       nPtr --
   EndIf
   If oApl:oEmp:DIVIDENOMB > 0
      nLen := oApl:oEmp:DIVIDENOMB
      nCol := LEN( ALLTRIM( oApl:oEmp:NOMBRE ) ) -;
              RAT( "-",oApl:oEmp:NOMBRE ) + nLen
   EndIf
   aColArray := { nLen,oApl:oEmp:DIVIDENOMB,nCol,nPtr }
Else
   nLen := If( LEN( aArray ) > 0, If( VALTYPE( aArray[1] ) == 'A',;
               LEN( aArray[1] ), 0 ), 0 )
   nCol := If( Rango( nCol,1,nLen ), nCol, 1 )
   FOR nPtr := 1 TO LEN( aArray )
      AADD( aColArray, aArray[nPtr,nCol] )
   NEXT nPtr
EndIf
RETURN aColArray

//------------------------------------//
FUNCTION ArrayCombo( cTipo )
   LOCAL aItem := {}, cRet, nL, oSql
cRet := "SELECT desplegar, retornar FROM cadcombo" +;
        " WHERE tipo = '" + (cTipo) + "'"
oSql := TMsQuery():Query( oApl:oDb,cRet )
If oSql:Open()	         // Abrimos el conjunto resultado de la consulta
   oSql:GoTop()
   FOR nL := 1 TO oSql:nRowCount
      cTipo := oSql:Read()
      cTipo[2] := If( EMPTY(cTipo[2]), " ", cTipo[2] )
      AADD( aItem, cTipo )
      oSql:Skip(1)
   NEXT
EndIf
oSql:Close()		 // Destruimos el objeto y liberamos memoria
If LEN( aItem ) == 0
   AADD( aItem, { " "," " } )
EndIf
//AEval( aItem, { | e | MsgInfo( e[ 1 ],e[ 2 ]+STR(LEN(e[ 2 ])) ) } )
RETURN aItem

//------------------------------------//
FUNCTION ArrayValor( aDat,xVar,bDat,lPos,nPos )
   LOCAL nP
   DEFAULT bDat := {|xV| NIL }, lPos := .f., nPos := 2
xVar := If( EMPTY( xVar ), "*", xVar )
If VALTYPE( xVar ) # "A"
   nP := ASCAN( aDat, { |x| x[nPos] == xVar } )
Else
   FOR nPos := 1 TO LEN( aDat )
      If aDat[nPos,2] == xVar[1] .AND.;
         aDat[nPos,7] == xVar[2]
         nP := nPos
         EXIT
      EndIf
   NEXT nPos
   nPos := 2
EndIf
If nP == 0
   nP := 1 ; EVAL(bDat,aDat[nP,nPos])
EndIf
RETURN If( lPos, nP, aDat[nP,1] )

//------------------------------------//
FUNCTION BorraFile( cFile,aExt,cRuta )
   DEFAULT aExt := { "CDX" }, cRuta := oApl:cRuta2
cRuta += cFile + "."
AEVAL( aExt, {|cExt| FERASE( cRuta + cExt )} )
RETURN NIL

//------------------------------------//
FUNCTION Buscar( uValor,cTabla,cLista,nTope,cOrderBy,nType )
   LOCAL aRes := {}, hRes, cOpe, cQry, nL, nCol
   DEFAULT cTabla := "cadclien", cLista := "*", nTope := 1, nType := 1
If VALTYPE( uValor ) # "A" .AND. cTabla # "CM"
   MsgStop( "Primer Parametro Invalido" )
   RETURN NIL
EndIf
If cTabla # "CM"
   cQry := "SELECT " + (cLista) +" FROM " + (cTabla) + " WHERE "
   FOR nL := 1 TO LEN( uValor ) STEP 2
      cOpe := If( AT( " ",uValor[nL] ) == 0, " = ", "" )
      cQry += uValor[nL] + (cOpe) + xValToChar( uValor[nL+1] ) + " AND "
   NEXT
   cQry   := LEFT( cQry,LEN(cQry)-5 ) +;
             If( cOrderBy == nil, '', " ORDER BY " + cOrderBy )
Else
   cQry := uValor
EndIf
If !MSQuery( oApl:oMySql:hConnect,cQry )
   oApl:oMySql:oError:Display( .f. )
   RETURN ""
EndIf
hRes := MSStoreResult( oApl:oMySql:hConnect )
nCol := MyFieldCount( hRes )
If (nL := MSNumRows( hRes )) == 0
// aRes := MyAFillResult( hRes, 1 ) //MyRowCount( hRes )
   aRes := If( nCol == 1, {"",CTOD(""),.f.,0}[nType], {} )
   If nTope < 8
      MsgStop( cQry,"NO Existe" )
   EndIf
EndIf
While nL > 0
   cOpe := MyReadRow( hRes )
   AEVAL( cOpe, { | xV,nP | cOpe[nP] := MyClReadCol( hRes,nP ) } )
   If nTope == 1 .OR. nTope == 8
      aRes := If( nCol == 1, cOpe[1], cOpe )
      Exit
   EndIf
   AADD( aRes,If( nCol == 1, cOpe[1], cOpe ) )
   nL --
EndDo
MSFreeResult( hRes )
RETURN aRes

//------------------------------------//
FUNCTION DelRecord( oTB,oLbx,lSig )
   LOCAL cQry
   DEFAULT lSig := .f.
If lSig
   cQry := "DELETE FROM " + oTB:cName +;
          " WHERE row_id = " + LTRIM(STR(oTB:ROW_ID))
   If MSQuery( oApl:oMySql:hConnect,cQry )
      MsgInfo( "Registro Borrado","LISTO" )
   Else
      oApl:oMySql:oError:Display( .f. )
   EndIf
Else
   If MsgYesNo("Esta seguro de eliminar este registro","Eliminar")
      oTB:Delete(.f.,1)
      If oLbx # NIL
         oLbx:Refresh()
         oLbx:SetFocus()
      EndIf
   EndIf
EndIf
RETURN NIl

//------------------------------------//
FUNCTION Dolar_Peso( nUS,nValor,cUS )
If cUS == "U" .AND. nValor <= 3000
   nValor *= nUS
EndIf
RETURN nValor

//------------------------------------//
FUNCTION Empresa()
   LOCAL oDlg, oGet, cEmp := oApl:oEmp:LOCALIZ, lSi := .f.
DEFINE DIALOG oDlg FROM 1, 2 TO 06, 28 ;
   TITLE "Por favor digite Optica"
   @ 02,24 GET oGet VAR cEmp OF oDlg PICTURE "@!" SIZE 22,10 PIXEL
   @ 18,20 BUTTON "&Aceptar" OF oDlg SIZE 44,12 ACTION ;
      ( If( oApl:oEmp:Seek( {"localiz",cEmp} )        ,;
         ( nEmpresa( .t. ), lSi := .t., oDlg:End() )  ,;
         ( MsgAlert( "Optica Errada!" ), oGet:SetFocus() ) ) ) PIXEL
ACTIVATE DIALOG oDlg CENTERED
RETURN lSi

PROCEDURE nEmpresa( lWnd )
   LOCAL cEmp, dFec := DATE()
//dFec -= If( NtChr( dFec,"5" ) == "Sabado" .AND. !Rango( oApl:oEmp:OPTICA,{46,48,52,53,54} ), 1, 0 )
If oApl:oEmp:FEC_HOY  < dFec .AND. oApl:cLocal # "LOC"
   oApl:oEmp:FEC_HOY := dFec
   oApl:oEmp:Update()
EndIf
oApl:cCiu     := Buscar( {"codigo",oApl:oEmp:RESHABIT},"ciudades","nombre" )
oApl:cEmpresa := ALLTRIM( oApl:oEmp:NOMBRE )
oApl:nEmpresa := oApl:oEmp:OPTICA
oApl:dFec     := oApl:oEmp:FEC_HOY
oApl:cPer     := NtChr( oApl:dFec,"1" )
oApl:lEnLinea := If( oApl:cLocal # "LOC" .AND. TRIM( oApl:cUser ) # "root", .t., .f. )
//oApl:lEnLinea := If( oApl:oEmp:ENLINEA .AND. TRIM( oApl:cUser ) # "root", .t., .f. )
If lWnd
   cEmp := oApl:oWnd:cTitle()
   oApl:oWnd:SetText( STUFF( cEmp,1,AT("[",cEmp)-2,oApl:cEmpresa ) )
EndIf
RETURN

//------------------------------------//
FUNCTION DefineBar(oDlg,oLbx,aAction,nRow,nCol,nAncho)
   LOCAL oBar
   DEFAULT nAncho := 380
If nRow == NIL
   DEFINE BUTTONBAR oBar OF oDlg 3DLOOK SIZE 28,28
Else
   oBar := TBar():NewAt( nRow,nCol,nAncho,32,28,28,oDlg, .t.,"TOP", )
EndIf
DEFINE BUTTON RESOURCE "NUEVO"    OF oBar NOBORDER;
   TOOLTIP "Nuevo Registro (Ctrl+N)" ;
   ACTION EVAL(aAction[1])
DEFINE BUTTON RESOURCE "EDIT"     OF oBar NOBORDER;
   TOOLTIP "Editar Registro (Ctrl+E)";
   ACTION EVAL(aAction[2])
If nRow == NIL
   DEFINE BUTTON OF oBar NOBORDER     ;
      ACTION EVAL(aAction[3])         ;
      FILENAME oApl:cIco+"SBloque.bmp";
      TOOLTIP "Armar Contabilizacion"
Else
   DEFINE BUTTON RESOURCE "BUSCAR"   OF oBar NOBORDER;
      TOOLTIP "Localizar (Ctrl+L)"  ;
      ACTION EVAL(aAction[3])
EndIf
DEFINE BUTTON RESOURCE "ELIMINAR" OF oBar NOBORDER;
   TOOLTIP "Eliminar (Ctrl+DEL)" ;
   ACTION EVAL(aAction[4])
DEFINE BUTTON RESOURCE "IMPRIMIR"  OF oBar NOBORDER TOOLTIP "Imprimir (F3 � Ctrl+P)";
   ACTION EVAL(aAction[5])
DEFINE BUTTON RESOURCE "ANTERIOR"  OF oBar NOBORDER TOOLTIP "Registro Anterior";
   ACTION oLbx:GoUp() GROUP
DEFINE BUTTON RESOURCE "PRIMERO"   OF oBar NOBORDER TOOLTIP "Primer Registro";
   ACTION oLbx:GoTop()
DEFINE BUTTON RESOURCE "RETROCEDE" OF oBar NOBORDER TOOLTIP "P�gina anterior";
   ACTION oLbx:PageUp()
DEFINE BUTTON RESOURCE "AVANZA"    OF oBar NOBORDER TOOLTIP "P�gina posterior";
   ACTION oLbx:PageDown()
DEFINE BUTTON RESOURCE "ULTIMO"    OF oBar NOBORDER TOOLTIP "Ultimo Registro";
   ACTION oLbx:GoBottom()
DEFINE BUTTON RESOURCE "SIGUIENTE" OF oBar NOBORDER TOOLTIP "Siguiente Registro";
   ACTION oLbx:GoDown()
DEFINE BUTTON RESOURCE "SALIR"     OF oBar NOBORDER TOOLTIP "Salir"   ;
   ACTION EVAL(aAction[6]) GROUP
RETURN oBar

//------------------------------------//
PROCEDURE GrabaSal( nFactura,nMov,nPago )
   LOCAL cCam, cWhe, cQry
If oApl:Tipo # "Z"
   If !oApl:lFam .AND. (oApl:nSaldo # 0 .OR. nPago # 0)
      cQry := "INSERT INTO cadfactm VALUES ( null, " +;
               LTRIM(STR(oApl:nEmpresa)) + ", "      +;
               LTRIM(STR(nFactura))      + ", '"     +;
               oApl:Tipo + "', '" + oApl:cPer + "', "+;
               LTRIM(STR(oApl:nSaldo)) + ", 0, 0 )"
      MSQuery( oApl:oMySql:hConnect,cQry )
   EndIf
   If nPago # 0
      cWhe := " WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
                " AND numfac = " + LTRIM(STR(nFactura))     +;
                " AND tipo   = '" + oApl:Tipo +;
               "' AND anomes = '" + oApl:cPer + "'"
      If nMov > 0
         cCam := { "abonos","debito" }[nMov]
         cQry := "UPDATE cadfactm SET " + cCam + " = " + cCam +" + "+;
                  LTRIM(STR(nPago)) + cWhe
         MSQuery( oApl:oMySql:hConnect,cQry )
         nPago *= If( nMov == 1, -1, 1 )
      EndIf
      cQry := "UPDATE cadfactm SET saldo = saldo + " + LTRIM(STR(nPago)) + ;
              STRTRAN( cWhe,"mes ","mes >" )
      MSQuery( oApl:oMySql:hConnect,cQry )
   EndIf
EndIf
RETURN

//------------------------------------//
PROCEDURE Guardar( oTB,lInsert,lRefresh )
WHILE .t.
   If VALTYPE( oTB ) == "C"
      If MSQuery( oApl:oMySql:hConnect,oTB )
         oApl:oDb:Commit()
         EXIT
      ElseIf oApl:oMySql:GetErrNo() == 1030  //Got error from storage engine
         If oApl:oDb:Repair( lInsert )
            MsgInfo( "la Tabla "+lInsert,"Se Reparo" )
         Else
            MsgStop( "la Tabla "+lInsert,"No se Pudo Reparar" )
            EXIT
         EndIf
      ElseIf oApl:oMySql:GetErrNo()  # 2013  //Lost connection to MySQL server during query
         oApl:oMySql:oError:Display( .f. )
         EXIT
      EndIf
   Else
      If lInsert
         If oTB:Insert( lRefresh )
            oApl:oDb:Commit()
            EXIT
         EndIf
      Else
         If oTB:Update( lRefresh,1 )
            EXIT
         EndIf
      EndIf
   EndIf
   oApl:oWnd:SetMsg( "Por FAVOR espere estoy Reconectandome" )
   oApl:oMySql:Ping()
EndDo
RETURN

//------------------------------------//
FUNCTION Letras( nMonto,nDiv )
   LOCAL cL1 := "      UN    DOS   TRES  CUATROCINCO SEIS  SIETE OCHO  NUEVE "
   LOCAL cL2 := "DIEZ      ONCE      DOCE      TRECE     CATORCE   "+;
                "QUINCE    DIECISEIS DIECISIETEDIECIOCHO DIECINUEVE"
   LOCAL cL3 := SPACE(18) + "VEINTI   TREINTA  CUARENTA CINCUENTA" + ;
          "SESENTA  SETENTA  OCHENTA  NOVENTA  "
   LOCAL cL4 := "             CIENTO       DOSCIENTOS   TRESCIENTOS  CUATROCIENTOS"+;
          "QUINIENTOS   SEISCIENTOS  SETECIENTOS  OCHOCIENTOS  NOVECIENTOS  "
   LOCAL cNum := STRTRAN( STR( nMonto,18,2 )," ","0" ), nMtl
   LOCAL aMtl := {}, cLetra := "", cUnid, uni, cDece, dec, cCent, cen, cGru
   DEFAULT nDiv := 0
If EMPTY( nMonto )
   RETURN { "CERO","" }
EndIf
AADD( aMtl, If( SUBSTR( cNum, 1,3 ) > "000", If( SUBSTR( cNum,1,3 ) = "001", ;
             " BILLON", " BILLONES"), "") )
AADD( aMtl, If( SUBSTR( cNum, 4,3 ) > "000", " MIL", "") )
AADD( aMtl, If( SUBSTR( cNum, 7,3 ) > "000" .OR. SUBSTR( cNum,4,3 ) > "000", ;
            If( SUBSTR( cNum, 7,3 ) = "001", " MILLON", " MILLONES"), "") )
AADD( aMtl, If( SUBSTR( cNum,10,3 ) > "000", " MIL", "") )
AADD( aMtl, "" )
FOR nMtl  := 1 TO 5
   cGru   := SUBSTR( cNum,nMtl*3-2,3 )
   uni    :=  RIGHT( cGru,1 )
   dec    := SUBSTR( cGru,2,1 )
   cen    :=   LEFT( cGru,1 )
   cUnid  := If( dec > "2" .AND. uni > "0",  " Y ", If(dec = "2", "", " ")) + ;
             If( dec = "1", SUBSTR( cL2,VAL(uni)*10+1,10 ), ;
                            SUBSTR( cL1,VAL(uni)*06+1,06 ) )
   cDece  := " " + If(dec + uni = "20", "VEINTE", ;
             SUBSTR( cL3,VAL(dec)*9+1,9 ))
   cCent  := If( cGru = "100", " CIEN", " " + SUBSTR( cL4,VAL(cen)*13+1,13 ) )
   cLetra += (TRIM(cCent) + TRIM(cDece) + TRIM(cUnid) + aMtl[nMtl])
NEXT
aMtl := { LTRIM(cLetra) + " PESOS CON " + RIGHT( cNum,2 ) + "/100 ML.","" }
If nDiv > 0 .AND. LEN(aMtl[1]) > nDiv
   nMtl := LEN(aMtl[1])
   While !SUBSTR( aMtl[1],nDiv,1 ) $ " "
      nDiv--
   EndDo
   // Divide el Monto en dos partes
   aMtl[2] := SUBSTR( aMtl[1],nDiv+1,nMtl-nDiv )
   aMtl[1] :=   LEFT( aMtl[1],nDiv )
EndIf
RETURN aMtl

//------------------------------------//
FUNCTION NtChr( xVar,wPict )
   LOCAL cDia, nDia, cMes, nMes
   DEFAULT wPict := ""
do CASE
CASE VALTYPE( xVar ) == "C" .AND. wPict == "A"
     cDia := ""
   FOR nDia := 1 TO LEN( xVar )
       cDia += SUBSTR( xVar,nDia,1 ) + " "
   NEXT nDia
   xVar := cDia
CASE VALTYPE( xVar ) == "C" .AND. wPict == "N"
     cDia := ""
   FOR nDia := 1 TO LEN( xVar )
      If SUBSTR( xVar,nDia,1 ) $ "1234567890"
         cDia += SUBSTR( xVar,nDia,1 )
      EndIf
   NEXT nDia
   xVar := cDia
CASE VALTYPE( xVar ) == "C" .AND. wPict == "F"
   xVar := If( RIGHT( xVar,2 ) == "13", STUFF( xVar,5,2,"12" ),xVar )
   xVar := CTOD( "01."+RIGHT( xVar,2 )+"."+LEFT( xVar,4 ) )
CASE VALTYPE( xVar ) == "C" .AND. wPict == "P"
   If  LEFT( xVar,4 ) < "1980" .OR. ;
      RIGHT( xVar,2 ) >   "13" .OR. RIGHT( xVar,2 ) < "01"
      MsgStop( "Periodo no es Correcto" )
      xVar := .f.
   Else
      xVar := .t.
   EndIf
CASE VALTYPE( xVar ) == "C"
   xVar := LEN( ALLTRIM( xVar ) )

CASE VALTYPE( xVar ) == "D" .AND. wPict == "1"
   xVar := LEFT( DTOS( xVar ),6 )
CASE VALTYPE( xVar ) == "D" .AND. wPict == "2" .AND. !EMPTY( xVar )
   nMes := MONTH( xVar ) * 5 - 4
   cMes := "-ENE--FEB--MAR--ABR--MAY--JUN--JUL--AGO--SEP--OCT--NOV--DIC-"
//   xVar := STR(DAY(xVar),2) + SUBSTR( cMes,nMes,5 ) + RIGHT(DTOC(xVar),4)
   xVar := STUFF( DTOC(xVar),3,4,SUBSTR( cMes,nMes,5 ) )
CASE VALTYPE( xVar ) == "D" .AND. wPict $ "36"
   nMes := MONTH( xVar ) * 10 - 9
   cMes := "ENERO     FEBRERO   MARZO     ABRIL     MAYO      JUNIO     "+ ;
           "JULIO     AGOSTO    SEPTIEMBREOCTUBRE   NOVIEMBRE DICIEMBRE "
   wPict:= If( wPict = "3", STR( DAY(xVar),3 ),"" ) + " DE "
   xVar := TRIM( SUBSTR( cMes,nMes,10 ) ) + wPict + ;
           TransForm( YEAR(xVar),"#,###" )
CASE VALTYPE( xVar ) == "D" .AND. wPict == "4"
   nMes := MONTH( xVar )
   cDia := If( nMes = 2 .AND. MOD(YEAR(xVar), 4) = 0, "29" , ;
               SUBSTR("312831303130313130313031", nMes*2-1, 2) )
   xVar := cDia + "." + StrZero( nMes,2 ) + "." + STR( YEAR(xVar),4 )
CASE VALTYPE( xVar ) == "D" .AND. wPict == "5"
   cDia := "Domingo  Lunes    Martes   MiercolesJueves   Viernes  Sabado   "
   xVar := TRIM( SUBSTR( cDia,DOW( xVar ) * 9 - 8,9 ) )
CASE VALTYPE( xVar ) == "D" .AND. wPict == "7"
   wPict:= STRTRAN( DTOC( xVar ),"."," " )
   xVar := RIGHT( wPict,4 ) + SUBSTR( wPict,3,4 ) + LEFT( wPict,2 )
CASE VALTYPE( xVar ) == "D" .AND. wPict == "A"
// xVar := (YEAR(date()) - YEAR(xVar)) - (RIGHT(date(),5) < RIGHT(xVar,5))
   nMes := DATE() - xVar
   nDia := If( nMes/365 >= 1, 365, If( nMes/30 >= 1, 30, 1 ))
   xVar := ROUND( nMes/nDia,0 )

CASE VALTYPE( xVar ) == "N"
   wPict:= If( wPict == "0", Replicate( "9",LenNum(xVar) ),wPict )
   xVar := TransForm( xVar,wPict )

OtherWise
   xVar := ""
EndCASE
RETURN xVar

//------------------------------------//
FUNCTION NetTry(nSecond,bAction)
   LOCAL lForever, lSucces
lForever := (nSecond == NIL .OR. nSecond == 0)
WHILE !(lSucces := EVAL(bAction) .AND. (lForever .OR. nSecond > 0))
   INKEY(.5)
   nSecond-=.5
ENDDO
RETURN lSucces

//------------------------------------//
FUNCTION Rango( xValor,xMinimo,xMaximo )
   LOCAL lSi
If VALTYPE( xMinimo ) == "A"
   lSi := If( ASCAN( xMinimo, xValor ) == 0, .f. , .t. )
Else
   lSi := xMinimo <= xValor .AND. xValor <= xMaximo
EndIf
RETURN lSi

FUNCTION Redondear( nValCa,nEnte,nApro,nX )
   LOCAL nRes := Val( Right( Str( nValCa,10 ),LenNum(nEnte) ) )
RETURN( If( nX == NIL, nValCa,0 ) + If( nRes < nEnte, -nRes, nApro-nRes ) )

FUNCTION XTrim( cCadena,nLen,cType )
If nLen == -9
   cType := VALTYPE( cCadena )
   If cType == "D"
      cCadena := If( EMPTY( cCadena ), "", MyDToMs( DTOS( cCadena ) ) )
   ElseIf cType == "L"
      cCadena := MyLToMs( cCadena )
   ElseIf cType == "N"
      cCadena := STRTRAN( LTRIM( STR( cCadena ) ),".","," )
      If RIGHT(cCadena,3) == ",00"
         cCadena := LEFT( cCadena,LEN(cCadena)-3 )
      EndIf
   Else
      cCadena := ALLTRIM(cCadena)
   EndIf
      cCadena := '"' + cCadena + '",'
ElseIf nLen == NIL
   cCadena := If( EMPTY(cCadena), "", ALLTRIM(cCadena)+" " )
Else
   cCadena := PADR( cCadena,nLen )
   If LEN( cCadena ) > nLen
      cCadena := LEFT( cCadena,nLen )
   EndIf
EndIf
RETURN cCadena

//------------------------------------//
FUNCTION Privileg( cModulo,lGru,lBod )
   LOCAL aRes := { .f.,.f.,.f. }, cQry, hRes
If lGru == NIL
   cQry := "SELECT insert_priv, update_priv, delete_priv FROM usuarios "+;
           "WHERE user = " + xValToChar( oApl:cUser ) +;
           "AND modulo = " + xValToChar( cModulo )
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   If MSNumRows( hRes ) > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
Else
   If lGru
      If lBod
         aRes := { "IN (0, ","BOD - " }
      Else
         aRes := { "IN (","" }
      EndIf
      oApl:oEmp:dbEval( {|o| aRes[1] += LTRIM(STR(o:OPTICA)) + ", ",;
                             aRes[2] += o:LOCALIZ +  " - " }       ,;
                        cModulo )
      aRes[1] := LEFT( aRes[1],LEN(aRes[1])-2 ) + ")"
   Else
      aRes := { " = " + LTRIM(STR(oApl:nEmpresa)),"" }
   EndIf
EndIf
RETURN aRes

//------------------------------------//
FUNCTION PListbox( oLbx,oTB )
 oLbx:SetFocus()
 If oTB:nRowCount == 0
    oLbx:Refresh()
 ElseIf oTB:nRowCount < oLbx:nLen
    //MsgInfo( oLbx:nLen,"DEL nRowCount"+STR(oTB:nRowCount) )
    oTB:GoTop():Read()
    oTB:xLoad()
    oLbx:nLen := oTB:nRowCount
    oLbx:Refresh()  ; oLbx:PageUp()
    //oLbx:PageDown()
 Else
    //MsgInfo( oLbx:nRowPos,"INS nRowCount"+STR(oTB:nRowCount)+If( oLbx:lHitBottom, "SI", "NO" ) )
    oLbx:nRowPos ++ ; oLbx:Refresh()
    oLbx:GoDown()
 EndIf
RETURN NIL

//------------------------------------//
FUNCTION SaldoFac( nFactura,xRet )
   LOCAL cTipo := If( xRet == NIL .OR. !IsAlpha( xRet ), oApl:Tipo, xRet )
/*
cQry := "SELECT s.saldo, s.anomes FROM cadfactm s "    +;
        "WHERE s.optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND s.numfac = " + LTRIM(STR(nFactura))     +;
         " AND s.tipo   = " + xValToChar( cTipo )      +;
         " AND s.anomes = (SELECT MAX(m.anomes) FROM cadfactm m "+;
                          "WHERE m.optica = s.optica"  +;
                           " AND m.numfac = s.numfac"  +;
                           " AND m.tipo   = s.tipo"    +;
                           " AND m.anomes <= '" + oApl:cPer + "')"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If MSNumRows( hRes ) > 0
   cQry := MyReadRow( hRes )
   AEVAL( cQry, { | xV,nP | cQry[nP] := MyClReadCol( hRes,nP ) } )
   oApl:nSaldo := cQry[1]
   xRet := If( xRet # NIL, cQry[1], !(cQry[2] != oApl:cPer) )
Else
   oApl:nSaldo := 0
   xRet := If( xRet # NIL, 0, .f. )
EndIf
MSFreeResult( hRes )
*/
If oApl:oFam:Seek( { "optica",oApl:nEmpresa,"numfac",nFactura,;
                     "tipo",cTipo,"anomes <= ",oApl:cPer },,.f. )
   oApl:nSaldo := oApl:oFam:SALDO
   xRet := If( xRet # NIL, oApl:nSaldo, !(oApl:oFam:ANOMES != oApl:cPer) )
Else
   oApl:nSaldo := 0
   xRet := If( xRet # NIL, 0, .f. )
EndIf
RETURN xRet

//------------------------------------//
FUNCTION SaldoInv( cCodig,cPer,xRet )
   LOCAL hRes, cQry
cQry := "SELECT s.existencia, s.pcosto, s.fec_ulte, s.fec_ults, s.anomes "+;
        "FROM cadinvme s "                                                +;
        "WHERE s.optica = " + LTRIM(STR(oApl:nEmpresa))                   +;
         " AND s.codigo = '" + TRIM(cCodig)                               +;
        "' AND s.anomes = (SELECT MAX(m.anomes) FROM cadinvme m "         +;
                          "WHERE m.optica = " + LTRIM(STR(oApl:nEmpresa)) +;
                           " AND m.codigo = '" + TRIM(cCodig)             +;
                          "' AND m.anomes <= '" + cPer + "')"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If MSNumRows( hRes ) > 0
   oApl:aInvme := MyReadRow( hRes )
   AEVAL( oApl:aInvme, { | xV,nP | oApl:aInvme[nP] := MyClReadCol( hRes,nP ) } )
   xRet := If( xRet # NIL, oApl:aInvme[1], !(oApl:aInvme[5] != cPer) )
Else
   oApl:aInvme := { 0,0,CTOD(""),CTOD(""),"" }
   xRet := If( xRet # NIL, 0, .f. )
EndIf
MSFreeResult( hRes )
If VALTYPE( xRet ) == "L" .AND. oApl:aInvme[2] == 0
   oApl:aInvme[2] := Buscar( {"codigo",cCodig},"cadinven","pcosto",8,,4 )
EndIf
RETURN xRet

//------------------------------------//
FUNCTION SgteNumero( cFieldName,nOptica,lSi )
   LOCAL cQry, aRes, hRes
   DEFAULT nOptica := oApl:nEmpresa, lSi := .t.
cFieldName := LOWER( cFieldName )
cQry := "SELECT " + (cFieldName) +;
        " FROM cadempre WHERE optica = " + LTRIM(STR(nOptica))
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
aRes := MyReadRow( hRes )
If lSi
   cQry := "UPDATE cadempre SET " + (cFieldName) + " = " +;
           (cFieldName) + " + 1 WHERE optica = " + LTRIM(STR(nOptica))
   MSQuery( oApl:oMySql:hConnect,cQry )
EndIf
MSFreeResult( hRes )
RETURN VAL(aRes[1]) + 1

//------------------------------------//
FUNCTION RunSql( cFileSql,cTitle )
   LOCAL oWnd, oMemo, oFont, oHand, oCol,oRow, cMemo:=""
   LOCAL cRuta := "\" + CURDIR() + "\"
   DEFAULT cTitle := "cTitle "
//SETKEY( VK_F8,{|| RunSql1( cMemo,cTitle ), oMemo:SetFocus() } )
   IF FILE(cFileSql)
      cMemo := MEMOREAD(cFileSql)
   ENDIF

   DEFINE CURSOR oHand RESOURCE "DEDO"
   DEFINE FONT oFont NAME "Courier New" BOLD SIZE 0,-14
                                                                                              //  1234567890             1234567890
   DEFINE WINDOW oWnd MDICHILD OF oApl:oWnd TITLE cTitle+" / "+cFileSql

//   oWnd:SetIcon(oIco)
   DEFINE BUTTONBAR OF oWnd _3D SIZE 33, 33 CURSOR oHand

   DEFINE BUTTON OF oWnd:oBar NOBORDER ;
      ACTION ( cFileSql := AbrirFile( 3,cRuta )                ,;
               IF( FILE(cFileSql), (cMemo := MEMOREAD(cFileSql),;
                   oMemo:Refresh() ), ) );
      FILENAME oApl:cIco+"OPEN.BMP" ;
      MESSAGE "Abrir un Archivo Sql";
      TOOLTIP "Abrir un Archivo Sql"
   DEFINE BUTTON OF oWnd:oBar NOBORDER;
      ACTION RCopiar( cRuta,cMemo )   ;
      RESOURCE "DEDISCO"              ;
      MESSAGE "Grabar un Archivo Sql" ;
      TOOLTIP "Grabar un Archivo Sql"
   DEFINE BUTTON OF oWnd:oBar NOBORDER ;
      ACTION ( RunSql1( cMemo,cTitle ) );
      FILENAME oApl:cIco+"RUN.BMP"  ;
      MESSAGE "Ejecutar Comando Sql";
      TOOLTIP "Ejecutar Comando Sql"
   DEFINE BUTTON OF oWnd:oBar NOBORDER ;
      ACTION ExportDBF( nil,cMemo );
      FILENAME oApl:cIco+"DBF.bmp" ;
      MESSAGE "Exportar Hacia DBF" ;
      TOOLTIP "Exportar Hacia DBF"
   DEFINE BUTTON OF oWnd:oBar NOBORDER ;
      ACTION ExportEXC( cMemo )        ;
      FILENAME oApl:cIco+"EXCEL.bmp"   ;
      MESSAGE "Exportar Hacia EXCEL"   ;
      TOOLTIP "Exportar Hacia EXCEL"
   DEFINE BUTTON OF oWnd:oBar NOBORDER ;
      ACTION oWnd:End() ;
      RESOURCE "Salir"  ;
      MESSAGE "Salir";
      TOOLTIP "Salir"
   SET MESSAGE OF oWnd TO cFileSql

   DEFINE MSGITEM oRow OF oWnd:oMsgBar PROMPT "Row: 1" SIZE 70
   DEFINE MSGITEM oCol OF oWnd:oMsgBar PROMPT "Col: 1" SIZE 70

   @ 0,0 GET oMemo VAR cMemo OF oWnd FONT oFont HSCROLL

   oWnd:oClient := oMemo

   ACTIVATE WINDOW oWnd ON INIT (oMemo:SetFocus());
      VALID .T.
//SETKEY( VK_F8,{|| .t. } )
RETURN NIL

//------------------------------------//
FUNCTION ExportDBF( oTb,uQry,cRuta,uMsg )
   LOCAL aDbf, cFile, cType, n, nRec := 0
   DEFAULT cRuta := oApl:cRuta2
If oTb == nil .OR. VALTYPE( oTb ) == "C"
   If (cFile:= oTb) == nil
      cFile := AbrirFile( 4,cRuta )
      cFile += IF( !"."$cFile, ".dbf","" )
      If FILE(cFile) .AND. !MsgYesNo("Archivo "+cFile+" ya existe","Desea Sobreescribir")
         RETURN .F.
      EndIf
   Else
      cFile := cRuta + cFile + ".dbf"
   EndIf
   FERASE( cFile )
   oTb := TMsQuery():Query( oApl:oDb,uQry )
   If oTb:Open()	 // Abrimos el conjunto resultado de la consulta
      oApl:oWnd:SetMsg( "Exportando hacia "+cFile )
      aDbf := {}
      FOR n := 1 TO oTb:nFieldCount
         cType := If( oTb:ClFieldType(n) == "B", "N", oTb:ClFieldType(n) )
         AADD( aDbf, { oTb:FieldName(n)  , cType,;
                       oTb:FieldLength(n), oTb:FieldDec(n) } )
      NEXT n
      dbCreate( cFile, aDbf )
      dbUseArea( .t.,, cFile,,.f. )
      oTb:GoTop()
      FOR n := 1 TO oTb:nRowCount
         aDbf := oTb:Read()
         dbAppend()      // Grabar registros
         AEVAL( aDbf, { |xV,nP| xV := MyClReadCol( oTb:hResult,nP ),;
                                FieldPut( nP,xV ) } )
         oTb:Skip(1)
      NEXT n
      dbCloseArea()
      nRec := oTb:nRowCount
      If uMsg == nil
         MsgInfo( STR(nRec)+" Registros Copiados","Comando Sql Ejecutado" )
      EndIf
   EndIf
   oTb:Close()		 // Destruimos el objeto y liberamos memoria
Else
   aDbf := MyDbStruct( oTb:hResult )
   AEVAL( aDbf, { | e | If( e[2] == "B", e[2] := "N", ) } )
   BorraFile( oTb:cName,{"DBF"},cRuta )
   dbCreate( cRuta + oTb:cName, aDbf )
   dbUseArea( .t.,, cRuta+oTb:cName,,.f. )
   If VALTYPE( uQry ) # "A"
      oTb:Seek( uQry,"CM" )
   Else
      oTb:Seek( uQry )
   EndIf
   oTb:GoTop()
// While oTb:Fetch()    //Salta, hace el read, controla registro y pone el eof
   While oTb:FetchRow() //Salta, hace el read pero no controla registro ni pone el eof
      dbAppend()
      FOR n := 1 TO oTb:nFieldCount
         FieldPut( n, oTb:xFieldGet( n ) )
      NEXT n
   EndDo
   dbCloseArea()
   nRec := oTb:nRowCount
   If oTb:cName == "cadclien" //.OR. oTb:cName == "historia"
      uQry := "UPDATE " + oTb:cName +;
              " SET exportar = '' WHERE exportar = '"+ uQry[2]+ "'"
      MSQuery( oApl:oMySql:hConnect,uQry )
   EndIf
EndIf
RETURN nRec

//------------------------------------//
FUNCTION ExportEXC( uQry,xModo )
   LOCAL aRS, cFile, cTxt, nF, oExcel, oTb
 cFile := cFilePath( GetModuleFileName( GetInstance() )) + "Test1.xls"
 If EMPTY(cFile)
    RETURN nil
 EndIf
If xModo == NIL
   oTb := TMsQuery():Query( oApl:oDb,uQry )
   If oTb:Open()
      oApl:oWnd:SetMsg( "Exportando hacia "+cFile )
      If oApl:lOffice
         cFile := STRTRAN( cFile,"xls","csv" )
         FERASE(cFile)
         oExcel := FCREATE(cFile,0) //, FC_NORMAL)
         If FERROR() != 0
            Msginfo(FERROR(),"No se pudo crear el archivo "+cFile )
            oTb:Close()
            RETURN nil
         EndIf
         cTxt := ""
         uQry := CHR(13) + CHR(10)  //CRLF
         FOR nF := 1 TO oTb:nFieldCount
            cTxt += '"'+STRTRAN(UPPER(oTb:FieldName(nF)),"'",'') +'",'
         NEXT nF
         FWRITE( oExcel,'"'+oApl:cEmpresa+'"'+uQry )
         FWRITE( oExcel,'""' + uQry )
         FWRITE( oExcel,LEFT( cTxt,LEN(cTxt)-1 )+uQry )
         oTb:GoTop()
         FOR nF := 1 TO oTb:nRowCount
            aRS := oTb:Read()
            cTxt:= ""
            AEVAL( aRS, { |xV,nP| xV := MyClReadCol( oTb:hResult,nP ),;
                                  cTxt += XTrim( xV,-9 )          } )
            FWRITE( oExcel,LEFT( cTxt,LEN(cTxt)-1 )+uQry )
            oTb:Skip(1)
         NEXT nF
         If !FCLOSE(oExcel)
            Msginfo( FERROR(),"Error cerrando el archivo "+cFile )
         EndIf
         WAITRUN("OPENOFICE.BAT " + cFile, 0 )
//"C:\Archivos de Programa\OpenOffice.org 3\program\scalc" -h
//"C:\Archivos de Programa\OpenOffice.org 3\program\scalc -o " + cFile
      Else
         oExcel := TExcelScript():New()
         oExcel:Create( cFile )
       //oExcel:Font("Verdana")
       //oExcel:Size(10)
       //oExcel:ColumnWidth( 1 , 25.00 )
         oExcel:Align(1)
         oExcel:Visualizar(.F.)
         oExcel:Say(  1 , 1 , oApl:cEmpresa )
         oExcel:Say(  2 , 2 , "MOVIMIENTO A " )

         FOR nF := 1 TO oTb:nFieldCount
            oExcel:Say(  3, nF, oTb:FieldName(nF) )
         NEXT nF

         oTb:GoTop()
         FOR nF := 1 TO oTb:nRowCount
            cTxt := oTb:Read()
            AEVAL( cTxt, { |xV,nP| xV := MyClReadCol( oTb:hResult,nP ),;
                                   oExcel:Say( nF+4, nP, xV ) } )
            oTb:Skip(1)
         NEXT nF
         oExcel:Visualizar(.T.)
         oExcel:End(.f.) ; oExcel := NIL
//      oExcel:Save()
      EndIf
   EndIf
   oTb:Close()
Else
   oTb    := TTxtFile():New( uQry )
   oExcel := TExcelScript():New()
   oExcel:Create( cFile )

   WHILE !oTb:lEoF()
      cTxt := oTb:cLine
      If !EMPTY(cTxt)
         oExcel:EVAL( cTxt )
      EndIf
      oTb:Skip( 1 )
   EndDo

   oExcel:End(.F.) ; oExcel := NIL
   oTb:End()       ; oTb    := NIL
EndIf
RETURN .T.

//------------------------------------//
STATIC PROCEDURE RCopiar( cRuta,cTexto )
   LOCAL cFile, hFile
cFile := AbrirFile( 3,cRuta )
cFile += If( !"." $ cFile, ".sql","" )
If cTexto # NIL .AND. !EMPTY( cTexto )
   hFile := FCREATE( cFile, 0 )
   FWRITE( hFile ,TRIM(cTexto) )
   FCLOSE( hFile )
EndIf
RETURN

//------------------------------------//
FUNCTION AbrirFile( nFilter,cDir,cArch )
   DEFAULT cDir := "\" + CURDIR() + "\", cArch := "*.txt"
RETURN cGetFile32("Texto (*.txt) | " + cArch + " |"  + ;
                  "Print (*.prn) | *.prn |"          + ;
                  "Archivos SQL (*.sql) | *.sql |"   + ;
                  "DataBase (*.dbf) | *.dbf |"       + ;
                  "Excel (*.xls) | *.xls |"          + ;
                  "Clipper Program (*.prg) | *.prg |"+ ;
                  "Windows Bitmap (*.bmp) | *.bmp |" + ;
                  "Separado por Coma(*.csv) | *.csv |",;
                  "Selecione uno", nFilter,cDir )

//------------------------------------//
PROCEDURE RunSql1( cQry,cTitle )
   LOCAL aLS, aRes, hRes, nL, nC, nSec, oRpt, oSql
   DEFAULT cTitle := "Comando SQL Ejecutado"
If !"SELECT" $ UPPER(cQry)
   If "WHERE" $ UPPER(cQry)
      If !MSQuery( oApl:oMySql:hConnect,cQry )
         oApl:oMySql:oError:Display( .f. )
      Else
         hRes := MSStoreResult( oApl:oMySql:hConnect )
         nL   := MSAffectedRows( oApl:oMySql:hConnect )
         MSFreeResult( hRes )
         MsgInfo( STR(nL)+" Registros Cambiados",cTitle )
      EndIf
   Else
      MsgInfo( "No Puedo hacer nada sin WHERE" )
   EndIf
   RETURN
EndIf
//MsgInfo( PrnGetPort() )
If LEFT( cQry,1 ) == "#"
   cTitle := Saca( @cQry,"#" )
   cTitle := Saca( @cQry,"#" )
EndIf
nSec := SECONDS()
oSql := TMsQuery():Query( oApl:oDb,cQry )
If oSql:Open()	         // Abrimos el conjunto resultado de la consulta
   //BrowseDB( oSql )
   oSql:GoTop()
   aLS  := ARRAY( 3,oSql:nFieldCount )
   cQry := ""
   FOR nL := 1 TO oSql:nFieldCount
      aLS[1,nL] := MAX( oSql:FieldLength(nL),LEN(oSql:FieldName(nL)) )+1
      If oSql:ClFieldType(nL) == "B" .OR.;
         oSql:ClFieldType(nL) == "N"
         aLS[2,nL] := 0
         aLS[3,nL] := "999,999,999,999" +;
                   If( oSql:FieldDec(nL) > 0, "."+REPLICATE("9",oSql:FieldDec(nL) ), "" )
         aLS[1,nL] := LEN( aLS[3,nL] )
         cQry += PADL( oSql:FieldName(nL),aLS[1,nL] ) + " "
         aLS[1,nL] ++
      Else
         cQry += PADR( oSql:FieldName(nL),aLS[1,nL] )
      EndIf
   NEXT nL
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,{ cTitle,"",cQry },.t.,1,;
             If( LEN( cQry ) > 80, 2, 1 ) )
   FOR nL := 1 TO oSql:nRowCount
      aRes := oSql:Read()
      nC   := 0
      oRpt:Titulo( 79 )
      AEVAL( aRes, { |xV,nP| If( aLS[3,nP] == NIL .OR. VALTYPE( aRes[nP] ) == "U"    ,;
                                 oRpt:Say( oRpt:nL,nC,aRes[nP] )                     ,;
                               (  aRes[nP] := VAL(aRes[nP])                          ,;
                                 oRpt:Say( oRpt:nL,nC,TRANSFORM(aRes[nP],aLS[3,nP]) ),;
                                 aLS[2,nP] += aRes[nP] )), nC += aLS[1,nP] } )
      oRpt:nL++
      oSql:Skip(1)
   NEXT nL
      nC  := 0
   FOR nL := 1 TO oSql:nFieldCount
      If aLS[3,nL] # NIL
         oRpt:Say( oRpt:nL,nC,TRANSFORM(aLS[2,nL],aLS[3,nL]) )
      EndIf
      nC += aLS[1,nL]
   NEXT nL
   oApl:oWnd:SetMsg( "Demore "+STR(SECONDS() - nSec)+" Segundos" )
   oRpt:NewPage()
   oRpt:End()
EndIf
oSql:Close()		 // Destruimos el objeto y liberamos memoria
RETURN