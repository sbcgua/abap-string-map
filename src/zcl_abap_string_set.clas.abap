class zcl_abap_string_set definition
  public
  final
  create public.

  public section.
    class-methods create
      returning
        value(ro_instance) type ref to zcl_abap_string_set.
    methods add
      importing
        iv_value type clike
      returning
        value(ro_instance) type ref to zcl_abap_string_set.
    methods delete
      importing
        iv_value type clike.
    methods has
      importing
        iv_value type clike
      returning
        value(rv_has) type abap_bool.
    methods size
      returning
        value(rv_size) type i.
    methods to_range
      changing
        ct_range type standard table.

  private section.
    data mt_values type sorted table of string with unique key table_line.
ENDCLASS.


CLASS ZCL_ABAP_STRING_SET IMPLEMENTATION.


  method create.
    create object ro_instance.
  endmethod.


  method add.
    data lv_value type string.
    lv_value = iv_value.
    insert lv_value into table mt_values.
    ro_instance = me.
  endmethod.


  method delete.
    data lv_value type string.
    lv_value = iv_value.
    delete table mt_values from lv_value.
  endmethod.


  method has.
    data lv_value type string.
    lv_value = iv_value.
    read table mt_values with table key table_line = lv_value transporting no fields.
    rv_has = boolc( sy-subrc = 0 ).
  endmethod.


  method size.
    rv_size = lines( mt_values ).
  endmethod.


  method to_range.

    data lo_table type ref to cl_abap_tabledescr.
    data lo_line type ref to cl_abap_datadescr.
    data lo_structure type ref to cl_abap_structdescr.
    data lr_result type ref to data.
    data lv_value type string.
    data lx_conversion type ref to cx_sy_conversion_error.
    field-symbols <result> type standard table.
    field-symbols <row> type any.
    field-symbols <sign> type any.
    field-symbols <option> type any.
    field-symbols <low> type any.
    field-symbols <high> type any.

    lo_table ?= cl_abap_typedescr=>describe_by_data( ct_range ).
    lo_line = lo_table->get_table_line_type( ).
    if lo_line->kind <> cl_abap_typedescr=>kind_struct.
      lcx_error=>raise( 'Range line must be a structure with SIGN, OPTION, LOW and HIGH' ).
    endif.
    lo_structure ?= lo_line.
    if lines( lo_structure->components ) <> 4.
      lcx_error=>raise( 'Range line must have exactly SIGN, OPTION, LOW and HIGH' ).
    endif.

    " Build a copy so a failed conversion never leaves the caller's range half-filled.
    create data lr_result like ct_range.
    assign lr_result->* to <result>.
    <result> = ct_range.
    append initial line to <result> assigning <row>.
    assign component 'SIGN' of structure <row> to <sign>.
    if sy-subrc <> 0.
      lcx_error=>raise( 'Range line must contain SIGN' ).
    endif.
    assign component 'OPTION' of structure <row> to <option>.
    if sy-subrc <> 0.
      lcx_error=>raise( 'Range line must contain OPTION' ).
    endif.
    assign component 'LOW' of structure <row> to <low>.
    if sy-subrc <> 0.
      lcx_error=>raise( 'Range line must contain LOW' ).
    endif.
    assign component 'HIGH' of structure <row> to <high>.
    if sy-subrc <> 0.
      lcx_error=>raise( 'Range line must contain HIGH' ).
    endif.
    if cl_abap_typedescr=>describe_by_data( <sign> )->type_kind <> cl_abap_typedescr=>typekind_char
      or cl_abap_typedescr=>describe_by_data( <option> )->type_kind <> cl_abap_typedescr=>typekind_char.
      lcx_error=>raise( 'Range SIGN and OPTION must be character fields' ).
    endif.
    if cl_abap_typedescr=>describe_by_data( <low> )->kind <> cl_abap_typedescr=>kind_elem
      or cl_abap_typedescr=>describe_by_data( <high> )->kind <> cl_abap_typedescr=>kind_elem.
      lcx_error=>raise( 'Range LOW and HIGH must be elementary fields' ).
    endif.
    <sign> = 'I'.
    <option> = 'EQ'.
    if <sign> <> 'I' or <option> <> 'EQ'.
      lcx_error=>raise( 'Range SIGN or OPTION is too short' ).
    endif.
    delete <result> index lines( <result> ).

    loop at mt_values into lv_value.
      append initial line to <result> assigning <row>.
      assign component 'SIGN' of structure <row> to <sign>.
      assign component 'OPTION' of structure <row> to <option>.
      assign component 'LOW' of structure <row> to <low>.
      <sign> = 'I'.
      <option> = 'EQ'.
      try.
        <low> = lv_value.
      catch cx_sy_conversion_error into lx_conversion.
        lcx_error=>raise( |Cannot convert set value to range LOW: { lx_conversion->get_text( ) }| ).
      endtry.
    endloop.
    ct_range = <result>.

  endmethod.
ENDCLASS.
