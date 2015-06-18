// Programa.: CAORESUM.PRG     >>> Martin A. Toloza Lozano <<<
// Notas....: Resumen o Descuadre de la Cartera.
#include "FiveWin.ch"

MEMVAR oApl

PROCEDURE CaoResum()
   LOCAL oDlg, oGet := ARRAY(6), aVta := { oApl:cPer,"R",.f.,.t. }
DEFINE DIALOG oDlg TITLE "Resumen de la Cartera" FROM 0, 0 TO 09,42
   @ 02,00 SAY "DIGITE EL PERIODO"   OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02,92 GET oGet[1] VAR aVta[1] OF oDlg PICTURE "999999" SIZE 36,12 PIXEL;
      VALID NtChr( aVta[1],"P" )
   @ 16,00 SAY "RESUMEN O DESCUADRE" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 16,92 GET oGet[2] VAR aVta[2] OF oDlg PICTURE "!"  SIZE 08,12 PIXEL;
      VALID aVta[2] $ "RD"
   @ 30,20 CHECKBOX oGet[3] VAR aVta[3] PROMPT "Ajusto Saldos" OF oDlg ;
      WHEN aVta[2] == "D"  SIZE 60,12 PIXEL
   @ 30,92 CHECKBOX oGet[4] VAR aVta[4] PROMPT "Vista &Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 46, 60 BUTTON oGet[5] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[5]:Disable(), ListoRes( aVta ), oDlg:End() ) PIXEL
   @ 46,110 BUTTON oGet[6] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 52, 02 SAY "[CAORESUM]" OF oDlg PIXEL SIZE 34,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT ( Empresa( .t. ) )
RETURN

//------------------------------------//
STATIC PROCEDURE ListoRes( aVT )
   LOCAL aLS := { "",0,0,0,0,0,0,0,0,0,0,0,0,aVT[3] }
   LOCAL aRes, hRes, cQry, nL, nK, oRpt := TDosPrint()
aLS[1] := NtChr( aVT[1],"F" )
aLS[2] := CTOD( NtChr( aLS[1],"4" ) )
aLS[3] := NtChr( aLS[1]-1,"1" )         // Anomes Anterior
oRpt:New( oApl:cPuerto,oApl:cImpres,{"RESUMEN DE LA CARTERA",;
           "Movimiento a " + NtChr( aLS[2],"3" ) },aVt[4] )
If aVt[2] == "D"
   oRpt:aEnc[2] := "Descuadre a " + NtChr( aLS[2],"3" )
   oRpt:Titulo( 80 )
   cQry := "SELECT p.numfac, f.indicador FROM cadpagos p, cadfactu f "+;
           "WHERE p.optica = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND p.fecpag >= "+ xValToChar( aLS[1] )     +;
            " AND p.fecpag <= "+ xValToChar( aLS[2] )     +;
            " AND p.tipo   = " + xValToChar( oApl:Tipo )  +;
            " AND f.optica = p.optica"                    +;
            " AND f.numfac = p.numfac AND f.tipo = p.tipo"+;
            " AND f.fechoy < " + xValToChar( aLS[1] )     +;
            " GROUP BY p.numfac"
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nK   := MSNumRows( hRes )
   While nK > 0
      aRes := MyReadRow( hRes )
      aRes[1]   := VAL( aRes[1] )
      oApl:cPer := aLS[3]
      aLS[04]   := SaldoFac( aRes[1],1 )
      oApl:cPer := aVT[1]
      oApl:lFam := SaldoFac( aRes[1] )
      aLS[05]   := oApl:nSaldo
      Abonos( @aLS,aRes[1],oRpt,aRes[2] )
      If aRes[2] $ "P " .AND. oApl:nSaldo == 0
         oApl:oFac:Seek( {"optica",oApl:nEmpresa,"numfac",aRes[1],"tipo",oApl:Tipo} )
         FechaCan( aLS[2],aRes[1] )
      EndIf
      nK --
   EndDo
