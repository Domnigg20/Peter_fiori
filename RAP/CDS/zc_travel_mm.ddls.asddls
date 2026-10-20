@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel projection view'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_TRAVEL_MM
provider contract transactional_query
as projection on ZI_TRAVEL_MM
{
  key TravelId,
  AgencyId,
  CustomerId,
  BeginDate,
  EndDate,
 CurrencyCode,
  @Semantics.amount.currencyCode: 'CurrencyCode'
  BookingFee,
   @Semantics.amount.currencyCode: 'CurrencyCode'
  TotalPrice,
  Description,
  OverallStatus,
  Createdby,
  Createdat,
  Lastchangedby,
  Lastchangedat,
  
  _Agency,
  _Booking : redirected to composition child ZC_BOOKING_TECCH,
  _Currency,
  _Customer,
  _Status
}
