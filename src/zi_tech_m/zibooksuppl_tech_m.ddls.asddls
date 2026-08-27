@AbapCatalog.viewEnhancementCategory: [ #NONE ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking  supply interface Mangd view'
@Metadata.ignorePropagatedAnnotations: true




define view entity  ZIBOOKSUPPL_TECH_M 
as select from zibooksuppl_th_m
association to parent ZBOOKING_TCH_M as _Booking on $projection.TravelId = _Booking.TravelId
and $projection.BookingId =  _Booking.BookingId
association [1..1] to ZI_TRAVEL_MM as _Travel on  $projection.TravelId = _Travel.TravelId
association [1..1] to /DMO/I_Supplement as _Supplement on $projection.SupplementId = _Supplement.SupplementID
association [1..*] to /DMO/I_SupplementText as _SupplementText on $projection.SupplementId = _SupplementText.SupplementID
{
    key travel_id as TravelId,
    key booking_id as BookingId,
    key booking_supplement_id as BookingSupplementId,
    supplement_id as SupplementId,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    price as Price,
    currency_code as CurrencyCode,
    last_changed_at as LastChangedAt,
    _Travel,
    _Supplement,
    _SupplementText,
    _Booking
}
