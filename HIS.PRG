/* Programa............................ HIS
*    Sistema De Historias Clinicas
*  Fecha de escritura...................08.04.2009
*  Fecha de Culminacion .................
*  Version ..............................1.0 para windows 9x
*  Lenguaje ...................CA-Clipper for Windows Library(fiveWin 2.0)
*  Programador ................. Martin A. Toloza Lozano
*/
#include "Fivewin.ch"        //Incluir Archivos Nesaarios
#include "Colors.ch"
#include "Objects.ch"
#include "Eagle1.ch"

MEMVAR oApl

FUNCTION Main()
   LOCAL  hBorland, oBru, oIco
   PUBLIC oApl
SET CENTURY ON
SET EXACT ON
SET CONFIRM ON
SET EPOCH TO 1990
SET DATE FORMAT TO "DD.MM.YYYY"
SET DELETED ON
SET _3DLOOK ON

//hBorland := LoadLibrary( "BWCC.dll" )
//SETHANDLECOUNT(80)          // Establece el numero de archivo abiertos
REQUEST DBFCDX              // Utilizar el RDD cdx
RDDSETDEFAULT("DBFCDX")
SETKEY( VK_F4,{||Empresa()} )

oApl := THis()
oApl:New()

DEFINE ICON  oIco RESOURCE "DATOS"
DEFINE BRUSH oBru FILE oApl:FondoWnd()

// Definir Ventana Principal
DEFINE WINDOW oApl:oWnd FROM 1,1 TO 400,600 PIXEL  ;
   TITLE oApl:cEmpresa +                           ;
       " [ Sistema de Historias Clinicas ver 2.0 ]";
   BRUSH oBru                                      ;
   MENU Creamenu( "menuhis" )                      ;
   MDI ICON oIco                                   ;
   COLOR CLR_BLUE,RGB(0,128,192)
   SET MESSAGE OF oApl:oWnd TO "Tolozano. Telf: 3649075  Celular: 300-8045043, 321-6627536";
       TIME DATE KEYBOARD
  // BarraMenu( "menuhis" )
   DEFINE BUTTONBAR OF oApl:oWnd 3DLOOK SIZE 40,40
      DEFINE BUTTON RESOURCE "DOCUMENTOS2" OF oApl:oWnd:oBar NOBORDER ;
         TOOLTIP "Acceso a las Historias (Ctrl+H)";
         ACTION Historia()
      DEFINE BUTTON RESOURCE "ADISCO"      OF oApl:oWnd:oBar NOBORDER ;
         TOOLTIP "Disco con los datos para el RIP"                    ;
         ACTION Diskette( 3 ) GROUP
      DEFINE BUTTON OF oApl:oWnd:oBar NOBORDER ;
         FILENAME oApl:cIco+"Database.bmp"     ;
         ACTION oApl:UtilDB()                  ;
         MESSAGE "Mantenimiento de la Base de Datos";
         TOOLTIP "Mantenimiento de la Base de Datos"
      DEFINE BUTTON RESOURCE "Salir" ADJUST OF oApl:oWnd:oBar NOBORDER;
         TOOLTIP "Cerrar la aplicación";
         ACTION Salir()
ACTIVATE WINDOW oApl:oWnd MAXIMIZED             ;
   ON INIT (If( oApl:lSalir, oApl:oWnd:End(), ));
   VALID If( oApl:lSalir, .t., Salir() )
//FreeLibrary(hBorland )
//CLOSE CONNECT oApl:oMySql
RETURN NIL

//------------------------------------//
FUNCTION Salir()
If MsgYesNo( "Deseas salir del programa","Abandonar el sistema" )
   If oApl:oLoc # NIL
      oApl:oLoc:End()
   EndIf
   oApl:lSalir := .t.
   oApl:oMySql:End()
   oApl:oWnd:End()
EndIf
RETURN oApl:lSalir

//------------------------------------//
CLASS THis

   DATA aInvme AS ARRAY INIT { 0,0 }
   DATA aOptic, aTit
   DATA aDoctor  INIT {}
   DATA cEmpresa INIT "Centro Optico de la Costa S.A."
   DATA dFec     INIT DATE()
   DATA lSalir   INIT .F.
   DATA Tipo     INIT "U"
   DATA cCiu, cPer, cRuta1, cRuta2, cLocal, nUS, nTFor
   DATA cImpres, cPuerto, nTHoja, nLF, nItems
   DATA cIco, cIP, cUser, cBaseD, nPort, cSocket
   DATA lEnLinea, lFam, lOffice, nEmpresa, nSaldo, nX, nY
   DATA nClrBackHead, nClrForeHead, nClrBack, nClrFore
   DATA nClrBackFocus, nClrForeFocus, nClrNBack, nClrNFore, nGotFocus, nLostFocus
   DATA oMysql, oDb, oWnd, oLoc, oBD
   DATA oEmp, oHab, oHis, oAna, oCtl, oAgv
   DATA oExa, oQue, oRet, oOft, oDgn, oMot
 //DATA oLen, oCit, oArs, oPcp, oDia, oEsp, oCon, oSrv, oTra, oCmb

   METHOD NEW() Constructor
   METHOD Conectar( cPassw,oGet )
   METHOD Abrir( cTabla,cOrderBy,lBlank,lTemp,nLimit,oGet )
   METHOD FondoWnd( oGet )
   METHOD UtilDB()
