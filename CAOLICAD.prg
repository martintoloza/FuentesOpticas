// Programa.: CAOLICAD.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Cartera diaria de las Opticas
#include "FiveWin.ch"
#include "UtilPrn.ch"

MEMVAR oApl

PROCEDURE CaoLiCad( nOpc )
   LOCAL aOpc, oA, oDlg, oGet := ARRAY(9)
   DEFAULT nOpc := 1
 oA := CDiarias()
aOpc:= { { {|| oA:NEW() }     ,"Listo Cartera Diaria" },;
         { {|| oA:TirizDOS() },"Reporte Ventas TIRILLA Z" } }
DEFINE DIALOG oDlg TITLE aOpc[nOpc,2] FROM 0, 0 TO 11,44
   @ 02, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 75,10
   @ 02, 78 GET oGet[1] VAR oA:aLS[1] OF oDlg  SIZE 40,10 PIXEL
   @ 14, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 75,10
   @ 14, 78 GET oGet[2] VAR oA:aLS[2] OF oDlg      ;
      VALID oA:aLS[2] >= oA:aLS[1] SIZE 40,10 PIXEL;
      WHEN nOpc == 1
   @ 26, 00 SAY "DESEA RESUMEN [S/N]" OF oDlg RIGHT PIXEL SIZE 75,10
   @ 26, 78 GET oGet[3] VAR oA:aLS[3] OF oDlg PICTURE "!";
      VALID oA:aLS[3] $ "NS"     SIZE 08,10 PIXEL;
      WHEN nOpc == 1
   @ 38, 00 SAY "TIPO DE IMPRESORA" OF oDlg RIGHT PIXEL SIZE 75,10
   @ 38, 78 COMBOBOX oGet[4] VAR oA:aLS[4] ITEMS { "Matriz","Laser" };
      SIZE 40,90 OF oDlg PIXEL
   @ 38,122 CHECKBOX oGet[9] VAR oA:aLS[8] PROMPT "Resumen" OF oDlg;
      SIZE 60,12 PIXEL ;
      WHEN oApl:cLocal == "LOC"
   @ 50, 00 SAY "Número de Copias"  OF oDlg RIGHT PIXEL SIZE 75,10
   @ 50, 78 GET oGet[5] VAR oA:aLS[5] OF oDlg PICTURE "99" SIZE 12,10 PIXEL;
      VALID Rango( oA:aLS[4],1,10 ) ;
      WHEN oA:aLS[4] == 2
   @ 50,122 CHECKBOX oGet[6] VAR oA:aLS[6] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,10 PIXEL
   @ 64, 50 BUTTON oGet[7] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[7]:Disable(), EVAL( aOpc[nOpc,1] ), oDlg:End() ) PIXEL
//      ( oGet[7]:Disable(), oA:NEW(), oDlg:End() ) PIXEL
   @ 64,100 BUTTON oGet[8] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 70, 02 SAY "[CAOLICAD]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
PROCEDURE ReciCaja( aLS )
   LOCAL oA, oDlg, oGet := ARRAY(7)
 oA := CDiarias()
If aLS # NIL
   oA:aLS := ACLONE( aLS )
   oA:ListoRec()
   RETURN
EndIf
oA:aLS := { DATE(), DATE(), 0, oApl:nTFor, .f. ,"", .t. }
DEFINE DIALOG oDlg TITLE "Listo Recibos de Caja" FROM 0, 0 TO 09,46
   @ 02, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02, 92 GET oGet[1] VAR oA:aLS[1] OF oDlg  SIZE 40,10 PIXEL
   @ 14, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 14, 92 GET oGet[2] VAR oA:aLS[2] OF oDlg ;
      VALID oA:aLS[2] >= oA:aLS[1] SIZE 40,10 PIXEL
   @ 26, 00 SAY  "DOCUMENTO Default Todos" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 26, 92 GET oGet[3] VAR oA:aLS[3] OF oDlg PICTURE "999999" SIZE 40,10 PIXEL
   @ 38, 00 SAY "TIPO DE IMPRESORA" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 38, 92 COMBOBOX oGet[4] VAR oA:aLS[4] ITEMS { "Matriz","Laser" };
      SIZE 48,90 OF oDlg PIXEL
   @ 38,140 CHECKBOX oGet[5] VAR oA:aLS[5] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 52, 50 BUTTON oGet[6] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[6]:Disable(), oA:ListoRec(), oDlg:End() ) PIXEL
   @ 52,100 BUTTON oGet[7] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 58, 02 SAY "[CAOLICAD]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
CLASS CDiarias FROM TIMPRIME

 DATA hRes, nL
 DATA aLS  INIT { DATE(),DATE(),"N",oApl:nTFor,1, .f.,0, (oApl:cLocal != "LOC") }
 DATA aCD  INIT { 0,0,0,0,0,0,0,0,0,"= 'P'", }
 DATA aTG  INIT { 0,0,0,0,0,0,0,0,0,0,0 }

 METHOD NEW() Constructor
 METHOD ArmarINF( aRes )
 METHOD ArmarPAG( aRes,nK )
 METHOD ListoWIN( aRes )
 METHOD TirizDOS()
 METHOD TirizWin( aRes )
 METHOD ListoRec()
 METHOD LaserRec( aCT,aLC,hRes,nL )
 METHOD Memo( nLin )
ENDCLASS

//------------------------------------//
METHOD NEW() CLASS CDiarias
   LOCAL aRes, cQry, oRpt
//If oApl:cLocal == "LOC"
If !::aLS[8]
   ::aCD[10] := "IN ('F', 'P')"
EndIf
 aRes   := ::ArmarINF( "Diaria" )
If ::nL > 0
   ::aCD[11] := aRes[2]
EndIf
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit                 ,;
             "LISTADO DE CARTERA DIARIA",NtChr( ::aCD[11],"3" ),;
             { .T., 1.9,"FACTURA" }  , { .F., 2.0,"NOMBRE DEL CLIENTE" },;
             { .T., 6.3,"P A G O" }  , { .T., 8.0,"EFECTIVO" }      ,;
             { .T., 9.7,"CHEQUES" }  , { .T.,11.8,"TARJETAS" }      ,;
             { .T.,13.6,"BONOS" }    , { .T.,15.7,"OTRO.PAGOS" }    ,;
             { .T.,17.5,"DEDUCCION" }, { .T.,19.2,"RETENCION" }     ,;
             { .T.,20.9,"S A L D O" } }
oApl:cPer := NtChr( ::aLS[2],"1" )
If ::aLS[4] == 2
   ::ListoWIN( aRes )
   RETURN NIL
EndIf
cQry := ""
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4],::aEnc[5],;
         "FACTURA NOMBRE CLIENTE   TOTAL PAGO    EFECTIVO     CHEQUES      T"+;
         "ARJETAS      BONOS OTRO.PAGOS     DEDUCCION  RETENCION   S A L D O" } ,;
         ::aLS[6],1,2 )
