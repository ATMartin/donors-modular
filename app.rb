require 'sinatra'
require 'dotenv'
Dotenv.load
require 'stripe'
# require 'mail'
require_relative 'database'

Database.initialize


set :publishable_key, ENV['PUBLISHABLE_KEY']
set :secret_key, ENV['SECRET_KEY']
enable :sessions

Stripe.api_key = settings.secret_key

=begin
Mail.defaults do
  delivery_method :smtp, { :address   => "smtp.sendgrid.net",
                           :port      => 587,
                           :domain    => ENV['SENDGRID_DOMAIN'],
                           :user_name => ENV['SENDGRID_USERNAME'],
                           :password  => ENV['SENDGRID_PW'],
                           :authentication => 'plain',
                           :enable_starttls_auto => true }
end
=end

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
  @donation = Donation.get(params[:donation_id])

  customer = Stripe::Customer.create(
    email: params[:email],
    card: params[:token_id]
  )

  begin
    Stripe::Charge.create(
      amount: @donation.amount*100,
      description: "200 Donors",
      currency: 'usd',
      customer: customer.id
    )

    @donation.update(paid: 'true')
    session[:id] = @donation.id
  rescue Stripe::CardError => e
    body = e.json_body
    session[:error] = body[:error][:message]
    halt 500
  end

=begin
  mail = Mail.deliver do
  to customer.email
  from 'Ryan McCrary <ryan@goattrips.org>'
  subject 'GOAT Christmas!'
  text_part do
    body 'Thanks so much for helping make GOAT Christmas a reality!

We would love to get your information so we can follow up with a tax receipt and some other GOAT goodies. Please fill out this form for our records - http://gtrps.org/1AtqNcK

To say thanks, we have a couple of exciting offers for you!

If you would like to redeem your 1-month membership at the Mountain Goat indoor climbing gym, please complete the following form to recieve your voucher and let us know who will be redeeming it: http://gtrps.org/11sS6nE

Our friends at Dapper Ink in Greenville also make some beautiful screen printed goods that make great Christmas Gifts and they are offering 10% off your order in their store. To view and print your 10% off coupon, please visit this link: http://gtrps.org/1CaQik0

Thanks again for helping make GOAT a reality for kids all over Greenville and the state of SC. We would love for you to share GOAT Christmas with your friends and family and encourage them to give whatever they can. You can also keep up with the progress at https://christmas.goattrips.org/goal

Please let me know if you have any thoughts or questions about GOAT and/or GOAT Christmas!


Ryan McCrary
Executive Director
GOAT'
  end
  html_part do
    content_type 'text/html; charset=UTF-8'
    body '<p>Thanks so much for helping make GOAT Christmas a reality!</p>

<p>We would love to get your information so we can follow up with a tax receipt and some other GOAT goodies. Please fill out this form for our records - http://gtrps.org/1AtqNcK</p>

<p>To say thanks, we have a couple of exciting offers for you!

<p>Our friends at Half-Moon Outfitters have been providing the Southeast with quality goods and services for all outdoor adventure and travel since 1993. They are offering 10% off your order in their stores (excluding Kayaks and Paddleboards). To print your 10% off coupon, please visit this link: http://gtrps.org/1yfyiSR</p>


<p>Our friends at Dapper Ink in Greenville also make some beautiful screen printed goods that make great Christmas Gifts and they are offering 10% off your order in their store. To view and print your 10% off coupon, please visit this link: http://gtrps.org/1CaQik0</p>

<p>If you would like to redeem your 1-month membership at the Mountain Goat indoor climbing gym, please complete the following form to recieve your voucher and let us know who will be redeeming it: http://gtrps.org/11sS6nE</p>

<p>Thanks again for helping make GOAT a reality for kids all over Greenville and the state of SC. We would love for you to share GOAT Christmas with your friends and family and encourage them to give whatever they can. You can also keep up with the progress at https://christmas.goattrips.org/goal </p>

<p>Please let me know if you have any thoughts or questions about GOAT and/or GOAT Christmas!</p>


<p>Ryan McCrary<br />
Executive Director<br />
GOAT</p>'
  end
  end
=end
  halt 200
end

get '/thanks' do
  @error = session[:error]
  if @error
    halt erb(:thanks)
  end

  @donation = Donation.get(session[:id])

  paid_donations = Donation.all(paid: 'true')
  @total = 0
  paid_donations.each do |done|
    @total += done.amount
  end

  erb :thanks
end

__END__
