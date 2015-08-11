// Programa.: INOVENTA.PRG     >>> Martin A. Toloza Lozano <<<
// Notas....: Pasa las Ventas a Diskette y Actualiza Cartera.
#include "FiveWin.ch"

MEMVAR oApl

PROCEDURE InoVenta( nOpc )
   LOCAL oV, aVT := { {|| oV:ArmarInf() }, {|| oV:Traslado() }, {|| oV:Ajustes() } }
   DEFAULT nOpc := 1
oV := TVentas() ; oV:NEW( nOpc )
EVAL( aVT[nOpc] )
RETURN

//------------------------------------//
CLASS TVentas FROM TContabil
 DATA cRut
 METHOD NEW( nOpc,cRut ) Constructor
 METHOD ArmarInf()
 METHOD CopioVta( oDlg,oGet )
 METHOD Traslado()
 METHOD PegoVenta( aTin,oDlg,oGet )
 METHOD Ajustes()
 METHOD GrabaFac( nNumFac,dFec,nPago,nMov )
ENDCLASS

//------------------------------------//
METHOD NEW( nOpc,cRut ) CLASS TVentas
   LOCAL nK
If VALTYPE( nOpc ) == "C"
   If cRut # NIL
      cRut := STRTRAN( oApl:cRuta1,"Bitmap",cRut )
   EndIf
   ::cRut := AbrirFile( 4,cRut,nOpc )
   If (nK := RAT( "\", ::cRut )) > 0
      ::cRut := LEFT( ::cRut,nK )
   Else
      ::cRut := "A:"
   EndIf
ElseIf nOpc == 1
   Empresa()
   nK := If( oApl:lEnLinea, oApl:oEmp:FECVENTA, oApl:oEmp:CARTERA ) +1
   ::aLS := { "PASAV",nK,nK,"",.f. }
EndIf
RETURN NIL

//------------------------------------//
METHOD ArmarInf() CLASS TVentas
   LOCAL oDlg, oGet := ARRAY(7)
DEFINE DIALOG oDlg TITLE "Pasa las Ventas a Diskette" FROM 1, 2 TO 10,50
   @ 02,00 SAY "Nombre del Archivo a pasar" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02,92 GET oGet[1] VAR ::aLS[1] OF oDlg PICTURE "@!"  PIXEL SIZE 36,10;
      WHEN !oApl:lEnLinea
   @ 16,00 SAY "Fecha Inicial [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 16,92 GET oGet[2] VAR ::aLS[2] OF oDlg SIZE 40,10 PIXEL
   @ 30,00 SAY "Fecha   Final [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 30,92 GET oGet[3] VAR ::aLS[3] OF oDlg SIZE 40,10 PIXEL
   @ 30,136 CHECKBOX oGet[4] VAR ::aLS[5] PROMPT "Por INTERNET" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 46, 04 SAY oGet[5] VAR ::aLS[4] OF oDlg PIXEL SIZE 50,10 ;
      UPDATE COLOR nRGB( 160,19,132 )
   @ 46, 70 BUTTON oGet[6] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      (If( ::aLS[3] >= ::aLS[2] .AND. ::aLS[3] < oApl:dFec           ,;
         ( oGet[6]:Disable(), ::CopioVta( oDlg,oGet ), oDlg:End() )  ,;
         ( MsgStop( "Fecha Final tiene que ser MAYOR o IGUAL" + CRLF +;
                    "a la Fecha inicial y MENOR que la fecha" + CRLF +;
                    "del Sistema = " + DTOC(oApl:dFec) )             ,;
                    oGet[3]:SetFocus() ) ) ) PIXEL
   @ 46,120 BUTTON oGet[7] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 52, 02 SAY "[INOVENTA]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
ConectaOff()
RETURN NIL

//------------------------------------//
METHOD CopioVta( oDlg,oGet ) CLASS TVentas
   LOCAL aDat, aOK, cFile, cTemp := "", nK
 ::NEW( "VENTAS.DBF" )  //If( ::aLS[5], "A Sistemas", )
If ::aLS[1] == "PASAV"
   //ActuCliente( oDlg,"SISTEM",::cRut )
   cFile := "optica  = " + LTRIM(STR(oApl:nEmpresa))+;
       " AND fecpag >= " + xValToChar( ::aLS[2] )   +;
       " AND fecpag <= " + xValToChar( ::aLS[3] )   +;
       " AND formapago <= 4"
   cFile += " OR (" + STRTRAN(cFile,"o <= 4","o = 7") + " AND pordonde = 'N')"
   aOK  := { 0,0,0,0,0,0,0,0,0 }
   aDat := { {"CADPAGOS","CADFACTU","CADVENTA",;
              "CADANTIC","CADANTID","CADANTIP",;
              "CADRCAJA","CADNOTAC","CADNOTAD"} }
   oGet[5]:SetText( "CADFACTU" )
   aOK[2] := ExportDBF( oApl:oFac,;
             {"optica",oApl:nEmpresa,"fechoy >= ",::aLS[2],"fechoy <= ",::aLS[3] } )
   oGet[5]:SetText( "CADVENTA" )
   aOK[3] := ExportDBF( oApl:oVen,;
             {"optica",oApl:nEmpresa,"fecfac >= ",::aLS[2],"fecfac <= ",::aLS[3] } )
Else      // "CARTE"
   cFile := "optica  = " + LTRIM(STR(oApl:nEmpresa))+;
       " AND fecpag >= " + xValToChar( ::aLS[2] )   +;
       " AND fecpag <= " + xValToChar( ::aLS[3] )   +;
       " AND pordonde <> 'N'"                       +;
       " AND (formapago >= 7 OR indicador = '*')"
   aOK  := { 0 }
   aDat := { {"PAGOS"} } //,"FACTU"
//             { "optica",oApl:nEmpresa,"fechaent >= ",::aLS[2],;
//               "fechaent <= ",::aLS[3],"indicador","A" } }
EndIf
 oGet[5]:SetText( "CADPAGOS" )
aOK[1] := ExportDBF( oApl:oPag,cFile )
If LEN( aOK ) > 3
   cFile := "SELECT * FROM cadantic "                    +;
            "WHERE optica = " + xValToChar(oApl:nEmpresa)+;
             " AND fecha >= " + xValToChar( ::aLS[2] )   +;
             " AND fecha <= " + xValToChar( ::aLS[3] )   + " ORDER BY numero"
   aOK[4] := ExportDBF( "CADANTIC",cFile,,1 )
   aOK[5] := ExportDBF( "CADANTID",STRTRAN(cFile,"antic","antid"),,1 )
   aOK[6] := ExportDBF( "CADANTIP",STRTRAN(cFile,"antic","antip"),,1 )
   cFile := STRTRAN(cFile,"numero","rcaja")
   aOK[7] := ExportDBF( "CADRCAJA",STRTRAN(cFile,"antic","rcaja"),,1 )
   cFile := STRTRAN(cFile,"rcaja","numero")
   aOK[8] := ExportDBF( "CADNOTAC",STRTRAN(cFile,"antic","notac"),,1 )
   cFile := "SELECT d.* FROM cadnotac c, cadnotad d "      +;
            "WHERE c.optica = " + xValToChar(oApl:nEmpresa)+;
             " AND c.fecha >= " + xValToChar( ::aLS[2] )   +;
             " AND c.fecha <= " + xValToChar( ::aLS[3] )   +;
             " AND d.optica = c.optica"                    +;
             " AND d.numero = c.numero ORDER BY c.numero"
   aOK[9] := ExportDBF( "CADNOTAD",cFile,,1 )
EndIf
FOR nK := 1 TO LEN( aOK )
   If aOK[nK] > 0
      cTemp += aDat[1,nK] + " = " + LTRIM(STR(aOK[nK])) + CRLF
   EndIf
NEXT nK
If EMPTY( cTemp )
   MsgStop( "No hay nada que Enviar",">>> OJO <<<" )
Else
   aOK := If( ::aLS[5], "VENTAS.ZIP", "Inserte un DISKETTE en la Unidad" )
   If MsgYesNo( aOK+CRLF+cTemp,">>> Por Favor <<<" )
      If ::aLS[1] == "PASAV"
         cFile := "SELECT n.* FROM historia n, cadfactu u "       +;
                  "WHERE n.codigo_nit = u.codigo_cli"             +;
                   " AND u.optica  = " + xValToChar(oApl:nEmpresa)+;
                   " AND u.fechoy >= " + xValToChar( ::aLS[2] )   +;
                   " AND u.fechoy <= " + xValToChar( ::aLS[3] )   +;
                   " UNION "                                      +;
                  "SELECT n.* FROM historia n, cadantic c "       +;
                  "WHERE n.codigo_nit = c.codigo_cli"             +;
                   " AND c.optica = " + xValToChar(oApl:nEmpresa) +;
                   " AND c.fecha >= " + xValToChar( ::aLS[2] )    +;
                   " AND c.fecha <= " + xValToChar( ::aLS[3] )    +;
                   " GROUP BY codigo_nit"
         ExportDBF( "HCEDULAS",cFile,,1 )
         AADD( aDat[1],"HCEDULAS" )
         cFile := STRTRAN(cFile,"codigo_cli","codigo_nit")
         ExportDBF( "CADCLIEN",STRTRAN(cFile,"historia","cadclien"),,1 )
         AADD( aDat[1],"CADCLIEN" )

         cFile := "SELECT c.optica, c.numero, c.numfac "          +;
                  "FROM cadantic c, cadfactu u WHERE "            +;
                  If( oApl:nEmpresa == 18,                         ;
                        "c.optica IN(18, 21)"                     ,;
                        "u.optica  = c.optica" )                  +;
                   " AND u.numfac  = c.numfac"                    +;
                   " AND u.optica  = " + xValToChar(oApl:nEmpresa)+;
                   " AND u.fechoy >= " + xValToChar( ::aLS[2] )   +;
                   " AND u.fechoy <= " + xValToChar( ::aLS[3] )   +;
                   " AND u.indicador  <> 'A'"                     +;
                   " AND u.remplaza > 0"
         ExportDBF( "CADANTIF",cFile,,1 )
         AADD( aDat[1],"CADANTIF" )
         If oApl:oEmp:FECVENTA < ::aLS[3]
            oApl:oEmp:FECVENTA:= ::aLS[3]
            oApl:oEmp:Update(.f.,1)
         EndIf
      Else
         oApl:oEmp:CARTERA := ::aLS[3]
         oApl:oEmp:Update(.f.,1)
      EndIf
      If ::aLS[5]
         WAITRUN( 'Ventas.bat' )
         MsgStop( "Está en la Carpeta "+oApl:cRuta2,"El Archivo VENTAS.ZIP" )
      Else
         ::aLS[1] := oApl:cRuta2 + If( ::aLS[1] == "PASAV", "", "CAD" )
         FOR nK := 1 TO LEN( aDat[1] )
            cTemp := ::aLS[1] + aDat[1,nK] + ".DBF"
            cFile := ::cRut   + aDat[1,nK] + ".DBF"
            oGet[5]:SetText( cFile )
            COPY FILE &(cTemp) TO &(cFile)
         NEXT nK
      EndIf
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Traslado() CLASS TVentas
   LOCAL nAnticip, oDlg, oGet := ARRAY(7)
   LOCAL aTin := { 0,CTOD(""),CTOD(""),0,.f.,oApl:nEmpresa,9999999999,9999999999 }
   LOCAL aFile := { "CADFACTU","CADPAGOS","CADANTIC","CADVENTA",;
                    "CADANTID","CADANTIP","CADRCAJA","CADNOTAC",;
                    "CADNOTAD","CADCLIEN","HCEDULAS","Pegar y Actualizar " }
If MsgYesNo( "Si esta todo Ok.", "Inserte el DISKETTE con las Ventas" )
   ::NEW( "*.DBF","Archivo de Ventas Opticas" )
   FOR aTin[4] := 1 TO 11
      If !AbreDbf( "Tem",aFile[aTin[4]],,::cRut )
         ::aLS[10] := .f.
         EXIT
      EndIf
      aTin[5] := { "FECHOY","FECPAG","FECHA","FECFAC","FECHA",;
                   "FECHA","FECHA","FECHA","NADA","NADA","NADA" }[aTin[4]]
      MsgMeter( { | oMeter, oText, oDlg, lEnd | ;
                Revisar( oMeter,oText,oDlg,@lEnd,@aTin ) },;
                aFile[aTin[4]],"Revisando" )
      If Tem->(LASTREC()) > 0 .AND. aTin[4] <= 9
         aFile[12] += aFile[aTin[4]] + ", "
         ::aLS[5]  += { 1,2,0,0,0,3,0,4,0,0,0 }[aTin[4]]
      EndIf
      Tem->(dbCloseArea())
   NEXT
   aTin[5] := .f.
EndIf
If ::aLS[10] .AND. ::aLS[5] >= 1
   oApl:oEmp:Seek( { "optica",aTin[1] } )
    aTin[4] := ::aLS[5]
    aTin[5] := .t.
   ::aLS[5] := aTin[7]
   ::aLS[6] := oApl:oEmp:NUMFACU
   nAnticip := Buscar( "SELECT MAX(numero) FROM cadantic WHERE optica = "+;
                       LTRIM(STR(aTin[1])),"CM",,8,,4 )
EndIf
DEFINE DIALOG oDlg TITLE oApl:oEmp:NOMBRE FROM 1, 2 TO 10,52
   @ 02, 10 SAY oGet[1] VAR aFile[12] OF oDlg PIXEL SIZE 160,12 COLOR nRGB( 255,0,0 )
   @ 12,166 SAY "# Anticipos"              OF oDlg       PIXEL SIZE 40,10
   @ 22, 00 SAY "Fecha Inicial [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 22, 72 GET oGet[2] VAR aTin[2] OF oDlg SIZE 40,10 PIXEL
   @ 22,120 SAY oGet[6] VAR ::aLS[6] OF oDlg PIXEL SIZE 44,10
   @ 22,166 SAY             nAnticip OF oDlg PIXEL SIZE 44,10
   @ 34, 00 SAY "Fecha   Final [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 34, 72 GET oGet[3] VAR aTin[3] OF oDlg ;
      VALID aTin[3] >= aTin[2] SIZE 40,10 PIXEL
   @ 34,120 SAY oGet[5] VAR ::aLS[5] OF oDlg PIXEL SIZE 44,10 ;
      UPDATE COLOR nRGB( 160,19,132 )
   @ 34,166 SAY              aTin[8] OF oDlg PIXEL SIZE 44,10 ;
             COLOR nRGB( 0,128,192 )
    @ 48, 60 BUTTON oGet[4] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( MsgRun( "Adicionando CADFACTU","Por favor Espere",;
              { |oDlg| ::PegoVenta(aTin,oDlg,oGet) } ), oDlg:End() ) PIXEL
   @ 48,110 BUTTON oGet[7] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 52, 02 SAY "[INOVENTA]" OF oDlg PIXEL SIZE 34,10
   ACTIVAGET(oGet)
   If (aTin[7] # 9999999999 .AND. ::aLS[6] # aTin[7]-1) .OR.;
      (aTin[8] # 9999999999 .AND. nAnticip # aTin[8]-1) .OR. aTin[4] == 0
      oGet[4]:Disable()
   EndIf
ACTIVATE DIALOG oDlg CENTERED ;
   WHEN aTin[5]
oApl:oEmp:Seek( { "optica",aTin[6] } )
oApl:nEmpresa := aTin[6]
RETURN NIL

//------------------------------------//
METHOD PegoVenta( aTin,oDlg,oGet ) CLASS TVentas
   LOCAL aFac, aPag, aRes, cQry, nL, nP
   LOCAL hPag, hRes, aV := ARRAY(2)
oApl:nEmpresa := aTin[1]
aV[1] := CopyaSQL( oDlg,oApl:oFac,.t.,,.t.,::cRut )

aV[2] := CopyaSQL( oDlg,oApl:oPag,.t.,,,::cRut )

 CopyaSQL( oDlg,oApl:oVen,.t.,,,::cRut )
 CopyaSQL( oDlg,oApl:oAtc,.f.,,,::cRut )

 hRes := oApl:Abrir( "cadantid","optica, numero",,,1 )
 CopyaSQL( oDlg,hRes,.t.,,,::cRut )
 hRes:Destroy()

 hRes := oApl:Abrir( "cadantip","optica, numero",,,1 )
 CopyaSQL( oDlg,hRes,.t.,,,::cRut )
 hRes:Destroy()

 hRes := oApl:Abrir( "cadrcaja","optica, rcaja",,,1 )
 CopyaSQL( oDlg,hRes,.f.,,,::cRut )
 hRes:Destroy()

 hRes := oApl:Abrir( "cadnotac","optica, numero",,,1 )
 CopyaSQL( oDlg,hRes,.t.,,,::cRut )
 hRes:Destroy()

 hRes := oApl:Abrir( "cadnotad","optica, numero",,,1 )
 CopyaSQL( oDlg,hRes,.t.,,,::cRut )
 hRes:Destroy()
aFac := { oApl:oEmp:NUMFACU,oApl:oEmp:NOTASC,0 }
cQry := "SELECT c.numero, c.numfac, c.fecha, c.clase, "+;
              "d.codigo, d.cantidad, d.pcosto, c.tipo "+;
        "FROM cadnotac c LEFT JOIN cadnotad d ON "     +;
         "c.optica = d.optica AND c.numero = d.numero "+;
        "WHERE c.optica = " +  LTRIM(STR( aTin[1] ))   +;
         " AND c.fecha >= " + xValToChar( aTin[2] )    +;
         " AND c.fecha <= " + xValToChar( aTin[3] )    +;
         " ORDER BY c.numero"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
cQry := "SELECT numfac, pagado FROM cadpagos "  +;
        "WHERE optica = " + LTRIM(STR(aTin[1])) +;
         " AND fecpag = [Fec]"                  +;
         " AND tipo   = "+ xValToChar(oApl:Tipo)+;
         " AND numcheque = '[Doc]'"             +;
         " AND formapago = 7 AND pordonde = 'N'"
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aFac[3]  # aRes[1]
      aFac[3] := aFac[2] := aRes[1]
      oApl:cPer := NtChr( aRes[3],"1" )
      aPag := STRTRAN( cQry,"[Fec]",xValToChar(aRes[3]) )
      aPag := STRTRAN( aPag,"[Doc]",LTRIM(STR(aRes[1])) )
      hPag := If( MSQuery( oApl:oMySql:hConnect,aPag ) ,;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      nP   := MSNumRows( hPag )
      While nP > 0
         aPag := MyReadRow( hPag )
         AEVAL( aPag, { | xV,nX | aPag[nX] := MyClReadCol( hPag,nX ) } )
         NotaCre( aPag[1],aRes[3],aRes[1],aPag[2],aRes[4] )
         nP --
      EndDo
      MSFreeResult( hPag )
      NotaCre( aRes[2],aRes[3],aRes[1],,aRes[4] )  //( nFac,dFec,nDoc,nPago,nClase )
      If aRes[4] == 5
         NotaCre( aRes[2],aRes[3],aRes[1],1,aRes[4] )
      EndIf
   EndIf
   If aRes[4] <= 2
      oApl:nEmpresa := If( aRes[8] == "F", 21, aTin[1] )
      Actualiz( aRes[5],aRes[6],aRes[3],7,aRes[7] )
      oApl:nEmpresa := aTin[1]
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
aFac[3]   := 0
oApl:lFam := .f.
cQry := "SELECT numfac, fechoy, totalfac, tipo, indicador, autoriza FROM cadfactu "+;
        "WHERE optica  = " +  LTRIM(STR( aTin[1])) +;
         " AND fechoy >= " + xValToChar( aTin[2] ) +;
         " AND fechoy <= " + xValToChar( aTin[3] ) +;
         " AND numfac >= " +  LTRIM(STR( aV[1] ) ) +;
         " AND tipo  <> 'Z' ORDER BY numfac"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0 .AND. aV[1] > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aFac[1] := aRes[1]
   If aFac[3]  < aFac[1]
      If aFac[3] # 0
         AADD( aFac, aFac[3] )
      EndIf
      aFac[3] := aFac[1]
   EndIf
   If aRes[5] # "A"
      oApl:cPer   := NtChr( aRes[2],"1" )
      oApl:nSaldo := aRes[3]
      oApl:Tipo   := aRes[4]
      GrabaSal( aFac[1],1,0 )
      oApl:nEmpresa := If( TRIM(aRes[6]) == "FOCA", 21, aTin[1] )
      oApl:oVen:dbEval( {|o| GrabaV( o:CANTIDAD,"N",2,o:FECFAC,0,1 ) }      ,;
                        {"optica",aTin[1],"numfac",aFac[1],"tipo",oApl:Tipo ,;
                         "LEFT(codart,2) NOT IN ","('02','05')","indicador <> ","D"} )
      oApl:nEmpresa := aTin[1]
   EndIf
   aFac[3] ++
   nL --
EndDo
MSFreeResult( hRes )
If aFac[1] > oApl:oEmp:NUMFACU .OR. aFac[2] > oApl:oEmp:NOTASC
   oApl:oEmp:NUMFACU := aFac[1] ; oApl:oEmp:NOTASC := aFac[2]
EndIf
If oApl:oEmp:FECVENTA < aTin[3]
   oApl:oEmp:FECVENTA:= aTin[3]
EndIf
   oApl:oEmp:Update(.f.,1)
 cQry := "UPDATE cadnotad d, cadnotac c, cadventa v "+;
         "SET d.pcosto = v.pcosto "                  +;
         "WHERE c.optica = " +  LTRIM(STR( aTin[1] ))+;
          " AND c.fecha >= " + xValToChar( aTin[2] ) +;
          " AND c.fecha <= " + xValToChar( aTin[3] ) +;
          " AND d.optica = c.optica"                 +;
          " AND d.numero = c.numero"                 +;
          " AND v.optica = c.optica"                 +;
          " AND v.numfac = c.numfac"                 +;
          " AND v.codart = d.codigo"
 MSQuery( oApl:oMySql:hConnect,cQry )
aRes := ::cRut + "CADANTIF.DBF"
If FILE( aRes )
   BorraFile( "CADANTIF",{"DBF"},oApl:cRuta2 )
   BorraFile( "CADANTIF",{"ULT"},::cRut )
   cQry := oApl:cRuta2 + "CADANTIF.DBF"
   COPY FILE &(aRes) TO &(cQry)
   dbUseArea( .t.,, oApl:cRuta2 + "CADANTIF","Tmp" )

   cQry := "UPDATE cadantic SET numfac = "
   While !Tmp->(EOF())
      Guardar( cQry              + LTRIM(STR(Tmp->NUMFAC))+;
              " WHERE optica = " + LTRIM(STR(Tmp->OPTICA))+;
                " AND numero = " + LTRIM(STR(Tmp->NUMERO)), "cadantic" )
      Tmp->(dbSkip())
   EndDo
   Tmp->(dbCloseArea())
   cQry := STRTRAN( aRes,".DBF",".ULT" )
   RENAME &(aRes) TO &(cQry)
 //cQry := "UPDATE cadantic c, cadantif f SET c.numfac = f.numfac "+;
 //        "WHERE f.optica = c.optica" +;
 //         " AND f.numero = c.numero"
Else
   If aTin[1] == 18
      cQry := "UPDATE cadantic c, cadfactu u SET c.numfac = u.numfac "+;
              "WHERE u.optica  = " +  LTRIM(STR( aTin[1]))+;
               " AND u.fechoy >= " + xValToChar( aTin[2] )+;
               " AND u.fechoy <= " + xValToChar( aTin[3] )+;
               " AND u.remplaza > 0"                      +;
               " AND u.autoriza = 'FOCA'"                 +;
               " AND c.optica = 21 AND c.numero = u.remplaza"
      MSQuery( oApl:oMySql:hConnect,cQry )
   EndIf
   cQry := "UPDATE cadantic c, cadfactu u SET c.numfac = u.numfac "+;
           "WHERE u.optica  = " +  LTRIM(STR( aTin[1]))+;
            " AND u.fechoy >= " + xValToChar( aTin[2] )+;
            " AND u.fechoy <= " + xValToChar( aTin[3] )+;
            " AND u.remplaza > 0"                      +;
            " AND u.autoriza <> 'FOCA'"                +;
            " AND c.optica = u.optica AND c.numero = u.remplaza"
   MSQuery( oApl:oMySql:hConnect,cQry )
EndIf
cQry := "SELECT numfac, fecpag, pagado-IFNULL(p_de_mas,0), tipo FROM cadpagos "+;
        "WHERE optica  = "  + LTRIM(STR( aTin[1]))+;
         " AND fecpag >= " + xValToChar( aTin[2] )+;
         " AND fecpag <= " + xValToChar( aTin[3] )+;
         " AND pagado > 0 AND formapago <= 4"     +;
         " AND indicador NOT IN ('A','*') ORDER BY numfac"
//       " AND Numfac >= " +  LTRIM(STR( aV[2] ) )+;
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0 .AND. aV[2] > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   oDlg:cMsg := "Actualizo PAGOS" + STR(aRes[1])
   oDlg:Refresh() ; SysRefresh()
   oApl:cPer := NtChr( aRes[2],"1" )
   oApl:Tipo := aRes[4]
   oApl:lFam := SaldoFac( aRes[1] )
   GrabaSal( aRes[1],1,aRes[3] )
   If oApl:nSaldo - aRes[3] = 0
      oApl:oFac:Seek( { "optica",aTin[1],"numfac",aRes[1],"tipo",aRes[4] } )
      oApl:oFac:INDICADOR := "C" ; oApl:oFac:FECHACAN := aRes[2]
      oApl:oFac:Update(.f.,1)
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
/*
cQry := "UPDATE cadinven i, cadantid d SET i.pvendida = d.precioven, "   +;
        "i.factuven = d.numero, i.fecventa = d.fecha, i.situacion = 'A' "+;
        "WHERE d.optica = " +  LTRIM(STR( aTin[1]))+;
         " AND d.fecha >= " + xValToChar( aTin[2] )+;
         " AND d.fecha <= " + xValToChar( aTin[3] )+;
         " AND d.indicador = ''"                   +;
         " AND LEFT(d.codart,2) = '01'"            +;
         " AND i.codigo = d.codart AND i.optica = d.optica"+;
         " AND (i.factuven = 0 .OR. i.factuven = d.numero)"
MSQuery( oApl:oMySql:hConnect,cQry )
*/
ActuCliente( oDlg,"OPTICA",::cRut )
cQry := "UPDATE cadfactu c, cadclieo n SET c.codigo_nit = n.codigo_cli " +;
        "WHERE c.optica     = n.optica"             +;
         " AND c.codigo_nit = n.codigo_nit"         +;
         " AND c.optica  = " +  LTRIM(STR( aTin[1]))+;
         " AND c.fechoy >= " + xValToChar( aTin[2] )+;
         " AND c.fechoy <= " + xValToChar( aTin[3] )
MSQuery( oApl:oMySql:hConnect,cQry )
cQry := STRTRAN( cQry,"fechoy","fecha" )
MSQuery( oApl:oMySql:hConnect,STRTRAN(cQry,"factu","antic") )

ActuCedulas( { 0,0,.t. },,::cRut )
BorraFile( "REPLICA",{"DBF"} )
cQry := "UPDATE cadfactu c, histocli n SET c.codigo_cli = n.codigo_cli " +;
        "WHERE c.optica     = n.optica"             +;
         " AND c.codigo_cli = n.codigo_nit"         +;
         " AND c.optica  = " +  LTRIM(STR( aTin[1]))+;
         " AND c.fechoy >= " + xValToChar( aTin[2] )+;
         " AND c.fechoy <= " + xValToChar( aTin[3] )
MSQuery( oApl:oMySql:hConnect,cQry )
cQry := STRTRAN( cQry,"fechoy","fecha" )
MSQuery( oApl:oMySql:hConnect,STRTRAN(cQry,"factu","antic") )
If LEFT( ::cRut,2 ) # "A:"
   aPag := { "CADCLIEN","HCEDULAS" }
   FOR nP := 1 TO 2
      BorraFile( aPag[nP],{"ULT"},::cRut )
      cQry := ::cRut + aPag[nP] + ".DBF"
      aRes := STRTRAN( cQry,".DBF",".ULT" )
      RENAME &(cQry) TO &(aRes)
   NEXT nP
EndIf

If oApl:lEnLinea
   RETURN NIL
EndIf
oDlg:cMsg := "Grabando Ventas en IBM"
oDlg:Refresh() ; SysRefresh()
::aLS[1] := 2  ; ::aMV[1,8] := 1
::aLS[2] := aTin[2]
::aLS[3] := aTin[3]
::Ventas( oGet )
::aLS[1] := 6
::NCredito( oGet )
::aLS[1] := 7
::RCaja( oGet )

cQry := "SELECT optica, fecventa, fec_hoy FROM cadempre " +;
        "WHERE internet = '1' AND fecventa < fec_hoy"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   oApl:oEmp:Seek( { "optica",aRes[1] } )
   oDlg:cMsg := "Grabando RCAJA en IBM " + oApl:oEmp:LOCALIZ
   oDlg:Refresh() ; SysRefresh()
   oApl:nEmpresa := aRes[1]
   ::aLS[1] := 7
   ::aLS[2] := aRes[2]
   ::aLS[3] := aRes[3] -1 //If( aRes[3] > aRes[2], 1, 0 )
   ::RCaja( oGet )
   ::aLS[1] := 2
   ::Ventas( oGet )
   ::aLS[1] := 6
   ::NCredito( oGet )
   cQry := "UPDATE cadempre SET fecventa = " + xValToChar( aRes[3] )+;
          " WHERE optica = " + LTRIM(STR(aRes[1]))
   MSQuery( oApl:oMySql:hConnect,cQry )
   nL --
EndDo
MSFreeResult( hRes )

MsgInfo( "Ventas Actualizadas","HECHO" )
If LEN( aFac ) > 3
   cQry := ""
   AEVAL( aFac, {|nFac| cQry += STR(nFac) + CRLF },4 )
   MsgStop( cQry,"FALTAN FACTURAS" )
EndIf
RETURN NIL

//------------------------------------//
METHOD Ajustes() CLASS TVentas
   LOCAL aTin := { 0,CTOD(""),CTOD(""),0,.f. }
   LOCAL aFile := { "PAGOS","FACTU","" }, cUlt
If MsgYesNo( "Si esta todo Ok.", "Inserte el DISKETTE con la Cartera" )
   ::NEW( "*.DBF" )
   FOR aTin[4] := 1 TO 1
      If !AbreDbf( "Tem",aFile[aTin[4]],,::cRut )
         RETURN NIL
      EndIf
       aTin[5] := { "FECPAG","FECHOY" }[aTin[4]]
      MsgMeter( { | oMeter, oText, oDlg, lEnd | ;
                Revisar( oMeter,oText,oDlg,@lEnd,@aTin ) },;
                aFile[aTin[4]],"Revisando" )
      Tem->(dbCloseArea())
   NEXT
EndIf
oApl:nEmpresa := aTin[1]
//BorraFile( "FACTU",{"DBF"},oApl:cRuta2 )
BorraFile( "PAGOS",{"DBF"},oApl:cRuta2 )
cUlt := ::cRut + "PAGOS.DBF"
aFile:= oApl:cRuta2 + "PAGOS.DBF"
COPY FILE &(cUlt) TO &(aFile)
dbUseArea( .t.,,oApl:cRuta2+"PAGOS","Tmp" )
Tmp->(dbGoTop())
While !Tmp->(EOF())
   oApl:oPag:xBlank()
   oApl:oPag:OPTICA    := Tmp->OPTICA    ; oApl:oPag:NUMFAC    := Tmp->NUMFAC
   oApl:oPag:TIPO      := Tmp->TIPO      ; oApl:oPag:FECPAG    := Tmp->FECPAG
   oApl:oPag:ABONO     := Tmp->ABONO     ; oApl:oPag:PAGADO    := Tmp->PAGADO
   oApl:oPag:RETENCION := Tmp->RETENCION ; oApl:oPag:DEDUCCION := Tmp->DEDUCCION
   oApl:oPag:DESCUENTO := Tmp->DESCUENTO ; oApl:oPag:NUMCHEQUE := Tmp->NUMCHEQUE
   oApl:oPag:CODBANCO  := Tmp->CODBANCO  ; oApl:oPag:FORMAPAGO := Tmp->FORMAPAGO
   oApl:oPag:INDICADOR := Tmp->INDICADOR ; oApl:oPag:INDRED    := Tmp->INDRED
   oApl:oPag:PORDONDE  := Tmp->PORDONDE  ; oApl:oPag:P_DE_MAS  := Tmp->P_DE_MAS
   oApl:oPag:Append()
   oApl:Tipo := Tmp->TIPO
   ::GrabaFac( Tmp->NUMFAC,Tmp->FECPAG,Tmp->PAGADO,Tmp->FORMAPAGO )
   Tmp->(dbSkip())
EndDo
Tmp->(dbCloseArea())
cUlt := ::cRut + "PAGOS.ULT"
ERASE  &(cUlt)
RENAME &(aFile) TO &(cUlt)
/*
MsgWait( "Actualizando FACTU","Por Favor Espere.." )
cUlt := ::cRut + "FACTU.DBF"
aFile:= oApl:cRuta2+ "FACTU.DBF"
COPY FILE &(cUlt) TO &(aFile)
dbUseArea( .t.,,oApl:cRuta2+"FACTU","Tmp" )
Tmp->(dbGoTop())
While !Tmp->(EOF())
   oApl:Tipo := Tmp->TIPO
   ::GrabaFac( Tmp->NUMFAC,Tmp->FECHAENT,0,10 )
   oApl:oPag:dbEval( {|o| o:INDICADOR := "A", o:Update( .f.,1 ) },;
                     {"optica",Tmp->OPTICA, "numfac",Tmp->NUMFAC ,;
                      "tipo",Tmp->TIPO,"indicador NOT IN ","('A','D')"} )
   Tmp->(dbSkip())
EndDo
Tmp->(dbCloseArea())
cUlt := ::cRut + "FACTU.ULT"
ERASE  &(cUlt)
RENAME &(aFile) TO &(cUlt)
*/
MsgInfo( "Actualización de Cartera","HECHA" )
RETURN NIL

//------------------------------------//
METHOD GrabaFac( nNumFac,dFec,nPago,nMov ) CLASS TVentas
   LOCAL aCan := { "P",CTOD("") }, lSi, nSaldo
oApl:oFac:Seek( { "optica",oApl:nEmpresa,"numfac",nNumFac,"tipo",oApl:Tipo } )
oApl:cPer := NtChr( dFec,"1" )
oApl:lFam := SaldoFac( nNumFac )
nSaldo    := oApl:nSaldo + If( nMov == 8, nPago, -nPago )
If nMov == 10
   If oApl:oFac:INDICADOR == "A"
      RETURN NIL
   EndIf
   nPago := oApl:nSaldo
Else
   If nSaldo == 0
      aCan := { "C",dFec }
   EndIf
   oApl:oFac:INDICADOR := aCan[1] ; oApl:oFac:FECHACAN := aCan[2]
   oApl:oFac:Update( .f.,1 )
EndIf
If nPago # 0
   GrabaSal( nNumFac,If( nMov == 8, 2, 1 ),nPago )
EndIf
If nMov >= 9
   oApl:oFac:INDICADOR := "A" ; oApl:oFac:FECHAENT := dFec
   oApl:oFac:Update( .f.,1 )
   oApl:oVen:Seek( { "optica",oApl:nEmpresa,"numfac",nNumFac,"tipo",oApl:Tipo,;
                     "indicador NOT IN ","('A','D')" } )
   While !oApl:oVen:Eof()
      lSi := oApl:oInv:Seek( {"codigo",oApl:oVen:CODART} )
      If oApl:oInv:MONEDA == "C" .AND. oApl:cPer # LEFT( DTOS(oApl:oVen:FECFAC),6 )
         lSi := .f.
      EndIf
      If lSi
         If oApl:oInv:GRUPO == "1" .AND. oApl:oInv:FACTUVEN == nNumFac
            oApl:oInv:PVENDIDA  := 0   ; oApl:oInv:FACTUVEN := 0
            oApl:oInv:SITUACION := "E" ; oApl:oInv:FECVENTA := CTOD("")
            oApl:oInv:Update( .f.,1 )
         EndIf
         Actualiz( oApl:oVen:CODART,oApl:oVen:CANTIDAD,dFec,7 )
         oApl:oVen:INDICADOR := If( nMov == 10, "A", "D" )
         oApl:oVen:FECDEV    := dFec ; oApl:oVen:Update( .f.,1 )
      EndIf
      oApl:oVen:Skip(1):Read()
      oApl:oVen:xLoad()
   EndDo
EndIf
RETURN NIL

//------------------------------------//
PROCEDURE ActuCliente( oDlg,cHago,cCli )
   LOCAL aNit, cQry, cTemp := oApl:cRuta2 + "REPLICA.DBF"
cCli += "Cadclien.DBF"
If !FILE( cCli )
   RETURN
EndIf
COPY FILE &(cCli) TO &(cTemp)
If !AbreDbf( "Rep","Replica",,,.f. )
   RETURN
EndIf
oDlg:cMsg := "Actualizando CLIENTES"
oDlg:Refresh() ; SysRefresh()
cTemp := "SELECT codigo_cli FROM cadclieo " +;
         "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
      " AND codigo_nit = [NIT]"
While !Rep->(EOF())
   If Rango( Rep->CODIGO,{0,800214345,890110934,890111588,890117716} )
      // PAN, COC, OGB, FPV
      Rep->(dbSkip())
      LOOP
   EndIf
   aNit := { 1,Rep->CODIGO_NIT,.f. }
/*
   cQry := "codigo = " + LTRIM(STR(Rep->CODIGO))
   If Rep->EXPORTAR == "C"
      cCli := Buscar( STRTRAN( cTemp,"[NIT]",LTRIM(STR( aNit[2] )) ),"CM",,8 )
      If !EMPTY( cCli )
         cQry := "codigo_nit = " + LTRIM(STR(cCli))
      EndIf
   EndIf
   oApl:oNit:Seek( cQry,"CM" )
*/
   oApl:oNit:Seek( {"codigo",Rep->CODIGO} )
   If oApl:oNit:lOK .AND. oApl:oNit:CODIGO_NIT # aNit[2]
      cCli := Buscar( STRTRAN( cTemp,"[NIT]",LTRIM(STR( aNit[2] )) ),"CM",,8 )
      If !EMPTY( cCli )
         aNit[2] := cCli
      EndIf
   EndIf
   While oApl:oNit:nRowCount  >= aNit[1]
      If oApl:oNit:CODIGO_NIT == aNit[2] .OR.;
         oApl:oNit:NOMBRE     == Rep->NOMBRE
         aNit[3] := .t.
         EXIT
      EndIf
      oApl:oNit:Skip(1):Read()
      oApl:oNit:xLoad()
      aNit[1] ++
   EndDo
   If !oApl:oNit:lOK
       oApl:oNit:Seek( "codigo = 999999 LIMIT 1","CM" )
      oApl:oNit:CODIGO    := Rep->CODIGO    ; oApl:oNit:DIGITO    := Rep->DIGITO
      oApl:oNit:TIPOCOD   := Rep->TIPOCOD   ; oApl:oNit:NOMBRE    := Rep->NOMBRE
      oApl:oNit:TELEFONO  := Rep->TELEFONO  ; oApl:oNit:FAX       := Rep->FAX
      oApl:oNit:DIRECCION := Rep->DIRECCION ; oApl:oNit:EMAIL     := Rep->EMAIL
      oApl:oNit:CODIGO_CIU:= Rep->CODIGO_CIU
      oApl:oNit:POR_DSCTO := Rep->POR_DSCTO ; oApl:oNit:CONSULTA  := Rep->CONSULTA
      oApl:oNit:EPS       := Rep->EPS       ; oApl:oNit:GRUPO     := Rep->GRUPO
      oApl:oNit:AUTORETEN := Rep->AUTORETEN
    //If cHago == "OPTICA" .AND. !oApl:oNit:lOK
      If oApl:oNit:CODIGO_NIT == 0
         oApl:oNit:CODIGO_NIT := Buscar( "SELECT MAX(codigo_nit) FROM cadclien","CM" ) + 1
      EndIf
      Guardar( oApl:oNit,!oApl:oNit:lOK,.t. )
   ElseIf Rep->EXPORTAR == "C"
      oApl:oNit:CODIGO    := Rep->CODIGO    ; oApl:oNit:DIGITO    := Rep->DIGITO
      oApl:oNit:TIPOCOD   := Rep->TIPOCOD   ; oApl:oNit:NOMBRE    := Rep->NOMBRE
      oApl:oNit:TELEFONO  := Rep->TELEFONO  ; oApl:oNit:FAX       := Rep->FAX
      oApl:oNit:DIRECCION := Rep->DIRECCION ; oApl:oNit:EMAIL     := Rep->EMAIL
      oApl:oNit:CODIGO_CIU:= Rep->CODIGO_CIU
      oApl:oNit:POR_DSCTO := Rep->POR_DSCTO ; oApl:oNit:CONSULTA  := Rep->CONSULTA
      oApl:oNit:EPS       := Rep->EPS       ; oApl:oNit:GRUPO     := Rep->GRUPO
      oApl:oNit:AUTORETEN := Rep->AUTORETEN
      Guardar( oApl:oNit,.f.,.f. )
   EndIf
   If cHago == "OPTICA" .AND.;
      oApl:oNit:CODIGO_NIT # Rep->CODIGO_NIT
      cQry := Buscar( STRTRAN( cTemp,"[NIT]",LTRIM(STR(Rep->CODIGO_NIT)) ),"CM",,8 )
      If EMPTY( cQry )
         //row_id, optica, codigo_nit, codigo_cli
         cQry := "INSERT INTO cadclieo VALUES( null, "    +;
                  LTRIM(STR(oApl:nEmpresa))        + ", " +;
                  LTRIM(STR(     Rep->CODIGO_NIT)) + ", " +;
                  LTRIM(STR(oApl:oNit:CODIGO_NIT)) + " )"
         Guardar( cQry,"cadclieo" )
      EndIf
   EndIf
   Rep->(dbSkip())
EndDo
Rep->(dbCloseArea())
BorraFile( "REPLICA",{"DBF"} )
RETURN