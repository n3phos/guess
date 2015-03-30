
require 'spec_helper'
require 'rails_helper'

describe RoomsController, :type => :controller do
  describe "GET #join" do
    it "renders the :join view" do

      get :join
      response.should render_template :index
    end

  end
end