ENDCLASS

//------------------------------------//
METHOD New() CLASS THis
   LOCAL oIni, cFecha, aC := ARRAY(30), nP := 0
   LOCAL oDlg, oGet[10], cPassw := SPACE(16)
INI oIni FILE ".\His.ini"
   GET ::cIP     SECTION "MySQL"     ENTRY "ServerIP" OF oIni;
       DEFAULT "LocalHost"
   GET ::cUser   SECTION "MySQL"     ENTRY "Usuario"  OF oIni;
       DEFAULT "root"
   GET ::cBaseD  SECTION "MySQL"     ENTRY "DataBase" OF oIni;
       DEFAULT "mysql"
   GET ::nPort   SECTION "MySQL"     ENTRY "nPort"    OF oIni;
       DEFAULT 3306
   GET ::cSocket SECTION "MySQL"     ENTRY "cSocket"  OF oIni;
       DEFAULT "/tmp/mysql.sock"
   GET ::cRuta1  SECTION "Tablas"    ENTRY "Ruta1"    OF oIni;
       DEFAULT "\ProyecFW\Bitmap\"
   GET ::cRuta2  SECTION "Tablas"    ENTRY "Ruta2"    OF oIni;
       DEFAULT "\ProyecFW\Datos\"
   GET ::nUS     SECTION "Tablas"    ENTRY "Dolar"    OF oIni;
       DEFAULT 2500
   GET ::cLocal  SECTION "Tablas"    ENTRY "Localiz"  OF oIni;
       DEFAULT "COC"
   GET ::nX      SECTION "Logo"      ENTRY "nX2"      OF oIni;
       DEFAULT 70
   GET ::nY      SECTION "Logo"      ENTRY "nY2"      OF oIni;
       DEFAULT 24
   GET ::cImpres SECTION "Impresora" ENTRY "Modelo"   OF oIni;
       DEFAULT "EPSON"
   GET ::cPuerto SECTION "Impresora" ENTRY "Puerto"   OF oIni;
       DEFAULT "LPT1"
   GET ::nTHoja  SECTION "Impresora" ENTRY "THoja"    OF oIni;
       DEFAULT 66
   GET ::nLF     SECTION "Impresora" ENTRY "LFactura" OF oIni;
       DEFAULT 12
   GET ::nItems  SECTION "Impresora" ENTRY "ItemsFac" OF oIni;
       DEFAULT 11
   GET ::nTFor   SECTION "Impresora" ENTRY "Formato"  OF oIni;
       DEFAULT 1
   GET cFecha    SECTION "BrowSetu"  ENTRY "Colors"   OF oIni;
       DEFAULT "252,231,165,120,25,25,255,255,235,0,0,0,225,192,192,0,0,0,128,178,182,100,0,0,255,255,255,0,0,0"
//   SET SECTION "Impresora" ENTRY "Modelo" TO oApl:cImpres OF oIni
ENDINI
::nX := ROUND( ::nX/10,2 )
::nY := ROUND( ::nY/10,2 )
AFILL( aC,0 )
WHILE !EMPTY(cFecha)
   aC[++nP] := VAL( Saca(@cFecha,",") )
ENDDO
 ::cIco          := STRTRAN( ::cRuta1,"map","maps" )
 ::nClrBackHead  := nRGB( aC[01],aC[02],aC[03] ) //Fondo Encabezado
 ::nClrForeHead  := nRGB( aC[04],aC[05],aC[06] ) //Texto Encabezado
 ::nClrBack      := nRGB( aC[07],aC[08],aC[09] ) //Fondo Browse
 ::nClrFore      := nRGB( aC[10],aC[11],aC[12] ) //Texto Browse
 ::nClrBackFocus := nRGB( aC[13],aC[14],aC[15] ) //Linea Activa Browse
 ::nClrForeFocus := nRGB( aC[16],aC[17],aC[18] ) //Texto Activa Browse
 ::nClrNBack     := nRGB( aC[19],aC[20],aC[21] ) //Fondo Celda con Foco
 ::nClrNFore     := nRGB( aC[22],aC[23],aC[24] ) //Texto Celda con Foco
 ::nGotFocus     := nRGB( aC[25],aC[26],aC[27] ) //Fondo Edicion
 ::nLostFocus    := nRGB( aC[28],aC[29],aC[30] ) //Texto Edicion
