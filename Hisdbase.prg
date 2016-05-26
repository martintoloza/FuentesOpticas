// Programa.: HISDBASE.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Modulo para la creacion de el diccionario de datos

MEMVAR oApl

FUNCTION Diccionario( cTabla,xDbf,cTB )
   LOCAL aStruct, aIndice := {}, nI, oTb
   LOCAL cType, cLogica := " unsigned zerofill NOT NULL default '0'"
do Case
Case cTabla == "cadcombo"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "tipo"      , "C", 10, 00, },;
                { "desplegar" , "C", 30, 00, },;
                { "retornar"  , "C", 02, 00, } }
   aIndice := { { "TipoComb", { "tipo" } } }
Case cTabla == "cadempre"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "fec_hoy"   , "D", 08, 00, },;
                { "optica"    , "N", 02, 00, },;
                { "localiz"   , "C", 03, 00, },;
                { "titular"   , "C", 03, 00, },;
                { "nit"       , "C", 14, 00, },;
                { "nombre"    , "C", 43, 00, },;
                { "enlinea"   , "L", 01, 00, cLogica },;
                { "numfacu"   , "N", 10, 00, },;
                { "numfacd"   , "N", 10, 00, },;
                { "numfacz"   , "N", 10, 00, },;
                { "nro_histor", "N", 08, 00, },;
                { "piva"      , "N", 06, 02, },;
                { "val_admon" , "N", 10, 00, },;
                { "orden_dato", "N", 02, 00, },;
                { "rsv"       , "N", 02, 00, },;
                { "cartera"   , "D", 08, 00, },;
                { "codmontura", "N", 06, 00, },;
                { "numdevol"  , "N", 10, 00, },;
                { "consedev"  , "N", 10, 00, },;
                { "numrep"    , "N", 06, 00, },;
                { "numingreso", "N", 06, 00, },;
                { "numproveed", "N", 03, 00, },;
                { "direccion" , "C", 30, 00, },;
                { "telefonos" , "C", 30, 00, },;
                { "reshabit"  , "C", 05, 00, },;
                { "facturo"   , "C", 03, 00, },;
                { "precio"    , "C", 01, 00, },;
                { "dias"      , "N", 02, 00, },;
                { "principal" , "N", 02, 00, },;
                { "dividenomb", "N", 02, 00, },;
                { "lente"     , "C", 01, 00, },;
                { "sgsss"     , "C", 13, 00, },;
                { "observa"   , "C", 90, 00, } }
   aIndice := { { "Optica", { "Optica" } } }
Case cTabla == "cadlente"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 12, 00, },;
                { "tip"       , "N", 02, 00, },;
                { "esf"       , "C", 06, 00, },;
                { "cil"       , "C", 06, 00, },;
                { "adi"       , "C", 06, 00, },;
                { "cantidad"  , "N", 04, 00, },;
                { "valor"     , "N", 10, 00, } }
   aIndice := { { "Codigo", "codigo" } }
Case cTabla == "encuestc"
   aStruct := { { "optica"    , "N", 02, 00, },;
                { "control"   , "N", 10, 00, " auto_increment" },;
                { "periodo"   , "N", 04, 00, },;
                { "semestre"  , "N", 01, 00, },;
                { "PRIMARY KEY (optica, control)", "P",,,} }
   aIndice := { { "Periodo"   , { "optica", "periodo", "semestre" } } }
Case cTabla == "encuestd"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "optica"    , "N", 02, 00, },;
                { "control"   , "N", 10, 00, },;
                { "encuesta"  , "N", 10, 00, },;
                { "atencion_r", "N", 01, 00, },;
                { "atencion_t", "N", 01, 00, },;
                { "atencion_a", "N", 01, 00, },;
                { "atencion_o", "N", 01, 00, },;
                { "calidad_is", "N", 01, 00, },;
                { "prontitud" , "N", 01, 00, },;
                { "calidad_pr", "N", 01, 00, },;
                { "instalacio", "N", 01, 00, },;
                { "atencion_p", "N", 01, 00, },;
                { "servicios" , "N", 01, 00, },;
                { "recomendar", "N", 01, 00, },;
                { "adversos"  , "N", 01, 00, },;
                { "resuelto"  , "L", 01, 00, cLogica } }
   aIndice := { { "Periodo"   , { "optica", "control" } } }
