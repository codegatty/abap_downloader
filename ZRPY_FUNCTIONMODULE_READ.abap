function ZRPY_FUNCTIONMODULE_READ.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(FUNCTIONNAME) LIKE  RS38L-NAME
*"  EXPORTING
*"     VALUE(GLOBAL_FLAG) LIKE  RS38L-GLOBAL
*"     VALUE(REMOTE_CALL) LIKE  RS38L-REMOTE
*"     VALUE(UPDATE_TASK) LIKE  RS38L-UTASK
*"     VALUE(SHORT_TEXT) LIKE  TFTIT-STEXT
*"     VALUE(FUNCTION_POOL) LIKE  RS38L-AREA
*"     VALUE(REMOTE_BASXML_SUPPORTED) LIKE  RS38L-BASXML_ENABLED
*"     VALUE(SORUCE_STRING) TYPE  RSWSOURCET
*"  TABLES
*"      IMPORT_PARAMETER STRUCTURE  RSIMP
*"      CHANGING_PARAMETER STRUCTURE  RSCHA
*"      EXPORT_PARAMETER STRUCTURE  RSEXP
*"      TABLES_PARAMETER STRUCTURE  RSTBL
*"      EXCEPTION_LIST STRUCTURE  RSEXC
*"      DOCUMENTATION STRUCTURE  RSFDO
*"      SOURCE TYPE  RSWSOURCET
*"  EXCEPTIONS
*"      ERROR_MESSAGE
*"      FUNCTION_NOT_FOUND
*"      INVALID_NAME
*"----------------------------------------------------------------------
  data: include like trdir-name, zeilen like sy-tabix.
  data: docu like funct occurs 0 with header line.
  data: oref type ref to cx_root.

* ec 2.12.2003 Sonderzeichenprüfung korrigiert

  if functionname  ca '\$!§%&'''.                           "#EC *
    raise invalid_name.
  endif.

  if functionname ca '-'.
    if functionname np '*-TEXTH# ' and
       functionname np '*-TEXTL# '.
      raise invalid_name.
    endif.
  endif.
  if functionname ca '.'.
    raise invalid_name.
  endif.
data:ls_tfdir type tfdir.
  select single * from tfdir into ls_tfdir where funcname = functionname.
  if sy-subrc ne 0.
    message e046(fl) with functionname raising function_not_found.
  endif.

  call function 'FUNCTION_INCLUDE_CONCATENATE'
    changing
      program                  = ls_tfdir-pname
      complete_area            = function_pool
    exceptions
      not_enough_input         = 1
      no_function_pool         = 2
      delimiter_wrong_position = 3
      others                   = 4.

  remote_call = ls_tfdir-fmode.
  if ls_tfdir-fmode = 'R'.
    remote_basxml_supported = space.
  elseif ls_tfdir-fmode = 'X'.
    remote_basxml_supported = 'X'.
  else.
    remote_basxml_supported = space.
  endif.

  update_task = ls_tfdir-utask.
* Interface ermitteln
  perform fu_import_interface_fupararef(sapms38l)
                            tables import_parameter
                                   changing_parameter
                                   export_parameter
                                   tables_parameter
                                   exception_list
                                   documentation
                            using  functionname
                            changing global_flag.
* Report einlesen
  call function 'FUNCTION_INCLUDE_CONCATENATE'
    exporting
      include_number = ls_tfdir-include
    importing
      include        = include
    changing
      program        = ls_tfdir-pname
    exceptions
      others         = 0.
*ec 19. März 2004
  try.
      read report include into source.
      read report include into soruce_string.
    catch cx_root into oref.
      if oref is bound.
        message e180(fl) with text-001 raising error_message.
      endif.
  endtry.

* Dokumentation holen
  describe table documentation lines zeilen.
  if zeilen ne 0.
    select * from funct into table docu
               where spras     =   sy-langu
               and   funcname  =   functionname.
    loop at documentation.
      zeilen = sy-tabix.
      read table docu with key parameter = documentation-parameter
                               kind     = documentation-kind.
      if sy-subrc = 0.
        move docu-stext to documentation-stext.
        modify documentation index zeilen.
      endif.
    endloop.
    data:ls_funct type  funct.
    loop at documentation where stext is initial.
      select * from funct into ls_funct where spras = 'E'
                             and funcname = functionname
*                               and version =  documentation-version
                             and kind     = documentation-kind
                             and parameter = documentation-parameter.
        move ls_funct-stext to documentation-stext.
        modify documentation index sy-tabix.
      endselect.
    endloop.

  endif.
  data:ls_tftit type tftit.
  select single * from  tftit
          into ls_tftit
         where  spras       = sy-langu
         and    funcname    = functionname.
  if sy-subrc = 0.
    short_text = ls_tftit-stext.
  else.
    select single * from  tftit
          into ls_tftit
           where  spras       = 'E'
           and    funcname    = functionname.
    if sy-subrc = 0.
      short_text = ls_tftit-stext.
    else.
      clear short_text.
    endif.
  endif.
endfunction.
