# Abap string map

String map primitive implementation for abap

- install using [abapGit](https://github.com/larshp/abapGit)
- implements `get`, `set`, `has`, `size`, `delete`, `keys`, `values`, see [unit tests code](https://github.com/sbcgua/abap-string-map/blob/master/src/zcl_abap_string_map.clas.testclasses.abap) for example
- also implements `to_abap`, `from_abap`

```abap
data:
  begin of ls_struc,
    a type string,
    b type abap_bool,
    c type i,
  end of ls_struc.

lo_map->from_abap( ls_struc ). " Converts abap structure to string map
lo_map->to_abap( changing cs_container = ls_struc ). " Converts map to abap structure

" If you have more data entries in the map than fields in the target structure
lo_map->strict( abap_false )->to_abap( changing cs_container = ls_struc ).
" This skips entries which do not have a matching field
```
