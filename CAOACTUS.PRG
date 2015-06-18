// Programa.: CAOACTUS.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Cambiar numeracion de Facturas
#include "Fivewin.ch"

MEMVAR oApl

PROCEDURE CaoNumer( lActuS )
   LOCAL oDlg, oGet := ARRAY(8), aOpc, aRep := TRIM( oApl:cUser )
//   LOCAL aPrv := Privileg( "RENUMERAR" )
   DEFAULT lActuS := .f.
If aRep # "Martin" .AND. aRep # "root"
   aOpc := If( lActuS, "ACTUALIZAR LOS SALDOS", "RENUMERAR LAS FACTURAS" )
   MsgStop( "Usted no está Autorizado para " + aOpc,oApl:cUser )
   RETURN
EndIf
aOpc := { DATE(),DATE(),1,1,6,0,"Nro. FACTURA" }
aRep := { {|| Renumera( aOpc,oDlg ) },"RENUMERAR LAS FACTURAS" }
If lActuS
   aRep := { {|| ActuSaldo( aOpc,oDlg ) },"ACTUALIZAR LOS SALDOS" }
   aOpc[7] := "GRUPO"
EndIf

DEFINE DIALOG oDlg TITLE aRep[2] FROM 0, 0 TO 12,50
   @ 02, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02, 92 GET oGet[1] VAR aOpc[1] OF oDlg SIZE 40,12 PIXEL
   @ 16, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 16, 92 GET oGet[2] VAR aOpc[2] OF oDlg    ;
      VALID aOpc[2] >= aOpc[1] SIZE 40,12 PIXEL;
      WHEN !lActuS
   @ 30, 00 SAY  "INCREMENTAR FACTURAS EN" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 30, 92 GET oGet[3] VAR aOpc[3] OF oDlg PICTURE "9999" SIZE 24,12 PIXEL
    oGet[3]:cTooltip := "2 = Resumen para ver descuadres"
   @ 44, 00 SAY aOpc[7] + " INICIAL" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 44, 92 GET oGet[4] VAR aOpc[4] OF oDlg ;
      VALID aOpc[4] > 0 SIZE 44,12 PIXEL
   @ 58, 00 SAY aOpc[7] + "   FINAL" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 58, 92 GET oGet[5] VAR aOpc[5] OF oDlg ;
      VALID aOpc[5] >= aOpc[4] SIZE 44,12 PIXEL
   @ 58,154 SAY oGet[6] VAR aOpc[6] OF oDlg PIXEL SIZE 44,18 ;
      UPDATE COLOR nRGB( 160,19,132 )
   @ 74, 50 BUTTON oGet[7] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[7]:Disable(), EVAL( aRep[1] ), oDlg:End() ) PIXEL
   @ 74,100 BUTTON oGet[8] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 80, 02 SAY "[CAOACTUS]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
PROCEDURE Renumera( aLS,oDlg )
   LOCAL aRes, hRes, cQry, nL
cQry := "UPDATE cadfactu SET numfac = numfac "        + If( aLS[3] == 0,;
              "* -1", "+ " + LTRIM( STR(aLS[3] ) ) )  +;
       " WHERE optica  = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND numfac >= " + LTRIM( STR( aLS[4] ) )   +;
         " AND numfac <= " + LTRIM( STR( aLS[5] ) )   +;
         " AND tipo    = " + xValToChar( oApl:Tipo )  +;
         " AND fechoy >= " + xValToChar( aLS[1] )     +;
         " AND fechoy <= " + xValToChar( aLS[2] )
 MSQuery( oApl:oMySql:hConnect,cQry )
/*
cQry := STRTRAN( cQry,"cadfactu","cadventa" )
cQry := STRTRAN( cQry,"fechoy","fecfac" )
 MSQuery( oApl:oMySql:hConnect,cQry )
cQry := STRTRAN( cQry,"cadventa","cadfactu" )
cQry := STRTRAN( cQry,"fecfac","fecpag" )
 MSQuery( oApl:oMySql:hConnect,cQry )
*/
If aLS[3] == 0
   aLS[4] *= -1
   aLS[5] *= -1
Else
   aLS[4] += aLS[3]
   aLS[5] += aLS[3]
EndIf
cQry := "SELECT numfac, codart FROM cadventa "        +;
        "WHERE optica  = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND numfac >= " + LTRIM( STR( aLS[4] ) )   +;
         " AND numfac <= " + LTRIM( STR( aLS[5] ) )   +;
         " AND tipo    = " + xValToChar( oApl:Tipo )  +;
         " AND fecfac >= " + xValToChar( aLS[1] )     +;
         " AND fecfac <= " + xValToChar( aLS[2] )     +;
         " AND LEFT(codart,2) = '01'"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
//MsgInfo( cQry,"Registros"+STR(nL) )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aLS[3] == 0
      aLS[6] := aRes[1] * -1
   Else
      aLS[6] := aRes[1] - aLS[3]
   EndIf
   If oDlg # NIL
      oDlg:Update()
   EndIf
   oApl:oInv:Seek( {"codigo",aRes[2]} )
   If oApl:oInv:OPTICA   == oApl:nEmpresa .AND. oApl:oInv:FACTUVEN == aLS[6]
      oApl:oInv:FACTUVEN := aRes[1] ; oApl:oInv:Update( .f.,1 )
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
RETURN

//------------------------------------//
PROCEDURE ActuSaldo( aLS,oDlg )
   LOCAL aGF, cCod, cGI, cRep, nCon, nCan, dFecI
   LOCAL aMV, aRes, hRes, cQry, nL
aLS[1] := NtChr( LEFT( DTOS( aLS[1] ),6 ),"F" )
aLS[2] := CTOD( NtChr( aLS[1],"4" ) )
If aLS[3] == 2
   Descuadre( aLS,oDlg )
   RETURN
ElseIf aLS[4] == 0
   aGF := { .t.,aLS[6],aLS[5] }
   cGI := " AND d.codigo = " + xValToChar( aLS[5] )
   aLS[5] := 6
Else
   aGF := { .f.,0,{ "01",,"03","04","05","60" }[aLS[4]] }
   cGI := " AND LEFT(d.codigo,2) >= '" + aGF[3] +;
         "' AND LEFT(d.codigo,2) <= '" + { "01",,"03","04","05","99" }[aLS[5]] + "'"
