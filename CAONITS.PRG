// Programa.: CAONITS.PRG     >>> Martin A. Toloza Lozano <<<
// Notas....: Modulo para la manipulacion de Nits
#include "Fivewin.ch"
#include "Objects.ch"
#include "btnget.ch"

MEMVAR oApl

FUNCTION Nits()
   LOCAL oNits := TNits()
oNits:New(,.f.)
oNits:Activate()
RETURN NIL

//------------------------------------//
CLASS TNits

 DATA cBus          INIT ""
 DATA cWhere        INIT ""
 DATA lBuscar       INIT .f.
 DATA nOrden        INIT 2
 DATA xVar          INIT 0
 DATA oFont         INIT Tfont():New("Ms Sans Serif",0,-10,,.f.)
 DATA aOrden, aOld, cLista, oDb, oCiu, oIndex, oLbx
 DATA bNew, bEditar, bVer
 DATA bBorrar, bBuscar, bPrint, lBorrar

 METHOD NEW( oTabla,lDel ) Constructor
 METHOD ACTIVATE() INLINE ::Mostrar( .f.,2 )
 METHOD Guardar( lNew )
 METHOD Editar( xRec,lNuevo,lView,nNit )
 METHOD Mostrar( lAyuda,nOrd,nCod )
 METHOD Ordenar( nOrd )
 METHOD Barra( lHelp,oDlg )
 METHOD Borrar( xRec )
 METHOD Buscar( uBus,cCampo,lTB,lNew )
 METHOD Buscando( cWhere )
 METHOD BuscaInc( nKey,cWhere )
 METHOD ChangeOrder()
 METHOD Cambios( aCam,nBtn )
 METHOD Listado()

ENDCLASS

//------------------------------------//
METHOD NEW( oTabla,lDel ) CLASS TNits
   DEFAULT oTabla := oApl:oNit, lDel := .t.
 ::aOrden  := { {"<None> "  ,1,.f.},{"Código"   ,2,.f.},;
                {"Nombre"   ,5,.t.},{"CódigoNit",11,.f.} }
//               {"Nombre"   ,"CONCAT(nombre,' ', apellido)"},;
//               {"Apellido" ,"CONCAT(apellido,' ', nombre)"},;
//::cLista  := "codigo, nombre, telefono"
 ::oDb     := oTabla
 ::bNew    := {||::Editar( ::oDb:Recno(),.t. ),    ;
                 ::oLbx:SetFocus(),::oLbx:Refresh()  }
 ::bEditar := {||::Editar( ::oDb:Recno(),.f. ),    ;
                 ::oLbx:SetFocus(),::oLbx:Refresh()  }
 ::bVer    := {||::Editar( ::oDb:Recno(),.f.,.t. ),;
                 ::oLbx:SetFocus(),::oLbx:Refresh()  }
 ::bBorrar := {||::Borrar( ::oDb:Recno() ),        ;
                 ::oLbx:SetFocus(),::oLbx:Refresh()  }
 ::bBuscar := {|| ::cBus := If( EMPTY( ::cBus ), ::Buscando(), "" ),;
                  ::oLbx:SetFocus(),::oLbx:Refresh() }
 ::bPrint  := {|| ::Listado() }
 ::lBorrar := lDel
If ::oDb:cName == "cadclien"
   ::oCiu := TRip()
   ::oCiu:New( 1,.f. )
EndIf
RETURN NIL

//------------------------------------//
METHOD Mostrar( lAyuda,nOrd,nCod ) CLASS TNits
   LOCAL oDlg, oM := Self
   LOCAL cTit := "Ayuda de Nits", bHacer, lReturn := NIL
   DEFAULT lAyuda := .t. , nOrd := 3, nCod := 0
If lAyuda
   bHacer  := {|| ::lBuscar := lReturn := .t., oDlg:End()}
   lReturn := .f.
ELSE
   bHacer  := ::bEditar
   cTit    := "Clientes o Proveedores"
ENDIF
 ::xVar := nCod
nOrd   := ::Ordenar( nOrd )
If ::oDb:cName == "cadclien" .AND. nCod > 0
   ::oDb:Seek( {"codigo",nCod} )
