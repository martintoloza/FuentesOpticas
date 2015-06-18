// Programa.: HISLISTA.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Lista Certificado de un Paciente.
#include "FiveWin.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE HisLiRXF( nHis,nCtl )
   LOCAL oC, oDlg, oGet := ARRAY(7)
 oC := TCerti() ; oC:New()
DEFINE DIALOG oDlg TITLE "CERTIFICADO" FROM 0, 0 TO 17,50
   @ 02, 00 SAY "FECHA Certificado"   OF oDlg RIGHT PIXEL SIZE 80,10
   @ 02, 82 GET oGet[1] VAR oC:aLS[1] OF oDlg  SIZE 40,10 PIXEL
   @ 14, 00 SAY "TIPO DE IMPRESORA"   OF oDlg RIGHT PIXEL SIZE 80,10
   @ 14, 82 COMBOBOX oGet[2] VAR oC:aLS[2] ITEMS { "Matriz","Laser" };
      SIZE 48,90 OF oDlg PIXEL
   @ 14,140 COMBOBOX oGet[3] VAR oC:aLS[3] ITEMS { "Con Formato","Sin Formato","Consulta" };
      SIZE 48,90 OF oDlg PIXEL
   @ 26, 82 COMBOBOX oGet[4] VAR oC:aLS[4] ITEMS oApl:aDoctor ;
      SIZE 48,90 OF oDlg PIXEL
   @ 38,00 SAY "Observaciones"       OF oDlg RIGHT PIXEL SIZE 80,10
   @ 48,02 GET oGet[5] VAR oC:aLS[5] OF oDlg MEMO ;
      SIZE 190,60 PIXEL HSCROLL
   @ 114, 50 BUTTON oGet[6] PROMPT "Imprimir" SIZE 44,12 OF oDlg ACTION;
      ( oGet[6]:Disable(), oC:New( nHis,nCtl ), oDlg:End() ) PIXEL
   @ 114,100 BUTTON oGet[7] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 118, 02 SAY "[HISLISTA]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED

RETURN

//------------------------------------//
CLASS TCerti FROM TIMPRIME

 DATA aLS, aRX
 METHOD New( nHis,nCtl ) Constructor
 METHOD ListoDOS()
 METHOD ListoWIN()

ENDCLASS

//------------------------------------//
METHOD NEW( nHis,nCtl ) CLASS TCerti
   LOCAL aRX, nL, nO, hRes
If nCtl == NIL
   ::aLS := { DATE(),oApl:nTFor,1,"","" }
   ::aRX := { { "  N  ","","" },{ "  N  ","","" },"","" }
Else
   aRX := "SELECT d.ladolente, d.esfera, d.cilindro, d.eje, d.adicion, d.avl "+;
          "FROM hisdiagn d, hiscntrl c "               +;
          "WHERE d.tipodgn    = 'R'"                   +;
           " AND c.cntrl_id   = d.cntrl_id"            +;
           " AND c.nro_histor = " + LTRIM(STR( nHis )) +;
           " AND c.control    = " + LTRIM(STR( nCtl )) +;
           " ORDER BY d.ladolente LIMIT 2"
   hRes := If( MSQuery( oApl:oMySql:hConnect,aRX )  ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nCtl := nL := MSNumRows( hRes )
   nHis := 0
   While nL > 0
      aRX := MyReadRow( hRes )
      AEVAL( aRX, {| xV,nP | aRX[nP] := MyClReadCol( hRes,nP ) } )
      nO := If( aRX[1] $ "ADd", 1, 2 )
      If LEFT(aRX[2],1) $ "+-"
         ::aRX[nO,1] := aRX[2]
      EndIf
      If !EMPTY(aRX[3])
         ::aRX[nO,1] += " = " + aRX[3]
      EndIf
      If !EMPTY(aRX[4])
         ::aRX[nO,1] += " X " + aRX[4]
      EndIf
         ::aRX[nO,2] := aRX[5]
         ::aRX[nO,3] := "20/" + aRX[6]
      If LEFT(aRX[2],1) $ "+-" .OR.;
       !EMPTY(aRX[3])          .OR.;
       !EMPTY(aRX[5])
         nHis ++
      EndIf
      nL --
   EndDo
   MSFreeResult( hRes )
   If nCtl == 1
      If aRX[1] == "A"
         ::aRX[2,1] := ::aRX[1,1]
         ::aRX[2,2] := ::aRX[1,2]
         ::aRX[2,3] := ::aRX[1,3]
      EndIf
   EndIf
         ::aRX[3] := XTRIM( oApl:oHis:NOMBRES ) + oApl:oHis:APELLIDOS
         ::aRX[4] := If( nHis > 0, "SI", "NO" )
   If ::aLS[2] == 1
      ::ListoDOS()
   Else
      ::ListoWIN()
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD ListoDOS() CLASS TCerti
   LOCAL nL, oRpt, aM := { 25,60,"" }
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,,.t. )
oRpt:nPage := 1
oRpt:SetFont( oRpt:CPINormal,80,2 )

