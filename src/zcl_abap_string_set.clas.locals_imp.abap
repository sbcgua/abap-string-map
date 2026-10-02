class lcx_error definition final inheriting from cx_no_check.
  public section.

    interfaces if_t100_message.
    constants:
      begin of c_error_signature,
        msgid type symsgid value 'SY',
        msgno type symsgno value '002', " &
        attr1 type scx_attrname value 'MSG',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of c_error_signature.
    data msg type string read-only.

    class-methods raise
      importing
        iv_msg type string.
  private section.
endclass.

class lcx_error implementation.
  method raise.
    data lx_e type ref to lcx_error.
    create object lx_e.
    lx_e->msg = iv_msg.
    lx_e->if_t100_message~t100key = c_error_signature.
    raise exception lx_e.
  endmethod.
endclass.
