require 'rails_helper'

RSpec.describe Api::V1::JsonWebToken do
  describe '#encode' do
    it 'encode payload' do
      expect(JsonWebToken.encode({ token: 'lol' }, 99_999_999_999_999_999)).to eq 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbiI6ImxvbCIsImV4cCI6OTk5OTk5OTk5OTk5OTk5OTl9.B5MMkwWUyUMn_IeTUzEzSuyMD7hL9uSxA7HMxwH4e4s'
    end
  end

  describe '#decode' do
    context 'with valid token' do
      let!(:token) { 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbiI6ImxvbCIsImV4cCI6OTk5OTk5OTk5OTk5OTk5OTl9.B5MMkwWUyUMn_IeTUzEzSuyMD7hL9uSxA7HMxwH4e4s' }
      let!(:result) { { 'token' => 'lol', 'exp' => 99_999_999_999_999_999 } }

      it 'decode token' do
        expect(JsonWebToken.decode(token)).to eq result
      end
    end

    context 'with expired token' do
      let!(:token) { 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbiI6ImxvbCIsImV4cCI6MTIzfQ.5jn-MEFLrB_gcK0bTA4W5CxWiFw8bpGIrClJ6avE6aE' }

      it 'decode token' do
        expect(JsonWebToken.decode(token)).to eq nil
      end
    end
  end
end
