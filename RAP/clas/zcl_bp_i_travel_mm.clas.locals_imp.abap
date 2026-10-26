annotate entity ZC_TRAVEL_MM with
{
 @UI.facet: [{
      id: 'Travel',
      purpose: #STANDARD,
      position: 10,
      label: 'Travel',
      type: #IDENTIFICATION_REFERENCE
  },
  {
      id: 'Booking',
      purpose: #STANDARD,
      position: 20,
      label: 'Booking',
      type: #LINEITEM_REFERENCE,
      targetElement: '_Booking'
  }]


 

  @UI.lineItem: [{ position: 10 }]
  @UI.identification: [{ position: 10 }]
  
@UI.identification: [
    { position: 10 },
    { type: #FOR_ACTION, dataAction: 'acceptTravel', label: 'Accept Travel' },
    { type: #FOR_ACTION, dataAction: 'rejectTravel', label: 'Reject Travel' },
    { type: #FOR_ACTION, dataAction: 'generatePDF', label: 'Download PDF' }
  ]
  @Search.defaultSearchElement: true
  TravelId;