If ::aLS[3] == 1
   oRpt:Say(  7,18,NtChr( ::aLS[1],"5" ) + ", " +;
                   NtChr( ::aLS[1],"3" ) )
   oRpt:Say( 11,15,oRpt:CPIBold + ::aRX[3] )
   oRpt:Say( 13, 8,::aRX[4] )
   oRpt:Say( 15, 6,::aRX[1,1] )
   oRpt:Say( 15,36,::aRX[1,2] )
   oRpt:Say( 15,44,::aRX[1,3] )
   oRpt:Say( 17, 6,::aRX[2,1] )
   oRpt:Say( 17,36,::aRX[2,2] )
   oRpt:Say( 17,44,::aRX[2,3] )
   oRpt:Say( 19,18,"N" )
   oRpt:Say( 21,18,"N" )
   oRpt:Say( 23,18,"N" )
Else
   oRpt:Say(  2,00,oRpt:CPILarge+PADC( oApl:cEmpresa,43 ) )
   oRpt:Say(  5,10,"Fecha :  " + NtChr( ::aLS[1],"5" ) + ", " +;
                                 NtChr( ::aLS[1],"3" ) )
   oRpt:Say(  7,30,"C E R T I F I C A:" )

   oRpt:Say(  9, 1,"Que el pacíente:" )
   oRpt:Say(  9,20,oRpt:CPIBold + ::aRX[3] )
   oRpt:Say( 12, 2,::aRX[4] + " necesita corrección Oftálmica" )
//          " necesita corrección Oftálmica con la siguiente fórmula" )
   oRpt:Say( 14, 2,"O.D. "   + ::aRX[1,1] )
   oRpt:Say( 14,35,"A.D.D. " + ::aRX[1,2] )
   oRpt:Say( 14,50,"A.V. "   + ::aRX[1,3] )
   oRpt:Say( 16, 2,"O.I. "   + ::aRX[2,1] )
   oRpt:Say( 16,35,"A.D.D. " + ::aRX[2,2] )
   oRpt:Say( 16,50,"A.V. "   + ::aRX[2,3] )
   oRpt:Say( 18, 2,"Percepción a los colores  N" )
   oRpt:Say( 20, 2,"Campos visuales  N" )
   oRpt:Say( 22, 2,"Balance muscular  N" )
   oRpt:Say( 24, 2,"Presión intraocular  N" )
   oRpt:Say( 26, 2,"O.D.                  O.I." )
   oRpt:Say( 28, 2,"Observaciones" )
   oRpt:Say( 40,15,"Atentamente," + REPLICATE("_",30) )
   aM[1] := 29
   aM[2] := 78
EndIf
FOR nL := 1 TO  MLCOUNT( ::aLS[5],aM[2] )
   aM[3] := MEMOLINE( ::aLS[5],aM[2],nL )
   oRpt:Say( aM[1],04,aM[3] )
   aM[1] += 2
NEXT nL
oRpt:NewPage()
oRpt:End()

RETURN NIL

