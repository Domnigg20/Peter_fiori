" Added SELECT statements in load_flight to populate class attributes
" me->details: fetches DepartureAirport, DestinationAirport, AirlineName
"              from CDS View /DMO/I_Connection using CORRESPONDING FIELDS
" me->connection_full: fetches full flight record including times and distance
" Both SELECTs use import parameters i_carrier_id and i_connection_id as filters

CLASS zcl_structured_cl_3 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.


    INTERFACES if_oo_adt_classrun .

   METHODS get_output
RETURNING VALUE(rv_output) TYPE string_table.


 METHODS load_flight
 IMPORTING
    i_carrier_id    TYPE /dmo/carrier_id
    i_connection_id TYPE /dmo/connection_id
  RAISING
    cx_abap_invalid_value.


 METHODS get_struct   "for connection_full
  RETURNING VALUE(rs_conn) TYPE /dmo/I_Connection.

  PROTECTED SECTION.
  PRIVATE SECTION.

  DATA carrier_id      TYPE /dmo/carrier_id.
  DATA connection_id   TYPE /dmo/connection_id.
  DATA connection_full TYPE /dmo/I_Connection.

  TYPES:
  BEGIN OF st_details,
        DepartureAirport   TYPE /dmo/airport_from_id,
        DestinationAirport TYPE   /dmo/airport_to_id,
        AirlineName        TYPE   /dmo/carrier_name,
      END OF st_details.
  DATA details TYPE st_details.

ENDCLASS.


CLASS zcl_structured_cl_3 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    TRY.

    DATA(lo_flight) = NEW ZCL_STRUCTURED_CL_3( ).

    lo_flight->load_flight(
     i_carrier_id    = 'AZ'  i_connection_id = '0789' ).


    out->write( lo_flight->get_output( ) ) .


    lo_flight->load_flight(  i_carrier_id = 'LH' i_connection_id = '0400' ).

    out->write( lo_flight->get_struct( ) ).


    CATCH cx_abap_invalid_value.
      out->write( `Check your Flight IDs!` ).
    ENDTRY.


 IF sy-subrc = 0.

*      out->write( `----------`  ).
*      out->write( `Example 3:`  ).
*      out->write( |Flight XX 1234 departs from {  airport_from_id }.| ).

    ELSE.

*      out->write( `----------`  ).
*      out->write( `Example 3:`  ).
*      out->write( |There is no flight XX 1234, but still airport_from_id = {  airport_from_id }!| ).

    ENDIF.

 ENDMETHOD.




METHOD get_struct.
  " rs_conn is the 'output' variable defined in the method signature
  rs_conn = me->connection_full.
ENDMETHOD.


  METHOD get_output.

*    APPEND |--------------------------------|             TO r_output.
*    APPEND |Carrier:     { carrier_id } { carrier_name }| TO r_output.
*    APPEND |Connection:  { connection_id   }|             TO r_output.
*    APPEND |Departure:   { airport_from_id }|             TO r_output.
*    APPEND |Destination: { airport_to_id   }|             TO r_output.

    APPEND |--------------------------------|                    TO rv_output.
    APPEND |Carrier:     { carrier_id } { details-airlinename }| TO rv_output.
    APPEND |Connection:  { connection_id   }|                    TO rv_output.
    APPEND |Departure:   { details-departureairport     }|       TO rv_output.
    APPEND |Destination: { details-destinationairport   }|       TO rv_output.

 ENDMETHOD.


METHOD load_flight.

    " 1. Validation (The check we discussed)
    IF i_carrier_id IS INITIAL OR i_connection_id IS INITIAL.
      RAISE EXCEPTION TYPE cx_abap_invalid_value.
    ENDIF.

    " 2. Mapping inputs to class attributes
    me->carrier_id    = i_carrier_id.
    me->connection_id = i_connection_id.

"parsing data into connection full

  SELECT SINGLE
  FROM /DMO/I_Connection
  FIELDS AirlineID, ConnectionID, DepartureAirport, DestinationAirport,
         DepartureTime, ArrivalTime, Distance, DistanceUnit
  WHERE AirlineID    = @i_carrier_id
    AND ConnectionID = @i_connection_id
  INTO @me->connection_full.



    SELECT SINGLE
    FROM /DMO/I_Connection
    FIELDS DepartureAirport, DestinationAirport, \_Airline-Name AS AirlineName
    WHERE AirlineID    = @i_carrier_id
      AND ConnectionID = @i_connection_id
    INTO CORRESPONDING FIELDS OF @me->details.

  IF sy-subrc <> 0.
    RAISE EXCEPTION TYPE cx_abap_invalid_value.
  ENDIF.

  ENDMETHOD.
ENDCLASS.