Case cTabla == "ciudades"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 05, 00, },;
                { "nombre"    , "C", 30, 00, } }
   aIndice := { { "Codigo",  { "codigo" } },;
                { "Nombre",  { "nombre" } } }
Case cTabla == "historia"
   aStruct := { { "codigo_nit", "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "tipoiden"  , "C", 02, 00, " default 'CC'"},;
                { "nroiden"   , "C", 15, 00, },;
                { "apellidos" , "C", 35, 00, },;
                { "nombres"   , "C", 30, 00, },;
                { "sexo"      , "C", 01, 00, " default 'M'"},;
                { "fec_nacimi", "D", 08, 00, },;
                { "uniedad"   , "C", 01, 00, " default '1'"},;
                { "edad"      , "N", 03, 00, },;
                { "reshabit"  , "C", 05, 00, },;
                { "zonaresi"  , "C", 01, 00, " default 'U'"},;
                { "direccion" , "C", 40, 00, },;
                { "tel_reside", "C", 15, 00, },;
                { "tel_oficin", "C", 15, 00, },;
                { "email"     , "C", 40, 00, },;
                { "ocupacion" , "C", 03, 00, " default '999'"},;
                { "tipousua"  , "C", 01, 00, " default '5'"},;
                { "tipoafili" , "C", 01, 00, " default 'C'"},;
                { "nro_histor", "N", 08, 00, },;
                { "papel"     , "N", 02, 00, },;
                { "pnomb"     , "N", 02, 00, },;
                { "optica"    , "N", 02, 00, },;
                { "exportar"  , "C", 01, 00, },;
                { "est_civil" , "C", 01, 00, " default 'S'"},;
                { "cityb_id"  , "N", 11, 00, } }
   aIndice := { { "NroIden"  , { "nroiden" } }  ,;
                { "Apellido" , { "apellidos", "nombres" } },;
                { "Nombres"  , { "nombres", "apellidos" } } }
   cType   := "InnoDB"
Case cTabla == "historic"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo_nit", "N", 06, 00, },;
                { "optica"    , "N", 02, 00, },;
                { "nro_histor", "N", 08, 00, },;
                { "fec_histor", "D", 08, 00, },;
                { "apersonal" , "M", 10, 00, },;
                { "afamiliar" , "M", 10, 00, },;
                { "observ_his", "C",100, 00, },;
                { "estrefod"  , "C",100, 00, },;
                { "estrefoi"  , "C",100, 00, } }
   aIndice := { { "Historia" , { "optica", "nro_histor" } } }
   cType   := "InnoDB"
Case cTabla == "historpa"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "optica"    , "N", 02, 00, },;
                { "codigo_nit", "N", 11, 00, },;
                { "fecha"     , "E", 08, 00, },;
                { "hora_con"  , "C", 05, 00, },;
                { "destino"   , "C", 15, 00, },;
                { "referido"  , "C", 15, 00, } }
   aIndice := { { "Atencion"  , { "fecha" } } }
Case cTabla == "hiscntrl"
   aStruct := { { "cntrl_id"  , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "optica"    , "N", 02, 00, },;
                { "nro_histor", "N", 08, 00, },;
                { "control"   , "N", 08, 00, },;
                { "fecha"     , "D", 08, 00, },;
                { "doctor"    , "C", 50, 00, },;
                { "motivo_con", "M", 10, 00, },;
                { "fechafac"  , "D", 08, 00, },;
                { "fechaent"  , "D", 08, 00, },;
                { "notas_lc"  , "C",100, 00, },;
                { "medicament", "C",100, 00, },;
                { "remitir"   , "C", 50, 00, },;
                { "fchproxcon", "D", 08, 00, },;
                { "observ_dia", "M", 10, 00, },;
                { "codigo_nit", "N", 11, 00, } }
   aIndice := { { "Control"  , { "nro_histor", "control" } },;
                { "Fecha"    , { "fecha" } } }
