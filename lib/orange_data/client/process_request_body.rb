# frozen_string_literal: true

module OrangeData
  class Client
    class ProcessRequestBody < Faraday::Middleware
      include OrangeData::Client::ConvertKeysMixin

      def initialize(app, config)
        @app = app
        @config = config
      end

      def call(env)
        @app.call(env.tap do |e|
          e[:body] = convert_values(e[:body])
          e[:body] = convert_keys(e[:body])
        end)
      end

      private

      def convert_values(payload)
        if payload.dig(:content, :type)
          payload[:content][:type] = @config.receipt_types[payload.dig(:content, :type)] || payload.dig(:content, :type)
        end

        if payload.dig(:content, :agent_type)
          payload[:content][:agent_type] = @config.agent_types[payload.dig(:content, :agent_type)] || payload.dig(:content, :agent_type)
        end

        if payload.dig(:content, :check_close, :taxation_system)
          payload[:content][:check_close][:taxation_system] = @config.taxation_system_types[payload.dig(:content, :check_close, :taxation_system)] || payload.dig(:content, :check_close, :taxation_system)
        end

        if payload.dig(:content, :positions)
          payload[:content][:positions].each do |position|
            position[:tax] = @config.tax_types[position[:tax]] || position[:tax]
            position[:payment_method_type] = @config.payment_method_types[position[:payment_method_type]] || position[:payment_method_type]
            position[:payment_subject_type] = @config.payment_subject_types[position[:payment_subject_type]] || position[:payment_subject_type]
            if position.keys.include?(:nomenclature_code)
              position[:nomenclature_code] = position[:nomenclature_code] ? Base64.strict_encode64(position[:nomenclature_code]) : nil
            end
          end
        end

        if payload.dig(:content, :check_close, :payments)
          payload[:content][:check_close][:payments].each do |payment|
            payment[:type] = @config.payment_types[payment[:type]] || payment[:type]
          end
        end

        payload
      end

      def orange_data_keys
        @orange_data_keys ||= {
          check_close: :checkClose,
          customer_contact: :customerContact,
          agent_type: :agentType,
          payment_transfer_operator_phone_numbers: :paymentTransferOperatorPhoneNumbers,
          payment_agent_operation: :paymentAgentOperation,
          payment_agent_phone_numbers: :paymentAgentPhoneNumbers,
          payment_operator_phone_numbers: :paymentOperatorPhoneNumbers,
          payment_operator_name: :paymentOperatorName,
          payment_operator_address: :paymentOperatorAddress,
          payment_operator_inn: :paymentOperatorINN,
          supplier_phone_numbers: :supplierPhoneNumbers,
          additional_user_attribute: :additionalUserAttribute,
          automat_number: :automatNumber,
          settlement_address: :settlementAddress,
          settlement_place: :settlementPlace,
          payment_method_type: :paymentMethodType,
          payment_subject_type: :paymentSubjectType,
          nomenclature_code: :nomenclatureCode,
          supplier_info: :supplierInfo,
          supplier_inn: :supplierINN,
          taxation_system: :taxationSystem,
          phone_numbers: :phoneNumbers,
          device_sn: :deviceSN,
          device_rn: :deviceRN,
          fs_number: :fsNumber,
          ofd_name: :ofdName,
          odf_website: :odfWebsite,
          odf_inn: :odfINN,
          fns_website: :fnsWebsite,
          company_inn: :companyINN,
          company_name: :companyName,
          document_number: :documentNumber,
          shift_number: :shiftNumber,
          document_index: :documentIndex,
          processed_at: :processedAt,
          correction_type: :correctionType,
          cause_document_date: :causeDocumentDate,
          cause_document_number: :causeDocumentNumber,
          total_sum: :totalSum,
          cash_sum: :cashSum,
          e_cash_sum: :eCashSum,
          prepayment_sum: :prepaymentSum,
          postpayment_sum: :postpaymentSum,
          other_payment_type_sum: :otherPaymentTypeSum,
          tax1_sum: :tax1Sum,
          tax2_sum: :tax2Sum,
          tax3_sum: :tax3Sum,
          tax4_sum: :tax4Sum,
          tax5_sum: :tax5Sum,
          tax6_sum: :tax6Sum
        }.freeze
      end
    end

    Faraday::Request.register_middleware(process_request_body: ProcessRequestBody)
  end
end
