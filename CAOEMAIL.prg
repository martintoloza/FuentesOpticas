// Programa.: CAOEMAIL.PRG     >>> Martin A. Toloza Lozano <<<
// Notas....: Enviar E-Mail a los Clientes.
#include "FiveWin.ch"

MEMVAR oApl

FUNCTION Correos()
   LOCAL oMail := TEMail()
oMail:NEW()
oMail:EnviaCorreo()
RETURN NIL

//------------------------------------//
CLASS TEMail

 DATA sAsunto       INIT SPACE(100)
 DATA sTexto        INIT ""
 DATA sEMail        INIT SPACE(100)
 DATA aEMail, aFiles, aMsg, aOrigen

 METHOD NEW() Constructor
 METHOD EnviaCorreo()
 METHOD Adjuntar()
 METHOD Llenar()
 METHOD EnviaMail()

ENDCLASS

//------------------------------------//
METHOD NEW() CLASS TEMail

 ::aEMail  := {}
 ::aFiles  := {}
 ::aOrigen := { "centroptico@labocosta.com" }
 ::aMsg    := { ,"",.f.,.f. }
 // cMsgType, cConversationID, lReceipt, lFromUSer
 // lFromUSer = si verdadero entonces Abre el outlock, si falso no lo abre
 ::sEMail  := "martintoloza@labocosta.com" + SPACE(74)
/*
 ::sAsunto := "Texto del asunto"
 ::sTexto  := "Texto del cuerpo del correo"+CRLF+;
              "continuación del cuerpo del texto del correo"
*/
RETURN NIL

//------------------------------------//
METHOD EnviaCorreo() CLASS TEMail
   LOCAL oDlg, oGet := ARRAY(07), lOK := .f.
DEFINE DIALOG oDlg TITLE "Envio de Mails" FROM 0,0 TO 18,70
   @ 02, 00 SAY "PARA"         OF oDlg RIGHT PIXEL SIZE 44,10
   @ 02, 46 GET oGet[01] VAR ::sEMail  OF oDlg ;
      SIZE 160,10 PIXEL

   @ 30, 00 SAY "Asunto"       OF oDlg RIGHT PIXEL SIZE 44,10
   @ 30, 46 GET oGet[02] VAR ::sAsunto OF oDlg ;
      SIZE 160,10 PIXEL
   @ 44, 10 BUTTON oGet[03] PROMPT "Adjuntar" SIZE 40,12 OF oDlg ;
      ACTION ( ::Adjuntar() ) PIXEL

   @ 60, 00 SAY "Texto"        OF oDlg RIGHT PIXEL SIZE 34,10
   @ 60, 36 GET oGet[04] VAR ::sTexto OF oDlg MEMO ;
      SIZE 214,40 PIXEL HSCROLL

   @ 112, 80 BUTTON oGet[5] PROMPT "ENVIAR"   SIZE 40,12 OF oDlg ;
      ACTION ( ::EnviaMail(), oDlg:End() ) PIXEL
   @ 112,130 BUTTON oGet[6] PROMPT "MASIVO"   SIZE 40,12 OF oDlg ;
      ACTION ( oGet[5]:Disable(), oGet[6]:Disable(),;
               ::Llenar(), oDlg:End() ) PIXEL
   @ 112,180 BUTTON oGet[07] PROMPT "Cancelar" SIZE 40,12 OF oDlg CANCEL ;
      ACTION ( oDlg:End() ) PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN NIL

//------------------------------------//
METHOD Adjuntar() CLASS TEMail

   LOCAL cRut := AbrirFile( 1,"*" )
Msginfo( cRut )
 If LEN( cRut ) > 0
    AADD( ::aFiles,cRut )
 Else
    MsgStop( "No escogio ningun Archivo" )
 EndIf
RETURN NIL

//------------------------------------//
METHOD Llenar() CLASS TEMail
   LOCAL cQry, aRes, nL, hRes
cQry := "SELECT CONCAT(nombres, ' ', apellidos), email, codigo_nit "+;
        "FROM historia WHERE email LIKE '%@%'"+;
          " AND LEFT(reshabit,2) = '08'"      +;
          " AND exportar = 'E'"
//        " AND MONTH(fec_nacimi) = 9
//        " AND   DAY(fec_nacimi) = 20
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
::sEMail := ""
//MsgInfo( cQry,STR(nL) )
While nL > 0
   aRes := MyReadRow( hRes )
   //AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If AT( ".",aRes[2] ) > 0
      //AADD( ::aEMail,aRes[2] )
      ::aEMail := { aRes[2] }
      ::sTexto := "Sr(a) " + aRes[1] + CRLF + "No se pierda esta oportunidad"
      ::EnviaMail()
      Guardar( "UPDATE historia SET exportar = 'N' WHERE codigo_nit = " + aRes[3],"historia" )
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
RETURN NIL

//------------------------------------//
METHOD EnviaMail() CLASS TEMail

   LOCAL cEmail, cEmail2, nP, oMail
   LOCAL cTime := TIME()
   LOCAL dDate := DATE()

   cEmail := ALLTRIM( ::sEMail )
   If !EMPTY( cEmail )
      While .t.
         nP := AT(",",cEmail)
         If nP > 0
            cEmail2 := ALLTRIM(SUBSTR( cEmail,1,nP-1 ))
            cEmail  := SUBSTR( cEmail,nP+1 )
            AADD( ::aEMail,cEmail2 )
         Else
            AADD( ::aEMail,cEmail )
            EXIT
         EndIf
      Enddo
   EndIf
   If LEN( ::aEMail ) > 0
      oMail := TMail()
      oMail:New( ::sAsunto,::sTexto,::aMsg[1],::aMsg[2],dDate,cTime,::aMsg[3],::aMsg[4],;
                 ::aOrigen,::aEMail,::aFiles )
      oMail:Activate()
   Else
      MsgStop( "No hay un correo Valido" )
   EndIf
RETURN NIL