Case cTabla == "hisagvis"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "cntrl_id"  , "N", 11, 00, },;
                { "scavlod"   , "C", 06, 00, },;
                { "scavlodph" , "C", 06, 00, },;
                { "scavcod"   , "C", 06, 00, },;
                { "scavloi"   , "C", 06, 00, },;
                { "scavloiph" , "C", 06, 00, },;
                { "scavcoi"   , "C", 06, 00, },;
                { "scavlao"   , "C", 06, 00, },;
                { "scavlaoph" , "C", 06, 00, },;
                { "scavcao"   , "C", 06, 00, },;
                { "ccavlod"   , "C", 06, 00, },;
                { "ccavlodph" , "C", 06, 00, },;
                { "ccavcod"   , "C", 06, 00, },;
                { "ccavloi"   , "C", 06, 00, },;
                { "ccavloiph" , "C", 06, 00, },;
                { "ccavcoi"   , "C", 06, 00, },;
                { "ccavlao"   , "C", 06, 00, },;
                { "ccavlaoph" , "C", 06, 00, },;
                { "ccavcao"   , "C", 06, 00, },;
                { "observ_av" , "M", 10, 00, },;
                { "lovlodesf" , "C", 06, 00, },;
                { "lovlodcil" , "C", 06, 00, },;
                { "lovlodeje" , "C", 04, 00, },;
                { "lovloiesf" , "C", 06, 00, },;
                { "lovloicil" , "C", 06, 00, },;
                { "lovloieje" , "C", 04, 00, },;
                { "lovpodesf" , "C", 06, 00, },;
                { "lovpodcil" , "C", 06, 00, },;
                { "lovpodeje" , "C", 04, 00, },;
                { "lovpoiesf" , "C", 06, 00, },;
                { "lovpoicil" , "C", 06, 00, },;
                { "lovpoieje" , "C", 04, 00, },;
                { "loodadd"   , "C", 04, 00, },;
                { "looiadd"   , "C", 04, 00, },;
                { "lotipo"    , "C",100, 00, },;
                { "odcurvabas", "C", 06, 00, },;
                { "odpoder"   , "C", 06, 00, },;
                { "oddiametro", "C", 06, 00, },;
                { "odcurvap"  , "C", 06, 00, },;
                { "oicurvabas", "C", 06, 00, },;
                { "oipoder"   , "C", 06, 00, },;
                { "oidiametro", "C", 06, 00, },;
                { "oicurvap"  , "C", 06, 00, },;
                { "tipolc"    , "C", 10, 00, },;
                { "observ_rxu", "M", 10, 00, } }
   aIndice := { { "Control", { "cntrl_id" } } }
//              { "Constraint",{ "ALTER TABLE hisagvis ADD CONSTRAINT kt_agvis " +;
//                                   "FOREIGN KEY (optica, nro_histor, control) "+;
//                           "REFERENCES hiscntrl (optica, nro_histor, control) "+;
//                           "ON DELETE CASCADE ON UPDATE CASCADE" } } }
Case cTabla == "hisdiagn"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "cntrl_id"  , "N", 11, 00, },;
                { "tipodgn"   , "C", 01, 00, },;
                { "ladolente" , "C", 01, 00, },;
                { "codigo"    , "C", 06, 00, },;
                { "esfera"    , "C", 06, 00, },;
                { "cilindro"  , "C", 06, 00, },;
                { "eje"       , "C", 03, 00, },;
                { "adicion"   , "C", 04, 00, },;
                { "tipoadd"   , "C", 03, 00, },;
                { "avl"       , "C", 04, 00, },;
                { "avc"       , "C", 04, 00, },;
                { "dp_cb"     , "C", 09, 00, },;
                { "cbase"     , "C", 12, 00, },;
                { "diametro"  , "C", 06, 00, },;
                { "ecentro"   , "C", 05, 00, },;
                { "eborde"    , "C", 05, 00, },;
                { "zoptica"   , "C", 05, 00, } }
   aIndice := { { "Control", { "cntrl_id" } } }
Case cTabla == "hisexame"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "cntrl_id"  , "N", 11, 00, },;
                { "odpintraoc", "C", 03, 00, },;
                { "oipintraoc", "C", 03, 00, },;
                { "examen_ext", "M", 10, 00, } }
   aIndice := { { "Control", { "cntrl_id" } } }
