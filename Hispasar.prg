// Programa.: HISPASAR.PRG     >>> Martin A. Toloza Lozano <<<
// Notas....: Pasar las Historias Clinicas a MySQL.
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE DbfSQL()
   LOCAL oDlg, oGet := ARRAY(6), aLS := TRIM( oApl:cUser )
If aLS # "Martin" .AND. aLS # "root"
   MsgStop( "Usted no está Autorizado para PASAR Datos",oApl:cUser )
   RETURN
EndIf
aLS := { 1,0,"",0,"","" }
DEFINE DIALOG oDlg TITLE "Pasar los Datos de DBF" FROM 0, 0 TO 10,42
   @ 02,00 SAY "Tabla"      OF oDlg RIGHT PIXEL SIZE 60,10
   @ 02,62 COMBOBOX oGet[1] VAR aLS[1] ITEMS ;
      {"HISTORIA","HISCNTRL","HISDIAGN","HISAGVIS","HISEXAME",;
       "HISQUERA","HISRETIN","HISOFTAL","RIDCONSU","RIDSERVI"};
      SIZE 66,99 OF oDlg PIXEL
   @ 14,00 SAY "NRO. REGISTRO"    OF oDlg RIGHT PIXEL SIZE 60,10
   @ 14,62 GET oGet[2] VAR aLS[2] OF oDlg PICTURE "999999" SIZE 36,10 PIXEL;
      VALID aLS[2] >= 0
   @ 26,04 SAY oGet[3] VAR aLS[3] OF oDlg PIXEL SIZE 60,10 ;
      UPDATE COLOR nRGB( 160,19,132 )
   @ 40,52 METER oGet[4] VAR aLS[4] TOTAL 100 SIZE 46,10 OF oDlg PIXEL

   @ 56, 60 BUTTON oGet[5] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[5]:Disable(), CopyaSQL( oDlg,oGet,aLS ), oDlg:End() ) PIXEL
   @ 56,110 BUTTON oGet[6] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 62, 02 SAY "[HISPASAR]" OF oDlg PIXEL SIZE 34,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT ( Empresa( .t. ) )
RETURN
/*
select nro_histor, familiar, cntrl_id
from hiscntrl
WHERE familiar <> ''
  and codigo_nit <> 0
ORDER BY cntrl_id
        " ORDER BY familiar, nro_histor"
*/
//------------------------------------//
PROCEDURE Familiar()
   LOCAL aCtl, aHis, cQry, hCtl, hRes, nA, nH, nL
nA := 1
MsgGet( "HISCNTRL","cntrl_id",@nA )
cQry := "SELECT familiar, nro_histor, cntrl_id FROM hiscntrl "+;
        "WHERE codigo_nit = 0 AND familiar <> '' "            +;
          "AND cntrl_id  >= " + LTRIM(STR(nA))                +;
        " ORDER BY cntrl_id LIMIT 50"
hCtl := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hCtl )) == 0
   MsgInfo( "NO HAY INFORMACION PARA GRABAR" )
   MSFreeResult( hCtl ) ; RETURN
EndIf
While nL > 0
   aCtl := MyReadRow( hCtl )
   AEVAL( aCtl, { | xV,nP | aCtl[nP] := MyClReadCol( hCtl,nP ) },2 )
   nA   := AT( " ",ALLTRIM(aCtl[1]) )
   cQry := "SELECT direccion, codigo_nit FROM historia "   +;
           "WHERE nombres   LIKE '" +   LEFT(aCtl[1],nA-1) +;
          "%' AND apellidos LIKE '" + SUBSTR(aCtl[1],nA+1) + "%'"
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   If (nH := MSNumRows( hRes )) > 0
      aHis := MyReadRow( hRes )
      AEVAL( aHis, { | xV,nP | aHis[nP] := MyClReadCol( hRes,nP ) } )
      cQry := Buscar( {"nro_histor",aCtl[2]},"historia","direccion",8 )
      If aHis[1] == cQry
         oApl:oWnd:SetMsg( aCtl[1] )
         cQry := "UPDATE hiscntrl SET codigo_nit = " + LTRIM(STR(aHis[2])) +;
                 " WHERE cntrl_id = " + LTRIM(STR(aCtl[3]))
         Guardar( cQry,"hiscntrl" )
      ElseIf MsgYesNo( "His = " + cQry + CRLF +;
                       "Fam = " + aHis[1],"Actualizar"+STR(aCtl[3]) )
         cQry := "UPDATE hiscntrl SET codigo_nit = " + LTRIM(STR(aHis[2])) +;
                 " WHERE cntrl_id = " + LTRIM(STR(aCtl[3]))
         Guardar( cQry,"hiscntrl" )
      EndIf
      MSFreeResult( hRes )
   EndIf
   nL --
EndDo
MsgInfo( "Fin Actualizo Familiar",STR(aCtl[3]) )
MSFreeResult( hCtl )
RETURN

//------------------------------------//
PROCEDURE CopyaSQL1( oDlg,oGet,aLS )
   LOCAL aCtl, aHis, aRes, cQry, hCtl, hRes, nCtl, nL
cQry := "SELECT * FROM htoria WHERE nro_histor > 0 ORDER BY nro_histor"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA GRABAR" )
   MSFreeResult( hRes ) ; RETURN
