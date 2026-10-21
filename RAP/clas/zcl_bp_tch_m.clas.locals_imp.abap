
CLASS lhc_ZBOOKING_TCH_M DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.



 METHODS earlynumbering_bookingsuppl FOR NUMBERING
      IMPORTING entities FOR CREATE Booking\_Bookingsuppl.

*    METHODS generatePDF_Suppl FOR MODIFY
*      IMPORTING keys FOR ACTION BookingSupplement~generatePDF
*      RESULT result.

ENDCLASS.

CLASS lhc_ZBOOKING_TCH_M IMPLEMENTATION.


  METHOD earlynumbering_bookingsuppl.

DATA: lv_max_suppl_id TYPE /dmo/booking_supplement_id.

" 1. Read existing database links for Booking Supplements
  READ ENTITIES OF ZI_TRAVEL_MM IN LOCAL MODE
  ENTITY Booking BY \_Bookingsuppl
  FROM CORRESPONDING #( entities )
  LINK DATA(_Booking_supplements).


LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking_group>) GROUP BY <booking_group>-%tky.

"lv_max_booking is equal to lv_max at the end
lv_max_suppl_id = REDUCE #(
  INIT bsp_max = CONV /dmo/booking_supplement_id( '0' )
  FOR booksuppl IN _Booking_supplements USING KEY entity
    WHERE ( source-TravelId    = <booking_group>-TravelId
            AND source-BookingId = <booking_group>-BookingId )
  NEXT bsp_max = COND /dmo/booking_supplement_id(
            WHEN booksuppl-target-BookingSupplementId > bsp_max
            THEN booksuppl-target-BookingSupplementId
            ELSE bsp_max )
).



" 2. Find max booking_suppl ID from incoming transient entries in the current request
lv_max_suppl_id = REDUCE #(
            INIT bsp_max = lv_max_suppl_id
            FOR entity IN entities USING KEY entity
                    WHERE ( TravelId = <booking_group>-TravelId
                                    AND BookingId = <booking_group>-BookingId )
                 FOR    target    IN entity-%target
            NEXT bsp_max = COND /dmo/booking_supplement_id(
                                  WHEN target-BookingsupplementID > bsp_max
                                  THEN target-BookingsupplementID
                                   ELSE bsp_max )
).



"Looping entries with same TravelID and BookingID
LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking>)
    USING KEY entity
    WHERE TravelId = <booking_group>-TravelId
      AND      BookingID = <booking_group>-BookingId.



"When bookingID is zero or has no data.

LOOP AT <booking>-%target ASSIGNING FIELD-SYMBOL(<booksuppl_num>).
    APPEND CORRESPONDING #(  <booksuppl_num> ) to mapped-ZIBOOKSUPPL_TECH_M ASSIGNING FIELD-SYMBOL(<mapped_booksuppl>).
       IF  <booksuppl_num>-BookingsupplementID is INITIAL.
       lv_max_suppl_id += 1.
        <mapped_booksuppl>-BookingsupplementID = lv_max_suppl_id.



            ENDIF.

        ENDLOOP.

    ENDLOOP.


    ENDLOOP.


ENDMETHOD.
*"
*  METHOD generatePDF_Suppl.
*
*  " 1. Read the Business Object data using EML
*    READ ENTITIES OF ZIBOOKSUPPL_TECH_M IN LOCAL MODE
*      ENTITY Travel
*      ALL FIELDS WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_booksuppl).
*
*    LOOP AT lt_booksuppl INTO DATA(ls_booksuppl).
*
*ENDLOOP.
*
*
*   " Create simple XML/text content"
*DATA(lv_content) = |Travel ID: { ls_booksuppl-TravelId }| &&
*                   |Agency ID: { ls_booksuppl-AgencyId }| &&
*                   |Customer ID: { ls_booksuppl-CustomerId }| &&
*                   |Start Date: { ls_booksuppl-BeginDate }| &&
*                   |End Date: { ls_booksuppl-EndDate }|.
*
*    " In Cloud, you'd send this to a PDF service or return as text
*
*  APPEND VALUE #( %tky   = ls_booksuppl-%tky
*              %param = ls_booksuppl ) TO result.
*
*  ENDMETHOD.
*
"

ENDCLASS.
