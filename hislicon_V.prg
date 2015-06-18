// Programa.: HISLICON.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Lista Estadistica por Defecto Refractivo
#include "FiveWin.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE HisLiCon( nOpc )
   LOCAL aHC, oDlg, oLF, oGet := ARRAY(7)
   DEFAULT nOpc := 1
oLF := TRefra()
aHC := { { {|| oLF:ListoEDR() },"Resumen por Defecto Refractivo" },;
         { {|| oLF:ListoCon() },"Pacientes con su Refración" } }
DEFINE DIALOG oDlg TITLE aHC[nOpc,2] FROM 0, 0 TO 09,50
   @ 02,00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02,92 GET oGet[1] VAR oLF:aLS[1] OF oDlg SIZE 40,10 PIXEL
   @ 14,00 SAY "FECHA   FINAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 14,92 GET oGet[2] VAR oLF:aLS[2] OF oDlg SIZE 40,10 PIXEL ;
      VALID oLF:aLS[2] >= oLF:aLS[1]
   @ 26,00 SAY          "CLASE DE LENTES" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 26,92 COMBOBOX oGet[3] VAR oLF:aLS[3] ITEMS { "Contacto","Oftalmicos" };
      SIZE 48,90 OF oDlg PIXEL
   @ 38,00 SAY "TIPO DE IMPRESORA"   OF oDlg RIGHT PIXEL SIZE 90,10
   @ 38,92 COMBOBOX oGet[4] VAR oLF:aLS[4] ITEMS { "Matriz","Laser" };
      SIZE 48,90 OF oDlg PIXEL
   @ 38,148 CHECKBOX oGet[5] VAR oLF:aLS[5] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 52, 50 BUTTON oGet[6] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ;
      ACTION ( oGet[6]:Disable(), EVAL( aHC[nOpc,1] ), oDlg:End() ) PIXEL
   @ 52,100 BUTTON oGet[7] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 58, 02 SAY "[HISLICON]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
CLASS TRefra FROM TIMPRIME

 DATA aLS  AS ARRAY INIT { DATE(),DATE(),2,oApl:nTFor,.t.,0,.t. }

 METHOD ListoEDR()
 METHOD Visual( aDp,aDR )
 METHOD Defecto( nEsf,nCyl )
 METHOD Edad( nHis,dFec )
 METHOD ListoCON()
 METHOD ListoWIN( nL,hRes )
ENDCLASS

//------------------------------------//
METHOD ListoEDR() CLASS TRefra
   LOCAL aDR := {}, aRes, aRX, cQry, nL, hRes, oRpt
cQry := "SELECT nombre FROM hisvisua ORDER BY codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AADD( aDR, { aRes[1],0,0,0,0,0,0,0 } )
   nL --
EndDo
 MSFreeResult( hRes )

cQry := "SELECT c.nro_histor, c.fecha, c.control, "        +;
            "d.ladolente, d.esfera, d.cilindro, d.adicion "+;
        "FROM hisdiagn d, hiscntrl c "                     +;
        "WHERE d.tipodgn    = 'R'"                         +;
         " AND c.optica     = d.optica"                    +;
         " AND c.nro_histor = d.nro_histor"                +;
         " AND c.control    = d.control"                   +;
         " AND c.optica     = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fecha     >= " + xValToChar( ::aLS[1] )   +;
         " AND c.fecha     <= " + xValToChar( ::aLS[2] )   +;
         " ORDER BY c.nro_histor, c.fecha, d.ladolente"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
EndIf
 aRes := MyReadRow( hRes )
 AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
  aRX := { 0,0,0,1,0,0,0,1,"",aRes[1],aRes[2] }
