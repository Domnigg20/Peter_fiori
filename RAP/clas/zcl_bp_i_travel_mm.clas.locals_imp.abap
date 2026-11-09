
CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_authorizations
      FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations
      FOR Travel RESULT result.

    METHODS get_global_authorizations
      FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations
      FOR Travel RESULT result.

    METHODS earlynumbering_create
      FOR NUMBERING
      IMPORTING entities
      FOR CREATE Travel.

    METHODS earlynumbering_booking
      FOR NUMBERING
      IMPORTING entities
      FOR CREATE Travel\_Booking.

    METHODS generatePDF
      FOR MODIFY
      IMPORTING keys FOR ACTION Travel~generatePDF
      RESULT result.

    METHODS calculateTotalPrice
      FOR MODIFY
      IMPORTING keys FOR ACTION Travel~calculateTotalPrice
      RESULT result.

    METHODS get_features
      FOR FEATURES
      IMPORTING keys REQUEST requested_features
      FOR Travel RESULT result.

    METHODS accepttravel FOR MODIFY
      keys FOR ACTION travel~accepttravel RESULT result.

    METHODS copytravel FOR MODIFY
      keys FOR ACTION travel~copytravel.

    METHODS recalctotprice FOR MODIFY
      keys FOR ACTION travel~recalctotprice.

    METHODS rejecttravel FOR MODIFY
      keys FOR ACTION travel~rejecttravel RESULT result.

ENDCLASS.


CLASS lhc_Travel IMPLEMENTATION.

  METHOD generatePDF.

    " 1. Read the Business Object data using EML
    READ ENTITIES OF ZI_TRAVEL_MM IN LOCAL MODE
      ENTITY Travel
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travels).

    " 2. Read the uploaded Adobe form layout

*    * DATA(lo_form_reader) =
*    *   cl_fp_form_reader=>create_form_reader(
*    *     'Z_MY_TRAVEL_FORM'
*    *   ).

    LOOP AT lt_travels INTO DATA(ls_travel).

      " Adobe Document Services requires your variables
      " wrapped into an XML payload

      DATA(lv_xml_data) =
        |<form>| &&
        |<TravelId>{ ls_travel-TravelId }</TravelId>| &&
        |<AgencyId>{ ls_travel-AgencyId }</AgencyId>| &&
        |<CustomerId>{ ls_travel-CustomerId }</CustomerId>| &&
        |<BeginDate>{ ls_travel-BeginDate }</BeginDate>| &&
        |<EndDate>{ ls_travel-EndDate }</EndDate>| &&
        |</form>|.

      " Convert the XML string into a raw XSTRING

      DATA(lv_xml_xstring) = cl_abap_conv_codepage=>create_out( )->convert( lv_xml_data ).

      DATA lv_pdf_xstring TYPE xstring.
      DATA lv_xdp_layout  TYPE xstring.

      TRY.

