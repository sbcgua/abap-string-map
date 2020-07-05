class zcl_abap_string_map definition
  public
  final
  create public .

  public section.

    constants version type string value 'v1.0.0'.

    types:
      begin of ty_entry,
          k type string,
          v type string,
        end of ty_entry .
    types:
      tty_entries type standard table of ty_entry with key k .
    types:
      tts_entries type sorted table of ty_entry with unique key k .

    data mt_entries type tts_entries read-only.

    class-methods create
      returning
        value(ro_instance) type ref to zcl_abap_string_map .
    methods constructor.

    methods get
      importing
        !iv_key type string
      returning
        value(rv_val) type string .
    methods has
      importing
        !iv_key type string
      returning
        value(rv_has) type abap_bool .
    methods set
      importing
        !iv_key type string
        !iv_val type string .
    methods size
      returning
        value(rv_size) type i .
    methods is_empty
      returning
        value(rv_yes) type abap_bool .
    methods delete
      importing
        !iv_key type string .
    methods keys
      returning
        value(rt_keys) type string_table .
    methods values
      returning
        value(rt_values) type string_table .
    methods clear.
    methods to_abap
      changing
        !cs_container type any.
    methods from_abap
      importing
        !is_container type any.
    methods strict
      importing
        !iv_strict type abap_bool default abap_true
      returning
        value(ro_instance) type ref to zcl_abap_string_map .

  protected section.
  private section.
    data mv_is_strict type abap_bool.
ENDCLASS.



CLASS ZCL_ABAP_STRING_MAP IMPLEMENTATION.


  method clear.
    clear mt_entries.
  endmethod.


  method constructor.
    mv_is_strict = abap_true.
  endmethod.


  method create.
    create object ro_instance.
  endmethod.


  method delete.

    delete mt_entries where k = iv_key.

  endmethod.


  method from_abap.

    data lo_type type ref to cl_abap_typedescr.
    data lo_struc type ref to cl_abap_structdescr.
    field-symbols <c> like line of lo_struc->components.
    field-symbols <val> type any.

    clear mt_entries.

    lo_type = cl_abap_typedescr=>describe_by_data( is_container ).
    if lo_type->type_kind <> cl_abap_typedescr=>typekind_struct1
      and lo_type->type_kind <> cl_abap_typedescr=>typekind_struct2.
      lcx_error=>raise( 'Only structures supported' ).
    endif.

    lo_struc ?= lo_type.
    loop at lo_struc->components assigning <c>.
      check <c>-type_kind co 'bsI8PaeFCNgXyDT'. " values
      assign component <c>-name of structure is_container to <val>.
      assert sy-subrc = 0.
      set(
        iv_key = |{ <c>-name }|
        iv_val = |{ <val> }| ).
    endloop.

  endmethod.


  method get.

    field-symbols <entry> like line of mt_entries.
    read table mt_entries assigning <entry> with key k = iv_key.
    if sy-subrc = 0.
      rv_val = <entry>-v.
    endif.

  endmethod.


  method has.

    read table mt_entries transporting no fields with key k = iv_key.
    rv_has = boolc( sy-subrc = 0 ).

  endmethod.


  method is_empty.
    rv_yes = boolc( lines( mt_entries ) = 0 ).
  endmethod.


  method keys.

    field-symbols <entry> like line of mt_entries.
    loop at mt_entries assigning <entry>.
      append <entry>-k to rt_keys.
    endloop.

  endmethod.


  method set.

    data ls_entry like line of mt_entries.
    field-symbols <entry> like line of mt_entries.

    read table mt_entries assigning <entry> with key k = iv_key.
    if sy-subrc = 0.
      <entry>-v = iv_val.
    else.
      ls_entry-k = iv_key.
      ls_entry-v = iv_val.
      insert ls_entry into table mt_entries.
    endif.

  endmethod.


  method size.

    rv_size = lines( mt_entries ).

  endmethod.


  method strict.
    mv_is_strict = iv_strict.
    ro_instance = me.
  endmethod.


  method to_abap.

    data lo_type type ref to cl_abap_typedescr.
    data lo_struc type ref to cl_abap_structdescr.
    data lv_field type string.
    field-symbols <entry> like line of mt_entries.
    field-symbols <val> type any.

    lo_type = cl_abap_typedescr=>describe_by_data( cs_container ).
    if lo_type->type_kind <> cl_abap_typedescr=>typekind_struct1
      and lo_type->type_kind <> cl_abap_typedescr=>typekind_struct2.
      lcx_error=>raise( 'Only structures supported' ).
    endif.

    lo_struc ?= lo_type.
    loop at mt_entries assigning <entry>.
      lv_field = to_upper( <entry>-k ).
      assign component lv_field of structure cs_container to <val>.
      if sy-subrc = 0.
        " TODO check target type ?
        <val> = <entry>-v.
      elseif mv_is_strict = abap_false.
        continue.
      else.
        lcx_error=>raise( |Component { lv_field } not found in target| ).
      endif.
    endloop.

  endmethod.


  method values.

    field-symbols <entry> like line of mt_entries.
    loop at mt_entries assigning <entry>.
      append <entry>-v to rt_values.
    endloop.

  endmethod.
ENDCLASS.
