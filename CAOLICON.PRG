// Programa.: CAOLICON.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Medios Magneticos, Listo Tallas, Consultas y L.Contacto.
#include "FiveWin.ch"
#include "Xls.ch"

MEMVAR oApl

PROCEDURE MediosMg()
   LOCAL oDlg, oGet := ARRAY(7), oM
oM := TMedios() ; oM:New()
DEFINE DIALOG oDlg TITLE "MEDIOS MAGNETICOS" FROM 0, 0 TO 09,50
   @ 02, 00 SAY "FORMATO"   OF oDlg RIGHT PIXEL SIZE 88,10
   @ 02, 90 COMBOBOX oGet[1] VAR oM:aLS[1] ITEMS { "VENTAS","CARTERA","IVA" };
      SIZE 48,90 OF oDlg PIXEL
   @ 14, 00 SAY "PERIODO INICIAL"     OF oDlg RIGHT PIXEL SIZE 88,10
   @ 14, 90 GET oGet[2] VAR oM:aLS[2] OF oDlg PICTURE "999999" SIZE 30,10 PIXEL;
      VALID NtChr( oM:aLS[2],"P" )
   @ 26, 00 SAY "PERIODO   FINAL"     OF oDlg RIGHT PIXEL SIZE 88,10
   @ 26, 90 GET oGet[3] VAR oM:aLS[3] OF oDlg PICTURE "999999" SIZE 30,10 PIXEL;
      VALID NtChr( oM:aLS[3],"P" )
   @ 26,122 CHECKBOX oGet[4] VAR oM:aLS[4] PROMPT "Agrupar Opticas" OF oDlg;
       SIZE 60,10 PIXEL
   @ 38, 00 SAY "CUANTIAS MENORES"     OF oDlg RIGHT PIXEL SIZE 88,10
   @ 38, 90 GET oGet[5] VAR oM:aLS[5] OF oDlg PICTURE "999,999,999" ;
      VALID If( oM:aLS[5] >=  0, .t.                       ,;
          (MsgStop( "El Valor debe ser Mayor o Igual a 0","<< OJO >>"), .f.));
      SIZE 40,10 PIXEL
   @ 52, 50 BUTTON oGet[6] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ;
      ACTION ( oGet[6]:Disable(), oM:MediosDT(), oDlg:End() ) PIXEL
   @ 52,100 BUTTON oGet[7] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 58, 02 SAY "[CAOLICON]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT ( Empresa( .t. ) )
oM:Cerrar( .t. )
RETURN

//------------------------------------//
CLASS TMedios

 DATA aLS AS ARRAY INIT { 1,NtChr( DATE(),"1" ),"",.f.,0,"","","",0 }
 DATA cNit, cTB, nConce, nDV, oMed

 METHOD NEW( cOpt,lHis ) Constructor
 METHOD Cerrar( lCie )
 METHOD MediosDT()
 METHOD GrabarDT( aRes,lHis,lDeb )
 METHOD ArmoQuery()

ENDCLASS

//------------------------------------//
METHOD NEW( cOpt,lHis ) CLASS TMedios
 If cOpt == NIL
    ::aLS[3] := ::aLS[2]
    ::cTB := LOWER( ALLTRIM(oApl:cUser) ) + "mg"
    ::Cerrar( .f. )
    ::oMed := oApl:Abrir( ::cTB,"conce",,.f. )
 Else
    If ::aLS[1] == 1
       ::nConce := 4001
       If lHis
