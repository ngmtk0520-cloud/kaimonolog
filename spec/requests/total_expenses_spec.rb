require 'rails_helper'

RSpec.describe "TotalExpenses", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/total_expenses/index"
      expect(response).to have_http_status(:success)
    end
  end

end