EndIf
aHis := { .f.,"","",1 }
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   oApl:oWnd:SetMsg( STR(aRes[19]) )
   aRes[3] := ALLTRIM( STRTRAN( aRes[3],".","" ) )
   cQry :=    "nroiden = '" + aRes[3]           +;
      "' OR (apellidos = '" + ALLTRIM(aRes[04]) +;
      "' AND nombres   = '" + ALLTRIM(aRes[05]) + "')"
   If !oApl:oHis:Seek( cQry,"CM" )
       oApl:oHis:TIPOIDEN  := aRes[02] ; oApl:oHis:NROIDEN    := aRes[03]
       oApl:oHis:APELLIDOS := aRes[04] ; oApl:oHis:NOMBRES    := aRes[05]
       oApl:oHis:SEXO      := aRes[06] ; oApl:oHis:FEC_NACIMI := aRes[07]
       oApl:oHis:UNIEDAD   := aRes[08] ; oApl:oHis:EDAD       := aRes[09]
       oApl:oHis:RESHABIT  := aRes[10] ; oApl:oHis:ZONARESI   := aRes[11]
       oApl:oHis:DIRECCION := aRes[12] ; oApl:oHis:TEL_RESIDE := aRes[13]
       oApl:oHis:TEL_OFICIN:= aRes[14] ; oApl:oHis:EMAIL      := aRes[15]
       oApl:oHis:OCUPACION := aRes[16] ; oApl:oHis:TIPOUSUA   := aRes[17]
       oApl:oHis:TIPOAFILI := aRes[18] ; oApl:oHis:PAPEL      := aRes[20]
       oApl:oHis:PNOMB     := aRes[21] ; oApl:oHis:OPTICA     := aRes[22]
       oApl:oHis:EXPORTAR  := "N"
       Guardar( oApl:oHis,.t.,.t. )
   EndIf
   aHis[1] := oApl:oHis:NRO_HISTOR
   If oApl:oHis:NRO_HISTOR  # aRes[19]
      oApl:oHis:NRO_HISTOR := Buscar( "SELECT sf_secuencia(0, 'HISTORIAS') FROM DUAL","CM" )
      Guardar( oApl:oHis,.f.,.t. )
   EndIf
   If aHis[1] == 0
      cQry := "INSERT INTO historic (codigo_nit, optica, nro_histor, fec_histor, "+;
                          "apersonal, afamiliar, observ_his, estrefod, estrefoi) "+;
              "SELECT " + LTRIM(STR(oApl:oHis:CODIGO_NIT)) + ", " +;
                          LTRIM(STR(aRes[22])) + ", "             +;
                          LTRIM(STR(oApl:oHis:NRO_HISTOR)) + ", v.fec_histor, "+;
                     "v.apersonal, v.afamiliar, v.observ_his, v.estrefod, v.estrefoi "+;
              "FROM htoric v WHERE v.nro_histor = " + LTRIM(STR(aRes[19]))
      Guardar( cQry,"historic" )
   EndIf
   cQry := "INSERT INTO historig VALUES( null, " + LTRIM(STR(oApl:oHis:CODIGO_NIT)) + ", "+;
                     LTRIM(STR(aRes[22])) + ", " + LTRIM(STR(aRes[19])) + " )"
   Guardar( cQry,"historig" )

   cQry := "SELECT * FROM hcntrl WHERE nro_histor = " + LTRIM(STR(aRes[19])) +;
           " ORDER BY control"
   hCtl := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nCtl := MSNumRows( hCtl )
   While nCtl > 0
      aCtl := MyReadRow( hRes )
      AEVAL( aCtl, { | xV,nP | aCtl[nP] := MyClReadCol( hCtl,nP ) } )
      oApl:oCtl:xBlank()
      oApl:oCtl:OPTICA  := aCtl[01] ; oApl:oCtl:NRO_HISTOR := oApl:oHis:NRO_HISTOR
      oApl:oCtl:CONTROL := Buscar( "SELECT MAX(control) FROM hiscntrl WHERE nro_histor = "+;
                                   LTRIM(STR(oApl:oHis:NRO_HISTOR)),"CM",,,,4 ) + 1
      oApl:oCtl:FECHA      := aCtl[04] ; oApl:oCtl:DOCTOR     := aCtl[05]
      oApl:oCtl:MOTIVO_CON := aCtl[06] ; oApl:oCtl:FECHAFAC   := aCtl[07]
      oApl:oCtl:FECHAENT   := aCtl[08] ; oApl:oCtl:NOTAS_LC   := aCtl[09]
      oApl:oCtl:MEDICAMENT := aCtl[10] ; oApl:oCtl:REMITIR    := aCtl[11]
      oApl:oCtl:FCHPROXCON := aCtl[12] ; oApl:oCtl:OBSERV_DIA := aCtl[13]
      oApl:oCtl:FAMILIAR   := aCtl[14] ; oApl:oCtl:TELEFONO   := aCtl[15]
      Guardar( oApl:oCtl,.t.,.t. )
      aHis[2] := "SELECT " + LTRIM(STR(oApl:oCtl:CNTRL_ID)) + ", "
      aHis[3] := "WHERE v.nro_histor = " + LTRIM(STR(aRes[19])) +;
                  " AND v.control    = " + LTRIM(STR(aCtl[03]))
      //4 oAgv
      cQry := "INSERT INTO hisagvis (cntrl_id , scavlod  , scavlodph, scavcod  , scavloi, "    +;
                                    "scavloiph, scavcoi  , scavlao  , scavlaoph, scavcao, "    +;
                                    "ccavlod  , ccavlodph, ccavcod  , ccavloi  , ccavloiph, "  +;
                                    "ccavcoi  , ccavlao  , ccavlaoph, ccavcao  , observ_av, "  +;
                                    "lovlodesf, lovlodcil, lovlodeje, lovloiesf, lovloicil, "  +;
                                    "lovloieje, lovpodesf, lovpodcil, lovpodeje, lovpoiesf, "  +;
                                    "lovpoicil, lovpoieje, loodadd  , looiadd  , lotipo, "     +;
                                    "odcurvabas, odpoder , oddiametro, odcurvap, oicurvabas, " +;
                                    "oipoder  , oidiametro, oicurvap, tipolc, observ_rxu) "    +;
              aHis[2] + "v.scavlod   , v.scavlodph , v.scavcod   , v.scavloi  , "              +;
                        "v.scavloiph , v.scavcoi   , v.scavlao   , v.scavlaoph, v.scavcao, "   +;
                        "v.ccavlod   , v.ccavlodph , v.ccavcod   , v.ccavloi  , v.ccavloiph, " +;
                        "v.ccavcoi   , v.ccavlao   , v.ccavlaoph , v.ccavcao  , v.observ_av, " +;
                        "v.lovlodesf , v.lovlodcil , v.lovlodeje , v.lovloiesf, v.lovloicil, " +;
                        "v.lovloieje , v.lovpodesf , v.lovpodcil , v.lovpodeje, v.lovpoiesf, " +;
                        "v.lovpoicil , v.lovpoieje , v.loodadd   , v.looiadd  , v.lotipo, "    +;
                        "v.odcurvabas, v.odpoder   , v.oddiametro, v.odcurvap , v.oicurvabas, "+;
                        "v.oipoder   , v.oidiametro, v.oicurvap  , v.tipolc   , v.observ_rxu " +;
              "FROM hagvis v " + aHis[3]
      Guardar( cQry,"hisagvis" )
      //5 oExa
      cQry := "INSERT INTO hisexame (cntrl_id , odpintraoc, oipintraoc, examen_ext) "+;
              aHis[2] + "v.odpintraoc, v.oipintraoc, v.examen_ext "                  +;
              "FROM hexame v " + aHis[3]
      Guardar( cQry,"hisexame" )
      //6 oQue
      cQry := "INSERT INTO hisquera (cntrl_id , odplano, odcurvo, odeje, oiplano, "+;
                                      "oicurvo, oieje, miras, equipo, observ_ot) " +;
              aHis[2] + "v.odplano, v.odcurvo, v.odeje, oiplano, "                 +;
                        "v.oicurvo, v.oieje, v.miras, v.equipo, v.observ_ot "      +;
              "FROM hquera v " + aHis[3]
      Guardar( cQry,"hisquera" )
      //7 oRet
      cQry := "INSERT INTO hisretin (cntrl_id , estodesf, estodcil, estodeje, estodavl, "+;
                                     "estodavc, estoiesf, estoicil, estoieje, estoiavl, "+;
                                     "estoiavc, dinodesf, dinodcil, dinodeje, dinodavl, "+;
                                     "dinodavc, dinoiesf, dinoicil, dinoieje, dinoiavl, "+;
                                     "dinoiavc, observ_rt) "                             +;
              aHis[2] + "v.estodesf, v.estodcil, v.estodeje, v.estodavl, v.estodavc, "   +;
                        "v.estoiesf, v.estoicil, v.estoieje, v.estoiavl, v.estoiavc, "   +;
                        "v.dinodesf, v.dinodcil, v.dinodeje, v.dinodavl, v.dinodavc, "   +;
                        "v.dinoiesf, v.dinoicil, v.dinoieje, v.dinoiavl, v.dinoiavc, v.observ_rt "+;
              "FROM hretin v " + aHis[3]
      Guardar( cQry,"hisretin" )
      //8 oOft
      cQry := "INSERT INTO hisoftal (cntrl_id, tipo, odpolopost, odexcava, odmacula, "       +;
                                    "oipolopost, oiexcava, oimacula, oifijacion, observ_of) "+;
              aHis[2] + "v.tipo, v.odpolopost, v.odexcava, v.odmacula, v.oipolopost, "       +;
                        "v.oiexcava, v.oimacula, v.oifijacion, v.observ_of "                 +;
              "FROM hoftal v " + aHis[3]
      Guardar( cQry,"hisoftal" )
      //9 oDgn
      cQry := "INSERT INTO hisdiagn (cntrl_id, tipodgn , ladolente, codigo, esfera, cilindro, "+;
                                    "eje     , adicion , tipoadd  , avl   , avc   , dp_cb   , "+;
                                    "cbase   , diametro, ecentro  , eborde, zoptica) "         +;
              aHis[2] + "v.tipodgn, v.ladolente, v.codigo  , v.esfera , v.cilindro, "          +;
                        "v.eje    , v.adicion  , v.tipoadd , v.avl    , v.avc     , "          +;
                        "v.dp_cb  , v.cbase    , v.diametro, v.ecentro, v.eborde  , v.zoptica "+;
              "FROM hdiagn v " + aHis[3]
      Guardar( cQry,"hisdiagn" )
      nCtl --
   EndDo
   MSFreeResult( hCtl )

   aHis[4] := 1
   cQry := "SELECT control, fecha, cntrl_id FROM hiscntrl "+;
           "WHERE nro_histor = " + LTRIM(STR(aRes[19]))    +;
           " ORDER BY fecha DESC"
   hCtl := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nCtl := MSNumRows( hCtl )
   While nCtl > 0
      aCtl := MyReadRow( hCtl )
      AEVAL( aCtl, { | xV,nP | aCtl[nP] := MyClReadCol( hCtl,nP ) } )
      If aCtl[1] # nCtl
         cQry := "UPDATE hiscntrl SET control = " + LTRIM(STR(nCtl)) +;
                " WHERE cntrl_id = " + LTRIM(STR(aCtl[3]))
         Guardar( cQry,"hiscntrl" )
      EndIf
      nCtl --
   EndDo
   MSFreeResult( hCtl )
   nL --