cFecha  := "CONECTANDO ...."
 ::cIP   := PADR( ::cIP   ,16 )
 ::cUser := PADR( ::cUser ,16 )
 ::cBaseD:= PADR( ::cBaseD,16 )
aC := { 1,2 }
If !EMPTY( ::cUser )
   AADD( aC,3 )
EndIf
DEFINE DIALOG oDlg FROM 1, 2 TO 15, 40 TITLE "Conexion TC/IP remota a " + oApl:cIP

   @ 02,  0 SAY "Server IP:"         OF oDlg RIGHT PIXEL SIZE  50,10
   @ 02, 52 GET oGet[1] VAR ::cIP    OF oDlg       PIXEL SIZE  46,10
   @ 16,  0 SAY "Base Datos:"        OF oDlg RIGHT PIXEL SIZE  50,10
   @ 16, 52 GET oGet[2] VAR ::cBaseD OF oDlg       PIXEL SIZE  46,10
   @ 30,  0 SAY "Usuario:"           OF oDlg RIGHT PIXEL SIZE  50,10
   @ 30, 52 GET oGet[3] VAR ::cUser  OF oDlg       PIXEL SIZE  46,10
   @ 44,  0 SAY "Clave:"             OF oDlg RIGHT PIXEL SIZE  50,10
   @ 44, 52 GET oGet[4] VAR cPassw   OF oDlg       PIXEL SIZE  46,10 PASSWORD
   @ 58,  0 SAY oGet[5] VAR cFecha   OF oDlg RIGHT PIXEL SIZE  50,10
   @ 58, 52 METER oGet[6] VAR ::aInvme[1] TOTAL 100 SIZE 46,10 OF oDlg PIXEL
   @ 58,104 SAY oGet[7]   VAR ::aInvme[2] OF oDlg  PIXEL SIZE  30,10
   @ 72, 52 SAY oGet[8] VAR "     "  OF oDlg       PIXEL SIZE  90,10

   @ 88, 50 BUTTON oGet[09] PROMPT "&Ok"     OF oDlg SIZE 44,12 ACTION ;
      ( oGet[9]:Disable(), ::Conectar( cPassw,oGet ), oDlg:End() ) PIXEL
   @ 88,100 BUTTON oGet[10] PROMPT "&Cancel" OF oDlg SIZE 44,12 CANCEL ;
      ACTION ( ::lSalir := .t., oDlg:End() ) PIXEL
ACTIVATE DIALOG oDlg CENTERED ;
   ON INIT AEVAL( aC,{|xV| oDlg:PostMsg( WM_KEYDOWN, 13, 0 ) } )
If !::lSalir
   cFecha := If( RIGHT( AmPm(TIME()),2 ) == "am", "BUENOS DIAS",;
                 "BUENAS TARDES" ) + "   >> HOY ES <<"  + CRLF +;
        NtChr( DATE(),"5" ) + " " + NtChr( DATE(),"2" ) + CRLF +;
              "Y SON LAS " + AmPm(TIME())
   If !MsgYesNo( cFecha,::cUser )
      ::lSalir := .t.
      RETURN NIL
   EndIf
   If oApl:dFec >= CTOD("31.12.2016") + ::oEmp:DIAS
      MsgStop( "ESTO ERA UN PROGRAMA DE DEMOSTRACION" + CRLF +;
               "POR FAVOR CONTACTE A SU PROPIETARIO " + CRLF +;
               "PARA OBTENER LA LICENCIA............" )
      ::lSalir := .t.
   EndIf
   ::lOffice := FILE( "OPENOFICE.BAT" )
EndIf
RETURN NIL

