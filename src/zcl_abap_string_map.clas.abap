class zcl_abap_string_map definition
  public
  final
  create public .

  public section.

    constants version type string value 'v1.0.3'.
    constants origin type string value 'https://github.com/sbcgua/abap-string-map'.
    constants license type string value 'MIT'.

    types:
      begin of ty_entry,
        k type string,
        v type string,
      end of ty_entry.
    types:
      tty_entries type standard table of ty_entry with key k.
    types:
      tts_entries type sorted table of ty_entry with unique key k.

    data mt_entries type tts_entries read-only.

    class-methods create
      importing
        !iv_case_insensitive type abap_bool default abap_false
        !iv_from type any optional
        preferred parameter iv_from
      returning
        value(ro_instance) type ref to zcl_abap_string_map.
    methods constructor
      importing
        !iv_case_insensitive type abap_bool default abap_false
        !iv_from type any optional.

    methods get
      importing
        !iv_key type clike
      returning
        value(rv_val) type string.
    methods has
      importing
        !iv_key type clike
      returning
        value(rv_has) type abap_bool.
    methods set
      importing
        !iv_key type clike
        !iv_val type clike
      returning
        value(ro_map) type ref to zcl_abap_string_map.
    methods size
      returning
        value(rv_size) type i.
    methods is_empty
      returning
        value(rv_yes) type abap_bool.
    methods delete
      importing
        !iv_key type clike.
    methods keys
      returning
        value(rt_keys) type string_table.
    methods values
      returning
        value(rt_values) type string_table.
    methods clear.

    methods from_struc
      importing
        !is_container type any
      returning
        value(ro_instance) type ref to zcl_abap_string_map.
    methods from_entries
      importing
        !it_entries type any table
      returning
        value(ro_instance) type ref to zcl_abap_string_map.
    methods from_string
      importing
        !iv_string_params type csequence
      returning
        value(ro_instance) type ref to zcl_abap_string_map.
    methods from_map
      importing
        !io_string_map type ref to zcl_abap_string_map
      returning
        value(ro_instance) type ref to zcl_abap_string_map.
    methods merge
      importing
        !io_string_map type ref to zcl_abap_string_map
      returning
        value(ro_instance) type ref to zcl_abap_string_map.

    methods to_struc
      changing
        !cs_container type any.
    methods to_string
      returning
        value(rv_string) type string.

    methods strict
      importing
        !iv_strict type abap_bool default abap_true
      returning
        value(ro_instance) type ref to zcl_abap_string_map.
    methods freeze.

  protected section.
  private section.
    data mv_is_strict type abap_bool.
    data mv_read_only type abap_bool.
    data mv_case_insensitive type abap_bool.
ENDCLASS.