EndIf

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE cTit
   @ 1.5, 0 LISTBOX ::oLbx FIELDS   ;
         TRANSFORM( ::oDb:CODIGO,"999,999,999,999"),;
         OEMTOANSI( ::oDb:NOMBRE ) ,;
                   ::oDb:TELEFONO  ;
      HEADERS "Nit ó"+CRLF+"Cédula","Nombre","Telefono" ;
      SIZES 400, 450 SIZE 200,107  ;
      OF oDlg UPDATE               ;
      ON DBLCLICK EVAL(bHacer)
    ::oLbx:nClrBackHead  := oApl:nClrBackHead
    ::oLbx:nClrForeHead  := oApl:nClrForeHead
    ::oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    ::oLbx:nClrBackFocus := oApl:nClrBackFocus
    ::oLbx:nClrForeFocus := oApl:nClrForeFocus
    ::oLbx:GoTop()
    ::oLbx:oFont      := ::oFont
    ::oLbx:nHeaderHeight := 28
    ::oLbx:aColSizes  := {80,240,110}
    ::oLbx:aHjustify  := {2,2,2}
    ::oLbx:aJustify   := {1,0,0}
    ::oLbx:ladjbrowse  := ::oLbx:lCellStyle  := .f.
    ::oLbx:ladjlastcol := .t.
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN, EVAL(bHacer),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(::BNew),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=69, EVAL(::bEditar)		    ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=86, EVAL(::bVer) 		      ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, EVAL(::bBorrar) ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) ))))) }
   MySetBrowse( ::oLbx, ::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
//        UPPER(SUBSTR(::cBus,1,1))+LOWER(SUBSTR(::cBus,2,LEN(::cBus)-1) );
ACTIVATE DIALOG oDlg CENTER ON INIT (oM:Barra(lAyuda,oDlg))

 ::oDb:Setorder(nOrd)

RETURN lReturn

//------------------------------------//
METHOD Ordenar( nOrd ) CLASS TNits

 ::cBus   := ""
 ::nOrden := nOrd
nOrd     := ::oDb:Setorder( ::aOrden[ ::nOrden,2 ] )
If ::oDb:RecCount() > 0
   ::oDb:GoTop():Read()  // Hacer siempre un Read() para cargar el buffer interno
   ::oDb:xLoad()
Else
   ::oDb:xBlank():Read()
EndIf

RETURN nOrd

//------------------------------------//
METHOD Editar(xRec,lNuevo,lView,nNit) CLASS TNits
   LOCAL oDlg, oGet := ARRAY(20), oE := Self
   LOCAL aEd  := { "Nuevo Nit",.f.,0, }
   LOCAL aNom := { SPACE(35),SPACE(15),SPACE(20),SPACE(20) }
   DEFAULT lNuevo := .t. , lView := .f. ,;
           xRec   :=  0  , nNit  := ::xVar
If lNuevo
   ::oDb:xBlank()
   ::oDb:Read()
   ::oDb:CODIGO     := nNit
   ::oDb:TIPOCOD    := 1
   ::oDb:CODIGO_CIU := oApl:oEmp:RESHABIT
   aEd[3] := SgteNumero( "NUMPROVEED",0,.f. )
   aEd[1] += STR( aEd[3] )
Else
   lView   := If( ::oDb:CODIGO == 0, .t., lView )
    aEd[1] := If( lView, "Viendo", "Modificando" ) + " Nit"
   aNom[1] := ::oDb:NOMBRE
//   aNom[1] := PADR( SUBSTR( ::oDb:NOMBRE  ,1,::oDb:PNOMB ),35 )
//   aNom[2] := PADR( SUBSTR( ::oDb:NOMBRE  ,2+::oDb:PNOMB ),15 )
//   aNom[3] := PADR( SUBSTR( ::oDb:APELLIDO,1,::oDb:PAPEL ),20 )
//   aNom[4] := PADR( SUBSTR( ::oDb:APELLIDO,2+::oDb:PAPEL ),20 )
   nNit    := ::oDb:CODIGO
EndIf
 ::aOld := ACLONE( ::oDb:axBuffer )
 ::oCiu:oDb:Seek( { "codigo",::oDb:CODIGO_CIU } )
//aNom   := Separar( ::oDb:NOMBRE,::oDb:PA,::oDb:SA,::oDb:PN,::oDb:SN )
aEd[4] := {|| ::oDb:DIGITO  := DigitoVerifica( ::oDb:CODIGO )   ,;
              oDlg:Update(), xRec := ::Buscar( ::oDb:CODIGO )   ,;
              If( (xRec .AND.  lNuevo) .OR.                      ;
                  (xRec .AND. !lNuevo .AND. ::oDb:CODIGO # nNit),;
                ( MsgNoYes("Nit ó Cédula ya existe") ), .t. ) }
DEFINE DIALOG oDlg TITLE aEd[1] FROM 0, 0 TO 285,570 PIXEL
   @  04, 00 SAY "Cédula / Nit" OF oDlg RIGHT PIXEL SIZE 48,10
   @  04, 50 GET oGet[1] VAR ::oDb:CODIGO OF oDlg ;
      PICTURE "999,999,999,999"                   ;
      VALID EVAL( aEd[4] ) SIZE 50,10 PIXEL
   @  04,102 SAY "DV"         OF oDlg RIGHT PIXEL SIZE 12,10
   @  04,116 GET oGet[2] VAR ::oDb:DIGITO OF oDlg ;
      PICTURE "9" SIZE 10,10 PIXEL UPDATE
   @  04,142 SAY "Código Nit" OF oDlg RIGHT PIXEL SIZE 48,10
   @  04,192 SAY oGet[3] VAR ::oDb:CODIGO_NIT OF oDlg ;
      PICTURE "99,999" SIZE 30,10 PIXEL
   @  16, 00 SAY "Tipo de NIT" OF oDlg RIGHT PIXEL SIZE 48,10
   @  16, 50 COMBOBOX oGet[04] VAR ::oDb:TIPOCOD PROMPTS      ;
      {"Cliente","Proveedor","Cliente y Proveedor"};
      SIZE 70,99 OF oDlg PIXEL
//      {"Cliente","Proveedor","Cliente y Proveedor","Paciente"};
//      ON CHANGE( MsgInfo( oE:oDb:TIPOCOD,"TIPO" ), oDlg:Update() )
   @  28, 00 SAY "Primer Nombre ó Razon Social"  OF oDlg RIGHT PIXEL SIZE 48,20
   @  28, 50 GET oGet[05] VAR aNom[1] OF oDlg PICTURE "@!";
      VALID EVAL( { || If( !EMPTY( aNom[1] ), .t. ,;
                 (MsgInfo( "Es obligatorio el 1er.Nombre" ), .f.) ) } );
      SIZE 130,10 PIXEL
   @  17,192 SAY "Segundo Nombre" OF oDlg PIXEL SIZE 50,10
   @  28,192 GET oGet[06] VAR aNom[2] OF oDlg PICTURE "@!";
      WHEN ::oDb:TIPOCOD == 4 SIZE 80,10 PIXEL
   @  42, 00 SAY "Primer Apellido" OF oDlg RIGHT PIXEL SIZE 48,10
   @  42, 50 GET oGet[07] VAR aNom[3] OF oDlg PICTURE "@!";
      VALID EVAL( { || If( !EMPTY( aNom[3] ), .t. ,;
                 (MsgInfo( "Es obligatorio el 1er.Apellido" ), .f.) ) } );
      WHEN ::oDb:TIPOCOD == 4 SIZE 90,10 PIXEL
   @  42,140 SAY "Segundo Apellido" OF oDlg RIGHT PIXEL SIZE 50,10
   @  42,192 GET oGet[08] VAR aNom[4] OF oDlg PICTURE "@!";
      WHEN ::oDb:TIPOCOD == 4 SIZE 80,10 PIXEL
//      VALID ::SiExiste( lNuevo,aNom,oGet[19] )
   @  54, 00 SAY "Dirección" OF oDlg RIGHT PIXEL SIZE 48,10
   @  54, 50 GET oGet[09] VAR ::oDb:DIRECCION OF oDlg SIZE 130,10 PIXEL
   @  66, 00 SAY "Telefono"  OF oDlg RIGHT PIXEL SIZE 48,10
   @  66, 50 GET oGet[10] VAR ::oDb:TELEFONO  OF oDlg SIZE  80,10 PIXEL
   @  66,142 SAY "Fax o Celular" OF oDlg RIGHT PIXEL SIZE 48,10
   @  66,192 GET oGet[11] VAR ::oDb:FAX       OF oDlg SIZE  80,10 PIXEL
   @  78, 00 SAY "Email" OF oDlg RIGHT PIXEL SIZE 48,10
   @  78, 50 GET oGet[12] VAR ::oDb:EMAIL     OF oDlg SIZE 130,10 PIXEL
   @  90, 00 SAY "Cíudad" OF oDlg RIGHT PIXEL SIZE 48,10
   @  90, 50 BTNGET oGet[13] VAR oE:oDb:CODIGO_CIU OF oDlg PICTURE "99999";
      ACTION EVAL({|| If( oE:oCiu:Mostrar(), (oE:oDb:CODIGO_CIU := oE:oCiu:oDb:CODIGO,;
                         oGet[13]:Refresh(), oGet[13]:lValid(.f.)), ) })  ;
      SIZE 30,10 PIXEL UPDATE  RESOURCE "BUSCAR"                          ;
      VALID  EVAL({|| If( oE:oCiu:oDb:Seek( {"codigo",oE:oDb:CODIGO_CIU}),;
                        ( oDlg:Update(), .t. )                           ,;
                        ( MsgStop("Está Ciudad no Existe"),.f.) ) } )
   @  90, 84 SAY ::oCiu:oDb:NOMBRE OF oDlg PIXEL SIZE 110,10 UPDATE
   @ 102, 00 SAY "% Descuento"     OF oDlg RIGHT PIXEL SIZE 48,10
   @ 102, 50 GET oGet[14] VAR ::oDb:POR_DSCTO OF oDlg PICTURE "999.99";
      SIZE 40,10 PIXEL
   @ 102, 92 SAY "Valor Consulta" OF oDlg RIGHT PIXEL SIZE 48,10
   @ 102,142 GET oGet[15] VAR ::oDb:CONSULTA OF oDlg PICTURE "99,999,999";
      SIZE 50,10 PIXEL
   @ 102,196 CHECKBOX oGet[16] VAR ::oDb:EPS      PROMPT "EPS" OF oDlg;
      SIZE 40,12 PIXEL
   @ 102,240 CHECKBOX oGet[17] VAR ::oDb:CONVENIO PROMPT "Convenio" OF oDlg;
      SIZE 60,12 PIXEL
   @ 114, 50 CHECKBOX oGet[18] VAR ::oDb:AUTORETEN PROMPT "AutoRetenedor" OF oDlg;
      SIZE 60,12 PIXEL
   @ 118,100 BUTTON oGet[19] PROMPT "Grabar"   SIZE 44,14 OF oDlg ACTION;
      ( If( ::Cambios( aNom,1 ), (aEd[2] := .t.,oDlg:End()),;
          ( oGet[1]:SetFocus() ))) PIXEL
    oGet[19]:cToolTip := "Graba estos Datos"
   @ 118,148 BUTTON oGet[20] PROMPT "Cancelar" SIZE 44,14 OF oDlg CANCEL;
      ACTION ( If( ::Cambios( aNom,2 )                    ,;
               If( MsgYesNo( "Desea Guardar los Cambios" ),;
                   aEd[2] := .t. , ), ), oDlg:End() ) PIXEL
    oGet[20]:cToolTip := "Regresa al menu Anterior"
   ACTIVAGET(oGet)
   IF lView                     // Solo Consulta
      DesactivaALLGET(oGet)
      oGet[19]:Disable()
      oGet[20]:Enable()
      oGet[20]:SetFocus()
   ENDIF
ACTIVATE DIALOG oDlg CENTER
If aEd[2]
    //::oDb:PA := LEN( ALLTRIM( aNom[1] ) )
    //::oDb:SA := LEN( ALLTRIM( aNom[2] ) )
    //::oDb:PN := LEN( ALLTRIM( aNom[3] ) )
    //::oDb:SN := LEN( ALLTRIM( aNom[4] ) )
   If lNuevo
      //If ::oDb:TIPOCOD >= 2
      //   aEd[3] := SgteNumero( "NUMPROVEED",0,.t. )
      //   ::oDb:CODIGOPRV := aEd[3]
      //EndIf
      ::oDb:CODIGO_NIT := Buscar( "SELECT MAX(codigo_nit) FROM cadclien","CM" ) + 1
      ::oDb:EXPORTAR   := If( oApl:lEnLinea, "N", "P" )
      ::Guardar( lNuevo )
      ::oDb:Seek( { "codigo",::oDb:CODIGO } )
   Else
      ::oDb:EXPORTAR   := "C"
      ::Guardar( lNuevo )
   EndIf
EndIf
 ::aOld := NIL
RETURN NIL

//------------------------------------//
METHOD Guardar( lNew ) CLASS TNits
   If lNew
      ::oDb:Append( .t. )
   Else
      ::oDb:Update(.t.,1)
   EndIf
RETURN NIL

//------------------------------------//
METHOD Borrar(xRec) CLASS TNits
   LOCAL nRecNo := ::oDb:RecNo()
If ::lBorrar
   If MsgNoYes( "Esta seguro que desea"+ CRLF + "eliminar este registro "+;
                STR(::oDb:row_id)+"?", "MySQL" )
      ::oDb:GoTo(xRec)
      ::oDb:Read()
      If ::oDb:Delete(.t.,1)
         MsgInfo("Borrado exitoso!!!","Borrado en el servidor")
         ::oDb:Refresh()
         ::oDb:GoTo(nRecNo)
         If ::oDb:lEof
            ::oDb:Read()
         Else
            ::oDb:Read()
            ::oDb:xLoad()
         EndIf
         ::oLbx:Refresh()
      EndIf
   EndIf
Else
   MsgStop( "Esta Prohibido Borrar","IMPOSIBLE" )
EndIf

RETURN NIL

//------------------------------------//
METHOD Buscar( uBus,cCampo,lTB,lNew ) CLASS TNits
   LOCAL cQry, hRes, lSi := .t., nRow := 0
   DEFAULT cCampo := "codigo", lTB := .f., lNew := .t.
If !::lBuscar
   If lTB
      ::oDb:Seek( {cCampo,uBus} )
         lSi := ( ::oDb:nRowCount != 0 )
      If ::oDb:nRowCount > 1
         MsgStop( cCampo+" Está en (" + STR(::oDb:nRowCount) + " ) Registros","Buscar por AYUDA" )
         lSi := .f.
      EndIf
   Else
      cQry := "SELECT " + If( ::oDb:cName == "historia", "CONCAT(apellidos, ' ', nombres)",;
                          If( ::oDb:cName == "cadclien", "nombre", (cCampo) ) )           +;
              " FROM "  + ::oDb:cName +;
              " WHERE " + (cCampo) + " = " + xValToChar( uBus )
      hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      nRow := MSNumRows( hRes )
      lSi  := If( !lNew .AND. nRow > 0, .f., ( nRow != 0 ) )
      cQry := ""
      While nRow > 0
         cCampo := MyReadRow( hRes )
         cQry += (STR(nRow,3) + ".  " + cCampo[1] + CRLF)
         nRow --
      EndDo
      MSFreeResult( hRes )
      If lSi
         MsgStop( cQry,">> Está en <<" )
      EndIf
   EndIf
EndIf
 ::lBuscar := .f.
RETURN lSi

//------------------------------------//
METHOD Buscando( cWhere ) CLASS TNits
   LOCAL cBus := "%" + SPACE(24), nOldRec := ::oDb:Recno()
   LOCAL nTab := ::aOrden[ ::nOrden,2 ]
   DEFAULT cWhere := ""
If MsgGet( ::aOrden[ ::nOrden,1 ],"Buscar",@cBus )
   cBus := UPPER( ALLTRIM( cBus ) )
   cBus += If( RIGHT( cBus ) == "%", "", "%" )
   If ::oDb:Find( nTab, cBus, cWhere ) == 0
      MessageBeep()
      Msginfo( "Termino la busqueda"+ CRLF +"Examine o corrija","Advertencia!!!" )
      ::oDb:Go(nOldRec):Read()
   Else
      ::cBus := cBus
      ::oDb:GoTop():Read()
   EndIf
EndIf

RETURN ::cBus

//------------------------------------//
METHOD BuscaInc( nKey,cWhere ) CLASS TNits
   LOCAL bSeek, cQry, nTab := ::aOrden[ ::nOrden,2 ]
   DEFAULT cWhere := ""
bSeek := {|| If( ::oDb:Find( nTab, ALLTRIM(::cBus), cWhere ) == 0     ,;
               ( MessageBeep()                                        ,;
                 If( ::aOrden[ ::nOrden,3 ] .AND. LEN( ::cBus ) >= 3  ,;
                   ( ::cBus := "%" + STRTRAN(::cBus,"%","") + "%" )   ,;
                   ( Msginfo( "Termino la busqueda" + CRLF +           ;
                              "Examine o corrija","Advertencia!!!" )  ,;
                     ::cBus := STUFF( ::cBus,LEN( ::cBus )-1 ),"" ) ) ,;
                 ::oDb:Find( nTab, ALLTRIM(::cBus), cWhere ) ), )     ,;
                 ::oDb:GoTop():Read()                                 ,;
                 ::oLbx:GoTop(), ::oLbx:Refresh() }
/*
SELECT * FROM ciudad_barrios
WHERE MATCH(nombre) AGAINST('angelita')
                 ::cBus := LEFT( ::cBus,LEN( ALLTRIM( ::cBus ) )-2 ) + "%",;
                 If( ::aOrden[ ::nOrden,3 ] .AND. LEN( ::cBus ) >= 3      ,;
                   ( ::cBus := "%" + STRTRAN(::cBus,"%","") + "%" )       ,;
                   ( ::cBus := STUFF( ::cBus,LEN( ::cBus )-1 ),"" ) )     ,;
*/
If nKey # VK_RETURN
   ::cBus := STRTRAN(::cBus,"%","")
   do Case
      Case nKey == VK_BACK
         ::cBus := LEFT( ::cBus,LEN( ALLTRIM( ::cBus ) )-1 ) + "%"
      Case nKey == VK_ESCAPE
         ::cBus := "%"
      Case nKey >= 32
         ::cBus += UPPER( CHR( nKey ) )+"%"
   EndCase
   EVAL(bSeek)
EndIf

RETURN ::cBus

//------------------------------------//
METHOD Cambios( aCam,nBtn ) CLASS TNits
   LOCAL lOK := .f., nFld, xVal
//xVal := XTRIM( aCam[1] ) +   XTRIM( aCam[2] ) +;
//        XTRIM( aCam[3] ) + ALLTRIM( aCam[4] )
 nFld := ::oDb:FieldLength( 5 )
 xVal := XTRIM( aCam[1] ) + ALLTRIM( aCam[2] )
 ::oDb:axBuffer[ 5 ] := PADR( xVal,nFld )
 FOR nFld := 2 TO ::oDb:nFieldCount
    If ::oDb:axBuffer[ nFld ] # ::aOld[ nFld ]
          lOK := .t.
       If EMPTY(::oDb:CODIGO) .OR. EMPTY(aCam[1]) .OR. EMPTY(::oDb:DIRECCION) .OR.;
               (::oDb:TIPOCOD == 4 .AND. EMPTY(aCam[3]) )
          If nBtn == 1
             MsgStop("No es posible grabar este registro, debe completar datos" +CRLF+;
                     "Cédula / NIT, Primer Nombre, Primer Apellido" )
          EndIf
          lOK := .f.
       EndIf
       EXIT
    EndIf
 NEXT nFld
RETURN lOK

//------------------------------------//
METHOD Listado() CLASS TNits
   LOCAL oRpt, nConta := 0, nReg := ::oDb:Recno(), cPict
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"LISTADO DE NITS","",;
         "N O M B R E-------------------- DOC No. DOCUMENTO  CODIGO  "+;
         "TELEFONOS-------  F A X     D I R E C C I O N"},,,2 )
