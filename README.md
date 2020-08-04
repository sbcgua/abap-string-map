![abaplint](https://github.com/sbcgua/abap-string-map/workflows/abaplint/badge.svg)
![abap package version](https://img.shields.io/endpoint?url=https://shield.abap.space/version-shield-json/github/sbcgua/abap-string-map/src/zcl_abap_string_map.clas.abap)

# Abap string map

String map primitive implementation for abap

- install using [abapGit](https://github.com/larshp/abapGit)
- implements `get`, `set`, `has`, `size`, `is_empty`, `delete`

```abap

data lo_map type ref to zcl_abap_string_map.
lo_map = zcl_abap_string_map=>create( ). " or create object ...

lo_map->set(
  iv_key = 'hello'
  iv_val = 'world' ).
some_var = lo_map->get( 'hello' ).

lo_map->has( 'hello' ) " => abap_true
lo_map->is_empty( )    " => abap_false
lo_map->size( )        " => 1

" Also allows set() chaining
lo_map->set(
  iv_key = 'A'
  iv_val = '1' )->set(
  iv_key = 'B'
  iv_val = '2' ).
```

- implements `keys`, `values`

```abap
data lt_all_keys type string_table.
lt_all_keys = lo_map->keys( ).         " => ( 'hello' )

data(lt_all_vals) = lo_map->values( ). " => ( 'world' )
```

- implements `to_struc`, `from_struc`

```abap
data:
  begin of ls_struc,
    a type string,
    b type abap_bool,
    c type i,
  end of ls_struc.

lo_map->from_struc( ls_struc ). " Converts abap structure to string map
lo_map->to_struc( changing cs_container = ls_struc ). " Converts map to abap structure

" If you have more data entries in the map than fields in the target structure
lo_map->strict( abap_false )->to_struc( changing cs_container = ls_struc ).
" This skips entries which do not have a matching field
```

- implements `from_entries` - this copies entries from a provided param. **Importantly**, the method accepts `any table` but the shape of the record **must** conform to `zcl_abap_string_map=>ty_entry`, namely it **must** have 2 string attributes for key and value respectively

```abap
types:
  begin of ty_my_key_value,
    key type string,
    value type string,
  end of ty_my_key_value.
data lt_entries type table of ty_my_key_value.
lt_entries = value #(
  ( key = 'hello' value 'world' )
  ( key = 'and' value 'another' )
).
lo_map->from_entries( lt_entries ).
```

- may set the map immutable (read only). Guards `set`, `delete`, `clear`, `from_*` methods.

```abap
lo_map->set(
  iv_key = 'A'
  iv_val = '1' )->freeze( ).

lo_map->set(
  iv_key = 'A'
  iv_val = '2' ). " raises cx_no_check
```

For more examples see [unit tests code](https://github.com/sbcgua/abap-string-map/blob/master/src/zcl_abap_string_map.clas.testclasses.abap)


