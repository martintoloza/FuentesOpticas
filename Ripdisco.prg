// Programa.: RIPDISCO.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Creacion de los Archivos planos en Diskette
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE Diskette( nOpc,oAd )
   LOCAL aRep, oR, oDlg, oGet := ARRAY(10)
If nOpc == 3
   oAd := TRip(); oAd:New( 2,.f. )
EndIf
  oR := TRips();  oR:New( nOpc )
aRep := { {|| oR:ArmoRepor( 1 ) },;
          {|| oR:ArmoRepor( 2 ) },;
          {|| oR:ArmoDatos( oDlg,oAd:oDb ) } }
DEFINE DIALOG oDlg TITLE oR:cTit FROM 0, 0 TO 18,70
   @  02, 00 SAY "Fecha Factura" OF oDlg RIGHT PIXEL SIZE 80,10
   @  02, 82 GET oGet[1] VAR oR:aLS[1] OF oDlg ;
      WHEN nOpc == 3           SIZE 40,10 PIXEL
   @  14, 00 SAY "Fecha Inicial a Facturada"   OF oDlg RIGHT PIXEL SIZE 80,10
   @  14, 82 GET oGet[2] VAR oR:aLS[2] OF oDlg SIZE 40,10 PIXEL
   @  26, 00 SAY "Fecha Final a Facturada"     OF oDlg RIGHT PIXEL SIZE 80,10
   @  26, 82 GET oGet[3] VAR oR:aLS[3] OF oDlg SIZE 40,10 PIXEL
   @  38, 00 SAY "Código Administradora - EPS" OF oDlg RIGHT PIXEL SIZE 80,10
   @  38, 82 BTNGET oGet[4] VAR oR:aLS[4] OF oDlg PICTURE "@!"       ;
      ACTION EVAL({|| If(oAd:Mostrar(), (oR:aLS[4] := oAd:oDb:CODIGO,;
                         oGet[4]:Refresh() ), ) })                   ;
      VALID EVAL( {|| If( oAd:oDb:Seek( {"codigo",oR:aLS[4]} )      ,;
                        (oR:aLS[9] := oAd:oDb:NOMBRE, oDlg:Update(), .t. ),;
                  (MsgStop("Esta Administradora no Existe .."),.f.) ) } )  ;
      SIZE 36,10 PIXEL  RESOURCE "BUSCAR"
    oGet[4]:cToolTip := "Ayuda de Administradoras [F2]"
   @  38,120 SAY oR:aLS[9] OF oDlg PIXEL SIZE 150,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @  50, 00 SAY "Número de la Factura" OF oDlg RIGHT PIXEL SIZE 80,10
   @  50, 82 GET oGet[5] VAR oR:aLS[5] OF oDlg ;
      WHEN nOpc == 3          SIZE  70,10 PIXEL
   @  62, 00 SAY "Número del Contrato"  OF oDlg RIGHT PIXEL SIZE 80,10
   @  62, 82 GET oGet[6] VAR oR:aLS[6] OF oDlg ;
      WHEN nOpc == 3          SIZE  70,10 PIXEL
   @  74, 00 SAY "Número de la Poliza"  OF oDlg RIGHT PIXEL SIZE 80,10
   @  74, 82 GET oGet[7] VAR oR:aLS[7] OF oDlg ;
      WHEN nOpc == 3          SIZE  70,10 PIXEL
   @  86, 00 SAY "Plan de Beneficios"   OF oDlg RIGHT PIXEL SIZE 80,10
   @  86, 82 GET oGet[8] VAR oR:aLS[8] OF oDlg ;
      WHEN nOpc == 3          SIZE 100,10 PIXEL
   @  98, 00 SAY "Total Moderadora ó CoPago" OF oDlg RIGHT PIXEL SIZE 80,10
   @  98, 82 SAY oR:aLS[10] OF oDlg PICTURE "999,999,999" ;
      SIZE 42,10 PIXEL UPDATE COLOR nRGB( 255,0,128 )
   @  98,126 SAY "Total a Facturar" OF oDlg RIGHT PIXEL SIZE 70,10
   @  98,198 SAY oR:aLS[11] OF oDlg PICTURE "999,999,999" ;
      SIZE 42,10 PIXEL UPDATE COLOR nRGB( 255,0,128 )

   @ 112, 50 BUTTON oGet[09] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[09]:Disable(), EVAL( aRep[nOpc] ), oDlg:End() ) PIXEL
    oGet[09]:cToolTip := "Si todo está Ok Pulsame"
   @ 112,100 BUTTON oGet[10] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 116, 02 SAY "[RIPDISCO]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER
