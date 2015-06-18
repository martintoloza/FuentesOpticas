Validación de Contactos Multiples José Luis Ysturiz

  Esta funcion permite a través de un solo GET y un COMBOBOX, agrupar cualquier cantidad de datos, su uso original fue para el siguiente ejemplo:

Supongamos que estas llenado un formulario y que la persona tiene: Telefono de la Casa, Telefono Mobil, Email, Pagina WEB, Fax, Telefono de la Oficina, etc. y cualquier otra cantidad de formas de UBICARLO o comunicarte con dicha persona, no hay necesidad de realizar un oGET para cada Telefono.

* aLlamar  = Arreglo Mensajes para el oCmb
* cTele     = Variable auxiliar
* cLlamar  = Variable contenedora del oCmb
* aTele     = Arreglo con Valores de los Campos de la DBF
* nPosi     = Posicion de cLlamar dentro del Arreglo aLlamar

NOTA: para una correcta funcionalidad ambos arreglos deben tener la misma cantidad de elementos,
aLlamar(Mensajes) y aTele(Valores de los Campos de la DBF)

FUNCION xxxxxxxxxx() // NOMBRE DE TU FUNCION
  local oDlg, oCmb, oGet, cAlias

  // ARREGLO CON LOS MENSAJES QUE SE DESPLEGARAN EN EL oCmb (ComboBox)
  local aLlamar := {"Teléfono1", "Teléfono2", "Teléfono3", "Teléfono4", "Teléfono5", "Fax", "Email", "HomePage"}

  // VARIABLE AUXILIAR PARA EL CAMPO DE LA BASE DE DATO, EL TAMAÑO SERA EL DE TU CAMPO,
  // RECOMENDABLE QUE TODOS LOS CAMPOS A USAR SEAN DEL MISMO TAMAÑO
  local cTele := SPACE(30)

  // VARIABLE QUE CONTENDRA LA OPCION SELECCIONADA EN EL oCmb (ComboBox)
  local cLlamar := "Teléfono1"

  // ARREGLO DONDE SE AGREGARAN LOS VALORES DE LOS CAMPOS DE LA BASE DE DATOS,
  // CADA UNO CONCUERDA CON EL ARREGLO aLlamar[]
  Public aTele := {}

  // ABRIR BASE DE DATOS O ACTIVAR BASE DE DATOS CON LOS CAMPOS DE DATOS A USAR
  USE DATOS NEW
  cAlias := alias()

  // CAMPOS DE LA BASE
  aTele := {(cAlias)->Campo1, (cAlias)->Campo2, (cAlias)->Campo3, (cAlias)->Campo4, (cAlias)->Campo5}

  DEFINE DIALOG oDlg FROM 1.0, 1.0 TO 30.0, 80.0;
            TITLE " Funcion Varios Datos donde Ubicarlo..." OF oWnd

  @ 4.6, 15.0 GET oGET VAR cTeleAG;
            VALID (vcontacto(oGET, cTele, cLlamar, aTele, ASCAN(aLlamar, cLlamar)));
            SIZE 123,10 OF oDlg

  @ 4.1, 8.0 COMBOBOX oCmb VAR cLlamar PROMPTS aLlamar;
            ON CHANGE (vcontacto(oGET, , cLlamar, aTele, ASCAN(aLlamar, cLlamar)));
            SIZE 50,50 OF oDlg

  ACTIVATE DIALOG oDlg CENTER

RETURN NIL // FIN FUNCION xxxxxxxxxx

FUNCTION vcontacto(oGET, cTeleX, cLlamar, aTeleX, nPosi) // VALIDA CONTACTOS

  // EL PRIMER VALOR DE nPOSI ES NIL NO SE PORQUE, POR ESO ESTA EVALUACION
  IF nPosi = NIL .OR. nPosi < 1
      nPosi := 1
  ENDIF

  IIF(!EMPTY(cTeleX), aTeleX[nPosi] := cTeleX, )

  oGET:VarPut(aTeleX[nPosi])
  oGET:REFRESH()

RETURN .T. // FIN VALIDA CONTACTOS


