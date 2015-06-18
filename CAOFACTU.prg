// Programa.: CAOFACTU.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Genera Factura de Remisiones.
#include "FiveWin.ch"
#include "btnget.ch"
#include "UtilPrn.ch"

MEMVAR oApl

PROCEDURE CaoFactu()
   LOCAL aOP, oA, oNi, oDlg, oGet := ARRAY(11)
oA  := TFacture()
oNi := TNits() ; oNi:New()
aOP := { { "Totalizar"          ,{|| oA:ResCotiz( oDlg ) } },;
         { "Resumen Factura"    ,{|| oA:ResFactu( oDlg ) } },;
         { "Listar Cotizaciones",{|| oA:Facturar( oDlg ) } },;
         { "Facturar"           ,{|| oA:Facturar( oDlg ) } },;
         { "FAN Amigos Niños"   ,{|| oA:FanChild() } } }
DEFINE DIALOG oDlg TITLE "Facturación de Remisión" FROM 0, 0 TO 16,50
   @ 02, 00 SAY "Nit o C.C. del Cliente" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 02,102 BTNGET oGet[1] VAR oA:aLS[1] OF oDlg PICTURE "9999999999";
      ACTION EVAL({|| If(oNi:Mostrar(), (oA:aLS[1] := oNi:oDb:CODIGO,;
                         oGet[1]:Refresh() ),) })                    ;
      VALID EVAL( {|| If( oNi:Buscar( oA:aLS[1],"codigo",.t. )      ,;
                        ( oDlg:Update(), .t. )                      ,;
                     (MsgStop("Este Nit ó C.C. no Existe"), .f.) ) });
      SIZE 50,10 PIXEL RESOURCE "BUSCAR"
   @ 14, 30 SAY oGet[2] VAR oNi:oDb:NOMBRE OF oDlg PIXEL SIZE 120,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 26, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 26,102 GET oGet[3] VAR oA:aLS[2] OF oDlg  SIZE 44,10 PIXEL
   @ 38, 00 SAY "FECHA   FINAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 38,102 GET oGet[4] VAR oA:aLS[3] OF oDlg ;
      VALID oA:aLS[3] >= oA:aLS[2] SIZE 44,10 PIXEL
   @ 50, 00 SAY  "NUMERO FACTURA ANTERIOR" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 50,102 GET oGet[5] VAR oA:aLS[4] OF oDlg PICTURE "9999999999" SIZE 44,10 PIXEL
   @ 62, 00 SAY    "ESCOJA OPCION DESEADA" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 62,102 COMBOBOX oGet[6] VAR oA:aLS[5] ITEMS ArrayCol( aOP,1 ) SIZE 76,99 OF oDlg PIXEL
   @ 74, 10 GET oGet[7] VAR oA:aLS[7] OF oDlg PICTURE "@!" PIXEL SIZE 90,10 ;
      UPDATE COLOR nRGB( 160,19,132 )
   @ 74,102 CHECKBOX oGet[8] VAR oA:aLS[6] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,10 PIXEL
   @ 86, 00 SAY "CLASE DE LISTADO"   OF oDlg RIGHT PIXEL SIZE 100,10
   @ 86,102 COMBOBOX oGet[9] VAR oA:aLS[9] ITEMS { "Matriz","Laser","Excel" };
      SIZE 48,90 OF oDlg PIXEL
   @ 102, 50 BUTTON oGet[10] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[10]:Disable(), oA:aLS[1] := oNi:oDb:CODIGO_NIT    ,;
        oA:aLS[8] := If( oA:aLS[7] == "FOCA", 21, oApl:nEmpresa ),;
        EVAL( aOP[ oA:aLS[5],2 ] ), oDlg:End() ) PIXEL
   @ 102,100 BUTTON oGet[11] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 108, 02 SAY "[CAOFACTU]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
CLASS TFacture FROM TIMPRIME

 DATA aLS  INIT { 0,DATE(),DATE(),0,1,.t.,"    ",0,oApl:nTFor }

 METHOD Facturar( oDlg )
 METHOD Ventas( nNumFac,aDet,nOptica )
 METHOD ResFactu( oDlg )
 METHOD Poder( cX,cTB )
 METHOD ResCotiz( oDlg )
 METHOD LaserCot( hRes,nL )
 METHOD FanChild()
 METHOD FanExcel( hRes,nL )
 METHOD GrabaFan( aVT,cSer,nValor,cQry )
ENDCLASS

//34----------------------------------//
METHOD Facturar( oDlg ) CLASS TFacture
   LOCAL aDet, aTF := {}, nK, nPago
   LOCAL aFac := ArrayCombo( oApl:oNit:TIPOFAC )
AEVAL( aFac, { |x| AADD( aTF, { 0,0,0,0,0,0,UPPER(x[1]),x[2],0 } ) } )
oDlg:SetText( "<< ESPERE >> GENERANDO FACTURA" )
aFac := { "DEL " + NtChr( ::aLS[2],"2" ) + " AL " + NtChr( ::aLS[3],"2" ),;
          .f.," ","","" }
If ::aLS[1] == 48   // Intercor
/* aDet := { {"0201      ","LENTES MONOFOCALES"      ,0,0,0,0,0,0,0},;
             {"0201      ","LENTES BIFOCAL FLAT TOP" ,0,0,0,0,0,0,0},;
             {"0201      ","LENTES BIFOCAL INVISIBLE",0,0,0,0,0,0,0},;
             {"0201      ","LENTES PROGRESIVOS"      ,0,0,0,0,0,0,0},;
             {"0599000002","COLOR"                   ,0,0,0,0,0,0,0},;
             {"0599000002","FILTRO UV"               ,0,0,0,0,0,0,0},;
             {"0599000002","VARIOS"                  ,0,0,0,0,0,0,0} } */
   aDet := { {"0599000002","FACTURACION  CORRESPONDIENTE AL  SUMINIS",0,0,0,0,0,0,0},;
             {"0599000002","TRO DE LENTES OFTALMICOS SEGUN ORDENES Y",0,0,0,0,0,0,0},;
             {"0599000002","REMISIONES ADJUNTAS "+ LEFT( aFac[1],18 ),0,0,0,0,0,0,0},;
             {"0599000002",RIGHT( aFac[1],11 ),0,0,0,0,0,0,0} }
   aFac[1] := ""
   aFac[5] := "SELECT SUM(cantidad * pcosto) FROM cadantid "   +;
              "WHERE codart IN('0201', '0202', '0503', '0505')"+;
               " AND optica = " + LTRIM(STR(oApl:nEmpresa))    +;
               " AND numero = [X]"
