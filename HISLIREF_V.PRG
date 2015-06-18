// Programa.: HISLIREF.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Modulo para listar la Historia Clinica
#include "FiveWin.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE HisLiRef( nHis,nCtl,nP,lRxf )
   LOCAL aHC, oBtn, oDlg, oLF, lSI := .f.
   DEFAULT nCtl := 0, nP := 1
oLF := TExamen()
DEFINE DIALOG oDlg TITLE "Listar HISTORIA CLINICA"
   @ 02,62 CHECKBOX oLF:lPrev PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,10 PIXEL
   @ 14,00 SAY "TIPO DE IMPRESORA" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 14,62 COMBOBOX oLF:aLS[1] ITEMS { "Matriz","Laser" };
      SIZE 48,90 OF oDlg PIXEL

   @ 38,70 BUTTON oBtn PROMPT "Imprimir" SIZE 44,12 ;
      ACTION ( lSI := .t., oDlg:End() ) OF oDlg PIXEL
ACTIVATE DIALOG oDlg CENTER
If lSI
   oApl:aTit  := {.f.}
   oLF:aLS[3] := "HISTORIA CLINICA No. " + STR(nHis)
   oLF:aLS[4] := XTRIM(oApl:oHis:APELLIDOS) + TRIM(oApl:oHis:NOMBRES)
   oLF:aLS[5] := Buscar( {"codigo",oApl:oHis:OCUPACION},"ridocupa","nombre",8 )
   oLF:aHC    := {.f.,If( EMPTY(oApl:oHis:FEC_NACIMI), STR(oApl:oHis:EDAD),;
                          STR(NtChr( oApl:oHis:FEC_NACIMI,"A" ),4) )      +;
                      If( oApl:oHis:UNIEDAD == "1", " Años"               ,;
                      If( oApl:oHis:UNIEDAD == "2", " Meses", " Dias" )) }
   oLF:nCtl   := oLF:nCtrl := nCtl
   oLF:nHis   := nHis
   oApl:oHab:Seek( {"codigo",oApl:oHis:RESHABIT} )
   If oLF:aLS[1] == 1
      aHC := { {|| oLF:DHClinica() },{|| oLF:DHisLCont() },;
               {|| oLF:DHisRxFin( lRxf ) } }
      EVAL( aHC[ nP ] )
      oLF:oPrn:NewPage()
      oLF:oPrn:End()
   Else
      aHC := { {|| oLF:WHClinica() },{|| oLF:WHisLCont() },;
               {|| oLF:WHisRxFin( lRxf ) } }
      oLF:Init( oLF:aLS[3], .f. ,, !oLF:lPrev ,,, oLF:lPrev, 5 )
      oLF:aEnc := { .t.,0 }
      PAGE
         EVAL( aHC[ nP ] )
      ENDPAGE
      oLF:EndInit( .F. )
   EndIf
EndIf
RETURN

//------------------------------------//
CLASS TExamen FROM TIMPRIME

 DATA aHC, nCtl, nCtrl, nHis
 DATA aLS  AS ARRAY INIT { oApl:nTFor,"Arial","","","" }
 DATA lPrev   INIT .t.

  METHOD DHClinica()
  METHOD WHClinica()
  METHOD DHisLCont()
  METHOD WHisLCont()
  METHOD DHisRxFin( lRxf )
  METHOD WHisRxFin( lRxf )
  METHOD AGVisual( cBusca,nH )
  METHOD Queratom( cBusca,nH )
  METHOD RetinosC( cBusca,nH )
  METHOD OftalMos( cBusca,nH )
  METHOD Diagnost( nH )
  METHOD Diagnosw( nH )
  METHOD ImpLine( aLinea,nS )
  METHOD ImpLinw( aLinea,nS )
  METHOD ImpMemo( cMsg,mObser,nA,nH )
  METHOD ImpRaya( lSi )
  METHOD Cabecera( lSep,nSpace,nSuma )
  METHOD Query( aBus,nH )
ENDCLASS

//------------------------------------//
METHOD DHClinica() CLASS TExamen
   LOCAL aKey
::oPrn := TDosPrint()
::oPrn:New( oApl:cPuerto,oApl:cImpres,{::aLS[3],::aLS[4]},::lPrev,,,,,78 )
//METHOD New( cPort,cPrinter,aHea,lPreview,nPgI,nFt,nInches,nLength,nWidth,;
//            nLeft,nRight,nTop,nBottom,nAlign ) CLASS TDosPrint
::oPrn:Titulo()
::oPrn:cFont := ::oPrn:CPICompress
::oPrn:Say( ::oPrn:nL  ,01,"Doc.Identidad: "+oApl:oHis:TIPOIDEN+" - "+oApl:oHis:NROIDEN )
::oPrn:Say( ::oPrn:nL++,84,"   Fecha : "+NtChr( oApl:oAna:FEC_HISTOR,"2" ) )
::oPrn:Say( ::oPrn:nL  ,01,"      Nombre : "+::oPrn:aEnc[2] )
::oPrn:Say( ::oPrn:nL++,84,"    Edad : "    + ::aHC[2] )
::oPrn:Say( ::oPrn:nL++,01,"        Sexo : "+;
          If( oApl:oHis:SEXO == "M", "Masculino", "Femenino" ) )
//::oPrn:Say( ::oPrn:nL++,80,"Tipo Usuario : "+ArrayValor( oApl:oHis:aTipoU,oApl:oHis:TIPOUSUA ) )
// { "Contributivo","Subsidiado","Vinculado","Particular","Otro" }[]
::oPrn:Say( ::oPrn:nL  ,01,"   Dirección : "+oApl:oHis:DIRECCION )
::oPrn:Say( ::oPrn:nL++,84,"Tel.Res. : "+oApl:oHis:TEL_RESIDE )
::oPrn:Say( ::oPrn:nL  ,01,"      Ciudad : "+oApl:oHis:RESHABIT+"  -  "+oApl:oHab:NOMBRE )
::oPrn:Say( ::oPrn:nL++,84,"Tel.Ofi. : "+oApl:oHis:TEL_OFICIN )
::oPrn:Say( ::oPrn:nL  ,01,"   Profesión : "+ ::aLS[5] )
::oPrn:Say( ::oPrn:nL++,80,"Zona Residen : "+;
          If( oApl:oHis:ZONARESI == "U", "Urbano", "Rural" ) )
::oPrn:Say( ::oPrn:nL++,16,oApl:oHis:EMAIL )
::oPrn:Say( ::oPrn:nL++,01,"    Referido : "+oApl:oAna:OBSERV_HIS )
::oPrn:cFont := ::oPrn:CPINormal
If RIGHT( DTOS(oApl:oHis:FEC_NACIMI),4 ) == RIGHT( DTOS(DATE()),4 )
   ::oPrn:Say( ::oPrn:nL++,01,"FELIZ CUMPLEA\OS",80,2 )
EndIf
::oPrn:Say( ::oPrn:nL++,01,"        ANAMNESIS" )
::ImpMemo( "Antecedentes Personales:",oApl:oAna:APERSONAL,,2 )
::ImpMemo( "Antecedentes Familiares:",oApl:oAna:AFAMILIAR,,2 )
::ImpLine( {01,"","Estado Refractivo Ojo  Derecho :",0,;
            34,"",oApl:oAna:ESTREFOD,1 } )
::ImpLine( {01,"","Estado Refractivo Ojo Izquierdo:",0,;
            34,"",oApl:oAna:ESTREFOI,1 } )

While !oApl:oCtl:EOF()
   ::nCtrl := oApl:oCtl:CONTROL
   aKey := { "optica",oApl:nEmpresa,"nro_histor",::nHis,"control",::nCtrl }
   ::ImpLine( {01,::oPrn:CPIBold+"Fecha del Examen : ",NtChr( oApl:oCtl:FECHA,"2" ),1, ;
               34,"Control No.",STR(oApl:oCtl:CONTROL),1 } )
   ::ImpLine( {01,"","  Doctor(a) :",0, 15,"",oApl:oCtl:DOCTOR  ,1 },1 )
   ::ImpLine( {01,"","Acompañante :",0, 15,"",oApl:oCtl:FAMILIAR,1 },0 )
   ::ImpLine( {01,"","   Telefono :",0, 15,"",oApl:oCtl:TELEFONO,1 },1 )
   If !EMPTY( oApl:oCtl:MOTIVO_CON )
      ::ImpLine( {01,"","MOTIVO DE LA CONSULTA",1 } )
      ::ImpMemo( "Signos y Sintomas",oApl:oCtl:MOTIVO_CON )
   EndIf
   ::AGVisual( aKey,0 )
   If oApl:oExa:Seek( aKey )
      ::ImpMemo( "EXAMEN EXTERNO",oApl:oExa:EXAMEN_EXT )
      ::ImpLine( {03,"","Presión Intraocular",0, ;
                  24,"O.D.:",oApl:oExa:ODPINTRAOC ,1, ;
                  34,"O.I.:",oApl:oExa:OIPINTRAOC ,1 } )
      ::ImpRaya( .f. )
   EndIf
   ::Queratom( aKey,0 )
   ::RetinosC( aKey,0 )
   ::OftalMos( aKey,0 )
   ::Diagnost( 0 )
   oApl:aTit := { .f. }
   ::aHC := { .f. }
   If ::nCtl > 0
      ::nCtl ++
      EXIT
   EndIf
   ::oPrn:nL += If( ::oPrn:nL < ::oPrn:nLength, 1, 0 )
   oApl:oCtl:Skip(1):Read()
   oApl:oCtl:xLoad()