Else
   cQry := "SELECT SUM(s.saldo) FROM cadfactm s "         +;
           "WHERE s.optica = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND s.tipo   = 'U'"                         +;
            " AND s.anomes = (SELECT MAX(m.anomes) FROM cadfactm m "+;
                              "WHERE m.optica = s.optica" +;
                               " AND m.numfac = s.numfac" +;
                               " AND m.tipo   = s.tipo"   +;
                               " AND m.anomes <= '" + aLS[3] + "')"
   FOR nK := 1 TO 2
      hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      If MSNumRows( hRes ) > 0
         aRes := MyReadRow( hRes )
         aLS[3+nK] := MyClReadCol( hRes,1 )
      EndIf
      MSFreeResult( hRes )
      cQry := STRTRAN( cQry,aLS[3],aVT[1] )
   NEXT nS
EndIf

//aLS[2] := SECONDS()
oApl:cPer := aVt[1]
oApl:oFac:Seek( {"optica",oApl:nEmpresa,"fechoy >= ",aLS[1],"fechoy <= ",aLS[2],;
                 "tipo",oApl:Tipo,"indicador <>","A"} )
While !oApl:oFac:Eof()
   oApl:lFam := SaldoFac( oApl:oFac:NUMFAC )
   aLS[06] += oApl:oFac:TOTALFAC
   cQry    := oApl:oFac:INDICADOR
   If aVt[2] == "D"
      aLS[5] := oApl:nSaldo
      Abonos( @aLS,oApl:oFac:NUMFAC,oRpt,cQry )
   EndIf
   If (cQry == "P" .OR. EMPTY( cQry )) .AND. oApl:nSaldo == 0
      FechaCan( aLS[2],oApl:oFac:NUMFAC )
   EndIf
   oApl:oFac:Skip(1):Read()
   oApl:oFac:xLoad()
EndDo
//MsgInfo( "Ha tardado " + STR( Seconds() - aLS[2] ),"Saldo Actual" )

If aVt[2] == "D"
   oRpt:NewPage()
   oRpt:End() ; RETURN
EndIf
cQry := "SELECT formapago, pagado, abono, deduccion, descuento, retencion + IFNULL(retiva,0) +"+;
        " IFNULL(retica,0) + IFNULL(retcre,0), indicador, indred, 0 FROM cadpagos "+;
        "WHERE optica = " + LTRIM(STR(oApl:nEmpresa)) +;
         " AND fecpag >= "+ xValToChar( aLS[1] )      +;
         " AND fecpag <= "+ xValToChar( aLS[2] )      +;
         " AND tipo   = " + xValToChar( oApl:Tipo )   +;
         " AND indicador <> 'A' UNION ALL "           +;
        "SELECT formapago, pagado, abono, deduccion, descuento, retencion + IFNULL(retiva,0) +"+;
        " IFNULL(retica,0) + IFNULL(retcre,0), 'T', indred, 1 FROM cadantip " +;
        "WHERE optica = " + LTRIM(STR(oApl:nEmpresa)) +;
         " AND fecha >= " + xValToChar( aLS[1] )      +;
         " AND fecha <= " + xValToChar( aLS[2] )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aRes[1] == 8
      aLS[09] += aRes[2]     //N.D.
   ElseIf aRes[1] >= 7
      aLS[10] += aRes[2]     //N.C.
   ElseIf aRes[9] == 1
      aLS[08] += aRes[3]
   Else
      nK  := aRes[3] + aRes[4] + aRes[6] +;
             If( oApl:cPer < "199604", 0, aRes[5] )
      aVT[04] := aRes[4] + aRes[5]
      aLS[07] += (nK - If( aRes[7] == "-", aRes[5], 0))
//    aLS[08] += If( aRes[1] == 4 .AND. aRes[8], aRes[3], 0 )
      If aRes[1] == 3 .AND. aRes[2] < nK
         aLS[11] += aRes[3] + aRes[4]
         aLS[12] += If( aRes[7] == ".", 0, aVT[4] )
         aLS[13] += aRes[6]
      EndIf
   EndIf
   nL --
EndDo
MSFreeResult( hRes )