Case cTabla == "hisnotas"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "cntrl_id"  , "N", 11, 00, },;
                { "tiponota"  , "C", 01, 00, },;
                { "notas"     , "M", 10, 00, } }
   aIndice := { { "Control", { "cntrl_id" } } }
Case cTabla == "hisretin"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "cntrl_id"  , "N", 11, 00, },;
                { "estodesf"  , "C", 06, 00, },;
                { "estodcil"  , "C", 06, 00, },;
                { "estodeje"  , "C", 04, 00, },;
                { "estodavl"  , "C", 04, 00, },;
                { "estodavc"  , "C", 04, 00, },;
                { "estoiesf"  , "C", 06, 00, },;
                { "estoicil"  , "C", 06, 00, },;
                { "estoieje"  , "C", 04, 00, },;
                { "estoiavl"  , "C", 04, 00, },;
                { "estoiavc"  , "C", 04, 00, },;
                { "dinodesf"  , "C", 06, 00, },;
                { "dinodcil"  , "C", 06, 00, },;
                { "dinodeje"  , "C", 04, 00, },;
                { "dinodavl"  , "C", 04, 00, },;
                { "dinodavc"  , "C", 04, 00, },;
                { "dinoiesf"  , "C", 06, 00, },;
                { "dinoicil"  , "C", 06, 00, },;
                { "dinoieje"  , "C", 04, 00, },;
                { "dinoiavl"  , "C", 04, 00, },;
                { "dinoiavc"  , "C", 04, 00, },;
                { "observ_rt" , "M", 10, 00, } }
   aIndice := { { "Control", { "cntrl_id" } } }
Case cTabla == "hisoftal"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "cntrl_id"  , "N", 11, 00, },;
                { "tipo"      , "C", 50, 00, },;
                { "odpolopost", "C",255, 00, },;
                { "odexcava"  , "C",255, 00, },;
                { "odmacula"  , "C",255, 00, },;
                { "odfijacion", "C",255, 00, },;
                { "oipolopost", "C",255, 00, },;
                { "oiexcava"  , "C",255, 00, },;
                { "oimacula"  , "C",255, 00, },;
                { "oifijacion", "C",255, 00, },;
                { "observ_of" , "M", 10, 00, } }
   aIndice := { { "Control", { "cntrl_id" } } }
Case cTabla == "hisquera"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "cntrl_id"  , "N", 11, 00, },;
                { "odplano"   , "C", 06, 00, },;
                { "odcurvo"   , "C", 06, 00, },;
                { "odeje"     , "C", 04, 00, },;
                { "oiplano"   , "C", 06, 00, },;
                { "oicurvo"   , "C", 06, 00, },;
                { "oieje"     , "C", 04, 00, },;
                { "miras"     , "C", 50, 00, },;
                { "equipo"    , "C", 50, 00, },;
                { "observ_ot" , "M", 10, 00, } }
   aIndice := { { "Control", { "cntrl_id" } } }
Case cTabla == "hislente"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 06, 00, },;
                { "nombre"    , "C", 40, 00, },;
                { "tipo_lente", "C", 01, 00, } }
   aIndice := { { "Codigo",  { "codigo" } },;
                { "Nombre",  { "nombre" } } }
Case cTabla == "hisvaria"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "tipo"      , "C", 02, 00, },;
                { "descripcio", "C", 50, 00, } }
   aIndice := { { "TipoExam"  , { "tipo" } } }
Case cTabla == "menuhis"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "grupo"     , "N", 02, 00, },;
                { "Nivel"     , "N", 02, 00, },;
                { "pos"       , "N", 02, 00, },;
                { "submenu"   , "L", 01, 00, cLogica },;
                { "item"      , "C", 40, 00, },;
                { "accion"    , "C", 40, 00, },;
                { "mensaje"   , "C", 60, 00, },;
                { "prompt"    , "C", 20, 00, },;
                { "acelerador", "C", 03, 00, },;
                { "tecla"     , "C", 03, 00, } }
   aIndice := { { "Posicion", { "grupo","pos" } } }
Case cTabla == "ridars"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 06, 00, },;
                { "nombre"    , "C",100, 00, },;
                { "sgsss"     , "C", 13, 00, },;
                { "remision"  , "N", 08, 00, } }
   aIndice := { { "Codigo",  { "codigo" } },;
                { "Nombre",  { "nombre" } } }
