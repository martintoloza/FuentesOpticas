// Programa.: CAOLIVED.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo ventas diarias de las Opticas
#include "FiveWin.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE CaoLiVed()
   LOCAL oA, oDlg, oGet := ARRAY(8)
 oA := VDiarias()
DEFINE DIALOG oDlg TITLE "Listo Ventas Diarias" FROM 0, 0 TO 09,50
   @ 02, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02, 92 GET oGet[1] VAR oA:aLS[1] OF oDlg  SIZE 40,10 PIXEL
   @ 14, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 14, 92 GET oGet[2] VAR oA:aLS[2] OF oDlg ;
      VALID oA:aLS[2] >= oA:aLS[1] SIZE 40,10 PIXEL
   @ 26, 00 SAY "TIPO DE IMPRESORA" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 26, 92 COMBOBOX oGet[3] VAR oA:aLS[3] ITEMS { "Matriz","Laser" };
      SIZE 40,90 OF oDlg PIXEL
   @ 26,140 CHECKBOX oGet[8] VAR oA:aLS[6] PROMPT "Resumen" OF oDlg;
      SIZE 60,12 PIXEL ;
      WHEN oApl:cLocal == "LOC"
   @ 38, 00 SAY "Número de Copias"  OF oDlg RIGHT PIXEL SIZE 90,10
   @ 38, 92 GET oGet[4] VAR oA:aLS[4] OF oDlg PICTURE "99" SIZE 12,10 PIXEL;
      VALID Rango( oA:aLS[4],1,10 ) ;
      WHEN oA:aLS[3] == 2
   @ 38,140 CHECKBOX oGet[5] VAR oA:aLS[5] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 52, 50 BUTTON oGet[6] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[6]:Disable(), oA:NEW(), oDlg:End() ) PIXEL
   @ 52,100 BUTTON oGet[7] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 58, 02 SAY "[CAOLIVED]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
CLASS VDiarias FROM TIMPRIME

 DATA hRes, nL
 DATA aLS  INIT { DATE(),DATE(),oApl:nTFor,1, .f., (oApl:cLocal != "LOC") }
 DATA aPG  INIT { 0,0,0,0,0,0,0,0 }
 DATA aTG  INIT { 0,0,0,0,0,0,0,0,0,0 }

 METHOD NEW() Constructor
 METHOD ArmarINF( aRes )
 METHOD ArmarPAG( aRes,nK,cTipo )
 METHOD ListoWIN( aRes )
 METHOD AnulaDOS()
 METHOD AnulaWin()
 METHOD ResumDOS()
 METHOD ResumWIN()
 METHOD NotacDOS()
 METHOD NotacWIN()
ENDCLASS

//------------------------------------//
METHOD NEW() CLASS VDiarias
   LOCAL cPict := "@Z 99,999,999"
   LOCAL aRes, oRpt, oAnu := {|| .t. }
 aRes   := ::ArmarINF( "Diaria" )
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit                 ,;
             "LISTADO DE VENTAS DIARIAS", NtChr( ::aLS[1],"3" ),;
             { .F., 0.5,"FACTURA" }   , { .F., 2.0,"--ORDEN" } ,;
             { .F., 3.3,"NOMBRE DEL CLIENTE" }                 ,;
             { .T., 7.9,"VENTAS" }   , { .T., 9.5,"EFECTIVO" } ,;
             { .T.,11.4,"CHEQUES" }  , { .T.,13.4,"TARJETAS" } ,;
             { .T.,15.2,"BONOS" }    , { .T.,17.2,"OTRO.PAGOS" },;
             { .T.,19.2,"DEDUCCION" }, { .T.,20.9,"RETENCION" } }
If ::aLS[3] == 2
   ::ListoWIN( aRes )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4],::aEnc[5],;
          "FACTURA -ORDEN- NOMBRE DEL CLIENTE GAV     VENTAS   EFECTIVO    CHEQUES " +;
          "     TARJETAS      BONOS OTRO.PAGOS     DEDUCCION  RETENCION"},::aLS[5],1,2 )
oRpt:Titulo( 132 )
While ::nL > 0
   ::ArmarPAG( aRes,0 )
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aPG[10] # aRes[2]
      oRpt:Titulo( 132 )
      oRpt:Say( oRpt:nL,00,STR(::aPG[10],7) + STR(::aPG[11],9) )
      If ::aPG[15] == "A"
         oRpt:Say( oRpt:nL,16,"** A N U L A D A **" )
         oAnu := {|| ::AnulaDOS() }
      Else
         oRpt:Say( oRpt:nL, 17, ::aPG[12],17 )
         oRpt:Say( oRpt:nL, 35,STR(::aPG[13],3) )
         oRpt:Say( oRpt:nL, 39,TRANSFORM(::aPG[14],"99,999,999" ))
         oRpt:Say( oRpt:nL, 50,TRANSFORM(::aPG[01],cPict ))
         oRpt:Say( oRpt:nL, 61,TRANSFORM(::aPG[02],cPict ))
         oRpt:Say( oRpt:nL, 72,TRANSFORM(::aPG[03],"@Z 99,999,999.99" ))
         oRpt:Say( oRpt:nL, 86,TRANSFORM(::aPG[04],cPict ))
         oRpt:Say( oRpt:nL, 97,TRANSFORM(::aPG[05],cPict ))
         oRpt:Say( oRpt:nL,108,TRANSFORM(::aPG[06],"@Z 99,999,999.99" ))
         oRpt:Say( oRpt:nL,122,TRANSFORM(::aPG[07],cPict ))
         AEVAL( ::aPG, {|nVal,nPos| ::aTG[nPos] += nVal },1,7 )
         //::aTG[7] += oApl:nSaldo
         ::aTG[8] += ::aPG[14]
      EndIf
      ::aPG := { 0,0,0,0,0,0,0,0 }
      AEVAL( aRes, {|xV| AADD( ::aPG,xV ) },1,7 )
      ::aTG[10] ++
      oRpt:nL ++
   EndIf
EndDo
MSFreeResult( ::hRes )
If ::aTG[10] > 0
   oRpt:Separator( 0,2,132 )
   oRpt:Say(++oRpt:nL, 01,STR( ::aTG[10],3 ) + " FACTURAS" )
   oRpt:Say(  oRpt:nL, 39,TRANSFORM(::aTG[8],"99,999,999" ))
   oRpt:Say(  oRpt:nL, 50,TRANSFORM(::aTG[1],"99,999,999" ))
   oRpt:Say(  oRpt:nL, 61,TRANSFORM(::aTG[2],"99,999,999" ))
   oRpt:Say(  oRpt:nL, 72,TRANSFORM(::aTG[3],"99,999,999.99" ))
   oRpt:Say(  oRpt:nL, 86,TRANSFORM(::aTG[4],"99,999,999" ))
   oRpt:Say(  oRpt:nL, 97,TRANSFORM(::aTG[5],"99,999,999" ))
   oRpt:Say(  oRpt:nL,108,TRANSFORM(::aTG[6],"99,999,999.99" ))
   oRpt:Say(  oRpt:nL,122,TRANSFORM(::aTG[7],"99,999,999" ))
   oRpt:Say(++oRpt:nL, 96,TRANSFORM(::aTG[9],"(99,999,999)" ))
EndIf
::aPG := { 0,0,0,0,0,0,0,0 }
::aTG := { 0,0,0,0,0,0,0,0,0,0 }
aRes  := ::ArmarINF( "Antici" )
   oRpt:NewPage()
   oRpt:aEnc[1] := ::aEnc[4]
   oRpt:nL := oRpt:nLength + 1
   oRpt:Titulo( 132 )
