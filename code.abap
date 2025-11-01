*&---------------------------------------------------------------------*
* Project          : MELSA ERP Implementation
* Object Name      : ZAABBNNN_XXXXXXXXXXXXXXXXXXXXX
* Technical        :
* Functional       :
* Date             : 01.01.2016
* Module           : XX
* Development ID   : 000
* Transaction Code : ZAANNN
* Description      : Short Description
*&---------------------------------------------------------------------*
* Change Control Information
*&---------------------------------------------------------------------*
* CR & SpecNo | Date       | Name        | Description
* XXXXXXXXXXX | DD.MM.YYYY | XXXXXXXXXXX | XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*&---------------------------------------------------------------------*
* Detail Description: This program is xxxxxx xxxxx xxxxx xxxxxxxxxxxxxx.
*&---------------------------------------------------------------------*
REPORT zotestr_download_download.

DATA:gv_package TYPE tadir-devclass VALUE 'YATPL_GAZTEINVOICE'.
DATA:gv_base_path TYPE string VALUE 'd:\temp\'.
TYPES: ty_excel_tab TYPE STANDARD TABLE OF string WITH DEFAULT KEY.


"PERFORM downlaod_tables.
"PERFORM download_class_methods.
"PERFORM download_function_mods.
"PERFORM download_domains.
PERFORM download_data_element.

FORM download_data_element.

  TYPES: BEGIN OF ty_tadir,
           obj_name TYPE dd04l-rollname,
           devclass TYPE tadir-devclass,
           object   TYPE tadir-object,
         END OF ty_tadir.

  TYPES: BEGIN OF ty_dd04l,
           rollname   TYPE dd04l-rollname,
           domname    TYPE dd04l-domname,
           datatype   TYPE dd04l-datatype,
           leng       TYPE dd04l-leng,
           decimals   TYPE dd04l-decimals,
           outputlen  TYPE dd04l-ROUTPUTLEN,
           shlpname   TYPE dd04l-shlpname,
         END OF ty_dd04l.

  TYPES: BEGIN OF ty_dd01t,
           domname TYPE dd01t-domname,
           ddtext  TYPE dd01t-ddtext,
         END OF ty_dd01t.

  DATA: lt_tadir   TYPE STANDARD TABLE OF ty_tadir,
        lt_dd04l   TYPE STANDARD TABLE OF ty_dd04l,
        lt_dd01t   TYPE STANDARD TABLE OF ty_dd01t,
        lt_excel   TYPE STANDARD TABLE OF string,
        lv_filename TYPE string,
        lv_line     TYPE string.

  FIELD-SYMBOLS: <fs_dd04l> TYPE ty_dd04l,
                 <fs_dd01t> TYPE ty_dd01t.

  " Fetch all Data Elements in the given package
  SELECT obj_name devclass object
    FROM tadir
    INTO TABLE lt_tadir
    WHERE object   = 'DTEL'
      AND devclass = gv_package.

  IF lt_tadir IS INITIAL.
    MESSAGE 'No Data Elements found in this package' TYPE 'I'.
    RETURN.
  ENDIF.

  " Fetch Data Element definitions
  SELECT rollname
         domname
         datatype
         leng
         decimals
         routputlen
         shlpname
    FROM dd04l
    INTO TABLE lt_dd04l
    FOR ALL ENTRIES IN lt_tadir
    WHERE rollname = lt_tadir-obj_name.

  " Fetch Domain descriptions (text)
  SELECT domname
         ddtext
    FROM dd01t
    INTO TABLE lt_dd01t
    FOR ALL ENTRIES IN lt_dd04l
    WHERE domname = lt_dd04l-domname
      AND ddlanguage = sy-langu.

  " Header row
  APPEND 'Data Element,Domain,Data Type,Length,Output Length,Decimals,Search Help,Domain Text' TO lt_excel.

  LOOP AT lt_dd04l ASSIGNING <fs_dd04l>.
    READ TABLE lt_dd01t ASSIGNING <fs_dd01t>
      WITH KEY domname = <fs_dd04l>-domname.

    CONCATENATE
      <fs_dd04l>-rollname
      <fs_dd04l>-domname
      <fs_dd04l>-datatype
      <fs_dd04l>-leng
      <fs_dd04l>-outputlen
      <fs_dd04l>-decimals
      <fs_dd04l>-shlpname
      <fs_dd01t>-ddtext
      INTO lv_line SEPARATED BY ','.

    APPEND lv_line TO lt_excel.
    CLEAR lv_line.
  ENDLOOP.

  CONCATENATE gv_base_path 'data_elements.csv' INTO lv_filename.
  PERFORM save_excel_in_file USING lt_excel lv_filename.