EndIf
If aLS[5] == 9
   aLS[6] := NtChr( aLS[2],"1" )
   cQry := "SELECT IF(d.material='P', '1', '2'), d.consec, "  +;
                  "d.cantidad, d.pcosto "                     +;
           "FROM comprasc c, cadmontd d "                     +;
           "WHERE c.optica = "    + LTRIM(STR(oApl:nEmpresa)) +;
            " AND c.fecingre >= " + xValToChar( aLS[1] )      +;
            " AND c.fecingre <= " + xValToChar( aLS[2] )      +;
            " AND c.moneda <> 'X'"                            +;
            " AND d.ingreso = c.ingreso"                      +;
            " AND d.indica IN('A','E')"
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   MsgInfo( cQry,"TOTAL "+STR(nL) )
   While nL > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      nCon     := VAL( aRes[2] )
      FOR nCan := 1 TO aRes[3]
         aLS[6]:= "010" + aRes[1] + STRZERO( nCon,6 )
         oDlg:Update()
         cRep  := SaldoInv( aLS[6],aLS[6],1 )
         If aRes[4] # oApl:aInvme[2]
            MsgInfo( TRANSFORM( aRes[4],"999,999,999" ),aLS[6] )
         EndIf
         nCon ++
      NEXT
      nL --
   EndDo
   MSFreeResult( hRes )
   RETURN
EndIf

 oApl:oWnd:SetMsg( "Por Favor espere Actualizando Saldos" )
cRep   := NtChr( aLS[1]-1,"1" )   // ANOMES Anterior
aLS[4] := NtChr( aLS[2],"1" )     // ANOMES Final
aLS[6] := LOWER( ALLTRIM(oApl:cUser) ) + "sm"

 MSQuery( oApl:oMySql:hConnect,"DROP TABLE " + aLS[6] )
 MSQuery( oApl:oMySql:hConnect,"CREATE TABLE " + aLS[6] + " LIKE promedio" )
 aMV := "INSERT INTO " + aLS[6] + " (fecha, codigo, cantidad, pcosto, mov) "

If LEFT( aGF[3],2 ) == "01"
   cQry := "SELECT c.fecingre, IF(d.material='P', '1', '2'), "+;
                  "d.cantidad, d.consec, d.pcosto "           +;
           "FROM cadmontd d, comprasc c "                     +;
           "WHERE d.indica <> ' '"                            +;
            " AND c.ingreso   = d.ingreso"                    +;
            " AND c.optica    = " + LTRIM(STR(oApl:nEmpresa)) +;
            " AND c.fecingre >= " + xValToChar( aLS[1] )      +;
            " AND c.fecingre <= " + xValToChar( aLS[2] )      +;
            " AND c.moneda <> 'X'"
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   While nL > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      nCon     := VAL( aRes[4] )
      FOR nCan := 1 TO aRes[3]
         cCod  := "010" + aRes[2] + STRZERO( nCon,6 )
         If !aGF[1] .OR.;
            (aGF[1] .AND. aGF[3] == cCod)
            cQry := aMV + "VALUES( " + xValToChar( aRes[1] )     +;
                    ", '" + cCod + "', 1, " + LTRIM(STR(aRes[5]))+ ", 1 )"
            MSQuery( oApl:oMySql:hConnect,cQry )
         EndIf
         nCon ++
      NEXT nCan
      nL --
   EndDo
   MSFreeResult( hRes )
EndIf

cQry := aMV + ;
        "SELECT c.fecingre, d.codigo, d.cantidad, d.pcosto, 1 "+;
        "FROM cadartid d, comprasc c "                      +;
        "WHERE d.indica <> 'B'"  + cGI                      +;
         " AND c.ingreso = d.ingreso"                       +;
         " AND c.optica  = "   + LTRIM(STR(oApl:nEmpresa))  +;
         " AND c.fecingre >= " + xValToChar( aLS[1] )       +;
         " AND c.fecingre <= " + xValToChar( aLS[2] )       +;
         " AND c.moneda  = 'X'"
//MsgInfo( cQry,"1_Compras" )
 MSQuery( oApl:oMySql:hConnect,cQry )
If oApl:nEmpresa == 0
   cQry := aMV + ;
          "SELECT d.fechad, d.codigo, d.cantidad, d.pcosto, 3 "+;
          "FROM cadinven i, caddevod d "                    +;
          "WHERE i.codigo  = d.codigo"                      +;
           " AND i.grupo  <> '6' AND i.moneda <> 'C'"       +;
           " AND i.compra_d = '0'"                          +;
           " AND d.destino = 0   AND d.optica <> 0"         +;
           " AND d.fechad >= " + xValToChar( aLS[1] )       +;
           " AND d.fechad <= " + xValToChar( aLS[2] )       +;
           " AND d.causadev IN(2,3)" + cGI
//MsgInfo( cQry,"2_Devoluciones" )
 MSQuery( oApl:oMySql:hConnect,cQry )
   cQry := aMV + ;
           "SELECT c.fecharep, d.codigo, d.cantidad, i.pcosto, 2 "+;
           "FROM cadrepod d, cadinven i, cadrepoc c "       +;
           "WHERE d.numrep = c.numrep"                      +;
            " AND d.indica <> 'B'" + cGI                    +;
            " AND i.codigo = d.codigo"                      +;
            " AND c.fecharep >= " + xValToChar( aLS[1] )    +;
            " AND c.fecharep <= " + xValToChar( aLS[2] )
Else
   cQry := aMV + ;
           "SELECT fechad, codigo, cantidad, pcosto, 3 "    +;
           "FROM caddevod d "                               +;
           "WHERE destino = "    + LTRIM(STR(oApl:nEmpresa))+;
            " AND fechad >= "    + xValToChar( aLS[1] )     +;
            " AND fechad <= "    + xValToChar( aLS[2] )     +;
            " AND causadev = 4"  + cGI
//MsgInfo( cQry,"2_Traslados" )
 MSQuery( oApl:oMySql:hConnect,cQry )

   cQry := aMV + ;
           "SELECT c.fecharep, d.codigo, d.cantidad, d.pcosto, 1 "+;
           "FROM cadrepod d, cadrepoc c "                   +;
           "WHERE d.indica <> 'B'" + cGI                    +;
            " AND c.numrep = d.numrep"                      +;
            " AND c.optica = "   + LTRIM(STR(oApl:nEmpresa))+;
            " AND c.fecharep >= " + xValToChar( aLS[1] )    +;
            " AND c.fecharep <= " + xValToChar( aLS[2] )
EndIf
//MsgInfo( cQry,"3_Reposiciones" )
 MSQuery( oApl:oMySql:hConnect,cQry )

cQry := STRTRAN( aMV,")",", row_vta)" ) + ;
        "SELECT fecfac, codart, cantidad, pcosto, 2, row_id "+;
         "FROM cadventa "                                   +;
         "WHERE optica  = "    + LTRIM(STR(oApl:nEmpresa))  +;
          " AND fecfac >= "    + xValToChar( aLS[1] )       +;
          " AND fecfac <= "    + xValToChar( aLS[2] )       +;
          " AND tipo    = 'U'"                              +;
         STRTRAN( cGI,"d.codigo","codart" )