EndDo
If ::nCtl == 0 .OR. ::nCtl == oApl:oCtl:CONTROL
   ::nCtrl ++
   aKey := { "optica",oApl:nEmpresa,"nro_histor",::nHis,"control",::nCtrl }
   ::ImpLine( {01,"Fecha del Examen :",NtChr( DATE(),"2" ),1, ;
               32,"Control No.",STR(::nCtrl),1 } )
   ::ImpLine( {01,"","Acompañante :",1 },0 )
   ::ImpLine( {01,"","   Telefono :",1 },1 )
   ::ImpLine( {01,"","MOTIVO DE LA CONSULTA",1 } )
   ::ImpLine( {02,"","Signos y Sintomas",1 },3 )
   ::ImpLine( {01,"",REPLICATE("-",::oPrn:nWidth),1 } )
   ::AGVisual( aKey,1 )
   ::ImpLine( {02,"","EXAMEN EXTERNO",1 },2 )
   ::ImpLine( {03,"","Presión Intraocular",1, ;
               24,"","O.D.:",1, 34,"","O.I.:",1 } )
   ::ImpRaya( .f. )
   ::Queratom( aKey,1 )
   ::RetinosC( aKey,1 )
//   ::OftalMos( aKey,1 )
   ::Diagnost( 1 )
   oApl:aTit := {.f.}
   ::aHC := {.f.}
   ::oPrn:nL += 4
   ::ImpLine( {50,"","Firma",1, ;
               55,"",REPLICATE("_",15),1 } )
EndIf
RETURN NIL

//------------------------------------//
METHOD WHClinica() CLASS TExamen
   LOCAL aKey
 ::Cabecera( .t.,0.45 )
 UTILPRN ::oUtil SELECT ::aFnt[5]
 UTILPRN ::oUtil  4.0, 2.5 SAY "Doc.Identidad: " RIGHT
 UTILPRN ::oUtil  4.0, 2.7 SAY oApl:oHis:TIPOIDEN+" - "+oApl:oHis:NROIDEN
 UTILPRN ::oUtil  4.0,14.3 SAY        "Fecha : " RIGHT
 UTILPRN ::oUtil  4.0,14.5 SAY NtChr( oApl:oAna:FEC_HISTOR,"2" )
 UTILPRN ::oUtil  4.5, 2.5 SAY       "Nombre : " RIGHT
 UTILPRN ::oUtil  4.5, 2.7 SAY ::aLS[4]
 UTILPRN ::oUtil  4.5,14.3 SAY         "Edad : " RIGHT
 UTILPRN ::oUtil  4.5,14.5 SAY ::aHC[2]
 UTILPRN ::oUtil  5.0, 2.5 SAY         "Sexo : " RIGHT
 UTILPRN ::oUtil  5.0, 2.7 SAY If( oApl:oHis:SEXO == "M", "Masculino", "Femenino" )
 UTILPRN ::oUtil  5.5, 2.5 SAY    "Dirección : " RIGHT
 UTILPRN ::oUtil  5.5, 2.7 SAY oApl:oHis:DIRECCION
 UTILPRN ::oUtil  5.5,14.3 SAY     "Tel.Res. : " RIGHT
 UTILPRN ::oUtil  5.5,14.5 SAY oApl:oHis:TEL_RESIDE
 UTILPRN ::oUtil  6.0, 2.5 SAY       "Ciudad : " RIGHT
 UTILPRN ::oUtil  6.0, 2.7 SAY oApl:oHis:RESHABIT+"  -  "+oApl:oHab:NOMBRE
 UTILPRN ::oUtil  6.0,14.3 SAY     "Tel.Ofi. : " RIGHT
 UTILPRN ::oUtil  6.0,14.5 SAY oApl:oHis:TEL_OFICIN
 UTILPRN ::oUtil  6.5, 2.5 SAY    "Profesión : " RIGHT
 UTILPRN ::oUtil  6.5, 2.7 SAY ::aLS[5]
 UTILPRN ::oUtil  6.5,14.3 SAY "Zona Residen : " RIGHT
 UTILPRN ::oUtil  6.5,14.5 SAY If( oApl:oHis:ZONARESI == "U", "Urbano", "Rural" )
 UTILPRN ::oUtil  7.0, 2.5 SAY oApl:oHis:EMAIL
 UTILPRN ::oUtil  7.5, 2.5 SAY     "Referido : " RIGHT
 UTILPRN ::oUtil  7.5, 2.7 SAY oApl:oAna:OBSERV_HIS
 ::nLinea := 8.0
 UTILPRN ::oUtil SELECT ::aFnt[2]
If RIGHT( DTOS(oApl:oHis:FEC_NACIMI),4 ) == RIGHT( DTOS(DATE()),4 )
   UTILPRN ::oUtil Self:nLinea,10.5 SAY "FELIZ CUMPLEAÑOS"
   ::nLinea += 0.5
EndIf
UTILPRN ::oUtil Self:nLinea, 2.7 SAY "ANAMNESIS"
::ImpMemo( "Antecedentes Personales:",oApl:oAna:APERSONAL,,0.5 )
::ImpMemo( "Antecedentes Familiares:",oApl:oAna:AFAMILIAR,,0.5 )
::ImpLinw( {0.5,"","Estado Refractivo Ojo  Derecho :",0,;
            9.0,"",oApl:oAna:ESTREFOD,1 } )
::ImpLinw( {0.5,"","Estado Refractivo Ojo Izquierdo:",0,;
            9.0,"",oApl:oAna:ESTREFOI,1 } )
While !oApl:oCtl:EOF()
   ::nCtrl := oApl:oCtl:CONTROL
   aKey := { "optica",oApl:nEmpresa,"nro_histor",::nHis,"control",::nCtrl }
   UTILPRN ::oUtil SELECT ::aFnt[1]
   ::ImpLinw( {0.5,"Fecha del Examen : ",NtChr( oApl:oCtl:FECHA,"2" ),1, ;
               9.0,"Control No.",STR(oApl:oCtl:CONTROL),1 } )
   UTILPRN ::oUtil SELECT ::aFnt[2]
   ::ImpLinw( {0.5,"","  Doctor(a) :",0, 4.2,"",oApl:oCtl:DOCTOR  ,1 },0.5 )
   ::ImpLinw( {0.5,"","Acompañante :",0, 4.2,"",oApl:oCtl:FAMILIAR,1 },0 )
   ::ImpLinw( {0.5,"","   Telefono :",0, 4.2,"",oApl:oCtl:TELEFONO,1 },0.5 )
   If !EMPTY( oApl:oCtl:MOTIVO_CON )
      ::ImpLinw( {0.5,"","MOTIVO DE LA CONSULTA",1 } )
      ::ImpMemo( "Signos y Sintomas",oApl:oCtl:MOTIVO_CON )
   EndIf
   ::AGVisual( aKey,0 )
   If oApl:oExa:Seek( aKey )
      ::ImpMemo( "EXAMEN EXTERNO",oApl:oExa:EXAMEN_EXT )
      ::ImpLinw( {1.0,"","Presión Intraocular",0, ;
                  6.4,"O.D.:",oApl:oExa:ODPINTRAOC ,1, ;
                  9.0,"O.I.:",oApl:oExa:OIPINTRAOC ,1 } )
      ::ImpRaya( .f. )
   EndIf
   ::Queratom( aKey,0 )
   ::RetinosC( aKey,0 )
   ::OftalMos( aKey,0 )
   ::Diagnosw( 0 )
   oApl:aTit := { .f. }
   ::aHC := { .f. }
   If ::nCtl > 0
      ::nCtl ++
      EXIT
   EndIf
   ::nLinea += If( ::nLinea  < ::nEndLine, 0.5, 0 )
   oApl:oCtl:Skip(1):Read()
   oApl:oCtl:xLoad()