While ::nL > 0
   ::ArmarPAG( aRes,1 )
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aPG[10] # aRes[2]
      oRpt:Titulo( 132 )
      oRpt:Say( oRpt:nL,00,STR(::aPG[10],7) + STR(::aPG[11],9) )
      If ::aPG[15] == "A"
         oRpt:Say( oRpt:nL,16,"** A N U L A D A **" )
      Else
         oRpt:Say( oRpt:nL, 17, ::aPG[12],17 )
         oRpt:Say( oRpt:nL, 35,STR(::aPG[13],3) )
         oRpt:Say( oRpt:nL, 39,TRANSFORM(::aPG[14],"99,999,999" ))
         oRpt:Say( oRpt:nL, 50,TRANSFORM(::aPG[01],cPict ))
         oRpt:Say( oRpt:nL, 61,TRANSFORM(::aPG[02],cPict ))
         oRpt:Say( oRpt:nL, 72,TRANSFORM(::aPG[03],"@Z 99,999,999.99" ))
         oRpt:Say( oRpt:nL, 86,TRANSFORM(::aPG[04],cPict ))
         oRpt:Say( oRpt:nL, 97,TRANSFORM(::aPG[05],cPict ))
         oRpt:Say( oRpt:nL,108,TRANSFORM(::aPG[06],"@Z 99,999,999.99" ))
         oRpt:Say( oRpt:nL,122,TRANSFORM(::aPG[07],cPict ))
         AEVAL( ::aPG, {|nVal,nPos| ::aTG[nPos] += nVal },1,7 )
         ::aTG[8] += ::aPG[14]
      EndIf
      ::aPG := { 0,0,0,0,0,0,0,0 }
      AEVAL( aRes, {|xV| AADD( ::aPG,xV ) },1,7 )
      ::aTG[10] ++
      oRpt:nL++
   EndIf
EndDo
MSFreeResult( ::hRes )
If ::aTG[10] > 0
   oRpt:Separator( 0,1,132 )
   oRpt:Say(++oRpt:nL, 01,STR( ::aTG[10],3 ) + " ANTICIPOS" )
   oRpt:Say(  oRpt:nL, 39,TRANSFORM(::aTG[8],"99,999,999" ))
   oRpt:Say(  oRpt:nL, 50,TRANSFORM(::aTG[1],"99,999,999" ))
   oRpt:Say(  oRpt:nL, 61,TRANSFORM(::aTG[2],"99,999,999" ))
   oRpt:Say(  oRpt:nL, 72,TRANSFORM(::aTG[3],"99,999,999.99" ))
   oRpt:Say(  oRpt:nL, 86,TRANSFORM(::aTG[4],"99,999,999" ))
   oRpt:Say(  oRpt:nL, 97,TRANSFORM(::aTG[5],"99,999,999" ))
   oRpt:Say(  oRpt:nL,108,TRANSFORM(::aTG[6],"99,999,999.99" ))
   oRpt:Say(  oRpt:nL,122,TRANSFORM(::aTG[7],"99,999,999" ))
EndIf
   oRpt:NewPage()
   oRpt:End()
//If oApl:cLocal # "LOC"
If ::aLS[6]
   ::ResumDOS()
   ::NotacDOS()
   If !oRpt:lMp
      EVAL( oAnu )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD ArmarINF( aRes ) CLASS VDiarias
If aRes == "Diaria"
   aRes := "SELECT u.fechoy, u.numfac, u.orden, u.cliente, u.gaveta, "   +;
                  "u.totalfac, u.indicador, p.abono, p.retencion + "     +;
           "IFNULL(p.retiva,0) + IFNULL(p.retica,0) + IFNULL(p.retcre,0)"+;
                ", p.deduccion, p.descuento, p.pagado, p.formapago "     +;
                ", p.indred, p.p_de_mas "                                +;
           "FROM cadfactu u LEFT JOIN cadpagos p ON u.optica = p.optica "+;
             "AND u.numfac = p.numfac AND u.tipo = p.tipo "+;
             "AND p.pordonde = 'F' AND p.indicador <> 'A' "+;
           "WHERE u.optica  = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND u.fechoy >= " + xValToChar( ::aLS[1] )   +;
            " AND u.fechoy <= " + xValToChar( ::aLS[2] )   +;
            " AND u.tipo   = "  + xValToChar(oApl:Tipo)    +;
           " ORDER BY u.fechoy, u.numfac"
ElseIf aRes == "Antici"
   aRes := "SELECT c.saldofac, c.numero, c.orden, c.cliente, c.gaveta, " +;
                  "c.totalfac, c.indicador, p.abono, p.retencion + "     +;
           "IFNULL(p.retiva,0) + IFNULL(p.retica,0) + IFNULL(p.retcre,0)"+;
                ", p.deduccion, p.descuento, p.pagado, p.formapago "     +;
                ", p.indred, p.p_de_mas "                                +;
           "FROM cadantic c LEFT JOIN cadantip p ON c.optica = p.optica "+;
             "AND c.numero = p.numero AND p.pordonde = 'F' "             +;
           "WHERE c.optica = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND c.fecha >= " + xValToChar( ::aLS[1] )   +;
            " AND c.fecha <= " + xValToChar( ::aLS[2] )   +;
            " ORDER BY c.fecha, c.numero"
   ::aEnc[4] := "LISTADO DE ANTICIPOS"
ElseIf aRes == "Anular"
   aRes := "SELECT numfac, orden, cliente, gaveta, totalfac, remplaza "+;
           "FROM cadfactu "                                    +;
           "WHERE optica    = " + LTRIM(STR(oApl:nEmpresa))    +;
            " AND fechaent  = " + xValToChar( ::aLS[1] )       +;
            " AND tipo      = "  + xValToChar(oApl:Tipo)       +;
            " AND indicador = 'A' ORDER BY numfac"
   ::aEnc[4] := "LISTADO DE FACTURAS ANULADAS"
ElseIf aRes == "Resume"
   aRes := "SELECT abono, deduccion, descuento, retencion, codbanco, numcheque, numfac"   +;
                ", pagado, formapago, indred, retiva, retica, retcre, pordonde, p_de_mas "+;
           "FROM cadpagos "  +;
           "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))  +;
            " AND fecpag = " + xValToChar( ::aLS[1] )     +;
            " AND tipo   = " + xValToChar(oApl:Tipo)      +;
            " AND formapago <= 4 AND indicador <> 'A' "   +;
            " UNION ALL "                                 +;
           "SELECT abono, deduccion, descuento, retencion, codbanco, numcheque, numero"+;
                ", pagado, formapago, indred, retiva, retica, retcre, 'X', p_de_mas "  +;
           "FROM cadantip "  +;
           "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))  +;
            " AND fecha  = " + xValToChar( ::aLS[1] )     +;
           " ORDER BY formapago, codbanco, numcheque"
   ::aEnc[4] := "RESUMEN DE INGRESOS DIARIOS"
   ASIZE( ::aEnc,5 )
ElseIf aRes == "Notasc"
    aRes := "SELECT c.numero, c.clase, c.numfac, p.numfac, c.nroiden, "+;
                   "c.concepto, p.pagado, c.bonos, c.devol, c.anulap "+;
           "FROM cadnotac c LEFT JOIN cadpagos p "        +;
             " ON p.optica    = c.optica"                 +;
            " AND p.fecpag    = c.fecha"                  +;
            " AND p.numcheque = c.numero"                 +;
            " AND p.formapago = 7"                        +;
            " AND p.pordonde  = 'N'"                      +;
           "WHERE c.optica = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND c.fecha  = " + xValToChar( ::aLS[1] )   +;
           " ORDER BY c.numero, p.numfac"
   ::aEnc[4] := "LISTADO DE NOTAS CREDITO"
EndIf
::hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) > 0
   aRes := MyReadRow( ::hRes )
   AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( ::hRes,nP ), AADD(::aPG,aRes[nP]) } )
EndIf
RETURN aRes

//------------------------------------//
METHOD ArmarPAG( aRes,nK,cTipo ) CLASS VDiarias

If cTipo == NIL
   If aRes[7] # "A"
      ::aPG[6] += (aRes[10] + aRes[11])
      ::aPG[7] +=  aRes[09]
      ::aPG[8] :=  aRes[08] + aRes[09] + aRes[10] + aRes[11]
      If aRes[13] == 3                 // Tarj. Credito
         If STR(aRes[12],10,2) == STR(::aPG[8],10,2)
            ::aPG[03] += ::aPG[8]
         Else
            ::aPG[03] += (::aPG[8] - aRes[09])
         // ::aPG[04] += (::aPG[8] - aRes[09])
         EndIf
      Else
            nK := aRes[13] + 1
         If nK == 5
            If aRes[14]
               // Bono por NC
               ::aTG[9] += aRes[08]
            Else
               nK := 4
            EndIf
         EndIf
         ::aPG[nK]+= ::aPG[8]
      EndIf
      If aRes[15] > 0
         ::aPG[05]+= aRes[15] //P_DE_MAS
      EndIf
   EndIf
