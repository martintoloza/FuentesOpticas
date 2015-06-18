// Programa.: HISLIPAC.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Lista de Consultas por Fecha.
#include "Fivewin.ch"
#include "btnget.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE HisLiest()
   LOCAL oDlg, oLF, oGet := ARRAY(7)
oLF := TRcita()
DEFINE DIALOG oDlg TITLE "Recordar Proximo Control" FROM 0, 0 TO 10,50
   @ 02,00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02,92 GET oGet[1] VAR oLF:aLS[1] OF oDlg SIZE 40,10 PIXEL
   @ 14,00 SAY "FECHA   FINAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 14,92 GET oGet[2] VAR oLF:aLS[2] OF oDlg SIZE 40,10 PIXEL ;
      VALID oLF:aLS[2] >= oLF:aLS[1]
   @ 26,00 SAY            "RECORDAR PARA" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 26,92 COMBOBOX oGet[3] VAR oLF:aLS[3] ITEMS { "R.X.","L.CONTACTO" };
      SIZE 40,90 OF oDlg PIXEL
   @ 38,00 SAY "TIPO DE IMPRESORA"   OF oDlg RIGHT PIXEL SIZE 90,10
   @ 38,92 COMBOBOX oGet[4] VAR oLF:aLS[4] ITEMS { "Matriz","Laser" };
      SIZE 40,90 OF oDlg PIXEL
   @ 38,148 CHECKBOX oGet[5] VAR oLF:aLS[5] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 60, 50 BUTTON oGet[6] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ;
      ACTION ( oGet[6]:Disable(), oLF:ListoCTL(), oDlg:End() ) PIXEL
   @ 60,100 BUTTON oGet[7] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 66, 02 SAY "[HISLIPAC]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
PROCEDURE HisLiPac()
   LOCAL oDlg, oLF, oMu, oGet := ARRAY(11)
oLF := TRcita()
oMu := TRip() ; oMu:New(,,8)
oLF:aLS := { 1,"AÑOS",CTOD("01.01.1990"),oApl:oEmp:RESHABIT,10,80,oApl:nTFor,.f.,"" }

DEFINE DIALOG oDlg TITLE "Ultima Cita Paciente" FROM 0, 0 TO 14,54
   @ 02,00 SAY "PACIENTES CON MAS DE" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02,92 GET oGet[1] VAR oLF:aLS[1] OF oDlg PICTURE "999" SIZE 20,10 PIXEL
   @ 14,00 SAY            "TIEMPO EN" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 14,92 COMBOBOX oGet[2] VAR oLF:aLS[2] ITEMS { "AÑOS","MESES","DIAS" };
      SIZE 40,90 OF oDlg PIXEL
   @ 26,00 SAY       "DESDE LA FECHA" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 26,92 GET oGet[3] VAR oLF:aLS[3] OF oDlg SIZE 40,10 PIXEL
   @ 38,00 SAY  "RESIDENCIA HABITUAL" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 38,92 BTNGET oGet[4] VAR oLF:aLS[4] OF oDlg PICTURE "99999"   ;
      VALID EVAL( {|| If( EMPTY( oLF:aLS[4] ), .t.                ,;
                     (If( oMu:oDb:Seek( {"codigo",oLF:aLS[4]} )   ,;
                        ( oGet[9]:Settext( oMu:oDb:NOMBRE), .t. ) ,;
                  (MsgStop("Este Municipio no Existe"), .f.)))) } );
      SIZE 34,10 PIXEL  RESOURCE "BUSCAR"                          ;
      ACTION EVAL({|| If(oMu:Mostrar(), (oLF:aLS[4] := oMu:oDb:CODIGO,;
                        oGet[4]:Refresh(), oGet[4]:lValid(.f.)),)})
   @ 38,128 SAY oGet[9] VAR oLF:aLS[9] OF oDlg PIXEL SIZE 76,24 ;
      UPDATE COLOR nRGB( 160,19,132 )
   @ 50,00 SAY    "CON EDAD MAYOR DE" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 50,92 GET oGet[5] VAR oLF:aLS[5] OF oDlg PICTURE "999" SIZE 20,10 PIXEL
   @ 62,00 SAY    "CON EDAD MENOR DE" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 62,92 GET oGet[6] VAR oLF:aLS[6] OF oDlg PICTURE "999" SIZE 20,10 PIXEL
   @ 74,00 SAY "TIPO DE IMPRESORA"   OF oDlg RIGHT PIXEL SIZE 90,10
   @ 74,92 COMBOBOX oGet[7] VAR oLF:aLS[7] ITEMS { "Matriz","Laser" };
      SIZE 40,90 OF oDlg PIXEL
   @ 74,140 CHECKBOX oGet[8] VAR oLF:aLS[8] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 88, 50 BUTTON oGet[10] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[10]:Disable(), oLF:ListoMOV(), oDlg:End() ) PIXEL
   @ 88,100 BUTTON oGet[11] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 94, 02 SAY "[HISLIPAC]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