EndDo
If ::nCtl == 0 .OR. ::nCtl == oApl:oCtl:CONTROL
   ::nCtrl ++
   aKey := { "optica",oApl:nEmpresa,"nro_histor",::nHis,"control",::nCtrl }
   UTILPRN ::oUtil SELECT ::aFnt[1]
   ::ImpLinw( {0.5,"Fecha del Examen : ",NtChr( DATE(),"2" ),1, ;
               9.0,"Control No.",STR(::nCtrl),1 } )
   UTILPRN ::oUtil SELECT ::aFnt[2]
   ::ImpLinw( {0.5,"","Acompañante :",1 },0 )
   ::ImpLinw( {0.5,"","   Telefono :",1 },0.5 )
   ::ImpLinw( {0.5,"","MOTIVO DE LA CONSULTA",1 } )
   ::ImpLinw( {0.8,"","Signos y Sintomas",1 },1.5 )
   ::ImpRaya( .f. )
   ::AGVisual( aKey,1 )
   ::ImpLinw( {0.8,"","EXAMEN EXTERNO",1 },2 )
   ::ImpLinw( {1.0,"","Presión Intraocular",1, ;
               6.4,"","O.D.:",1, 34,"","O.I.:",1 } )
   ::ImpRaya( .f. )
   ::Queratom( aKey,1 )
   ::RetinosC( aKey,1 )
//   ::OftalMos( aKey,1 )
   ::Diagnosw( 1 )
   oApl:aTit := {.f.}
   ::aHC := {.f.}
   ::nLinea += 2
   ::ImpLinw( {13.0,"","Firma",1, ;
               14.3,"",REPLICATE("_",15),1 } )
EndIf
RETURN NIL

//------------------------------------//
METHOD DHisLCont() CLASS TExamen
   LOCAL aRes, hRes, nL
hRes := ::Query( "C",2 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes ) ; RETURN NIL
EndIf
aRes := MyReadRow( hRes )
AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
::oPrn := TDosPrint()
::oPrn:New( oApl:cPuerto,oApl:cImpres,{ ::aLS[4],;
           "Historial Lentes de Contacto"," F E C H A  EXAMEN #        C u r v a"+;
           "  B a s e  Diametro Esfera Cilindro Eje Adicion AV.Lejos"},::lPrev,,2,,,100 )
::aHC := { .f.,aRes[10],NtChr(aRes[11],"2"),STR(aRes[10],8),aRes[12],aRes[13] }
oApl:aTit  := {.f.}

While nL > 0
   aRes[1] := If( aRes[1] == "A", "A.O.", "O."+aRes[1]+"." )
   aRes[2] := aRes[14] + " " + aRes[2]
   ::ImpLine( {01,"",::aHC[3],0, 13,""   ,::aHC[4],0,;
               24,"", aRes[1],0, 28,""   , aRes[2],1,;
               49,"", aRes[3],1, 57,""   , aRes[4],1,;
               65,"", aRes[5],1, 73,""   , aRes[6],1,;
               79,"", aRes[7],1, 85,"20/", aRes[8],1,;
               94,"", aRes[9],0 } )
   ::aHC[3] := ::aHC[4] := " "
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. ::aHC[2] # aRes[10]
      If !EMPTY(::aHC[6])
         ::aHC[6] := DTOC(::aHC[6])
      EndIf
      ::ImpLine( {21,"","Notas de L.C." ,0, 35,"",::aHC[5] ,1} )
      ::ImpLine( {21,"","Fecha  Compra" ,0, 35,"",::aHC[6] ,1} )
      ::aHC := { .f.,aRes[10],NtChr(aRes[11],"2"),STR(aRes[10],8),aRes[12],aRes[13] }
      ::oPrn:nL ++
   EndIf
EndDo
MSFreeResult( hRes )
RETURN NIL

//------------------------------------//
METHOD WHisLCont() CLASS TExamen
   LOCAL aRes, hRes, nL
hRes := ::Query( "C",2 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes ) ; RETURN NIL
EndIf
aRes := MyReadRow( hRes )
AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
 ::aLS[3] := "Historial Lentes de Contacto" + STR(::nHis)
 ::aEnc := { .t., 0.5           , {  0.9,"F E C H A" },;
             {  2.4,"EXAMEN #" }, {  4.7,"C U R V A  B A S E" },;
             {  7.3,"DIAMETRO" }, {  8.9,"ESFERA" }   ,;
             { 10.1,"CILINDRO" }, { 11.6,"EJE" }      ,;
             { 12.3,"ADICION" } , { 13.6,"AV.LEJOS" } }
::aHC := { .f.,aRes[10],NtChr(aRes[11],"2"),STR(aRes[10],8),aRes[12],aRes[13] }
oApl:aTit  := {.f.}
While nL > 0
   aRes[1] := If( aRes[1] == "A", "A.O.", "O."+aRes[1]+"." )
   aRes[2] := aRes[14] + " " + aRes[2]
   ::ImpLinw( {  0.5,"",::aHC[3],0,  3.0,""   ,::aHC[4],0,;
                 4.0,"", aRes[1],0,  4.9,""   , aRes[2],1,;
                 7.6,"", aRes[3],1,  8.9,""   , aRes[4],1,;
                10.2,"", aRes[5],1, 11.6,""   , aRes[6],1,;
                12.4,"", aRes[7],1, 13.7,"20/", aRes[8],1,;
                14.9,"", aRes[9],0 } )
   ::aHC[3] := ::aHC[4] := " "
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. ::aHC[2] # aRes[10]
      If !EMPTY(::aHC[6])
         ::aHC[6] := DTOC(::aHC[6])
      EndIf
      ::ImpLinw( {2.8,"","Notas de L.C." ,0, 4.9,"",::aHC[5] ,1} )
      ::ImpLinw( {2.8,"","Fecha  Compra" ,0, 4.9,"",::aHC[6] ,1} )
      ::aHC := { .f.,aRes[10],NtChr(aRes[11],"2"),STR(aRes[10],8),aRes[12],aRes[13] }
   EndIf
EndDo
MSFreeResult( hRes )
RETURN NIL

//----------------NRP_LEFT 1,  NRP_RIGHT 2, NRP_CENTER 3-----------------//
METHOD DHisRxFin( lRxf ) CLASS TExamen
   LOCAL aRes, hRes, nL
   DEFAULT lRxf := .t.
If lRxf
   ::aHC := { "R","Historial RX Final","  D.PUPILAR",2,91 }
Else
   ::aHC := { "S","Historial Subjetivos","",1,80 }
EndIf
hRes := ::Query( ::aHC[1],3 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes ) ; RETURN NIL
EndIf
aRes := MyReadRow( hRes )
AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
::oPrn := TDosPrint()
::oPrn:New( oApl:cPuerto,oApl:cImpres,{ ::aLS[4],"   F E C H A  EXAMEN #       ESFERA"+;
            "  CILINDRO  EJE   ADICION  AV.LEJOS  AV.CERCA"+::aHC[3]},::lPrev,,::aHC[4],,,::aHC[5] )
// E C H A   EXAMEN #       ESFERA  CILINDRO  EJE   ADICION  AV.LEJOS  AV.CERCA  D.PUPILAR"
//-SEP/2003  12345678  O.D. 123456   123456   1234   1234    20/1234     1234      123456

::aHC  := { .f.,aRes[10],NtChr(aRes[11],"2"),STR(aRes[10],8) }
oApl:aTit  := {.f.}
While nL > 0
   aRes[1] := If( aRes[1] == "A", "A.O.", "O."+aRes[1]+"." )
   ::ImpLine( {01,"",::aHC[3],0, 14,""   ,::aHC[4],0,;
               24,"", aRes[1],0, 29,""   , aRes[2],1,;
               38,"", aRes[3],1, 47,""   , aRes[4],1,;
               54,"", aRes[5],1, 62,"20/", aRes[6],1,;
               74,"", aRes[7],1, 84,""   , aRes[8],1,;
               93,"", aRes[9],1 } )
   ::aHC[3] := ::aHC[4] := " "
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. ::aHC[2] # aRes[10]
      ::aHC := { .f.,aRes[10],NtChr(aRes[11],"2"),STR(aRes[10],8) }
      ::oPrn:nL ++
   EndIf
EndDo
MSFreeResult( hRes )
RETURN NIL

//------------------------------------//
METHOD WHisRxFin( lRxf ) CLASS TExamen
   LOCAL aRes, hRes, nL
   DEFAULT lRxf := .t.
If lRxf
   ::aHC := { "R","Historial RX Final","D.PUPILAR" }
Else
   ::aHC := { "S","Historial Subjetivos","" }
EndIf
hRes := ::Query( ::aHC[1],3 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes ) ; RETURN NIL
EndIf
aRes := MyReadRow( hRes )
AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
oApl:aTit := {.f.}
 ::aLS[3] := ::aHC[2] + STR(::nHis)
 ::aEnc := { .t., 0.5           , {  0.9,"F E C H A" },;
             {  2.4,"EXAMEN #" }, {  4.7,"ESFERA" }   ,;
             {  6.0,"CILINDRO" }, {  7.6,"EJE" }      ,;
             {  8.3,"ADICION" } , {  9.8,"AV.LEJOS" } ,;
             { 11.4,"AV.CERCA" }, { 13.1,::aHC[3] } }
 ::aHC  := { .f.,aRes[10],NtChr(aRes[11],"2"),STR(aRes[10],8) }
