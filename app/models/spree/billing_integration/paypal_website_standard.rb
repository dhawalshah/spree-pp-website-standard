class Spree::BillingIntegration::PaypalWebsiteStandard < Spree::BillingIntegration

  attr_accessible :preferred_account_email, :preferred_ipn_notify_host, :preferred_success_url, 
    :preferred_paypal_url, :preferred_encryption, :preferred_certificate_id, :preferred_ipn_secret,
    :preferred_currency, :preferred_language,
    :preferred_server, :preferred_test_mode

  preference :account_email, :string
  preference :ipn_notify_host, :string
  preference :success_url, :string
  #sandbox paypal_url: https://www.sandbox.paypal.com/cgi-bin/webscr
  #production paypal_url: https://www.paypal.com/cgi-bin/webscr
  preference :paypal_url, :string, :default => 'https://www.sandbox.paypal.com/cgi-bin/webscr'
  preference :encryption, :boolean, :default => false
  preference :certificate_id, :string, :default => ''
  preference :ipn_secret, :string, :default => ''
  preference :currency, :string, :default => "USD"
  preference :language, :string, :default => "en"


  def payment_profiles_supported?
    false
  end

  def actions
    %w(capture void)
  end

  def can_capture?(payment)
    ['pending'].include?(payment.state)
  end

  def capture(*args)
    r = ActiveMerchant::Billing::Response.new(true, "", {}, {})
    # Horrible, horrible hack...
    if r.success?
      order_id = /^\w+/.match(args[2][:order_id]).to_s
      order = Spree::Order.find_by_number(order_id)
      order.update_attribute :state, "complete"
    end
    return r
  end

  def void(*args)
    ActiveMerchant::Billing::Response.new(true, "", {}, {})
  end

end