If nOpc == 3
   oAd:oDb:Destroy()
EndIf
RETURN

//------------------------------------//
CLASS TRips
 DATA cTB, cTit
 DATA aLS  INIT { DATE()   , DATE()   , DATE()   , SPACE(06),;
                  SPACE(20), SPACE(15), SPACE(15), SPACE(30), "",0,0 }
 DATA aTB  INIT { "ripac","ripad","ripaf","ripat","ripus","ripct" }
 DATA oTB  INIT { ,,,,, }
 METHOD New( nOpc ) Constructor
 METHOD Cerrar( lCie )
 METHOD ArmoRepor( nT )
 METHOD ArmoDatos( oDlg,oArs )
 METHOD ATransac( cFac,dFec,nPago,nNeto )
 METHOD Control( cTipo )
 METHOD Usuarios( dFec )
 METHOD Espejo( cFile,cArc,cRut )
ENDCLASS

//------------------------------------//
METHOD New( nOpc ) CLASS TRips
 ::cTB  := LOWER( ALLTRIM(oApl:cUser) )
 ::cTit := { "Listar Pacientes Atendidos"  ,;
             "Listar Servicios a Pacientes",;
             "Datos para el RIPS" }[nOpc]
RETURN NIL

//------------------------------------//
METHOD Cerrar( lCie ) CLASS TRips
   LOCAL cF, nT, oTB
If lCie
   FOR nT := 1 TO 6
      ::oTB[nT]:Destroy()
      MSQuery( oApl:oMySql:hConnect,"DROP TABLE " + ::cTB + RIGHT(::aTB[nT],2) )
   NEXT nT
   oApl:oDb:GetTables()
Else
   FOR nT := 1 TO 6
      If !oApl:oDb:ExistTable( ::aTB[nT] )
         oTB := oApl:Abrir( ::aTB[nT],,,.t. )
         oTB:Destroy()
      EndIf
      cF := ::cTB + RIGHT(::aTB[nT],2)
      If !oApl:oDb:ExistTable( cF )
         MSQuery( oApl:oMySql:hConnect,"CREATE TABLE " + cF + " LIKE " + ::aTB[nT] )
         oApl:oDb:GetTables()
      EndIf
      ::oTB[nT] := oApl:Abrir( cF,,,.t. )
   NEXT nT
EndIf
RETURN NIL

//------------------------------------//
METHOD ArmoRepor( nL ) CLASS TRips
   LOCAL aRes, cQry, hRes, oRpt, nTF := 0