//MsgInfo( cQry,"4_Ventas" )
 MSQuery( oApl:oMySql:hConnect,cQry )

cQry := aMV + ;
        "SELECT c.fechad, d.codigo, d.cantidad, d.pcosto, u.movto "+;
        "FROM caddevod d, cadcausa u, caddevoc c "          +;
        "WHERE d.optica  = c.optica"                        +;
         " AND d.documen = c.documen" + cGI                 +;
         " AND u.tipo = d.causadev AND u.clase = 'Devolucion'"+;
         " AND c.optica  = " + LTRIM(STR(oApl:nEmpresa))    +;
         " AND c.fechad >= " + xValToChar( aLS[1] )         +;
         " AND c.fechad <= " + xValToChar( aLS[2] )
//MsgInfo( cQry,"5_Devoluciones" )
 MSQuery( oApl:oMySql:hConnect,cQry )

cQry := aMV + ;
        "SELECT c.fecha, d.codigo, d.cantidad, d.pcosto, 7 "+;
        "FROM cadnotad d, cadnotac c "                      +;
        "WHERE c.optica = d.optica"                         +;
         " AND c.numero = d.numero" + cGI                   +;
         " AND c.optica = [OPT]"                            +;
         " AND c.fecha >= " + xValToChar( aLS[1] )          +;
         " AND c.fecha <= " + xValToChar( aLS[2] )          +;
         " AND c.clase <= 2"
CambiarNC( @cQry )
//MsgInfo( cQry,"6_N.Credito" )
 MSQuery( oApl:oMySql:hConnect,cQry )

cQry := aMV + "SELECT " + xValToChar( aLS[2] )              +;
                ", d.codigo, d.cantidad, d.pcosto, u.movto "+;
        "FROM cadcausa u, cadajust d "                      +;
        "WHERE u.tipo   = d.tipo AND u.clase = 'Ajustes'"   +;
         " AND d.optica = " + LTRIM(STR(oApl:nEmpresa))     +;
         " AND d.fecha >= " + xValToChar( aLS[1] )          +;
         " AND d.fecha <= " + xValToChar( aLS[2] )          +;
         " AND d.indica <> 'B'" + cGI
//MsgInfo( cQry,"7_Ajustes" )
 MSQuery( oApl:oMySql:hConnect,cQry )

 aMV := { 0,0,0,0,0,0,0,0,0,"" }
cQry := "SELECT codigo, cantidad, pcosto, mov, row_vta FROM " + aLS[6] +;
        " WHERE LEFT(codigo,2) NOT IN('02', '05')" +;
        " AND LENGTH(codigo) >= 10 ORDER BY codigo, fecha"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL  := MSNumRows( hRes )) > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
   SaldoInv( aRes[1],cRep )
   aMV[08] := oApl:aInvme[1]
   aMV[09] := oApl:aInvme[2]
   aMV[10] := aRes[1]
EndIf

cCod := " WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
          " AND codigo = '[COD]'"                     +;
          " AND anomes = " + xValToChar( aLS[4] )
While nL > 0
   If Rango( aRes[4],{1,3,5,7} )
         nCan := ABS( aMV[8] ) + aRes[2]
      If nCan > 0
         aMV[9] := (ABS( aMV[8] )*aMV[9] + aRes[2]*aRes[3]) / nCan
         aMV[9] := ROUND( aMV[9],2 )
      ElseIf aMV[8] < 0
         aMV[9] := aRes[3]
      EndIf
      aMV[8] += aRes[2]
   Else
      aMV[8] -= aRes[2]
   EndIf
      aMV[ aRes[4] ] += aRes[2]
   If aLS[3] > 0 .AND. aRes[5] > 0
      cQry := "UPDATE cadventa SET pcosto = " + LTRIM(STR(aMV[9])) +;
             " WHERE row_id = " + LTRIM(STR(aRes[5]))
      MSQuery( oApl:oMySql:hConnect,cQry )
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aMV[10] # aRes[1]
      If aGF[1]
         cGI := "PC.A=" + TRANSFORM(aGF[2],"999,999,999.99") + CRLF +;
                "PC.N=" + TRANSFORM(aMV[9],"999,999,999.99") + CRLF +;
                "EX.N=" + TRANSFORM(aMV[8],"999,999,999")
         If !MsgNoYes( cGI,"Cambio el Promedio" )
            EXIT
         EndIf
      EndIf
      If Buscar( "SELECT 1 FROM cadinvme" + STRTRAN( cCod,"[COD]",TRIM(aMV[10]) ),;
                 "CM",,8,,4 ) == 0
         cQry := "INSERT INTO cadinvme VALUES( NULL, " + LTRIM(STR(oApl:nEmpresa))+;
                                                 ", '" + aLS[4]             +;
                                                 "', " + LTRIM(STR(aMV[8])) +;
                                                 ", '" +  TRIM(aMV[10])     +;
                                                 "', " + LTRIM(STR(aMV[1])) +;
                                                  ", " + LTRIM(STR(aMV[2])) +;
                                                  ", " + LTRIM(STR(aMV[5])) +;
                                                  ", " + LTRIM(STR(aMV[6])) +;
                                      ", NULL, NULL, " + LTRIM(STR(aMV[3])) +;
                                                  ", " + LTRIM(STR(aMV[4])) +;
                                                  ", " + LTRIM(STR(aMV[7])) +;
                                                  ", " + LTRIM(STR(aMV[9])) + " )"
      Else
         cQry := "UPDATE cadinvme SET entradas = " + LTRIM(STR(aMV[1])) +;
                                    ", salidas = " + LTRIM(STR(aMV[2])) +;
                                    ", devol_e = " + LTRIM(STR(aMV[3])) +;
                                    ", devol_s = " + LTRIM(STR(aMV[4])) +;
                                  ", ajustes_e = " + LTRIM(STR(aMV[5])) +;
                                  ", ajustes_s = " + LTRIM(STR(aMV[6])) +;
                                   ", devolcli = " + LTRIM(STR(aMV[7])) +;
                                 ", existencia = " + LTRIM(STR(aMV[8])) +;
                                     ", pcosto = " + LTRIM(STR(aMV[9])) +;
                 STRTRAN( cCod,"[COD]",TRIM(aMV[10]) )
      EndIf
      MSQuery( oApl:oMySql:hConnect,cQry )
      If aLS[3] == 0
         cQry := "UPDATE cadventa v, " + aLS[6] + " m SET v.pcosto = " + LTRIM(STR(aMV[9])) +;
                " WHERE m.row_vta  = v.row_id AND m.row_vta <> 0"
         RunSql1( cQry,"Actualizo Ventas" )
      EndIf
      SaldoInv( aRes[1],cRep )
      AFILL( aMV,0,1,7 )
      aMV[08] := oApl:aInvme[1]
      aMV[09] := oApl:aInvme[2]
      aMV[10] := aRes[1]
      oApl:oWnd:SetMsg( "CODIGO = "+aMV[10] )
   EndIf