ENDFORM.



form download_domains.
    TYPES:BEGIN OF ty_tadir,
obj_name TYPE dd01l-DOMNAME,
devclass TYPE tadir-devclass,
object TYPE tadir-object,
 END OF ty_tadir.
types:begin of ty_DD01L,
  DOMNAME type dd01l-DOMNAME,
  DATATYPE type dd01l-DATATYPE,
  LENG type dd01l-LENG,
  OUTPUTLEN type dd01l-OUTPUTLEN,
  DECIMALS type dd01l-DECIMALS,
end of ty_dd01l.

types:begin of ty_DD01T,
  DOMNAME type dd01t-DOMNAME,
  DDTEXT type dd01t-DDTEXT,
  end of ty_DD01T.

data:lt_tadir type  STANDARD TABLE OF ty_tadir.
data:lt_dd01l type STANDARD TABLE OF ty_dd01l.
data:lt_dd01t type STANDARD TABLE OF ty_dd01t.
data:lt_excel type STANDARD TABLE OF string.
data:lv_filename type string.
data:lv_line type string.
FIELD-SYMBOLS:<fs_dd01l> type ty_dd01l.
FIELD-SYMBOLS:<fs_dd01t> type ty_dd01t.

SELECT obj_name devclass object
FROM tadir INTO TABLE lt_tadir
WHERE object = 'DOMA'
AND devclass = gv_package.

select domname
       ddtext
        from DD01T
        into table lt_DD01T for ALL ENTRIES IN lt_tadir where domname = lt_tadir-obj_name.

select domname
        datatype
        leng
        outputlen
        decimals
        from dd01l into table lt_dd01l FOR ALL ENTRIES IN lt_tadir where domname = lt_tadir-obj_name.


  APPEND 'Domain Name,Data Type,Length,output Len,Decimals,short text' to lt_excel.
 loop at lt_dd01l ASSIGNING <fs_dd01l>.
   READ TABLE lt_dd01t ASSIGNING <fs_dd01t> WITH key domname = <fs_dd01l>-domname.
   CONCATENATE
      <fs_dd01l>-domname
      <fs_dd01l>-datatype
      <fs_dd01l>-leng
      <fs_dd01l>-outputlen
      <fs_dd01l>-decimals
      <fs_dd01t>-ddtext
      into lv_line SEPARATED BY ','.

   APPEND lv_line to lt_excel.
   clear:lv_line.
 ENDLOOP.
 CONCATENATE gv_base_path 'domains.csv' INTO lv_filename.
 PERFORM save_excel_in_file USING lt_excel lv_filename.

endform.

FORM download_function_mods.

  TYPES:BEGIN OF ty_tadir,
obj_name TYPE area,
devclass TYPE tadir-devclass,
object TYPE tadir-object,
 END OF ty_tadir.

  TYPES:BEGIN OF ty_v_fdirt,
    funcname TYPE v_fdirt-funcname,
    area TYPE area,
    stext TYPE v_fdirt-stext,
  END OF ty_v_fdirt.
  DATA:lt_param_lines TYPE STANDARD TABLE OF string.
  DATA:ls_param_line TYPE string.
  DATA:lt_source TYPE RSWSOURCET.
  DATA:ls_source TYPE RSWSOURCET.
  DATA:lt_import TYPE STANDARD TABLE OF rsimp.
  DATA:lt_changing TYPE STANDARD TABLE OF rscha.
  DATA:lt_export TYPE STANDARD TABLE OF rsexp.
  DATA:lt_tables TYPE STANDARD TABLE OF rstbl.
  DATA:lt_exception TYPE STANDARD TABLE OF rsexc.
  DATA:lt_source_result TYPE STANDARD TABLE OF string.
  DATA:lt_doc TYPE STANDARD TABLE OF rsfdo.
  DATA:lt_excel TYPE STANDARD TABLE OF string.
  data:lt_data type RSWSOURCET.

  DATA:lt_tadir TYPE STANDARD TABLE OF ty_tadir.
  DATA:lt_v_fdirt TYPE STANDARD TABLE OF ty_v_fdirt.
  DATA:lt_params TYPE STANDARD TABLE OF rfc_funint.
  FIELD-SYMBOLS:<fs_params> TYPE rfc_funint.
  FIELD-SYMBOLS:<fs_v_fdirt> TYPE ty_v_fdirt.

  SELECT obj_name devclass object