Else
   aDet := { {"0599000001","MONTURAS"         ,0,0,0,0,0,0,0},;
             {"0599000002","LENTES OFTALMICOS",0,0,0,0,0,0,0},;
             {"0599000003","LENTES CONTACTOS" ,0,0,0,0,0,0,0},;
             {"0501"      ,"CONSULTAS"        ,0,0,0,0,0,0,0},;
             {"0502"      ,"AJUSTES MONTURAS" ,0,0,0,0,0,0,0},;
             {"0503"      ,"COLOR_TRATAMIENTO",0,0,0,0,0,0,0} }
EndIf
If ::aLS[4] > 0
   oApl:oFac:Seek( {"optica",oApl:nEmpresa,"numfac",::aLS[4],"tipo",oApl:Tipo} )
   aFac[3] := oApl:oFac:TIPOFAC
EndIf
oApl:oEmp:Seek( {"optica",oApl:nEmpresa} )
oApl:cPer := NtChr( oApl:oEmp:FEC_HOY,"1" )
oApl:lFam := .f.
oApl:Tipo := If( ::aLS[5] == 3, "Z", "U" )
oApl:oAtc:Seek( { "optica",::aLS[8],"codigo_nit",::aLS[1],"fecha >=",::aLS[2],;
                  "fecha <=",::aLS[3],"indicador <>","A" },"tipofac, numero" )