Case cTabla == "ridclpro"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 06, 00, },;
                { "nombre"    , "C",254, 00, },;
                { "valor"     , "N", 10, 00, } }
   aIndice := { { "Codigo",  { "codigo" } },;
                { "Nombre",  { "nombre" } } }
Case cTabla == "riddiagn"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 04, 00, },;
                { "nombre"    , "C",250, 00, } }
   aIndice := { { "Codigo",  { "codigo" } },;
                { "Nombre",  { "nombre" } } }
Case cTabla == "ridespec"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 03, 00, },;
                { "nombre"    , "C", 75, 00, } }
   aIndice := { { "Codigo",  { "codigo" } },;
                { "Nombre",  { "nombre" } } }
Case cTabla == "ridocupa"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 03, 00, },;
                { "nombre"    , "C", 75, 00, } }
   aIndice := { { "Codigo",  { "codigo" } },;
                { "Nombre",  { "nombre" } } }
Case cTabla == "ridconsu"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "optica"    , "N", 02, 00, },;
                { "factura"   , "C", 10, 00, },;
                { "codadmin"  , "C", 06, 00, },;
                { "codigo_nit", "N", 06, 00, },;
                { "fecha"     , "D", 08, 00, },;
                { "orden"     , "N", 10, 00, },;
                { "autoriza"  , "C", 15, 00, },;
                { "codespec"  , "C", 03, 00, " default '500'" },;
                { "codcons"   , "C", 06, 00, " default '890207'" },;
                { "fincons"   , "C", 02, 00, " default '08'" },;
                { "causaextr" , "C", 02, 00, " default '15'" },;
                { "coddiag"   , "C", 04, 00, " default 'H521'" },;
                { "coddiag1"  , "C", 04, 00, },;
                { "coddiag2"  , "C", 04, 00, },;
                { "coddiag3"  , "C", 04, 00, },;
                { "tipodiag"  , "C", 01, 00, " default '1'" },;
                { "hriaclin"  , "N", 10, 00, },;
                { "valormod"  , "N", 14, 02, },;
                { "valor"     , "N", 15, 02, },;
                { "valornet"  , "N", 15, 02, } }
   aIndice := { { "CodigoEps",  { "codadmin, fecha" } },;
                { "Fecha"    ,  { "fecha, factura" } } }
Case cTabla == "ridservi"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "optica"    , "N", 02, 00, },;
                { "codadmin"  , "C", 06, 00, },;
                { "codigo_nit", "N", 06, 00, },;
                { "tiposerv"  , "C", 01, 00, " default '1'" },;
                { "codservi"  , "C", 06, 00, " default 'S21505'" },;
                { "nombre"    , "C", 60, 00, },;
                { "fecha"     , "D", 08, 00, },;
                { "factura"   , "C", 10, 00, },;
                { "autoriza"  , "C", 15, 00, },;
                { "cantidad"  , "N", 05, 00, },;
                { "valormod"  , "N", 14, 02, },;
                { "valor"     , "N", 15, 02, } }
   aIndice := { { "CodigoEps",  { "codadmin, fecha" } },;
                { "Fecha"    ,  { "fecha, factura" } } }
Case cTabla == "ripac"          // Archivo de Consulta
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "factura"   , "C", 20, 00, },;
                { "sgsss"     , "C", 13, 00, },;
                { "tipoiden"  , "C", 02, 00, },;
                { "nroiden"   , "C", 15, 00, },;
                { "fecha"     , "D", 08, 00, },;
                { "autoriza"  , "C", 15, 00, },;
                { "codigo"    , "C", 08, 00, },;
                { "fincons"   , "C", 02, 00, },;
                { "causaextr" , "C", 02, 00, },;
                { "coddiag"   , "C", 04, 00, },;
                { "coddiag1"  , "C", 04, 00, },;
                { "coddiag2"  , "C", 04, 00, },;
                { "coddiag3"  , "C", 04, 00, },;
                { "tipodiag"  , "C", 01, 00, },;
                { "valorcon"  , "N", 15, 02, },;
                { "valormod"  , "N", 15, 02, },;
                { "valornet"  , "N", 15, 02, } }