Else
   AFILL( ::aPG,0 )
   If aRes[6] == 0
      aRes[6] := aRes[1] ; cTipo  := oApl:Tipo
   Else
      cTipo   := If( oApl:Tipo == "U", "D", "U" )
   EndIf
   oApl:oPag:Seek( {"optica",oApl:nEmpresa,"numfac",aRes[6],"tipo",cTipo,;
                    "formapago <= ",4,"pordonde","F"} )
   While !oApl:oPag:Eof()
      ::aPG[5] +=  oApl:oPag:P_DE_MAS
      ::aPG[6] += (oApl:oPag:DEDUCCION + oApl:oPag:DESCUENTO)
      aRes[6] := oApl:oPag:ABONO + oApl:oPag:RETENCION + oApl:oPag:DEDUCCION +;
                 oApl:oPag:DESCUENTO + oApl:oPag:P_DE_MAS
      If oApl:oPag:FORMAPAGO == 3                 // Tarj. Credito
         If oApl:oPag:PAGADO == aRes[6]
            ::aPG[3] += aRes[6]
         Else
            ::aPG[3] += oApl:oPag:ABONO + oApl:oPag:DEDUCCION
         EndIf
      Else
          nK  := oApl:oPag:FORMAPAGO + 1
            ::aPG[nK]+= aRes[6]
      EndIf
      oApl:oPag:Skip(1):Read()
      oApl:oPag:xLoad()
   EndDo
EndIf
RETURN NIL

//------------------------------------//
METHOD ListoWIN( aRes ) CLASS VDiarias
   LOCAL cPict := "@Z 99,999,999"
   LOCAL nK, oRpt, oAnu := {|| .t. }
 ::Init( ::aEnc[4], .f. ,, !::aLS[5] ,,,, 5 )
 ::nMD := 21
   PAGE
      ::Cabecera( .t.,0.45 )
      ::nLinea -= 0.45
