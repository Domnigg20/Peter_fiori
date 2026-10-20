@AccessControl.authorizationCheck:#NOT_REQUIRED
@EndUserText.label: 'BOOKING PROJECTION'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true

define view  entity ZC_BOOKING_TECCH
  as projection on ZBOOKING_TCH_M
{
    key TravelId,
    key BookingId,
    BookingDate,
    @Search.defaultSearchElement: true
    CustomerId,
    CarrierId,
     ConnectionId,
    FlightDate,
     @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,

    
    CurrencyCode,
    BookingStatus,
    LastChangedAt,
    _Bookingsuppl : redirected to composition child ZCBOOKSUPPL_TECH_M, 
    _Booking_Status,
    _Carrier,
    _Connection,
    _Customer,
   _Travel : redirected to parent ZC_TRAVEL_MM
}