FROM tadir INTO TABLE lt_tadir
WHERE object = 'FUGR'
AND devclass = gv_package.

  SELECT funcname area stext FROM v_fdirt INTO TABLE lt_v_fdirt FOR ALL ENTRIES IN lt_tadir WHERE area = lt_tadir-obj_name.
  LOOP AT lt_v_fdirt ASSIGNING <fs_v_fdirt>.
    DATA:lv_fun_name TYPE rs38l-name.
    DATA:lv_filename TYPE string.
    WRITE <fs_v_fdirt>-funcname TO lv_fun_name.

    CALL FUNCTION 'RFC_GET_FUNCTION_INTERFACE'
      EXPORTING
        funcname                      = <fs_v_fdirt>-funcname
*   LANGUAGE                      = 'EN'
*   NONE_UNICODE_LENGTH           = ' '
* IMPORTING
*   REMOTE_BASXML_SUPPORTED       =
*   REMOTE_CALL                   =
*   UPDATE_TASK                   =
      TABLES
        params                        = lt_params
*   RESUMABLE_EXCEPTIONS          =
     EXCEPTIONS
       fu_not_found                  = 1
       nametab_fault                 = 2
       OTHERS                        = 3
              .
    IF sy-subrc = 0.
* Implement suitable error handling here
      APPEND 'PARAMCLASS,PARAMETER,TABNAME,FIELDNAME,EXID,POSITION,OFFSET,INTLENGTH,DECIMALS,DEFAULT,PARAMTEXT,OPTIONAL' TO lt_param_lines.
      LOOP AT lt_params ASSIGNING <fs_params>.
        DATA: lv_intlength TYPE char5,
              lv_decimals  TYPE char5,
              lv_optional  TYPE char5.


        WRITE <fs_params>-intlength TO lv_intlength.
        WRITE <fs_params>-decimals TO lv_decimals.
        WRITE <fs_params>-optional TO lv_optional.
        CONCATENATE
          <fs_params>-paramclass
          <fs_params>-parameter
          <fs_params>-tabname
          <fs_params>-fieldname
          <fs_params>-exid
          lv_intlength
          lv_decimals
          <fs_params>-default
          <fs_params>-paramtext
          lv_optional
          INTO ls_param_line
          SEPARATED BY ','.
        APPEND ls_param_line TO lt_excel.
        clear:lv_intlength,lv_decimals,lv_optional.

      ENDLOOP.
      CONCATENATE gv_base_path <fs_v_fdirt>-area '-' <fs_v_fdirt>-funcname '.csv' INTO lv_filename.
      PERFORM save_excel_in_file USING lt_excel lv_filename.
      clear:lv_filename,lt_excel.
    ENDIF.

    CALL FUNCTION 'ZRPY_FUNCTIONMODULE_READ'
      EXPORTING
        functionname                  = lv_fun_name
 IMPORTING
*   GLOBAL_FLAG                   =
*   REMOTE_CALL                   =
*   UPDATE_TASK                   =
*   SHORT_TEXT                    =
*   FUNCTION_POOL                 =
*   REMOTE_BASXML_SUPPORTED       =
      SORUCE_STRING = lt_data
      TABLES
        import_parameter              = lt_import
        changing_parameter            = lt_changing
        export_parameter              = lt_export
        tables_parameter              = lt_tables
        exception_list                = lt_exception
        documentation                 = lt_doc
        source                        = lt_source
     EXCEPTIONS
       error_message                 = 1
       function_not_found            = 2
       invalid_name                  = 3
       OTHERS                        = 4
              .
    IF sy-subrc = 0.
      DATA:lv_line TYPE string.
* Implement suitable error handling her
*      LOOP AT lt_source INTO ls_source.
*        lv_line = ls_source-line.
*        APPEND lv_line TO lt_source_result.
*      ENDLOOP.

      CONCATENATE gv_base_path <fs_v_fdirt>-area '-' <fs_v_fdirt>-funcname '.txt' INTO lv_filename.
      CALL FUNCTION 'GUI_DOWNLOAD'
        EXPORTING
          filename = lv_filename
          filetype = 'ASC'
        TABLES
          data_tab = lt_data
        EXCEPTIONS
          OTHERS   = 1.

      IF sy-subrc = 0.
        WRITE: / 'File downloaded successfully:', lv_filename.
      ELSE.
        WRITE: / 'Error while downloading file'.
      ENDIF.

    ENDIF.
    clear:lv_fun_name,lv_filename,lt_params,lt_source,lv_filename,lt_source_result,lt_data.
  ENDLOOP.