/*
SELECT sum(totalfac - totaliva) VENTA, SUM(totaldes) FROM cadfactu
WHERE optica IN(16, 19)
  AND fechoy >= '2012-01-01'
  AND fechoy <= '2012-12-31'
  AND indicador <> 'A'
  AND codigo_nit <> 123
*/
          ::aLS[8] := "SELECT n.nroiden, n.apellidos, n.nombres, n.direccion, n.reshabit, "   +;
                      "SUM(u.totalfac - u.totaliva) VENTA, SUM(u.totaldes), n.papel, n.pnomb "+;
                      "FROM historia n, cadfactu u "                +;
                      "WHERE u.codigo_cli = n.codigo_nit"           +;
                       " AND u.optica "    + cOpt                   +;
                       " AND u.fechoy >= " + xValToChar( ::aLS[6] ) +;
                       " AND u.fechoy <= " + xValToChar( ::aLS[7] ) +;
                       " AND u.tipo = 'U'"                          +;
                       " AND u.indicador <> 'A'"                    +;
                       " AND u.codigo_nit = 123"                    +;
                       " GROUP BY u.codigo_cli"
       Else
          ::aLS[8] := "SELECT n.codigo, n.digito, n.nombre, n.direccion, n.codigo_ciu, "+;
                            "SUM(u.totalfac - u.totaliva) VENTA, SUM(u.totaldes) "      +;
                      "FROM cadclien n, cadfactu u "                +;
                      "WHERE u.codigo_nit = n.codigo_nit"           +;
                       " AND u.optica "    + cOpt                   +;
                       " AND u.fechoy >= " + xValToChar( ::aLS[6] ) +;
                       " AND u.fechoy <= " + xValToChar( ::aLS[7] ) +;
                       " AND u.tipo = 'U'"                          +;
                       " AND u.indicador <> 'A'"                    +;
                       " AND u.codigo_nit <> 123"                   +;
                       " GROUP BY n.codigo"
       EndIf
    ElseIf ::aLS[1] == 2
       ::nConce := 1315
       If lHis
          ::aLS[8] := "SELECT n.nroiden, n.apellidos, n.nombres, n.direccion,"     +;
                       "n.reshabit, SUM(s.saldo) CARTERA, 0, n.papel, n.pnomb "    +;
                      "FROM cadfactm s, cadfactu u, historia n "                   +;
                      "WHERE u.codigo_cli = n.codigo_nit"                          +;
                       " AND u.optica "    + cOpt                                  +;
                       " AND u.fechoy <= " + xValToChar( ::aLS[7] )                +;
                       " AND u.tipo   = 'U'"                                       +;
                       " AND u.codigo_nit = 123"                                   +;
                       " AND s.optica = u.optica"                                  +;
                       " AND s.numfac = u.numfac AND s.tipo = u.tipo"              +;
                       " AND s.anomes = (SELECT MAX(m.anomes) FROM cadfactm m "    +;
                                        "WHERE m.optica = u.optica"                +;
                                         " AND m.numfac = u.numfac"                +;
                                         " AND m.tipo   = u.tipo"                  +;
                                         " AND m.anomes <= " + xValToChar(::aLS[3])+;
                      ") GROUP BY u.codigo_cli"
       Else
          ::aLS[8] := "SELECT n.codigo, n.digito, n.nombre, n.direccion, "         +;
                             "n.codigo_ciu, SUM(s.saldo) CARTERA, 0 "              +;
                      "FROM cadfactm s, cadfactu u, cadclien n "                   +;
                      "WHERE u.codigo_nit = n.codigo_nit"                          +;
                       " AND u.optica "    + cOpt                                  +;
                       " AND u.fechoy <= " + xValToChar( ::aLS[7] )                +;
                       " AND u.tipo   = 'U'"                                       +;
                       " AND u.codigo_nit <> 123"                                  +;
                       " AND s.optica = u.optica"                                  +;
                       " AND s.numfac = u.numfac AND s.tipo = u.tipo"              +;
                       " AND s.anomes = (SELECT MAX(m.anomes) FROM cadfactm m "    +;
                                        "WHERE m.optica = u.optica"                +;
                                         " AND m.numfac = u.numfac"                +;
                                         " AND m.tipo   = u.tipo"                  +;
                                         " AND m.anomes <= " + xValToChar(::aLS[3])+;
                      ") GROUP BY n.codigo"
       EndIf
    Else
       ::nConce := 0
       If lHis
          ::aLS[8] := "SELECT n.nroiden, n.apellidos, n.nombres, n.direccion, n.reshabit, "+;
                         "SUM(u.totaliva) IVA, 0, n.papel, n.pnomb "+;
                      "FROM historia n, cadfactu u "                +;
                      "WHERE u.codigo_cli = n.codigo_nit"           +;
                       " AND u.optica "    + cOpt                   +;
                       " AND u.fechoy >= " + xValToChar( ::aLS[6] ) +;
                       " AND u.fechoy <= " + xValToChar( ::aLS[7] ) +;
                       " AND u.tipo = 'U'"                          +;
                       " AND u.indicador <> 'A'"                    +;
                       " AND u.codigo_nit = 123"                    +;
                       " GROUP BY u.codigo_cli"
       Else
          ::aLS[8] := "SELECT n.codigo, n.digito, n.nombre, n.direccion,"+;
                                 " n.codigo_ciu, SUM(u.totaliva) IVA, 0 "+;
                      "FROM cadclien n, cadfactu u "                +;
                      "WHERE u.codigo_nit = n.codigo_nit"           +;
                       " AND u.optica "    + cOpt                   +;
                       " AND u.fechoy >= " + xValToChar( ::aLS[6] ) +;
                       " AND u.fechoy <= " + xValToChar( ::aLS[7] ) +;
                       " AND u.tipo = 'U'"                          +;
                       " AND u.indicador <> 'A'"                    +;
                       " AND u.codigo_nit <> 123"                   +;
                       " GROUP BY n.codigo"
       EndIf
    //MsgInfo( ::aLS[8] )
    EndIf
 EndIf