While nL > 0
   aRes[1] := If( aRes[1] == "A", "A.O.", "O."+aRes[1]+"." )
   ::ImpLinw( { 0.5,"",::aHC[3],0,  3.0,""   ,::aHC[4],0,;
                4.0,"", aRes[1],0,  4.7,""   , aRes[2],1,;
                6.2,"", aRes[3],1,  7.6,""   , aRes[4],1,;
                8.5,"", aRes[5],1, 10.0,"20/", aRes[6],1,;
               11.6,"", aRes[7],1, 13.7,""   , aRes[8],1,;
               14.5,"", aRes[9],1 } )
   ::aHC[3] := ::aHC[4] := " "
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. ::aHC[2] # aRes[10]
      ::aHC := { .f.,aRes[10],NtChr(aRes[11],"2"),STR(aRes[10],8) }
   EndIf
EndDo
MSFreeResult( hRes )
RETURN NIL

//------------------------------------//
METHOD AGVisual( cBusca,nH ) CLASS TExamen
If oApl:oAgv:Seek( cBusca ) .OR. nH == 1
      oApl:aTit := {.f.}
   If ::aLS[1] == 1
      ::oPrn:Titulo()
      ::oPrn:Say( ::oPrn:nL++,01,"AGUDEZA VISUAL Y CORRECION EN USO" )
      ::aHC := {.t.,27,"AV.Lejos   Pin Hole   AV.Cerca"}
      ::ImpLine( {06,"","Sin Corrección",nH, 22,"","O.D.",0, ;
                  27,"20/",oApl:oAgv:SCAVLOD ,1 , 38,"20/",oApl:oAgv:SCAVLODPH,1, ;
                  50,"",oApl:oAgv:SCAVCOD    ,1 } )
      ::ImpLine( {22,"","O.I."          ,nH, ;
                  27,"20/",oApl:oAgv:SCAVLOI ,1 , 38,"20/",oApl:oAgv:SCAVLOIPH,1, ;
                  50,"",oApl:oAgv:SCAVCOI    ,1 } )
      ::ImpLine( {22,"","A.O."          ,nH, ;
                  27,"20/",oApl:oAgv:SCAVLAO ,1 , 38,"20/",oApl:oAgv:SCAVLAOPH,1, ;
                  50,"",oApl:oAgv:SCAVCAO    ,1 } )
      ::ImpLine( {06,"","Con Corrección",nH, 22,"","O.D.",0, ;
                  27,"20/",oApl:oAgv:CCAVLOD ,1 , 50,"",oApl:oAgv:CCAVCOD,1 } )
      ::ImpLine( {22,"","O.I."          ,nH, ;
                  27,"20/",oApl:oAgv:CCAVLOI ,1 , 50,"",oApl:oAgv:CCAVCOI,1 } )
      ::ImpLine( {22,"","A.O."          ,nH, ;
                  27,"20/",oApl:oAgv:CCAVLAO ,1 , 50,"",oApl:oAgv:CCAVCAO,1 } )
      ::ImpMemo( "Notas de Agudeza Visual",oApl:oAgv:OBSERV_AV,,nH )
      ::ImpRaya( ::aHC[1] )

      oApl:aTit  := {.t.,4,"Lensometría"}
      ::aHC := {.t.,26,"Esfera  Cilindro  Eje  Adición"}
      ::ImpLine( {17,"","VL. O.D."     ,nH, ;
                  26,"",oApl:oAgv:LOVLODESF,1 , 35,"",oApl:oAgv:LOVLODCIL,1, ;
                  44,"",oApl:oAgv:LOVLODEJE,1 } )
      ::ImpLine( {17,"","VL. O.I."     ,nH, ;
                  26,"",oApl:oAgv:LOVLOIESF,1 , 35,"",oApl:oAgv:LOVLOICIL,1, ;
                  44,"",oApl:oAgv:LOVLOIEJE,1 } )
      ::ImpLine( {17,"","VP. O.D."     ,nH, ;
                  26,"",oApl:oAgv:LOVPODESF,1 , 35,"",oApl:oAgv:LOVPODCIL,1, ;
                  44,"",oApl:oAgv:LOVPODEJE,1 , 50,"",oApl:oAgv:LOODADD  ,1 } )
      ::ImpLine( {17,"","VP. O.I."     ,nH, ;
                  26,"",oApl:oAgv:LOVPOIESF,1 , 35,"",oApl:oAgv:LOVPOICIL,1, ;
                  44,"",oApl:oAgv:LOVPOIEJE,1 , 50,"",oApl:oAgv:LOOIADD  ,1 } )
      ::ImpLine( {07,"","Tipo de Lente",nH,     21,"",oApl:oAgv:LOTIPO   ,1 } )
      ::ImpRaya( ::aHC[1] )

      oApl:aTit := {.t.,02,"L.Contacto en uso"}
      ::aHC := {.t.,27,"Cva.Base  Poder   Diámetro Cva.Periférica"}
      ::ImpLine( {22,"","O.D."         ,nH, ;
                  28,"",oApl:oAgv:ODCURVABAS,1 , 37,"",oApl:oAgv:ODPODER ,1, ;
                  46,"",oApl:oAgv:ODDIAMETRO,1 , 58,"",oApl:oAgv:ODCURVAP,1 } )
      ::ImpLine( {22,"","O.I."         ,nH, ;
                  28,"",oApl:oAgv:OICURVABAS, 1, 37,"",oApl:oAgv:OIPODER ,1, ;
                  26,"",oApl:oAgv:OIDIAMETRO, 1, 58,"",oApl:oAgv:OICURVAP,1 } )
      ::ImpLine( {13,"","Tipo de Lente",nH, 28,"",oApl:oAgv:TIPOLC  ,1 } )
   Else
      ::Cabecera( .t.,0.45,1 )
      UTILPRN ::oUtil Self:nLinea, 0.5 SAY "AGUDEZA VISUAL Y CORRECION EN USO"
      ::aHC := {.t.,7.2,"AV.Lejos   Pin Hole   AV.Cerca"}
      ::ImpLinw( { 1.9,"","Sin Corrección"     ,nH,  5.9,"","O.D.",0, ;
                   7.2,"20/",oApl:oAgv:SCAVLOD ,1 ,  9.0,"20/",oApl:oAgv:SCAVLODPH,1,;
                  10.7,"",oApl:oAgv:SCAVCOD    ,1 } )
      ::ImpLinw( { 5.9,"","O.I."               ,nH, ;
                   7.2,"20/",oApl:oAgv:SCAVLOI ,1 ,  9.0,"20/",oApl:oAgv:SCAVLOIPH,1,;
                  10.7,"",oApl:oAgv:SCAVCOI    ,1 } )
      ::ImpLinw( { 5.9,"","A.O."               ,nH, ;
                   7.2,"20/",oApl:oAgv:SCAVLAO ,1 ,  9.0,"20/",oApl:oAgv:SCAVLAOPH,1,;
                  10.7,"",oApl:oAgv:SCAVCAO    ,1 } )
      ::ImpLinw( { 1.9,"","Con Corrección"     ,nH,  5.9,"","O.D.",0, ;
                   7.2,"20/",oApl:oAgv:CCAVLOD ,1 , 10.7,"",oApl:oAgv:CCAVCOD,1 } )
      ::ImpLinw( { 5.9,"","O.I."               ,nH, ;
                   7.2,"20/",oApl:oAgv:CCAVLOI ,1 , 10.7,"",oApl:oAgv:CCAVCOI,1 } )
      ::ImpLinw( { 5.9,"","A.O."               ,nH, ;
                   7.2,"20/",oApl:oAgv:CCAVLAO ,1 , 10.7,"",oApl:oAgv:CCAVCAO,1 } )
      ::ImpMemo( "Notas de Agudeza Visual",oApl:oAgv:OBSERV_AV,,nH )
      ::ImpRaya( ::aHC[1] )

      oApl:aTit := {.t.,1.3,"Lensometría"}
      ::aHC := {.t.,6.9,"Esfera  Cilindro    Eje  Adición"}
      ::ImpLinw( { 4.7,"","VL. O.D."         ,nH, ;
                   6.9,"",oApl:oAgv:LOVLODESF,1 ,  8.3,"",oApl:oAgv:LOVLODCIL,1, ;
                   9.7,"",oApl:oAgv:LOVLODEJE,1 } )
      ::ImpLinw( { 4.7,"","VL. O.I."         ,nH, ;
                   6.9,"",oApl:oAgv:LOVLOIESF,1 ,  8.3,"",oApl:oAgv:LOVLOICIL,1, ;
                   9.7,"",oApl:oAgv:LOVLOIEJE,1 } )
      ::ImpLinw( { 4.7,"","VP. O.D."         ,nH, ;
                   6.9,"",oApl:oAgv:LOVPODESF,1 ,  8.3,"",oApl:oAgv:LOVPODCIL,1, ;
                   9.7,"",oApl:oAgv:LOVPODEJE,1 , 10.4,"",oApl:oAgv:LOODADD  ,1 } )
      ::ImpLinw( { 4.7,"","VP. O.I."         ,nH, ;
                   6.9,"",oApl:oAgv:LOVPOIESF,1 ,  8.3,"",oApl:oAgv:LOVPOICIL,1, ;
                   9.7,"",oApl:oAgv:LOVPOIEJE,1 , 10.4,"",oApl:oAgv:LOOIADD  ,1 } )
      ::ImpLinw( { 1.9,"","Tipo de Lente"    ,nH,  4.7,"",oApl:oAgv:LOTIPO   ,1 } )
      ::ImpRaya( ::aHC[1] )

      oApl:aTit := {.t.,0.8,"L.Contacto en uso"}
      ::aHC := {.t., 7.2,"Cva.Base   Poder   Diámetro Cva.Periférica"}
      ::ImpLinw( { 5.9,"","O.D."              ,nH, ;
                   7.5,"",oApl:oAgv:ODCURVABAS,1 ,  9.0,"",oApl:oAgv:ODPODER ,1, ;
                  10.5,"",oApl:oAgv:ODDIAMETRO,1 , 12.5,"",oApl:oAgv:ODCURVAP,1 } )
      ::ImpLinw( { 5.9,"","O.I."              ,nH, ;
                   7.5,"",oApl:oAgv:OICURVABAS, 1,  9.0,"",oApl:oAgv:OIPODER ,1, ;
                  10.5,"",oApl:oAgv:OIDIAMETRO, 1, 12.5,"",oApl:oAgv:OICURVAP,1 } )
      ::ImpLinw( { 3.6,"","Tipo de Lente"     ,nH,  7.5,"",oApl:oAgv:TIPOLC  ,1 } )
      nH    -= 0.5
   EndIf
      ::ImpMemo( "Notas de L.C.",oApl:oAgv:OBSERV_RXU,,nH )
      ::ImpRaya( ::aHC[1] )
