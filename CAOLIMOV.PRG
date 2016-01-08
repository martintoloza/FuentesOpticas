// Programa.: CAOLIMOV.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Ventas Mensuales
#include "FiveWin.ch"

MEMVAR oApl

PROCEDURE CaoLiMov()
   LOCAL oDlg, oGet := ARRAY(9), aVta := { DATE(), DATE(), .f., "N",1,999,SPACE(10) }
DEFINE DIALOG oDlg TITLE "Listo Ventas Detalladas" FROM 0, 0 TO 12,46
   @ 02, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02, 92 GET oGet[1] VAR aVta[1] OF oDlg  SIZE 40,12 PIXEL
   @ 16, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 16, 92 GET oGet[2] VAR aVta[2] OF oDlg ;
      VALID aVta[2] >= aVta[1] SIZE 40,12 PIXEL
   @ 30, 00 SAY "DESEA RESUMEN [S/N]"      OF oDlg RIGHT PIXEL SIZE 90,10
   @ 30, 92 GET oGet[3] VAR aVta[4] OF oDlg PICTURE "!";
      VALID aVta[4] $ "NS"     SIZE 08,12 PIXEL
   @ 44, 00 SAY "PAGINA INICIAL"           OF oDlg RIGHT PIXEL SIZE 90,10
   @ 44, 92 GET oGet[4] VAR aVta[5] OF oDlg PICTURE "999";
      VALID Rango( aVta[5],1,999 )       SIZE 24,12 PIXEL
   @ 58, 00 SAY "PAGINA   FINAL"           OF oDlg RIGHT PIXEL SIZE 90,10
   @ 58, 92 GET oGet[5] VAR aVta[6] OF oDlg PICTURE "999";
      VALID Rango( aVta[6],aVta[5],999 ) SIZE 24,12 PIXEL
   @ 44,120 GET oGet[6] VAR aVta[7] OF oDlg PICTURE "@!" PIXEL SIZE 40,10
   @ 58,120 CHECKBOX oGet[7] VAR aVta[3] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 74, 50 BUTTON oGet[8] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[8]:Disable(), ListaMov( aVta ), oDlg:End() ) PIXEL
   @ 74,100 BUTTON oGet[9] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 80, 02 SAY "[CAOLIMOV]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED;
   ON INIT (Empresa() )
RETURN

//------------------------------------//
PROCEDURE ListaMov( aLS )
   LOCAL oRpt, aLC := ARRAY(2,7), aVT := ARRAY(2,12), aGT := ARRAY(2,15)
   LOCAL aRA, aRS, nC, nL, nK := 0, hRes, cPict := "99,999,999,999"
If aLS[4] == "N" .AND. aLS[6] # 888
   aRA := "EN " + NtChr( aLS[1],"6" )
Else
   aRA := "DESDE "+ NtChr( aLS[1],"2" )+ " HASTA "+ NtChr( aLS[2],"2" )
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"MOVIMIENTO  DE  VENTAS",aRA,;
          " C L I E N T E                    FECHA      FACTURA   LEN.OFTALMICO  " +;
          " M O N T U R A   LENT.CONTACTO   ----CONSULTAS   -----LIQUIDOS   ------"+;
          "VARIOS  Venta Bruta  -DESCUENTO  Venta Grava       I.V.A.   Valor Total"},;
          aLS[3],aLS[5],2 )
AEVAL( aLC, { |x| AFILL( x,0 ) } )
AEVAL( aGT, { |x| AFILL( x,0 ) } )
AEVAL( aVT, { |x| AFILL( x,0 ) } )
If aLS[6] == 888
   ListaTOP( aLS,oRpt,aGT,aVT )
   RETURN
EndIf
aRS := "SELECT c.codigo_nit, c.cliente, c.fechoy, c.numfac, c.indicador, "+;
              "c.totalfac, d.indicador, d.fecdev, d.codart, d.cantidad, " +;
              "d.precioven, d.desmon, d.montoiva "     +;
       "FROM cadfactu c LEFT JOIN cadventa d"          +;
       " USING(optica, numfac, tipo) "                 +;
       "WHERE c.optica  = " + LTRIM(STR(oApl:nEmpresa))+;
        " AND c.fechoy >= " + xValToChar( aLS[1])      +;
        " AND c.fechoy <= " + xValToChar( aLS[2])      +;
        " AND c.tipo    = " + xValToChar(oApl:Tipo)