ENDFORM.

FORM download_class_methods.
  DATA:lt_source TYPE STANDARD TABLE OF string.
  DATA:lt_source_para TYPE STANDARD TABLE OF string.
  DATA:lv_filename TYPE string.
  DATA:lv_line TYPE string.
  DATA:lt_method_para TYPE seos_parameters_r.
  FIELD-SYMBOLS:<fs_method_para> TYPE seos_parameter_r.
  TYPES:BEGIN OF ty_tadir,
obj_name TYPE seoclsname,
devclass TYPE tadir-devclass,
 object TYPE tadir-object,
   END OF ty_tadir.

  TYPES:BEGIN OF ty_tmdir,
     classname TYPE tmdir-classname,
     methodname TYPE tmdir-methodname,
    END OF ty_tmdir.

  DATA:lt_tadir TYPE STANDARD TABLE OF ty_tadir.
  DATA:lt_tmdir TYPE STANDARD TABLE OF ty_tmdir.
  FIELD-SYMBOLS:<fs_tmdir> TYPE ty_tmdir.

  SELECT obj_name devclass object
FROM tadir INTO TABLE lt_tadir
WHERE object = 'CLAS'
AND devclass = gv_package.
  BREAK-POINT.
  SELECT classname methodname FROM tmdir INTO TABLE lt_tmdir FOR ALL ENTRIES IN lt_tadir WHERE classname = lt_tadir-obj_name.
  DATA:ls_mtdkey TYPE seocpdkey.
  DATA:ls_mtdkey_2 TYPE seocmpkey.

  LOOP AT lt_tmdir ASSIGNING <fs_tmdir>.

    ls_mtdkey-clsname = <fs_tmdir>-classname.
    ls_mtdkey-cpdname = <fs_tmdir>-methodname.
    ls_mtdkey_2-clsname = <fs_tmdir>-classname.
    ls_mtdkey_2-cmpname = <fs_tmdir>-methodname.

    CALL FUNCTION 'SEO_METHOD_SIGNATURE_GET'
      EXPORTING
        mtdkey        = ls_mtdkey_2
*       VERSION       = SEOC_VERSION_INACTIVE
*       STATE         = '1'
*       RESOLVE_ALIAS = ABAP_FALSE
      IMPORTING
*       METHOD        =
        parameters    = lt_method_para
*       EXCEPS        =
      EXCEPTIONS
        not_existing  = 1
        is_event      = 2
        is_type       = 3
        is_attribute  = 4
        model_only    = 5
        OTHERS        = 6.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ELSE.
      LOOP AT lt_method_para INTO <fs_method_para>.
        "CONCATENATE <fs_method_para>-sconame <fs_method_para>-descript <fs_method_para>-type <fs_method_para>-parvalue <fs_method_para>-CMPTYPE <fs_method_para>-TABLEOF
      ENDLOOP.
    ENDIF.


    CALL FUNCTION 'SEO_METHOD_GET_SOURCE'
      EXPORTING
        mtdkey                        = ls_mtdkey
        state                         = 'A'
*       WITH_ENHANCEMENTS             = SEOX_FALSE
      IMPORTING
*       SOURCE                        =
        source_expanded               = lt_source
*       INCNAME                       =
*       RESOLVED_METHOD_KEY           =
      EXCEPTIONS
        _internal_method_not_existing = 1
        _internal_class_not_existing  = 2
        version_not_existing          = 3
        inactive_new                  = 4
        inactive_deleted              = 5
        OTHERS                        = 6.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ELSE.
      CONCATENATE gv_base_path <fs_tmdir>-classname '-' <fs_tmdir>-methodname '.txt' INTO lv_filename.
      CALL FUNCTION 'GUI_DOWNLOAD'
        EXPORTING
          filename = lv_filename
          filetype = 'ASC'
        TABLES
          data_tab = lt_source
        EXCEPTIONS
          OTHERS   = 1.

      IF sy-subrc = 0.
        WRITE: / 'File downloaded successfully:', lv_filename.
      ELSE.
        WRITE: / 'Error while downloading file'.
      ENDIF.

    ENDIF.

  ENDLOOP.



ENDFORM.

"SEO_METHOD_GET_SOURCE
FORM download_class_interface.

  DATA:lv_filename TYPE string.
  TYPES:BEGIN OF ty_tadir,