cQry := "SELECT r.fecha, r.factura, h.nroiden, "                   +;
        "CONCAT(h.nombres, ' ', h.apellidos), r.valor, r.valormod "+;
        "FROM historia h, " + {"ridconsu r ", "ridservi r "}[nL]   +;
        "WHERE r.codigo_nit = h.codigo_nit"                +;
         " AND r.optica     = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND r.fecha     >= " + xValToChar( ::aLS[2] )   +;
         " AND r.fecha     <= " + xValToChar( ::aLS[3] )   +;
         " AND r.codadmin   = " + xValToChar( ::aLS[4] )   +;
         " ORDER BY r.fecha"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::cTit, "DESDE " +;
          NtChr( ::aLS[2],"2" ) + " HASTA " + NtChr( ::aLS[3],"2" )       ,;
          SPACE(38) + ALLTRIM(::aLS[9])                                   ,;
          "  FECHA DE    NUMERO       DOCUMENTO                          "+;
          "                      V A L O R        V A L O R "             ,;
          "  ATENCION   FACTURA     IDENTIFICION   APELLIDOS Y NOMBRES---"+;
          "------------------ S E R V I C I O    C O P A G O"},.t.,,2 )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   oRpt:Titulo( 112 )
   oRpt:Say( oRpt:nL,00,NtChr( aRes[1],"2" ) )
   oRpt:Say( oRpt:nL,13,aRes[2] )
   oRpt:Say( oRpt:nL,24,aRes[3] )
   oRpt:Say( oRpt:nL,40,aRes[4],40 )
   oRpt:Say( oRpt:nL,82,TRANSFORM( aRes[5],"999,999,999.99" ) )
   oRpt:Say( oRpt:nL,98,TRANSFORM( aRes[6],"999,999,999.99" ) )
   oRpt:nL ++
   ::aLS[10] += aRes[5]
   ::aLS[11] += aRes[6]
   nTF ++
   nL --
EndDo
   MSFreeResult( hRes )
   oRpt:Say( oRpt:nL++,40,REPLICATE( "=",72 ) )
   oRpt:Say( oRpt:nL  ,40,STR( nTF,8) )
   oRpt:Say( oRpt:nL  ,69,"TOTALES ===>" )
   oRpt:Say( oRpt:nL  ,82,TRANSFORM( ::aLS[10],"999,999,999.99" ) )
   oRpt:Say( oRpt:nL++,98,TRANSFORM( ::aLS[11],"999,999,999.99" ) )
   ::aLS[10] -= ::aLS[11]
   oRpt:Say( oRpt:nL  ,82,TRANSFORM( ::aLS[10],"999,999,999.99" ) )
   oRpt:NewPage()
   oRpt:End()
RETURN NIL

//------------------------------------//
METHOD ArmoDatos( oDlg,oArs ) CLASS TRips
   LOCAL aRes, cTipo, cRut, hRes, nL, nK
   LOCAL aDes := { {"01",0,0,0} }
::Cerrar( .f. )

aRes := "SELECT codigo_nit, factura, fecha, autoriza, codcons, "+;
             "fincons, causaextr, coddiag, coddiag1, coddiag2, "+;
               "coddiag3, tipodiag, valormod, valor, valornet " +;
        "FROM ridconsu "                               +;
        "WHERE optica   = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND codadmin = " + xValToChar( ::aLS[4] )   +;
         " AND fecha   >= " + xValToChar( ::aLS[2] )   +;
         " AND fecha   <= " + xValToChar( ::aLS[3] )   +;
         " ORDER BY fecha"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
//1 [AC] Archivo de Consulta //
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   oApl:oHis:Seek( {"codigo_nit",aRes[1]} )
   ::oTB[1]:xBlank()
   ::oTB[1]:FACTURA  := If( EMPTY(aRes[2]), ::aLS[5], aRes[2] )
   ::oTB[1]:SGSSS    := oApl:oEmp:SGSSS  ; ::oTB[1]:TIPOIDEN  := oApl:oHis:TIPOIDEN
   ::oTB[1]:NROIDEN  := oApl:oHis:NROIDEN; ::oTB[1]:FECHA     := aRes[03]
   ::oTB[1]:AUTORIZA := aRes[04]         ; ::oTB[1]:CODIGO    := aRes[05]
   ::oTB[1]:FINCONS  := aRes[06]         ; ::oTB[1]:CAUSAEXTR := aRes[07]
   ::oTB[1]:CODDIAG  := aRes[08]         ; ::oTB[1]:CODDIAG1  := aRes[09]
   ::oTB[1]:CODDIAG2 := aRes[10]         ; ::oTB[1]:CODDIAG3  := aRes[11]
   ::oTB[1]:TIPODIAG := aRes[12]         ; ::oTB[1]:VALORCON  := aRes[14]
   ::oTB[1]:VALORMOD := aRes[13]         ; ::oTB[1]:VALORNET  := aRes[15]
