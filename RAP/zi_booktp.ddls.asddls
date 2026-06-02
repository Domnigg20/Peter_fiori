@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Books Core CDS View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_BOOKTP
  as select from zbook
{
  key book_id    as BookId,
      title      as Title,
      author     as Author,
      isbn       as Isbn,
      
      @Semantics.amount.currencyCode: 'Currency'
      price      as Price,
      currency   as Currency,
      
      created_at as CreatedAt,
      created_by as CreatedBy
}