oRpt:lPreview := MsgNoYes( "Vista Previa", ">>> Desea Ver <<<" )
 ::oDb:GoTop():Read()
 ::oDb:xLoad()
While !::oDb:Eof()
   If ::oDb:TIPOCOD # 2
/*    ::oDb:Go( Nits->(RECNO()) ) ; ::oDb:Read()
      If LenNum(Nits->CODIGO) == 10
         cPict := LEFT( STR(Nits->CODIGO),11 )
         ::oDb:CODIGO := VAL( cPict )
      EndIf
      ::oDb:DIGITO := DigitoVerifica( ::oDb:CODIGO )
      ::oDb:Replace() */
      cPict := TransForm( ::oDb:CODIGO,"999,999,999" ) +;
               If( LenNum(::oDb:CODIGO) > 4, "-"+STR(::oDb:DIGITO), "" )
      oRpt:Titulo( 130 )
      oRpt:Say( oRpt:nL,00,::oDb:NOMBRE,31 )
      oRpt:Say( oRpt:nL,32,If( ::oDb:TIPOCOD = 0, " CC", "NIT" ))
      oRpt:Say( oRpt:nL,36,cPict )
      oRpt:Say( oRpt:nL,51,TransForm( ::oDb:CODIGO_NIT,"99,999" ))
      oRpt:Say( oRpt:nL,59,::oDb:TELEFONO )
      oRpt:Say( oRpt:nL,77,::oDb:FAX )
      oRpt:Say( oRpt:nL,87,::oDb:DIRECCION )
      oRpt:nL ++
      nConta   ++
   EndIf
   ::oDb:Skip(1):Read()
   ::oDb:xLoad()
