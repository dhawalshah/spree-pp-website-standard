module Spree
  class PaypalController < Spree::CheckoutController
    protect_from_forgery :except => [:confirm]
    skip_before_filter :persist_gender
    
    def confirm
      unless current_order
        redirect_to root_path
      else
        order = current_order

        if ((order.state == "payment") && order.valid?)
          if order.payable_via_paypal?
            payment = Payment.new
            payment.amount = order.total
            payment.payment_method = Order.paypal_payment_method
            order.payments << payment
            payment.pend
            session.delete :order_id
          end
        end


        if (order.payment_state == "paid") or (order.payment_state == "credit_owed")
          flash[:notice] = t('spree.paypal_website_standard.payment_received')
          #state_callback(:after)
        else
          # order.next
          # while order.state != "complete"
          #   order.next
          #   #state_callback(:after)
          # end
          flash[:notice] = t('spree.paypal_website_standard.order_processed_successfully')# + order.errors.full_messages.inspect
          flash[:commerce_tracking] = "nothing special"
        end

        redirect_to token_order_path(order, order.token)
      end
    end
  
  end
end