While ::nL > 0
   ::ArmarPAG( aRes,0 )
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aPG[10] # aRes[2]
      ::Cabecera( .t.,0.45 )
         UTILPRN ::oUtil Self:nLinea,01.9 SAY STR(::aPG[10],7)  RIGHT
         UTILPRN ::oUtil Self:nLinea,03.1 SAY STR(::aPG[11],9)  RIGHT
      If ::aPG[15] == "A"
         UTILPRN ::oUtil Self:nLinea,03.3 SAY "** A N U L A D A **"
         oAnu := {|| ::AnulaWIN() }
      Else
         UTILPRN ::oUtil Self:nLinea,03.3 SAY LEFT( ::aPG[12],17 )
         UTILPRN ::oUtil Self:nLinea,07.9 SAY TRANSFORM(::aPG[14],"99,999,999" )       RIGHT
         UTILPRN ::oUtil Self:nLinea,09.5 SAY TRANSFORM(::aPG[01],cPict )              RIGHT
         UTILPRN ::oUtil Self:nLinea,11.4 SAY TRANSFORM(::aPG[02],cPict )              RIGHT
         UTILPRN ::oUtil Self:nLinea,13.4 SAY TRANSFORM(::aPG[03],"@Z 99,999,999.99" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,15.2 SAY TRANSFORM(::aPG[04],cPict )              RIGHT
         UTILPRN ::oUtil Self:nLinea,17.2 SAY TRANSFORM(::aPG[05],cPict )              RIGHT
         UTILPRN ::oUtil Self:nLinea,19.2 SAY TRANSFORM(::aPG[06],"@Z 99,999,999.99" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,20.9 SAY TRANSFORM(::aPG[07],cPict )              RIGHT
         AEVAL( ::aPG, {|nVal,nPos| ::aTG[nPos] += nVal },1,7 )
         ::aTG[8] += ::aPG[14]
      EndIf
      ::aPG := { 0,0,0,0,0,0,0,0 }
      AEVAL( aRes, {|xV| AADD( ::aPG,xV ) },1,7 )
      ::aTG[10] ++
   EndIf
EndDo
If ::aTG[10] > 0
   ::Cabecera( .t.,0.4,1.3,21 )
   UTILPRN ::oUtil Self:nLinea,00.6 SAY STR( ::aTG[10],3 ) + " FACTURAS"
   UTILPRN ::oUtil Self:nLinea,07.9 SAY TRANSFORM(::aTG[8], "99,999,999" )    RIGHT
   UTILPRN ::oUtil Self:nLinea,09.5 SAY TRANSFORM(::aTG[1], "99,999,999" )    RIGHT
   UTILPRN ::oUtil Self:nLinea,11.4 SAY TRANSFORM(::aTG[2], "99,999,999" )    RIGHT
   UTILPRN ::oUtil Self:nLinea,13.4 SAY TRANSFORM(::aTG[3], "99,999,999.99" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,15.2 SAY TRANSFORM(::aTG[4], "99,999,999" )    RIGHT
   UTILPRN ::oUtil Self:nLinea,17.2 SAY TRANSFORM(::aTG[5], "99,999,999" )    RIGHT
   UTILPRN ::oUtil Self:nLinea,19.2 SAY TRANSFORM(::aTG[6], "99,999,999.99" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,20.9 SAY TRANSFORM(::aTG[7], "99,999,999" )    RIGHT
   ::nLinea += 0.5
   UTILPRN ::oUtil Self:nLinea,17.3 SAY TRANSFORM(::aTG[9],"(99,999,999)" )   RIGHT
EndIf
MSFreeResult( ::hRes )
 ::aEnc[1] := ::Separator( ::nEndLine )
 ::aPG := { 0,0,0,0,0,0,0,0 }
 ::aTG := { 0,0,0,0,0,0,0,0,0,0 }
 aRes  := ::ArmarINF( "Antici" )
While ::nL > 0
   ::ArmarPAG( aRes,1 )
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aPG[10] # aRes[2]
      ::Cabecera( .t.,0.45 )
         UTILPRN ::oUtil Self:nLinea,01.9 SAY STR(::aPG[10],7) RIGHT
         UTILPRN ::oUtil Self:nLinea,03.1 SAY STR(::aPG[11],9) RIGHT
      If ::aPG[15] == "A"
         UTILPRN ::oUtil Self:nLinea,03.3 SAY "** A N U L A D A **"
      Else
         UTILPRN ::oUtil Self:nLinea,03.3 SAY LEFT( ::aPG[12],17 )
         UTILPRN ::oUtil Self:nLinea,07.9 SAY TRANSFORM(::aPG[14],"99,999,999" )       RIGHT
         UTILPRN ::oUtil Self:nLinea,09.5 SAY TRANSFORM(::aPG[01],cPict )              RIGHT
         UTILPRN ::oUtil Self:nLinea,11.4 SAY TRANSFORM(::aPG[02],cPict )              RIGHT
         UTILPRN ::oUtil Self:nLinea,13.4 SAY TRANSFORM(::aPG[03],"@Z 99,999,999.99" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,15.4 SAY TRANSFORM(::aPG[04],cPict )              RIGHT
         UTILPRN ::oUtil Self:nLinea,17.2 SAY TRANSFORM(::aPG[05],cPict )              RIGHT
         UTILPRN ::oUtil Self:nLinea,19.2 SAY TRANSFORM(::aPG[06],"@Z 99,999,999.99" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,20.9 SAY TRANSFORM(::aPG[07],cPict )              RIGHT
         AEVAL( ::aPG, {|nVal,nPos| ::aTG[nPos] += nVal },1,7 )
         ::aTG[8] += ::aPG[14]
      EndIf
      ::aPG := { 0,0,0,0,0,0,0,0 }
      AEVAL( aRes, {|xV| AADD( ::aPG,xV ) },1,7 )
      ::aTG[10] ++
   EndIf
EndDo
MSFreeResult( ::hRes )
If ::aTG[10] > 0
   ::Cabecera( .t.,0.4,0.9,21 )
   UTILPRN ::oUtil Self:nLinea,00.6 SAY STR( ::aTG[10],3 ) + " ANTICIPOS"
   UTILPRN ::oUtil Self:nLinea,07.9 SAY TRANSFORM(::aTG[8], "99,999,999" )    RIGHT
   UTILPRN ::oUtil Self:nLinea,09.5 SAY TRANSFORM(::aTG[1], "99,999,999" )    RIGHT
   UTILPRN ::oUtil Self:nLinea,11.4 SAY TRANSFORM(::aTG[2], "99,999,999" )    RIGHT
   UTILPRN ::oUtil Self:nLinea,13.4 SAY TRANSFORM(::aTG[3], "99,999,999.99" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,15.4 SAY TRANSFORM(::aTG[4], "99,999,999" )    RIGHT
   UTILPRN ::oUtil Self:nLinea,17.2 SAY TRANSFORM(::aTG[5], "99,999,999" )    RIGHT
   UTILPRN ::oUtil Self:nLinea,19.2 SAY TRANSFORM(::aTG[6], "99,999,999.99" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,20.9 SAY TRANSFORM(::aTG[7], "99,999,999" )    RIGHT
EndIf
If ::aLS[6]
   EVAL( oAnu )
   ::ResumWIN()
   ::NotacWIN()
EndIf
   ENDPAGE
IMPRIME END .F.
RETURN NIL

//-------Listo Facturas Anuladas------//
METHOD AnulaDOS() CLASS VDiarias
   LOCAL aRes, oRpt, cPict := "@Z 99,999,999"
 aRes   := ::ArmarINF( "Anular" )
If ::nL ==  0
   MSFreeResult( ::hRes )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4], ::aEnc[5],;
          "FACTURA -ORDEN- NOMBRE DEL CLIENTE GAV     VENTAS   EFECTIVO    CHEQUES "+;
          "     TARJETAS      BONOS OTRO.PAGOS     DEDUCCION   CREDITOS"},::aLS[5],1,2 )
::aPG := ARRAY(6)
::aTG := { 0,0,0,0,0,0,0,0,0 }
While ::nL > 0
   ::ArmarPAG( aRes,1,"U" )
   oApl:nSaldo := aRes[5] -::aPG[1] -::aPG[2] -::aPG[3] -::aPG[4] -::aPG[5]
   oRpt:Titulo( 132 )
   oRpt:Say( oRpt:nL, 00,STR(aRes[1],7) + STR(aRes[2],8) )
   oRpt:Say( oRpt:nL, 16,aRes[3],18 )
   oRpt:Say( oRpt:nL, 35,STR(aRes[4],3) )
   oRpt:Say( oRpt:nL, 39,TRANSFORM(aRes[5],"99,999,999" ))
   oRpt:Say( oRpt:nL, 50,TRANSFORM(::aPG[1],cPict ))
   oRpt:Say( oRpt:nL, 61,TRANSFORM(::aPG[2],cPict ))
   oRpt:Say( oRpt:nL, 72,TRANSFORM(::aPG[3],"@Z 99,999,999.99" ))
   oRpt:Say( oRpt:nL, 86,TRANSFORM(::aPG[4],cPict ))
   oRpt:Say( oRpt:nL, 97,TRANSFORM(::aPG[5],cPict ))
   oRpt:Say( oRpt:nL,108,TRANSFORM(::aPG[6],"@Z 99,999,999.99" ))
   oRpt:Say( oRpt:nL,122,TRANSFORM(oApl:nSaldo,cPict ))
   AEVAL( ::aPG, {|nVal,nPos| ::aTG[nPos] += nVal } )
   ::aTG[7] += oApl:nSaldo
   ::aTG[8] += aRes[5]
   ::aTG[9] ++
   oRpt:nL ++
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
EndDo
   MSFreeResult( ::hRes )
   oRpt:Separator( 0,1,132 )
   oRpt:Say(++oRpt:nL, 01,STR( ::aTG[9],3 ) + " FACTURAS" )
   oRpt:Say(  oRpt:nL, 39,TRANSFORM(::aTG[8],"99,999,999" ))
   oRpt:Say(  oRpt:nL, 50,TRANSFORM(::aTG[1],"99,999,999" ))
   oRpt:Say(  oRpt:nL, 61,TRANSFORM(::aTG[2],"99,999,999" ))
   oRpt:Say(  oRpt:nL, 72,TRANSFORM(::aTG[3],"99,999,999.99" ))
   oRpt:Say(  oRpt:nL, 86,TRANSFORM(::aTG[4],"99,999,999" ))
   oRpt:Say(  oRpt:nL, 97,TRANSFORM(::aTG[5],"99,999,999" ))
   oRpt:Say(  oRpt:nL,108,TRANSFORM(::aTG[6],"99,999,999.99" ))
   oRpt:Say(  oRpt:nL,122,TRANSFORM(::aTG[7],"99,999,999" ))
oRpt:NewPage()
oRpt:End()
RETURN NIL

//-------Listo Facturas Anuladas------//
METHOD AnulaWIN() CLASS VDiarias
   LOCAL aRes, cPict := "@Z 99,999,999"
 aRes   := ::ArmarINF( "Anular" )
If ::nL ==  0
   MSFreeResult( ::hRes )
   RETURN NIL
EndIf
 ::aEnc[1] := ::Separator( ::nEndLine )
 ::aPG := ARRAY(6)
 ::aTG := { 0,0,0,0,0,0,0,0,0 }
While ::nL > 0
   ::ArmarPAG( aRes,1,"U" )
   oApl:nSaldo := aRes[4] -::aPG[1] -::aPG[2] -::aPG[3] -::aPG[4] -::aPG[5]
   ::Cabecera( .t.,0.45 )
   UTILPRN ::oUtil Self:nLinea,01.9 SAY STR(aRes[1],7)  RIGHT
   UTILPRN ::oUtil Self:nLinea,03.1 SAY STR(aRes[2],9)  RIGHT
   UTILPRN ::oUtil Self:nLinea,03.3 SAY LEFT( aRes[3],17 )
   UTILPRN ::oUtil Self:nLinea,07.9 SAY TRANSFORM(aRes[5],"99,999,999" )         RIGHT
   UTILPRN ::oUtil Self:nLinea,09.5 SAY TRANSFORM(::aPG[01],cPict )              RIGHT
   UTILPRN ::oUtil Self:nLinea,11.4 SAY TRANSFORM(::aPG[02],cPict )              RIGHT
   UTILPRN ::oUtil Self:nLinea,13.4 SAY TRANSFORM(::aPG[03],"@Z 99,999,999.99" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,15.2 SAY TRANSFORM(::aPG[04],cPict )              RIGHT
   UTILPRN ::oUtil Self:nLinea,17.2 SAY TRANSFORM(::aPG[05],cPict )              RIGHT
   UTILPRN ::oUtil Self:nLinea,19.2 SAY TRANSFORM(::aPG[06],"@Z 99,999,999.99" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,20.9 SAY TRANSFORM(oApl:nSaldo,cPict )            RIGHT
   AEVAL( ::aPG, {|nVal,nPos| ::aTG[nPos] += nVal } )
   ::aTG[7] += oApl:nSaldo
   ::aTG[8] += aRes[5]
   ::aTG[9] ++
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
EndDo
   MSFreeResult( ::hRes )
   ::Cabecera( .t.,0.4,0.9,21 )
   UTILPRN ::oUtil Self:nLinea,00.6 SAY STR( ::aTG[9],3 ) + " FACTURAS"
   UTILPRN ::oUtil Self:nLinea,07.9 SAY TRANSFORM(::aTG[8], "99,999,999" )      RIGHT
   UTILPRN ::oUtil Self:nLinea,09.5 SAY TRANSFORM(::aTG[1], "99,999,999" )      RIGHT
   UTILPRN ::oUtil Self:nLinea,11.4 SAY TRANSFORM(::aTG[2], "99,999,999" )      RIGHT
   UTILPRN ::oUtil Self:nLinea,13.4 SAY TRANSFORM(::aTG[3], "99,999,999.99" )   RIGHT
   UTILPRN ::oUtil Self:nLinea,15.2 SAY TRANSFORM(::aTG[4], "99,999,999" )      RIGHT
   UTILPRN ::oUtil Self:nLinea,17.2 SAY TRANSFORM(::aTG[5], "99,999,999" )      RIGHT
   UTILPRN ::oUtil Self:nLinea,19.2 SAY TRANSFORM(::aTG[6], "99,999,999.99" )   RIGHT
   UTILPRN ::oUtil Self:nLinea,20.9 SAY TRANSFORM(::aTG[7], "99,999,999" )      RIGHT
RETURN NIL

//--------Listo Resumen Diario--------//
METHOD ResumDOS() CLASS VDiarias
   LOCAL aRes, cQry, oRpt, nK, nFormaP := 0
 aRes  := ::ArmarINF( "Resume" )
 ::aTG := { 0,0,0,0,0,0,0,"CHEQUES            :","TARJETAS DEBITO    :",;
           "TARJETAS DE CREDITO:","OTROS PAGOS (BONOS):",0,0,0,0,0,0,0,0 }
 ::aPG := {}
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{::aEnc[4],::aEnc[5]},::aLS[5],1,2 )
oRpt:Titulo( 126 )
oRpt:Say( oRpt:nL,00,REPLICATE("_",133 ) )
If ::nL > 0
   cQry := "BANCO CHEQUE / VOUCHER MONTO DEL PAGO                "+;
           "      RETENCION     RETEN.IVA    RETEN.ICA    RETE.CREE     ABONO NETO"
   If (nFormaP := aRes[9]) > 0
      oRpt:Say(++oRpt:nL,00,::aTG[nFormaP+7],19 )
      oRpt:nL ++
      oRpt:Say(  oRpt:nL,11,cQry )
      oRpt:nL ++
      cQry := ""
   EndIf
EndIf
While ::nL > 0
   If aRes[14] == "A"
       ::aTG[17] += aRes[8]
   Else
      If nFormaP # 0 .AND. nFormaP == aRes[9]
         If aRes[9] >= 2 .AND. aRes[9] <= 3
            nK := aRes[8] -  aRes[3]
         Else
            nK := aRes[8] //- (aRes[2] + aRes[3] + aRes[4] + aRes[11] + aRes[12])
         EndIf
         oRpt:Titulo( 130 )
         oRpt:Say( oRpt:nL,00,STR(aRes[7],10) )
         oRpt:Say( oRpt:nL,13,aRes[5] )
         oRpt:Say( oRpt:nL,17,aRes[6] )
         oRpt:Say( oRpt:nL,35,TRANSFORM( nK     ,"99,999,999.99" ))
         oRpt:Say( oRpt:nL,50,TRANSFORM(aRes[02],"(99,999,999.99)" ))
         oRpt:Say( oRpt:nL,67,TRANSFORM(aRes[04],"(99,999,999)" ))
         nK := aRes[1] + aRes[2] + aRes[3] + aRes[4]
         If nFormaP == 3 .AND. aRes[8] < nK     // Tarj. Credito
            ::aTG[2] -= aRes[1]
            oRpt:Say( oRpt:nL,22,"P" )
         ElseIf nFormaP >= 2
             If nFormaP == 4 .AND. aRes[10]
                ::aTG[7] += aRes[1]
                oRpt:Say( oRpt:nL,11,"A" )
             EndIf
            oRpt:Say( oRpt:nL, 81,TRANSFORM(aRes[11],"(99,999,999)" ))
            oRpt:Say( oRpt:nL, 94,TRANSFORM(aRes[12],"(99,999,999)" ))
         EndIf
         oRpt:Say( oRpt:nL,107,TRANSFORM(aRes[13],"(99,999,999)" ))
         oRpt:Say( oRpt:nL,121,TRANSFORM(aRes[1],"99,999,999.99" ))
         oRpt:nL++
         If aRes[9] == 2 .OR. aRes[9] == 3
          //aRes[5] := If( ISALPHA( aRes[5] ), aRes[5], "M " )
            If (nK := ASCAN( ::aPG, {|aVal| aVal[1] == aRes[5] } )) == 0
               AADD( ::aPG, { aRes[5],0,0,0,0,0 } )
                nK := LEN( ::aPG )
            EndIf
            ::aPG[nK,2] += (aRes[01] + aRes[02] + aRes[04] +aRes[11] + aRes[12])
            ::aPG[nK,3] +=  aRes[02]
            ::aPG[nK,4] +=  aRes[04]
            ::aPG[nK,5] +=  aRes[11]
            ::aPG[nK,6] +=  aRes[12]
         EndIf
      EndIf
      ::aTG[18] +=  aRes[1]
      ::aTG[12] += (aRes[2] + aRes[3])
      ::aTG[13] +=  aRes[4]
      ::aTG[14] +=  aRes[11]
      ::aTG[15] +=  aRes[12]
      ::aTG[16] +=  aRes[13]
      ::aTG[19] +=  aRes[15]
   EndIf
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {|xV,nP| aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. nFormaP # aRes[9]
      If nFormaP == 0
         oRpt:Say(++oRpt:nL,05,oRpt:CPIBold+"EFECTIVO        :" )
      Else
         oRpt:Say(++oRpt:nL,05,oRpt:CPIBold+"TOTAL " + ::aTG[nFormaP+7],,,1 )
      EndIf
         ::aTG[18] -= ::aTG[7]
         oRpt:Say(  oRpt:nL, 53,TRANSFORM(::aTG[12],"@Z 99,999,999.99") )
         oRpt:Say(  oRpt:nL, 70,TRANSFORM(::aTG[13],"@Z 99,999,999") )
         oRpt:Say(  oRpt:nL, 84,TRANSFORM(::aTG[14],"@Z 99,999,999") )
         oRpt:Say(  oRpt:nL, 97,TRANSFORM(::aTG[15],"@Z 99,999,999") )
         oRpt:Say(  oRpt:nL,110,TRANSFORM(::aTG[16],"@Z 99,999,999") )
         oRpt:Say(  oRpt:nL,123,TRANSFORM(::aTG[18],   "99,999,999.99")+oRpt:CPIBoldN )
      If nFormaP == 4
         oRpt:Say(++oRpt:nL,23,oRpt:CPIBold+"( N.C. )",,,1 )
         oRpt:Say(  oRpt:nL,123,TRANSFORM(::aTG[07],   "99,999,999.99")+oRpt:CPIBoldN )
         ::aTG[18] += ::aTG[7]
      EndIf
      nFormaP := aRes[9]
      If ::nL > 0
         oRpt:nL+= 2
         oRpt:Say( oRpt:nL,00,::aTG[nFormaP+7],19,,1 )
         If !EMPTY( cQry )
            oRpt:Say(++oRpt:nL,11,cQry )
            cQry := ""
         EndIf
      EndIf
      oRpt:nL++
      ::aTG[1] += ::aTG[18]
      ::aTG[2] += ::aTG[12]
      ::aTG[3] += ::aTG[13]
      ::aTG[4] += ::aTG[14]
      ::aTG[5] += ::aTG[15]
      ::aTG[6] += ::aTG[16]
      ::aTG[12]:= ::aTG[13] := ::aTG[14] := ::aTG[15] := ::aTG[16] := ::aTG[18] := 0
   EndIf
EndDo
MSFreeResult( ::hRes )
cQry := "SELECT MIN(rcaja), MAX(rcaja) FROM cadrcaja " +;
        "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))  +;
         " AND fecha  = " + xValToChar( ::aLS[1] )
cQry := Buscar( cQry,"CM",,8 )
If LEN( cQry ) == 0
   aRes := ""
Else
   aRes := "TC 14 DOC." + LTRIM(STR(cQry[1])) +;
           If( cQry[2] > cQry[1], "-"+LTRIM(STR(cQry[2])), "" )
EndIf
::aTG[1] -= ::aTG[7]
::aTG[8] := ::aTG[1] + ::aTG[2] + ::aTG[3] + ::aTG[4] + ::aTG[5] + ::aTG[6]
::aTG[9] := 0
::nL     := If( LEN( ::aPG ) > 0, 13, 12 )
cQry := SPACE(11)

oRpt:Separator( 0,::nL+LEN( ::aPG ) )
If ::nL > 9
   ASORT( ::aPG,,, { |x,y| x[1] < y[1] } )
      oRpt:Say(++oRpt:nL,00,"RESUMEN TARJETAS" )
   FOR nK := 1 TO LEN( ::aPG )
      ::aTG[9] += (::aPG[nK,3] + ::aPG[nK,4] +::aPG[nK,5] + ::aPG[nK,6])
      oRpt:Say(  oRpt:nL, 22,::aPG[nK,1],,,1 )
      oRpt:Say(  oRpt:nL, 35,TRANSFORM(::aPG[nK,2],   "99,999,999.99") )
      oRpt:Say(  oRpt:nL, 51,TRANSFORM(::aPG[nK,3],"@Z 99,999,999.99") )
      oRpt:Say(  oRpt:nL, 68,TRANSFORM(::aPG[nK,4],"@Z 99,999,999") )
      oRpt:Say(  oRpt:nL, 82,TRANSFORM(::aPG[nK,5],"@Z 99,999,999") )
      oRpt:Say(  oRpt:nL, 95,TRANSFORM(::aPG[nK,6],"@Z 99,999,999") )
      oRpt:nL++
   NEXT nK
EndIf
::aTG[10] := ::aTG[8] + ::aTG[7] + ::aTG[9] + ::aTG[17]
oRpt:SetFont( oRpt:cFontI+oRpt:CPIBold,82,2 )
oRpt:Say(++oRpt:nL,07,"INGRESOS NETOS  :" + cQry +;
           TRANSFORM( ::aTG[1],"99,999,999.99" ))
oRpt:Say(++oRpt:nL,07,"TOTAL DEDUCCION :" + cQry +;
           TRANSFORM( ::aTG[2],"99,999,999.99" ))
oRpt:Say(++oRpt:nL,07,"TOTAL RETENCION :" + cQry +;
           TRANSFORM( ::aTG[3],"99,999,999.99" ))
oRpt:Say(++oRpt:nL,07,"TOTAL RETEN.IVA :" + cQry +;
           TRANSFORM( ::aTG[4],"99,999,999.99" ))
oRpt:Say(++oRpt:nL,07,"TOTAL RETEN.ICA :" + cQry +;
           TRANSFORM( ::aTG[5],"99,999,999.99" ))
oRpt:Say(++oRpt:nL,07,"TOTAL RETE.CREE :" + cQry +;
           TRANSFORM( ::aTG[6],"99,999,999.99" ))
oRpt:Say(++oRpt:nL,35,"=============" )
oRpt:Say(++oRpt:nL,07,"TOTAL ING.BRUTOS:" + cQry +;
           TRANSFORM( ::aTG[8],"99,999,999.99" ))
oRpt:Say(++oRpt:nL,07,"OTROS PAGOS(ant):" + cQry +;
           TRANSFORM( ::aTG[7],"99,999,999.99" ))
oRpt:Say(  oRpt:nL,63,TRANSFORM( ::aTG[17],"@Z 99,999,999.99" ))
oRpt:Say(++oRpt:nL,07,"DSCTO. TARJETAS :" + cQry +;
           TRANSFORM( ::aTG[09],"99,999,999.99" ))
oRpt:Say(++oRpt:nL,07,"APROVECHAMIENTO :" + cQry +;
           TRANSFORM( ::aTG[19],"99,999,999.99" ))
oRpt:Say(++oRpt:nL,07,"MOVTO. CONTABLE :" + cQry +;
           TRANSFORM( ::aTG[10],"99,999,999.99" ))
oRpt:Say(  oRpt:nL,100,aRes )
oRpt:NewPage()
oRpt:End()
RETURN NIL

//--------Listo Resumen Diario--------//
METHOD ResumWIN() CLASS VDiarias
   LOCAL aRes, cQry, nK, nFormaP := 0
 ::aEnc[1] := ::Separator( ::nEndLine )
 ::nPage := 1
 ::aTG := { 0,0,0,0,0,0,0,"CHEQUES            :","TARJETAS DEBITO    :",;
           "TARJETAS DE CREDITO:","OTROS PAGOS (BONOS):",0,0,0,0,0,0,0,0 }
 aRes  := ::ArmarINF( "Resume" )
 ::aPG := {}
If ::nL > 0
   cQry := "BANCO CHEQUE / VOUCHER MONTO DEL PAGO                "+;
           "      RETENCION     RETEN.IVA    RETEN.ICA    RETE.CREE     ABONO NETO"
   If (nFormaP := aRes[9]) > 0
      ::Cabecera( .t.,0.45 )
      UTILPRN ::oUtil Self:nLinea,00.6 SAY ::aTG[nFormaP+7] FONT ::aFnt[6]
      ::nLinea += 0.5
      UTILPRN ::oUtil Self:nLinea,02.2 SAY cQry
      ::nLinea += 0.5
      cQry := ""
   EndIf
EndIf
While ::nL > 0
   If aRes[14] == "A"
       ::aTG[17] += aRes[8]
   Else
      If nFormaP # 0 .AND. nFormaP == aRes[9]
         If aRes[9] >= 2 .AND. aRes[9] <= 3
            nK := aRes[8] -  aRes[3]
         Else
            nK := aRes[8]
         EndIf
         ::Cabecera( .t.,0.45 )
         UTILPRN ::oUtil Self:nLinea,02.0 SAY STR(aRes[7],10)  RIGHT
         UTILPRN ::oUtil Self:nLinea,02.5 SAY aRes[5]
         UTILPRN ::oUtil Self:nLinea,03.1 SAY aRes[6]
         UTILPRN ::oUtil Self:nLinea,07.7 SAY TRANSFORM(nK      , "99,999,999.99" )  RIGHT
         UTILPRN ::oUtil Self:nLinea,10.0 SAY TRANSFORM(aRes[02],"(99,999,999.99)" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,12.1 SAY TRANSFORM(aRes[04],"(99,999,999)" )    RIGHT
         nK := aRes[1] + aRes[2] + aRes[3] + aRes[4]
         If nFormaP == 3 .AND. aRes[8] < nK     // Tarj. Credito
            ::aTG[2] -= aRes[1]
            UTILPRN ::oUtil Self:nLinea,04.0 SAY "P"
         ElseIf nFormaP >= 2
             If nFormaP == 4 .AND. aRes[10]
                ::aTG[7] += aRes[1]
                UTILPRN ::oUtil Self:nLinea,02.1 SAY "A"
             EndIf
            UTILPRN ::oUtil Self:nLinea,14.2 SAY TRANSFORM(aRes[11],"(99,999,999)"  ) RIGHT
            UTILPRN ::oUtil Self:nLinea,16.0 SAY TRANSFORM(aRes[12],"(99,999,999)"  ) RIGHT
         EndIf
         UTILPRN ::oUtil Self:nLinea,18.0 SAY TRANSFORM(aRes[13],"(99,999,999)"  )    RIGHT
         UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM(aRes[01], "99,999,999.99"  )  RIGHT
         If aRes[9] == 2 .OR. aRes[9] == 3
            If (nK := ASCAN( ::aPG, {|aVal| aVal[1] == aRes[5] } )) == 0
               AADD( ::aPG, { aRes[5],0,0,0,0,0 } )
                nK := LEN( ::aPG )
            EndIf
            ::aPG[nK,2] += (aRes[01] + aRes[02] + aRes[04] +aRes[11] + aRes[12])
            ::aPG[nK,3] +=  aRes[02]
            ::aPG[nK,4] +=  aRes[04]
            ::aPG[nK,5] +=  aRes[11]
            ::aPG[nK,6] +=  aRes[12]
         EndIf
      EndIf
      ::aTG[18] +=  aRes[1]
      ::aTG[12] += (aRes[2] + aRes[3])
      ::aTG[13] +=  aRes[4]
      ::aTG[14] +=  aRes[11]
      ::aTG[15] +=  aRes[12]
      ::aTG[16] +=  aRes[13]
      ::aTG[19] +=  aRes[15]
   EndIf
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {|xV,nP| aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. nFormaP # aRes[9]
      ::Cabecera( .t.,0.45 )
      UTILPRN ::oUtil SELECT ::aFnt[6]
      If nFormaP == 0
         ::nLinea += 0.5
         UTILPRN ::oUtil Self:nLinea,01.5 SAY "EFECTIVO        :"
      Else
         UTILPRN ::oUtil Self:nLinea,01.5 SAY "TOTAL " + ::aTG[nFormaP+7]
      EndIf
         ::aTG[18] -= ::aTG[7]
         UTILPRN ::oUtil Self:nLinea,09.9 SAY TRANSFORM(::aTG[12],"@Z 99,999,999.99" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,12.0 SAY TRANSFORM(::aTG[13],"@Z 99,999,999" )    RIGHT
         UTILPRN ::oUtil Self:nLinea,14.1 SAY TRANSFORM(::aTG[14],"@Z 99,999,999" )    RIGHT
         UTILPRN ::oUtil Self:nLinea,15.9 SAY TRANSFORM(::aTG[15],"@Z 99,999,999" )    RIGHT
         UTILPRN ::oUtil Self:nLinea,17.9 SAY TRANSFORM(::aTG[16],"@Z 99,999,999" )    RIGHT
         UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM(::aTG[18],   "99,999,999.99" ) RIGHT
      If nFormaP == 4
         ::nLinea += 0.5
         UTILPRN ::oUtil Self:nLinea,04.8 SAY "( N.C. )"
         UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM(::aTG[07],   "99,999,999.99" ) RIGHT
         ::aTG[18] += ::aTG[7]
      EndIf
      UTILPRN ::oUtil SELECT ::aFnt[5]

      nFormaP := aRes[9]
      If ::nL > 0
         ::Cabecera( .t.,1 )
         UTILPRN ::oUtil Self:nLinea,00.6 SAY ::aTG[nFormaP+7]
         If !EMPTY( cQry )
            ::nLinea += 0.5
            UTILPRN ::oUtil Self:nLinea,02.2 SAY cQry
            cQry := ""
         EndIf
      EndIf
      ::aTG[1] += ::aTG[18]
      ::aTG[2] += ::aTG[12]
      ::aTG[3] += ::aTG[13]
      ::aTG[4] += ::aTG[14]
      ::aTG[5] += ::aTG[15]
      ::aTG[6] += ::aTG[16]
      ::aTG[12]:= ::aTG[13] := ::aTG[14] := ::aTG[15] := ::aTG[16] := ::aTG[18] := 0
   EndIf
EndDo
MSFreeResult( ::hRes )
cQry := "SELECT MIN(rcaja), MAX(rcaja) FROM cadrcaja " +;
        "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))  +;
         " AND fecha  = " + xValToChar( ::aLS[1] )
cQry := Buscar( cQry,"CM",,8 )
If LEN( cQry ) == 0
   aRes := ""
Else
   aRes := "TC 14 DOC." + LTRIM(STR(cQry[1])) +;
           If( cQry[2] > cQry[1], "-"+LTRIM(STR(cQry[2])), "" )
EndIf
 ::aTG[1] -= ::aTG[7]
 ::aTG[8] := ::aTG[1] + ::aTG[2] + ::aTG[3] + ::aTG[4] + ::aTG[5] + ::aTG[6]
 ::aTG[9] := 0
   nK     := LEN( ::aPG ) / 2
 ::nL     := If( nK > 0, 6.5, 6 )
 ::Cabecera( .t.,0.5,::nL + nK )
If nK > 0
   ASORT( ::aPG,,, { |x,y| x[1] < y[1] } )
      ::nLinea += 0.5
      UTILPRN ::oUtil Self:nLinea,00.6 SAY "RESUMEN TARJETAS"
   FOR nK := 1 TO LEN( ::aPG )
      ::aTG[9] += (::aPG[nK,3] + ::aPG[nK,4] +::aPG[nK,5] + ::aPG[nK,6])
      UTILPRN ::oUtil Self:nLinea,03.9 SAY ::aPG[nK,1]
      UTILPRN ::oUtil Self:nLinea,09.9 SAY TRANSFORM(::aPG[nK,2],   "99,999,999.99" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,12.0 SAY TRANSFORM(::aPG[nK,3],"@Z 99,999,999.99" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,14.1 SAY TRANSFORM(::aPG[nK,4],"@Z 99,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,15.9 SAY TRANSFORM(::aPG[nK,5],"@Z 99,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,17.9 SAY TRANSFORM(::aPG[nK,6],"@Z 99,999,999" )    RIGHT
      ::nLinea += 0.5
   NEXT nK
EndIf
 ::aTG[10] := ::aTG[8] + ::aTG[7] + ::aTG[9] + ::aTG[17]
 ::nLinea += 0.5
UTILPRN ::oUtil SELECT ::aFnt[6]
UTILPRN ::oUtil Self:nLinea,01.7 SAY "INGRESOS NETOS  :"
UTILPRN ::oUtil Self:nLinea,09.9 SAY TRANSFORM( ::aTG[01],   "99,999,999.99" ) RIGHT
 ::nLinea += 0.5
UTILPRN ::oUtil Self:nLinea,01.7 SAY "TOTAL DEDUCCION :"
UTILPRN ::oUtil Self:nLinea,09.9 SAY TRANSFORM( ::aTG[02],   "99,999,999.99" ) RIGHT
 ::nLinea += 0.5
UTILPRN ::oUtil Self:nLinea,01.7 SAY "TOTAL RETENCION :"
UTILPRN ::oUtil Self:nLinea,09.9 SAY TRANSFORM( ::aTG[03],   "99,999,999.99" ) RIGHT
 ::nLinea += 0.5
UTILPRN ::oUtil Self:nLinea,01.7 SAY "TOTAL RETEN.IVA :"
UTILPRN ::oUtil Self:nLinea,09.9 SAY TRANSFORM( ::aTG[04],   "99,999,999.99" ) RIGHT
 ::nLinea += 0.5
UTILPRN ::oUtil Self:nLinea,01.7 SAY "TOTAL RETEN.ICA :"
UTILPRN ::oUtil Self:nLinea,09.9 SAY TRANSFORM( ::aTG[05],   "99,999,999.99" ) RIGHT
 ::nLinea += 0.5
UTILPRN ::oUtil Self:nLinea,01.7 SAY "TOTAL RETE.CREE :"
UTILPRN ::oUtil Self:nLinea,09.9 SAY TRANSFORM( ::aTG[06],   "99,999,999.99" ) RIGHT
 ::nLinea += 0.5
UTILPRN ::oUtil Self:nLinea,09.9 SAY "============="                           RIGHT
 ::nLinea += 0.5
UTILPRN ::oUtil Self:nLinea,01.7 SAY "TOTAL ING.BRUTOS:"
UTILPRN ::oUtil Self:nLinea,09.9 SAY TRANSFORM( ::aTG[08],   "99,999,999.99" ) RIGHT
 ::nLinea += 0.5
UTILPRN ::oUtil Self:nLinea,01.7 SAY "OTROS PAGOS(ant):"
UTILPRN ::oUtil Self:nLinea,09.9 SAY TRANSFORM( ::aTG[07],   "99,999,999.99" ) RIGHT
UTILPRN ::oUtil Self:nLinea,12.0 SAY TRANSFORM( ::aTG[17],"@Z 99,999,999.99" ) RIGHT
 ::nLinea += 0.5
UTILPRN ::oUtil Self:nLinea,01.7 SAY "DSCTO. TARJETAS :"
UTILPRN ::oUtil Self:nLinea,09.9 SAY TRANSFORM( ::aTG[09],   "99,999,999.99" ) RIGHT
 ::nLinea += 0.5
UTILPRN ::oUtil Self:nLinea,01.7 SAY "APROVECHAMIENTO :"
UTILPRN ::oUtil Self:nLinea,09.9 SAY TRANSFORM( ::aTG[19],   "99,999,999.99" ) RIGHT
 ::nLinea += 0.5
UTILPRN ::oUtil Self:nLinea,01.7 SAY "MOVTO. CONTABLE :"
UTILPRN ::oUtil Self:nLinea,09.9 SAY TRANSFORM( ::aTG[10],   "99,999,999.99" ) RIGHT
UTILPRN ::oUtil Self:nLinea,15.0 SAY aRes
RETURN NIL

//--------Notas Creditos--------------//
METHOD NotacDOS() CLASS VDiarias
   LOCAL aRes, oRpt
/*
aRes := "SELECT p.numfac, c.cliente, p.numcheque, p.pagado "+;
        "FROM cadpagos p, cadfactu c "                 +;
        "WHERE p.optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND p.fecpag = " + xValToChar( aLS[1] )     +;
         " AND p.tipo   = "+ xValToChar(oApl:Tipo)     +;
         " AND p.formapago = 7 AND p.pordonde = 'N'"   +;
         " AND c.optica = p.optica"                    +;
         " AND c.numfac = p.numfac"                    +;
         " AND c.tipo   = p.tipo"                      +;
         " ORDER BY p.numcheque, p.numfac"
::hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
::nL   := MSNumRows( ::hRes )
::aTG  := { ::nL,0 }
If ::aTG[1] > 0
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,{"PAGOS POR NOTA CREDITO",NtChr( aLS[1],"3" ),;
            " # FACTURA NOMBRE DEL CLIENTE             NOTA CREDITO   V A L O R"},aLS[5] )
   While ::nL > 0
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( ::hRes,nP ) } )
      oRpt:Titulo( 70 )
      oRpt:Say( oRpt:nL, 00,STR(aRes[1],10) )
      oRpt:Say( oRpt:nL, 11,aRes[2] )
      oRpt:Say( oRpt:nL, 44,aRes[3] )
      oRpt:Say( oRpt:nL, 56,TRANSFORM(aRes[4],"99,999,999" ))
      oRpt:nL++
      ::aTG[2] += aRes[4]
      ::nL --
   EndDo
   MSFreeResult( ::hRes )
   oRpt:Separator( 0,2,70 )
   oRpt:Say(++oRpt:nL, 01,STR( ::aTG[1],3 ) + " FACTURAS" )
   oRpt:Say(  oRpt:nL, 55,TRANSFORM(::aTG[2],"999,999,999" ))
   oRpt:NewPage()
   oRpt:End()
EndIf

aRes := "SELECT nroiden, concepto, numero, clase, numfac, devol "+;
        "FROM cadnotac "                             +;
        "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND fecha  = " + xValToChar( aLS[1] )     +;
         " AND anulap <= 2 AND devol > 0"            +;
         " ORDER BY numero"
::hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) == 0
   MSFreeResult( ::hRes )
   RETURN
EndIf
::aTG  := { ::nL,0 }
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"DEVOLUCION DE DINERO POR NOTA CREDITO",NtChr( aLS[1],"3" ),;
          "DOC. IDENTIDAD  NOMBRE DEL CLIENTE                       N.CREDITO  # FACTURA   V A L O R"},aLS[5],1,2 )
While ::nL > 0
   aRes := MyReadRow( ::hRes )
   AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   oRpt:Titulo( 90 )
   oRpt:Say( oRpt:nL, 00,aRes[1] )
   oRpt:Say( oRpt:nL, 16,aRes[2] )
   oRpt:Say( oRpt:nL, 58,STR(aRes[3],8) )
   oRpt:Say( oRpt:nL, 67,If( aRes[4] == 5, "A.", "F." ) + STR(aRes[5],8) )
   oRpt:Say( oRpt:nL, 79,TRANSFORM(aRes[6],"999,999,999" ))
   oRpt:nL++
   ::aTG[2] += aRes[6]
   ::nL --
EndDo
MSFreeResult( ::hRes )
oRpt:Separator( 0,2,90 )
oRpt:Say(++oRpt:nL, 01,STR( ::aTG[1],3 ) + " NOTA CREDITO" )
oRpt:Say(  oRpt:nL, 79,TRANSFORM(::aTG[2],"999,999,999" ))
oRpt:NewPage()
oRpt:End()
*/
aRes  := ::ArmarINF( "Notasc" )
If ::nL == 0
   MSFreeResult( ::hRes )
   RETURN NIL
EndIf
 ::aTG := { 0,0,0,0,0,0 }
oRpt  := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4],::aEnc[5],;
          SPACE(74) + "V A L O R    DIFERIDOS   DEVOLUCION    V A L O R" ,;
          "N.CREDITO  # FACTURA   DOC. IDENTIDAD   NOMBRE DEL CLIENTE   "+;
          "               CARTERA    B O N O S    DE DINERO     DIVERSOS"},::aLS[5],1,2 )
While ::nL > 0
   If aRes[7]  > 0
      aRes[3] := aRes[4]
      aRes[6] := Buscar( {"optica",oApl:nEmpresa,"numfac",aRes[3]},;
                         "cadfactu","cliente",8 )
   EndIf
   oRpt:Titulo( 122 )
   If ::aTG[1]  # aRes[1]
      ::aTG[1] := aRes[1]
      ::aTG[2] ++
      oRpt:Say( oRpt:nL, 00,STR(aRes[1],8) )
   EndIf
   oRpt:Say( oRpt:nL, 10,If( aRes[2] == 5, "A.", "F." ) + STR(aRes[3],8) )
   oRpt:Say( oRpt:nL, 23,aRes[5] )
   oRpt:Say( oRpt:nL, 40,aRes[6] )
   oRpt:Say( oRpt:nL, 72,TRANSFORM(aRes[7],"@Z 999,999,999" ))
   oRpt:Say( oRpt:nL, 85,TRANSFORM(aRes[8],"@Z 999,999,999" ))
   If aRes[10] <= 2
      oRpt:Say( oRpt:nL, 98,TRANSFORM(aRes[9],"@Z 999,999,999" ))
      ::aTG[5] += aRes[9]
   Else
      oRpt:Say( oRpt:nL,111,TRANSFORM(aRes[9],"@Z 999,999,999" ))
      ::aTG[6] += aRes[9]
   EndIf
   oRpt:nL++
   ::aTG[3] += aRes[7]
   ::aTG[4] += aRes[8]
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {|xV,nP| aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
EndDo
MSFreeResult( ::hRes )
oRpt:Separator( 0,2,122 )
oRpt:Say(++oRpt:nL, 05,STR( ::aTG[2],3 ) + " NOTA CREDITO" )
oRpt:Say(  oRpt:nL, 72,TRANSFORM(::aTG[3],"999,999,999" ))
oRpt:Say(  oRpt:nL, 85,TRANSFORM(::aTG[4],"999,999,999" ))
oRpt:Say(  oRpt:nL, 98,TRANSFORM(::aTG[5],"999,999,999" ))
oRpt:Say(  oRpt:nL,111,TRANSFORM(::aTG[6],"999,999,999" ))
oRpt:NewPage()
oRpt:End()
RETURN NIL

//--------Notas Creditos--------------//
METHOD NotacWIN() CLASS VDiarias
   LOCAL aRes := ::ArmarINF( "Notasc" )
If ::nL == 0
   MSFreeResult( ::hRes )
   RETURN NIL
EndIf
 ::aTG  := { 0,0,0,0,0,0 }
 ::aEnc[1] := ::Separator( ::nEndLine )
 ::nPage:= 1
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit                 ,;
             "LISTADO DE NOTAS CREDITO" , NtChr( ::aLS[1],"3" ),;
             { .F., 0.5,"N.CREDITO" }   , { .F., 2.3,"# FACTURA" },;
             { .F., 4.0,"DOC. IDENTIDAD" }                        ,;
             { .F., 6.5,"NOMBRE DEL CLIENTE" }                    ,;
             { .T.,12.8,"CARTERA" }     , { .T.,15.2,"DIFERIDO/BONOS" },;
             { .T.,17.9,"DEVOL.DINERO" }, { .T.,20.8,"VALOR DIVERSOS" } }
UTILPRN ::oUtil SELECT ::aFnt[5]
While ::nL > 0
   If aRes[7]  > 0
      aRes[3] := aRes[4]
      aRes[6] := Buscar( {"optica",oApl:nEmpresa,"numfac",aRes[3]},;
                         "cadfactu","cliente",8 )
   EndIf
   ::Cabecera( .t.,0.45 )
   If ::aTG[1]  # aRes[1]
      ::aTG[1] := aRes[1]
      ::aTG[2] ++
      UTILPRN ::oUtil Self:nLinea,02.0 SAY STR(aRes[1],8) RIGHT
   EndIf
      UTILPRN ::oUtil Self:nLinea,02.3 SAY If( aRes[2] == 5, "A.", "F." )
      UTILPRN ::oUtil Self:nLinea,03.8 SAY STR(aRes[3],8) RIGHT
      UTILPRN ::oUtil Self:nLinea,04.0 SAY aRes[5]
      UTILPRN ::oUtil Self:nLinea,06.5 SAY aRes[6]
      UTILPRN ::oUtil Self:nLinea,12.8 SAY TRANSFORM(aRes[7],"@Z 999,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,15.2 SAY TRANSFORM(aRes[8],"@Z 999,999,999" ) RIGHT
   If aRes[10] <= 2
      UTILPRN ::oUtil Self:nLinea,17.9 SAY TRANSFORM(aRes[9],"@Z 999,999,999" ) RIGHT
      ::aTG[5] += aRes[9]
   Else
      UTILPRN ::oUtil Self:nLinea,20.8 SAY TRANSFORM(aRes[9],"@Z 999,999,999" ) RIGHT
      ::aTG[6] += aRes[9]
   EndIf
   ::aTG[3] += aRes[7]
   ::aTG[4] += aRes[8]
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {|xV,nP| aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
EndDo
MSFreeResult( ::hRes )
 ::Cabecera( .t.,0.4,0.9,21 )
 UTILPRN ::oUtil Self:nLinea,02.0 SAY STR( ::aTG[2],3 ) + " NOTA CREDITO"
 UTILPRN ::oUtil Self:nLinea,12.8 SAY TRANSFORM(::aTG[3],"999,999,999" ) RIGHT
 UTILPRN ::oUtil Self:nLinea,15.2 SAY TRANSFORM(::aTG[4],"999,999,999" ) RIGHT
 UTILPRN ::oUtil Self:nLinea,17.9 SAY TRANSFORM(::aTG[5],"999,999,999" ) RIGHT
 UTILPRN ::oUtil Self:nLinea,20.8 SAY TRANSFORM(::aTG[6],"999,999,999" ) RIGHT
RETURN NIL