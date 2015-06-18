// Programa.: HISPERSO.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Creacion y Manto. de Datos Personales.
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

FUNCTION Personales()
   LOCAL oPer := TPer()
oPer:NEW()
oPer:Activate()
oPer:NEW( "FIN" )
RETURN NIL

//------------------------------------//
CLASS TPer FROM TNits

 DATA aTipoD, aSexo, aZonaR, aTipoU, aTipoA, aEdad, aECiv
 DATA oMu, oBC, oPr

 METHOD NEW( xFin ) Constructor
 METHOD Editar( xRec,lNuevo,lView,cNit )
 METHOD Mostrar( lAyuda,nOrd,cNI )
 METHOD Cambios( aDP,nBtn )
 METHOD SiExiste( lNuevo,aCam,oBtP )
 METHOD Listado()
ENDCLASS

//------------------------------------//
METHOD NEW( xFin ) CLASS TPer
If xFin == NIL
   Super:New( oApl:oHis )
   ::aOrden := { {"<None> "  ,1,.f.},{"Nroiden"  ,"nroiden",.f.},;
                 {"Apellido" ,"CONCAT(apellidos,' ', nombres)",.f.},;
                 {"Nombres"  ,"CONCAT(nombres,' ', apellidos)",.f.},;
                 {"Historia" ,"nro_histor",.f.} }
   ::aTipoD := ArrayCombo( "TIPODOC" )
   ::aSexo  := ArrayCombo( "SEXO" )
   ::aZonaR := ArrayCombo( "ZONARES" )
   ::aTipoU := ArrayCombo( "TIPOUSU" )
   ::aTipoA := ArrayCombo( "TIPOAFI" )
   ::aEdad  := ArrayCombo( "UMEDAD" )
   ::aECiv  := ArrayCombo( "ESTADCIVIL" )
   //::cLista := "nroiden, apellidos, nombres, nro_histor"
   ::xVar   := SPACE(15)
   ::oMu    := TRip() ; ::oMu:New( 1 )
   ::oBC    := TRip() ; ::oBC:New( 8 )
   ::oPr    := TRip() ; ::oPr:New( 4 )
Else
   ::oMu:oDb:Destroy()
   ::oBC:oDb:Destroy()
   ::oPr:oDb:Destroy()
EndIf
RETURN NIL

//------------------------------------//
METHOD Mostrar( lAyuda,nOrd,cNI ) CLASS TPer
   LOCAL oDlg, oM := Self
   LOCAL cTit := "Ayuda de Datos Personales", bHacer, lReturn := NIL
   DEFAULT lAyuda := .t. , nOrd := 2, cNI := ""
If lAyuda
   bHacer  := {|| ::lBuscar := lReturn := .t., oDlg:End()}
   lReturn := .f.
ELSE
   bHacer  := ::bEditar
   cTit    := "Datos Personales"
ENDIF
nOrd := ::Ordenar( nOrd )
If !EMPTY( cNI )
   ::oDb:Seek( {"nroiden",cNI} )