nK := ASCAN( aTF, { |x| x[8] == oApl:oAtc:TIPOFAC } )
While !oApl:oAtc:EOF()
   If Rango( oApl:oAtc:NUMFAC,{ 0,::aLS[4] } )
      ::aLS[7] := "Cotiz" + STR(oApl:oAtc:NUMFAC)
      oDlg:Update()
      aFac[2] := If( ::aLS[4] > 0 .AND. oApl:oAtc:TIPOFAC # aFac[3], .f., .t. )
//      nK := If( ::aLS[1] # 48, 1, If( oApl:oAtc:TIPOFAC == "R", 1, 2 ))
      aTF[nK,2] += oApl:oAtc:TOTALDES
      aTF[nK,3] += oApl:oAtc:TOTALIVA
      aTF[nK,4] += oApl:oAtc:TOTALFAC
      If ::aLS[5] == 3
         aDet := Buscar( {"optica",::aLS[8],"numero",oApl:oAtc:NUMERO},"cadantid",;
                          "codart, descri, ppubli, cantidad, despor, desmon, " +;
                          "precioven, montoiva, 'P', 0, 0, 1, 0, ordenemp",9 )
         CaoLiFac( oApl:oAtc:NUMERO,aDet,{"0",aTF[nK,7]} )
      ElseIf aFac[2]
         If aTF[nK,5] == 0
            aTF[nK,5] := SgteNumero( "numfacu",oApl:nEmpresa,.t. )
            aTF[nK,6] := If( ::aLS[1] == 48, 0, aTF[nK,5] )
            ::aLS[7]  := If( EMPTY(aTF[nK,7]), "REMISIONES ADJUNTAS", aTF[nK,7] )+;
                             " - " + oApl:oNit:NOMBRE
            BuscaDup( aTF[nK,5],oApl:Tipo,.t. )
            oApl:oFac:Seek( {"optica",oApl:nEmpresa,"numfac",aTF[nK,5],"tipo",oApl:Tipo} )
            oApl:oFac:OPTICA     := oApl:nEmpresa; oApl:oFac:NUMFAC  := aTF[nK,5]
            oApl:oFac:TIPO       := oApl:Tipo    ; oApl:oFac:CLIENTE := XTrim( ::aLS[7],29 )
            oApl:oFac:FECHOY     := oApl:oFac:FECHAENT := oApl:dFec
            oApl:oFac:DIRECC     := aFac[1]
            oApl:oFac:CODIGO_NIT := ::aLS[1]
            oApl:oFac:CODIGO_CLI := oApl:oAtc:CODIGO_CLI
            oApl:oFac:AUTORIZA   := If( ::aLS[8] == 21, "FOCA", "LIBRANZA" )
            oApl:oFac:INDICADOR  := "P"          ; oApl:oFac:TIPOFAC := aTF[nK,8]
            oApl:oFac:REMPLAZA   := aTF[nK,6]    ; oApl:oFac:Append( .t. )
         EndIf
         If ::aLS[1] # 48
            ::Ventas( aTF[nK,5],@aDet,::aLS[8] )  //,aLS[1]
         Else
            ::aLS[7] := Buscar( STRTRAN( aFac[5],"[X]",LTRIM(STR(oApl:oAtc:NUMERO)) ),"CM",,8,,4 )
            ::aLS[7] := (aTF[nK,1] * aTF[nK,9] + ::aLS[7]) / (aTF[nK,1] + 1)
            aTF[nK,9] := ROUND( ::aLS[7],2 )
         EndIf
         aTF[nK,1] ++
         oApl:oAtc:NUMFAC := aTF[nK,5] ; oApl:oAtc:Update( .t.,1 )
      EndIf
   EndIf
   oApl:oAtc:Skip(1):Read()
   oApl:oAtc:xLoad()
   If oApl:oAtc:EOF() .OR. oApl:oAtc:TIPOFAC # aTF[nK,8]
      If aTF[nK,1] > 0
         If ::aLS[1] == 48   // Intercor
            aDet[1,3] := aTF[nK,1] ; aDet[1,4] := aTF[nK,4] - aTF[nK,3]
            aDet[1,6] := aTF[nK,2] ; aDet[1,7] := aTF[nK,3]
            aDet[1,9] := aTF[nK,9]
         EndIf
/*       If ::aLS[1] # 123
            If (nPago := aTF[nK,4] - aTF[nK,3]) >= oApl:oEmp:TOPERET
               oApl:oFac:RETFTE := ROUND( nPago * oApl:oEmp:PRET,0 )
            EndIf
         EndIf*/
         oApl:oFac:TOTALDES := aTF[nK,2] ; oApl:oFac:TOTALIVA := aTF[nK,3]
         oApl:oFac:TOTALFAC := aTF[nK,4] ; oApl:oFac:Update( .t.,1 )
         oApl:lFam   := SaldoFac( aTF[nK,5] )
         oApl:nSaldo := aTF[nK,4] // - oApl:oFac:RETFTE
         GrabaSal( aTF[nK,5],1,0 )
         GrabaVen( aDet,aTF[nK,6] )
      EndIf
      If aTF[nK,4] > 0
         aFac[4] += aTF[nK,7] + TRANSFORM( aTF[nK,4],"99,999,999" ) + CRLF
      EndIf
      AEVAL( aDet, { |x| AFILL( x,0,3 ) } )
      nK := ASCAN( aTF, { |x| x[8] == oApl:oAtc:TIPOFAC } )
   EndIf
EndDo
oApl:Tipo := "U"
MsgInfo( aFac[4],"TOTAL FACTURAS" )
RETURN NIL

//------------------------------------//
METHOD Ventas( nNumFac,aDet,nOptica ) CLASS TFacture
   LOCAL aVen, nC, nV, aR := { "","",0,oApl:oAtc:VALOROT }
aVen := Buscar( {"optica",nOptica,"numero",oApl:oAtc:NUMERO}     ,;
                 "cadantid","codart, descri, cantidad, precioven"+;
                 ", despor, desmon, montoiva, ppubli, pcosto",9 )
oApl:oVen:Seek( {"optica",oApl:nEmpresa,"numfac",nNumFac,"tipo",oApl:Tipo} )
FOR nC := 1 TO LEN( aVen )
   aR[1] := RTRIM( aVen[nC,1] )
   If LEFT( aR[1],2 ) # "05" .AND. LEN( aR[1] ) >= 10
      oApl:oVen:Seek( {"row_id",0} )
      oApl:oVen:OPTICA   := oApl:nEmpresa; oApl:oVen:NUMFAC    := nNumFac
      oApl:oVen:TIPO     := oApl:Tipo    ; oApl:oVen:FECFAC    := oApl:dFec
      oApl:oVen:CODART   := aVen[nC,1]   ; oApl:oVen:DESCRI    := aVen[nC,2]
      oApl:oVen:CANTIDAD := aVen[nC,3]   ; oApl:oVen:PRECIOVEN := aVen[nC,4]
      oApl:oVen:DESPOR   := aVen[nC,5]   ; oApl:oVen:DESMON    := aVen[nC,6]
      oApl:oVen:MONTOIVA := aVen[nC,7]   ; oApl:oVen:PPUBLI    := aVen[nC,8]
      oApl:nEmpresa := nOptica
      Guardar( oApl:oVen,.t.,.t. )
      GrabaV( aVen[nC,3],"N",2,oApl:dFec,oApl:oAtc:NUMERO,1 )
      oApl:nEmpresa := oApl:oFac:OPTICA
   ElseIf aR[1] # "0203"
//      aR[2] := RIGHT( TRIM(aVen[nC,2]),2 )
      aR[3] := 0
//      nV    := 7
      do Case
/*    Case aR[1] == "0201" .AND. nCodigo == 48 .AND. aR[2] == "11"
         nV := 1
      Case aR[1] == "0201" .AND. nCodigo == 48 .AND. aR[2] == "21"
         nV := 2
      Case aR[1] == "0201" .AND. nCodigo == 48 .AND. aR[2] == "24"
         nV := 3
      Case aR[1] == "0201" .AND. nCodigo == 48 .AND. "5" $ aR[2]
         nV := 4
      Case aR[1] == "0599000002" .AND. nCodigo == 48
         nV :=  If( "COLOR" $ aVen[nC,2], 5, If( "UV" $ aVen[nC,2], 6, 7 ))
*/
      Case LEFT( aR[1],2 ) == "02"
         aR[1] := "0599000002"
      // aR[3] := aR[4]
      // aR[4] := 0
      Case LEFT( aR[1],2 ) >= "60"
         aR[1] := "0599000003"
      Case aR[1] == "0504"
         aR[1] := "0502"
      Case aR[1] == "0505" .OR. aR[1] == "0599"
         aR[1] := "0503"
      EndCase
      //If nCodigo # 48
         nV := ASCAN( aDet, {|aVal| aVal[1] == aR[1]} )
         nV := If( nV == 0, 6, nV )
      //EndIf
      aR[3] := (aDet[nV,3] * aDet[nV,9] + aVen[nC,3] * aVen[nC,9]) /;
               (aDet[nV,3] + aVen[nC,3])
      aDet[nV,3] += aVen[nC,3] ; aDet[nV,4] += aVen[nC,4]
      aDet[nV,6] += aVen[nC,6] ; aDet[nV,7] += aVen[nC,7]
      aDet[nV,8] += aVen[nC,8] ; aDet[nV,9] := ROUND( aR[3],2 )
   EndIf
NEXT nC
RETURN NIL

//2-----------------------------------//
METHOD ResFactu( oDlg ) CLASS TFacture
   LOCAL aRes, hRes, nL, nP
   LOCAL aX := ARRAY(7), oRpt, oTb, nVU, nGT := 0
aRes := "SELECT d.codart, d.descri, d.cantidad, d.precioven, d.ordenemp "+;
        "FROM cadantic c LEFT JOIN cadantid d "        +;
          "USING(optica, numero) "                     +;
        "WHERE c.optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.codigo_nit = " + LTRIM(STR(::aLS[1])) +;
         " AND c.fecha >= " +  xValToChar( ::aLS[2] )  +;
         " AND c.fecha <= " +  xValToChar( ::aLS[3] )  +;
         " AND c.tipofac = 'D'"                        +;
         " AND c.indicador <> 'A'"  + If( ::aLS[4] > 0 ,;
         " AND c.numfac IN(0, " + LTRIM(STR(::aLS[4])) + ")", "" )
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   RETURN NIL
EndIf
oTb := oApl:Abrir( "cadlente","codigo",,.t. )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   AFILL( aX,"" )
   If TRIM(aRes[1]) == "0201"
      nP    := AT( ".",SUBSTR( aRes[2],12 ) ) + 11
      aX[4] := SUBSTR( aRes[2],nP,37-nP )
      aX[5] := If( EMPTY(aRes[5]), RIGHT(aRes[2],2), SUBSTR(aRes[5],3,2) )
      aX[6] := If( aX[5] == "11", 1, If( aX[5] == "21", 3,;
               If( aX[5] == "24", 5, 7 )))
      If (nP := AT( "E",aX[4] )) > 0
         aX[1] := SUBSTR( aX[4],nP+1,6 )
         aX[5] += If( AT( "-",aX[1] ) > 0, "2", "1" ) + LEFT( ::Poder( aX[1] ),3 )
      EndIf
      If (nP := AT( "C",aX[4] )) > 0
         aX[2] := SUBSTR( aX[4],nP+1,6 )
         aX[5] += LEFT( ::Poder( aX[2] ),3 )
         aX[6] ++
      ElseIf aX[6] > 1
         aX[5] += "   "
      EndIf
      If (nP := AT( "A",aX[4] )) > 0
         aX[3] := SUBSTR( aX[4],nP+1,4 )
         aX[5] += SUBSTR( ::Poder( aX[3] ),2,2 )
      EndIf
   Else
      aX[5] := If( "COLOR" $ aRes[2], "900", ;
               If( "UV"    $ aRes[2], "910", "920" ))
      aX[6] := If( aX[5] == "900", 9, If( aX[5] == "910", 10, 11 ))
   EndIf
   aX[5] := PADR( aX[5],12 )
   If oTb:Seek( {"codigo",aX[5]} )
      oTb:CANTIDAD += aRes[3]
      oTb:VALOR    += aRes[4]
      oTb:Update( .t.,1 )
   Else
      oTb:CODIGO   := aX[5] ; oTb:TIP := aX[6]
      oTb:ESF      := aX[1] ; oTb:CIL := aX[2]
      oTb:ADI      := aX[3]
      oTb:CANTIDAD := aRes[3]
      oTb:VALOR    := aRes[4]
      oTb:Append( .t. )
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
aX := { {"MONOFOCAL ESFERICO"         ,0,0},{"MONOFOCAL ESFEROCIL"        ,0,0},;
        {"BIFOCAL FLAT-TOP ESFERICO"  ,0,0},{"BIFOCAL FLAT-TOP ESFEROCIL" ,0,0},;
        {"BIFOCAL INVISIBLE ESFERICO" ,0,0},{"BIFOCAL INVISIBLE ESFEROCIL",0,0},;
        {"PROGRESIVO ESFERICO"        ,0,0},{"PROGRESIVO ESFEROCIL"       ,0,0},;
        {"COLOR"                      ,0,0},{"FILTRO UV"                  ,0,0},;
        {"VARIOS"                     ,0,0} }
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ALLTRIM(oApl:oNit:NOMBRE)+;
         " DIVISION MEDICA", "RELACION DE MATERIAL OFTALMICO"       ,;
         "DEL " + NtChr( ::aLS[2],"2" ) + " AL " + NtChr( ::aLS[3],"2" ),;
         "TIPO DE MATERIAL---------- ESFERA CILIND. ADD CANTIDAD " +;
         "VR.UNITARIO   VR.TOTAL"},::aLS[6] )
