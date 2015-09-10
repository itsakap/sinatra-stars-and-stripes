require 'sinatra'
require 'stripe'

set :publishable_key, ENV['PUBLISHABLE_KEY']
set :secret_key, ENV['SECRET_KEY']

Stripe.api_key = settings.secret_key


get '/' do
	erb :index
end

post '/charge' do
	@amount = (params[:Amount].to_f * 100).to_i
  puts @amount
	customer = Stripe::Customer.create(
		:email => 'customer@example.com',
		:card  => params[:stripeToken]
	)

	charge = Stripe::Charge.create(
		:amount      => @amount,
		:description => 'Sinatra Charge',
		:currency    => 'usd',
		:customer    => customer.id
	)
	erb :charge, :locals => { :amount => '%.2f' % (@amount.to_f/100) }
end
error Stripe::CardError do
	  env['sinatra.error'].message
end

__END__

@@ layout
<!DOCTYPE html>
<html>
	<head></head>
	<body>
    <script src="https://code.jquery.com/jquery-2.1.4.min.js"></script>
		<%= yield %>

	</body>
</html>

@@ index
<form action="/charge" method="post" id="chargeForm" class="payment">
	<article>
		<label class="amount">
			<span>Enter an amount or leave blank for $10.00</span>
		</label>
	</article>

	<script src="https://checkout.stripe.com/checkout.js"></script>
          <div class="input-group col-md-6 col-md-offset-3 col-sm-6 col-sm-offset-3 col-xs-10 col-xs-offset-1">
            <span class="input-group-addon">$</span>
            <input type="number" value="" placeholder="10" name="Amount" class="form-control" id="custom-donation-amount">
            <span class="input-group-addon">.00</span>
            <span class="input-group-btn">
              <button class="btn btn-default" id="charge-button" type="submit" value="Subscribe" name="subscribe">
                <span class="glyphicon glyphicon-circle-arrow-right"></span>
              </button>
            </span>
          </div>

          <script>
            $(function(){
              var amount = 1000;
              var handler = StripeCheckout.configure({
                key: '<%= settings.publishable_key %>',
                image: "",
                token: function(token) {
                  // Use the token to create the charge with a server-side script.
                  // You can access the token ID with `token.id`
                  // return false;
                  var $input = $('<input type=hidden name=stripeToken />').val(token.id);
                  $("#chargeForm").append($input).submit();
                }
              });
            
              document.getElementById('charge-button').addEventListener('click', function(e) {
                // This line is the only real modification...
                var val =$("#custom-donation-amount").val();
                if(val.length > 0) amount = val * 100;
                else {
                  $("#custom-donation-amount").val(10);
                };
                handler.open({
                  name: 'Wraps Condoms',
                  description: 'Condom Order',
                  // ... aside from this line where we use the value.
                  amount: amount
                });
                e.preventDefault();
              });
              window.onpopstate= function() {

                handler.close();
              };
            });
          </script>
</form>

@@ charge
  <h2>Thanks, you paid <strong>$<%= amount %></strong>!</h2>
