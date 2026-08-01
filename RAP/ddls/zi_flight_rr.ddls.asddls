@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Connection View CDS model'
@Metadata.ignorePropagatedAnnotations: true


define view  entity ZI_FLIGHT_RR 
as select from /dmo/flight
  association [1] to ZI_CARRIER_RR as _Airline  
  on $projection.CarrierId = _Airline.CarrierId

{

    @UI.lineItem: [{position: 10 }]
    @ObjectModel.text.association: '_Airline'
     @UI.textArrangement: #TEXT_FIRST    
 key carrier_id as CarrierId,
    @UI.lineItem: [{position: 20 }]
 key connection_id as ConnectionId,
    
    @UI.lineItem: [{position: 30 }]
 key flight_date as FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    @UI.lineItem: [{position: 40 }]
    price as Price,
    @UI.lineItem: [{position: 50 }]
    currency_code as CurrencyCode,
    @UI.lineItem: [{position: 60 }]
     @Search.defaultSearchElement: true
    plane_type_id as PlaneTypeId,
    @UI.lineItem: [{position: 70 }]
    seats_max as SeatsMax,
    @UI.lineItem: [{position: 80 }]
    seats_occupied as SeatsOccupied,
    _Airline
}