EndDo
If nConta > 0
   oRpt:Say( oRpt:nL++,00,Replicate ("_",130) )
   oRpt:Say( oRpt:nL  ,10,"TOTAL NITS ESTE LISTADO...." + STR( nConta,4 ) )
EndIf
oRpt:NewPage()
oRpt:End()
 ::oDb:Go(nReg):Read()
 ::oLbx:GoTop()
 ::oLbx:Refresh()
RETURN NIL
/*
//------------------------------------//
METHOD Listado() CLASS TPer
   LOCAL aHis, cQry, hRes, nCNit, oIni
INI oIni FILE ".\Nit.ini"
   GET cQry  SECTION "Historia" ENTRY "Ruta"      OF oIni;
       DEFAULT "\ProyecFW\His\Datos\"
   GET nCNit SECTION "Historia" ENTRY "CodigoNit" OF oIni;
       DEFAULT 1
ENDINI
If !AbreDbf( "His","HISTORIA","HISTORIA",cQry,.t. )
   RETURN NIL
EndIf
oApl:oWnd:SetMsg( "Por FAVOR espere estoy Actualizando" )
aHis := { 0,0,"" }
His->(DBSETORDER( 5 ))
His->(dbSeek( STR(nCNit,6) ))
While !His->(EOF())
   cQry := STRTRAN( His->NROIDEN,".","" )
   cQry := STRTRAN( cQry,"-","" )
   aHis[2] := INT( VAL(cQry) )
   If His->NRO_HISTOR # aHis[2]
      cQry := "Codigo  = "   + LTRIM(STR(aHis[2]))         +;
          " OR (Nombre = "   + xValToChar( His->NOMBRES )  +;
          " AND Apellido = " + xValToChar( His->APELLIDOS )+ ")"
      If !::oDb:Seek( cQry,"CM" )
         ::oDb:CODIGO    := aHis[2]        ; ::oDb:TIPOCOD   := 4
         ::oDb:DIGITO    := DigitoVerifica( ::oDb:CODIGO )
         ::oDb:NOMBRE    := His->NOMBRES   ; ::oDb:APELLIDO  := His->APELLIDOS
         ::oDb:TELEFONO  := His->TEL_RESIDE; ::oDb:FAX       := His->TEL_OFICIN
         ::oDb:DIRECCION := His->DIRECCION ; ::oDb:EMAIL     := His->EMAIL
         ::oDb:CODIGO_CIU:= His->RESHABIT  ; ::oDb:EXPORTAR  := "N"
         ::oDb:PAPEL     := His->PAPEL     ; ::oDb:PNOMB     := His->PNOMB
         ::oDb:CODIGO_NIT:= Buscar( "SELECT MAX(codigo_nit) FROM cadclien","CM" ) + 1
         ::oDb:Insert( .f. )
         aHis[1] ++
      EndIf
   EndIf
   nCNit := His->CODIGO_NIT
   His->(dbSkip())
EndDo
His->(dbCloseArea())
SET SECTION "Historia" ENTRY "CodigoNit" TO nCNit OF oIni
MsgInfo( STR(aHis[1])+" Nuevos","INSERTE" )
RETURN NIL
*/
//------------------------------------//
METHOD Barra(lHelp,oDlg) CLASS TNits
   LOCAL oBar, oBot := ARRAY(7)