RETURN NIL

//------------------------------------//
METHOD Cerrar( lCie ) CLASS TMedios
If lCie
   ::oMed:Destroy()
   MSQuery( oApl:oMySql:hConnect,"DROP TABLE " + ::cTB )
Else
   If !oApl:oDb:ExistTable( ::cTB )
      MSQuery( oApl:oMySql:hConnect,"CREATE TABLE " + ::cTB + " LIKE mediosmg" )
   EndIf
EndIf
 oApl:oDb:GetTables()
RETURN NIL

//------------------------------------//
METHOD MediosDT() CLASS TMedios
   LOCAL aOP, aRes, hRes, nL
If ::aLS[2]  > ::aLS[3]
   aRes     := ::aLS[2]
   ::aLS[3] := ::aLS[2]
   ::aLS[2] := aRes
EndIf
::aLS[6] := CTOD( "01.01."+LEFT(::aLS[2],4) )
   aRes  := NtChr( ::aLS[3],"F" )
::aLS[7] := CTOD( NtChr( aRes,"4" ) )
::aLS[9] := { 1007,1008,1006 }[::aLS[1]]
 MSQuery( oApl:oMySql:hConnect,"DELETE FROM " + ::cTB )

aOP := Privileg( {"Principal",oApl:oEmp:PRINCIPAL,"Optica <> ",1},::aLS[4],;
                 If( ::aLS[1] == 2, .f., .t. ) )
 ::NEW( aOP[1],.t. )
aRes := "INSERT INTO " + ::cTB + " (row_id, conce, td, nit, dv, razonso, dpto, mcp) VALUES( 1, "+;
        STR(::nConce,4) + ", '43', '222222222', '0', 'CUANTIAS MENORES', '08', '001' )"
 MSQuery( oApl:oMySql:hConnect,aRes )