While ::nL > 0
   ::ArmarPAG( aRes,0 )
   oApl:nSaldo := If( aRes[9] == "T", 0, SaldoFac( aRes[1],1 ) )
   oRpt:Titulo( 132 )
   If ::aLS[3] == "N"
      oApl:oNit:Seek( {"codigo_nit",aRes[12]} )
      oRpt:Say( oRpt:nL, 00,STR(aRes[1],7) )
      oRpt:Say( oRpt:nL, 08,If( oApl:oNit:CODIGO > 0, oApl:oNit:NOMBRE,;
                                  aRes[11] ),15 )
      oRpt:Say( oRpt:nL, 24,TRANSFORM( ::aCD[7],   "999,999,999" ))
      oRpt:Say( oRpt:nL, 36,TRANSFORM( ::aCD[1],"@Z 999,999,999" ))
      oRpt:Say( oRpt:nL, 48,TRANSFORM( ::aCD[2],"@Z 999,999,999" ))
      oRpt:Say( oRpt:nL, 60,TRANSFORM( ::aCD[3],"@Z 99,999,999.99" ))
      oRpt:Say( oRpt:nL, 74,TRANSFORM( ::aCD[4],"@Z 999,999,999" ))
      oRpt:Say( oRpt:nL, 85,TRANSFORM( ::aCD[5],"@Z 99,999,999" ))
      oRpt:Say( oRpt:nL, 96,TRANSFORM( ::aCD[6],"@Z 99,999,999.99" ))
      oRpt:Say( oRpt:nL,110,TRANSFORM(aRes[6],"@Z 99,999,999" ))
      oRpt:Say( oRpt:nL,121,TRANSFORM(oApl:nSaldo,"999,999,999" ))
      oRpt:nL++
   EndIf
   AEVAL( ::aCD, {|nVal,nPos| ::aTG[nPos] += nVal },1,6 )
   ::aTG[7] += ::aCD[7] - If( aRes[9] == "-", aRes[5], 0 )
   ::aTG[8] += aRes[6]
   ::aTG[9] += oApl:nSaldo
   ::aCD[9] ++
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aCD[11] # aRes[2]
    //::aTG[07] -= (If( oApl:cLocal # "LOC", 0, ::aCD[8] ) + ::aTG[10])
      ::aTG[07] -= (If( ::aLS[8], 0, ::aCD[8] ) + ::aTG[10])
      If ::aLS[3] == "N"
         oRpt:Separator( 0,2,132 )
         oRpt:nL ++
      Else
         ::aTG[11] += ::aTG[07]
         cQry := STR( DAY(::aCD[11]),3)
      EndIf
      oRpt:Say( oRpt:nL, 01,STR( ::aCD[9],3 ) + "  PAGOS" + cQry )
      oRpt:Say( oRpt:nL, 24,TRANSFORM(::aTG[7],"999,999,999" ))
      oRpt:Say( oRpt:nL, 36,TRANSFORM(::aTG[1],"999,999,999" ))
      oRpt:Say( oRpt:nL, 48,TRANSFORM(::aTG[2],"999,999,999" ))
      oRpt:Say( oRpt:nL, 60,TRANSFORM(::aTG[3], "99,999,999.99" ))
      oRpt:Say( oRpt:nL, 74,TRANSFORM(::aTG[4],"999,999,999" ))
      oRpt:Say( oRpt:nL, 85,TRANSFORM(::aTG[5], "99,999,999" ))
      oRpt:Say( oRpt:nL, 96,TRANSFORM(::aTG[6], "99,999,999.99" ))
      oRpt:Say( oRpt:nL,110,TRANSFORM(::aTG[8], "99,999,999" ))
      oRpt:Say( oRpt:nL,121,TRANSFORM(::aTG[9],"999,999,999" ))
      If ::aLS[3] == "N"
         oRpt:Say(++oRpt:nL,84,TRANSFORM(::aTG[10],"(99,999,999)" ))
         If ::nL > 0
            oRpt:NewPage()
            oRpt:aEnc[2] := NtChr( aRes[2],"3" )
            oRpt:nL    := oRpt:nLength +1
            oRpt:nPage := 0
         EndIf
      Else
         oRpt:Say(++oRpt:nL,0,REPLICATE("_",132) )
         oRpt:nL ++
      EndIf
      AFILL( ::aTG,0,1,10 )
      ::aCD[08] := ::aCD[9] := 0
      ::aCD[11] := aRes[2]
   EndIf
EndDo
MSFreeResult( ::hRes )
   oRpt:Titulo( 132 )
If ::aTG[11] # 0
   oRpt:Say( oRpt:nL+1,20,TRANSFORM(::aTG[11],"9,999,999,999.99" ))
EndIf
   oRpt:NewPage()
   oRpt:aEnc[1] := "LISTADO DE ABONOS POR ANTICIPOS"
   oRpt:aEnc[2] := NtChr( ::aLS[1],"3" )
   oRpt:aEnc[3] := STRTRAN( oRpt:aEnc[3],"FACTURA","NUMERO " )

 aRes   := ::ArmarINF( "Antici" )
If ::nL  > 0
   oRpt:nL := oRpt:nLength + 1
   ::aCD[11] := aRes[2]
ElseIf ::aLS[8]
   oRpt:Titulo( 132 )
EndIf
AFILL( ::aCD,0,1,9 )
::aTG  := { 0,0,0,0,0,0,0,0,0,0,0 }
cQry := ""
While ::nL > 0
   ::ArmarPAG( aRes,1 )
   oRpt:Titulo( 132 )
   If ::aLS[3] == "N"
      oApl:oNit:Seek( {"codigo_nit",aRes[12]} )
      oRpt:Say( oRpt:nL, 00,STR(aRes[1],7) )
      oRpt:Say( oRpt:nL, 08,If( oApl:oNit:CODIGO > 0, oApl:oNit:NOMBRE,;
                                  aRes[11] ),15 )
      oRpt:Say( oRpt:nL, 24,TRANSFORM( ::aCD[7],   "999,999,999" ))
      oRpt:Say( oRpt:nL, 36,TRANSFORM( ::aCD[1],"@Z 999,999,999" ))
      oRpt:Say( oRpt:nL, 48,TRANSFORM( ::aCD[2],"@Z 999,999,999" ))
      oRpt:Say( oRpt:nL, 60,TRANSFORM( ::aCD[3],"@Z 99,999,999.99" ))
      oRpt:Say( oRpt:nL, 74,TRANSFORM( ::aCD[4],"@Z 999,999,999" ))
      oRpt:Say( oRpt:nL, 85,TRANSFORM( ::aCD[5],"@Z 99,999,999" ))
      oRpt:Say( oRpt:nL, 96,TRANSFORM( ::aCD[6],"@Z 99,999,999.99" ))
      oRpt:Say( oRpt:nL,110,TRANSFORM(aRes[6],"@Z 99,999,999" ))
      oRpt:Say( oRpt:nL,121,TRANSFORM(aRes[9],"999,999,999" ))
      oRpt:nL++
   EndIf
   AEVAL( ::aCD, {|nVal,nPos| ::aTG[nPos] += nVal },1,6 )
   ::aTG[7] += ::aCD[7]
   ::aTG[8] += aRes[6]
   ::aCD[9] ++
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aCD[11] # aRes[2]
      ::aTG[07] -= (If( ::aLS[8], 0, ::aCD[8] ) + ::aTG[10])
      If ::aLS[3] == "N"
         oRpt:Separator( 0,2,132 )
         oRpt:nL ++
      Else
         ::aTG[11] += ::aTG[07]
         cQry := STR( DAY(::aCD[11]),3)
      EndIf
      oRpt:Say( oRpt:nL, 01,STR( ::aCD[9],3 ) + "  ANTICIPOS" + cQry )
      oRpt:Say( oRpt:nL, 24,TRANSFORM(::aTG[7],"999,999,999" ))
      oRpt:Say( oRpt:nL, 36,TRANSFORM(::aTG[1],"999,999,999" ))
      oRpt:Say( oRpt:nL, 48,TRANSFORM(::aTG[2],"999,999,999" ))
      oRpt:Say( oRpt:nL, 60,TRANSFORM(::aTG[3], "99,999,999.99" ))
      oRpt:Say( oRpt:nL, 74,TRANSFORM(::aTG[4],"999,999,999" ))
      oRpt:Say( oRpt:nL, 85,TRANSFORM(::aTG[5], "99,999,999" ))
      oRpt:Say( oRpt:nL, 96,TRANSFORM(::aTG[6], "99,999,999.99" ))
      oRpt:Say( oRpt:nL,110,TRANSFORM(::aTG[8], "99,999,999" ))
      If ::aLS[3] == "N"
         oRpt:Say(++oRpt:nL,84,TRANSFORM(::aTG[10],"(99,999,999)" ))
         If ::nL > 0
            oRpt:NewPage()
            oRpt:aEnc[2] := NtChr( aRes[2],"3" )
            oRpt:nL    := oRpt:nLength +1
            oRpt:nPage := 0
         EndIf
      Else
         oRpt:Say(++oRpt:nL,0,REPLICATE("_",132) )
         oRpt:nL ++
      EndIf
      AFILL( ::aTG,0,1,10 )
      ::aCD[08] := ::aCD[9] := 0
      ::aCD[11] := aRes[2]
   EndIf
