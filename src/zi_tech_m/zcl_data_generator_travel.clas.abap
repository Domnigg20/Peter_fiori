CLASS zcl_data_generator_travel DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_data_generator_travel IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.




    " delete existing entries in the database table

    DELETE FROM ztravel_tech_m4.

    DELETE FROM zibooksuppl_th_m.

    DELETE FROM zibooking_tch_m.

    COMMIT WORK.

    " insert travel demo data

    INSERT ztravel_tech_m4 FROM (
   SELECT * FROM /dmo/travel_m


).
    COMMIT WORK.



    " insert booking demo data

    INSERT zibooking_tch_m FROM (

     SELECT * FROM   /dmo/booking_m

   " JOIN ZI_TRAVEL_MM AS z
   "  ON   booking~travel_id = z~travel_id



      ).

    COMMIT WORK.

    INSERT zibooksuppl_th_m FROM (

        SELECT * FROM   /dmo/booksuppl_m

*            JOIN ztravel_tech_m AS z

*            ON   booking~travel_id = z~travel_id



      ).

    COMMIT WORK.



    out->write( 'Travel and booking demo data inserted.').
  ENDMETHOD.
ENDCLASS.