//--------Conectarse con MySQL--------//
METHOD Conectar( cPassw,oGet ) CLASS THis
   LOCAL nSec := Seconds()
 INIT CONNECT  ::oMySql         ;
      HOST     ALLTRIM(::cIP)   ;
      USER     ALLTRIM(::cUser) ;
      PASSWORD ALLTRIM(cPassw)  ;
      PORT     ::nPort          ;
      SOCKET   ALLTRIM(::cSocket)
 If ::oMySql:lConnected
    USE DATABASE ::oDb NAME (ALLTRIM(::cBaseD)) OF ::oMySql
    If ::oDb:Used()
       ::FondoWnd( oGet )
       oGet[5]:setText( "Conectado " + LTRIM(STR(SECONDS() - nSec)) +" S" )
       ::oEmp := ::Abrir( "cadempre",,,,,oGet )
       ::oEmp:GoTop():Read()
       cPassw := If( oApl:cLocal == "LOC", "COC", oApl:cLocal )
       ::aOptic := {}
       While !::oEmp:EOF()
          ::oEmp:xLoad()
          AADD( ::aOptic, { ::oEmp:LOCALIZ, STR(::oEmp:OPTICA,2) } )
          ::oEmp:Skip(1):Read()
       EndDo
       ::oEmp:Seek( {"localiz",cPassw} )
       nEmpresa( .f. )
       ::oHab := ::Abrir( "ciudades","codigo",,,100,oGet )
     //::oCib := ::Abrir( "ciudad_barrios","codigo",,,100,oGet )
       ::oHis := ::Abrir( "historia","nroiden",,,50,oGet )
       ::oAna := ::Abrir( "historic","nro_histor"         ,,,50,oGet )
       ::oCtl := ::Abrir( "hiscntrl","nro_histor, control",,,50,oGet )
       ::oAgv := ::Abrir( "hisagvis","cntrl_id",,,50,oGet )
       ::oExa := ::Abrir( "hisexame","cntrl_id",,,50,oGet )
       ::oQue := ::Abrir( "hisquera","cntrl_id",,,30,oGet )
       ::oRet := ::Abrir( "hisretin","cntrl_id",,,30,oGet )
       ::oOft := ::Abrir( "hisoftal","cntrl_id",,,50,oGet )
       ::oDgn := ::Abrir( "hisdiagn","cntrl_id",,,50 )
       ::oMot := ::Abrir( "hisvaria","tipo",,,50 )
    // ::oLen := ::Abrir( "hislente","codigo",,,50 )
    // ::oCit := ::Abrir( "hiscitas","fec_cita, turno",,,50 )
    // ::oArs := ::Abrir( "ridars"  ,"codigo",,,50 )
    // ::oPcp := ::Abrir( "ridclpro","codigo",,,50 )
    // ::oDia := ::Abrir( "riddiagn","codigo",,,50 )
    // ::oEsp := ::Abrir( "ridespec","codigo",,,50 )
    // ::oCon := ::Abrir( "ridconsu","codadmin, fecha",,,100,oGet )
    // ::oSrv := ::Abrir( "ridservi","codadmin, fecha",,,100,oGet )
    // ::oTra := ::Abrir( "ridocupa","codigo",,,100,oGet )
    // ::oCmb := ::Abrir( "cadcombo","tipo",,,100,oGet )
       ::oMot:Seek( {"tipo","05"} )
       While !::oMot:Eof()
          AADD( oApl:aDoctor, TRIM(::oMot:DESCRIPCIO) )
          ::oMot:Skip(1):Read()
          ::oMot:xLoad()
       EndDo
       If oApl:cLocal == "COC"
          INIT CONNECT  ::oLoc          ;
               HOST     '192.168.80.50' ;
               USER     'Martin'        ;
               PASSWORD 'tolozano'      ;
               PORT     ::nPort         ;
               SOCKET   ALLTRIM(::cSocket)
          If ::oLoc:lConnected
             USE DATABASE ::oBD NAME "ventasinv" OF ::oLoc
          EndIf
       EndIf
    Else
       ::lSalir := .t.
    EndIf
 Else
    ::lSalir := .t.
 EndIf
If ::lSalir
   MsgInfo( "No hay conexion", "Señor(a) : "+ALLTRIM(::cUser) )
EndIf
//::oMySql:Ping()
RETURN NIL

//------------------------------------//
METHOD Abrir( cTabla,cOrderBy,lBlank,lTemp,nLimit,oGet ) CLASS THis
   LOCAL oTb, lSi := .f., nSec, nCon := 0
   DEFAULT cOrderBy := 1, lBlank := .f. , lTemp := .f.
While !lSi .AND. nCon <= 3
   If !(lSi := ::oDb:ExistTable( cTabla ))
      Diccionario( cTabla )
   EndIf
   nCon++
EndDo
If ::oDb:ExistTable( cTabla )
//	New( oDbCon, cName, cWhere, cHaving, cOrderBy, nLimit )
   nSec:= Seconds()
   oTb := TMyTable( (cTabla) ):New( ::oDb, (cTabla),"",,cOrderBy,nLimit )
   If !(lSi := oTb:Open())
      If ::oMySql:GetErrNo() == 1030
         If ::oDb:Repair( cTabla )
            MsgInfo( "la Tabla "+cTabla,"Se Reparo" )
            lSi := oTb:Open()
         Else
            MsgStop( "la Tabla "+cTabla,"No se Pudo Reparar" )
         EndIf
      EndIf
   EndIf
   If lSi
      nCon := oTb:RecCount()
      If nCon == 0 .AND. !lTemp
         MsgInfo( "está sin registros",cTabla )
      ElseIf nCon > 0 .AND. lTemp
         oTb:dbEval( {|o| o:Delete( .f.,1 ) } )
      EndIf
      If lBlank
         oTb:xBlank()
      EndIf
   EndIf
   If oGet # NIL
      nSec := SECONDS() - nSec
      oGet[8]:setText( cTabla +" Demore " + STR(nSec) + " Seg" )
      ::aInvme[1] += 10   ; oGet[6]:Refresh() ; SysRefresh()
      ::aInvme[2] += nSec ; oGet[7]:Refresh()
   EndIf