EndDo
MSFreeResult( ::hRes )
If ::aTG[11] # 0
   oRpt:Say( oRpt:nL+1,20,TRANSFORM(::aTG[11],"9,999,999,999.99" ))
EndIf
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD ArmarINF( aRes ) CLASS CDiarias
If aRes == "Diaria"
   aRes := "SELECT p.numfac FAC, p.fecpag FECHA, p.abono, p.deduccion, p.descuento, "          +;
                  "p.retencion + IFNULL(p.retiva,0) + IFNULL(p.retica,0) + IFNULL(p.retcre,0) "+;
                ", p.pagado, p.formapago, p.indicador, p.pordonde, u.cliente, u.codigo_nit, "  +;
                  "p.indred, p.p_de_mas "                  +;
           "FROM cadpagos p LEFT JOIN cadfactu u "         +;
             "USING(optica, numfac, tipo) "                +;
           "WHERE p.optica  = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND p.fecpag >= " + xValToChar( ::aLS[1] )   +;
            " AND p.fecpag <= " + xValToChar( ::aLS[2] )   +;
            " AND p.tipo = "    + xValToChar(oApl:Tipo)    +;
            " AND p.formapago <= 4 AND p.indicador <> 'A'" +;
            " AND p.pordonde "  + ::aCD[10]                +;
            " ORDER BY FECHA, FAC"
ElseIf aRes == "Antici"
   aRes := "SELECT p.numero FAC, p.fecha, p.abono, p.deduccion, p.descuento, p.retencion + "+;
                  "IFNULL(p.retiva,0) + IFNULL(p.retica,0) + IFNULL(p.retcre,0), p.pagado, "+;
                  "p.formapago, c.saldofac, p.pordonde, c.cliente, c.codigo_nit, p.indred, p.p_de_mas " +;
           "FROM cadantic c, cadantip p "                     +;
           "WHERE p.optica = c.optica AND p.numero = c.numero"+;
            " AND p.optica = " + LTRIM(STR(oApl:nEmpresa))    +;
            " AND p.fecha >= " + xValToChar( ::aLS[1] )       +;
            " AND p.fecha <= " + xValToChar( ::aLS[2] )       +;
            " AND p.pordonde " + ::aCD[10]                    +;
            " ORDER BY FECHA, FAC"
   ::aEnc[4] := "LISTADO DE ABONOS POR ANTICIPOS"
ElseIf aRes == "Tiriz1"
   aRes := "SELECT numfac, codart, precioven, desmon, " +;
           "montoiva, indicador, fecdev FROM cadventa " +;
           "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND fecfac = " + xValToChar( ::aLS[1] )   +;
            " AND tipo   = " + xValToChar(oApl:Tipo)    +;
            " ORDER BY numfac"
   ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit,;
               "REPORTE DE VENTAS - TIRILLA Z"  ,;
               "DIA : "+ NtChr( ::aLS[1],"2" ) }
ElseIf aRes == "Tiriz2"
   aRes := "SELECT formapago, abono, deduccion, descuento, "+;
               "retencion, retiva, retica, pagado, indred, "+;
           "codbanco FROM cadpagos "                        +;
           "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))    +;
            " AND fecpag = " + xValToChar( ::aLS[1] )       +;
            " AND tipo = "   + xValToChar(oApl:Tipo)        +;
            " AND formapago <= 4 AND indicador <> 'A' "     +;
            " AND pordonde <> 'A' UNION ALL "               +;
           "SELECT formapago, abono, deduccion, descuento, "+;
               "retencion, retiva, retica, pagado, indred, "+;
           "codbanco FROM cadantip "                        +;
           "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))    +;
            " AND fecha  = " + xValToChar( ::aLS[1] )       +;
           " ORDER BY formapago"
EndIf
::hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) > 0
   aRes := MyReadRow( ::hRes )
   AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( ::hRes,nP ) } )
EndIf
If ::aLS[3] == "T"
   ::aLS[3] := "Z"
   ::aTG := { 0,0,0,0,0,0,0,0,0,0,0,0 }
   While ::nL > 0
      If aRes[5] == 0
         ::aTG[08] += aRes[3]
      Else
         ::aTG[09] += aRes[3]               // Ventas Gravadas
      EndIf
         ::aTG[10] += aRes[5]
      If ::aTG[12]  # aRes[1]
         ::aTG[12] := aRes[1]
         If ::aTG[11] == 0
            ::aTG[11] := aRes[1]
         EndIf
      EndIf
      aRes[2] := TRIM( aRes[2] )
      aRes[3] += aRes[5]
      do Case
         Case LEFT(aRes[2],2) == "01" .OR. aRes[2] == "0599000001"
            ::aTG[01] += aRes[3]            // Montura
         Case LEFT(aRes[2],2) == "02" .OR. aRes[2] == "0599000002"
            ::aTG[02] += aRes[3]            // Oftalmicos
         Case LEFT(aRes[2],2) == "03"
            ::aTG[03] += aRes[3]            // Liquidos
         Case LEFT(aRes[2],2) == "04"
            ::aTG[04] += aRes[3]            // Accesorios
         Case LEFT(aRes[2],4) == "0501"
            ::aTG[05] += aRes[3]            // Consultas
         Case LEFT(aRes[2],2) >= "60" .OR. ;
             aRes[2] = "0599000003"   .OR. ;
             aRes[2] = "0504"
             ::aTG[06] += aRes[3]           // L.Contacto
         OtherWise
             ::aTG[07] += aRes[3]           // Varios
         EndCase
      If (::nL --) > 1
         aRes := MyReadRow( ::hRes )
         AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
      EndIf
   EndDo
   MSFreeResult( ::hRes )
   ::nL := ::aTG[12] - ::aTG[11] + If( ::aTG[12] > 0, 1, 0 )
EndIf
RETURN aRes

//------------------------------------//
METHOD ArmarPAG( aRes,nK ) CLASS CDiarias

 AFILL( ::aCD,0,1,5 )
 ::aCD[6] := aRes[4] + aRes[5]
 ::aCD[7] := aRes[3] + aRes[6] + aRes[14] + ::aCD[6]
 If aRes[8] >= 2 .AND. aRes[8] <= 3
    If aRes[7] == ::aCD[7]
       ::aCD[3] := ::aCD[7]          //[3]Tarj. Debito
    Else
       ::aCD[3] := ::aCD[7]          //[4]Tarj. Credito
       If nK == 0
          ::aCD[8] += aRes[3] + aRes[4] + If( aRes[9] == ".", 0, ::aCD[6] )
       Else
          ::aCD[8] += ::aCD[6] + aRes[3] + aRes[4]
       EndIf
    EndIf
 Else
    nK  := aRes[8] + 1
    If nK == 5
       If aRes[13]
          // Bono por NC
          ::aTG[10] += aRes[03]
       Else
          nK := 4
       EndIf
    EndIf
       ::aCD[nK] := aRes[3] + If( aRes[10] == "F", ::aCD[6], 0 )
 EndIf
 ::aCD[5] += aRes[14]
RETURN NIL

//------------------------------------//
METHOD ListoWIN( aRes ) CLASS CDiarias
   LOCAL cQry := ""
 ::aLS[7] := If( ::aLS[3] == "N", 1, 0.45 )
 ::Init( ::aEnc[4], .f. ,, !::aLS[6] ,,,, 5 )
 ::nMD := 21
   PAGE
      ::Cabecera( .t.,0.45 )
      ::nLinea -= 0.45