CLASS TRcita FROM TIMPRIME

 DATA aLS  AS ARRAY INIT { DATE(),DATE()+3,1,oApl:nTFor,.t.,0,.t. }

 METHOD ListoCTL()
 METHOD LaserCTL( hRes,nL )
 METHOD ListoMOV()
 METHOD LaserMOV( hRes,nL )
ENDCLASS

//------------------------------------//
METHOD ListoCTL() CLASS TRcita
   LOCAL aRes, cQry, nL, hRes, oRpt
/*
SELECT CONCAT(n.nombres, ' ', n.apellidos) PAC, c.nro_histor,
        c.control, c.fecha, c.fchproxcon
FROM historia n, historic a, hiscntrl c
WHERE n.codigo_nit  = a.codigo_nit
  AND c.nro_histor  = a.nro_histor
  AND c.fchproxcon >= '2003-08-01'
  AND c.control     = (SELECT d.control FROM hisdiagn d
                       WHERE d.optica     = c.optica
                         AND d.nro_histor = c.nro_histor
                         AND d.control    = c.control
                         AND d.tipodgn    = 'R'
                       GROUP BY d.control HAVING COUNT(*)>1)
ORDER BY PAC

SELECT c1.nro_histor, c1.control, c1.fecha, c1.fchproxcon
FROM hiscntrl c1
WHERE c1.fchproxcon >= '2003-08-01'
  AND NOT EXISTS (SELECT 1 FROM hiscntrl c2, hisdiagn d
                  WHERE c2.nro_histor = c1.nro_histor
                    AND c2.control   >= c1.control+1
                    AND d.optica      = c2.optica
                    AND d.nro_histor  = c2.nro_histor
                    AND d.control     = c2.control
                    AND d.tipodgn     = 'R')
*/
aRes := { "R","C" }[::aLS[3]] + "')"
cQry := "SELECT CONCAT(n.nombres, ' ', n.apellidos) PAC, n.direccion "+;
                ", n.tel_reside, n.tel_oficin, c.fecha, c.fchproxcon "+;
        "FROM historia n, historic a, hiscntrl c "     +;
        "WHERE n.codigo_nit  = a.codigo_nit"           +;
         " AND c.nro_histor  = a.nro_histor"           +;
         " AND c.fchproxcon >= " + xValToChar(::aLS[1])+;
         " AND c.fchproxcon <= " + xValToChar(::aLS[2])+;
         " AND     EXISTS (SELECT 1 FROM hisdiagn d "+;
                          "WHERE d.optica     = c.optica"         +;
                           " AND d.nro_histor = c.nro_histor"     +;
                           " AND d.control    = c.control"        +;
                           " AND d.tipodgn    = '" + aRes         +;
         " AND NOT EXISTS (SELECT 1 FROM hiscntrl c2, hisdiagn d "+;
                          "WHERE c2.nro_histor =  c.nro_histor"   +;
                           " AND c2.control   >=  c.control+1"    +;
                           " AND d.optica      = c2.optica"       +;
                           " AND d.nro_histor  = c2.nro_histor"   +;
                           " AND d.control     = c2.control"      +;
                           " AND d.tipodgn     = '" + aRes        +;
        " ORDER BY PAC"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[4] == 2
   ::LaserCTL( hRes,nL )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"RECORDAR PROXIMO CONTROL PARA "   +;
         { "R.X.","L.CONTACTO" }[::aLS[3]], NtChr( DATE(),"6" )           ,;
         "    P A C I E N T E                               ULTIMA CITA"+;
         "  PROXIMO CONTROL"},::aLS[5] )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   oRpt:Titulo( 79 )
   oRpt:Say(  oRpt:nL,00,"Sr(a). " + aRes[1] )
   oRpt:Say(  oRpt:nL,50,NtChr( aRes[5],"2" ) )
   oRpt:Say(  oRpt:nL,64,NtChr( aRes[6],"2" ) )
   oRpt:Say(++oRpt:nL,02,aRes[2] )  //40
   oRpt:Say(  oRpt:nL,44,"T.C " + aRes[3] +;
                         " T.O " + aRes[4] )
   oRpt:nL ++
   nL --
