@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Connection View CDS model'
@Metadata.ignorePropagatedAnnotations: true

@UI.headerInfo: {
  typeName: 'Connection',
  typeNamePlural: 'Connections'

   }



define view entity ZI_ConnectIon_Zcl 
  as select from /dmo/connection as Connection
  association [1..*] to ZI_FLIGHT_RR as _Flight
  on $projection.CarrierId = _Flight.CarrierId
  and $projection.ConnectionId = _Flight.ConnectionId
  
  
  association [1] to ZI_CARRIER_RR as _Airline 
  on $projection.CarrierId = _Airline.CarrierId
  
{



@UI.facet: [{ 
              id:'Connection',
              purpose:#STANDARD, 
              type: #IDENTIFICATION_REFERENCE, 
              position: 10,
              label: 'Connection details' },
              
              { id: 'Flight',
              purpose:#STANDARD, 
              type: #LINEITEM_REFERENCE, 
              position: 20,
              label: 'Flights' ,
               targetElement: '_Flight'
            
            
            }
              
              ]



  @UI.lineItem: [{position: 10 }]
  @UI.identification: [{position: 10, label: 'Carrier ID' }]
  // 1. Tells the UI where to find the descriptive name text
  @ObjectModel.text.association: '_Airline'
 @UI.textArrangement: #TEXT_FIRST
  key carrier_id as CarrierId,
  
  @UI.lineItem: [{position: 20 }]
  @UI.identification: [{position: 20, label: 'Connection ID' }]
  key connection_id as ConnectionId,
  
  @UI.selectionField: [{ position : 10 }]
  @UI.identification: [{position: 30, label: 'Departure Airport' }]
  airport_from_id as AirportFromId,
  
  @UI.lineItem: [{position: 40 }]
  @UI.identification: [{position: 40, label: 'Destination Airport' }]
  airport_to_id as AirportToId,
  
  @UI.lineItem: [{position: 50 }]
  @UI.identification: [{position: 50, label: 'Departure Time' }]
  departure_time as DepartureTime,
  
  @UI.lineItem: [{position: 60, label : 'Arrival time' }]
  @UI.identification: [{position: 60, label: 'Arrival Time' }]
  arrival_time as ArrivalTime,
  
  @UI.lineItem: [{position: 70 }]
  @UI.identification: [{position: 70, label: 'Distance' }]
  @Semantics.quantity.unitOfMeasure: 'DistanceUnit'
  distance as Distance,
  
  @UI.lineItem: [{position: 80 }]
  @UI.identification: [{position: 80, label: 'Distance Unit' }]
  distance_unit as DistanceUnit,
  
  //        Association --->
  _Flight,
  _Airline
}
