"Complete RAP Implementation
"!
"! This class demonstrates a complete SAP RAP (Restful Application Programming)
"! business object implementation with CRUD operations using EML
"! (Entity Manipulation Language).





CLASS z_test_book DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.

CLASS z_test_book implEMENTATION.

  METHOD if_oo_adt_classrun~main.

    " 1. Push the book data into the temporary memory buffer
    MODIFY ENTITIES OF ZI_BOOKTP
      ENTITY ZI_BOOKTP
      CREATE FROM VALUE #( (
        %cid     = '1'
        BookId   = 12345  " 💡 Tip: Changed to 10 to prevent duplicate-key errors if run multiple times!
        Title    = 'ABAP Masterclass'
        Author   = 'Expert'
        Isbn     = '123-456-789'
        Price    = '45.99'
        Currency = 'EUR'
      ) )
      REPORTED DATA(reported)
      FAILED   DATA(failed).

    IF failed IS NOT INITIAL.
      out->write( 'Buffer creation failed!' ).
      out->write( failed ).
    ELSE.
      out->write( 'Book created in buffer successfully!' ).

      " 2. CRITICAL: Permanently save the book from the buffer to the ZBOOK table!
      COMMIT ENTITIES
        RESPONSE OF ZI_BOOKTP
        FAILED   DATA(save_failed)
        REPORTED DATA(save_reported).
    ENDIF.

    " 3. Prepare the keys to read it back
    DATA input_keys TYPE TABLE FOR READ IMPORT ZI_BOOKTP.
    DATA result_tab TYPE TABLE FOR READ RESULT ZI_BOOKTP.

    input_keys = VALUE #( ( %key-BookId = 12345 ) ).

    " 4. Read the book back from the active database layer
    READ ENTITIES OF ZI_BOOKTP
      ENTITY ZI_BOOKTP
      FROM input_keys
      RESULT result_tab.

    out->write( '====== BOOKS =====' ).
    LOOP AT result_tab INTO DATA(book).
      out->write( |Title: { book-Title }| ).
      out->write( |Author: { book-Author }| ).
      out->write( |Price: { book-Price } { book-Currency }| ).
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