//      ::oTB[1]:CODDIAG1  := If( EMPTY(aRes[09]), "0", aRes[09] )
   ::oTB[1]:Append( .f. )
   aDes[1,2] ++
   aDes[1,3] += aRes[13]
   aDes[1,4] += aRes[15]
   ::ATransac( ::oTB[1]:FACTURA,aRes[03],aRes[13],aRes[15] )
   ::Usuarios( aRes[03] )
   nL --
EndDo
MSFreeResult( hRes )

aRes := "SELECT codigo_nit, factura, autoriza, tiposerv, codservi, "+;
            "nombre, cantidad, valor, valormod, fecha "+;
        "FROM ridservi "                               +;
        "WHERE optica   = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND codadmin = " + xValToChar( ::aLS[4] )   +;
         " AND fecha   >= " + xValToChar( ::aLS[2] )   +;
         " AND fecha   <= " + xValToChar( ::aLS[3] )   +;
         " ORDER BY fecha"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
//4 [AT] Archivo de Otros Servicios //
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   cTipo  := { "09","14","06","07" }[VAL(aRes[4])]
   If (nK := ASCAN(aDes, {|aVal| aVal[1] == cTipo})) == 0
      AADD( aDes, { cTipo,0,0,0 } )
      nK  := LEN( aDes )
   EndIf
   aRes[7] := MAX( 1,aRes[7] )
   oApl:oHis:Seek( {"codigo_nit",aRes[1]} )
   ::oTB[4]:xBlank()
   ::oTB[4]:FACTURA  := If( EMPTY(aRes[2]), ::aLS[5], aRes[2] )
   ::oTB[4]:SGSSS    := oApl:oEmp:SGSSS  ; ::oTB[4]:TIPOIDEN := oApl:oHis:TIPOIDEN
   ::oTB[4]:NROIDEN  := oApl:oHis:NROIDEN; ::oTB[4]:AUTORIZA := aRes[3]
   ::oTB[4]:TIPOSERV := aRes[4]          ; ::oTB[4]:CODIGO   := aRes[5]
   ::oTB[4]:NOMBRE   := aRes[6]          ; ::oTB[4]:CANTIDAD := aRes[7]
   ::oTB[4]:VALORUND := aRes[8] / aRes[7]
   ::oTB[4]:VALORTOT := aRes[8]          ; ::oTB[4]:Append( .f. )
   aDes[nK,2] +=  aRes[7]
   aDes[nK,3] +=  aRes[9]
   aDes[nK,4] += (aRes[8] - aRes[9])
   ::ATransac( ::oTB[4]:FACTURA,aRes[10],aRes[9],aRes[8] )
   ::Usuarios( aRes[10] )
   nL --
EndDo
MSFreeResult( hRes )

/*2 [AD] Archivo de Descripcion Agrupada
01 Consultas                        02 Procedimientos de Diagnósticos
03 Procedimientos Terapéuticos n.q  04 Procedimientos Terapéuticos quirúrgicos
05 Procedimientos Promoción y prev  06 Estancias
07 Honorarios                       08 Derechos de Sala
09 Materiales e Insumos             10 Banco de Sangre
11 Prótesis y órtesis               12 Medicamentos POS
13 Medicamentos no POS              14 Traslados de Pacientes
*/
FOR nK := 1 TO LEN( aDes )
   If aDes[nK,2] > 0
      ::oTB[2]:xBlank()
      ::oTB[2]:FACTURA  := ::aLS[5]   ; ::oTB[2]:SGSSS    := oApl:oEmp:SGSSS
      ::oTB[2]:CONCEPTO := aDes[nK,1] ; ::oTB[2]:CANTIDAD := aDes[nK,2]
      ::oTB[2]:VALORUND := aDes[nK,4] / aDes[nK,2]
      ::oTB[2]:VALORTOT := aDes[nK,4]
      ::oTB[2]:Append( .f. )
   EndIf
   ::aLS[10] += aDes[nK,3]
   ::aLS[11] += aDes[nK,4]
