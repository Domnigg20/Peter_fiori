@AbapCatalog.viewEnhancementCategory: [ #NONE ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking interface Mangd view'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZBOOKING_TCH_M
 as select from zbooking_tech_db
    association to parent ZI_TRAVEL_MM as _Travel on $projection.TravelId = _Travel.TravelId
    composition [0..*] of ZIBOOKSUPPL_TECH_M as _Bookingsuppl
        association [0..1] to /DMO/I_Customer  as _Customer  on $projection.CustomerId = _Customer.CustomerID
    association [0..1] to /DMO/I_Carrier as _Carrier on $projection.CarrierId = _Carrier.AirlineID
     association [0..1] to /DMO/I_Connection  as _Connection on $projection.ConnectionId = _Connection.ConnectionID
    association [0..1] to /DMO/I_Booking_Status_VH  as _Booking_Status on $projection.BookingStatus = _Booking_Status.BookingStatus
    
    {
    key travel_id as TravelId,
    key booking_id as BookingId,
    booking_date as BookingDate,
    customer_id as CustomerId,
    carrier_id as CarrierId,
    connection_id as ConnectionId,
    flight_date as FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    flight_price as FlightPrice,
    currency_code as CurrencyCode,
    booking_status as BookingStatus,
     @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at as LastChangedAt,
    
    _Carrier,
    _Customer,
    _Connection,
    _Booking_Status,
   _Travel
    ,_Bookingsuppl
}
