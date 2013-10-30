Spree::BaseController.class_eval do
	include Spree::Core::ControllerHelpers::Order
	before_filter :check_current_order
	def check_current_order
		if current_order or session[:order_id]
			order = current_order
			if (order.payment_state == "paid") or (order.payment_state == "credit_owed")
				session[:order_id] = nil
				order.line_items.destroy_all
				flash[:notice] = t('spree.paypal_website_standard.payment_received') if order.payments.any? and order.payments.first.payment_method.type == "Spree::BillingIntegration::PaypalWebsiteStandard"
			end
		end
	end
end