While ::nL > 0
   ::ArmarPAG( aRes,0 )
   oApl:nSaldo := If( aRes[9] == "T", 0, SaldoFac( aRes[1],1 ) )
   If ::aLS[3] == "N"
      oApl:oNit:Seek( {"codigo_nit",aRes[12]} )
      aRes[11] := If( oApl:oNit:CODIGO > 0, oApl:oNit:NOMBRE, aRes[11] )
      ::Cabecera( .t.,0.45 )
      UTILPRN ::oUtil Self:nLinea,01.9 SAY STR(aRes[1],7)  RIGHT
      UTILPRN ::oUtil Self:nLinea,02.0 SAY LEFT( aRes[11],15 )
      UTILPRN ::oUtil Self:nLinea,06.3 SAY TRANSFORM(::aCD[7],   "999,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,08.0 SAY TRANSFORM(::aCD[1],"@Z 999,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,09.7 SAY TRANSFORM(::aCD[2],"@Z 999,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,11.8 SAY TRANSFORM(::aCD[3] ,"@Z 99,999,999.99" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,13.6 SAY TRANSFORM(::aCD[4],"@Z 999,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,15.7 SAY TRANSFORM(::aCD[5] ,"@Z 99,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,17.5 SAY TRANSFORM(::aCD[6] ,"@Z 99,999,999.99" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,19.2 SAY TRANSFORM( aRes[6] ,"@Z 99,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,20.9 SAY TRANSFORM(oApl:nSaldo,"999,999,999" )    RIGHT
   EndIf
   AEVAL( ::aCD, {|nVal,nPos| ::aTG[nPos] += nVal },1,6 )
   ::aTG[7] += ::aCD[7] - If( aRes[9] == "-", aRes[5], 0 )
   ::aTG[8] += aRes[6]
   ::aTG[9] += oApl:nSaldo
   ::aCD[9] ++
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aCD[11] # aRes[2]
      ::aTG[07] -= (If( ::aLS[8], 0, ::aCD[8] ) + ::aTG[10])
      If ::aLS[3] == "N"
         ::Cabecera( .t.,::aLS[7],1.4,21 )
      Else
         ::Cabecera( .t.,::aLS[7] )
         ::aTG[11] += ::aTG[07]
         cQry := STR( DAY(::aCD[11]),3)
      EndIf
      UTILPRN ::oUtil Self:nLinea,01.0 SAY STR( ::aCD[9],3 ) + "  PAGOS" + cQry
      UTILPRN ::oUtil Self:nLinea,06.3 SAY TRANSFORM(::aTG[7],"999,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,08.0 SAY TRANSFORM(::aTG[1],"999,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,09.7 SAY TRANSFORM(::aTG[2],"999,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,11.8 SAY TRANSFORM(::aTG[3] ,"99,999,999.99" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,13.6 SAY TRANSFORM(::aTG[4],"999,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,15.7 SAY TRANSFORM(::aTG[5] ,"99,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,17.5 SAY TRANSFORM(::aTG[6] ,"99,999,999.99" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,19.2 SAY TRANSFORM(::aTG[8] ,"99,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,20.9 SAY TRANSFORM(::aTG[9],"999,999,999" )    RIGHT
      If ::aLS[3] == "N"
         ::nLinea += 0.5
         UTILPRN ::oUtil Self:nLinea,15.8 SAY TRANSFORM(::aTG[10],"(99,999,999)" ) RIGHT
         If ::nL > 0
            ::aEnc[1] := ::Separator( ::nEndLine )
            ::aEnc[5] := NtChr( aRes[2],"3" )
            ::nPage   := 1
         EndIf
      Else
         UTILPRN ::oUtil LINEA Self:nLinea,0.5 TO Self:nLinea,21.0 PEN ::oPen
         ::nLinea += 0.3
      EndIf
      AFILL( ::aTG,0,1,10 )
      ::aCD[08] := ::aCD[9] := 0
      ::aCD[11] := aRes[2]
   EndIf
EndDo
MSFreeResult( ::hRes )

If ::aTG[11] # 0
   ::Cabecera( .t.,0.4,0.8 )
   UTILPRN ::oUtil Self:nLinea,06.3 SAY TRANSFORM(::aTG[11],"9,999,999,999.99" )  RIGHT
EndIf
 ::aEnc[5]  := NtChr( ::aLS[1],"3" )
 ::aEnc[6,3]:=  "NUMERO"
 aRes       := ::ArmarINF( "Antici" )
If ::nL  > 0
   ::aEnc[1] := ::Separator( ::nEndLine )
   ::aCD[11] := aRes[2]
ElseIf ::aLS[8]
   ::Cabecera( .t.,0.45 )
EndIf
AFILL( ::aCD,0,1,9 )
::aTG  := { 0,0,0,0,0,0,0,0,0,0,0 }
cQry := ""
While ::nL > 0
   ::ArmarPAG( aRes,1 )
   If ::aLS[3] == "N"
      oApl:oNit:Seek( {"codigo_nit",aRes[12]} )
      aRes[11] := If( oApl:oNit:CODIGO > 0, oApl:oNit:NOMBRE, aRes[11] )
      ::Cabecera( .t.,0.45 )
      UTILPRN ::oUtil Self:nLinea,01.9 SAY STR(aRes[1],7)  RIGHT
      UTILPRN ::oUtil Self:nLinea,02.0 SAY LEFT( aRes[11],15 )
      UTILPRN ::oUtil Self:nLinea,06.3 SAY TRANSFORM(::aCD[7],   "999,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,08.0 SAY TRANSFORM(::aCD[1],"@Z 999,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,09.7 SAY TRANSFORM(::aCD[2],"@Z 999,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,11.8 SAY TRANSFORM(::aCD[3] ,"@Z 99,999,999.99" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,13.6 SAY TRANSFORM(::aCD[4],"@Z 999,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,15.7 SAY TRANSFORM(::aCD[5] ,"@Z 99,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,17.5 SAY TRANSFORM(::aCD[6] ,"@Z 99,999,999.99" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,19.2 SAY TRANSFORM( aRes[6] ,"@Z 99,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,20.9 SAY TRANSFORM( aRes[9] ,  "999,999,999" )    RIGHT
   EndIf
   AEVAL( ::aCD, {|nVal,nPos| ::aTG[nPos] += nVal },1,6 )
   ::aTG[7] += ::aCD[7]
   ::aTG[8] += aRes[6]
   ::aCD[9] ++
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aCD[11] # aRes[2]
      ::aTG[07] -= (If( ::aLS[8], 0, ::aCD[8] ) + ::aTG[10])
      If ::aLS[3] == "N"
         ::Cabecera( .t.,::aLS[7],1.4,21 )
      Else
         ::Cabecera( .t.,::aLS[7] )
         ::aTG[11] += ::aTG[07]
         cQry := STR( DAY(::aCD[11]),3)
      EndIf
      UTILPRN ::oUtil Self:nLinea,01.0 SAY STR( ::aCD[9],3 ) + "  ANTICIPOS" + cQry
      UTILPRN ::oUtil Self:nLinea,06.3 SAY TRANSFORM(::aTG[7],"999,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,08.0 SAY TRANSFORM(::aTG[1],"999,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,09.7 SAY TRANSFORM(::aTG[2],"999,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,11.8 SAY TRANSFORM(::aTG[3] ,"99,999,999.99" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,13.6 SAY TRANSFORM(::aTG[4],"999,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,15.7 SAY TRANSFORM(::aTG[5] ,"99,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,17.5 SAY TRANSFORM(::aTG[6] ,"99,999,999.99" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,19.2 SAY TRANSFORM(::aTG[8] ,"99,999,999" )    RIGHT
      If ::aLS[3] == "N"
         ::nLinea += 0.5
         UTILPRN ::oUtil Self:nLinea,15.8 SAY TRANSFORM(::aTG[10],"(99,999,999)" ) RIGHT
         If ::nL > 0
            ::aEnc[1]:= ::Separator( ::nEndLine )
            ::aEnc[5]:= NtChr( aRes[2],"3" )
            ::nPage  := 1
         EndIf
      Else
         UTILPRN ::oUtil LINEA Self:nLinea,0.5 TO Self:nLinea,21.0 PEN ::oPen
         ::nLinea += 0.3
      EndIf
      AFILL( ::aTG,0,1,10 )
      ::aCD[08] := ::aCD[9] := 0
      ::aCD[11] := aRes[2]
   EndIf
EndDo
MSFreeResult( ::hRes )
If ::aTG[11] # 0
   ::Cabecera( .t.,0.4,0.8 )
   UTILPRN ::oUtil Self:nLinea,06.3 SAY TRANSFORM(::aTG[11],"9,999,999,999.99" )  RIGHT
EndIf
   ENDPAGE
IMPRIME END .F.
RETURN NIL

//------------------------------------//
METHOD TirizDOS() CLASS CDiarias
   LOCAL aRes, cQry, oRpt, nFP
 ::aLS[3] := "T"
 aRes := ::ArmarINF( "Tiriz1" )
If ::aLS[4] == 2
   ::TirizWIN( aRes )
   RETURN NIL
EndIf
 cQry := "99,999,999,999"
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4],::aEnc[5] },::aLS[6] )
 oRpt:Titulo( 80 )
 oRpt:Say( 07,34,"Total Facturas"+ STR(::nL,6) )
 oRpt:Say( 09,14,"Desde No." + STR(::aTG[11],10) + "  Hasta No." + STR(::aTG[12],10) )
 oRpt:Say( 10,10,REPLICATE("_",50) )
 ::aTG[12] := ::aTG[1] + ::aTG[2] + ::aTG[3] + ::aTG[4] + ::aTG[5] + ::aTG[6] + ::aTG[7]
 oRpt:Say( 11,10,"MONTURAS.................. " + TRANSFORM( ::aTG[01],cQry ))
 oRpt:Say( 12,10,"LENTES OFTALMICOS......... " + TRANSFORM( ::aTG[02],cQry ))
 oRpt:Say( 13,10,"LIQUIDOS.................. " + TRANSFORM( ::aTG[03],cQry ))
 oRpt:Say( 14,10,"ACCESORIOS................ " + TRANSFORM( ::aTG[04],cQry ))
 oRpt:Say( 15,10,"CONSULTAS................. " + TRANSFORM( ::aTG[05],cQry ))
 oRpt:Say( 16,10,"LENTES DE CONTACTO........ " + TRANSFORM( ::aTG[06],cQry ))
 oRpt:Say( 17,10,"VARIOS.................... " + TRANSFORM( ::aTG[07],cQry ))
 oRpt:Say( 18,10,REPLICATE("_",50) )
 oRpt:Say( 19,10,"TOTAL    VENTAS........... " + TRANSFORM( ::aTG[12],cQry ))

 oRpt:Say( 21,10,"Ventas no Gravadas........ " + TRANSFORM( ::aTG[08],cQry ))
 oRpt:Say( 22,10,"Ventas    Gravadas........ " + TRANSFORM( ::aTG[09],cQry ))
 oRpt:Say( 23,10,"I.V.A. " + TRANSFORM( oApl:oEmp:PIVA,"(99%)" ) +;
                             " ............. " + TRANSFORM( ::aTG[10],cQry ))
 oRpt:Say( 25,10,REPLICATE("=",50) )
 oRpt:Say( 26,20,"I N G R E S O S" )
 oRpt:SetFont( oRpt:CPICompress,82,2 )
 oRpt:Say( 28,56,"DEDUCCION   RET.RENTA   RETEN.IVA   RETEN.ICA     VALOR NETO" )
 oRpt:nL := 29
 aRes := ::ArmarINF( "Tiriz2" )
If ::nL > 0
   nFP := aRes[1]
EndIf
::aTG  := { 0,0,0,0,0,0,0,0,0,0,0,0,0 }
cQry := { "EFECTIVO           :","CHEQUES            :","TARJETAS DEBITO    :",;
          "TARJETAS DE CREDITO:","OTROS PAGOS (BONOS):" }
While ::nL > 0
   //aRes[9] := If( nFP == 4 .AND. aRes[9], .f., .t. )
   If !(nFP == 4 .AND. aRes[9])
      ::aTG[01] ++
      ::aTG[03] += (aRes[3] + aRes[4])
      ::aTG[04] +=  aRes[5]
      ::aTG[05] +=  aRes[6]
      ::aTG[06] +=  aRes[7]
      ::aTG[07] +=  aRes[2]
   EndIf
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {|xV,nP| aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. nFP # aRes[1]
      ::aTG[2] := ::aTG[3] + ::aTG[4] + ::aTG[5] + ::aTG[6] + ::aTG[7]
      oRpt:Titulo( 126 )
      oRpt:Say( oRpt:nL, 10,cQry[nFP+1] + STR(::aTG[1],5) )
      oRpt:Say( oRpt:nL, 37,TRANSFORM(::aTG[2],   "99,999,999.99") )
      oRpt:Say( oRpt:nL, 52,TRANSFORM(::aTG[3],"@Z 99,999,999.99") )
      oRpt:Say( oRpt:nL, 66,TRANSFORM(::aTG[4],"@Z 99,999,999") )
      oRpt:Say( oRpt:nL, 79,TRANSFORM(::aTG[5],"@Z 99,999,999") )
      oRpt:Say( oRpt:nL, 91,TRANSFORM(::aTG[6],"@Z 99,999,999") )
      oRpt:Say( oRpt:nL,103,TRANSFORM(::aTG[7],"99,999,999.99") )
      oRpt:nL++
      ::aTG[08] += ::aTG[2]
      ::aTG[09] += ::aTG[3]
      ::aTG[10] += ::aTG[4]
      ::aTG[11] += ::aTG[5]
      ::aTG[12] += ::aTG[6]
      ::aTG[13] += ::aTG[7]
      ::aTG[01] := ::aTG[3] := ::aTG[4] := ::aTG[5] := ::aTG[6] := ::aTG[7] := 0
      nFP     := aRes[1]
   EndIf
EndDo
MSFreeResult( ::hRes )
 oRpt:Say(  oRpt:nL, 10,REPLICATE("=",106) )
 oRpt:Say(++oRpt:nL, 10,"TOTAL PAGADO" )
 oRpt:Say(  oRpt:nL, 36,TRANSFORM(::aTG[08],"999,999,999.99") )
 oRpt:Say(  oRpt:nL, 52,TRANSFORM(::aTG[09], "99,999,999.99") )
 oRpt:Say(  oRpt:nL, 67,TRANSFORM(::aTG[10], "99,999,999") )
 oRpt:Say(  oRpt:nL, 79,TRANSFORM(::aTG[11], "99,999,999") )
 oRpt:Say(  oRpt:nL, 91,TRANSFORM(::aTG[12], "99,999,999") )
 oRpt:Say(  oRpt:nL,102,TRANSFORM(::aTG[13],"999,999,999.99") )
 oRpt:NewPage()
 oRpt:End()
RETURN NIL

//------------------------------------//
METHOD TirizWIN( aRes ) CLASS CDiarias
   LOCAL cQry, nFP
 cQry := "99,999,999,999"
 ::Init( ::aEnc[4], .f. ,, !::aLS[6] )
   PAGE
    ::Cabecera( .t.,0.45 )
    UTILPRN ::oUtil 04.0,09.5 SAY "Total Facturas" + STR(::nL,6)
    UTILPRN ::oUtil 05.0,04.5 SAY "Desde No." + STR(::aTG[11],10) + "  Hasta No." + STR(::aTG[12],10)
    UTILPRN ::oUtil LINEA 5.5,3.5 TO 5.5,12.0 PEN ::oPen

 ::aTG[12] := ::aTG[1] + ::aTG[2] + ::aTG[3] + ::aTG[4] + ::aTG[5] + ::aTG[6] + ::aTG[7]
    UTILPRN ::oUtil 06.0,03.5 SAY "MONTURAS"
    UTILPRN ::oUtil 06.0,12.0 SAY TRANSFORM( ::aTG[01],cQry )  RIGHT
    UTILPRN ::oUtil 06.5,03.5 SAY "LENTES OFTALMICOS"
    UTILPRN ::oUtil 06.5,12.0 SAY TRANSFORM( ::aTG[02],cQry )  RIGHT
    UTILPRN ::oUtil 07.0,03.5 SAY "LIQUIDOS"
    UTILPRN ::oUtil 07.0,12.0 SAY TRANSFORM( ::aTG[03],cQry )  RIGHT
    UTILPRN ::oUtil 07.5,03.5 SAY "ACCESORIOS"
    UTILPRN ::oUtil 07.5,12.0 SAY TRANSFORM( ::aTG[04],cQry )  RIGHT
    UTILPRN ::oUtil 08.0,03.5 SAY "CONSULTAS"
    UTILPRN ::oUtil 08.0,12.0 SAY TRANSFORM( ::aTG[05],cQry )  RIGHT
    UTILPRN ::oUtil 08.5,03.5 SAY "LENTES DE CONTACTO"
    UTILPRN ::oUtil 08.5,12.0 SAY TRANSFORM( ::aTG[06],cQry )  RIGHT
    UTILPRN ::oUtil 09.0,03.5 SAY "VARIOS"
    UTILPRN ::oUtil 09.0,12.0 SAY TRANSFORM( ::aTG[07],cQry )  RIGHT
    UTILPRN ::oUtil LINEA 9.5,3.5 TO 9.5,12.0 PEN ::oPen
    UTILPRN ::oUtil 10.0,03.5 SAY "TOTAL    VENTAS"
    UTILPRN ::oUtil 10.0,12.0 SAY TRANSFORM( ::aTG[12],cQry )  RIGHT

    UTILPRN ::oUtil 11.0,03.5 SAY "Ventas no Gravadas"
    UTILPRN ::oUtil 11.0,12.0 SAY TRANSFORM( ::aTG[08],cQry )  RIGHT
    UTILPRN ::oUtil 11.5,03.5 SAY "Ventas     Gravadas"
    UTILPRN ::oUtil 11.5,12.0 SAY TRANSFORM( ::aTG[09],cQry )  RIGHT
    UTILPRN ::oUtil 12.0,03.5 SAY "I.V.A. " + TRANSFORM( oApl:oEmp:PIVA,"(99%)" )
    UTILPRN ::oUtil 12.0,12.0 SAY TRANSFORM( ::aTG[10],cQry )  RIGHT
    UTILPRN ::oUtil LINEA 12.5,3.5 TO 12.5,12.0 PEN ::oPen
    UTILPRN ::oUtil 13.0,06.0 SAY "I N G R E S O S"

    UTILPRN ::oUtil SELECT ::aFnt[5]
    UTILPRN ::oUtil 14.0,09.2 SAY "DEDUCCION   RET.RENTA   RETEN.IVA   RETEN.ICA     VALOR NETO"
    ::nLinea := 14.0
 aRes := ::ArmarINF( "Tiriz2" )
If ::nL > 0
   nFP := aRes[1]
EndIf
::aTG  := { 0,0,0,0,0,0,0,0,0,0,0,0,0 }
cQry := { "EFECTIVO","CHEQUES" ,"TARJETAS DEBITO",;
          "TARJETAS DE CREDITO","OTROS PAGOS (BONOS)" }
While ::nL > 0
   If !(nFP == 4 .AND. aRes[9])
      ::aTG[01] ++
      ::aTG[03] += (aRes[3] + aRes[4])
      ::aTG[04] +=  aRes[5]
      ::aTG[05] +=  aRes[6]
      ::aTG[06] +=  aRes[7]
      ::aTG[07] +=  aRes[2]
   EndIf
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {|xV,nP| aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. nFP # aRes[1]
      ::aTG[2] := ::aTG[3] + ::aTG[4] + ::aTG[5] + ::aTG[6] + ::aTG[7]
      ::Cabecera( .t.,0.45 )
      UTILPRN ::oUtil Self:nLinea,02.5 SAY cQry[nFP+1]
      UTILPRN ::oUtil Self:nLinea,06.2 SAY STR(::aTG[1],5)                          RIGHT
      UTILPRN ::oUtil Self:nLinea,08.8 SAY TRANSFORM( ::aTG[2],   "99,999,999.99" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,11.0 SAY TRANSFORM( ::aTG[3],"@Z 99,999,999.99" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,12.8 SAY TRANSFORM( ::aTG[4],"@Z 99,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,14.5 SAY TRANSFORM( ::aTG[5],"@Z 99,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,16.3 SAY TRANSFORM( ::aTG[6],"@Z 99,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM( ::aTG[7],   "99,999,999.99" ) RIGHT
      ::aTG[08] += ::aTG[2]
      ::aTG[09] += ::aTG[3]
      ::aTG[10] += ::aTG[4]
      ::aTG[11] += ::aTG[5]
      ::aTG[12] += ::aTG[6]
      ::aTG[13] += ::aTG[7]
      ::aTG[01] := ::aTG[3] := ::aTG[4] := ::aTG[5] := ::aTG[6] := ::aTG[7] := 0
      nFP     := aRes[1]
   EndIf
EndDo
MSFreeResult( ::hRes )
    ::nLinea += 0.5
    UTILPRN ::oUtil LINEA Self:nLinea,2.5 TO Self:nLinea,18.5 PEN ::oPen
    UTILPRN ::oUtil Self:nLinea,02.5 SAY "TOTAL PAGADO"
    UTILPRN ::oUtil Self:nLinea,08.8 SAY TRANSFORM( ::aTG[08],"999,999,999.99" ) RIGHT
    UTILPRN ::oUtil Self:nLinea,11.0 SAY TRANSFORM( ::aTG[09], "99,999,999.99" ) RIGHT
    UTILPRN ::oUtil Self:nLinea,12.8 SAY TRANSFORM( ::aTG[10], "99,999,999" )    RIGHT
    UTILPRN ::oUtil Self:nLinea,14.5 SAY TRANSFORM( ::aTG[11], "99,999,999" )    RIGHT
    UTILPRN ::oUtil Self:nLinea,16.3 SAY TRANSFORM( ::aTG[12], "99,999,999" )    RIGHT
    UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM( ::aTG[13],"999,999,999.99" ) RIGHT
   ENDPAGE
IMPRIME END .F.
RETURN NIL

//------------------------------------//
METHOD ListoRec() CLASS CDiarias
   LOCAL aCT, aLC, aRC, aPG, cQry, hRes, nC, nL, oRpt
If oApl:oEmp:DIVIDENOMB > 0
   nC := LEN( ALLTRIM( oApl:oEmp:NOMBRE ) ) -;
         RAT( "-",oApl:oEmp:NOMBRE ) + oApl:oEmp:DIVIDENOMB
Else
   nC := 0
EndIf
aCT  := { {"11050501",0,0},{"13551501",0,0},{"13551701",0,0},{"13551801",0,0},;
          {"13551901",0,0},{"53053501",0,0},{"28050501",0,0},{"13050502",0,0} }
aLC  := { PADC(   LEFT( oApl:oEmp:NOMBRE,oApl:oEmp:DIVIDENOMB    ),25 ),;
          PADC( SUBSTR( oApl:oEmp:NOMBRE,oApl:oEmp:DIVIDENOMB,nC ),25 ),;
          0,0,"99,999,999",0,;
        "SELECT p.numero, p.abono, p.retencion, p.retiva, p.retica, p.deduccion + p.descuento, "+;
               "p.retcre, p.pordonde, p.formapago, c.cliente, c.codigo_cli, p.indred "+;
        "FROM cadantip p, cadantic c "                 +;
        "WHERE p.optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND p.rcaja  = [RCAJA]"                     +;
         " AND c.optica = p.optica AND c.numero = p.numero","" }
aLC[8]:= STRTRAN( aLC[7],"antip","pagos" ) + " AND c.tipo = p.tipo ORDER BY p.numfac"
aLC[8]:= STRTRAN( aLC[8],"antic","factu" )
aLC[8]:= STRTRAN( aLC[8],"numero","numfac" )
cQry := "SELECT c.rcaja, c.fecha, c.tipo, n.nombre "   +;
        "FROM cadrcaja c LEFT JOIN cadclien n "        +;
         "USING( codigo_nit ) "                        +;
        "WHERE c.optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fecha >= " + xValToChar( ::aLS[1] )   +;
         " AND c.fecha <= " + xValToChar( ::aLS[2] )   + If( ::aLS[3] > 0,;
         " AND c.rcaja  = " + LTRIM(STR(::aLS[3])), "" )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgStop( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[4] == 2
   ::LaserRec( aCT,aLC,hRes,nL )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,,::aLS[5],,,33,33 )
oRpt:Cargo := {|| oRpt:nL := 10, oRpt:nPagI ++       ,;
                  oRpt:SetFont( oRpt:CPINormal,82,2 ),;
                  oRpt:Say( 01,06,aLC[1] + "    DIRECCION: " + oApl:oEmp:DIRECCION ),;
                  oRpt:Say( 02,06,aLC[2] + "    TELEFONOS: " + oApl:oEmp:TELEFONOS ),;
                  oRpt:Say( 03,06,"Nit: " + oApl:oEmp:NIT + SPACE(21)+ oApl:cCiu )  ,;
                  oRpt:Say( 04,46,"F E C H A        RECIBO DE CAJA" ),;
                  oRpt:Say( 05,45,NtChr( aRC[2],"2" ) )              ,;
                  oRpt:Say( 05,64,"No. " + STRZERO( aRC[1],8 ))      ,;
                  oRpt:SetFont( oRpt:CPICompress,82,1 )              ,;
                  oRpt:Say( 06,01,"Recibido DE: " + aRC[4] )         ,;
                  oRpt:Say( 07,00,REPLICATE( "-",136 ) )             ,;
                  oRpt:Say( 08,00,"  FACTURA                  C L I E N T E                                 FORMA PAGO        ABONOS    RETENCION    DEDUCCION  -V A L O R-" ),;
                  oRpt:Say( 09,00,REPLICATE( "-",136 ) ) }
While nL > 0
   aRC := MyReadRow( hRes )
   AEVAL( aRC, { | xV,nP | aRC[nP] := MyClReadCol( hRes,nP ) } )
   nC  := If( aRC[3] == "A", 7, 8 )
   aPG := Buscar( STRTRAN( aLC[nC],"[RCAJA]",LTRIM(STR(aRC[1])) ),"CM",,9 )
   If LEN( aPG ) == 0
      nL --
      LOOP
   EndIf
   oRpt:nPagI := oRpt:nL := aLC[4] := aLC[6] := 0
   oRpt:nPage := 1
   If (nC := LEN( aPG )) > 13
      oRpt:nPage := INT( nC/18 ) // + If( nC % 18 > 0, 1, 0 )
      oRpt:nPage += If( nC-oRpt:nPage*18 > 13, 2, 1 )
   EndIf
   FOR nC := 1 TO LEN( aPG )
      aLC[3] := aPG[nC,2] + aPG[nC,3] + aPG[nC,4] + aPG[nC,5] + aPG[nC,6] + aPG[nC,7]
      aLC[4] += aLC[3]
      If aPG[nC,9] == 4 .AND. aPG[nC,12]
         If aRC[3]  # "A"
            aCT[6,2] += aLC[3]
            aCT[8,3] += aLC[3]
         EndIf
      Else
         If aPG[nC,8] # "A"
            aCT[1,2] += aPG[nC,2]
            aCT[2,2] += aPG[nC,3]
            aCT[3,2] += aPG[nC,4]
            aCT[4,2] += aPG[nC,5]
            aCT[5,2] += aPG[nC,7]
            aCT[6,2] += aPG[nC,6]
         EndIf
         If aRC[3]  # "A"
            aCT[7,2] += If( aPG[nC,8] == "A", aLC[3], 0 )
            aCT[8,3] += aLC[3]
         Else
            aCT[7,3] += aLC[3]
         EndIf
      EndIf
      If oRpt:nL ==  0
         EVAL( oRpt:Cargo )
      EndIf
      If aLC[6]  # aPG[nC,1]
         aLC[6] := aPG[nC,1]
         If ::aLS[7]
            oApl:oHis:Seek( {"codigo_nit",aPG[nC,11]} )
            ::aLS[6] := oApl:oHis:NROIDEN
         EndIf
         oRpt:Say( oRpt:nL, 01,aRC[3] )
         oRpt:Say( oRpt:nL, 03,TRANSFORM(aLC[6],"99999999") )
         oRpt:Say( oRpt:nL, 15,aPG[nC,10] + "    C.C. " + ::aLS[6] )
      EndIf
      aPG[nC,3] += aPG[nC,4] + aPG[nC,5]
      oRpt:Say( oRpt:nL, 73,{"EFECTIVO","CHEQUE","T.DEBITO","T.CREDITO",;
                             "OTROS PAGOS"}[aPG[nC,9]+1] )
      oRpt:Say( oRpt:nL, 87,TRANSFORM(aPG[nC,2], aLC[5]) )
      oRpt:Say( oRpt:nL,100,TRANSFORM(aPG[nC,3], aLC[5]) )
      oRpt:Say( oRpt:nL,113,TRANSFORM(aPG[nC,6], aLC[5]) )
      oRpt:Say( oRpt:nL,126,TRANSFORM(aLC[3]   , aLC[5]) )
      oRpt:nL++
      If oRpt:nL >= 28 .AND. oRpt:nPagI < oRpt:nPage
         oRpt:nL :=  0
         oRpt:Say( 29,00,REPLICATE( "=",136 ) )
         oRpt:Say( 30,73,"Pagina" +STR(oRpt:nPagI,3) +" DE" +STR(oRpt:nPage,3) )
         oRpt:NewPage()
      EndIf
   NEXT nC
   If oRpt:nL >= 24 .AND. oRpt:nPagI < oRpt:nPage
      oRpt:Say( 29,00,REPLICATE( "=",136 ) )
      oRpt:Say( 30,73,"Pagina" +STR(oRpt:nPagI,3) +" DE" +STR(oRpt:nPage,3) )
      oRpt:NewPage()
      EVAL( oRpt:Cargo )
   Else
      oRpt:Say(  oRpt:nL, 00,REPLICATE( "=",136 ) )
   EndIf
   oRpt:Say(++oRpt:nL, 73,"TOTALES =>" )
   oRpt:Say(  oRpt:nL,126,TRANSFORM( aLC[4], aLC[5] ) )
   oRpt:Say(++oRpt:nL, 73,REPLICATE( "=",63 ) )
   oRpt:SetFont( oRpt:CPINormal,82,1 )
   FOR nC := 1 TO 8
      If aCT[nC,2] > 0 .OR. aCT[nC,3] > 0
         oRpt:Say(++oRpt:nL,06,aCT[nC,1] )
         oRpt:Say(  oRpt:nL,16,TRANSFORM(aCT[nC,2],"@Z 99,999,999") )
         oRpt:Say(  oRpt:nL,30,TRANSFORM(aCT[nC,3],"@Z 99,999,999") )
         aCT[nC,2] := aCT[nC,3] := 0
      EndIf
   NEXT nC
   oRpt:NewPage()
   nL --
EndDo
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserRec( aCT,aLC,hRes,nL ) CLASS CDiarias
   LOCAL aRC, aPG, nC
 ::Init( "RECIBO DE CAJA", .f. ,, !::aLS[5] )
 DEFINE FONT ::aFnt[1] NAME ::cFont SIZE 0,-20 BOLD OF ::oPrn
   PAGE
While nL > 0
   aRC := MyReadRow( hRes )
   AEVAL( aRC, { | xV,nP | aRC[nP] := MyClReadCol( hRes,nP ) } )
   nC  := If( aRC[3] == "A", 7, 8 )
   aPG := Buscar( STRTRAN( aLC[nC],"[RCAJA]",LTRIM(STR(aRC[1])) ),"CM",,9 )
   If LEN( aPG ) == 0
      nL --
      LOOP
   EndIf
    aLC[4] := aLC[6] := 0
   ::aEnc  := { .t.,aLC[1],aLC[2],aRC[1],aRC[4],aRC[2] }
   ::nFila := ::nPage := 1
   If (nC := LEN( aPG )) > 13
      ::nFila := INT( nC/19 ) // + If( nC % 18 > 0, 1, 0 )
      ::nFila +=  If( nC-::nFila*19 > 13, 2, 1 )
   EndIf
   FOR nC := 1 TO LEN( aPG )
      aLC[3] := aPG[nC,2] + aPG[nC,3] + aPG[nC,4] + aPG[nC,5] + aPG[nC,6] + aPG[nC,7]
      aLC[4] += aLC[3]
      If aPG[nC,9] == 4 .AND. aPG[nC,12]
         If aRC[3]  # "A"
            aCT[6,2] += aLC[3]
            aCT[8,3] += aLC[3]
         EndIf
      Else
         If aPG[nC,8] # "A"
            aCT[1,2] += aPG[nC,2]
            aCT[2,2] += aPG[nC,3]
            aCT[3,2] += aPG[nC,4]
            aCT[4,2] += aPG[nC,5]
            aCT[5,2] += aPG[nC,7]
            aCT[6,2] += aPG[nC,6]
         EndIf
         If aRC[3]  # "A"
            aCT[7,2] += If( aPG[nC,8] == "A", aLC[3], 0 )
            aCT[8,3] += aLC[3]
         Else
            aCT[7,3] += aLC[3]
         EndIf
      EndIf
      aPG[nC,3] += aPG[nC,4] + aPG[nC,5]
      ::Memo( 11.56 )
      If aLC[6]  # aPG[nC,1]
         aLC[6] := aPG[nC,1]
         If ::aLS[7]
            oApl:oHis:Seek( {"codigo_nit",aPG[nC,11]} )
            ::aLS[6] := oApl:oHis:NROIDEN
         EndIf
         UTILPRN ::oUtil Self:nLinea, 0.5 SAY aRC[3]
         UTILPRN ::oUtil Self:nLinea, 2.1 SAY STR(aLC[6],9) RIGHT
         UTILPRN ::oUtil Self:nLinea, 2.3 SAY aPG[nC,10]
         UTILPRN ::oUtil Self:nLinea, 7.6 SAY "C.C. " + ::aLS[6]
      EndIf
         UTILPRN ::oUtil Self:nLinea,10.6 SAY {"EFECTIVO","CHEQUE","T.DEBITO","T.CREDITO",;
                                               "OTROS PAGOS"}[aPG[nC,9]+1]
         UTILPRN ::oUtil Self:nLinea,14.5 SAY TRANSFORM( aPG[nC,2], aLC[5] ) RIGHT
         UTILPRN ::oUtil Self:nLinea,16.5 SAY TRANSFORM( aPG[nC,3], aLC[5] ) RIGHT
         UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM( aPG[nC,6], aLC[5] ) RIGHT
         UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aLC[3]   , aLC[5] ) RIGHT
   NEXT nC
   ::Memo( 09.88 )
   If ::nLinea > 4
      UTILPRN ::oUtil LINEA Self:nLinea  , 0.5 TO Self:nLinea,20.5 PEN ::oPen
      ::nLinea += 0.42
   EndIf
      UTILPRN ::oUtil Self:nLinea,10.6 SAY "TOTALES =>"
      UTILPRN ::oUtil Self:nLinea,20.6 SAY TRANSFORM( aLC[4]   , aLC[5] ) RIGHT
      ::nLinea += 0.42
      UTILPRN ::oUtil LINEA Self:nLinea  ,10.6 TO Self:nLinea,20.5 PEN ::oPen
      UTILPRN ::oUtil SELECT ::aFnt[2]
   FOR nC := 1 TO 8
      If aCT[nC,2] > 0 .OR. aCT[nC,3] > 0
         ::nLinea += 0.42
         UTILPRN ::oUtil Self:nLinea, 2.0 SAY aCT[nC,1]
         UTILPRN ::oUtil Self:nLinea, 7.0 SAY TRANSFORM(aCT[nC,2],"@Z 99,999,999") RIGHT
         UTILPRN ::oUtil Self:nLinea,10.5 SAY TRANSFORM(aCT[nC,3],"@Z 99,999,999") RIGHT
         aCT[nC,2] := aCT[nC,3] := 0
      EndIf
   NEXT nC
   If (nL --) > 1
      ENDPAGE
      PAGE
   EndIf
EndDo
   ENDPAGE
IMPRIME END .F.
RETURN NIL

//------------------------------------//
METHOD Memo( nLin ) CLASS CDiarias
If !::aEnc[1]
      ::nLinea += 0.42
   If ::nLinea >= nLin .AND. ::nPage < ::nFila
      UTILPRN ::oUtil LINEA Self:nLinea,0.5 TO Self:nLinea,20.5 PEN ::oPen
      ::nLinea += 0.42
      UTILPRN ::oUtil Self:nLinea,12.5 SAY "Pagina" +STR(::nPage,3) +" DE" +STR(::nFila,3)
      ENDPAGE
      PAGE
      ::aEnc[1]:= .T.
      ::nPage  ++
   EndIf
EndIf
If ::aEnc[1]
   ::aEnc[1]:= .F.
   UTILPRN ::oUtil 0.8, 0.5 SAY ALLTRIM( ::aEnc[2] )    FONT ::aFnt[1]
   UTILPRN ::oUtil 1.5, 0.6 SAY ALLTRIM( ::aEnc[3] )    FONT ::aFnt[4]
   UTILPRN ::oUtil SELECT ::aFnt[2]

   UTILPRN ::oUtil 1.3, 6.5 SAY oApl:oEmp:DIRECCION
   UTILPRN ::oUtil 1.3,15.7 SAY "RECIBO DE CAJA No."    FONT ::aFnt[4]
   UTILPRN ::oUtil 1.8, 6.5 SAY "Teléfonos: " + oApl:oEmp:TELEFONOS
   UTILPRN ::oUtil 2.0,16.4 SAY STR(::aEnc[4],10)       FONT ::aFnt[4]
   UTILPRN ::oUtil 2.3, 1.5 SAY "NIT: " + oApl:oEmp:NIT
   UTILPRN ::oUtil 2.3, 6.5 SAY TRIM(oApl:cCiu) + " - COLOMBIA"
   UTILPRN ::oUtil 2.8, 1.0 SAY "Recibido DE: " + ::aEnc[5]
   UTILPRN ::oUtil 2.8,15.5 SAY "FECHA  " + NtChr( ::aEnc[6],"2" )
   UTILPRN ::oUtil BOX  3.2 , 0.4 TO  3.7 ,20.6 ROUND 25,25
   UTILPRN ::oUtil SELECT ::aFnt[5]
   UTILPRN ::oUtil 3.3, 0.8 SAY "FACTURA"
   UTILPRN ::oUtil 3.3, 4.5 SAY "C L I E N T E"
   UTILPRN ::oUtil 3.3,10.6 SAY "FORMA PAGO"
   UTILPRN ::oUtil 3.3,14.5 SAY "ABONOS"    RIGHT
   UTILPRN ::oUtil 3.3,16.5 SAY "RETENCION" RIGHT
   UTILPRN ::oUtil 3.3,18.5 SAY "DEDUCCION" RIGHT
   UTILPRN ::oUtil 3.3,20.5 SAY "V A L O R" RIGHT
   ::nLinea := 4.0
EndIf
RETURN NIL

//------------------------------------//
FUNCTION RCaja( lInsert,nCNit,dFecha,cTipo,cNIde )
   LOCAL cIns := {0}, cQry, hRes
cQry := "SELECT MAX(rcaja) FROM cadrcaja "           +;
        "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND fecha  = " + xValToChar( dFecha )     +;
         " AND codigo_nit = " + LTRIM(STR(nCNit))    +;
         " AND tipo = "   + xValToChar( cTipo )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If MSNumRows( hRes ) > 0
   cIns    := MyReadRow( hRes )
   cIns[1] := MyClReadCol( hRes,1 )
EndIf
MSFreeResult( hRes )
If lInsert .OR. EMPTY(cIns[1])
   cIns := "INSERT INTO cadrcaja VALUES( " + LTRIM(STR(oApl:nEmpresa)) +;
           ", null, '" + MyDToMs( DTOS( dFecha ) ) + "', " +;
           LTRIM(STR(nCNit)) + ", '" + cTipo       + "', " +;
           If( cNIde == NIL .OR. EMPTY(cNIde), "null", "'"+cNIde+"'" ) + ", 0 )"
   Guardar( cIns,"cadrcaja" )
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   cIns    := MyReadRow( hRes )
   cIns[1] := MyClReadCol( hRes,1 )
   MSFreeResult( hRes )
EndIf
RETURN cIns[1]