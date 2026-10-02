class ltcl_string_set definition
  for testing
  risk level harmless
  duration short
  final.

  private section.
    methods add_delete_has_size for testing.
    methods clike_values for testing.
    methods string_range for testing.
    methods integer_range for testing.
    methods conversion_error for testing.
    methods invalid_ranges for testing.
    methods assert_invalid_range
      changing ct_range type standard table.
endclass.

class ltcl_string_set implementation.

  method add_delete_has_size.
    data lo_set type ref to zcl_abap_string_set.
    lo_set = zcl_abap_string_set=>create( ).
    cl_abap_unit_assert=>assert_equals( act = lo_set->size( )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lo_set->has( 'missing' )
      exp = abap_false ).
    lo_set->add( 'b' )->add( 'a' )->add( 'a' )->add( 'A' )->add( '' ).
    cl_abap_unit_assert=>assert_equals( act = lo_set->size( )
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = lo_set->has( 'a' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lo_set->has( '' )
      exp = abap_true ).
    lo_set->delete( 'missing' ).
    lo_set->delete( 'a' ).
    lo_set->delete( 'a' ).
    cl_abap_unit_assert=>assert_equals( act = lo_set->size( )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lo_set->has( 'a' )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = lo_set->has( 'A' )
      exp = abap_true ).
    lo_set->delete( '' ).
    cl_abap_unit_assert=>assert_equals( act = lo_set->has( '' )
      exp = abap_false ).
  endmethod.

  method clike_values.
    data lo_set type ref to zcl_abap_string_set.
    data lv_char type c length 5 value 'abc'.
    data lv_numc type n length 3 value '012'.
    lo_set = zcl_abap_string_set=>create( ).
    lo_set->add( lv_char )->add( 'abc' )->add( lv_numc ).
    cl_abap_unit_assert=>assert_equals( act = lo_set->size( )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lo_set->has( lv_char )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lo_set->has( '012' )
      exp = abap_true ).
    lo_set->delete( lv_numc ).
    cl_abap_unit_assert=>assert_equals( act = lo_set->size( )
      exp = 1 ).
  endmethod.

  method string_range.
    data lo_set type ref to zcl_abap_string_set.
    data lt_range type range of string.
    data lt_expected like lt_range.
    data ls_row like line of lt_range.
    lo_set = zcl_abap_string_set=>create( ).
    ls_row-sign = 'E'.
    ls_row-option = 'EQ'.
    ls_row-low = 'existing'.
    append ls_row to lt_range.
    append ls_row to lt_expected.
    lo_set->to_range( changing ct_range = lt_range ).
    cl_abap_unit_assert=>assert_equals( act = lt_range
      exp = lt_expected ).
    lo_set->add( 'b' )->add( 'a' )->add( 'a' )->add( '' ).
    clear ls_row.
    ls_row-sign = 'I'.
    ls_row-option = 'EQ'.
    append ls_row to lt_expected.
    ls_row-low = 'a'.
    append ls_row to lt_expected.
    ls_row-low = 'b'.
    append ls_row to lt_expected.
    lo_set->to_range( changing ct_range = lt_range ).
    cl_abap_unit_assert=>assert_equals( act = lt_range
      exp = lt_expected ).
  endmethod.

  method integer_range.
    data lo_set type ref to zcl_abap_string_set.
    data lt_range type range of i.
    data lt_expected like lt_range.
    data ls_row like line of lt_range.
    lo_set = zcl_abap_string_set=>create( ).
    lo_set->add( '20' )->add( '-1' ).
    ls_row-sign = 'I'.
    ls_row-option = 'EQ'.
    ls_row-low = -1.
    append ls_row to lt_expected.
    ls_row-low = 20.
    append ls_row to lt_expected.
    lo_set->to_range( changing ct_range = lt_range ).
    cl_abap_unit_assert=>assert_equals( act = lt_range
      exp = lt_expected ).
  endmethod.

  method conversion_error.
    data lo_set type ref to zcl_abap_string_set.
    data lt_range type range of i.
    data lt_expected like lt_range.
    data ls_row like line of lt_range.
    data lx_error type ref to cx_no_check.
    lo_set = zcl_abap_string_set=>create( ).
    lo_set->add( '1' )->add( 'bad' ).
    ls_row-sign = 'I'.
    ls_row-option = 'EQ'.
    ls_row-low = 7.
    append ls_row to lt_range.
    lt_expected = lt_range.
    try.
      lo_set->to_range( changing ct_range = lt_range ).
      cl_abap_unit_assert=>fail( ).
    catch cx_no_check into lx_error.
      cl_abap_unit_assert=>assert_char_cp( act = lx_error->get_text( )
      exp = '*Cannot convert set value*' ).
    endtry.
    cl_abap_unit_assert=>assert_equals( act = lt_range
      exp = lt_expected ).
  endmethod.

  method invalid_ranges.
    types:
      begin of ty_wrong_names,
        sign type c length 1,
        option type c length 2,
        wrong type string,
        high type string,
      end of ty_wrong_names,
      begin of ty_short_option,
        sign type c length 1,
        option type c length 1,
        low type string,
        high type string,
      end of ty_short_option,
      begin of ty_deep_low,
        sign type c length 1,
        option type c length 2,
        low type string_table,
        high type string_table,
      end of ty_deep_low.
    data lt_scalar type string_table.
    data lt_wrong_names type standard table of ty_wrong_names.
    data lt_short_option type standard table of ty_short_option.
    data lt_deep_low type standard table of ty_deep_low.
    data lt_map_entries type zcl_abap_string_map=>tty_entries.
    assert_invalid_range( changing ct_range = lt_scalar ).
    assert_invalid_range( changing ct_range = lt_wrong_names ).
    assert_invalid_range( changing ct_range = lt_short_option ).
    assert_invalid_range( changing ct_range = lt_deep_low ).
    assert_invalid_range( changing ct_range = lt_map_entries ).
  endmethod.

  method assert_invalid_range.
    data lo_set type ref to zcl_abap_string_set.
    data lr_original type ref to data.
    field-symbols <original> type standard table.
    create data lr_original like ct_range.
    assign lr_original->* to <original>.
    <original> = ct_range.
    lo_set = zcl_abap_string_set=>create( ).
    lo_set->add( 'a' ).
    try.
      lo_set->to_range( changing ct_range = ct_range ).
      cl_abap_unit_assert=>fail( 'Invalid range must be rejected' ).
    catch lcx_error.
    endtry.
    cl_abap_unit_assert=>assert_equals( act = ct_range
      exp = <original> ).
  endmethod.

endclass.