aLS[07] := aLS[07] - aLS[11] - If( oApl:cPer < "199604", 0, aLS[12] )
aLS[11] := aLS[04] + aLS[06] - aLS[07] + aLS[09] - aLS[10] + aLS[13]
aLS[12] := aLS[05] - aLS[11]
cQry    := "999,999,999"
oRpt:Titulo( 80 )
oRpt:Say( 10,10,"Saldo Anterior............" + TRANSFORM( aLS[04],cQry ) )
oRpt:Say( 12,10,"Cargos del Mes............" + TRANSFORM( aLS[06],cQry ) )
oRpt:Say( 14,10,"Abonos del Mes............" + TRANSFORM( aLS[07],cQry ) )
oRpt:Say( 16,10,"Diferidos................." + TRANSFORM( aLS[08],cQry ) )
oRpt:Say( 18,10,"Notas Debitos............." + TRANSFORM( aLS[09],cQry ) )
oRpt:Say( 20,10,"Notas Creditos............" + TRANSFORM( aLS[10],cQry ) )
oRpt:Say( 22,10,"Saldo Actual.............." + TRANSFORM( aLS[05],cQry ) )
oRpt:Say( 24,10,"Saldo Matematico.........." + TRANSFORM( aLS[11],cQry ) )
oRpt:Say( 26,10,"Diferencia................" + TRANSFORM( aLS[12],cQry ) )
oRpt:NewPage()
oRpt:End()
RETURN

//------------------------------------//
STATIC PROCEDURE Abonos( aLS,nNumfac,oRpt,cIndica )
   LOCAL nK
oApl:oPag:dbEval( {|o| If( o:FORMAPAGO >= 7                                            ,;
                         (aLS[10] += (o:PAGADO * {-1,1,-1}[o:FORMAPAGO-6]) )           ,;
                         (nK      := o:ABONO     + o:RETENCION + o:DEDUCCION +          ;
                                     o:DESCUENTO + o:RETIVA    + o:RETICA    + o:RETCRE,;
                          aLS[07] += nK, If( o:FORMAPAGO == 3 .AND. o:PAGADO < nK ,;
                         (aLS[11] += o:ABONO + o:DEDUCCION + o:DESCUENTO), ) ) ) },;
                  {"optica",oApl:nEmpresa,"numfac",nNumfac,"tipo",oApl:Tipo       ,;
                   "fecpag >= ",aLS[1],"fecpag <= ",aLS[2],"indicador <>","A"} )
aLS[04] := If( aLS[06] > 0, aLS[06], aLS[04] )
aLS[07] -= aLS[11]
aLS[06] := aLS[04] - aLS[07] + aLS[10]
If ABS( aLS[05] ) # ABS( aLS[06] )
   oRpt:Say( oRpt:nL++,01," Fac" + STR(nNumfac)+ " Ant" +;
              TRANSFORM( aLS[04],"999,999,999" ) + " Act" +;
              TRANSFORM( aLS[05],"999,999,999" ) + " Mov" +;
              TRANSFORM( aLS[06],"999,999,999" ) + cIndica,,,1 )
   aLS[7] -= If( oApl:lFam, oApl:oFam:ABONOS, 0 )
   If aLS[14] .AND. aLS[07] > 0
      GrabaSal( nNumfac,1,aLS[07] )
      oApl:nSaldo := SaldoFac( nNumfac,1 )
   EndIf
EndIf
AFILL( aLS,0,6,6 )
RETURN

//------------------------------------//
STATIC PROCEDURE FechaCan( dFec,nNumfac )
   LOCAL dFecP //nK := SECONDS()
dFecP := Buscar( { "optica",oApl:nEmpresa,"numfac",nNumfac,"tipo",oApl:Tipo },;
                 "cadpagos","MAX(fecpag)",8 )
If !EMPTY( dFecP )
   dFecP := MAX( dFecP,oApl:oFac:FECHOY )
   If dFecP <= dFec
      oApl:oFac:INDICADOR := "C" ; oApl:oFac:FECHACAN := dFecP
      oApl:oFac:Update(.f.,1)
      oApl:oWnd:SetMsg( "Factura "+STR(nNumfac) )
   EndIf
EndIf
RETURN