EndIf
RETURN NIL

//------------------------------------//
METHOD Queratom( cBusca,nH ) CLASS TExamen
If oApl:oQue:Seek( cBusca ) .OR. nH == 1
      oApl:aTit := {.f.}
   If ::aLS[1] == 1
      ::oPrn:Titulo()
      ::oPrn:Say( ::oPrn:nL++,01,"QUERATOMETRIA" )
      ::aHC := {.t.,21,"PLANO   CURVO   EJE"}
      ::ImpLine( {16,"","O.D."      ,nH, 21,"",oApl:oQue:ODPLANO,1 ,;
                  29,"",oApl:oQue:ODCURVO, 1, 37,"",oApl:oQue:ODEJE  ,1 } )
      ::ImpLine( {16,"","O.I."      ,nH, 21,"",oApl:oQue:OIPLANO,1 ,;
                  29,"",oApl:oQue:OICURVO, 1, 37,"",oApl:oQue:OIEJE  ,1 } )
      ::ImpLine( {12,""," Miras :"  ,nH, 21,"",oApl:oQue:MIRAS  ,1 } )
      ::ImpLine( {12,"","Equipo :"  ,nH, 21,"",oApl:oQue:EQUIPO ,1 } )
   Else
      ::Cabecera( .t.,0.45,1 )
      UTILPRN ::oUtil Self:nLinea, 0.5 SAY "QUERATOMETRIA"
      ::aHC := {.t.,5.6,"PLANO   CURVO   EJE"}
      ::ImpLinw( { 4.4,"","O.D."           ,nH,  5.6,"",oApl:oQue:ODPLANO,1 ,;
                   7.2,"",oApl:oQue:ODCURVO, 1,  8.7,"",oApl:oQue:ODEJE  ,1 } )
      ::ImpLinw( { 4.4,"","O.I."           ,nH,  5.6,"",oApl:oQue:OIPLANO,1 ,;
                   7.2,"",oApl:oQue:OICURVO, 1,  8.7,"",oApl:oQue:OIEJE  ,1 } )
      ::ImpLinw( { 3.4,""," Miras :"       ,nH,  5.6,"",oApl:oQue:MIRAS  ,1 } )
      ::ImpLinw( { 3.4,"","Equipo :"       ,nH,  5.6,"",oApl:oQue:EQUIPO ,1 } )
      nH    -= 0.5
   EndIf
      ::ImpMemo( "Notas de Queratometría",oApl:oQue:OBSERV_OT,,nH )
      ::ImpRaya( ::aHC[1] )
EndIf
RETURN NIL

//------------------------------------//
METHOD RetinosC( cBusca,nH ) CLASS TExamen
If oApl:oRet:Seek( cBusca ) .OR. nH == 1
   If ::aLS[1] == 1
      ::oPrn:Titulo()
      ::oPrn:Say( ::oPrn:nL++,01,"RETINOSCOPIA" )
      oApl:aTit := {.t.,04,"Estática"}
      ::aHC := {.t.,21,"Esfera  Cilindro  Eje   AV.Lejos  AV.Cerca"}
      ::ImpLine( {16,"","O.D."       ,nH, 21,"",oApl:oRet:ESTODESF,1 ,;
                  30,"",oApl:oRet:ESTODCIL, 1, 39,"",oApl:oRet:ESTODEJE,1 ,;
                  47,"",oApl:oRet:ESTODAVL, 1, 57,"",oApl:oRet:ESTODAVC,1 } )
      ::ImpLine( {16,"","O.I."       ,nH, 21,"",oApl:oRet:ESTOIESF,1 ,;
                  30,"",oApl:oRet:ESTOICIL, 1, 39,"",oApl:oRet:ESTOIEJE,1 ,;
                  47,"",oApl:oRet:ESTOIAVL, 1, 57,"",oApl:oRet:ESTOIAVC,1 } )
      oApl:aTit := {.t.,04,"Dinámica"}
      ::ImpLine( {16,"","O.D."       ,nH, 21,"",oApl:oRet:DINODESF,1 ,;
                  30,"",oApl:oRet:DINODCIL, 1, 39,"",oApl:oRet:DINODEJE,1 ,;
                  47,"",oApl:oRet:DINODAVL, 1, 57,"",oApl:oRet:DINODAVC,1 } )
      ::ImpLine( {16,"","O.I."       ,nH, 21,"",oApl:oRet:DINOIESF,1 ,;
                  30,"",oApl:oRet:DINOICIL, 1, 39,"",oApl:oRet:DINOIEJE,1 ,;
                  47,"",oApl:oRet:DINOIAVL, 1, 57,"",oApl:oRet:DINOIAVC,1 } )
   Else
      ::Cabecera( .t.,0.45,1 )
      UTILPRN ::oUtil Self:nLinea, 0.5 SAY "RETINOSCOPIA"
      oApl:aTit := {.t.,1.4,"Estática"}
      ::aHC := {.t.,5.6,"Esfera       Cilindro     Eje      AV.Lejos    AV.Cerca"}
      ::ImpLinw( { 4.4,"","O.D."            ,nH,  5.6,"",oApl:oRet:ESTODESF,1 ,;
                   7.6,"",oApl:oRet:ESTODCIL, 1,  9.1,"",oApl:oRet:ESTODEJE,1 ,;
                  10.5,"",oApl:oRet:ESTODAVL, 1, 12.3,"",oApl:oRet:ESTODAVC,1 } )
      ::ImpLinw( { 4.4,"","O.I."            ,nH,  5.6,"",oApl:oRet:ESTOIESF,1 ,;
                   7.6,"",oApl:oRet:ESTOICIL, 1,  9.1,"",oApl:oRet:ESTOIEJE,1 ,;
                  10.5,"",oApl:oRet:ESTOIAVL, 1, 12.3,"",oApl:oRet:ESTOIAVC,1 } )
      oApl:aTit := {.t.,1.4,"Dinámica"}
      ::ImpLinw( { 4.4,"","O.D."            ,nH,  5.6,"",oApl:oRet:DINODESF,1 ,;
                   7.6,"",oApl:oRet:DINODCIL, 1,  9.1,"",oApl:oRet:DINODEJE,1 ,;
                  10.5,"",oApl:oRet:DINODAVL, 1, 12.3,"",oApl:oRet:DINODAVC,1 } )
      ::ImpLinw( { 4.4,"","O.I."            ,nH,  5.6,"",oApl:oRet:DINOIESF,1 ,;
                   7.6,"",oApl:oRet:DINOICIL, 1,  9.1,"",oApl:oRet:DINOIEJE,1 ,;
                  12.5,"",oApl:oRet:DINOIAVL, 1, 12.3,"",oApl:oRet:DINOIAVC,1 } )
      nH    -= 0.5
   EndIf
      ::ImpMemo( "Notas de Retinoscopia",oApl:oRet:OBSERV_RT,,nH )
      ::ImpRaya( ::aHC[1] )
EndIf
RETURN NIL

