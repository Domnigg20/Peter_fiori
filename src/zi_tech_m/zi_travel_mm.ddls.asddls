@AbapCatalog.viewEnhancementCategory: [ #NONE ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root entity for travel'
@Metadata.ignorePropagatedAnnotations: true

define root view  entity ZI_TRAVEL_MM 
    as select from ztravel_tech_m4
    composition [0..*] of ZBOOKING_TCH_M as _Booking
    association [0..1] to /DMO/I_Agency as _Agency on $projection.AgencyId = _Agency.AgencyID
    association [0..1] to /DMO/I_Customer as _Customer on $projection.CustomerId = _Customer.CustomerID
    association [0..1] to I_Currency as _Currency on $projection.CurrencyCode = _Currency.Currency
    association [0..1] to /DMO/I_Overall_Status_VH  as _Status on $projection.OverallStatus = _Status.OverallStatus
    
{
    key travel_id as TravelId,
    agency_id as AgencyId,
    customer_id as CustomerId,
    begin_date as BeginDate,
    end_date as EndDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    booking_fee as BookingFee,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    total_price as TotalPrice,
    currency_code as CurrencyCode,
    description as Description,
    overall_status as OverallStatus,
    createdby as Createdby,
    createdat as Createdat,
    lastchangedby as Lastchangedby,
    lastchangedat as Lastchangedat,
    
    _Agency,
    _Customer,
    _Currency,
    _Status,
    _Booking
    
    }