Else
   MsgInfo( "No Existe !!!!",cTabla )
EndIf
RETURN oTb

//------------------------------------//
METHOD FondoWnd( oGet ) CLASS THis
   LOCAL aEstru, aNombre := {}, cQry, hRes, nFon, nLen
If oGet == NIL
   aEstru := DIRECTORY( oApl:cRuta1+"*.BMP" )
   AEVAL( aEstru , {|aFile| AADD( aNombre, oApl:cRuta1+ aFile[1] ) } )
   If LEN( aNombre ) == 0
      AADD( aNombre, "STYLE TILED" )
   EndIf
   nLen := LEN( aNombre )
   nFon := nRandom( nLen ) + 1
   cQry := aNombre[ If( nFon > nLen, nLen, nFon ) ]
ElseIf FILE( "CAMBIOTL.TXT" )
   aEstru := { { "CEL", "C", 140, 0 } }
   aNombre:= { "\" + CURDIR() + "\","",.f.,0 }
   cQry   := aNombre[1] + "CAMBIOTL.TXT"
   dbCREATE( "CAMBIOTL",aEstru )
   If !AbreDbf( "Tem","CAMBIOTL",,aNombre[1],.f. )
      BorraFile( "CAMBIOTL",{"DBF"},aNombre[1] )
      RETURN NIL
   EndIf
   APPEND FROM &(cQry) SDF
   Tem->(dbGoTop())
   aNombre[3] := If( SUBSTR(Tem->CEL,3,10) <= DTOC(DATE()), .t., .f. )
   While !Tem->(EOF()) .AND. aNombre[3]
      If LEFT( Tem->CEL,1 ) == "#"
         aNombre[2] := ALLTRIM( SUBSTR(Tem->CEL,2) )
         cQry := ""
      Else
         cQry += ALLTRIM( Tem->CEL ) + " "
      EndIf
      If AT( ";",Tem->CEL ) > 0
         oGet[5]:setText( aNombre[2] )
         cQry := LEFT( cQry,LEN(cQry)-2 )
       //nFon := SECONDS()
         If !MSQuery( ::oMySql:hConnect,cQry )
            ::oMySql:oError:Display( .f. )
         Else
            hRes :=  MSStoreResult( ::oMySql:hConnect )
            nLen := MSAffectedRows( ::oMySql:hConnect )
            MSFreeResult( hRes )
          //nFon := SECONDS() - nFon
          //oGet[8]:setText( "Demore " + STR(nFon) + " Seg" )
            oGet[8]:setText( STR(nLen)+" Registros Cambiados" )
            aNombre[4] ++
         EndIf
         cQry := ""
      EndIf
      Tem->(dbSkip())
   EndDo
   Tem->(dbCloseArea())
   If aNombre[3]
      BorraFile( "CAMBIOTL",{"DBF","TXT"},aNombre[1] )
      MsgInfo( STR(aNombre[4])+" Cambios","HECHO" )
   Else
      BorraFile( "CAMBIOTL",{"DBF"},aNombre[1] )
   EndIf
EndIf
RETURN cQry

//------------------------------------//
METHOD UtilDB() CLASS THis
   LOCAL bOK, oDlg, oGet := ARRAY(4), nOpc := 3
   LOCAL cTabla := ::oDb:aTables[1]
bOK := { {|cTB| ::oDb:Check( cTB ) }   ,;
         {|cTB| ::oDb:Optimize( cTB ) },;
         {|cTB| ::oDb:Repair( cTB ) }  , "" }
DEFINE DIALOG oDlg FROM 1, 2 TO 08, 40 TITLE "Database Utilidades"
   @ 02,  0 SAY "Opción"     OF oDlg RIGHT PIXEL SIZE 50,10
   @ 02, 52 COMBOBOX oGet[1] VAR nOpc   ITEMS {"Chequear","Optimizar","Reparar"};
      SIZE 68,99 OF oDlg PIXEL
   @ 16,  0 SAY "Tabla"      OF oDlg RIGHT PIXEL SIZE 50,10
   @ 16, 52 COMBOBOX oGet[2] VAR cTabla ITEMS ::oDb:aTables;
      SIZE 68,99 OF oDlg PIXEL
   @ 32, 50 BUTTON oGet[3] PROMPT "Ok"     OF oDlg SIZE 40,12 ACTION;
      ( bOK[4] := {"Chequear","Optimizar","Reparar"}[nOpc],;
        If( EVAL( bOK[nOpc],cTabla )            ,;
            MsgInfo( bOK[4]+" "+cTabla,"HECHO" ),;
            MsgInfo( "Al "+ bOK[4],"ERROR" ) ) ,;
            oGet[3]:oJump := oGet[2], oGet[2]:SetFocus() ) PIXEL
   @ 32,100 BUTTON oGet[4] PROMPT "Cancel" OF oDlg SIZE 40,12 CANCEL;
      ACTION oDlg:End() PIXEL
ACTIVATE DIALOG oDlg CENTERED
RETURN NIL

//------------------------------------//
PROCEDURE Backup( cBaseD )
   LOCAL aMsg, cFile := ALLTRIM(cBaseD) + ".sql"
 aMsg := { "Voy a Sacar una Copia de Seguridad" ,;
           "Por favor digite la >>> Contraseña <<<<" }
If !MsgYesNo( aMsg[2],aMsg[1] )
   RETURN
EndIf
//WAITRUN('Copia.bat ' + cUnd + ' ' + cFile )
//Vuelco todos los datos de cache a disco, cierro y bloqueo todas las tablas
MSQuery( oApl:oMySql:hConnect,"FLUSH TABLES WITH READ LOCK" )
//WAITRUN( 'mysqldump -u root -p ' + cBaseD + ' > ' + cFile )
WAITRUN('BACKUP.bat ' + cBaseD + ' ' + cFile + ' ' + oApl:cRuta2 )
//Desbloqueo las tablas
MSQuery( oApl:oMySql:hConnect,"UNLOCK TABLES" )
MsgInfo( "OK!" )
//Para Restaurar
//mysql -u root -p base_de_datos < backup.sql
RETURN

//------------------------------------//
FUNCTION Login( cTit )
   LOCAL oDlg, oGet := ARRAY(4), aLog := { oApl:cUser,SPACE(16),0,.f. }
   DEFAULT cTit := ""
DEFINE DIALOG oDlg FROM 1, 2 TO 08, 40 TITLE cTit
   @ 02,  0 SAY "Usuario:"          OF oDlg RIGHT PIXEL SIZE 50,10
   @ 02, 52 GET oGet[1] VAR aLog[1] OF oDlg       PIXEL SIZE 46,10
   @ 16,  0 SAY "Clave:"            OF oDlg RIGHT PIXEL SIZE 50,10
   @ 16, 52 GET oGet[2] VAR aLog[2] OF oDlg       PIXEL SIZE 46,10 PASSWORD

   @ 32, 50 BUTTON oGet[3] PROMPT "&Ok"     OF oDlg SIZE 44,12 ACTION;
      ( aLog[3]++, aLog[4] := Leer_Clave( aLog ),;
       If( aLog[3] > 3 .OR. aLog[4], oDlg:End() ,;
         ( MsgInfo( "Clave Erronea","Error" )   ,;
           oGet[3]:oJump := oGet[1], oGet[1]:SetFocus())) ) PIXEL
   @ 32,100 BUTTON oGet[4] PROMPT "&Cancel" OF oDlg SIZE 44,12 CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN aLog[4]

//------------------------------------//
FUNCTION Leer_Clave( aUsu )
   LOCAL hRes, cQry //:= MyPasswd( oApl:oMySql:hConnect )
cQry := "SELECT Host FROM mysql.user WHERE User = " + xValToChar( aUsu[1] ) +;
        " AND Password = OLD_PASSWORD(" + xValToChar( aUsu[2] ) +")"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
//MSChangeuser( oApl:oMySql:hConnect, <usuario>, <password>[, basededatos] )
RETURN ( MSNumRows( hRes ) != 0 )

//------------------------------------//
FUNCTION Encriptar( cNomH,lEncrita )
   LOCAL nC, nX, nLen := LEN( ALLTRIM( cNomH ) )
DEFAULT lEncrita := .t.
FOR nX  := 1 TO nLen
   If lEncrita
      nC := ASC( SUBSTR( cNomH,nX,1 ) ) + 4 + nX * 25
   Else
      nC := ASC( SUBSTR( cNomH,nX,1 ) ) - 4 - nX * 25
   EndIf
   cNomH := STUFF( cNomH,nX,1,CHR( nC ) )
Next
RETURN cNomH

//----------------------------------------------//
FUNCTION MsgDate( dDate, cPrompt, oGet )
   LOCAL oDlg, oFont, oCursor, dSelect, dWork
   LOCAL nRow, nCol, nMonth, nYear, cCYear, cFechaLarga
   LOCAL aMes := { "Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio",;
                   "Agosto","Septiembre","Octubre","Noviembre","Diciembre"}
   DEFAULT dDate := Date(), cPrompt := "Selecione una Fecha"
dDate       := If( EMPTY(dDate), Date(), dDate )
cFechaLarga := dDateToString( dDate,aMes )
cCYear      := str(year(dDate), 4)
nYear       := Year( dDate )
nMonth      := Month( dDate )
dSelect     := dDate
dWork       := TToD( "01/" + padl( nMonth, 2 ) + "/" + ;
                      right( cCYear, 2), "DD/MM/YY" )
while DoW( dWork ) > 1
   dWork --
enddo

DEFINE FONT oFont NAME "Ms Sans Serif" SIZE 0, -14
DEFINE DIALOG oDlg SIZE 250, 235 TITLE cPrompt FONT oFont // -> 6 Semanas

   @ 0.2, .75 COMBOBOX  nMonth  ITEMS  aMes SIZE 50,150  OF  oDlg ;
              ON CHANGE MoveCalendar( oDlg,1,nMonth,aMes )
   @ 3.5, 63 BTNBMP PROMPT "-" SIZE 11,11 ACTION ( MoveCalendar(oDlg,3,,aMes ))
   @ 3.5,105 BTNBMP PROMPT "+" SIZE 11,11 ACTION ( MoveCalendar(oDlg,4,,aMes ))

   @ 0.2, 9.3 GET  nYear  SIZE 31, 12 OF oDlg
   ATail( oDlg:aControls ):Cargo = "YEAR"
     // Atail -> Devuelve el último elemento de una Matriz
   @ 1.1, (35  - LEN( cFechaLarga )) / 4.8  SAY cFechaLarga COLOR CLR_HBLUE
   ATail( oDlg:aControls ):Cargo = "DATE"

   @ 2, 1 SAY "Dom   Lun   Mar   Mie   Jue    Vie   Sab" COLOR CLR_HRED

   FOR nRow = 2 TO 7
      FOR nCol = 1 TO 7
         @ (nRow * 10) + 20, ( nCol * 16 ) - 6 BTNBMP ;
             PROMPT STR( DAY( dWork ), 2 ) SIZE 12, 12 NOBORDER ;
             ACTION ( oDlg:Cargo := ::Cargo, oDlg:End( IDOK ) )

         ATail( oDlg:aControls ):Cargo    = dWork
         ATail( oDlg:aControls ):nClrText = If( dWork == Date(), CLR_HRED,;
                If( dWork == dDate, CLR_HBLUE, If( Month( dWork ) == nMonth,;
                CLR_BLACK, CLR_GRAY ) ) )
         If ATail( oDlg:aControls ):Cargo == dDate
            ATail( oDlg:aControls ):lPressed = .t.
            ATail( oDlg:aControls ):cToolTip = "Seleccionado"
         ElseIf ATail( oDlg:aControls ):Cargo == Date()
            ATail( oDlg:aControls ):cToolTip = "Hoy"
         Else
            ATail( oDlg:aControls ):cToolTip = DToC(ATail( oDlg:aControls ):Cargo)
         EndIf

         dWork++
      NEXT
   NEXT
   oDlg:Cargo := dDate

ACTIVATE DIALOG oDlg CENTERED

dSelect := oDlg:Cargo
If oGet != NIL
   oGet:VarPut( If( oDlg:nResult == IDOK, dSelect, dDate ) )
   oGet:Refresh()
EndIf

RETURN If( oDlg:nResult == IDOK, dSelect, dDate )

//----------------------------------------------//
STATIC FUNCTION MoveCalendar( oDlg, nMode, nVar, aMes )
   LOCAL cFechaLarga, dWork, nDay, nMonth, nYear, n
   LOCAL dSelect      := oDlg:Cargo
   LOCAL nFirstButton := 0, nLastButton := 0
   LOCAL nDays  := 0
   LOCAL nDate  := 0
   LOCAL nSkip  := 0
   LOCAL nPDate := 0
   LOCAL nPYear := 0
FOR n := 1 TO Len( oDlg:aControls )
   If oDlg:aControls[ n ]:ClassName() == "TBTNBMP"
      nFirstButton := If( nFirstButton == 0, If(nSkip<2, 0, n), nFirstButton )
      nLastButton  := n
      nSkip++
      oDlg:aControls[ n ]:lPressed := .f.
   EndIf
   If ValType( oDlg:aControls[ n ]:Cargo ) == "C"
      If oDlg:aControls[ n ]:Cargo == "DATE"
         nPDate    := n
      EndIf
      If oDlg:aControls[ n ]:Cargo == "YEAR"
         nPYear    := n
      EndIf
   EndIf
NEXT n

nDay   := Day( dSelect )
nMonth := Month( dSelect )
nYear  := Year( dSelect )

do case
   case nMode == 1
      nMonth := nVar
   case nMode == 3
      nYear --
   case nMode == 4
      nYear ++
endcase
If LEFT(NtChr( dSelect,"4" ),2) == STR(nDay,2)
   nDay := DAY(CTOD(NtChr( CTOD("01."+STRZERO(nMonth,2)+STR(nYear)),"4" )))
EndIf
dSelect     := TToD( padl( nDay, 2) + "/" + ;
                     padl( nMonth, 2 ) + "/" + ;
                     right(padl( nYear, 4 ), 2), "DD/MM/YY" )
cFechaLarga := dDateToString( dSelect,aMes )
oDlg:aControls[ nPDate ]:cMsg := cFechaLarga
oDlg:aControls[ nPYear ]:VarPut( nYear)

dWork    := TToD( "01/" + padl( nMonth, 2 ) + "/" + right(padl( nYear, 4 ), 2), "DD/MM/YY" )
while DoW( dWork ) > 1
   dWork --
enddo

FOR n := nFirstButton TO nLastButton
   oDlg:aControls[ n ]:SetText( Str( Day( dWork ), 2 ) )
   oDlg:aControls[ n ]:Cargo   = dWork
   oDlg:aControls[ n ]:nClrText = If( dWork == Date(), CLR_HRED,;
        If( dWork == dSelect, CLR_HBLUE, If( Month( dWork ) == nMonth,;
            CLR_BLACK, CLR_GRAY ) ) )
   oDlg:aControls[ n ]:cToolTip = DToC(dWork)
   If dWork == dSelect
      oDlg:aControls[ n ]:lPressed = .t.
      oDlg:aControls[ n ]:cToolTip = "Seleccionado"
   EndIf
   dWork++
NEXT n

FOR n := 1 TO Len( oDlg:aControls )
   oDlg:aControls[ n ]:Refresh()
NEXT n
oDlg:Cargo   := dSelect
return nil

//----------------------------------------------//
STATIC FUNCTION dDateToString( dDate,aMes )
   Local aDia := { "Domingo ","Lunes ","Martes ","Miercoles ","Jueves ",;
                   "Viernes ","Sabado " }
RETURN aDia[Dow( dDate )] + aMes[Month( dDate )] + Str( Day( dDate ),3 ) +;
       ", " + Str( Year( dDate), 4)

//----------------------------------------------//
STATIC FUNCTION TToD(cDate, cFormat)
  LOCAL cDia, cMes, cYear, cLYear
  LOCAL RetDate
  LOCAL cClipFormat := UPPER(SET(4))
  LOCAL nEPOCH      := SET(5)

IF VALTYPE(cFormat) != "C"
   cFormat  := "MM/DD/YY"
ENDIF
IF EMPTY(cDate)
   RetDate := CTOD("")
ELSE
   IF ("YYYY" $ cFormat)
      cLYear :=  PADR( VAL( SUBSTR(cDate, AT("YYYY", cFormat), 4 )), 4, "0")
      cYear  :=  PADL( VAL( RIGHT(cLYear, 2)), 2, "0")
   ELSEIF ("YY" $ cFormat)
      cYear  :=  PADL( VAL( SUBSTR(cDate, AT("YY", cFormat), 2 )), 2, "0")
      IF VAL("19" + cYear) > nEPOCH
         cLYear := "19" + cYear
      ELSE
         cLYear := "20" + cYear
      ENDIF
   ENDIF
   IF ("MM" $ cFormat)
      cMes  :=  PADL( ALLTRIM( SUBSTR(cDate, AT("MM", cFormat), 2 )), 2, "0")
   ENDIF
   IF ("DD" $ cFormat)
      cDia  :=  PADL( ALLTRIM( SUBSTR(cDate, AT("DD", cFormat), 2 )), 2, "0")
   ENDIF

   IF ("YYYY" $ cClipFormat)
      cClipFormat := LEFT(cClipFormat, AT("YYYY", cClipFormat) - 1 ) + cLYear + SUBSTR(cClipFormat, AT("YYYY", cClipFormat) + 4 )
   ELSEIF ("YY" $ cClipFormat)
       cClipFormat := LEFT(cClipFormat, AT("YY", cClipFormat) - 1 ) + cYear + SUBSTR(cClipFormat, AT("YY", cClipFormat) + 2 )
   ENDIF
   IF ("MM" $ cClipFormat)
      cClipFormat := LEFT(cClipFormat, AT("MM", cClipFormat) - 1 ) + cMes + SUBSTR(cClipFormat, AT("MM", cClipFormat) + 2 )
   ENDIF
   IF ("DD" $ cClipFormat)
      cClipFormat := LEFT(cClipFormat, AT("DD", cClipFormat) - 1 ) + cDia + SUBSTR(cClipFormat, AT("DD", cClipFormat) + 2 )
   ENDIF
   RetDate := CTOD(cClipFormat)
ENDIF
RETURN (RetDate)