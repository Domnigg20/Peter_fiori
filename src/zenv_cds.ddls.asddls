@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Environmental Emission Log View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED

  
  
}
define root view entity ZENV_CDS
  as select from zrenv
{

 @UI.lineItem: [ { position: 10 } ]
  @UI.selectionField: [ { position: 10 } ]
  @EndUserText.label: 'Log UUID'
  
  key log_uuid      as LogUuid,
  
  @UI.lineItem: [ { position: 20 } ]
  @UI.selectionField: [ { position: 20 } ]
  @EndUserText.label: 'Facility ID'
  
  facility_id       as FacilityId,
  
   @UI.lineItem: [ { position: 20 } ]
  @UI.selectionField: [ { position: 20 } ]
  @EndUserText.label: 'CountryCode'
  
  country_code      as CountryCode,
  
  
  log_date          as LogDate,
 
  energy_source as EnergySource,
      
  
  @Semantics.quantity.unitOfMeasure: 'FuelUnit'
  fuel_consumed     as FuelConsumed,
  fuel_unit         as FuelUnit,
  @Semantics.amount.currencyCode: 'EmissionUnit'
  co2_emitted       as Co2Emitted,
  
  @Consumption.valueHelpDefinition: [{ 
  entity: { name: 'I_UnitOfMeasure', element: 'UnitOfMeasure' } 
}]
  emission_unit     as EmissionUnit
}
