class ltcl_string_map definition
  for testing
  risk level harmless
  duration short
  final.

  private section.

    types:
      begin of ty_struc,
        a type string,
        b type abap_bool,
        c type i,
      end of ty_struc.

    methods get_set_has for testing.
    methods size_empty_clear for testing.
    methods delete for testing.
    methods keys_values for testing.
    methods to_abap for testing.
    methods from_abap for testing.
    methods strict for testing.
    methods from_to_abap_negative for testing.

endclass.

class ltcl_string_map implementation.

  method get_set_has.

    data lo_cut type ref to zcl_abap_string_map.
    lo_cut = zcl_abap_string_map=>create( ).

    lo_cut->set(
      iv_key = 'A'
      iv_val = 'avalue' ).
    lo_cut->set(
      iv_key = 'B'
      iv_val = 'bvalue' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'avalue'
      act = lo_cut->get( 'A' ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'bvalue'
      act = lo_cut->get( 'B' ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = ''
      act = lo_cut->get( 'C' ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lo_cut->has( 'C' ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lo_cut->has( 'A' ) ).

    lo_cut->set(
      iv_key = 'A'
      iv_val = 'newvalue' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'newvalue'
      act = lo_cut->get( 'A' ) ).

  endmethod.

  method size_empty_clear.

    data lo_cut type ref to zcl_abap_string_map.
    lo_cut = zcl_abap_string_map=>create( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_cut->size( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lo_cut->is_empty( ) ).

    lo_cut->set(
      iv_key = 'A'
      iv_val = 'avalue' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_cut->size( ) ).

    lo_cut->set(
      iv_key = 'B'
      iv_val = 'bvalue' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_cut->size( ) ).

    lo_cut->set(
      iv_key = 'A'
      iv_val = 'newvalue' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_cut->size( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lo_cut->is_empty( ) ).

    lo_cut->clear( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_cut->size( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lo_cut->is_empty( ) ).

  endmethod.

  method delete.

    data lo_cut type ref to zcl_abap_string_map.
    lo_cut = zcl_abap_string_map=>create( ).

    lo_cut->set(
      iv_key = 'A'
      iv_val = 'avalue' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'avalue'
      act = lo_cut->get( 'A' ) ).

    lo_cut->delete( iv_key = 'A' ).

    cl_abap_unit_assert=>assert_equals(
      exp = ''
      act = lo_cut->get( 'A' ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lo_cut->has( 'A' ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_cut->size( ) ).

  endmethod.

  method keys_values.

    data lo_cut type ref to zcl_abap_string_map.
    data lt_exp type string_table.
    lo_cut = zcl_abap_string_map=>create( ).

    lo_cut->set(
      iv_key = 'A'
      iv_val = 'avalue' ).
    lo_cut->set(
      iv_key = 'B'
      iv_val = 'bvalue' ).

    clear lt_exp.
    append 'A' to lt_exp.
    append 'B' to lt_exp.

    cl_abap_unit_assert=>assert_equals(
      exp = lt_exp
      act = lo_cut->keys( ) ).

    clear lt_exp.
    append 'avalue' to lt_exp.
    append 'bvalue' to lt_exp.

    cl_abap_unit_assert=>assert_equals(
      exp = lt_exp
      act = lo_cut->values( ) ).

  endmethod.

  method to_abap.

    data ls_struc_act type ty_struc.
    data ls_struc_exp type ty_struc.
    data lo_cut type ref to zcl_abap_string_map.
    lo_cut = zcl_abap_string_map=>create( ).

    lo_cut->set(
      iv_key = 'a'
      iv_val = 'avalue' ).
    lo_cut->set(
      iv_key = 'b'
      iv_val = 'X' ).
    lo_cut->set(
      iv_key = 'c'
      iv_val = '123' ).

    lo_cut->to_abap( changing cs_container = ls_struc_act ).

    ls_struc_exp-a = 'avalue'.
    ls_struc_exp-b = abap_true.
    ls_struc_exp-c = 123.

    cl_abap_unit_assert=>assert_equals(
      exp = ls_struc_exp
      act = ls_struc_act ).

  endmethod.

  method from_abap.

    data ls_struc type ty_struc.
    data lo_cut type ref to zcl_abap_string_map.
    lo_cut = zcl_abap_string_map=>create( ).

    ls_struc-a = 'avalue'.
    ls_struc-b = abap_true.
    ls_struc-c = 123.

    lo_cut->set(
      iv_key = 'z'
      iv_val = 'xyz' ).

    lo_cut->from_abap( ls_struc ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lo_cut->size( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'avalue'
      act = lo_cut->get( 'A' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'X'
      act = lo_cut->get( 'B' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '123'
      act = lo_cut->get( 'C' ) ).

  endmethod.

  method strict.

    data ls_struc_act type ty_struc.
    data ls_struc_exp type ty_struc.
    data lx type ref to cx_root.
    data lo_cut type ref to zcl_abap_string_map.
    lo_cut = zcl_abap_string_map=>create( ).

    lo_cut->set(
      iv_key = 'a'
      iv_val = 'avalue' ).
    lo_cut->set(
      iv_key = 'b'
      iv_val = 'X' ).
    lo_cut->set(
      iv_key = 'c'
      iv_val = '123' ).
    lo_cut->set(
      iv_key = 'z'
      iv_val = 'xyz' ).

    ls_struc_exp-a = 'avalue'.
    ls_struc_exp-b = abap_true.
    ls_struc_exp-c = 123.

    try.
      lo_cut->to_abap( changing cs_container = ls_struc_act ).
      cl_abap_unit_assert=>fail( ).
    catch cx_root into lx.
      cl_abap_unit_assert=>assert_equals(
        exp = 'Component Z not found in target'
        act = lx->get_text( ) ).
    endtry.

    lo_cut->strict( abap_false )->to_abap( changing cs_container = ls_struc_act ).

    cl_abap_unit_assert=>assert_equals(
      exp = ls_struc_exp
      act = ls_struc_act ).

  endmethod.

  method from_to_abap_negative.

    data lt_dummy type string_table.
    data lx type ref to cx_root.
    data lo_cut type ref to zcl_abap_string_map.
    lo_cut = zcl_abap_string_map=>create( ).

    try.
      lo_cut->from_abap( lt_dummy ).
      cl_abap_unit_assert=>fail( ).
    catch cx_root into lx.
      cl_abap_unit_assert=>assert_equals(
        exp = 'Only structures supported'
        act = lx->get_text( ) ).
    endtry.

    try.
      lo_cut->to_abap( changing cs_container = lt_dummy ).
      cl_abap_unit_assert=>fail( ).
    catch cx_root into lx.
      cl_abap_unit_assert=>assert_equals(
        exp = 'Only structures supported'
        act = lx->get_text( ) ).
    endtry.

  endmethod.

endclass.