DEFINE BUTTONBAR oBar OF oDlg 3DLOOK SIZE 28,28

DEFINE BUTTON oBot[1] RESOURCE "NUEVO"    OF oBar NOBORDER ;
   TOOLTIP "Nuevo Registro (Ctrl+N)" ;
   ACTION Eval(::bNew)
DEFINE BUTTON oBot[2] RESOURCE "EDIT"     OF oBar NOBORDER ;
   TOOLTIP "Editar Registro (Ctrl+E)";
   ACTION Eval(::bEditar)
DEFINE BUTTON oBot[3] RESOURCE "VER"      OF oBar NOBORDER ;
   TOOLTIP "Ver datos (Ctrl+V)" ;
   ACTION Eval(::bVer)
DEFINE BUTTON oBot[4] RESOURCE "ELIMINAR" OF oBar NOBORDER ;
   TOOLTIP "Eliminar (Ctrl+DEL)" ;
   ACTION Eval(::bBorrar)
DEFINE BUTTON oBot[5] RESOURCE "BUSCAR"   OF oBar NOBORDER ;
   TOOLTIP "Localizar (Ctrl+L)"  ;
   ACTION Eval(::bBuscar) GROUP
DEFINE BUTTON oBot[6] RESOURCE "PRINT"    OF oBar NOBORDER ;
   TOOLTIP "Imprimir" ;
   ACTION Eval(::bPrint)