//------------------------------------//
METHOD OftalMos( cBusca,nH ) CLASS TExamen
If oApl:oOft:Seek( cBusca ) .OR. nH == 1
      ::aHC     := { .f. }
      oApl:aTit := { .f. }
   If ::aLS[1] == 1
      ::oPrn:Titulo()
      ::oPrn:cFont := ::oPrn:CPICompress
      ::oPrn:Say( ::oPrn:nL++,01,"OFTALMOSCOPIA" )
      ::ImpLine( {02,"","         TIPO",nH, 16,"",oApl:oOft:TIPO,1 } )
      ::ImpLine( {02,"","Poloposterior",nH, 16,"","O.D.",0 ,;
                  21,"",oApl:oOft:ODPOLOPOST, 1 } )
      ::ImpLine( {02,"","   Excavación",nH, 16,"","O.D.",0 ,;
                  21,"",oApl:oOft:ODEXCAVA  , 1 } )
      ::ImpLine( {02,"","       Mácula",nH, 16,"","O.D.",0 ,;
                  21,"",oApl:oOft:ODMACULA  , 1 } )
      ::ImpLine( {02,"","     Fijación",nH, 16,"","O.D.",0 ,;
                  21,"",oApl:oOft:ODFIJACION, 1 } )
      ::ImpLine( {02,"","Poloposterior",nH, 16,"","O.I.",0 ,;
                  21,"",oApl:oOft:OIPOLOPOST, 1 } )
      ::ImpLine( {02,"","   Excavación",nH, 16,"","O.I.",0 ,;
                  21,"",oApl:oOft:OIEXCAVA  , 1 } )
      ::ImpLine( {02,"","       Mácula",nH, 16,"","O.I.",0 ,;
                  21,"",oApl:oOft:OIMACULA  , 1 } )
      ::ImpLine( {02,"","     Fijación",nH, 16,"","O.I.",0 ,;
                  21,"",oApl:oOft:OIFIJACION, 1 } )
      ::oPrn:cFont := ::oPrn:CPINormal
   Else
      ::Cabecera( .t.,0.45,1 )
      UTILPRN ::oUtil SELECT ::aFnt[5]
      UTILPRN ::oUtil Self:nLinea, 0.5 SAY "OFTALMOSCOPIA"
      ::ImpLinw( { 0.7,"","         TIPO",nH,  3.0,"",oApl:oOft:TIPO,1 } )
      ::ImpLinw( { 0.7,"","Poloposterior",nH,  3.0,"","O.D.",0 ,;
                   3.9,"",oApl:oOft:ODPOLOPOST, 1 } )
      ::ImpLinw( { 0.7,"","   Excavación",nH,  3.0,"","O.D.",0 ,;
                   3.9,"",oApl:oOft:ODEXCAVA  , 1 } )
      ::ImpLinw( { 0.7,"","       Mácula",nH,  3.0,"","O.D.",0 ,;
                   3.9,"",oApl:oOft:ODMACULA  , 1 } )
      ::ImpLinw( { 0.7,"","     Fijación",nH,  3.0,"","O.D.",0 ,;
                   3.9,"",oApl:oOft:ODFIJACION, 1 } )
      ::ImpLinw( { 0.7,"","Poloposterior",nH,  3.0,"","O.I.",0 ,;
                   3.9,"",oApl:oOft:OIPOLOPOST, 1 } )
      ::ImpLinw( { 0.7,"","   Excavación",nH,  3.0,"","O.I.",0 ,;
                   3.9,"",oApl:oOft:OIEXCAVA  , 1 } )
      ::ImpLinw( { 0.7,"","       Mácula",nH,  3.0,"","O.I.",0 ,;
                   3.9,"",oApl:oOft:OIMACULA  , 1 } )
      ::ImpLinw( { 0.7,"","     Fijación",nH,  3.0,"","O.I.",0 ,;
                   3.9,"",oApl:oOft:OIFIJACION, 1 } )
      UTILPRN ::oUtil SELECT ::aFnt[2]
      nH    -= 0.5
   EndIf
   ::ImpMemo( "Notas de Oftalmoscopía",oApl:oOft:OBSERV_OF,,nH )
   ::ImpRaya( ::aHC[1] )
EndIf
RETURN NIL

//------------------------------------//
METHOD Diagnost( nH ) CLASS TExamen
   LOCAL aBus, aRes, nL, hRes
hRes := ::Query( "S",1 )
   ::oPrn:Titulo()
   ::oPrn:Say( ::oPrn:nL++,01,"DIAGNOSTICO (Subjetivo, Rx Final, Lentes de Contacto)" )
   ::aHC := { .t.,21,"Esfera  Cilindro  Eje   Adición  AV.Lejos  AV.Cerca" }
   oApl:aTit  := { .t.,03,"Subjetivo" }
If (nL := MSNumRows( hRes )) == 0 .AND. nH == 1
   ::ImpLine( {16,"","O.D."  ,nH, 54,"20/"," "     ,1 } )
   ::ImpLine( {16,"","O.I."  ,nH, 54,"20/"," "     ,1 } )
   ::ImpRaya( oApl:aTit[1] )
EndIf
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[1] := If( aRes[1] == "A", "A.O.", "O."+aRes[1]+"." )
   ::ImpLine( {16,"",aRes[01],nH, 21,""   ,aRes[04],1,;
               30,"",aRes[05], 1, 39,""   ,aRes[06],1,;
               46,"",aRes[07], 1, 54,"20/",aRes[08],1,;
               67,"",aRes[09], 1 } )
   nL --
   If nL == 0
      ::ImpRaya( oApl:aTit[1] )
   EndIf
EndDo
MSFreeResult( hRes )

   oApl:aTit  := { .t.,04,"Rx Final" }
   aBus       := {}
hRes := ::Query( "R",1 )
If (nL := MSNumRows( hRes )) == 0 .AND. nH == 1
   ::ImpLine( {16,"","O.D."  ,nH, 54,"20/"," "     ,1 } )
   ::ImpLine( {16,"","O.I."  ,nH, 54,"20/"," "     ,1 } )
   ::ImpLine( {16,"","Tipo de Lente",nH } )
   ::ImpLine( {12,"","Distancia Pupilar",nH,;
               40,"O.D.:","" , 1, 50,"O.I.:","",1 } )
   ::ImpRaya( oApl:aTit[1] )
EndIf
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[1] := If( aRes[1] == "A", "A.O.", "O."+aRes[1]+"." )
   ::ImpLine( {16,"",aRes[01],nH, 21,""   ,aRes[04],1,;
               30,"",aRes[05], 1, 39,""   ,aRes[06],1,;
               46,"",aRes[07], 1, 54,"20/",aRes[08],1,;
               67,"",aRes[09], 1 } )
   AADD( aBus,aRes[02] )
   nL --
   If nL == 0
      If LEN(aBus) == 1
         AADD( aBus,"" )
      EndIf
         aRes[2] := ALLTRIM(aBus[1]) + ALLTRIM(aBus[2])
      If AT( "/",aRes[2]) > 0 .OR.;
         EMPTY( aBus[1] ) .OR. EMPTY( aBus[2] )
         aBus[1] := aBus[2] := ""
      Else
         aRes[3] := VAL(aBus[1])
         aRes[4] := VAL(aBus[2])
         If aRes[3] < 45 .AND. aRes[4] < 45
            aRes[2] := LTRIM(STR( aRes[3] + aRes[4],10,2 ))
         Else
            aRes[2] := LTRIM(STR( MAX(aRes[3],aRes[4]),10,2 ))
            aBus[1] := If( aRes[3] < 45, aBus[1], "" )
            aBus[2] := If( aRes[4] < 45, aBus[2], "" )
         EndIf
      EndIf
      ::ImpLine( {16,"","Tipo de Lente",nH, 38,"",aRes[10],1 } )
      ::ImpLine( {12,"","Distancia Pupilar",nH,;
                  30,""     ,aRes[2],1,;
                  40,"O.D.:",aBus[1],1, 50,"O.I.:",aBus[2],1 } )
      ::ImpRaya( oApl:aTit[1] )
   EndIf
EndDo
MSFreeResult( hRes )
   ::aHC := { .t.,13," C u r v a  B a s e  Diametro Esfera Cilindro Eje  Adicion "+;
                    " E.Centro E.Borde Z.Optica AV.Lejos" }
   oApl:aTit  := { .t.,02,"L.Contacto" }
   ::oPrn:cFont := ::oPrn:CPICompress
hRes := ::Query( "C",1 )
If (nL := MSNumRows( hRes )) == 0 .AND. nH == 1
   ::ImpLine( {08,"","O.D."  ,nH, 87,"20/"," "     ,1 } )
   ::ImpLine( {08,"","O.I."  ,nH, 87,"20/"," "     ,1 } )
   ::ImpLine( {08,"","Notas de L.C.",nH },2 )
EndIf
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[1] := If( aRes[1] == "A", "A.O.", "O."+aRes[1]+"." )
   aRes[2] := aRes[15] + " " + aRes[2]
   ::ImpLine( {08,"",aRes[01], 0, 14,""   ,aRes[02],1,;
               35,"",aRes[03], 1, 43,""   ,aRes[04],1,;
               51,"",aRes[05], 1, 59,""   ,aRes[06],1,;
               64,"",aRes[07], 1, 69,""   ,aRes[14],1,;
               75,"",aRes[11], 1, 83,""   ,aRes[12],1,;
               92,"",aRes[13], 1, 99,"20/",aRes[08],1,;
              108,"",LEFT(aRes[10],26), 1 } )
   nL --
