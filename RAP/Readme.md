"! Database Table: ZBOOK
"!   ↓
"! CDS View: ZI_BOOKTP (data projection)
"!   ↓
"! Behavior Definition: ZI_BOOKTP (business rules)
"!   ↓
"! Handler Class: ZBP_I_BOOKTP (custom logic)
"!   ↓
"! Test Class: Z_TEST_BOOK (this file - EML operations)
"!

### CRUD Operations

- **CREATE**: Add new books to the database
- **READ**: Retrieve books using entity keys
- **UPDATE**: Modify existing book records
- **DELETE**: Remove books from the database
- **COMMIT ENTITIES**: Persist changes to database

### EML Concepts

- **%cid**: Client ID for new instances (identifies records being created)
- **%key-**: Reference to entity key fields (identifies existing records)
- **MODIFY ENTITIES**: Create/update/delete operations
- **READ ENTITIES**: Retrieve data from business object
- **IN LOCAL MODE**: Local processing without remote calls
- **COMMIT ENTITIES**: Finalize and persist changes to database