EndDo
   MSFreeResult( hRes )
   oRpt:NewPage()
   oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserCTL( hRes,nL ) CLASS TRcita
   LOCAL aRes
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit                    ,;
             "RECORDAR PROXIMO CONTROL PARA "                     +;
             { "R.X.","L.CONTACTO" }[::aLS[3]],NtChr( DATE(),"6" ),;
             { .F., 1.2,"P A C I E N T E" }, { .F.,12.0,"ULTIMA CITA" },;
             { .F.,15.0,"PROXIMO CONTROL" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[5] ,,, ::aLS[5] )
 ::nMD := 18.5
  PAGE
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   ::Cabecera( .t.,0.42,0.84 )
   UTILPRN ::oUtil Self:nLinea, 0.9 SAY "Sr(a). " + aRes[1]
   UTILPRN ::oUtil Self:nLinea,12.0 SAY NtChr( aRes[5],"2" )
   UTILPRN ::oUtil Self:nLinea,15.0 SAY NtChr( aRes[6],"2" )
   ::nLinea += 0.42
   UTILPRN ::oUtil Self:nLinea, 1.2 SAY aRes[2]
   UTILPRN ::oUtil Self:nLinea,10.3 SAY "T.C " + aRes[3]
   UTILPRN ::oUtil Self:nLinea,14.5 SAY "T.O " + aRes[4]
   nL --
EndDo
   MSFreeResult( hRes )
  ENDPAGE
 ::EndInit( .F. )
RETURN NIL

//------------------------------------//
METHOD ListoMOV() CLASS TRcita
   LOCAL aRes := "", aRX, cQry, nL, hRes, oRpt
If !EMPTY( ::aLS[4] )
   aRes := " AND n.reshabit = " + xValToChar(::aLS[4])
   ::aLS[9] := oApl:oHab:NOMBRE
EndIf
MSQuery( oApl:oMySql:hConnect,"DROP TABLE fechahis" )
cQry := "CREATE TEMPORARY TABLE fechahis ( " +;
            "nro_histor INT(8) NOT NULL, "   +;
            "fecha      DATE   NOT NULL )"   +;
        " ENGINE=MEMORY"
MSQuery( oApl:oMySql:hConnect,cQry )

// Introducimos datos en el cursor
cQry := "INSERT INTO fechahis (nro_histor, fecha) "   +;
        "SELECT nro_histor, MAX(fecha) FROM hiscntrl "+;
        "WHERE fecha >= " + xValToChar( ::aLS[3] )    +;
        " GROUP BY nro_histor"
MSQuery( oApl:oMySql:hConnect,cQry )

cQry := "SELECT CONCAT(n.nombres, ' ', n.apellidos) PAC, c.nro_histor, c.fecha, "+;
          "n.fec_nacimi, n.edad, n.direccion, n.tel_reside, n.reshabit, n.email "+;
        "FROM historia n, fechahis c LEFT JOIN historic a "+;
         "USING( nro_histor ) "             +;
        "WHERE a.codigo_nit = n.codigo_nit" + aRes         +;
        " ORDER BY PAC"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[7] == 2
   ::LaserMOV( hRes,nL )
   RETURN NIL
EndIf

oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"PACIENTES CON MAS DE"+;
         STR(::aLS[1]) + " " + ::aLS[2], NtChr( DATE(),"6" ),;
         "    P A C I E N T E                            No.HISTORIA  ULTI"+;
         "MA CITA    EDAD"},::aLS[8] )