oTb:Seek( { "valor >",0 },"codigo" )
While !oTb:EOF()
   nVU := oTb:VALOR / oTb:CANTIDAD
   oRpt:Titulo( 79 )
   oRpt:Say( oRpt:nL,00,aX[oTb:TIP,1] )
   oRpt:Say( oRpt:nL,27,oTb:ESF )
   oRpt:Say( oRpt:nL,34,oTb:CIL )
   oRpt:Say( oRpt:nL,41,oTb:ADI )
   oRpt:Say( oRpt:nL,47,TRANSFORM(oTb:CANTIDAD,     "99,999") )
   oRpt:Say( oRpt:nL,55,TRANSFORM( nVU        ,"999,999,999") )
   oRpt:Say( oRpt:nL,68,TRANSFORM(oTb:VALOR   ,"999,999,999") )
   oRpt:nL ++
   aX[oTb:TIP,2] += oTb:CANTIDAD
   aX[oTb:TIP,3] += oTb:VALOR
   nGT += oTb:VALOR
   oTb:Skip(1):Read()
   oTb:xLoad()
EndDo
oRpt:Say( oRpt:nL++,00,Replicate("_",80) )
oRpt:Say( oRpt:nL++,57,"TOTAL -->  " + TRANSFORM( nGT,"999,999,999" ) )
oRpt:Say( oRpt:nL++,34,"R E S U M E N" )
FOR nP := 1 TO 11
   If aX[nP,3] > 0
      nVU := aX[nP,3] / aX[nP,2]
      oRpt:Titulo( 79 )
      oRpt:Say( oRpt:nL,00,aX[nP,1] )
      oRpt:Say( oRpt:nL,47,TRANSFORM(aX[nP,2],     "99,999") )
      oRpt:Say( oRpt:nL,55,TRANSFORM( nVU    ,"999,999,999") )
      oRpt:Say( oRpt:nL,68,TRANSFORM(aX[nP,3],"999,999,999") )
      oRpt:nL ++
   EndIf
NEXT
oRpt:Say( oRpt:nL,57,"TOTAL -->  " + TRANSFORM( nGT,"999,999,999" ) )
oRpt:NewPage()
oRpt:End()
oTb:Destroy()
 ::Poder( "0","cadlente" )
RETURN NIL

//------------------------------------//
METHOD Poder( cX,cTB ) CLASS TFacture

If cTB == NIL
   cX  := VAL( cX )
   cTB := PADL( LTRIM( STR( ABS(cX)*100,4 ) ),4,"0" )
Else
   If cX == "0"
      MSQuery( oApl:oMySql:hConnect,"DROP TABLE " + cTB )
   Else
      If !oApl:oDb:ExistTable( cTB )
         MSQuery( oApl:oMySql:hConnect,"CREATE TABLE " + cTB + " LIKE fanproce" )
      EndIf
   EndIf
   oApl:oDb:GetTables()
EndIf
RETURN cTB

//1-----------------------------------//
METHOD ResCotiz( oDlg ) CLASS TFacture
   LOCAL aRes, aGT, aVT, aTF, hRes, nL, nK, oRpt
aRes := "SELECT c.numero, c.autoriza, c.tipofac, c.fecha, c.cliente"+;
             ", c.totalfac, d.codart, d.precioven, d.montoiva "     +;
        "FROM cadantic c LEFT JOIN cadantid d "         +;
          "USING(optica, numero) "                      +;
        "WHERE c.optica = " + LTRIM(STR(oApl:nEmpresa)) +;
         " AND c.codigo_nit = " + LTRIM(STR(::aLS[1]))  +;
         " AND c.fecha >= " +  xValToChar( ::aLS[2] )   +;
         " AND c.fecha <= " +  xValToChar( ::aLS[3] )   +;
         " AND c.indicador <> 'A'"   + If( ::aLS[4] > 0 ,;
         " AND c.numfac IN(0, " + LTRIM(STR(::aLS[4])) + ")", "" )+;
         " ORDER BY c.tipofac, c.numero"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[9] == 2
   ::LaserCot( hRes,nL )
   RETURN NIL
EndIf
aTF := ArrayCombo( oApl:oNit:TIPOFAC )
aRes:= MyReadRow( hRes )
AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
aGT := { 0,0,0,0,0,0,0 }
aVT := { aRes[1],aRes[2],aRes[3],aRes[4],aRes[5],aRes[6],0,0,0,0,0,0 }
nK  := ASCAN( aTF, { |x| x[2] == aRes[3] } )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ALLTRIM(oApl:oNit:NOMBRE),UPPER(aTF[nK,1]),;
         "COTIZACIONES DESDE "+ NtChr(::aLS[2],"2") + " HASTA " + NtChr(::aLS[3],"2"),;
         "# COTIZ  #AUTORI.  FECHA COTIZ NOMBRE DEL CLIENTE TOTAL COTIZ  --MONTUR"+;
         "AS  OFTALMICOS  L.CONTACTO  -CONSULTAS  ----VARIOS  TOTAL IVA."},::aLS[6],1,2 )