DEFINE BUTTON oBot[7] RESOURCE "QUIT"     OF oBar NOBORDER ;
   TOOLTIP "Salir"    ;
   ACTION (oDlg:End())    GROUP
// Crear combobox para indices
   @ .45,36 COMBOBOX ::oIndex VAR ::nOrden;
          ITEMS ArrayCol( ::aOrden,1 )    ;
          SIZE 95, 120 FONT ::oFont ;
          COLOR CLR_BLACK, NIL  OF oBar
   ::oIndex:cTooltip := "Selecione el orden"
   ::oIndex:bChange  := {|| ::cBus := If( !EMPTY(::cBus) .AND. ::nOrden # 1    ;
                                  .AND. VALTYPE( ::aOrden[::nOrden,2] ) == "N",;
                             xValBuscar( ::oDb:FldLoad(::aOrden[::nOrden,2]) ),;
                             "%" ), oDlg:Update(), ::ChangeOrder()   ,;
                            ::oDb:Find( ::aOrden[::nOrden,2],::cBus ),;
                            ::oDb:GoTop():Read()                     ,;
                            ::oLbx:GoTop(), ::oLbx:Refresh() }
   ::oIndex:Set3DLook()
IF lHelp
   oBot[4]:Disable()
   oBot[6]:Disable()
