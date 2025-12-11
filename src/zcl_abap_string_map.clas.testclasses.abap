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
    methods case_insensitive for testing.
    methods set_clike for testing.
    methods setx for testing.

    methods strict for testing.
    methods freeze for testing.

    methods from_struc for testing.
    methods from_to_struc_negative for testing.
    methods from_entries for testing.
    methods from_string for testing.
    methods from_map for testing.
    methods merge for testing.

    methods to_struc for testing.
    methods to_string for testing.
    methods to_entries for testing.

    methods create_from for testing.
    methods case_insensitive_create for testing.
    methods list_mode for testing.

endclass.

class ltcl_string_map implementation.

  method create_from.

    data lx_e type ref to cx_root.
    data lo_src type ref to zcl_abap_string_map.
    data lo_cut type ref to zcl_abap_string_map.
    data: begin of ls_dummy, a type string value '1', end of ls_dummy.

    lo_src = zcl_abap_string_map=>create( ).
    lo_src->set(
      iv_key = 'A'
      iv_val = '1' ).

    try.
      zcl_abap_string_map=>create( iv_from = 12345 ).
      cl_abap_unit_assert=>fail( ).
    catch cx_root into lx_e.
      cl_abap_unit_assert=>assert_equals(
        exp = 'Incorrect input for string_map=>create, typekind I'
        act = lx_e->get_text( ) ).
    endtry.

    try.
      zcl_abap_string_map=>create( iv_from = me ).
      cl_abap_unit_assert=>fail( ).
    catch cx_root into lx_e.
      cl_abap_unit_assert=>assert_equals(
        exp = 'Incorrect string map instance to copy from'
        act = lx_e->get_text( ) ).
    endtry.

    " From obj
    lo_cut = zcl_abap_string_map=>create( iv_from = lo_src ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_cut->size( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1'
      act = lo_cut->get( 'A' ) ).

    " From tab
    lo_cut = zcl_abap_string_map=>create( iv_from = lo_src->mt_entries ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_cut->size( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1'
      act = lo_cut->get( 'A' ) ).

    " From struc
    lo_cut = zcl_abap_string_map=>create( iv_from = ls_dummy ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_cut->size( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1'
      act = lo_cut->get( 'A' ) ).

    " From string
    lo_cut = zcl_abap_string_map=>create( iv_from = 'x=y' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->size( )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get( 'x' )
      exp = 'y' ).

    " From another map
    lo_cut = zcl_abap_string_map=>create( iv_from = zcl_abap_string_map=>create( iv_from = 'x=1' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->size( )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get( 'x' )
      exp = '1' ).

  endmethod.

  method freeze.

    data lt_entries type zcl_abap_string_map=>tty_entries.
    data ls_dummy type syst.
    data lx_e type ref to cx_root.
    data lo_cut type ref to zcl_abap_string_map.
    field-symbols <l> like line of lt_entries.

    lo_cut = zcl_abap_string_map=>create( ).

    lo_cut->set(
      iv_key = 'A'
      iv_val = 'avalue' )->freeze( ).

    try.
      lo_cut->set(
        iv_key = 'A'
        iv_val = '2' ).
      cl_abap_unit_assert=>fail( ).
    catch cx_root into lx_e.
      cl_abap_unit_assert=>assert_equals(
        exp = 'String map is read only'
        act = lx_e->get_text( ) ).
    endtry.

    try.
      lo_cut->set(
        iv_key = 'B'
        iv_val = '2' ).
      cl_abap_unit_assert=>fail( ).
    catch cx_root into lx_e.
      cl_abap_unit_assert=>assert_equals(
        exp = 'String map is read only'
        act = lx_e->get_text( ) ).
    endtry.

    try.
      lo_cut->delete( 'A' ).
      cl_abap_unit_assert=>fail( ).
    catch cx_root into lx_e.
      cl_abap_unit_assert=>assert_equals(
        exp = 'String map is read only'
        act = lx_e->get_text( ) ).
    endtry.

    try.
      lo_cut->clear( ).
      cl_abap_unit_assert=>fail( ).
    catch cx_root into lx_e.
      cl_abap_unit_assert=>assert_equals(
        exp = 'String map is read only'
        act = lx_e->get_text( ) ).
    endtry.

    try.

      append initial line to lt_entries assigning <l>.
      <l>-k = 'a'.
      lo_cut->from_entries( lt_entries ).
      cl_abap_unit_assert=>fail( ).
    catch cx_root into lx_e.
      cl_abap_unit_assert=>assert_equals(
        exp = 'String map is read only'
        act = lx_e->get_text( ) ).
    endtry.

    try.
      lo_cut->from_struc( ls_dummy ).
      cl_abap_unit_assert=>fail( ).
    catch cx_root into lx_e.
      cl_abap_unit_assert=>assert_equals(
        exp = 'String map is read only'
        act = lx_e->get_text( ) ).
    endtry.

    try.
      lo_cut->from_string( 'x=y' ).
      cl_abap_unit_assert=>fail( ).
    catch cx_root into lx_e.
      cl_abap_unit_assert=>assert_equals(
        exp = 'String map is read only'
        act = lx_e->get_text( ) ).
    endtry.

    try.
      lo_cut->from_map( zcl_abap_string_map=>create( iv_from = 'x=y' ) ).
      cl_abap_unit_assert=>fail( ).
    catch cx_root into lx_e.
      cl_abap_unit_assert=>assert_equals(
        exp = 'String map is read only'
        act = lx_e->get_text( ) ).
    endtry.

  endmethod.

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

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lo_cut->has( 'a' ) ). " case sensitive

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

  method to_struc.

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

    lo_cut->to_struc( changing cs_container = ls_struc_act ).

    ls_struc_exp-a = 'avalue'.
    ls_struc_exp-b = abap_true.
    ls_struc_exp-c = 123.

    cl_abap_unit_assert=>assert_equals(
      exp = ls_struc_exp
      act = ls_struc_act ).

  endmethod.

  method from_struc.

    data ls_struc type ty_struc.
    data lo_cut type ref to zcl_abap_string_map.
    lo_cut = zcl_abap_string_map=>create( ).

    ls_struc-a = 'avalue'.
    ls_struc-b = abap_true.
    ls_struc-c = 123.

    lo_cut->set(
      iv_key = 'z'
      iv_val = 'xyz' ).

    lo_cut = lo_cut->from_struc( ls_struc ).

    cl_abap_unit_assert=>assert_equals(
      exp = 4
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
    cl_abap_unit_assert=>assert_equals(
      exp = 'xyz'
      act = lo_cut->get( 'z' ) ).

  endmethod.

  method strict.

    data ls_struc_act type ty_struc.
    data ls_struc_exp type ty_struc.
    data lx_e type ref to cx_root.
    data lo_struc type ref to zcl_abap_string_map.
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
      lo_cut->to_struc( changing cs_container = ls_struc_act ).
      cl_abap_unit_assert=>fail( ).
    catch cx_root into lx_e.
      cl_abap_unit_assert=>assert_equals(
        exp = 'Component Z not found in target'
        act = lx_e->get_text( ) ).
    endtry.

    lo_struc = lo_cut->strict( abap_false ).
    lo_struc->to_struc( changing cs_container = ls_struc_act ).

    cl_abap_unit_assert=>assert_equals(
      exp = ls_struc_exp
      act = ls_struc_act ).

  endmethod.

  method from_to_struc_negative.

    data lt_dummy type string_table.
    data lx_e type ref to cx_root.
    data lo_cut type ref to zcl_abap_string_map.
    lo_cut = zcl_abap_string_map=>create( ).

    try.
      lo_cut->from_struc( lt_dummy ).
      cl_abap_unit_assert=>fail( ).
    catch cx_root into lx_e.
      cl_abap_unit_assert=>assert_equals(
        exp = 'Only structures supported'
        act = lx_e->get_text( ) ).
    endtry.

    try.
      lo_cut->to_struc( changing cs_container = lt_dummy ).
      cl_abap_unit_assert=>fail( ).
    catch cx_root into lx_e.
      cl_abap_unit_assert=>assert_equals(
        exp = 'Only structures supported'
        act = lx_e->get_text( ) ).
    endtry.

  endmethod.

  method from_entries.

    types:
      begin of ty_pair,
        key type string,
        val type string,
      end of ty_pair.

    data lt_entries type table of ty_pair.
    data ls_entry like line of lt_entries.
    data lo_cut type ref to zcl_abap_string_map.
    lo_cut = zcl_abap_string_map=>create( ).

    ls_entry-key = 'A'.
    ls_entry-val = 'avalue'.
    append ls_entry to lt_entries.

    ls_entry-key = 'B'.
    ls_entry-val = '123'.
    append ls_entry to lt_entries.

    lo_cut->set(
      iv_key = 'z'
      iv_val = 'xyz' ).

    lo_cut = lo_cut->from_entries( lt_entries ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lo_cut->size( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'avalue'
      act = lo_cut->get( 'A' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '123'
      act = lo_cut->get( 'B' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'xyz'
      act = lo_cut->get( 'z' ) ).

  endmethod.

  method case_insensitive.

    data lt_exp_keys type string_table.
    data lo_cut type ref to zcl_abap_string_map.
    lo_cut = zcl_abap_string_map=>create( iv_case_insensitive = abap_true ).

    lo_cut->set(
      iv_key = 'A'
      iv_val = 'avalue' ).
    lo_cut->set(
      iv_key = 'b'
      iv_val = 'bvalue' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'avalue'
      act = lo_cut->get( 'A' ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'avalue'
      act = lo_cut->get( 'a' ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'bvalue'
      act = lo_cut->get( 'B' ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'bvalue'
      act = lo_cut->get( 'b' ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lo_cut->has( 'A' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lo_cut->has( 'a' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lo_cut->has( 'B' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lo_cut->has( 'b' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lo_cut->has( 'c' ) ).

    append 'A' to lt_exp_keys.
    append 'B' to lt_exp_keys.

    cl_abap_unit_assert=>assert_equals(
      exp = lt_exp_keys
      act = lo_cut->keys( ) ).

    lo_cut->delete( 'a' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_cut->size( ) ).

    lo_cut->delete( 'B' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_cut->size( ) ).

  endmethod.

  method case_insensitive_create.

    data lo_src type ref to zcl_abap_string_map.
    data lo_cut type ref to zcl_abap_string_map.

    lo_src = zcl_abap_string_map=>create( ).
    lo_src->set(
      iv_key = 'A'
      iv_val = '1' ).
    lo_src->set(
      iv_key = 'b'
      iv_val = '2' ).
    lo_src->freeze( ).

    lo_cut = zcl_abap_string_map=>create(
      iv_from             = lo_src
      iv_case_insensitive = abap_true ).

    data lt_exp_keys type string_table.
    append 'A' to lt_exp_keys.
    append 'B' to lt_exp_keys.

    cl_abap_unit_assert=>assert_equals(
      exp = lt_exp_keys
      act = lo_cut->keys( ) ).

  endmethod.

  method set_clike.

    data lv_char type c length 10.
    data lv_numc type n length 4.
    data lo_cut type ref to zcl_abap_string_map.
    lo_cut = zcl_abap_string_map=>create( ).

    lo_cut->set(
      iv_key = 'A'
      iv_val = 'avalue' ).
    lo_cut->set(
      iv_key = `B`
      iv_val = `bvalue` ).

    lv_char = 'C'.
    lo_cut->set(
      iv_key = lv_char
      iv_val = lv_char ).

    lv_numc = '123'.
    lo_cut->set(
      iv_key = lv_numc
      iv_val = lv_numc ).

    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lo_cut->size( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'C'
      act = lo_cut->get( 'C' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0123'
      act = lo_cut->get( '0123' ) ).

  endmethod.

  method from_string.

    data lx_e type ref to lcx_error.
    data lo_cut type ref to zcl_abap_string_map.
    lo_cut = zcl_abap_string_map=>create( ).

    lo_cut->set(
      iv_key = 'z'
      iv_val = 'xyz' ).

    lo_cut = lo_cut->from_string( 'a = avalue, b = some data, c = space   space' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->size( )
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get( 'a' )
      exp = 'avalue' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get( 'b' )
      exp = 'some data' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get( 'c' )
      exp = 'space   space' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get( 'z' )
      exp = 'xyz' ).

    try.
      lo_cut->from_string( `x=y,  ` ).
    catch lcx_error into lx_e.
      cl_abap_unit_assert=>assert_char_cp(
        act = lx_e->get_text( )
        exp = 'Empty key*' ).
    endtry.

  endmethod.

  method to_string.

    data lo_cut type ref to zcl_abap_string_map.
    lo_cut = zcl_abap_string_map=>create( ).

    lo_cut->from_string( 'a = avalue, b = some data, c = space   space' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->to_string( )
      exp = 'a=avalue,b=some data,c=space   space' ).

  endmethod.

  method from_map.

    data lo_src type ref to zcl_abap_string_map.
    data lo_cut type ref to zcl_abap_string_map.

    lo_src = zcl_abap_string_map=>create( ).
    lo_src->set(
      iv_key = 'a'
      iv_val = '1' ).
    lo_src->set(
      iv_key = 'b'
      iv_val = '2' ).
    lo_src->freeze( ).

    " Empty map
    lo_cut = zcl_abap_string_map=>create( ).
    lo_cut = lo_cut->from_map( lo_src ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->size( )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get( 'a' )
      exp = '1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get( 'b' )
      exp = '2' ).

    " Existing values + overwrite
    lo_cut = zcl_abap_string_map=>create( ).
    lo_cut->set(
      iv_key = 'a'
      iv_val = 'x' ).
    lo_cut->set(
      iv_key = 'c'
      iv_val = '3' ).

    lo_cut->from_map( lo_src ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->size( )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get( 'a' )
      exp = '1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get( 'b' )
      exp = '2' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get( 'c' )
      exp = '3' ).

  endmethod.

  method merge.

    data lo_src type ref to zcl_abap_string_map.
    data lo_cut type ref to zcl_abap_string_map.

    lo_cut = zcl_abap_string_map=>create( ).
    lo_cut->set(
      iv_key = 'a'
      iv_val = '1' ).
    lo_cut->set(
      iv_key = 'b'
      iv_val = '2' ).

    lo_src = zcl_abap_string_map=>create( ).
    lo_src->set(
      iv_key = 'b'
      iv_val = '20' ).
    lo_src->set(
      iv_key = 'c'
      iv_val = '30' ).

    lo_cut->merge( lo_src ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->size( )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get( 'a' )
      exp = '1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get( 'b' )
      exp = '20' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get( 'c' )
      exp = '30' ).

    " Case 2
    lo_cut = zcl_abap_string_map=>create( iv_case_insensitive = abap_true ).
    lo_cut->set(
      iv_key = 'a'
      iv_val = '1' ).
    lo_cut->set(
      iv_key = 'b'
      iv_val = '2' ).

    lo_src = zcl_abap_string_map=>create( ).
    lo_src->set(
      iv_key = 'B'
      iv_val = '200' ).
    lo_src->set(
      iv_key = 'D'
      iv_val = '400' ).

    lo_cut->merge( lo_src ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->size( )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get( 'a' )
      exp = '1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get( 'b' )
      exp = '200' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get( 'd' )
      exp = '400' ).

  endmethod.


  method to_entries.

    types:
      begin of lty_str,
        a type string,
        b type string,
      end of lty_str,
      lty_str_t type standard table of lty_str,
      begin of lty_char,
        a type c length 10,
        b type c length 10,
      end of lty_char,
      lty_char_t type standard table of lty_char,
      begin of lty_bad1,
        a type c length 10,
      end of lty_bad1,
      lty_bad1_t type standard table of lty_bad1,
      begin of lty_bad2,
        a type i,
        b type i,
      end of lty_bad2,
      lty_bad2_t type standard table of lty_bad2.

    data lo_cut type ref to zcl_abap_string_map.
    lo_cut = zcl_abap_string_map=>create( `x=1,y=2` ).

    data lt_str_act type lty_str_t.
    data lt_str_exp type lty_str_t.
    data ls_str like line of lt_str_act.
    data lt_char_act type lty_char_t.
    data lt_char_exp type lty_char_t.
    data ls_char like line of lt_char_act.

    ls_str-a = 'x'.
    ls_str-b = '1'.
    append ls_str to lt_str_exp.
    ls_str-a = 'y'.
    ls_str-b = '2'.
    append ls_str to lt_str_exp.
    lo_cut->to_entries( changing ct_entries = lt_str_act ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_str_act
      exp = lt_str_exp ).

    ls_char-a = 'x'.
    ls_char-b = '1'.
    append ls_char to lt_char_exp.
    ls_char-a = 'y'.
    ls_char-b = '2'.
    append ls_char to lt_char_exp.
    lo_cut->to_entries( changing ct_entries = lt_char_act ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_char_act
      exp = lt_char_exp ).

    data lx type ref to lcx_error.
    data lt_bad1 type lty_bad1_t.
    try.
      lo_cut->to_entries( changing ct_entries = lt_bad1 ).
      cl_abap_unit_assert=>fail( ).
    catch lcx_error into lx.
      cl_abap_unit_assert=>assert_char_cp(
        act = lx->get_text( )
        exp = '*number*' ).
    endtry.

    data lt_bad2 type lty_bad2_t.
    try.
      lo_cut->to_entries( changing ct_entries = lt_bad2 ).
      cl_abap_unit_assert=>fail( ).
    catch lcx_error into lx.
      cl_abap_unit_assert=>assert_char_cp(
        act = lx->get_text( )
        exp = '*type*' ).
    endtry.

    data lt_bad3 type string_table.
    try.
      lo_cut->to_entries( changing ct_entries = lt_bad3 ).
      cl_abap_unit_assert=>fail( ).
    catch lcx_error into lx.
      cl_abap_unit_assert=>assert_char_cp(
        act = lx->get_text( )
        exp = '*table line*' ).
    endtry.

  endmethod.

  method setx.

    data lo_cut type ref to zcl_abap_string_map.

    lo_cut = zcl_abap_string_map=>create( ).

    lo_cut->setx( 'a:1' ).
    lo_cut->setx( |b : 2| ).
    lo_cut->setx( ':c' ).
    lo_cut->setx( '' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_cut->size( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = lo_cut->get( 'a' )
      act = '1' ).
    cl_abap_unit_assert=>assert_equals(
      exp = lo_cut->get( 'b' )
      act = '2' ).

  endmethod.

  method list_mode.

    data lo_cut type ref to zcl_abap_string_map.

    lo_cut = zcl_abap_string_map=>create( ).
    lo_cut->setx( 'a:1' ).
    lo_cut->setx( 'a:2' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_cut->size( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = lo_cut->get( 'a' )
      act = '2' ).

    lo_cut = zcl_abap_string_map=>create( iv_list_mode = abap_true ).
    lo_cut->setx( 'a:1' ).
    lo_cut->setx( 'a:2' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_cut->size( ) ).

    data lt_entries type zcl_abap_string_map=>tty_entries.
    data ls_item like line of lt_entries.
    lt_entries = lo_cut->mt_entries.
    sort lt_entries by k v.

    read table lt_entries index 1 into ls_item.
    cl_abap_unit_assert=>assert_equals(
      exp = '1'
      act = ls_item-v ).

    read table lt_entries index 2 into ls_item.
    cl_abap_unit_assert=>assert_equals(
      exp = '2'
      act = ls_item-v ).

    lo_cut->delete( 'a' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_cut->size( ) ).

  endmethod.


endclass.