EndDo
MSFreeResult( hRes )
/*
cQry := "DELETE FROM cadinvme "                       +;
        "WHERE optica = " + LTRIM(STR(oApl:nEmpresa)) +;
         " AND LEFT(codigo,2) >= '" + cGI             +;
        "' AND LEFT(codigo,2) <= '" + aGF             +;
        "' AND anomes = " + xValToChar( aLS[4] )      +;
        "' AND entradas  = 0 AND salidas   = 0"       +;
         " AND ajustes_e = 0 AND ajustes_s = 0"       +;
         " AND devol_e   = 0 AND devol_s   = 0 AND devolcli = 0"
MSQuery( oApl:oMySql:hConnect,cQry )
oApl:Tipo := "U"
*/
RETURN

//------------------------------------//
PROCEDURE CambiarNC( cQry )
   If oApl:nEmpresa == 18
      cQry := STRTRAN( cQry,"[OPT]","18" ) +;
         " AND c.tipo <> 'F'"
   ElseIf oApl:nEmpresa == 21
      cQry := STRTRAN( cQry,"[OPT]","18" ) +;
         " AND c.tipo  = 'F'"
   Else
      cQry := STRTRAN( cQry,"[OPT]",LTRIM(STR(oApl:nEmpresa)) )
   EndIf
RETURN

//------------------------------------//
STATIC PROCEDURE Descuadre( aLS,oDlg )
   LOCAL cGI, cGF, cQry, nCon, nCan
   LOCAL aRes, hRes, nL, oTB, oRpt
oTB := oApl:Abrir( "cadsaldo","codigo",,.t. )
cGF := { "01",,"03","04","05","60" }[aLS[4]]
cGI := " AND LEFT(d.codigo,2) >= '" + cGF +;
      "' AND LEFT(d.codigo,2) <= '" + { "01",,"03","04","05","99" }[aLS[5]] + "'"

oDlg:SetText( "<< ESPERE >> ARMANDO LOS DATOS " )
If cGF == "01"
   cQry := "SELECT IF(d.material='P', '1', '2'), d.cantidad, d.consec "+;
           "FROM cadmontd d, comprasc c "                     +;
           "WHERE d.ingreso = c.ingreso"                      +;
            " AND d.indica <> ' '"                            +;
            " AND c.optica  = "   + LTRIM(STR(oApl:nEmpresa)) +;
            " AND c.fecingre >= " + xValToChar( aLS[1] )      +;
            " AND c.fecingre <= " + xValToChar( aLS[2] )      +;
            " AND c.moneda <> 'X'"
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   aLS[6] := STR(nL,5) + " MONTURAS" ; oDlg:Update()
   While nL > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      nCon     := VAL( aRes[3] )
      FOR nCan := 1 TO aRes[2]
         cQry  := "010" + aRes[1] + STRZERO( nCon,6 )
         If oTB:Seek( {"codigo",cQry} )
            oTB:ENTRADAS ++
            oTB:Update(.f.,1)
         Else
            oTB:CODIGO := cQry ; oTB:ENTRADAS := 1
            oTB:Insert( .f. )
         EndIf
         nCon ++
      NEXT
      nL --
   EndDo
   MSFreeResult( hRes )
EndIf

//cQry := "SELECT d.codigo, SUM(d.cantidad) "               +;
cQry := "SELECT d.codigo, d.cantidad "                    +;
        "FROM cadartid d, comprasc c "                    +;
        "WHERE d.ingreso = c.ingreso"                     +;
         " AND d.indica <> 'B'" + cGI                     +;
         " AND c.optica = "    + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fecingre >= " + xValToChar( aLS[1] )     +;
         " AND c.fecingre <= " + xValToChar( aLS[2] )     +;
         " AND c.moneda  = 'X'"
//         " GROUP BY d.codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
aLS[6] := STR(nL,5) + " ARTIC" ; oDlg:Update()
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If oTB:Seek( {"codigo",aRes[1]} )
      //oTB:ENTRADAS += aRes[2]
      //oTB:Update(.f.,1)
      cQry := "UPDATE cadsaldo SET entradas = IFNULL(entradas,0) + " +;
               LTRIM(STR(aRes[2])) + " WHERE codigo = '[COD]'"
   Else
      //oTB:ENTRADAS := aRes[2] ; oTB:CODIGO := aRes[1]
      //oTB:Insert( .f. )
      cQry := "INSERT INTO cadsaldo (codigo, entradas) VALUES( '[COD]', "+;
               LTRIM(STR(aRes[2])) + " )"
   EndIf
   Guardar( STRTRAN( cQry,"[COD]",ALLTRIM(aRes[1]) ),"cadsaldo" )
   nL --
EndDo
MSFreeResult( hRes )
cQry := "SELECT d.codigo, d.cantidad, d.causadev, "+;
               "i.grupo, i.moneda, i.compra_d "    +;
        "FROM cadinven i, caddevod d "                    +;
        "WHERE i.codigo  = d.codigo"                      +;
         " AND d.destino = " + LTRIM(STR(oApl:nEmpresa))  +;
         " AND d.fechad >= " + xValToChar( aLS[1] )       +;
         " AND d.fechad <= " + xValToChar( aLS[2] )       +;
         " AND d.optica  > 0 AND d.causadev "             +;
               If( oApl:nEmpresa == 0, "IN(2,3)", "= 4" ) + cGI
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
aLS[6] := STR(nL,5) + " TRASLADOS" ; oDlg:Update()
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If LEFT(aRes[1],2) # "05"
      If aRes[3] # 4 .AND. (aRes[4] == "6" .OR. aRes[5] == "C" .OR. aRes[6])
         aRes[4] := "" //NO ACTUALIZO
      Else
         If oTB:Seek( {"codigo",aRes[1]} )
            oTB:DEVOL_E += aRes[2]
            oTB:Update(.f.,1)
         Else
            oTB:DEVOL_E := aRes[2] ; oTB:CODIGO := aRes[1]
            oTB:Insert( .f. )
         EndIf
      EndIf
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
If oApl:nEmpresa == 0
   cQry := "SELECT d.codigo, d.cantidad "               +;
           "FROM cadrepod d, cadrepoc c "               +;
           "WHERE d.numrep = c.numrep"                  +;
            " AND d.indica <> 'B'" + cGI                +;
            " AND c.fecharep >= " + xValToChar( aLS[1] )+;
            " AND c.fecharep <= " + xValToChar( aLS[2] )