While nL > 0
   If UPPER(aRes[4]) == "D"
      aRX[1] := VAL( aRes[5] )
      aRX[2] := VAL( aRes[6] )
      aRX[3] := VAL( aRes[7] )
      If EMPTY( aRes[5]+aRes[6]+aRes[7] )
         aRX[4] --
      EndIf
   Else
      aRX[5] := VAL( aRes[5] )
      aRX[6] := VAL( aRes[6] )
      aRX[7] := VAL( aRes[7] )
      If EMPTY( aRes[5]+aRes[6]+aRes[7] )
         aRX[8] --
      EndIf
   EndIf
      aRX[9] += LEFT( aRes[5],1 )      // ESFERA
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If (nL == 0 .OR. aRX[10] # aRes[1] .OR. aRX[11] # aRes[2])
      If aRX[4] + aRX[8] > 0
         ::Visual( aRX,@aDR )
         ::aLS[6] ++
      EndIf
      aRX := { 0,0,0,1,0,0,0,1,"",aRes[1],aRes[2] }
   EndIf
EndDo
 MSFreeResult( hRes )
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit    ,;
             "ESTADISTICA POR DEFECTO REFRACTIVO","DESDE "        +;
             NtChr(::aLS[1],"2") + " HASTA " + NtChr(::aLS[2],"2"),;
             { .F., 0.9,"D E F E C T O" }, { .T., 6.5,"De  0 a  5" },;
             { .T., 8.5,"De  6 a 10" }   , { .T.,10.5,"De 11 a 20" },;
             { .T.,12.5,"De 21 a 40" }   , { .T.,14.5,"De 41 a 60" },;
             { .T.,16.5,"De 61 a ->" }   , { .T.,18.5,"T O T A L" } }
If ::aLS[4] == 1
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4],::aEnc[5],;
            "D E F E C T O              De  0 a  5  De  6 a 10  De 11 a 20  "+;
            "De 21 a 40  De 41 a 60  De 61 a ->  T O T A L"},::aLS[5],,2 )
   FOR nL := 1 TO LEN( aDR )
      oRpt:Titulo( 108 )
      oRpt:Say( oRpt:nL,00,aDR[nL,1] )
      oRpt:Say( oRpt:nL,30,TRANSFORM(aDR[nL,2],"@Z 999,999") )
      oRpt:Say( oRpt:nL,42,TRANSFORM(aDR[nL,3],"@Z 999,999") )
      oRpt:Say( oRpt:nL,54,TRANSFORM(aDR[nL,4],"@Z 999,999") )
      oRpt:Say( oRpt:nL,66,TRANSFORM(aDR[nL,5],"@Z 999,999") )
      oRpt:Say( oRpt:nL,78,TRANSFORM(aDR[nL,6],"@Z 999,999") )
      oRpt:Say( oRpt:nL,90,TRANSFORM(aDR[nL,7],"@Z 999,999") )
      oRpt:Say( oRpt:nL,99,TRANSFORM(aDR[nL,8], "9,999,999") )
      oRpt:nL ++
   NEXT nL
      oRpt:Say(  oRpt:nL,00,REPLICATE("=",108) )
      oRpt:Say(++oRpt:nL,01,"TOTAL DE PACIENTES ======>" )
      oRpt:Say(  oRpt:nL,30,TRANSFORM( ::aLS[6],"999,999" ) )
      oRpt:NewPage()
      oRpt:End()
Else
   ::Init( ::aEnc[4], .f. ,, !::aLS[5] ,,, ::aLS[5], 5 )
   ::nMD := 18.5
   PAGE
   FOR nL := 1 TO LEN( aDR )
      ::Cabecera( .t.,0.45 )
      UTILPRN ::oUtil Self:nLinea, 0.9 SAY aDR[nL,1]
      UTILPRN ::oUtil Self:nLinea, 6.5 SAY TRANSFORM(aDR[nL,2],"@Z 999,999") RIGHT
      UTILPRN ::oUtil Self:nLinea, 8.5 SAY TRANSFORM(aDR[nL,3],"@Z 999,999") RIGHT
      UTILPRN ::oUtil Self:nLinea,10.5 SAY TRANSFORM(aDR[nL,4],"@Z 999,999") RIGHT
      UTILPRN ::oUtil Self:nLinea,12.5 SAY TRANSFORM(aDR[nL,5],"@Z 999,999") RIGHT
      UTILPRN ::oUtil Self:nLinea,14.5 SAY TRANSFORM(aDR[nL,6],"@Z 999,999") RIGHT
      UTILPRN ::oUtil Self:nLinea,16.5 SAY TRANSFORM(aDR[nL,7],"@Z 999,999") RIGHT
      UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM(aDR[nL,8], "9,999,999") RIGHT
   NEXT nL
      ::Cabecera( .t.,0.45,0.9,18.5 )
      UTILPRN ::oUtil Self:nLinea, 0.9 SAY "TOTAL DE PACIENTES ======>"
      UTILPRN ::oUtil Self:nLinea, 6.5 SAY TRANSFORM(::aLS[6] ,   "999,999") RIGHT
   ENDPAGE
   ::EndInit( .F. )