ENDIF
 oBar:bRClicked := {|| NIL }
 oBar:bLClicked := {|| NIL }
RETURN oBar

//------------------------------------//
METHOD ChangeOrder() CLASS TNits
   LOCAL nOrder := ::aOrden[ ::nOrden,2 ]
CursorWait()

 ::oDb:SetOrder( nOrder )
 ::oDb:GoTop():Read()

 ::oIndex:Refresh()
 ::oLbx:GoTop()
 ::oLbx:Refresh()
 ::oLbx:SetFocus()

CursorArrow()

RETURN .T.

//------------------------------------//
FUNCTION DigitoVerifica( nNit )
   LOCAL aP, cNum, nDV := 0, nSuma
If LENNUM( nNit ) > 4
   aP    := { 71,67,59,53,47,43,41,37,29,23,19,17,13,7,3 }
   cNum  := STRZERO( nNit,15 )
   nSuma := 0
   FOR nDV  := 15 TO 1 STEP -1
      nNit  := VAL(SUBSTR( cNum,nDV,1 ))
      nSuma += (nNit * aP[nDV])
   NEXT
   nDV := nSuma % 11            // Resto
// nDV := INT(nSuma / 11)       // Resto
// nDV := nSuma - (11*nDV)      // Residuo
   If nDV > 1
      nDV := 11 - nDV
   EndIf
