


##  Architecture Flow
* **Database Table** (`ZBOOK`)  
* └── **Interface CDS View** (`ZI_BOOKTP` - Core Data Model)  
*     └── **Behavior Definition** (`ZI_BOOKTP` - Business Rules)  
*         └── **Behavior Implementation Class** (`ZBP_I_BOOKTP` - Custom Logic)  
*             └── **Test Class / Console Runner** (`Z_TEST_BOOK` - EML Operations)


##  Architecture Flow
* **Database Table** (`ZCL_ENV`)  
* └── **Interface CDS View** (`ZENV_CDS` - Core Data Model)  
*         └── **Behavior Implementation Class** (`ZENV_CDS.BDEF` - Custom Logic)  
*             └── **Database Table** (`ZRENV`)
                └── **Test Class / Console Runner** (`ZCL_ENV` - EML Operations)


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


##  Project Architecture
**ZI_CONNECTION_RR** - Root CDS View Entity for connection details.
**ZI_FLIGHT_RR** - Child/Associated CDS View Entity for flight schedules and pricing.
**ZI_CARRIER_RR** - Associated CDS View Entity for airline/carrier information.

Service binding- ****ZUI_FLIGHT_ZCL** - Exposes the data model entities for consumption.
Service Definition- **ZI_CONNECTION_ZCL** - Exposes the service definition as an OData UI service for previewing in SAP Fiori elements.


