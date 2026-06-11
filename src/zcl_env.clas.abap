CLASS ZCL_ENV DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
INTERFACES if_oo_adt_classrun.

ENDCLASS.

CLASS ZCL_ENV IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    " 1. Create a data structure matching your RAP entity
    DATA lt_emissions TYPE TABLE FOR CREATE ZENV_CDS.

    " 2. Simulate parsing your raw data values into the internal table
    APPEND VALUE #(
        %cid          = 'MyDummyCID_01'    " Content ID required for internal tracking
        FacilityId    = 'FAC_LISBON'
        CountryCode   = 'PT'
        LogDate       = cl_abap_context_info=>get_system_date( )
        EnergySource  = 'DIESEL'
        FuelConsumed  = '1500.250'
        FuelUnit      = 'L'
        Co2Emitted    = '4020.675'         " Your parsed environmental calculation
        EmissionUnit  = 'KG'
    ) TO lt_emissions.

    " 3. The RAP way to parse data directly into the database via BDEF
    MODIFY ENTITIES OF ZENV_CDS
      ENTITY ZENV_CDS
      CREATE FIELDS ( FacilityId CountryCode LogDate EnergySource FuelConsumed FuelUnit Co2Emitted EmissionUnit )
   WITH lt_emissions
      MAPPED   DATA(ls_mapped)
      FAILED   DATA(ls_failed)
      REPORTED DATA(ls_reported).

    " 4. Commit the changes to the persistent DB table
    IF ls_failed IS INITIAL.
      COMMIT ENTITIES.
      out->write( 'Environmental data successfully parsed and saved via BDEF!' ).
    ELSE.
      out->write( 'Error: Verification failed in BDEF.' ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.