//------------------------------------//
METHOD ListoWIN() CLASS TCerti
   LOCAL cLinea, nL
 ::Init( "Certifica "+ ::aRX[3], .f. ,, .f. ,,, .t. )
 ::aEnc := { 13.1,60 }

 DEFINE FONT ::aFnt[2] NAME ::cFont SIZE 0, -20 OF ::oPrn
 DEFINE FONT ::aFnt[3] NAME ::cFont SIZE 0, -12 OF ::oPrn

 UTILPRN ::oUtil SELECT ::aFnt[3]
 PAGE
    If ::aLS[3] == 1
       //Con Formato
       UTILPRN ::oUtil  3.4, 4.8 SAY NtChr( ::aLS[1],"5" ) + ", " +;
                                     NtChr( ::aLS[1],"3" )
       UTILPRN ::oUtil  5.2, 3.8 SAY ::aRX[3] FONT ::aFnt[4]
       UTILPRN ::oUtil  6.0, 2.5 SAY ::aRX[4]
       UTILPRN ::oUtil  6.8, 2.5 SAY ::aRX[1,1]
       UTILPRN ::oUtil  6.8,10.0 SAY ::aRX[1,2]
       UTILPRN ::oUtil  6.8,12.1 SAY ::aRX[1,3]
       UTILPRN ::oUtil  7.6, 2.5 SAY ::aRX[2,1]
       UTILPRN ::oUtil  7.6,10.0 SAY ::aRX[2,2]
       UTILPRN ::oUtil  7.6,12.0 SAY ::aRX[2,3]
       UTILPRN ::oUtil  8.4, 5.0 SAY "N"
       UTILPRN ::oUtil  9.2, 5.0 SAY "N"
       UTILPRN ::oUtil 10.0, 5.0 SAY "N"
    ElseIf ::aLS[3] == 2
       If FILE( oApl:cIco+"logohis.jpg" )
          MsgStop( STR(oApl:nX)+STR(oApl:nY),"LOGO" )
          UTILPRN ::oUtil 0.5,1.5 IMAGE oApl:cIco+"logohis.jpg" SIZE oApl:nX,oApl:nY JPG
       Else
          ::Centrar( oApl:cEmpresa,::aFnt[2],1.0 )
       EndIf

       UTILPRN ::oUtil  3.0, 3.0 SAY "Fecha :"
       UTILPRN ::oUtil  3.0, 4.5 SAY NtChr( ::aLS[1],"5" ) + ", " +;
                                     NtChr( ::aLS[1],"3" )
       ::Centrar( "C E R T I F I C A:",::aFnt[3],4.0 )

       UTILPRN ::oUtil  6.0, 2.5 SAY "Que el pacíente:"
       UTILPRN ::oUtil  6.0, 5.8 SAY ::aRX[3] FONT ::aFnt[4]
       UTILPRN ::oUtil  6.8, 2.5 SAY ::aRX[4] + ;
          " necesita corrección Oftálmica con la siguiente fórmula"
       UTILPRN ::oUtil  7.6, 2.5 SAY "O.D. "   + ::aRX[1,1]
       UTILPRN ::oUtil  7.6,10.0 SAY "A.D.D. " + ::aRX[1,2]
       UTILPRN ::oUtil  7.6,13.0 SAY "A.V. "   + ::aRX[1,3]
       UTILPRN ::oUtil  8.4, 2.5 SAY "O.I. "   + ::aRX[2,1]
       UTILPRN ::oUtil  8.4,10.0 SAY "A.D.D. " + ::aRX[2,2]
       UTILPRN ::oUtil  8.4,13.0 SAY "A.V. "   + ::aRX[2,3]
       UTILPRN ::oUtil  9.2, 2.5 SAY "Percepción a los colores  N"
       UTILPRN ::oUtil 10.0, 2.5 SAY "Campos visuales  N"
       UTILPRN ::oUtil 10.8, 2.5 SAY "Balance muscular  N"
       UTILPRN ::oUtil 11.6, 2.5 SAY "Presión intraocular  N"
       UTILPRN ::oUtil 12.4, 2.5 SAY "O.D.                  O.I."
       UTILPRN ::oUtil 13.2, 2.5 SAY "Observaciones"
       UTILPRN ::oUtil 18.0, 6.5 SAY "Atentamente,"
       UTILPRN ::oUtil LINEA 18.4, 8.5 TO 18.4,19.0
       ::aEnc[1] := 13.7
       ::aEnc[2] := 78
    Else
       If FILE( oApl:cIco+"logohis.jpg" )
        //MsgStop( STR(oApl:nX)+STR(oApl:nY),"LOGO" )
          UTILPRN ::oUtil 3.1,1.5 IMAGE oApl:cIco+"logohis.jpg" SIZE oApl:nX,oApl:nY JPG
        //UTILPRN ::oUtil 3.1,1.5 IMAGE oApl:cIco+"logohis.jpg" SIZE 7.0,2.4 JPG
       EndIf
       UTILPRN ::oUtil  7.5, 2.5 SAY "Barranquilla, " + NtChr( ::aLS[1],"3" )
       ::Centrar( "C E R T I F I C A M O S",::aFnt[3],10.0 )
       UTILPRN ::oUtil 12.5, 2.5 SAY "Que el pacíente"
       UTILPRN ::oUtil 12.5, 5.8 SAY ::aRX[3] FONT ::aFnt[4]
       UTILPRN ::oUtil 13.0, 2.5 SAY "identificado con cédula de ciudadanía No. " +;
                             ALLTRIM( oApl:oHis:NROIDEN ) + " estuvo en consulta"
       UTILPRN ::oUtil 13.5, 2.5 SAY "de Optometría en el dia de hoy."
       UTILPRN ::oUtil 15.0, 2.5 SAY "Atentamente,"
       UTILPRN ::oUtil 18.0, 2.5 SAY "Dr(a) " + ::aLS[4]
       UTILPRN ::oUtil 18.5, 2.5 SAY "OPTOMETRA"
    EndIf
      FOR nL := 1 TO MLCOUNT( ::aLS[5],::aEnc[2] )
         cLinea := MEMOLINE( ::aLS[5],::aEnc[2],nL )
         UTILPRN ::oUtil Self:aEnc[1],1.5 SAY cLinea
         ::aEnc[1] += .8
      NEXT nL
 ENDPAGE
IMPRIME END .F.

RETURN NIL