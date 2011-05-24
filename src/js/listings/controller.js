//depends: core/controller.js, listings/models.js

hs.regController('listings', hs.Controller.extend({
  routes: {
    '!/listings/new/': 'newListing',
    '!/listings/thanks/': 'thanks',
    '!/listings/:id/': 'listing'
  },
  listing: function(id){
    hs.page.finish();
    var listing = hs.listings.models.Listing.get(id);
    hs.page = new hs.listings.views.ListingPage({model: listing});
    hs.page.render();
  },
  newListing: function(){
    // var l = new hs.listings.models.Listing();
    // l.set({
    //   "description": "MacBook Pro for sale. Excellent condition and fully loaded. 8GB RAM 64GB SSD. Must see. ",
    //   "latitude": 43.651702,
    //   "longitude": -79.373703000000006,
    //   "updated": "2011-05-02T15:40:06.629088",
    //   "photo": {
    //     "original": "http://lorempixum.com/560/418/technics/",
    //     "web": "http://lorempixum.com/560/418/technics/"
    //   },
    //   "price": 1500.0
    // });
    // l.bind('change:id', function(){
    //   hs.goTo('!/listings/'+l.get('id')+'/');
    // });
    // l.save();
    hs.page.finish();
    hs.page = new hs.listings.views.ListingForm({el: $('#main')});
    hs.page.render();
  },
  thanks: function(){
    hs.page.finish();
    hs.page = new hs.listings.views.Thanks();
    hs.page.render();
  }
}));