EndIf
RETURN NIL

//------------------------------------//
METHOD Visual( aDp,aDR ) CLASS TRefra
   LOCAL nE := 6 , nV , nX , lSano
nX := ::Edad( aDp[10],aDp[11] )
nV := nX[2]

do Case
Case nV >=  0 .AND. nV <=  5
   nE := 1
Case nV >=  6 .AND. nV <= 10
   nE := 2
Case nV >= 11 .AND. nV <= 20
   nE := 3
Case nV >= 21 .AND. nV <= 40
   nE := 4
Case nV >= 41 .AND. nV <= 60
   nE := 5
EndCase
nE += 1
FOR nV := 1 TO 8 STEP 4
   If aDp[nV+3] > 0
      If aDp[nV] > 10.25 .AND. aDp[nV+2] > 0
         nX := 9                       // Afacos
      Else
         aDp[nV+2] := If( aDp[nV+2] > 0, 9, 0 )
         nX := aDp[nV+2] + ::Defecto( aDp[nV],aDp[nV+1] )
      EndIf
      aDR[nX,nE] ++
      aDR[nX, 8] ++
   EndIf
NEXT nV
If aDp[4]+aDp[8] == 2
// lSano  := If( aDp[1] # 0 .AND. aDp[5] # 0, .f., .t. )
   lSano  := If( aDp[1] # 0 .OR. aDp[5] # 0, .f., .t. )
   aDp[6] := ABS( aDp[1] ) - ABS( aDp[5] )
   aDp[6] := ABS( aDp[6] )
   If aDp[9] # "++" .AND. aDp[9] # "--"
      nX := 8 + aDp[3]                 // AntiMetropia
      aDR[nX,nE] += 2
      aDR[nX, 8] += 2
   EndIf
   If (aDp[6] >= 5.00 .AND. lSano) .OR. ;
       aDp[6] >= 3.00
      nX := 7 + aDp[3]                 // AnisoMetropia
      aDR[nX,nE] += 2
      aDR[nX, 8] += 2
   EndIf
EndIf

RETURN NIL

//------------------------------------//
METHOD Defecto( nEsf,nCyl ) CLASS TRefra
   LOCAL nD := 6                       // Astigmatico HyperMetrope (+)
do Case
Case nEsf == 0 .AND. nCyl == 0
   nD := 1                             // EMetrope (N)
Case nEsf  < 0 .AND. nCyl == 0
   nD := 2                             // Miope (-)
Case nEsf  > 0 .AND. nCyl == 0
   nD := 3                             // HyperMetrope (+)
Case nEsf == 0 .AND. nCyl  # 0
   nD := 4                             // Astigmatico Simple
Case nEsf  < 0 .AND. nCyl  # 0
   nD := 5                             // Astigmatico Miope (-)
EndCase
RETURN nD

//------------------------------------//
METHOD Edad( nHis,dFec ) CLASS TRefra
   LOCAL aLC, aRes, hRes
aRes := "SELECT h.apellidos, h.nombres, h.edad, h.fec_nacimi "+;
        "FROM historia h, historic c "                        +;
        "WHERE c.codigo_nit = h.codigo_nit"                   +;
         " AND c.nro_histor = " + LTRIM(STR(nHis))
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If MSNumRows( hRes ) > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If !EMPTY( aRes[4] )
      aRes[3] := dFec - aRes[4]
      aRes[3] := ROUND( aRes[3]/365,0 )
   EndIf
   aLC := { XTrim( aRes[1] ) + aRes[2],aRes[3] }
Else
   aLC := { "",0 }
EndIf
   MSFreeResult( hRes )
RETURN aLC

//----Lista de Consultas por Fecha---//
METHOD ListoCON() CLASS TRefra
   LOCAL aLC, aRes, cQry, nL, hRes, oRpt
cQry := "SELECT c.nro_histor, c.fecha, c.control, d.ladolente "+;
             ", d.esfera, d.cilindro, d.adicion, l.nombre "    +;
        "FROM hiscntrl c, hisdiagn d LEFT JOIN hislente l "+;
         "USING( codigo ) "                                +;
        "WHERE d.tipodgn    = '"+ { "C","R" }[ ::aLS[3] ]  +;
        "' AND c.optica     = d.optica"                    +;
         " AND c.nro_histor = d.nro_histor"                +;
         " AND c.control    = d.control"                   +;
         " AND c.optica     = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fecha     >= " + xValToChar( ::aLS[1] )   +;
         " AND c.fecha     <= " + xValToChar( ::aLS[2] )   +;
         " ORDER BY c.fecha, c.nro_histor, d.ladolente"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
EndIf
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit    ,;
             "PACIENTES CON SU FORMULA", "DESDE " +;
             NtChr(::aLS[1],"2") + " HASTA " + NtChr(::aLS[2],"2"),;
             { .F., 0.9,"P A C I E N T E" }, { .F.,13.8,"---FECHA---" },;
             { .F.,16.7,"No.HISTORIA" }    , { .F.,19.6,"EDAD" } }
