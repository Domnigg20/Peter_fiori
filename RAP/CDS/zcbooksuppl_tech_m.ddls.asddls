@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BOOKINGSUPPL PROJECTION'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZCBOOKSUPPL_TECH_M
as projection on ZIBOOKSUPPL_TECH_M
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
  SupplementId,
  @Semantics.amount.currencyCode: 'CurrencyCode'
  Price,
  CurrencyCode,
  LastChangedAt,
  
  _Booking : redirected to parent ZC_BOOKING_TECCH,
  _Supplement,
  _SupplementText,
  _Travel : redirected to ZC_TRAVEL_MM
  
  
}