EndDo
MSFreeResult( hRes )
RETURN

//------------------------------------//
PROCEDURE CopyaSQL( oDlg,oGet,aLS )
   LOCAL cINS, cQry, xVal, n, nHis, nCtl := 0
   LOCAL oRpt, cRuta := AbrirFile( 4,oApl:cRuta2,"HISDIAGN.DBF" )
If (n := RAT( "\", cRuta )) > 0
   cRuta := LEFT( cRuta,n )
Else
   cRuta := oApl:cRuta2
EndIf

If aLS[1] == 1
   If !AbreDbf( "Ana","HISTORIC","HISTORIC",cRuta,.t. )
      RETURN
   EndIf
   Ana->(DBSETORDER( 1 ))
      AbreDbf( "His","HISTORIA",,cRuta,.t. )
   If aLS[2] > 0
      GO( aLS[2] )
   EndIf
   /*
   SELECT * FROM historia
   WHERE nroiden = '42166'
     OR (apellidos = 'CABEZA SARMIENTO'
     AND nombres = 'VIANNY' )

   SELECT DISTINCT codigo_nit FROM historia
   WHERE NOT EXISTS (SELECT * FROM cadfactu
                     WHERE cadfactu.codigo_cli = historia.codigo_nit);
ALTER TABLE cadantic ADD autoriza INT(8) DEFAULT 0
   */
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,{"ESTOS YA EXISTEN","POR FAVOR REVISAR"},.t.,1,2 )
      oGet[3]:setText( "HISTORIA" )
   aLS[2] := SECONDS()
   While !His->(EOF())
      oApl:oWnd:SetMsg( STR( RecNo() ) )
      cINS := ALLTRIM( STRTRAN( His->NROIDEN,".","" ) )
      cQry :=    "nroiden = '"+ cINS  +;
         "' OR (apellidos = " + ( '"' + ALLTRIM(His->APELLIDOS) + '"' ) +;
          " AND nombres   = " + ( '"' + ALLTRIM(His->NOMBRES)   + '"' ) + ")"
      If oApl:oHis:Seek( cQry,"CM" )
         If oApl:oHis:NRO_HISTOR == His->NRO_HISTOR .OR.;
            oApl:oHis:NRO_HISTOR == 0
            If cINS == LTRIM(STR(His->NRO_HISTOR)) .AND.;
               cINS  # ALLTRIM(oApl:oHis:NROIDEN)
               cINS := ALLTRIM(oApl:oHis:NROIDEN)
            EndIf
            cQry := "INSERT INTO historib VALUES( " + LTRIM(STR(oApl:oHis:CODIGO_NIT)) + ", "
            xVal := .f.
            FOR n := 1 TO 17
               If oApl:oHis:axBuffer[ n+1 ] # FieldGet( n ) .OR.;
                  (n == 2 .AND. ALLTRIM(oApl:oHis:NROIDEN) # cINS)
                  aLS[5] := oApl:oHis:axBuffer[ n+1 ]
                  cQry += If( VALTYPE( aLS[5] ) == "C", ( '"' + ALLTRIM(aLS[5]) + '"' ),;
                              xValToChar( aLS[5],1 ) ) + ", "
                  xVal := .t.
               Else
                  cQry += "NULL, "
               EndIf
            NEXT n
            If xVal
               cQry := LEFT( cQry,LEN(cQry)-2 ) + " )"
               MSQuery( oApl:oMySql:hConnect,cQry )
            EndIf
         Else
            nCtl ++
            oApl:oHis:xBlank()
            oApl:oHis:lOK    := .f.
            oApl:oHis:OPTICA := oApl:nEmpresa
            xVal := .t.
         EndIf
         If xVal
            oRpt:Titulo( 80 )
            oRpt:Say(++oRpt:nL,02,His->NROIDEN   + " " +;
                                  His->APELLIDOS + " " +;
                                  His->NOMBRES   + " " +;
                              STR(oApl:oHis:NRO_HISTOR)+;
                              STR(His->NRO_HISTOR)     +;
                              STR( RecNo() ) + " Rec." )
         EndIf
      Else
         nCtl ++
         oApl:oHis:OPTICA    := oApl:nEmpresa
         xVal := .t.
      EndIf

      If xVal
         oApl:oHis:TIPOIDEN  := His->TIPOIDEN  ; oApl:oHis:NROIDEN   := cINS
         oApl:oHis:APELLIDOS := His->APELLIDOS ; oApl:oHis:NOMBRES   := His->NOMBRES
         oApl:oHis:SEXO      := His->SEXO      ; oApl:oHis:FEC_NACIMI:= His->FEC_NACIMI
         oApl:oHis:UNIEDAD   := His->UNIEDAD   ; oApl:oHis:EDAD      := His->EDAD
         oApl:oHis:RESHABIT  := His->RESHABIT  ; oApl:oHis:ZONARESI  := His->ZONARESI
         oApl:oHis:DIRECCION := His->DIRECCION ; oApl:oHis:TEL_RESIDE:= His->TEL_RESIDE
         oApl:oHis:TEL_OFICIN:= His->TEL_OFICIN; oApl:oHis:EMAIL     := His->EMAIL
         oApl:oHis:OCUPACION := His->OCUPACION ; oApl:oHis:TIPOUSUA  := His->TIPOUSUA
         oApl:oHis:TIPOAFILI := His->TIPOAFILI ; oApl:oHis:NRO_HISTOR:= His->NRO_HISTOR
         oApl:oHis:PAPEL     := His->PAPEL     ; oApl:oHis:PNOMB     := His->PNOMB
         Guardar( oApl:oHis,!oApl:oHis:lOK,.t. )
      EndIf
      If His->NRO_HISTOR > 0
         If Ana->(dbSeek( STR(His->NRO_HISTOR,8) ))
            n := If( His->CODIGO_NIT == oApl:oHis:CODIGO_NIT,;
                     His->CODIGO_NIT,   oApl:oHis:CODIGO_NIT )
            cQry := "INSERT INTO historic VALUES( null, " +;
                      LTRIM(STR(n))               +  ", " +;
                      LTRIM(STR(oApl:nEmpresa))   +  ", " +;
                      LTRIM(STR(Ana->NRO_HISTOR)) +  ", " +;
                     xValToChar(Ana->FEC_HISTOR)  +  ", "
            FOR n := 3 TO 7
             //xVal := ALLTRIM(Ana->(FieldGet( n )))
             //cQry += ( '"' + xVal + '", ' )
               cQry += ( "'" + ESCAPESTR( Ana->(FieldGet( n )) ) + "', " )
            NEXT n
            cQry := LEFT( cQry,LEN(cQry)-2 ) + " )"
            Guardar( cQry,"historic" )
         EndIf
      EndIf
      His->(dbSkip())
   EndDo
   aLS[6] := "HISTORIA" + STR(nCtl) + " NUEVOS, Demore " +;
             STR(SECONDS() - aLS[2])+" s"
   Ana->(dbCloseArea())
   His->(dbCloseArea())
   oRpt:NewPage()
   oRpt:End()

ElseIf aLS[1] == 2

   AbreDbf( "Tmp","HISCNTRL",,cRuta,.f. )
   If aLS[2] > 0
      GO( aLS[2] )
   EndIf
    oGet[3]:setText( "HISCNTRL"+STR(LASTREC()) )
   cINS := "INSERT INTO hiscntrl VALUES ( " + LTRIM(STR(oApl:nEmpresa)) + ", "
   aLS[2] := SECONDS()
   While !Tmp->(EOF())
      If Tmp->NRO_HISTOR > 0 .AND. Tmp->CONTROL_NO > 0
         oApl:oWnd:SetMsg( STR( RecNo() ) )
         cQry := cINS + LTRIM(STR(Tmp->NRO_HISTOR))+  ", " +;
                        LTRIM(STR(Tmp->CONTROL_NO))+  ", " +;
                       xValToChar(Tmp->FCHCTRL)    +  ", " +;
                       xValToChar(Tmp->DOCTOR)     +  ", '"+;
                        ESCAPESTR(Tmp->MOTIVO_CON )        +;
                 "', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)"
         MSQuery( oApl:oMySql:hConnect,cQry )
      EndIf
      Tmp->(dbSkip())
       aLS[4] ++
      oGet[4]:Refresh()
   Enddo
   aLS[6] := "HISCNTRL Demore " + STR(SECONDS() - aLS[2])+" s"
   dbCloseArea()

ElseIf aLS[1] == 3

   If !AbreDbf( "Tmp","HISDIAGN",,cRuta,.f. )
      MsgInfo( "NO SE PUEDEN CREAR CODIGOS" )
   EndIf
   If aLS[2] > 0
      GO( aLS[2] )
   EndIf
    oGet[3]:setText( "HISDIAGN"+STR(LASTREC()) )
   aLS[2] := SECONDS()
   While !Tmp->(EOF())
      nHis := FieldGet( 1 )
      nCtl := FieldGet( 2 )
      If !oApl:oCtl:Seek( {"optica",oApl:nEmpresa,"nro_histor",nHis,"control",nCtl} )
         Tmp->(dbSkip())
         LOOP
      EndIf
      oApl:oWnd:SetMsg( STR( RecNo() ) )
      xVal := .t.
      If Revisar( 3,6 ,{11,12} )
         oApl:oDgn:xBlank()
         oApl:oDgn:OPTICA     := oApl:nEmpresa
         oApl:oDgn:NRO_HISTOR := nHis
         oApl:oDgn:CONTROL    := nCtl
         oApl:oDgn:TIPODGN    := "S"
         oApl:oDgn:LADOLENTE  := "D"
         oApl:oDgn:ESFERA     := FieldGet( 3 )
         oApl:oDgn:CILINDRO   := FieldGet( 4 )
         oApl:oDgn:EJE        := FieldGet( 5 )
         oApl:oDgn:ADICION    := FieldGet( 6 )
         oApl:oDgn:AVL        := FieldGet(11 )
         oApl:oDgn:AVC        := FieldGet(12 )
         Guardar( oApl:oDgn,.t.,.f. )
      EndIf
      If Revisar( 7,10,{13,14} )
         oApl:oDgn:xBlank()
         oApl:oDgn:OPTICA     := oApl:nEmpresa
         oApl:oDgn:NRO_HISTOR := nHis
         oApl:oDgn:CONTROL    := nCtl
         oApl:oDgn:TIPODGN    := "S"
         oApl:oDgn:LADOLENTE  := "I"
         oApl:oDgn:ESFERA     := FieldGet( 7 )
         oApl:oDgn:CILINDRO   := FieldGet( 8 )
         oApl:oDgn:EJE        := FieldGet( 9 )
         oApl:oDgn:ADICION    := FieldGet(10 )
         oApl:oDgn:AVL        := FieldGet(13 )
         oApl:oDgn:AVC        := FieldGet(14 )
         Guardar( oApl:oDgn,.t.,.f. )
      EndIf
      cQry := FieldGet(28)      //DISPUPILAR
      If Revisar(15,18,{23,24,29} )
         oApl:oDgn:xBlank()
         oApl:oDgn:OPTICA     := oApl:nEmpresa
         oApl:oDgn:NRO_HISTOR := nHis
         oApl:oDgn:CONTROL    := nCtl
         oApl:oDgn:TIPODGN    := "R"
         oApl:oDgn:LADOLENTE  := "D"
         oApl:oDgn:CODIGO     := FieldGet(27 )
         oApl:oDgn:ESFERA     := FieldGet(15 )
         oApl:oDgn:CILINDRO   := FieldGet(16 )
         oApl:oDgn:EJE        := FieldGet(17 )
         oApl:oDgn:ADICION    := FieldGet(18 )
         oApl:oDgn:AVL        := FieldGet(23 )
         oApl:oDgn:AVC        := FieldGet(24 )
         If EMPTY( FieldGet(29) ) .AND. EMPTY( FieldGet(30) )
          //oApl:oDgn:DP_CB   := LEFT( cQry,6 )
            oApl:oDgn:DP_CB   := cQry
            xVal := .f.
         Else
            oApl:oDgn:DP_CB   := FieldGet(29)
         EndIf
         Guardar( oApl:oDgn,.t.,.f. )
      EndIf
      If Revisar(19,22,{25,26,30} )
         oApl:oDgn:xBlank()
         oApl:oDgn:OPTICA     := oApl:nEmpresa
         oApl:oDgn:NRO_HISTOR := nHis
         oApl:oDgn:CONTROL    := nCtl
         oApl:oDgn:TIPODGN    := "R"
         oApl:oDgn:LADOLENTE  := "I"
         oApl:oDgn:CODIGO     := FieldGet(27 )
         oApl:oDgn:ESFERA     := FieldGet(19 )
         oApl:oDgn:CILINDRO   := FieldGet(20 )
         oApl:oDgn:EJE        := FieldGet(21 )
         oApl:oDgn:ADICION    := FieldGet(22 )
         oApl:oDgn:AVL        := FieldGet(25 )
         oApl:oDgn:AVC        := FieldGet(26 )
         If EMPTY( FieldGet(30) ) .AND. xVal
            oApl:oDgn:DP_CB   := cQry
         Else
            oApl:oDgn:DP_CB   := FieldGet(30)
         EndIf
         Guardar( oApl:oDgn,.t.,.f. )
      EndIf
      If Revisar(33,42,{53} )
         oApl:oDgn:xBlank()
         oApl:oDgn:OPTICA     := oApl:nEmpresa
         oApl:oDgn:NRO_HISTOR := nHis
         oApl:oDgn:CONTROL    := nCtl
         oApl:oDgn:TIPODGN    := "C"
         oApl:oDgn:LADOLENTE  := "D"
         oApl:oDgn:CODIGO     := FieldGet(33 )
         oApl:oDgn:DP_CB      := FieldGet(34 )
         oApl:oDgn:DIAMETRO   := FieldGet(35 )
         oApl:oDgn:ESFERA     := FieldGet(36 )
         oApl:oDgn:CILINDRO   := FieldGet(37 )
         oApl:oDgn:EJE        := FieldGet(38 )
         oApl:oDgn:ADICION    := FieldGet(39 )
         oApl:oDgn:ECENTRO    := FieldGet(40 )
         oApl:oDgn:EBORDE     := FieldGet(41 )
         oApl:oDgn:ZOPTICA    := FieldGet(42 )
         oApl:oDgn:AVL        := FieldGet(53 )
         Guardar( oApl:oDgn,.t.,.f. )
      EndIf
      If Revisar(43,52,{54} )
         oApl:oDgn:xBlank()
         oApl:oDgn:OPTICA     := oApl:nEmpresa
         oApl:oDgn:NRO_HISTOR := nHis
         oApl:oDgn:CONTROL    := nCtl
         oApl:oDgn:TIPODGN    := "C"
         oApl:oDgn:LADOLENTE  := "I"
         oApl:oDgn:CODIGO     := FieldGet(43 )
         oApl:oDgn:DP_CB      := FieldGet(44 )
         oApl:oDgn:DIAMETRO   := FieldGet(45 )
         oApl:oDgn:ESFERA     := FieldGet(46 )
         oApl:oDgn:CILINDRO   := FieldGet(47 )
         oApl:oDgn:EJE        := FieldGet(48 )
         oApl:oDgn:ADICION    := FieldGet(49 )
         oApl:oDgn:ECENTRO    := FieldGet(50 )
         oApl:oDgn:EBORDE     := FieldGet(51 )
         oApl:oDgn:ZOPTICA    := FieldGet(52 )
         oApl:oDgn:AVL        := FieldGet(54 )
         Guardar( oApl:oDgn,.t.,.f. )
      EndIf
      cQry := "UPDATE hiscntrl SET fechafac = "  + xValToChar(Tmp->FECHAFAC)   +;
                                ", fechaent = "  + xValToChar(Tmp->FECHAENT)   +;
                                ", notas_lc = '" + ESCAPESTR( Tmp->NOTAS_LC )  +;
                             "', medicament = '" + ESCAPESTR( Tmp->MEDICAMENT )+;
                                "', remitir = '" + ESCAPESTR( Tmp->REMITIR )   +;
                             "', fchproxcon = "  + xValToChar(Tmp->FCHPROXCON) +;
                              ", observ_dia = '" + ESCAPESTR( Tmp->OBSERV_DIA )+;
                            "' WHERE optica = "  + LTRIM(STR(oApl:nEmpresa))   +;
                           " AND nro_histor = "  + LTRIM(STR(nHis))            +;
                              " AND control = "  + LTRIM(STR(nCtl))
      Guardar( cQry,"hiscntrl" )
      Tmp->(dbSkip())
   Enddo
   aLS[6] := "HISDIAGN Demore " + STR(SECONDS() - aLS[2])+" s"
   dbCloseArea()

ElseIf aLS[1] == 4
   MsgMeter( { | oMeter, oText, oDlg, lEnd | ;
                 LosDemas( oMeter,oText,oDlg,@lEnd,"hisagvis",cRuta,aLS ) },;
                 "hisagvis","4_Grabando" )
ElseIf aLS[1] == 5
   MsgMeter( { | oMeter, oText, oDlg, lEnd | ;
                 LosDemas( oMeter,oText,oDlg,@lEnd,"hisexame",cRuta,aLS ) },;
                 "hisexame","5_Grabando" )
ElseIf aLS[1] == 6
   MsgMeter( { | oMeter, oText, oDlg, lEnd | ;
                 LosDemas( oMeter,oText,oDlg,@lEnd,"hisquera",cRuta,aLS ) },;
                 "hisquera","6_Grabando" )
ElseIf aLS[1] == 7
   MsgMeter( { | oMeter, oText, oDlg, lEnd | ;
                 LosDemas( oMeter,oText,oDlg,@lEnd,"hisretin",cRuta,aLS ) },;
                 "hisretin","7_Grabando" )
ElseIf aLS[1] == 8
   MsgMeter( { | oMeter, oText, oDlg, lEnd | ;
                 LosDemas( oMeter,oText,oDlg,@lEnd,"hisoftal",cRuta,aLS ) },;
                 "hisoftal","8_Grabando" )
Else
   If aLS[1] == 9
      cINS := "RIDCONSU"
      nCtl := 4
   Else
      cINS := "RIDSERVI"
      nCtl := 3
   EndIf
       AbreDbf( "His","HISTORIA","HISTORIA",cRuta,.t. )
   If !AbreDbf( "Tmp",cINS,,cRuta,.t. )
      MsgInfo( "NO SE PUEDEN CREAR "+cINS )
      His->(dbCloseArea())
      RETURN
   EndIf
   If aLS[2] > 0
      GO( aLS[2] )
   EndIf
   His->(DBSETORDER( 5 ))
   nHis  := FCOUNT()
   cRuta := "INSERT INTO " + cINS +;
            " VALUES ( NULL, " + LTRIM(STR(oApl:nEmpresa)) + ", "
   aLS[2] := SECONDS()
   While !Tmp->(EOF())
      cINS := Tmp->CODIGO_NIT
      His->(dbSeek( STR(cINS,6) ))
      cQry :=    "nroiden = '"+ ALLTRIM(STRTRAN(His->NROIDEN,".","" ) ) +;
         "' OR (apellidos = " + ( '"' + ALLTRIM(His->APELLIDOS) + '"' ) +;
          " AND nombres   = " + ( '"' + ALLTRIM(His->NOMBRES)   + '"' ) + ")"
      If oApl:oHis:Seek( cQry,"CM" ) .AND. cINS # oApl:oHis:CODIGO_NIT
         cINS := oApl:oHis:CODIGO_NIT
      EndIf
      cQry  := cRuta
      FOR n := 2 TO nHis
         xVal := If( n == nCtl, cINS, FieldGet( n ) )
         cQry += If( VALTYPE( xVal ) == "C", ( '"' + ALLTRIM(xVal) + '"' ),;
                     xValToChar( xVal,1 ) ) + ", "
      NEXT n
      cQry := LEFT( cQry,LEN(cQry)-2 ) + " )"
      MSQuery( oApl:oMySql:hConnect,cQry )
      Tmp->(dbSkip())
   Enddo
   His->(dbCloseArea())
   Tmp->(dbCloseArea())
   aLS[6] := "RIDS Demore " + STR(SECONDS() - aLS[2])+" s"
EndIf
MsgStop( aLS[6] )
RETURN

//------------------------------------//
FUNCTION LosDemas( oMeter,oText,oDlg,lEnd,cFile,cRuta,aLS )
   LOCAL cQry, n, nFldCount, xVal
If !AbreDbf( "Tmp",cFile,,cRuta,.f. )
   MsgInfo( "NO SE PUEDEN CREAR "+cFile )
   RETURN NIL
EndIf
If aLS[2] > 0
   GO( aLS[2] )
EndIf
nFldCount := FCOUNT()
oMeter:nTotal := LASTREC()
cRuta := "INSERT INTO " + cFile +;
         " VALUES ( NULL, " + LTRIM(STR(oApl:nEmpresa)) + ", "
aLS[2] := SECONDS()
While !Tmp->(EOF())
   If !oApl:oCtl:Seek( {"optica",oApl:nEmpresa,"nro_histor",Tmp->NRO_HISTOR,"control",Tmp->CONTROL_NO} )
      Tmp->(dbSkip())
      LOOP
   EndIf
   If Revisar( 3,nFldCount )
      cQry  := cRuta
      FOR n := 1 TO nFldCount
         xVal := FieldGet( n )
         cQry += If( VALTYPE( xVal ) == "C", ( '"' + ALLTRIM(xVal) + '"' ),;
                     xValToChar( xVal,1 ) ) + ", "
      NEXT n
      cQry := LEFT( cQry,LEN(cQry)-2 ) + " )"
      MSQuery( oApl:oMySql:hConnect,cQry )
   EndIf
   Tmp->(dbSkip())
   oMeter:Set( RecNo() )
Enddo
aLS[6] += (cFile +" Demore " + STR(SECONDS() - aLS[2])+" s" + CRLF)
dbCloseArea()
RETURN NIL

//------------------------------------//
FUNCTION Revisar( nCI,nCF,aC )
   LOCAL lSI := .f., n
FOR n := nCI TO nCF
   If !EMPTY( FieldGet( n ) )
      lSI := .t.
      EXIT
   EndIF
NEXT n
If !lSI .AND. aC # NIL
   AEVAL( aC, { |nV,nP| If( !EMPTY( FieldGet(nV) ), lSI := .t., ) } )
EndIf
RETURN lSI

//------------------------------------//
FUNCTION ESCAPESTR( cVal )
  cVal := STRTRAN( cVal,"/","." )
RETURN MYREALESCAPESTR( oApl:oMySql:hConnect,ALLTRIM(cVal) )

//------------------------------------//
PROCEDURE Unificar()
   LOCAL oDlg, oDp, oGet := ARRAY(8), aLS := TRIM( oApl:cUser )
If aLS # "Martin" .AND. aLS # "root"
   MsgStop( "Usted no está Autorizado para PASAR Datos",oApl:cUser )
   RETURN
EndIf
aLS := { SPACE(15),0,SPACE(15),0,0,"","" }
oDp := TPer() ; oDp:NEW()
DEFINE DIALOG oDlg TITLE "Unificar Historia Doble" FROM 0, 0 TO 10,42
   @ 02,00 SAY "Doc.Iden 1" OF oDlg RIGHT PIXEL SIZE 40,10
   @ 02,42 BTNGET oGet[1] VAR aLS[1] OF oDlg ;
      ACTION EVAL({|| If(oDp:Mostrar( ,3 ), (aLS[1] := oDp:oDb:NROIDEN,;
                         oGet[1]:Refresh() ),) })                      ;
      VALID EVAL( {|| If( oDp:Buscar( aLS[1],"nroiden",.t. )          ,;
                        ( aLS[2] := oApl:oHis:NRO_HISTOR              ,;
                          oGet[2]:Settext( aLS[2] )                   +;
                          oGet[3]:Settext( XTRIM(oApl:oHis:NOMBRES)   +;
                                           oApl:oHis:APELLIDOS), .t. ),;
                        (MsgStop("Este Paciente no Existe"), .f.) ) } );
      SIZE 44,10 PIXEL RESOURCE "BUSCAR"
   @ 02,96 SAY oGet[2] VAR aLS[2] OF oDlg PIXEL SIZE 130,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 14,10 SAY oGet[3] VAR aLS[6] OF oDlg PIXEL SIZE 130,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 26,00 SAY "Doc.Iden 2" OF oDlg RIGHT PIXEL SIZE 40,10
   @ 26,42 BTNGET oGet[4] VAR aLS[3] OF oDlg ;
      ACTION EVAL({|| If(oDp:Mostrar( ,3 ), (aLS[3] := oDp:oDb:NROIDEN,;
                         oGet[4]:Refresh() ),) })                      ;
      VALID EVAL( {|| If( oDp:Buscar( aLS[3],"nroiden",.t. )          ,;
                        ( aLS[4] := oApl:oHis:NRO_HISTOR              ,;
                          aLS[5] := oApl:oHis:CODIGO_NIT              ,;
                          oGet[5]:Settext( aLS[4] )                   +;
                          oGet[6]:Settext( XTRIM(oApl:oHis:NOMBRES)   +;
                                           oApl:oHis:APELLIDOS), .t. ),;
                        (MsgStop("Este Paciente no Existe"), .f.) ) } );
      SIZE 44,10 PIXEL RESOURCE "BUSCAR"
   @ 26,96 SAY oGet[5] VAR aLS[4] OF oDlg PIXEL SIZE 130,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 38,10 SAY oGet[6] VAR aLS[7] OF oDlg PIXEL SIZE 130,10 ;
      UPDATE COLOR nRGB( 128,0,255 )

   @ 56, 60 BUTTON oGet[7] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[7]:Disable(), Unificah( aLS ), oGet[7]:Enable(),;
        oGet[7]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 56,110 BUTTON oGet[8] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 62, 02 SAY "[HISPASAR]" OF oDlg PIXEL SIZE 34,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT ( Empresa( .t. ) )
oDp:NEW( "FIN" )
RETURN

//------------------------------------//
PROCEDURE Unificah( aLS )
   LOCAL aRes, cQry, cWhe, nL, nCtl := 0, hRes
cWhe := " WHERE optica    = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND nro_histor = [HIS]"                       +;
         " AND control    = [CTL]"
cQry := "SELECT fecha, nro_histor, control FROM hiscntrl"+;
        " WHERE optica = " + LTRIM(STR(oApl:nEmpresa))   +;
         " AND nro_histor IN(" + LTRIM(STR(aLS[2]))      +;
                           "," + LTRIM(STR(aLS[4]))      +;
         " ) ORDER BY fecha DESC"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aRes[2] # aLS[2] .OR.;
      aRes[3] # nL
      cQry := "UPDATE hiscntrl SET control = " + LTRIM(STR(nL))
      If aRes[2] # aLS[2]
         cQry += ", nro_histor = " + LTRIM(STR(aLS[2]))
      EndIf
      cQry += STRTRAN( cWhe,"[HIS]",LTRIM(STR(aRes[2])) )
      cQry := STRTRAN( cQry,"[CTL]",LTRIM(STR(aRes[3])) )
      nCtl ++
  //  MsgInfo( cQry,STR(aRes[3]) )
      Guardar( cQry,"hiscntrl" )
      Guardar( STRTRAN( cQry,"hiscntrl","hisdiagn" ),"hisdiagn" )
      Guardar( STRTRAN( cQry,"hiscntrl","hisagvis" ),"hisagvis" )
      Guardar( STRTRAN( cQry,"hiscntrl","hisexame" ),"hisexame" )
      Guardar( STRTRAN( cQry,"hiscntrl","hisquera" ),"hisquera" )
      Guardar( STRTRAN( cQry,"hiscntrl","hisretin" ),"hisretin" )
      Guardar( STRTRAN( cQry,"hiscntrl","hisoftal" ),"hisoftal" )
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
If nCtl > 0
   cQry := "UPDATE historia SET nro_histor = 0"+;
              ", apellidos = 'ZZZZZZZZZZZZZZZ'"+;
                ", nombres = 'ZZZZZZZZZZZZZZZ'"+;
                  ", papel = 15, pnomb = 15 "  +;
           "WHERE codigo_nit = " + LTRIM(STR(aLS[5]))
 //MsgInfo( cQry )
   Guardar( cQry,"historia" )
   If aLS[2] > aLS[4]
      oApl:oAna:Seek( {"nro_histor",aLS[4]} )
      cQry := "UPDATE historic SET fec_histor = " + xValToChar( oApl:oAna:FEC_HISTOR )+;
             " WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
           " AND nro_histor = " + LTRIM(STR(aLS[2]))
      Guardar( cQry,"historic" )
   EndIf
   cQry := "DELETE FROM historic "+;
           "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
        " AND nro_histor = " + LTRIM(STR(aLS[4]))
   Guardar( cQry,"historic" )
EndIf
RETURN