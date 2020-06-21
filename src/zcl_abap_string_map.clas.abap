class ZCL_ABAP_STRING_MAP definition
  public
  final
  create public .

  public section.

    types:
      begin of ty_entry,
          k type string,
          v type string,
        end of ty_entry .
    types:
      tty_entries type standard table of ty_entry with key k .
    types:
      tts_entries type sorted table of ty_entry with unique key k .

    class-methods create
      returning
        value(ro_instance) type ref to zcl_abap_string_map .
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
    methods delete
      importing
        !iv_key type string .
    methods keys
      returning
        value(rt_keys) type string_table .
    methods values
      returning
        value(rt_values) type string_table .
  protected section.
  private section.
    data mt_entries type tts_entries.

ENDCLASS.



CLASS ZCL_ABAP_STRING_MAP IMPLEMENTATION.


  method create.
    create object ro_instance.
  endmethod.


  method delete.

    delete mt_entries where k = iv_key.

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


  method values.

    field-symbols <entry> like line of mt_entries.
    loop at mt_entries assigning <entry>.
      append <entry>-v to rt_values.
    endloop.

  endmethod.
ENDCLASS.
