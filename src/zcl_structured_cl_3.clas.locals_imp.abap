*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_connection DEFINITION.

  PRIVATE SECTION.
    " This is where you define the structure as requested
    TYPES: BEGIN OF st_details,
             departure_airport   TYPE /dmo/airport_from_id,
             destination_airport TYPE /dmo/airport_to_id,
             airline_name        TYPE /dmo/carrier_name,
           END OF st_details.

    " You might also define an attribute using this type
    DATA ms_details TYPE st_details.

ENDCLASS.

CLASS lcl_connection IMPLEMENTATION.
  " Your logic for lcl_connection goes here
ENDCLASS.