While nL > 0
   aRes[7] := TRIM( aRes[7] )
      nK := 11  // Varios
   do Case
   Case aRes[7] == "0599000001" .OR. LEFT(aRes[7],2) == "01"
      nK := 7   // Montura
   Case aRes[7] == "0599000002" .OR. LEFT(aRes[7],2) == "02"
      nK := 8   // L.Oftalmicos
   Case aRes[7] == "0599000003" .OR. LEFT(aRes[7],2) >= "60" .OR. ;
        aRes[7] == "0504"
      nK := 9   // L.Contacto
   Case LEFT(aRes[7],4) = "0501"
      nK := 10  // Consultas
   EndCase
   aVT[nK] += aRes[8]
   aVT[12] += aRes[9]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aRes[1] # aVT[1]
      nK := aVT[07] + aVT[08] + aVT[09] + aVT[10] + aVT[11] + aVT[12]
      oRpt:Titulo( 133 )
      oRpt:Say( oRpt:nL, 00,STR(aVT[1],7) + STR(aVT[2],9) )
      oRpt:Say( oRpt:nL, 17,If( aVT[6] # nK, "*", " " ) )
      oRpt:Say( oRpt:nL, 19,NtChr( aVT[4],"2" ))
      oRpt:Say( oRpt:nL, 31,aVT[5],20 )
      oRpt:Say( oRpt:nL, 50,TRANSFORM(aVT[06],  "999,999,999" ))
      oRpt:Say( oRpt:nL, 63,TRANSFORM(aVT[07],"@Z 99,999,999" ))
      oRpt:Say( oRpt:nL, 75,TRANSFORM(aVT[08],"@Z 99,999,999" ))
      oRpt:Say( oRpt:nL, 87,TRANSFORM(aVT[09],"@Z 99,999,999" ))
      oRpt:Say( oRpt:nL, 99,TRANSFORM(aVT[10],"@Z 99,999,999" ))
      oRpt:Say( oRpt:nL,111,TRANSFORM(aVT[11],"@Z 99,999,999" ))
      oRpt:Say( oRpt:nL,123,TRANSFORM(aVT[12],"@Z 99,999,999" ))
      oRpt:nL++
      AEVAL( aVT, {|nVal,nPos| aGT[nPos-6] += nVal },7 )
      aGT[7] += aVT[6]
      If nL == 0 .OR. aRes[3] # aVT[3]
         nK := ASCAN( aTF, { |x| x[2] == aRes[3] } )
         oRpt:Say(  oRpt:nL, 00,REPLICATE("_",133),,,1 )
         oRpt:Say(++oRpt:nL, 10,"TOTAL DE " + oRpt:aEnc[2] )
         oRpt:Say(  oRpt:nL, 50,TRANSFORM(aGT[7],"999,999,999"))
         oRpt:Say(  oRpt:nL, 63,TRANSFORM(aGT[1], "99,999,999"))
         oRpt:Say(  oRpt:nL, 75,TRANSFORM(aGT[2], "99,999,999"))
         oRpt:Say(  oRpt:nL, 87,TRANSFORM(aGT[3], "99,999,999"))
         oRpt:Say(  oRpt:nL, 99,TRANSFORM(aGT[4], "99,999,999"))
         oRpt:Say(  oRpt:nL,111,TRANSFORM(aGT[5], "99,999,999"))
         oRpt:Say(  oRpt:nL,123,TRANSFORM(aGT[6], "99,999,999"))
         oRpt:NewPage()
         oRpt:nL := oRpt:nLength +1
         oRpt:aEnc[2] := UPPER(aTF[nK,1])
         AFILL( aGT,0 )
      EndIf
      aVT := { aRes[1],aRes[2],aRes[3],aRes[4],aRes[5],aRes[6],0,0,0,0,0,0 }
   EndIf
EndDo
MSFreeResult( hRes )
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserCot( hRes,nL ) CLASS TFacture
   LOCAL aRes, aGT, aVT, aTF, nK
aTF := ArrayCombo( oApl:oNit:TIPOFAC )
aRes:= MyReadRow( hRes )
AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
aGT := { 0,0,0,0,0,0,0 }
aVT := { aRes[1],aRes[2],aRes[3],aRes[4],aRes[5],aRes[6],0,0,0,0,0,0 }
nK  := ASCAN( aTF, { |x| x[2] == aRes[3] } )
 ::aLS[7]:= " COTIZ.DEL " + NtChr(::aLS[2],"2") + " AL " + NtChr(::aLS[3],"2")
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit                   ,;
             ALLTRIM(oApl:oNit:NOMBRE), UPPER(aTF[nK,1])+::aLS[7],;
             { .T., 1.5,"# Cotiz" }   , { .T., 2.7,"#Autori." },;
             { .F., 3.1,"FECHA COTIZ" }                        ,;
             { .F., 5.1,"NOMBRE DEL CLIENTE" }                 ,;
             { .T.,10.1,"Total Cotiz" },;
             { .T.,11.9,"Monturas" }   , { .T.,13.7,"Oftalmicos" },;
             { .T.,15.5,"L.Contacto" } , { .T.,17.3,"Consultas" } ,;
             { .T.,19.1,"VARIOS" }     , { .T.,20.9,"TOTAL IVA." } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[6] ,,,, 5 )
 ::nMD := 20.9
  PAGE
While nL > 0
   aRes[7] := TRIM( aRes[7] )
      nK := 11  // Varios
   do Case
   Case aRes[7] == "0599000001" .OR. LEFT(aRes[7],2) == "01"
      nK := 7   // Montura
   Case aRes[7] == "0599000002" .OR. LEFT(aRes[7],2) == "02"
      nK := 8   // L.Oftalmicos
   Case aRes[7] == "0599000003" .OR. LEFT(aRes[7],2) >= "60" .OR. ;
        aRes[7] == "0504"
      nK := 9   // L.Contacto
   Case LEFT(aRes[7],4) = "0501"
      nK := 10  // Consultas
   EndCase
   aVT[nK] += aRes[8]
   aVT[12] += aRes[9]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aRes[1] # aVT[1]
      nK := aVT[07] + aVT[08] + aVT[09] + aVT[10] + aVT[11] + aVT[12]
      ::Cabecera( .t.,0.45 )
      UTILPRN ::oUtil Self:nLinea,01.5 SAY STR(aVT[1],7)  RIGHT
      UTILPRN ::oUtil Self:nLinea,02.7 SAY STR(aVT[2],9)  RIGHT
      UTILPRN ::oUtil Self:nLinea,02.9 SAY If( aVT[6] # nK, "*", " " )
      UTILPRN ::oUtil Self:nLinea,03.1 SAY NtChr( aVT[4],"2" )
      UTILPRN ::oUtil Self:nLinea,05.1 SAY  LEFT( aVT[5],20 )
      UTILPRN ::oUtil Self:nLinea,10.1 SAY TRANSFORM( aVT[06],  "999,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,11.9 SAY TRANSFORM( aVT[07],"@Z 99,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,13.7 SAY TRANSFORM( aVT[08],"@Z 99,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,15.5 SAY TRANSFORM( aVT[09],"@Z 99,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,17.3 SAY TRANSFORM( aVT[10],"@Z 99,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,19.1 SAY TRANSFORM( aVT[11],"@Z 99,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,20.9 SAY TRANSFORM( aVT[12],"@Z 99,999,999" ) RIGHT
      AEVAL( aVT, {|nVal,nPos| aGT[nPos-6] += nVal },7 )
      aGT[7] += aVT[6]
      If nL == 0 .OR. aRes[3] # aVT[3]
         nK := ASCAN( aTF, { |x| x[2] == aVT[3] } )
         ::Cabecera( .t.,0.40,0.90,20.9 )
         UTILPRN ::oUtil Self:nLinea,02.0 SAY "TOTAL DE " + UPPER(aTF[nK,1])
         UTILPRN ::oUtil Self:nLinea,10.1 SAY TRANSFORM( aGT[7],"999,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,11.9 SAY TRANSFORM( aGT[1], "99,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,13.7 SAY TRANSFORM( aGT[2], "99,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,15.5 SAY TRANSFORM( aGT[3], "99,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,17.3 SAY TRANSFORM( aGT[4], "99,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,19.1 SAY TRANSFORM( aGT[5], "99,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,20.9 SAY TRANSFORM( aGT[6], "99,999,999" ) RIGHT
         nK := ASCAN( aTF, { |x| x[2] == aRes[3] } )
         ::aEnc[5] := UPPER(aTF[nK,1]) + ::aLS[7]
         ::nLinea  := ::nEndLine
         AFILL( aGT,0 )
      EndIf
      aVT := { aRes[1],aRes[2],aRes[3],aRes[4],aRes[5],aRes[6],0,0,0,0,0,0 }
   EndIf
EndDo
MSFreeResult( hRes )
   ENDPAGE
IMPRIME END .F.
 ::aLS[7] := "    "
RETURN NIL

//5-----------------------------------//
METHOD FanChild() CLASS TFacture
   LOCAL aRes, aCH, aGT, aVT, cTB, hRes, nL, nK, oRpt, oTB
cTB  := If( ::aLS[9] == 3, "IN(44, 54)", "= " + LTRIM(STR(oApl:nEmpresa)) )
aRes := "SELECT c.numero, c.fecha, c.cliente, c.valorot, "+;
         "d.codart, d.descri, d.precioven + d.montoiva "+;
        "FROM cadantic c LEFT JOIN cadantid d "         +;
          "USING(optica, numero) "                      +;
        "WHERE c.optica "   + cTB                       +;
         " AND c.codigo_nit = " + LTRIM(STR(::aLS[1]))  +;
         " AND c.fecha >= " +   xValToChar( ::aLS[2] )  +;
         " AND c.fecha <= " +   xValToChar( ::aLS[3] )  +;
         " AND c.indicador <> 'A'"   +  If( ::aLS[4] > 0,;
         " AND c.numfac IN(0, " + LTRIM(STR(::aLS[4])) + ")", "" )+;
         " ORDER BY c.numero"
//       " AND c.optica = " + LTRIM(STR(oApl:nEmpresa)) +;
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   RETURN NIL
EndIf
cTB := LOWER( ALLTRIM(oApl:cUser) ) + "fn"
 ::Poder( "1",cTB )
oTB := oApl:Abrir( cTB,"sub_proj",,.t. )
aRes:= MyReadRow( hRes )
AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
aGT := { {"Lentes Oftalmicos",0},{"Monturas Oftalmicas",0},{"Consulta Optometrica",0} }
aVT := { aRes[1],aRes[2],aRes[3],aRes[4] }
While nL > 0
   aRes[5] := TRIM( aRes[5] )
   If aRes[5] == "0599000001" .OR. LEFT(aRes[5],2) == "01"
      nK := 2   // Montura
   ElseIf LEFT(aRes[5],4) = "0501"
      If (nK := AT( "-",aRes[6] )) > 0
         aVT[3] :=    SUBSTR(aRes[6],nK+1)
         aVT[4] := TRIM(LEFT(aRes[6],nK-1))
         ::GrabaFan( aVT,aGT[3,1],aRes[7],cTB )
         aVT[3] := aRes[3]
         aVT[4] := aRes[4]
         aRes[7]:= 0
      EndIf
      nK := 3   // Consultas
   Else
      nK := 1   // L.Oftalmicos
   EndIf
   aGT[nK,2] += aRes[7]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aVT[1] # aRes[1]
      aVT[4] := LTRIM(STR(aVT[4]))
      FOR nK := 1 TO 3
         If aGT[nK,2] > 0
            ::GrabaFan( aVT,aGT[nK,1],aGT[nK,2],cTB )
         EndIf
         aGT[nK,2] := 0
      NEXT nK
      aVT := { aRes[1],aRes[2],aRes[3],aRes[4] }
   EndIf
EndDo
MSFreeResult( hRes )
aRes := "SELECT child_id, nombre, sub_proj, edad, area, factura, servicio, valor, fecha "+;
        "FROM " + cTB + " ORDER BY area, child_id, factura"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
If ::aLS[9] == 3
   ::FanExcel( hRes,nL )
   MSFreeResult( hRes )
   oTB:Destroy()
   ::Poder( "0",cTB )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ "Servicios Proporcionados a Niños y Adolescentes",;
         "Apadrinados de la Fundacion Amigos de los Niños","Atendidos en el mes de "   +;
          NtChr(::aLS[3],"6"),"Codigo     Nombre Completo                Subp Edad "     +;
         "No.Factura  Servicio Prestado-  --Valor--     Fecha"},::aLS[6],1,2 )
aRes := MyReadRow( hRes )
AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
aVT := { " ","X",0,0,0,0,0,0 }
While nL > 0
   oRpt:Titulo( 106 )
   If aVT[1]  # aRes[5]
      aVT[1] := aRes[5]
      oRpt:Say( oRpt:nL++,10,"Area No. " + LEFT(aVT[1],1) + "    Clasificacion " +;
                If(  LEFT(aVT[1],1) == "V", "No Estan en la Base Datos",;
                If( RIGHT(aVT[1],1) == "1", "NI\OS", "ADOLESCENTES" ) ) )
   EndIf
   If aVT[2]  # aRes[1]
      aVT[2] := aRes[1]
      aVT[3] ++
      oRpt:Say( oRpt:nL,00,aRes[1] )
      oRpt:Say( oRpt:nL,11,aRes[2],30 )
      oRpt:Say( oRpt:nL,42,aRes[3] )
      oRpt:Say( oRpt:nL,48,aRes[4] )
   EndIf
   oRpt:Say( oRpt:nL,52,aRes[6] )
   oRpt:Say( oRpt:nL,64,aRes[7],18 )
   oRpt:Say( oRpt:nL,84,TRANSFORM(aRes[8],"9,999,999" ))
   oRpt:Say( oRpt:nL,95,NtChr( aRes[9],"2" ) )
   oRpt:nL ++
   aVT[4] += aRes[8]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aVT[1] # aRes[5]
      oRpt:Say( oRpt:nL,23,"Numero de Registros " + STR(aVT[3],6),,,1 )
      oRpt:Say( oRpt:nL,59,"Total por Clasificacion " + TRANSFORM(aVT[4],"$9,999,999") )
      oRpt:nL += 2
      aVT[5] += aVT[3]
      aVT[6] += aVT[4]
      aVT[3] := aVT[4] := 0
   EndIf
   If nL == 0 .OR. LEFT(aVT[1],1) # LEFT(aRes[5],1)
      oRpt:Say( oRpt:nL,12,"subtotal de Registros por Area " + STR(aVT[5],6),,,1 )
      oRpt:Say( oRpt:nL,68,"Total por Area " + TRANSFORM(aVT[6],"$9,999,999") )
      oRpt:nL += 2
      aVT[7] += aVT[5]
      aVT[8] += aVT[6]
      aVT[5] := aVT[6] := 0
   EndIf
EndDo
MSFreeResult( hRes )
      oRpt:Say( oRpt:nL,19,"Gran Total de Registros " + STR(aVT[7],6),,,1 )
      oRpt:Say( oRpt:nL,71,"Valor Total " + TRANSFORM(aVT[8],"$9,999,999") )
oRpt:NewPage()
oRpt:End()

oTB:Destroy()
 ::Poder( "0",cTB )
RETURN NIL

//5-----------------------------------//
METHOD FanExcel( hRes,nL ) CLASS TFacture
   LOCAL aRes, cQry, nF, oXLS
   LOCAL aVT := { " ","X",0,0,0,0,0,0,"#.##0,00" }
If oApl:lOffice
   cQry := cFilePath( GetModuleFileName( GetInstance() )) + "Fanchild.csv"
   FERASE(cQry)
   oXLS := FCREATE(cQry,0) //, FC_NORMAL)
   If FERROR() != 0
      Msginfo(FERROR(),"No se pudo crear el archivo "+cQry )
      RETURN NIL
   EndIf
   aVT[9] := CHR(13) + CHR(10)  //CRLF
   FWRITE( oXLS,'"","'+oApl:cEmpresa+'"'+aVT[9] )
   FWRITE( oXLS,'"","NIT: ' + oApl:oEmp:Nit + '"' +aVT[9] )
   FWRITE( oXLS,'"","Servicios Proporcionados a Niños y Adolescentes"'+aVT[9] )
   FWRITE( oXLS,'"","Apadrinados de la Fundacion Amigos de los Niños"'+aVT[9] )
   FWRITE( oXLS,'"Codigo","Nombre Completo","Subp","Edad","No.Factura","Servicio Prestado","Valor","Fecha"'+aVT[9] )
Else
   cQry := cFilePath( GetModuleFileName( GetInstance() )) + "Fanchild.xls"
   oApl:oWnd:SetMsg( "Exportando hacia "+cQry )
   oXLS := TExcelScript():New()
   oXLS:Create( cQry )
   oXLS:Font("Verdana")
   oXLS:Visualizar(.F.)
// oXLS:Say( nRow, nCol, xValue, cFont, nSize, lBold, lItalic, ;
//             lUnderLine, nAlign, nColor, nFondo , nOrien , nStyle , cFormat )
   oXLS:Say(  1 , 2 , oApl:cEmpresa, , 14 ,,,,,,,, 0  )
   oXLS:Say(  2 , 2 , "NIT: " + oApl:oEmp:Nit, ,12 ,,,, 7,,,, 0 )
   oXLS:Say(  3 , 2 , "Servicios Proporcionados a Niños y Adolescentes", , 12 ,,,, 7,,,, 0  )
   oXLS:Say(  4 , 2 , "Apadrinados de la Fundacion Amigos de los Niños", , 12 ,,,, 7,,,, 0  )

   oXLS:Say(  5,  1, "Codigo",,,,,, 7,,,, 0, "Text" )
   oXLS:Say(  5,  2, "Nombre Completo",,,,,, 7,,,, 0, "Text" )
   oXLS:Say(  5,  3, "Subp",,,,,, 7,,,, 0, "Text" )
   oXLS:Say(  5,  4, "Edad",,,,,, 7,,,, 0, "Text" )
   oXLS:Say(  5,  5, "No.Factura",,,,,, 7,,,, 0, "Text" )
   oXLS:Say(  5,  6, "Servicio Prestado",,,,,, 7,,,, 0, "Text" )
   oXLS:Say(  5,  7, "Valor",,,,,, 7,,,, 0, "Text" )
   oXLS:Say(  5,  8, "Fecha",,,,,, 7,,,, 0, "Text" )
   ::aLS[6] := .f.
EndIf

aRes := MyReadRow( hRes )
  nF := 6
AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
While nL > 0
   If aVT[1]  # aRes[5]
      aVT[1] := "Area No. " + LEFT(aRes[5],1) + "    Clasificacion "    +;
                If(  LEFT(aRes[5],1) == "V", "No Estan en la Base Datos",;
                If( RIGHT(aRes[5],1) == "1", "NI\OS", "ADOLESCENTES" ) )
      If oApl:lOffice
         FWRITE( oXLS,'"","' + aVT[1] + '"' + aVT[9] )
      Else
         oXLS:Say( nF, 2, aVT[1],,, ::aLS[6],,, 2,,,,, "Text" )
      EndIf
      nF ++
      aVT[1] := aRes[5]
   EndIf
//   aRes[9] := NtChr( aRes[9],"2" )
   If aVT[2]  # aRes[1]
      aVT[2] := aRes[1]
      aVT[3] ++
      If oApl:lOffice
         ::aLS[7] := XTrim( aRes[1],-9 ) + XTrim( aRes[2],-9 ) +;
                     XTrim( aRes[3],-9 ) + XTrim( aRes[4],-9 )
      Else
         oXLS:Say( nF, 1, aRes[1],,, ::aLS[6],,, 2,,,,, "Text" )
         oXLS:Say( nF, 2, aRes[2],,, ::aLS[6],,, 2,,,,, "Text" )
         oXLS:Say( nF, 3, aRes[3],,, ::aLS[6],,, 2,,,,, "Text" )
         oXLS:Say( nF, 4, aRes[4],,, ::aLS[6],,,,,,,, )
      EndIf
   EndIf
      If oApl:lOffice
         ::aLS[7] += XTrim( aRes[6],-9 ) + XTrim( aRes[7],-9 ) +;
                     XTrim( aRes[8],-9 ) + XTrim( aRes[9],-9 )
         FWRITE( oXLS,::aLS[7] + aVT[9] )
      Else
         oXLS:Say( nF, 5, aRes[6],,, ::aLS[6],,,,,,,, )
         oXLS:Say( nF, 6, aRes[7],,, ::aLS[6],,, 2,,,,, "Text" )
         oXLS:Say( nF, 7, aRes[8],,, ::aLS[6],,,,,,,, aVT[9] )
         oXLS:Say( nF, 8, aRes[9],,, ::aLS[6],,, 2,,,,, "Text" )
      EndIf
   nF ++
   aVT[4] += aRes[8]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aVT[1] # aRes[5]
      If oApl:lOffice
         ::aLS[7] := XTrim( aVT[3],-9 ) + '"","Total por Clasificacion",' +;
                     XTrim( aVT[4],-9 )
         FWRITE( oXLS,'"","Numero de Registros","",'+ ::aLS[7] + aVT[9] )
         FWRITE( oXLS,'""' + aVT[9] )
      Else
         oXLS:Say( nF, 2, "Numero de Registros",,, ::aLS[6],,, 2,,,,, "Text" )
         oXLS:Say( nF, 4, aVT[3],,, ::aLS[6],,,,,,,, )
         oXLS:Say( nF, 6, "Total por Clasificacion",,, ::aLS[6],,, 2,,,,, "Text" )
         oXLS:Say( nF, 7, aVT[4],,, ::aLS[6],,,,,,,, aVT[9] )
      EndIf
      nF += 2
      aVT[5] += aVT[3]
      aVT[6] += aVT[4]
      aVT[3] := aVT[4] := 0
   EndIf
   If nL == 0 .OR. LEFT(aVT[1],1) # LEFT(aRes[5],1)
      If oApl:lOffice
         ::aLS[7] := XTrim( aVT[5],-9 ) + '"","Total por Area",' +;
                     XTrim( aVT[6],-9 )
         FWRITE( oXLS,'"","subtotal de Registros por Area","",'+ ::aLS[7] + aVT[9] )
         FWRITE( oXLS,'""' + aVT[9] )
      Else
         oXLS:Say( nF, 2, "subtotal de Registros por Area",,, ::aLS[6],,, 2,,,,, "Text" )
         oXLS:Say( nF, 4, aVT[5],,, ::aLS[6],,,,,,,, )
         oXLS:Say( nF, 6, "Total por Area",,, ::aLS[6],,, 2,,,,, "Text" )
         oXLS:Say( nF, 7, aVT[6],,, ::aLS[6],,,,,,,, aVT[9] )
      EndIf
      nF += 2
      aVT[7] += aVT[5]
      aVT[8] += aVT[6]
      aVT[5] := aVT[6] := 0
   EndIf
   ::aLS[7] := '"","","",""'
EndDo
If oApl:lOffice
   ::aLS[7] := XTrim( aVT[7],-9 ) + '"","Valor Total",' +;
               XTrim( aVT[8],-9 )
   FWRITE( oXLS,'"","Gran Total de Registros","",'+ ::aLS[7] + aVT[9] )
   If !FCLOSE(oXLS)
      Msginfo(FERROR(),"Error cerrando el archivo "+cQry)
   EndIf
   WAITRUN("OPENOFICE.BAT " + cQry, 0 )
Else
   oXLS:Say( nF, 2, "Gran Total de Registros",,, ::aLS[6],,, 2,,,,, "Text" )
   oXLS:Say( nF, 4, aVT[7],,, ::aLS[6],,,,,,,, )
   oXLS:Say( nF, 6, "Valor Total",,, ::aLS[6],,, 2,,,,, "Text" )
   oXLS:Say( nF, 7, aVT[8],,, ::aLS[6],,,,,,,, aVT[9] )
   oXLS:Borders("A1:H" + LTRIM(STR(nF)) ,,, 3 )
   oXLS:ColumnWidth( 2 , 45 )
   oXLS:ColumnWidth( 6 , 25 )
   oXLS:Visualizar(.T.)
   oXLS:End(.f.) ; oXLS := NIL
EndIf
RETURN NIL

//------------------------------------//
METHOD GrabaFan( aVT,cSer,nValor,cQry ) CLASS TFacture
   LOCAL aCH
aCH := Buscar( "SELECT child_id, dob, first_name, last_name, sub_proj FROM fanchild "+;
               "WHERE child_id = " + aVT[4],"CM",,8 )
If LEN( aCH ) == 0
   aCH := { aVT[4],0,aVT[3],"","V" }
EndIf
aCH[2] := If( EMPTY(aCH[2]), 0, NtChr( aCH[2],"A" ) )
cQry := "INSERT INTO " + cQry +" VALUES ( null, '"   +;
        TRIM(aCH[1]) + "', "     + LTRIM(STR(aCH[2]))+  ", '" +;
        TRIM(aCH[3]) + " " + aCH[4]                  + "', '" +;
        LEFT(aCH[5],1) + If( aCH[2] <= 12, "1", "2" )+ "', '" +;
             aCH[5]  + "', '', " + LTRIM(STR(aVT[1]))+  ", '" +;
        MyDToMs( DTOS( aVT[2] ) )                    + "', '" +;
        TRIM(cSer)   + "', "     + LTRIM(STR(nValor))+  " )"
MSQuery( oApl:oMySql:hConnect,cQry )
RETURN NIL

//------------------------------------//
PROCEDURE GrabaVen( aDet,nAlgo )
   LOCAL nF
FOR nF := 1 TO LEN( aDet )
   If nAlgo == 0 .OR. aDet[nF,3] > 0
      aDet[nF,5] := ROUND( (aDet[nF,6] / (aDet[nF,6]+aDet[nF,4]))*100,2 )
      oApl:oVen:xBlank()
      oApl:oVen:OPTICA   := oApl:nEmpresa; oApl:oVen:NUMFAC    := oApl:oFac:NUMFAC
      oApl:oVen:TIPO     := oApl:Tipo    ; oApl:oVen:FECFAC    := oApl:oFac:FECHOY
      oApl:oVen:CODART   := aDet[nF,1]   ; oApl:oVen:DESCRI    := aDet[nF,2]
      oApl:oVen:CANTIDAD := aDet[nF,3]   ; oApl:oVen:PRECIOVEN := aDet[nF,4]
      oApl:oVen:DESPOR   := aDet[nF,5]   ; oApl:oVen:DESMON    := aDet[nF,6]
      oApl:oVen:MONTOIVA := aDet[nF,7]   ; oApl:oVen:PPUBLI    := aDet[nF,8]
      oApl:oVen:PCOSTO   := aDet[nF,9]   ; oApl:oVen:Append( .f. )
   EndIf
NEXT nF
RETURN