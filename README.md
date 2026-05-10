# ABAP OOP & CDS Views - Learning Project

Practice classes built on SAP BTP using the /DMO/ Flight Reference Scenario.
This repo documents my progression from basic ABAP to Object Oriented Programming
and CDS View consumption.

---

## Classes

### zcl_flights
- Basic flight data retrieval
- Introduction to SELECT statements in ABAP

### zcl_cds_19
- Use of CDS Views via /DMO/I_Connection
- SELECT SINGLE with WHERE filters
- Fetching associated data via \_Airline association

### zcl_structured_cl
- Introduction to class definition and implementation
- Public methods and basic output

### zcl_structured_cl_2
- Structured types (BEGIN OF / END OF)
- Multiple SELECT fields into a structure
- sy-subrc handling for empty results

### zcl_structured_cl_3
- Full OOP implementation
- Private attributes and me-> concept
- Methods: load_flight, get_output, get_struct
- Exception handling with cx_abap_invalid_value
- Populating class attributes from CDS View /DMO/I_Connection

---

## Concepts Covered
- ABAP OOP (classes, methods, private attributes)
- CDS View consumption
- SELECT SINGLE with import parameters as filters
- CORRESPONDING FIELDS OF
- me-> vs local variables
- Exception handling
- abapGit for version control

---

## System
- Built on: SAP BTP ABAP Environment
- Demo Data: /DMO/ Flight Reference Scenario
- Tool: Eclipse ADT with abapGit
