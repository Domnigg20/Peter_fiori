
## 🏗️ Architecture Flow
* **Database Table** (`ZBOOK`)  
* └── **Interface CDS View** (`ZI_BOOKTP` - Core Data Model)  
*     └── **Behavior Definition** (`ZI_BOOKTP` - Business Rules)  
*         └── **Behavior Implementation Class** (`ZBP_I_BOOKTP` - Custom Logic)  
*             └── **Test Class / Console Runner** (`Z_TEST_BOOK` - EML Operations)



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
