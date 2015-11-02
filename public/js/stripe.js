// ----- Stripe Payment Modal -----

// Name of Organization
var orgName = "Family Stripe Account";

// Organizational Badge / Image
var orgBadge = "img/160x160.jpg";


var stripe_public_key = $('script[data-pk]').data('pk');

$('.bigbox').on('click', '.giftbox button', function(e) {
  e.preventDefault();
  $this = $(this);

  var handler = StripeCheckout.configure({
    key:  stripe_public_key,
    name: orgName,
    image: orgBadge,
    allowRememberMe: 'false',
    amount: $this.data('amount'),
    closed: function() {
    },
    token: function(token) {
      $.post( "/charge", {
        token_id: token.id,
        donation_id: $this.data('id'),
        email: token.email
      }).done(function() {
        window.location.href = "/thanks";
      }).fail(function() {
        alert( "Sorry! There was an error processing your donation." );
      });
    }
  });

  handler.open();
});
