require 'sinatra'
require 'stripe'
require 'pry'
require_relative 'database'

require 'dotenv' if development?
Dotenv.load if development?

Database.initialize
Database.seed_data if Donation.count < 199


 
set :publishable_key, 'pk_test_KFojpZFSM1VdKsgApaMozAIA'
set :secret_key, 'sk_test_FQks2lhN9ueh8lsb8jslDvlL'

Stripe.api_key = settings.secret_key
 
get '/' do
  @donations = Donation.all
  erb :index
end
 
post '/charge' do
  @donation = Donation.get(params[:donation])
  @amount = @donation.amount*100
 
  customer = Stripe::Customer.create(
    :email => 'customer@example.com',
    :card  => params[:stripeToken]
  )
 
  charge = Stripe::Charge.create(
    :amount      => @amount,
    :description => 'Sinatra Charge',
    :currency    => 'usd',
    :customer    => customer
  )

  @donation.update(:paid => 'true')
 
  erb :charge
end
 
__END__
 
@@ layout
  <!DOCTYPE html>
  <html>
  <head>
    <link rel='stylesheet' type='text/css' href='css/main.css'/>
  </head>
  <body>
    <%= yield %>
  </body>
  </html>
 
@@index
  <% @donations.each do |donation| %>
    <% if donation.paid? %>
      <div class="giftbox complete">
        Amount: $<%= donation.amount %>.00 Complete!
      </div>
    <% else %>
    <div class="giftbox">
      <form action="/charge" method="post">
        <label class="amount">
          <span>Amount: $<%= donation.amount %>.00</span>
          <input type="hidden" name="donation" value="<%= donation.id %>">
        </label>

      <script src="https://checkout.stripe.com/v3/checkout.js" 
              class="stripe-button" 
              data-key="<%= settings.publishable_key %>"
              data-name="Great Outdoor Adventure Trips"
              data-amount="<%= donation.amount*100 %>"
              data-allowRememberMe="false"
              data-panel-label="Donate"
              data-label="Donate $<%= donation.amount %>"
              data-image="http://goattrips.org/images/160x160.jpg"></script>
      </form>
    </div>
    <% end %>
  <% end %>
 
@@charge
  <h2>Thanks, you paid <strong><%= @donation.amount %></strong>!</h2>