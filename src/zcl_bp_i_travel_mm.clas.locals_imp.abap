CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities
                  FOR CREATE Travel.


  METHODS earlynumbering_booking FOR NUMBERING
  IMPORTING entities
  FOR CREATE Travel\_Booking.


    METHODS generatePDF FOR MODIFY
      IMPORTING keys FOR ACTION Travel~generatePDF
      RESULT result.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.


  METHOD generatePDF.

  " 1. Read the Business Object data using EML
    READ ENTITIES OF ZI_TRAVEL_MM IN LOCAL MODE
      ENTITY Travel
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travels).

      "2. Read the uploaded Adobe form layout
  DATA(lo_form_reader) =
    cl_fp_form_reader=>create_form_reader(
      'Z_MY_TRAVEL_FORM'
    ).



  LOOP AT lt_travels INTO DATA(ls_travel).

  " Adobe Document Services requires your variables wrapped into an XML payload
    DATA(lv_xml_data) = |<form>| &&
                        |<TravelId>{ ls_travel-TravelId }</TravelId>| &&
                        |<AgencyId>{ ls_travel-AgencyId }</AgencyId>| &&
                        |<CustomerId>{ ls_travel-CustomerId }</CustomerId>| &&
                        |<BeginDate>{ ls_travel-BeginDate }</BeginDate>| &&
                        |<EndDate>{ ls_travel-EndDate }</EndDate>| &&
                        |</form>|.

    " Convert the XML string into a raw XSTRING
    DATA(lv_xml_xstring) = cl_abap_conv_codepage=>create_out( )->convert( lv_xml_data ).

    DATA lv_pdf_xstring TYPE xstring.


    TRY.

    DATA(lo_form) = cl_fp_form_reader=>create_form_reader( 'Z_MY_TRAVEL_FORM' ).

    DATA(lv_xdp_layout) = lo_form->get_layout( ).

        cl_fp_ads_util=>render_pdf(
          EXPORTING
            iv_xml_data        = lv_xml_xstring
            IV_XDP_LAYOUT   =      lv_xdp_layout
            iv_locale          = 'en_US'
          IMPORTING
            ev_pdf             = lv_pdf_xstring " This outputs your clean, valid PDF binary
        ).
      CATCH cx_fp_ads_util INTO DATA(lx_ads_error).
    ENDTRY.

    " 4. Pass the binary data to your Abstract Entity
    APPEND VALUE #(
      %tky   = ls_travel-%tky
      %param = VALUE ZDEC_PDF_FILE(
                 Attachment = lv_pdf_xstring
                 MimeType   = 'application/pdf'
                 Filename   = |Travel_{ ls_travel-TravelId }.pdf|
               )
    ) TO result.

  ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.


  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>) WHERE TravelId IS INITIAL.

      TRY.
          " Generate a unique 16-byte UUID
          APPEND VALUE #(
            %cid     = <ls_entity>-%cid
            TravelId = cl_system_uuid=>create_uuid_x16_static( )
          ) TO mapped-travel.

        CATCH cx_uuid_error INTO DATA(lx_uuid_error).
          " Handle error if UUID generation fails
          APPEND VALUE #(
            %cid = <ls_entity>-%cid
            %key = <ls_entity>-%key


          ) TO failed-travel.


          APPEND VALUE #(
            %cid = <ls_entity>-%cid
            %key = <ls_entity>-%key
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = lx_uuid_error->get_text( ) )
          ) TO reported-travel.
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.
  METHOD earlynumbering_booking.

  DATA: lv_max_booking TYPE /dmo/booking_id.

  READ ENTITIES OF zi_travel_mm IN LOCAL MODE
  ENTITY Travel BY \_Booking
  FROM CORRESPONDING #( entities )
  LINK DATA(lt_link_data).


  LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_group_entity>)
                    GROUP BY <ls_group_entity>-TravelId.


"lv_max_booking is equal to lv_max at the end
 lv_max_booking = REDUCE #(
            INIT lv_max = CONV /dmo/booking_id( '0' )
            FOR ls_link IN lt_link_data USING KEY entity
             WHERE ( source-TravelId = <ls_group_entity>-TravelId )
             NEXT lv_max = COND /dmo/booking_id(
                WHEN lv_max < ls_link-target-BookingId
                THEN ls_link-target-BookingId
            ELSE lv_max )
).



" 2. Find max booking ID from incoming transient entries in the current request
lv_max_booking = REDUCE #(
            INIT lv_max = lv_max_booking
            FOR ls_entity IN entities USING KEY entity
             WHERE ( TravelId = <ls_group_entity>-TravelId )
                FOR ls_booking IN ls_entity-%target
            NEXT lv_max = COND /dmo/booking_id(
            WHEN lv_max < ls_booking-BookingId
             THEN ls_booking-BookingId
             ELSE lv_max )
).


LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entities>)
    USING KEY entity
    WHERE TravelId = <ls_group_entity>-TravelId.



"When bookingID is zero or has no data.

LOOP AT <ls_entities>-%target ASSIGNING FIELD-SYMBOL(<ls_booking>).

IF  <ls_booking>-BookingId IS INITIAL.
        lv_max_booking += 10.
    APPEND CORRESPONDING #(  <ls_booking> ) to mapped-booking ASSIGNING FIELD-SYMBOL(<ls_mapped_book>).
        <ls_mapped_book>-BookingId = lv_max_booking .


            ENDIF.

        ENDLOOP.

    ENDLOOP.


    ENDLOOP.


ENDMETHOD.


ENDCLASS.