Else
   cQry := "SELECT d.codigo, d.cantidad "               +;
           "FROM cadrepod d, cadrepoc c "               +;
           "WHERE d.numrep = c.numrep"                  +;
            " AND d.indica <> 'B'" + cGI                +;
            " AND c.optica = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND c.fecharep >= " + xValToChar( aLS[1] )+;
            " AND c.fecharep <= " + xValToChar( aLS[2] )
EndIf
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
aLS[6] := STR(nL,5) + " REPOSICIO" ; oDlg:Update()
While nL > 0
   aRes := MyReadRow( hRes )
   If LEN( aRes[1] ) >= 10
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      oTB:Seek( {"codigo",aRes[1]} )
      If oApl:nEmpresa == 0
         oTB:SALIDAS  += aRes[2]
      Else
         oTB:ENTRADAS += aRes[2]
      EndIf
      If oTB:lOK
         oTB:Update(.f.,1)
      Else
         oTB:CODIGO := aRes[1]
         oTB:Insert( .f. )
      EndIf
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
If oApl:nEmpresa == 18 .OR. oApl:nEmpresa == 21
   cQry := "SELECT d.codart, d.cantidad "               +;
           "FROM cadventa d, cadfactu c "               +;
           "WHERE d.optica  = c.optica"                 +;
            " AND d.numfac  = c.numfac"                 +;
            " AND d.tipo    = c.tipo"                   +;
            STRTRAN( cGI,"codigo","codart" )            +;
            " AND c.optica  = 18"                       +;
            " AND c.fechoy >= " + xValToChar( aLS[1] )  +;
            " AND c.fechoy <= " + xValToChar( aLS[2] )  +;
            " AND c.autoriza "                          +;
            If( oApl:nEmpresa == 18, "<>", "=" ) + " 'FOCA'"
Else
   cQry := "SELECT codart, cantidad "                   +;
           "FROM cadventa "                             +;
           "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND fecfac >= " + xValToChar( aLS[1] )    +;
            " AND fecfac <= " + xValToChar( aLS[2] )    +;
            " AND tipo = 'U'"                           +;
            STRTRAN( cGI,"d.codigo","codart" )
EndIf
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
aLS[6] := STR(nL,5) + " VENTAS" ; oDlg:Update()
While nL > 0
   aRes := MyReadRow( hRes )
   If LEN( aRes[1] ) >= 10
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      If oTB:Seek( {"codigo",aRes[1]} )
         oTB:SALIDAS  += aRes[2]
         oTB:Update(.f.,1)
      Else
         oTB:SALIDAS  := aRes[2] ; oTB:CODIGO := aRes[1]
         oTB:Insert( .f. )
      EndIf
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
cQry := "SELECT d.codigo, d.cantidad, u.movto "        +;
        "FROM caddevod d, cadcausa u, caddevoc c "     +;
        "WHERE d.optica  = c.optica"                   +;
         " AND d.documen = c.documen" + cGI            +;
         " AND u.tipo = d.causadev AND u.clase = 'Devolucion'"+;
         " AND c.optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fechad >= " + xValToChar( aLS[1] )    +;
         " AND c.fechad <= " + xValToChar( aLS[2] )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
aLS[6] := STR(nL,5) + " DEVOC" ; oDlg:Update()
While nL > 0
   aRes := MyReadRow( hRes )
   If LEN( aRes[1] ) >= 10
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      oTB:Seek( {"codigo",aRes[1]} )
      If aRes[3] == 2
         oTB:SALIDAS  += aRes[2]
      ElseIf aRes[3] == 4
         oTB:DEVOL_S  += aRes[2]
      Else
         oTB:DEVOLCLI += aRes[2]
      EndIf
      If oTB:lOK
         oTB:Update(.f.,1)
      Else
         oTB:CODIGO := aRes[1]
         oTB:Insert( .f. )
      EndIf
   EndIf
   nL --
EndDo
MSFreeResult( hRes )

cQry := "SELECT d.codigo, d.cantidad "             +;
        "FROM cadnotad d, cadnotac c "             +;
        "WHERE c.optica = d.optica"                +;
         " AND c.numero = d.numero" + cGI          +;
         " AND c.optica = [OPT]"                   +;
         " AND c.fecha >= " + xValToChar( aLS[1] ) +;
         " AND c.fecha <= " + xValToChar( aLS[2] ) +;
         " AND c.clase <= 2"
CambiarNC( @cQry )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
aLS[6] := STR(nL,5) + " N.CREDITO" ; oDlg:Update()
While nL > 0
   aRes := MyReadRow( hRes )
   If LEN( aRes[1] ) >= 10
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      oTB:Seek( {"codigo",aRes[1]} )
      oTB:DEVOLCLI += aRes[2]
      If oTB:lOK
         oTB:Update(.f.,1)
      Else
         oTB:CODIGO := aRes[1]
         oTB:Insert( .f. )
      EndIf
   EndIf
   nL --
EndDo
MSFreeResult( hRes )

aLS[3] := NtChr( aLS[1]-1,"1" )   // ANOMES Anterior
aLS[4] := NtChr( aLS[2],"1" )     // ANOMES Final
cQry := "SELECT d.codigo, d.cantidad, u.movto "         +;
        "FROM cadcausa u, cadajust d "                  +;
        "WHERE u.clase  = 'Ajustes' AND d.tipo = u.tipo"+;
         " AND d.optica = " + LTRIM(STR(oApl:nEmpresa)) +;
         " AND d.fecha >= " + xValToChar( aLS[1] )      +;
         " AND d.fecha <= " + xValToChar( aLS[2] )      +;
         " AND d.indica <> 'B'" + cGI
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
aLS[6] := STR(nL,5) + " AJUSTES" ; oDlg:Update()
While nL > 0
   aRes := MyReadRow( hRes )
   If LEN( aRes[1] ) >= 10
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      oTB:Seek( {"codigo",aRes[1]} )
      If aRes[3] == 5
         oTB:AJUSTES_E += aRes[2]
      Else
         oTB:AJUSTES_S += aRes[2]
      EndIf
      If oTB:lOK
         oTB:Update(.f.,1)
      Else
         oTB:CODIGO := aRes[1]
         oTB:Insert( .f. )
      EndIf
   EndIf
   nL --
EndDo
MSFreeResult( hRes )

oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"DESCUADRE DE INVENTARIO ", NtChr( aLS[2],"3" ),SPACE(36) +;
         "EXISTENCIA     TOTAL        TOTAL   DEVOLUCION  DEVOLUCION     AJUSTE      AJUSTE  DEVOLUCION     SALDO ",;
         "C O D I G O- -----DESCRIPCION-----  MES ANTER.    ENTRADAS      VENTAS"+;
         "   ENTRADAS     SALIDAS     ENTRADAS     SALIDAS   CLIENTE      ACTUAL"},.t.,1,2 )