EndDo
MSFreeResult( hRes )
If nH == 0
   ::ImpLine( {08,"","Notas de L.C.", 0, ;
               22,"",oApl:oCtl:NOTAS_LC  , 1 } )
   ::ImpLine( {08,""," Medicamentos", 0, ;
               22,"",oApl:oCtl:MEDICAMENT, 1 } )
   ::oPrn:cFont := ::oPrn:CPINormal
   ::ImpLine( {08,"","Fecha  Compra", 0, ;
               22,"",If(EMPTY(oApl:oCtl:FECHAFAC), "", DTOC(oApl:oCtl:FECHAFAC)),1 ,;
               38,"","Fecha Entrega", 0, ;
               52,"",If(EMPTY(oApl:oCtl:FECHAENT), "", DTOC(oApl:oCtl:FECHAENT)),1 } )
   ::ImpLine( {08,"","   Remisiones", 0, ;
               22,"",oApl:oCtl:REMITIR   , 1 } )
   ::ImpLine( {06,"","Próximo Control",0, ;
               22,"",NtChr( oApl:oCtl:FCHPROXCON,"2" ),1 } )
   ::ImpMemo( "Notas del Diagnóstico",oApl:oCtl:OBSERV_DIA,,0 )
Else
   ::ImpMemo( "Notas del Diagnóstico","",,3 )
EndIf
   ::ImpRaya( oApl:aTit[1] )
RETURN NIL

//------------------------------------//
METHOD Diagnosw( nH ) CLASS TExamen
   LOCAL aBus, aRes, nL, hRes
hRes := ::Query( "S",1 )
   ::Cabecera( .t.,0.45,1 )
   UTILPRN ::oUtil Self:nLinea, 0.5 SAY "DIAGNOSTICO (Subjetivo, Rx Final, Lentes de Contacto)"
   ::aHC := { .t.,5.6,"Esfera    Cilindro    Eje     Adición    AV.Lejos    AV.Cerca" }
   oApl:aTit := { .t.,1.0,"Subjetivo" }
If (nL := MSNumRows( hRes )) == 0 .AND. nH == 1
   ::ImpLinw( { 4.4,"","O.D."  ,nH, 11.5,"20/"," "     ,1 } )
   ::ImpLinw( { 4.4,"","O.I."  ,nH, 11.5,"20/"," "     ,1 } )
   ::ImpRaya( oApl:aTit[1] )
EndIf
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[1] := If( aRes[1] == "A", "A.O.", "O."+aRes[1]+"." )
   ::ImpLinw( { 4.4,"",aRes[01],nH,  5.6,""   ,aRes[04],1,;
                7.3,"",aRes[05], 1,  8.6,""   ,aRes[06],1,;
               10.0,"",aRes[07], 1, 11.5,"20/",aRes[08],1,;
               13.4,"",aRes[09], 1 } )
   nL --
   If nL == 0
      ::ImpRaya( oApl:aTit[1] )
   EndIf
EndDo
MSFreeResult( hRes )

   oApl:aTit := { .t.,1.4,"Rx Final" }
   aBus      := {}
hRes := ::Query( "R",1 )
If (nL := MSNumRows( hRes )) == 0 .AND. nH == 1
   ::ImpLinw( { 4.4,"","O.D."  ,nH, 11.5,"20/"," "     ,1 } )
   ::ImpLinw( { 4.4,"","O.I."  ,nH, 11.5,"20/"," "     ,1 } )
   ::ImpLinw( { 4.4,"","Tipo de Lente",nH } )
   ::ImpLinw( { 3.9,"","Distancia Pupilar",nH,;
               10.5,"O.D.:","" , 1, 13.0,"O.I.:","",1 } )
   ::ImpRaya( oApl:aTit[1] )
EndIf
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[1] := If( aRes[1] == "A", "A.O.", "O."+aRes[1]+"." )
   ::ImpLinw( { 4.4,"",aRes[01],nH,  5.6,""   ,aRes[04],1,;
                7.3,"",aRes[05], 1,  8.6,""   ,aRes[06],1,;
               10.0,"",aRes[07], 1, 11.5,"20/",aRes[08],1,;
               13.4,"",aRes[09], 1 } )
   AADD( aBus,aRes[02] )
   nL --
   If nL == 0
      If LEN(aBus) == 1
         AADD( aBus,"" )
      EndIf
         aRes[2] := ALLTRIM(aBus[1]) + ALLTRIM(aBus[2])
      If AT( "/",aRes[2]) > 0 .OR.;
         EMPTY( aBus[1] ) .OR. EMPTY( aBus[2] )
         aBus[1] := aBus[2] := ""
      Else
         aRes[3] := VAL(aBus[1])
         aRes[4] := VAL(aBus[2])
         If aRes[3] < 45 .AND. aRes[4] < 45
            aRes[2] := LTRIM(STR( aRes[3] + aRes[4],10,2 ))
         Else
            aRes[2] := LTRIM(STR( MAX(aRes[3],aRes[4]),10,2 ))
            aBus[1] := If( aRes[3] < 45, aBus[1], "" )
            aBus[2] := If( aRes[4] < 45, aBus[2], "" )
         EndIf
      EndIf
      ::ImpLinw( { 4.4,"","Tipo de Lente",nH, 10.0,"",aRes[10],1 } )
      ::ImpLinw( { 3.9,"","Distancia Pupilar",nH,;
                   7.9,""     ,aRes[2],1,;
                  10.5,"O.D.:",aBus[1],1, 13.0,"O.I.:",aBus[2],1 } )
      ::ImpRaya( oApl:aTit[1] )
   EndIf
EndDo
MSFreeResult( hRes )
   ::aHC := { .t.,2.7,"C u r v a  B a s e  Diametro  Esfera  Cilindro  Eje  Adicion "+;
                    " E.Centro  E.Borde  Z.Optica  AV.Lejos" }
   oApl:aTit := { .t.,0.8,"L.Contacto" }
   UTILPRN ::oUtil SELECT ::aFnt[5]
hRes := ::Query( "C",1 )
If (nL := MSNumRows( hRes )) == 0 .AND. nH == 1
   ::ImpLinw( { 1.7,"","O.D."  ,nH, 15.1,"20/"," "     ,1 } )
   ::ImpLinw( { 1.7,"","O.I."  ,nH, 15.1,"20/"," "     ,1 } )
   ::ImpLinw( { 1.7,"","Notas de L.C.",nH },2 )
EndIf
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[1] := If( aRes[1] == "A", "A.O.", "O."+aRes[1]+"." )
   aRes[2] := aRes[15] + " " + aRes[2]
   ::ImpLinw( { 1.7,"",aRes[01], 0,  2.7,""   ,aRes[02],1,;
                5.3,"",aRes[03], 1,  6.3,""   ,aRes[04],1,;
                7.4,"",aRes[05], 1,  8.4,""   ,aRes[06],1,;
                9.0,"",aRes[07], 1,  9.7,""   ,aRes[14],1,;
               10.2,"",aRes[11], 1, 11.5,""   ,aRes[12],1,;
               12.7,"",aRes[13], 1, 14.0,"20/",aRes[08],1,;
               15.4,"",LEFT(aRes[10],26), 1 } )
   nL --
EndDo
MSFreeResult( hRes )
If nH == 0
   ::ImpLinw( { 1.7,"","Notas de L.C.", 0, ;
                4.0,"",oApl:oCtl:NOTAS_LC  , 1 } )
   ::ImpLinw( { 1.7,""," Medicamentos", 0, ;
                4.0,"",oApl:oCtl:MEDICAMENT, 1 } )
   UTILPRN ::oUtil SELECT ::aFnt[2]
   ::ImpLinw( { 2.4,"","Fecha  Compra", 0, ;
                5.4,"",If(EMPTY(oApl:oCtl:FECHAFAC), "", DTOC(oApl:oCtl:FECHAFAC)),1 ,;
               10.0,"","Fecha Entrega", 0, ;
               13.5,"",If(EMPTY(oApl:oCtl:FECHAENT), "", DTOC(oApl:oCtl:FECHAENT)),1 } )
   ::ImpLinw( { 2.4,"","   Remisiones", 0, ;
                5.4,"",oApl:oCtl:REMITIR   , 1 } )
   ::ImpLinw( { 1.8,"","Próximo Control",0, ;
                5.4,"",NtChr( oApl:oCtl:FCHPROXCON,"2" ),1 } )
   ::ImpMemo( "Notas del Diagnóstico",oApl:oCtl:OBSERV_DIA,,0 )
Else
   ::ImpMemo( "Notas del Diagnóstico","",,1.5 )
EndIf
   ::ImpRaya( oApl:aTit[1] )
RETURN NIL

// 1_nCol, 2_cTexto1, 3_cTexto2, 4_Imprimo( 1_Si, 0_No ) //
METHOD ImpLine( aLinea,nS ) CLASS TExamen
   LOCAL nC, lSi := .f.
   DEFAULT nS := 0