If oApl:nEmpresa == 18 .AND. !EMPTY( aLS[7] )
   aRS += " AND c.autoriza = " + xValToChar(aLS[7])
   oRpt:aEnc[1] += " - FOCA"
EndIf
   aRS += " ORDER BY c.numfac"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRS )  ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) > 0
   aRS := MyReadRow( hRes )
   AEVAL( aRS, { | xV,nP | aRS[nP] := MyClReadCol( hRes,nP ) } )
   aRA := { aRS[1],aRS[2],aRS[3],aRS[4],aRS[5],aRS[6],0,0 }
EndIf
aLS[5] := nL
While nL > 0
   If aRS[5] # "A"
      aRA[07] := aRS[11] + aRS[12]   //d.precioven + d.desmon
      aRA[08] := If( LEFT(DTOS(aRS[3]),6) <= LEFT(DTOS(aRS[8]),6) .AND.;
                               aRS[7] == "D", 0, aRS[10] )
      aRS[09] := TRIM( aRS[9] )
      do Case
      Case aRS[09] == "0599000002" .OR. LEFT(aRS[09],2) = "02" // Oftalmicos
         aVT[1,01] += If( SUBSTR(aRS[09],4,1) $ "12", aRA[8], 0 )
         aVT[2,01] += aRA[07]
      Case aRS[09] == "0599000001" .OR. LEFT(aRS[09],2) = "01" // Montura
         aVT[1,02] += If( aRS[09] = "0599000001", 0, aRA[8] )
         aVT[2,02] += aRA[07]
      Case LEFT(aRS[09],4) = "0501"                // Consultas
         aVT[1,04] += aRS[10]
         aVT[2,04] += aRA[07]
      Case LEFT(aRS[09],2) = "03"                  // Liquidos
         aVT[1,05] += aRS[10]
         aVT[2,05] += aRA[07]
      Case LEFT(aRS[09],2) = "04"                  // Accesorios
         aVT[1,06] += aRS[10]
         aVT[2,06] += aRA[07]
      Case LEFT(aRS[09],2) >= "60" .OR. ;
          aRS[09] = "0599000003"   .OR. ;
          aRS[09] = "0504"
         If LEFT(aRS[09],3) = "601"
            nK := 1                               // B. Diarios
         ElseIf LEFT(aRS[09],3) = "607"
            nK := 3                               // B. Cosmeticos
         ElseIf LEFT(aRS[09],3) = "701"
            nK := 4                               // P. Diarios
         ElseIf LEFT(aRS[09],3) = "702" .OR. aRS[09] = "0504"
            nK := 5                               // P. Permanentes
         ElseIf LEFT(aRS[09],2) = "80"
            nK := 6                               // Semiduros
         ElseIf LEFT(aRS[09],2) = "90"
            nK := 7                               // Toricos
         Else
            nK := 2                               // B. Permanentes
         EndIf
         If aRS[09] # "0599000003"
            aLC[1,nK] += aRS[10]
            aVT[1,03] += aRS[10]
         EndIf
         aLC[2,nK] += aRA[07]
         aVT[2,03] += aRA[07]
      OtherWise                                   // Varios
         aVT[2,07] += aRA[07]
      EndCase
         nK := If( aRS[13] == 0, 2, 1 )
         aVT[02,09] += aRS[12]
         aVT[nK,10] += aRS[11]
         aVT[02,11] += aRS[13]
   EndIf
   If (nL --) > 1
      aRS := MyReadRow( hRes )
      AEVAL( aRS, {| xV,nP | aRS[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aRA[4] # aRS[4]
      aVT[2,08] := aVT[2,1]+ aVT[2,2]+ aVT[2,3]+ aVT[2,4]+ aVT[2,5]+ aVT[2,6]+ aVT[2,7]
      aVT[2,12] := aVT[2,08] + aVT[2,11] - aVT[2,09]
         nK := 13
      If aRA[5] # "A"
         If aRA[1] # 123
            oApl:oNit:Seek( {"codigo_nit",aRA[1]} )
            aRA[2] := oApl:oNit:NOMBRE
            nK := If( oApl:oNit:GRUPO, 14, 15 )
         EndIf
         aGT[1,nK] += aRA[6]
      EndIf
      If aLS[4] == "N"
         oRpt:Titulo( 212 )
         If oRpt:nPage > aLS[6]
            nK := 27
            EXIT
         EndIf
         If oRpt:nPage >= oRpt:nPagI
            If aRA[5] == "A"
               oRpt:Say( oRpt:nL, 00,"A N U L A D A" )
               oRpt:Say( oRpt:nL, 32,NtChr( aRA[3],"2" ))
               oRpt:Say( oRpt:nL, 43,   STR(aRA[4]) )
            Else
               aVT[2,07] += aVT[2,06]
               oRpt:Say( oRpt:nL, 00,aRA[2] )
               oRpt:Say( oRpt:nL, 32,NtChr( aRA[3],"2" ))
               oRpt:Say( oRpt:nL, 44,If( aRA[6] # aVT[2,12], "*", " " ) +;
                         STR(aRA[4],8) )
               oRpt:Say( oRpt:nL, 55,STR(aVT[1,01],2) )
               oRpt:Say( oRpt:nL, 59,TRANSFORM(aVT[2,01], "9,999,999" ))
               oRpt:Say( oRpt:nL, 71,STR(aVT[1,02],2) )
               oRpt:Say( oRpt:nL, 75,TRANSFORM(aVT[2,02], "9,999,999" ))
               oRpt:Say( oRpt:nL, 87,STR(aVT[1,03],3) )
               oRpt:Say( oRpt:nL, 91,TRANSFORM(aVT[2,03], "9,999,999" ))
               oRpt:Say( oRpt:nL,103,STR(aVT[1,04],2) )
               oRpt:Say( oRpt:nL,107,TRANSFORM(aVT[2,04], "9,999,999" ))
               oRpt:Say( oRpt:nL,119,STR(aVT[1,05],2) )
               oRpt:Say( oRpt:nL,123,TRANSFORM(aVT[2,05],  "9,999,999" ))
               oRpt:Say( oRpt:nL,136,TRANSFORM(aVT[2,07],"999,999,999" ))
               oRpt:Say( oRpt:nL,149,TRANSFORM(aVT[2,08],"999,999,999" ))
               oRpt:Say( oRpt:nL,162,TRANSFORM(aVT[2,09], "99,999,999" ))
               oRpt:Say( oRpt:nL,175,TRANSFORM(aVT[1,10], "99,999,999" ))
               oRpt:Say( oRpt:nL,188,TRANSFORM(aVT[2,11], "99,999,999" ))
               oRpt:Say( oRpt:nL,201,TRANSFORM(aVT[2,12],"999,999,999" ))
            EndIf
         EndIf
         oRpt:nL ++
      EndIf
      FOR nC := 1 TO 12
         aGT[1,nC] += aVT[1,nC]
         aGT[2,nC] += aVT[2,nC]
         aVT[1,nC] := aVT[2,nC] := 0
      NEXT nC
         aRA := { aRS[1],aRS[2],aRS[3],aRS[4],aRS[5],aRS[6],0,0 }
   EndIf
EndDo
   MSFreeResult( hRes )
/* Aqui 2
aRA := { "optica",oApl:nEmpresa,"fechoy >= ",aLS[1],"fechoy <= ",aLS[2],;
         "tipo",oApl:Tipo}
If oApl:nEmpresa == 18 .AND. !EMPTY( aLS[7] )
   AADD( aRA,"autoriza" )
   AADD( aRA,aLS[7] )
   oRpt:aEnc[1] += " - FOCA"
EndIf
oApl:oFac:Seek( aRA )
aLS[5] := oApl:oFac:nRowCount
While !oApl:oFac:Eof()
   If aLS[4] == "N"
      oRpt:Titulo( 211 )
      If oRpt:nPage > aLS[6]
         nK := 27
         Exit
      EndIf
   EndIf
   If oApl:oFac:INDICADOR # "A"
      AEVAL( aVT, { |x| AFILL( x,0 ) } )
      oApl:oVen:Seek( {"optica",oApl:nEmpresa,"numfac",oApl:oFac:NUMFAC,;
                       "tipo",oApl:Tipo,"indicador <> ","A"} )
      While !oApl:oVen:Eof()
         aRA := TRIM( oApl:oVen:CODART )
         nC := If( LEFT(DTOS(oApl:oVen:FECFAC),6) <= LEFT(DTOS(oApl:oVen:FECDEV),6) .AND.;
                   oApl:oVen:INDICADOR == "D", 0, oApl:oVen:CANTIDAD )
         nL := oApl:oVen:PRECIOVEN + oApl:oVen:DESMON
         do Case
         Case aRA == "0599000002" .OR. LEFT(aRA,2) = "02" // Oftalmicos
            aVT[1,01] += If( SUBSTR(aRA,4,1) $ "12", nC, 0 )
            aVT[2,01] += nL
         Case aRA == "0599000001" .OR. LEFT(aRA,2) = "01" // Montura
            aVT[1,02] += If( aRA = "0599000001", 0, nC )
            aVT[2,02] += nL
         Case LEFT(aRA,4) = "0501"                // Consultas
            aVT[1,04] += oApl:oVen:CANTIDAD
            aVT[2,04] += nL
         Case LEFT(aRA,2) = "03"                  // Liquidos
            aVT[1,05] += oApl:oVen:CANTIDAD
            aVT[2,05] += nL
         Case LEFT(aRA,2) = "04"                  // Accesorios
            aVT[1,06] += oApl:oVen:CANTIDAD
            aVT[2,06] += nL
         Case LEFT(aRA,2) >= "60" .OR. ;
             aRA = "0599000003"   .OR. ;
             aRA = "0504"
            If LEFT(aRA,3) = "601"
               nK := 1                               // B. Diarios
            ElseIf LEFT(aRA,3) = "607"
               nK := 3                               // B. Cosmeticos
            ElseIf LEFT(aRA,3) = "701"
               nK := 4                               // P. Diarios
            ElseIf LEFT(aRA,3) = "702" .OR. aRA = "0504"
               nK := 5                               // P. Permanentes
            ElseIf LEFT(aRA,2) = "80"
               nK := 6                               // Semiduros
            ElseIf LEFT(aRA,2) = "90"
               nK := 7                               // Toricos
            Else
               nK := 2                               // B. Permanentes
            EndIf
            If aRA # "0599000003"
               aLC[1,nK] += oApl:oVen:CANTIDAD
               aVT[1,03] += oApl:oVen:CANTIDAD
            EndIf
            aLC[2,nK] += nL
            aVT[2,03] += nL
         OtherWise                                   // Varios
            aVT[2,07] += nL
         EndCase
         nK := If( oApl:oVen:MONTOIVA == 0, 2, 1 )
         aVT[nK,10] += oApl:oVen:PRECIOVEN
         oApl:oVen:Skip(1):Read()
         oApl:oVen:xLoad()
      EndDo
      aVT[2,08] := aVT[2,1]+ aVT[2,2]+ aVT[2,3]+ aVT[2,4]+ aVT[2,5]+ aVT[2,6]+ aVT[2,7]
      aVT[2,09] := oApl:oFac:TOTALDES
      aVT[2,11] := oApl:oFac:TOTALIVA
      aVT[2,12] := aVT[2,08] + aVT[2,11] - aVT[2,09]
      FOR nK := 1 TO 2
         FOR nC := 1 TO 12
            aGT[nK][nC] += aVT[nK][nC]
         NEXT
      NEXT
      oApl:oNit:Seek( {"codigo_nit",oApl:oFac:CODIGO_NIT} )
      nK := If( oApl:oNit:GRUPO, 14, If( oApl:oNit:CODIGO > 0, 15, 13 ) )
      aGT[1][nK] += oApl:oFac:TOTALFAC
   EndIf
   If aLS[4] == "N"
      If oRpt:nPage >= oRpt:nPagI
         If oApl:oFac:INDICADOR == "A"        // .AND. Fac->FECHAENT <= aLS[2]
            oRpt:Say( oRpt:nL, 00,"A N U L A D A" )
            oRpt:Say( oRpt:nL, 32,NtChr( oApl:oFac:FECHOY,"2" ))
            oRpt:Say( oRpt:nL, 43,STR(oApl:oFac:NUMFAC) )
         Else
            aVT[2,07] += aVT[2,06]
            oRpt:Say( oRpt:nL, 00,If( oApl:oNit:CODIGO > 0, oApl:oNit:NOMBRE,;
                      oApl:oFac:CLIENTE ))
            oRpt:Say( oRpt:nL, 32,NtChr( oApl:oFac:FECHOY,"2" ))
            oRpt:Say( oRpt:nL, 44,If( oApl:oFac:TOTALFAC # aVT[2,12], "*",;
                       " " ) + STR(oApl:oFac:NUMFAC,8) )
            oRpt:Say( oRpt:nL, 55,STR(aVT[1,01],2) )
            oRpt:Say( oRpt:nL, 59,TRANSFORM(aVT[2,01], "9,999,999" ))
            oRpt:Say( oRpt:nL, 71,STR(aVT[1,02],2) )
            oRpt:Say( oRpt:nL, 75,TRANSFORM(aVT[2,02], "9,999,999" ))
            oRpt:Say( oRpt:nL, 87,STR(aVT[1,03],3) )
            oRpt:Say( oRpt:nL, 91,TRANSFORM(aVT[2,03], "9,999,999" ))
            oRpt:Say( oRpt:nL,103,STR(aVT[1,04],2) )
            oRpt:Say( oRpt:nL,107,TRANSFORM(aVT[2,04], "9,999,999" ))
            oRpt:Say( oRpt:nL,119,STR(aVT[1,05],2) )
            oRpt:Say( oRpt:nL,123,TRANSFORM(aVT[2,05], "9,999,999" ))
            oRpt:Say( oRpt:nL,136,TRANSFORM(aVT[2,07],"99,999,999" ))
            oRpt:Say( oRpt:nL,149,TRANSFORM(aVT[2,08],"99,999,999" ))
            oRpt:Say( oRpt:nL,162,TRANSFORM(aVT[2,09],"99,999,999" ))
            oRpt:Say( oRpt:nL,175,TRANSFORM(aVT[1,10],"99,999,999" ))
            oRpt:Say( oRpt:nL,188,TRANSFORM(aVT[2,11],"99,999,999" ))
            oRpt:Say( oRpt:nL,201,TRANSFORM(aVT[2,12],"99,999,999" ))
         EndIf
      EndIf
      oRpt:nL ++
   EndIf
   oApl:oFac:Skip(1):Read()
   oApl:oFac:xLoad()
EndDo
*/
If aLS[5] > 0 .AND. nK # 27
   If aLS[4] == "N"
      oRpt:Say( oRpt:nL,0,REPLICATE("_",212) )
      oRpt:NewPage()
      oRpt:nL := 67
   EndIf
   ASIZE( oRpt:aEnc,2 )
   oRpt:cFontI := oRpt:CPINormal
   oRpt:Titulo( 80 )
   oRpt:Say( 07,10,STR(oApl:oFac:nRowCount,4) + "  FACTURAS            CANTIDAD     V A L O R" )
   oRpt:Say( 08,10,REPLICATE("_",50) )
   oRpt:Say( 09,10,"LENTES OFTALMICOS......... " + NtChr( aGT[1,01],"999,999" ))
   oRpt:Say( 09,46,NtChr( aGT[2,01],cPict ))
   oRpt:Say( 10,10,"MONTURAS.................. " + NtChr( aGT[1,02],"999,999" ))
   oRpt:Say( 10,46,NtChr( aGT[2,02],cPict ))
   oRpt:Say( 11,10,"L.C. Blandos Diarios...... " + NtChr( aLC[1,01],"999,999" ))
   oRpt:Say( 11,46,NtChr( aLC[2,01],cPict ))
   oRpt:Say( 12,10,"L.C. Blandos Permanentes.. " + NtChr( aLC[1,02],"999,999" ))
   oRpt:Say( 12,46,NtChr( aLC[2,02],cPict ))
   oRpt:Say( 13,10,"L.C. Cosmeticos........... " + NtChr( aLC[1,03],"999,999" ))
   oRpt:Say( 13,46,NtChr( aLC[2,03],cPict ))
   oRpt:Say( 14,10,"L.C. Permeables Diarios... " + NtChr( aLC[1,04],"999,999" ))
   oRpt:Say( 14,46,NtChr( aLC[2,04],cPict ))
   oRpt:Say( 15,10,"L.C. Permeables Permanetes " + NtChr( aLC[1,05],"999,999" ))
   oRpt:Say( 15,46,NtChr( aLC[2,05],cPict ))
   oRpt:Say( 16,10,"L.C. Semiduros............ " + NtChr( aLC[1,06],"999,999" ))
   oRpt:Say( 16,46,NtChr( aLC[2,06],cPict ))
   oRpt:Say( 17,10,"L.C. Toricos.............. " + NtChr( aLC[1,07],"999,999" ))
   oRpt:Say( 17,46,NtChr( aLC[2,07],cPict ))
   oRpt:Say( 18,10,"CONSULTAS................. " + NtChr( aGT[1,04],"999,999" ))
   oRpt:Say( 18,46,NtChr( aGT[2,04],cPict ))
   oRpt:Say( 19,10,"LIQUIDOS.................. " + NtChr( aGT[1,05],"999,999" ))
   oRpt:Say( 19,46,NtChr( aGT[2,05],cPict ))
   oRpt:Say( 20,10,"ACCESORIOS................ " + NtChr( aGT[1,06],"999,999" ))
   oRpt:Say( 20,46,NtChr( aGT[2,06],cPict ))
   oRpt:Say( 21,10,"VARIOS...................." )
   oRpt:Say( 21,46,NtChr( aGT[2,07],cPict ))
   oRpt:Say( 22,10,REPLICATE("_",50) )
   oRpt:Say( 23,10,"VALOR    VENTA............" )
   oRpt:Say( 23,46,NtChr( aGT[2,08],cPict ))

   oRpt:Say( 26,16,"TOTAL CLIENTES PARTICULARES  $" + NtChr( aGT[1,13],cPict ))
   oRpt:Say( 27,16,"TOTAL OPTICAS DEL GRUPO ---> $" + NtChr( aGT[1,14],cPict ))
   oRpt:Say( 28,16,"TOTAL EMPRESAS ------------> $" + NtChr( aGT[1,15],cPict ))
   oRpt:Say( 31,16,"Cuentas por Cobrar            " + NtChr( aGT[2,12],cPict ))
   oRpt:Say( 32,16,"Descuento                     " + NtChr( aGT[2,09],cPict ))
   oRpt:Say( 33,16,"Ventas    Gravadas" + SPACE(23) + NtChr( aGT[1,10],cPict ))
   oRpt:Say( 34,16,"Ventas no Gravadas" + SPACE(23) + NtChr( aGT[2,10],cPict ))
   oRpt:Say( 35,16,"I.V.A.            " + SPACE(23) + NtChr( aGT[2,11],cPict ))
EndIf
oRpt:NewPage()
oRpt:End()
RETURN

//------------------------------------//
STATIC PROCEDURE ListaTOP( aLS,oRpt,aGT,aVT )
   LOCAL aRA, aRS, aOpt, cQry, hRes, nC, nL
aOpt := { oApl:oEmp:RESHABIT }
If EMPTY(aLS[7])
   aRS  := "IN("
   cQry := If( oApl:oEmp:PRINCIPAL == 4, "IN(0, 4)", "= " + LTRIM(STR(oApl:oEmp:PRINCIPAL)) )
   oApl:oEmp:dbEval( {|o| aRS += LTRIM(STR(o:OPTICA)) + ", ",;
                          If( aOpt[1] # o:RESHABIT, AADD( aOpt,o:OPTICA ), ) },;
                          "principal " + cQry + " AND optica <> 1 ORDER BY reshabit" )
   aRS := LEFT( aRS,LEN(aRS)-2 ) + ")"
Else
   aRS := "= " + LTRIM(STR(oApl:oEmp:OPTICA))
EndIf
oRpt:aEnc[1] := "LIBRO AUXILIAR POR TERCEROS"
cQry := "SELECT n.nombre, c.cliente, c.fechoy, c.optica, c.codigo_nit, "   +;
               "c.totalfac, d.indicador, d.fecdev, d.codart, d.cantidad, " +;
               "d.precioven, d.desmon, d.montoiva "                        +;
        "FROM cadfactu c LEFT JOIN cadclien n USING(codigo_nit) "          +;
                        "LEFT JOIN cadventa d USING(optica, numfac, tipo) "+;
        "WHERE c.optica "    + aRS                  +;
         " AND c.fechoy >= " + xValToChar( aLS[1])  +;
         " AND c.fechoy <= " + xValToChar( aLS[2])  +;
         " AND c.tipo    = " + xValToChar(oApl:Tipo)+;
         " AND c.indicador <> 'A'"                  +;
         " ORDER BY n.nombre, c.cliente"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) > 0
   aRS := MyReadRow( hRes )
   AEVAL( aRS, { | xV,nP | aRS[nP] := MyClReadCol( hRes,nP ) } )
   aRA := { aRS[1],aRS[2],aRS[5],0,0 }
EndIf
If aLS[4] == "N"
   aLS[3] := .f.
   aLS[4] := { || (aRA[3] == 123 .AND. aRA[2] # aRS[2]) .OR.;
                  (aRA[3]  # 123 .AND. aRA[1] # aRS[1]) }
Else
   aLS[3] := .t.
   aLS[4] := { || aRA[1] # aRS[1] }
EndIf
While nL > 0
   aRA[4] := aRS[11] + aRS[12]   //d.precioven + d.desmon
   aRA[5] := If( LEFT(DTOS(aRS[3]),6) <= LEFT(DTOS(aRS[8]),6) .AND.;
                           aRS[7] == "D", 0, aRS[10] )
   aRS[9] := TRIM( aRS[9] )
   do Case
   Case aRS[9] == "0599000002" .OR. LEFT(aRS[9],2) = "02" // Oftalmicos
      nC := 1
      aVT[1,01] += If( SUBSTR(aRS[9],4,1) $ "12", aRA[5], 0 )
      aVT[2,01] += aRA[4]
   Case aRS[9] == "0599000001" .OR. LEFT(aRS[9],2) = "01" // Montura
      nC := 2
      aVT[1,02] += If( aRS[9] = "0599000001", 0, aRA[5] )
      aVT[2,02] += aRA[4]
   Case LEFT(aRS[9],2) >= "60" .OR. ;
       aRS[9] = "0599000003"   .OR. ;
       aRS[9] = "0504"
      nC := 3
      If aRS[9] # "0599000003"
         aVT[1,03] += aRS[10]
      EndIf
      aVT[2,03] += aRA[4]
   Case LEFT(aRS[9],4) = "0501"                // Consultas
      nC := 4
      aVT[1,04] += aRS[10]
      aVT[2,04] += aRA[4]
   Case LEFT(aRS[9],2) = "03"                  // Liquidos
      nC := 5
      aVT[1,05] += aRS[10]
      aVT[2,05] += aRA[4]
   OtherWise                                   // Varios
      nC := 7
      aVT[2,07] += aRA[4]
   EndCase
      aVT[2,09] += aRS[12]
      aVT[2,10] += If( aRS[13] == 0, 0, aRS[11] )
      aVT[2,11] += aRS[13]
   If ASCAN( aOpt, aRS[4] ) > 0
      aGT[2,nC] += aRA[4]
      aGT[2,09] += aRS[12]
      aGT[2,10] += If( aRS[13] == 0, 0, aRS[11] )
      aGT[2,11] += aRS[13]
   EndIf
   If (nL --) > 1
      aRS := MyReadRow( hRes )
      AEVAL( aRS, {| xV,nP | aRS[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. EVAL( aLS[4] )
      aVT[2,08] := aVT[2,1]+ aVT[2,2]+ aVT[2,3]+ aVT[2,4]+ aVT[2,5]+ aVT[2,7]
      aVT[2,12] := aVT[2,08] + aVT[2,11] - aVT[2,09]
         oRpt:Titulo( 211 )
      If oRpt:nPage >= oRpt:nPagI
         If aLS[3] .OR. aRA[3]  # 123
            aRA[2] := aRA[1]
         EndIf
         oRpt:Say( oRpt:nL, 00,aRA[2] )
       //oRpt:Say( oRpt:nL, 55,STR(aVT[1,01],2) )
         oRpt:Say( oRpt:nL, 56,TRANSFORM(aVT[2,01],"9999,999,999" ))
       //oRpt:Say( oRpt:nL, 71,STR(aVT[1,02],2) )
         oRpt:Say( oRpt:nL, 73,TRANSFORM(aVT[2,02],"999,999,999" ))
       //oRpt:Say( oRpt:nL, 87,STR(aVT[1,03],3) )
         oRpt:Say( oRpt:nL, 89,TRANSFORM(aVT[2,03],"999,999,999" ))
       //oRpt:Say( oRpt:nL,103,STR(aVT[1,04],2) )
         oRpt:Say( oRpt:nL,105,TRANSFORM(aVT[2,04],"999,999,999" ))
       //oRpt:Say( oRpt:nL,119,STR(aVT[1,05],2) )
         oRpt:Say( oRpt:nL,121,TRANSFORM(aVT[2,05],"999,999,999" ))
         oRpt:Say( oRpt:nL,135,TRANSFORM(aVT[2,07],"999,999,999" ))
         oRpt:Say( oRpt:nL,147,TRANSFORM(aVT[2,08],"9999,999,999" ))
         oRpt:Say( oRpt:nL,161,TRANSFORM(aVT[2,09],"999,999,999" ))
         oRpt:Say( oRpt:nL,174,TRANSFORM(aVT[2,10],"999,999,999" ))
         oRpt:Say( oRpt:nL,187,TRANSFORM(aVT[2,11],"999,999,999" ))
         oRpt:Say( oRpt:nL,199,TRANSFORM(aVT[2,12],"9999,999,999" ))
      EndIf
      oRpt:nL ++
      FOR nC := 1 TO 12
         aGT[1,nC] += aVT[2,nC]
         aVT[1,nC] := aVT[2,nC] := 0
      NEXT nC
      aRA := { aRS[1],aRS[2],aRS[5],0,0 }
   EndIf
EndDo
   MSFreeResult( hRes )
   If aGT[1,12] > 0 .AND. oRpt:nPage >= oRpt:nPagI
      oRpt:Separator( 0,3 )
      oRpt:Say( oRpt:nL,0,REPLICATE("_",211) )
      oRpt:nL ++
      oRpt:Say( oRpt:nL, 32,"GRAN TOTAL ==>" )
      oRpt:Say( oRpt:nL, 56,TRANSFORM(aGT[1,01],"9999,999,999" ))
      oRpt:Say( oRpt:nL, 72,TRANSFORM(aGT[1,02],"9999,999,999" ))
      oRpt:Say( oRpt:nL, 88,TRANSFORM(aGT[1,03],"9999,999,999" ))
      oRpt:Say( oRpt:nL,104,TRANSFORM(aGT[1,04],"9999,999,999" ))
      oRpt:Say( oRpt:nL,120,TRANSFORM(aGT[1,05],"9999,999,999" ))
      oRpt:Say( oRpt:nL,134,TRANSFORM(aGT[1,07],"9999,999,999" ))
      oRpt:Say( oRpt:nL,147,TRANSFORM(aGT[1,08],"9999,999,999" ))
      oRpt:Say( oRpt:nL,160,TRANSFORM(aGT[1,09],"9999,999,999" ))
      oRpt:Say( oRpt:nL,173,TRANSFORM(aGT[1,10],"9999,999,999" ))
      oRpt:Say( oRpt:nL,186,TRANSFORM(aGT[1,11],"9999,999,999" ))
      oRpt:Say( oRpt:nL,199,TRANSFORM(aGT[1,12],"9999,999,999" ))
      oRpt:nL += 2
   EndIf
      aGT[2,08] := aGT[2,1]+ aGT[2,2]+ aGT[2,3]+ aGT[2,4]+ aGT[2,5]+ aGT[2,7]
      aGT[2,12] := aGT[2,08] + aGT[2,11] - aGT[2,09]
   If aGT[2,12] > 0
      oRpt:Separator( 0,3 )
      oRpt:Say( oRpt:nL, 32,"TOTAL OTRAS CIUDADES" )
      oRpt:Say( oRpt:nL, 56,TRANSFORM(aGT[2,01],"9999,999,999" ))
      oRpt:Say( oRpt:nL, 72,TRANSFORM(aGT[2,02],"9999,999,999" ))
      oRpt:Say( oRpt:nL, 88,TRANSFORM(aGT[2,03],"9999,999,999" ))
      oRpt:Say( oRpt:nL,104,TRANSFORM(aGT[2,04],"9999,999,999" ))
      oRpt:Say( oRpt:nL,120,TRANSFORM(aGT[2,05],"9999,999,999" ))
      oRpt:Say( oRpt:nL,134,TRANSFORM(aGT[2,07],"9999,999,999" ))
      oRpt:Say( oRpt:nL,147,TRANSFORM(aGT[2,08],"9999,999,999" ))
      oRpt:Say( oRpt:nL,160,TRANSFORM(aGT[2,09],"9999,999,999" ))
      oRpt:Say( oRpt:nL,173,TRANSFORM(aGT[2,10],"9999,999,999" ))
      oRpt:Say( oRpt:nL,186,TRANSFORM(aGT[2,11],"9999,999,999" ))
      oRpt:Say( oRpt:nL,199,TRANSFORM(aGT[2,12],"9999,999,999" ))
   EndIf
oRpt:NewPage()
oRpt:End()
RETURN