aRX := { ::aLS[1] * { 365,30,1 }[AT( LEFT(::aLS[2],1),"AMD" )],0,0 }
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[5] := If( EMPTY( aRes[4]), aRes[5], NtChr( aRes[4],"A" ) )
    aRX[2] := DATE() - aRes[3]
   If aRX[2] >= aRX[1] .AND.;
      Rango( aRes[5],::aLS[5],::aLS[6] )
      If aRes[8] # ::aLS[4]
         cQry := Buscar( {"codigo",aRes[8]},"ciudades","nombre" )
      Else
         cQry := ::aLS[9]
      EndIf
      oRpt:Titulo( 80 )
      oRpt:Say(  oRpt:nL,02,"Sr(a). " + aRes[1] )
      oRpt:Say(  oRpt:nL,50,aRes[2] )
      oRpt:Say(  oRpt:nL,60,NtChr( aRes[3],"2" ) + STR(aRes[5],8) )
      oRpt:Say(++oRpt:nL,10,aRes[6] )            //40
      oRpt:Say(  oRpt:nL,50,"T.C. " + aRes[7])   //15
      oRpt:Say(++oRpt:nL,10,cQry )               //30
      oRpt:Say(  oRpt:nL,50,aRes[9] )
      oRpt:nL ++
      aRX[3] ++
   EndIf
   nL --
EndDo
   MSFreeResult( hRes )
   oRpt:Say(  oRpt:nL,00,REPLICATE("_",80) )
   oRpt:Say(++oRpt:nL,01,"TOTAL DE PACIENTES ======>" )
   oRpt:Say(  oRpt:nL,73,TRANSFORM( aRX[3],"999,999" ) )
   oRpt:NewPage()
   oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserMOV( hRes,nL ) CLASS TRcita
   LOCAL aRes, aRX
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit      ,;
             "PACIENTES CON MAS DE" + STR(::aLS[1]) +;
             " " + ::aLS[2], NtChr( DATE(),"6" )    ,;
             { .F., 1.2,"P A C I E N T E" }, { .F.,14.8,"No.HISTORIA" },;
             { .F.,17.2,"ULTIMA CITA" }    , { .T.,20.5,"EDAD" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[8] ,,, ::aLS[8] )
 ::nMD := 20.5
  PAGE
aRX := { ::aLS[1] * { 365,30,1 }[AT( LEFT(::aLS[2],1),"AMD" )],0,0,"" }
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[5] := If( EMPTY( aRes[4]), aRes[5], NtChr( aRes[4],"A" ) )
    aRX[2] := DATE() - aRes[3]
   If aRX[2] >= aRX[1] .AND.;
      Rango( aRes[5],::aLS[5],::aLS[6] )
      If aRes[8] # ::aLS[4]
          aRX[4] := Buscar( {"codigo",aRes[8]},"ciudades","nombre" )
      Else
          aRX[4] := ::aLS[9]
      EndIf
      ::Cabecera( .t.,0.42,1.26 )
      UTILPRN ::oUtil Self:nLinea, 0.9 SAY "Sr(a). " + aRes[1]
      UTILPRN ::oUtil Self:nLinea,15.2 SAY aRes[2]
      UTILPRN ::oUtil Self:nLinea,17.2 SAY NtChr( aRes[3],"2" )
      UTILPRN ::oUtil Self:nLinea,20.5 SAY STR(aRes[5],5) RIGHT
      ::nLinea += 0.42
      UTILPRN ::oUtil Self:nLinea, 1.9 SAY aRes[6]
      UTILPRN ::oUtil Self:nLinea,13.5 SAY "T.C " + aRes[7]
      ::nLinea += 0.42
      UTILPRN ::oUtil Self:nLinea, 1.9 SAY aRX[4]
      UTILPRN ::oUtil Self:nLinea,13.5 SAY aRes[9]
      aRX[3] ++
   EndIf
   nL --
EndDo
   MSFreeResult( hRes )
      ::Cabecera( .t.,0.45,0.9,20.5 )
      UTILPRN ::oUtil Self:nLinea, 5.0 SAY "TOTAL DE PACIENTES ======>"
      UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM(aRX[3],"999,999") RIGHT
  ENDPAGE
 ::EndInit( .F. )
RETURN NIL