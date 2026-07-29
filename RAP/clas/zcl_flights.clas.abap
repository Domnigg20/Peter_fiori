CLASS zcl_flights DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.


 INTERFACES if_oo_adt_classrun .


METHODS get_output
RETURNING VALUE(rv_output) TYPE string_table.

"Constructor definition

METHODS load_flight
  IMPORTING
    i_carrier_id    TYPE /dmo/carrier_id
    i_connection_id TYPE /dmo/connection_id
  RAISING
    cx_abap_invalid_value.






  PROTECTED SECTION.
  PRIVATE SECTION.


    DATA carrier_id    TYPE /dmo/carrier_id.
    DATA connection_id TYPE /dmo/connection_id.
    DATA airport_from_id TYPE /dmo/airport_from_id.
    DATA airport_to_id   TYPE /dmo/airport_to_id.


ENDCLASS.



CLASS zcl_flights IMPLEMENTATION.


METHOD if_oo_adt_classrun~main.

" --- LOCAL DECLARATIONS FOR EXAMPLES ---
    " These are needed because 'main' cannot see the PRIVATE attributes directly
    DATA airport_from_id TYPE /dmo/airport_from_id.
    DATA airport_to_id   TYPE /dmo/airport_to_id.

  TRY.
      " We don't need local DATA declarations anymore!
      " The 'NEW' statement handles the work.


      DATA(lo_flight) = NEW zcl_flights( ).

      lo_flight->load_flight(
                          i_carrier_id    = 'LH'
                          i_connection_id = '0400'
                        ).

      " This calls the method that uses the PRIVATE attributes
      out->write( lo_flight->get_output( ) ).

    CATCH cx_abap_invalid_value.
      out->write( `Check your Flight IDs!` ).
  ENDTRY.



" The @DATA(lt_airports) creates the table automatically
SELECT  FROM /dmo/airport
  FIELDS airport_id, name
  INTO TABLE @DATA(lt_airports).

out->write( lt_airports ).

* Example 1: Single field from Single Record
**********************************************************************
    SELECT SINGLE
      FROM /dmo/connection
      FIELDS airport_from_id
      WHERE carrier_id    = 'LH'
        AND connection_id = '0400'
        INTO @airport_from_id.

    out->write( `----------`  ).
    out->write( `Example 1:`  ).

    out->write( |Flight LH 400 departs from {  airport_from_id }.| ).

* Example 2: Multiple Fields from Single Record
**********************************************************************
    SELECT SINGLE
      FROM /dmo/connection
      FIELDS airport_from_id, airport_to_id
      WHERE carrier_id    = 'LH'
        AND connection_id = '0400'
        INTO (  @airport_from_id, @airport_to_id ).

    out->write( `----------`  ).
    out->write( `Example 2:`  ).

    out->write( |Flight LH 400 flies from {  airport_from_id } to { airport_to_id  }| ).

* Example 3: Empty Result and sy-subrc
**********************************************************************
    SELECT SINGLE
      FROM /dmo/connection
      FIELDS airport_from_id
      WHERE carrier_id    = 'XX'
        AND connection_id = '1234'
        INTO @airport_from_id.

    IF sy-subrc = 0.

      out->write( `----------`  ).
      out->write( `Example 3:`  ).
      out->write( |Flight XX 1234 departs from {  airport_from_id }.| ).

    ELSE.

      out->write( `----------`  ).
      out->write( `Example 3:`  ).
      out->write( |There is no flight XX 1234, but still airport_from_id = {  airport_from_id }!| ).

    ENDIF.

      ENDMETHOD.


 METHOD get_output.

  " Add some output for the new attributes
  APPEND |Flight { carrier_id } { connection_id }| TO rv_output.
  APPEND |From: { airport_from_id }| TO rv_output.
  APPEND |To:   { airport_to_id }|   TO rv_output.

    ENDMETHOD.



  METHOD load_flight.

    " 1. Validation (The check we discussed)
    IF i_carrier_id IS INITIAL OR i_connection_id IS INITIAL.
      RAISE EXCEPTION TYPE cx_abap_invalid_value.
    ENDIF.

    " 2. Mapping inputs to class attributes
    me->carrier_id    = i_carrier_id.
    me->connection_id = i_connection_id.

    " 3. The SELECT statement you just wrote
    SELECT SINGLE
      FROM /dmo/connection
      FIELDS airport_from_id, airport_to_id
      WHERE carrier_id    = @i_carrier_id
        AND connection_id = @i_connection_id
      INTO ( @me->airport_from_id, @me->airport_to_id ).

  ENDMETHOD.



ENDCLASS.