EndIf
RETURN nDV

//------------------------------------//
FUNCTION FormatoNit( nNit,nDV )
   LOCAL cDV := If( LenNum(nNit) > 4, "-"+STR(nDV,1), "" )
RETURN TransForm( nNit,"999,999,999" ) + cDV
/*
//------------------------------------//
FUNCTION Separar( cNom,nPA,nSA,nPN,nSN )
   LOCAL aNom := { "",SPACE(20),SPACE(15),SPACE(15) }
If nPA > 0
   aNom[1] := PADR( SUBSTR( cNom,  1,nPA ),40 )
   nPA     += 2
   aNom[2] := PADR( SUBSTR( cNom,nPA,nSA ),20 )
   nPA     += nSA + 1
   aNom[3] := PADR( SUBSTR( cNom,nPA,nPN ),15 )
   nPA     += nPN + 1
   aNom[4] := PADR( SUBSTR( cNom,nPA,nSN ),15 )
Else
   aNom[1] := cNom
EndIf
RETURN aNom
*/
//------------------------------------//
FUNCTION xValBuscar( uVal )
   LOCAL cType := VALTYPE( uVal ), cValor := ""
do Case
Case cType == "C"
   cValor := ALLTRIM( uVal )
case cType == "D"
   cValor := MyDToMs( DToS( uVal ) )
case cType == "L"
   cValor := MyLToMs( uVal )
Case cType == "N"
   cValor := LTRIM( STR( uVal ) )
EndCase
RETURN cValor + "%"