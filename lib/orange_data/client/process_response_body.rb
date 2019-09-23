# 'frozen_string_literal' =>true

module OrangeData
  class Client
    class ProcessResponseBody < Faraday::Response::Middleware
      include OrangeData::Client::ConvertKeysMixin

      def initialize(app = nil, config)
        @config = config
        super(app)
      end

      def parse(payload)
        convert_keys(payload).yield_self do |pl|
          pl.is_a?(Hash) ? convert_values(pl) : pl
        end
      end

      private

      def receipt_types
        @receipt_types ||= @config.receipt_types.invert
      end

      def agent_types
        @agent_types ||= @config.agent_types.invert
      end

      def taxation_system_types
        @taxation_system_types ||= @config.taxation_system_types.invert
      end

      def tax_types
        @tax_types ||= @config.tax_types.invert
      end

      def payment_method_types
        @payment_method_types ||= @config.payment_method_types.invert
      end

      def payment_subject_types
        @payment_subject_types ||= @config.payment_subject_types.invert
      end

      def payment_types
        @payment_types ||= @config.payment_types.invert
      end

      def convert_values(payload)
        if payload.dig(:content, :type)
          payload[:content][:type] = receipt_types[payload.dig(:content, :type)] || payload.dig(:content, :type)
        end

        if payload.dig(:content, :agent_type)
          payload[:content][:agent_type] = agent_types[payload.dig(:content, :agent_type)] || payload.dig(:content, :agent_type)
        end

        if payload.dig(:content, :check_close, :taxation_system)
          payload[:content][:check_close][:taxation_system] = taxation_system_types[payload.dig(:content, :check_close, :taxation_system)] || payload.dig(:content, :check_close, :taxation_system)
        end

        if payload.dig(:content, :positions)
          payload[:content][:positions].each do |position|
            position[:tax] = tax_types[position[:tax]] || position[:tax]
            position[:payment_method_type] = payment_method_types[position[:payment_method_type]] || position[:payment_method_type]
            position[:payment_subject_type] = payment_subject_types[position[:payment_subject_type]] || position[:payment_subject_type]
            if position.keys.include?(:nomenclature_code)
              position[:nomenclature_code] = position[:nomenclature_code] ? Base64.decode64(position[:nomenclature_code]) : nil
            end
          end
        end

        if payload.dig(:content, :check_close, :payments)
          payload[:content][:check_close][:payments].each do |payment|
            payment[:type] = payment_types[payment[:type]] || payment[:type]
          end
        end

        payload
      end

      def orange_data_keys
        @orange_data_keys ||= {
          'checkClose' => :check_close,
          'customerContact' => :customer_contact,
          'agentType' => :agent_type,
          'paymentTransferOperatorPhoneNumbers' => :payment_transfer_operator_phone_numbers,
          'paymentAgentOperation' => :payment_agent_operation,
          'paymentAgentPhoneNumbers' => :payment_agent_phone_numbers,
          'paymentOperatorPhoneNumbers' => :payment_operator_phone_numbers,
          'paymentOperatorName' => :payment_operator_name,
          'paymentOperatorAddress' => :payment_operator_address,
          'paymentOperatorINN' => :payment_operator_inn,
          'supplierPhoneNumbers' => :supplier_phone_numbers,
          'additionalUserAttribute' => :additional_user_attribute,
          'automatNumber' => :automat_number,
          'settlementAddress' => :settlement_address,
          'settlementPlace' => :settlement_place,
          'paymentMethodType' => :payment_method_type,
          'paymentSubjectType' => :payment_subject_type,
          'nomenclatureCode' => :nomenclature_code,
          'supplierInfo' => :supplier_info,
          'supplierINN' => :supplier_inn,
          'taxationSystem' => :taxation_system,
          'phoneNumbers' => :phone_numbers,
          'deviceSN' => :device_sn,
          'deviceRN' => :device_rn,
          'fsNumber' => :fs_number,
          'ofdName' => :ofd_name,
          'ofdWebsite' => :ofd_website,
          'ofdINN' => :ofd_inn,
          'ofdinn' => :ofd_inn,
          'fnsWebsite' => :fns_website,
          'companyINN' => :company_inn,
          'companyName' => :company_name,
          'documentNumber' => :document_number,
          'shiftNumber' => :shift_number,
          'documentIndex' => :document_index,
          'processedAt' => :processed_at,
          'correctionType' => :correction_type,
          'causeDocumentDate' => :cause_document_date,
          'causeDocumentNumber' => :cause_document_number,
          'totalSum' => :total_sum,
          'cashSum' => :cash_sum,
          'eCashSum' => :ecash_sum,
          'prepaymentSum' => :prepayment_sum,
          'postpaymentSum' => :postpayment_sum,
          'otherPaymentTypeSum' => :other_payment_type_sum,
          'tax1Sum' => :tax1_sum,
          'tax2Sum' => :tax2_sum,
          'tax3Sum' => :tax3_sum,
          'tax4Sum' => :tax4_sum,
          'tax5Sum' => :tax5_sum,
          'tax6Sum' => :tax6_sum
        }.freeze
      end
    end

    Faraday::Response.register_middleware(process_response_body: ProcessResponseBody)
  end
end