*          DATA(lo_form) =
*            cl_fp_form_reader=>create_form_reader(
*             'Z_MY_TRAVEL_FORM'
*             ).


          cl_fp_ads_util=>render_pdf(
            EXPORTING
              iv_xml_data   = lv_xml_xstring
              iv_xdp_layout = lv_xdp_layout
              iv_locale     = 'en_US'
            IMPORTING
              ev_pdf        = lv_pdf_xstring
          ).

        CATCH cx_fp_ads_util INTO DATA(lx_ads_error).
         APPEND VALUE #(
            %tky = ls_travel-%tky
            %msg = new_message_with_text(
             severity = if_abap_behv_message=>severity-error
               text     = lx_ads_error->get_text( )
         )
             ) TO reported-travel.

                     CONTINUE.


      ENDTRY.

      " 4. Pass the binary data to your Abstract Entity
      APPEND VALUE #(
        %tky = ls_travel-%tky
        %param = VALUE ZDEC_PDF_FILE(
          Attachment = lv_pdf_xstring
          MimeType   = 'application/pdf'
          Filename   = |Travel_{ ls_travel-TravelId }.pdf|
        )
      ) TO result.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_features.
    READ ENTITIES OF zi_travel_mm IN LOCAL MODE
    ENTITY Travel
    FIELDS ( OverallStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travels).


    result = VALUE #(
      FOR ls_travel IN lt_travels
      (
      %tky                 = ls_travel-%tky
      %action-acceptTravel = COND #(
        WHEN ls_travel-OverallStatus = 'O'
        THEN if_abap_behv=>fc-o-enabled
        ELSE if_abap_behv=>fc-o-disabled )
      %action-generatePDF  = if_abap_behv=>fc-o-enabled
      %action-calculateTotalPrice = if_abap_behv=>fc-o-enabled
      )
    ).

  ENDMETHOD.


  " Checking total price from Travel and Booking
  METHOD calculateTotalPrice.

    " 1. Read the Travel instance using EML
    READ ENTITIES OF ZI_TRAVEL_MM IN LOCAL MODE
      ENTITY Travel
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travels)

      " Booking instance using EML
      ENTITY Travel BY \_Booking
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_bookings).

    DATA lt_travel_update
      TYPE TABLE FOR UPDATE ZI_TRAVEL_MM.

    " 2. Loop through each travel record to calculate
    "    the new total price
    LOOP AT lt_travels INTO DATA(ls_travel).

      DATA(lv_total_price) = ls_travel-BookingFee.

      " Sum up all flight prices belonging to the travel
      " instance
      LOOP AT lt_bookings INTO DATA(ls_booking)
        WHERE TravelId = ls_travel-TravelId.

        lv_total_price += ls_booking-FlightPrice.

      ENDLOOP.

      " 3. Append the calculated total to the update table
      APPEND VALUE #(
        %tky      = ls_travel-%tky
        TotalPrice = lv_total_price
      ) TO lt_travel_update.

    ENDLOOP.

    " 4. Update the Business Object buffer with the new
    "    TotalPrice
    MODIFY ENTITIES OF ZI_TRAVEL_MM IN LOCAL MODE
      ENTITY Travel
      UPDATE FIELDS ( TotalPrice )
      WITH lt_travel_update.

    " 5. Read back the updated travel instances from the
    "    buffer so we have fresh data
    READ ENTITIES OF ZI_TRAVEL_MM IN LOCAL MODE
      ENTITY Travel
      ALL FIELDS WITH CORRESPONDING #( lt_travel_update )
      RESULT lt_travels.

    " 6. Pass the updated instances to the action's
    "    RESULT export parameter
    result = VALUE #(
      FOR ls_updated IN lt_travels
      (
        %tky   = ls_updated-%tky
        %param = ls_updated
      )
    ).

  ENDMETHOD.


  METHOD get_instance_authorizations.
  ENDMETHOD.


  METHOD get_global_authorizations.
  ENDMETHOD.


  METHOD earlynumbering_create.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>)
      WHERE TravelId IS INITIAL.

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
              text     = lx_uuid_error->get_text( )
            )
          ) TO reported-travel.

      ENDTRY.

    ENDLOOP.

  ENDMETHOD.


  METHOD earlynumbering_booking.

    DATA lv_max_booking TYPE /dmo/booking_id.

    READ ENTITIES OF zi_travel_mm IN LOCAL MODE
      ENTITY Travel BY \_Booking
      FROM CORRESPONDING #( entities )
      LINK DATA(lt_link_data).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_group_entity>)
      GROUP BY <ls_group_entity>-TravelId.

      " lv_max_booking is equal to lv_max at the end
      lv_max_booking = REDUCE #(
        INIT lv_max = CONV /dmo/booking_id( '0' )
        FOR ls_link IN lt_link_data USING KEY entity
        WHERE (
          source-TravelId = <ls_group_entity>-TravelId
        )
        NEXT lv_max = COND /dmo/booking_id(
          WHEN lv_max < ls_link-target-BookingId
          THEN ls_link-target-BookingId
          ELSE lv_max
        )
      ).

      " 2. Find max booking ID from incoming transient
      "    entries in the current request
      lv_max_booking = REDUCE #(
        INIT lv_max = lv_max_booking
        FOR ls_entity IN entities USING KEY entity
        WHERE (
          TravelId = <ls_group_entity>-TravelId
        )
        FOR ls_booking IN ls_entity-%target
        NEXT lv_max = COND /dmo/booking_id(
          WHEN lv_max < ls_booking-BookingId
          THEN ls_booking-BookingId
          ELSE lv_max
        )
      ).

      LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entities>)
        USING KEY entity
        WHERE TravelId = <ls_group_entity>-TravelId.

        " When BookingID is zero or has no data
        LOOP AT <ls_entities>-%target
          ASSIGNING FIELD-SYMBOL(<ls_booking>).

          IF <ls_booking>-BookingId IS INITIAL.

            lv_max_booking += 10.

            APPEND CORRESPONDING #( <ls_booking> )
              TO mapped-booking
              ASSIGNING FIELD-SYMBOL(<ls_mapped_book>).

            <ls_mapped_book>-BookingId = lv_max_booking.

          ENDIF.

        ENDLOOP.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

      METHOD acceptTravel.
      " 1. Read the current status of the selected travels from the buffer
    READ ENTITIES OF ZI_TRAVEL_MM IN LOCAL MODE
      ENTITY Travel
      FIELDS ( OverallStatus )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travels).

    DATA lt_travel_update TYPE TABLE FOR UPDATE ZI_TRAVEL_MM.

    LOOP AT lt_travels INTO DATA(ls_travel).

      " 2. Check the status before deciding to change it
      CASE ls_travel-OverallStatus.
        WHEN 'A'. " Already Accepted
          " Add an error message to 'reported' so the user knows why it failed
          APPEND VALUE #(
            %tky = ls_travel-%tky
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = |Travel { ls_travel-TravelId } is already accepted.|
            )
          ) TO reported-travel.

          " Mark this specific key as failed
          APPEND VALUE #(
            %tky = ls_travel-%tky
          ) TO failed-travel.

        WHEN 'X'. " Cancelled / Rejected
          APPEND VALUE #(
            %tky = ls_travel-%tky
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = |Cancelled travel { ls_travel-TravelId } cannot be accepted.|
            )
          ) TO reported-travel.

          APPEND VALUE #(
            %tky = ls_travel-%tky
          ) TO failed-travel.

        WHEN 'O'. " Open - This is valid! Safe to update.
          APPEND VALUE #(
            %tky          = ls_travel-%tky
            OverallStatus = 'A'
          ) TO lt_travel_update.

      ENDCASE.

    ENDLOOP.

    " 3. Only execute the update if there are valid 'Open' records to change
    IF lt_travel_update IS NOT INITIAL.
      MODIFY ENTITIES OF ZI_TRAVEL_MM IN LOCAL MODE
        ENTITY Travel
        UPDATE FIELDS ( OverallStatus )
        WITH lt_travel_update.
    ENDIF.

    " 4. Read back the updated records (including any that failed or succeeded)
    "    to populate the result parameter for the UI
    READ ENTITIES OF ZI_TRAVEL_MM IN LOCAL MODE
      ENTITY Travel
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_updated_travels).

    result = VALUE #(
      FOR ls_updated IN lt_updated_travels
      (
        %tky   = ls_updated-%tky
        %param = ls_updated
      )
    ).
      ENDMETHOD.

 METHOD copyTravel.

    DATA: lt_travel TYPE TABLE FOR CREATE ZI_TRAVEL_MM,

          lt_booking TYPE TABLE FOR CREATE ZI_TRAVEL_MM\_Booking,

          lt_bookingsuppl TYPE TABLE FOR CREATE ZBOOKING_TCH_M\_Bookingsuppl.

    " 1. Read source travel instances using EML
    READ ENTITIES OF ZI_TRAVEL_MM IN LOCAL MODE
      ENTITY Travel
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travel_r)
      FAILED DATA(lt_failed).

    READ ENTITIES OF ZI_TRAVEL_MM IN LOCAL MODE
      ENTITY Travel BY \_Booking
      ALL FIELDS WITH CORRESPONDING #( lt_travel_r )
      RESULT DATA(lt_booking_r).

    READ ENTITIES OF ZI_TRAVEL_MM IN LOCAL MODE
      ENTITY Booking BY \_Bookingsuppl
      ALL FIELDS WITH CORRESPONDING #( lt_booking_r )
      RESULT DATA(lt_bookingsuppl_r).

    " 2. Build the deep structure hierarchy natively
    LOOP AT lt_travel_r INTO DATA(ls_travel_r).

     " Get the corresponding %cid passed from the UI action
          " Safely extract the %cid using OPTIONAL to prevent short dumps if not found
      DATA(lv_cid) = VALUE #( keys[ KEY entity TravelId = ls_travel_r-TravelId ]-%cid OPTIONAL ).
      IF lv_cid IS INITIAL.
        CONTINUE.
      ENDIF.

      " Append root Travel entry
      APPEND INITIAL LINE TO lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
      <ls_travel>-%cid          = lv_cid.
      <ls_travel>-%data         = CORRESPONDING #( ls_travel_r EXCEPT TravelId ).
      <ls_travel>-BeginDate     = cl_abap_context_info=>get_system_date( ).
      <ls_travel>-EndDate       = cl_abap_context_info=>get_system_date( ) + 30.
      <ls_travel>-OverallStatus = 'O'.



        APPEND VALUE #(  %cid_ref = <ls_travel>-%cid ) to
        lt_booking  ASSIGNING FIELD-SYMBOL(<lt_bookingg>).

      " Loop at related bookings and nest them directly into %target
      LOOP AT lt_booking_r INTO DATA(ls_booking_r)
                          USING KEY entity
                          WHERE TravelId = ls_travel_r-TravelId.

    APPEND INITIAL LINE TO <lt_bookingg>-%target ASSIGNING FIELD-SYMBOL(<ls_booking_target>).

       <ls_booking_target>-%cid          = lv_cid && '_' && ls_booking_r-BookingId.
        <ls_booking_target>-%data         = CORRESPONDING #( ls_booking_r EXCEPT TravelId BookingId ).
        <ls_booking_target>-BookingStatus = 'N'.

        APPEND VALUE #(
  %cid_ref = <ls_booking_target>-%cid  ) TO lt_bookingsuppl ASSIGNING FIELD-SYMBOL(<ls_suppl_assoc>).

        " Loop at related booking supplements and nest them into the booking's %target
        LOOP AT lt_bookingsuppl_r INTO DATA(ls_booksupp_r)
                    USING KEY ENTITY
                    WHERE TravelId  = ls_travel_r-TravelId
                    AND   BookingId = ls_booking_r-BookingId.

          APPEND INITIAL LINE TO <ls_suppl_assoc>-%target ASSIGNING FIELD-SYMBOL(<ls_suppl_target>).
          <ls_suppl_target>-%cid  = lv_cid && '_' && ls_booking_r-BookingId && '_' && ls_booksupp_r-BookingSupplementId.
          <ls_suppl_target>-%data = CORRESPONDING #( ls_booksupp_r EXCEPT TravelId BookingId BookingSupplementId ).

        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    " 3. Execute a single deep MODIFY ENTITIES call
    IF lt_travel IS NOT INITIAL.
      MODIFY ENTITIES OF ZI_TRAVEL_MM IN LOCAL MODE
        ENTITY Travel
          CREATE FIELDS ( AgencyId CustomerId BeginDate EndDate BookingFee TotalPrice CurrencyCode OverallStatus Description )
          WITH lt_travel
        ENTITY Travel
          CREATE BY \_Booking
          FIELDS (  BookingDate CustomerID CarrierId ConnectionId FlightDate FlightPrice CurrencyCode BookingStatus )
            WITH  lt_booking
            ENTITY Booking
          CREATE BY \_Bookingsuppl
          FIELDS (  SupplementId Price CurrencyCode )
          WITH lt_bookingsuppl
        MAPPED   DATA(it_mapped)
        FAILED   DATA(it_failed)
        REPORTED DATA(it_reported).

      " Pass mapping back to framework mapped structures
      mapped-travel = it_mapped-travel.

    ENDIF.

  ENDMETHOD.


  METHOD reCalcTotprice.
  ENDMETHOD.

  METHOD rejectTravel.
  ENDMETHOD.

ENDCLASS.
