# frozen_string_literal: true

module OrangeData
  class Configuration
    class WrongRSAKeyParams < StandardError;
    end

    attr_accessor :debug,
                  :api_url,
                  :api_path,
                  :api_key,
                  :inn,
                  :group,
                  :agent_type,
                  :payment_transfer_operator_phone_numbers,
                  :payment_agent_operation,
                  :payment_agent_phone_numbers,
                  :payment_operator_phone_numbers,
                  :payment_operator_name,
                  :payment_operator_address,
                  :payment_operator_inn,
                  :supplier_phone_numbers,
                  :additional_user_attribute,
                  :automat_number,
                  :settlement_address,
                  :settlement_place,
                  :taxation_system,
                  :receipt_type,
                  :tax,
                  :payment_method_type,
                  :payment_subject_type,

                  :receipt_types,
                  :agent_types,
                  :tax_types,
                  :payment_method_types,
                  :payment_subject_types,
                  :taxation_system_types,
                  :payment_types

    attr_reader :organization_key,
                :orange_data_certificate,
                :orange_data_key

    def initialize
      @debug = false
      @api_url = 'https://api.orangedata.ru:12003'
      @api_path = '/api/v2'
      @payment_transfer_operator_phone_numbers = []
      @payment_agent_phone_numbers = []
      @payment_operator_phone_numbers = []
      @supplier_phone_numbers = []
      @group = 'Main'
      @receipt_types = {
        income: 1, # Приход
        return_income: 2, # Возврат прихода
        expenditure: 3, # Расход
        return_expense: 4 # Возврат расхода
      }

      @agent_types = {
        bank_payment_agent: 0, # банковский платежный агент
        bank_payment_subagent: 1, # банковский платежный субагент
        payment_agent: 2, # платежный агент
        payment_subagent: 3, # платежный субагент
        attorney: 4, # поверенный
        commission_agent: 5, # комиссионер
        other_agent: 6 # иной агент
      }
      @tax_types = {
        vat_20: 1, # ставка НДС 20%
        vat_10: 2, # ставка НДС 10%
        vat_20_120: 3, # ставка НДС расч. 20/120
        vat_10_110: 4, # ставка НДС расч. 10/110
        vat_0: 5, # ставка НДС 0%
        vat_not_charged: 6 # НДС не облагается
      }
      @payment_method_types = {
        full_prepayment: 1, # Предоплата 100%
        partial_prepayment: 2, # Частичная предоплата
        advance_payment: 3, # Аванс
        full_calculation: 4, # Полный расчет
        partial_calculation_and_credit: 5, # Частичный расчет и кредит
        transfer_on_credit: 6, # Передача в кредит
        credit_payment: 7 # оплата кредита
      }
      @payment_subject_types = {
        goods: 1, # Товар
        excisable_goods: 2, # Подакцизный товар
        work: 3, # Работа
        service: 4, # Услуга
        gambling_bet: 5, # Ставка азартной игры
        gambling_winning: 6, # Выигрыш азартной игры
        lottery_ticket: 7, # Лотерейный билет
        lottery_winning: 8, # Выигрыш лотереи
        provision_rid: 9, # Предоставление РИД
        payment: 10, # Платеж
        agent_commission: 11, # Агентское вознаграждение
        compound_calculation: 12, # Составной предмет расчета
        other: 13 # Иной предмет расчета
      }
      @taxation_system_types = {
        osn: 0, # Общая
        usn: 1, # Упрощенная доход
        usn_revenue_minus_consumption: 2, # Упрощенная доход минус расход
        envd: 3, # Единый налог на вмененный доход
        esn: 4, # Единый сельскохозяйственный налог
        patent: 5 # Патентная система налогообложения
      }
      @payment_types = {
        cash: 1, # сумма по чеку наличными, 1031
        card: 2, # сумма по чеку электронными, 1081
        prepayment: 14, # сумма по чеку предоплатой (зачетом аванса и (или) предыдущих платежей), 1215
        postpayment: 15, # сумма по чеку постоплатой (в кредит), 1216
        counterclaims: 16 # сумма по чеку (БСО) встречным предоставлением, 1217
      }
    end

    def organization_key=(credentials)
      @organization_key = get_rsa_key(credentials)
    end

    def orange_data_key=(credentials)
      @orange_data_key = get_rsa_key(credentials)
    end

    def orange_data_certificate=(str)
      @orange_data_certificate = OpenSSL::X509::Certificate.new(str)
    end

    private

    def get_rsa_key(credentials)
      case credentials
      when Array
        key, password = credentials
        OpenSSL::PKey::RSA.new(key, password)
      when String
        OpenSSL::PKey::RSA.new(credentials)
      else
        raise WrongRSAKeyParams, credentials.inspect
      end
    end
  end
end