NEXT nK

oDlg:Update()
If MsgYesNo( "Si esta todo Ok.", "Inserte un DISKETTE vacio en la Unidad" )
   cRut := AbrirFile( 1,,"*.txt" )
   If (nK := RAT( "\", cRut )) > 0
      cRut := LEFT( cRut,nK )
   Else
      cRut := "A:"
   EndIf
   SET DATE FORMAT TO "DD/MM/YYYY"

   cTipo:= " WHERE codigo = " + xValToChar( ::aLS[4] )
   aRes := "SELECT IFNULL( remision,0 ) +1 FROM ridars" + cTipo
   hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   If MSNumRows( hRes ) == 0
      aRes := { "1" }
   Else
      aRes := MyReadRow( hRes )
   EndIf
   MSFreeResult( hRes )
   Guardar( "UPDATE ridars SET remision = IFNULL( remision,0 ) +1" + cTipo, "ridars" )

   cTipo := STRZERO( VAL(aRes[1]),6 )
   aRes  := { "AC","AD","AF","AT","CT","US" }
   AEVAL( aRes, {|cFile| FERASE( cRut + cFile + "*.TXT" )} )

   ::Control( cTipo )
   ::Espejo( ::cTB+"ac","AC"+cTipo,cRut )
   ::Espejo( ::cTB+"ad","AD"+cTipo,cRut )
   ::Espejo( ::cTB+"af","AF"+cTipo,cRut )
   ::Espejo( ::cTB+"at","AT"+cTipo,cRut )
   ::Espejo( ::cTB+"ct","CT"+cTipo,cRut )
   ::Espejo( ::cTB+"us","US"+cTipo,cRut )
   SET DATE FORMAT TO "DD.MM.YYYY"
 //MsgInfo( "Número de Remisión "+cTipo )
   MsgStop( "Estan en la Carpeta "+cRut,"Número de Remisión "+cTipo )
EndIf
::Cerrar( .t. )

RETURN NIL

//3 [AF] Archivo de Transaccion ------//
METHOD ATransac( cFac,dFec,nPago,nNeto ) CLASS TRips
If !::oTB[3]:Seek( {"factura",cFac} )
   ::oTB[3]:SGSSS    := oApl:oEmp:SGSSS; ::oTB[3]:RAZONSOC  := oApl:oEmp:NOMBRE
   ::oTB[3]:TIPOIDEN := "NI"           ; ::oTB[3]:NROIDEN   := STRTRAN(STRTRAN(oApl:oEmp:NIT,"."),"-")
   ::oTB[3]:FACTURA  := cFac           ; ::oTB[3]:FECHA     := dFec
   ::oTB[3]:FECHAINI := ::aLS[2]       ; ::oTB[3]:FECHAFIN  := ::aLS[3]
   ::oTB[3]:CODADMIN := ::aLS[4]       ; ::oTB[3]:NOMBREADM := ::aLS[9]
   ::oTB[3]:CONTRATO := ::aLS[6]       ; ::oTB[3]:PLANBENE  := ::aLS[8]
   ::oTB[3]:POLIZA   := ::aLS[7]       ; ::oTB[3]:Append( .t. )
   //::oTB[3]:COMISION  : nComision    ; ::oTB[3]:DESCTOS  := nDesctos
EndIf
   ::oTB[3]:COPAGO += nPago
   ::oTB[3]:NETO   += nNeto ; ::oTB[3]:Update( .f.,1 )
RETURN NIL

//5 [CT] Archivo de Control------------//
METHOD Control( cTipo ) CLASS TRips
   LOCAL nK, nRec
FOR nK := 1 TO 5
   nRec := Buscar( "SELECT COUNT(*) FROM " + ::cTB + RIGHT(::aTB[nK],2),"CM",,8,,4 )
   If nRec > 0
      ::oTB[6]:xBlank()
      ::oTB[6]:SGSSS     := oApl:oEmp:SGSSS
      ::oTB[6]:FECHA     := ::aLS[3]
      ::oTB[6]:ARCHIVO   := UPPER( RIGHT(::aTB[nK],2) ) + cTipo
      ::oTB[6]:REGISTROS := LTRIM(STR(nRec,10,0))
      ::oTB[6]:Append( .f. )
   EndIf
NEXT nK
RETURN NIL

//6 [US] Archivo de Usuarios----------//
METHOD Usuarios( dFec ) CLASS TRips
   LOCAL nDias
If !::oTB[5]:Seek( {"nroiden",oApl:oHis:NROIDEN} )
   If EMPTY(oApl:oHis:FEC_NACIMI)
      ::oTB[5]:EDAD   := oApl:oHis:EDAD           ; ::oTB[5]:UNIEDAD  := oApl:oHis:UNIEDAD
   Else
      nDias := dFec - oApl:oHis:FEC_NACIMI
      ::oTB[5]:EDAD   := If( nDias/365 >= 1, ROUND(nDias/365,0),;
                         If( nDias/30  >= 1, ROUND(nDias/30 ,0), nDias) )
      ::oTB[5]:UNIEDAD:= If( nDias/365 >= 1, "1", If(nDias/30 >= 1, "2","3") )
   EndIf
   ::oTB[5]:TIPOIDEN  := oApl:oHis:TIPOIDEN       ; ::oTB[5]:NROIDEN  := oApl:oHis:NROIDEN
   ::oTB[5]:CODADMIN  := ::aLS[4]                 ; ::oTB[5]:TIPOUSUA := oApl:oHis:TIPOUSUA
   ::oTB[5]:PRIAPELLI := SUBSTR( oApl:oHis:APELLIDOS,1,oApl:oHis:PAPEL )
   ::oTB[5]:SEGAPELLI := SUBSTR( oApl:oHis:APELLIDOS,2+oApl:oHis:PAPEL )
   ::oTB[5]:PRINOMBRE := SUBSTR( oApl:oHis:NOMBRES  ,1,oApl:oHis:PNOMB )
   ::oTB[5]:SEGNOMBRE := SUBSTR( oApl:oHis:NOMBRES  ,2+oApl:oHis:PNOMB )
   ::oTB[5]:SEXO      := oApl:oHis:SEXO
   ::oTB[5]:DPTORH    :=  LEFT(oApl:oHis:RESHABIT,2)
   ::oTB[5]:MUNIRH    := RIGHT(oApl:oHis:RESHABIT,3)
   ::oTB[5]:ZONARESI  := oApl:oHis:ZONARESI
   ::oTB[5]:Append( .f. )
EndIf
RETURN NIL

//------------------------------------//
METHOD Espejo( cFile,cArc,cRut ) CLASS TRips
   LOCAL aRes, hFile, hRes, nL, nC
   LOCAL nCol, cRegis, cTipo
aRes := "SELECT * FROM " + cFile
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   RETURN NIL
EndIf
 cFile := cArc += ".TXT"
 nCol  := MyFieldCount( hRes )
 hFile := FCREATE( cArc, 0 )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   cRegis := ""
   FOR nC := 2 TO nCol
      cTipo := VALTYPE( aRes[nC] )
      do Case
      Case cTipo == "C"
         cRegis += ALLTRIM(aRes[nC]) + ","
      Case cTipo == "D"
         cRegis += DTOC( aRes[nC] ) + ","
      Case cTipo == "L"
         cRegis += If( aRes[nC], ".T.", ".F." ) + ","
      Case cTipo == "N"
         cRegis += ALLTRIM(STR( aRes[nC] )) + ","
//         cRegis += ALLTRIM(STR( aRes[nC],aEstru[nC,3],aEstru[nC,4] )) + ","
      EndCase
   NEXT nC
   cRegis := LEFT(cRegis,LEN(cRegis)-1)
   FWRITE( hFile, cRegis + CRLF )
   nL --
EndDo
   MSFreeResult( hRes )
   FCLOSE( hFile )
   cRut += cFile
   COPY FILE &(cFile) TO &(cRut)
FERASE( cArc )
RETURN NIL