FOR nC := 1 TO LEN( aLinea ) STEP 4
   If aLinea[nC+3] == 1 .AND. !EMPTY( aLinea[nC+2] )
      lSi := .t.
      EXIT
   EndIf
NEXT nC
If lSi
   If ::aHC[1]
      ::aHC[1] := .f.
      ::oPrn:Titulo()
      If oApl:aTit[1]
         oApl:aTit[1] := .f.
         ::oPrn:Say( ::oPrn:nL,oApl:aTit[2],oApl:aTit[3] )
      EndIf
      ::oPrn:Say( ::oPrn:nL++,::aHC[2],::aHC[3] )
   EndIf
   ::oPrn:Titulo()
   If oApl:aTit[1]
      oApl:aTit[1] := .f.
      ::oPrn:Say( ::oPrn:nL,oApl:aTit[2],oApl:aTit[3] )
   EndIf
   FOR nC := 1 TO LEN( aLinea ) STEP 4
      ::oPrn:Say( ::oPrn:nL,aLinea[nC], aLinea[nC+1]+aLinea[nC+2] )
   NEXT nC
   ::oPrn:nL ++
   If ::oPrn:nL < ::oPrn:nLength .AND. nS > 0
      ::oPrn:nL += nS
   EndIf
EndIf
RETURN NIL

// 1_nCol, 2_cTexto1, 3_cTexto2, 4_Imprimo( 1_Si, 0_No ) //
METHOD ImpLinw( aLinea,nS ) CLASS TExamen
   LOCAL nC, lSi := .f.
   DEFAULT nS := 0
FOR nC := 1 TO LEN( aLinea ) STEP 4
   If aLinea[nC+3] == 1 .AND. !EMPTY( aLinea[nC+2] )
      lSi := .t.
      EXIT
   EndIf
NEXT nC
If lSi
   If ::aHC[1]
      ::aHC[1] := .f.
      ::Cabecera( .t.,0.45,1 )
      If oApl:aTit[1]
         oApl:aTit[1] := .f.
         UTILPRN ::oUtil Self:nLinea, oApl:aTit[2] SAY oApl:aTit[3]
      EndIf
         UTILPRN ::oUtil Self:nLinea, ::aHC[2] SAY ::aHC[3]
   EndIf
      ::Cabecera( .t.,0.45,1 )
   If oApl:aTit[1]
      oApl:aTit[1] := .f.
      UTILPRN ::oUtil Self:nLinea, oApl:aTit[2] SAY oApl:aTit[3]
   EndIf
   FOR nC := 1 TO LEN( aLinea ) STEP 4
      UTILPRN ::oUtil Self:nLinea, aLinea[nC] SAY aLinea[nC+1]+aLinea[nC+2]
   NEXT nC
   If ::nLinea  < ::nEndLine .AND. nS > 0
      ::nLinea += nS
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD ImpMemo( cMsg,mObser,nA,nH ) CLASS TExamen
   LOCAL nObs
   DEFAULT nA := 72, nH := 0
mObser := ALLTRIM(mObser)
If !EMPTY(mObser)
   If !EMPTY(cMsg)
      If ::aLS[1] == 1
         ::oPrn:Titulo()
         ::oPrn:Say( ::oPrn:nL++,01,cMsg,24,1 )
      Else
         ::Cabecera( .t.,0.45,1 )
         UTILPRN ::oUtil Self:nLinea, 0.8 SAY cMsg RIGHT
      EndIf
   EndIf
   nObs := MLCOUNT( mObser,nA )
   FOR nH := 1 TO nObs
      cMsg := MEMOLINE( mObser,nA,nH )
      If !EMPTY( cMsg )
         If ::aLS[1] == 1
            ::oPrn:Titulo()
            ::oPrn:Say( ::oPrn:nL++,01,cMsg )
         Else
            ::Cabecera( .t.,0.45,1 )
            UTILPRN ::oUtil Self:nLinea, 1.0 SAY cMsg
         EndIf
      EndIf
   NEXT nH
ElseIf nH >= 0.5
    If ::aLS[1] == 1
       ::oPrn:Titulo()
       ::oPrn:Say( ::oPrn:nL,01,cMsg,24,1 )
       ::oPrn:nL += nH
    Else
       ::Cabecera( .t.,0.45,1 )
       UTILPRN ::oUtil Self:nLinea, 0.8 SAY cMsg RIGHT
       ::nLinea += nH
    EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD ImpRaya( lSi ) CLASS TExamen
If !lSi
   If ::aLS[1] == 1
      If ::oPrn:nL + 1 < ::oPrn:nLength
         ::oPrn:Say( ::oPrn:nL,00,REPLICATE("-",::oPrn:nWidth) )
      EndIf
      ::oPrn:nL += If( ::oPrn:nL < ::oPrn:nLength, 1, 0 )
   Else
      If ::nLinea +  0.5 < ::nEndLine
         ::nLinea += 0.5
         UTILPRN ::oUtil LINEA Self:nLinea,1.0 TO Self:nLinea,20.0 PEN ::oPen
      EndIf
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Cabecera( lSep,nSpace,nSuma ) CLASS TExamen
If lSep .AND. !::aEnc[1]
   ::aEnc[1] := ::Separator( nSpace,nSuma )
EndIf
If ::aEnc[1]
   ::aEnc[1] := .F.
   ::Centrar( oApl:cEmpresa,::aFnt[4],1.0 )
   ::Centrar( "NIT: " + oApl:oEmp:Nit,::aFnt[2],2.0 )

   UTILPRN ::oUtil SELECT ::aFnt[2]
   UTILPRN ::oUtil 2.0, 0.5 SAY "FEC.PROC:"+DTOC( DATE() )
   UTILPRN ::oUtil 2.0,16.4 SAY "HORA: " + AmPm( TIME() )
   ::Centrar( ::aLS[3],::aFnt[2],2.5 )
   UTILPRN ::oUtil 2.5,16.5 SAY "PAGINA" + STR(::nPage,4 )
   ::Centrar( ::aLS[4],::aFnt[2],3.0 )
   UTILPRN ::oUtil SELECT ::aFnt[5]
   FOR nSuma := 3 TO LEN( ::aEnc )
      UTILPRN ::oUtil 3.5,::aEnc[nSuma,1] SAY ::aEnc[nSuma,2]
   NEXT nSuma
   ::nLinea := 3.5 + ::aEnc[2]
EndIf
RETURN NIL

//------------------------------------//
METHOD Query( aBus,nH ) CLASS TExamen
   LOCAL cQry, hRes
If nH == 1
   cQry := "SELECT d.ladolente, d.dp_cb, d.diametro, d.esfera, d.cilindro"+;
                ", d.eje, d.adicion, d.avl, d.avc, l.nombre, d.ecentro, " +;
                  "d.eborde, d.zoptica, d.tipoadd, d.cbase "              +;
           "FROM hisdiagn d LEFT JOIN hislente l "            +;
            "USING( codigo ) "                                +;
           "WHERE d.optica     = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND d.nro_histor = " + LTRIM(STR(::nHis))       +;
            " AND d.control    = " + LTRIM(STR(::nCtrl))      +;
            " AND d.tipodgn    = '"+ aBus                     +;
           "' ORDER BY d.ladolente"
ElseIf nH == 2
//             "d.avc, d.ecentro, d.eborde, d.zoptica "          +;
//            "ON d.codigo     = l.codigo "                   +;
   cQry := "SELECT d.ladolente, d.dp_cb, d.diametro, d.esfera, "        +;
                  "d.cilindro, d.eje, d.adicion, d.avl, l.nombre, "     +;
                  "c.control, c.fecha, c.notas_lc, c.fechafac, d.cbase "+;
           "FROM hiscntrl c, hisdiagn d LEFT JOIN hislente l "+;
            "USING( codigo ) "                                +;
           "WHERE d.tipodgn    = 'C'"                         +;
            " AND c.optica     = d.optica"                    +;
            " AND c.nro_histor = d.nro_histor"                +;
            " AND c.control    = d.control"                   +;
            " AND c.optica     = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND c.nro_histor = " + LTRIM(STR( ::nHis ))     +;
            " ORDER BY d.control, d.ladolente"
ElseIf nH == 3
   cQry := "SELECT d.ladolente, d.esfera, d.cilindro, d.eje, d.adicion, "+;
                  "d.avl, d.avc, d.dp_cb, l.nombre, c.control, c.fecha " +;
           "FROM hiscntrl c, hisdiagn d LEFT JOIN hislente l "+;
            "USING( codigo ) "                                +;
           "WHERE d.tipodgn    = '"+ aBus                     +;
           "' AND c.optica     = d.optica"                    +;
            " AND c.nro_histor = d.nro_histor"                +;
            " AND c.control    = d.control"                   +;
            " AND c.optica     = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND c.nro_histor = " + LTRIM(STR( ::nHis ))     +;
            " ORDER BY d.control, d.ladolente"
EndIf
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry, ),;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
RETURN hRes