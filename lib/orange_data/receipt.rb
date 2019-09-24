# frozen_string_literal: true

module OrangeData
  class Receipt
    include OrangeData::PipelineMixin

    def initialize(id: SecureRandom.uuid, inn: nil, group: nil, type: nil, key: nil, customer_contact: nil, taxation_system: nil, config: OrangeData.configuration)
      @id = id
      @inn = inn
      @group = group
      @receipt_type = type
      @key = key
      @customer_contact = customer_contact
      @taxation_system = taxation_system
      @config = config
    end

    def add_position(quantity:, price:, text:, tax: nil, payment_method_type: nil, payment_subject_type: nil, nomenclature_code: nil)
      position = {
        quantity: quantity,
        price: price,
        tax: tax || @config.tax,
        text: text,
        payment_method_type: payment_method_type || @config.payment_method_type,
        payment_subject_type: payment_subject_type || @config.payment_subject_type
      }
      if nomenclature_code.present?
        position[nomenclature_code] = nomenclature_code
      end
      payload.dig(:content, :positions) << position

      self
    end

    def add_payment(type:, amount:)
      payload.dig(:content, :check_close, :payments) << {
        type: type,
        amount: amount
      }

      self
    end

    def add_agent(agent_type: nil, payment_transfer_operator_phone_numbers: nil, payment_agent_operation: nil,
                  payment_agent_phone_numbers: nil, payment_operator_phone_numbers: nil, payment_operator_name: nil,
                  payment_operator_address: nil, payment_operator_inn:, supplier_phone_numbers: nil)

      payload[:content].tap do |content|
        content[:agent_type] = agent_type || @config.agent_type
        content[:payment_transfer_operator_phone_numbers] = if payment_transfer_operator_phone_numbers.empty?
                                                              @config.payment_transfer_operator_phone_numbers
                                                            else
                                                              payment_transfer_operator_phone_numbers
                                                            end
        content[:payment_agent_operation] = payment_agent_operation || @config.payment_agent_operation
        content[:payment_agent_phone_numbers] = if payment_agent_phone_numbers.empty?
                                                  @config.payment_agent_phone_numbers
                                                else
                                                  payment_agent_phone_numbers
                                                end
        content[:payment_operator_phone_numbers] = if payment_operator_phone_numbers.empty?
                                                     @config.payment_operator_phone_numbers
                                                   else
                                                     payment_operator_phone_numbers
                                                   end
        content[:payment_operator_name] = payment_operator_name || @config.payment_operator_name
        content[:payment_operator_address] = payment_operator_address || @config.payment_operator_address
        content[:payment_operator_inn] = payment_operator_inn || @config.payment_operator_inn
        content[:supplier_phone_numbers] = if supplier_phone_numbers.empty?
                                             @config.supplier_phone_numbers
                                           else
                                             supplier_phone_numbers
                                           end
      end

      self
    end

    def add_customer_info(name:, value:)
      payload[:content][:additional_user_attribute] = {
        name: name,
        value: value
      }

      self
    end

    def sync!
      Client.request(Marshal.load(Marshal.dump(payload)), api_name: :add_receipt).yield_self do |response|
        response.success? ? Succ.new(payload) : response
      end
    end

    private

    def payload
      @payload ||= {
        id: @id,
        inn: @inn || @config.inn,
        group: @group || @config.group,
        content: {
          type: @receipt_type || @config.receipt_type,
          positions: [],
          check_close: {
            taxation_system: @taxation_system || @config.taxation_system,
            payments: []
          },
          customer_contact: @customer_contact,
        },
        key: @key || @config.api_key
      }
    end
  end
end