obj_name TYPE seoclsname,
devclass TYPE tadir-devclass,
 object TYPE tadir-object,
   END OF ty_tadir.
  BREAK-POINT.
  DATA:lt_source TYPE STANDARD TABLE OF string.
  FIELD-SYMBOLS:<fs_tadir> TYPE ty_tadir.
  DATA:lt_tadir TYPE STANDARD TABLE OF ty_tadir.
  SELECT obj_name devclass object
FROM tadir INTO TABLE lt_tadir
WHERE object = 'INTF'
  AND devclass = gv_package.

  DATA:ty_test TYPE seoclskey.



  LOOP AT lt_tadir ASSIGNING <fs_tadir>.
    ty_test-clsname = <fs_tadir>-obj_name.
    CALL FUNCTION 'SEO_INTERFACE_GET_SOURCE'
      EXPORTING
        cifkey                       = ty_test
       state                        = 'A'
     IMPORTING
*          SOURCE                       = lt_source
*          INCNAME                      =
       source_expanded              = lt_source
*        EXCEPTIONS
*          INTERFACE_NOT_EXISTING       = 1
*          VERSION_NOT_EXISTING         = 2
*          OTHERS                       = 3
              .
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ELSE.

      CONCATENATE gv_base_path <fs_tadir>-obj_name '.txt' INTO lv_filename.
      CALL FUNCTION 'GUI_DOWNLOAD'
        EXPORTING
          filename = lv_filename
          filetype = 'ASC'
        TABLES
          data_tab = lt_source
        EXCEPTIONS
          OTHERS   = 1.

      IF sy-subrc = 0.
        WRITE: / 'File downloaded successfully:', lv_filename.
      ELSE.
        WRITE: / 'Error while downloading file'.
      ENDIF.
    ENDIF.
  ENDLOOP.


ENDFORM.


FORM downlaod_tables.

  TYPES:BEGIN OF ty_tadir,
  obj_name TYPE char30,
  devclass TYPE tadir-devclass,
   object TYPE tadir-object,
     END OF ty_tadir.


  DATA:lv_file_name TYPE string.


  TYPES: BEGIN OF ty_dd03l,
           tabname    TYPE dd03l-tabname,     "Table name
           fieldname  TYPE dd03l-fieldname,   "Field name
           mandatory  TYPE dd03l-keyflag,     "Mandatory (Key flag or req field)
           rollname   TYPE dd03l-rollname,    "Data element
           checktable TYPE dd03l-checktable,  "Check table
           notnull    TYPE dd03l-notnull,     "Not null flag
           datatype   TYPE dd03l-datatype,    "Data type
           leng       TYPE dd03l-leng,        "Length
           decimals   TYPE dd03l-decimals,    "Decimals
           domname    TYPE dd03l-domname,     "Domain name
           comptype   TYPE dd03l-comptype,    "Component type (Structure, Table, etc.)
         END OF ty_dd03l.

  TYPES:BEGIN OF ty_dd02l,
    tabclass TYPE dd02l-tabclass,
      tabname TYPE dd02l-tabname,
    END OF ty_dd02l.




  DATA: lt_tadir TYPE STANDARD TABLE OF ty_tadir.
  DATA:lt_dd03l TYPE STANDARD  TABLE OF ty_dd03l.
  DATA:lt_dd02l TYPE STANDARD TABLE OF ty_dd02l.

  FIELD-SYMBOLS:<fs_dd03l> TYPE ty_dd03l.
  FIELD-SYMBOLS:<fs_dd02l> TYPE ty_dd02l.

  DATA: lt_excel TYPE TABLE OF string,
    lv_line  TYPE string.

  SELECT obj_name devclass object
  FROM tadir INTO TABLE lt_tadir
  WHERE object  = 'TABL'
    AND devclass = gv_package.


  SELECT
    tabclass
    tabname
   FROM dd02l
    INTO TABLE lt_dd02l
    FOR ALL ENTRIES IN lt_tadir WHERE tabname = lt_tadir-obj_name.
  SELECT
    tabname
    fieldname
    mandatory
    rollname
    checktable
    notnull
    datatype
    leng
    decimals
    domname
    comptype
    FROM dd03l INTO TABLE lt_dd03l FOR ALL ENTRIES IN lt_tadir WHERE tabname = lt_tadir-obj_name.



  SORT lt_dd02l BY tabclass.
  APPEND 'Table Name,Field Name,Mandatory,Data Element,Check Table,Not Null flag,Data Type,Length,Decimals,Domain Name,Component Type' TO lt_excel.
  LOOP AT lt_dd02l ASSIGNING <fs_dd02l>.
    LOOP AT lt_dd03l ASSIGNING <fs_dd03l> WHERE tabname = <fs_dd02l>-tabname .
      CONCATENATE
        <fs_dd03l>-tabname
        <fs_dd03l>-fieldname
        <fs_dd03l>-mandatory
        <fs_dd03l>-rollname
        <fs_dd03l>-checktable
        <fs_dd03l>-notnull
        <fs_dd03l>-datatype
        <fs_dd03l>-leng
        <fs_dd03l>-decimals
        <fs_dd03l>-domname
        <fs_dd03l>-comptype
        INTO lv_line SEPARATED BY ','.
      APPEND lv_line TO lt_excel.
    ENDLOOP.

    AT END OF tabclass.
      CASE <fs_dd02l>-tabclass.
        WHEN 'TRANSP'.
          lv_file_name = 'tables.csv'.
        WHEN 'INTTAB'.
          lv_file_name = 'structures.csv'.
        WHEN  'APPEND'.
          lv_file_name = 'append_structures.csv'.
        WHEN 'VIEW'.
          lv_file_name = 'views.csv'.
        WHEN OTHERS.
          lv_file_name = 'misc.csv'.
      ENDCASE.

      PERFORM save_excel_in_file USING lt_excel lv_file_name.
      CLEAR:lt_excel,lv_file_name.
      APPEND 'Table Name,Field Name,Mandatory,Data Element,Check Table,Not Null flag,Data Type,Length,Decimals,Domain Name,Component Type' TO lt_excel.
    ENDAT.

  ENDLOOP.