cQry := "SELECT s.codigo, i.descrip, s.entradas, s.salidas, s.devol_e, s.devol_s, "+;
                  "s.ajustes_e, s.ajustes_s, s.devolcli, s.existencia, s.anomes "  +;
        "FROM cadinvme s, cadinven i "                           +;
        "WHERE s.optica = " + LTRIM(STR(oApl:nEmpresa))          +;
            STRTRAN( cGI,"d.","s." )                             +;
         " AND s.anomes = (SELECT MAX(m.anomes) FROM cadinvme m "+;
                          "WHERE m.optica = s.optica"            +;
	                         " AND m.codigo = s.codigo"            +;
                           " AND m.anomes <= '" + aLS[4] + "')"  +;
         " AND s.anomes = '" + aLS[4]                            +;
        "' AND i.codigo = s.codigo ORDER BY s.codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aRes[11] == aLS[4]
      cGF := { SaldoInv( aRes[01],aLS[3],1 ),;
               aRes[03],aRes[04],aRes[05],aRes[06],aRes[07],aRes[08],aRes[09],aRes[10] }
   Else
      cGF := { aRes[10],0,0,0,0,0,0,0,aRes[10] }
   EndIf
   oTB:Seek( {"codigo",aRes[1]} )
   If oTB:ENTRADAS  # cGF[2] .OR. oTB:SALIDAS   # cGF[3] .OR.;
      oTB:DEVOL_E   # cGF[4] .OR. oTB:DEVOL_S   # cGF[5] .OR.;
      oTB:AJUSTES_E # cGF[6] .OR. oTB:AJUSTES_S # cGF[7] .OR.;
      oTB:DEVOLCLI  # cGF[8]
      nCan := cGF[1] + cGF[2] - cGF[3] + cGF[4] - cGF[5] + cGF[6] - cGF[7] + cGF[8]
      nCon := cGF[1] + oTB:ENTRADAS  - oTB:SALIDAS   + oTB:DEVOL_E - oTB:DEVOL_S +;
                       oTB:AJUSTES_E - oTB:AJUSTES_S + oTB:DEVOLCLI
      oRpt:Titulo( 141 )
      oRpt:Say( oRpt:nL, 00,aRes[1] )
      oRpt:Say( oRpt:nL, 13,aRes[2],24 )
      oRpt:Say( oRpt:nL, 38,TRANSFORM(cGF[1],"999,999") )
      oRpt:Say( oRpt:nL, 50,TRANSFORM(cGF[2],"@Z 999,999") )
      oRpt:Say( oRpt:nL, 62,TRANSFORM(cGF[3],"@Z 999,999") )
      oRpt:Say( oRpt:nL, 74,TRANSFORM(cGF[4],"@Z 999,999") )
      oRpt:Say( oRpt:nL, 86,TRANSFORM(cGF[5],"@Z 999,999") )
      oRpt:Say( oRpt:nL, 98,TRANSFORM(cGF[6],"@Z 999,999") )
      oRpt:Say( oRpt:nL,110,TRANSFORM(cGF[7],"@Z 999,999") )
      oRpt:Say( oRpt:nL,122,TRANSFORM(cGF[8],"@Z 999,999") )
      oRpt:Say( oRpt:nL,134,TRANSFORM(cGF[9],"999,999") )
      oRpt:Say( oRpt:nL,142,If( nCan # cGF[9], "X", "" ) )
      oRpt:nL ++
      oRpt:Say( oRpt:nL, 50,TRANSFORM(oTB:ENTRADAS ,"@Z 999,999") )
      oRpt:Say( oRpt:nL, 62,TRANSFORM(oTB:SALIDAS  ,"@Z 999,999") )
      oRpt:Say( oRpt:nL, 74,TRANSFORM(oTB:DEVOL_E  ,"@Z 999,999") )
      oRpt:Say( oRpt:nL, 86,TRANSFORM(oTB:DEVOL_S  ,"@Z 999,999") )
      oRpt:Say( oRpt:nL, 98,TRANSFORM(oTB:AJUSTES_E,"@Z 999,999") )
      oRpt:Say( oRpt:nL,110,TRANSFORM(oTB:AJUSTES_S,"@Z 999,999") )
      oRpt:Say( oRpt:nL,122,TRANSFORM(oTB:DEVOLCLI ,"@Z 999,999") )
      oRpt:Say( oRpt:nL,134,TRANSFORM(nCon,"999,999") )
      oRpt:nL ++
   EndIf
   If oTB:lOK
      oTB:ANOMES_AN := "SI"
      oTB:Update(.f.,1)
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
oTB:Seek( "anomes_an <> 'SI'","CM" )
WHILE !oTB:Eof()
   oRpt:Titulo( 141 )
   oRpt:Say( oRpt:nL, 00,oTB:CODIGO )
   oRpt:Say( oRpt:nL, 50,TRANSFORM(oTB:ENTRADAS ,"@Z 999,999") )
   oRpt:Say( oRpt:nL, 62,TRANSFORM(oTB:SALIDAS  ,"@Z 999,999") )
   oRpt:Say( oRpt:nL, 74,TRANSFORM(oTB:DEVOL_E  ,"@Z 999,999") )
   oRpt:Say( oRpt:nL, 86,TRANSFORM(oTB:DEVOL_S  ,"@Z 999,999") )
   oRpt:Say( oRpt:nL, 98,TRANSFORM(oTB:AJUSTES_E,"@Z 999,999") )
   oRpt:Say( oRpt:nL,110,TRANSFORM(oTB:AJUSTES_S,"@Z 999,999") )
   oRpt:Say( oRpt:nL,122,TRANSFORM(oTB:DEVOLCLI ,"@Z 999,999") )
   oRpt:nL ++
   oTB:Skip(1):Read()
   oTB:xLoad()
ENDDO
oRpt:NewPage()
oRpt:End()
oTB:DropIndex( "Codigo" )
oTB:Destroy()
MSQuery( oApl:oMySql:hConnect,"DROP TABLE cadsaldo" )
oApl:oDb:GetTables()
RETURN

//------------------------------------//
PROCEDURE InoPreci()
   LOCAL oDlg, oGet := ARRAY(13), aOpc := { "6000        ",0,0,0,0,"","C",DATE(), }
aOpc[9] := oApl:Abrir( "cadpreci","Codigo",.f.,,10 )
SETKEY( VK_F4,{|| aOpc[2] := -40 ,aOpc[3] := 1, oGet[10]:Click() } )
DEFINE DIALOG oDlg TITLE "Cambia Precio al Público" FROM 0, 0 TO 16,50
   @ 02, 00 SAY "FECHA   CAMBIO" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 02,102 GET oGet[1] VAR aOpc[8] OF oDlg SIZE 40,12 PIXEL UPDATE
   @ 16, 00 SAY "CODIGO [L.CON]" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 16,102 GET oGet[2] VAR aOpc[1] OF oDlg PICTURE "9999999999";
      VALID If( oApl:oInv:Seek( { "codigo",aOpc[1] } )         ,;
              (If( oApl:oInv:GRUPO == "1" .AND. oApl:oInv:SITUACION $ "DV" ,;
                 ( MsgStop( "Montura Vendida o Devuelta" ), .f. )          ,;
                 (aOpc[2] := oApl:oInv:PCOSTO , aOpc[3] := oApl:oInv:PVENTA,;
                  aOpc[5] := oApl:oInv:CODIGO_NIT, oDlg:Update(), .t. ) ) ),;
               (MsgStop( "Este Código NO EXISTE !!!"), .f. )) SIZE 50,12 PIXEL
   @ 30, 30 SAY oGet[3] VAR oApl:oInv:DESCRIP OF oDlg PIXEL SIZE 140,12;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 44, 00 SAY "PRECIO COSTO %" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 44,102 GET oGet[4] VAR aOpc[2] OF oDlg PICTURE "999,999,999.99";
      SIZE 40,12 PIXEL UPDATE
   @ 58, 00 SAY "PRECIO   VENTA" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 58,102 GET oGet[5] VAR aOpc[3] OF oDlg PICTURE "999,999,999.99";
      SIZE 40,12 PIXEL UPDATE
    oGet[5]:cTooltip := "1 = Cambio solamente el Precio de Venta"
   @ 58,150 GET oGet[6] VAR aOpc[4] OF oDlg PICTURE "9999" SIZE 30,12 PIXEL
    oGet[6]:cTooltip := "Año Inicial"
   @ 72, 00 SAY "CODIGO PROVEED [A.F]" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 72,102 GET oGet[7] VAR aOpc[5] OF oDlg PICTURE "9999" SIZE 30,12 PIXEL UPDATE
    oGet[7]:cTooltip := "Año Final"
   @ 72,154 SAY oGet[8] VAR aOpc[6] OF oDlg PIXEL SIZE  44,12 ;
      UPDATE COLOR nRGB( 160,19,132 )
   @ 86, 00 SAY "MONEDA" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 86,102 GET oGet[9] VAR aOpc[7] OF oDlg PICTURE "!";
      SIZE 12,12 PIXEL UPDATE
   @ 90, 02 SAY "[CAOACTUS]" OF oDlg PIXEL SIZE 32,10
   @ 104, 20 BUTTON oGet[10] PROMPT "&Aceptar"  SIZE 38,12 OF oDlg ACTION;
      ( Precios( aOpc,oDlg ), oGet[10]:oJump := oGet[2], oGet[2]:SetFocus() ) PIXEL
   @ 104, 62 BUTTON oGet[11] PROMPT "&Cancelar" SIZE 38,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 104,104 BUTTON oGet[12] PROMPT "&Imprimir" SIZE 38,12 OF oDlg ACTION;
      ( ListaPre( aOpc,.f. ), oGet[12]:oJump := oGet[2], oGet[2]:SetFocus() ) PIXEL
   @ 104,146 BUTTON oGet[13] PROMPT "&Etiqueta" SIZE 38,12 OF oDlg ACTION;
      ( ListaPre( aOpc,.t. ), oGet[13]:oJump := oGet[2], oGet[2]:SetFocus() ) PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
aOpc[9]:Destroy()
SETKEY( VK_F4,{||Empresa()} )
RETURN

//------------------------------------//
STATIC PROCEDURE Precios( aLS,oDlg )
   LOCAL aP := { 0,.f.,0,0,0,0,1 + ROUND( oApl:oEmp:PIVA/100,2 ) }
   LOCAL aRes, hRes, cQry, nL
If LEFT( aLS[1],2 ) == "01"
   aP[4] := If( aLS[2] >= 0, 1, -1 )
   aP[5] := ABS(aLS[2]) / 100
   If NtChr( aLS[1] ) >= 10
      If aLS[3] == 1
         aLS[3] := oApl:oInv:PVENTA + ;
                   Redondear( ROUND( oApl:oInv:PVENTA*aP[5],0 ),500,1000 ) * aP[4]
      ElseIf oApl:oInv:PCOSTO # aLS[2]
         oApl:oInv:PCOSTO := aLS[2]
         aP[2] := .t.
      EndIf
      oApl:oInv:PVENTA := aLS[3]
      oApl:oInv:PPUBLI := ROUND( oApl:oInv:PVENTA*aP[7],0 )
      oApl:oInv:Update(.f.,1)
      PCosto( aLS,aP[2] )
      RETURN
   EndIf
   aP[1] := "Incrementar en un " + TransForm( aLS[2],"999.99%" )
   If !MsgYesNo( aP[1],"Desea" )
      RETURN
   EndIf
   If aLS[4] == 0
      oApl:oInv:Seek( { "codigo_nit",aLS[5],"optica",oApl:nEmpresa,"grupo","1",;
                        "moneda",aLS[7],"situacion","E" } )
      While !oApl:oInv:Eof()
         aLS[6] := oApl:oInv:CODIGO ; oDlg:Update()
         If aLS[3] == 1
            aP[6] := ROUND( oApl:oInv:PVENTA*aP[5],0 )
            oApl:oInv:PVENTA += Redondear( aP[6],500,1000 ) * aP[4]
         Else
            oApl:oInv:PCOSTO += ROUND( oApl:oInv:PCOSTO * aP[5],0 )
            PrecioVenta( oApl:oInv,oDlg )
            aP[2] := .t.
         EndIf
         oApl:oInv:PPUBLI := ROUND( oApl:oInv:PVENTA*aP[7],0 )
         oApl:oInv:Update(.f.,1)
         PCosto( aLS,aP[2] )
         oApl:oInv:Skip(1):Read()
         oApl:oInv:xLoad()
      EndDo
   Else
      cQry := "SELECT s.codigo FROM cadinvme s, cadinven i "  +;
              "WHERE s.optica = " + LTRIM(STR(oApl:nEmpresa)) +;
          " AND LEFT(s.codigo,2) = '01'"                      +;
               " AND s.anomes = (SELECT MAX(m.anomes) FROM cadinvme m "    +;
                                "WHERE m.optica = s.optica"                +;
                                 " AND m.codigo = s.codigo"                +;
                                 " AND m.anomes <= '" + NtChr( aLS[8],"1" )+;
             "') AND s.existencia <> 0"                        +;
               " AND i.codigo = s.codigo"                      +;
               " AND YEAR(i.fecrecep) >= " + LTRIM(STR(aLS[4]))+;
               " AND YEAR(i.fecrecep) <= " + LTRIM(STR(aLS[5]))+;
               " ORDER BY s.optica"
       hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
                   MSStoreResult( oApl:oMySql:hConnect ), 0 )
       nL   := MSNumRows( hRes )
       While nL > 0
          aRes := MyReadRow( hRes )
          aLS[1] := aLS[6] := aRes[1] ; oDlg:Update()
          oApl:oInv:Seek( { "codigo",aRes[1] } )
          If aLS[2] == 0
             oApl:oInv:PVENTA := oApl:oInv:PCOSTO
          Else
             aP[6] := ROUND( oApl:oInv:PVENTA*aP[5],0 )
             oApl:oInv:PVENTA += Redondear( aP[6],500,1000 ) * aP[4]
          EndIf
          oApl:oInv:PPUBLI := ROUND( oApl:oInv:PVENTA*aP[7],0 )
          oApl:oInv:Update(.f.,1)
          PCosto( aLS,aP[2] )
          nL --
       EndDo
       MSFreeResult( hRes )
   EndIf
   aLS[4] := aLS[5] := 0
Else
   aLS[6] := LEFT( aLS[1],4 )
   oApl:oInv:dbEval( {|o| aLS[6] := o:CODIGO , oDlg:Update()     ,;
                          aLS[4] := If( o:INDIVA == 0, aLS[3]    ,;
                                        ROUND( aLS[3]*aP[7],0 ) ),;
                          o:PCOSTO := aLS[2] , o:PVENTA := aLS[3],;
                          o:PPUBLI := aLS[4] , o:Update(.f.,1) } ,;
                     { "LEFT(codigo,4)",aLS[6] } )
EndIf
RETURN

//------------------------------------//
PROCEDURE PCosto( aLS,lCambio )
   LOCAL cPer, nExi, nOpt := oApl:nEmpresa
If LEFT( aLS[1],2 ) == "01"
   oApl:nEmpresa := oApl:oInv:OPTICA
   If lCambio
      cPer := NtChr( aLS[8],"1" )
      oApl:oMes:Seek( { "optica",oApl:nEmpresa,"codigo",aLS[1],;
                        "anomes <= ",cPer },,.f. )
      If oApl:oMes:EXISTENCIA # 0 .AND. oApl:oMes:PCOSTO # oApl:oInv:PCOSTO
         If oApl:oMes:ANOMES == cPer
            oApl:oMes:PCOSTO   := oApl:oInv:PCOSTO   ; oApl:oMes:Update(.f.,1)
         Else
            nExi := oApl:oMes:EXISTENCIA
            oApl:oMes:xBlank()
            oApl:oMes:OPTICA   := oApl:nEmpresa      ; oApl:oMes:ANOMES     := cPer
            oApl:oMes:CODIGO   := aLS[1]             ; oApl:oMes:EXISTENCIA := nExi
            oApl:oMes:FEC_ULTE := oApl:oMes:FEC_ULTS := aLS[8]
            oApl:oMes:DEVOL_E  := oApl:oMes:DEVOL_S  := 1
            oApl:oMes:PCOSTO   := oApl:oInv:PCOSTO   ; oApl:oMes:Append(.f.)
         EndIf
      EndIf
   EndIf
   If aLS[9]:Seek( { "fecha",aLS[8],"codigo",aLS[1] } )
      aLS[9]:PCOSTO := oApl:oInv:PCOSTO ; aLS[9]:PVENTA := oApl:oInv:PVENTA
      aLS[9]:PPUBLI := oApl:oInv:PPUBLI ; aLS[9]:Update(.f.,1)
   Else
      aLS[9]:xBlank()                   ; aLS[9]:OPTICA := oApl:nEmpresa
      aLS[9]:FECHA  := aLS[8]           ; aLS[9]:CODIGO := aLS[1]
      aLS[9]:PCOSTO := oApl:oInv:PCOSTO ; aLS[9]:PVENTA := oApl:oInv:PVENTA
      aLS[9]:PPUBLI := oApl:oInv:PPUBLI ; aLS[9]:Append(.f.)
   EndIf
   oApl:nEmpresa := nOpt
EndIf
RETURN

//------------------------------------//
STATIC PROCEDURE ListaPre( aLS,lEtq )
   LOCAL oRpt, nConta := 0, cPict := "999,999,999"
   LOCAL oG := { { "VITRINA","C", 3,0 },{ "CODIGO","C",12,0 },{ "VALOR","C",11,0 } }
If lEtq
   BorraFile( "CODIGOS",{"DBF","N0","PXX","IXX"} )
   dbCREATE( oApl:cRuta2+"CODIGOS",oG )
   If !AbreDbf( "Tem","CODIGOS",,,.f. )
      MsgInfo( "NO SE PUEDEN CREAR CODIGOS" ) ; RETURN
   EndIf
Else
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,{"PRECIOS DE PROMOCION",NtChr( aLS[8],"2"),;
             "C O D I G O- D E S C R I P C I O N---------- PRECI.COSTO "+;
             "PRECI.VENTA PRE.PUBLICO"} )
   oRpt:lPreview := MsgNoYes( "Vista Previa", ">>> Desea Ver <<<" )
