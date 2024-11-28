<!-- markdownlint-disable MD041 -->
![abaplint](https://github.com/sbcgua/abap-string-map/workflows/abaplint/badge.svg)
![abap package version](https://img.shields.io/endpoint?url=https://shield.abap.space/version-shield-json/github/sbcgua/abap-string-map/src/zcl_abap_string_map.clas.abap)

# ABAP string map

String map primitive implementation for abap

- install it using [abapGit](https://github.com/larshp/abapGit)
- errors, if happen, are raised via `cx_no_check` (with get_text)
- implements `get`, `set`, `has`, `size`, `is_empty`, `delete`, `clear`
- also convenience features to create map *from string, table or structure (key/value)*

```abap
data lo_map type ref to zcl_abap_string_map.
lo_map = zcl_abap_string_map=>create( ). " or create object ...

" Key and value can be a string or of C or N types (so `clike`)
lo_map->set(
  iv_key = 'hello'
  iv_val = 'world' ).
some_var = lo_map->get( 'hello' ). " => 'world'

lo_map->has( 'hello' ). " => abap_true
lo_map->is_empty( ).    " => abap_false
lo_map->size( ).        " => 1
lo_map->delete( 'hello' ).
lo_map->clear( ).
```

- `set` allows chaining

```abap
lo_map->set(
  iv_key = 'A'
  iv_val = '1' 
)->set(
  iv_key = 'B'
  iv_val = '2' ).
```

- there is also `setx` - a more readable yet not so strict version of `set`. Can be useful for multiple sets in a raw.

```abap
lo_map->setx( 'A:1' )->setx( |B : { '2' }| ).
```

- implements `keys`, `values`

```abap
data lt_all_keys type string_table.
data lt_all_vals type string_table.

lt_all_keys = lo_map->keys( ).   " => ( 'hello' )
lt_all_vals = lo_map->values( ). " => ( 'world' )
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
" use strict( false ) - this skips entries which do not have a matching field
lo_map->strict( abap_false )->to_struc( changing cs_container = ls_struc ).
```

- implements `from_entries` - this copies entries from a provided param. **Importantly**, the method accepts `any table` but the shape of the record **must** conform to `zcl_abap_string_map=>ty_entry`, namely it **must** have 2 string attributes for key and value respectively (see the code of `from_entries` for clarification)

```abap
types:
  begin of ty_my_key_value,
    key type string,
    value type string,
  end of ty_my_key_value.

data lt_entries type table of ty_my_key_value.
lt_entries = value #(
  ( key = 'hello' value = 'world' )
  ( key = 'and' value = 'another' )
).
lo_map->from_entries( lt_entries ).
```

- implements `to_entries` - the opposite to `from_entries`, saves data to a table with 2 char-like components

```abap
types:
  begin of ty_my_key_value,
    a type string,
    b type c length 10,
  end of ty_my_key_value.

data lt_entries type table of ty_my_key_value.
lo_map->to_entries( changing ct_entries = lt_entries ).
```

- implements `from_string` - this parses string of pairs like `a = b, x = y` into map. Spaces are condensed. `to_string` renders in string representation (careful with case insensitive - keys will be upper-cased).

```abap
lo_map->from_string( 'a = b, x = y' ).
lo_map->get( 'a' ). " => 'b'
lo_map->to_string( ). " => 'a=b,x=y'
```

- implements `from_map` - copies another map object (respecting destination case sensitivity)

```abap
lo_map->from_map( lo_another_map ).
```

- `from_*` methods allow chaining. They all *add* values to the map, existing values with the same name are overwritten.

```abap
lo_map->from_map( lo_another_map )->from_struc( ls_struc )->set( iv_key = 'x' iv_val = '1' ).
```

- `create` also supports immediate initiation from another instance of string map, a structure (same as running `from_struc` after) or a table (same as running `from_entries` after)

```abap
lo_copy = zcl_abap_string_map=>create( lo_map ).
lo_copy = zcl_abap_string_map=>create( ls_struc ).   " see examples above
lo_copy = zcl_abap_string_map=>create( lt_entries ). " see examples above
lo_copy = zcl_abap_string_map=>create( 'a=b, x=y' ). " see examples above
```

- you may set the map **immutable** (read only). Guards `set`, `delete`, `clear`, `from_*` methods.

```abap
lo_map->set(
  iv_key = 'A'
  iv_val = '1' )->freeze( ).

lo_map->set(
  iv_key = 'A'
  iv_val = '2' ). " raises cx_no_check
```

- you may switch the map into "list" mode - this way there is no guarantee for the record uniqueness, but can be useful for some applications.

```abap
  lo = zcl_abap_string_map=>create( iv_list_mode = abap_false ).
```

For more examples see [unit tests code](https://github.com/sbcgua/abap-string-map/blob/master/src/zcl_abap_string_map.clas.testclasses.abap)

## Blog posts

- [Bicycles: String map](https://blogs.sap.com/2020/08/04/bicycles.-1-string-map)
