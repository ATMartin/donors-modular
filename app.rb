require 'sinatra'
require 'stripe'
require_relative 'database'


Database.initialize
Database.seed_data if Donation.count < 199


 
set :publishable_key, 
set :secret_key, 

Stripe.api_key = settings.secret_key
 
get '/' do
  @donations = Donation.all
  erb :index
end

get '/goal' do
  @done = Donation.all(:paid => 'true')
  @total = 0
  @done.each do |done|
    @total += done.amount
  end
  erb :goal
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
  
  @done = Donation.all(:paid => 'true')
  @total = 0
  @done.each do |done|
    @total += done.amount
  end
  erb :charge
end
 
__END__
 
@@ layout
  <!DOCTYPE html>
  <html>
  <head>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
    <link rel='stylesheet' type='text/css' href='css/main.css'/>
  </head>
  <body>
    <%= yield %>
  </body>
  </html>
 
@@index
  <div class="container">
    <div class="row lights">
      <div class="col-md-6">
        <h3>Merry Christmas GOAT!</h3>
        <p>The end of the calendar year always brings excitement. Thanksgiving and Christmas are around the corner and that means time with family and friends that we often miss during the year.</p>
        <p>The end of the year also brings planning and looking forward to the next year. At GOAT, that means planning our capacity for the following year. How many kids can we provide summer experiences for? How many new kids will get to join our Adventure Teams? How many kids will we be able to hire this year?</p>
        <p>As we look towards the next year, much of this planning invovles budgeting. Our goal is to serve kids and change their lives in the long-term. To do this, we have to steward our resources well in the short term.</p>
      </div>
      <div class="col-md-6">
        <h3>&nbsp;</h3>
        <p>This is where we need your help! If someone gives each of the values below from $1-200 we will raise just over $20,000 to kickstart our programs for 2015.</p>
        <p>GOAT would never happen without passionate people giving generously to changing lives in Greenville. We're excited to have each of you as a partner in this Christmas season.</p>
        <br /><br />Because we value your privacy, all donations are <a href="http://stripe.com"><img src="img/solid@2x.png" width="119" height="26" border="0" /></a>
      </div>
    </div>
  </div>

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
<div class="container">
  <div class="row">
    <div class="col-md-6 col-md-offset-3">
      <h2>Thanks for being a part of GOAT Christmas! You gave <strong>$<%= @donation.amount %></strong>!</h2>
      <p>That makes the total: <b>$<%= @total %></b> so far!</p>
      <p>You'll be receiving an email soon so we can get more details from you to send a tax-reciept and some other goodies!</p>
      <p>It would mean the world to us if you would share this with your friends! Tweet it, facebook it, instagram it, or even email it!<p>
        <div class="well">
          <h4>Example tweet:</h4>
          <h4>Example facebook post:</h4>
          <h4>Photos to use:</h4>
        </div>
      <a href="/">Go see what it looks like with your square taken!</a>
    </div>
  </div>
</div>

@@goal
<div class="container">
  <div class="row">
    <div class="col-md-6 col-md-offset-3">
      <center>
        <h4>Our Christmas goal is currently at:</h4>
        <h1><b><%= @total %></b> of <b>$21,100</b></h1>
      </center>
    </div>
  </div>
</div>