EndIf
aLS[9]:Seek( { "fecha",aLS[8] },"optica, row_id" )
oG := aLS[9]:OPTICA
While !aLS[9]:EOF()
   If lEtq
      Tem->(dbAppend())
      Tem->CODIGO := aLS[9]:CODIGO
      Tem->VALOR  := TRANSFORM(aLS[9]:PPUBLI,"999,999,999")
   Else
      oApl:oInv:Seek( { "codigo",aLS[9]:CODIGO } )
      oRpt:Titulo( 80 )
      If oG  # aLS[9]:OPTICA
         oG := aLS[9]:OPTICA
         oRpt:Say( oRpt:nL,12,ArrayValor( oApl:aOptic,STR(oG,2) ) )
         oRpt:nL ++
      EndIf
      oRpt:Say( oRpt:nL,00,aLS[9]:CODIGO,,,1 )
      oRpt:Say( oRpt:nL,13,oApl:oInv:DESCRIP,30 )
      oRpt:Say( oRpt:nL,45,TRANSFORM( aLS[9]:PCOSTO,cPict ))
      oRpt:Say( oRpt:nL,57,TRANSFORM( aLS[9]:PVENTA,cPict ))
      oRpt:Say( oRpt:nL,69,TRANSFORM( aLS[9]:PPUBLI,cPict ))
      oRpt:nL ++
      nConta   ++
   EndIf
   aLS[9]:Skip(1):Read()
   aLS[9]:xLoad()
EndDo
If lEtq
   Tem->(dbCloseArea())
Else
   If nConta > 0
      oRpt:Say( oRpt:nL++,00,REPLICATE ("_",80) )
      oRpt:Say( oRpt:nL  ,10,"TOTAL ESTE LISTADO...." + STR( nConta,4 ) )
   EndIf
   oRpt:NewPage()
   oRpt:End()
EndIf
RETURN