Case cTabla == "ripad"          // Archivo de descripcion agrupada de los servicios de salud prestados
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "factura"   , "C", 20, 00, },;
                { "sgsss"     , "C", 13, 00, },;
                { "concepto"  , "C", 02, 00, },;
                { "cantidad"  , "N", 15, 02, },;
                { "valorund"  , "N", 15, 02, },;
                { "valortot"  , "N", 15, 02, } }
Case cTabla == "ripaf"          // Archivo de las Transacciones
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "sgsss"     , "C", 13, 00, },;
                { "razonsoc"  , "C", 60, 00, },;
                { "tipoiden"  , "C", 02, 00, },;
                { "nroiden"   , "C", 15, 00, },;
                { "factura"   , "C", 20, 00, },;
                { "fecha"     , "D", 08, 00, },;
                { "fechaini"  , "D", 08, 00, },;
                { "fechafin"  , "D", 08, 00, },;
                { "codadmin"  , "C", 06, 00, },;
                { "nombreadm" , "C",100, 00, },;
                { "contrato"  , "C", 15, 00, },;
                { "planbene"  , "C", 30, 00, },;
                { "poliza"    , "C", 10, 00, },;
                { "copago"    , "N", 15, 02, },;
                { "comision"  , "N", 15, 02, },;
                { "desctos"   , "N", 15, 02, },;
                { "neto"      , "N", 15, 02, } }
Case cTabla == "ripat"          // Archivo de Otros Servicios
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "factura"   , "C", 20, 00, },;
                { "sgsss"     , "C", 13, 00, },;
                { "tipoiden"  , "C", 02, 00, },;
                { "nroiden"   , "C", 15, 00, },;
                { "autoriza"  , "C", 15, 00, },;
                { "tiposerv"  , "C", 01, 00, },;
                { "codigo"    , "C", 08, 00, },;
                { "nombre"    , "C", 60, 00, },;
                { "cantidad"  , "N", 05, 00, },;
                { "valorund"  , "N", 15, 02, },;
                { "valortot"  , "N", 15, 02, } }
Case cTabla == "ripct"          // Archivo de Control
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "sgsss"     , "C", 13, 00, },;
                { "fecha"     , "D", 08, 00, },;
                { "archivo"   , "C", 08, 00, },;
                { "registros" , "C", 10, 00, } }
Case cTabla == "ripus"          // Archivo de Usuarios de los servicios de salud
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "tipoiden"  , "C", 02, 00, },;
                { "nroiden"   , "C", 15, 00, },;
                { "codadmin"  , "C", 06, 00, },;
                { "tipousua"  , "C", 01, 00, },;
                { "priapelli" , "C", 30, 00, },;
                { "segapelli" , "C", 30, 00, },;
                { "prinombre" , "C", 20, 00, },;
                { "segnombre" , "C", 20, 00, },;
                { "edad"      , "N", 03, 00, },;
                { "uniedad"   , "C", 01, 00, },;
                { "sexo"      , "C", 01, 00, },;
                { "dptorh"    , "C", 02, 00, },;
                { "munirh"    , "C", 03, 00, },;
                { "zonaresi"  , "C", 01, 00, },;
                { "fechanac"  , "D", 08, 00, },;
                { "fechacon"  , "D", 08, 00, } }
EndCase
If xDbf == nil
   cTabla := If( cTB == nil, cTabla, cTB )
   oTb := TMSTable():Create( oApl:oMySql, cTabla, aStruct,,,,, cType )
   FOR nI := 1 TO LEN( aIndice )
      If aIndice[nI,1] == "PrimaryKey"
         oTb:CreatePrimaryKey( aIndice[nI,2] )
      ElseIf aIndice[nI,1] == "Constraint"
         MSQuery( oApl:oMySql:hConnect,aIndice[nI,2] )
      Else
         oTb:CreateIndex( aIndice[nI,1],aIndice[nI,2], .f. )
      EndIf
   NEXT nI
   oTb:Destroy()
Else
   BorraFile( cTabla,{"DBF"} )
   dbCREATE( oApl:cRuta2+cTabla,aStruct )
EndIf
RETURN NIL