If ::aLS[4] == 2
   ::ListoWIN( nL,hRes )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4],::aEnc[5],;
         "P A C I E N T E"+SPACE(35)+"---FECHA---  No.HISTORIA  EDAD"},::aLS[5] )
aLC := { 0,0,0 }
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[4] := If( aRes[4] == "A", "A.O.", "O."+aRes[4]+"." )
   aRes[7] := If( EMPTY( aRes[7] ), "", "   Add :"+aRes[7] )
      oRpt:Titulo( 80 )
   If aLC[1]  # aRes[1]
      aLC[1] := aRes[1]
        cQry := ::Edad( aRes[1],aRes[2] )
      oRpt:nL += aLC[2]
      oRpt:Say( oRpt:nL,00,cQry[1] )
      oRpt:Say( oRpt:nL,50,NtChr( aRes[2],"2" ) )
      oRpt:Say( oRpt:nL,65,aLC[1] )
      oRpt:Say( oRpt:nL,77,STR( cQry[2],3 ) )
      oRpt:nL ++
      aLC[2] := 1
      aLC[3] ++
   EndIf
      oRpt:Say( oRpt:nL,10,aRes[4] + aRes[5] + "   " + aRes[6] + aRes[7] )
      oRpt:nL ++
   nL --
EndDo
   MSFreeResult( hRes )
 oRpt:Say(  oRpt:nL,00,REPLICATE("_",80) )
 oRpt:Say(++oRpt:nL,01,"TOTAL DE PACIENTES ======>" )
 oRpt:Say(  oRpt:nL,30,TRANSFORM( aLC[3],"999,999" ) )
 oRpt:NewPage()
 oRpt:End()
RETURN NIL

//------------------------------------//
METHOD ListoWIN( nL,hRes ) CLASS TRefra
   LOCAL aLC := { 0,0,0 }, aRes, cQry
 ::Init( ::aEnc[4], .f. ,, !::aLS[5] ,,, ::aLS[5] )
 PAGE
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[4] := If( aRes[4] == "A", "A.O.", "O."+aRes[4]+"." )
   aRes[7] := If( EMPTY( aRes[7] ), "", "Add :"+aRes[7] )
   If aLC[1]  # aRes[1]
      aLC[1] := aRes[1]
        cQry := ::Edad( aRes[1],aRes[2] )
      ::Cabecera( .t.,0.42+aLC[2] )
      UTILPRN ::oUtil Self:nLinea, 0.9 SAY cQry[1]
      UTILPRN ::oUtil Self:nLinea,13.7 SAY NtChr( aRes[2],"2" )
      UTILPRN ::oUtil Self:nLinea,17.5 SAY STR( aLC[1],8 )
      UTILPRN ::oUtil Self:nLinea,20.0 SAY STR(cQry[2],3 )
      aLC[2] := 0.45
      aLC[3] ++
   EndIf
      ::Cabecera( .t.,0.42 )
      UTILPRN ::oUtil Self:nLinea, 3.2 SAY aRes[4]
      UTILPRN ::oUtil Self:nLinea, 4.0 SAY aRes[5]
      UTILPRN ::oUtil Self:nLinea, 5.5 SAY aRes[6]
      UTILPRN ::oUtil Self:nLinea, 6.8 SAY aRes[7]
   nL --
EndDo
   MSFreeResult( hRes )
      ::Cabecera( .t.,0.5,1,20 )
      UTILPRN ::oUtil Self:nLinea, 0.9 SAY "TOTAL DE PACIENTES ======>"
      UTILPRN ::oUtil Self:nLinea, 7.0 SAY TRANSFORM( aLC[3],   "999,999") RIGHT
 ENDPAGE
 ::EndInit( .F. )
RETURN NIL