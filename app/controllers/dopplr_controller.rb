class DopplrController < ApplicationController
    def index
      d = Dopplr.new
      #puts d.login_url("http://localhost:3000/dopplr/")
      d.set_token('15d5b1fcc65130c57b54a0a04ea0a51f')
      session = d.upgrade_to_session
      d.set_token(session)
      pp d.traveller_info(:id => 'Jorgezapico')['traveller']
  end
end