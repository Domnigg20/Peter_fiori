"! Loads flight data based on carrier and connection IDs.
"! @parameter i_carrier_id    | Airline Code (e.g., 'LH')
"! @parameter i_connection_id | Connection Number (e.g., '0400')
"! @raising   cx_abap_invalid_value | Raised if flight is not found.
"! "This defines how structured data objects work using OOP. 
"I imported some CDS views





CLASS zcl_structured_cl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .



  PUBLIC SECTION.
"local declarations


  DATA AirlineId TYPE /dmo/airport_from_id.
    DATA ConnectionId   TYPE /dmo/airport_to_id.



  METHODS load_flight
  IMPORTING
    i_carrier_id    TYPE /dmo/carrier_id
    i_connection_id TYPE /dmo/connection_id
  RAISING
    cx_abap_invalid_value.


    INTERFACES if_oo_adt_classrun .


  PROTECTED SECTION.
  PRIVATE SECTION.

      DATA carrier_id      TYPE /dmo/carrier_id.
    DATA connection_id   TYPE /dmo/connection_id.

    DATA airport_from_id TYPE /dmo/airport_from_id.
    DATA airport_to_id   TYPE /dmo/airport_to_id.

    DATA carrier_name    TYPE /dmo/carrier_name.
    DATA connection_full TYPE /dmo/I_Connection.





ENDCLASS.



CLASS zcl_structured_cl IMPLEMENTATION.

METHOD if_oo_adt_classrun~main.


* Example 3 : Local Structured Type
**********************************************************************

    TYPES: BEGIN OF st_connection,
             airport_from_id TYPE /dmo/airport_from_id,
             airport_to_id   TYPE /dmo/airport_to_id,
             carrier_name    TYPE /dmo/carrier_name,
           END OF st_connection.

    DATA connection TYPE st_connection.


    TYPES: BEGIN OF st_nested,
             airport_from_id TYPE /dmo/airport_from_id,
             airport_to_id   TYPE /dmo/airport_to_id,
             message         TYPE symsg,
             carrier_name    TYPE /dmo/carrier_name,
           END OF st_nested.

    DATA connection_nested TYPE st_nested.

    connection-airport_from_id = 'ABC'.
     connection-airport_to_id = 'XYZ'.
    connection-carrier_name = 'Sky Airline'.


     out->write( '............! .First connection..!......' ).

     out->write( connection ).



   " These are needed because 'main' cannot see the PRIVATE attributes directly
    DATA airport_from_id TYPE /dmo/airport_from_id.
    DATA airport_to_id   TYPE /dmo/airport_to_id.
    DATA connection_full TYPE /dmo/I_Connection.



TRY.


DATA(new_struct) =  NEW ZCL_STRUCTURED_CL( ).

      new_struct->load_flight(
                          i_carrier_id    = 'LH'
                          i_connection_id = '0400'
                        ).



    SELECT SINGLE
      FROM /DMO/I_Connection
    FIELDS DepartureAirport, DestinationAirport, \_Airline-Name
     WHERE AirlineID = 'LH'
       AND ConnectionID = '0400'
      INTO @connection.

    out->write(  `---------------------------------------` ).
    out->write(  `Example 1: Local Structured Type` ).
    out->write( connection ).

* Example 4 : Nested Structured Type
**********************************************************************
 connection_nested-airport_from_id = connection-airport_from_id.



    out->write(  `---------------------------------` ).
    out->write(  `Example 2: Nested Structured Type` ).
    out->write( connection_nested ).


  CATCH cx_abap_invalid_value.
      out->write( `Check your Flight IDs!` ).
  ENDTRY.



    SELECT SINGLE
     FROM /dmo/I_Connection
   FIELDS AirlineID, ConnectionID, DepartureAirport, DestinationAirport,
          DepartureTime, ArrivalTime, Distance, DistanceUnit
    WHERE AirlineId    = 'LH'
      AND ConnectionId = '0400'
     INTO @connection_full.

IF sy-subrc = 0.



    out->write(  `--------------------------------------` ).
    out->write(  `Example 3: CDS View as Structured Type` ).
    out->write( connection_full ).

* Example 2: Global Structured Type
**********************************************************************

ELSE.
    DATA message TYPE symsg.

    out->write(  `---------------------------------` ).
    out->write(  `Example 4: Global Structured Type` ).
    out->write( message ).


 ENDIF.
 ENDMETHOD.


  METHOD load_flight.
    me->carrier_id = i_carrier_id.
    me->connection_id = i_connection_id.

  ENDMETHOD.





ENDCLASS.
