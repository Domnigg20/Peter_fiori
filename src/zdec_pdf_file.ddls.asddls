@EndUserText.label: 'File Download Return Structure'
define abstract entity ZDEC_PDF_FILE
{
  @Semantics.largeObject: { 
    mimeType: 'MimeType', 
    fileName: 'Filename', 
    contentDispositionPreference: #ATTACHMENT 
  }
  Attachment : abap.rawstring(0);
  
  @Semantics.mimeType: true
  MimeType   : abap.char(128);
  
  Filename   : abap.char(128);
}