EndIf

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 68 TITLE cTit
   @ 1.5,.5 LISTBOX ::oLbx FIELDS    ;
                    ::oDb:NROIDEN   ,;
          OEMTOANSI(::oDb:APELLIDOS),;
          OEMTOANSI(::oDb:NOMBRES), STR(::oDb:NRO_HISTOR);
      HEADERS "Documento"+CRLF+"Identidad","Apellidos","Nombres","Nro.Historia" ;
      SIZES 400, 450 SIZE 250,107 ;
      OF oDlg UPDATE              ;
      ON DBLCLICK EVAL(bHacer)
    ::oLbx:nClrBackHead  := oApl:nClrBackHead
    ::oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    ::oLbx:nClrBackFocus := oApl:nClrBackFocus
    ::oLbx:GoTop()
    ::oLbx:oFont      := ::oFont
    ::oLbx:nHeaderHeight := 28
    ::oLbx:aColSizes  := {75,164,164,60}
    ::oLbx:aHjustify  := {2,2,2,2}
    ::oLbx:aJustify   := {0,0,0,1}
    ::oLbx:lCellStyle := ::oLbx:ladjbrowse := .f.
    ::oLbx:ladjlastcol:= .t.
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN, EVAL(bHacer),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(::bNew),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=69, EVAL(::bEditar)	 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=86, EVAL(::bVer) 		 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) )))) }
   MySetBrowse( ::oLbx,::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT ( oM:Barra(lAyuda,oDlg) )
::oDb:Setorder(nOrd)
If lReturn # NIL .AND. lReturn
   ::oDb:Seek( {"codigo_nit",::oDb:CODIGO_NIT} )
EndIf

RETURN lReturn

//------------------------------------//
METHOD Editar(xRec,lNuevo,lView,cNit) CLASS TPer
   LOCAL oDlg, oGet := ARRAY(23), aH := ARRAY(8), oE := Self
   LOCAL aEd  := { "Nuevo Nit ",.f. }
   LOCAL aNom := { SPACE(20),SPACE(20),SPACE(15),SPACE(15) }
   DEFAULT lNuevo := .t. , lView := .f. ,;
           cNit   := ::xVar
If lNuevo
   ::oDb:xBlank()
   ::oDb:NROIDEN  := cNit
   ::oDb:RESHABIT := oApl:oEmp:RESHABIT
   ::oDb:OCUPACION:= "999"
   aEd[1]  += STR(oApl:oEmp:NRO_HISTOR + 1)
Else
   ::oDb:Seek( {"codigo_nit",::oDb:CODIGO_NIT} )
   aEd[1]  := If( lView, "Viendo", "Modificando" ) + " Nit"
   aNom[1] := PADR( SUBSTR( ::oDb:APELLIDOS,1,::oDb:PAPEL ),20 )
   aNom[2] := PADR( SUBSTR( ::oDb:APELLIDOS,2+::oDb:PAPEL ),20 )
   aNom[3] := PADR( SUBSTR( ::oDb:NOMBRES  ,1,::oDb:PNOMB ),15 )
   aNom[4] := PADR( SUBSTR( ::oDb:NOMBRES  ,2+::oDb:PNOMB ),15 )
   cNit    := ::oDb:NROIDEN
EndIf
 ::aOld := ACLONE( ::oDb:axBuffer )
 ::oMu:oDb:Seek( { "codigo",::oDb:RESHABIT } )
 ::oBC:oDb:Seek( { "cityb_id",::oDb:CITYB_ID } )
 ::oPr:oDb:Seek( { "codigo",::oDb:OCUPACION} )
aH[1] := ArrayValor( ::aTipoD,::oDb:TIPOIDEN ,{|xV|::oDb:TIPOIDEN  := xV},.t. )
aH[2] := ArrayValor( ::aSexo ,::oDb:SEXO     ,{|xV|::oDb:SEXO      := xV},.t. )
aH[3] := ArrayValor( ::aZonaR,::oDb:ZONARESI ,{|xV|::oDb:ZONARESI  := xV},.t. )
aH[4] := ArrayValor( ::aTipoU,::oDb:TIPOUSUA ,{|xV|::oDb:TIPOUSUA  := xV},.t. )
aH[5] := ArrayValor( ::aTipoA,::oDb:TIPOAFILI,{|xV|::oDb:TIPOAFILI := xV},.t. )
aH[6] := ArrayValor( ::aEdad ,::oDb:UNIEDAD  ,{|xV|::oDb:UNIEDAD   := xV},.t. )
aH[7] := ArrayValor( ::aECiv ,::oDb:EST_CIVIL,{|xV|::oDb:EST_CIVIL := xV},.t. )
aH[8] := If( EMPTY(::oDb:FEC_NACIMI), ::oDb:EDAD, NtChr( ::oDb:FEC_NACIMI,"A" ) )
//aH[8] := Direcion( ::oDb )

DEFINE DIALOG oDlg TITLE aEd[1] FROM 0, 0 TO 374,570 PIXEL
   @  02, 14 SAY "Información de los Datos Personles" OF oDlg PIXEL SIZE 116,10
   @  02,147 SAY "Historia Nro." OF oDlg RIGHT PIXEL SIZE 43,10
   @  02,192 SAY ::oDb:NRO_HISTOR OF oDlg SIZE 38,10 PIXEL
//      WHEN EMPTY(::oDb:NRO_HISTOR) .AND. oApl:oEmp:TITULAR # "COC"
   @  02,234 SAY ::oDb:CODIGO_NIT OF oDlg SIZE 30,12 PIXEL
   @  14, 00 SAY "Documento ID" OF oDlg RIGHT PIXEL SIZE 48,10
   @  14, 50 GET oGet[1] VAR ::oDb:NROIDEN OF oDlg                   ;
      VALID If( EMPTY( ::oDb:NROIDEN ),                              ;
              (MsgStop("Doc.Identidad no puede quedar vacío"),.f.)  ,;
              (::oDb:NROIDEN := LTRIM(STRTRAN(::oDb:NROIDEN,".","")),;
               xRec := ::Buscar( ::oDb:NROIDEN,"nroiden",,lNuevo )  ,;
               If( (xRec .AND.  lNuevo) .OR.                         ;
                   (xRec .AND. !lNuevo .AND. ::oDb:NROIDEN # cNit)  ,;
              (MsgStop("Doc.Identidad ya existe"),.f.),.t. ) ))      ;
      SIZE 65,10 PIXEL
   @  14,144 SAY "Tipo de Documento" OF oDlg RIGHT PIXEL SIZE 50,10
   @  14,196 COMBOBOX oGet[02] VAR aH[1] ITEMS ArrayCol( ::aTipoD,1 );
      SIZE 50,99 OF oDlg PIXEL
   @  26, 00 SAY "Primer Apellido" OF oDlg RIGHT PIXEL SIZE 48,10
   @  26, 50 GET oGet[03] VAR aNom[1] OF oDlg PICTURE "@!";
      VALID EVAL( { || If( !EMPTY( aNom[1] ), .t. ,;
                 (MsgInfo( "Es obligatorio el 1er.Apellido" ), .f.) ) } );
      SIZE 90,10 PIXEL
   @  26,144 SAY "Segundo Apellido" OF oDlg RIGHT PIXEL SIZE 50,10
   @  26,196 GET oGet[04] VAR aNom[2] OF oDlg PICTURE "@!" SIZE 80,10 PIXEL
   @  38, 00 SAY "Primer Nombre" OF oDlg RIGHT PIXEL SIZE 48,10
   @  38, 50 GET oGet[05] VAR aNom[3] OF oDlg PICTURE "@!";
      VALID EVAL( { || If( !EMPTY( aNom[3] ), .t. ,;
                 (MsgInfo( "Es obligatorio el 1er.Nombre" ), .f.) ) } );
      SIZE 90,10 PIXEL
   @  38,144 SAY "Segundo Nombre" OF oDlg RIGHT PIXEL SIZE 50,10
   @  38,196 GET oGet[06] VAR aNom[4] OF oDlg PICTURE "@!";
      VALID ::SiExiste( lNuevo,aNom,oGet[22] ) ;
      SIZE 80,10 PIXEL
   @  50, 00 SAY "Sexo" OF oDlg RIGHT PIXEL SIZE 48,10
   @  50, 50 COMBOBOX oGet[07] VAR aH[2] ITEMS ArrayCol( ::aSexo,1 );
      SIZE 50,99 OF oDlg PIXEL
   @  50,144 SAY "Fecha Nacimiento" OF oDlg RIGHT PIXEL SIZE 50,10
   @  50,196 GET oGet[08] VAR ::oDb:FEC_NACIMI OF oDlg ;
      VALID ::SiExiste( ,,oGet[21] ) ;
      SIZE 40,10 PIXEL
   @  62, 00 SAY "Resid.Habitual" OF oDlg RIGHT PIXEL SIZE 48,10
   @  62, 50 BTNGET oGet[09] VAR oE:oDb:RESHABIT OF oDlg PICTURE "99999";
      ACTION EVAL({|| If( oE:oMu:Mostrar(), (oE:oDb:RESHABIT := oE:oMu:oDb:CODIGO,;
                         oGet[09]:Refresh(), oGet[09]:lValid(.f.)), ) })       ;
      SIZE 30,10 PIXEL UPDATE  RESOURCE "BUSCAR" ;
      VALID  EVAL({|| If( oE:oMu:oDb:Seek( {"codigo",oE:oDb:RESHABIT})          ,;
             (oDlg:Update(), .t.), (MsgStop("Este Municipio no Existe"),.f.) ) } )
//  oGet[09]:cToolTip := "Ayuda de Municipios (F2)"
   @  62, 84 SAY ::oMu:oDb:NOMBRE OF oDlg PIXEL SIZE 100,10 UPDATE
   @  62,188 SAY "Zona Residencia" OF oDlg RIGHT PIXEL SIZE 46,10
   @  62,236 COMBOBOX oGet[10] VAR aH[3] ITEMS ArrayCol( ::aZonaR,1 );
      SIZE 40,99 OF oDlg PIXEL
   @  84, 00 SAY "Dirección" OF oDlg RIGHT PIXEL SIZE 48,10
   @  74, 50 GET oGet[11] VAR ::oDb:DIRECCION OF oDlg SIZE 100,24 PIXEL
//        VALID EVAL( {|| aH[8] := Direcion( ::oDb,1 ), oGet[11]:Refresh(), .t. })
   @  74,154 SAY "Tel.Residencia" OF oDlg RIGHT PIXEL SIZE 40,10
   @  74,196 GET oGet[12] VAR ::oDb:TEL_RESIDE OF oDlg SIZE 80,10 PIXEL
   @  86,154 SAY "Tel.Oficina" OF oDlg RIGHT PIXEL SIZE 40,10
   @  86,196 GET oGet[13] VAR ::oDb:TEL_OFICIN OF oDlg SIZE 80,10 PIXEL
   @  98, 00 SAY "Barrio" OF oDlg RIGHT PIXEL SIZE 48,10
   @  98, 50 BTNGET oGet[14] VAR oE:oDb:CITYB_ID OF oDlg PICTURE "999999";
      ACTION EVAL({|| If( oE:oBC:Mostrar( .t.,3,oE:oDb:RESHABIT ),;
                        ( oE:oDb:CITYB_ID := oE:oBC:oDb:CITYB_ID ,;
                          oGet[14]:Refresh() ), ) })              ;
      SIZE 30,10 PIXEL UPDATE  RESOURCE "BUSCAR" ;
      VALID  EVAL({|| If( oE:oBC:oDb:Seek( {"cityb_id",oE:oDb:CITYB_ID}),;
             (oDlg:Update(), .t.), (MsgStop("Este Barrio no Existe"),.f.) ) } )
   @  98, 84 SAY ::oBC:oDb:NOMBRE OF oDlg PIXEL SIZE 130,10 UPDATE
   @ 110, 00 SAY "Email" OF oDlg RIGHT PIXEL SIZE 48,10
   @ 110, 50 GET oGet[15] VAR ::oDb:EMAIL OF oDlg SIZE 120,10 PIXEL
   @ 110,186 SAY "Estado Civil" OF oDlg RIGHT PIXEL SIZE 46,10
   @ 110,236 COMBOBOX oGet[16] VAR aH[7] ITEMS ArrayCol( ::aECiv,1 );
      SIZE 40,99 OF oDlg PIXEL
   @ 122, 00 SAY "Ocupación" OF oDlg RIGHT PIXEL SIZE 48,10
   @ 122, 50 BTNGET oGet[17] VAR oE:oDb:OCUPACION OF oDlg PICTURE "99999";
      ACTION EVAL({|| If( oE:oPr:Mostrar(), (oE:oDb:OCUPACION := oE:oPr:oDb:CODIGO,;
                         oGet[17]:Refresh(), oGet[17]:lValid(.f.)), ) })       ;
      SIZE 30,10 PIXEL UPDATE  RESOURCE "BUSCAR" ;
      VALID  EVAL({|| If( oE:oPr:oDb:Seek( {"codigo",oE:oDb:OCUPACION})          ,;
             (oDlg:Update(), .t.), (MsgStop("Esta Ocupación no Existe"),.f.) ) } )
//  oGet[17]:cToolTip := "Ayuda de las Ocupaciones (F2)"
   @ 122, 84 SAY ::oPr:oDb:NOMBRE OF oDlg PIXEL SIZE 200,10 UPDATE
   @ 134, 00 SAY "Tipo Usuario"     OF oDlg RIGHT PIXEL SIZE 48,10
   @ 134, 50 COMBOBOX oGet[18] VAR aH[4] ITEMS ArrayCol( ::aTipoU,1 );
      SIZE 50,99 OF oDlg PIXEL
   @ 146, 00 SAY "Tipo Afiliado"    OF oDlg RIGHT PIXEL SIZE 48,10
   @ 146, 50 COMBOBOX oGet[19] VAR aH[5] ITEMS ArrayCol( ::aTipoA,1 );
      SIZE 50,99 OF oDlg PIXEL
   @ 134,144 SAY "Und.Medida Edad"  OF oDlg RIGHT PIXEL SIZE 50,10
   @ 134,196 COMBOBOX oGet[20] VAR aH[6] ITEMS ArrayCol( ::aEdad,1 );
      SIZE 50,99 OF oDlg PIXEL
   @ 146,144 SAY "Edad al Ingresar" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 146,196 GET oGet[21] VAR ::oDb:EDAD OF oDlg PICTURE "999" SIZE 20,10 PIXEL
   @ 146,220 SAY "Edad Actual" OF oDlg RIGHT PIXEL SIZE 40,10
   @ 146,262 SAY aH[8] OF oDlg PIXEL SIZE 24,10

   @ 165,100 BUTTON oGet[22] PROMPT "Grabar"   SIZE 44,14 OF oDlg ACTION;
      ( If( ::Cambios( aNom,1 ), (aEd[2] := .t., oDlg:End()),;
          (oGet[1]:SetFocus()))) PIXEL
    oGet[22]:cToolTip := "Graba estos Datos"
   @ 165,148 BUTTON oGet[23] PROMPT "Cancelar" SIZE 44,14 OF oDlg CANCEL;
      ACTION ( If( ::Cambios( aNom,2 )                      ,;
               If( MsgYesNo( "Guardar los Cambios","DESEA" ),;
                   aEd[2] := .t. , ), ), oDlg:End() ) PIXEL
    oGet[23]:cToolTip := "Regresa al menu Anterior"
   ACTIVAGET(oGet)
   IF lView                     // Solo Consulta
      DesactivaALLGET(oGet)
      oGet[22]:Disable()
      oGet[23]:Enable()
      oGet[23]:SetFocus()
   ENDIF
ACTIVATE DIALOG oDlg CENTER
If aEd[2]
   ::oDb:TIPOIDEN := ::aTipoD[aH[1],2]
   ::oDb:SEXO     :=  ::aSexo[aH[2],2]
   ::oDb:UNIEDAD  :=  ::aEdad[aH[6],2]
   ::oDb:ZONARESI := ::aZonaR[aH[3],2]
   ::oDb:TIPOUSUA := ::aTipoU[aH[4],2]
   ::oDb:TIPOAFILI:= ::aTipoA[aH[5],2]
   ::oDb:EST_CIVIL:=  ::aECiv[aH[7],2]
   ::oDb:PAPEL    := LEN( ALLTRIM( aNom[1] ) )
   ::oDb:PNOMB    := LEN( ALLTRIM( aNom[3] ) )
   If lNuevo
      ::oDb:OPTICA   := oApl:nEmpresa
      ::oDb:EXPORTAR := "N"
   Else
      ::oDb:EXPORTAR := "C"
   EndIf
   ::Guardar( lNuevo )
   If lNuevo
      ::oDb:Seek( {"codigo_nit",::oDb:CODIGO_NIT} )
      If oApl:nItems == 0
         ::Cambios()
      EndIf
   EndIf
EndIf
 ::aOld := NIL
RETURN NIL

//------------------------------------//
METHOD Cambios( aDP,nBtn ) CLASS TPer
   LOCAL nFld, lOK := .f.
If nBtn == NIL
//
   If oApl:oLoc # NIL
      If oApl:oLoc:lConnected
         If oApl:oBD:Used()
            aDP    := { ALLTRIM( STRTRAN( ::oDb:NROIDEN,".","" ) ),, }
            aDP[2] := "SELECT codigo_nit FROM historia "             +;
                      "WHERE nroiden = '" + aDP[1]                   +;
                    "' OR (apellidos = '" + ALLTRIM(::oDb:APELLIDOS) +;
                      "' AND nombres = '" + ALLTRIM(::oDb:NOMBRES)   + "' )"
            aDP[3] := Buscar( aDP[2],"CM",,8,,4 )
            If aDP[3] == 0
               aDP[2] := "INSERT INTO historia VALUES ( NULL, '" +;
                                      ::oDb:TIPOIDEN    + "', '" +;
                                                 aDP[1] + "', '" +;
                              ALLTRIM(::oDb:APELLIDOS)  + "', '" +;
                              ALLTRIM(::oDb:NOMBRES)    + "', '" +;
                                      ::oDb:SEXO        + "', "  +;
                           xValToChar(::oDb:FEC_NACIMI) + ", '"  +;
                                      ::oDb:UNIEDAD     + "', "  +;
                            LTRIM(STR(::oDb:EDAD))      + ", '"  +;
                              ALLTRIM(::oDb:RESHABIT)   + "', '" +;
                                      ::oDb:ZONARESI    + "', '" +;
                              ALLTRIM(::oDb:DIRECCION)  + "', '" +;
                              ALLTRIM(::oDb:TEL_RESIDE) + "', '" +;
                              ALLTRIM(::oDb:TEL_OFICIN) + "', '" +;
                              ALLTRIM(::oDb:EMAIL)      + "', '" +;
                              ALLTRIM(::oDb:OCUPACION)  + "', '" +;
                                      ::oDb:TIPOUSUA    + "', '" +;
                                      ::oDb:TIPOAFILI   + "', "  +;
                            LTRIM(STR(::oDb:NRO_HISTOR))+ ", "   +;
                            LTRIM(STR(::oDb:PAPEL))     + ", "   +;
                            LTRIM(STR(::oDb:PNOMB))     + ", 4, 'N' )"
            Else
               aDP[2] := "UPDATE historia SET tipoiden = '" +           ::oDb:TIPOIDEN    +;
                                           "', nroiden = '" + aDP[1]                      +;
                                         "', apellidos = '" +   ALLTRIM(::oDb:APELLIDOS)  +;
                                           "', nombres = '" +   ALLTRIM(::oDb:NOMBRES)    +;
                                              "', sexo = '" +           ::oDb:SEXO        +;
                                        "', fec_nacimi = "  +xValToChar(::oDb:FEC_NACIMI) +;
                                            ", uniedad = '" +           ::oDb:UNIEDAD     +;
                                              "', edad = "  + LTRIM(STR(::oDb:EDAD))      +;
                                           ", reshabit = '" +   ALLTRIM(::oDb:RESHABIT)   +;
                                          "', zonaresi = '" +           ::oDb:ZONARESI    +;
                                         "', direccion = '" +   ALLTRIM(::oDb:DIRECCION)  +;
                                        "', tel_reside = '" +   ALLTRIM(::oDb:TEL_RESIDE) +;
                                        "', tel_oficin = '" +   ALLTRIM(::oDb:TEL_OFICIN) +;
                                             "', email = '" +   ALLTRIM(::oDb:EMAIL)      +;
                                         "', ocupacion = '" +   ALLTRIM(::oDb:OCUPACION)  +;
                                          "', tipousua = '" +           ::oDb:TIPOUSUA    +;
                                         "', tipoafili = '" +           ::oDb:TIPOAFILI   +;
                                        "', nro_histor = "  + LTRIM(STR(::oDb:NRO_HISTOR))+;
                                              ", papel = "  + LTRIM(STR(::oDb:PAPEL))     +;
                                              ", pnomb = "  + LTRIM(STR(::oDb:PNOMB))     +;
                                           ", exportar = 'C'" +;
                                    " WHERE codigo_nit = "  + LTRIM(STR(aDP[3]))
            EndIf
            MSQuery( oApl:oLoc:hConnect,aDP[2] )
         EndIf
      EndIf
   EndIf
/*
   aDP := "C:\HisFw\Datos\"
   If !AbreDbf( "His","HISTORIA","HISTORIA",aDP,.t. )
      RETURN NIL
   EndIf
   His->(DBSETORDER( 5 ))
   His->(DbGoBottom())
   nFld := His->CODIGO_NIT + 1
   His->(dbAppend())
   His->TIPOIDEN   := oApl:oHis:TIPOIDEN  ; His->NROIDEN    := oApl:oHis:NROIDEN
   His->APELLIDOS  := oApl:oHis:APELLIDOS ; His->NOMBRES    := oApl:oHis:NOMBRES
   His->SEXO       := oApl:oHis:SEXO      ; His->FEC_NACIMI := oApl:oHis:FEC_NACIMI
   His->UNIEDAD    := oApl:oHis:UNIEDAD   ; His->EDAD       := oApl:oHis:EDAD
   His->RESHABIT   := oApl:oHis:RESHABIT  ; His->ZONARESI   := oApl:oHis:ZONARESI
   His->DIRECCION  := oApl:oHis:DIRECCION ; His->TEL_RESIDE := oApl:oHis:TEL_RESIDE
   His->TEL_OFICIN := oApl:oHis:TEL_OFICIN; His->EMAIL      := oApl:oHis:EMAIL
   His->OCUPACION  := oApl:oHis:OCUPACION ; His->TIPOUSUA   := oApl:oHis:TIPOUSUA
   His->TIPOAFILI  := oApl:oHis:TIPOAFILI ; His->CODIGO_NIT := nFld
   His->NRO_HISTOR := oApl:oHis:NRO_HISTOR; His->PAPEL      := oApl:oHis:PAPEL
   His->PNOMB      := oApl:oHis:PNOMB
   His->TAPEL      := LEN( TRIM(oApl:oHis:APELLIDOS) )
   His->TNOMB      := LEN( TRIM(oApl:oHis:NOMBRES) )
   His->(dbCloseArea())
*/
Else
   ::oDb:axBuffer[ 4 ] := PADR( XTRIM( aDP[1] ) + ALLTRIM( aDP[2] ),35 )
   ::oDb:axBuffer[ 5 ] := PADR( XTRIM( aDP[3] ) + ALLTRIM( aDP[4] ),30 )
  //::oDb:APELLIDOS:= XTRIM( aDP[1] ) + ALLTRIM( aDP[2] )
  //::oDb:NOMBRES  := XTRIM( aDP[3] ) + ALLTRIM( aDP[4] )
   FOR nFld := 2 TO ::oDb:nFieldCount
      If ::oDb:axBuffer[ nFld ] # ::aOld[ nFld ]
            lOK := .t.
         If EMPTY(::oDb:NROIDEN) .OR. EMPTY(aDP[1]) .OR. EMPTY(aDP[3])
            If nBtn == 1
               MsgStop("No es posible grabar este registro, debe completar datos" +CRLF+;
                       "Documento ID, Primer Apellido, Primer Nombre" )
            EndIf
            lOK := .f.
         EndIf
         EXIT
      EndIf
   NEXT nFld
EndIf
RETURN lOK

//------------------------------------//
METHOD SiExiste( lNuevo,aCam,oBtP ) CLASS TPer
   LOCAL cQry, hRes, lSi := .t.
If lNuevo == NIL
   If !EMPTY( ::oDb:FEC_NACIMI )
      If DATE() <= ::oDb:FEC_NACIMI
         MsgStop("Fecha del Sistema es MENOR",">> ERROR <<")
         lSi := .f.
      ElseIf YEAR( ::oDb:FEC_NACIMI ) < 1900
         MsgStop("Año de Nacimiento es MENOR de 1900",">> ERROR <<")
         lSi := .f.
      Else
         ::oDb:EDAD := If( !EMPTY( ::oDb:EDAD ), ::oDb:EDAD,;
                           NtChr( ::oDb:FEC_NACIMI,"A" ))
         oBtP:Refresh()
      EndIf
   EndIf
ElseIf lNuevo
   cQry := "SELECT nroiden FROM historia "+;
           "WHERE apellidos = " + xValToChar( XTRIM(aCam[1])+aCam[2] )+;
            " AND nombres = "   + xValToChar( XTRIM(aCam[3])+aCam[4] )
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   If MSNumRows( hRes ) > 0
      cQry := MyReadRow( hRes )
      MsgStop( "ya Existe Documento ID = " + cQry[1],"Este Paciente" )
      lSi := .f.
   EndIf
   MSFreeResult( hRes )
EndIf
RETURN lSi

//------------------------------------//
METHOD Listado() CLASS TPer
   LOCAL aHis := { 0,0,.f. }, cQry, oIni
If oApl:cLocal == "LOC"
   cQry := AbrirFile( 4,"Archivo de Ventas Opticas","*.DBF" )
   If (oIni := RAT( "\", cQry )) > 0
      cQry := LEFT( cQry,oIni )
   Else
      cQry := "A:"
   EndIf
   Empresa()
   aHis[3] := .t.
   oIni := ::oDb:Recno()
   ActuCedulas( @aHis,,cQry )
   BorraFile( "REPLICA",{"DBF"} )
   ::oDb:Go(oIni):Read()
   ::oLbx:GoTop()
   ::oLbx:Refresh()
   cQry := "UPDATE cadfactu c, histocli n SET c.codigo_cli = n.codigo_cli "+;
           "WHERE c.optica     = n.optica"    +;
            " AND c.codigo_cli = n.codigo_nit"+;
            " AND c.optica = " + LTRIM(STR(oApl:nEmpresa))
   MSQuery( oApl:oMySql:hConnect,cQry )
   MSQuery( oApl:oMySql:hConnect,STRTRAN(cQry,"factu","antic") )
Else
   INI oIni FILE ".\Nit.ini"
      GET cQry    SECTION "Historia" ENTRY "Ruta"      OF oIni;
          DEFAULT "\ProyecFW\His\Datos\"
      GET aHis[2] SECTION "Historia" ENTRY "CodigoNit" OF oIni;
          DEFAULT 1
   ENDINI
   ActuCedulas( @aHis,cQry )
   SET SECTION "Historia" ENTRY "CodigoNit" TO aHis[2] OF oIni
EndIf
MsgInfo( STR(aHis[1])+" Nuevos","INSERTE" )
RETURN NIL

//------------------------------------//
FUNCTION ActuCedulas( aHis,cRut,cHis )
   LOCAL cDoc, cQry, hRes, n, nFldCount
If aHis[3]
   cHis += "HCEDULAS.DBF"
   If !FILE( cHis )
      RETURN NIL
   EndIf
   hRes := oApl:cRuta2 + "REPLICA.DBF"
   COPY FILE &(cHis) TO &(hRes)
   If !AbreDbf( "His","REPLICA",,,.f. )
      RETURN NIL
   EndIf
   cHis := "SELECT codigo_cli FROM histocli " +;
           "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
        " AND codigo_nit = [NIT]"
   nFldCount := oApl:oHis:FieldCount()
Else
   If !AbreDbf( "His","HISTORIA","HISTORIA",cRut,.t. )
      RETURN NIL
   EndIf
   His->(DBSETORDER( 5 ))
   His->(dbSeek( STR(aHis[2],6) ))
EndIf
oApl:oWnd:SetMsg( "Por FAVOR espere estoy Actualizando" )
While !His->(EOF())
   cDoc := ALLTRIM( STRTRAN( His->NROIDEN,".","" ) )
   cQry :=    "nroiden = '" + cDoc                    +;
      "' OR (apellidos = '" + ALLTRIM(His->APELLIDOS) +;
      "' AND nombres = '"   + ALLTRIM(His->NOMBRES)   + "' )"
      aHis[2] := His->CODIGO_NIT
   If aHis[3]
      If EMPTY( cDoc ) .OR. cDoc == LTRIM(STR(His->NRO_HISTOR))
         His->(dbSkip())
         LOOP
      EndIf
      If His->EXPORTAR == "C"
         cRut := Buscar( STRTRAN( cHis,"[NIT]",LTRIM(STR(aHis[2])) ),"CM",,8 )
         If !EMPTY( cRut )
            cQry := "Codigo_nit = " + LTRIM(STR(cRut))
         EndIf
      EndIf
      oApl:oWnd:SetMsg( "Row_id = "+STR(His->CODIGO_NIT) )
   EndIf
   If !oApl:oHis:Seek( cQry,"CM" )
       oApl:oHis:Seek( "nroiden LIKE 'XXXXX%' LIMIT 1","CM" )
      If aHis[3] .AND. oApl:oHis:CODIGO_NIT == 0
         His->NROIDEN := cDoc
         cQry := "INSERT INTO historia VALUES ( "
         FOR n := 1 TO nFldCount
            cRut := FieldGet( n )
            cQry += If( MyIsAutoInc( oApl:oHis:hResult,n ), 'NULL'       ,;
                    If( VALTYPE( cRut ) == "C", ( '"' + ALLTRIM(cRut) + '"' ),;
                        xValToChar( cRut,1 ) ) ) + ", "
         NEXT n
         cQry := LEFT( cQry,LEN(cQry)-2 ) + ' )'
         MSQuery( oApl:oMySql:hConnect,cQry )
         oApl:oHis:Seek( "nroiden = '"+ cDoc +"'","CM" )
      Else
         oApl:oHis:TIPOIDEN  := His->TIPOIDEN  ; oApl:oHis:NROIDEN   := cDoc
         oApl:oHis:APELLIDOS := His->APELLIDOS ; oApl:oHis:NOMBRES   := His->NOMBRES
         oApl:oHis:SEXO      := His->SEXO      ; oApl:oHis:FEC_NACIMI:= His->FEC_NACIMI
         oApl:oHis:UNIEDAD   := His->UNIEDAD   ; oApl:oHis:EDAD      := His->EDAD
         oApl:oHis:RESHABIT  := His->RESHABIT  ; oApl:oHis:ZONARESI  := His->ZONARESI
         oApl:oHis:DIRECCION := His->DIRECCION ; oApl:oHis:TEL_RESIDE:= His->TEL_RESIDE
         oApl:oHis:TEL_OFICIN:= His->TEL_OFICIN; oApl:oHis:EMAIL     := His->EMAIL
         oApl:oHis:OCUPACION := His->OCUPACION ; oApl:oHis:TIPOUSUA  := His->TIPOUSUA
         oApl:oHis:TIPOAFILI := His->TIPOAFILI ; oApl:oHis:NRO_HISTOR:= His->NRO_HISTOR
         oApl:oHis:PAPEL     := His->PAPEL     ; oApl:oHis:PNOMB     := His->PNOMB
         oApl:oHis:OPTICA    := oApl:nEmpresa  ; oApl:oHis:EXPORTAR  := "N"
         Guardar( oApl:oHis,!oApl:oHis:lOK,.t. )
      EndIf
      aHis[1] ++
   ElseIf LEFT( cQry,6 ) == "Codigo"
      oApl:oHis:TIPOIDEN  := His->TIPOIDEN  ; oApl:oHis:NROIDEN   := cDoc
      oApl:oHis:APELLIDOS := His->APELLIDOS ; oApl:oHis:NOMBRES   := His->NOMBRES
      oApl:oHis:SEXO      := His->SEXO      ; oApl:oHis:FEC_NACIMI:= His->FEC_NACIMI
      oApl:oHis:UNIEDAD   := His->UNIEDAD   ; oApl:oHis:EDAD      := His->EDAD
      oApl:oHis:RESHABIT  := His->RESHABIT  ; oApl:oHis:ZONARESI  := His->ZONARESI
      oApl:oHis:DIRECCION := His->DIRECCION ; oApl:oHis:TEL_RESIDE:= His->TEL_RESIDE
      oApl:oHis:TEL_OFICIN:= His->TEL_OFICIN; oApl:oHis:EMAIL     := His->EMAIL
      oApl:oHis:OCUPACION := His->OCUPACION ; oApl:oHis:TIPOUSUA  := His->TIPOUSUA
      oApl:oHis:TIPOAFILI := His->TIPOAFILI ; oApl:oHis:NRO_HISTOR:= His->NRO_HISTOR
      oApl:oHis:PAPEL     := His->PAPEL     ; oApl:oHis:PNOMB     := His->PNOMB
      Guardar( oApl:oHis,.f.,.f. )
   EndIf
   If aHis[3] .AND. aHis[2] # oApl:oHis:CODIGO_NIT
      hRes := If( MSQuery( oApl:oMySql:hConnect,STRTRAN( cHis,"[NIT]",LTRIM(STR(aHis[2])) ) ),;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      If MSNumRows( hRes ) == 0
            //Row_id, Optica, Codigo_nit, Codigo_cli
         cQry := "INSERT INTO histocli VALUES( null, "    +;
                  LTRIM(STR(oApl:nEmpresa))        + ", " +;
                  LTRIM(STR(     His->CODIGO_NIT)) + ", " +;
                  LTRIM(STR(oApl:oHis:CODIGO_NIT)) + " )"
         Guardar( cQry,"histocli" )
      EndIf
      MSFreeResult( hRes )
   EndIf
   His->(dbSkip())
EndDo
His->(dbCloseArea())
RETURN NIL
/*
//------------------------------------//
FUNCTION Direcion( o,lCap )
   LOCAL cDir, oDlg, oGet
If lCap # nil
   cDir := { { " ","A","B","C","D","E","F","G","H","I","J","K","L","M"  ,;
               "N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z" },;
             { " ","BIS","SUR","ESTE","OESTE","1","2","3","4","5","6","7","8","9" } }
   oGet := ARRAY(9)
   DEFINE DIALOG oDlg TITLE "DIRECCION" FROM 2,02 TO 10,60
      @ 02, 04 SAY "CL         25       A        BIS           No.   48       F         SUR          -  100";
         OF oDlg PIXEL SIZE 220,10
      @ 16, 02 COMBOBOX oGet[1] VAR o:CALLE ITEMS { " ","CL","CR","TR","DG","AV" };
         SIZE 23,99 OF oDlg PIXEL
      @ 16, 27 GET oGet[2] VAR o:NUMERO1 OF oDlg PICTURE "999" SIZE 20,12 PIXEL
      @ 16, 49 COMBOBOX oGet[3] VAR o:LADO1 ITEMS cDir[1] ;
         SIZE 20,99 OF oDlg PIXEL
      @ 16, 71 COMBOBOX oGet[4] VAR o:CARDINAL1 ITEMS cDir[2] ;
         SIZE 34,99 OF oDlg PIXEL
      @ 16,107 SAY "No." OF oDlg PIXEL SIZE 12,12
      @ 16,121 GET oGet[5] VAR o:NUMERO2 OF oDlg PICTURE "999" SIZE 20,12 PIXEL
      @ 16,143 COMBOBOX oGet[6] VAR o:LADO2     ITEMS cDir[1] ;
         SIZE 20,99 OF oDlg PIXEL
      @ 16,165 COMBOBOX oGet[7] VAR o:CARDINAL2 ITEMS cDir[2] ;
         SIZE 34,99 OF oDlg PIXEL
      @ 16,201 SAY "-" OF oDlg PIXEL SIZE 08,12
      @ 16,208 GET oGet[8] VAR o:NUMERO3 OF oDlg PICTURE "999" SIZE 20,12 PIXEL
      @ 36, 90 BUTTON oGet[9] PROMPT "&OK"       SIZE 44,12 OF oDlg ;
         ACTION oDlg:End() PIXEL
      ACTIVAGET(oGet)
   ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
EndIf
cDir := XTRIM( o:CALLE )   +   XTRIM( o:NUMERO1 ) +;
        XTRIM( o:LADO1 )   + ALLTRIM( o:CARDINAL1 )
cDir += If( EMPTY( cDir ), "", " No. " )          +;
        XTRIM( o:NUMERO2 ) + XTRIM( o:LADO2 )     +;
        XTRIM( o:CARDINAL2 )                      +;
        If( EMPTY( o:NUMERO3 ), "", " - " )       + ALLTRIM( o:NUMERO3 )
RETURN cDir*/