//------------------------------------//
FUNCTION CopyaSQL( oDlg,oTb,lAuto,cRuta,lFac,cOri )
   LOCAL aSQL, cQry, n, nFldCount := oTb:FieldCount()
   DEFAULT cRuta := oApl:cRuta2, lFac := .f., cOri := "A:"
oDlg:cMsg := "Adicionando " + UPPER(oTb:cName)
oDlg:Refresh() ; SysRefresh()
BorraFile( oTb:cName,{"DBF"},cRuta )
cOri := cOri + oTb:cName + ".DBF"
aSQL := cRuta+ oTb:cName + ".DBF"
COPY FILE &(cOri) TO &(aSQL)
dbUseArea( .t.,, cRuta+oTb:cName,"Tmp" )
If UPPER(FieldName( 1 )) # UPPER(oTb:FieldName( 1 ))
   aSQL := { "INSERT INTO " + oTb:cName + " VALUES ( NULL, ","",1,2,2 }
Else
   aSQL := { "INSERT INTO " + oTb:cName + " VALUES ( ","",0,3,1 }
EndIf
If FCOUNT() < nFldCount .AND.;
  (UPPER(oTb:cName) == "CADANTIP" .OR. UPPER(oTb:cName) == "CADPAGOS")
   aSQL[2] := ", NULL, NULL"
   nFldCount -= 2
EndIf
If UPPER(oTb:cName) == "CADRCAJA" .AND. UPPER(FieldName( 6 )) == "ANTICIPO"
   aSQL[2] := ", NULL, NULL"
   nFldCount -= 2
EndIf
While !Tmp->(EOF())
   cQry  := aSQL[1]
   FOR n := aSQL[5] TO nFldCount
      cRuta:= FieldGet( n-aSQL[3] )
      cQry += If( MyIsAutoInc( oTb:hResult,n ) .AND. lAuto, 'NULL'       ,;
              If( VALTYPE( cRuta ) == "C", ( '"' + ALLTRIM(cRuta) + '"' ),;
                  xValToChar( cRuta,1 ) ) ) + ", "
   NEXT n
   cQry := LEFT( cQry,LEN(cQry)-2 ) + aSQL[2] + ' )'
   If lFac
      BuscaDup( Tmp->(FieldGet( aSQL[4] )),Tmp->(FieldGet( aSQL[4]+1 )),.f. )
   EndIf
   MSQuery( oApl:oMySql:hConnect,cQry )
   Tmp->(dbSkip())
Enddo

If (n := Tmp->(LASTREC()) ) > 0 .AND.;
   (UPPER(oTb:cName) == "CADFACTU" .OR. UPPER(oTb:cName) == "CADPAGOS")
   Tmp->(dbGoTop())
   n := Tmp->(FieldGet( 3 ))
EndIf
dbCloseArea()
aSQL := STRTRAN( cOri,".DBF",".ULT" )
ERASE  &(aSQL)
RENAME &(cOri) TO &(aSQL)

RETURN n

//------------------------------------//
FUNCTION Revisar( oMeter,oText,oDlg,lEnd,aTin )
   LOCAL cCam := aTin[5], lFac
If (oMeter:nTotal := LASTREC()) > 0
   If AT( "FEC",cCam ) > 0
      aTin[1] := Tem->OPTICA
      aTin[2] := If( EMPTY( aTin[2] ), &(cCam), aTin[2] )
      aTin[2] := MIN( aTin[2],&(cCam) )
   EndIf
   lFac := If( Rango( aTin[4],{1,3} ) .AND. LEN( aTin ) == 8, .t. , .f. )
   WHILE !EOF()
      If aTin[4] <= 3
         aTin[3] := MAX( aTin[3],&(cCam) )
         If lFac
//          If Tem->TIPO # "Z"
            If aTin[4] == 1
               aTin[7] := MIN( aTin[7],Tem->NUMFAC )
            Else
               aTin[8] := MIN( aTin[8],Tem->NUMERO )
            EndIf
         EndIf
      EndIf
      dbSkip()
      oMeter:Set( RecNo() )
      SysRefresh()
   ENDDO
EndIf
RETURN NIL