hRes := If( MSQuery( oApl:oMySql:hConnect,::aLS[8] ),;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
//MsgInfo( ::aLS[8],STR(nL) )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
   ::GrabarDT( aRes,.t.,.t. )
   nL --
EndDo
MSFreeResult( hRes )

 ::NEW( aOP[1],.f. )
hRes := If( MSQuery( oApl:oMySql:hConnect,::aLS[8] ),;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
   ::GrabarDT( aRes,.f.,.t. )
   nL --
EndDo
MSFreeResult( hRes )

If ::aLS[1] == 3
/*
   ::aLS[8] := "SELECT n.codigo, n.digito, n.nombre, n.direccion,"+;
                          " n.codigo_ciu, 0, SUM(d.montoiva) IVA "+;
               "FROM cadnotad d, cadnotac c, cadclien n "         +;
               "WHERE c.codigo_nit = n.codigo_nit"                +;
                " AND c.optica = d.optica"                        +;
                " AND c.numero = d.numero"                        +;
                " AND c.optica "   + aOP[1]                       +;
                " AND c.fecha >= " + xValToChar( ::aLS[6] )       +;
                " AND c.fecha <= " + xValToChar( ::aLS[7] )       +;
                " GROUP BY c.codigo_nit"
   hRes := If( MSQuery( oApl:oMySql:hConnect,::aLS[8] ),;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   While nL > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
      ::GrabarDT( aRes,.f.,.f. )
      nL --
   EndDo
   MSFreeResult( hRes )
*/
   ::aLS[8] := "SELECT n.nroiden, n.apellidos, n.nombres, n.direccion," +;
                "n.reshabit, 0, SUM(d.montoiva) IVA, n.papel, n.pnomb " +;
               "FROM cadnotad d, cadnotac c LEFT JOIN historia n "      +;
                 " ON c.nroiden = n.nroiden "                           +;
               "WHERE d.montoiva > 0"                                   +;
                " AND c.optica = d.optica"                              +;
                " AND c.numero = d.numero"                              +;
                " AND c.optica "   + aOP[1]                             +;
                " AND c.fecha >= " + xValToChar( ::aLS[6] )             +;
                " AND c.fecha <= " + xValToChar( ::aLS[7] )             +;
                " GROUP BY n.nroiden"
   hRes := If( MSQuery( oApl:oMySql:hConnect,::aLS[8] ),;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   While nL > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
      ::GrabarDT( aRes,.t.,.f. )
      nL --
   EndDo
   MSFreeResult( hRes )
EndIf
 ::ArmoQuery()
RETURN NIL

//------------------------------------//
METHOD GrabarDT( aRes,lHis,lDeb ) CLASS TMedios

 If aRes[6] < ::aLS[5]
    ::cNit := "222222222"
 ElseIf lHis
    ::cNit := NtChr( aRes[1],"N" )
    ::nDV  := DigitoVerifica( INT(VAL(::cNit)) )
 Else
    ::cNit := If( aRes[1] == 0, "222222222", LTRIM(STR(aRes[1],11,0)) )
    ::nDV  := aRes[2]
 EndIf
 If ::oMed:Seek( {"conce",::nConce,"nit",::cNit} )
    If lDeb
       ::oMed:VALOR_DEB += aRes[6]
    Else
       ::oMed:VALOR_CRE += aRes[6]
    EndIf
    ::oMed:RETENCION += aRes[7]
    ::oMed:Update(.f.,1)
 Else
    If EMPTY( aRes[5] )
       aRes[5] := "08001"
    EndIf
    ::oMed:CONCE := ::nConce        ; ::oMed:NIT       := ::cNit
    ::oMed:DV    :=  STR(::nDV,1)   ; ::oMed:DIRECCION := aRes[4]
    ::oMed:DPTO  := LEFT(aRes[5],2) ; ::oMed:MCP       := RIGHT(aRes[5],3)
    ::oMed:RETENCION    := aRes[7]
    If lDeb
       ::oMed:VALOR_DEB := aRes[6]
    Else
       ::oMed:VALOR_CRE := aRes[6]
    EndIf
    If lHis
       ::oMed:TD        := "13"
       ::oMed:APELLIDO1 := SUBSTR( aRes[2],1,aRes[8] )
       ::oMed:APELLIDO2 := SUBSTR( aRes[2],2+aRes[8] )
       ::oMed:NOMBRE1   := SUBSTR( aRes[3],1,aRes[9] )
       ::oMed:NOMBRE2   := SUBSTR( aRes[3],2+aRes[9] )
    Else
       ::oMed:TD        := "31"
       ::oMed:RAZONSO   := aRes[3]
    EndIf
    ::oMed:Append( .t. )
 EndIf
RETURN NIL

//------------------------------------//
METHOD ArmoQuery() CLASS TMedios
   LOCAL aTxt, cQry, nC, nF, oExcel, oTb
   LOCAL ptrHandle, cTexto
   LOCAL cFile := cFilePath( GetModuleFileName( GetInstance() ))
   cQry := "SELECT conce, td, nit, dv, apellido1, apellido2, nombre1, nombre2"
If ::aLS[9] == 1001 .OR. ::aLS[9] == 1008 .OR. ::aLS[9] == 1009
   //13 Columnas ->14
   cQry += ", razonso, direccion, dpto, mcp, 169 pais, ABS(valor_deb - valor_cre) valor"
ElseIf ::aLS[9] == 1002
   //14 Columnas
   cQry += ", razonso, direccion, dpto, mcp, retencion valor, ABS(valor_deb - valor_cre) retfte"
ElseIf ::aLS[9] == 1003
   //10 Columnas
   cQry += ", razonso, ABS(valor_deb - valor_cre) valor"
ElseIf ::aLS[9] ==  1005 .OR. ::aLS[9] == 1006
   // 9 Columnas ->10
   cQry := "SELECT td, nit, dv, apellido1, apellido2, nombre1, nombre2, "+;
           "razonso, ABS(valor_deb - valor_cre) valor, retencion devol"
ElseIf ::aLS[9] == 1007
   //11 Columnas ->17
   cQry += ", razonso, 169 pais, ABS(valor_deb - valor_cre) valor, 0 consor, 0 contra"
   cQry += ", 0 mineral, 0 fiducia, 0 tercero, retencion dscto"
 //cQry += ", razonso, ABS(valor_deb - valor_cre) valor, retencion dscto"
EndIf
   cQry += " FROM " + ::cTB + " WHERE ABS(valor_deb - valor_cre) > 0 ORDER BY valor DESC"
   cTexto := cFile + "FORM"+STR(::aLS[9],4) + ".txt"
   FERASE(cTexto)
   ptrHandle := FCREATE(cTexto,0) //, FC_NORMAL)
   If FERROR() != 0
      Msginfo(FERROR(),"No se pudo crear el archivo "+cTexto )
      RETURN nil
   EndIf

   oTb := TMsQuery():Query( oApl:oDb,cQry )
   If oTb:Open()
      oApl:oWnd:SetMsg( "Exportando hacia "+cTexto )
      cQry := ""
      FOR nC := 1 TO oTb:nFieldCount
         cQry += '"'+STRTRAN(UPPER(oTb:FieldName(nC)),"'",'')+'",'
      NEXT nC
         FWRITE( ptrHandle,'"FORMATO","'+STR(::aLS[9],4)+'","","'+oApl:cEmpresa+'"'+CHR(13)+CHR(10) )
         FWRITE( ptrHandle,LEFT( cQry,LEN(cQry)-1 )+CHR(13)+CHR(10) )

      oTb:GoTop()
      FOR nF := 1 TO oTb:nRowCount
         aTxt := oTb:Read()
         cQry := ""
//                             cQry += ('"=VALOR('+    xV +')",' ) } )
         AEVAL( aTxt, { |xV,nP| xV := MyClReadCol( oTb:hResult,nP ),;
                            If( VALTYPE( xV ) == "N"               ,;
                              ( xV := STRTRAN( STR(xV),".","," )   ,;
                                If( RIGHT(xV,3) == ",00"           ,;
                                   xV := LEFT( xV,LEN(xV)-3 ), )),),;
                                cQry += ('"'+    xV +'",' ) } )
         FWRITE( ptrHandle,LEFT( cQry,LEN(cQry)-1 )+CHR(13)+CHR(10) )
         oTb:Skip(1)
      NEXT nF
      If !FCLOSE(ptrHandle)
         Msginfo(FERROR(),"Error cerrando el archivo "+cTexto)
      EndIf
      XLS( cTexto )
   EndIf
   oTb:Close()
RETURN NIL

//------------------------------------//
FUNCTION XLS( cTexto )
   LOCAL oXls, oFile, cCelda, cTxt
   LOCAL f, i, j, lAlfa
   LOCAL cExcel := ""
If (j := RAT( "\",cTexto )) > 0
   cTxt   :=  LEFT( cTexto,j )
   cExcel := SUBSTR(cTexto,j+1 )
EndIf
    cTxt := STRTRAN( oApl:cRuta1,"Bitmap","Excel" )
  cExcel := AbrirFile( 5,cTxt,"*.XLS" )
  If EMPTY( cExcel )
     RETURN Nil
  EndIf
  cExcel += If( !"." $ cExcel, ".xls","" )

  oFile  := TTxtFile():New(cTexto)
  FERASE(cExcel)
  oApl:oWnd:SetMsg( "Exportando hacia "+cExcel )

  OPEN XLS oXls ;
    FILENAME cExcel

  f := 1
  WHILE !oFile:lEoF()
     cTxt := oFile:cLine
     If !EMPTY(cTxt)
        i := 1
        WHILE !EMPTY(cTxt)
           cCelda := Saca(@cTxt,'",')
           cCelda := StrTran(cCelda,'"')

           lAlfa := .f.
           FOR j=1 TO LEN(cCelda)
              If ISALPHA( SUBSTR(cCelda,j,1) )
                 lAlfa := .t.
                 Exit
              EndIf
           NEXT j
           If !lAlfa
              cCelda := ALLTRIM(cCelda)
           EndIf
           @ f, i SAY cCelda OF oXls
           i++
        ENDDO
     EndIf
     oFile:Skip( 1 )
     f++
  ENDDO

  CLOSE XLS oXls

  If MSGYESNO("Se ha generado el archivo Excel "+CRLF+CRLF+;
              cExcel+CRLF+CRLF+;
              "¿Desea poner en marcha Excel y visualizar el archivo?","Informe terminado")
     ShellExecute( ,,cExcel,'','',5)  //Ejecutamos Excel
  ENDIF

RETURN NIL

//----------CONSECUTIVOS--------------//
PROCEDURE CaoLiCon()
   LOCAL oDlg, oGet := ARRAY(6), aOpc := { CTOD(""),DATE(), 1, .f. }
   LOCAL aGrupo := { "TALLAS DE LENTES", "CONSULTAS","LENTES DE CONTACTO" }
DEFINE DIALOG oDlg TITLE "Listo Tallas y Consultas" FROM 0, 0 TO 10,50
   @ 02,00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02,92 GET oGet[1] VAR aOpc[1] OF oDlg SIZE 40,12 PIXEL
   @ 16,00 SAY "FECHA   FINAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 16,92 GET oGet[2] VAR aOpc[2] OF oDlg ;
      VALID aOpc[2] >= aOpc[1] SIZE 40,12 PIXEL
   @ 30,00 SAY "GRUPO A LISTAR"    OF oDlg RIGHT PIXEL SIZE 90,10
   @ 30,92 COMBOBOX oGet[3] VAR aOpc[3] ITEMS aGrupo SIZE 70,36 OF oDlg PIXEL
   @ 44,92 CHECKBOX oGet[4] VAR aOpc[4] PROMPT "Vista &Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 60, 50 BUTTON oGet[5] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[5]:Disable(), ListoRep( aOpc,aGrupo ), oDlg:End() ) PIXEL
   @ 60,110 BUTTON oGet[6] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 66, 02 SAY "[CAOLICON]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
STATIC PROCEDURE ListoRep( aLS,aGrp )
   LOCAL oLC, aCon := { 0,0,0,0,0,0,0,0,0 }, nF := aLS[3]
   LOCAL aRes, hRes, cQry, nL, oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"VENTAS DE LENTES DE CONTACTO","DEL " +;
          NtChr( aLS[1],"2" )+ " AL " + NtChr( aLS[2],"2" ),"" },aLS[4] )
If aLS[3] # 3
   oRpt:cFontI  := oRpt:CPICompress
   oRpt:aEnc[1] := "LISTADO DE FACTURAS CON " + aGrp[nF]
   oRpt:aEnc[3] := "NRO. ORDEN     # FACTURA    FECHA  C L I E N T E         "+;
        "P R E C I O   DESCUENTO      I.V.A.  VAL. ORDEN  P. PUBLICO  CANTIDAD"
EndIf
oLC := oApl:Abrir( "contacto","grupo, codigo" )
oLC:dbEval( {|o| o:CANTIDAD := o:VALOR := 0, o:Update( .f.,1 ) } )

cQry := "SELECT f.orden, f.numfac, f.fechoy, f.cliente, v.codart, "+;
        "v.cantidad, v.precioven, v.desmon, v.montoiva, v.ppubli " +;
        "FROM cadventa v, cadfactu f "+;
        "WHERE LEFT(v.codart," + {"4) IN('0201','0202')","4) = '0501'","2) >= '60'"}[nF]+;
         " AND f.optica = v.optica"   +;
         " AND f.numfac = v.numfac"   +;
         " AND f.tipo   = v.tipo AND v.indicador <> 'A'"+;
         " AND f.optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND f.fechoy >= "+ xValToChar( aLS[1] )     +;
         " AND f.fechoy <= "+ xValToChar( aLS[2] )     +;
         " AND f.tipo  = "  + xValToChar( oApl:Tipo )  +;
         " ORDER BY f.numfac"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL  := MSNumRows( hRes )) > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aGrp := { aRes[1],aRes[2],aRes[3],aRes[4] }
EndIf
While nL > 0
   If aLS[3] == 3
      If oLC:Seek( { "grupo","6","codigo",LEFT(aRes[5],4) } )
         oLC:CANTIDAD += aRes[6]
         oLC:VALOR    += aRes[7] ; oLC:Update(.f.)
      EndIf
   Else
      aCon[1] +=  aRes[07] + aRes[08]
      aCon[2] +=  aRes[08]
      aCon[3] +=  aRes[09]
      aCon[4] += (aRes[06] * aRes[10])
      aCon[5] +=  aRes[06]
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If (nL == 0 .OR. aRes[2] # aGrp[2]) .AND. aCon[5] > 0
      aCon[9] := aCon[1] + aCon[3] - aCon[2]
      oRpt:Titulo( 127 )
      oRpt:Say( oRpt:nL, 01,aGrp[1] )
      oRpt:Say( oRpt:nL, 12,If( aCon[9] # aCon[4], "*", "" ) )
      oRpt:Say( oRpt:nL, 15,aGrp[2] )
      oRpt:Say( oRpt:nL, 26,aGrp[3] )
      oRpt:Say( oRpt:nL, 37,aGrp[4] )
      oRpt:Say( oRpt:nL, 59,TRANSFORM(aCon[1],"99,999,999") )
      oRpt:Say( oRpt:nL, 71,TRANSFORM(aCon[2],"99,999,999") )
      oRpt:Say( oRpt:nL, 83,TRANSFORM(aCon[3],"99,999,999") )
      oRpt:Say( oRpt:nL, 95,TRANSFORM(aCon[9],"99,999,999") )
      oRpt:Say( oRpt:nL,107,TRANSFORM(aCon[4],"99,999,999") )
      oRpt:Say( oRpt:nL,122,TRANSFORM(aCon[5],"999") )
      oRpt:nL++
      aCon[6] ++
      aCon[7] += aCon[9]
      aCon[8] += aCon[5]
      aGrp := { aRes[1],aRes[2],aRes[3],aRes[4] }
      AFILL( aCon,0,1,5 )
   EndIf
EndDo
MSFreeResult( hRes )
If aLS[3] == 3
   oRpt:aEnc[3] := SPACE(10) + "CODIGO   N O M B R E                     CANTIDAD"
   oLC:Seek( { "cantidad >",0 },"codigo" )
   While !oLC:EOF()
      oRpt:Titulo( 60 )
      oRpt:Say( oRpt:nL,11,oLC:CODIGO )
      oRpt:Say( oRpt:nL,19,oLC:NOMBRE )
      oRpt:Say( oRpt:nL,52,TRANSFORM(oLC:CANTIDAD,"99,999") )
      oRpt:nL+= 2
      aCon[5] += oLC:CANTIDAD
      oLC:Skip(1):Read()
      oLC:xLoad()
   EndDo
   oRpt:Say(  oRpt:nL,10,REPLICATE("_",50),,,1 )
   oRpt:Say(++oRpt:nL,12,"TOTALES",,,1 )
   oRpt:Say(  oRpt:nL,52,TRANSFORM(aCon[5],"99,999") )
Else
   oRpt:Say(  oRpt:nL, 01,REPLICATE("_",127),,,1 )
   oRpt:Say(++oRpt:nL, 02,"TOTAL FACTURAS:",,,1 )
   oRpt:Say(  oRpt:nL, 20,TRANSFORM(aCon[6],"999") )
   oRpt:Say(  oRpt:nL, 94,TRANSFORM(aCon[7],"999,999,999") )
   oRpt:Say(  oRpt:nL,120,TRANSFORM(aCon[8],"9,999") )
EndIf
oRpt:NewPage()
oRpt:End()
oLC:Destroy()
RETURN

//------------------------------------//
PROCEDURE CgeLibro()
   LOCAL aLib, aLS, oDlg, oGet := ARRAY(7)
aLib := Buscar( "SELECT libro, folio FROM cgelibro","CM",,9 )
aLS  := { 1,1,1,1,.f.,"" }

DEFINE DIALOG oDlg TITLE "TIMBRAR LIBROS" FROM 0, 0 TO 09,54
   @ 02,00 SAY "ESCOJA EL LIBRO" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 02,82 COMBOBOX oGet[1] VAR aLS[1] ITEMS ArrayCol( aLib,1 );
      SIZE 129,99 OF oDlg PIXEL
   @ 14,00 SAY "DESDE EL FOLIO No." OF oDlg RIGHT PIXEL SIZE 80,10
   @ 14,82 GET oGet[2] VAR aLS[2] OF oDlg PICTURE "99999" SIZE 36,10 PIXEL ;
      VALID aLS[2] > 0
   @ 26,00 SAY "HASTA EL FOLIO No." OF oDlg RIGHT PIXEL SIZE 80,10
   @ 26,82 GET oGet[3] VAR aLS[3] OF oDlg PICTURE "99999" SIZE 36,10 PIXEL ;
      VALID aLS[3] >= aLS[2]
   @ 38, 00 SAY "Nro. DE COPIAS"    OF oDlg RIGHT PIXEL SIZE 80,10
   @ 38,82 GET oGet[4] VAR aLS[4] OF oDlg PICTURE "99999" SIZE 36,10 PIXEL ;
      VALID aLS[4] > 0
   @ 38,134 CHECKBOX oGet[5] VAR aLS[5] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,10 PIXEL
   @ 52, 50 BUTTON oGet[6] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[6]:Disable(), aLS[6] := aLib[ aLS[1],1 ],;
        Timbrar( aLS,oDlg ), oDlg:End() ) PIXEL
   @ 52,100 BUTTON oGet[7] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 58, 02 SAY "[CGELIBRO]" OF oDlg PIXEL SIZE 30,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED;
   ON INIT (Empresa( .t. ) )
RETURN

//------------------------------------//
STATIC PROCEDURE Timbrar( aLS,oDlg )
   LOCAL cEmp, cLib, nC, oRpt
//If aLS[4] == 1
   cEmp := PADC( oApl:cEmpresa,44 )
   cLib := PADC( aLS[6],30 ) + "   FOLIO No. "
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,,aLS[5] )
   oRpt:nPage := 1
   oRpt:SetFont( oRpt:CPINormal,82,2 )
   While aLS[2] <= aLS[3]
      FOR nC := 1 TO aLS[4]
         oRpt:Say( 01,00,oRpt:CPILarge + cEmp )
         oRpt:Say( 03,20,cLib + STR( aLS[2],6 ) )
         oRpt:NewPage()
      NEXT nC
      aLS[2] ++
   EndDo
   oRpt:End()
/*
Else
   ::Init( "TIMBRAR LIBROS", .f. ,, !::aLS[5] )
   cEmp := { ::Centrar( oApl:cEmpresa,::oFnt4 ),;
             ::Centrar( cLib,::oFnt2 ) }
   While ::aLS[2] <= ::aLS[3]
      PAGE
        UTILPRN ::oUtil 1.0,cEmp[1] SAY oApl:cEmpresa FONT ::oFnt4
        UTILPRN ::oUtil 2.0,cEmp[2] SAY cLib
        UTILPRN ::oUtil 2.0,16.0    SAY "FOLIO No." + STR( ::aLS[2],7 )
      ENDPAGE
      ::aLS[2] ++
   EndDo
   IMPRIME END .F.
EndIf
*/
RETURN