ENDFORM.

FORM save_excel_in_file USING p_excel TYPE ty_excel_tab p_file_name TYPE string .

*  DATA:lv_complete_path TYPE string.
*
*  CONCATENATE gv_base_path p_file_name INTO lv_complete_path.
  CALL FUNCTION 'GUI_DOWNLOAD'
  EXPORTING
*   BIN_FILESIZE                    =
    filename                        = p_file_name
   filetype                        = 'ASC'
*   APPEND                          = ' '
   write_field_separator           = 'X'
*   HEADER                          = '00'
*   TRUNC_TRAILING_BLANKS           = ' '
*   WRITE_LF                        = 'X'
*   COL_SELECT                      = ' '
*   COL_SELECT_MASK                 = ' '
*   DAT_MODE                        = ' '
*   CONFIRM_OVERWRITE               = ' '
*   NO_AUTH_CHECK                   = ' '
*   CODEPAGE                        = ' '
*   IGNORE_CERR                     = ABAP_TRUE
*   REPLACEMENT                     = '#'
*   WRITE_BOM                       = ' '
*   TRUNC_TRAILING_BLANKS_EOL       = 'X'
*   WK1_N_FORMAT                    = ' '
*   WK1_N_SIZE                      = ' '
*   WK1_T_FORMAT                    = ' '
*   WK1_T_SIZE                      = ' '
*   WRITE_LF_AFTER_LAST_LINE        = ABAP_TRUE
*   SHOW_TRANSFER_STATUS            = ABAP_TRUE
*   VIRUS_SCAN_PROFILE              = '/SCET/GUI_DOWNLOAD'
* IMPORTING
*   FILELENGTH                      =
  TABLES
    data_tab                        = p_excel
*   FIELDNAMES                      =
 EXCEPTIONS
   file_write_error                = 1
   no_batch                        = 2
   gui_refuse_filetransfer         = 3
   invalid_type                    = 4
   no_authority                    = 5
   unknown_error                   = 6
   header_not_allowed              = 7
   separator_not_allowed           = 8
   filesize_not_allowed            = 9
   header_too_long                 = 10
   dp_error_create                 = 11
   dp_error_send                   = 12
   dp_error_write                  = 13
   unknown_dp_error                = 14
   access_denied                   = 15
   dp_out_of_memory                = 16
   disk_full                       = 17
   dp_timeout                      = 18
   file_not_found                  = 19
   dataprovider_exception          = 20
   control_flush_error             = 21
   OTHERS                          = 22
          .
  IF sy-subrc = 0.
    MESSAGE 'Excel file downloaded successfully!' TYPE 'S'.
  ELSE.
    MESSAGE 'Download failed.' TYPE 'E'.
  ENDIF.


ENDFORM.
