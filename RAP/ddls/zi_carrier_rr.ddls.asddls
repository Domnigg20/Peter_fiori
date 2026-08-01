@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Connection View CDS model'
@Metadata.ignorePropagatedAnnotations: true


@Search.searchable: true
define view entity ZI_CARRIER_RR 
as select from  /dmo/carrier

{
   @ObjectModel.text.element: ['Name']  
    key carrier_id as CarrierId,
    @Semantics.text: true
     @Search.defaultSearchElement: true
     @Search.fuzzinessThreshold: 0.7
    name as Name,
    currency_code as CurrencyCode,
    local_created_by as LocalCreatedBy,
    local_created_at as LocalCreatedAt,
    local_last_changed_by as LocalLastChangedBy,
    local_last_changed_at as LocalLastChangedAt,
    last_changed_at as LastChangedAt
}