CLASS ZCL_ABAP_STRING_MAP IMPLEMENTATION.


  method clear.

    if mv_read_only = abap_true.
      lcx_error=>raise( 'String map is read only' ).
    endif.

    clear mt_entries.

  endmethod.


  method constructor.
    mv_is_strict = abap_true.
    mv_case_insensitive = iv_case_insensitive.

    if iv_from is not initial.
      data lo_type type ref to cl_abap_typedescr.
      lo_type = cl_abap_typedescr=>describe_by_data( iv_from ).

      case lo_type->type_kind.
        when cl_abap_typedescr=>typekind_struct1 or cl_abap_typedescr=>typekind_struct2.
          me->from_struc( iv_from ).

        when cl_abap_typedescr=>typekind_oref.
          data lo_from type ref to zcl_abap_string_map.
          try.
            lo_from ?= iv_from.
          catch cx_sy_move_cast_error.
            lcx_error=>raise( 'Incorrect string map instance to copy from' ).
          endtry.

          if mt_entries is initial and mv_case_insensitive = abap_false.
            me->mt_entries = lo_from->mt_entries. " shortcut, maybe remove for safety
          else.
            me->from_map( lo_from ).
          endif.

        when cl_abap_typedescr=>typekind_table.
          me->from_entries( iv_from ).

        when cl_abap_typedescr=>typekind_string or cl_abap_typedescr=>typekind_char.
          me->from_string( iv_from ).

        when others.
          lcx_error=>raise( |Incorrect input for string_map=>create, typekind { lo_type->type_kind }| ).
      endcase.
    endif.

  endmethod.


  method create.
    create object ro_instance
      exporting
        iv_case_insensitive = iv_case_insensitive
        iv_from = iv_from.
  endmethod.


  method delete.

    if mv_read_only = abap_true.
      lcx_error=>raise( 'String map is read only' ).
    endif.

    data lv_key type string.

    if mv_case_insensitive = abap_true.
      lv_key = to_upper( iv_key ).
    else.
      lv_key = iv_key.
    endif.

    delete mt_entries where k = lv_key.

  endmethod.


  method freeze.
    mv_read_only = abap_true.
  endmethod.


  method from_entries.

    field-symbols <i> type ty_entry.

    loop at it_entries assigning <i> casting.
      set(
        iv_key = <i>-k
        iv_val = <i>-v ).
    endloop.

    ro_instance = me.

  endmethod.


  method from_map.

    from_entries( io_string_map->mt_entries ).
    ro_instance = me.

  endmethod.


  method from_string.

    if iv_string_params is initial.
      return.
    endif.

    data lt_lines type string_table.
    field-symbols <i> like line of lt_lines.
    split iv_string_params at ',' into table lt_lines.

    data lv_key type string.
    data lv_val type string.

    loop at lt_lines assigning <i>.
      split <i> at '=' into lv_key lv_val.
      shift lv_key right deleting trailing space.
      shift lv_key left deleting leading space.
      shift lv_val right deleting trailing space.
      shift lv_val left deleting leading space.
      if lv_key is initial.
        lcx_error=>raise( 'Empty key in initialization string is not allowed' ).
        " value can be initial, even a,b,c is ok to create sets
      endif.
      set(
        iv_key = lv_key
        iv_val = lv_val ).
    endloop.

    ro_instance = me.

  endmethod.


  method from_struc.

    data lo_type type ref to cl_abap_typedescr.
    data lo_struc type ref to cl_abap_structdescr.
    field-symbols <c> like line of lo_struc->components.
    field-symbols <val> type any.

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

    ro_instance = me.

  endmethod.


  method get.

    data lv_key type string.
    field-symbols <entry> like line of mt_entries.

    if mv_case_insensitive = abap_true.
      lv_key = to_upper( iv_key ).
    else.
      lv_key = iv_key.
    endif.

    read table mt_entries assigning <entry> with key k = lv_key.
    if sy-subrc = 0.
      rv_val = <entry>-v.
    endif.

  endmethod.


  method has.

    data lv_key type string.

    if mv_case_insensitive = abap_true.
      lv_key = to_upper( iv_key ).
    else.
      lv_key = iv_key.
    endif.

    read table mt_entries transporting no fields with key k = lv_key.
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


  method merge.

    field-symbols <entry> like line of mt_entries.

    loop at io_string_map->mt_entries assigning <entry>.
      set(
        iv_key = <entry>-k
        iv_val = <entry>-v ).
    endloop.

  endmethod.


  method set.

    data ls_entry like line of mt_entries.
    data lv_key type string.
    field-symbols <entry> like line of mt_entries.

    if mv_read_only = abap_true.
      lcx_error=>raise( 'String map is read only' ).
    endif.

    if mv_case_insensitive = abap_true.
      lv_key = to_upper( iv_key ).
    else.
      lv_key = iv_key.
    endif.

    read table mt_entries assigning <entry> with key k = lv_key.
    if sy-subrc = 0.
      <entry>-v = iv_val.
    else.
      ls_entry-k = lv_key.
      ls_entry-v = iv_val.
      insert ls_entry into table mt_entries.
    endif.

    ro_map = me.

  endmethod.


  method size.

    rv_size = lines( mt_entries ).

  endmethod.


  method strict.
    mv_is_strict = iv_strict.
    ro_instance = me.
  endmethod.


  method to_string.

    data lv_size type i.
    field-symbols <entry> like line of mt_entries.

    lv_size = lines( mt_entries ).
    loop at mt_entries assigning <entry>.
      rv_string = rv_string && <entry>-k && '=' && <entry>-v.
      if sy-tabix < lv_size.
        rv_string = rv_string && ','.
      endif.
    endloop.

  endmethod.


  method to_struc.

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
